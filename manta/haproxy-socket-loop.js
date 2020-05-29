/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/*
 * Copyright 2019 Joyent, Inc.
 */

/*jsl:ignore*/
'use strict';
/*jsl:end*/

const FSM = require('mooremachine').FSM;
const mod_fs = require('fs');
const mod_assert = require('assert-plus');
const mod_forkexec = require('forkexec');
const mod_bunyan = require('bunyan');
const mod_net = require('net');
const mod_util = require('util');
const mod_vasync = require('vasync');
const VError = require('verror');

/* These should be kept in sync with haproxy.cfg.in / haproxy.cfg.test */
const HAPROXY_SOCK_PATH = '/tmp/haproxy';
const HAPROXY_SOCK_PATH_TEST = '/tmp/haproxy.test';

const CONNECT_TIMEOUT = 3000;
const COMMAND_TIMEOUT = 30000;

/* Stats commands */
const HAPROXY_SERVER_STATS_COMMAND = 'show stat -1 4 -1';
const HAPROXY_ALL_STATS_COMMAND = 'show stat -1 7 -1';

function HaproxyCmdFSM(opts) {
    mod_assert.string(opts.command, 'opts.command');
    this.hcf_cmd = opts.command;

    mod_assert.object(opts.log, 'opts.log');
    this.hcf_log = opts.log;

    this.hcf_sockpath = process.env.MUPPET_TESTING === '1' ?
        HAPROXY_SOCK_PATH_TEST : HAPROXY_SOCK_PATH;

    this.hcf_sock = null;
    this.hcf_lastError = null;
    this.hcf_buf = '';

    FSM.call(this, 'connecting');
}
mod_util.inherits(HaproxyCmdFSM, FSM);

HaproxyCmdFSM.prototype.state_connecting = function (S) {
    var self = this;

    this.hcf_sock = mod_net.connect(self.hcf_sockpath);

    S.gotoStateOn(this.hcf_sock, 'connect', 'writing');
    S.on(this.hcf_sock, 'error', function (err) {
        self.hcf_lastError = new VError(err,
            'socket emitted error while connecting to %s',
            self.hcf_sockpath);
        S.gotoState('error');
    });
    S.timeout(CONNECT_TIMEOUT, function () {
        self.hcf_lastError = new VError(
            'timed out while connecting to %s',
            self.hcf_sockpath);
        S.gotoState('error');
    });
};

HaproxyCmdFSM.prototype.state_error = function (S) {
    var self = this;
    this.hcf_log.warn({ err: this.hcf_lastError, cmd: this.hcf_cmd },
        'haproxy command failed');
    S.immediate(function () {
        self.emit('error', self.hcf_lastError);
    });
};

HaproxyCmdFSM.prototype.state_writing = function (S) {
    this.hcf_log.trace({ cmd: this.hcf_cmd }, 'executing haproxy cmd');
    this.hcf_sock.write(this.hcf_cmd + '\n');
    this.hcf_sock.end();
    S.gotoState('reading');
};

HaproxyCmdFSM.prototype.state_reading = function (S) {
    var self = this;
    this.hcf_log.trace({ cmd: this.hcf_cmd }, 'waiting for results');
    S.on(this.hcf_sock, 'readable', function () {
        var chunk;
	self.hcf_log.warn('readable now');
        while ((chunk = self.hcf_sock.read()) !== null) {
            self.hcf_buf += chunk.toString('ascii');
	self.hcf_log.warn({buf: self.hcf_buf}, 'read chunk');
        }
	self.hcf_log.warn('read returned null');
    });
    S.on(this.hcf_sock, 'end', function () {
	self.hcf_log.warn('finished');
        S.gotoState('finished');
    });
    S.on(this.hcf_sock, 'error', function (err) {
        self.hcf_lastError = new VError(err,
            'socket emitted error while waiting for reply to command "%s"',
            self.hcf_cmd);
        S.gotoState('error');
    });
    S.timeout(COMMAND_TIMEOUT, function () {
        self.hcf_lastError = new VError(
            'timed out while executing command "%s"',
            self.hcf_cmd);
        S.gotoState('error');
    });
};

HaproxyCmdFSM.prototype.state_finished = function (S) {
    var self = this;
    this.hcf_log.trace({ cmd: this.hcf_cmd, result: this.hcf_buf },
        'command results received');
    S.immediate(function () {
        self.emit('result', self.hcf_buf);
    });
};

function serverStats(opts, cb) {
    statsCommon(opts, HAPROXY_SERVER_STATS_COMMAND, cb);
}
function allStats(opts, cb) {
    statsCommon(opts, HAPROXY_ALL_STATS_COMMAND, cb);
}

function statsCommon(opts, cmd, cb) {
    mod_assert.object(opts, 'options');
    mod_assert.string(cmd, 'cmd');
    mod_assert.func(cb, 'callback');
    mod_assert.object(opts.log, 'opts.log');

    var fsm = new HaproxyCmdFSM({
        command: cmd,
        log: opts.log
    });
    fsm.on('result', function (output) {
        var lines = output.split('\n');
        if (!/^#/.test(lines[0])) {
            cb(new VError('haproxy returned unexpected output: %j', output));
            return;
        }
        var headings = lines[0].slice(2).split(',');
        var objs = [];
        lines.slice(1).forEach(function (line) {
            var parts = line.split(',');
            if (parts.length < headings.length)
                return;
            var obj = {};
            for (var i = 0; i < parts.length; ++i) {
                if (parts[i].length > 0)
                    obj[headings[i]] = parts[i];
            }
            objs.push(obj);
        });
        cb(null, objs);
    });
    fsm.on('error', function (err) {
        cb(err);
    });
}

/*
 * We need to serialize the execution of all the exported functions. This is
 * required because all these functions use haproxy socket which can't be
 * accessed concurrently.
 */

var queue = mod_vasync.queue(function (task, qcb) {
    mod_assert.object(task, 'task');
    mod_assert.func(task.func, 'task.func');
    mod_assert.object(task.opts, 'task.opts');
    mod_assert.func(task.cb, 'task.cb');

    task.func(task.opts, function _cb(err, data) {
        task.cb(err, data);
        qcb();
    });
}, 1);


// serialize a given function
function serialize(func) {
    return (function (opts, cb) {
        var task = {
            func: func,
            opts: opts,
            cb: cb
        };
        queue.push(task);
    });
}


module.exports = {
    /* Exported for testing */
    /* Used by app.js */
    serverStats: serialize(serverStats),
    /* Used by metric_exporter.js */
    allStats: serialize(allStats)
};

    var log = mod_bunyan.createLogger({
        level: (process.env.LOG_LEVEL || 'info'),
        name: 'muppet',
        stream: process.stdout,
        serializers: {
            err: mod_bunyan.stdSerializers.err
        }
    });

var opts = {};
opts.log = log;

var count = 0;

mod_vasync.whilst(function() { return true; }, function (cb) {
    serverStats(opts, function (err) {
	    if (err) { console.log(err); process.exit(1); }
		count += 1;
		if (count === 1000) { process.exit(0); }
	    return cb();
	}); }, function (cb) {
    console.log(done);
});

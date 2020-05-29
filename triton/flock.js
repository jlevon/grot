/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/*
 * Copyright 2019 Joyent, Inc.
 */

/*
 * Verifies that when one process takes the same lock many times that the lock
 * is granted in the order in which it was requested.
 */

var qlocker = require('node-qlocker');
var vasync = require('/usr/vm/node_modules/vasync');
var fs = require('fs');

function _test(t) {
    var waiters = [];
    var max = 200;
    var path = 'intra_file';

    vasync.forEachParallel({
        'func': lockone,
        'inputs': [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]
    }, function (err, results) {
        if (err) {
            throw err;
        }
    });

    function lockone(waiter, next) {
        waiters.push(waiter);

        qlocker.lock(path, function locked(err, unlocker) {
            if (err) {
                throw err;
            }

            var delay;
            if (waiter === 0) {
                // The first waiter waits for all the others to make progress
                delay = 500;
            } else {
                // Others hold lock for a decreasing amount of time
                delay = (max - waiter) / 5;
            }

            setTimeout(function unlocking() {

                unlocker(function unlocked() {
                    next();
                });
            }, delay);
        });
    }
}

_test(null)

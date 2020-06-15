fs = require('fs');
util = require('util');

const readFile = util.promisify(fs.readFile);

async function etc_hosts() {
	f = await readFile("/etc/hosts");
	console.log(f.toString());
}


(async function () { await etc_hosts(); })();

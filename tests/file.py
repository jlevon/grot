#!/usr/bin/python

import os
import json
import tempfile
import time

f = ["test","yes"]
d = {
	"name":"John",
	"age":11,
	}
d["address"] = "11 house close"
d["total"] = ",".join(f)

o=  tempfile.TemporaryFile()

o.write(json.dumps(d,indent=4))
o.seek(0)
print("File contains:")

# child_fd = os.dup(o.fileno())
child_fd = o.fileno()
pid = os.fork()
if pid == 0:
	print("child " + str(child_fd))
	os.execv("main.out",["main.out",str(child_fd)])
else:
	time.sleep(5)
	o.close()

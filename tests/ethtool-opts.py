#!/usr/bin/python2.7

import getopt

rx = 0
tx = 0

current_values = "-G ${DEVICE} rx 64 ; -G ${DEVICE} tx   128 ; -A ${DEVICE} rx OFF tx OFF"
for current_opt in current_values.split(";"):
 try:
  args = getopt.getopt(current_opt .split(), "-G:")[1]
  vals = dict(zip(args[::2], args[1::2]))
  if vals.get("rx"):
    rx = vals["rx"]
  if vals.get("tx"):
    tx = vals["tx"]
 except:
  pass

print rx, tx

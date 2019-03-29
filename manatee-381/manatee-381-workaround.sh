#!/bin/bash

#
# As per the analysis in MANATEE-381, we will try to apply a temporary (not
# persisted on reboot) workaround in the hopes this helps the situation.
#

set -e

echo "k_anoninfo::print ; availrmem/D; segspt_minfree/D" | mdb -k
sysinfo -p | grep MiB_of_Memory
sysinfo -p | grep UUID

mem=$(sysinfo -p | grep MiB_of_Memory | cut -d= -f2)
availrmem=$(( $(echo availrmem/D  | mdb -k | cut -d: -f2) * 4096 ))

# 16 Gb
if [[ $mem -lt 16384 ]]; then
	echo "Low total mem: not doing anything" >&2
	exit 1
fi

# 4 Gb
if [[ $availrmem -lt 4294967296 ]]; then
	echo "Low availrmem: not doing anything" >&2
	exit 1
fi

echo "Set segspt_minfree to 1Gb: yes/no?"
read ans

if [[ "$ans" != "yes" ]]; then
	echo "not doing anything" >&2
	exit 1
fi

echo "segspt_minfree/z 0t262144" | mdb -kw

echo "done"

echo "k_anoninfo::print ; availrmem/D; segspt_minfree/D" | mdb -k

exit 0

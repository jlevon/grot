#!/bin/bash

count=$1

paths=$(mfind -t o /poseidon/stor/logs/ | head -$count)

i=0

set -e

while :; do
	echo "Start run $i $(date)"
	for path in $paths; do
		mget -q -o /dev/null $path &
	done
	echo "Waiting for mgets"
	wait
	echo "Done run $i $(date)"
	i=$(( i += 1 ))
done

#!/bin/bash

count=$1

set -e

echo "Preparing..."

for i in $(seq 0 $count); do
	mkfile 2m /var/tmp/lots-mput.$i &
done

wait

i=0

while :; do
	echo "Start run $i $(date)"
	for i in $(seq 0 $count); do
		mput -p -q -f /var/tmp/lots-mput.$i /poseidon/stor/lots-mput/$RANDOM/lots-mput.$i &
	done
	echo "Waiting for mputs"
	wait
	echo "Done run $i $(date)"
	i=$(( i += 1 ))
done

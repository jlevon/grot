#!/bin/bash

lb=$(vmadm list -H -o uuid tags.manta_role=loadbalancer)

bapis=$(vmadm list -Ho uuid tags.manta_role=buckets-api)
wapis=$(vmadm list -Ho uuid tags.manta_role=webapi)

echo "uuids: $bapis $wapis"

array=($bapis $wapis)
totalstr=$((${#array[@]}))

actions=("stop -f" "start" "reboot")
totalactions=$((${#actions[@]}))
while :; do
	while :; do
		randomnum=$(($(($RANDOM % $totalstr)) + 0))
		uuid=$(echo ${array[$randomnum]})

		randomnum=$(($(($RANDOM % $totalactions)) + 0))
		action=$(echo ${actions[$randomnum]})

		echo "vmadm $action $uuid"
		if vmadm $action $uuid; then
			break
		fi
	done

	date
	sleep 30

	svcs -Z $lb -xv manta/muppet
done

#!/bin/bash

lb=$(vmadm list -H -o uuid tags.manta_role=loadbalancer)

bapis=$(vmadm list -Ho uuid tags.manta_role=buckets-api)
wapis=$(vmadm list -Ho uuid tags.manta_role=webapi)

echo "uuids: $bapis $wapis"

array=($bapis $wapis)
totalstr=$((${#array[@]}))

actions=("stop -f" "start" "reboot")
totalactions=$((${#actions[@]}))
echo $totalstr
echo $totalactions
while :; do
	randomnum=$(($(($RANDOM % $totalstr)) + 0))
	echo $randomnum
	uuid=$(echo ${array[$randomnum]})

	randomnum=$(($(($RANDOM % $totalactions)) + 0))
	echo $randomnum
	action=$(echo ${actions[$randomnum]})

	echo "vmadm $action $uuid"
	date
	vmadm $action $uuid
	sleep 30

	svcs -Z $lb -xv manta/muppet
done

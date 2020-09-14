#!/bin/bash

vm=$1

set -e

function run() {
	iter=5

	while [ $iter -gt 0 ]; do
		count=5

		echo "--------------------------- $1 $iter --------------"
		if [ "$1" = "pinned" ]; then
			./bindings
		fi

		ssh -oBatchMode=yes $vm iperf -c 192.168.9.2 -w 2m -P4 -t 10 -i 1 >/dev/null || {
			echo "can't login" >&2
			exit 1
		}

		while [ $count -gt 0 ]; do
			ssh -oBatchMode=yes $vm iperf -c 192.168.9.2 -w 2m -P4 -t 10 -i 1
			let count-=1 || true
		done

		vmadm stop $vm
		vmadm start $vm
		sleep 30
		let iter-=1 || true
	done

	vmadm stop $vm
}

echo "---------------- unpinned ---------------------------"

vmadm stop $vm
zonecfg -z $vm remove attr name=bhyve-extra-opts || true
vmadm start $vm
sleep 30

run "unpinned"

echo "------------------ pinned ---------------------------"

vmadm stop $vm
echo 'add attr ; set name=bhyve-extra-opts; set type=string; set value="-p vcpus"; end' | zonecfg -z $vm
vmadm start $vm
sleep 30

run "pinned"

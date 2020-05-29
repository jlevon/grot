#!/bin/bash

vm=$1

set -e

function run() {
	iter=5

	while [ $iter -gt 0 ]; do
		count=5

		echo "--------------------------- $1 $iter --------------"
		sleep 3

		# the two viona_worker_tx threads, bind to socket 1, try again
		# if we end up with both a tx thread and a VCPU bound to a core
		# (even HT)
		pbind -b 30 $(pgrep bhyve)/26
		pbind -b 31 $(pgrep bhyve)/28
		if ./bindings | grep "b3.*b3" >/dev/null; then
			echo "double-bound: restarting"
			vmadm stop $vm
			vmadm start $vm
			continue
		fi

		sleep 20
		./bindings

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
		let iter-=1 || true
	done

	vmadm stop $vm
}

echo "---------------- unpinned tx ---------------------------"

vmadm stop $vm
zonecfg -z $vm remove attr name=bhyve-extra-opts || true
vmadm start $vm
sleep 30

run "tx-only pinned"

echo "------------------ pinned tx ---------------------------"

vmadm stop $vm
echo 'add attr ; set name=bhyve-extra-opts; set type=string; set value="-p vcpus"; end' | zonecfg -z $vm
vmadm start $vm
sleep 30

run "tx+vcpu pinned"

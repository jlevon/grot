#!/bin/bash

# should be run on bhyve with 16 VCPU, 32Gb RAM

vm=$1

set -e

cmd="cd /export/l_mklb_p_2018.2.010/benchmarks_2018/linux/mkl/benchmarks/linpack/ && ./runme_xeon64"

function run() {
	iter=3

	while [ $iter -gt 0 ]; do
		count=3

		echo "--------------------------- $1 $iter --------------"
		if [ "$1" = "pinned" ]; then
			./bindings
		fi

		while [ $count -gt 0 ]; do
			ssh -oBatchMode=yes $vm "$cmd"
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

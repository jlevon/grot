#!/bin/bash

(cd ~/src/spdk/ ;
sudo pkill -f -9 nvmf_tgt ;
sudo rm -f /var/run/cntrl ;
sudo ./build/bin/nvmf_tgt -L vfio_user -L nvmf_vfio --no-huge -s 1024 >spdk.log 2>&1 &
sleep 1
sudo chmod a+rwx /var/tmp/spdk.sock
scripts/rpc.py nvmf_create_transport -t VFIOUSER  && 	scripts/rpc.py bdev_malloc_create 512 512 -b Malloc0 && 	scripts/rpc.py nvmf_create_subsystem nqn.2019-07.io.spdk:cnode0 -a -s SPDK0 && 	scripts/rpc.py nvmf_subsystem_add_ns nqn.2019-07.io.spdk:cnode0 Malloc0 && 	scripts/rpc.py nvmf_subsystem_add_listener nqn.2019-07.io.spdk:cnode0 -t VFIOUSER -a /var/run -s 0
)

sudo pkill -f qemu-system-x86_64

sleep 1

sudo mkdir /dev/hugepages/spdk
sudo ~/src/qemu/build/qemu-system-x86_64 -D /tmp/qemu.log -machine accel=kvm,type=q35 \
   -cpu host -m 2G -mem-prealloc -object memory-backend-file,id=ram-node0,prealloc=yes,mem-path=/dev/hugepages/spdk,share=yes,size=2G \
   -numa node,memdev=ram-node0 \
   -nographic -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2222-:22 \
   -drive if=virtio,format=qcow2,file=/home/jlevon/bionic-server-cloudimg-amd64.img -drive if=virtio,format=raw,file=seed.img \
   -device vfio-user-pci,socket=/var/run/cntrl


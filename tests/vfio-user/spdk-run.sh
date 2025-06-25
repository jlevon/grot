#!/bin/bash

set -x

sudo -b pkill -f -9 nvmf_tgt
sudo -b pkill -f -9 reactor_0
sudo -b pkill -f qemu-system-x86_64

(cd ~/src/spdk/ ;
sudo -b rm -f /var/run/cntrl ;
sudo -b ./build/bin/nvmf_tgt -L vfio_user -L nvmf_vfio --no-huge -s 1024 >spdk.log 2>&1 </dev/null  &
sleep 1
sudo -b chmod a+rwx /var/tmp/spdk.sock
scripts/rpc.py nvmf_create_transport -t VFIOUSER  && 	scripts/rpc.py bdev_malloc_create 512 512 -b Malloc0 && 	scripts/rpc.py nvmf_create_subsystem nqn.2019-07.io.spdk:cnode0 -a -s SPDK0 && 	scripts/rpc.py nvmf_subsystem_add_ns nqn.2019-07.io.spdk:cnode0 Malloc0 && 	scripts/rpc.py nvmf_subsystem_add_listener nqn.2019-07.io.spdk:cnode0 -t VFIOUSER -a /var/run -s 0
)


sleep 1

# sudo -b mkdir -p /dev/hugepages/spdk

sudo -b ~/src/qemu.vfio-prep.v3/build/qemu-system-x86_64 --trace "vfio_user*" -D /tmp/qemu.log -machine accel=kvm,type=q35 \
   -cpu host -m 2G -mem-prealloc -object memory-backend-file,id=ram-node0,prealloc=yes,mem-path=/dev/hugepages/spdk,share=yes,size=2G \
   -numa node,memdev=ram-node0 \
   -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2222-:22 \
   -drive if=virtio,format=qcow2,file=/home/jlevon/bionic-server-cloudimg-amd64.img -drive if=virtio,format=raw,file=seed.img \
   -nographic -device '{"driver":"vfio-user-pci","socket":{"path": "/var/run/cntrl", "type": "unix"},"bus":"pcie.0","addr":"0x5"}'




#   -nographic -device vfio-user-pci,socket=/var/run/cntrl,bus=pcie.0,addr=0x03

#!/bin/bash


# modprobe vfio-pci
# sbdf=0000:00:08.0
# echo "vfio-pci" >/sys/bus/pci/devices/$sbdf/driver_override
# echo $sbdf >/sys/bus/pci/drivers/vfio-pci/bind

sudo ~/src/qemu.vfio-prep.v3/build/qemu-system-x86_64 -D qemu.log -machine accel=kvm,type=q35 \
   -cpu host -m 2G -mem-prealloc -object memory-backend-file,id=ram-node0,prealloc=yes,mem-path=/dev/hugepages/spdk,share=yes,size=2G \
   -numa node,memdev=ram-node0 \
   -nographic -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2222-:22 \
   -drive if=virtio,format=qcow2,file=/home/jlevon/bionic-server-cloudimg-amd64.img -drive if=virtio,format=raw,file=seed.img \
   -device vfio-pci,host=00:08.0,bus=pcie.0,addr=0x9

# ssh -p 2222 ubuntu@localhost

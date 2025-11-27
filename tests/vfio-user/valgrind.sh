#!/bin/bash

(cd ~/src/libvfio-user ;
rm -f /tmp/vfio-user.sock ;
./build/samples/gpio-pci-idio-16 -v /tmp/vfio-user.sock >/tmp/gpio.out 2>&1 &
)

sudo valgrind --leak-check=full --track-origins=yes --verbose ~/src/qemu/build/qemu-system-x86_64 -D qemu.log -machine accel=kvm,type=q35 \
   -cpu host -m 2G -mem-prealloc -object memory-backend-file,id=ram-node0,prealloc=yes,mem-path=/dev/hugepages/spdk,share=yes,size=2G \
   -numa node,memdev=ram-node0 \
   -nographic -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2222-:22 \
   -drive if=virtio,format=qcow2,file=/home/jlevon/bionic-server-cloudimg-amd64.img -drive if=virtio,format=raw,file=seed.img \
   -device vfio-user-pci,socket=/tmp/vfio-user.sock

#!/bin/bash

#(cd ~/src/libvfio-user ;
#rm -f /tmp/vfio-user.sock ;
#./build/samples/gpio-pci-idio-16 -v /tmp/vfio-user.sock >/tmp/gpio.out 2>&1 &
#)

# sudo ~/src/qemu.vfio-prep.v3/build/qemu-system-x86_64 --trace "vfio_user*" -D qemu.log -machine accel=kvm,type=q35 \
#
sudo ~/src/qemu/build/qemu-system-x86_64 -D qemu.log --trace "vfio_user*" -machine accel=kvm,type=q35 \
   -cpu host -m 2G -mem-prealloc -object memory-backend-file,id=ram-node0,prealloc=yes,mem-path=/dev/hugepages/spdk,share=yes,size=2G \
   -numa node,memdev=ram-node0 \
   -nographic -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp::3333-:22 \
   -drive if=virtio,format=qcow2,file=/home/jlevon/bionic-server-cloudimg-amd64.img -drive if=virtio,format=raw,file=seed.img \
   -device pcie-root-port,id=rp.0,bus=pcie.0,slot=2,chassis=1 \
   -device '{"driver":"vfio-user-pci","socket":{"path": "/tmp/vfio-user.sock", "type": "unix"},"bus":"rp.0","id":"jlevon0"}'

#   -device vfio-user-pci,socket=/tmp/vfio-user.sock,bus=pcie.0,addr=0x9
   # -device vfio-user-pci,socket.type=unix,socket.path=/tmp/vfio-user.sock,bus=pcie.0,addr=0x9

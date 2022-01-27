#!/bin/bash

set -e

# build qemu with vfio-user client support

cd ~/src

git clone https://github.com/oracle/qemu qemu-orcl
cd qemu-orcl
git reset --hard d377d483f9
git submodule update --init --recursive
./configure --enable-multiprocess
make

# build SPDK with interrupt mode and shadow doorbell support

cd ~/src

git clone https://github.com/jlevon/spdk spdk-doorbells
cd spdk-doorbells
git co shadow-doorbells
git submodule update --init --recursive
./configure --with-vfio-user --enable-debug
make

# start SPDK app

sudo ./scripts/setup.sh
sudo ./build/examples/interrupt_tgt -L nvmf_vfio  -L bdev -L bdev_malloc -L nvmf -L app_rpc -E

# create vfio-user listener, with a single malloc bdev namespace

sudo rm -f /var/run/{cntrl,bar0}
sudo ~/src/spdk-doorbells/scripts/rpc.py nvmf_create_transport -t VFIOUSER -M
sudo ~/src/spdk-doorbells/scripts/rpc.py bdev_malloc_create 512 512 -b Malloc0
sudo ~/src/spdk-doorbells/scripts/rpc.py nvmf_create_subsystem nqn.2019-07.io.spdk:cnode0 -a -s SPDK0
sudo ~/src/spdk-doorbells/scripts/rpc.py nvmf_subsystem_add_ns nqn.2019-07.io.spdk:cnode0 Malloc0
sudo ~/src/spdk-doorbells/scripts/rpc.py nvmf_subsystem_add_listener nqn.2019-07.io.spdk:cnode0 -t VFIOUSER -a /var/run -s 0

# start Windows installer

iso=~/windows.iso

sudo ~/src/qemu-orcl/build/qemu-system-x86_64 -machine q35 -m 1G \
 -object memory-backend-file,id=mem0,size=1G,mem-path=/dev/hugepages,share=on,prealloc=yes \
 -numa node,memdev=mem0  -device vfio-user-pci,socket=/var/run/cntrl -enable-kvm \
 -net nic,model=rtl8139  -net user,hostname=windowsvm -boot d -drive file=$iso,media=cdrom

# repair, drop into cmd prompt, then:
# diskpart
# select disk 0
# create partition primary
# format fs=ntfs

# test linux like this for example:

# sudo ~/src/qemu-orcl/build/qemu-system-x86_64 -machine q35 -m 1G -object memory-backend-file,id=mem0,size=1G,mem-path=/dev/hugepages,share=on,prealloc=yes -numa node,memdev=mem0  -device vfio-user-pci,socket=/var/run/cntrl  -enable-kvm   -net nic,model=rtl8139  -net user,hostname=windowsvm -boot d -drive file=~/src/isos/ubuntu-20.04.1-live-server-amd64.iso,media=cdrom

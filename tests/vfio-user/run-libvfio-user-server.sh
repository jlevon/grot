#!/bin/bash

#(cd ~/src/libvfio-user ;
#m -f /tmp/vfio-user.sock ;
#/build/samples/gpio-pci-idio-16 -v /tmp/vfio-user.sock >/tmp/gpio.out 2>&1 &
#

# sudo ~/src/qemu.vfio-prep.v3/build/qemu-system-x86_64 --trace "vfio_user*" -D qemu.log -machine accel=kvm,type=q35 \
#
   #-nographic \


# login over ssh with jlevon user
# become root
#
# then
#
# ./libvfio-user/build/samples/gpio-pci-idio-16  -v /tmp/vfio-user.sock &
#
# socat UNIX-CONNECT:/tmp/vfio-user.sock /dev/vport3p1,ignoreeof

sudo ~/src/qemu/build/qemu-system-x86_64 -D server-qemu.log --trace "vfio_user*" -machine accel=kvm,type=q35 \
   -cpu host -m 2G -mem-prealloc -object memory-backend-file,id=ram-node0,prealloc=yes,mem-path=/dev/hugepages/spdk,share=yes,size=2G \
   -numa node,memdev=ram-node0 \
 -nographic \
 -serial mon:stdio \
-device \
'{"driver":"pcie-root-port","port":16,"chassis":1,"id":"pci.1","bus":"pcie.0","multifunction":true,"addr":"0x2"}' \
-device \
'{"driver":"pcie-root-port","port":17,"chassis":2,"id":"pci.2","bus":"pcie.0","addr":"0x2.0x1"}' \
-device \
'{"driver":"pcie-root-port","port":18,"chassis":3,"id":"pci.3","bus":"pcie.0","addr":"0x2.0x2"}' \
-device \
'{"driver":"pcie-root-port","port":19,"chassis":4,"id":"pci.4","bus":"pcie.0","addr":"0x2.0x3"}' \
-device \
'{"driver":"pcie-root-port","port":20,"chassis":5,"id":"pci.5","bus":"pcie.0","addr":"0x2.0x4"}' \
-device \
'{"driver":"pcie-root-port","port":21,"chassis":6,"id":"pci.6","bus":"pcie.0","addr":"0x2.0x5"}' \
-device \
'{"driver":"pcie-root-port","port":22,"chassis":7,"id":"pci.7","bus":"pcie.0","addr":"0x2.0x6"}' \
-device \
'{"driver":"pcie-root-port","port":23,"chassis":8,"id":"pci.8","bus":"pcie.0","addr":"0x2.0x7"}' \
-device \
'{"driver":"pcie-root-port","port":24,"chassis":9,"id":"pci.9","bus":"pcie.0","multifunction":true,"addr":"0x3"}' \
-device \
'{"driver":"pcie-root-port","port":25,"chassis":10,"id":"pci.10","bus":"pcie.0","addr":"0x3.0x1"}' \
-device \
'{"driver":"pcie-root-port","port":26,"chassis":11,"id":"pci.11","bus":"pcie.0","addr":"0x3.0x2"}' \
-device \
'{"driver":"pcie-root-port","port":27,"chassis":12,"id":"pci.12","bus":"pcie.0","addr":"0x3.0x3"}' \
-device \
'{"driver":"pcie-root-port","port":28,"chassis":13,"id":"pci.13","bus":"pcie.0","addr":"0x3.0x4"}' \
-device \
'{"driver":"pcie-root-port","port":29,"chassis":14,"id":"pci.14","bus":"pcie.0","addr":"0x3.0x5"}' \
-device \
'{"driver":"qemu-xhci","p2":15,"p3":15,"id":"usb","bus":"pci.2","addr":"0x0"}' \
-blockdev \
'{"driver":"file","filename":"/var/lib/libvirt/images/ubuntu20.04.qcow2","node-name":"libvirt-2-storage","auto-read-only":true,"discard":"unmap"}' \
-blockdev \
'{"node-name":"libvirt-2-format","read-only":false,"discard":"unmap","driver":"qcow2","file":"libvirt-2-storage","backing":null}' \
-device \
'{"driver":"virtio-blk-pci","bus":"pci.4","addr":"0x0","drive":"libvirt-2-format","id":"virtio-disk0","bootindex":1}' \
-device \
'{"driver":"virtio-balloon-pci","id":"balloon0","bus":"pci.5","addr":"0x0"}' \
-device \
'{"driver":"virtio-net-pci","netdev":"net0","bus":"pci.6","addr":"0x0"}' \
-netdev \
 user,id=net0,hostfwd=tcp::2222-:22 \
-device \
'{"driver":"virtio-serial-pci","id":"virtio-serial0","bus":"pci.8","addr":"0x0"}' \
-chardev socket,id=sock0,path=/tmp/vfio-user.sock,telnet=off,server=on,wait=off \
-device '{"driver":"virtserialport","chardev":"sock0","name":"org.fedoraproject.port.0"}' \


#-device virtio-serial \

exit 0

sudo /usr/bin/qemu-system-x86_64 \
-name \
guest=ubuntu20.04,debug-threads=on \
-S \
-machine \
pc-q35-8.2,usb=off,vmport=off,dump-guest-core=off,memory-backend=pc.ram,hpet=off,acpi=on \
-accel \
kvm \
-cpu \
host,migratable=on \
-m \
size=4194304k \
-object \
'{"qom-type":"memory-backend-ram","id":"pc.ram","size":4294967296}' \
-overcommit \
mem-lock=off \
-smp \
2,sockets=2,cores=1,threads=1 \
-uuid \
36148ac8-b632-4786-a051-87c0226a9703 \
-no-user-config \
-nodefaults \
-rtc \
base=utc,driftfix=slew \
-global \
kvm-pit.lost_tick_policy=delay \
-no-shutdown \
-global \
ICH9-LPC.disable_s3=1 \
-global \
ICH9-LPC.disable_s4=1 \
-boot \
strict=on \
-device \
'{"driver":"pcie-root-port","port":16,"chassis":1,"id":"pci.1","bus":"pcie.0","multifunction":true,"addr":"0x2"}' \
-device \
'{"driver":"pcie-root-port","port":17,"chassis":2,"id":"pci.2","bus":"pcie.0","addr":"0x2.0x1"}' \
-device \
'{"driver":"pcie-root-port","port":18,"chassis":3,"id":"pci.3","bus":"pcie.0","addr":"0x2.0x2"}' \
-device \
'{"driver":"pcie-root-port","port":19,"chassis":4,"id":"pci.4","bus":"pcie.0","addr":"0x2.0x3"}' \
-device \
'{"driver":"pcie-root-port","port":20,"chassis":5,"id":"pci.5","bus":"pcie.0","addr":"0x2.0x4"}' \
-device \
'{"driver":"pcie-root-port","port":21,"chassis":6,"id":"pci.6","bus":"pcie.0","addr":"0x2.0x5"}' \
-device \
'{"driver":"pcie-root-port","port":22,"chassis":7,"id":"pci.7","bus":"pcie.0","addr":"0x2.0x6"}' \
-device \
'{"driver":"pcie-root-port","port":23,"chassis":8,"id":"pci.8","bus":"pcie.0","addr":"0x2.0x7"}' \
-device \
'{"driver":"pcie-root-port","port":24,"chassis":9,"id":"pci.9","bus":"pcie.0","multifunction":true,"addr":"0x3"}' \
-device \
'{"driver":"pcie-root-port","port":25,"chassis":10,"id":"pci.10","bus":"pcie.0","addr":"0x3.0x1"}' \
-device \
'{"driver":"pcie-root-port","port":26,"chassis":11,"id":"pci.11","bus":"pcie.0","addr":"0x3.0x2"}' \
-device \
'{"driver":"pcie-root-port","port":27,"chassis":12,"id":"pci.12","bus":"pcie.0","addr":"0x3.0x3"}' \
-device \
'{"driver":"pcie-root-port","port":28,"chassis":13,"id":"pci.13","bus":"pcie.0","addr":"0x3.0x4"}' \
-device \
'{"driver":"pcie-root-port","port":29,"chassis":14,"id":"pci.14","bus":"pcie.0","addr":"0x3.0x5"}' \
-device \
'{"driver":"qemu-xhci","p2":15,"p3":15,"id":"usb","bus":"pci.2","addr":"0x0"}' \
-device \
'{"driver":"virtio-serial-pci","id":"virtio-serial0","bus":"pci.3","addr":"0x0"}' \
-blockdev \
'{"driver":"file","filename":"/var/lib/libvirt/images/ubuntu20.04.qcow2","node-name":"libvirt-2-storage","auto-read-only":true,"discard":"unmap"}' \
-blockdev \
'{"node-name":"libvirt-2-format","read-only":false,"discard":"unmap","driver":"qcow2","file":"libvirt-2-storage","backing":null}' \
-device \
'{"driver":"virtio-blk-pci","bus":"pci.4","addr":"0x0","drive":"libvirt-2-format","id":"virtio-disk0","bootindex":1}' \
-device \
'{"driver":"ide-cd","bus":"ide.0","id":"sata0-0-0"}' \
-device \
'virtio-net-pci,netdev=net0,addr=0x4' \
-netdev \
'user,id=net0,hostfwd=tcp::2222-:22' \
-chardev \
pty,id=charserial0 \
-device \
'{"driver":"isa-serial","chardev":"charserial0","id":"serial0","index":0}' \
-chardev \
spicevmc,id=charchannel1,name=vdagent \
-device \
'{"driver":"virtserialport","bus":"virtio-serial0.0","nr":2,"chardev":"charchannel1","id":"channel1","name":"com.redhat.spice.0"}' \
-device \
'{"driver":"usb-tablet","id":"input0","bus":"usb.0","port":"1"}' \
-audiodev \
'{"id":"audio1","driver":"spice"}' \
-spice \
port=5900,addr=127.0.0.1,disable-ticketing=on,image-compression=off,seamless-migration=on \
-device \
'{"driver":"virtio-vga","id":"video0","max_outputs":1,"bus":"pcie.0","addr":"0x1"}' \
-device \
'{"driver":"ich9-intel-hda","id":"sound0","bus":"pcie.0","addr":"0x1b"}' \
-device \
'{"driver":"hda-duplex","id":"sound0-codec0","bus":"sound0.0","cad":0,"audiodev":"audio1"}' \
-global \
ICH9-LPC.noreboot=off \
-watchdog-action \
reset \
-chardev \
spicevmc,id=charredir0,name=usbredir \
-device \
'{"driver":"usb-redir","chardev":"charredir0","id":"redir0","bus":"usb.0","port":"2"}' \
-chardev \
spicevmc,id=charredir1,name=usbredir \
-device \
'{"driver":"usb-redir","chardev":"charredir1","id":"redir1","bus":"usb.0","port":"3"}' \
-device \
'{"driver":"virtio-balloon-pci","id":"balloon0","bus":"pci.5","addr":"0x0"}' \
-object \
'{"qom-type":"rng-random","id":"objrng0","filename":"/dev/urandom"}' \
-device \
'{"driver":"virtio-rng-pci","rng":"objrng0","id":"rng0","bus":"pci.6","addr":"0x0"}' \
-sandbox \
on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \
-msg \
timestamp=on


#-netdev \
#'{"type":"tap","fd":"33","vhost":true,"vhostfd":"36","id":"hostnet0"}' \
#-device \
#'{"driver":"virtio-net-pci","netdev":"hostnet0","id":"net0","mac":"52:54:00:2d:95:5b","bus":"pci.1","addr":"0x0"}' \
#-object \
#'{"qom-type":"secret","id":"masterKey0","format":"raw","file":"/var/lib/libvirt/qemu/domain-1-ubuntu20.04/master-key.aes"}' \
#-chardev \
#socket,id=charmonitor,fd=32,server=on,wait=off \
# -mon \
# chardev=charmonitor,id=monitor,mode=control \
#-chardev \
#socket,id=charchannel0,fd=31,server=on,wait=off \
#-device \
#'{"driver":"virtserialport","bus":"virtio-serial0.0","nr":1,"chardev":"charchannel0","id":"channel0","name":"org.qemu.guest_agent.0"}' \

#   -drive if=virtio,format=qcow2,file=/home/jlevon/bionic-server-cloudimg-amd64.img -drive if=virtio,format=raw,file=seed.img \

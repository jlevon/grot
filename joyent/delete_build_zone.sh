#!/bin/bash

name=$1

# FIXME : doesn't clean up IP

vnic=${name}0

#set -e
set -x

zoneadm -z $name halt
zoneadm -z $name uninstall -F
zonecfg -z $name delete -F
zfs destroy -r zones/$name

dladm delete-vnic $vnic

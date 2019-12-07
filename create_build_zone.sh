#!/bin/bash

name=$1
next=$(cat /opt/etc/next_ip)
ip=172.26.7.$next

vnic=${name}0

set -e
set -x

zonecfg -z $name -f - <<EOF
create ;
set zonepath=/zones/$name;
set ip-type=exclusive;
add net; set physical=$vnic ; end ;
add dataset ; set name=zones/$name/export ; end ;
EOF

dladm create-vnic -l ixgbe1 -v 3307 $vnic
zoneadm -z $name install
zoneadm -z $name boot

sleep 60

zlogin $name ipadm create-addr -T static -a local=$ip/24 $vnic/v4
zlogin $name route -p add default 172.26.7.1

echo $(( $next + 1 )) >/opt/etc/next_ip

echo "nameserver 8.8.8.8" >/zones/$name/root/etc/resolv.conf
echo "nameserver 8.8.4.4" >>/zones/$name/root/etc/resolv.conf
cp /zones/$name/root/etc/nsswitch.dns /zones/$name/root/etc/nsswitch.conf

zlogin $name zfs set mountpoint=/export zones/$name/export

zlogin $name useradd -d /export/home/gk -P \"Primary Administrator\" gk
mkdir -p /zones/$name/root/export/home/gk
zlogin $name chown gk /export/home/gk
cat /zones/$name/root/etc/shadow | grep -v ^gk >/tmp/shadow.$$
grep '^gk' /etc/shadow >>/tmp/shadow.$$
mv /tmp/shadow.$$ /zones/$name/root/etc/shadow

echo "export PATH=\$PATH:/opt/onbld/bin/:/opt/bin:/usr/node/0.12/bin/:/usr/sbin:/export/home/gk/node_modules/.bin/" >>/zones/$name/root/export/home/gk/.bash_profile
echo "export MANPATH=\$MANPATH:/opt/onbld/man:/opt/share/man" >>/zones/$name/root/export/home/gk/.bash_profile

zlogin $name pkg install git exuberant-ctags build-essential runtime/python-35 developer/gcc-7 nodejs
zlogin $name npm install -g manta

zlogin -l gk $name git clone https://github.com/illumos/illumos-gate.git

# redmine cli is stupid, needs config.json writable in install path
zlogin -l gk $name npm install redmine-cli

cp -r /opt/* /zones/$name/root/opt
cp /opt/etc/illumos.sh /zones/$name/root/export/home/gk/
zlogin $name chown gk /export/home/gk/illumos.sh
zlogin -l gk $name cp illumos-gate/usr/src/tools/scripts/nightly.sh .
zlogin -l gk $name chmod +x nightly.sh

echo
echo
echo "Done: log in as gk@$ip"

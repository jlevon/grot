#!/bin/bash

set -o xtrace

# lazy usage message and args parsing
if [[ "$#" -ne 1 || $(echo $* | egrep -e '-h' -e 'help') ]]; then
        echo "Usage: update-image  [headnode ssh address]"
        exit 2
fi

if [[ -z "$1" ]]; then
        HEADNODE=root@coal
else
        HEADNODE=$1
fi

set -e

make all buildimage prepublish

NAME=$(make print-NAME 2>/dev/null | cut -d= -f2)
BITSPATH=bits/$NAME
STAMP=$(cat $BITSPATH/latest-build-stamp)

ZFS=$BITSPATH/$NAME-zfs-$STAMP.zfs.gz
MF=$BITSPATH/$NAME-zfs-$STAMP.imgmanifest

UUID=$(json uuid <$MF)
ROLE=$(json name <$MF | sed 's+manta-++')

scp $ZFS $MF $HEADNODE:/tmp/
ssh $HEADNODE /opt/smartdc/bin/sdc-imgadm import -f /tmp/$(basename $ZFS) -m /tmp/$(basename $MF)

ssh $HEADNODE /opt/smartdc/bin/sdcadm update -y $ROLE@$UUID || {
        #
        # Manta updates are handled by manta-adm rather than sdcadm
        #
        echo "Image update failed, perhaps this is a manta image?"

	HN_UUID=$(ssh $HEADNODE /opt/smartdc/bin/sdc-cnapi --no-headers /servers | json -a -c 'hostname == "headnode"' uuid)
	CURRENT_UUID=$(ssh $HEADNODE /opt/smartdc/bin/manta-adm show -js | json $HN_UUID.$ROLE | json -ka)

	ssh $HEADNODE "/opt/smartdc/bin/manta-adm show -js | sed "s+$CURRENT_UUID+$UUID+" >/tmp/manta.json"
	ssh $HEADNODE "/opt/smartdc/bin/manta-adm update -l /dev/stdout -y /tmp/manta.json 2>&1 | bunyan"
}

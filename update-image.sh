#!/bin/bash

set -o xtrace

# lazy usage message and args parsing
if [[ "$#" -ne 1 || $(echo $* | egrep -e '-h' -e 'help') ]]; then
        echo "Usage: update-image headnode"
        exit 2
fi

if [[ -z "$1" ]]; then
        HEADNODE=root@coal
else
        HEADNODE=root@$1
fi

set -e

eval $(make print-NAME)
BITSPATH=bits/$NAME

if [[ "$NAME" == "sdcadm" ]]; then
	make all publish
	STAMP=$(cat $BITSPATH/latest-build-stamp)
	FILE=$BITSPATH/$NAME-$STAMP.sh
	MF=$BITSPATH/$NAME-$STAMP.imgmanifest
else
	make all buildimage publish
	STAMP=$(cat $BITSPATH/latest-build-stamp)
	FILE=$BITSPATH/$NAME-zfs-$STAMP.zfs.gz
	MF=$BITSPATH/$NAME-zfs-$STAMP.imgmanifest
fi

UUID=$(json uuid <$MF)
ROLE=$(json name <$MF | sed 's+manta-++')

if [[ "$ROLE" = "deployment" ]]; then
	ROLE=manta0
fi

scp $FILE $MF $HEADNODE:/tmp/

if [[ "$NAME" == "sdcadm" ]]; then
	ssh $HEADNODE /opt/smartdc/bin/sdc-imgadm import -c none -f /tmp/$(basename $FILE) -m /tmp/$(basename $MF)
	IMGAPI=$(ssh $HEADNODE /opt/smartdc/bin/sdc-sapi --no-headers /services?name=imgapi | json -a metadata.SERVICE_DOMAIN)
	ssh $HEADNODE /opt/smartdc/bin/sdcadm self-update -S http://$IMGAPI $UUID
	exit 0
fi

ssh $HEADNODE /opt/smartdc/bin/sdc-imgadm import -f /tmp/$(basename $FILE) -m /tmp/$(basename $MF)

ssh $HEADNODE /opt/smartdc/bin/sdcadm update -y $ROLE@$UUID && exit 0

#
# Manta updates are handled by manta-adm rather than sdcadm
#
echo "Image update failed, trying as a manta image instead"


MROLE=${ROLE/mantav?-/}

ssh $HEADNODE "/opt/smartdc/bin/manta-adm show -js >/tmp/manta.json"

HN_UUID=$(ssh $HEADNODE /opt/smartdc/bin/sdc-cnapi --no-headers /servers | json -a -c 'hostname == "headnode"' uuid)
CURRENT_UUID=$(ssh $HEADNODE cat /tmp/manta.json | json $HN_UUID.$MROLE | json -ka)

ssh $HEADNODE "sed -i\"\" -e s+$CURRENT_UUID+$UUID+ /tmp/manta.json"
ssh $HEADNODE "/opt/smartdc/bin/manta-adm update --skip-verify-channel --experimental -l /dev/stdout -y /tmp/manta.json 2>&1 | bunyan"

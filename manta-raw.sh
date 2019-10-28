#!/bin/bash

# this can only support old-style fingerprints (MD5:a0:cf:... etc)

insecure="--insecure"
alg=rsa-sha256
#set -x

trimmed_key=$(echo $MANTA_KEY_ID | sed 's/^SHA256://' | sed 's/^MD5://')
keyId=/$MANTA_USER/keys/$trimmed_key
now="date: $(date -u "+%a, %d %h %Y %H:%M:%S GMT")"
#sig=$(echo -n $now | openssl dgst -sha256 -sign $MANTA_KEY_PATH | \
#          openssl enc -e -a | tr -d '\n')
sig2=$(echo -n "$now" | manta-sign | tr -d '\n')

#echo $sig2
sig=$sig2

#echo curl -sS $insecure $MANTA_URL"$@" -H "$now" -H "Authorization: Signature keyId=\"$keyId\",algorithm=\"$alg\",signature=\"$sig\""
curl -sS $insecure $MANTA_URL"$@" -H "$now" -H "Authorization: Signature keyId=\"$keyId\",algorithm=\"$alg\",signature=\"$sig\""

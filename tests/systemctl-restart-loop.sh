#!/bin/bash

host=$1
svc=$2
set -x

while :; do
    date
    ssh $host systemctl restart $svc
    sleep 5
    ssh $host systemctl -q is-failed $svc && {
           echo "$svc failed ??"
        exit 1
    }
done

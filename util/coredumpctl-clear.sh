#!/bin/bash

# systemd, you suck, badly.

while coredumpctl list >/dev/null; do
    for (( i=1; i<=500; i++ )); do
        logger "journalctl, I hate you: $RANDOM"
    done
    journalctl --flush  && journalctl --vacuum-time=1s
done

coredumpctl list

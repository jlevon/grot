#!/bin/bash

# systemd, you suck, badly.

while coredumpctl list >/dev/null; do
    for (( i=1; i<=500; i++ )); do
        logger "journalctl, I hate you: $RANDOM"
    done
    journalctl --flush  && journalctl --vacuum-time=1s
done

coredumpctl list

looking through your slides. ready for some questions?
CoCoCo (yeah, confidential computing containers :slightly_smiling_face:). no VGPU - that means "scale/density is irrelevant for cococo" - per-host pGPUs are < 100 per host and we have no scale issues here. therefore VM-based containers is confidential XOR scale - right? (Obviously non-GPU case could be different)
you say TEE is pod based - sidecars and so on are inside trust boundary then i.e. run in the VM? excluding the source side of peer pods
how critical is virtio-fs here for the non-coco case in general? We don't have this - yet.

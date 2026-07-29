#!/bin/bash

LOGFILE="/var/log/memory_top.log"

echo "Starting memory monitor. Logging to $LOGFILE"

d() {

    echo "=================================================="
    echo " $* "
    echo "=================================================="
    $*
}

while true; do
{
    echo "=================================================="
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo

    echo

    sudo journalctl --lines 1000

    echo "=================================================="
    for p in /proc/[0-9]*; do     pid=${p##*/};     if grep -q memfd "$p/maps" 2>/dev/null; then         echo;         ps -p "$pid" -o pid,comm,args --no-headers;         grep memfd "$p/maps";     fi; done

    d free

    d ps -eo pid,ppid,user,%mem,rss,vsz,comm --sort=-%mem | head -n 11

    d pgrep -fl NetworkManager

    d df -h /dev/shm

    d grep -E 'MemTotal|MemFree|Shmem|AnonPages|Cached|Swap' /proc/meminfo

    d findmnt -t tmpfs

    d df -h -t tmpfs

    d smem -tk

    d vmstat 1 1


    echo
}

    sleep 20
done


#!/bin/bash

LOGFILE="/var/log/memory_top.log"

echo "Starting memory monitor. Logging to $LOGFILE"

d() {
    echo "=================================================="
    echo " $* "
    echo "=================================================="
    $*
}

# Compact, greppable lines first so a truncated/wedged dump still has the leak.
scoreboard() {
    echo "=================================================="
    echo " SCOREBOARD "
    echo "=================================================="
    avail=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
    shmem=$(awk '/^Shmem:/{print $2}' /proc/meminfo)
    shhp=$(awk '/^ShmemHugePages:/{print $2}' /proc/meminfo)
    swfree=$(awk '/^SwapFree:/{print $2}' /proc/meminfo)
    echo "SCORE mem avail_kB=$avail shmem_kB=$shmem shmemhp_kB=$shhp swapfree_kB=$swfree"

    sess=$(loginctl list-sessions --no-legend 2>/dev/null | awk '$3=="jlevon" || $3==ENVIRON["USER"] {print $1; exit}')
    if [ -z "$sess" ]; then
        sess=$(loginctl list-sessions --no-legend 2>/dev/null | awk '/seat0/ {print $1; exit}')
    fi
    if [ -n "$sess" ]; then
        loginctl show-session "$sess" -p Id -p Name -p State -p Type -p LockedHint -p IdleHint -p Active --no-pager 2>/dev/null \
            | awk -F= '{printf "  %s=%s\n", $1, $2}'
        locked=$(loginctl show-session "$sess" -p LockedHint --value 2>/dev/null)
        idle=$(loginctl show-session "$sess" -p IdleHint --value 2>/dev/null)
        echo "SCORE session id=$sess locked=$locked idle=$idle"
    else
        echo "SCORE session none"
    fi

    echo "SCORE_DRM (all /dev/dri clients, unique driver+client-id)"
    sudo python3 - << 'PY'
import os, glob

def comm(pid):
    try:
        with open("/proc/%s/comm" % pid) as f:
            return f.read().strip()
    except OSError:
        return "?"

def rss_kB(pid):
    try:
        with open("/proc/%s/status" % pid) as f:
            for line in f:
                if line.startswith("VmRSS:"):
                    return int(line.split()[1])
    except OSError:
        pass
    return -1

clients = []
seen = set()
for fdpath in glob.glob("/proc/[0-9]*/fd/[0-9]*"):
    try:
        target = os.readlink(fdpath)
    except OSError:
        continue
    if "/dev/dri/" not in target:
        continue
    parts = fdpath.split("/")
    pid, fd = parts[2], parts[4]
    try:
        with open("/proc/%s/fdinfo/%s" % (pid, fd)) as f:
            text = f.read()
    except OSError:
        continue
    drm = {}
    for line in text.splitlines():
        if line.startswith("drm-"):
            k, _, v = line.partition(":")
            drm[k] = v.strip()
    if not drm:
        continue
    key = (pid, drm.get("drm-driver", "?"), drm.get("drm-client-id", fd))
    if key in seen:
        continue
    seen.add(key)
    clients.append((pid, comm(pid), rss_kB(pid), fd, target, drm))

def kib(drm, *names):
    for n in names:
        if n in drm:
            s = drm[n].replace("KiB", "").replace("kiB", "").strip()
            try:
                return int(s.split()[0])
            except ValueError:
                return s
    return 0

clients.sort(key=lambda c: -int(kib(c[5], "drm-total-system0", "drm-total-gtt", "drm-total-memory") or 0))
print("pid      comm                 rss_kB   fd  node                 driver  client  total_sys_kB  resid_sys_kB  total_gtt_kB")
for pid, cm, rss, fd, target, drm in clients:
    total = kib(drm, "drm-total-system0", "drm-total-memory")
    resid = kib(drm, "drm-resident-system0", "drm-resident-memory")
    gtt = kib(drm, "drm-total-gtt")
    print("%-8s %-20s %7s %4s %-20s %-7s %-7s %12s %12s %12s" % (
        pid, cm[:20], rss, fd, os.path.basename(target),
        drm.get("drm-driver", "?")[:7], drm.get("drm-client-id", "?"),
        total, resid, gtt))
    if cm == "gnome-shell":
        print("SCORE_DRM pid=%s comm=gnome-shell rss_kB=%s total_sys_kB=%s resid_sys_kB=%s total_gtt_kB=%s n_clients=%d" % (
            pid, rss, total, resid, gtt, len(clients)))
if not clients:
    print("(no DRM clients)")
PY

    echo "SCORE_PKGS"
    dpkg-query -W -f='  ${Package} ${Version}\n' \
        libmutter-14-0 mutter-common mutter-common-bin gir1.2-mutter-14 \
        gnome-shell gnome-shell-common \
        libgl1-mesa-dri mesa-libgallium libmesa-intel-dri \
        2>/dev/null || true

    gs=$(pgrep -x gnome-shell | head -n1)
    if [ -n "$gs" ]; then
        echo "SCORE_GS pid=$gs etimes=$(ps -p "$gs" -o etimes= 2>/dev/null | tr -d ' ') nfd=$(ls /proc/$gs/fd 2>/dev/null | wc -l)"
        echo "SCORE_LIBMUTTER maps:"
        sudo awk '/libmutter-14\.so/ {print "  " $0}' /proc/$gs/maps 2>/dev/null | head -n 6
        deleted=$(sudo awk '/libmutter-14\.so/ {print; exit}' /proc/$gs/maps 2>/dev/null | grep -c '(deleted)' || true)
        lib=$(sudo awk '/libmutter-14\.so/ {print $6; exit}' /proc/$gs/maps 2>/dev/null)
        echo "SCORE_LIBMUTTER file=${lib:-unknown} deleted=$deleted"
        if [ -n "$lib" ]; then
            ls -l -- "$lib" 2>/dev/null | awk '{print "  "$0}'
        fi
    else
        echo "SCORE_GS not-running"
    fi

    echo "SCORE_DRM_CONNECTORS"
    for con in /sys/class/drm/card*-*-*; do
        [ -e "$con/status" ] || continue
        printf "  %s status=%s enabled=%s dpms=%s\n" \
            "$(basename "$con")" \
            "$(cat "$con/status" 2>/dev/null)" \
            "$(cat "$con/enabled" 2>/dev/null)" \
            "$(cat "$con/dpms" 2>/dev/null || echo n/a)"
    done

    echo "SCORE_JOBS running=$(systemctl is-system-running 2>/dev/null || true)"
    systemctl list-jobs --no-pager --no-legend 2>/dev/null | head -n 20 || echo "  (none)"
    echo "SCORE_INHIBIT"
    systemd-inhibit --list --no-pager 2>/dev/null | head -n 20 || true
    echo "SCORE_DSTATE"
    ps -eo state,pid,ppid,wchan:24,comm | awk 'NR==1 || $1 ~ /D/'
    echo "SCORE_PSI"
    cat /proc/pressure/memory 2>/dev/null || true
}

while true; do
{
    echo "=================================================="
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo

    scoreboard

    echo "=================================================="
    echo " Recent critical events (last 3 min, filtered) "
    echo "=================================================="
    n_atomic=$(sudo journalctl --since "3 minutes ago" --no-pager -q -n 5000 --grep="drmModeAtomicCommit" 2>/dev/null | wc -l)
    echo "SCORE_ATOMIC drmModeAtomicCommit_lines_3min=$n_atomic"
    sudo journalctl --since "3 minutes ago" --no-pager -n 40 \
        --grep="Out of memory|oom-kill|Watchdog|Killed process|hotplug|i915 .*HPD|Failed to start|timed out|Resetting chip" \
        2>/dev/null || sudo journalctl --since "3 minutes ago" -p err --no-pager -n 20

    d cat /proc/meminfo
    d free -h
    d ps -eo pid,ppid,user,%mem,rss,vsz,comm --sort=-%mem | head -n 16

    echo "=================================================="
    echo " gnome-shell smaps_rollup "
    echo "=================================================="
    gs_pids=$(pgrep -x gnome-shell)
    if [ -z "$gs_pids" ]; then
        echo "gnome-shell not running"
    else
        for pid in $gs_pids; do
            echo "--- PID $pid ---"
            sudo grep -E "^Rss:|^Pss:|^Shared|^Private|^Referenced|^Anonymous|^Swap" /proc/$pid/smaps_rollup
        done
    fi

    echo "=================================================="
    echo " i915 GEM objects (summary, one device) "
    echo "=================================================="
    sudo python3 - << 'PY'
import os, glob
seen = set()
found = False
for pat in ("/sys/kernel/debug/dri/*/i915_gem_objects",
            "/sys/kernel/debug/dri/*/i915_get_objects"):
    for f in glob.glob(pat):
        try:
            real = os.path.realpath(f)
        except OSError:
            continue
        if real in seen:
            continue
        seen.add(real)
        found = True
        print("--- %s (realpath %s) ---" % (f, real))
        try:
            with open(f) as fh:
                for i, line in enumerate(fh):
                    if i >= 25:
                        print("  ... truncated ...")
                        break
                    print(line, end="")
        except OSError as e:
            print("  cannot read: %s" % e)
if not found:
    print("No i915_gem_objects under /sys/kernel/debug/dri")
PY

    echo "=================================================="
    echo " dma-buf summary "
    echo "=================================================="
    sudo python3 - << 'PY'
import os
p = "/sys/kernel/debug/dma_buf/bufinfo"
if not os.path.exists(p):
    print("no %s" % p)
else:
    n = 0
    total = 0
    # bufinfo format varies; count "size:" lines and sum
    try:
        with open(p) as f:
            for line in f:
                if line.startswith("size:") or "\tsize:" in line or line.lstrip().startswith("size"):
                    parts = line.replace("=", " ").split()
                    for i, tok in enumerate(parts):
                        if tok.rstrip(":") == "size" and i + 1 < len(parts):
                            try:
                                total += int(parts[i+1])
                                n += 1
                            except ValueError:
                                pass
                            break
        print("dma_buf bufinfo size-entries=%d total_bytes=%d (%.1f MB)" % (
            n, total, total / 1024.0 / 1024.0))
    except OSError as e:
        print("cannot read %s: %s" % (p, e))
if os.path.exists("/sys/kernel/debug/dma_buf/dmaprocs"):
    print("--- dmaprocs (first 40 lines) ---")
    with open("/sys/kernel/debug/dma_buf/dmaprocs") as f:
        for i, line in enumerate(f):
            if i >= 40:
                print("  ... truncated ...")
                break
            print(line, end="")
PY

    d vmstat 1 1
    echo
}

    sleep 20
done

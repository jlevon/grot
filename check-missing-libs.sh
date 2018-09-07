#!/bin/bash

# look at a running system for any binaries linked against libraries that can't
# be found

find . -name proc -o -name zones -prune -o -type f -print0 | xargs -0 file | grep ELF | cut -d: -f1 | xargs ldd >/tmp/ldd.out 2>&1

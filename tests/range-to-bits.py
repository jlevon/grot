#!/usr/bin/python

import struct
import sys

# convert a range [start, end) into set bits, in uint64_t chunks.

start = int(sys.argv[1])
end = int(sys.argv[2])

def BIT2QW(v):
    """Convert from a position into the corresponding uint64_t offset."""
    return v >> 6

def BITQWOFF(v):
    """Mask a position into a bit position within a uint64_t."""
    return v & ((1 << 6)  -1)

ws = BIT2QW(start)
we = BIT2QW(end) + bool(BITQWOFF(end))

for i, w in enumerate(range(ws, we)):
    print("word %d" % w)
    r = -1
    if w == ws and BITQWOFF(start):
        r &= ~((1 << BITQWOFF(start)) - 1)
        start = 0
    if w == we - 1 and BITQWOFF(end):
        r &= ((1 << BITQWOFF(end)) - 1)

    packed = struct.pack('>q', r)  # Packing a long number.
    unpacked = struct.unpack('>Q', packed)[0]  # Unpacking a packed long number to unsigned long
    print(format(unpacked, '064b'))

#!/usr/bin/python3 -u

#
# Not going to win any awards this one, is it?
#
# The Pi is wired up such that pin 18 goes through the switch to ground.
# The on-pin pull-up resistor is enabled (so .input() is normally True).
# When the circuit completes, it goes to ground and hence we get a
# falling edge and .input() becomes False.
#
# I get the occasional phantom still so we wait for settle_time before
# thinking it's real.
#

import alsaaudio
import threading
import signal
import wave
import time
import sys
import os

samplefile = sys.argv[1]
#device='plughw:1,0'
device='plughw:2,0'

# in seconds
settle_time = 0.1
bounce_time = 1

active = False

def play():
    global samplefile
    global active

    active = True
    count = 0

    with wave.open(samplefile) as f:
        periodsize = f.getframerate() // 8

        out = alsaaudio.PCM(alsaaudio.PCM_PLAYBACK, channels=f.getnchannels(),
            rate=f.getframerate(), periodsize=periodsize, device=device)

        # We always play at least one time round...
        while active or count < 1:
            data = f.readframes(periodsize)

            if data:
                out.write(data)
            else:
                print('looping after %d plays, active %s' % (count, active))
                count += 1
                f.rewind()

        print('pausing audio')
        out.pause()

    print('stopped after %d plays' % count)

def wait():
    global active

    while True:
        #active = False
        time.sleep(0.2)

def trigger():
    print('triggering at %s' % time.time())

    tp = threading.Thread(target=play)
    tp.start()

    tw = threading.Thread(target=wait)
    tw.start()

    tw.join()
    tp.join()

trigger()

#signal.pause()

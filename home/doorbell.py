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

from email.mime.text import MIMEText
from subprocess import Popen, PIPE
from datetime import datetime

import RPi.GPIO as GPIO
import subprocess
import logging
import alsaaudio
import threading
import signal
import wave
import time
import sys
import urllib.request
import os

logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)

samplefile = sys.argv[1]
device='plughw:1,0'

# in seconds
settle_time = 0.1
bounce_time = 1

active = False

def notify():
    with open("doorbell_url.txt", 'r') as urlf:
        url=urlf.read().strip('\n')
        urllib.request.urlopen(url)

    subprocess.run(['/home/pi/notify-sent'])

    msg = MIMEText('At %s' % datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    msg['From'] = 'doorbell <levon@movementarian.org>'
    msg['To'] = 'John Levon <doorbell@movementarian.org>'
    msg['Subject'] = 'Someone is ringing the doorbell'

    p = Popen(['/usr/sbin/sendmail', '-f', 'levon@movementarian.org', '-t', '-oi'], stdin=PIPE)
    p.stdin.write(msg.as_string().encode())
    p.stdin.close()

def open_wav():
    global format
    global out
    global periodsize
    global wavfile

    wavfile = wave.open(samplefile)

    # things go horrible if the rate isn't 48000 for some reason
    if wavfile.getframerate() != 48000:
        raise ValueError('file must be 48000 rate')

    format = None
    width = wavfile.getsampwidth()
    # 8bit is unsigned in wav files
    if width == 1:
        format = alsaaudio.PCM_FORMAT_U8
    # Otherwise we assume signed data, little endian
    elif width == 2:
        format = alsaaudio.PCM_FORMAT_S16_LE
    elif width == 3:
        format = alsaaudio.PCM_FORMAT_S24_3LE
    elif width == 4:
        format = alsaaudio.PCM_FORMAT_S32_LE
    else:
        raise ValueError('Unsupported format')

    rate = wavfile.getframerate()

    periodsize = rate // 8

    logging.info("opening alsa")
    out = alsaaudio.PCM(alsaaudio.PCM_PLAYBACK, device=device)
    logging.info("out.setchannels(wavfile.getnchannels())")
    out.setchannels(wavfile.getnchannels())
    logging.info("out.setrate(rate)")
    out.setrate(rate)
    logging.info("out.setformat(format)")
    out.setformat(format)
    logging.info("out.setperiodsize(periodsize)")
    out.setperiodsize(periodsize)


def play():
    global active

    active = True
    count = 0

    logging.info('started playing at %s' % time.time())

    # We always play at least one time round...
    while active or count < 1:
        data = wavfile.readframes(periodsize)

        if data:
            out.write(data)
        else:
            logging.info('looping after %d plays, active %s' % (count, active))
            count += 1
            wavfile.rewind()

    logging.info('stopping audio')

    out.pause()
    out.close()
    wavfile.close()

    logging.info('stopped after %d plays' % count)

    open_wav()

def wait():
    global active

    while True:
        input_state = GPIO.input(18)
        if input_state:
            logging.info('got input_state %s, active -> False' % input_state)
            active = False
            break
        time.sleep(0.2)

def trigger():
    logging.info('triggering at %s' % time.time())

    tp = threading.Thread(target=play)
    tp.start()

    tn = threading.Thread(target=notify)
    tn.start()

    tw = threading.Thread(target=wait)
    tw.start()

    tw.join()
    tp.join()
    tn.join()

def settle():
    global settle_time
    time.sleep(settle_time)
    input_state = GPIO.input(18)
    logging.info('input state now %s' % input_state)
    return not input_state

def falling_edge(channel):
    input_state = GPIO.input(18)
    logging.info('got falling edge, input_state %s' % input_state)
    if settle():
        trigger()

GPIO.setmode(GPIO.BCM)
GPIO.setup(18, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.add_event_detect(18, GPIO.FALLING, callback=falling_edge, bouncetime=(bounce_time * 1000))

open_wav()

logging.info('started')

signal.pause()

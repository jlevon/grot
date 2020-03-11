#!/usr/bin/python

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
import subprocess
import RPi.GPIO as GPIO
import signal
import time
import os

GPIO.setmode(GPIO.BCM)

GPIO.setup(18, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# in seconds
settle_time = 0.2
bounce_time = 1

def notify():
    print('notifying at %s' % time.time())

    msg = MIMEText("At %s" % datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    msg["From"] = "doorbell <levon@movementarian.org>"
    msg["To"] = "John Levon <john.levon@gmail.com>"
    msg["Subject"] = "Doorbell is ringing"

    p = Popen(["/usr/sbin/sendmail", "-f", "levon@movementarian.org", "-t", "-oi"], stdin=PIPE)
    p.communicate(msg.as_string())
    while True:
        os.system('ssh jlevon@kent mpg123 Dropbox/personal/doorbell.mp3')
        input_state = GPIO.input(18)
        if input_state:
            break

def settle():
    global settle_time
    time.sleep(settle_time)
    input_state = GPIO.input(18)
    print('input state now %s' % input_state)
    return not input_state

def falling_edge(channel):

    input_state = GPIO.input(18)
    print('got falling edge, input_state %s' % input_state)
    if settle():
        notify()
          
GPIO.add_event_detect(18, GPIO.FALLING, callback=falling_edge, bouncetime=(bounce_time * 1000))

print('started')

signal.pause()

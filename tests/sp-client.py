#!/usr/bin/python

import socket
import time
import sys
import os

server_address = './uds_socket'

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

# Connect the socket to the port where the server is listening
server_address = './uds_socket'
print >>sys.stderr, 'connecting to %s' % server_address
try:
    sock.connect(server_address)
except socket.error, msg:
    print >>sys.stderr, msg
    sys.exit(1)

read_forever = True
send_one = True

try:
    if send_one:
       sock.sendall('T')
       time.sleep(5)
       sock.sendall('his the mess')
       sys.exit(0)

    # Send data
    message = 'This is the message.  It will be repeated.'
    print >>sys.stderr, 'sending "%s"' % message
    sock.sendall(message)

    amount_received = 0
    amount_expected = len(message)

    while read_forever or amount_received < amount_expected:
        data = sock.recv(16)
        amount_received += len(data)
        print >>sys.stderr, 'received %d bytes "%s"' % (len(data), data)
        if len(data) == 0:
             print >>sys.stderr, 'got EOF, quitting'
             sys.exit(0)

finally:
    print >>sys.stderr, 'closing socket'
    sock.close()

#!/usr/bin/python

import socket
import sys
import os

server_address = './uds_socket'

# Make sure the socket does not already exist
try:
    os.unlink(server_address)
except OSError:
    if os.path.exists(server_address):
        raise

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

# Bind the socket to the port
print >>sys.stderr, 'starting up on %s' % server_address
sock.bind(server_address)

# Listen for incoming connections
sock.listen(1)

do_close = False
do_exit_after_read = False
do_read_one_then_close = True

while True:
    # Wait for a connection
    print >>sys.stderr, 'waiting for a connection'
    connection, client_address = sock.accept()
    try:
        print >>sys.stderr, 'connection from', client_address

        if do_close:
            connection.close()
            while True:
                pass

        if do_read_one_then_close:
            data = connection.recv(1)
            print >>sys.stderr, 'received "%s"' % data
            connection.close()
            while True:
                pass

        while True:
            data = connection.recv(4096)
            print >>sys.stderr, 'received "%s"' % data
            if data:
                print >>sys.stderr, 'sending data back to the client'
                connection.sendall(data)
            else:
                print >>sys.stderr, 'no more data from', client_address
                break
            if do_exit_after_read:
                sys.exit(0)
    finally:
        # Clean up the connection
        connection.close()

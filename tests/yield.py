#!/usr/bin/python3

import time

def a():
	print("a here\n");
	yield
	print("a here 2\n");
	yield
	print("a here 3\n");

def b():
	print("b here\n");
	yield
	print("b here 2\n");
	yield
	print("b here 3\n");

print("here")
co_a = a()
co_b = b()
while True:
	print("here a")
	next(co_a)
	print("here b")
	next(co_b)

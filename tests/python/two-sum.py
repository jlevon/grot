#!/usr/bin/python

# https://leetcode.com/problems/two-sum/

def check(input, target):
	print input, target

	seen = dict()

	for i, val in enumerate(input):
		complement = target - val

		if complement in seen:
			print seen[complement], i
			return

		seen[val] = i

	print "impossible"



check([2, 7, 11, 15], 9)
check([7, 11, 15, 2], 9)
check([], 4)
check([0, 0, 0], 0)
check([-4, 0], -4)
check([-4, 6, 2, 4], 2)
check([1, 3], 4)
check([1, 3], 5)
check([1, 3, 2], 5)
check([3, 3, 7, 6], 9)
check([0, 2, 7, 9], 9)

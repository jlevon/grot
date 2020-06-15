#!/usr/bin/python

limits = [
	(9, ( "MMMMMMMMM", "CM", "XC", "IX" ) ),
	(5, ( "MMMMM", "D", "L", "V" ) ),
	(4, ( "MMMM", "CD", "XL", "IV" ) ),
	(1, ( "M", "C", "X", "I" ) )
];

def roman(input):
	print input
	out = ""

	for i in range(4):
		units = 10 ** (3 - i);
		place_val = input / units
		input = input % units

		for lim, strings in limits:
			while place_val >= lim:
				out += strings[i]
				place_val -= lim

	print out

roman(2555)
roman(1994)
roman(1111)
roman(3000)
roman(3994)


def check(input):
	print input

	count = sum(input)

	if count % 3 != 0:
		print "no"
		return

	size = count / 3

	lims = [ -1, -1, -1];
	index = 0;

	c = 0;
	for i, val in enumerate(input):
		c += val;

		if c == size:
			lims[index] = i + 1;
			index += 1;
			c = 0;

	print -1 not in lims

check([1,0,1,1, 0,1,1,1, 1,1,1,0])
check([1,1,1, 0,1,1,1,0,0, 1,1,0,1])
check([1,0,0,0, 0,1,0, 0])
check([1,1,0,0, 0,1,1, 0,1,0])
check([1, 0,0,0,1,0, 1])
check([1,1, 0,0,1,1,0, 1,1])
check([0,0,0])

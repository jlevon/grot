
/*
 * This file and its contents are supplied under the terms of the
 * Common Development and Distribution License ("CDDL"), version 1.0.
 * You may only use this file in accordance with the terms of version
 * 1.0 of the CDDL.
 *
 * A full copy of the text of the CDDL should have accompanied this
 * source.  A copy of the CDDL is also available via the Internet at
 * http://www.illumos.org/license/CDDL.
 */

/*
 * Copyright (c) 2018, Joyent, Inc.
 */

// ldtfucker.c

#include <errno.h>
#include <strings.h>
#include <stdio.h>
#include <stdlib.h>
#include <thread.h>
#include <sys/sysi86.h>
#include <sys/mman.h>
#include <sys/segments.h>
#include <assert.h>
#include <fcntl.h>
#include <unistd.h>

int idx;

char buf[4096];

static void
make_ldt(int idx)
{
	uint_t i;
	struct ssd ssd;

	fprintf(stderr, "make_ldt index %d\n", idx);
	bzero(&ssd, sizeof (ssd));
	/* XXX These bits aren't even used */
	ssd.sel = SEL_LDT(idx);
	ssd.bo = (uintptr_t)buf;
	ssd.ls = 4096;
	ssd.acc1 = SDT_MEMRWD | (0x3 << 5) | (1 << 7);
	ssd.acc2 = 1 << 2;

	if (sysi86(SI86DSCR, &ssd) != 0) {
		(void) fprintf(stderr, "failed to make ldt entry "
		    "%u: %s\n", i, strerror(errno));
	}
}

static void
donothing(void)
{
	int fd = open("/dev/null", O_WRONLY);
	fprintf(stderr, "spinning on nothing\n");
	for (;;) {
		write(fd, "nothing", sizeof ("nothing"));
	}
}

int
main(int argc, char *argv[])
{
	if (argv[1])
		idx = atoi(argv[1]);
	printf("idx %d\n", idx);
	make_ldt(idx);
	donothing();
	return (0);
}

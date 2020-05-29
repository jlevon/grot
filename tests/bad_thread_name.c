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
 * Copyright 2018 Joyent, Inc.
 */

/*
 * Some basic pthread name API tests.
 */

#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <err.h>

static void *
thr(void *unused)
{
	sleep(100);
	return (NULL);
}

int
main(int argc, char *argv[])
{
	char name[PTHREAD_MAX_NAMELEN_NP];
        pthread_attr_t attr;
	pthread_t tid;
	int rc;

	/* 1. Default thread name is empty string. */

	rc = pthread_getname_np(pthread_self(), name, sizeof (name));

	if (rc != 0 || strcmp(name, "") != 0)
		err(EXIT_FAILURE, "test 1 failed");

	/* 2. Can set name. */

	//(void) strlcpy(name, "main", sizeof (name));
	strlcpy(name, "\033]0;BAD!!\a", sizeof (name));
	rc = pthread_setname_np(pthread_self(), name);
	for (;;) {}

	if (rc != 0)
		err(EXIT_FAILURE, "test 2 failed");

	rc = pthread_getname_np(pthread_self(), name, sizeof (name));

	if (rc != 0 || strcmp(name, "main") != 0)
		err(EXIT_FAILURE, "test 2 failed");

	/* 3. ERANGE check. */

	rc = pthread_getname_np(pthread_self(), name, 2);

	if (rc != ERANGE)
		errx(EXIT_FAILURE, "test 3 failed");

	/* 4. can clear thread name. */

	rc = pthread_setname_np(pthread_self(), NULL);

	if (rc != 0)
		err(EXIT_FAILURE, "test 4 failed");

	rc = pthread_getname_np(pthread_self(), name, sizeof (name));

	if (rc != 0 || strcmp(name, "") != 0)
		err(EXIT_FAILURE, "test 4 failed");

	/* 5. non-existent thread check. */
	rc = pthread_getname_np(808, name, sizeof (name));

	if (rc != ESRCH)
		errx(EXIT_FAILURE, "test 5 failed");

	rc = pthread_setname_np(808, "state");

	if (rc != ESRCH)
		errx(EXIT_FAILURE, "test 5 failed");

	/* 6. too long a name. */
	rc = pthread_setname_np(pthread_self(),
	    "12345678901234567890123456789012");

	if (rc != ERANGE)
		errx(EXIT_FAILURE, "test 6 failed");

	/* 7. can name another thread. */
	rc = pthread_create(&tid, NULL, thr, NULL);

	if (rc != 0)
		err(EXIT_FAILURE, "test 7 failed pthread_create()");

	rc = pthread_setname_np(tid, "otherthread");

	if (rc != 0)
		err(EXIT_FAILURE, "test 7 failed");

	/* 8. attr tests. */
	pthread_attr_init(&attr);

	rc = pthread_attr_getname_np(&attr, name, 2);

	if (rc != ERANGE)
		errx(EXIT_FAILURE, "test 8 failed");

	rc = pthread_attr_setname_np(&attr,
	    "12345678901234567890123456789012");

	if (rc != ERANGE)
		errx(EXIT_FAILURE, "test 8 failed");

	rc = pthread_attr_setname_np(&attr, "thread2");

	if (rc != 0)
		err(EXIT_FAILURE, "test 8 failed");

	rc = pthread_create(&tid, &attr, thr, NULL);

	if (rc != 0)
		err(EXIT_FAILURE, "test 8 failed pthread_create()");

	rc = pthread_getname_np(tid, name, sizeof (name));

	if (rc != 0 || strcmp(name, "thread2") != 0)
		err(EXIT_FAILURE, "test 8 failed");

	exit(EXIT_SUCCESS);
}

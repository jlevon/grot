/* gcd.c -- benchmark gcd.

Copyright 2003, 2009 Free Software Foundation, Inc.

This file is part of GMPbench.

GMPbench is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or (at your option) any later
version.

GMPbench is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
GMPbench.  If not, see http://www.gnu.org/licenses/.  */


#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include "gmp.h"
#include "timing.h"

int cputime (void);

long totals[1024];
pthread_t threads[1024];

unsigned long m = 256;
unsigned long n = 256;

  gmp_randstate_t rs;
  mpz_t x, y, z;
double t;
static long
runit(void *argument)
{
  unsigned long int m, n, i, niter, t0, ti;
  double f, ops_per_sec;
  int decimals;
  m = 256;
  n = 256;

again:
  niter = 1 + (unsigned long) (1e4 / t);
#if 0
  printf ("Multiplying %lu-bit number with %lu-bit number %lu times...",
 	  m, n, niter);
  fflush (stdout);
#endif
  t0 = cputime ();
  for (i = niter; i > 0; i--)
    {
      mpz_gcd (z, x, y);
    }
  ti = cputime () - t0;
 // printf ("done!\n");

#if 1
  ops_per_sec = 1000.0 * niter / ti;
  f = 100.0;
  for (decimals = 0;; decimals++)
    {
      if (ops_per_sec > f)
	break;
      f = f * 0.1;
    }

  //printf ("RESULT: %.*f operations per second\n", decimals, ops_per_sec);
#endif
  totals[(long)argument] = 1000 * niter / ti;
   //goto again;
  return 0;
}

/* Return user CPU time measured in milliseconds.  */
#if !defined (__sun) \
    && (defined (USG) || defined (__SVR4) || defined (_UNICOS) \
	|| defined (__hpux))
#include <time.h>

int
cputime ()
{
  return (int) ((double) clock () * 1000 / CLOCKS_PER_SEC);
}
#else
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>

int
cputime ()
{
  struct rusage rus;

  getrusage (0, &rus);
  return rus.ru_utime.tv_sec * 1000 + rus.ru_utime.tv_usec / 1000;
}
#endif

int
main (int argc, char *argv[])
{

  
 long nr;
#if 0
  if (argc != 3)
    {
      fprintf (stderr, "usage: %s m n\n", argv[0]);
      fprintf (stderr, "  where m and n are number of bits in numbers tested\n");
      return -1;
    }

  m = atoi (argv[1]);
  n = atoi (argv[2]);
#endif

	nr = atoi(argv[1]);

  gmp_randinit_default (rs);

  mpz_init (x);
  mpz_init (y);
  mpz_init (z);
  mpz_urandomb (x, rs, m);
  mpz_urandomb (y, rs, n);

  //printf ("Calibrating CPU speed...");  fflush (stdout);
  TIME (t, mpz_gcd (z, x, y));
  //printf ("done\n");

	for (;;) {
		long total = 0;

	for (long i = 0; i < nr; i++) {
		pthread_create(&threads[i], NULL, (void *)runit, (void *)i);
	}

#if 1
		for (long i = 0; i < nr; i++) {
			void *status;
			//printf("waiting for t%d\n", i);
			pthread_join(threads[i], NULL);
		}
#endif

		for (long i = 0; i < nr; i++) {
			total += totals[i];
			totals[i] = 0;
		}

		printf("%lu\n", total);
		break;
	}

}

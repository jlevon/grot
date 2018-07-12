/* timing.h

Copyright 2003 Free Software Foundation, Inc.

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


#define TIME(t,func)							\
  do { long int __t0, __times, __t, __tmp;				\
    __times = 1;							\
    {func;}								\
    do									\
      {									\
	__times <<= 1;							\
	__t0 = cputime ();						\
	for (__t = 0; __t < __times; __t++)				\
	  {func;}							\
	__tmp = cputime () - __t0;					\
      }									\
    while (__tmp < 250);						\
    (t) = (double) __tmp / __times;					\
  } while (0)

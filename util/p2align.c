
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>

#define ROUND_DOWN(x, a)    ((x) & ~((a)-1))
#define ROUND_UP(x,a)       ROUND_DOWN((x)+(a)-1, a)

int
main(int argc, char *argv[])
{
	unsigned long long x, a;
	x = strtoull(argv[1], NULL, 0);
	a = strtoull(argv[2], NULL, 0);
	printf("ROUND_UP(%llu, %llu) -> %llu\n", x, a, ROUND_UP(x, a));
}

#include <time.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	struct timespec ts;

	int rc = clock_getres(CLOCK_REALTIME, &ts);

	printf("ts.nsec %lu\n", ts.tv_nsec);
}

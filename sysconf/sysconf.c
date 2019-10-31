#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	long ret = sysconf(_SC_NPROCESSORS_ONLN);
	printf("_SC_NPROCESSORS_ONLN = %ld\n", ret);
}

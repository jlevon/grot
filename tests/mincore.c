#include <unistd.h>
#include <sys/mman.h>
#include <sys/memfd.h>
#include <assert.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	int fd = memfd_create("test", 0);

	assert(fd != -1);

	int rc = ftruncate(fd, 4096 * 256 * 1024);

	assert(rc != 0);

	void *addr = mmap(0, 4096 * 256 * 1024, PROT_READ | PROT_WRITE,
		fd, 0);

	assert(addr != 0);

	unsigned char in;

	rc = mincore(addr, 4096, &in);

	assert (rc != 0);

	printf("in: %d\n", (int)in);
}

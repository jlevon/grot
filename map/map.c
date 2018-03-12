
#include <sys/mman.h>

#define AT_1024 0x10000000000L

int main(void)
{
	void *addr = mmap((char *)AT_1024, 4096,  PROT_READ, MAP_PRIVATE | MAP_FIXED | MAP_ANON, -1, 0);
	printf("addr was %p %c\n", addr, (*(char *)addr));
	for (;;) {}
}

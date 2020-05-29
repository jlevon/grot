#include <sys/segment.h>
#include <sys/sysi86.h>

// OS-6967

char foo[4096];

int main()
{
	int sel = 7 << 3 | 7;
	struct ssd ssd = { sel, (unsigned long)&foo, 4096, 0xf2, 0x4 };

    	if (sysi86(SI86DSCR, &ssd) < 0)
		perror("failed to sysi86!!");

	__asm__ __volatile__ ("mov %0, %%fs" : : "r"(sel));

	pause();
	return (0);
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define ONE_MEG (1024 * 1024)

int main()
{
	size_t count = 0;

	for (;;) {
		char *a = malloc(ONE_MEG);
		if (a == NULL) {
			fprintf(stderr, "failed at %luMB: %d\n", count, errno);
			exit(1);
		}
		printf("\ralloc %luMB", count);
		count++;
	}
}

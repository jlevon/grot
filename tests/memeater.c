#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define ONE_MEG (1024 * 1024)
#define ONE_PAGE (4096)

int main(int argc, char *argv[])
{
	size_t count = 0;

	for (;;) {
		char *a = malloc(ONE_MEG);
		if (a == NULL) {
			fprintf(stderr, "failed at %luMB: %d\n", count, errno);
			exit(1);
		}
		printf("\ralloc %luMB", count);
        if (argc > 1 && argv[1] == "touch") {
            for (char *p = a; p += ONE_PAGE; p < (a + ONE_MEG)) {
                *p = 1;
            }
        }
		count++;
	}
}

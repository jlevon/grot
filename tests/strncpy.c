#include <string.h>
#include <stdio.h>

/*
 * Demonstration of how to deal with strncpy() overflow if you don't care.
 */

int main()
{
	const char *l = "longstring";
	char buf[5];
	strncpy(buf, l, sizeof (buf) - 1);
	buf[sizeof(buf) - 1] = '\0';
	printf("Result: %s\n", buf);
}

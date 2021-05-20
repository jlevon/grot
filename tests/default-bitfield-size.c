#include <stdio.h>

struct foo {
	union {
		short foo;
		struct {
			unsigned int a:1;
			unsigned int b:1;
		};
	};
} __attribute((packed));

int main() { printf("%zu\n", sizeof (struct foo)); }

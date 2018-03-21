
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

int main(int argc, char *argv[])
{
	uint64_t value;
	uint64_t align;
	char *end;

	if (argc < 3) {
		fprintf(stderr, "usage: align value alignment\n");
		exit(1);
	}

	errno = 0;

	value = strtoull(argv[1], &end, 0);

	if (errno != 0 || *end != '\0') {
		fprintf(stderr, "invalid value %s\n", argv[1]);
		exit(1);
	}

	errno = 0;

	align = strtoull(argv[2], &end, 0);

	if (errno != 0 || *end != '\0') {
		fprintf(stderr, "invalid align %s\n", argv[1]);
		exit(1);
	}

	printf("value:0x%lx (%ld) align:0x%lx (%ld)\n", value, value, align, align);
	printf("phase:0x%lx (%ld)\n", value % align, value % align);
	printf("rounded up:0x%lx (%ld)\n", align * ((value + align - 1) / align),
		align * ((value + align - 1) / align));
	printf("rounded down:0x%lx (%ld)\n", align * (value / align),
		align * (value / align));
}

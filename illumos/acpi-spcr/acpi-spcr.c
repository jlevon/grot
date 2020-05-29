
#include <sys/acpi/platform/acsolaris.h>
#include <sys/acpi/actypes.h>
#include <sys/acpi/actbl.h>

#include <unistd.h>
#include <fcntl.h>

struct acpi_table_spcr spcr;

int printit(void)
{
	sleep(50);
}

int main(int argc, char *argv[])
{
	int fd = open(argv[1], O_RDONLY);
	read(fd, &spcr, sizeof(spcr));
	printit();
}

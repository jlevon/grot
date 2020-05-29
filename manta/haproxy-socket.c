#include <stdio.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <err.h>
#include <stdlib.h>
#include <strings.h>

int main(int argc, char *argv)
{
	int fd;

	for (;;) {
		struct sockaddr_un addr;
		char buf[4096];
		int r;

		int fd = socket(PF_UNIX, SOCK_STREAM, 0);
		if (fd == -1)
			err(EXIT_FAILURE, "failed to create socket");

		bzero(&addr, sizeof (addr));

		addr.sun_family = AF_UNIX;
		strcpy(addr.sun_path, "/tmp/haproxy");
		if (connect(fd, (struct sockaddr *)&addr, sizeof (addr)) == -1)
			err(EXIT_FAILURE, "failed to connect");

		const char str[] = "show stat -1 4 -1\n";

		if (write(fd, str, strlen(str)) != strlen(str))
			err(EXIT_FAILURE, "failed to write");

		if (shutdown(fd, SHUT_WR) == -1)
			err(EXIT_FAILURE, "failed to shutdown");

		if ((r = read(fd, buf, sizeof (buf))) < 1) {
			err(EXIT_FAILURE, "got read of %d", r);
		}

		close(fd);
		if (argc > 1)
			exit(0);
	}
}

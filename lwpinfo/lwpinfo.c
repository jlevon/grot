
#define __EXTENSIONS__
#define _STRUCTURED_PROC 1
#include <signal.h>
#include <ucontext.h>
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <sys/procfs.h>
#include <sys/processor.h>
#include <strings.h>
#include <errno.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <limits.h>
#include <sys/param.h>

char buf[16384];

void
Format_state(char *str, char state, processorid_t pr_id, int length)
{
        switch (state) {
        case 'S':
                (void) strncpy(str, "sleep", length);
                break;
        case 'R':
                (void) strncpy(str, "run", length);
                break;
        case 'Z':
                (void) strncpy(str, "zombie", length);
                break;
        case 'T':
                (void) strncpy(str, "stop", length);
                break;
        case 'I':
                (void) strncpy(str, "idle", length);
                break;
        case 'W':
                (void) strncpy(str, "wait", length);
                break;
        case 'O':
                (void) snprintf(str, length, "cpu%-3d", (int)pr_id);
                break;
        default:
                (void) strncpy(str, "?", length);
                break;
        }
}


int main(int argc, char *argv[])
{
	char path[MAXPATHLEN];
	snprintf(path, sizeof (path), "/proc/%s/lpsinfo", argv[1]);
	int fd = open(path, O_RDONLY);

	if (fd == -1) {
		fprintf(stderr, "failed to open %s\n", path);
		exit(1);
	}

	prheader_t header;

	if (read(fd, &header, sizeof (header)) != sizeof (header)) {
		fprintf(stderr, "failed to read %s\n", path);
		exit(1);
	}

	printf("%s: %d LWPs\n", path, header.pr_nent);

	size_t size = header.pr_nent * header.pr_entsize;

	char *lis = malloc(size);

	if (read(fd, lis, size) != size) {
		fprintf(stderr, "failed to read %s LWPs\n", path);
		exit(1);
	}
	for (size_t i = 0; i < header.pr_nent; i++) {
		lwpsinfo_t *li = lis + (i * header.pr_entsize);
		char st[20] = "";

		if (0 && li->pr_sname != 'O')
			continue;

		Format_state(st, li->pr_sname, li->pr_onpro, sizeof (st));

		printf("lwpid:%d state:%s bind:%d\n", li->pr_lwpid,
		    st, li->pr_bindpro);
	}
}

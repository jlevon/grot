#include <setjmp.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <ucontext.h>
#include <sys/wait.h>

/* Try this on CPU0... */

unsigned short seg;

void badcs(void) { asm volatile("movw %0, %%cs" : : "r" (seg)); }
void badds(void) { asm volatile("movw %0, %%ds" : : "r" (seg)); }
void bades(void) { asm volatile("movw %0, %%es" : : "r" (seg)); }
void badfs(void) { asm volatile("movw %0, %%fs" : : "r" (seg)); }
void badgs(void) { asm volatile("movw %0, %%gs" : : "r" (seg)); }
void badss(void) { asm volatile("movw %0, %%ss" : : "r" (seg)); }

#define SS              18      /* only stored on a privilege transition */
#define UESP            17      /* only stored on a privilege transition */
#define EFL             16
#define CS              15
#define EIP             14
#define ERR             13
#define TRAPNO          12
#define EAX             11
#define ECX             10
#define EDX             9
#define EBX             8
#define ESP             7
#define EBP             6
#define ESI             5
#define EDI             4
#define DS              3
#define ES              2
#define FS              1
#define GS              0

void resetfs(void)
{
	ucontext_t ucp;
	int done = 0;

	int rc = getcontext(&ucp);
	if (done) {
		rc = getcontext(&ucp);
		return;
	}

	done = 1;
	ucp.uc_mcontext.gregs[FS] = seg;
	setcontext(&ucp);
	printf("here?\n");
}

void resetgs(void)
{
	ucontext_t ucp;
	int done = 0;

	int rc = getcontext(&ucp);
	if (done) {
		rc = getcontext(&ucp);
		return;
	}

	done = 1;
	ucp.uc_mcontext.gregs[GS] = seg;
	setcontext(&ucp);
	printf("here?\n");
}
void resetcs(void)
{
	ucontext_t ucp;
	int done = 0;

	int rc = getcontext(&ucp);
	if (done) {
		rc = getcontext(&ucp);
		return;
	}

	done = 1;
	ucp.uc_mcontext.gregs[CS] = seg;
	setcontext(&ucp);
	printf("here?\n");
}
void resetds(void)
{
	ucontext_t ucp;
	int done = 0;

	int rc = getcontext(&ucp);
	if (done) {
		rc = getcontext(&ucp);
		return;
	}

	done = 1;
	ucp.uc_mcontext.gregs[DS] = seg;
	setcontext(&ucp);
	printf("here?\n");
}
void resetes(void)
{
	ucontext_t ucp;
	int done = 0;

	int rc = getcontext(&ucp);
	if (done) {
		rc = getcontext(&ucp);
		return;
	}

	done = 1;
	ucp.uc_mcontext.gregs[ES] = seg;
	setcontext(&ucp);
	printf("here?\n");
}

void resetss(void)
{
	ucontext_t ucp;
	int done = 0;

	int rc = getcontext(&ucp);
	if (done) {
		rc = getcontext(&ucp);
		return;
	}

	done = 1;
	ucp.uc_mcontext.gregs[SS] = seg;
	setcontext(&ucp);
	printf("here?\n");
}

void inchild(void (*func)())
{
	pid_t pid;
	switch ((pid = fork())) {
	case 0:
		func();
		exit(0);
	case -1:
		exit(1);
	default:
		waitpid(pid, NULL, 0);
		return;
	}

}

int main(int argc, char *argv[])
{
	if (argc > 1)
		seg = atoi(argv[1]);

	for (;(unsigned int)seg < 8194; seg++ ) {
		printf("seg = %u\n", seg);
#if 1
	if (argc > 1) fprintf(stderr, "resetfs\n");
	inchild(resetfs);
	if (argc > 1)fprintf(stderr, "resetgs\n");
	inchild(resetgs);
	if (argc > 1)fprintf(stderr, "resetcs\n");
	inchild(resetcs);
	if (argc > 1)fprintf(stderr, "resetds\n");
	inchild(resetds);
	if (argc > 1)fprintf(stderr, "resetes\n");
	inchild(resetes);
	if (argc > 1)fprintf(stderr, "resetss\n");
	inchild(resetss);
	//return 0;
#endif
	if (argc > 1)fprintf(stderr, "badcs\n");
	inchild(badcs);
	if (argc > 1)fprintf(stderr, "badds\n");
	inchild(badds);
	if (argc > 1)fprintf(stderr, "bades\n");
	inchild(bades);
	if (argc > 1)fprintf(stderr, "badfs\n");
	inchild(badfs);
	if (argc > 1)fprintf(stderr, "badgs\n");
	inchild(badgs);
	if (argc > 1)fprintf(stderr, "badss\n");
	inchild(badss);
		if (argc > 1) {
			printf( "done %u\n", seg);
			exit(0);
		}
	}
}

#include <setjmp.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/syscall.h>


#define INT(i) { \
	asm volatile("int $" #i : : );	\
}

void inchild(void (*func)())
{
	pid_t pid;
	int i = 0;

	switch ((pid = fork())) {
	case 0:
		func();
		exit(0);
	case -1:
		exit(1);
	default:
		while (waitpid(pid, NULL, WNOHANG) != pid) {
			usleep(10000);
			if (++i == 100) {
				fprintf(stderr, "Killing child %d\n", pid);
				kill(pid, SIGKILL);
			}
		}
		return;
	}

}
		
ulong_t argrand(void)
{
#ifdef __amd64
	return (rand() + (ulong_t)rand() << 32);
#else
	return (rand());
#endif
}

int sysc;
ulong_t arg1;
ulong_t arg2;
ulong_t arg3;
ulong_t arg4;
ulong_t arg5;

/*
 * Without the brand wrapper, this should not be interesting.
 */
void int80(void)
{
	fprintf(stderr, "int80(%d, %lx, %lx, %lx, %lx, %lx)\n",
	    sysc, arg1, arg2, arg3, arg4, arg5);
	asm volatile(
	    "push %1\n"
	    "push %2\n"
	    "push %3\n"
	    "push %4\n"
	    "push %5\n"
	    "int $0x80" : :
	    "a" (sysc),
	    "r" (arg1),
	    "r" (arg2),
	    "r" (arg3),
	    "r" (arg4),
	    "r" (arg5)
	    : );
}

void int91(void)
{
	fprintf(stderr, "int91(%d, %lx, %lx, %lx, %lx, %lx)\n",
	    sysc, arg1, arg2, arg3, arg4, arg5);
	asm volatile(
	    "push %1\n"
	    "push %2\n"
	    "push %3\n"
	    "push %4\n"
	    "push %5\n"
	    "int $0x91" : :
	    "a" (sysc),
	    "r" (arg1),
	    "r" (arg2),
	    "r" (arg3),
	    "r" (arg4),
	    "r" (arg5)
	    : );
}

int main(int argc, char *argv[])
{
	int iter = argv[1] == NULL ? 10000 : atoi(argv[1]);
	int i;

	for (i = 0; i < iter; i++ ) {
		arg1 = argrand();
		arg2 = argrand();
		arg3 = argrand();
		arg4 = argrand();
		arg5 = argrand();
		for (sysc = 0; sysc < 257 ; sysc++) {
			if (sysc == SYS_stime)
				continue; // breaks getexecname() for some reason
			//sigactions();
			inchild(int80);
		}
	
		for (sysc = 0; sysc < 257 ; sysc++) {
			if (sysc == SYS_stime)
				continue; // breaks getexecname() for some reason
			inchild(int91);
		}
	}
}

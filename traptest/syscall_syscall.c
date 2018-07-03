#include <setjmp.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>

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

ulong_t rsp;
int sysc;
ulong_t arg1;
ulong_t arg2;
ulong_t arg3;
ulong_t arg4;
ulong_t arg5;

void syscall_badrsp(void)
{
	fprintf(stderr, "syscall(%d, %lx, %lx, %lx, %lx)\n",
	    sysc, arg1, arg2, arg3, arg4);
	asm volatile(
	    "push %1\n"
	    "push %2\n"
	    "push %3\n"
	    "push %4\n"
#ifdef __amd64
	    "mov %5, %%rsp\n"
#else
	    "mov %5, %%esp\n"
#endif
	    "syscall" : :
	    "a" (sysc),
	    "r" (arg1),
	    "r" (arg2),
	    "r" (arg3),
	    "r" (arg4),
	    "r" (rsp)
	    : );
}

void syscall(void)
{
	fprintf(stderr, "syscall(%d, %lx, %lx, %lx, %lx, %lx)\n",
	    sysc, arg1, arg2, arg3, arg4, arg5);
	asm volatile(
	    "push %1\n"
	    "push %2\n"
	    "push %3\n"
	    "push %4\n"
	    "push %5\n"
	    "syscall" : :
	    "a" (sysc),
	    "r" (arg1),
	    "r" (arg2),
	    "r" (arg3),
	    "r" (arg4),
	    "r" (arg5)
	    : );
}

void sysenter(void)
{
	fprintf(stderr, "sysenter(%d, %lx, %lx, %lx, %lx, %lx)\n",
	    sysc, arg1, arg2, arg3, arg4, arg5);
	asm volatile(
	    "push %1\n"
	    "push %2\n"
	    "push %3\n"
	    "push %4\n"
	    "push %5\n"
	    "sysenter" : :
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
			//sigactions();
			inchild(syscall);
		}
	
		for (sysc = 0; sysc < 257 ; sysc++) {
			inchild(sysenter);
		}
	}

	for (i = 0; i < iter; i++) {
		rsp = argrand();
		arg1 = argrand();
		arg2 = argrand();
		arg3 = argrand();
		arg4 = argrand();
		arg5 = argrand();
		inchild(syscall_badrsp);
	}
}

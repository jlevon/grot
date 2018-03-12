#include <setjmp.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

sigjmp_buf jmp_env;

static void segv(int dummy)
{
	//fprintf(stderr, "SIGSEGV\n");
	siglongjmp(jmp_env, 1);
}

static void bus(int dummy)
{
	fprintf(stderr, "SIGBUS\n");
	siglongjmp(jmp_env, 1);
}

static void fpe(int dummy)
{
	fprintf(stderr, "SIGFPE\n");
	siglongjmp(jmp_env, 1);
}

#define INT(i) { \
	if (sigsetjmp(jmp_env, 0) == 0) { 	\
		fprintf(stderr, "int %d\n", i);	\
		asm volatile("int $" #i : : );	\
	}					\
}						\

void sigactions()
{
	struct sigaction new_action = { 0, };

	new_action.sa_handler = segv;
	(void)sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = SA_ONSTACK;
	if (sigaction(SIGSEGV, &new_action, NULL) < 0)
		exit(1);

	new_action.sa_handler = bus;
	(void)sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = SA_ONSTACK;
	if (sigaction(SIGBUS, &new_action, NULL) < 0)
		exit(1);

	new_action.sa_handler = fpe;
	(void)sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = SA_ONSTACK;
	if (sigaction(SIGFPE, &new_action, NULL) < 0)
		exit(1);
}

#define _XBEGIN_STARTED (~0u)

// ---------------------------------------------------------------------------
static __attribute__((always_inline)) inline unsigned int xbegin(void) {
  unsigned status;
  //asm volatile("xbegin 1f \n 1:" : "=a"(status) : "a"(-1UL) : "memory");
  asm volatile(".byte 0xc7,0xf8,0x00,0x00,0x00,0x00" : "=a"(status) : "a"(-1UL) : "memory");
  return status;
}

// ---------------------------------------------------------------------------
static __attribute__((always_inline)) inline void xend(void) {
  //asm volatile("xend" ::: "memory");
  asm volatile(".byte 0x0f; .byte 0x01; .byte 0xd5" ::: "memory");
}


#define TB
int main(int argc, char *argv[])
{
	char *p;
	char a;
	char *start = (char *)strtoull(argv[1], NULL, 0);
	char *started = 0;

	sigactions();

	printf("Sweeping from %lx\n", start);
	for (p = start ; p != 0; p += 4096) {
		if (((uint64_t)p % 1073741824) == 0)
			printf("At %lx\n", p);
		if (argc > 2) {
			if (xbegin() == _XBEGIN_STARTED) {
				a = *p;
				xend();
				if (started == 0)
					started = p;
			} else if (started != 0) {
				printf("Hit valid range %lx-%lx\n", started, p - 1);
				started = 0;
			}
		} else {
			if (sigsetjmp(jmp_env, 1) == 0) {
				a = *p;
				if (started == 0)
					started = p;
			} else if (started != 0) {
				printf("Hit valid range %lx-%lx\n", started, p - 1);
				started = 0;
			}
		}
	}
}


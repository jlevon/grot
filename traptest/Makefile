#

all: syscall_int syscall_int64 syscall_syscall syscall_syscall64 badseg
syscall_int64: syscall_int.c
	gcc -m64 -o syscall_int64 syscall_int.c
syscall_int: syscall_int.c
	gcc -o syscall_int syscall_int.c
syscall_syscall64: syscall_syscall.c
	gcc -m64 -o syscall_syscall64 syscall_syscall.c
syscall_syscall: syscall_syscall.c
	gcc -o syscall_syscall syscall_syscall.c
badseg: badseg.c
	gcc -o badseg badseg.c

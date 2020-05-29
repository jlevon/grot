#!/usr/sbin/dtrace -Cs

syscall::: { @[((cpu_t *)curcpu)->cpu_lpl->lpl_lgrpid, execname] = count(); }

tick-5s {
	printa(@);
	clear(@);
}

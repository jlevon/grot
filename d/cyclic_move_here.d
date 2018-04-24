#!/usr/sbin/dtrace -Cs

/* for OS-6848 */

BEGIN {
	self->lastcpu = -1;
}

#define CCPUID(a) ((cyc_id_t *)a)->cyi_cpu->cyp_cpu->cpu_id

sched:::on-cpu /execname == "bhyve" && cpu != self->lastcpu/
{
	printf("%d:%d CPU%d->CPU%d", pid, tid, self->lastcpu, cpu);
	self->lastcpu = cpu;
}

vcpu_notify_event:entry {
	printf("CPU%d->CPU%d notify for VCPU%d", cpu,
	    args[0]->vcpu[arg1].hostcpu, arg1);
	stack();
}

cyclic_move_here:entry /CCPUID(arg0) != cpu/ {
	printf("%d:%d cyclic CPU%d->CPU%d)", pid, tid, CCPUID(arg0), cpu);
}

cyclic_move_here:entry /CCPUID(arg0) == cpu/ {
	printf("Already here?!");
	stack();
}

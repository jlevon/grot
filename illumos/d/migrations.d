#!/usr/sbin/dtrace -Cs
#
# Track CPU migrations as well as enqueued time for a particular process's threads.

#define ONE_SEC 1000000000

BEGIN {
	self->pcpu = -1;
	migrations = 0;
	runnable = 0;
	target = $target;
}

sched:::on-cpu /pid == target && cpu != self->pcpu/
{
	migrations++;
	self->pcpu = cpu;
}

sched:::enqueue /args[1]->pr_pid == target/
{
	ts[args[0]->pr_lwpid] = timestamp;
#if DEBUG
	printf("%s:%s %d on %d at %lu ns", probename, execname, args[0]->pr_lwpid, args[2]->cpu_id, timestamp);
	stack();
#endif
}

sched:::on-cpu /ts[curlwpsinfo->pr_lwpid] != 0 &&
	(timestamp - ts[curlwpsinfo->pr_lwpid]) > (ONE_SEC / 100)/
{
#if 1 || DEBUG
	printf("thread %d now on %d queued for %lu ns", curlwpsinfo->pr_lwpid, cpu, timestamp - ts[curlwpsinfo->pr_lwpid]);
#endif
}

sched:::on-cpu /ts[curlwpsinfo->pr_lwpid] != 0/
{
	this->prev = ts[curlwpsinfo->pr_lwpid];
	this->diff = timestamp - this->prev;
	runnable += this->diff;
	ts[curlwpsinfo->pr_lwpid] = 0;
}

tick-1s {
	printf("total thread migrations: %5d total queue time: %u ns", migrations, runnable);
	migrations = 0;
	runnable = 0;
}


#!/usr/sbin/dtrace -Cs

#define ONE_SEC 1000000000

#define DEBUG 0

BEGIN {
}

sched:::enqueue /args[1]->pr_pid == $1/
{
	ts[args[0]->pr_lwpid] = timestamp;
}

sched:::on-cpu /curpsinfo->pr_pid == $1 && ts[curlwpsinfo->pr_lwpid] != 0 &&
	(timestamp - ts[curlwpsinfo->pr_lwpid]) > (ONE_SEC / 10)/
{
	printf("thread %d (%s) now on %d was queued for %lu us", curlwpsinfo->pr_lwpid, threadname, cpu, (timestamp - ts[curlwpsinfo->pr_lwpid] ) / 1000);
}

sched:::on-cpu /curpsinfo->pr_pid == $1 && ts[curlwpsinfo->pr_lwpid] != 0/
{
	this->prev = ts[curlwpsinfo->pr_lwpid];
	this->diff = timestamp - this->prev;
	@runnable[threadname, tid] = sum(this->diff);
	ts[curlwpsinfo->pr_lwpid] = 0;
}

tick-10s {
	printf("run q latency sum for cpu %d", $1);
	printa(@runnable);
	clear(@runnable);
}

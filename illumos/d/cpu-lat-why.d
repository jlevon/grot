#!/usr/sbin/dtrace -Cs

#define ONE_SEC 1000000000

#define DEBUG 0

BEGIN {
}

sched:::enqueue /args[0]->pr_lwpid == $1/
{
	ts[args[0]->pr_lwpid] = timestamp;
}

sched:::on-cpu /cpu == $1 && ts[curlwpsinfo->pr_lwpid] != 0 &&
	(timestamp - ts[curlwpsinfo->pr_lwpid]) > (ONE_SEC / 100)/ 
{
	printf("thread %d now on %d was queued for %lu us", curlwpsinfo->pr_lwpid, cpu, (timestamp - ts[curlwpsinfo->pr_lwpid] ) / 1000);
}

sched:::on-cpu /ts[curlwpsinfo->pr_lwpid] != 0/
{
	this->prev = ts[curlwpsinfo->pr_lwpid];
	this->diff = timestamp - this->prev;
	@runnable[execname, tid] = sum(this->diff);
	ts[curlwpsinfo->pr_lwpid] = 0;
}

tick-1s {
	printf("run q latency sum for cpu %d", $1);
	printa(@runnable);
	clear(@runnable);
}

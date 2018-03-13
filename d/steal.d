#!/usr/sbin/dtrace -Cs

/*
 * Report process steals from specific CPU dispatcher queues.
 */

sdt:::steal /((kthread_t *)arg0)->t_procp->p_pidp->pid_id == $1 && arg1 == NULL/ {
	this->thread = (kthread_t *)arg0;
	this->cpu = (cpu_t *)arg2;
	printf("stealing thread %d from non-CPU queue for CPU%d", this->thread->t_tid,
	    this->cpu->cpu_id);
}

sdt:::steal /((kthread_t *)arg0)->t_procp->p_pidp->pid_id == $1 && arg1 != NULL/ {
	this->thread = (kthread_t *)arg0;
	this->tcpu = (cpu_t *)arg1;
	this->cpu = (cpu_t *)arg2;
	printf("stealing thread %d from disp CPU%d for CPU%d", this->thread->t_tid,
	    this->tcpu->cpu_id, this->cpu->cpu_id);
}

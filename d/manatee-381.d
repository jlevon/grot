#!/usr/sbin/dtrace -Cs

#pragma D option quiet

#define	TRACEINTRET(f) fbt::f:return /self->spec/ \
	{ \
		speculate(self->spec); \
		printf("t%u:pid%d %s() -> %d\n", \
			timestamp - start, pid, probefunc, \
			arg1); \
	}

BEGIN {
	printf("Started tracing...\n");
	start = timestamp;
}

/*
 * Bracket shmat
 */

fbt::shmat:entry /execname == "postgres"/
{
	self->spec = speculation();
	printf("t%u:pid%d shmat(%d, %p)\n",
		timestamp - start, pid,
		args[0], args[1]
		);
}

fbt::shmat:return /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s() -> %p\n",
		timestamp - start, pid, probefunc,
		arg1);
}

fbt::shmat:return /self->spec && arg1 == 0/
{
	commit(self->spec); /* FIXME: discard */
	self->spec = 0;
}

/* FIXME */
fbt::shmat:return
{
	exit(0);
}

fbt::shmat:return /self->spec && arg1 != 0/
{
	commit(self->spec);
	self->spec = 0;
}

/*
 * Acquire kshmid_t
 */

fbt::ipc_lookup:entry /self->spec/
{
	speculate(self->spec);
	self->spp = (kshmid_t **)args[2];
}

fbt::ipc_lookup:return /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s() -> %d\n",
		timestamp - start, pid, probefunc,
		arg1);
	print(**(self->spp));
	printf("\n");
	self->spp = NULL;
}

fbt::map_addr:entry /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s(align_hint = %p, size = %p)\n",
		timestamp - start, pid, probefunc,
		*args[0], args[1]);
	self->ap = args[0];
}

fbt::map_addr:return /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s() -> addr = %p\n",
		timestamp - start, pid, probefunc,
		*self->ap);
	self->ap = 0;
}

fbt::sptcreate:entry /self->spec/
{
	speculate(self->spec);
}

TRACEINTRET(sptcreate)

fbt::as_map:entry /self->spec/
{
	speculate(self->spec);
	/* FIXME */
}

TRACEINTRET(as_map)

/* Any nosleep failures? */
fbt::kmem_zalloc:return, fbt::kmem_alloc:return /self->spec && arg1 == NULL/
{
	speculate(self->spec);
	printf("t%u:pid%d %s() failed\n",
		timestamp - start, pid, probefunc
		);
	stack();
}

/* Do we hit RLIMIT_VMEM in as_map_locked() ? */
fbt::rctl_action:entry /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s(%d)\n",
		timestamp - start, pid, probefunc,
		arg0);
}

/* Do we hit as_user_seg_limit? */
fbt::avl_numnodes:return /self->spec && arg1 >= `as_user_seg_limit/
{
	speculate(self->spec);
	printf("t%u:pid%d %s() %d > as_user_seg_limit %u\n",
		timestamp - start, pid, probefunc,
		arg1, `as_user_seg_limit);
}

fbt::seg_alloc:return /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s() -> %p\n",
		timestamp - start, pid, probefunc,
		arg1);
}

/* as_map_locked()->seg_alloc()->seg_attach() */
TRACEINTRET(as_addseg)

/* AS_ISPGLCK() in as_map_locked() - shouldn't be the case */
TRACEINTRET(as_ctl)

fbt::segspt_create:entry /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s()\n",
		timestamp - start, pid, probefunc
		);
	print(*(struct segspt_crargs *)arg1);
	printf("\n");
}

fbt::anon_swap_adjust:entry /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s(%u)\n",
		timestamp - start, pid, probefunc,
		args[0]);
	print(`k_anoninfo);
	printf("\n");
}

fbt::anon_swap_adjust:return /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s() -> %d\n",
		timestamp - start, pid, probefunc,
		arg1);
}

fbt::page_reclaim_mem:entry /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s(%u, %u, %d)\n",
		timestamp - start, pid, probefunc,
		args[0], args[1], args[2]
		);
}

TRACEINTRET(page_reclaim_mem)

fbt::anon_map_createpages:entry /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s(%p, %u, %u, ...)\n",
		timestamp - start, pid, probefunc,
		args[0], args[1], args[2]
		);
}

fbt::anon_map_createpages:return /self->spec/
{
	speculate(self->spec);
}

fbt::rctl_incr_locked_mem:entry /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s(_, _, %u)\n",
		timestamp - start, pid, probefunc,
		args[2]);
}

TRACEINTRET(rctl_incr_locked_mem)

/* shouldn't fail: accounting done already */
fbt::page_pp_lock:return /self->spec && arg1 == 0/
{
	speculate(self->spec);
	printf("t%u:pid%d %s() failed?\n",
		timestamp - start, pid, probefunc
		);
}


fbt::segspt_shmattach:entry /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s()\n",
		timestamp - start, pid, probefunc
		);
	print(*(struct shm_data *)args[1]);
	printf("\n");
}

TRACEINTRET(segspt_shmattach)

fbt::htable_create:entry /self->spec/
{
	speculate(self->spec);
	printf("t%u:pid%d %s()\n",
		timestamp - start, pid, probefunc
		);
	stack();
}

TRACEINTRET(hat_share)

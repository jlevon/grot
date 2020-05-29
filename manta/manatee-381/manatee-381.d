#!/usr/sbin/dtrace -Cs

#pragma D option quiet
#pragma D option temporal

/* FIXME: should we do this ? */
#define STOP_ON_FAILURE (0)
/* FIXME */
#define TEST_MODE (0)

#define	TRACEINTRET(f) fbt::f:return /self->spec/ \
	{ \
		speculate(self->spec); \
		printf("T%u:pid%dt%d %s() -> %d\n", \
			timestamp - start, pid, tid, probefunc, \
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
}

fbt::shmat:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s(%x, %p)\n",
		timestamp - start, pid, tid, probefunc,
		args[0], args[1]
		);
}

fbt::shmat:return /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() -> %p\n",
		timestamp - start, pid, tid, probefunc,
		arg1);
}

fbt::shmat:return /self->spec && arg1 == 0/
{
#if TEST_MODE
	commit(self->spec);
#else
	discard(self->spec);
#endif
	self->spec = 0;
}

#if TEST_MODE
fbt::shmat:return
{
	exit(0);
}
#endif

fbt::shmat:return /self->spec && arg1 != 0/
{
	commit(self->spec);
	self->spec = 0;
}

#if STOP_ON_FAILURE
fbt::shmat:return /arg1 != 0/
{
	stop();
}
#endif

/* Any nosleep failures? */
fbt::kmem_zalloc:return, fbt::kmem_alloc:return /self->spec && arg1 == NULL/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() failed\n",
		timestamp - start, pid, tid, probefunc
		);
	stack();
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
	printf("T%u:pid%dt%d %s() -> %d\n",
		timestamp - start, pid, tid, probefunc,
		arg1);
	print(**(self->spp));
	printf("\n");
	self->spp = NULL;
}

/* ============================== map_addr ====================================

 First possible failure point:

 402                 if (addr == 0) {
 403                         for (;;) {
 404                                 addr = (caddr_t)align_hint;
 405                                 map_addr(&addr, size, 0ll, 1, MAP_ALIGN);
 406                                 if (addr != NULL || align_hint == share_size)
 407                                         break;
 408                                 align_hint = share_size;
 409                         }
 410                         if (addr == NULL) {
 411                                 as_rangeunlock(as);
 412                                 error = ENOMEM;
 413                                 goto errret;
 414                         }

 As this is just finding VA, it seems unlikely to be the failure point.

*/

fbt::map_addr:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s(align_hint = %p, size = %p)\n",
		timestamp - start, pid, tid, probefunc,
		*args[0], args[1]);
	self->ap = args[0];
}

fbt::map_addr:return /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() -> addr = %p\n",
		timestamp - start, pid, tid, probefunc,
		*self->ap);
	self->ap = 0;
}

/* ============================== sptcreate ======================================

 459                 if (!isspt(sp)) {
 460                         error = sptcreate(size, &segspt, sp->shm_amp, prot,
 461                             flags, share_szc);
 462                         if (error) {
 463                                 as_rangeunlock(as);
 464                                 goto errret;
 465                         }

 We should be hitting this path... this can return ENOMEM

 */
fbt::sptcreate:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s()\n",
		timestamp - start, pid, tid, probefunc
		);
	self->in_sptcreate = 1;
}

fbt::sptcreate:return /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() -> %d\n",
		timestamp - start, pid, tid, probefunc,
		arg1);
	self->in_sptcreate = 0;
}

fbt::as_map:entry /self->spec && self->in_sptcreate/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() (create)\n",
		timestamp - start, pid, tid, probefunc
		);
}

fbt::as_map:return /self->spec && self->in_sptcreate/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() (create) -> %d\n",
		timestamp - start, pid, tid, probefunc,
		arg1);
}

/* ============================== as_map / segspt_shmattach ======================

 Last possible top-level failure path

	error = as_map(as, addr, size, segspt_shmattach, &ssd);

 */

fbt::as_map:entry /self->spec && !self->in_sptcreate/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() (attach)\n",
		timestamp - start, pid, tid, probefunc
		);
}

fbt::as_map:return /self->spec && !self->in_sptcreate/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() (attach) -> %d\n",
		timestamp - start, pid, tid, probefunc,
		arg1);
}

/* ======================= dive into as_map ===================================== */

/* Do we hit RLIMIT_VMEM in as_map_locked() ? */
fbt::rctl_action:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s(%d)\n",
		timestamp - start, pid, tid, probefunc,
		arg0);
}

/* Do we hit as_user_seg_limit? */
fbt::avl_numnodes:return /self->spec && arg1 >= `as_user_seg_limit/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() %d > as_user_seg_limit %u\n",
		timestamp - start, pid, tid, probefunc,
		arg1, `as_user_seg_limit);
}

fbt::seg_alloc:return /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() -> %p\n",
		timestamp - start, pid, tid, probefunc,
		arg1);
}

/* as_map_locked()->seg_alloc() */
TRACEINTRET(valid_va_range)
TRACEINTRET(valid_usr_range)

/* as_map_locked()->seg_alloc()->seg_attach() */
fbt::as_addseg:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s()\n",
		timestamp - start, pid, tid, probefunc
		);
	print(*args[1]);
	printf("\n");
}

TRACEINTRET(as_addseg)

/* AS_ISPGLCK() in as_map_locked() - shouldn't be the case */
TRACEINTRET(as_ctl)

/* ================= segspt_create ================================= */

fbt::segspt_create:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s()\n",
		timestamp - start, pid, tid, probefunc
		);
	print(*(struct segspt_crargs *)arg1);
	printf("\n");
}

/*
  407         if ((sptcargs->flags & SHM_PAGEABLE) == 0) {
  408                 if (err = anon_swap_adjust(npages))
  409                         return (err);
  410         }
 */
fbt::anon_swap_adjust:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s(%u)\n",
		timestamp - start, pid, tid, probefunc,
		args[0]);
	print(`k_anoninfo);
	printf("\n");
}

TRACEINTRET(anon_swap_adjust)

fbt::page_reclaim_mem:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s(%u, %u, %d); availrmem = %u, t_minarmem = %u\n",
		timestamp - start, pid, tid, probefunc,
		args[0], args[1], args[2], `availrmem, `tune.t_minarmem
		);
	self->reclaim_iter = 1;
}

fbt::page_needfree:entry /self->spec && self->reclaim_iter/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s(%u); `needfree = %u (+ %u), `availrmem = %u\n",
		timestamp - start, pid, tid, probefunc,
		args[0], `needfree, `needfree + args[0], `availrmem
		);
	self->reclaim_iter++;
}

fbt::kmem_reap_common:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s(%u)\n",
		timestamp - start, pid, tid, probefunc,
		*(unsigned int *)args[0]
		);
}

fbt::kmem_reap_start:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s(%u)\n",
		timestamp - start, pid, tid, probefunc,
		*(unsigned int *)args[0]
		);
}

fbt::page_reclaim_mem:return /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() -> %d after %u iterations, availrmem now %u\n",
		timestamp - start, pid, tid, probefunc,
		arg1, self->reclaim_iter - 1, `availrmem);
	self->reclaim_iter = 0;
}


/* never returns an error */
fbt::anon_map_createpages:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s(%p, %u, %u, ...)\n",
		timestamp - start, pid, tid, probefunc,
		args[0], args[1], args[2]
		);
	print(*args[4]);
	printf("\n");
}

fbt::rctl_incr_locked_mem:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s(_, _, %u)\n",
		timestamp - start, pid, tid, probefunc,
		args[2]);
}

TRACEINTRET(rctl_incr_locked_mem)

/* shouldn't fail: accounting done already */
fbt::page_pp_lock:return /self->spec && arg1 == 0/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s() failed?\n",
		timestamp - start, pid, tid, probefunc
		);
}


fbt::segspt_shmattach:entry /self->spec/
{
	speculate(self->spec);
	printf("T%u:pid%dt%d %s()\n",
		timestamp - start, pid, tid, probefunc
		);
	print(*(struct shm_data *)args[1]);
	printf("\n");
}

TRACEINTRET(segspt_shmattach)

TRACEINTRET(hat_share)

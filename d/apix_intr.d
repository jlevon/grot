#!/usr/sbin/dtrace -Cs

/* What interrupts are happening... */

#define T_SOFTINT      0x50fd  /*      pseudo softint trap type        */
#define trap (args[0]->r_trapno)

#define vec (args[0]->r_trapno + 0x20)
#define av (`apixs[cpu]->x_vectbl[vec]->v_autovect)

apix_do_interrupt:entry /trap != T_SOFTINT && av != NULL/ {
#if 0
	printf("CPU%d: vec:0x%x %a\n", cpu, vec, av->av_vector);
#endif
	@[cpu, vec, (void (*)())av->av_vector] = count();
}

apix_do_interrupt:entry /trap != T_SOFTINT && av == NULL/ {
#if 0
	printf("CPU%d: vec:0x%x no handler\n", cpu, vec);
#endif
	@[cpu, vec, (void (*)())0] = count();
}

tick-5s {
	printa("CPU%d vec:0x%x %a: %@8u\n", @);
	trunc(@);
}

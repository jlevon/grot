#!/usr/sbin/dtrace -Cs

fbt::do_core:entry {
	printf("zone %p zone_kcred refs %d\n", curthread->t_procp->p_zone, curthread->t_procp->p_zone->zone_kcred->cr_ref);
	printf("proc %p p->cred refs %d\n", curthread->t_procp, curthread->t_procp->p_cred->cr_ref);
	self->p = 1;
}

fbt::set_cred:entry /self->p/ {
}

fbt::do_core:return { 
	self->p = 0;
	printf("ret zone %p zone_kcred refs %d\n", curthread->t_procp->p_zone, curthread->t_procp->p_zone->zone_kcred->cr_ref);
	printf("ret proc %p p->cred refs %d\n", curthread->t_procp, curthread->t_procp->p_cred->cr_ref);
}


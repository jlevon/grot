#!/usr/sbin/dtrace -Cs

sdt:vmm::vmm-sibling-bind-count {
	printf("sibling CPU%d of CPU%d bind: %d", ((cpu_t *)arg1)->cpu_id, ((cpu_t *)arg0)->cpu_id, arg2);
}

sdt:vmm::vmm-choose-pcpu-lpl {
	printf("looking at lpl %p:%d", arg0, ((lpl_t *)arg0)->lpl_lgrpid);
}

fbt::vmm_score_pcpu:entry {
	self->c = args[0];
}

fbt::vmm_score_pcpu:return {
	printf("CPU%d lpl %p score: %d", self->c->cpu_id, self->c->cpu_lpl, arg1);
	self->c = 0;
}

fbt::vmm_choose_pcpu:entry {
	printf("%d:%d", pid, tid);
	self->t = timestamp;
}

fbt::vmm_choose_pcpu:return {
	printf("%d:%d -> CPU%d", pid, tid, ((cpu_t *)arg1)->cpu_id);
	printf("\nTook %d us", (timestamp - self->t) / 1000);
	self->t = 0;
}

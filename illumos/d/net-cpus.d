#!/usr/sbin/dtrace -Cs

sdt:::viona-tx {
	@tx[cpu] = count();
}

sdt:::viona-tx {
	@rx[cpu] = count();
}

viona_intr_ring:entry {
	self->t = 1;
}

vmx_set_intr_ready:entry /self->t/ {
	this->vm = args[0]->vm;
	this->vcpu = &this->vm->vcpu[args[0]->vcpuid];

	@intrs[cpu, this->vcpu->hostcpu, this->vcpu->lastloccpu] = count();
}

viona_intr_ring:return {
	self->t = 0;
}

ixgbe_intr_rx_work:entry {
	@ixgberx[cpu] = count();
}
ixgbe_intr_tx_work:entry {
	@ixgbetx[cpu] = count();
}

END {
	printf("tx\n\n");
	printa(@tx);
	printf("ixgbe tx\n\n");
	printa(@ixgbetx);
	printf("ixgbe rx\n\n");
	printa(@ixgberx);
	printf("rx\n\n");
	printa(@rx);
	printf("intrs CPU->vcpu\n\n");
	printa(@intrs);
}

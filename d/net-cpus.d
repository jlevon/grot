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
	@intrs[cpu, args[0]->cpuid] = count();
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

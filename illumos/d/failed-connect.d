#!/usr/sbin/dtrace -Cs

tcp:::connect-refused {
	this->addr = args[2]->ip_daddr;
	this->port = args[4]->tcp_dport;
	printf("zone %s %s(%d): connect(%s:%d)", zonename, execname, pid, this->addr, this->port);
	ustack();
}

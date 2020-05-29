#!/usr/sbin/dtrace -Cs

#pragma D option bufsize=32m

BEGIN {
	mp = (mblk_t *)0;
	stp = (struct stdata *)0;
}

/* reader */

fbt::kstrgetmsg:entry /execname == "haproxy-socket"/ {
	self->uio = args[2];
	self->resid = self->uio->uio_resid;
	printf("------------------ T%lu", timestamp);
	printf(" vnode %p stp:%p", args[0], args[0]->v_stream);
	stp = args[0]->v_stream;
}

fbt::strget:entry /args[0] == stp/ {
	printf("T%lu ", timestamp);
	printf("stp:%p q:%p (next:%p) sd_flag: %x", args[0], args[1], args[1]->q_next, args[0]->sd_flag);
	self->strget = 1;
}

fbt::strget:return /self->strget/ {
	printf("T%lu ", timestamp);
	printf("ret:%p", arg1);
	self->strget = 0;
}

fbt::strwaitq:entry /args[0] == stp/ {
	printf("T%lu ", timestamp);
	printf("sd_flag: %x", args[0]->sd_flag);
	self->strget = 1;
}

fbt::strwaitq:return /self->strget/ {
	printf("T%lu ", timestamp);
	printf("ret:%p", arg1);
	self->strget = 0;
}

fbt::kstrgetmsg:return /self->uio && self->resid - self->uio->uio_resid == 0/ {
	printf("T%lu:recv %d bytes", timestamp, self->resid - self->uio->uio_resid);
	exit(1);
}

fbt::kstrgetmsg:return /self->uio/ {
	printf("T%lu:recv %d bytes", timestamp, self->resid - self->uio->uio_resid);
	self->uio = 0;
	stp = 0;
}

fbt::strseteof:entry {
	printf("T%lu ", timestamp);
	printf("vnode %p stp %p", args[0], args[0]->v_stream);
}

#if 0
fbt::tl_wsrv:entry {
	printf("T%lu ", timestamp);
	printf("q:%p tep:%p q_first:%p", args[0], args[0]->q_ptr, args[0]->q_first);
}

fbt::tl_wsrv_ser:entry {
	printf("T%lu ", timestamp);
	printf("tep:%p q:%p q_first:%p", args[1], args[1]->te_wq, args[1]->te_wq->q_first);
	self->tl_wsrv_ser = args[1];
}

fbt::tl_wput_common_ser:entry {
	printf("T%lu ", timestamp);
	printf("mp:%p tep:%p ->te_wq:%p", args[0], args[1], args[1]->te_wq);
}

fbt::tl_wsrv_ser:return /self->tl_wsrv_ser/ {
	printf("T%lu ", timestamp);
	printf("done for tep:%p", self->tl_wsrv_ser);
	self->tl_wsrv_ser = 0;
}


fbt::putnext:entry /args[1]->b_datap->db_type == 1/ {
	printf("T%lu ", timestamp);
	printf("M_PROTO putnext %d for q:%p next:%p mp:%p putproc:%a", ((union T_primitives *)args[1]->b_rptr)->type, args[0], args[0]->q_next, args[1], args[0]->q_qinfo->qi_putp);
}

fbt::putq:entry /args[1]->b_datap->db_type == 1/ {
	printf("T%lu ", timestamp);
	printf("M_PROTO putq %d for q:%p mp:%p", ((union T_primitives *)args[1]->b_rptr)->type, args[0], args[1]);
}


#endif

fbt::tl_do_proto:entry /args[0]->b_datap->db_type == 1 &&
   ((union T_primitives *)args[0]->b_rptr)->type == 10/ {
	printf("T%lu ", timestamp);
	printf("handling T_ORDREL_REQ for mp:%p tep:%p  ->wq:%p next:%p stp:%p", args[0], args[1], args[1]->te_wq, args[1]->te_wq->q_next, args[1]->te_wq->q_stream);
}

fbt::putnext:entry /args[1]->b_datap->db_type == 1 &&
   ((union T_primitives *)args[1]->b_rptr)->type == 10/ {
	printf("T%lu ", timestamp);
	printf("T_ORDREL_REQ for q:%p q_next:%p mp:%p stp:%p putproc:%a", args[0], args[0]->q_next, args[1], args[0]->q_stream, args[0]->q_qinfo->qi_putp);
	printf(" exec %s", execname);
	stack();
	ustack();
}

fbt::putnext:entry /args[1]->b_datap->db_type == 1 &&
   ((union T_primitives *)args[1]->b_rptr)->type == 23/ {
	printf("T%lu ", timestamp);
	printf("T_ORDREL_IND for q:%p q_next:%p mp:%p stp:%p", args[0], args[0]->q_next, args[1], args[0]->q_stream);
}

fbt::tl_ordrel:entry {
	printf("T%lu ", timestamp);
	printf("\n mp:%p tep:%p te_wq:%p\n", args[0], args[1], args[1]->te_wq);
	this->peer = args[1]->_te_transport_state._te_cots_state._te_conp;
	printf(" peer tep:%p peer_rq:%p to get T_ORDREL_IND", 
		this->peer, this->peer->te_rq);
}

/* writer */

fbt::strrput:entry /args[1]->b_datap->db_type == 1 &&
   ((union T_primitives *)args[1]->b_rptr)->type == 23/ {
	printf("T%lu ", timestamp);
	printf("handling T_ORDREL_IND for q:%p next:%p stp:%p mp:%p", args[0], args[0]->q_next, args[0]->q_ptr, args[1]);
}

fbt::strsock_proto:entry /args[1]->b_datap->db_type == 1 &&
   ((union T_primitives *)args[1]->b_rptr)->type == 23/ {
	printf("T%lu ", timestamp);
	printf(" T_ORDREL_IND");
}

fbt::strrput:entry /stp && stp == args[0]->q_ptr/ {
	printf("T%lu:q:%p, mp:%p type %d stp:%p sd_flag %d", timestamp, args[0], args[1],
	    (args[1] ? args[1]->b_datap->db_type : -1),
	    args[0]->q_ptr,
	    ((struct stdata *)args[0]->q_ptr)->sd_flag);
	printf(" mtype %d", ((union T_primitives *)args[1]->b_rptr)->type);
	self->s = 1;
}

fbt::strrput:entry /execname == "haproxy" && mp == args[1]/ {
	mp = 0;
}


fbt::strrput:return /self->s/ {
	printf("T%lu ", timestamp);
	self->s = 0;
}

fbt::strwrite_common:entry /execname == "haproxy"/ {
	printf("T%lu ", timestamp);
	printf("stp:%p", args[0]->v_stream);
	self->strwrite = 1;
	stack();
	ustack();
}

fbt::putnext:entry /self->strwrite/ {
	printf("T%lu ", timestamp);
	printf("wqp:%p mp:%p stp:%p putproc:%a", args[0], args[1], args[0]->q_stream, args[0]->q_next->q_qinfo->qi_putp);
	mp = args[1];
}

fbt::tl_wput:entry /self->strwrite && mp == args[1]/  {
	printf("T%lu ", timestamp);
	printf("wq:%p mp:%p", args[0], args[1]);
}

fbt::serializer_enqueue:entry /self->strwrite && mp == args[2]/  {
	printf("T%lu ", timestamp);
	printf("proc:%a mp:%p", args[1], args[2]);
}

fbt::runservice:entry /stp && args[0]->q_stream == stp/ {
	printf("T%lu ", timestamp);
	printf("q:%p stp:%p", args[0], args[0]->q_stream);
	self->run = 1;
}

fbt::runservice:return /self->run/ {
	printf("T%lu ", timestamp);
	self->run = 0;
}

fbt::qenable_locked:entry /args[0]->q_stream == stp/ {
	printf("T%lu ", timestamp);
	printf("stp:%p stp->sd_qhead:%p flag:%x", args[0]->q_stream, args[0]->q_stream->sd_qhead, args[0]->q_flag);
}

fbt::strwrite_common:return /self->strwrite/ {
	printf("T%lu ", timestamp);
	self->strwrite = 0;
}

fbt::strclose:entry /execname == "haproxy"/ {
	printf("T%lu ", timestamp);
	self->stp = args[0]->v_stream;
	printf("stp:%p", self->stp);
	cstp = self->stp;
}

fbt::qdetach:entry /self->stp/ {
	printf("T%lu ", timestamp);
	printf("stp:%p close:%a", args[0]->q_stream, args[0]->q_qinfo->qi_qclose);
	q = args[0];
}

fbt::qdetach:return /self->stp/ {
	q = 0;
}

fbt::strclose:return /self->stp/ { 
	printf("T%lu\n\n\n\n", timestamp);
	self->stp = 0;
}

fbt::tl_wput_data_ser:entry /args[0] == mp/ {
	printf("T%lu", timestamp);
	this->tep = args[1];
	printf(" mp:%p tep:%p", args[0], args[1]);
/*
	printf("\ntep %p te_state %d\n", this->tep, this->tep->te_state);
	this->peer = args[1]->_te_transport_state._te_cots_state._te_conp;
	printf("peer %p te_state %d\n", this->peer, this->peer->te_state);
*/
	self->data_ser = 1;
}

fbt::putq:entry /args[1] == mp/ {
	printf("T%lu ", timestamp);
	printf("q:%p mp:%p", args[0], args[1]);
}

fbt::tl_wput_data_ser:return /self->data_ser/ {
	printf("T%lu", timestamp);
	self->data_ser = 0;
}

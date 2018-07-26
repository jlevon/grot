#include <setjmp.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

#if 0

sigjmp_buf jmp_env;

static void segv(int dummy)
{
	fprintf(stderr, "SIGSEGV\n");
	siglongjmp(jmp_env, 1);
}

static void bus(int dummy)
{
	fprintf(stderr, "SIGBUS\n");
	siglongjmp(jmp_env, 1);
}

static void fpe(int dummy)
{
	fprintf(stderr, "SIGFPE\n");
	siglongjmp(jmp_env, 1);
}

#define INT(i) { \
	if (sigsetjmp(jmp_env, 0) == 0) { 	\
		fprintf(stderr, "int %d\n", i);	\
		asm volatile("int $" #i : : );	\
	}					\
}						\

void sigactions()
{
	struct sigaction new_action = { 0, };

	new_action.sa_handler = segv;
	(void)sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = SA_ONSTACK;
	if (sigaction(SIGSEGV, &new_action, NULL) < 0)
		exit(1);

	new_action.sa_handler = bus;
	(void)sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = SA_ONSTACK;
	if (sigaction(SIGBUS, &new_action, NULL) < 0)
		exit(1);

	new_action.sa_handler = fpe;
	(void)sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = SA_ONSTACK;
	if (sigaction(SIGFPE, &new_action, NULL) < 0)
		exit(1);
}

#endif

#define INT(i) { \
	fprintf(stderr, "int %d\n", i);	\
	asm volatile("int $" #i : : );	\
}

void div0()
{
	fprintf(stderr, "actual div0\n");
	int a = 4 / 0;
}
	
void int0() { INT(0); }
void int1() { INT(1); }
void int2() { INT(2); }
void int3() { INT(3); }
void int4() { INT(4); }
void int5() { INT(5); }
void int6() { INT(6); }
void int7() { INT(7); }
void int8() { INT(8); }
void int9() { INT(9); }
void int10() { INT(10); }
void int11() { INT(11); }
void int12() { INT(12); }
void int13() { INT(13); }
void int14() { INT(14); }
void int15() { INT(15); }
void int16() { INT(16); }
void int17() { INT(17); }
void int18() { INT(18); }
void int19() { INT(19); }
void int20() { INT(20); }
void int21() { INT(21); }
void int22() { INT(22); }
void int23() { INT(23); }
void int24() { INT(24); }
void int25() { INT(25); }
void int26() { INT(26); }
void int27() { INT(27); }
void int28() { INT(28); }
void int29() { INT(29); }
void int30() { INT(30); }
void int31() { INT(31); }
void int32() { INT(32); }
void int33() { INT(33); }
void int34() { INT(34); }
void int35() { INT(35); }
void int36() { INT(36); }
void int37() { INT(37); }
void int38() { INT(38); }
void int39() { INT(39); }
void int40() { INT(40); }
void int41() { INT(41); }
void int42() { INT(42); }
void int43() { INT(43); }
void int44() { INT(44); }
void int45() { INT(45); }
void int46() { INT(46); }
void int47() { INT(47); }
void int48() { INT(48); }
void int49() { INT(49); }
void int50() { INT(50); }
void int51() { INT(51); }
void int52() { INT(52); }
void int53() { INT(53); }
void int54() { INT(54); }
void int55() { INT(55); }
void int56() { INT(56); }
void int57() { INT(57); }
void int58() { INT(58); }
void int59() { INT(59); }
void int60() { INT(60); }
void int61() { INT(61); }
void int62() { INT(62); }
void int63() { INT(63); }
void int64() { INT(64); }
void int65() { INT(65); }
void int66() { INT(66); }
void int67() { INT(67); }
void int68() { INT(68); }
void int69() { INT(69); }
void int70() { INT(70); }
void int71() { INT(71); }
void int72() { INT(72); }
void int73() { INT(73); }
void int74() { INT(74); }
void int75() { INT(75); }
void int76() { INT(76); }
void int77() { INT(77); }
void int78() { INT(78); }
void int79() { INT(79); }
void int80() { INT(80); }
void int81() { INT(81); }
void int82() { INT(82); }
void int83() { INT(83); }
void int84() { INT(84); }
void int85() { INT(85); }
void int86() { INT(86); }
void int87() { INT(87); }
void int88() { INT(88); }
void int89() { INT(89); }
void int90() { INT(90); }
void int91() { INT(91); }
void int92() { INT(92); }
void int93() { INT(93); }
void int94() { INT(94); }
void int95() { INT(95); }
void int96() { INT(96); }
void int97() { INT(97); }
void int98() { INT(98); }
void int99() { INT(99); }
void int100() { INT(100); }
void int101() { INT(101); }
void int102() { INT(102); }
void int103() { INT(103); }
void int104() { INT(104); }
void int105() { INT(105); }
void int106() { INT(106); }
void int107() { INT(107); }
void int108() { INT(108); }
void int109() { INT(109); }
void int110() { INT(110); }
void int111() { INT(111); }
void int112() { INT(112); }
void int113() { INT(113); }
void int114() { INT(114); }
void int115() { INT(115); }
void int116() { INT(116); }
void int117() { INT(117); }
void int118() { INT(118); }
void int119() { INT(119); }
void int120() { INT(120); }
void int121() { INT(121); }
void int122() { INT(122); }
void int123() { INT(123); }
void int124() { INT(124); }
void int125() { INT(125); }
void int126() { INT(126); }
void int127() { INT(127); }
void int128() { INT(128); }
void int129() { INT(129); }
void int130() { INT(130); }
void int131() { INT(131); }
void int132() { INT(132); }
void int133() { INT(133); }
void int134() { INT(134); }
void int135() { INT(135); }
void int136() { INT(136); }
void int137() { INT(137); }
void int138() { INT(138); }
void int139() { INT(139); }
void int140() { INT(140); }
void int141() { INT(141); }
void int142() { INT(142); }
void int143() { INT(143); }
void int144() { INT(144); }
void int145() { INT(145); }
void int146() { INT(146); }
void int147() { INT(147); }
void int148() { INT(148); }
void int149() { INT(149); }
void int150() { INT(150); }
void int151() { INT(151); }
void int152() { INT(152); }
void int153() { INT(153); }
void int154() { INT(154); }
void int155() { INT(155); }
void int156() { INT(156); }
void int157() { INT(157); }
void int158() { INT(158); }
void int159() { INT(159); }
void int160() { INT(160); }
void int161() { INT(161); }
void int162() { INT(162); }
void int163() { INT(163); }
void int164() { INT(164); }
void int165() { INT(165); }
void int166() { INT(166); }
void int167() { INT(167); }
void int168() { INT(168); }
void int169() { INT(169); }
void int170() { INT(170); }
void int171() { INT(171); }
void int172() { INT(172); }
void int173() { INT(173); }
void int174() { INT(174); }
void int175() { INT(175); }
void int176() { INT(176); }
void int177() { INT(177); }
void int178() { INT(178); }
void int179() { INT(179); }
void int180() { INT(180); }
void int181() { INT(181); }
void int182() { INT(182); }
void int183() { INT(183); }
void int184() { INT(184); }
void int185() { INT(185); }
void int186() { INT(186); }
void int187() { INT(187); }
void int188() { INT(188); }
void int189() { INT(189); }
void int190() { INT(190); }
void int191() { INT(191); }
void int192() { INT(192); }
void int193() { INT(193); }
void int194() { INT(194); }
void int195() { INT(195); }
void int196() { INT(196); }
void int197() { INT(197); }
void int198() { INT(198); }
void int199() { INT(199); }
void int200() { INT(200); }
void int201() { INT(201); }
void int202() { INT(202); }
void int203() { INT(203); }
void int204() { INT(204); }
void int205() { INT(205); }
void int206() { INT(206); }
void int207() { INT(207); }
void int208() { INT(208); }
void int209() { INT(209); }
void int210() { INT(210); }
void int211() { INT(211); }
void int212() { INT(212); }
void int213() { INT(213); }
void int214() { INT(214); }
void int215() { INT(215); }
void int216() { INT(216); }
void int217() { INT(217); }
void int218() { INT(218); }
void int219() { INT(219); }
void int220() { INT(220); }
void int221() { INT(221); }
void int222() { INT(222); }
void int223() { INT(223); }
void int224() { INT(224); }
void int225() { INT(225); }
void int226() { INT(226); }
void int227() { INT(227); }
void int228() { INT(228); }
void int229() { INT(229); }
void int230() { INT(230); }
void int231() { INT(231); }
void int232() { INT(232); }
void int233() { INT(233); }
void int234() { INT(234); }
void int235() { INT(235); }
void int236() { INT(236); }
void int237() { INT(237); }
void int238() { INT(238); }
void int239() { INT(239); }
void int240() { INT(240); }
void int241() { INT(241); }
void int242() { INT(242); }
void int243() { INT(243); }
void int244() { INT(244); }
void int245() { INT(245); }
void int246() { INT(246); }
void int247() { INT(247); }
void int248() { INT(248); }
void int249() { INT(249); }
void int250() { INT(250); }
void int251() { INT(251); }
void int252() { INT(252); }
void int253() { INT(253); }
void int254() { INT(254); }
void int255() { INT(255); }


void inchild(void (*func)())
{
	pid_t pid;
	switch ((pid = fork())) {
	case 0:
		func();
		exit(0);
	case -1:
		exit(1);
	default:
		waitpid(pid, NULL, 0);
		return;
	}

}
		
int main()
{
	//sigactions();

	inchild(div0);
	inchild(int0);
	inchild(int1);
inchild(int0);
inchild(int1);
inchild(int2);
inchild(int3);
inchild(int4);
inchild(int5);
inchild(int6);
inchild(int7);
inchild(int8);
inchild(int9);
inchild(int10);
inchild(int11);
inchild(int12);
inchild(int13);
inchild(int14);
inchild(int15);
inchild(int16);
inchild(int17);
inchild(int18);
inchild(int19);
inchild(int20);
inchild(int21);
inchild(int22);
inchild(int23);
inchild(int24);
inchild(int25);
inchild(int26);
inchild(int27);
inchild(int28);
inchild(int29);
inchild(int30);
inchild(int31);
inchild(int32);
inchild(int33);
inchild(int34);
inchild(int35);
inchild(int36);
inchild(int37);
inchild(int38);
inchild(int39);
inchild(int40);
inchild(int41);
inchild(int42);
inchild(int43);
inchild(int44);
inchild(int45);
inchild(int46);
inchild(int47);
inchild(int48);
inchild(int49);
inchild(int50);
inchild(int51);
inchild(int52);
inchild(int53);
inchild(int54);
inchild(int55);
inchild(int56);
inchild(int57);
inchild(int58);
inchild(int59);
inchild(int60);
inchild(int61);
inchild(int62);
inchild(int63);
inchild(int64);
inchild(int65);
inchild(int66);
inchild(int67);
inchild(int68);
inchild(int69);
inchild(int70);
inchild(int71);
inchild(int72);
inchild(int73);
inchild(int74);
inchild(int75);
inchild(int76);
inchild(int77);
inchild(int78);
inchild(int79);
inchild(int80);
inchild(int81);
inchild(int82);
inchild(int83);
inchild(int84);
inchild(int85);
inchild(int86);
inchild(int87);
inchild(int88);
inchild(int89);
inchild(int90);
inchild(int91);
inchild(int92);
inchild(int93);
inchild(int94);
inchild(int95);
inchild(int96);
inchild(int97);
inchild(int98);
inchild(int99);
inchild(int100);
inchild(int101);
inchild(int102);
inchild(int103);
inchild(int104);
inchild(int105);
inchild(int106);
inchild(int107);
inchild(int108);
inchild(int109);
inchild(int110);
inchild(int111);
inchild(int112);
inchild(int113);
inchild(int114);
inchild(int115);
inchild(int116);
inchild(int117);
inchild(int118);
inchild(int119);
inchild(int120);
inchild(int121);
inchild(int122);
inchild(int123);
inchild(int124);
inchild(int125);
inchild(int126);
inchild(int127);
inchild(int128);
inchild(int129);
inchild(int130);
inchild(int131);
inchild(int132);
inchild(int133);
inchild(int134);
inchild(int135);
inchild(int136);
inchild(int137);
inchild(int138);
inchild(int139);
inchild(int140);
inchild(int141);
inchild(int142);
inchild(int143);
inchild(int144);
inchild(int145);
inchild(int146);
inchild(int147);
inchild(int148);
inchild(int149);
inchild(int150);
inchild(int151);
inchild(int152);
inchild(int153);
inchild(int154);
inchild(int155);
inchild(int156);
inchild(int157);
inchild(int158);
inchild(int159);
inchild(int160);
inchild(int161);
inchild(int162);
inchild(int163);
inchild(int164);
inchild(int165);
inchild(int166);
inchild(int167);
inchild(int168);
inchild(int169);
inchild(int170);
inchild(int171);
inchild(int172);
inchild(int173);
inchild(int174);
inchild(int175);
inchild(int176);
inchild(int177);
inchild(int178);
inchild(int179);
inchild(int180);
inchild(int181);
inchild(int182);
inchild(int183);
inchild(int184);
inchild(int185);
inchild(int186);
inchild(int187);
inchild(int188);
inchild(int189);
inchild(int190);
inchild(int191);
inchild(int192);
inchild(int193);
inchild(int194);
inchild(int195);
inchild(int196);
inchild(int197);
inchild(int198);
inchild(int199);
inchild(int200);
inchild(int201);
inchild(int202);
inchild(int203);
inchild(int204);
inchild(int205);
inchild(int206);
inchild(int207);
inchild(int208);
inchild(int209);
inchild(int210);
inchild(int211);
inchild(int212);
inchild(int213);
inchild(int214);
inchild(int215);
inchild(int216);
inchild(int217);
inchild(int218);
inchild(int219);
inchild(int220);
inchild(int221);
inchild(int222);
inchild(int223);
inchild(int224);
inchild(int225);
inchild(int226);
inchild(int227);
inchild(int228);
inchild(int229);
inchild(int230);
inchild(int231);
inchild(int232);
inchild(int233);
inchild(int234);
inchild(int235);
inchild(int236);
inchild(int237);
inchild(int238);
inchild(int239);
inchild(int240);
inchild(int241);
inchild(int242);
inchild(int243);
inchild(int244);
inchild(int245);
inchild(int246);
inchild(int247);
inchild(int248);
inchild(int249);
inchild(int250);
inchild(int251);
inchild(int252);
inchild(int253);
inchild(int254);
inchild(int255);

}

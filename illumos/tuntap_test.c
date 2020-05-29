#include <sys/types.h>
#include <sys/stat.h>
#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <stropts.h>
#include <unistd.h>
#include <strings.h>
#include <string.h>
#include <sys/conf.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/ethernet.h>
#include <sys/dlpi.h>

/* Pulled from if_tun.h */
#define TUNNEWPPA	(('T'<<16) | 0x0001)
#define TUNSETPPA	(('T'<<16) | 0x0002)

/* Stolen from udp_impl.h */
typedef uint16_t in_port_t;
typedef	struct udpahdr_s {
	in_port_t	uha_src_port;		/* Source port */
	in_port_t	uha_dst_port;		/* Destination port */
	uint16_t	uha_length;		/* UDP length */
	uint16_t	uha_checksum;		/* UDP checksum */
} udpha_t;

/* Stolen from ip.h */
typedef uint32_t ipaddr_t;
typedef struct ipha_s {
	uint8_t		ipha_version_and_hdr_length;
	uint8_t		ipha_type_of_service;
	uint16_t	ipha_length;
	uint16_t	ipha_ident;
	uint16_t	ipha_fragment_offset_and_flags;
	uint8_t		ipha_ttl;
	uint8_t		ipha_protocol;
	uint16_t	ipha_hdr_checksum;
	ipaddr_t	ipha_src;
	ipaddr_t	ipha_dst;
} ipha_t;


/*
 * TODO: Document what is happening here.
 */
static int
tun_new_ppa(int fd)
{
	int ppa, ret;
	struct strioctl strioc = {
		.ic_cmd = TUNNEWPPA,
		.ic_timout = 0,
		.ic_len = sizeof (ppa),
		.ic_dp = (char *)&ppa
	};

	for (int i = 0; i < 128; i++) {
		ppa = i;
		ret = ioctl(fd, I_STR, &strioc);
		if (ret == -1 && errno != EEXIST) {
			perror("failed to I_STR");
			exit(1);
		}

		if (ret != -1) {
			return (ppa);
		}
	}

	fprintf(stderr, "failed to find PPA\n");
	exit(1);
}

static void
push_ip(int fd)
{
	int ret;

	ret = ioctl(fd, I_PUSH, "ip");
	assert(ret != -1);
}

static void
unit_select(int fd, int ppa)
{
	int ret;

	ret = ioctl(fd, IF_UNITSEL, &ppa);
	assert(ret != -1);
}

static int
plink(int fd, int other_fd)
{
	int ret;
	int other_fd_cp = other_fd;

	ret = ioctl(fd, I_PLINK, other_fd_cp);
	if (ret == -1) {
		perror("failed to I_PLINK");
		return (-1);
	}

	return (ret);
}

static void
set_muxid(int fd, char *name, int ip_muxid, int arp_muxid,
    boolean_t tap_mode)
{
	struct lifreq lir;

	bzero(&lir, sizeof (lir));
	strlcpy(lir.lifr_name, name, LIFNAMSIZ);
	lir.lifr_lifru.lif_muxid[0] = ip_muxid;

	if (tap_mode)
		lir.lifr_arp_muxid = arp_muxid;

	if (ioctl(fd, SIOCSLIFMUXID, &lir) == -1) {
		perror ("failed to set mux id");
		exit (1);
	}
}

#define	NAMESZ	32
#define	ETH_FMT	"%x:%x:%x:%x:%x:%x"

int
main(int argc, char *argv[])
{
	int ret;
	int ip_fd, dev_fd, if_fd, arp_fd, ppa, ip_muxid, arp_muxid;
	char name[NAMESZ];
	boolean_t tap_mode = B_FALSE;
	char c;

	while ((c = getopt(argc, argv, ":er")) != -1) {
		switch (c) {
		case 'e':
			tap_mode = B_TRUE;
			break;
		case '?':
			fprintf(stderr, "Unrecognized option: -%c\n", optopt);
			return (EXIT_FAILURE);
		}
	}

	ip_fd = open("/dev/udp", O_RDWR, 0);
	assert(ip_fd != -1);

	if (tap_mode)
		dev_fd = open("/dev/tap", O_RDWR, 0);
	else
		dev_fd = open("/dev/tun", O_RDWR, 0);

	assert(dev_fd != -1);

	ppa = tun_new_ppa(dev_fd);

	if (tap_mode)
		ret = snprintf(name, NAMESZ, "tap%d", ppa);
	else
		ret = snprintf(name, NAMESZ, "tun%d", ppa);

	assert(ret > 0);
	printf("device: %s\n", name);

	if (tap_mode)
		if_fd = open("/dev/tap", O_RDWR, 0);
	else
		if_fd = open("/dev/tun", O_RDWR, 0);

	assert(if_fd != -1);

	push_ip(if_fd);

	if (!tap_mode)
		unit_select(if_fd, ppa);

	if (tap_mode) {
		struct lifreq lir;
		struct strioctl strioc;

		bzero(&lir, sizeof (lir));
		bzero(&strioc, sizeof (strioc));

		if (ioctl(if_fd, SIOCGLIFFLAGS, &lir) == -1) {
			perror("SIOCGLIFFLAGS failed");
			return (EXIT_FAILURE);
		}

		strlcpy(lir.lifr_name, name, LIFNAMSIZ);
		lir.lifr_ppa = ppa;

		if (ioctl(if_fd, SIOCSLIFNAME, &lir) == -1) {
			perror("SIOCSLIFNAME failed");
			return (EXIT_FAILURE);
		}

		if (ioctl(if_fd, SIOCGLIFFLAGS, &lir) == -1) {
			perror("SIOCGLIFFLAGS (#2) failed");
			return (EXIT_FAILURE);
		}

		if (ioctl(if_fd, I_PUSH, "arp") == -1) {
			perror("Failed to push arp onto if_fd");
			return (EXIT_FAILURE);
		}

		while (B_TRUE) {
			if (ioctl(ip_fd, I_POP, NULL) == -1)
				break;
		}

		if ((arp_fd = open("/dev/tap", O_RDWR, 0)) == -1) {
			perror("failed to open arp_fd");
			return (EXIT_FAILURE);
		}

		if (ioctl(arp_fd, I_PUSH, "arp") == -1) {
			perror("failed to push arp onto arp_fd");
			return (EXIT_FAILURE);
		}

		strioc.ic_cmd = SIOCSLIFNAME;
		strioc.ic_timout = 0;
		strioc.ic_len = sizeof (lir);
		strioc.ic_dp = (char *)&lir;

		if (ioctl(arp_fd, I_STR, &strioc) == -1) {
			perror("failed to SIOCSLIFNAME arp_fd");
			return (EXIT_FAILURE);
		}
	}

	ip_muxid = plink(ip_fd, if_fd);
	if (ip_muxid == -1) {
		return (1);
	}
	printf("ip_muxid: %d\n", ip_muxid);

	close(if_fd);

	if (tap_mode) {
		if ((arp_muxid = ioctl(ip_fd, I_PLINK, arp_fd)) == -1) {
			perror("failed to PLINK ip_fd to ARP");
			return (EXIT_FAILURE);
		}
		close(arp_fd);
	}

	set_muxid(ip_fd, name, ip_muxid, arp_muxid, tap_mode);

	for (;;) {
		char buf[1518];
		char *rptr = buf;
		struct strbuf sbuf;
		int flags = 0, ret;
		ipha_t *ipha;
		/* udpha_t *udp; */
		struct in_addr src, dst;

		bzero(buf, sizeof (buf));
		bzero(&sbuf, sizeof (sbuf));
		sbuf.maxlen = sizeof (buf);
		sbuf.buf = buf;
		ret = getmsg(dev_fd, NULL, &sbuf, &flags);
		if (ret < 0) {
			/*
			 * Might need to modify this to check for
			 * MOREDATA.
			 */
			perror("getmsg() failed");
			return (1);
		}

		printf("Received %d bytes\n", sbuf.len);

		/* For now, we assume untagged. */
		if (tap_mode) {
			struct ether_header *eh = (struct ether_header *)rptr;
			ether_addr_t *src;
			ether_addr_t *dst;

			src = &eh->ether_shost.ether_addr_octet;
			dst = &eh->ether_dhost.ether_addr_octet;

			printf("ETHER:\t----- Ether Header -----\n");
			printf("ETHER:\n");
			printf("ETHER:\tDestination = ");
			printf(ETH_FMT, (*dst)[0], (*dst)[1], (*dst)[2],
			    (*dst)[3], (*dst)[4], (*dst)[5]);
			printf(",\n");
			printf("ETHER:\tSource      = ");
			printf(ETH_FMT, (*src)[0], (*src)[1], (*src)[2],
			    (*src)[3], (*src)[4], (*src)[5]);
			printf(",\n");
			printf("ETHER:\tEthertype = %.4x\n",
			    ntohs(eh->ether_type));
			printf("ETHER:\n");
			rptr += sizeof (eh);
		}

		ipha = (ipha_t *)rptr;

		bcopy(&ipha->ipha_src, &src, sizeof (src));
		bcopy(&ipha->ipha_dst, &dst, sizeof (dst));
		printf("IP:\t----- IP Header -----\n");
		printf("IP:\n");
		printf("IP:\tTotal length: %u bytes\n",
		    ntohs(ipha->ipha_length));
		printf("IP:\tHeader checksum: 0x%.4x\n",
		    ntohs(ipha->ipha_hdr_checksum));
		printf("IP:\tSource address = %s, %s\n", inet_ntoa(src),
		    inet_ntoa(src));
		printf("IP:\tDestination address = %s, %s\n", inet_ntoa(dst),
		    inet_ntoa(dst));
		printf("IP:\n");

	}
}


#include <stdio.h>
#include <sys/types.h>
#include <stdint.h>
#include <errno.h>
#include <stdlib.h>

/* walk a 64-bit pagetable */

#define masktop(val, i) (val & ((1UL << (i + 1)) - 1))
#define maskbottom(val, i) (val & ~((1UL << i) - 1))

#define pickbits(val, i, j) (masktop(maskbottom(val, j), i))

uint64_t
getbits(uint64_t in, uint64_t high, uint64_t low, uint64_t dest)
{
	uint64_t ret = pickbits(in, high, low);
	ret >>= high - dest;
	//printf("%lx here\n", ret);
	return (ret);
}

/*
 * usage: walk-pt <cr3> <va>
 */
int
main(int argc, char *argv[])
{
	uint64_t cr3 = strtoull(argv[1], NULL, 0);
	uint64_t va = strtoull(argv[2], NULL, 16);
	char buf[64];

	uint64_t tmp;

	printf("%%cr3 = 0x%llx, va = 0x%llx\n", cr3, va);

/*
A PML4E is selected using the physical
address defined as follows:
— Bits 51:12 are from CR3.
— Bits 11:3 are bits 47:39 of the linear address.
— Bits 2:0 are all 0.
*/
	uint64_t pml4e = getbits(cr3, 51, 12, 51) | getbits(va, 47, 39, 11);
	printf("pml4e paddr is 0x%lx; enter 0x%lx::dump -p -eg8\n",  pml4e, pml4e);
	fgets(buf, sizeof (buf), stdin);
	sscanf(buf, "%lx", &tmp);
	printf("got %lx\n", tmp);

/*
A PDPTE is selected using the physical address defined as follows:
— Bits 51:12 are from the PML4E.
— Bits 11:3 are bits 38:30 of the linear address.
— Bits 2:0 are all 0.
*/

	uint64_t pdpte = getbits(tmp, 51, 12, 51) | getbits(va, 38, 30, 11);
	printf("pdpte paddr is 0x%lx; enter 0x%lx::dump -p -eg8\n", pdpte, pdpte);
	fgets(buf, sizeof (buf), stdin);
	sscanf(buf, "%lx", &tmp);
	printf("got %lx\n", tmp);

/*
A PDE is selected using the physical address defined as follows:
— Bits 51:12 are from the PDPTE.
— Bits 11:3 are bits 29:21 of the linear address.
— Bits 2:0 are all 0.
*/

	uint64_t pde = getbits(tmp, 51, 12, 51) | getbits(va, 29, 21, 11);
	printf("pde paddr is 0x%lx; enter 0x%lx::dump -p -eg8\n", pde, pde);
	fgets(buf, sizeof (buf), stdin);
	sscanf(buf, "%lx", &tmp);
	printf("got %lx\n", tmp);

/*
A PTE is selected using the physical address defined as follows:
— Bits 51:12 are from the PDE.
— Bits 11:3 are bits 20:12 of the linear address.
— Bits 2:0 are all 0.
*/

	uint64_t pte = getbits(tmp, 51, 12, 51) | getbits(va, 20, 12, 11);
	printf("pde paddr is 0x%lx; enter 0x%lx::dump -p -eg8\n", pte, pte);
}

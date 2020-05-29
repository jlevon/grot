
#include <stdio.h>
#include <sys/types.h>
#include <stdint.h>

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


int main()
{
	uint64_t phys = 0xfffffff0;

	uint64_t eptp = 0x2034a701e;
/*
—   Bits 63:52 are all 0.
—   Bits 51:12 are from the EPTP.
—   Bits 11:3 are bits 47:39 of the guest-physical address.
—   Bits 2:0 are all 0.
*/
	printf("pml4e paddr is %lx\n", getbits(eptp, 51, 12, 51) | getbits(phys, 47, 39, 11));
/*
2034a7000::dump -p -eg8
2034a7000:  00000001c3c10007
*/
	uint64_t pml4e = 0x00000001c3c10007;

/*
An EPT PDPTE is selected using the physical address defined as follows:
—   Bits 63:52 are all 0.
—   Bits 51:12 are from the EPT PML4E.
—   Bits 11:3 are bits 38:30 of the guest-physical address.
—   Bits 2:0 are all 0.
*/

	printf("pdpte paddr is %lx\n", getbits(pml4e, 51, 12, 51) | getbits(phys, 38, 30, 11));

/*
1c3c10018::dump -p -eg8
1c3c10018:  00000002306f4007
*/
	uint64_t pdpte = 0x00000002306f4007;

/*
An EPT page-directory comprises 512 64-bit entries (PDE s). An EPT PDE
is selected using the physical address defined as follows:
—   Bits 63:52 are all 0.
—   Bits 51:12 are from the EPT PDPTE.
—   Bits 11:3 are bits 29:21 of the guest-physical address.

        0xfffffff0 = 0x1ff .. << 3  0xff8
—   Bits 2:0 are all 0.
*/

	printf("pde paddr is %lx\n", getbits(pdpte, 51, 12, 51) | getbits(phys, 29, 21, 11));

/*
2306f4ff8::dump -p -eg8
2306f4ff8:  00000002113f6007
*/

	uint64_t pde = 0x00000002113f6007;

/*
An EPT page table comprises 512 64-bit entries (PTEs). An EPT PTE is selected using a physical address defined as follows:
—   Bits 63:52 are all 0.
—   Bits 51:12 are from the EPT PDE.
—   Bits 11:3 are bits 20:12 of the guest-physical address.
—   Bits 2:0 are all 0.
*/

	printf("pte paddr is %lx\n", getbits(pde, 51, 12, 51) | getbits(phys, 20, 12, 11));
/*
[3]> 2113f6ff8::dump -p -eg8
2113f6ff8:  00000002229cd0b5
*/

That pte entry: Hex 00000002229cd0b5, binary 1000100010100111001101000010110101,
set bits 0,2,4,5,7,12,14,15,18,19,20,23,25,29,33,

READ,EXEC, (memtype is 6, WB),  ignored, 

}


#include <stdio.h>
#include <inttypes.h>

/* sscanf can't detect integer overflow */

int main()
{
	uint64_t out;
	int ret;

	ret = sscanf("18446744073709551616", "%"SCNu64, &out);
	printf("ret:%d val:%" PRIu64 "\n", ret, out);
	ret = sscanf("184467440737095516167777", "%"SCNu64, &out);
	printf("ret:%d val:%" PRIu64 "\n", ret, out);
}

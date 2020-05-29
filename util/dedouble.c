#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
    int rdHdl, ret, i;
    char buffer[1024];

    if(argc < 1) {
        printf("Usage: %s <input-filename>\n", argv[0]);
        return -1;
    }

    if((rdHdl = open(argv[1], O_RDONLY | O_NONBLOCK)) < 0) {
        printf("Error opening file %s.  Error %d:%s\n", argv[1], errno,
strerror(errno));
        return -1;
    }

    memset(buffer, 0, sizeof(buffer));

    /* Read input and put into output */
    while((ret = read(rdHdl, &buffer[0], sizeof(buffer))) > 0) {
        for (i = 0; i < ret ; i += 2) 
		printf("%c", buffer[i]);
    }

    close(rdHdl);
    // print success
    return 0;
}

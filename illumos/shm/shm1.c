
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#define ONE_GIG 1073741824UL


int main(int argc, char *argv[])
{
   size_t size = ONE_GIG * 2;
   int count = 20000;

	setvbuf(stdout, NULL, _IOLBF, 1024);

   int id = shmget( 1, size, IPC_CREAT | IPC_EXCL | 0660 );

   if ( id == -1 )
   {
      fprintf(stderr, "Failure!\n");
   }
   else
   {
      fprintf(stderr, "Success id %d!\n", id);

      fprintf(stderr, "Attaching to shared memory. \n");

      void * p = shmat( id, 0, ((argc > 1 && strcmp(argv[1], "dism") == 0) ? SHM_PAGEABLE : SHM_SHARE_MMU));
#if 0
      volatile void * p = (volatile void *)shmat( id, 0, );
#endif

      if ( p == (void *)-1 ) {
         fprintf(stderr, "Failure!\n");
      } else {
         fprintf(stderr, "Success!\n");

         fprintf(stderr, "Using shared memory %p\n", p);
  
	printf("ready\n");
	fflush(stdout);

         //         
         // Touch the whole shared segment.
         // Fill it with '*'.
         //
         // This will force the amount reserved
         // to be actually allocated (at least with DISM).
         //

	for (int i = 0; i < count; i++) {
		size_t off;

		for (;;) {
			off = ((size_t)rand() * 4096) % size;
			if (*((volatile char *)p + off) == 0)
				break;
		}
		int c = ((rand() ) % 255) + 1;
		*((volatile char *)p + off) = c;
		fprintf(stderr, "shm1: %d: %d %d %p \n", i, off, c, (volatile char *)p + off);
		printf("%d %d\n", off, c);
		fflush(stdout);
	}

	
	char *buf = NULL;
	size_t sz = 0;
	fprintf(stderr, "Waiting for keypress\n\n");
	getline(&buf, &sz, stdin);

         fprintf(stderr, "Detaching shared memory. \n");

         switch ( shmdt((char *) p ) )
         {
            case 0:
               fprintf(stderr, "Success!\n");
               break;

            case -1:
               fprintf(stderr, "Failure!\n");
               break;

            default:
               fprintf(stderr, "?\n");
               break;
         }
      }

      //
      // End of fun!
      //
  
      fprintf(stderr, "Removing shared memory. \n");

      switch ( shmctl( id, IPC_RMID, 0 ) )
      {
         case 0:
            fprintf(stderr, "Success!\n");
            break;

         case -1:
            fprintf(stderr, "Failure!\n");
            break;

         default:
            fprintf(stderr, "?\n");
            break;
      }
   }

   return 0;
}

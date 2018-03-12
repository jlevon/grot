
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
 #include <assert.h>
#include <sys/ipc.h>
#include <sys/shm.h>

/*
 * This is just a raw demonstration of the shared memory API.
 * To avoid leaks use "resource acquisition is initialization".
 */
#define ONE_GIG 1073741824UL


  
int main(int argc, char *argv[])
{
   size_t size = ONE_GIG * 2;
char *buf = NULL;
size_t sz = 0;

	// ready
	getline(&buf, &sz, stdin);


   int id = shmget( 1, size, 0660 );

   if ( id == -1 )
   {
      fprintf(stderr, "shm2: Failure!\n");
   }
   else
   {
      fprintf(stderr, "shm2:Success %d!\n", id);

      fprintf(stderr, "Attaching to shared memory. \n");

      //
      // For a "standard" shared memory segment, 
      // don't pass any flags, that is, pass 0.
      //
      // SHM_RND [Optional]
      // Asks to round down the address to a page boundary.
      // Not necessary for ISM or DISM.
      //
      // SHM_SHARE_MMU
      // Asks for a ISM segment locked in physical memory.
      //
      // SHM_PAGEABLE
      // Asks for a DISM segment pageable (virtual memory).
      //
  
      void * p = shmat( id, 0, ((argc > 1 && strcmp(argv[1], "dism") == 0) ? SHM_PAGEABLE : SHM_SHARE_MMU));

      if ( p == (void *)-1 ) {
         fprintf(stderr, "shm2 shmat Failure! %d\n", errno);
      } else {
         fprintf(stderr, "Success!\n");

         fprintf(stderr, "shm2: Using shared memory %p\n", p);
  
	int i = 0;
	for (;;) {
		unsigned int c;
		unsigned char d;
		size_t off;

		int read = fscanf(stdin, "%lu %d\n", &off, &c);
		assert(read == 2);

		d = *((unsigned char *)p + off);
		if (d != c)  {
			fprintf(stderr, "shm2: %d: got %d %d %p\n", i, off, c, (unsigned char *)p + off);
			fprintf(stderr, "shm2: %d != %d\n", d, c);
		} else {
		//	fprintf(stderr, "shm2: %d: got %d %d %p\n", i, off, c, (unsigned char *)p + off);
		//	fprintf(stderr, "shm2: %d == %d\n", d, c);
	}

		free(buf);
		if (feof(stdin))
			break;
		i++;
	}

         fprintf(stderr, "Detaching shared memory. \n");

         switch ( shmdt( (char *)p ) )
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

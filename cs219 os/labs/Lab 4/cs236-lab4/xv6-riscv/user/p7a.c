#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"



int
main(int argc, char *argv[])
{
//   int fd, i;
  xtrace_start();
    // printf("Creating a pipe\n");
    int p[2];
    if (pipe(p) < 0) {
        printf("pipe error\n");
        exit(1);
    }
    getpid();
  xtrace_end();
  exit(0);
}

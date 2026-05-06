#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  int fd_in, fd_out;

  // 1. Check for correct number of command-line arguments
  if(argc != 3) {
    printf("Usage: %s <input_file> <output_file>\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  printf("argv[1]: %s, argv[2]: %s\n", argv[1],argv[2]);
  

  // 2. Open input file for reading
  fd_in=open(argv[1],0);
  fd_out=open(argv[2],1);

  // 3. Open output file for writing (create/truncate as needed)

  // 4. Redirect STDIN to input file using dup2()
  dup2(fd_in,0);
  dup2(fd_out,1);
  // 5. Redirect STDOUT to output file using dup2()

  // 6. Close unused file descriptors
  close(fd_in);
  close(fd_out);
  // 7. Execute the inbuilt cat command using exec()
  char* g[]={"cat",NULL};
  execvp(g[0],g);
  return 0;
}

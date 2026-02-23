// p1a.c
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main() {
  int fd[2]; // fd[0] -> read end, fd[1] -> write end
  char buffer[100];
  char *message = "Hello World";

  // 1. Create the pipe using pipe()
  int p;
  p=pipe(fd);

  // 2. Write a message to the write end of the pipe
  write(fd[1],message,11);
  

  // 3. Read the message from the read end of the pipe
  read(fd[0],buffer,11);
  // 4. Print the message read from the pipe
  printf("%s\n",buffer);

  // 5. Close both ends of the pipe
  close(fd[1]);
  close(fd[0]);
  return 0;
}

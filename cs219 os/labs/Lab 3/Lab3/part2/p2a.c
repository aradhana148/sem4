#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void f(int a){
  printf("s: %d\n",getpid());
}

int main(int argc, char *argv[]) {
  /* TODO: implement logic here */
  signal(SIGINT,f);
  while(1){}
  return 0;
}

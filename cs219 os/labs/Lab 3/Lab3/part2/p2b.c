#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int ff=0;
int f;
int handler(int s){
  printf("%d\n",f);
  ff=1;
}

int main(int argc, char *argv[]) {
  /* TODO: implement logic here */
  f=fork();
  if(f==0){
    sleep(3);
    exit(0);
  }
  else{
    signal(SIGCHLD,handler);
    while(ff==0){}
    printf("d\n");

  }
  return 0;
}

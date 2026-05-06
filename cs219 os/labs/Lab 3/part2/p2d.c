#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>


void h(int a){
  printf("s: %d\n",getpid());
}

int main(int argc, char *argv[]) {
  int f=fork();
  int ff;
  if(f>0){
    ff=fork();
  }
  if(f>0 && ff>0){
    signal(SIGINT,h);
    while(1){}
  }
  else if(f==0){
    setpgid(0,0);
    printf("f%d\n",getpid());
    while(1){}
  }
  else if(ff==0){
    printf("ff%d\n",getpid());
  }
  return 0;
}

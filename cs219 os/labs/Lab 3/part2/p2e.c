#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  /* TODO: implement logic here */
  int f=fork();
  int ff;
  if(f>0){
    ff=fork();
  }
  if(ff==0 && f>0){
    printf("2 %d\n", getpid());
    sleep(2);
    exit(0);
  }
  else if(f==0){
    printf("1 %d\n", getpid());
    sleep(2);
    exit(0);
  }
  else if(f>0 && ff>0){
    sleep(5);
    wait(NULL);
    wait(NULL);
    printf("ff\n");
    while(1){}

  }
  return 0;
}

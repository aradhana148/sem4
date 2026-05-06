#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void handler(int sig,siginfo_t *info, void* ucontext){
  double user=(double)info->si_utime/100;
  double syss=(double)info->si_stime/100;
  printf("%.6f,%.6f\n",user,syss);
}


int main(int argc, char *argv[]) {
  struct sigaction sg;
  sg.sa_flags=SA_SIGINFO;
  sg.sa_sigaction=handler;
  sigaction(SIGCHLD, &sg, NULL);
  int f=fork();
  if(argc<=1){
    printf("give nice\n");
    return;
  }
  if(f==0){
    char* arr[argc];
    for(int i=0;i<argc-1;i++){
      arr[i]=argv[i+1];
    }
    arr[argc-1]=NULL;
    execvp(arr[0],arr);
  }
  else if(f>0){
    wait();
  }

  return 0;
}

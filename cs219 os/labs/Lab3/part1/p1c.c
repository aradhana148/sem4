#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main() {
  int p1_to_p2[2]; // Pipe: Parent -> Child 1
  int p2_to_p3[2]; // Pipe: Child 1 -> Child 2
  int p3_to_p1[2]; // Pipe: Child 2 -> Parent

  pid_t pid1, pid2;
  int num;

  // 1. take num input from command line
  scanf("%d",&num);

  // 2. Create all three pipes
  int p1=pipe(p1_to_p2);
  int p2=pipe(p2_to_p3);
  int p3=pipe(p3_to_p1);

  // 3. Create first child process (Child 1)
  int f1=fork();
  int f2;

  // 4. Create second child process (Child 2)
  if(f1>0){
    f2=fork();
  }
  // ---- Parent Process (Process 1) ----
  // - Send integer to Child 1
  if(f1>0 && f2>0){
  write(p1_to_p2[1],&num,10);
  close(p1_to_p2[1]);
  read(p3_to_p1[0],&num,10);
  close(p3_to_p1[0]);
  printf("p got: %d\n",num);
  }
  else if(f1==0){
    read(p1_to_p2[0],&num,10);
    printf("c1 got: %d\n",num);
    num=num*2;
    write(p2_to_p3[1],&num,10);
    close(p1_to_p2[0]);
    close(p2_to_p3[1]);
  }
  // - Read final result from Child 2
  else if(f2==0){
    read(p2_to_p3[0],&num,10);
    printf("c2 got: %d\n",num);
    num=num*2;
    write(p3_to_p1[1],&num,10);
    close(p2_to_p3[0]);
    close(p3_to_p1[1]);
  }
  // - Print the result


  return 0;
}

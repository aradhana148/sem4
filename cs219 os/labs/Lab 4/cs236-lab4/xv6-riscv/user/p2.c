#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[]) {

    // Write your code here
    
    int f=fork();
    if(f==0){
        printf("in child %d\n",getpid());
    }
    else if(f>0){
        wait(0);
        printf("%d,child: %d\n",getpid(),f);
    }

    exit(0);
}

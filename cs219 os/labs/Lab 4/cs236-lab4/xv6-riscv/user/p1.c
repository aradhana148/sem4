#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
    if (argc != 2)
        printf("Usage: p1 <filename>\n");
    else
        printf("%s\n", argv[1]);

    // Write your code here
    
    int f=fork();
    if(f==0){
        printf("in child %d\n",getpid());
        close(0);
        open(argv[1],0);
        char* arr[]={"cat",'\0'};
        exec("cat",arr);
    }
    else if(f>0){
        wait(0);
        printf("%d,child: %d\n",getpid(),f);
    }

    exit(0);
}

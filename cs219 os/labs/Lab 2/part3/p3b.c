#include <stdio.h>
#include <unistd.h>

int main() {
    // TODO: create new process using fork and complete if else blocks
    int f=fork();
    if (f<0) {
        printf("fork failed\n");
        return 1;
    } else if (f==0) {  // Child
        // TODO: print pid and ppid

        printf("%d, %d\n", getpid(), getppid());
    } else {  // Parent
        // TODO: print pid and child pid
        printf("%d, %d\n", getpid(), getppid());
        printf("%d\n",f);
    }

    return 0;
}
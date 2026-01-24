#include <stdio.h>
#include <unistd.h>

int main() {
    // TODO: fork and complete if-else (copy from p3b.c)
    int f=fork();
    if (f<0) {
        printf("fork failed\n");
        return 1;
    } else if (f==0) {  // Child
        // TODO: print (copy from p3b.c)
        printf("%d, %d\n", getpid(), getppid());

        // TODO: sleep for 5 secs using sleep syscall
        sleep(5);
    } else {  // Parent
        // TODO: wait for user input before waiting for child
        getchar();

        // TODO: wait for child to terminate using wait syscall
        wait();

        // TODO: print (copy from p3b.c)
        printf("%d, %d\n", getpid(), getppid());
    }

    return 0;
}

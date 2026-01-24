#include <stdio.h>
#include <unistd.h>

int main() {
    char ch;

    // TODO: complete the following syscalls
    // read from STDIN_FILENO 
    // write to STDOUT_FILENO
    
    while (read(0,&ch,1) > 0){
        printf("\nsde\n");
        if (write(1,&ch,1) < 0) {
            perror("Error writing to stdout\n");
            return 1;
        }
    }
    return 0;
}

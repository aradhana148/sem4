#include <stdio.h>
#include <unistd.h>

int main() {
    char ch;

    // TODO: complete the following syscalls
    // read from STDIN_FILENO 
    // write to STDOUT_FILENO
    
    while (read(0,&ch,1) > 0){
        // printf("\nsde\n");
        write(1,&ch,1); 
        // if (write(1,&ch,1) < 0) {
        //     perror("Error writing to stdout\n");
        //     return 1;
        // }
    }
    return 0;
}
//read(0,&ch,2) abcNULL only if char ch[>=2] cuz char ch is not safe, it stores starting from the address of ch
//read(0,&ch,3) abcdfNULL, abNULL  only if char ch[>=3]
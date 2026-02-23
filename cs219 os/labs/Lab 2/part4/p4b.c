#include <stdio.h>

int main() {
    char n[32];
    printf("give: \n");
    scanf("%31s",n);
    int f=fork();
    if(f==0){
        printf("in child\n");
        char* argv[] = {n, NULL};
        execvp(argv[0], argv);
    }
    else{
        printf("end in parent\n");
    }
    return 0;
}

#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    char *var = (char *)sbrk(8192);
    int f=fork();
    if(f>0){
        uint64 z=(uint64)var;
        uint64 z_pa = va_to_pa(z);
        wait(0);
        printf("parent VA  : 0x%lx\n", z);
        printf("parent PA  : 0x%lx\n", z_pa);
    }
    else if(f==0){
        uint64 z=(uint64)var;
        uint64 z_pa = va_to_pa(z);
        printf("child VA  : 0x%lx\n", z);
        printf("child PA  : 0x%lx\n", z_pa);
    }
    exit(0);
}
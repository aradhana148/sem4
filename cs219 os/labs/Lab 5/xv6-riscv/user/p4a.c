#include "kernel/types.h"
#include "user/user.h"

#define MAXVA (1L << (9 + 9 + 9 + 12 - 1))
#define PGSIZE 4096
int main(int argc, char *argv[])
{
    // Implement your logic here. Re-use va_to_pa() here.
    uint64 diff=MAXVA-PGSIZE;
    printf("Trampoline virtual address : %p\n",(void *)(diff));
    printf("Trampoline physical address (va_to_pa) : %p\n",(void *)(va_to_pa(diff)));
    exit(0);
}

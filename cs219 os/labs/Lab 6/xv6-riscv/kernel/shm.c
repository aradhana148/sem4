#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "shm.h"

uint64
sys_shm_init(void)
{
    if(shm.valid){
        return -1;
    }
    else{
        void* pa=kalloc();
        memset(pa, 0, PGSIZE);
        shm.kva=(uint64)pa;
        shm.refcnt=0;
        shm.valid=1;
    }
    return 0;
    
}

uint64
sys_shm_attach(void)
{
    struct proc *p=myproc();
    if(!shm.valid){
        return -1;
    }
    if(p->shm) return -1;
    p->shm=1;
    shm.refcnt++;
    int a=mappages(p->pagetable,SHMEM,PGSIZE,shm.kva,PTE_U | PTE_R |PTE_W);
    if(a==0) return SHMEM;
    return -1;
}

uint64
sys_shm_detach(void)
{
    struct proc *p=myproc();
    if(!shm.valid){
        return -1;
    }
    if(!p->shm) return -1;
    p->shm=0;
    shm.refcnt--;
    uvmunmap(p->pagetable, SHMEM, 1, 0);
    return 0;
}

uint64
sys_shm_destroy(void)
{
    if(!shm.valid){
        return -1;
    }
    if(shm.refcnt!=0) return -1;
    shm.valid=0;
    kfree((void*)shm.kva);
    return 0;
}

uint64
sys_shm_refcount(void)
{
    if(!shm.valid){
        return -1;
    }
    return shm.refcnt;
}

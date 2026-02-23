#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

extern pagetable_t kernel_pagetable;

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    if(addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_pte_valid(void)
{
  uint64 va;
  argaddr(0, &va);
  return ismapped(myproc()->pagetable,va);
}

uint64
sys_get_pteflags(void)
{
  uint64 va;
  argaddr(0, &va);

  pte_t *pte = walk(myproc()->pagetable, va, 0);
  if (pte == 0) {
    return 0;
  }
  if (*pte & PTE_V){
    printf("VA: 0x%lx -> R:%d  W:%d  X:%d  U:%d\n",va,(*pte & PTE_R)? 1:0 ,(*pte & PTE_W)? 1:0,(*pte & PTE_X)? 1:0,(*pte & PTE_U)? 1:0);
    return 0;
  }
  return 0;
}

uint64
sys_print_pgdirs(void)
{
  printf("Physical Address of Kernel root pagetable : %p\n",(void *)kernel_pagetable);
  printf("Physical Address of User root pagetable   : %p\n",(void *)(myproc()->pagetable));
  printf("Physical Address of Current satp register : %p\n",(void *)((r_satp() &((1L<<44)-1))<<12));
  return 0;
}

uint64
sys_va_to_pte(void)
{
  uint64 va;
  argaddr(0, &va);
  pagetable_t pagetable=myproc()->pagetable;
  for(int level = 2; level > 0; level--) {
    pte_t pte = pagetable[PX(level, va)];
    if(pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(pte);
    } else {
      return -1;
    }
  }
  return PTE2PA(pagetable[PX(0, va)]);
}

uint64
sys_va_to_pa(void)
{
  uint64 va;
  argaddr(0, &va);

  pagetable_t pagetable=myproc()->pagetable;
  for(int level = 2; level > 0; level--) {
    pte_t pte = pagetable[PX(level, va)];
    if(pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(pte);
      
    } else {
      return -1;
    }
  }
  return PTE2PA(pagetable[PX(0, va)])+(va&((1L<<12)-1));
}

uint64
sys_getvasize(void)
{
  return myproc()->sz;
}

uint64
sys_getpasize(void)
{
  int n=myproc()->sz;
  int count=0;
  for(uint64 i=0;i<n;i+=PGSIZE){
    
    count+=ismapped(myproc()->pagetable,i);
  }
  return count*PGSIZE;
}

uint64
sys_getlazyfaults(void)
{
  return (myproc()->pf_count);
}

uint64
sys_kva_to_pa(void)
{
  uint64 va;
  argaddr(0, &va);
  pagetable_t pagetable=kernel_pagetable;
  for(int level = 2; level > 0; level--) {
    pte_t pte = pagetable[PX(level, va)];
    if(pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(pte);
      
    } else {
      return -1;
    }
  }
  if(!(pagetable[PX(0, va)] & PTE_V)){
    return -1;
  }
  return PTE2PA(pagetable[PX(0, va)])+(va&((1L<<12)-1));
}


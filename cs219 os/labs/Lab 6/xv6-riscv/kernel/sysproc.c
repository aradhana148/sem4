#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

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
sys_tfork()
{
  int n;
  argint(0,&n);
  uint64 pids;
  argaddr(1,&pids);

  for(int i=0;i<n;i++){
    int f= kfork();
    if(f==0){
      return 0;
    }
    if(f>0){
      if(copyout(myproc()->pagetable,pids+i*sizeof(int),(char*)&f,sizeof(int))<0){
        return -1;
      }
    }
  }
  return n;
}

uint64
sys_getppid()
{
  return myproc()->parent->pid;
}

uint64
sys_tfork2()
{
  int n;
  argint(0,&n);
  uint64 pids;
  argaddr(1,&pids);
  int ppid=myproc()->pid;
  for(int i=0;i<n;i++){
    int f= pfork(ppid);
    if(f==0){
      return 0;
    }
    if(f>0){
      if(copyout(myproc()->pagetable,pids+i*sizeof(int),(char*)&f,sizeof(int))<0){
        return -1;
      }
    }
    ppid=f;
  }
  return n;
}

// uint64
// sys_kmap()
// {
//   struct proc *p=myproc();
//   void* pa=kalloc();
//   memset(pa, 0, PGSIZE);
//   p->kva_whis=(uint64)pa;
//   int a=mappages(p->pagetable,KERWHIS,PGSIZE,p->kva_whis,PTE_U | PTE_R |PTE_W);
//   if(a==0) return KERWHIS;
//   return -1;
// }
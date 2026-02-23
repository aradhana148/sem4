#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

extern struct proc proc[NPROC];

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
  int f=kfork();
  myproc()->child_count++;
  printf("fork: created child with pid: %d\n",f);
  return f;
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  if(myproc()->child_count>0){
    myproc()->child_count--;
  }
  else{
    myproc()->child_count=0;
  }
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
sys_knockknock(void)
{
  int p=myproc()->pid;
  printf("I am %d, Who's there?\n",p);
  return 0;
}

uint64
sys_getProcessStates(void)
{
  static char *states[] = {
    [UNUSED]    "unused",
    [USED]      "used",
    [SLEEPING]  "sleep ",
    [RUNNABLE]  "runble",
    [RUNNING]   "run   ",
    [ZOMBIE]    "zombie"
  };
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state != UNUSED) {
      printf("Process %d was found in %s state\n",p->pid,states[p->state]);
    }
    release(&p->lock);
  }
  
  return 0;
}

uint64
sys_areYouThere(void)
{
  int n;
  argint(0, &n);
  static char *states[] = {
    [UNUSED]    "unused",
    [USED]      "used",
    [SLEEPING]  "sleep ",
    [RUNNABLE]  "runble",
    [RUNNING]   "run   ",
    [ZOMBIE]    "zombie"
  };
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->pid == n) {
      printf("I am %d in %s state\n",p->pid,states[p->state]);
      release(&p->lock);
      return 0;
    } 
    release(&p->lock);
  }
  printf("%d has gone missing\n",n);
  return 0;
}

uint64
sys_getChildCount(void)
{
  return myproc()->child_count;
}

uint64
sys_xtrace_start(void)
{
  struct proc *p= myproc();
  if(p->xtrace && p->xtrace->active){
    return -1;
  }
  if(p->xtrace){
    kfree((void*)p->xtrace);
    p->xtrace = 0;
  }
  p->xtrace=(struct xtrace*)kalloc();
  p->xtrace->active=1;
  p->xtrace->n=0;
  return 0;
}

uint64
sys_xtrace_end(void)
{
  struct proc *p= myproc();
  if(p->xtrace==0 || p->xtrace->active==0){
    return -1;
  }
  p->xtrace->active = 0;
  int num=p->xtrace->n;
  printf("Syscall Trace for PID %d :\n",p->pid);
  for(int i=0;i<num;i++){
    printf("Syscall %d returned %d\n",p->xtrace->list[i].sysno,p->xtrace->list[i].sysret);
  }
  kfree((void*)p->xtrace);
  p->xtrace = 0;
  return num;
}

kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	9c010113          	addi	sp,sp,-1600 # 800079c0 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	ra,80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	0x14d,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd737>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	d6278793          	addi	a5,a5,-670 # 80000de2 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	ra,8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7159                	addi	sp,sp,-112
    800000d2:	f486                	sd	ra,104(sp)
    800000d4:	f0a2                	sd	s0,96(sp)
    800000d6:	eca6                	sd	s1,88(sp)
    800000d8:	e8ca                	sd	s2,80(sp)
    800000da:	e4ce                	sd	s3,72(sp)
    800000dc:	e0d2                	sd	s4,64(sp)
    800000de:	fc56                	sd	s5,56(sp)
    800000e0:	f85a                	sd	s6,48(sp)
    800000e2:	f45e                	sd	s7,40(sp)
    800000e4:	f062                	sd	s8,32(sp)
    800000e6:	1880                	addi	s0,sp,112
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000e8:	04c05463          	blez	a2,80000130 <consolewrite+0x60>
    800000ec:	8a2a                	mv	s4,a0
    800000ee:	8aae                	mv	s5,a1
    800000f0:	89b2                	mv	s3,a2
  int i = 0;
    800000f2:	4901                	li	s2,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f4:	4bfd                	li	s7,31
    int nn = sizeof(buf);
    800000f6:	02000c13          	li	s8,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fa:	5b7d                	li	s6,-1
    800000fc:	a025                	j	80000124 <consolewrite+0x54>
    800000fe:	86a6                	mv	a3,s1
    80000100:	01590633          	add	a2,s2,s5
    80000104:	85d2                	mv	a1,s4
    80000106:	f9040513          	addi	a0,s0,-112
    8000010a:	110020ef          	jal	ra,8000221a <either_copyin>
    8000010e:	03650263          	beq	a0,s6,80000132 <consolewrite+0x62>
      break;
    uartwrite(buf, nn);
    80000112:	85a6                	mv	a1,s1
    80000114:	f9040513          	addi	a0,s0,-112
    80000118:	71e000ef          	jal	ra,80000836 <uartwrite>
    i += nn;
    8000011c:	0124893b          	addw	s2,s1,s2
  while(i < n){
    80000120:	01395963          	bge	s2,s3,80000132 <consolewrite+0x62>
    if(nn > n - i)
    80000124:	412984bb          	subw	s1,s3,s2
    80000128:	fc9bdbe3          	bge	s7,s1,800000fe <consolewrite+0x2e>
    int nn = sizeof(buf);
    8000012c:	84e2                	mv	s1,s8
    8000012e:	bfc1                	j	800000fe <consolewrite+0x2e>
  int i = 0;
    80000130:	4901                	li	s2,0
  }

  return i;
}
    80000132:	854a                	mv	a0,s2
    80000134:	70a6                	ld	ra,104(sp)
    80000136:	7406                	ld	s0,96(sp)
    80000138:	64e6                	ld	s1,88(sp)
    8000013a:	6946                	ld	s2,80(sp)
    8000013c:	69a6                	ld	s3,72(sp)
    8000013e:	6a06                	ld	s4,64(sp)
    80000140:	7ae2                	ld	s5,56(sp)
    80000142:	7b42                	ld	s6,48(sp)
    80000144:	7ba2                	ld	s7,40(sp)
    80000146:	7c02                	ld	s8,32(sp)
    80000148:	6165                	addi	sp,sp,112
    8000014a:	8082                	ret

000000008000014c <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014c:	7159                	addi	sp,sp,-112
    8000014e:	f486                	sd	ra,104(sp)
    80000150:	f0a2                	sd	s0,96(sp)
    80000152:	eca6                	sd	s1,88(sp)
    80000154:	e8ca                	sd	s2,80(sp)
    80000156:	e4ce                	sd	s3,72(sp)
    80000158:	e0d2                	sd	s4,64(sp)
    8000015a:	fc56                	sd	s5,56(sp)
    8000015c:	f85a                	sd	s6,48(sp)
    8000015e:	f45e                	sd	s7,40(sp)
    80000160:	f062                	sd	s8,32(sp)
    80000162:	ec66                	sd	s9,24(sp)
    80000164:	e86a                	sd	s10,16(sp)
    80000166:	1880                	addi	s0,sp,112
    80000168:	8aaa                	mv	s5,a0
    8000016a:	8a2e                	mv	s4,a1
    8000016c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000016e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000172:	00010517          	auipc	a0,0x10
    80000176:	84e50513          	addi	a0,a0,-1970 # 8000f9c0 <cons>
    8000017a:	1f3000ef          	jal	ra,80000b6c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	84248493          	addi	s1,s1,-1982 # 8000f9c0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00010917          	auipc	s2,0x10
    8000018a:	8d290913          	addi	s2,s2,-1838 # 8000fa58 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000018e:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000190:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000192:	4ca9                	li	s9,10
  while(n > 0){
    80000194:	07305363          	blez	s3,800001fa <consoleread+0xae>
    while(cons.r == cons.w){
    80000198:	0984a783          	lw	a5,152(s1)
    8000019c:	09c4a703          	lw	a4,156(s1)
    800001a0:	02f71163          	bne	a4,a5,800001c2 <consoleread+0x76>
      if(killed(myproc())){
    800001a4:	668010ef          	jal	ra,8000180c <myproc>
    800001a8:	705010ef          	jal	ra,800020ac <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	479010ef          	jal	ra,80001e2a <sleep>
    while(cons.r == cons.w){
    800001b6:	0984a783          	lw	a5,152(s1)
    800001ba:	09c4a703          	lw	a4,156(s1)
    800001be:	fef703e3          	beq	a4,a5,800001a4 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001c2:	0017871b          	addiw	a4,a5,1
    800001c6:	08e4ac23          	sw	a4,152(s1)
    800001ca:	07f7f713          	andi	a4,a5,127
    800001ce:	9726                	add	a4,a4,s1
    800001d0:	01874703          	lbu	a4,24(a4)
    800001d4:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001d8:	057d0f63          	beq	s10,s7,80000236 <consoleread+0xea>
    cbuf = c;
    800001dc:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001e0:	4685                	li	a3,1
    800001e2:	f9f40613          	addi	a2,s0,-97
    800001e6:	85d2                	mv	a1,s4
    800001e8:	8556                	mv	a0,s5
    800001ea:	7e7010ef          	jal	ra,800021d0 <either_copyout>
    800001ee:	01850663          	beq	a0,s8,800001fa <consoleread+0xae>
    dst++;
    800001f2:	0a05                	addi	s4,s4,1
    --n;
    800001f4:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800001f6:	f99d1fe3          	bne	s10,s9,80000194 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001fa:	0000f517          	auipc	a0,0xf
    800001fe:	7c650513          	addi	a0,a0,1990 # 8000f9c0 <cons>
    80000202:	203000ef          	jal	ra,80000c04 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	0000f517          	auipc	a0,0xf
    80000210:	7b450513          	addi	a0,a0,1972 # 8000f9c0 <cons>
    80000214:	1f1000ef          	jal	ra,80000c04 <release>
        return -1;
    80000218:	557d                	li	a0,-1
}
    8000021a:	70a6                	ld	ra,104(sp)
    8000021c:	7406                	ld	s0,96(sp)
    8000021e:	64e6                	ld	s1,88(sp)
    80000220:	6946                	ld	s2,80(sp)
    80000222:	69a6                	ld	s3,72(sp)
    80000224:	6a06                	ld	s4,64(sp)
    80000226:	7ae2                	ld	s5,56(sp)
    80000228:	7b42                	ld	s6,48(sp)
    8000022a:	7ba2                	ld	s7,40(sp)
    8000022c:	7c02                	ld	s8,32(sp)
    8000022e:	6ce2                	ld	s9,24(sp)
    80000230:	6d42                	ld	s10,16(sp)
    80000232:	6165                	addi	sp,sp,112
    80000234:	8082                	ret
      if(n < target){
    80000236:	0009871b          	sext.w	a4,s3
    8000023a:	fd6770e3          	bgeu	a4,s6,800001fa <consoleread+0xae>
        cons.r--;
    8000023e:	00010717          	auipc	a4,0x10
    80000242:	80f72d23          	sw	a5,-2022(a4) # 8000fa58 <cons+0x98>
    80000246:	bf55                	j	800001fa <consoleread+0xae>

0000000080000248 <consputc>:
{
    80000248:	1141                	addi	sp,sp,-16
    8000024a:	e406                	sd	ra,8(sp)
    8000024c:	e022                	sd	s0,0(sp)
    8000024e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000250:	10000793          	li	a5,256
    80000254:	00f50863          	beq	a0,a5,80000264 <consputc+0x1c>
    uartputc_sync(c);
    80000258:	67c000ef          	jal	ra,800008d4 <uartputc_sync>
}
    8000025c:	60a2                	ld	ra,8(sp)
    8000025e:	6402                	ld	s0,0(sp)
    80000260:	0141                	addi	sp,sp,16
    80000262:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000264:	4521                	li	a0,8
    80000266:	66e000ef          	jal	ra,800008d4 <uartputc_sync>
    8000026a:	02000513          	li	a0,32
    8000026e:	666000ef          	jal	ra,800008d4 <uartputc_sync>
    80000272:	4521                	li	a0,8
    80000274:	660000ef          	jal	ra,800008d4 <uartputc_sync>
    80000278:	b7d5                	j	8000025c <consputc+0x14>

000000008000027a <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    8000027a:	1101                	addi	sp,sp,-32
    8000027c:	ec06                	sd	ra,24(sp)
    8000027e:	e822                	sd	s0,16(sp)
    80000280:	e426                	sd	s1,8(sp)
    80000282:	e04a                	sd	s2,0(sp)
    80000284:	1000                	addi	s0,sp,32
    80000286:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80000288:	0000f517          	auipc	a0,0xf
    8000028c:	73850513          	addi	a0,a0,1848 # 8000f9c0 <cons>
    80000290:	0dd000ef          	jal	ra,80000b6c <acquire>

  switch(c){
    80000294:	47d5                	li	a5,21
    80000296:	0af48063          	beq	s1,a5,80000336 <consoleintr+0xbc>
    8000029a:	0297c663          	blt	a5,s1,800002c6 <consoleintr+0x4c>
    8000029e:	47a1                	li	a5,8
    800002a0:	0cf48f63          	beq	s1,a5,8000037e <consoleintr+0x104>
    800002a4:	47c1                	li	a5,16
    800002a6:	10f49063          	bne	s1,a5,800003a6 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    800002aa:	7bb010ef          	jal	ra,80002264 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	0000f517          	auipc	a0,0xf
    800002b2:	71250513          	addi	a0,a0,1810 # 8000f9c0 <cons>
    800002b6:	14f000ef          	jal	ra,80000c04 <release>
}
    800002ba:	60e2                	ld	ra,24(sp)
    800002bc:	6442                	ld	s0,16(sp)
    800002be:	64a2                	ld	s1,8(sp)
    800002c0:	6902                	ld	s2,0(sp)
    800002c2:	6105                	addi	sp,sp,32
    800002c4:	8082                	ret
  switch(c){
    800002c6:	07f00793          	li	a5,127
    800002ca:	0af48a63          	beq	s1,a5,8000037e <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002ce:	0000f717          	auipc	a4,0xf
    800002d2:	6f270713          	addi	a4,a4,1778 # 8000f9c0 <cons>
    800002d6:	0a072783          	lw	a5,160(a4)
    800002da:	09872703          	lw	a4,152(a4)
    800002de:	9f99                	subw	a5,a5,a4
    800002e0:	07f00713          	li	a4,127
    800002e4:	fcf765e3          	bltu	a4,a5,800002ae <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800002e8:	47b5                	li	a5,13
    800002ea:	0cf48163          	beq	s1,a5,800003ac <consoleintr+0x132>
      consputc(c);
    800002ee:	8526                	mv	a0,s1
    800002f0:	f59ff0ef          	jal	ra,80000248 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002f4:	0000f797          	auipc	a5,0xf
    800002f8:	6cc78793          	addi	a5,a5,1740 # 8000f9c0 <cons>
    800002fc:	0a07a683          	lw	a3,160(a5)
    80000300:	0016871b          	addiw	a4,a3,1
    80000304:	0007061b          	sext.w	a2,a4
    80000308:	0ae7a023          	sw	a4,160(a5)
    8000030c:	07f6f693          	andi	a3,a3,127
    80000310:	97b6                	add	a5,a5,a3
    80000312:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000316:	47a9                	li	a5,10
    80000318:	0af48f63          	beq	s1,a5,800003d6 <consoleintr+0x15c>
    8000031c:	4791                	li	a5,4
    8000031e:	0af48c63          	beq	s1,a5,800003d6 <consoleintr+0x15c>
    80000322:	0000f797          	auipc	a5,0xf
    80000326:	7367a783          	lw	a5,1846(a5) # 8000fa58 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	0000f717          	auipc	a4,0xf
    8000033a:	68a70713          	addi	a4,a4,1674 # 8000f9c0 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	0000f497          	auipc	s1,0xf
    8000034a:	67a48493          	addi	s1,s1,1658 # 8000f9c0 <cons>
    while(cons.e != cons.w &&
    8000034e:	4929                	li	s2,10
    80000350:	f4f70fe3          	beq	a4,a5,800002ae <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000354:	37fd                	addiw	a5,a5,-1
    80000356:	07f7f713          	andi	a4,a5,127
    8000035a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000035c:	01874703          	lbu	a4,24(a4)
    80000360:	f52707e3          	beq	a4,s2,800002ae <consoleintr+0x34>
      cons.e--;
    80000364:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000368:	10000513          	li	a0,256
    8000036c:	eddff0ef          	jal	ra,80000248 <consputc>
    while(cons.e != cons.w &&
    80000370:	0a04a783          	lw	a5,160(s1)
    80000374:	09c4a703          	lw	a4,156(s1)
    80000378:	fcf71ee3          	bne	a4,a5,80000354 <consoleintr+0xda>
    8000037c:	bf0d                	j	800002ae <consoleintr+0x34>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	64270713          	addi	a4,a4,1602 # 8000f9c0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	6cf72623          	sw	a5,1740(a4) # 8000fa60 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea9ff0ef          	jal	ra,80000248 <consputc>
    800003a4:	b729                	j	800002ae <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	f00484e3          	beqz	s1,800002ae <consoleintr+0x34>
    800003aa:	b715                	j	800002ce <consoleintr+0x54>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e9bff0ef          	jal	ra,80000248 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	60e78793          	addi	a5,a5,1550 # 8000f9c0 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	68c7a323          	sw	a2,1670(a5) # 8000fa5c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	67a50513          	addi	a0,a0,1658 # 8000fa58 <cons+0x98>
    800003e6:	291010ef          	jal	ra,80001e76 <wakeup>
    800003ea:	b5d1                	j	800002ae <consoleintr+0x34>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c1c58593          	addi	a1,a1,-996 # 80007010 <etext+0x10>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	5c450513          	addi	a0,a0,1476 # 8000f9c0 <cons>
    80000404:	6e8000ef          	jal	ra,80000aec <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00020797          	auipc	a5,0x20
    80000410:	b2478793          	addi	a5,a5,-1244 # 8001ff30 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d3870713          	addi	a4,a4,-712 # 8000014c <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7139                	addi	sp,sp,-64
    80000432:	fc06                	sd	ra,56(sp)
    80000434:	f822                	sd	s0,48(sp)
    80000436:	f426                	sd	s1,40(sp)
    80000438:	f04a                	sd	s2,32(sp)
    8000043a:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000043c:	c219                	beqz	a2,80000442 <printint+0x12>
    8000043e:	06054f63          	bltz	a0,800004bc <printint+0x8c>
    x = -xx;
  else
    x = xx;
    80000442:	4881                	li	a7,0
    80000444:	fc840693          	addi	a3,s0,-56

  i = 0;
    80000448:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000044a:	00007617          	auipc	a2,0x7
    8000044e:	bee60613          	addi	a2,a2,-1042 # 80007038 <digits>
    80000452:	883e                	mv	a6,a5
    80000454:	2785                	addiw	a5,a5,1
    80000456:	02b57733          	remu	a4,a0,a1
    8000045a:	9732                	add	a4,a4,a2
    8000045c:	00074703          	lbu	a4,0(a4)
    80000460:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000464:	872a                	mv	a4,a0
    80000466:	02b55533          	divu	a0,a0,a1
    8000046a:	0685                	addi	a3,a3,1
    8000046c:	feb773e3          	bgeu	a4,a1,80000452 <printint+0x22>

  if(sign)
    80000470:	00088b63          	beqz	a7,80000486 <printint+0x56>
    buf[i++] = '-';
    80000474:	fe040713          	addi	a4,s0,-32
    80000478:	97ba                	add	a5,a5,a4
    8000047a:	02d00713          	li	a4,45
    8000047e:	fee78423          	sb	a4,-24(a5)
    80000482:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000486:	02f05563          	blez	a5,800004b0 <printint+0x80>
    8000048a:	fc840713          	addi	a4,s0,-56
    8000048e:	00f704b3          	add	s1,a4,a5
    80000492:	fff70913          	addi	s2,a4,-1
    80000496:	993e                	add	s2,s2,a5
    80000498:	37fd                	addiw	a5,a5,-1
    8000049a:	1782                	slli	a5,a5,0x20
    8000049c:	9381                	srli	a5,a5,0x20
    8000049e:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a2:	fff4c503          	lbu	a0,-1(s1)
    800004a6:	da3ff0ef          	jal	ra,80000248 <consputc>
  while(--i >= 0)
    800004aa:	14fd                	addi	s1,s1,-1
    800004ac:	ff249be3          	bne	s1,s2,800004a2 <printint+0x72>
}
    800004b0:	70e2                	ld	ra,56(sp)
    800004b2:	7442                	ld	s0,48(sp)
    800004b4:	74a2                	ld	s1,40(sp)
    800004b6:	7902                	ld	s2,32(sp)
    800004b8:	6121                	addi	sp,sp,64
    800004ba:	8082                	ret
    x = -xx;
    800004bc:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004c0:	4885                	li	a7,1
    x = -xx;
    800004c2:	b749                	j	80000444 <printint+0x14>

00000000800004c4 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c4:	7131                	addi	sp,sp,-192
    800004c6:	fc86                	sd	ra,120(sp)
    800004c8:	f8a2                	sd	s0,112(sp)
    800004ca:	f4a6                	sd	s1,104(sp)
    800004cc:	f0ca                	sd	s2,96(sp)
    800004ce:	ecce                	sd	s3,88(sp)
    800004d0:	e8d2                	sd	s4,80(sp)
    800004d2:	e4d6                	sd	s5,72(sp)
    800004d4:	e0da                	sd	s6,64(sp)
    800004d6:	fc5e                	sd	s7,56(sp)
    800004d8:	f862                	sd	s8,48(sp)
    800004da:	f466                	sd	s9,40(sp)
    800004dc:	f06a                	sd	s10,32(sp)
    800004de:	ec6e                	sd	s11,24(sp)
    800004e0:	0100                	addi	s0,sp,128
    800004e2:	8a2a                	mv	s4,a0
    800004e4:	e40c                	sd	a1,8(s0)
    800004e6:	e810                	sd	a2,16(s0)
    800004e8:	ec14                	sd	a3,24(s0)
    800004ea:	f018                	sd	a4,32(s0)
    800004ec:	f41c                	sd	a5,40(s0)
    800004ee:	03043823          	sd	a6,48(s0)
    800004f2:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    800004f6:	00007797          	auipc	a5,0x7
    800004fa:	49e7a783          	lw	a5,1182(a5) # 80007994 <panicking>
    800004fe:	cb9d                	beqz	a5,80000534 <printf+0x70>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000500:	00840793          	addi	a5,s0,8
    80000504:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000508:	000a4503          	lbu	a0,0(s4)
    8000050c:	24050363          	beqz	a0,80000752 <printf+0x28e>
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000052a:	00007b97          	auipc	s7,0x7
    8000052e:	b0eb8b93          	addi	s7,s7,-1266 # 80007038 <digits>
    80000532:	a01d                	j	80000558 <printf+0x94>
    acquire(&pr.lock);
    80000534:	0000f517          	auipc	a0,0xf
    80000538:	53450513          	addi	a0,a0,1332 # 8000fa68 <pr>
    8000053c:	630000ef          	jal	ra,80000b6c <acquire>
    80000540:	b7c1                	j	80000500 <printf+0x3c>
      consputc(cx);
    80000542:	d07ff0ef          	jal	ra,80000248 <consputc>
      continue;
    80000546:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000548:	0014899b          	addiw	s3,s1,1
    8000054c:	013a07b3          	add	a5,s4,s3
    80000550:	0007c503          	lbu	a0,0(a5)
    80000554:	1e050f63          	beqz	a0,80000752 <printf+0x28e>
    if(cx != '%'){
    80000558:	ff5515e3          	bne	a0,s5,80000542 <printf+0x7e>
    i++;
    8000055c:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000560:	009a07b3          	add	a5,s4,s1
    80000564:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000568:	1e090563          	beqz	s2,80000752 <printf+0x28e>
    8000056c:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000570:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000572:	c789                	beqz	a5,8000057c <printf+0xb8>
    80000574:	009a0733          	add	a4,s4,s1
    80000578:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    8000057c:	03690863          	beq	s2,s6,800005ac <printf+0xe8>
    } else if(c0 == 'l' && c1 == 'd'){
    80000580:	05890263          	beq	s2,s8,800005c4 <printf+0x100>
    } else if(c0 == 'u'){
    80000584:	0d990163          	beq	s2,s9,80000646 <printf+0x182>
    } else if(c0 == 'x'){
    80000588:	11a90863          	beq	s2,s10,80000698 <printf+0x1d4>
    } else if(c0 == 'p'){
    8000058c:	15b90163          	beq	s2,s11,800006ce <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    80000590:	06300793          	li	a5,99
    80000594:	16f90963          	beq	s2,a5,80000706 <printf+0x242>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    80000598:	07300793          	li	a5,115
    8000059c:	16f90f63          	beq	s2,a5,8000071a <printf+0x256>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005a0:	03591c63          	bne	s2,s5,800005d8 <printf+0x114>
      consputc('%');
    800005a4:	8556                	mv	a0,s5
    800005a6:	ca3ff0ef          	jal	ra,80000248 <consputc>
    800005aa:	bf79                	j	80000548 <printf+0x84>
      printint(va_arg(ap, int), 10, 1);
    800005ac:	f8843783          	ld	a5,-120(s0)
    800005b0:	00878713          	addi	a4,a5,8
    800005b4:	f8e43423          	sd	a4,-120(s0)
    800005b8:	4605                	li	a2,1
    800005ba:	45a9                	li	a1,10
    800005bc:	4388                	lw	a0,0(a5)
    800005be:	e73ff0ef          	jal	ra,80000430 <printint>
    800005c2:	b759                	j	80000548 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c4:	03678163          	beq	a5,s6,800005e6 <printf+0x122>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005c8:	03878d63          	beq	a5,s8,80000602 <printf+0x13e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005cc:	09978a63          	beq	a5,s9,80000660 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005d0:	03878b63          	beq	a5,s8,80000606 <printf+0x142>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	0da78f63          	beq	a5,s10,800006b2 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005d8:	8556                	mv	a0,s5
    800005da:	c6fff0ef          	jal	ra,80000248 <consputc>
      consputc(c0);
    800005de:	854a                	mv	a0,s2
    800005e0:	c69ff0ef          	jal	ra,80000248 <consputc>
    800005e4:	b795                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    800005e6:	f8843783          	ld	a5,-120(s0)
    800005ea:	00878713          	addi	a4,a5,8
    800005ee:	f8e43423          	sd	a4,-120(s0)
    800005f2:	4605                	li	a2,1
    800005f4:	45a9                	li	a1,10
    800005f6:	6388                	ld	a0,0(a5)
    800005f8:	e39ff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800005fc:	0029849b          	addiw	s1,s3,2
    80000600:	b7a1                	j	80000548 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000602:	03668463          	beq	a3,s6,8000062a <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000606:	07968b63          	beq	a3,s9,8000067c <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000060a:	fda697e3          	bne	a3,s10,800005d8 <printf+0x114>
      printint(va_arg(ap, uint64), 16, 0);
    8000060e:	f8843783          	ld	a5,-120(s0)
    80000612:	00878713          	addi	a4,a5,8
    80000616:	f8e43423          	sd	a4,-120(s0)
    8000061a:	4601                	li	a2,0
    8000061c:	45c1                	li	a1,16
    8000061e:	6388                	ld	a0,0(a5)
    80000620:	e11ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000624:	0039849b          	addiw	s1,s3,3
    80000628:	b705                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    8000062a:	f8843783          	ld	a5,-120(s0)
    8000062e:	00878713          	addi	a4,a5,8
    80000632:	f8e43423          	sd	a4,-120(s0)
    80000636:	4605                	li	a2,1
    80000638:	45a9                	li	a1,10
    8000063a:	6388                	ld	a0,0(a5)
    8000063c:	df5ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000640:	0039849b          	addiw	s1,s3,3
    80000644:	b711                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint32), 10, 0);
    80000646:	f8843783          	ld	a5,-120(s0)
    8000064a:	00878713          	addi	a4,a5,8
    8000064e:	f8e43423          	sd	a4,-120(s0)
    80000652:	4601                	li	a2,0
    80000654:	45a9                	li	a1,10
    80000656:	0007e503          	lwu	a0,0(a5)
    8000065a:	dd7ff0ef          	jal	ra,80000430 <printint>
    8000065e:	b5ed                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	dbfff0ef          	jal	ra,80000430 <printint>
      i += 1;
    80000676:	0029849b          	addiw	s1,s3,2
    8000067a:	b5f9                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	6388                	ld	a0,0(a5)
    8000068e:	da3ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000692:	0039849b          	addiw	s1,s3,3
    80000696:	bd4d                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint32), 16, 0);
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	4601                	li	a2,0
    800006a6:	45c1                	li	a1,16
    800006a8:	0007e503          	lwu	a0,0(a5)
    800006ac:	d85ff0ef          	jal	ra,80000430 <printint>
    800006b0:	bd61                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 16, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45c1                	li	a1,16
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	d6dff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800006c8:	0029849b          	addiw	s1,s3,2
    800006cc:	bdb5                	j	80000548 <printf+0x84>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	b67ff0ef          	jal	ra,80000248 <consputc>
  consputc('x');
    800006e6:	856a                	mv	a0,s10
    800006e8:	b61ff0ef          	jal	ra,80000248 <consputc>
    800006ec:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ee:	03c9d793          	srli	a5,s3,0x3c
    800006f2:	97de                	add	a5,a5,s7
    800006f4:	0007c503          	lbu	a0,0(a5)
    800006f8:	b51ff0ef          	jal	ra,80000248 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006fc:	0992                	slli	s3,s3,0x4
    800006fe:	397d                	addiw	s2,s2,-1
    80000700:	fe0917e3          	bnez	s2,800006ee <printf+0x22a>
    80000704:	b591                	j	80000548 <printf+0x84>
      consputc(va_arg(ap, uint));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	4388                	lw	a0,0(a5)
    80000714:	b35ff0ef          	jal	ra,80000248 <consputc>
    80000718:	bd05                	j	80000548 <printf+0x84>
      if((s = va_arg(ap, char*)) == 0)
    8000071a:	f8843783          	ld	a5,-120(s0)
    8000071e:	00878713          	addi	a4,a5,8
    80000722:	f8e43423          	sd	a4,-120(s0)
    80000726:	0007b903          	ld	s2,0(a5)
    8000072a:	00090d63          	beqz	s2,80000744 <printf+0x280>
      for(; *s; s++)
    8000072e:	00094503          	lbu	a0,0(s2)
    80000732:	e0050be3          	beqz	a0,80000548 <printf+0x84>
        consputc(*s);
    80000736:	b13ff0ef          	jal	ra,80000248 <consputc>
      for(; *s; s++)
    8000073a:	0905                	addi	s2,s2,1
    8000073c:	00094503          	lbu	a0,0(s2)
    80000740:	f97d                	bnez	a0,80000736 <printf+0x272>
    80000742:	b519                	j	80000548 <printf+0x84>
        s = "(null)";
    80000744:	00007917          	auipc	s2,0x7
    80000748:	8d490913          	addi	s2,s2,-1836 # 80007018 <etext+0x18>
      for(; *s; s++)
    8000074c:	02800513          	li	a0,40
    80000750:	b7dd                	j	80000736 <printf+0x272>
    }

  }
  va_end(ap);

  if(panicking == 0)
    80000752:	00007797          	auipc	a5,0x7
    80000756:	2427a783          	lw	a5,578(a5) # 80007994 <panicking>
    8000075a:	c38d                	beqz	a5,8000077c <printf+0x2b8>
    release(&pr.lock);

  return 0;
}
    8000075c:	4501                	li	a0,0
    8000075e:	70e6                	ld	ra,120(sp)
    80000760:	7446                	ld	s0,112(sp)
    80000762:	74a6                	ld	s1,104(sp)
    80000764:	7906                	ld	s2,96(sp)
    80000766:	69e6                	ld	s3,88(sp)
    80000768:	6a46                	ld	s4,80(sp)
    8000076a:	6aa6                	ld	s5,72(sp)
    8000076c:	6b06                	ld	s6,64(sp)
    8000076e:	7be2                	ld	s7,56(sp)
    80000770:	7c42                	ld	s8,48(sp)
    80000772:	7ca2                	ld	s9,40(sp)
    80000774:	7d02                	ld	s10,32(sp)
    80000776:	6de2                	ld	s11,24(sp)
    80000778:	6129                	addi	sp,sp,192
    8000077a:	8082                	ret
    release(&pr.lock);
    8000077c:	0000f517          	auipc	a0,0xf
    80000780:	2ec50513          	addi	a0,a0,748 # 8000fa68 <pr>
    80000784:	480000ef          	jal	ra,80000c04 <release>
  return 0;
    80000788:	bfd1                	j	8000075c <printf+0x298>

000000008000078a <panic>:

void
panic(char *s)
{
    8000078a:	1101                	addi	sp,sp,-32
    8000078c:	ec06                	sd	ra,24(sp)
    8000078e:	e822                	sd	s0,16(sp)
    80000790:	e426                	sd	s1,8(sp)
    80000792:	e04a                	sd	s2,0(sp)
    80000794:	1000                	addi	s0,sp,32
    80000796:	84aa                	mv	s1,a0
  panicking = 1;
    80000798:	4905                	li	s2,1
    8000079a:	00007797          	auipc	a5,0x7
    8000079e:	1f27ad23          	sw	s2,506(a5) # 80007994 <panicking>
  printf("panic: ");
    800007a2:	00007517          	auipc	a0,0x7
    800007a6:	87e50513          	addi	a0,a0,-1922 # 80007020 <etext+0x20>
    800007aa:	d1bff0ef          	jal	ra,800004c4 <printf>
  printf("%s\n", s);
    800007ae:	85a6                	mv	a1,s1
    800007b0:	00007517          	auipc	a0,0x7
    800007b4:	87850513          	addi	a0,a0,-1928 # 80007028 <etext+0x28>
    800007b8:	d0dff0ef          	jal	ra,800004c4 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007bc:	00007797          	auipc	a5,0x7
    800007c0:	1d27aa23          	sw	s2,468(a5) # 80007990 <panicked>
  for(;;)
    800007c4:	a001                	j	800007c4 <panic+0x3a>

00000000800007c6 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007c6:	1141                	addi	sp,sp,-16
    800007c8:	e406                	sd	ra,8(sp)
    800007ca:	e022                	sd	s0,0(sp)
    800007cc:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007ce:	00007597          	auipc	a1,0x7
    800007d2:	86258593          	addi	a1,a1,-1950 # 80007030 <etext+0x30>
    800007d6:	0000f517          	auipc	a0,0xf
    800007da:	29250513          	addi	a0,a0,658 # 8000fa68 <pr>
    800007de:	30e000ef          	jal	ra,80000aec <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    800007ea:	1141                	addi	sp,sp,-16
    800007ec:	e406                	sd	ra,8(sp)
    800007ee:	e022                	sd	s0,0(sp)
    800007f0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007f2:	100007b7          	lui	a5,0x10000
    800007f6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007fa:	f8000713          	li	a4,-128
    800007fe:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000802:	470d                	li	a4,3
    80000804:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000808:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000810:	469d                	li	a3,7
    80000812:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000816:	00e780a3          	sb	a4,1(a5)

  initlock(&tx_lock, "uart");
    8000081a:	00007597          	auipc	a1,0x7
    8000081e:	83658593          	addi	a1,a1,-1994 # 80007050 <digits+0x18>
    80000822:	0000f517          	auipc	a0,0xf
    80000826:	25e50513          	addi	a0,a0,606 # 8000fa80 <tx_lock>
    8000082a:	2c2000ef          	jal	ra,80000aec <initlock>
}
    8000082e:	60a2                	ld	ra,8(sp)
    80000830:	6402                	ld	s0,0(sp)
    80000832:	0141                	addi	sp,sp,16
    80000834:	8082                	ret

0000000080000836 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000836:	715d                	addi	sp,sp,-80
    80000838:	e486                	sd	ra,72(sp)
    8000083a:	e0a2                	sd	s0,64(sp)
    8000083c:	fc26                	sd	s1,56(sp)
    8000083e:	f84a                	sd	s2,48(sp)
    80000840:	f44e                	sd	s3,40(sp)
    80000842:	f052                	sd	s4,32(sp)
    80000844:	ec56                	sd	s5,24(sp)
    80000846:	e85a                	sd	s6,16(sp)
    80000848:	e45e                	sd	s7,8(sp)
    8000084a:	0880                	addi	s0,sp,80
    8000084c:	84aa                	mv	s1,a0
    8000084e:	8aae                	mv	s5,a1
  acquire(&tx_lock);
    80000850:	0000f517          	auipc	a0,0xf
    80000854:	23050513          	addi	a0,a0,560 # 8000fa80 <tx_lock>
    80000858:	314000ef          	jal	ra,80000b6c <acquire>

  int i = 0;
  while(i < n){ 
    8000085c:	05505b63          	blez	s5,800008b2 <uartwrite+0x7c>
    80000860:	8a26                	mv	s4,s1
    80000862:	0485                	addi	s1,s1,1
    80000864:	3afd                	addiw	s5,s5,-1
    80000866:	1a82                	slli	s5,s5,0x20
    80000868:	020ada93          	srli	s5,s5,0x20
    8000086c:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    8000086e:	00007497          	auipc	s1,0x7
    80000872:	12e48493          	addi	s1,s1,302 # 8000799c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	20a98993          	addi	s3,s3,522 # 8000fa80 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	11a90913          	addi	s2,s2,282 # 80007998 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000886:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    8000088a:	4b05                	li	s6,1
    8000088c:	a005                	j	800008ac <uartwrite+0x76>
      sleep(&tx_chan, &tx_lock);
    8000088e:	85ce                	mv	a1,s3
    80000890:	854a                	mv	a0,s2
    80000892:	598010ef          	jal	ra,80001e2a <sleep>
    while(tx_busy != 0){
    80000896:	409c                	lw	a5,0(s1)
    80000898:	fbfd                	bnez	a5,8000088e <uartwrite+0x58>
    WriteReg(THR, buf[i]);
    8000089a:	000a4783          	lbu	a5,0(s4)
    8000089e:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008a2:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008a6:	0a05                	addi	s4,s4,1
    800008a8:	015a0563          	beq	s4,s5,800008b2 <uartwrite+0x7c>
    while(tx_busy != 0){
    800008ac:	409c                	lw	a5,0(s1)
    800008ae:	f3e5                	bnez	a5,8000088e <uartwrite+0x58>
    800008b0:	b7ed                	j	8000089a <uartwrite+0x64>
  }

  release(&tx_lock);
    800008b2:	0000f517          	auipc	a0,0xf
    800008b6:	1ce50513          	addi	a0,a0,462 # 8000fa80 <tx_lock>
    800008ba:	34a000ef          	jal	ra,80000c04 <release>
}
    800008be:	60a6                	ld	ra,72(sp)
    800008c0:	6406                	ld	s0,64(sp)
    800008c2:	74e2                	ld	s1,56(sp)
    800008c4:	7942                	ld	s2,48(sp)
    800008c6:	79a2                	ld	s3,40(sp)
    800008c8:	7a02                	ld	s4,32(sp)
    800008ca:	6ae2                	ld	s5,24(sp)
    800008cc:	6b42                	ld	s6,16(sp)
    800008ce:	6ba2                	ld	s7,8(sp)
    800008d0:	6161                	addi	sp,sp,80
    800008d2:	8082                	ret

00000000800008d4 <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800008d4:	1101                	addi	sp,sp,-32
    800008d6:	ec06                	sd	ra,24(sp)
    800008d8:	e822                	sd	s0,16(sp)
    800008da:	e426                	sd	s1,8(sp)
    800008dc:	1000                	addi	s0,sp,32
    800008de:	84aa                	mv	s1,a0
  if(panicking == 0)
    800008e0:	00007797          	auipc	a5,0x7
    800008e4:	0b47a783          	lw	a5,180(a5) # 80007994 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	0a67a783          	lw	a5,166(a5) # 80007990 <panicked>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800008f6:	c789                	beqz	a5,80000900 <uartputc_sync+0x2c>
    for(;;)
    800008f8:	a001                	j	800008f8 <uartputc_sync+0x24>
    push_off();
    800008fa:	232000ef          	jal	ra,80000b2c <push_off>
    800008fe:	b7f5                	j	800008ea <uartputc_sync+0x16>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000900:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000904:	0207f793          	andi	a5,a5,32
    80000908:	dfe5                	beqz	a5,80000900 <uartputc_sync+0x2c>
    ;
  WriteReg(THR, c);
    8000090a:	0ff4f513          	andi	a0,s1,255
    8000090e:	100007b7          	lui	a5,0x10000
    80000912:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000916:	00007797          	auipc	a5,0x7
    8000091a:	07e7a783          	lw	a5,126(a5) # 80007994 <panicking>
    8000091e:	c791                	beqz	a5,8000092a <uartputc_sync+0x56>
    pop_off();
}
    80000920:	60e2                	ld	ra,24(sp)
    80000922:	6442                	ld	s0,16(sp)
    80000924:	64a2                	ld	s1,8(sp)
    80000926:	6105                	addi	sp,sp,32
    80000928:	8082                	ret
    pop_off();
    8000092a:	286000ef          	jal	ra,80000bb0 <pop_off>
}
    8000092e:	bfcd                	j	80000920 <uartputc_sync+0x4c>

0000000080000930 <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000930:	1141                	addi	sp,sp,-16
    80000932:	e422                	sd	s0,8(sp)
    80000934:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000936:	100007b7          	lui	a5,0x10000
    8000093a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000093e:	8b85                	andi	a5,a5,1
    80000940:	cb91                	beqz	a5,80000954 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000942:	100007b7          	lui	a5,0x10000
    80000946:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000094a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000094e:	6422                	ld	s0,8(sp)
    80000950:	0141                	addi	sp,sp,16
    80000952:	8082                	ret
    return -1;
    80000954:	557d                	li	a0,-1
    80000956:	bfe5                	j	8000094e <uartgetc+0x1e>

0000000080000958 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000958:	1101                	addi	sp,sp,-32
    8000095a:	ec06                	sd	ra,24(sp)
    8000095c:	e822                	sd	s0,16(sp)
    8000095e:	e426                	sd	s1,8(sp)
    80000960:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000962:	100004b7          	lui	s1,0x10000
    80000966:	0024c783          	lbu	a5,2(s1) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    8000096a:	0000f517          	auipc	a0,0xf
    8000096e:	11650513          	addi	a0,a0,278 # 8000fa80 <tx_lock>
    80000972:	1fa000ef          	jal	ra,80000b6c <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000976:	0054c783          	lbu	a5,5(s1)
    8000097a:	0207f793          	andi	a5,a5,32
    8000097e:	eb89                	bnez	a5,80000990 <uartintr+0x38>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000980:	0000f517          	auipc	a0,0xf
    80000984:	10050513          	addi	a0,a0,256 # 8000fa80 <tx_lock>
    80000988:	27c000ef          	jal	ra,80000c04 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000098c:	54fd                	li	s1,-1
    8000098e:	a831                	j	800009aa <uartintr+0x52>
    tx_busy = 0;
    80000990:	00007797          	auipc	a5,0x7
    80000994:	0007a623          	sw	zero,12(a5) # 8000799c <tx_busy>
    wakeup(&tx_chan);
    80000998:	00007517          	auipc	a0,0x7
    8000099c:	00050513          	mv	a0,a0
    800009a0:	4d6010ef          	jal	ra,80001e76 <wakeup>
    800009a4:	bff1                	j	80000980 <uartintr+0x28>
      break;
    consoleintr(c);
    800009a6:	8d5ff0ef          	jal	ra,8000027a <consoleintr>
    int c = uartgetc();
    800009aa:	f87ff0ef          	jal	ra,80000930 <uartgetc>
    if(c == -1)
    800009ae:	fe951ce3          	bne	a0,s1,800009a6 <uartintr+0x4e>
  }
}
    800009b2:	60e2                	ld	ra,24(sp)
    800009b4:	6442                	ld	s0,16(sp)
    800009b6:	64a2                	ld	s1,8(sp)
    800009b8:	6105                	addi	sp,sp,32
    800009ba:	8082                	ret

00000000800009bc <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009bc:	1101                	addi	sp,sp,-32
    800009be:	ec06                	sd	ra,24(sp)
    800009c0:	e822                	sd	s0,16(sp)
    800009c2:	e426                	sd	s1,8(sp)
    800009c4:	e04a                	sd	s2,0(sp)
    800009c6:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009c8:	03451793          	slli	a5,a0,0x34
    800009cc:	e7a9                	bnez	a5,80000a16 <kfree+0x5a>
    800009ce:	84aa                	mv	s1,a0
    800009d0:	00020797          	auipc	a5,0x20
    800009d4:	6f878793          	addi	a5,a5,1784 # 800210c8 <end>
    800009d8:	02f56f63          	bltu	a0,a5,80000a16 <kfree+0x5a>
    800009dc:	47c5                	li	a5,17
    800009de:	07ee                	slli	a5,a5,0x1b
    800009e0:	02f57b63          	bgeu	a0,a5,80000a16 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009e4:	6605                	lui	a2,0x1
    800009e6:	4585                	li	a1,1
    800009e8:	258000ef          	jal	ra,80000c40 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800009ec:	0000f917          	auipc	s2,0xf
    800009f0:	0ac90913          	addi	s2,s2,172 # 8000fa98 <kmem>
    800009f4:	854a                	mv	a0,s2
    800009f6:	176000ef          	jal	ra,80000b6c <acquire>
  r->next = kmem.freelist;
    800009fa:	01893783          	ld	a5,24(s2)
    800009fe:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a00:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a04:	854a                	mv	a0,s2
    80000a06:	1fe000ef          	jal	ra,80000c04 <release>
}
    80000a0a:	60e2                	ld	ra,24(sp)
    80000a0c:	6442                	ld	s0,16(sp)
    80000a0e:	64a2                	ld	s1,8(sp)
    80000a10:	6902                	ld	s2,0(sp)
    80000a12:	6105                	addi	sp,sp,32
    80000a14:	8082                	ret
    panic("kfree");
    80000a16:	00006517          	auipc	a0,0x6
    80000a1a:	64250513          	addi	a0,a0,1602 # 80007058 <digits+0x20>
    80000a1e:	d6dff0ef          	jal	ra,8000078a <panic>

0000000080000a22 <freerange>:
{
    80000a22:	7179                	addi	sp,sp,-48
    80000a24:	f406                	sd	ra,40(sp)
    80000a26:	f022                	sd	s0,32(sp)
    80000a28:	ec26                	sd	s1,24(sp)
    80000a2a:	e84a                	sd	s2,16(sp)
    80000a2c:	e44e                	sd	s3,8(sp)
    80000a2e:	e052                	sd	s4,0(sp)
    80000a30:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a32:	6785                	lui	a5,0x1
    80000a34:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a38:	94aa                	add	s1,s1,a0
    80000a3a:	757d                	lui	a0,0xfffff
    80000a3c:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a3e:	94be                	add	s1,s1,a5
    80000a40:	0095ec63          	bltu	a1,s1,80000a58 <freerange+0x36>
    80000a44:	892e                	mv	s2,a1
    kfree(p);
    80000a46:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a48:	6985                	lui	s3,0x1
    kfree(p);
    80000a4a:	01448533          	add	a0,s1,s4
    80000a4e:	f6fff0ef          	jal	ra,800009bc <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a52:	94ce                	add	s1,s1,s3
    80000a54:	fe997be3          	bgeu	s2,s1,80000a4a <freerange+0x28>
}
    80000a58:	70a2                	ld	ra,40(sp)
    80000a5a:	7402                	ld	s0,32(sp)
    80000a5c:	64e2                	ld	s1,24(sp)
    80000a5e:	6942                	ld	s2,16(sp)
    80000a60:	69a2                	ld	s3,8(sp)
    80000a62:	6a02                	ld	s4,0(sp)
    80000a64:	6145                	addi	sp,sp,48
    80000a66:	8082                	ret

0000000080000a68 <kinit>:
{
    80000a68:	1141                	addi	sp,sp,-16
    80000a6a:	e406                	sd	ra,8(sp)
    80000a6c:	e022                	sd	s0,0(sp)
    80000a6e:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a70:	00006597          	auipc	a1,0x6
    80000a74:	5f058593          	addi	a1,a1,1520 # 80007060 <digits+0x28>
    80000a78:	0000f517          	auipc	a0,0xf
    80000a7c:	02050513          	addi	a0,a0,32 # 8000fa98 <kmem>
    80000a80:	06c000ef          	jal	ra,80000aec <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a84:	45c5                	li	a1,17
    80000a86:	05ee                	slli	a1,a1,0x1b
    80000a88:	00020517          	auipc	a0,0x20
    80000a8c:	64050513          	addi	a0,a0,1600 # 800210c8 <end>
    80000a90:	f93ff0ef          	jal	ra,80000a22 <freerange>
}
    80000a94:	60a2                	ld	ra,8(sp)
    80000a96:	6402                	ld	s0,0(sp)
    80000a98:	0141                	addi	sp,sp,16
    80000a9a:	8082                	ret

0000000080000a9c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000a9c:	1101                	addi	sp,sp,-32
    80000a9e:	ec06                	sd	ra,24(sp)
    80000aa0:	e822                	sd	s0,16(sp)
    80000aa2:	e426                	sd	s1,8(sp)
    80000aa4:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aa6:	0000f497          	auipc	s1,0xf
    80000aaa:	ff248493          	addi	s1,s1,-14 # 8000fa98 <kmem>
    80000aae:	8526                	mv	a0,s1
    80000ab0:	0bc000ef          	jal	ra,80000b6c <acquire>
  r = kmem.freelist;
    80000ab4:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab6:	c485                	beqz	s1,80000ade <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab8:	609c                	ld	a5,0(s1)
    80000aba:	0000f517          	auipc	a0,0xf
    80000abe:	fde50513          	addi	a0,a0,-34 # 8000fa98 <kmem>
    80000ac2:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000ac4:	140000ef          	jal	ra,80000c04 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000ac8:	6605                	lui	a2,0x1
    80000aca:	4595                	li	a1,5
    80000acc:	8526                	mv	a0,s1
    80000ace:	172000ef          	jal	ra,80000c40 <memset>
  return (void*)r;
}
    80000ad2:	8526                	mv	a0,s1
    80000ad4:	60e2                	ld	ra,24(sp)
    80000ad6:	6442                	ld	s0,16(sp)
    80000ad8:	64a2                	ld	s1,8(sp)
    80000ada:	6105                	addi	sp,sp,32
    80000adc:	8082                	ret
  release(&kmem.lock);
    80000ade:	0000f517          	auipc	a0,0xf
    80000ae2:	fba50513          	addi	a0,a0,-70 # 8000fa98 <kmem>
    80000ae6:	11e000ef          	jal	ra,80000c04 <release>
  if(r)
    80000aea:	b7e5                	j	80000ad2 <kalloc+0x36>

0000000080000aec <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000aec:	1141                	addi	sp,sp,-16
    80000aee:	e422                	sd	s0,8(sp)
    80000af0:	0800                	addi	s0,sp,16
  lk->name = name;
    80000af2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000af4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000af8:	00053823          	sd	zero,16(a0)
}
    80000afc:	6422                	ld	s0,8(sp)
    80000afe:	0141                	addi	sp,sp,16
    80000b00:	8082                	ret

0000000080000b02 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b02:	411c                	lw	a5,0(a0)
    80000b04:	e399                	bnez	a5,80000b0a <holding+0x8>
    80000b06:	4501                	li	a0,0
  return r;
}
    80000b08:	8082                	ret
{
    80000b0a:	1101                	addi	sp,sp,-32
    80000b0c:	ec06                	sd	ra,24(sp)
    80000b0e:	e822                	sd	s0,16(sp)
    80000b10:	e426                	sd	s1,8(sp)
    80000b12:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b14:	6904                	ld	s1,16(a0)
    80000b16:	4db000ef          	jal	ra,800017f0 <mycpu>
    80000b1a:	40a48533          	sub	a0,s1,a0
    80000b1e:	00153513          	seqz	a0,a0
}
    80000b22:	60e2                	ld	ra,24(sp)
    80000b24:	6442                	ld	s0,16(sp)
    80000b26:	64a2                	ld	s1,8(sp)
    80000b28:	6105                	addi	sp,sp,32
    80000b2a:	8082                	ret

0000000080000b2c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b2c:	1101                	addi	sp,sp,-32
    80000b2e:	ec06                	sd	ra,24(sp)
    80000b30:	e822                	sd	s0,16(sp)
    80000b32:	e426                	sd	s1,8(sp)
    80000b34:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b36:	100024f3          	csrr	s1,sstatus
    80000b3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b3e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b40:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000b44:	4ad000ef          	jal	ra,800017f0 <mycpu>
    80000b48:	5d3c                	lw	a5,120(a0)
    80000b4a:	cb99                	beqz	a5,80000b60 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4c:	4a5000ef          	jal	ra,800017f0 <mycpu>
    80000b50:	5d3c                	lw	a5,120(a0)
    80000b52:	2785                	addiw	a5,a5,1
    80000b54:	dd3c                	sw	a5,120(a0)
}
    80000b56:	60e2                	ld	ra,24(sp)
    80000b58:	6442                	ld	s0,16(sp)
    80000b5a:	64a2                	ld	s1,8(sp)
    80000b5c:	6105                	addi	sp,sp,32
    80000b5e:	8082                	ret
    mycpu()->intena = old;
    80000b60:	491000ef          	jal	ra,800017f0 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b64:	8085                	srli	s1,s1,0x1
    80000b66:	8885                	andi	s1,s1,1
    80000b68:	dd64                	sw	s1,124(a0)
    80000b6a:	b7cd                	j	80000b4c <push_off+0x20>

0000000080000b6c <acquire>:
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
    80000b76:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b78:	fb5ff0ef          	jal	ra,80000b2c <push_off>
  if(holding(lk))
    80000b7c:	8526                	mv	a0,s1
    80000b7e:	f85ff0ef          	jal	ra,80000b02 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b82:	4705                	li	a4,1
  if(holding(lk))
    80000b84:	e105                	bnez	a0,80000ba4 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b86:	87ba                	mv	a5,a4
    80000b88:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b8c:	2781                	sext.w	a5,a5
    80000b8e:	ffe5                	bnez	a5,80000b86 <acquire+0x1a>
  __sync_synchronize();
    80000b90:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b94:	45d000ef          	jal	ra,800017f0 <mycpu>
    80000b98:	e888                	sd	a0,16(s1)
}
    80000b9a:	60e2                	ld	ra,24(sp)
    80000b9c:	6442                	ld	s0,16(sp)
    80000b9e:	64a2                	ld	s1,8(sp)
    80000ba0:	6105                	addi	sp,sp,32
    80000ba2:	8082                	ret
    panic("acquire");
    80000ba4:	00006517          	auipc	a0,0x6
    80000ba8:	4c450513          	addi	a0,a0,1220 # 80007068 <digits+0x30>
    80000bac:	bdfff0ef          	jal	ra,8000078a <panic>

0000000080000bb0 <pop_off>:

void
pop_off(void)
{
    80000bb0:	1141                	addi	sp,sp,-16
    80000bb2:	e406                	sd	ra,8(sp)
    80000bb4:	e022                	sd	s0,0(sp)
    80000bb6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bb8:	439000ef          	jal	ra,800017f0 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bc0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000bc2:	e78d                	bnez	a5,80000bec <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000bc4:	5d3c                	lw	a5,120(a0)
    80000bc6:	02f05963          	blez	a5,80000bf8 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000bca:	37fd                	addiw	a5,a5,-1
    80000bcc:	0007871b          	sext.w	a4,a5
    80000bd0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000bd2:	eb09                	bnez	a4,80000be4 <pop_off+0x34>
    80000bd4:	5d7c                	lw	a5,124(a0)
    80000bd6:	c799                	beqz	a5,80000be4 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000bdc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000be0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000be4:	60a2                	ld	ra,8(sp)
    80000be6:	6402                	ld	s0,0(sp)
    80000be8:	0141                	addi	sp,sp,16
    80000bea:	8082                	ret
    panic("pop_off - interruptible");
    80000bec:	00006517          	auipc	a0,0x6
    80000bf0:	48450513          	addi	a0,a0,1156 # 80007070 <digits+0x38>
    80000bf4:	b97ff0ef          	jal	ra,8000078a <panic>
    panic("pop_off");
    80000bf8:	00006517          	auipc	a0,0x6
    80000bfc:	49050513          	addi	a0,a0,1168 # 80007088 <digits+0x50>
    80000c00:	b8bff0ef          	jal	ra,8000078a <panic>

0000000080000c04 <release>:
{
    80000c04:	1101                	addi	sp,sp,-32
    80000c06:	ec06                	sd	ra,24(sp)
    80000c08:	e822                	sd	s0,16(sp)
    80000c0a:	e426                	sd	s1,8(sp)
    80000c0c:	1000                	addi	s0,sp,32
    80000c0e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c10:	ef3ff0ef          	jal	ra,80000b02 <holding>
    80000c14:	c105                	beqz	a0,80000c34 <release+0x30>
  lk->cpu = 0;
    80000c16:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c1a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c1e:	0f50000f          	fence	iorw,ow
    80000c22:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c26:	f8bff0ef          	jal	ra,80000bb0 <pop_off>
}
    80000c2a:	60e2                	ld	ra,24(sp)
    80000c2c:	6442                	ld	s0,16(sp)
    80000c2e:	64a2                	ld	s1,8(sp)
    80000c30:	6105                	addi	sp,sp,32
    80000c32:	8082                	ret
    panic("release");
    80000c34:	00006517          	auipc	a0,0x6
    80000c38:	45c50513          	addi	a0,a0,1116 # 80007090 <digits+0x58>
    80000c3c:	b4fff0ef          	jal	ra,8000078a <panic>

0000000080000c40 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c40:	1141                	addi	sp,sp,-16
    80000c42:	e422                	sd	s0,8(sp)
    80000c44:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000c46:	ca19                	beqz	a2,80000c5c <memset+0x1c>
    80000c48:	87aa                	mv	a5,a0
    80000c4a:	1602                	slli	a2,a2,0x20
    80000c4c:	9201                	srli	a2,a2,0x20
    80000c4e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c52:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000c56:	0785                	addi	a5,a5,1
    80000c58:	fee79de3          	bne	a5,a4,80000c52 <memset+0x12>
  }
  return dst;
}
    80000c5c:	6422                	ld	s0,8(sp)
    80000c5e:	0141                	addi	sp,sp,16
    80000c60:	8082                	ret

0000000080000c62 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c62:	1141                	addi	sp,sp,-16
    80000c64:	e422                	sd	s0,8(sp)
    80000c66:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000c68:	ca05                	beqz	a2,80000c98 <memcmp+0x36>
    80000c6a:	fff6069b          	addiw	a3,a2,-1
    80000c6e:	1682                	slli	a3,a3,0x20
    80000c70:	9281                	srli	a3,a3,0x20
    80000c72:	0685                	addi	a3,a3,1
    80000c74:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000c76:	00054783          	lbu	a5,0(a0)
    80000c7a:	0005c703          	lbu	a4,0(a1)
    80000c7e:	00e79863          	bne	a5,a4,80000c8e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000c82:	0505                	addi	a0,a0,1
    80000c84:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000c86:	fed518e3          	bne	a0,a3,80000c76 <memcmp+0x14>
  }

  return 0;
    80000c8a:	4501                	li	a0,0
    80000c8c:	a019                	j	80000c92 <memcmp+0x30>
      return *s1 - *s2;
    80000c8e:	40e7853b          	subw	a0,a5,a4
}
    80000c92:	6422                	ld	s0,8(sp)
    80000c94:	0141                	addi	sp,sp,16
    80000c96:	8082                	ret
  return 0;
    80000c98:	4501                	li	a0,0
    80000c9a:	bfe5                	j	80000c92 <memcmp+0x30>

0000000080000c9c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000c9c:	1141                	addi	sp,sp,-16
    80000c9e:	e422                	sd	s0,8(sp)
    80000ca0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000ca2:	c205                	beqz	a2,80000cc2 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ca4:	02a5e263          	bltu	a1,a0,80000cc8 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ca8:	1602                	slli	a2,a2,0x20
    80000caa:	9201                	srli	a2,a2,0x20
    80000cac:	00c587b3          	add	a5,a1,a2
{
    80000cb0:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cb2:	0585                	addi	a1,a1,1
    80000cb4:	0705                	addi	a4,a4,1
    80000cb6:	fff5c683          	lbu	a3,-1(a1)
    80000cba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000cbe:	fef59ae3          	bne	a1,a5,80000cb2 <memmove+0x16>

  return dst;
}
    80000cc2:	6422                	ld	s0,8(sp)
    80000cc4:	0141                	addi	sp,sp,16
    80000cc6:	8082                	ret
  if(s < d && s + n > d){
    80000cc8:	02061693          	slli	a3,a2,0x20
    80000ccc:	9281                	srli	a3,a3,0x20
    80000cce:	00d58733          	add	a4,a1,a3
    80000cd2:	fce57be3          	bgeu	a0,a4,80000ca8 <memmove+0xc>
    d += n;
    80000cd6:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000cd8:	fff6079b          	addiw	a5,a2,-1
    80000cdc:	1782                	slli	a5,a5,0x20
    80000cde:	9381                	srli	a5,a5,0x20
    80000ce0:	fff7c793          	not	a5,a5
    80000ce4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000ce6:	177d                	addi	a4,a4,-1
    80000ce8:	16fd                	addi	a3,a3,-1
    80000cea:	00074603          	lbu	a2,0(a4)
    80000cee:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000cf2:	fee79ae3          	bne	a5,a4,80000ce6 <memmove+0x4a>
    80000cf6:	b7f1                	j	80000cc2 <memmove+0x26>

0000000080000cf8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d00:	f9dff0ef          	jal	ra,80000c9c <memmove>
}
    80000d04:	60a2                	ld	ra,8(sp)
    80000d06:	6402                	ld	s0,0(sp)
    80000d08:	0141                	addi	sp,sp,16
    80000d0a:	8082                	ret

0000000080000d0c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d12:	ce11                	beqz	a2,80000d2e <strncmp+0x22>
    80000d14:	00054783          	lbu	a5,0(a0)
    80000d18:	cf89                	beqz	a5,80000d32 <strncmp+0x26>
    80000d1a:	0005c703          	lbu	a4,0(a1)
    80000d1e:	00f71a63          	bne	a4,a5,80000d32 <strncmp+0x26>
    n--, p++, q++;
    80000d22:	367d                	addiw	a2,a2,-1
    80000d24:	0505                	addi	a0,a0,1
    80000d26:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d28:	f675                	bnez	a2,80000d14 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	a809                	j	80000d3e <strncmp+0x32>
    80000d2e:	4501                	li	a0,0
    80000d30:	a039                	j	80000d3e <strncmp+0x32>
  if(n == 0)
    80000d32:	ca09                	beqz	a2,80000d44 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000d34:	00054503          	lbu	a0,0(a0)
    80000d38:	0005c783          	lbu	a5,0(a1)
    80000d3c:	9d1d                	subw	a0,a0,a5
}
    80000d3e:	6422                	ld	s0,8(sp)
    80000d40:	0141                	addi	sp,sp,16
    80000d42:	8082                	ret
    return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	bfe5                	j	80000d3e <strncmp+0x32>

0000000080000d48 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000d48:	1141                	addi	sp,sp,-16
    80000d4a:	e422                	sd	s0,8(sp)
    80000d4c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000d4e:	872a                	mv	a4,a0
    80000d50:	8832                	mv	a6,a2
    80000d52:	367d                	addiw	a2,a2,-1
    80000d54:	01005963          	blez	a6,80000d66 <strncpy+0x1e>
    80000d58:	0705                	addi	a4,a4,1
    80000d5a:	0005c783          	lbu	a5,0(a1)
    80000d5e:	fef70fa3          	sb	a5,-1(a4)
    80000d62:	0585                	addi	a1,a1,1
    80000d64:	f7f5                	bnez	a5,80000d50 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000d66:	86ba                	mv	a3,a4
    80000d68:	00c05c63          	blez	a2,80000d80 <strncpy+0x38>
    *s++ = 0;
    80000d6c:	0685                	addi	a3,a3,1
    80000d6e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000d72:	fff6c793          	not	a5,a3
    80000d76:	9fb9                	addw	a5,a5,a4
    80000d78:	010787bb          	addw	a5,a5,a6
    80000d7c:	fef048e3          	bgtz	a5,80000d6c <strncpy+0x24>
  return os;
}
    80000d80:	6422                	ld	s0,8(sp)
    80000d82:	0141                	addi	sp,sp,16
    80000d84:	8082                	ret

0000000080000d86 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e422                	sd	s0,8(sp)
    80000d8a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000d8c:	02c05363          	blez	a2,80000db2 <safestrcpy+0x2c>
    80000d90:	fff6069b          	addiw	a3,a2,-1
    80000d94:	1682                	slli	a3,a3,0x20
    80000d96:	9281                	srli	a3,a3,0x20
    80000d98:	96ae                	add	a3,a3,a1
    80000d9a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000d9c:	00d58963          	beq	a1,a3,80000dae <safestrcpy+0x28>
    80000da0:	0585                	addi	a1,a1,1
    80000da2:	0785                	addi	a5,a5,1
    80000da4:	fff5c703          	lbu	a4,-1(a1)
    80000da8:	fee78fa3          	sb	a4,-1(a5)
    80000dac:	fb65                	bnez	a4,80000d9c <safestrcpy+0x16>
    ;
  *s = 0;
    80000dae:	00078023          	sb	zero,0(a5)
  return os;
}
    80000db2:	6422                	ld	s0,8(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <strlen>:

int
strlen(const char *s)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000dbe:	00054783          	lbu	a5,0(a0)
    80000dc2:	cf91                	beqz	a5,80000dde <strlen+0x26>
    80000dc4:	0505                	addi	a0,a0,1
    80000dc6:	87aa                	mv	a5,a0
    80000dc8:	4685                	li	a3,1
    80000dca:	9e89                	subw	a3,a3,a0
    80000dcc:	00f6853b          	addw	a0,a3,a5
    80000dd0:	0785                	addi	a5,a5,1
    80000dd2:	fff7c703          	lbu	a4,-1(a5)
    80000dd6:	fb7d                	bnez	a4,80000dcc <strlen+0x14>
    ;
  return n;
}
    80000dd8:	6422                	ld	s0,8(sp)
    80000dda:	0141                	addi	sp,sp,16
    80000ddc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000dde:	4501                	li	a0,0
    80000de0:	bfe5                	j	80000dd8 <strlen+0x20>

0000000080000de2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000de2:	1141                	addi	sp,sp,-16
    80000de4:	e406                	sd	ra,8(sp)
    80000de6:	e022                	sd	s0,0(sp)
    80000de8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000dea:	1f7000ef          	jal	ra,800017e0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dee:	00007717          	auipc	a4,0x7
    80000df2:	bb270713          	addi	a4,a4,-1102 # 800079a0 <started>
  if(cpuid() == 0){
    80000df6:	c51d                	beqz	a0,80000e24 <main+0x42>
    while(started == 0)
    80000df8:	431c                	lw	a5,0(a4)
    80000dfa:	2781                	sext.w	a5,a5
    80000dfc:	dff5                	beqz	a5,80000df8 <main+0x16>
      ;
    __sync_synchronize();
    80000dfe:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e02:	1df000ef          	jal	ra,800017e0 <cpuid>
    80000e06:	85aa                	mv	a1,a0
    80000e08:	00006517          	auipc	a0,0x6
    80000e0c:	2a850513          	addi	a0,a0,680 # 800070b0 <digits+0x78>
    80000e10:	eb4ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000e14:	080000ef          	jal	ra,80000e94 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e18:	57c010ef          	jal	ra,80002394 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1c:	6d8040ef          	jal	ra,800054f4 <plicinithart>
  }

  scheduler();        
    80000e20:	673000ef          	jal	ra,80001c92 <scheduler>
    consoleinit();
    80000e24:	dc8ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000e28:	99fff0ef          	jal	ra,800007c6 <printfinit>
    printf("\n");
    80000e2c:	00006517          	auipc	a0,0x6
    80000e30:	6dc50513          	addi	a0,a0,1756 # 80007508 <syscalls+0x100>
    80000e34:	e90ff0ef          	jal	ra,800004c4 <printf>
    printf("xv6 kernel is booting\n");
    80000e38:	00006517          	auipc	a0,0x6
    80000e3c:	26050513          	addi	a0,a0,608 # 80007098 <digits+0x60>
    80000e40:	e84ff0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80000e44:	00006517          	auipc	a0,0x6
    80000e48:	6c450513          	addi	a0,a0,1732 # 80007508 <syscalls+0x100>
    80000e4c:	e78ff0ef          	jal	ra,800004c4 <printf>
    kinit();         // physical page allocator
    80000e50:	c19ff0ef          	jal	ra,80000a68 <kinit>
    kvminit();       // create kernel page table
    80000e54:	2ca000ef          	jal	ra,8000111e <kvminit>
    kvminithart();   // turn on paging
    80000e58:	03c000ef          	jal	ra,80000e94 <kvminithart>
    procinit();      // process table
    80000e5c:	0d5000ef          	jal	ra,80001730 <procinit>
    trapinit();      // trap vectors
    80000e60:	510010ef          	jal	ra,80002370 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e64:	530010ef          	jal	ra,80002394 <trapinithart>
    plicinit();      // set up interrupt controller
    80000e68:	676040ef          	jal	ra,800054de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6c:	688040ef          	jal	ra,800054f4 <plicinithart>
    binit();         // buffer cache
    80000e70:	62d010ef          	jal	ra,80002c9c <binit>
    iinit();         // inode table
    80000e74:	3a0020ef          	jal	ra,80003214 <iinit>
    fileinit();      // file table
    80000e78:	280030ef          	jal	ra,800040f8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7c:	768040ef          	jal	ra,800055e4 <virtio_disk_init>
    userinit();      // first user process
    80000e80:	465000ef          	jal	ra,80001ae4 <userinit>
    __sync_synchronize();
    80000e84:	0ff0000f          	fence
    started = 1;
    80000e88:	4785                	li	a5,1
    80000e8a:	00007717          	auipc	a4,0x7
    80000e8e:	b0f72b23          	sw	a5,-1258(a4) # 800079a0 <started>
    80000e92:	b779                	j	80000e20 <main+0x3e>

0000000080000e94 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e422                	sd	s0,8(sp)
    80000e98:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000e9a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000e9e:	00007797          	auipc	a5,0x7
    80000ea2:	b0a7b783          	ld	a5,-1270(a5) # 800079a8 <kernel_pagetable>
    80000ea6:	83b1                	srli	a5,a5,0xc
    80000ea8:	577d                	li	a4,-1
    80000eaa:	177e                	slli	a4,a4,0x3f
    80000eac:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000eae:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000eb2:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000eb6:	6422                	ld	s0,8(sp)
    80000eb8:	0141                	addi	sp,sp,16
    80000eba:	8082                	ret

0000000080000ebc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ebc:	7139                	addi	sp,sp,-64
    80000ebe:	fc06                	sd	ra,56(sp)
    80000ec0:	f822                	sd	s0,48(sp)
    80000ec2:	f426                	sd	s1,40(sp)
    80000ec4:	f04a                	sd	s2,32(sp)
    80000ec6:	ec4e                	sd	s3,24(sp)
    80000ec8:	e852                	sd	s4,16(sp)
    80000eca:	e456                	sd	s5,8(sp)
    80000ecc:	e05a                	sd	s6,0(sp)
    80000ece:	0080                	addi	s0,sp,64
    80000ed0:	84aa                	mv	s1,a0
    80000ed2:	89ae                	mv	s3,a1
    80000ed4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ed6:	57fd                	li	a5,-1
    80000ed8:	83e9                	srli	a5,a5,0x1a
    80000eda:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000edc:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ede:	02b7fc63          	bgeu	a5,a1,80000f16 <walk+0x5a>
    panic("walk");
    80000ee2:	00006517          	auipc	a0,0x6
    80000ee6:	1e650513          	addi	a0,a0,486 # 800070c8 <digits+0x90>
    80000eea:	8a1ff0ef          	jal	ra,8000078a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000eee:	060a8263          	beqz	s5,80000f52 <walk+0x96>
    80000ef2:	babff0ef          	jal	ra,80000a9c <kalloc>
    80000ef6:	84aa                	mv	s1,a0
    80000ef8:	c139                	beqz	a0,80000f3e <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000efa:	6605                	lui	a2,0x1
    80000efc:	4581                	li	a1,0
    80000efe:	d43ff0ef          	jal	ra,80000c40 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f02:	00c4d793          	srli	a5,s1,0xc
    80000f06:	07aa                	slli	a5,a5,0xa
    80000f08:	0017e793          	ori	a5,a5,1
    80000f0c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f10:	3a5d                	addiw	s4,s4,-9
    80000f12:	036a0063          	beq	s4,s6,80000f32 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f16:	0149d933          	srl	s2,s3,s4
    80000f1a:	1ff97913          	andi	s2,s2,511
    80000f1e:	090e                	slli	s2,s2,0x3
    80000f20:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f22:	00093483          	ld	s1,0(s2)
    80000f26:	0014f793          	andi	a5,s1,1
    80000f2a:	d3f1                	beqz	a5,80000eee <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f2c:	80a9                	srli	s1,s1,0xa
    80000f2e:	04b2                	slli	s1,s1,0xc
    80000f30:	b7c5                	j	80000f10 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f32:	00c9d513          	srli	a0,s3,0xc
    80000f36:	1ff57513          	andi	a0,a0,511
    80000f3a:	050e                	slli	a0,a0,0x3
    80000f3c:	9526                	add	a0,a0,s1
}
    80000f3e:	70e2                	ld	ra,56(sp)
    80000f40:	7442                	ld	s0,48(sp)
    80000f42:	74a2                	ld	s1,40(sp)
    80000f44:	7902                	ld	s2,32(sp)
    80000f46:	69e2                	ld	s3,24(sp)
    80000f48:	6a42                	ld	s4,16(sp)
    80000f4a:	6aa2                	ld	s5,8(sp)
    80000f4c:	6b02                	ld	s6,0(sp)
    80000f4e:	6121                	addi	sp,sp,64
    80000f50:	8082                	ret
        return 0;
    80000f52:	4501                	li	a0,0
    80000f54:	b7ed                	j	80000f3e <walk+0x82>

0000000080000f56 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	00b7f463          	bgeu	a5,a1,80000f62 <walkaddr+0xc>
    return 0;
    80000f5e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f60:	8082                	ret
{
    80000f62:	1141                	addi	sp,sp,-16
    80000f64:	e406                	sd	ra,8(sp)
    80000f66:	e022                	sd	s0,0(sp)
    80000f68:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f6a:	4601                	li	a2,0
    80000f6c:	f51ff0ef          	jal	ra,80000ebc <walk>
  if(pte == 0)
    80000f70:	c105                	beqz	a0,80000f90 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000f72:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000f74:	0117f693          	andi	a3,a5,17
    80000f78:	4745                	li	a4,17
    return 0;
    80000f7a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000f7c:	00e68663          	beq	a3,a4,80000f88 <walkaddr+0x32>
}
    80000f80:	60a2                	ld	ra,8(sp)
    80000f82:	6402                	ld	s0,0(sp)
    80000f84:	0141                	addi	sp,sp,16
    80000f86:	8082                	ret
  pa = PTE2PA(*pte);
    80000f88:	00a7d513          	srli	a0,a5,0xa
    80000f8c:	0532                	slli	a0,a0,0xc
  return pa;
    80000f8e:	bfcd                	j	80000f80 <walkaddr+0x2a>
    return 0;
    80000f90:	4501                	li	a0,0
    80000f92:	b7fd                	j	80000f80 <walkaddr+0x2a>

0000000080000f94 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000f94:	715d                	addi	sp,sp,-80
    80000f96:	e486                	sd	ra,72(sp)
    80000f98:	e0a2                	sd	s0,64(sp)
    80000f9a:	fc26                	sd	s1,56(sp)
    80000f9c:	f84a                	sd	s2,48(sp)
    80000f9e:	f44e                	sd	s3,40(sp)
    80000fa0:	f052                	sd	s4,32(sp)
    80000fa2:	ec56                	sd	s5,24(sp)
    80000fa4:	e85a                	sd	s6,16(sp)
    80000fa6:	e45e                	sd	s7,8(sp)
    80000fa8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000faa:	03459793          	slli	a5,a1,0x34
    80000fae:	e7a9                	bnez	a5,80000ff8 <mappages+0x64>
    80000fb0:	8aaa                	mv	s5,a0
    80000fb2:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80000fb4:	03461793          	slli	a5,a2,0x34
    80000fb8:	e7b1                	bnez	a5,80001004 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80000fba:	ca39                	beqz	a2,80001010 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80000fbc:	79fd                	lui	s3,0xfffff
    80000fbe:	964e                	add	a2,a2,s3
    80000fc0:	00b609b3          	add	s3,a2,a1
  a = va;
    80000fc4:	892e                	mv	s2,a1
    80000fc6:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000fca:	6b85                	lui	s7,0x1
    80000fcc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000fd0:	4605                	li	a2,1
    80000fd2:	85ca                	mv	a1,s2
    80000fd4:	8556                	mv	a0,s5
    80000fd6:	ee7ff0ef          	jal	ra,80000ebc <walk>
    80000fda:	c539                	beqz	a0,80001028 <mappages+0x94>
    if(*pte & PTE_V)
    80000fdc:	611c                	ld	a5,0(a0)
    80000fde:	8b85                	andi	a5,a5,1
    80000fe0:	ef95                	bnez	a5,8000101c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000fe2:	80b1                	srli	s1,s1,0xc
    80000fe4:	04aa                	slli	s1,s1,0xa
    80000fe6:	0164e4b3          	or	s1,s1,s6
    80000fea:	0014e493          	ori	s1,s1,1
    80000fee:	e104                	sd	s1,0(a0)
    if(a == last)
    80000ff0:	05390863          	beq	s2,s3,80001040 <mappages+0xac>
    a += PGSIZE;
    80000ff4:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80000ff6:	bfd9                	j	80000fcc <mappages+0x38>
    panic("mappages: va not aligned");
    80000ff8:	00006517          	auipc	a0,0x6
    80000ffc:	0d850513          	addi	a0,a0,216 # 800070d0 <digits+0x98>
    80001000:	f8aff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size not aligned");
    80001004:	00006517          	auipc	a0,0x6
    80001008:	0ec50513          	addi	a0,a0,236 # 800070f0 <digits+0xb8>
    8000100c:	f7eff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size");
    80001010:	00006517          	auipc	a0,0x6
    80001014:	10050513          	addi	a0,a0,256 # 80007110 <digits+0xd8>
    80001018:	f72ff0ef          	jal	ra,8000078a <panic>
      panic("mappages: remap");
    8000101c:	00006517          	auipc	a0,0x6
    80001020:	10450513          	addi	a0,a0,260 # 80007120 <digits+0xe8>
    80001024:	f66ff0ef          	jal	ra,8000078a <panic>
      return -1;
    80001028:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000102a:	60a6                	ld	ra,72(sp)
    8000102c:	6406                	ld	s0,64(sp)
    8000102e:	74e2                	ld	s1,56(sp)
    80001030:	7942                	ld	s2,48(sp)
    80001032:	79a2                	ld	s3,40(sp)
    80001034:	7a02                	ld	s4,32(sp)
    80001036:	6ae2                	ld	s5,24(sp)
    80001038:	6b42                	ld	s6,16(sp)
    8000103a:	6ba2                	ld	s7,8(sp)
    8000103c:	6161                	addi	sp,sp,80
    8000103e:	8082                	ret
  return 0;
    80001040:	4501                	li	a0,0
    80001042:	b7e5                	j	8000102a <mappages+0x96>

0000000080001044 <kvmmap>:
{
    80001044:	1141                	addi	sp,sp,-16
    80001046:	e406                	sd	ra,8(sp)
    80001048:	e022                	sd	s0,0(sp)
    8000104a:	0800                	addi	s0,sp,16
    8000104c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000104e:	86b2                	mv	a3,a2
    80001050:	863e                	mv	a2,a5
    80001052:	f43ff0ef          	jal	ra,80000f94 <mappages>
    80001056:	e509                	bnez	a0,80001060 <kvmmap+0x1c>
}
    80001058:	60a2                	ld	ra,8(sp)
    8000105a:	6402                	ld	s0,0(sp)
    8000105c:	0141                	addi	sp,sp,16
    8000105e:	8082                	ret
    panic("kvmmap");
    80001060:	00006517          	auipc	a0,0x6
    80001064:	0d050513          	addi	a0,a0,208 # 80007130 <digits+0xf8>
    80001068:	f22ff0ef          	jal	ra,8000078a <panic>

000000008000106c <kvmmake>:
{
    8000106c:	1101                	addi	sp,sp,-32
    8000106e:	ec06                	sd	ra,24(sp)
    80001070:	e822                	sd	s0,16(sp)
    80001072:	e426                	sd	s1,8(sp)
    80001074:	e04a                	sd	s2,0(sp)
    80001076:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001078:	a25ff0ef          	jal	ra,80000a9c <kalloc>
    8000107c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000107e:	6605                	lui	a2,0x1
    80001080:	4581                	li	a1,0
    80001082:	bbfff0ef          	jal	ra,80000c40 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001086:	4719                	li	a4,6
    80001088:	6685                	lui	a3,0x1
    8000108a:	10000637          	lui	a2,0x10000
    8000108e:	100005b7          	lui	a1,0x10000
    80001092:	8526                	mv	a0,s1
    80001094:	fb1ff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001098:	4719                	li	a4,6
    8000109a:	6685                	lui	a3,0x1
    8000109c:	10001637          	lui	a2,0x10001
    800010a0:	100015b7          	lui	a1,0x10001
    800010a4:	8526                	mv	a0,s1
    800010a6:	f9fff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010aa:	4719                	li	a4,6
    800010ac:	040006b7          	lui	a3,0x4000
    800010b0:	0c000637          	lui	a2,0xc000
    800010b4:	0c0005b7          	lui	a1,0xc000
    800010b8:	8526                	mv	a0,s1
    800010ba:	f8bff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800010be:	00006917          	auipc	s2,0x6
    800010c2:	f4290913          	addi	s2,s2,-190 # 80007000 <etext>
    800010c6:	4729                	li	a4,10
    800010c8:	80006697          	auipc	a3,0x80006
    800010cc:	f3868693          	addi	a3,a3,-200 # 7000 <_entry-0x7fff9000>
    800010d0:	4605                	li	a2,1
    800010d2:	067e                	slli	a2,a2,0x1f
    800010d4:	85b2                	mv	a1,a2
    800010d6:	8526                	mv	a0,s1
    800010d8:	f6dff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800010dc:	4719                	li	a4,6
    800010de:	46c5                	li	a3,17
    800010e0:	06ee                	slli	a3,a3,0x1b
    800010e2:	412686b3          	sub	a3,a3,s2
    800010e6:	864a                	mv	a2,s2
    800010e8:	85ca                	mv	a1,s2
    800010ea:	8526                	mv	a0,s1
    800010ec:	f59ff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800010f0:	4729                	li	a4,10
    800010f2:	6685                	lui	a3,0x1
    800010f4:	00005617          	auipc	a2,0x5
    800010f8:	f0c60613          	addi	a2,a2,-244 # 80006000 <_trampoline>
    800010fc:	040005b7          	lui	a1,0x4000
    80001100:	15fd                	addi	a1,a1,-1
    80001102:	05b2                	slli	a1,a1,0xc
    80001104:	8526                	mv	a0,s1
    80001106:	f3fff0ef          	jal	ra,80001044 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000110a:	8526                	mv	a0,s1
    8000110c:	59a000ef          	jal	ra,800016a6 <proc_mapstacks>
}
    80001110:	8526                	mv	a0,s1
    80001112:	60e2                	ld	ra,24(sp)
    80001114:	6442                	ld	s0,16(sp)
    80001116:	64a2                	ld	s1,8(sp)
    80001118:	6902                	ld	s2,0(sp)
    8000111a:	6105                	addi	sp,sp,32
    8000111c:	8082                	ret

000000008000111e <kvminit>:
{
    8000111e:	1141                	addi	sp,sp,-16
    80001120:	e406                	sd	ra,8(sp)
    80001122:	e022                	sd	s0,0(sp)
    80001124:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001126:	f47ff0ef          	jal	ra,8000106c <kvmmake>
    8000112a:	00007797          	auipc	a5,0x7
    8000112e:	86a7bf23          	sd	a0,-1922(a5) # 800079a8 <kernel_pagetable>
}
    80001132:	60a2                	ld	ra,8(sp)
    80001134:	6402                	ld	s0,0(sp)
    80001136:	0141                	addi	sp,sp,16
    80001138:	8082                	ret

000000008000113a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000113a:	1101                	addi	sp,sp,-32
    8000113c:	ec06                	sd	ra,24(sp)
    8000113e:	e822                	sd	s0,16(sp)
    80001140:	e426                	sd	s1,8(sp)
    80001142:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001144:	959ff0ef          	jal	ra,80000a9c <kalloc>
    80001148:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000114a:	c509                	beqz	a0,80001154 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000114c:	6605                	lui	a2,0x1
    8000114e:	4581                	li	a1,0
    80001150:	af1ff0ef          	jal	ra,80000c40 <memset>
  return pagetable;
}
    80001154:	8526                	mv	a0,s1
    80001156:	60e2                	ld	ra,24(sp)
    80001158:	6442                	ld	s0,16(sp)
    8000115a:	64a2                	ld	s1,8(sp)
    8000115c:	6105                	addi	sp,sp,32
    8000115e:	8082                	ret

0000000080001160 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001160:	7139                	addi	sp,sp,-64
    80001162:	fc06                	sd	ra,56(sp)
    80001164:	f822                	sd	s0,48(sp)
    80001166:	f426                	sd	s1,40(sp)
    80001168:	f04a                	sd	s2,32(sp)
    8000116a:	ec4e                	sd	s3,24(sp)
    8000116c:	e852                	sd	s4,16(sp)
    8000116e:	e456                	sd	s5,8(sp)
    80001170:	e05a                	sd	s6,0(sp)
    80001172:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001174:	03459793          	slli	a5,a1,0x34
    80001178:	e785                	bnez	a5,800011a0 <uvmunmap+0x40>
    8000117a:	8a2a                	mv	s4,a0
    8000117c:	892e                	mv	s2,a1
    8000117e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001180:	0632                	slli	a2,a2,0xc
    80001182:	00b609b3          	add	s3,a2,a1
    80001186:	6b05                	lui	s6,0x1
    80001188:	0335e763          	bltu	a1,s3,800011b6 <uvmunmap+0x56>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000118c:	70e2                	ld	ra,56(sp)
    8000118e:	7442                	ld	s0,48(sp)
    80001190:	74a2                	ld	s1,40(sp)
    80001192:	7902                	ld	s2,32(sp)
    80001194:	69e2                	ld	s3,24(sp)
    80001196:	6a42                	ld	s4,16(sp)
    80001198:	6aa2                	ld	s5,8(sp)
    8000119a:	6b02                	ld	s6,0(sp)
    8000119c:	6121                	addi	sp,sp,64
    8000119e:	8082                	ret
    panic("uvmunmap: not aligned");
    800011a0:	00006517          	auipc	a0,0x6
    800011a4:	f9850513          	addi	a0,a0,-104 # 80007138 <digits+0x100>
    800011a8:	de2ff0ef          	jal	ra,8000078a <panic>
    *pte = 0;
    800011ac:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011b0:	995a                	add	s2,s2,s6
    800011b2:	fd397de3          	bgeu	s2,s3,8000118c <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800011b6:	4601                	li	a2,0
    800011b8:	85ca                	mv	a1,s2
    800011ba:	8552                	mv	a0,s4
    800011bc:	d01ff0ef          	jal	ra,80000ebc <walk>
    800011c0:	84aa                	mv	s1,a0
    800011c2:	d57d                	beqz	a0,800011b0 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800011c4:	611c                	ld	a5,0(a0)
    800011c6:	0017f713          	andi	a4,a5,1
    800011ca:	d37d                	beqz	a4,800011b0 <uvmunmap+0x50>
    if(do_free){
    800011cc:	fe0a80e3          	beqz	s5,800011ac <uvmunmap+0x4c>
      uint64 pa = PTE2PA(*pte);
    800011d0:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800011d2:	00c79513          	slli	a0,a5,0xc
    800011d6:	fe6ff0ef          	jal	ra,800009bc <kfree>
    800011da:	bfc9                	j	800011ac <uvmunmap+0x4c>

00000000800011dc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800011dc:	1101                	addi	sp,sp,-32
    800011de:	ec06                	sd	ra,24(sp)
    800011e0:	e822                	sd	s0,16(sp)
    800011e2:	e426                	sd	s1,8(sp)
    800011e4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800011e6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800011e8:	00b67d63          	bgeu	a2,a1,80001202 <uvmdealloc+0x26>
    800011ec:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800011ee:	6785                	lui	a5,0x1
    800011f0:	17fd                	addi	a5,a5,-1
    800011f2:	00f60733          	add	a4,a2,a5
    800011f6:	767d                	lui	a2,0xfffff
    800011f8:	8f71                	and	a4,a4,a2
    800011fa:	97ae                	add	a5,a5,a1
    800011fc:	8ff1                	and	a5,a5,a2
    800011fe:	00f76863          	bltu	a4,a5,8000120e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001202:	8526                	mv	a0,s1
    80001204:	60e2                	ld	ra,24(sp)
    80001206:	6442                	ld	s0,16(sp)
    80001208:	64a2                	ld	s1,8(sp)
    8000120a:	6105                	addi	sp,sp,32
    8000120c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000120e:	8f99                	sub	a5,a5,a4
    80001210:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001212:	4685                	li	a3,1
    80001214:	0007861b          	sext.w	a2,a5
    80001218:	85ba                	mv	a1,a4
    8000121a:	f47ff0ef          	jal	ra,80001160 <uvmunmap>
    8000121e:	b7d5                	j	80001202 <uvmdealloc+0x26>

0000000080001220 <uvmalloc>:
  if(newsz < oldsz)
    80001220:	08b66963          	bltu	a2,a1,800012b2 <uvmalloc+0x92>
{
    80001224:	7139                	addi	sp,sp,-64
    80001226:	fc06                	sd	ra,56(sp)
    80001228:	f822                	sd	s0,48(sp)
    8000122a:	f426                	sd	s1,40(sp)
    8000122c:	f04a                	sd	s2,32(sp)
    8000122e:	ec4e                	sd	s3,24(sp)
    80001230:	e852                	sd	s4,16(sp)
    80001232:	e456                	sd	s5,8(sp)
    80001234:	e05a                	sd	s6,0(sp)
    80001236:	0080                	addi	s0,sp,64
    80001238:	8aaa                	mv	s5,a0
    8000123a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000123c:	6985                	lui	s3,0x1
    8000123e:	19fd                	addi	s3,s3,-1
    80001240:	95ce                	add	a1,a1,s3
    80001242:	79fd                	lui	s3,0xfffff
    80001244:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001248:	06c9f763          	bgeu	s3,a2,800012b6 <uvmalloc+0x96>
    8000124c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000124e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001252:	84bff0ef          	jal	ra,80000a9c <kalloc>
    80001256:	84aa                	mv	s1,a0
    if(mem == 0){
    80001258:	c11d                	beqz	a0,8000127e <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    8000125a:	6605                	lui	a2,0x1
    8000125c:	4581                	li	a1,0
    8000125e:	9e3ff0ef          	jal	ra,80000c40 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001262:	875a                	mv	a4,s6
    80001264:	86a6                	mv	a3,s1
    80001266:	6605                	lui	a2,0x1
    80001268:	85ca                	mv	a1,s2
    8000126a:	8556                	mv	a0,s5
    8000126c:	d29ff0ef          	jal	ra,80000f94 <mappages>
    80001270:	e51d                	bnez	a0,8000129e <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001272:	6785                	lui	a5,0x1
    80001274:	993e                	add	s2,s2,a5
    80001276:	fd496ee3          	bltu	s2,s4,80001252 <uvmalloc+0x32>
  return newsz;
    8000127a:	8552                	mv	a0,s4
    8000127c:	a039                	j	8000128a <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    8000127e:	864e                	mv	a2,s3
    80001280:	85ca                	mv	a1,s2
    80001282:	8556                	mv	a0,s5
    80001284:	f59ff0ef          	jal	ra,800011dc <uvmdealloc>
      return 0;
    80001288:	4501                	li	a0,0
}
    8000128a:	70e2                	ld	ra,56(sp)
    8000128c:	7442                	ld	s0,48(sp)
    8000128e:	74a2                	ld	s1,40(sp)
    80001290:	7902                	ld	s2,32(sp)
    80001292:	69e2                	ld	s3,24(sp)
    80001294:	6a42                	ld	s4,16(sp)
    80001296:	6aa2                	ld	s5,8(sp)
    80001298:	6b02                	ld	s6,0(sp)
    8000129a:	6121                	addi	sp,sp,64
    8000129c:	8082                	ret
      kfree(mem);
    8000129e:	8526                	mv	a0,s1
    800012a0:	f1cff0ef          	jal	ra,800009bc <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012a4:	864e                	mv	a2,s3
    800012a6:	85ca                	mv	a1,s2
    800012a8:	8556                	mv	a0,s5
    800012aa:	f33ff0ef          	jal	ra,800011dc <uvmdealloc>
      return 0;
    800012ae:	4501                	li	a0,0
    800012b0:	bfe9                	j	8000128a <uvmalloc+0x6a>
    return oldsz;
    800012b2:	852e                	mv	a0,a1
}
    800012b4:	8082                	ret
  return newsz;
    800012b6:	8532                	mv	a0,a2
    800012b8:	bfc9                	j	8000128a <uvmalloc+0x6a>

00000000800012ba <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800012ba:	7179                	addi	sp,sp,-48
    800012bc:	f406                	sd	ra,40(sp)
    800012be:	f022                	sd	s0,32(sp)
    800012c0:	ec26                	sd	s1,24(sp)
    800012c2:	e84a                	sd	s2,16(sp)
    800012c4:	e44e                	sd	s3,8(sp)
    800012c6:	e052                	sd	s4,0(sp)
    800012c8:	1800                	addi	s0,sp,48
    800012ca:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800012cc:	84aa                	mv	s1,a0
    800012ce:	6905                	lui	s2,0x1
    800012d0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012d2:	4985                	li	s3,1
    800012d4:	a811                	j	800012e8 <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800012d6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800012d8:	0532                	slli	a0,a0,0xc
    800012da:	fe1ff0ef          	jal	ra,800012ba <freewalk>
      pagetable[i] = 0;
    800012de:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800012e2:	04a1                	addi	s1,s1,8
    800012e4:	01248f63          	beq	s1,s2,80001302 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800012e8:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012ea:	00f57793          	andi	a5,a0,15
    800012ee:	ff3784e3          	beq	a5,s3,800012d6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800012f2:	8905                	andi	a0,a0,1
    800012f4:	d57d                	beqz	a0,800012e2 <freewalk+0x28>
      panic("freewalk: leaf");
    800012f6:	00006517          	auipc	a0,0x6
    800012fa:	e5a50513          	addi	a0,a0,-422 # 80007150 <digits+0x118>
    800012fe:	c8cff0ef          	jal	ra,8000078a <panic>
    }
  }
  kfree((void*)pagetable);
    80001302:	8552                	mv	a0,s4
    80001304:	eb8ff0ef          	jal	ra,800009bc <kfree>
}
    80001308:	70a2                	ld	ra,40(sp)
    8000130a:	7402                	ld	s0,32(sp)
    8000130c:	64e2                	ld	s1,24(sp)
    8000130e:	6942                	ld	s2,16(sp)
    80001310:	69a2                	ld	s3,8(sp)
    80001312:	6a02                	ld	s4,0(sp)
    80001314:	6145                	addi	sp,sp,48
    80001316:	8082                	ret

0000000080001318 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001318:	1101                	addi	sp,sp,-32
    8000131a:	ec06                	sd	ra,24(sp)
    8000131c:	e822                	sd	s0,16(sp)
    8000131e:	e426                	sd	s1,8(sp)
    80001320:	1000                	addi	s0,sp,32
    80001322:	84aa                	mv	s1,a0
  if(sz > 0)
    80001324:	e989                	bnez	a1,80001336 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001326:	8526                	mv	a0,s1
    80001328:	f93ff0ef          	jal	ra,800012ba <freewalk>
}
    8000132c:	60e2                	ld	ra,24(sp)
    8000132e:	6442                	ld	s0,16(sp)
    80001330:	64a2                	ld	s1,8(sp)
    80001332:	6105                	addi	sp,sp,32
    80001334:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001336:	6605                	lui	a2,0x1
    80001338:	167d                	addi	a2,a2,-1
    8000133a:	962e                	add	a2,a2,a1
    8000133c:	4685                	li	a3,1
    8000133e:	8231                	srli	a2,a2,0xc
    80001340:	4581                	li	a1,0
    80001342:	e1fff0ef          	jal	ra,80001160 <uvmunmap>
    80001346:	b7c5                	j	80001326 <uvmfree+0xe>

0000000080001348 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001348:	ce49                	beqz	a2,800013e2 <uvmcopy+0x9a>
{
    8000134a:	715d                	addi	sp,sp,-80
    8000134c:	e486                	sd	ra,72(sp)
    8000134e:	e0a2                	sd	s0,64(sp)
    80001350:	fc26                	sd	s1,56(sp)
    80001352:	f84a                	sd	s2,48(sp)
    80001354:	f44e                	sd	s3,40(sp)
    80001356:	f052                	sd	s4,32(sp)
    80001358:	ec56                	sd	s5,24(sp)
    8000135a:	e85a                	sd	s6,16(sp)
    8000135c:	e45e                	sd	s7,8(sp)
    8000135e:	0880                	addi	s0,sp,80
    80001360:	8aaa                	mv	s5,a0
    80001362:	8b2e                	mv	s6,a1
    80001364:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001366:	4481                	li	s1,0
    80001368:	a029                	j	80001372 <uvmcopy+0x2a>
    8000136a:	6785                	lui	a5,0x1
    8000136c:	94be                	add	s1,s1,a5
    8000136e:	0544fe63          	bgeu	s1,s4,800013ca <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80001372:	4601                	li	a2,0
    80001374:	85a6                	mv	a1,s1
    80001376:	8556                	mv	a0,s5
    80001378:	b45ff0ef          	jal	ra,80000ebc <walk>
    8000137c:	d57d                	beqz	a0,8000136a <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    8000137e:	6118                	ld	a4,0(a0)
    80001380:	00177793          	andi	a5,a4,1
    80001384:	d3fd                	beqz	a5,8000136a <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001386:	00a75593          	srli	a1,a4,0xa
    8000138a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000138e:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001392:	f0aff0ef          	jal	ra,80000a9c <kalloc>
    80001396:	89aa                	mv	s3,a0
    80001398:	c105                	beqz	a0,800013b8 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000139a:	6605                	lui	a2,0x1
    8000139c:	85de                	mv	a1,s7
    8000139e:	8ffff0ef          	jal	ra,80000c9c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800013a2:	874a                	mv	a4,s2
    800013a4:	86ce                	mv	a3,s3
    800013a6:	6605                	lui	a2,0x1
    800013a8:	85a6                	mv	a1,s1
    800013aa:	855a                	mv	a0,s6
    800013ac:	be9ff0ef          	jal	ra,80000f94 <mappages>
    800013b0:	dd4d                	beqz	a0,8000136a <uvmcopy+0x22>
      kfree(mem);
    800013b2:	854e                	mv	a0,s3
    800013b4:	e08ff0ef          	jal	ra,800009bc <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800013b8:	4685                	li	a3,1
    800013ba:	00c4d613          	srli	a2,s1,0xc
    800013be:	4581                	li	a1,0
    800013c0:	855a                	mv	a0,s6
    800013c2:	d9fff0ef          	jal	ra,80001160 <uvmunmap>
  return -1;
    800013c6:	557d                	li	a0,-1
    800013c8:	a011                	j	800013cc <uvmcopy+0x84>
  return 0;
    800013ca:	4501                	li	a0,0
}
    800013cc:	60a6                	ld	ra,72(sp)
    800013ce:	6406                	ld	s0,64(sp)
    800013d0:	74e2                	ld	s1,56(sp)
    800013d2:	7942                	ld	s2,48(sp)
    800013d4:	79a2                	ld	s3,40(sp)
    800013d6:	7a02                	ld	s4,32(sp)
    800013d8:	6ae2                	ld	s5,24(sp)
    800013da:	6b42                	ld	s6,16(sp)
    800013dc:	6ba2                	ld	s7,8(sp)
    800013de:	6161                	addi	sp,sp,80
    800013e0:	8082                	ret
  return 0;
    800013e2:	4501                	li	a0,0
}
    800013e4:	8082                	ret

00000000800013e6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800013e6:	1141                	addi	sp,sp,-16
    800013e8:	e406                	sd	ra,8(sp)
    800013ea:	e022                	sd	s0,0(sp)
    800013ec:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800013ee:	4601                	li	a2,0
    800013f0:	acdff0ef          	jal	ra,80000ebc <walk>
  if(pte == 0)
    800013f4:	c901                	beqz	a0,80001404 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800013f6:	611c                	ld	a5,0(a0)
    800013f8:	9bbd                	andi	a5,a5,-17
    800013fa:	e11c                	sd	a5,0(a0)
}
    800013fc:	60a2                	ld	ra,8(sp)
    800013fe:	6402                	ld	s0,0(sp)
    80001400:	0141                	addi	sp,sp,16
    80001402:	8082                	ret
    panic("uvmclear");
    80001404:	00006517          	auipc	a0,0x6
    80001408:	d5c50513          	addi	a0,a0,-676 # 80007160 <digits+0x128>
    8000140c:	b7eff0ef          	jal	ra,8000078a <panic>

0000000080001410 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001410:	c2d5                	beqz	a3,800014b4 <copyinstr+0xa4>
{
    80001412:	715d                	addi	sp,sp,-80
    80001414:	e486                	sd	ra,72(sp)
    80001416:	e0a2                	sd	s0,64(sp)
    80001418:	fc26                	sd	s1,56(sp)
    8000141a:	f84a                	sd	s2,48(sp)
    8000141c:	f44e                	sd	s3,40(sp)
    8000141e:	f052                	sd	s4,32(sp)
    80001420:	ec56                	sd	s5,24(sp)
    80001422:	e85a                	sd	s6,16(sp)
    80001424:	e45e                	sd	s7,8(sp)
    80001426:	0880                	addi	s0,sp,80
    80001428:	8a2a                	mv	s4,a0
    8000142a:	8b2e                	mv	s6,a1
    8000142c:	8bb2                	mv	s7,a2
    8000142e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001430:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001432:	6985                	lui	s3,0x1
    80001434:	a035                	j	80001460 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001436:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000143a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000143c:	0017b793          	seqz	a5,a5
    80001440:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
    srcva = va0 + PGSIZE;
    8000145a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000145e:	c4b9                	beqz	s1,800014ac <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80001460:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001464:	85ca                	mv	a1,s2
    80001466:	8552                	mv	a0,s4
    80001468:	aefff0ef          	jal	ra,80000f56 <walkaddr>
    if(pa0 == 0)
    8000146c:	c131                	beqz	a0,800014b0 <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    8000146e:	41790833          	sub	a6,s2,s7
    80001472:	984e                	add	a6,a6,s3
    if(n > max)
    80001474:	0104f363          	bgeu	s1,a6,8000147a <copyinstr+0x6a>
    80001478:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000147a:	955e                	add	a0,a0,s7
    8000147c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001480:	fc080de3          	beqz	a6,8000145a <copyinstr+0x4a>
    80001484:	985a                	add	a6,a6,s6
    80001486:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001488:	41650633          	sub	a2,a0,s6
    8000148c:	14fd                	addi	s1,s1,-1
    8000148e:	9b26                	add	s6,s6,s1
    80001490:	00f60733          	add	a4,a2,a5
    80001494:	00074703          	lbu	a4,0(a4)
    80001498:	df59                	beqz	a4,80001436 <copyinstr+0x26>
        *dst = *p;
    8000149a:	00e78023          	sb	a4,0(a5)
      --max;
    8000149e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800014a2:	0785                	addi	a5,a5,1
    while(n > 0){
    800014a4:	ff0796e3          	bne	a5,a6,80001490 <copyinstr+0x80>
      dst++;
    800014a8:	8b42                	mv	s6,a6
    800014aa:	bf45                	j	8000145a <copyinstr+0x4a>
    800014ac:	4781                	li	a5,0
    800014ae:	b779                	j	8000143c <copyinstr+0x2c>
      return -1;
    800014b0:	557d                	li	a0,-1
    800014b2:	bf49                	j	80001444 <copyinstr+0x34>
  int got_null = 0;
    800014b4:	4781                	li	a5,0
  if(got_null){
    800014b6:	0017b793          	seqz	a5,a5
    800014ba:	40f00533          	neg	a0,a5
}
    800014be:	8082                	ret

00000000800014c0 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014c0:	1141                	addi	sp,sp,-16
    800014c2:	e406                	sd	ra,8(sp)
    800014c4:	e022                	sd	s0,0(sp)
    800014c6:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014c8:	4601                	li	a2,0
    800014ca:	9f3ff0ef          	jal	ra,80000ebc <walk>
  if (pte == 0) {
    800014ce:	c519                	beqz	a0,800014dc <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800014d0:	6108                	ld	a0,0(a0)
    return 0;
    800014d2:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800014d4:	60a2                	ld	ra,8(sp)
    800014d6:	6402                	ld	s0,0(sp)
    800014d8:	0141                	addi	sp,sp,16
    800014da:	8082                	ret
    return 0;
    800014dc:	4501                	li	a0,0
    800014de:	bfdd                	j	800014d4 <ismapped+0x14>

00000000800014e0 <vmfault>:
{
    800014e0:	7179                	addi	sp,sp,-48
    800014e2:	f406                	sd	ra,40(sp)
    800014e4:	f022                	sd	s0,32(sp)
    800014e6:	ec26                	sd	s1,24(sp)
    800014e8:	e84a                	sd	s2,16(sp)
    800014ea:	e44e                	sd	s3,8(sp)
    800014ec:	e052                	sd	s4,0(sp)
    800014ee:	1800                	addi	s0,sp,48
    800014f0:	89aa                	mv	s3,a0
    800014f2:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    800014f4:	318000ef          	jal	ra,8000180c <myproc>
  if (va >= p->sz)
    800014f8:	653c                	ld	a5,72(a0)
    800014fa:	00f4ec63          	bltu	s1,a5,80001512 <vmfault+0x32>
    return 0;
    800014fe:	4981                	li	s3,0
}
    80001500:	854e                	mv	a0,s3
    80001502:	70a2                	ld	ra,40(sp)
    80001504:	7402                	ld	s0,32(sp)
    80001506:	64e2                	ld	s1,24(sp)
    80001508:	6942                	ld	s2,16(sp)
    8000150a:	69a2                	ld	s3,8(sp)
    8000150c:	6a02                	ld	s4,0(sp)
    8000150e:	6145                	addi	sp,sp,48
    80001510:	8082                	ret
    80001512:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001514:	75fd                	lui	a1,0xfffff
    80001516:	8ced                	and	s1,s1,a1
  if(ismapped(pagetable, va)) {
    80001518:	85a6                	mv	a1,s1
    8000151a:	854e                	mv	a0,s3
    8000151c:	fa5ff0ef          	jal	ra,800014c0 <ismapped>
    return 0;
    80001520:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001522:	fd79                	bnez	a0,80001500 <vmfault+0x20>
  mem = (uint64) kalloc();
    80001524:	d78ff0ef          	jal	ra,80000a9c <kalloc>
    80001528:	8a2a                	mv	s4,a0
  if(mem == 0)
    8000152a:	d979                	beqz	a0,80001500 <vmfault+0x20>
  mem = (uint64) kalloc();
    8000152c:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    8000152e:	6605                	lui	a2,0x1
    80001530:	4581                	li	a1,0
    80001532:	f0eff0ef          	jal	ra,80000c40 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001536:	4759                	li	a4,22
    80001538:	86d2                	mv	a3,s4
    8000153a:	6605                	lui	a2,0x1
    8000153c:	85a6                	mv	a1,s1
    8000153e:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001542:	a53ff0ef          	jal	ra,80000f94 <mappages>
    80001546:	dd4d                	beqz	a0,80001500 <vmfault+0x20>
    kfree((void *)mem);
    80001548:	8552                	mv	a0,s4
    8000154a:	c72ff0ef          	jal	ra,800009bc <kfree>
    return 0;
    8000154e:	4981                	li	s3,0
    80001550:	bf45                	j	80001500 <vmfault+0x20>

0000000080001552 <copyout>:
  while(len > 0){
    80001552:	cec1                	beqz	a3,800015ea <copyout+0x98>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	e0ca                	sd	s2,64(sp)
    8000155e:	fc4e                	sd	s3,56(sp)
    80001560:	f852                	sd	s4,48(sp)
    80001562:	f456                	sd	s5,40(sp)
    80001564:	f05a                	sd	s6,32(sp)
    80001566:	ec5e                	sd	s7,24(sp)
    80001568:	e862                	sd	s8,16(sp)
    8000156a:	e466                	sd	s9,8(sp)
    8000156c:	e06a                	sd	s10,0(sp)
    8000156e:	1080                	addi	s0,sp,96
    80001570:	8c2a                	mv	s8,a0
    80001572:	8b2e                	mv	s6,a1
    80001574:	8bb2                	mv	s7,a2
    80001576:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001578:	74fd                	lui	s1,0xfffff
    8000157a:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000157c:	57fd                	li	a5,-1
    8000157e:	83e9                	srli	a5,a5,0x1a
    80001580:	0697e763          	bltu	a5,s1,800015ee <copyout+0x9c>
    80001584:	6d05                	lui	s10,0x1
    80001586:	8cbe                	mv	s9,a5
    80001588:	a015                	j	800015ac <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000158a:	409b0533          	sub	a0,s6,s1
    8000158e:	0009861b          	sext.w	a2,s3
    80001592:	85de                	mv	a1,s7
    80001594:	954a                	add	a0,a0,s2
    80001596:	f06ff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    8000159a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000159e:	9bce                	add	s7,s7,s3
  while(len > 0){
    800015a0:	040a0363          	beqz	s4,800015e6 <copyout+0x94>
    if(va0 >= MAXVA)
    800015a4:	055ce763          	bltu	s9,s5,800015f2 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    800015a8:	84d6                	mv	s1,s5
    dstva = va0 + PGSIZE;
    800015aa:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    800015ac:	85a6                	mv	a1,s1
    800015ae:	8562                	mv	a0,s8
    800015b0:	9a7ff0ef          	jal	ra,80000f56 <walkaddr>
    800015b4:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800015b6:	e901                	bnez	a0,800015c6 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800015b8:	4601                	li	a2,0
    800015ba:	85a6                	mv	a1,s1
    800015bc:	8562                	mv	a0,s8
    800015be:	f23ff0ef          	jal	ra,800014e0 <vmfault>
    800015c2:	892a                	mv	s2,a0
    800015c4:	c90d                	beqz	a0,800015f6 <copyout+0xa4>
    pte = walk(pagetable, va0, 0);
    800015c6:	4601                	li	a2,0
    800015c8:	85a6                	mv	a1,s1
    800015ca:	8562                	mv	a0,s8
    800015cc:	8f1ff0ef          	jal	ra,80000ebc <walk>
    if((*pte & PTE_W) == 0)
    800015d0:	611c                	ld	a5,0(a0)
    800015d2:	8b91                	andi	a5,a5,4
    800015d4:	c39d                	beqz	a5,800015fa <copyout+0xa8>
    n = PGSIZE - (dstva - va0);
    800015d6:	01a48ab3          	add	s5,s1,s10
    800015da:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    800015de:	fb3a76e3          	bgeu	s4,s3,8000158a <copyout+0x38>
    800015e2:	89d2                	mv	s3,s4
    800015e4:	b75d                	j	8000158a <copyout+0x38>
  return 0;
    800015e6:	4501                	li	a0,0
    800015e8:	a811                	j	800015fc <copyout+0xaa>
    800015ea:	4501                	li	a0,0
}
    800015ec:	8082                	ret
      return -1;
    800015ee:	557d                	li	a0,-1
    800015f0:	a031                	j	800015fc <copyout+0xaa>
    800015f2:	557d                	li	a0,-1
    800015f4:	a021                	j	800015fc <copyout+0xaa>
        return -1;
    800015f6:	557d                	li	a0,-1
    800015f8:	a011                	j	800015fc <copyout+0xaa>
      return -1;
    800015fa:	557d                	li	a0,-1
}
    800015fc:	60e6                	ld	ra,88(sp)
    800015fe:	6446                	ld	s0,80(sp)
    80001600:	64a6                	ld	s1,72(sp)
    80001602:	6906                	ld	s2,64(sp)
    80001604:	79e2                	ld	s3,56(sp)
    80001606:	7a42                	ld	s4,48(sp)
    80001608:	7aa2                	ld	s5,40(sp)
    8000160a:	7b02                	ld	s6,32(sp)
    8000160c:	6be2                	ld	s7,24(sp)
    8000160e:	6c42                	ld	s8,16(sp)
    80001610:	6ca2                	ld	s9,8(sp)
    80001612:	6d02                	ld	s10,0(sp)
    80001614:	6125                	addi	sp,sp,96
    80001616:	8082                	ret

0000000080001618 <copyin>:
  while(len > 0){
    80001618:	c6c9                	beqz	a3,800016a2 <copyin+0x8a>
{
    8000161a:	715d                	addi	sp,sp,-80
    8000161c:	e486                	sd	ra,72(sp)
    8000161e:	e0a2                	sd	s0,64(sp)
    80001620:	fc26                	sd	s1,56(sp)
    80001622:	f84a                	sd	s2,48(sp)
    80001624:	f44e                	sd	s3,40(sp)
    80001626:	f052                	sd	s4,32(sp)
    80001628:	ec56                	sd	s5,24(sp)
    8000162a:	e85a                	sd	s6,16(sp)
    8000162c:	e45e                	sd	s7,8(sp)
    8000162e:	e062                	sd	s8,0(sp)
    80001630:	0880                	addi	s0,sp,80
    80001632:	8baa                	mv	s7,a0
    80001634:	8aae                	mv	s5,a1
    80001636:	8932                	mv	s2,a2
    80001638:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    8000163a:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000163c:	6b05                	lui	s6,0x1
    8000163e:	a035                	j	8000166a <copyin+0x52>
    80001640:	412984b3          	sub	s1,s3,s2
    80001644:	94da                	add	s1,s1,s6
    if(n > len)
    80001646:	009a7363          	bgeu	s4,s1,8000164c <copyin+0x34>
    8000164a:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000164c:	413905b3          	sub	a1,s2,s3
    80001650:	0004861b          	sext.w	a2,s1
    80001654:	95aa                	add	a1,a1,a0
    80001656:	8556                	mv	a0,s5
    80001658:	e44ff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    8000165c:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001660:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001662:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001666:	020a0163          	beqz	s4,80001688 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    8000166a:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000166e:	85ce                	mv	a1,s3
    80001670:	855e                	mv	a0,s7
    80001672:	8e5ff0ef          	jal	ra,80000f56 <walkaddr>
    if(pa0 == 0) {
    80001676:	f569                	bnez	a0,80001640 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001678:	4601                	li	a2,0
    8000167a:	85ce                	mv	a1,s3
    8000167c:	855e                	mv	a0,s7
    8000167e:	e63ff0ef          	jal	ra,800014e0 <vmfault>
    80001682:	fd5d                	bnez	a0,80001640 <copyin+0x28>
        return -1;
    80001684:	557d                	li	a0,-1
    80001686:	a011                	j	8000168a <copyin+0x72>
  return 0;
    80001688:	4501                	li	a0,0
}
    8000168a:	60a6                	ld	ra,72(sp)
    8000168c:	6406                	ld	s0,64(sp)
    8000168e:	74e2                	ld	s1,56(sp)
    80001690:	7942                	ld	s2,48(sp)
    80001692:	79a2                	ld	s3,40(sp)
    80001694:	7a02                	ld	s4,32(sp)
    80001696:	6ae2                	ld	s5,24(sp)
    80001698:	6b42                	ld	s6,16(sp)
    8000169a:	6ba2                	ld	s7,8(sp)
    8000169c:	6c02                	ld	s8,0(sp)
    8000169e:	6161                	addi	sp,sp,80
    800016a0:	8082                	ret
  return 0;
    800016a2:	4501                	li	a0,0
}
    800016a4:	8082                	ret

00000000800016a6 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800016a6:	7139                	addi	sp,sp,-64
    800016a8:	fc06                	sd	ra,56(sp)
    800016aa:	f822                	sd	s0,48(sp)
    800016ac:	f426                	sd	s1,40(sp)
    800016ae:	f04a                	sd	s2,32(sp)
    800016b0:	ec4e                	sd	s3,24(sp)
    800016b2:	e852                	sd	s4,16(sp)
    800016b4:	e456                	sd	s5,8(sp)
    800016b6:	e05a                	sd	s6,0(sp)
    800016b8:	0080                	addi	s0,sp,64
    800016ba:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800016bc:	0000f497          	auipc	s1,0xf
    800016c0:	82c48493          	addi	s1,s1,-2004 # 8000fee8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800016c4:	8b26                	mv	s6,s1
    800016c6:	00006a97          	auipc	s5,0x6
    800016ca:	93aa8a93          	addi	s5,s5,-1734 # 80007000 <etext>
    800016ce:	04000937          	lui	s2,0x4000
    800016d2:	197d                	addi	s2,s2,-1
    800016d4:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800016d6:	00014a17          	auipc	s4,0x14
    800016da:	612a0a13          	addi	s4,s4,1554 # 80015ce8 <tickslock>
    char *pa = kalloc();
    800016de:	bbeff0ef          	jal	ra,80000a9c <kalloc>
    800016e2:	862a                	mv	a2,a0
    if(pa == 0)
    800016e4:	c121                	beqz	a0,80001724 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800016e6:	416485b3          	sub	a1,s1,s6
    800016ea:	858d                	srai	a1,a1,0x3
    800016ec:	000ab783          	ld	a5,0(s5)
    800016f0:	02f585b3          	mul	a1,a1,a5
    800016f4:	2585                	addiw	a1,a1,1
    800016f6:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800016fa:	4719                	li	a4,6
    800016fc:	6685                	lui	a3,0x1
    800016fe:	40b905b3          	sub	a1,s2,a1
    80001702:	854e                	mv	a0,s3
    80001704:	941ff0ef          	jal	ra,80001044 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001708:	17848493          	addi	s1,s1,376
    8000170c:	fd4499e3          	bne	s1,s4,800016de <proc_mapstacks+0x38>
  }
}
    80001710:	70e2                	ld	ra,56(sp)
    80001712:	7442                	ld	s0,48(sp)
    80001714:	74a2                	ld	s1,40(sp)
    80001716:	7902                	ld	s2,32(sp)
    80001718:	69e2                	ld	s3,24(sp)
    8000171a:	6a42                	ld	s4,16(sp)
    8000171c:	6aa2                	ld	s5,8(sp)
    8000171e:	6b02                	ld	s6,0(sp)
    80001720:	6121                	addi	sp,sp,64
    80001722:	8082                	ret
      panic("kalloc");
    80001724:	00006517          	auipc	a0,0x6
    80001728:	a4c50513          	addi	a0,a0,-1460 # 80007170 <digits+0x138>
    8000172c:	85eff0ef          	jal	ra,8000078a <panic>

0000000080001730 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001730:	7139                	addi	sp,sp,-64
    80001732:	fc06                	sd	ra,56(sp)
    80001734:	f822                	sd	s0,48(sp)
    80001736:	f426                	sd	s1,40(sp)
    80001738:	f04a                	sd	s2,32(sp)
    8000173a:	ec4e                	sd	s3,24(sp)
    8000173c:	e852                	sd	s4,16(sp)
    8000173e:	e456                	sd	s5,8(sp)
    80001740:	e05a                	sd	s6,0(sp)
    80001742:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001744:	00006597          	auipc	a1,0x6
    80001748:	a3458593          	addi	a1,a1,-1484 # 80007178 <digits+0x140>
    8000174c:	0000e517          	auipc	a0,0xe
    80001750:	36c50513          	addi	a0,a0,876 # 8000fab8 <pid_lock>
    80001754:	b98ff0ef          	jal	ra,80000aec <initlock>
  initlock(&wait_lock, "wait_lock");
    80001758:	00006597          	auipc	a1,0x6
    8000175c:	a2858593          	addi	a1,a1,-1496 # 80007180 <digits+0x148>
    80001760:	0000e517          	auipc	a0,0xe
    80001764:	37050513          	addi	a0,a0,880 # 8000fad0 <wait_lock>
    80001768:	b84ff0ef          	jal	ra,80000aec <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176c:	0000e497          	auipc	s1,0xe
    80001770:	77c48493          	addi	s1,s1,1916 # 8000fee8 <proc>
      initlock(&p->lock, "proc");
    80001774:	00006b17          	auipc	s6,0x6
    80001778:	a1cb0b13          	addi	s6,s6,-1508 # 80007190 <digits+0x158>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000177c:	8aa6                	mv	s5,s1
    8000177e:	00006a17          	auipc	s4,0x6
    80001782:	882a0a13          	addi	s4,s4,-1918 # 80007000 <etext>
    80001786:	04000937          	lui	s2,0x4000
    8000178a:	197d                	addi	s2,s2,-1
    8000178c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000178e:	00014997          	auipc	s3,0x14
    80001792:	55a98993          	addi	s3,s3,1370 # 80015ce8 <tickslock>
      initlock(&p->lock, "proc");
    80001796:	85da                	mv	a1,s6
    80001798:	8526                	mv	a0,s1
    8000179a:	b52ff0ef          	jal	ra,80000aec <initlock>
      p->state = UNUSED;
    8000179e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800017a2:	415487b3          	sub	a5,s1,s5
    800017a6:	878d                	srai	a5,a5,0x3
    800017a8:	000a3703          	ld	a4,0(s4)
    800017ac:	02e787b3          	mul	a5,a5,a4
    800017b0:	2785                	addiw	a5,a5,1
    800017b2:	00d7979b          	slliw	a5,a5,0xd
    800017b6:	40f907b3          	sub	a5,s2,a5
    800017ba:	e0bc                	sd	a5,64(s1)
      p->child_count=0;
    800017bc:	1604a423          	sw	zero,360(s1)
      p->xtrace=0;
    800017c0:	1604b823          	sd	zero,368(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c4:	17848493          	addi	s1,s1,376
    800017c8:	fd3497e3          	bne	s1,s3,80001796 <procinit+0x66>
  }
}
    800017cc:	70e2                	ld	ra,56(sp)
    800017ce:	7442                	ld	s0,48(sp)
    800017d0:	74a2                	ld	s1,40(sp)
    800017d2:	7902                	ld	s2,32(sp)
    800017d4:	69e2                	ld	s3,24(sp)
    800017d6:	6a42                	ld	s4,16(sp)
    800017d8:	6aa2                	ld	s5,8(sp)
    800017da:	6b02                	ld	s6,0(sp)
    800017dc:	6121                	addi	sp,sp,64
    800017de:	8082                	ret

00000000800017e0 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800017e0:	1141                	addi	sp,sp,-16
    800017e2:	e422                	sd	s0,8(sp)
    800017e4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800017e6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800017e8:	2501                	sext.w	a0,a0
    800017ea:	6422                	ld	s0,8(sp)
    800017ec:	0141                	addi	sp,sp,16
    800017ee:	8082                	ret

00000000800017f0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800017f0:	1141                	addi	sp,sp,-16
    800017f2:	e422                	sd	s0,8(sp)
    800017f4:	0800                	addi	s0,sp,16
    800017f6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800017f8:	2781                	sext.w	a5,a5
    800017fa:	079e                	slli	a5,a5,0x7
  return c;
}
    800017fc:	0000e517          	auipc	a0,0xe
    80001800:	2ec50513          	addi	a0,a0,748 # 8000fae8 <cpus>
    80001804:	953e                	add	a0,a0,a5
    80001806:	6422                	ld	s0,8(sp)
    80001808:	0141                	addi	sp,sp,16
    8000180a:	8082                	ret

000000008000180c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    8000180c:	1101                	addi	sp,sp,-32
    8000180e:	ec06                	sd	ra,24(sp)
    80001810:	e822                	sd	s0,16(sp)
    80001812:	e426                	sd	s1,8(sp)
    80001814:	1000                	addi	s0,sp,32
  push_off();
    80001816:	b16ff0ef          	jal	ra,80000b2c <push_off>
    8000181a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000181c:	2781                	sext.w	a5,a5
    8000181e:	079e                	slli	a5,a5,0x7
    80001820:	0000e717          	auipc	a4,0xe
    80001824:	29870713          	addi	a4,a4,664 # 8000fab8 <pid_lock>
    80001828:	97ba                	add	a5,a5,a4
    8000182a:	7b84                	ld	s1,48(a5)
  pop_off();
    8000182c:	b84ff0ef          	jal	ra,80000bb0 <pop_off>
  return p;
}
    80001830:	8526                	mv	a0,s1
    80001832:	60e2                	ld	ra,24(sp)
    80001834:	6442                	ld	s0,16(sp)
    80001836:	64a2                	ld	s1,8(sp)
    80001838:	6105                	addi	sp,sp,32
    8000183a:	8082                	ret

000000008000183c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000183c:	7179                	addi	sp,sp,-48
    8000183e:	f406                	sd	ra,40(sp)
    80001840:	f022                	sd	s0,32(sp)
    80001842:	ec26                	sd	s1,24(sp)
    80001844:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001846:	fc7ff0ef          	jal	ra,8000180c <myproc>
    8000184a:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000184c:	bb8ff0ef          	jal	ra,80000c04 <release>

  if (first) {
    80001850:	00006797          	auipc	a5,0x6
    80001854:	1307a783          	lw	a5,304(a5) # 80007980 <first.1>
    80001858:	cf8d                	beqz	a5,80001892 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000185a:	4505                	li	a0,1
    8000185c:	669010ef          	jal	ra,800036c4 <fsinit>

    first = 0;
    80001860:	00006797          	auipc	a5,0x6
    80001864:	1207a023          	sw	zero,288(a5) # 80007980 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001868:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    8000186c:	00006517          	auipc	a0,0x6
    80001870:	92c50513          	addi	a0,a0,-1748 # 80007198 <digits+0x160>
    80001874:	fca43823          	sd	a0,-48(s0)
    80001878:	fc043c23          	sd	zero,-40(s0)
    8000187c:	fd040593          	addi	a1,s0,-48
    80001880:	6ed020ef          	jal	ra,8000476c <kexec>
    80001884:	6cbc                	ld	a5,88(s1)
    80001886:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001888:	6cbc                	ld	a5,88(s1)
    8000188a:	7bb8                	ld	a4,112(a5)
    8000188c:	57fd                	li	a5,-1
    8000188e:	02f70d63          	beq	a4,a5,800018c8 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001892:	31b000ef          	jal	ra,800023ac <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001896:	68a8                	ld	a0,80(s1)
    80001898:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000189a:	04000737          	lui	a4,0x4000
    8000189e:	00004797          	auipc	a5,0x4
    800018a2:	7fe78793          	addi	a5,a5,2046 # 8000609c <userret>
    800018a6:	00004697          	auipc	a3,0x4
    800018aa:	75a68693          	addi	a3,a3,1882 # 80006000 <_trampoline>
    800018ae:	8f95                	sub	a5,a5,a3
    800018b0:	177d                	addi	a4,a4,-1
    800018b2:	0732                	slli	a4,a4,0xc
    800018b4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800018b6:	577d                	li	a4,-1
    800018b8:	177e                	slli	a4,a4,0x3f
    800018ba:	8d59                	or	a0,a0,a4
    800018bc:	9782                	jalr	a5
}
    800018be:	70a2                	ld	ra,40(sp)
    800018c0:	7402                	ld	s0,32(sp)
    800018c2:	64e2                	ld	s1,24(sp)
    800018c4:	6145                	addi	sp,sp,48
    800018c6:	8082                	ret
      panic("exec");
    800018c8:	00006517          	auipc	a0,0x6
    800018cc:	8d850513          	addi	a0,a0,-1832 # 800071a0 <digits+0x168>
    800018d0:	ebbfe0ef          	jal	ra,8000078a <panic>

00000000800018d4 <allocpid>:
{
    800018d4:	1101                	addi	sp,sp,-32
    800018d6:	ec06                	sd	ra,24(sp)
    800018d8:	e822                	sd	s0,16(sp)
    800018da:	e426                	sd	s1,8(sp)
    800018dc:	e04a                	sd	s2,0(sp)
    800018de:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018e0:	0000e917          	auipc	s2,0xe
    800018e4:	1d890913          	addi	s2,s2,472 # 8000fab8 <pid_lock>
    800018e8:	854a                	mv	a0,s2
    800018ea:	a82ff0ef          	jal	ra,80000b6c <acquire>
  pid = nextpid;
    800018ee:	00006797          	auipc	a5,0x6
    800018f2:	09678793          	addi	a5,a5,150 # 80007984 <nextpid>
    800018f6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018f8:	0014871b          	addiw	a4,s1,1
    800018fc:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018fe:	854a                	mv	a0,s2
    80001900:	b04ff0ef          	jal	ra,80000c04 <release>
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6902                	ld	s2,0(sp)
    8000190e:	6105                	addi	sp,sp,32
    80001910:	8082                	ret

0000000080001912 <proc_pagetable>:
{
    80001912:	1101                	addi	sp,sp,-32
    80001914:	ec06                	sd	ra,24(sp)
    80001916:	e822                	sd	s0,16(sp)
    80001918:	e426                	sd	s1,8(sp)
    8000191a:	e04a                	sd	s2,0(sp)
    8000191c:	1000                	addi	s0,sp,32
    8000191e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001920:	81bff0ef          	jal	ra,8000113a <uvmcreate>
    80001924:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001926:	cd05                	beqz	a0,8000195e <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001928:	4729                	li	a4,10
    8000192a:	00004697          	auipc	a3,0x4
    8000192e:	6d668693          	addi	a3,a3,1750 # 80006000 <_trampoline>
    80001932:	6605                	lui	a2,0x1
    80001934:	040005b7          	lui	a1,0x4000
    80001938:	15fd                	addi	a1,a1,-1
    8000193a:	05b2                	slli	a1,a1,0xc
    8000193c:	e58ff0ef          	jal	ra,80000f94 <mappages>
    80001940:	02054663          	bltz	a0,8000196c <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001944:	4719                	li	a4,6
    80001946:	05893683          	ld	a3,88(s2)
    8000194a:	6605                	lui	a2,0x1
    8000194c:	020005b7          	lui	a1,0x2000
    80001950:	15fd                	addi	a1,a1,-1
    80001952:	05b6                	slli	a1,a1,0xd
    80001954:	8526                	mv	a0,s1
    80001956:	e3eff0ef          	jal	ra,80000f94 <mappages>
    8000195a:	00054f63          	bltz	a0,80001978 <proc_pagetable+0x66>
}
    8000195e:	8526                	mv	a0,s1
    80001960:	60e2                	ld	ra,24(sp)
    80001962:	6442                	ld	s0,16(sp)
    80001964:	64a2                	ld	s1,8(sp)
    80001966:	6902                	ld	s2,0(sp)
    80001968:	6105                	addi	sp,sp,32
    8000196a:	8082                	ret
    uvmfree(pagetable, 0);
    8000196c:	4581                	li	a1,0
    8000196e:	8526                	mv	a0,s1
    80001970:	9a9ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001974:	4481                	li	s1,0
    80001976:	b7e5                	j	8000195e <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001978:	4681                	li	a3,0
    8000197a:	4605                	li	a2,1
    8000197c:	040005b7          	lui	a1,0x4000
    80001980:	15fd                	addi	a1,a1,-1
    80001982:	05b2                	slli	a1,a1,0xc
    80001984:	8526                	mv	a0,s1
    80001986:	fdaff0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    8000198a:	4581                	li	a1,0
    8000198c:	8526                	mv	a0,s1
    8000198e:	98bff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001992:	4481                	li	s1,0
    80001994:	b7e9                	j	8000195e <proc_pagetable+0x4c>

0000000080001996 <proc_freepagetable>:
{
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	e04a                	sd	s2,0(sp)
    800019a0:	1000                	addi	s0,sp,32
    800019a2:	84aa                	mv	s1,a0
    800019a4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019a6:	4681                	li	a3,0
    800019a8:	4605                	li	a2,1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	faeff0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800019b6:	4681                	li	a3,0
    800019b8:	4605                	li	a2,1
    800019ba:	020005b7          	lui	a1,0x2000
    800019be:	15fd                	addi	a1,a1,-1
    800019c0:	05b6                	slli	a1,a1,0xd
    800019c2:	8526                	mv	a0,s1
    800019c4:	f9cff0ef          	jal	ra,80001160 <uvmunmap>
  uvmfree(pagetable, sz);
    800019c8:	85ca                	mv	a1,s2
    800019ca:	8526                	mv	a0,s1
    800019cc:	94dff0ef          	jal	ra,80001318 <uvmfree>
}
    800019d0:	60e2                	ld	ra,24(sp)
    800019d2:	6442                	ld	s0,16(sp)
    800019d4:	64a2                	ld	s1,8(sp)
    800019d6:	6902                	ld	s2,0(sp)
    800019d8:	6105                	addi	sp,sp,32
    800019da:	8082                	ret

00000000800019dc <freeproc>:
{
    800019dc:	1101                	addi	sp,sp,-32
    800019de:	ec06                	sd	ra,24(sp)
    800019e0:	e822                	sd	s0,16(sp)
    800019e2:	e426                	sd	s1,8(sp)
    800019e4:	1000                	addi	s0,sp,32
    800019e6:	84aa                	mv	s1,a0
  if(p->trapframe)
    800019e8:	6d28                	ld	a0,88(a0)
    800019ea:	c119                	beqz	a0,800019f0 <freeproc+0x14>
    kfree((void*)p->trapframe);
    800019ec:	fd1fe0ef          	jal	ra,800009bc <kfree>
  p->trapframe = 0;
    800019f0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800019f4:	68a8                	ld	a0,80(s1)
    800019f6:	c501                	beqz	a0,800019fe <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800019f8:	64ac                	ld	a1,72(s1)
    800019fa:	f9dff0ef          	jal	ra,80001996 <proc_freepagetable>
  p->pagetable = 0;
    800019fe:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a02:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a06:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a0a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a0e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a12:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a16:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a1a:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a1e:	0004ac23          	sw	zero,24(s1)
  p->child_count=0;
    80001a22:	1604a423          	sw	zero,360(s1)
  if(p->xtrace){
    80001a26:	1704b503          	ld	a0,368(s1)
    80001a2a:	c509                	beqz	a0,80001a34 <freeproc+0x58>
    kfree((void*)p->xtrace);
    80001a2c:	f91fe0ef          	jal	ra,800009bc <kfree>
    p->xtrace=0;
    80001a30:	1604b823          	sd	zero,368(s1)
}
    80001a34:	60e2                	ld	ra,24(sp)
    80001a36:	6442                	ld	s0,16(sp)
    80001a38:	64a2                	ld	s1,8(sp)
    80001a3a:	6105                	addi	sp,sp,32
    80001a3c:	8082                	ret

0000000080001a3e <allocproc>:
{
    80001a3e:	1101                	addi	sp,sp,-32
    80001a40:	ec06                	sd	ra,24(sp)
    80001a42:	e822                	sd	s0,16(sp)
    80001a44:	e426                	sd	s1,8(sp)
    80001a46:	e04a                	sd	s2,0(sp)
    80001a48:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a4a:	0000e497          	auipc	s1,0xe
    80001a4e:	49e48493          	addi	s1,s1,1182 # 8000fee8 <proc>
    80001a52:	00014917          	auipc	s2,0x14
    80001a56:	29690913          	addi	s2,s2,662 # 80015ce8 <tickslock>
    acquire(&p->lock);
    80001a5a:	8526                	mv	a0,s1
    80001a5c:	910ff0ef          	jal	ra,80000b6c <acquire>
    if(p->state == UNUSED) {
    80001a60:	4c9c                	lw	a5,24(s1)
    80001a62:	cb91                	beqz	a5,80001a76 <allocproc+0x38>
      release(&p->lock);
    80001a64:	8526                	mv	a0,s1
    80001a66:	99eff0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a6a:	17848493          	addi	s1,s1,376
    80001a6e:	ff2496e3          	bne	s1,s2,80001a5a <allocproc+0x1c>
  return 0;
    80001a72:	4481                	li	s1,0
    80001a74:	a089                	j	80001ab6 <allocproc+0x78>
  p->pid = allocpid();
    80001a76:	e5fff0ef          	jal	ra,800018d4 <allocpid>
    80001a7a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001a7c:	4785                	li	a5,1
    80001a7e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001a80:	81cff0ef          	jal	ra,80000a9c <kalloc>
    80001a84:	892a                	mv	s2,a0
    80001a86:	eca8                	sd	a0,88(s1)
    80001a88:	cd15                	beqz	a0,80001ac4 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001a8a:	8526                	mv	a0,s1
    80001a8c:	e87ff0ef          	jal	ra,80001912 <proc_pagetable>
    80001a90:	892a                	mv	s2,a0
    80001a92:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001a94:	c121                	beqz	a0,80001ad4 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001a96:	07000613          	li	a2,112
    80001a9a:	4581                	li	a1,0
    80001a9c:	06048513          	addi	a0,s1,96
    80001aa0:	9a0ff0ef          	jal	ra,80000c40 <memset>
  p->context.ra = (uint64)forkret;
    80001aa4:	00000797          	auipc	a5,0x0
    80001aa8:	d9878793          	addi	a5,a5,-616 # 8000183c <forkret>
    80001aac:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001aae:	60bc                	ld	a5,64(s1)
    80001ab0:	6705                	lui	a4,0x1
    80001ab2:	97ba                	add	a5,a5,a4
    80001ab4:	f4bc                	sd	a5,104(s1)
}
    80001ab6:	8526                	mv	a0,s1
    80001ab8:	60e2                	ld	ra,24(sp)
    80001aba:	6442                	ld	s0,16(sp)
    80001abc:	64a2                	ld	s1,8(sp)
    80001abe:	6902                	ld	s2,0(sp)
    80001ac0:	6105                	addi	sp,sp,32
    80001ac2:	8082                	ret
    freeproc(p);
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	f17ff0ef          	jal	ra,800019dc <freeproc>
    release(&p->lock);
    80001aca:	8526                	mv	a0,s1
    80001acc:	938ff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001ad0:	84ca                	mv	s1,s2
    80001ad2:	b7d5                	j	80001ab6 <allocproc+0x78>
    freeproc(p);
    80001ad4:	8526                	mv	a0,s1
    80001ad6:	f07ff0ef          	jal	ra,800019dc <freeproc>
    release(&p->lock);
    80001ada:	8526                	mv	a0,s1
    80001adc:	928ff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001ae0:	84ca                	mv	s1,s2
    80001ae2:	bfd1                	j	80001ab6 <allocproc+0x78>

0000000080001ae4 <userinit>:
{
    80001ae4:	1101                	addi	sp,sp,-32
    80001ae6:	ec06                	sd	ra,24(sp)
    80001ae8:	e822                	sd	s0,16(sp)
    80001aea:	e426                	sd	s1,8(sp)
    80001aec:	1000                	addi	s0,sp,32
  p = allocproc();
    80001aee:	f51ff0ef          	jal	ra,80001a3e <allocproc>
    80001af2:	84aa                	mv	s1,a0
  initproc = p;
    80001af4:	00006797          	auipc	a5,0x6
    80001af8:	eaa7be23          	sd	a0,-324(a5) # 800079b0 <initproc>
  p->cwd = namei("/");
    80001afc:	00005517          	auipc	a0,0x5
    80001b00:	6ac50513          	addi	a0,a0,1708 # 800071a8 <digits+0x170>
    80001b04:	0be020ef          	jal	ra,80003bc2 <namei>
    80001b08:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b0c:	478d                	li	a5,3
    80001b0e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b10:	8526                	mv	a0,s1
    80001b12:	8f2ff0ef          	jal	ra,80000c04 <release>
}
    80001b16:	60e2                	ld	ra,24(sp)
    80001b18:	6442                	ld	s0,16(sp)
    80001b1a:	64a2                	ld	s1,8(sp)
    80001b1c:	6105                	addi	sp,sp,32
    80001b1e:	8082                	ret

0000000080001b20 <growproc>:
{
    80001b20:	1101                	addi	sp,sp,-32
    80001b22:	ec06                	sd	ra,24(sp)
    80001b24:	e822                	sd	s0,16(sp)
    80001b26:	e426                	sd	s1,8(sp)
    80001b28:	e04a                	sd	s2,0(sp)
    80001b2a:	1000                	addi	s0,sp,32
    80001b2c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b2e:	cdfff0ef          	jal	ra,8000180c <myproc>
    80001b32:	892a                	mv	s2,a0
  sz = p->sz;
    80001b34:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001b36:	02905963          	blez	s1,80001b68 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001b3a:	00b48633          	add	a2,s1,a1
    80001b3e:	020007b7          	lui	a5,0x2000
    80001b42:	17fd                	addi	a5,a5,-1
    80001b44:	07b6                	slli	a5,a5,0xd
    80001b46:	02c7ea63          	bltu	a5,a2,80001b7a <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001b4a:	4691                	li	a3,4
    80001b4c:	6928                	ld	a0,80(a0)
    80001b4e:	ed2ff0ef          	jal	ra,80001220 <uvmalloc>
    80001b52:	85aa                	mv	a1,a0
    80001b54:	c50d                	beqz	a0,80001b7e <growproc+0x5e>
  p->sz = sz;
    80001b56:	04b93423          	sd	a1,72(s2)
  return 0;
    80001b5a:	4501                	li	a0,0
}
    80001b5c:	60e2                	ld	ra,24(sp)
    80001b5e:	6442                	ld	s0,16(sp)
    80001b60:	64a2                	ld	s1,8(sp)
    80001b62:	6902                	ld	s2,0(sp)
    80001b64:	6105                	addi	sp,sp,32
    80001b66:	8082                	ret
  } else if(n < 0){
    80001b68:	fe04d7e3          	bgez	s1,80001b56 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b6c:	00b48633          	add	a2,s1,a1
    80001b70:	6928                	ld	a0,80(a0)
    80001b72:	e6aff0ef          	jal	ra,800011dc <uvmdealloc>
    80001b76:	85aa                	mv	a1,a0
    80001b78:	bff9                	j	80001b56 <growproc+0x36>
      return -1;
    80001b7a:	557d                	li	a0,-1
    80001b7c:	b7c5                	j	80001b5c <growproc+0x3c>
      return -1;
    80001b7e:	557d                	li	a0,-1
    80001b80:	bff1                	j	80001b5c <growproc+0x3c>

0000000080001b82 <kfork>:
{
    80001b82:	7139                	addi	sp,sp,-64
    80001b84:	fc06                	sd	ra,56(sp)
    80001b86:	f822                	sd	s0,48(sp)
    80001b88:	f426                	sd	s1,40(sp)
    80001b8a:	f04a                	sd	s2,32(sp)
    80001b8c:	ec4e                	sd	s3,24(sp)
    80001b8e:	e852                	sd	s4,16(sp)
    80001b90:	e456                	sd	s5,8(sp)
    80001b92:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001b94:	c79ff0ef          	jal	ra,8000180c <myproc>
    80001b98:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001b9a:	ea5ff0ef          	jal	ra,80001a3e <allocproc>
    80001b9e:	0e050863          	beqz	a0,80001c8e <kfork+0x10c>
    80001ba2:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001ba4:	048ab603          	ld	a2,72(s5)
    80001ba8:	692c                	ld	a1,80(a0)
    80001baa:	050ab503          	ld	a0,80(s5)
    80001bae:	f9aff0ef          	jal	ra,80001348 <uvmcopy>
    80001bb2:	04054863          	bltz	a0,80001c02 <kfork+0x80>
  np->sz = p->sz;
    80001bb6:	048ab783          	ld	a5,72(s5)
    80001bba:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001bbe:	058ab683          	ld	a3,88(s5)
    80001bc2:	87b6                	mv	a5,a3
    80001bc4:	0589b703          	ld	a4,88(s3)
    80001bc8:	12068693          	addi	a3,a3,288
    80001bcc:	0007b803          	ld	a6,0(a5) # 2000000 <_entry-0x7e000000>
    80001bd0:	6788                	ld	a0,8(a5)
    80001bd2:	6b8c                	ld	a1,16(a5)
    80001bd4:	6f90                	ld	a2,24(a5)
    80001bd6:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001bda:	e708                	sd	a0,8(a4)
    80001bdc:	eb0c                	sd	a1,16(a4)
    80001bde:	ef10                	sd	a2,24(a4)
    80001be0:	02078793          	addi	a5,a5,32
    80001be4:	02070713          	addi	a4,a4,32
    80001be8:	fed792e3          	bne	a5,a3,80001bcc <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001bec:	0589b783          	ld	a5,88(s3)
    80001bf0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001bf4:	0d0a8493          	addi	s1,s5,208
    80001bf8:	0d098913          	addi	s2,s3,208
    80001bfc:	150a8a13          	addi	s4,s5,336
    80001c00:	a829                	j	80001c1a <kfork+0x98>
    freeproc(np);
    80001c02:	854e                	mv	a0,s3
    80001c04:	dd9ff0ef          	jal	ra,800019dc <freeproc>
    release(&np->lock);
    80001c08:	854e                	mv	a0,s3
    80001c0a:	ffbfe0ef          	jal	ra,80000c04 <release>
    return -1;
    80001c0e:	597d                	li	s2,-1
    80001c10:	a0ad                	j	80001c7a <kfork+0xf8>
  for(i = 0; i < NOFILE; i++)
    80001c12:	04a1                	addi	s1,s1,8
    80001c14:	0921                	addi	s2,s2,8
    80001c16:	01448963          	beq	s1,s4,80001c28 <kfork+0xa6>
    if(p->ofile[i])
    80001c1a:	6088                	ld	a0,0(s1)
    80001c1c:	d97d                	beqz	a0,80001c12 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c1e:	55c020ef          	jal	ra,8000417a <filedup>
    80001c22:	00a93023          	sd	a0,0(s2)
    80001c26:	b7f5                	j	80001c12 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001c28:	150ab503          	ld	a0,336(s5)
    80001c2c:	772010ef          	jal	ra,8000339e <idup>
    80001c30:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c34:	4641                	li	a2,16
    80001c36:	158a8593          	addi	a1,s5,344
    80001c3a:	15898513          	addi	a0,s3,344
    80001c3e:	948ff0ef          	jal	ra,80000d86 <safestrcpy>
  pid = np->pid;
    80001c42:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001c46:	854e                	mv	a0,s3
    80001c48:	fbdfe0ef          	jal	ra,80000c04 <release>
  acquire(&wait_lock);
    80001c4c:	0000e497          	auipc	s1,0xe
    80001c50:	e8448493          	addi	s1,s1,-380 # 8000fad0 <wait_lock>
    80001c54:	8526                	mv	a0,s1
    80001c56:	f17fe0ef          	jal	ra,80000b6c <acquire>
  np->parent = p;
    80001c5a:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	fa5fe0ef          	jal	ra,80000c04 <release>
  acquire(&np->lock);
    80001c64:	854e                	mv	a0,s3
    80001c66:	f07fe0ef          	jal	ra,80000b6c <acquire>
  np->state = RUNNABLE;
    80001c6a:	478d                	li	a5,3
    80001c6c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001c70:	854e                	mv	a0,s3
    80001c72:	f93fe0ef          	jal	ra,80000c04 <release>
  np->xtrace=0;
    80001c76:	1609b823          	sd	zero,368(s3)
}
    80001c7a:	854a                	mv	a0,s2
    80001c7c:	70e2                	ld	ra,56(sp)
    80001c7e:	7442                	ld	s0,48(sp)
    80001c80:	74a2                	ld	s1,40(sp)
    80001c82:	7902                	ld	s2,32(sp)
    80001c84:	69e2                	ld	s3,24(sp)
    80001c86:	6a42                	ld	s4,16(sp)
    80001c88:	6aa2                	ld	s5,8(sp)
    80001c8a:	6121                	addi	sp,sp,64
    80001c8c:	8082                	ret
    return -1;
    80001c8e:	597d                	li	s2,-1
    80001c90:	b7ed                	j	80001c7a <kfork+0xf8>

0000000080001c92 <scheduler>:
{
    80001c92:	715d                	addi	sp,sp,-80
    80001c94:	e486                	sd	ra,72(sp)
    80001c96:	e0a2                	sd	s0,64(sp)
    80001c98:	fc26                	sd	s1,56(sp)
    80001c9a:	f84a                	sd	s2,48(sp)
    80001c9c:	f44e                	sd	s3,40(sp)
    80001c9e:	f052                	sd	s4,32(sp)
    80001ca0:	ec56                	sd	s5,24(sp)
    80001ca2:	e85a                	sd	s6,16(sp)
    80001ca4:	e45e                	sd	s7,8(sp)
    80001ca6:	e062                	sd	s8,0(sp)
    80001ca8:	0880                	addi	s0,sp,80
    80001caa:	8792                	mv	a5,tp
  int id = r_tp();
    80001cac:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001cae:	00779b13          	slli	s6,a5,0x7
    80001cb2:	0000e717          	auipc	a4,0xe
    80001cb6:	e0670713          	addi	a4,a4,-506 # 8000fab8 <pid_lock>
    80001cba:	975a                	add	a4,a4,s6
    80001cbc:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001cc0:	0000e717          	auipc	a4,0xe
    80001cc4:	e3070713          	addi	a4,a4,-464 # 8000faf0 <cpus+0x8>
    80001cc8:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001cca:	4c11                	li	s8,4
        c->proc = p;
    80001ccc:	079e                	slli	a5,a5,0x7
    80001cce:	0000ea17          	auipc	s4,0xe
    80001cd2:	deaa0a13          	addi	s4,s4,-534 # 8000fab8 <pid_lock>
    80001cd6:	9a3e                	add	s4,s4,a5
        found = 1;
    80001cd8:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cda:	00014997          	auipc	s3,0x14
    80001cde:	00e98993          	addi	s3,s3,14 # 80015ce8 <tickslock>
    80001ce2:	a83d                	j	80001d20 <scheduler+0x8e>
      release(&p->lock);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	f1ffe0ef          	jal	ra,80000c04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cea:	17848493          	addi	s1,s1,376
    80001cee:	03348563          	beq	s1,s3,80001d18 <scheduler+0x86>
      acquire(&p->lock);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	e79fe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == RUNNABLE) {
    80001cf8:	4c9c                	lw	a5,24(s1)
    80001cfa:	ff2795e3          	bne	a5,s2,80001ce4 <scheduler+0x52>
        p->state = RUNNING;
    80001cfe:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d02:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d06:	06048593          	addi	a1,s1,96
    80001d0a:	855a                	mv	a0,s6
    80001d0c:	5fa000ef          	jal	ra,80002306 <swtch>
        c->proc = 0;
    80001d10:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d14:	8ade                	mv	s5,s7
    80001d16:	b7f9                	j	80001ce4 <scheduler+0x52>
    if(found == 0) {
    80001d18:	000a9463          	bnez	s5,80001d20 <scheduler+0x8e>
      asm volatile("wfi");
    80001d1c:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d20:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d24:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d28:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d2c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001d30:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d32:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001d36:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d38:	0000e497          	auipc	s1,0xe
    80001d3c:	1b048493          	addi	s1,s1,432 # 8000fee8 <proc>
      if(p->state == RUNNABLE) {
    80001d40:	490d                	li	s2,3
    80001d42:	bf45                	j	80001cf2 <scheduler+0x60>

0000000080001d44 <sched>:
{
    80001d44:	7179                	addi	sp,sp,-48
    80001d46:	f406                	sd	ra,40(sp)
    80001d48:	f022                	sd	s0,32(sp)
    80001d4a:	ec26                	sd	s1,24(sp)
    80001d4c:	e84a                	sd	s2,16(sp)
    80001d4e:	e44e                	sd	s3,8(sp)
    80001d50:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d52:	abbff0ef          	jal	ra,8000180c <myproc>
    80001d56:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001d58:	dabfe0ef          	jal	ra,80000b02 <holding>
    80001d5c:	c92d                	beqz	a0,80001dce <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d5e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001d60:	2781                	sext.w	a5,a5
    80001d62:	079e                	slli	a5,a5,0x7
    80001d64:	0000e717          	auipc	a4,0xe
    80001d68:	d5470713          	addi	a4,a4,-684 # 8000fab8 <pid_lock>
    80001d6c:	97ba                	add	a5,a5,a4
    80001d6e:	0a87a703          	lw	a4,168(a5)
    80001d72:	4785                	li	a5,1
    80001d74:	06f71363          	bne	a4,a5,80001dda <sched+0x96>
  if(p->state == RUNNING)
    80001d78:	4c98                	lw	a4,24(s1)
    80001d7a:	4791                	li	a5,4
    80001d7c:	06f70563          	beq	a4,a5,80001de6 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d80:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001d84:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001d86:	e7b5                	bnez	a5,80001df2 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d88:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001d8a:	0000e917          	auipc	s2,0xe
    80001d8e:	d2e90913          	addi	s2,s2,-722 # 8000fab8 <pid_lock>
    80001d92:	2781                	sext.w	a5,a5
    80001d94:	079e                	slli	a5,a5,0x7
    80001d96:	97ca                	add	a5,a5,s2
    80001d98:	0ac7a983          	lw	s3,172(a5)
    80001d9c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001d9e:	2781                	sext.w	a5,a5
    80001da0:	079e                	slli	a5,a5,0x7
    80001da2:	0000e597          	auipc	a1,0xe
    80001da6:	d4e58593          	addi	a1,a1,-690 # 8000faf0 <cpus+0x8>
    80001daa:	95be                	add	a1,a1,a5
    80001dac:	06048513          	addi	a0,s1,96
    80001db0:	556000ef          	jal	ra,80002306 <swtch>
    80001db4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001db6:	2781                	sext.w	a5,a5
    80001db8:	079e                	slli	a5,a5,0x7
    80001dba:	97ca                	add	a5,a5,s2
    80001dbc:	0b37a623          	sw	s3,172(a5)
}
    80001dc0:	70a2                	ld	ra,40(sp)
    80001dc2:	7402                	ld	s0,32(sp)
    80001dc4:	64e2                	ld	s1,24(sp)
    80001dc6:	6942                	ld	s2,16(sp)
    80001dc8:	69a2                	ld	s3,8(sp)
    80001dca:	6145                	addi	sp,sp,48
    80001dcc:	8082                	ret
    panic("sched p->lock");
    80001dce:	00005517          	auipc	a0,0x5
    80001dd2:	3e250513          	addi	a0,a0,994 # 800071b0 <digits+0x178>
    80001dd6:	9b5fe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    80001dda:	00005517          	auipc	a0,0x5
    80001dde:	3e650513          	addi	a0,a0,998 # 800071c0 <digits+0x188>
    80001de2:	9a9fe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    80001de6:	00005517          	auipc	a0,0x5
    80001dea:	3ea50513          	addi	a0,a0,1002 # 800071d0 <digits+0x198>
    80001dee:	99dfe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    80001df2:	00005517          	auipc	a0,0x5
    80001df6:	3ee50513          	addi	a0,a0,1006 # 800071e0 <digits+0x1a8>
    80001dfa:	991fe0ef          	jal	ra,8000078a <panic>

0000000080001dfe <yield>:
{
    80001dfe:	1101                	addi	sp,sp,-32
    80001e00:	ec06                	sd	ra,24(sp)
    80001e02:	e822                	sd	s0,16(sp)
    80001e04:	e426                	sd	s1,8(sp)
    80001e06:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e08:	a05ff0ef          	jal	ra,8000180c <myproc>
    80001e0c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e0e:	d5ffe0ef          	jal	ra,80000b6c <acquire>
  p->state = RUNNABLE;
    80001e12:	478d                	li	a5,3
    80001e14:	cc9c                	sw	a5,24(s1)
  sched();
    80001e16:	f2fff0ef          	jal	ra,80001d44 <sched>
  release(&p->lock);
    80001e1a:	8526                	mv	a0,s1
    80001e1c:	de9fe0ef          	jal	ra,80000c04 <release>
}
    80001e20:	60e2                	ld	ra,24(sp)
    80001e22:	6442                	ld	s0,16(sp)
    80001e24:	64a2                	ld	s1,8(sp)
    80001e26:	6105                	addi	sp,sp,32
    80001e28:	8082                	ret

0000000080001e2a <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001e2a:	7179                	addi	sp,sp,-48
    80001e2c:	f406                	sd	ra,40(sp)
    80001e2e:	f022                	sd	s0,32(sp)
    80001e30:	ec26                	sd	s1,24(sp)
    80001e32:	e84a                	sd	s2,16(sp)
    80001e34:	e44e                	sd	s3,8(sp)
    80001e36:	1800                	addi	s0,sp,48
    80001e38:	89aa                	mv	s3,a0
    80001e3a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e3c:	9d1ff0ef          	jal	ra,8000180c <myproc>
    80001e40:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001e42:	d2bfe0ef          	jal	ra,80000b6c <acquire>
  release(lk);
    80001e46:	854a                	mv	a0,s2
    80001e48:	dbdfe0ef          	jal	ra,80000c04 <release>

  // Go to sleep.
  p->chan = chan;
    80001e4c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001e50:	4789                	li	a5,2
    80001e52:	cc9c                	sw	a5,24(s1)

  sched();
    80001e54:	ef1ff0ef          	jal	ra,80001d44 <sched>

  // Tidy up.
  p->chan = 0;
    80001e58:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001e5c:	8526                	mv	a0,s1
    80001e5e:	da7fe0ef          	jal	ra,80000c04 <release>
  acquire(lk);
    80001e62:	854a                	mv	a0,s2
    80001e64:	d09fe0ef          	jal	ra,80000b6c <acquire>
}
    80001e68:	70a2                	ld	ra,40(sp)
    80001e6a:	7402                	ld	s0,32(sp)
    80001e6c:	64e2                	ld	s1,24(sp)
    80001e6e:	6942                	ld	s2,16(sp)
    80001e70:	69a2                	ld	s3,8(sp)
    80001e72:	6145                	addi	sp,sp,48
    80001e74:	8082                	ret

0000000080001e76 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001e76:	7139                	addi	sp,sp,-64
    80001e78:	fc06                	sd	ra,56(sp)
    80001e7a:	f822                	sd	s0,48(sp)
    80001e7c:	f426                	sd	s1,40(sp)
    80001e7e:	f04a                	sd	s2,32(sp)
    80001e80:	ec4e                	sd	s3,24(sp)
    80001e82:	e852                	sd	s4,16(sp)
    80001e84:	e456                	sd	s5,8(sp)
    80001e86:	0080                	addi	s0,sp,64
    80001e88:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001e8a:	0000e497          	auipc	s1,0xe
    80001e8e:	05e48493          	addi	s1,s1,94 # 8000fee8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001e92:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001e94:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e96:	00014917          	auipc	s2,0x14
    80001e9a:	e5290913          	addi	s2,s2,-430 # 80015ce8 <tickslock>
    80001e9e:	a801                	j	80001eae <wakeup+0x38>
      }
      release(&p->lock);
    80001ea0:	8526                	mv	a0,s1
    80001ea2:	d63fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ea6:	17848493          	addi	s1,s1,376
    80001eaa:	03248263          	beq	s1,s2,80001ece <wakeup+0x58>
    if(p != myproc()){
    80001eae:	95fff0ef          	jal	ra,8000180c <myproc>
    80001eb2:	fea48ae3          	beq	s1,a0,80001ea6 <wakeup+0x30>
      acquire(&p->lock);
    80001eb6:	8526                	mv	a0,s1
    80001eb8:	cb5fe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001ebc:	4c9c                	lw	a5,24(s1)
    80001ebe:	ff3791e3          	bne	a5,s3,80001ea0 <wakeup+0x2a>
    80001ec2:	709c                	ld	a5,32(s1)
    80001ec4:	fd479ee3          	bne	a5,s4,80001ea0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001ec8:	0154ac23          	sw	s5,24(s1)
    80001ecc:	bfd1                	j	80001ea0 <wakeup+0x2a>
    }
  }
}
    80001ece:	70e2                	ld	ra,56(sp)
    80001ed0:	7442                	ld	s0,48(sp)
    80001ed2:	74a2                	ld	s1,40(sp)
    80001ed4:	7902                	ld	s2,32(sp)
    80001ed6:	69e2                	ld	s3,24(sp)
    80001ed8:	6a42                	ld	s4,16(sp)
    80001eda:	6aa2                	ld	s5,8(sp)
    80001edc:	6121                	addi	sp,sp,64
    80001ede:	8082                	ret

0000000080001ee0 <reparent>:
{
    80001ee0:	7179                	addi	sp,sp,-48
    80001ee2:	f406                	sd	ra,40(sp)
    80001ee4:	f022                	sd	s0,32(sp)
    80001ee6:	ec26                	sd	s1,24(sp)
    80001ee8:	e84a                	sd	s2,16(sp)
    80001eea:	e44e                	sd	s3,8(sp)
    80001eec:	e052                	sd	s4,0(sp)
    80001eee:	1800                	addi	s0,sp,48
    80001ef0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ef2:	0000e497          	auipc	s1,0xe
    80001ef6:	ff648493          	addi	s1,s1,-10 # 8000fee8 <proc>
      pp->parent = initproc;
    80001efa:	00006a17          	auipc	s4,0x6
    80001efe:	ab6a0a13          	addi	s4,s4,-1354 # 800079b0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f02:	00014997          	auipc	s3,0x14
    80001f06:	de698993          	addi	s3,s3,-538 # 80015ce8 <tickslock>
    80001f0a:	a029                	j	80001f14 <reparent+0x34>
    80001f0c:	17848493          	addi	s1,s1,376
    80001f10:	01348b63          	beq	s1,s3,80001f26 <reparent+0x46>
    if(pp->parent == p){
    80001f14:	7c9c                	ld	a5,56(s1)
    80001f16:	ff279be3          	bne	a5,s2,80001f0c <reparent+0x2c>
      pp->parent = initproc;
    80001f1a:	000a3503          	ld	a0,0(s4)
    80001f1e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001f20:	f57ff0ef          	jal	ra,80001e76 <wakeup>
    80001f24:	b7e5                	j	80001f0c <reparent+0x2c>
}
    80001f26:	70a2                	ld	ra,40(sp)
    80001f28:	7402                	ld	s0,32(sp)
    80001f2a:	64e2                	ld	s1,24(sp)
    80001f2c:	6942                	ld	s2,16(sp)
    80001f2e:	69a2                	ld	s3,8(sp)
    80001f30:	6a02                	ld	s4,0(sp)
    80001f32:	6145                	addi	sp,sp,48
    80001f34:	8082                	ret

0000000080001f36 <kexit>:
{
    80001f36:	7179                	addi	sp,sp,-48
    80001f38:	f406                	sd	ra,40(sp)
    80001f3a:	f022                	sd	s0,32(sp)
    80001f3c:	ec26                	sd	s1,24(sp)
    80001f3e:	e84a                	sd	s2,16(sp)
    80001f40:	e44e                	sd	s3,8(sp)
    80001f42:	e052                	sd	s4,0(sp)
    80001f44:	1800                	addi	s0,sp,48
    80001f46:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001f48:	8c5ff0ef          	jal	ra,8000180c <myproc>
    80001f4c:	892a                	mv	s2,a0
  if(p == initproc)
    80001f4e:	00006797          	auipc	a5,0x6
    80001f52:	a627b783          	ld	a5,-1438(a5) # 800079b0 <initproc>
    80001f56:	0d050493          	addi	s1,a0,208
    80001f5a:	15050993          	addi	s3,a0,336
    80001f5e:	00a79f63          	bne	a5,a0,80001f7c <kexit+0x46>
    panic("init exiting");
    80001f62:	00005517          	auipc	a0,0x5
    80001f66:	29650513          	addi	a0,a0,662 # 800071f8 <digits+0x1c0>
    80001f6a:	821fe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    80001f6e:	252020ef          	jal	ra,800041c0 <fileclose>
      p->ofile[fd] = 0;
    80001f72:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001f76:	04a1                	addi	s1,s1,8
    80001f78:	01348563          	beq	s1,s3,80001f82 <kexit+0x4c>
    if(p->ofile[fd]){
    80001f7c:	6088                	ld	a0,0(s1)
    80001f7e:	f965                	bnez	a0,80001f6e <kexit+0x38>
    80001f80:	bfdd                	j	80001f76 <kexit+0x40>
  begin_op();
    80001f82:	631010ef          	jal	ra,80003db2 <begin_op>
  iput(p->cwd);
    80001f86:	15093503          	ld	a0,336(s2)
    80001f8a:	5c8010ef          	jal	ra,80003552 <iput>
  end_op();
    80001f8e:	695010ef          	jal	ra,80003e22 <end_op>
  p->cwd = 0;
    80001f92:	14093823          	sd	zero,336(s2)
  acquire(&wait_lock);
    80001f96:	0000e497          	auipc	s1,0xe
    80001f9a:	b3a48493          	addi	s1,s1,-1222 # 8000fad0 <wait_lock>
    80001f9e:	8526                	mv	a0,s1
    80001fa0:	bcdfe0ef          	jal	ra,80000b6c <acquire>
  reparent(p);
    80001fa4:	854a                	mv	a0,s2
    80001fa6:	f3bff0ef          	jal	ra,80001ee0 <reparent>
  wakeup(p->parent);
    80001faa:	03893503          	ld	a0,56(s2)
    80001fae:	ec9ff0ef          	jal	ra,80001e76 <wakeup>
  acquire(&p->lock);
    80001fb2:	854a                	mv	a0,s2
    80001fb4:	bb9fe0ef          	jal	ra,80000b6c <acquire>
  p->xstate = status;
    80001fb8:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    80001fbc:	4795                	li	a5,5
    80001fbe:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    80001fc2:	8526                	mv	a0,s1
    80001fc4:	c41fe0ef          	jal	ra,80000c04 <release>
  if(p->xtrace && p->xtrace->active){
    80001fc8:	17093783          	ld	a5,368(s2)
    80001fcc:	c3b9                	beqz	a5,80002012 <kexit+0xdc>
    80001fce:	4398                	lw	a4,0(a5)
    80001fd0:	c329                	beqz	a4,80002012 <kexit+0xdc>
    p->xtrace->active = 0;
    80001fd2:	0007a023          	sw	zero,0(a5)
    int num=p->xtrace->n;
    80001fd6:	17093783          	ld	a5,368(s2)
    80001fda:	0047a983          	lw	s3,4(a5)
    for(int i=0;i<num;i++){
    80001fde:	03305463          	blez	s3,80002006 <kexit+0xd0>
    80001fe2:	4481                	li	s1,0
      printf("Syscall %d returned %d\n",p->xtrace->list[i].sysno,p->xtrace->list[i].sysret);
    80001fe4:	00005a17          	auipc	s4,0x5
    80001fe8:	224a0a13          	addi	s4,s4,548 # 80007208 <digits+0x1d0>
    80001fec:	00349713          	slli	a4,s1,0x3
    80001ff0:	17093783          	ld	a5,368(s2)
    80001ff4:	97ba                	add	a5,a5,a4
    80001ff6:	47d0                	lw	a2,12(a5)
    80001ff8:	478c                	lw	a1,8(a5)
    80001ffa:	8552                	mv	a0,s4
    80001ffc:	cc8fe0ef          	jal	ra,800004c4 <printf>
    for(int i=0;i<num;i++){
    80002000:	2485                	addiw	s1,s1,1
    80002002:	fe9995e3          	bne	s3,s1,80001fec <kexit+0xb6>
    kfree((void*)p->xtrace);
    80002006:	17093503          	ld	a0,368(s2)
    8000200a:	9b3fe0ef          	jal	ra,800009bc <kfree>
    p->xtrace = 0;
    8000200e:	16093823          	sd	zero,368(s2)
  sched();
    80002012:	d33ff0ef          	jal	ra,80001d44 <sched>
  panic("zombie exit");
    80002016:	00005517          	auipc	a0,0x5
    8000201a:	20a50513          	addi	a0,a0,522 # 80007220 <digits+0x1e8>
    8000201e:	f6cfe0ef          	jal	ra,8000078a <panic>

0000000080002022 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002022:	7179                	addi	sp,sp,-48
    80002024:	f406                	sd	ra,40(sp)
    80002026:	f022                	sd	s0,32(sp)
    80002028:	ec26                	sd	s1,24(sp)
    8000202a:	e84a                	sd	s2,16(sp)
    8000202c:	e44e                	sd	s3,8(sp)
    8000202e:	1800                	addi	s0,sp,48
    80002030:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002032:	0000e497          	auipc	s1,0xe
    80002036:	eb648493          	addi	s1,s1,-330 # 8000fee8 <proc>
    8000203a:	00014997          	auipc	s3,0x14
    8000203e:	cae98993          	addi	s3,s3,-850 # 80015ce8 <tickslock>
    acquire(&p->lock);
    80002042:	8526                	mv	a0,s1
    80002044:	b29fe0ef          	jal	ra,80000b6c <acquire>
    if(p->pid == pid){
    80002048:	589c                	lw	a5,48(s1)
    8000204a:	01278b63          	beq	a5,s2,80002060 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	bb5fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002054:	17848493          	addi	s1,s1,376
    80002058:	ff3495e3          	bne	s1,s3,80002042 <kkill+0x20>
  }
  return -1;
    8000205c:	557d                	li	a0,-1
    8000205e:	a819                	j	80002074 <kkill+0x52>
      p->killed = 1;
    80002060:	4785                	li	a5,1
    80002062:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002064:	4c98                	lw	a4,24(s1)
    80002066:	4789                	li	a5,2
    80002068:	00f70d63          	beq	a4,a5,80002082 <kkill+0x60>
      release(&p->lock);
    8000206c:	8526                	mv	a0,s1
    8000206e:	b97fe0ef          	jal	ra,80000c04 <release>
      return 0;
    80002072:	4501                	li	a0,0
}
    80002074:	70a2                	ld	ra,40(sp)
    80002076:	7402                	ld	s0,32(sp)
    80002078:	64e2                	ld	s1,24(sp)
    8000207a:	6942                	ld	s2,16(sp)
    8000207c:	69a2                	ld	s3,8(sp)
    8000207e:	6145                	addi	sp,sp,48
    80002080:	8082                	ret
        p->state = RUNNABLE;
    80002082:	478d                	li	a5,3
    80002084:	cc9c                	sw	a5,24(s1)
    80002086:	b7dd                	j	8000206c <kkill+0x4a>

0000000080002088 <setkilled>:

void
setkilled(struct proc *p)
{
    80002088:	1101                	addi	sp,sp,-32
    8000208a:	ec06                	sd	ra,24(sp)
    8000208c:	e822                	sd	s0,16(sp)
    8000208e:	e426                	sd	s1,8(sp)
    80002090:	1000                	addi	s0,sp,32
    80002092:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002094:	ad9fe0ef          	jal	ra,80000b6c <acquire>
  p->killed = 1;
    80002098:	4785                	li	a5,1
    8000209a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000209c:	8526                	mv	a0,s1
    8000209e:	b67fe0ef          	jal	ra,80000c04 <release>
}
    800020a2:	60e2                	ld	ra,24(sp)
    800020a4:	6442                	ld	s0,16(sp)
    800020a6:	64a2                	ld	s1,8(sp)
    800020a8:	6105                	addi	sp,sp,32
    800020aa:	8082                	ret

00000000800020ac <killed>:

int
killed(struct proc *p)
{
    800020ac:	1101                	addi	sp,sp,-32
    800020ae:	ec06                	sd	ra,24(sp)
    800020b0:	e822                	sd	s0,16(sp)
    800020b2:	e426                	sd	s1,8(sp)
    800020b4:	e04a                	sd	s2,0(sp)
    800020b6:	1000                	addi	s0,sp,32
    800020b8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020ba:	ab3fe0ef          	jal	ra,80000b6c <acquire>
  k = p->killed;
    800020be:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800020c2:	8526                	mv	a0,s1
    800020c4:	b41fe0ef          	jal	ra,80000c04 <release>
  return k;
}
    800020c8:	854a                	mv	a0,s2
    800020ca:	60e2                	ld	ra,24(sp)
    800020cc:	6442                	ld	s0,16(sp)
    800020ce:	64a2                	ld	s1,8(sp)
    800020d0:	6902                	ld	s2,0(sp)
    800020d2:	6105                	addi	sp,sp,32
    800020d4:	8082                	ret

00000000800020d6 <kwait>:
{
    800020d6:	715d                	addi	sp,sp,-80
    800020d8:	e486                	sd	ra,72(sp)
    800020da:	e0a2                	sd	s0,64(sp)
    800020dc:	fc26                	sd	s1,56(sp)
    800020de:	f84a                	sd	s2,48(sp)
    800020e0:	f44e                	sd	s3,40(sp)
    800020e2:	f052                	sd	s4,32(sp)
    800020e4:	ec56                	sd	s5,24(sp)
    800020e6:	e85a                	sd	s6,16(sp)
    800020e8:	e45e                	sd	s7,8(sp)
    800020ea:	e062                	sd	s8,0(sp)
    800020ec:	0880                	addi	s0,sp,80
    800020ee:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020f0:	f1cff0ef          	jal	ra,8000180c <myproc>
    800020f4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800020f6:	0000e517          	auipc	a0,0xe
    800020fa:	9da50513          	addi	a0,a0,-1574 # 8000fad0 <wait_lock>
    800020fe:	a6ffe0ef          	jal	ra,80000b6c <acquire>
    havekids = 0;
    80002102:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002104:	4a15                	li	s4,5
        havekids = 1;
    80002106:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002108:	00014997          	auipc	s3,0x14
    8000210c:	be098993          	addi	s3,s3,-1056 # 80015ce8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002110:	0000ec17          	auipc	s8,0xe
    80002114:	9c0c0c13          	addi	s8,s8,-1600 # 8000fad0 <wait_lock>
    havekids = 0;
    80002118:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000211a:	0000e497          	auipc	s1,0xe
    8000211e:	dce48493          	addi	s1,s1,-562 # 8000fee8 <proc>
    80002122:	a899                	j	80002178 <kwait+0xa2>
          pid = pp->pid;
    80002124:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002128:	000b0c63          	beqz	s6,80002140 <kwait+0x6a>
    8000212c:	4691                	li	a3,4
    8000212e:	02c48613          	addi	a2,s1,44
    80002132:	85da                	mv	a1,s6
    80002134:	05093503          	ld	a0,80(s2)
    80002138:	c1aff0ef          	jal	ra,80001552 <copyout>
    8000213c:	00054f63          	bltz	a0,8000215a <kwait+0x84>
          freeproc(pp);
    80002140:	8526                	mv	a0,s1
    80002142:	89bff0ef          	jal	ra,800019dc <freeproc>
          release(&pp->lock);
    80002146:	8526                	mv	a0,s1
    80002148:	abdfe0ef          	jal	ra,80000c04 <release>
          release(&wait_lock);
    8000214c:	0000e517          	auipc	a0,0xe
    80002150:	98450513          	addi	a0,a0,-1660 # 8000fad0 <wait_lock>
    80002154:	ab1fe0ef          	jal	ra,80000c04 <release>
          return pid;
    80002158:	a891                	j	800021ac <kwait+0xd6>
            release(&pp->lock);
    8000215a:	8526                	mv	a0,s1
    8000215c:	aa9fe0ef          	jal	ra,80000c04 <release>
            release(&wait_lock);
    80002160:	0000e517          	auipc	a0,0xe
    80002164:	97050513          	addi	a0,a0,-1680 # 8000fad0 <wait_lock>
    80002168:	a9dfe0ef          	jal	ra,80000c04 <release>
            return -1;
    8000216c:	59fd                	li	s3,-1
    8000216e:	a83d                	j	800021ac <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002170:	17848493          	addi	s1,s1,376
    80002174:	03348063          	beq	s1,s3,80002194 <kwait+0xbe>
      if(pp->parent == p){
    80002178:	7c9c                	ld	a5,56(s1)
    8000217a:	ff279be3          	bne	a5,s2,80002170 <kwait+0x9a>
        acquire(&pp->lock);
    8000217e:	8526                	mv	a0,s1
    80002180:	9edfe0ef          	jal	ra,80000b6c <acquire>
        if(pp->state == ZOMBIE){
    80002184:	4c9c                	lw	a5,24(s1)
    80002186:	f9478fe3          	beq	a5,s4,80002124 <kwait+0x4e>
        release(&pp->lock);
    8000218a:	8526                	mv	a0,s1
    8000218c:	a79fe0ef          	jal	ra,80000c04 <release>
        havekids = 1;
    80002190:	8756                	mv	a4,s5
    80002192:	bff9                	j	80002170 <kwait+0x9a>
    if(!havekids || killed(p)){
    80002194:	c709                	beqz	a4,8000219e <kwait+0xc8>
    80002196:	854a                	mv	a0,s2
    80002198:	f15ff0ef          	jal	ra,800020ac <killed>
    8000219c:	c50d                	beqz	a0,800021c6 <kwait+0xf0>
      release(&wait_lock);
    8000219e:	0000e517          	auipc	a0,0xe
    800021a2:	93250513          	addi	a0,a0,-1742 # 8000fad0 <wait_lock>
    800021a6:	a5ffe0ef          	jal	ra,80000c04 <release>
      return -1;
    800021aa:	59fd                	li	s3,-1
}
    800021ac:	854e                	mv	a0,s3
    800021ae:	60a6                	ld	ra,72(sp)
    800021b0:	6406                	ld	s0,64(sp)
    800021b2:	74e2                	ld	s1,56(sp)
    800021b4:	7942                	ld	s2,48(sp)
    800021b6:	79a2                	ld	s3,40(sp)
    800021b8:	7a02                	ld	s4,32(sp)
    800021ba:	6ae2                	ld	s5,24(sp)
    800021bc:	6b42                	ld	s6,16(sp)
    800021be:	6ba2                	ld	s7,8(sp)
    800021c0:	6c02                	ld	s8,0(sp)
    800021c2:	6161                	addi	sp,sp,80
    800021c4:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021c6:	85e2                	mv	a1,s8
    800021c8:	854a                	mv	a0,s2
    800021ca:	c61ff0ef          	jal	ra,80001e2a <sleep>
    havekids = 0;
    800021ce:	b7a9                	j	80002118 <kwait+0x42>

00000000800021d0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800021d0:	7179                	addi	sp,sp,-48
    800021d2:	f406                	sd	ra,40(sp)
    800021d4:	f022                	sd	s0,32(sp)
    800021d6:	ec26                	sd	s1,24(sp)
    800021d8:	e84a                	sd	s2,16(sp)
    800021da:	e44e                	sd	s3,8(sp)
    800021dc:	e052                	sd	s4,0(sp)
    800021de:	1800                	addi	s0,sp,48
    800021e0:	84aa                	mv	s1,a0
    800021e2:	892e                	mv	s2,a1
    800021e4:	89b2                	mv	s3,a2
    800021e6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800021e8:	e24ff0ef          	jal	ra,8000180c <myproc>
  if(user_dst){
    800021ec:	cc99                	beqz	s1,8000220a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800021ee:	86d2                	mv	a3,s4
    800021f0:	864e                	mv	a2,s3
    800021f2:	85ca                	mv	a1,s2
    800021f4:	6928                	ld	a0,80(a0)
    800021f6:	b5cff0ef          	jal	ra,80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800021fa:	70a2                	ld	ra,40(sp)
    800021fc:	7402                	ld	s0,32(sp)
    800021fe:	64e2                	ld	s1,24(sp)
    80002200:	6942                	ld	s2,16(sp)
    80002202:	69a2                	ld	s3,8(sp)
    80002204:	6a02                	ld	s4,0(sp)
    80002206:	6145                	addi	sp,sp,48
    80002208:	8082                	ret
    memmove((char *)dst, src, len);
    8000220a:	000a061b          	sext.w	a2,s4
    8000220e:	85ce                	mv	a1,s3
    80002210:	854a                	mv	a0,s2
    80002212:	a8bfe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    80002216:	8526                	mv	a0,s1
    80002218:	b7cd                	j	800021fa <either_copyout+0x2a>

000000008000221a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000221a:	7179                	addi	sp,sp,-48
    8000221c:	f406                	sd	ra,40(sp)
    8000221e:	f022                	sd	s0,32(sp)
    80002220:	ec26                	sd	s1,24(sp)
    80002222:	e84a                	sd	s2,16(sp)
    80002224:	e44e                	sd	s3,8(sp)
    80002226:	e052                	sd	s4,0(sp)
    80002228:	1800                	addi	s0,sp,48
    8000222a:	892a                	mv	s2,a0
    8000222c:	84ae                	mv	s1,a1
    8000222e:	89b2                	mv	s3,a2
    80002230:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002232:	ddaff0ef          	jal	ra,8000180c <myproc>
  if(user_src){
    80002236:	cc99                	beqz	s1,80002254 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002238:	86d2                	mv	a3,s4
    8000223a:	864e                	mv	a2,s3
    8000223c:	85ca                	mv	a1,s2
    8000223e:	6928                	ld	a0,80(a0)
    80002240:	bd8ff0ef          	jal	ra,80001618 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002244:	70a2                	ld	ra,40(sp)
    80002246:	7402                	ld	s0,32(sp)
    80002248:	64e2                	ld	s1,24(sp)
    8000224a:	6942                	ld	s2,16(sp)
    8000224c:	69a2                	ld	s3,8(sp)
    8000224e:	6a02                	ld	s4,0(sp)
    80002250:	6145                	addi	sp,sp,48
    80002252:	8082                	ret
    memmove(dst, (char*)src, len);
    80002254:	000a061b          	sext.w	a2,s4
    80002258:	85ce                	mv	a1,s3
    8000225a:	854a                	mv	a0,s2
    8000225c:	a41fe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    80002260:	8526                	mv	a0,s1
    80002262:	b7cd                	j	80002244 <either_copyin+0x2a>

0000000080002264 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002264:	715d                	addi	sp,sp,-80
    80002266:	e486                	sd	ra,72(sp)
    80002268:	e0a2                	sd	s0,64(sp)
    8000226a:	fc26                	sd	s1,56(sp)
    8000226c:	f84a                	sd	s2,48(sp)
    8000226e:	f44e                	sd	s3,40(sp)
    80002270:	f052                	sd	s4,32(sp)
    80002272:	ec56                	sd	s5,24(sp)
    80002274:	e85a                	sd	s6,16(sp)
    80002276:	e45e                	sd	s7,8(sp)
    80002278:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000227a:	00005517          	auipc	a0,0x5
    8000227e:	28e50513          	addi	a0,a0,654 # 80007508 <syscalls+0x100>
    80002282:	a42fe0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002286:	0000e497          	auipc	s1,0xe
    8000228a:	dba48493          	addi	s1,s1,-582 # 80010040 <proc+0x158>
    8000228e:	00014917          	auipc	s2,0x14
    80002292:	bb290913          	addi	s2,s2,-1102 # 80015e40 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002296:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002298:	00005997          	auipc	s3,0x5
    8000229c:	f9898993          	addi	s3,s3,-104 # 80007230 <digits+0x1f8>
    printf("%d %s %s", p->pid, state, p->name);
    800022a0:	00005a97          	auipc	s5,0x5
    800022a4:	f98a8a93          	addi	s5,s5,-104 # 80007238 <digits+0x200>
    printf("\n");
    800022a8:	00005a17          	auipc	s4,0x5
    800022ac:	260a0a13          	addi	s4,s4,608 # 80007508 <syscalls+0x100>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022b0:	00005b97          	auipc	s7,0x5
    800022b4:	fc8b8b93          	addi	s7,s7,-56 # 80007278 <states.0>
    800022b8:	a829                	j	800022d2 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022ba:	ed86a583          	lw	a1,-296(a3)
    800022be:	8556                	mv	a0,s5
    800022c0:	a04fe0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    800022c4:	8552                	mv	a0,s4
    800022c6:	9fefe0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022ca:	17848493          	addi	s1,s1,376
    800022ce:	03248163          	beq	s1,s2,800022f0 <procdump+0x8c>
    if(p->state == UNUSED)
    800022d2:	86a6                	mv	a3,s1
    800022d4:	ec04a783          	lw	a5,-320(s1)
    800022d8:	dbed                	beqz	a5,800022ca <procdump+0x66>
      state = "???";
    800022da:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022dc:	fcfb6fe3          	bltu	s6,a5,800022ba <procdump+0x56>
    800022e0:	1782                	slli	a5,a5,0x20
    800022e2:	9381                	srli	a5,a5,0x20
    800022e4:	078e                	slli	a5,a5,0x3
    800022e6:	97de                	add	a5,a5,s7
    800022e8:	6390                	ld	a2,0(a5)
    800022ea:	fa61                	bnez	a2,800022ba <procdump+0x56>
      state = "???";
    800022ec:	864e                	mv	a2,s3
    800022ee:	b7f1                	j	800022ba <procdump+0x56>
  }
}
    800022f0:	60a6                	ld	ra,72(sp)
    800022f2:	6406                	ld	s0,64(sp)
    800022f4:	74e2                	ld	s1,56(sp)
    800022f6:	7942                	ld	s2,48(sp)
    800022f8:	79a2                	ld	s3,40(sp)
    800022fa:	7a02                	ld	s4,32(sp)
    800022fc:	6ae2                	ld	s5,24(sp)
    800022fe:	6b42                	ld	s6,16(sp)
    80002300:	6ba2                	ld	s7,8(sp)
    80002302:	6161                	addi	sp,sp,80
    80002304:	8082                	ret

0000000080002306 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002306:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000230a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000230e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002310:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002312:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002316:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000231a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000231e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002322:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002326:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000232a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000232e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002332:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002336:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000233a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000233e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002342:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002344:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002346:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000234a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000234e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002352:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002356:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000235a:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000235e:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002362:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002366:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000236a:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000236e:	8082                	ret

0000000080002370 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002370:	1141                	addi	sp,sp,-16
    80002372:	e406                	sd	ra,8(sp)
    80002374:	e022                	sd	s0,0(sp)
    80002376:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002378:	00005597          	auipc	a1,0x5
    8000237c:	f3058593          	addi	a1,a1,-208 # 800072a8 <states.0+0x30>
    80002380:	00014517          	auipc	a0,0x14
    80002384:	96850513          	addi	a0,a0,-1688 # 80015ce8 <tickslock>
    80002388:	f64fe0ef          	jal	ra,80000aec <initlock>
}
    8000238c:	60a2                	ld	ra,8(sp)
    8000238e:	6402                	ld	s0,0(sp)
    80002390:	0141                	addi	sp,sp,16
    80002392:	8082                	ret

0000000080002394 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002394:	1141                	addi	sp,sp,-16
    80002396:	e422                	sd	s0,8(sp)
    80002398:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000239a:	00003797          	auipc	a5,0x3
    8000239e:	0e678793          	addi	a5,a5,230 # 80005480 <kernelvec>
    800023a2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023a6:	6422                	ld	s0,8(sp)
    800023a8:	0141                	addi	sp,sp,16
    800023aa:	8082                	ret

00000000800023ac <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800023ac:	1141                	addi	sp,sp,-16
    800023ae:	e406                	sd	ra,8(sp)
    800023b0:	e022                	sd	s0,0(sp)
    800023b2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800023b4:	c58ff0ef          	jal	ra,8000180c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023b8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023bc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023be:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800023c2:	04000737          	lui	a4,0x4000
    800023c6:	00004797          	auipc	a5,0x4
    800023ca:	c3a78793          	addi	a5,a5,-966 # 80006000 <_trampoline>
    800023ce:	00004697          	auipc	a3,0x4
    800023d2:	c3268693          	addi	a3,a3,-974 # 80006000 <_trampoline>
    800023d6:	8f95                	sub	a5,a5,a3
    800023d8:	177d                	addi	a4,a4,-1
    800023da:	0732                	slli	a4,a4,0xc
    800023dc:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023de:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800023e2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800023e4:	18002773          	csrr	a4,satp
    800023e8:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800023ea:	6d38                	ld	a4,88(a0)
    800023ec:	613c                	ld	a5,64(a0)
    800023ee:	6685                	lui	a3,0x1
    800023f0:	97b6                	add	a5,a5,a3
    800023f2:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800023f4:	6d3c                	ld	a5,88(a0)
    800023f6:	00000717          	auipc	a4,0x0
    800023fa:	0f470713          	addi	a4,a4,244 # 800024ea <usertrap>
    800023fe:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002400:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002402:	8712                	mv	a4,tp
    80002404:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002406:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000240a:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000240e:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002412:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002416:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002418:	6f9c                	ld	a5,24(a5)
    8000241a:	14179073          	csrw	sepc,a5
}
    8000241e:	60a2                	ld	ra,8(sp)
    80002420:	6402                	ld	s0,0(sp)
    80002422:	0141                	addi	sp,sp,16
    80002424:	8082                	ret

0000000080002426 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002426:	1101                	addi	sp,sp,-32
    80002428:	ec06                	sd	ra,24(sp)
    8000242a:	e822                	sd	s0,16(sp)
    8000242c:	e426                	sd	s1,8(sp)
    8000242e:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002430:	bb0ff0ef          	jal	ra,800017e0 <cpuid>
    80002434:	cd19                	beqz	a0,80002452 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002436:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000243a:	000f4737          	lui	a4,0xf4
    8000243e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002442:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002444:	14d79073          	csrw	0x14d,a5
}
    80002448:	60e2                	ld	ra,24(sp)
    8000244a:	6442                	ld	s0,16(sp)
    8000244c:	64a2                	ld	s1,8(sp)
    8000244e:	6105                	addi	sp,sp,32
    80002450:	8082                	ret
    acquire(&tickslock);
    80002452:	00014497          	auipc	s1,0x14
    80002456:	89648493          	addi	s1,s1,-1898 # 80015ce8 <tickslock>
    8000245a:	8526                	mv	a0,s1
    8000245c:	f10fe0ef          	jal	ra,80000b6c <acquire>
    ticks++;
    80002460:	00005517          	auipc	a0,0x5
    80002464:	55850513          	addi	a0,a0,1368 # 800079b8 <ticks>
    80002468:	411c                	lw	a5,0(a0)
    8000246a:	2785                	addiw	a5,a5,1
    8000246c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000246e:	a09ff0ef          	jal	ra,80001e76 <wakeup>
    release(&tickslock);
    80002472:	8526                	mv	a0,s1
    80002474:	f90fe0ef          	jal	ra,80000c04 <release>
    80002478:	bf7d                	j	80002436 <clockintr+0x10>

000000008000247a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000247a:	1101                	addi	sp,sp,-32
    8000247c:	ec06                	sd	ra,24(sp)
    8000247e:	e822                	sd	s0,16(sp)
    80002480:	e426                	sd	s1,8(sp)
    80002482:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002484:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002488:	57fd                	li	a5,-1
    8000248a:	17fe                	slli	a5,a5,0x3f
    8000248c:	07a5                	addi	a5,a5,9
    8000248e:	00f70d63          	beq	a4,a5,800024a8 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002492:	57fd                	li	a5,-1
    80002494:	17fe                	slli	a5,a5,0x3f
    80002496:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002498:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000249a:	04f70463          	beq	a4,a5,800024e2 <devintr+0x68>
  }
}
    8000249e:	60e2                	ld	ra,24(sp)
    800024a0:	6442                	ld	s0,16(sp)
    800024a2:	64a2                	ld	s1,8(sp)
    800024a4:	6105                	addi	sp,sp,32
    800024a6:	8082                	ret
    int irq = plic_claim();
    800024a8:	080030ef          	jal	ra,80005528 <plic_claim>
    800024ac:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800024ae:	47a9                	li	a5,10
    800024b0:	02f50363          	beq	a0,a5,800024d6 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    800024b4:	4785                	li	a5,1
    800024b6:	02f50363          	beq	a0,a5,800024dc <devintr+0x62>
    return 1;
    800024ba:	4505                	li	a0,1
    } else if(irq){
    800024bc:	d0ed                	beqz	s1,8000249e <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    800024be:	85a6                	mv	a1,s1
    800024c0:	00005517          	auipc	a0,0x5
    800024c4:	df050513          	addi	a0,a0,-528 # 800072b0 <states.0+0x38>
    800024c8:	ffdfd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    800024cc:	8526                	mv	a0,s1
    800024ce:	07a030ef          	jal	ra,80005548 <plic_complete>
    return 1;
    800024d2:	4505                	li	a0,1
    800024d4:	b7e9                	j	8000249e <devintr+0x24>
      uartintr();
    800024d6:	c82fe0ef          	jal	ra,80000958 <uartintr>
    800024da:	bfcd                	j	800024cc <devintr+0x52>
      virtio_disk_intr();
    800024dc:	4dc030ef          	jal	ra,800059b8 <virtio_disk_intr>
    800024e0:	b7f5                	j	800024cc <devintr+0x52>
    clockintr();
    800024e2:	f45ff0ef          	jal	ra,80002426 <clockintr>
    return 2;
    800024e6:	4509                	li	a0,2
    800024e8:	bf5d                	j	8000249e <devintr+0x24>

00000000800024ea <usertrap>:
{
    800024ea:	1101                	addi	sp,sp,-32
    800024ec:	ec06                	sd	ra,24(sp)
    800024ee:	e822                	sd	s0,16(sp)
    800024f0:	e426                	sd	s1,8(sp)
    800024f2:	e04a                	sd	s2,0(sp)
    800024f4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024f6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800024fa:	1007f793          	andi	a5,a5,256
    800024fe:	eba5                	bnez	a5,8000256e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002500:	00003797          	auipc	a5,0x3
    80002504:	f8078793          	addi	a5,a5,-128 # 80005480 <kernelvec>
    80002508:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000250c:	b00ff0ef          	jal	ra,8000180c <myproc>
    80002510:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002512:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002514:	14102773          	csrr	a4,sepc
    80002518:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000251a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000251e:	47a1                	li	a5,8
    80002520:	04f70d63          	beq	a4,a5,8000257a <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002524:	f57ff0ef          	jal	ra,8000247a <devintr>
    80002528:	892a                	mv	s2,a0
    8000252a:	e945                	bnez	a0,800025da <usertrap+0xf0>
    8000252c:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002530:	47bd                	li	a5,15
    80002532:	08f70863          	beq	a4,a5,800025c2 <usertrap+0xd8>
    80002536:	14202773          	csrr	a4,scause
    8000253a:	47b5                	li	a5,13
    8000253c:	08f70363          	beq	a4,a5,800025c2 <usertrap+0xd8>
    80002540:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002544:	5890                	lw	a2,48(s1)
    80002546:	00005517          	auipc	a0,0x5
    8000254a:	daa50513          	addi	a0,a0,-598 # 800072f0 <states.0+0x78>
    8000254e:	f77fd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002552:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002556:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000255a:	00005517          	auipc	a0,0x5
    8000255e:	dc650513          	addi	a0,a0,-570 # 80007320 <states.0+0xa8>
    80002562:	f63fd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    80002566:	8526                	mv	a0,s1
    80002568:	b21ff0ef          	jal	ra,80002088 <setkilled>
    8000256c:	a035                	j	80002598 <usertrap+0xae>
    panic("usertrap: not from user mode");
    8000256e:	00005517          	auipc	a0,0x5
    80002572:	d6250513          	addi	a0,a0,-670 # 800072d0 <states.0+0x58>
    80002576:	a14fe0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    8000257a:	b33ff0ef          	jal	ra,800020ac <killed>
    8000257e:	ed15                	bnez	a0,800025ba <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002580:	6cb8                	ld	a4,88(s1)
    80002582:	6f1c                	ld	a5,24(a4)
    80002584:	0791                	addi	a5,a5,4
    80002586:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002588:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000258c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002590:	10079073          	csrw	sstatus,a5
    syscall();
    80002594:	246000ef          	jal	ra,800027da <syscall>
  if(killed(p))
    80002598:	8526                	mv	a0,s1
    8000259a:	b13ff0ef          	jal	ra,800020ac <killed>
    8000259e:	e139                	bnez	a0,800025e4 <usertrap+0xfa>
  prepare_return();
    800025a0:	e0dff0ef          	jal	ra,800023ac <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800025a4:	68a8                	ld	a0,80(s1)
    800025a6:	8131                	srli	a0,a0,0xc
    800025a8:	57fd                	li	a5,-1
    800025aa:	17fe                	slli	a5,a5,0x3f
    800025ac:	8d5d                	or	a0,a0,a5
}
    800025ae:	60e2                	ld	ra,24(sp)
    800025b0:	6442                	ld	s0,16(sp)
    800025b2:	64a2                	ld	s1,8(sp)
    800025b4:	6902                	ld	s2,0(sp)
    800025b6:	6105                	addi	sp,sp,32
    800025b8:	8082                	ret
      kexit(-1);
    800025ba:	557d                	li	a0,-1
    800025bc:	97bff0ef          	jal	ra,80001f36 <kexit>
    800025c0:	b7c1                	j	80002580 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025c2:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025c6:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800025ca:	164d                	addi	a2,a2,-13
    800025cc:	00163613          	seqz	a2,a2
    800025d0:	68a8                	ld	a0,80(s1)
    800025d2:	f0ffe0ef          	jal	ra,800014e0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800025d6:	f169                	bnez	a0,80002598 <usertrap+0xae>
    800025d8:	b7a5                	j	80002540 <usertrap+0x56>
  if(killed(p))
    800025da:	8526                	mv	a0,s1
    800025dc:	ad1ff0ef          	jal	ra,800020ac <killed>
    800025e0:	c511                	beqz	a0,800025ec <usertrap+0x102>
    800025e2:	a011                	j	800025e6 <usertrap+0xfc>
    800025e4:	4901                	li	s2,0
    kexit(-1);
    800025e6:	557d                	li	a0,-1
    800025e8:	94fff0ef          	jal	ra,80001f36 <kexit>
  if(which_dev == 2)
    800025ec:	4789                	li	a5,2
    800025ee:	faf919e3          	bne	s2,a5,800025a0 <usertrap+0xb6>
    yield();
    800025f2:	80dff0ef          	jal	ra,80001dfe <yield>
    800025f6:	b76d                	j	800025a0 <usertrap+0xb6>

00000000800025f8 <kerneltrap>:
{
    800025f8:	7179                	addi	sp,sp,-48
    800025fa:	f406                	sd	ra,40(sp)
    800025fc:	f022                	sd	s0,32(sp)
    800025fe:	ec26                	sd	s1,24(sp)
    80002600:	e84a                	sd	s2,16(sp)
    80002602:	e44e                	sd	s3,8(sp)
    80002604:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002606:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000260a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000260e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002612:	1004f793          	andi	a5,s1,256
    80002616:	c795                	beqz	a5,80002642 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002618:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000261c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000261e:	eb85                	bnez	a5,8000264e <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002620:	e5bff0ef          	jal	ra,8000247a <devintr>
    80002624:	c91d                	beqz	a0,8000265a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002626:	4789                	li	a5,2
    80002628:	04f50a63          	beq	a0,a5,8000267c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000262c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002630:	10049073          	csrw	sstatus,s1
}
    80002634:	70a2                	ld	ra,40(sp)
    80002636:	7402                	ld	s0,32(sp)
    80002638:	64e2                	ld	s1,24(sp)
    8000263a:	6942                	ld	s2,16(sp)
    8000263c:	69a2                	ld	s3,8(sp)
    8000263e:	6145                	addi	sp,sp,48
    80002640:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002642:	00005517          	auipc	a0,0x5
    80002646:	d0650513          	addi	a0,a0,-762 # 80007348 <states.0+0xd0>
    8000264a:	940fe0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    8000264e:	00005517          	auipc	a0,0x5
    80002652:	d2250513          	addi	a0,a0,-734 # 80007370 <states.0+0xf8>
    80002656:	934fe0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000265a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000265e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002662:	85ce                	mv	a1,s3
    80002664:	00005517          	auipc	a0,0x5
    80002668:	d2c50513          	addi	a0,a0,-724 # 80007390 <states.0+0x118>
    8000266c:	e59fd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    80002670:	00005517          	auipc	a0,0x5
    80002674:	d4850513          	addi	a0,a0,-696 # 800073b8 <states.0+0x140>
    80002678:	912fe0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    8000267c:	990ff0ef          	jal	ra,8000180c <myproc>
    80002680:	d555                	beqz	a0,8000262c <kerneltrap+0x34>
    yield();
    80002682:	f7cff0ef          	jal	ra,80001dfe <yield>
    80002686:	b75d                	j	8000262c <kerneltrap+0x34>

0000000080002688 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002688:	1101                	addi	sp,sp,-32
    8000268a:	ec06                	sd	ra,24(sp)
    8000268c:	e822                	sd	s0,16(sp)
    8000268e:	e426                	sd	s1,8(sp)
    80002690:	1000                	addi	s0,sp,32
    80002692:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002694:	978ff0ef          	jal	ra,8000180c <myproc>
  switch (n) {
    80002698:	4795                	li	a5,5
    8000269a:	0497e163          	bltu	a5,s1,800026dc <argraw+0x54>
    8000269e:	048a                	slli	s1,s1,0x2
    800026a0:	00005717          	auipc	a4,0x5
    800026a4:	d5070713          	addi	a4,a4,-688 # 800073f0 <states.0+0x178>
    800026a8:	94ba                	add	s1,s1,a4
    800026aa:	409c                	lw	a5,0(s1)
    800026ac:	97ba                	add	a5,a5,a4
    800026ae:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800026b0:	6d3c                	ld	a5,88(a0)
    800026b2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800026b4:	60e2                	ld	ra,24(sp)
    800026b6:	6442                	ld	s0,16(sp)
    800026b8:	64a2                	ld	s1,8(sp)
    800026ba:	6105                	addi	sp,sp,32
    800026bc:	8082                	ret
    return p->trapframe->a1;
    800026be:	6d3c                	ld	a5,88(a0)
    800026c0:	7fa8                	ld	a0,120(a5)
    800026c2:	bfcd                	j	800026b4 <argraw+0x2c>
    return p->trapframe->a2;
    800026c4:	6d3c                	ld	a5,88(a0)
    800026c6:	63c8                	ld	a0,128(a5)
    800026c8:	b7f5                	j	800026b4 <argraw+0x2c>
    return p->trapframe->a3;
    800026ca:	6d3c                	ld	a5,88(a0)
    800026cc:	67c8                	ld	a0,136(a5)
    800026ce:	b7dd                	j	800026b4 <argraw+0x2c>
    return p->trapframe->a4;
    800026d0:	6d3c                	ld	a5,88(a0)
    800026d2:	6bc8                	ld	a0,144(a5)
    800026d4:	b7c5                	j	800026b4 <argraw+0x2c>
    return p->trapframe->a5;
    800026d6:	6d3c                	ld	a5,88(a0)
    800026d8:	6fc8                	ld	a0,152(a5)
    800026da:	bfe9                	j	800026b4 <argraw+0x2c>
  panic("argraw");
    800026dc:	00005517          	auipc	a0,0x5
    800026e0:	cec50513          	addi	a0,a0,-788 # 800073c8 <states.0+0x150>
    800026e4:	8a6fe0ef          	jal	ra,8000078a <panic>

00000000800026e8 <fetchaddr>:
{
    800026e8:	1101                	addi	sp,sp,-32
    800026ea:	ec06                	sd	ra,24(sp)
    800026ec:	e822                	sd	s0,16(sp)
    800026ee:	e426                	sd	s1,8(sp)
    800026f0:	e04a                	sd	s2,0(sp)
    800026f2:	1000                	addi	s0,sp,32
    800026f4:	84aa                	mv	s1,a0
    800026f6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800026f8:	914ff0ef          	jal	ra,8000180c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800026fc:	653c                	ld	a5,72(a0)
    800026fe:	02f4f663          	bgeu	s1,a5,8000272a <fetchaddr+0x42>
    80002702:	00848713          	addi	a4,s1,8
    80002706:	02e7e463          	bltu	a5,a4,8000272e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000270a:	46a1                	li	a3,8
    8000270c:	8626                	mv	a2,s1
    8000270e:	85ca                	mv	a1,s2
    80002710:	6928                	ld	a0,80(a0)
    80002712:	f07fe0ef          	jal	ra,80001618 <copyin>
    80002716:	00a03533          	snez	a0,a0
    8000271a:	40a00533          	neg	a0,a0
}
    8000271e:	60e2                	ld	ra,24(sp)
    80002720:	6442                	ld	s0,16(sp)
    80002722:	64a2                	ld	s1,8(sp)
    80002724:	6902                	ld	s2,0(sp)
    80002726:	6105                	addi	sp,sp,32
    80002728:	8082                	ret
    return -1;
    8000272a:	557d                	li	a0,-1
    8000272c:	bfcd                	j	8000271e <fetchaddr+0x36>
    8000272e:	557d                	li	a0,-1
    80002730:	b7fd                	j	8000271e <fetchaddr+0x36>

0000000080002732 <fetchstr>:
{
    80002732:	7179                	addi	sp,sp,-48
    80002734:	f406                	sd	ra,40(sp)
    80002736:	f022                	sd	s0,32(sp)
    80002738:	ec26                	sd	s1,24(sp)
    8000273a:	e84a                	sd	s2,16(sp)
    8000273c:	e44e                	sd	s3,8(sp)
    8000273e:	1800                	addi	s0,sp,48
    80002740:	892a                	mv	s2,a0
    80002742:	84ae                	mv	s1,a1
    80002744:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002746:	8c6ff0ef          	jal	ra,8000180c <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000274a:	86ce                	mv	a3,s3
    8000274c:	864a                	mv	a2,s2
    8000274e:	85a6                	mv	a1,s1
    80002750:	6928                	ld	a0,80(a0)
    80002752:	cbffe0ef          	jal	ra,80001410 <copyinstr>
    80002756:	00054c63          	bltz	a0,8000276e <fetchstr+0x3c>
  return strlen(buf);
    8000275a:	8526                	mv	a0,s1
    8000275c:	e5cfe0ef          	jal	ra,80000db8 <strlen>
}
    80002760:	70a2                	ld	ra,40(sp)
    80002762:	7402                	ld	s0,32(sp)
    80002764:	64e2                	ld	s1,24(sp)
    80002766:	6942                	ld	s2,16(sp)
    80002768:	69a2                	ld	s3,8(sp)
    8000276a:	6145                	addi	sp,sp,48
    8000276c:	8082                	ret
    return -1;
    8000276e:	557d                	li	a0,-1
    80002770:	bfc5                	j	80002760 <fetchstr+0x2e>

0000000080002772 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002772:	1101                	addi	sp,sp,-32
    80002774:	ec06                	sd	ra,24(sp)
    80002776:	e822                	sd	s0,16(sp)
    80002778:	e426                	sd	s1,8(sp)
    8000277a:	1000                	addi	s0,sp,32
    8000277c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000277e:	f0bff0ef          	jal	ra,80002688 <argraw>
    80002782:	c088                	sw	a0,0(s1)
}
    80002784:	60e2                	ld	ra,24(sp)
    80002786:	6442                	ld	s0,16(sp)
    80002788:	64a2                	ld	s1,8(sp)
    8000278a:	6105                	addi	sp,sp,32
    8000278c:	8082                	ret

000000008000278e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000278e:	1101                	addi	sp,sp,-32
    80002790:	ec06                	sd	ra,24(sp)
    80002792:	e822                	sd	s0,16(sp)
    80002794:	e426                	sd	s1,8(sp)
    80002796:	1000                	addi	s0,sp,32
    80002798:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000279a:	eefff0ef          	jal	ra,80002688 <argraw>
    8000279e:	e088                	sd	a0,0(s1)
}
    800027a0:	60e2                	ld	ra,24(sp)
    800027a2:	6442                	ld	s0,16(sp)
    800027a4:	64a2                	ld	s1,8(sp)
    800027a6:	6105                	addi	sp,sp,32
    800027a8:	8082                	ret

00000000800027aa <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027aa:	7179                	addi	sp,sp,-48
    800027ac:	f406                	sd	ra,40(sp)
    800027ae:	f022                	sd	s0,32(sp)
    800027b0:	ec26                	sd	s1,24(sp)
    800027b2:	e84a                	sd	s2,16(sp)
    800027b4:	1800                	addi	s0,sp,48
    800027b6:	84ae                	mv	s1,a1
    800027b8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800027ba:	fd840593          	addi	a1,s0,-40
    800027be:	fd1ff0ef          	jal	ra,8000278e <argaddr>
  return fetchstr(addr, buf, max);
    800027c2:	864a                	mv	a2,s2
    800027c4:	85a6                	mv	a1,s1
    800027c6:	fd843503          	ld	a0,-40(s0)
    800027ca:	f69ff0ef          	jal	ra,80002732 <fetchstr>
}
    800027ce:	70a2                	ld	ra,40(sp)
    800027d0:	7402                	ld	s0,32(sp)
    800027d2:	64e2                	ld	s1,24(sp)
    800027d4:	6942                	ld	s2,16(sp)
    800027d6:	6145                	addi	sp,sp,48
    800027d8:	8082                	ret

00000000800027da <syscall>:
[SYS_xtrace_end] sys_xtrace_end,
};

void
syscall(void)
{
    800027da:	1101                	addi	sp,sp,-32
    800027dc:	ec06                	sd	ra,24(sp)
    800027de:	e822                	sd	s0,16(sp)
    800027e0:	e426                	sd	s1,8(sp)
    800027e2:	e04a                	sd	s2,0(sp)
    800027e4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800027e6:	826ff0ef          	jal	ra,8000180c <myproc>
    800027ea:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800027ec:	6d3c                	ld	a5,88(a0)
    800027ee:	77dc                	ld	a5,168(a5)
    800027f0:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800027f4:	37fd                	addiw	a5,a5,-1
    800027f6:	4769                	li	a4,26
    800027f8:	04f76763          	bltu	a4,a5,80002846 <syscall+0x6c>
    800027fc:	00391713          	slli	a4,s2,0x3
    80002800:	00005797          	auipc	a5,0x5
    80002804:	c0878793          	addi	a5,a5,-1016 # 80007408 <syscalls>
    80002808:	97ba                	add	a5,a5,a4
    8000280a:	639c                	ld	a5,0(a5)
    8000280c:	cf8d                	beqz	a5,80002846 <syscall+0x6c>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    int ret= syscalls[num]();
    8000280e:	9782                	jalr	a5
    80002810:	2501                	sext.w	a0,a0
    p->trapframe->a0=ret;
    80002812:	6cbc                	ld	a5,88(s1)
    80002814:	fba8                	sd	a0,112(a5)
    if(p->xtrace && p->xtrace->active){
    80002816:	1704b783          	ld	a5,368(s1)
    8000281a:	c3b9                	beqz	a5,80002860 <syscall+0x86>
    8000281c:	4398                	lw	a4,0(a5)
    8000281e:	c329                	beqz	a4,80002860 <syscall+0x86>
    if(p->xtrace->n<100){
    80002820:	43d8                	lw	a4,4(a5)
    80002822:	06300693          	li	a3,99
    80002826:	02e6cd63          	blt	a3,a4,80002860 <syscall+0x86>
      int next=p->xtrace->n++;
    8000282a:	0017069b          	addiw	a3,a4,1
    8000282e:	c3d4                	sw	a3,4(a5)
      p->xtrace->list[next].sysno=num;
    80002830:	1704b783          	ld	a5,368(s1)
    80002834:	070e                	slli	a4,a4,0x3
    80002836:	97ba                	add	a5,a5,a4
    80002838:	0127a423          	sw	s2,8(a5)
      p->xtrace->list[next].sysret=ret;
    8000283c:	1704b783          	ld	a5,368(s1)
    80002840:	973e                	add	a4,a4,a5
    80002842:	c748                	sw	a0,12(a4)
    80002844:	a831                	j	80002860 <syscall+0x86>
    }
  }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002846:	86ca                	mv	a3,s2
    80002848:	15848613          	addi	a2,s1,344
    8000284c:	588c                	lw	a1,48(s1)
    8000284e:	00005517          	auipc	a0,0x5
    80002852:	b8250513          	addi	a0,a0,-1150 # 800073d0 <states.0+0x158>
    80002856:	c6ffd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000285a:	6cbc                	ld	a5,88(s1)
    8000285c:	577d                	li	a4,-1
    8000285e:	fbb8                	sd	a4,112(a5)
  }

  
}
    80002860:	60e2                	ld	ra,24(sp)
    80002862:	6442                	ld	s0,16(sp)
    80002864:	64a2                	ld	s1,8(sp)
    80002866:	6902                	ld	s2,0(sp)
    80002868:	6105                	addi	sp,sp,32
    8000286a:	8082                	ret

000000008000286c <sys_exit>:

extern struct proc proc[NPROC];

uint64
sys_exit(void)
{
    8000286c:	1101                	addi	sp,sp,-32
    8000286e:	ec06                	sd	ra,24(sp)
    80002870:	e822                	sd	s0,16(sp)
    80002872:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002874:	fec40593          	addi	a1,s0,-20
    80002878:	4501                	li	a0,0
    8000287a:	ef9ff0ef          	jal	ra,80002772 <argint>
  kexit(n);
    8000287e:	fec42503          	lw	a0,-20(s0)
    80002882:	eb4ff0ef          	jal	ra,80001f36 <kexit>
  return 0;  // not reached
}
    80002886:	4501                	li	a0,0
    80002888:	60e2                	ld	ra,24(sp)
    8000288a:	6442                	ld	s0,16(sp)
    8000288c:	6105                	addi	sp,sp,32
    8000288e:	8082                	ret

0000000080002890 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002890:	1141                	addi	sp,sp,-16
    80002892:	e406                	sd	ra,8(sp)
    80002894:	e022                	sd	s0,0(sp)
    80002896:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002898:	f75fe0ef          	jal	ra,8000180c <myproc>
}
    8000289c:	5908                	lw	a0,48(a0)
    8000289e:	60a2                	ld	ra,8(sp)
    800028a0:	6402                	ld	s0,0(sp)
    800028a2:	0141                	addi	sp,sp,16
    800028a4:	8082                	ret

00000000800028a6 <sys_fork>:

uint64
sys_fork(void)
{
    800028a6:	1101                	addi	sp,sp,-32
    800028a8:	ec06                	sd	ra,24(sp)
    800028aa:	e822                	sd	s0,16(sp)
    800028ac:	e426                	sd	s1,8(sp)
    800028ae:	1000                	addi	s0,sp,32
  int f=kfork();
    800028b0:	ad2ff0ef          	jal	ra,80001b82 <kfork>
    800028b4:	84aa                	mv	s1,a0
  myproc()->child_count++;
    800028b6:	f57fe0ef          	jal	ra,8000180c <myproc>
    800028ba:	16852783          	lw	a5,360(a0)
    800028be:	2785                	addiw	a5,a5,1
    800028c0:	16f52423          	sw	a5,360(a0)
  printf("fork: created child with pid: %d\n",f);
    800028c4:	85a6                	mv	a1,s1
    800028c6:	00005517          	auipc	a0,0x5
    800028ca:	c2250513          	addi	a0,a0,-990 # 800074e8 <syscalls+0xe0>
    800028ce:	bf7fd0ef          	jal	ra,800004c4 <printf>
  return f;
}
    800028d2:	8526                	mv	a0,s1
    800028d4:	60e2                	ld	ra,24(sp)
    800028d6:	6442                	ld	s0,16(sp)
    800028d8:	64a2                	ld	s1,8(sp)
    800028da:	6105                	addi	sp,sp,32
    800028dc:	8082                	ret

00000000800028de <sys_wait>:

uint64
sys_wait(void)
{
    800028de:	1101                	addi	sp,sp,-32
    800028e0:	ec06                	sd	ra,24(sp)
    800028e2:	e822                	sd	s0,16(sp)
    800028e4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028e6:	fe840593          	addi	a1,s0,-24
    800028ea:	4501                	li	a0,0
    800028ec:	ea3ff0ef          	jal	ra,8000278e <argaddr>
  if(myproc()->child_count>0){
    800028f0:	f1dfe0ef          	jal	ra,8000180c <myproc>
    800028f4:	16852783          	lw	a5,360(a0)
    800028f8:	02f05163          	blez	a5,8000291a <sys_wait+0x3c>
    myproc()->child_count--;
    800028fc:	f11fe0ef          	jal	ra,8000180c <myproc>
    80002900:	16852783          	lw	a5,360(a0)
    80002904:	37fd                	addiw	a5,a5,-1
    80002906:	16f52423          	sw	a5,360(a0)
  }
  else{
    myproc()->child_count=0;
  }
  return kwait(p);
    8000290a:	fe843503          	ld	a0,-24(s0)
    8000290e:	fc8ff0ef          	jal	ra,800020d6 <kwait>
}
    80002912:	60e2                	ld	ra,24(sp)
    80002914:	6442                	ld	s0,16(sp)
    80002916:	6105                	addi	sp,sp,32
    80002918:	8082                	ret
    myproc()->child_count=0;
    8000291a:	ef3fe0ef          	jal	ra,8000180c <myproc>
    8000291e:	16052423          	sw	zero,360(a0)
    80002922:	b7e5                	j	8000290a <sys_wait+0x2c>

0000000080002924 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002924:	7179                	addi	sp,sp,-48
    80002926:	f406                	sd	ra,40(sp)
    80002928:	f022                	sd	s0,32(sp)
    8000292a:	ec26                	sd	s1,24(sp)
    8000292c:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    8000292e:	fd840593          	addi	a1,s0,-40
    80002932:	4501                	li	a0,0
    80002934:	e3fff0ef          	jal	ra,80002772 <argint>
  argint(1, &t);
    80002938:	fdc40593          	addi	a1,s0,-36
    8000293c:	4505                	li	a0,1
    8000293e:	e35ff0ef          	jal	ra,80002772 <argint>
  addr = myproc()->sz;
    80002942:	ecbfe0ef          	jal	ra,8000180c <myproc>
    80002946:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002948:	fdc42703          	lw	a4,-36(s0)
    8000294c:	4785                	li	a5,1
    8000294e:	02f70763          	beq	a4,a5,8000297c <sys_sbrk+0x58>
    80002952:	fd842783          	lw	a5,-40(s0)
    80002956:	0207c363          	bltz	a5,8000297c <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    8000295a:	97a6                	add	a5,a5,s1
    8000295c:	0297ee63          	bltu	a5,s1,80002998 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002960:	02000737          	lui	a4,0x2000
    80002964:	177d                	addi	a4,a4,-1
    80002966:	0736                	slli	a4,a4,0xd
    80002968:	02f76a63          	bltu	a4,a5,8000299c <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    8000296c:	ea1fe0ef          	jal	ra,8000180c <myproc>
    80002970:	fd842703          	lw	a4,-40(s0)
    80002974:	653c                	ld	a5,72(a0)
    80002976:	97ba                	add	a5,a5,a4
    80002978:	e53c                	sd	a5,72(a0)
    8000297a:	a039                	j	80002988 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    8000297c:	fd842503          	lw	a0,-40(s0)
    80002980:	9a0ff0ef          	jal	ra,80001b20 <growproc>
    80002984:	00054863          	bltz	a0,80002994 <sys_sbrk+0x70>
  }
  return addr;
}
    80002988:	8526                	mv	a0,s1
    8000298a:	70a2                	ld	ra,40(sp)
    8000298c:	7402                	ld	s0,32(sp)
    8000298e:	64e2                	ld	s1,24(sp)
    80002990:	6145                	addi	sp,sp,48
    80002992:	8082                	ret
      return -1;
    80002994:	54fd                	li	s1,-1
    80002996:	bfcd                	j	80002988 <sys_sbrk+0x64>
      return -1;
    80002998:	54fd                	li	s1,-1
    8000299a:	b7fd                	j	80002988 <sys_sbrk+0x64>
      return -1;
    8000299c:	54fd                	li	s1,-1
    8000299e:	b7ed                	j	80002988 <sys_sbrk+0x64>

00000000800029a0 <sys_pause>:

uint64
sys_pause(void)
{
    800029a0:	7139                	addi	sp,sp,-64
    800029a2:	fc06                	sd	ra,56(sp)
    800029a4:	f822                	sd	s0,48(sp)
    800029a6:	f426                	sd	s1,40(sp)
    800029a8:	f04a                	sd	s2,32(sp)
    800029aa:	ec4e                	sd	s3,24(sp)
    800029ac:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029ae:	fcc40593          	addi	a1,s0,-52
    800029b2:	4501                	li	a0,0
    800029b4:	dbfff0ef          	jal	ra,80002772 <argint>
  if(n < 0)
    800029b8:	fcc42783          	lw	a5,-52(s0)
    800029bc:	0607c563          	bltz	a5,80002a26 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029c0:	00013517          	auipc	a0,0x13
    800029c4:	32850513          	addi	a0,a0,808 # 80015ce8 <tickslock>
    800029c8:	9a4fe0ef          	jal	ra,80000b6c <acquire>
  ticks0 = ticks;
    800029cc:	00005917          	auipc	s2,0x5
    800029d0:	fec92903          	lw	s2,-20(s2) # 800079b8 <ticks>
  while(ticks - ticks0 < n){
    800029d4:	fcc42783          	lw	a5,-52(s0)
    800029d8:	cb8d                	beqz	a5,80002a0a <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029da:	00013997          	auipc	s3,0x13
    800029de:	30e98993          	addi	s3,s3,782 # 80015ce8 <tickslock>
    800029e2:	00005497          	auipc	s1,0x5
    800029e6:	fd648493          	addi	s1,s1,-42 # 800079b8 <ticks>
    if(killed(myproc())){
    800029ea:	e23fe0ef          	jal	ra,8000180c <myproc>
    800029ee:	ebeff0ef          	jal	ra,800020ac <killed>
    800029f2:	ed0d                	bnez	a0,80002a2c <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800029f4:	85ce                	mv	a1,s3
    800029f6:	8526                	mv	a0,s1
    800029f8:	c32ff0ef          	jal	ra,80001e2a <sleep>
  while(ticks - ticks0 < n){
    800029fc:	409c                	lw	a5,0(s1)
    800029fe:	412787bb          	subw	a5,a5,s2
    80002a02:	fcc42703          	lw	a4,-52(s0)
    80002a06:	fee7e2e3          	bltu	a5,a4,800029ea <sys_pause+0x4a>
  }
  release(&tickslock);
    80002a0a:	00013517          	auipc	a0,0x13
    80002a0e:	2de50513          	addi	a0,a0,734 # 80015ce8 <tickslock>
    80002a12:	9f2fe0ef          	jal	ra,80000c04 <release>
  return 0;
    80002a16:	4501                	li	a0,0
}
    80002a18:	70e2                	ld	ra,56(sp)
    80002a1a:	7442                	ld	s0,48(sp)
    80002a1c:	74a2                	ld	s1,40(sp)
    80002a1e:	7902                	ld	s2,32(sp)
    80002a20:	69e2                	ld	s3,24(sp)
    80002a22:	6121                	addi	sp,sp,64
    80002a24:	8082                	ret
    n = 0;
    80002a26:	fc042623          	sw	zero,-52(s0)
    80002a2a:	bf59                	j	800029c0 <sys_pause+0x20>
      release(&tickslock);
    80002a2c:	00013517          	auipc	a0,0x13
    80002a30:	2bc50513          	addi	a0,a0,700 # 80015ce8 <tickslock>
    80002a34:	9d0fe0ef          	jal	ra,80000c04 <release>
      return -1;
    80002a38:	557d                	li	a0,-1
    80002a3a:	bff9                	j	80002a18 <sys_pause+0x78>

0000000080002a3c <sys_kill>:

uint64
sys_kill(void)
{
    80002a3c:	1101                	addi	sp,sp,-32
    80002a3e:	ec06                	sd	ra,24(sp)
    80002a40:	e822                	sd	s0,16(sp)
    80002a42:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a44:	fec40593          	addi	a1,s0,-20
    80002a48:	4501                	li	a0,0
    80002a4a:	d29ff0ef          	jal	ra,80002772 <argint>
  return kkill(pid);
    80002a4e:	fec42503          	lw	a0,-20(s0)
    80002a52:	dd0ff0ef          	jal	ra,80002022 <kkill>
}
    80002a56:	60e2                	ld	ra,24(sp)
    80002a58:	6442                	ld	s0,16(sp)
    80002a5a:	6105                	addi	sp,sp,32
    80002a5c:	8082                	ret

0000000080002a5e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a5e:	1101                	addi	sp,sp,-32
    80002a60:	ec06                	sd	ra,24(sp)
    80002a62:	e822                	sd	s0,16(sp)
    80002a64:	e426                	sd	s1,8(sp)
    80002a66:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a68:	00013517          	auipc	a0,0x13
    80002a6c:	28050513          	addi	a0,a0,640 # 80015ce8 <tickslock>
    80002a70:	8fcfe0ef          	jal	ra,80000b6c <acquire>
  xticks = ticks;
    80002a74:	00005497          	auipc	s1,0x5
    80002a78:	f444a483          	lw	s1,-188(s1) # 800079b8 <ticks>
  release(&tickslock);
    80002a7c:	00013517          	auipc	a0,0x13
    80002a80:	26c50513          	addi	a0,a0,620 # 80015ce8 <tickslock>
    80002a84:	980fe0ef          	jal	ra,80000c04 <release>
  return xticks;
}
    80002a88:	02049513          	slli	a0,s1,0x20
    80002a8c:	9101                	srli	a0,a0,0x20
    80002a8e:	60e2                	ld	ra,24(sp)
    80002a90:	6442                	ld	s0,16(sp)
    80002a92:	64a2                	ld	s1,8(sp)
    80002a94:	6105                	addi	sp,sp,32
    80002a96:	8082                	ret

0000000080002a98 <sys_knockknock>:

uint64
sys_knockknock(void)
{
    80002a98:	1141                	addi	sp,sp,-16
    80002a9a:	e406                	sd	ra,8(sp)
    80002a9c:	e022                	sd	s0,0(sp)
    80002a9e:	0800                	addi	s0,sp,16
  int p=myproc()->pid;
    80002aa0:	d6dfe0ef          	jal	ra,8000180c <myproc>
  printf("I am %d, Who's there?\n",p);
    80002aa4:	590c                	lw	a1,48(a0)
    80002aa6:	00005517          	auipc	a0,0x5
    80002aaa:	a6a50513          	addi	a0,a0,-1430 # 80007510 <syscalls+0x108>
    80002aae:	a17fd0ef          	jal	ra,800004c4 <printf>
  return 0;
}
    80002ab2:	4501                	li	a0,0
    80002ab4:	60a2                	ld	ra,8(sp)
    80002ab6:	6402                	ld	s0,0(sp)
    80002ab8:	0141                	addi	sp,sp,16
    80002aba:	8082                	ret

0000000080002abc <sys_getProcessStates>:

uint64
sys_getProcessStates(void)
{
    80002abc:	7179                	addi	sp,sp,-48
    80002abe:	f406                	sd	ra,40(sp)
    80002ac0:	f022                	sd	s0,32(sp)
    80002ac2:	ec26                	sd	s1,24(sp)
    80002ac4:	e84a                	sd	s2,16(sp)
    80002ac6:	e44e                	sd	s3,8(sp)
    80002ac8:	e052                	sd	s4,0(sp)
    80002aca:	1800                	addi	s0,sp,48
    [RUNNABLE]  "runble",
    [RUNNING]   "run   ",
    [ZOMBIE]    "zombie"
  };
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    80002acc:	0000d497          	auipc	s1,0xd
    80002ad0:	41c48493          	addi	s1,s1,1052 # 8000fee8 <proc>
    acquire(&p->lock);
    if(p->state != UNUSED) {
      printf("Process %d was found in %s state\n",p->pid,states[p->state]);
    80002ad4:	00005a17          	auipc	s4,0x5
    80002ad8:	acca0a13          	addi	s4,s4,-1332 # 800075a0 <states.1>
    80002adc:	00005997          	auipc	s3,0x5
    80002ae0:	a4c98993          	addi	s3,s3,-1460 # 80007528 <syscalls+0x120>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002ae4:	00013917          	auipc	s2,0x13
    80002ae8:	20490913          	addi	s2,s2,516 # 80015ce8 <tickslock>
    80002aec:	a801                	j	80002afc <sys_getProcessStates+0x40>
    }
    release(&p->lock);
    80002aee:	8526                	mv	a0,s1
    80002af0:	914fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002af4:	17848493          	addi	s1,s1,376
    80002af8:	03248163          	beq	s1,s2,80002b1a <sys_getProcessStates+0x5e>
    acquire(&p->lock);
    80002afc:	8526                	mv	a0,s1
    80002afe:	86efe0ef          	jal	ra,80000b6c <acquire>
    if(p->state != UNUSED) {
    80002b02:	4c9c                	lw	a5,24(s1)
    80002b04:	d7ed                	beqz	a5,80002aee <sys_getProcessStates+0x32>
      printf("Process %d was found in %s state\n",p->pid,states[p->state]);
    80002b06:	1782                	slli	a5,a5,0x20
    80002b08:	9381                	srli	a5,a5,0x20
    80002b0a:	078e                	slli	a5,a5,0x3
    80002b0c:	97d2                	add	a5,a5,s4
    80002b0e:	6390                	ld	a2,0(a5)
    80002b10:	588c                	lw	a1,48(s1)
    80002b12:	854e                	mv	a0,s3
    80002b14:	9b1fd0ef          	jal	ra,800004c4 <printf>
    80002b18:	bfd9                	j	80002aee <sys_getProcessStates+0x32>
  }
  
  return 0;
}
    80002b1a:	4501                	li	a0,0
    80002b1c:	70a2                	ld	ra,40(sp)
    80002b1e:	7402                	ld	s0,32(sp)
    80002b20:	64e2                	ld	s1,24(sp)
    80002b22:	6942                	ld	s2,16(sp)
    80002b24:	69a2                	ld	s3,8(sp)
    80002b26:	6a02                	ld	s4,0(sp)
    80002b28:	6145                	addi	sp,sp,48
    80002b2a:	8082                	ret

0000000080002b2c <sys_areYouThere>:

uint64
sys_areYouThere(void)
{
    80002b2c:	7179                	addi	sp,sp,-48
    80002b2e:	f406                	sd	ra,40(sp)
    80002b30:	f022                	sd	s0,32(sp)
    80002b32:	ec26                	sd	s1,24(sp)
    80002b34:	e84a                	sd	s2,16(sp)
    80002b36:	1800                	addi	s0,sp,48
  int n;
  argint(0, &n);
    80002b38:	fdc40593          	addi	a1,s0,-36
    80002b3c:	4501                	li	a0,0
    80002b3e:	c35ff0ef          	jal	ra,80002772 <argint>
    [RUNNABLE]  "runble",
    [RUNNING]   "run   ",
    [ZOMBIE]    "zombie"
  };
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    80002b42:	0000d497          	auipc	s1,0xd
    80002b46:	3a648493          	addi	s1,s1,934 # 8000fee8 <proc>
    80002b4a:	00013917          	auipc	s2,0x13
    80002b4e:	19e90913          	addi	s2,s2,414 # 80015ce8 <tickslock>
    acquire(&p->lock);
    80002b52:	8526                	mv	a0,s1
    80002b54:	818fe0ef          	jal	ra,80000b6c <acquire>
    if(p->pid == n) {
    80002b58:	fdc42583          	lw	a1,-36(s0)
    80002b5c:	589c                	lw	a5,48(s1)
    80002b5e:	02b78263          	beq	a5,a1,80002b82 <sys_areYouThere+0x56>
      printf("I am %d in %s state\n",p->pid,states[p->state]);
      release(&p->lock);
      return 0;
    } 
    release(&p->lock);
    80002b62:	8526                	mv	a0,s1
    80002b64:	8a0fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002b68:	17848493          	addi	s1,s1,376
    80002b6c:	ff2493e3          	bne	s1,s2,80002b52 <sys_areYouThere+0x26>
  }
  printf("%d has gone missing\n",n);
    80002b70:	fdc42583          	lw	a1,-36(s0)
    80002b74:	00005517          	auipc	a0,0x5
    80002b78:	9f450513          	addi	a0,a0,-1548 # 80007568 <syscalls+0x160>
    80002b7c:	949fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    80002b80:	a025                	j	80002ba8 <sys_areYouThere+0x7c>
      printf("I am %d in %s state\n",p->pid,states[p->state]);
    80002b82:	0184e783          	lwu	a5,24(s1)
    80002b86:	00379713          	slli	a4,a5,0x3
    80002b8a:	00005797          	auipc	a5,0x5
    80002b8e:	a1678793          	addi	a5,a5,-1514 # 800075a0 <states.1>
    80002b92:	97ba                	add	a5,a5,a4
    80002b94:	7b90                	ld	a2,48(a5)
    80002b96:	00005517          	auipc	a0,0x5
    80002b9a:	9ba50513          	addi	a0,a0,-1606 # 80007550 <syscalls+0x148>
    80002b9e:	927fd0ef          	jal	ra,800004c4 <printf>
      release(&p->lock);
    80002ba2:	8526                	mv	a0,s1
    80002ba4:	860fe0ef          	jal	ra,80000c04 <release>
}
    80002ba8:	4501                	li	a0,0
    80002baa:	70a2                	ld	ra,40(sp)
    80002bac:	7402                	ld	s0,32(sp)
    80002bae:	64e2                	ld	s1,24(sp)
    80002bb0:	6942                	ld	s2,16(sp)
    80002bb2:	6145                	addi	sp,sp,48
    80002bb4:	8082                	ret

0000000080002bb6 <sys_getChildCount>:

uint64
sys_getChildCount(void)
{
    80002bb6:	1141                	addi	sp,sp,-16
    80002bb8:	e406                	sd	ra,8(sp)
    80002bba:	e022                	sd	s0,0(sp)
    80002bbc:	0800                	addi	s0,sp,16
  return myproc()->child_count;
    80002bbe:	c4ffe0ef          	jal	ra,8000180c <myproc>
}
    80002bc2:	16852503          	lw	a0,360(a0)
    80002bc6:	60a2                	ld	ra,8(sp)
    80002bc8:	6402                	ld	s0,0(sp)
    80002bca:	0141                	addi	sp,sp,16
    80002bcc:	8082                	ret

0000000080002bce <sys_xtrace_start>:

uint64
sys_xtrace_start(void)
{
    80002bce:	1101                	addi	sp,sp,-32
    80002bd0:	ec06                	sd	ra,24(sp)
    80002bd2:	e822                	sd	s0,16(sp)
    80002bd4:	e426                	sd	s1,8(sp)
    80002bd6:	1000                	addi	s0,sp,32
  struct proc *p= myproc();
    80002bd8:	c35fe0ef          	jal	ra,8000180c <myproc>
    80002bdc:	84aa                	mv	s1,a0
  if(p->xtrace && p->xtrace->active){
    80002bde:	17053783          	ld	a5,368(a0)
    80002be2:	cb89                	beqz	a5,80002bf4 <sys_xtrace_start+0x26>
    80002be4:	4398                	lw	a4,0(a5)
    return -1;
    80002be6:	557d                	li	a0,-1
  if(p->xtrace && p->xtrace->active){
    80002be8:	e30d                	bnez	a4,80002c0a <sys_xtrace_start+0x3c>
  }
  if(p->xtrace){
    kfree((void*)p->xtrace);
    80002bea:	853e                	mv	a0,a5
    80002bec:	dd1fd0ef          	jal	ra,800009bc <kfree>
    p->xtrace = 0;
    80002bf0:	1604b823          	sd	zero,368(s1)
  }
  p->xtrace=(struct xtrace*)kalloc();
    80002bf4:	ea9fd0ef          	jal	ra,80000a9c <kalloc>
    80002bf8:	16a4b823          	sd	a0,368(s1)
  p->xtrace->active=1;
    80002bfc:	4785                	li	a5,1
    80002bfe:	c11c                	sw	a5,0(a0)
  p->xtrace->n=0;
    80002c00:	1704b783          	ld	a5,368(s1)
    80002c04:	0007a223          	sw	zero,4(a5)
  return 0;
    80002c08:	4501                	li	a0,0
}
    80002c0a:	60e2                	ld	ra,24(sp)
    80002c0c:	6442                	ld	s0,16(sp)
    80002c0e:	64a2                	ld	s1,8(sp)
    80002c10:	6105                	addi	sp,sp,32
    80002c12:	8082                	ret

0000000080002c14 <sys_xtrace_end>:

uint64
sys_xtrace_end(void)
{
    80002c14:	7179                	addi	sp,sp,-48
    80002c16:	f406                	sd	ra,40(sp)
    80002c18:	f022                	sd	s0,32(sp)
    80002c1a:	ec26                	sd	s1,24(sp)
    80002c1c:	e84a                	sd	s2,16(sp)
    80002c1e:	e44e                	sd	s3,8(sp)
    80002c20:	e052                	sd	s4,0(sp)
    80002c22:	1800                	addi	s0,sp,48
  struct proc *p= myproc();
    80002c24:	be9fe0ef          	jal	ra,8000180c <myproc>
  if(p->xtrace==0 || p->xtrace->active==0){
    80002c28:	17053783          	ld	a5,368(a0)
    80002c2c:	c7b5                	beqz	a5,80002c98 <sys_xtrace_end+0x84>
    80002c2e:	892a                	mv	s2,a0
    80002c30:	4398                	lw	a4,0(a5)
    return -1;
    80002c32:	557d                	li	a0,-1
  if(p->xtrace==0 || p->xtrace->active==0){
    80002c34:	cb31                	beqz	a4,80002c88 <sys_xtrace_end+0x74>
  }
  p->xtrace->active = 0;
    80002c36:	0007a023          	sw	zero,0(a5)
  int num=p->xtrace->n;
    80002c3a:	17093783          	ld	a5,368(s2)
    80002c3e:	0047a983          	lw	s3,4(a5)
  printf("Syscall Trace for PID %d :\n",p->pid);
    80002c42:	03092583          	lw	a1,48(s2)
    80002c46:	00005517          	auipc	a0,0x5
    80002c4a:	93a50513          	addi	a0,a0,-1734 # 80007580 <syscalls+0x178>
    80002c4e:	877fd0ef          	jal	ra,800004c4 <printf>
  for(int i=0;i<num;i++){
    80002c52:	03305463          	blez	s3,80002c7a <sys_xtrace_end+0x66>
    80002c56:	4481                	li	s1,0
    printf("Syscall %d returned %d\n",p->xtrace->list[i].sysno,p->xtrace->list[i].sysret);
    80002c58:	00004a17          	auipc	s4,0x4
    80002c5c:	5b0a0a13          	addi	s4,s4,1456 # 80007208 <digits+0x1d0>
    80002c60:	00349713          	slli	a4,s1,0x3
    80002c64:	17093783          	ld	a5,368(s2)
    80002c68:	97ba                	add	a5,a5,a4
    80002c6a:	47d0                	lw	a2,12(a5)
    80002c6c:	478c                	lw	a1,8(a5)
    80002c6e:	8552                	mv	a0,s4
    80002c70:	855fd0ef          	jal	ra,800004c4 <printf>
  for(int i=0;i<num;i++){
    80002c74:	2485                	addiw	s1,s1,1
    80002c76:	fe9995e3          	bne	s3,s1,80002c60 <sys_xtrace_end+0x4c>
  }
  kfree((void*)p->xtrace);
    80002c7a:	17093503          	ld	a0,368(s2)
    80002c7e:	d3ffd0ef          	jal	ra,800009bc <kfree>
  p->xtrace = 0;
    80002c82:	16093823          	sd	zero,368(s2)
  return num;
    80002c86:	854e                	mv	a0,s3
    80002c88:	70a2                	ld	ra,40(sp)
    80002c8a:	7402                	ld	s0,32(sp)
    80002c8c:	64e2                	ld	s1,24(sp)
    80002c8e:	6942                	ld	s2,16(sp)
    80002c90:	69a2                	ld	s3,8(sp)
    80002c92:	6a02                	ld	s4,0(sp)
    80002c94:	6145                	addi	sp,sp,48
    80002c96:	8082                	ret
    return -1;
    80002c98:	557d                	li	a0,-1
    80002c9a:	b7fd                	j	80002c88 <sys_xtrace_end+0x74>

0000000080002c9c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c9c:	7179                	addi	sp,sp,-48
    80002c9e:	f406                	sd	ra,40(sp)
    80002ca0:	f022                	sd	s0,32(sp)
    80002ca2:	ec26                	sd	s1,24(sp)
    80002ca4:	e84a                	sd	s2,16(sp)
    80002ca6:	e44e                	sd	s3,8(sp)
    80002ca8:	e052                	sd	s4,0(sp)
    80002caa:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002cac:	00005597          	auipc	a1,0x5
    80002cb0:	95458593          	addi	a1,a1,-1708 # 80007600 <states.0+0x30>
    80002cb4:	00013517          	auipc	a0,0x13
    80002cb8:	04c50513          	addi	a0,a0,76 # 80015d00 <bcache>
    80002cbc:	e31fd0ef          	jal	ra,80000aec <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002cc0:	0001b797          	auipc	a5,0x1b
    80002cc4:	04078793          	addi	a5,a5,64 # 8001dd00 <bcache+0x8000>
    80002cc8:	0001b717          	auipc	a4,0x1b
    80002ccc:	2a070713          	addi	a4,a4,672 # 8001df68 <bcache+0x8268>
    80002cd0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002cd4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002cd8:	00013497          	auipc	s1,0x13
    80002cdc:	04048493          	addi	s1,s1,64 # 80015d18 <bcache+0x18>
    b->next = bcache.head.next;
    80002ce0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ce2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ce4:	00005a17          	auipc	s4,0x5
    80002ce8:	924a0a13          	addi	s4,s4,-1756 # 80007608 <states.0+0x38>
    b->next = bcache.head.next;
    80002cec:	2b893783          	ld	a5,696(s2)
    80002cf0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002cf2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002cf6:	85d2                	mv	a1,s4
    80002cf8:	01048513          	addi	a0,s1,16
    80002cfc:	2fe010ef          	jal	ra,80003ffa <initsleeplock>
    bcache.head.next->prev = b;
    80002d00:	2b893783          	ld	a5,696(s2)
    80002d04:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d06:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d0a:	45848493          	addi	s1,s1,1112
    80002d0e:	fd349fe3          	bne	s1,s3,80002cec <binit+0x50>
  }
}
    80002d12:	70a2                	ld	ra,40(sp)
    80002d14:	7402                	ld	s0,32(sp)
    80002d16:	64e2                	ld	s1,24(sp)
    80002d18:	6942                	ld	s2,16(sp)
    80002d1a:	69a2                	ld	s3,8(sp)
    80002d1c:	6a02                	ld	s4,0(sp)
    80002d1e:	6145                	addi	sp,sp,48
    80002d20:	8082                	ret

0000000080002d22 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002d22:	7179                	addi	sp,sp,-48
    80002d24:	f406                	sd	ra,40(sp)
    80002d26:	f022                	sd	s0,32(sp)
    80002d28:	ec26                	sd	s1,24(sp)
    80002d2a:	e84a                	sd	s2,16(sp)
    80002d2c:	e44e                	sd	s3,8(sp)
    80002d2e:	1800                	addi	s0,sp,48
    80002d30:	892a                	mv	s2,a0
    80002d32:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d34:	00013517          	auipc	a0,0x13
    80002d38:	fcc50513          	addi	a0,a0,-52 # 80015d00 <bcache>
    80002d3c:	e31fd0ef          	jal	ra,80000b6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002d40:	0001b497          	auipc	s1,0x1b
    80002d44:	2784b483          	ld	s1,632(s1) # 8001dfb8 <bcache+0x82b8>
    80002d48:	0001b797          	auipc	a5,0x1b
    80002d4c:	22078793          	addi	a5,a5,544 # 8001df68 <bcache+0x8268>
    80002d50:	02f48b63          	beq	s1,a5,80002d86 <bread+0x64>
    80002d54:	873e                	mv	a4,a5
    80002d56:	a021                	j	80002d5e <bread+0x3c>
    80002d58:	68a4                	ld	s1,80(s1)
    80002d5a:	02e48663          	beq	s1,a4,80002d86 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d5e:	449c                	lw	a5,8(s1)
    80002d60:	ff279ce3          	bne	a5,s2,80002d58 <bread+0x36>
    80002d64:	44dc                	lw	a5,12(s1)
    80002d66:	ff3799e3          	bne	a5,s3,80002d58 <bread+0x36>
      b->refcnt++;
    80002d6a:	40bc                	lw	a5,64(s1)
    80002d6c:	2785                	addiw	a5,a5,1
    80002d6e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d70:	00013517          	auipc	a0,0x13
    80002d74:	f9050513          	addi	a0,a0,-112 # 80015d00 <bcache>
    80002d78:	e8dfd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002d7c:	01048513          	addi	a0,s1,16
    80002d80:	2b0010ef          	jal	ra,80004030 <acquiresleep>
      return b;
    80002d84:	a889                	j	80002dd6 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d86:	0001b497          	auipc	s1,0x1b
    80002d8a:	22a4b483          	ld	s1,554(s1) # 8001dfb0 <bcache+0x82b0>
    80002d8e:	0001b797          	auipc	a5,0x1b
    80002d92:	1da78793          	addi	a5,a5,474 # 8001df68 <bcache+0x8268>
    80002d96:	00f48863          	beq	s1,a5,80002da6 <bread+0x84>
    80002d9a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d9c:	40bc                	lw	a5,64(s1)
    80002d9e:	cb91                	beqz	a5,80002db2 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002da0:	64a4                	ld	s1,72(s1)
    80002da2:	fee49de3          	bne	s1,a4,80002d9c <bread+0x7a>
  panic("bget: no buffers");
    80002da6:	00005517          	auipc	a0,0x5
    80002daa:	86a50513          	addi	a0,a0,-1942 # 80007610 <states.0+0x40>
    80002dae:	9ddfd0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    80002db2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002db6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002dba:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002dbe:	4785                	li	a5,1
    80002dc0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dc2:	00013517          	auipc	a0,0x13
    80002dc6:	f3e50513          	addi	a0,a0,-194 # 80015d00 <bcache>
    80002dca:	e3bfd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002dce:	01048513          	addi	a0,s1,16
    80002dd2:	25e010ef          	jal	ra,80004030 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002dd6:	409c                	lw	a5,0(s1)
    80002dd8:	cb89                	beqz	a5,80002dea <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002dda:	8526                	mv	a0,s1
    80002ddc:	70a2                	ld	ra,40(sp)
    80002dde:	7402                	ld	s0,32(sp)
    80002de0:	64e2                	ld	s1,24(sp)
    80002de2:	6942                	ld	s2,16(sp)
    80002de4:	69a2                	ld	s3,8(sp)
    80002de6:	6145                	addi	sp,sp,48
    80002de8:	8082                	ret
    virtio_disk_rw(b, 0);
    80002dea:	4581                	li	a1,0
    80002dec:	8526                	mv	a0,s1
    80002dee:	1af020ef          	jal	ra,8000579c <virtio_disk_rw>
    b->valid = 1;
    80002df2:	4785                	li	a5,1
    80002df4:	c09c                	sw	a5,0(s1)
  return b;
    80002df6:	b7d5                	j	80002dda <bread+0xb8>

0000000080002df8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002df8:	1101                	addi	sp,sp,-32
    80002dfa:	ec06                	sd	ra,24(sp)
    80002dfc:	e822                	sd	s0,16(sp)
    80002dfe:	e426                	sd	s1,8(sp)
    80002e00:	1000                	addi	s0,sp,32
    80002e02:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e04:	0541                	addi	a0,a0,16
    80002e06:	2a8010ef          	jal	ra,800040ae <holdingsleep>
    80002e0a:	c911                	beqz	a0,80002e1e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e0c:	4585                	li	a1,1
    80002e0e:	8526                	mv	a0,s1
    80002e10:	18d020ef          	jal	ra,8000579c <virtio_disk_rw>
}
    80002e14:	60e2                	ld	ra,24(sp)
    80002e16:	6442                	ld	s0,16(sp)
    80002e18:	64a2                	ld	s1,8(sp)
    80002e1a:	6105                	addi	sp,sp,32
    80002e1c:	8082                	ret
    panic("bwrite");
    80002e1e:	00005517          	auipc	a0,0x5
    80002e22:	80a50513          	addi	a0,a0,-2038 # 80007628 <states.0+0x58>
    80002e26:	965fd0ef          	jal	ra,8000078a <panic>

0000000080002e2a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e2a:	1101                	addi	sp,sp,-32
    80002e2c:	ec06                	sd	ra,24(sp)
    80002e2e:	e822                	sd	s0,16(sp)
    80002e30:	e426                	sd	s1,8(sp)
    80002e32:	e04a                	sd	s2,0(sp)
    80002e34:	1000                	addi	s0,sp,32
    80002e36:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e38:	01050913          	addi	s2,a0,16
    80002e3c:	854a                	mv	a0,s2
    80002e3e:	270010ef          	jal	ra,800040ae <holdingsleep>
    80002e42:	c13d                	beqz	a0,80002ea8 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002e44:	854a                	mv	a0,s2
    80002e46:	230010ef          	jal	ra,80004076 <releasesleep>

  acquire(&bcache.lock);
    80002e4a:	00013517          	auipc	a0,0x13
    80002e4e:	eb650513          	addi	a0,a0,-330 # 80015d00 <bcache>
    80002e52:	d1bfd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002e56:	40bc                	lw	a5,64(s1)
    80002e58:	37fd                	addiw	a5,a5,-1
    80002e5a:	0007871b          	sext.w	a4,a5
    80002e5e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e60:	eb05                	bnez	a4,80002e90 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e62:	68bc                	ld	a5,80(s1)
    80002e64:	64b8                	ld	a4,72(s1)
    80002e66:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002e68:	64bc                	ld	a5,72(s1)
    80002e6a:	68b8                	ld	a4,80(s1)
    80002e6c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e6e:	0001b797          	auipc	a5,0x1b
    80002e72:	e9278793          	addi	a5,a5,-366 # 8001dd00 <bcache+0x8000>
    80002e76:	2b87b703          	ld	a4,696(a5)
    80002e7a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e7c:	0001b717          	auipc	a4,0x1b
    80002e80:	0ec70713          	addi	a4,a4,236 # 8001df68 <bcache+0x8268>
    80002e84:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e86:	2b87b703          	ld	a4,696(a5)
    80002e8a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e8c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002e90:	00013517          	auipc	a0,0x13
    80002e94:	e7050513          	addi	a0,a0,-400 # 80015d00 <bcache>
    80002e98:	d6dfd0ef          	jal	ra,80000c04 <release>
}
    80002e9c:	60e2                	ld	ra,24(sp)
    80002e9e:	6442                	ld	s0,16(sp)
    80002ea0:	64a2                	ld	s1,8(sp)
    80002ea2:	6902                	ld	s2,0(sp)
    80002ea4:	6105                	addi	sp,sp,32
    80002ea6:	8082                	ret
    panic("brelse");
    80002ea8:	00004517          	auipc	a0,0x4
    80002eac:	78850513          	addi	a0,a0,1928 # 80007630 <states.0+0x60>
    80002eb0:	8dbfd0ef          	jal	ra,8000078a <panic>

0000000080002eb4 <bpin>:

void
bpin(struct buf *b) {
    80002eb4:	1101                	addi	sp,sp,-32
    80002eb6:	ec06                	sd	ra,24(sp)
    80002eb8:	e822                	sd	s0,16(sp)
    80002eba:	e426                	sd	s1,8(sp)
    80002ebc:	1000                	addi	s0,sp,32
    80002ebe:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ec0:	00013517          	auipc	a0,0x13
    80002ec4:	e4050513          	addi	a0,a0,-448 # 80015d00 <bcache>
    80002ec8:	ca5fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt++;
    80002ecc:	40bc                	lw	a5,64(s1)
    80002ece:	2785                	addiw	a5,a5,1
    80002ed0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ed2:	00013517          	auipc	a0,0x13
    80002ed6:	e2e50513          	addi	a0,a0,-466 # 80015d00 <bcache>
    80002eda:	d2bfd0ef          	jal	ra,80000c04 <release>
}
    80002ede:	60e2                	ld	ra,24(sp)
    80002ee0:	6442                	ld	s0,16(sp)
    80002ee2:	64a2                	ld	s1,8(sp)
    80002ee4:	6105                	addi	sp,sp,32
    80002ee6:	8082                	ret

0000000080002ee8 <bunpin>:

void
bunpin(struct buf *b) {
    80002ee8:	1101                	addi	sp,sp,-32
    80002eea:	ec06                	sd	ra,24(sp)
    80002eec:	e822                	sd	s0,16(sp)
    80002eee:	e426                	sd	s1,8(sp)
    80002ef0:	1000                	addi	s0,sp,32
    80002ef2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ef4:	00013517          	auipc	a0,0x13
    80002ef8:	e0c50513          	addi	a0,a0,-500 # 80015d00 <bcache>
    80002efc:	c71fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002f00:	40bc                	lw	a5,64(s1)
    80002f02:	37fd                	addiw	a5,a5,-1
    80002f04:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f06:	00013517          	auipc	a0,0x13
    80002f0a:	dfa50513          	addi	a0,a0,-518 # 80015d00 <bcache>
    80002f0e:	cf7fd0ef          	jal	ra,80000c04 <release>
}
    80002f12:	60e2                	ld	ra,24(sp)
    80002f14:	6442                	ld	s0,16(sp)
    80002f16:	64a2                	ld	s1,8(sp)
    80002f18:	6105                	addi	sp,sp,32
    80002f1a:	8082                	ret

0000000080002f1c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f1c:	1101                	addi	sp,sp,-32
    80002f1e:	ec06                	sd	ra,24(sp)
    80002f20:	e822                	sd	s0,16(sp)
    80002f22:	e426                	sd	s1,8(sp)
    80002f24:	e04a                	sd	s2,0(sp)
    80002f26:	1000                	addi	s0,sp,32
    80002f28:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f2a:	00d5d59b          	srliw	a1,a1,0xd
    80002f2e:	0001b797          	auipc	a5,0x1b
    80002f32:	4ae7a783          	lw	a5,1198(a5) # 8001e3dc <sb+0x1c>
    80002f36:	9dbd                	addw	a1,a1,a5
    80002f38:	debff0ef          	jal	ra,80002d22 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f3c:	0074f713          	andi	a4,s1,7
    80002f40:	4785                	li	a5,1
    80002f42:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002f46:	14ce                	slli	s1,s1,0x33
    80002f48:	90d9                	srli	s1,s1,0x36
    80002f4a:	00950733          	add	a4,a0,s1
    80002f4e:	05874703          	lbu	a4,88(a4)
    80002f52:	00e7f6b3          	and	a3,a5,a4
    80002f56:	c29d                	beqz	a3,80002f7c <bfree+0x60>
    80002f58:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f5a:	94aa                	add	s1,s1,a0
    80002f5c:	fff7c793          	not	a5,a5
    80002f60:	8ff9                	and	a5,a5,a4
    80002f62:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002f66:	7d1000ef          	jal	ra,80003f36 <log_write>
  brelse(bp);
    80002f6a:	854a                	mv	a0,s2
    80002f6c:	ebfff0ef          	jal	ra,80002e2a <brelse>
}
    80002f70:	60e2                	ld	ra,24(sp)
    80002f72:	6442                	ld	s0,16(sp)
    80002f74:	64a2                	ld	s1,8(sp)
    80002f76:	6902                	ld	s2,0(sp)
    80002f78:	6105                	addi	sp,sp,32
    80002f7a:	8082                	ret
    panic("freeing free block");
    80002f7c:	00004517          	auipc	a0,0x4
    80002f80:	6bc50513          	addi	a0,a0,1724 # 80007638 <states.0+0x68>
    80002f84:	807fd0ef          	jal	ra,8000078a <panic>

0000000080002f88 <balloc>:
{
    80002f88:	711d                	addi	sp,sp,-96
    80002f8a:	ec86                	sd	ra,88(sp)
    80002f8c:	e8a2                	sd	s0,80(sp)
    80002f8e:	e4a6                	sd	s1,72(sp)
    80002f90:	e0ca                	sd	s2,64(sp)
    80002f92:	fc4e                	sd	s3,56(sp)
    80002f94:	f852                	sd	s4,48(sp)
    80002f96:	f456                	sd	s5,40(sp)
    80002f98:	f05a                	sd	s6,32(sp)
    80002f9a:	ec5e                	sd	s7,24(sp)
    80002f9c:	e862                	sd	s8,16(sp)
    80002f9e:	e466                	sd	s9,8(sp)
    80002fa0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002fa2:	0001b797          	auipc	a5,0x1b
    80002fa6:	4227a783          	lw	a5,1058(a5) # 8001e3c4 <sb+0x4>
    80002faa:	0e078163          	beqz	a5,8000308c <balloc+0x104>
    80002fae:	8baa                	mv	s7,a0
    80002fb0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002fb2:	0001bb17          	auipc	s6,0x1b
    80002fb6:	40eb0b13          	addi	s6,s6,1038 # 8001e3c0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fba:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002fbc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fbe:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002fc0:	6c89                	lui	s9,0x2
    80002fc2:	a0b5                	j	8000302e <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002fc4:	974a                	add	a4,a4,s2
    80002fc6:	8fd5                	or	a5,a5,a3
    80002fc8:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002fcc:	854a                	mv	a0,s2
    80002fce:	769000ef          	jal	ra,80003f36 <log_write>
        brelse(bp);
    80002fd2:	854a                	mv	a0,s2
    80002fd4:	e57ff0ef          	jal	ra,80002e2a <brelse>
  bp = bread(dev, bno);
    80002fd8:	85a6                	mv	a1,s1
    80002fda:	855e                	mv	a0,s7
    80002fdc:	d47ff0ef          	jal	ra,80002d22 <bread>
    80002fe0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002fe2:	40000613          	li	a2,1024
    80002fe6:	4581                	li	a1,0
    80002fe8:	05850513          	addi	a0,a0,88
    80002fec:	c55fd0ef          	jal	ra,80000c40 <memset>
  log_write(bp);
    80002ff0:	854a                	mv	a0,s2
    80002ff2:	745000ef          	jal	ra,80003f36 <log_write>
  brelse(bp);
    80002ff6:	854a                	mv	a0,s2
    80002ff8:	e33ff0ef          	jal	ra,80002e2a <brelse>
}
    80002ffc:	8526                	mv	a0,s1
    80002ffe:	60e6                	ld	ra,88(sp)
    80003000:	6446                	ld	s0,80(sp)
    80003002:	64a6                	ld	s1,72(sp)
    80003004:	6906                	ld	s2,64(sp)
    80003006:	79e2                	ld	s3,56(sp)
    80003008:	7a42                	ld	s4,48(sp)
    8000300a:	7aa2                	ld	s5,40(sp)
    8000300c:	7b02                	ld	s6,32(sp)
    8000300e:	6be2                	ld	s7,24(sp)
    80003010:	6c42                	ld	s8,16(sp)
    80003012:	6ca2                	ld	s9,8(sp)
    80003014:	6125                	addi	sp,sp,96
    80003016:	8082                	ret
    brelse(bp);
    80003018:	854a                	mv	a0,s2
    8000301a:	e11ff0ef          	jal	ra,80002e2a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000301e:	015c87bb          	addw	a5,s9,s5
    80003022:	00078a9b          	sext.w	s5,a5
    80003026:	004b2703          	lw	a4,4(s6)
    8000302a:	06eaf163          	bgeu	s5,a4,8000308c <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    8000302e:	41fad79b          	sraiw	a5,s5,0x1f
    80003032:	0137d79b          	srliw	a5,a5,0x13
    80003036:	015787bb          	addw	a5,a5,s5
    8000303a:	40d7d79b          	sraiw	a5,a5,0xd
    8000303e:	01cb2583          	lw	a1,28(s6)
    80003042:	9dbd                	addw	a1,a1,a5
    80003044:	855e                	mv	a0,s7
    80003046:	cddff0ef          	jal	ra,80002d22 <bread>
    8000304a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000304c:	004b2503          	lw	a0,4(s6)
    80003050:	000a849b          	sext.w	s1,s5
    80003054:	8662                	mv	a2,s8
    80003056:	fca4f1e3          	bgeu	s1,a0,80003018 <balloc+0x90>
      m = 1 << (bi % 8);
    8000305a:	41f6579b          	sraiw	a5,a2,0x1f
    8000305e:	01d7d69b          	srliw	a3,a5,0x1d
    80003062:	00c6873b          	addw	a4,a3,a2
    80003066:	00777793          	andi	a5,a4,7
    8000306a:	9f95                	subw	a5,a5,a3
    8000306c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003070:	4037571b          	sraiw	a4,a4,0x3
    80003074:	00e906b3          	add	a3,s2,a4
    80003078:	0586c683          	lbu	a3,88(a3) # 1058 <_entry-0x7fffefa8>
    8000307c:	00d7f5b3          	and	a1,a5,a3
    80003080:	d1b1                	beqz	a1,80002fc4 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003082:	2605                	addiw	a2,a2,1
    80003084:	2485                	addiw	s1,s1,1
    80003086:	fd4618e3          	bne	a2,s4,80003056 <balloc+0xce>
    8000308a:	b779                	j	80003018 <balloc+0x90>
  printf("balloc: out of blocks\n");
    8000308c:	00004517          	auipc	a0,0x4
    80003090:	5c450513          	addi	a0,a0,1476 # 80007650 <states.0+0x80>
    80003094:	c30fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003098:	4481                	li	s1,0
    8000309a:	b78d                	j	80002ffc <balloc+0x74>

000000008000309c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000309c:	7179                	addi	sp,sp,-48
    8000309e:	f406                	sd	ra,40(sp)
    800030a0:	f022                	sd	s0,32(sp)
    800030a2:	ec26                	sd	s1,24(sp)
    800030a4:	e84a                	sd	s2,16(sp)
    800030a6:	e44e                	sd	s3,8(sp)
    800030a8:	e052                	sd	s4,0(sp)
    800030aa:	1800                	addi	s0,sp,48
    800030ac:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800030ae:	47ad                	li	a5,11
    800030b0:	02b7e563          	bltu	a5,a1,800030da <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800030b4:	02059493          	slli	s1,a1,0x20
    800030b8:	9081                	srli	s1,s1,0x20
    800030ba:	048a                	slli	s1,s1,0x2
    800030bc:	94aa                	add	s1,s1,a0
    800030be:	0504a903          	lw	s2,80(s1)
    800030c2:	06091663          	bnez	s2,8000312e <bmap+0x92>
      addr = balloc(ip->dev);
    800030c6:	4108                	lw	a0,0(a0)
    800030c8:	ec1ff0ef          	jal	ra,80002f88 <balloc>
    800030cc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800030d0:	04090f63          	beqz	s2,8000312e <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    800030d4:	0524a823          	sw	s2,80(s1)
    800030d8:	a899                	j	8000312e <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    800030da:	ff45849b          	addiw	s1,a1,-12
    800030de:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800030e2:	0ff00793          	li	a5,255
    800030e6:	06e7eb63          	bltu	a5,a4,8000315c <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800030ea:	08052903          	lw	s2,128(a0)
    800030ee:	00091b63          	bnez	s2,80003104 <bmap+0x68>
      addr = balloc(ip->dev);
    800030f2:	4108                	lw	a0,0(a0)
    800030f4:	e95ff0ef          	jal	ra,80002f88 <balloc>
    800030f8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800030fc:	02090963          	beqz	s2,8000312e <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003100:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003104:	85ca                	mv	a1,s2
    80003106:	0009a503          	lw	a0,0(s3)
    8000310a:	c19ff0ef          	jal	ra,80002d22 <bread>
    8000310e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003110:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003114:	02049593          	slli	a1,s1,0x20
    80003118:	9181                	srli	a1,a1,0x20
    8000311a:	058a                	slli	a1,a1,0x2
    8000311c:	00b784b3          	add	s1,a5,a1
    80003120:	0004a903          	lw	s2,0(s1)
    80003124:	00090e63          	beqz	s2,80003140 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003128:	8552                	mv	a0,s4
    8000312a:	d01ff0ef          	jal	ra,80002e2a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000312e:	854a                	mv	a0,s2
    80003130:	70a2                	ld	ra,40(sp)
    80003132:	7402                	ld	s0,32(sp)
    80003134:	64e2                	ld	s1,24(sp)
    80003136:	6942                	ld	s2,16(sp)
    80003138:	69a2                	ld	s3,8(sp)
    8000313a:	6a02                	ld	s4,0(sp)
    8000313c:	6145                	addi	sp,sp,48
    8000313e:	8082                	ret
      addr = balloc(ip->dev);
    80003140:	0009a503          	lw	a0,0(s3)
    80003144:	e45ff0ef          	jal	ra,80002f88 <balloc>
    80003148:	0005091b          	sext.w	s2,a0
      if(addr){
    8000314c:	fc090ee3          	beqz	s2,80003128 <bmap+0x8c>
        a[bn] = addr;
    80003150:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003154:	8552                	mv	a0,s4
    80003156:	5e1000ef          	jal	ra,80003f36 <log_write>
    8000315a:	b7f9                	j	80003128 <bmap+0x8c>
  panic("bmap: out of range");
    8000315c:	00004517          	auipc	a0,0x4
    80003160:	50c50513          	addi	a0,a0,1292 # 80007668 <states.0+0x98>
    80003164:	e26fd0ef          	jal	ra,8000078a <panic>

0000000080003168 <iget>:
{
    80003168:	7179                	addi	sp,sp,-48
    8000316a:	f406                	sd	ra,40(sp)
    8000316c:	f022                	sd	s0,32(sp)
    8000316e:	ec26                	sd	s1,24(sp)
    80003170:	e84a                	sd	s2,16(sp)
    80003172:	e44e                	sd	s3,8(sp)
    80003174:	e052                	sd	s4,0(sp)
    80003176:	1800                	addi	s0,sp,48
    80003178:	89aa                	mv	s3,a0
    8000317a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000317c:	0001b517          	auipc	a0,0x1b
    80003180:	26450513          	addi	a0,a0,612 # 8001e3e0 <itable>
    80003184:	9e9fd0ef          	jal	ra,80000b6c <acquire>
  empty = 0;
    80003188:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000318a:	0001b497          	auipc	s1,0x1b
    8000318e:	26e48493          	addi	s1,s1,622 # 8001e3f8 <itable+0x18>
    80003192:	0001d697          	auipc	a3,0x1d
    80003196:	cf668693          	addi	a3,a3,-778 # 8001fe88 <log>
    8000319a:	a039                	j	800031a8 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000319c:	02090963          	beqz	s2,800031ce <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031a0:	08848493          	addi	s1,s1,136
    800031a4:	02d48863          	beq	s1,a3,800031d4 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800031a8:	449c                	lw	a5,8(s1)
    800031aa:	fef059e3          	blez	a5,8000319c <iget+0x34>
    800031ae:	4098                	lw	a4,0(s1)
    800031b0:	ff3716e3          	bne	a4,s3,8000319c <iget+0x34>
    800031b4:	40d8                	lw	a4,4(s1)
    800031b6:	ff4713e3          	bne	a4,s4,8000319c <iget+0x34>
      ip->ref++;
    800031ba:	2785                	addiw	a5,a5,1
    800031bc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031be:	0001b517          	auipc	a0,0x1b
    800031c2:	22250513          	addi	a0,a0,546 # 8001e3e0 <itable>
    800031c6:	a3ffd0ef          	jal	ra,80000c04 <release>
      return ip;
    800031ca:	8926                	mv	s2,s1
    800031cc:	a02d                	j	800031f6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031ce:	fbe9                	bnez	a5,800031a0 <iget+0x38>
    800031d0:	8926                	mv	s2,s1
    800031d2:	b7f9                	j	800031a0 <iget+0x38>
  if(empty == 0)
    800031d4:	02090a63          	beqz	s2,80003208 <iget+0xa0>
  ip->dev = dev;
    800031d8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800031dc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800031e0:	4785                	li	a5,1
    800031e2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800031e6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800031ea:	0001b517          	auipc	a0,0x1b
    800031ee:	1f650513          	addi	a0,a0,502 # 8001e3e0 <itable>
    800031f2:	a13fd0ef          	jal	ra,80000c04 <release>
}
    800031f6:	854a                	mv	a0,s2
    800031f8:	70a2                	ld	ra,40(sp)
    800031fa:	7402                	ld	s0,32(sp)
    800031fc:	64e2                	ld	s1,24(sp)
    800031fe:	6942                	ld	s2,16(sp)
    80003200:	69a2                	ld	s3,8(sp)
    80003202:	6a02                	ld	s4,0(sp)
    80003204:	6145                	addi	sp,sp,48
    80003206:	8082                	ret
    panic("iget: no inodes");
    80003208:	00004517          	auipc	a0,0x4
    8000320c:	47850513          	addi	a0,a0,1144 # 80007680 <states.0+0xb0>
    80003210:	d7afd0ef          	jal	ra,8000078a <panic>

0000000080003214 <iinit>:
{
    80003214:	7179                	addi	sp,sp,-48
    80003216:	f406                	sd	ra,40(sp)
    80003218:	f022                	sd	s0,32(sp)
    8000321a:	ec26                	sd	s1,24(sp)
    8000321c:	e84a                	sd	s2,16(sp)
    8000321e:	e44e                	sd	s3,8(sp)
    80003220:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003222:	00004597          	auipc	a1,0x4
    80003226:	46e58593          	addi	a1,a1,1134 # 80007690 <states.0+0xc0>
    8000322a:	0001b517          	auipc	a0,0x1b
    8000322e:	1b650513          	addi	a0,a0,438 # 8001e3e0 <itable>
    80003232:	8bbfd0ef          	jal	ra,80000aec <initlock>
  for(i = 0; i < NINODE; i++) {
    80003236:	0001b497          	auipc	s1,0x1b
    8000323a:	1d248493          	addi	s1,s1,466 # 8001e408 <itable+0x28>
    8000323e:	0001d997          	auipc	s3,0x1d
    80003242:	c5a98993          	addi	s3,s3,-934 # 8001fe98 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003246:	00004917          	auipc	s2,0x4
    8000324a:	45290913          	addi	s2,s2,1106 # 80007698 <states.0+0xc8>
    8000324e:	85ca                	mv	a1,s2
    80003250:	8526                	mv	a0,s1
    80003252:	5a9000ef          	jal	ra,80003ffa <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003256:	08848493          	addi	s1,s1,136
    8000325a:	ff349ae3          	bne	s1,s3,8000324e <iinit+0x3a>
}
    8000325e:	70a2                	ld	ra,40(sp)
    80003260:	7402                	ld	s0,32(sp)
    80003262:	64e2                	ld	s1,24(sp)
    80003264:	6942                	ld	s2,16(sp)
    80003266:	69a2                	ld	s3,8(sp)
    80003268:	6145                	addi	sp,sp,48
    8000326a:	8082                	ret

000000008000326c <ialloc>:
{
    8000326c:	715d                	addi	sp,sp,-80
    8000326e:	e486                	sd	ra,72(sp)
    80003270:	e0a2                	sd	s0,64(sp)
    80003272:	fc26                	sd	s1,56(sp)
    80003274:	f84a                	sd	s2,48(sp)
    80003276:	f44e                	sd	s3,40(sp)
    80003278:	f052                	sd	s4,32(sp)
    8000327a:	ec56                	sd	s5,24(sp)
    8000327c:	e85a                	sd	s6,16(sp)
    8000327e:	e45e                	sd	s7,8(sp)
    80003280:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003282:	0001b717          	auipc	a4,0x1b
    80003286:	14a72703          	lw	a4,330(a4) # 8001e3cc <sb+0xc>
    8000328a:	4785                	li	a5,1
    8000328c:	04e7f663          	bgeu	a5,a4,800032d8 <ialloc+0x6c>
    80003290:	8aaa                	mv	s5,a0
    80003292:	8bae                	mv	s7,a1
    80003294:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003296:	0001ba17          	auipc	s4,0x1b
    8000329a:	12aa0a13          	addi	s4,s4,298 # 8001e3c0 <sb>
    8000329e:	00048b1b          	sext.w	s6,s1
    800032a2:	0044d793          	srli	a5,s1,0x4
    800032a6:	018a2583          	lw	a1,24(s4)
    800032aa:	9dbd                	addw	a1,a1,a5
    800032ac:	8556                	mv	a0,s5
    800032ae:	a75ff0ef          	jal	ra,80002d22 <bread>
    800032b2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800032b4:	05850993          	addi	s3,a0,88
    800032b8:	00f4f793          	andi	a5,s1,15
    800032bc:	079a                	slli	a5,a5,0x6
    800032be:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800032c0:	00099783          	lh	a5,0(s3)
    800032c4:	cf85                	beqz	a5,800032fc <ialloc+0x90>
    brelse(bp);
    800032c6:	b65ff0ef          	jal	ra,80002e2a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800032ca:	0485                	addi	s1,s1,1
    800032cc:	00ca2703          	lw	a4,12(s4)
    800032d0:	0004879b          	sext.w	a5,s1
    800032d4:	fce7e5e3          	bltu	a5,a4,8000329e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800032d8:	00004517          	auipc	a0,0x4
    800032dc:	3c850513          	addi	a0,a0,968 # 800076a0 <states.0+0xd0>
    800032e0:	9e4fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    800032e4:	4501                	li	a0,0
}
    800032e6:	60a6                	ld	ra,72(sp)
    800032e8:	6406                	ld	s0,64(sp)
    800032ea:	74e2                	ld	s1,56(sp)
    800032ec:	7942                	ld	s2,48(sp)
    800032ee:	79a2                	ld	s3,40(sp)
    800032f0:	7a02                	ld	s4,32(sp)
    800032f2:	6ae2                	ld	s5,24(sp)
    800032f4:	6b42                	ld	s6,16(sp)
    800032f6:	6ba2                	ld	s7,8(sp)
    800032f8:	6161                	addi	sp,sp,80
    800032fa:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800032fc:	04000613          	li	a2,64
    80003300:	4581                	li	a1,0
    80003302:	854e                	mv	a0,s3
    80003304:	93dfd0ef          	jal	ra,80000c40 <memset>
      dip->type = type;
    80003308:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000330c:	854a                	mv	a0,s2
    8000330e:	429000ef          	jal	ra,80003f36 <log_write>
      brelse(bp);
    80003312:	854a                	mv	a0,s2
    80003314:	b17ff0ef          	jal	ra,80002e2a <brelse>
      return iget(dev, inum);
    80003318:	85da                	mv	a1,s6
    8000331a:	8556                	mv	a0,s5
    8000331c:	e4dff0ef          	jal	ra,80003168 <iget>
    80003320:	b7d9                	j	800032e6 <ialloc+0x7a>

0000000080003322 <iupdate>:
{
    80003322:	1101                	addi	sp,sp,-32
    80003324:	ec06                	sd	ra,24(sp)
    80003326:	e822                	sd	s0,16(sp)
    80003328:	e426                	sd	s1,8(sp)
    8000332a:	e04a                	sd	s2,0(sp)
    8000332c:	1000                	addi	s0,sp,32
    8000332e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003330:	415c                	lw	a5,4(a0)
    80003332:	0047d79b          	srliw	a5,a5,0x4
    80003336:	0001b597          	auipc	a1,0x1b
    8000333a:	0a25a583          	lw	a1,162(a1) # 8001e3d8 <sb+0x18>
    8000333e:	9dbd                	addw	a1,a1,a5
    80003340:	4108                	lw	a0,0(a0)
    80003342:	9e1ff0ef          	jal	ra,80002d22 <bread>
    80003346:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003348:	05850793          	addi	a5,a0,88
    8000334c:	40c8                	lw	a0,4(s1)
    8000334e:	893d                	andi	a0,a0,15
    80003350:	051a                	slli	a0,a0,0x6
    80003352:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003354:	04449703          	lh	a4,68(s1)
    80003358:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000335c:	04649703          	lh	a4,70(s1)
    80003360:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003364:	04849703          	lh	a4,72(s1)
    80003368:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000336c:	04a49703          	lh	a4,74(s1)
    80003370:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003374:	44f8                	lw	a4,76(s1)
    80003376:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003378:	03400613          	li	a2,52
    8000337c:	05048593          	addi	a1,s1,80
    80003380:	0531                	addi	a0,a0,12
    80003382:	91bfd0ef          	jal	ra,80000c9c <memmove>
  log_write(bp);
    80003386:	854a                	mv	a0,s2
    80003388:	3af000ef          	jal	ra,80003f36 <log_write>
  brelse(bp);
    8000338c:	854a                	mv	a0,s2
    8000338e:	a9dff0ef          	jal	ra,80002e2a <brelse>
}
    80003392:	60e2                	ld	ra,24(sp)
    80003394:	6442                	ld	s0,16(sp)
    80003396:	64a2                	ld	s1,8(sp)
    80003398:	6902                	ld	s2,0(sp)
    8000339a:	6105                	addi	sp,sp,32
    8000339c:	8082                	ret

000000008000339e <idup>:
{
    8000339e:	1101                	addi	sp,sp,-32
    800033a0:	ec06                	sd	ra,24(sp)
    800033a2:	e822                	sd	s0,16(sp)
    800033a4:	e426                	sd	s1,8(sp)
    800033a6:	1000                	addi	s0,sp,32
    800033a8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033aa:	0001b517          	auipc	a0,0x1b
    800033ae:	03650513          	addi	a0,a0,54 # 8001e3e0 <itable>
    800033b2:	fbafd0ef          	jal	ra,80000b6c <acquire>
  ip->ref++;
    800033b6:	449c                	lw	a5,8(s1)
    800033b8:	2785                	addiw	a5,a5,1
    800033ba:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033bc:	0001b517          	auipc	a0,0x1b
    800033c0:	02450513          	addi	a0,a0,36 # 8001e3e0 <itable>
    800033c4:	841fd0ef          	jal	ra,80000c04 <release>
}
    800033c8:	8526                	mv	a0,s1
    800033ca:	60e2                	ld	ra,24(sp)
    800033cc:	6442                	ld	s0,16(sp)
    800033ce:	64a2                	ld	s1,8(sp)
    800033d0:	6105                	addi	sp,sp,32
    800033d2:	8082                	ret

00000000800033d4 <ilock>:
{
    800033d4:	1101                	addi	sp,sp,-32
    800033d6:	ec06                	sd	ra,24(sp)
    800033d8:	e822                	sd	s0,16(sp)
    800033da:	e426                	sd	s1,8(sp)
    800033dc:	e04a                	sd	s2,0(sp)
    800033de:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800033e0:	c105                	beqz	a0,80003400 <ilock+0x2c>
    800033e2:	84aa                	mv	s1,a0
    800033e4:	451c                	lw	a5,8(a0)
    800033e6:	00f05d63          	blez	a5,80003400 <ilock+0x2c>
  acquiresleep(&ip->lock);
    800033ea:	0541                	addi	a0,a0,16
    800033ec:	445000ef          	jal	ra,80004030 <acquiresleep>
  if(ip->valid == 0){
    800033f0:	40bc                	lw	a5,64(s1)
    800033f2:	cf89                	beqz	a5,8000340c <ilock+0x38>
}
    800033f4:	60e2                	ld	ra,24(sp)
    800033f6:	6442                	ld	s0,16(sp)
    800033f8:	64a2                	ld	s1,8(sp)
    800033fa:	6902                	ld	s2,0(sp)
    800033fc:	6105                	addi	sp,sp,32
    800033fe:	8082                	ret
    panic("ilock");
    80003400:	00004517          	auipc	a0,0x4
    80003404:	2b850513          	addi	a0,a0,696 # 800076b8 <states.0+0xe8>
    80003408:	b82fd0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000340c:	40dc                	lw	a5,4(s1)
    8000340e:	0047d79b          	srliw	a5,a5,0x4
    80003412:	0001b597          	auipc	a1,0x1b
    80003416:	fc65a583          	lw	a1,-58(a1) # 8001e3d8 <sb+0x18>
    8000341a:	9dbd                	addw	a1,a1,a5
    8000341c:	4088                	lw	a0,0(s1)
    8000341e:	905ff0ef          	jal	ra,80002d22 <bread>
    80003422:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003424:	05850593          	addi	a1,a0,88
    80003428:	40dc                	lw	a5,4(s1)
    8000342a:	8bbd                	andi	a5,a5,15
    8000342c:	079a                	slli	a5,a5,0x6
    8000342e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003430:	00059783          	lh	a5,0(a1)
    80003434:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003438:	00259783          	lh	a5,2(a1)
    8000343c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003440:	00459783          	lh	a5,4(a1)
    80003444:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003448:	00659783          	lh	a5,6(a1)
    8000344c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003450:	459c                	lw	a5,8(a1)
    80003452:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003454:	03400613          	li	a2,52
    80003458:	05b1                	addi	a1,a1,12
    8000345a:	05048513          	addi	a0,s1,80
    8000345e:	83ffd0ef          	jal	ra,80000c9c <memmove>
    brelse(bp);
    80003462:	854a                	mv	a0,s2
    80003464:	9c7ff0ef          	jal	ra,80002e2a <brelse>
    ip->valid = 1;
    80003468:	4785                	li	a5,1
    8000346a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000346c:	04449783          	lh	a5,68(s1)
    80003470:	f3d1                	bnez	a5,800033f4 <ilock+0x20>
      panic("ilock: no type");
    80003472:	00004517          	auipc	a0,0x4
    80003476:	24e50513          	addi	a0,a0,590 # 800076c0 <states.0+0xf0>
    8000347a:	b10fd0ef          	jal	ra,8000078a <panic>

000000008000347e <iunlock>:
{
    8000347e:	1101                	addi	sp,sp,-32
    80003480:	ec06                	sd	ra,24(sp)
    80003482:	e822                	sd	s0,16(sp)
    80003484:	e426                	sd	s1,8(sp)
    80003486:	e04a                	sd	s2,0(sp)
    80003488:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000348a:	c505                	beqz	a0,800034b2 <iunlock+0x34>
    8000348c:	84aa                	mv	s1,a0
    8000348e:	01050913          	addi	s2,a0,16
    80003492:	854a                	mv	a0,s2
    80003494:	41b000ef          	jal	ra,800040ae <holdingsleep>
    80003498:	cd09                	beqz	a0,800034b2 <iunlock+0x34>
    8000349a:	449c                	lw	a5,8(s1)
    8000349c:	00f05b63          	blez	a5,800034b2 <iunlock+0x34>
  releasesleep(&ip->lock);
    800034a0:	854a                	mv	a0,s2
    800034a2:	3d5000ef          	jal	ra,80004076 <releasesleep>
}
    800034a6:	60e2                	ld	ra,24(sp)
    800034a8:	6442                	ld	s0,16(sp)
    800034aa:	64a2                	ld	s1,8(sp)
    800034ac:	6902                	ld	s2,0(sp)
    800034ae:	6105                	addi	sp,sp,32
    800034b0:	8082                	ret
    panic("iunlock");
    800034b2:	00004517          	auipc	a0,0x4
    800034b6:	21e50513          	addi	a0,a0,542 # 800076d0 <states.0+0x100>
    800034ba:	ad0fd0ef          	jal	ra,8000078a <panic>

00000000800034be <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034be:	7179                	addi	sp,sp,-48
    800034c0:	f406                	sd	ra,40(sp)
    800034c2:	f022                	sd	s0,32(sp)
    800034c4:	ec26                	sd	s1,24(sp)
    800034c6:	e84a                	sd	s2,16(sp)
    800034c8:	e44e                	sd	s3,8(sp)
    800034ca:	e052                	sd	s4,0(sp)
    800034cc:	1800                	addi	s0,sp,48
    800034ce:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800034d0:	05050493          	addi	s1,a0,80
    800034d4:	08050913          	addi	s2,a0,128
    800034d8:	a021                	j	800034e0 <itrunc+0x22>
    800034da:	0491                	addi	s1,s1,4
    800034dc:	01248b63          	beq	s1,s2,800034f2 <itrunc+0x34>
    if(ip->addrs[i]){
    800034e0:	408c                	lw	a1,0(s1)
    800034e2:	dde5                	beqz	a1,800034da <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800034e4:	0009a503          	lw	a0,0(s3)
    800034e8:	a35ff0ef          	jal	ra,80002f1c <bfree>
      ip->addrs[i] = 0;
    800034ec:	0004a023          	sw	zero,0(s1)
    800034f0:	b7ed                	j	800034da <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800034f2:	0809a583          	lw	a1,128(s3)
    800034f6:	ed91                	bnez	a1,80003512 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034f8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034fc:	854e                	mv	a0,s3
    800034fe:	e25ff0ef          	jal	ra,80003322 <iupdate>
}
    80003502:	70a2                	ld	ra,40(sp)
    80003504:	7402                	ld	s0,32(sp)
    80003506:	64e2                	ld	s1,24(sp)
    80003508:	6942                	ld	s2,16(sp)
    8000350a:	69a2                	ld	s3,8(sp)
    8000350c:	6a02                	ld	s4,0(sp)
    8000350e:	6145                	addi	sp,sp,48
    80003510:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003512:	0009a503          	lw	a0,0(s3)
    80003516:	80dff0ef          	jal	ra,80002d22 <bread>
    8000351a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000351c:	05850493          	addi	s1,a0,88
    80003520:	45850913          	addi	s2,a0,1112
    80003524:	a021                	j	8000352c <itrunc+0x6e>
    80003526:	0491                	addi	s1,s1,4
    80003528:	01248963          	beq	s1,s2,8000353a <itrunc+0x7c>
      if(a[j])
    8000352c:	408c                	lw	a1,0(s1)
    8000352e:	dde5                	beqz	a1,80003526 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003530:	0009a503          	lw	a0,0(s3)
    80003534:	9e9ff0ef          	jal	ra,80002f1c <bfree>
    80003538:	b7fd                	j	80003526 <itrunc+0x68>
    brelse(bp);
    8000353a:	8552                	mv	a0,s4
    8000353c:	8efff0ef          	jal	ra,80002e2a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003540:	0809a583          	lw	a1,128(s3)
    80003544:	0009a503          	lw	a0,0(s3)
    80003548:	9d5ff0ef          	jal	ra,80002f1c <bfree>
    ip->addrs[NDIRECT] = 0;
    8000354c:	0809a023          	sw	zero,128(s3)
    80003550:	b765                	j	800034f8 <itrunc+0x3a>

0000000080003552 <iput>:
{
    80003552:	1101                	addi	sp,sp,-32
    80003554:	ec06                	sd	ra,24(sp)
    80003556:	e822                	sd	s0,16(sp)
    80003558:	e426                	sd	s1,8(sp)
    8000355a:	e04a                	sd	s2,0(sp)
    8000355c:	1000                	addi	s0,sp,32
    8000355e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003560:	0001b517          	auipc	a0,0x1b
    80003564:	e8050513          	addi	a0,a0,-384 # 8001e3e0 <itable>
    80003568:	e04fd0ef          	jal	ra,80000b6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000356c:	4498                	lw	a4,8(s1)
    8000356e:	4785                	li	a5,1
    80003570:	02f70163          	beq	a4,a5,80003592 <iput+0x40>
  ip->ref--;
    80003574:	449c                	lw	a5,8(s1)
    80003576:	37fd                	addiw	a5,a5,-1
    80003578:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000357a:	0001b517          	auipc	a0,0x1b
    8000357e:	e6650513          	addi	a0,a0,-410 # 8001e3e0 <itable>
    80003582:	e82fd0ef          	jal	ra,80000c04 <release>
}
    80003586:	60e2                	ld	ra,24(sp)
    80003588:	6442                	ld	s0,16(sp)
    8000358a:	64a2                	ld	s1,8(sp)
    8000358c:	6902                	ld	s2,0(sp)
    8000358e:	6105                	addi	sp,sp,32
    80003590:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003592:	40bc                	lw	a5,64(s1)
    80003594:	d3e5                	beqz	a5,80003574 <iput+0x22>
    80003596:	04a49783          	lh	a5,74(s1)
    8000359a:	ffe9                	bnez	a5,80003574 <iput+0x22>
    acquiresleep(&ip->lock);
    8000359c:	01048913          	addi	s2,s1,16
    800035a0:	854a                	mv	a0,s2
    800035a2:	28f000ef          	jal	ra,80004030 <acquiresleep>
    release(&itable.lock);
    800035a6:	0001b517          	auipc	a0,0x1b
    800035aa:	e3a50513          	addi	a0,a0,-454 # 8001e3e0 <itable>
    800035ae:	e56fd0ef          	jal	ra,80000c04 <release>
    itrunc(ip);
    800035b2:	8526                	mv	a0,s1
    800035b4:	f0bff0ef          	jal	ra,800034be <itrunc>
    ip->type = 0;
    800035b8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800035bc:	8526                	mv	a0,s1
    800035be:	d65ff0ef          	jal	ra,80003322 <iupdate>
    ip->valid = 0;
    800035c2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800035c6:	854a                	mv	a0,s2
    800035c8:	2af000ef          	jal	ra,80004076 <releasesleep>
    acquire(&itable.lock);
    800035cc:	0001b517          	auipc	a0,0x1b
    800035d0:	e1450513          	addi	a0,a0,-492 # 8001e3e0 <itable>
    800035d4:	d98fd0ef          	jal	ra,80000b6c <acquire>
    800035d8:	bf71                	j	80003574 <iput+0x22>

00000000800035da <iunlockput>:
{
    800035da:	1101                	addi	sp,sp,-32
    800035dc:	ec06                	sd	ra,24(sp)
    800035de:	e822                	sd	s0,16(sp)
    800035e0:	e426                	sd	s1,8(sp)
    800035e2:	1000                	addi	s0,sp,32
    800035e4:	84aa                	mv	s1,a0
  iunlock(ip);
    800035e6:	e99ff0ef          	jal	ra,8000347e <iunlock>
  iput(ip);
    800035ea:	8526                	mv	a0,s1
    800035ec:	f67ff0ef          	jal	ra,80003552 <iput>
}
    800035f0:	60e2                	ld	ra,24(sp)
    800035f2:	6442                	ld	s0,16(sp)
    800035f4:	64a2                	ld	s1,8(sp)
    800035f6:	6105                	addi	sp,sp,32
    800035f8:	8082                	ret

00000000800035fa <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035fa:	0001b717          	auipc	a4,0x1b
    800035fe:	dd272703          	lw	a4,-558(a4) # 8001e3cc <sb+0xc>
    80003602:	4785                	li	a5,1
    80003604:	0ae7ff63          	bgeu	a5,a4,800036c2 <ireclaim+0xc8>
{
    80003608:	7139                	addi	sp,sp,-64
    8000360a:	fc06                	sd	ra,56(sp)
    8000360c:	f822                	sd	s0,48(sp)
    8000360e:	f426                	sd	s1,40(sp)
    80003610:	f04a                	sd	s2,32(sp)
    80003612:	ec4e                	sd	s3,24(sp)
    80003614:	e852                	sd	s4,16(sp)
    80003616:	e456                	sd	s5,8(sp)
    80003618:	e05a                	sd	s6,0(sp)
    8000361a:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000361c:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000361e:	00050a1b          	sext.w	s4,a0
    80003622:	0001ba97          	auipc	s5,0x1b
    80003626:	d9ea8a93          	addi	s5,s5,-610 # 8001e3c0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000362a:	00004b17          	auipc	s6,0x4
    8000362e:	0aeb0b13          	addi	s6,s6,174 # 800076d8 <states.0+0x108>
    80003632:	a099                	j	80003678 <ireclaim+0x7e>
    80003634:	85ce                	mv	a1,s3
    80003636:	855a                	mv	a0,s6
    80003638:	e8dfc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    8000363c:	85ce                	mv	a1,s3
    8000363e:	8552                	mv	a0,s4
    80003640:	b29ff0ef          	jal	ra,80003168 <iget>
    80003644:	89aa                	mv	s3,a0
    brelse(bp);
    80003646:	854a                	mv	a0,s2
    80003648:	fe2ff0ef          	jal	ra,80002e2a <brelse>
    if (ip) {
    8000364c:	00098f63          	beqz	s3,8000366a <ireclaim+0x70>
      begin_op();
    80003650:	762000ef          	jal	ra,80003db2 <begin_op>
      ilock(ip);
    80003654:	854e                	mv	a0,s3
    80003656:	d7fff0ef          	jal	ra,800033d4 <ilock>
      iunlock(ip);
    8000365a:	854e                	mv	a0,s3
    8000365c:	e23ff0ef          	jal	ra,8000347e <iunlock>
      iput(ip);
    80003660:	854e                	mv	a0,s3
    80003662:	ef1ff0ef          	jal	ra,80003552 <iput>
      end_op();
    80003666:	7bc000ef          	jal	ra,80003e22 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000366a:	0485                	addi	s1,s1,1
    8000366c:	00caa703          	lw	a4,12(s5)
    80003670:	0004879b          	sext.w	a5,s1
    80003674:	02e7fd63          	bgeu	a5,a4,800036ae <ireclaim+0xb4>
    80003678:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000367c:	0044d793          	srli	a5,s1,0x4
    80003680:	018aa583          	lw	a1,24(s5)
    80003684:	9dbd                	addw	a1,a1,a5
    80003686:	8552                	mv	a0,s4
    80003688:	e9aff0ef          	jal	ra,80002d22 <bread>
    8000368c:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000368e:	05850793          	addi	a5,a0,88
    80003692:	00f9f713          	andi	a4,s3,15
    80003696:	071a                	slli	a4,a4,0x6
    80003698:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000369a:	00079703          	lh	a4,0(a5)
    8000369e:	c701                	beqz	a4,800036a6 <ireclaim+0xac>
    800036a0:	00679783          	lh	a5,6(a5)
    800036a4:	dbc1                	beqz	a5,80003634 <ireclaim+0x3a>
    brelse(bp);
    800036a6:	854a                	mv	a0,s2
    800036a8:	f82ff0ef          	jal	ra,80002e2a <brelse>
    if (ip) {
    800036ac:	bf7d                	j	8000366a <ireclaim+0x70>
}
    800036ae:	70e2                	ld	ra,56(sp)
    800036b0:	7442                	ld	s0,48(sp)
    800036b2:	74a2                	ld	s1,40(sp)
    800036b4:	7902                	ld	s2,32(sp)
    800036b6:	69e2                	ld	s3,24(sp)
    800036b8:	6a42                	ld	s4,16(sp)
    800036ba:	6aa2                	ld	s5,8(sp)
    800036bc:	6b02                	ld	s6,0(sp)
    800036be:	6121                	addi	sp,sp,64
    800036c0:	8082                	ret
    800036c2:	8082                	ret

00000000800036c4 <fsinit>:
fsinit(int dev) {
    800036c4:	7179                	addi	sp,sp,-48
    800036c6:	f406                	sd	ra,40(sp)
    800036c8:	f022                	sd	s0,32(sp)
    800036ca:	ec26                	sd	s1,24(sp)
    800036cc:	e84a                	sd	s2,16(sp)
    800036ce:	e44e                	sd	s3,8(sp)
    800036d0:	1800                	addi	s0,sp,48
    800036d2:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800036d4:	4585                	li	a1,1
    800036d6:	e4cff0ef          	jal	ra,80002d22 <bread>
    800036da:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036dc:	0001b997          	auipc	s3,0x1b
    800036e0:	ce498993          	addi	s3,s3,-796 # 8001e3c0 <sb>
    800036e4:	02000613          	li	a2,32
    800036e8:	05850593          	addi	a1,a0,88
    800036ec:	854e                	mv	a0,s3
    800036ee:	daefd0ef          	jal	ra,80000c9c <memmove>
  brelse(bp);
    800036f2:	854a                	mv	a0,s2
    800036f4:	f36ff0ef          	jal	ra,80002e2a <brelse>
  if(sb.magic != FSMAGIC)
    800036f8:	0009a703          	lw	a4,0(s3)
    800036fc:	102037b7          	lui	a5,0x10203
    80003700:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003704:	02f71363          	bne	a4,a5,8000372a <fsinit+0x66>
  initlog(dev, &sb);
    80003708:	0001b597          	auipc	a1,0x1b
    8000370c:	cb858593          	addi	a1,a1,-840 # 8001e3c0 <sb>
    80003710:	8526                	mv	a0,s1
    80003712:	616000ef          	jal	ra,80003d28 <initlog>
  ireclaim(dev);
    80003716:	8526                	mv	a0,s1
    80003718:	ee3ff0ef          	jal	ra,800035fa <ireclaim>
}
    8000371c:	70a2                	ld	ra,40(sp)
    8000371e:	7402                	ld	s0,32(sp)
    80003720:	64e2                	ld	s1,24(sp)
    80003722:	6942                	ld	s2,16(sp)
    80003724:	69a2                	ld	s3,8(sp)
    80003726:	6145                	addi	sp,sp,48
    80003728:	8082                	ret
    panic("invalid file system");
    8000372a:	00004517          	auipc	a0,0x4
    8000372e:	fce50513          	addi	a0,a0,-50 # 800076f8 <states.0+0x128>
    80003732:	858fd0ef          	jal	ra,8000078a <panic>

0000000080003736 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003736:	1141                	addi	sp,sp,-16
    80003738:	e422                	sd	s0,8(sp)
    8000373a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000373c:	411c                	lw	a5,0(a0)
    8000373e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003740:	415c                	lw	a5,4(a0)
    80003742:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003744:	04451783          	lh	a5,68(a0)
    80003748:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000374c:	04a51783          	lh	a5,74(a0)
    80003750:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003754:	04c56783          	lwu	a5,76(a0)
    80003758:	e99c                	sd	a5,16(a1)
}
    8000375a:	6422                	ld	s0,8(sp)
    8000375c:	0141                	addi	sp,sp,16
    8000375e:	8082                	ret

0000000080003760 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003760:	457c                	lw	a5,76(a0)
    80003762:	0cd7ef63          	bltu	a5,a3,80003840 <readi+0xe0>
{
    80003766:	7159                	addi	sp,sp,-112
    80003768:	f486                	sd	ra,104(sp)
    8000376a:	f0a2                	sd	s0,96(sp)
    8000376c:	eca6                	sd	s1,88(sp)
    8000376e:	e8ca                	sd	s2,80(sp)
    80003770:	e4ce                	sd	s3,72(sp)
    80003772:	e0d2                	sd	s4,64(sp)
    80003774:	fc56                	sd	s5,56(sp)
    80003776:	f85a                	sd	s6,48(sp)
    80003778:	f45e                	sd	s7,40(sp)
    8000377a:	f062                	sd	s8,32(sp)
    8000377c:	ec66                	sd	s9,24(sp)
    8000377e:	e86a                	sd	s10,16(sp)
    80003780:	e46e                	sd	s11,8(sp)
    80003782:	1880                	addi	s0,sp,112
    80003784:	8b2a                	mv	s6,a0
    80003786:	8bae                	mv	s7,a1
    80003788:	8a32                	mv	s4,a2
    8000378a:	84b6                	mv	s1,a3
    8000378c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000378e:	9f35                	addw	a4,a4,a3
    return 0;
    80003790:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003792:	08d76663          	bltu	a4,a3,8000381e <readi+0xbe>
  if(off + n > ip->size)
    80003796:	00e7f463          	bgeu	a5,a4,8000379e <readi+0x3e>
    n = ip->size - off;
    8000379a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000379e:	080a8f63          	beqz	s5,8000383c <readi+0xdc>
    800037a2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037a4:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800037a8:	5c7d                	li	s8,-1
    800037aa:	a80d                	j	800037dc <readi+0x7c>
    800037ac:	020d1d93          	slli	s11,s10,0x20
    800037b0:	020ddd93          	srli	s11,s11,0x20
    800037b4:	05890793          	addi	a5,s2,88
    800037b8:	86ee                	mv	a3,s11
    800037ba:	963e                	add	a2,a2,a5
    800037bc:	85d2                	mv	a1,s4
    800037be:	855e                	mv	a0,s7
    800037c0:	a11fe0ef          	jal	ra,800021d0 <either_copyout>
    800037c4:	05850763          	beq	a0,s8,80003812 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800037c8:	854a                	mv	a0,s2
    800037ca:	e60ff0ef          	jal	ra,80002e2a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037ce:	013d09bb          	addw	s3,s10,s3
    800037d2:	009d04bb          	addw	s1,s10,s1
    800037d6:	9a6e                	add	s4,s4,s11
    800037d8:	0559f163          	bgeu	s3,s5,8000381a <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800037dc:	00a4d59b          	srliw	a1,s1,0xa
    800037e0:	855a                	mv	a0,s6
    800037e2:	8bbff0ef          	jal	ra,8000309c <bmap>
    800037e6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800037ea:	c985                	beqz	a1,8000381a <readi+0xba>
    bp = bread(ip->dev, addr);
    800037ec:	000b2503          	lw	a0,0(s6)
    800037f0:	d32ff0ef          	jal	ra,80002d22 <bread>
    800037f4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037f6:	3ff4f613          	andi	a2,s1,1023
    800037fa:	40cc87bb          	subw	a5,s9,a2
    800037fe:	413a873b          	subw	a4,s5,s3
    80003802:	8d3e                	mv	s10,a5
    80003804:	2781                	sext.w	a5,a5
    80003806:	0007069b          	sext.w	a3,a4
    8000380a:	faf6f1e3          	bgeu	a3,a5,800037ac <readi+0x4c>
    8000380e:	8d3a                	mv	s10,a4
    80003810:	bf71                	j	800037ac <readi+0x4c>
      brelse(bp);
    80003812:	854a                	mv	a0,s2
    80003814:	e16ff0ef          	jal	ra,80002e2a <brelse>
      tot = -1;
    80003818:	59fd                	li	s3,-1
  }
  return tot;
    8000381a:	0009851b          	sext.w	a0,s3
}
    8000381e:	70a6                	ld	ra,104(sp)
    80003820:	7406                	ld	s0,96(sp)
    80003822:	64e6                	ld	s1,88(sp)
    80003824:	6946                	ld	s2,80(sp)
    80003826:	69a6                	ld	s3,72(sp)
    80003828:	6a06                	ld	s4,64(sp)
    8000382a:	7ae2                	ld	s5,56(sp)
    8000382c:	7b42                	ld	s6,48(sp)
    8000382e:	7ba2                	ld	s7,40(sp)
    80003830:	7c02                	ld	s8,32(sp)
    80003832:	6ce2                	ld	s9,24(sp)
    80003834:	6d42                	ld	s10,16(sp)
    80003836:	6da2                	ld	s11,8(sp)
    80003838:	6165                	addi	sp,sp,112
    8000383a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000383c:	89d6                	mv	s3,s5
    8000383e:	bff1                	j	8000381a <readi+0xba>
    return 0;
    80003840:	4501                	li	a0,0
}
    80003842:	8082                	ret

0000000080003844 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003844:	457c                	lw	a5,76(a0)
    80003846:	0ed7ea63          	bltu	a5,a3,8000393a <writei+0xf6>
{
    8000384a:	7159                	addi	sp,sp,-112
    8000384c:	f486                	sd	ra,104(sp)
    8000384e:	f0a2                	sd	s0,96(sp)
    80003850:	eca6                	sd	s1,88(sp)
    80003852:	e8ca                	sd	s2,80(sp)
    80003854:	e4ce                	sd	s3,72(sp)
    80003856:	e0d2                	sd	s4,64(sp)
    80003858:	fc56                	sd	s5,56(sp)
    8000385a:	f85a                	sd	s6,48(sp)
    8000385c:	f45e                	sd	s7,40(sp)
    8000385e:	f062                	sd	s8,32(sp)
    80003860:	ec66                	sd	s9,24(sp)
    80003862:	e86a                	sd	s10,16(sp)
    80003864:	e46e                	sd	s11,8(sp)
    80003866:	1880                	addi	s0,sp,112
    80003868:	8aaa                	mv	s5,a0
    8000386a:	8bae                	mv	s7,a1
    8000386c:	8a32                	mv	s4,a2
    8000386e:	8936                	mv	s2,a3
    80003870:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003872:	00e687bb          	addw	a5,a3,a4
    80003876:	0cd7e463          	bltu	a5,a3,8000393e <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000387a:	00043737          	lui	a4,0x43
    8000387e:	0cf76263          	bltu	a4,a5,80003942 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003882:	0a0b0a63          	beqz	s6,80003936 <writei+0xf2>
    80003886:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003888:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000388c:	5c7d                	li	s8,-1
    8000388e:	a825                	j	800038c6 <writei+0x82>
    80003890:	020d1d93          	slli	s11,s10,0x20
    80003894:	020ddd93          	srli	s11,s11,0x20
    80003898:	05848793          	addi	a5,s1,88
    8000389c:	86ee                	mv	a3,s11
    8000389e:	8652                	mv	a2,s4
    800038a0:	85de                	mv	a1,s7
    800038a2:	953e                	add	a0,a0,a5
    800038a4:	977fe0ef          	jal	ra,8000221a <either_copyin>
    800038a8:	05850a63          	beq	a0,s8,800038fc <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800038ac:	8526                	mv	a0,s1
    800038ae:	688000ef          	jal	ra,80003f36 <log_write>
    brelse(bp);
    800038b2:	8526                	mv	a0,s1
    800038b4:	d76ff0ef          	jal	ra,80002e2a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038b8:	013d09bb          	addw	s3,s10,s3
    800038bc:	012d093b          	addw	s2,s10,s2
    800038c0:	9a6e                	add	s4,s4,s11
    800038c2:	0569f063          	bgeu	s3,s6,80003902 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800038c6:	00a9559b          	srliw	a1,s2,0xa
    800038ca:	8556                	mv	a0,s5
    800038cc:	fd0ff0ef          	jal	ra,8000309c <bmap>
    800038d0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038d4:	c59d                	beqz	a1,80003902 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800038d6:	000aa503          	lw	a0,0(s5)
    800038da:	c48ff0ef          	jal	ra,80002d22 <bread>
    800038de:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038e0:	3ff97513          	andi	a0,s2,1023
    800038e4:	40ac87bb          	subw	a5,s9,a0
    800038e8:	413b073b          	subw	a4,s6,s3
    800038ec:	8d3e                	mv	s10,a5
    800038ee:	2781                	sext.w	a5,a5
    800038f0:	0007069b          	sext.w	a3,a4
    800038f4:	f8f6fee3          	bgeu	a3,a5,80003890 <writei+0x4c>
    800038f8:	8d3a                	mv	s10,a4
    800038fa:	bf59                	j	80003890 <writei+0x4c>
      brelse(bp);
    800038fc:	8526                	mv	a0,s1
    800038fe:	d2cff0ef          	jal	ra,80002e2a <brelse>
  }

  if(off > ip->size)
    80003902:	04caa783          	lw	a5,76(s5)
    80003906:	0127f463          	bgeu	a5,s2,8000390e <writei+0xca>
    ip->size = off;
    8000390a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000390e:	8556                	mv	a0,s5
    80003910:	a13ff0ef          	jal	ra,80003322 <iupdate>

  return tot;
    80003914:	0009851b          	sext.w	a0,s3
}
    80003918:	70a6                	ld	ra,104(sp)
    8000391a:	7406                	ld	s0,96(sp)
    8000391c:	64e6                	ld	s1,88(sp)
    8000391e:	6946                	ld	s2,80(sp)
    80003920:	69a6                	ld	s3,72(sp)
    80003922:	6a06                	ld	s4,64(sp)
    80003924:	7ae2                	ld	s5,56(sp)
    80003926:	7b42                	ld	s6,48(sp)
    80003928:	7ba2                	ld	s7,40(sp)
    8000392a:	7c02                	ld	s8,32(sp)
    8000392c:	6ce2                	ld	s9,24(sp)
    8000392e:	6d42                	ld	s10,16(sp)
    80003930:	6da2                	ld	s11,8(sp)
    80003932:	6165                	addi	sp,sp,112
    80003934:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003936:	89da                	mv	s3,s6
    80003938:	bfd9                	j	8000390e <writei+0xca>
    return -1;
    8000393a:	557d                	li	a0,-1
}
    8000393c:	8082                	ret
    return -1;
    8000393e:	557d                	li	a0,-1
    80003940:	bfe1                	j	80003918 <writei+0xd4>
    return -1;
    80003942:	557d                	li	a0,-1
    80003944:	bfd1                	j	80003918 <writei+0xd4>

0000000080003946 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003946:	1141                	addi	sp,sp,-16
    80003948:	e406                	sd	ra,8(sp)
    8000394a:	e022                	sd	s0,0(sp)
    8000394c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000394e:	4639                	li	a2,14
    80003950:	bbcfd0ef          	jal	ra,80000d0c <strncmp>
}
    80003954:	60a2                	ld	ra,8(sp)
    80003956:	6402                	ld	s0,0(sp)
    80003958:	0141                	addi	sp,sp,16
    8000395a:	8082                	ret

000000008000395c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000395c:	7139                	addi	sp,sp,-64
    8000395e:	fc06                	sd	ra,56(sp)
    80003960:	f822                	sd	s0,48(sp)
    80003962:	f426                	sd	s1,40(sp)
    80003964:	f04a                	sd	s2,32(sp)
    80003966:	ec4e                	sd	s3,24(sp)
    80003968:	e852                	sd	s4,16(sp)
    8000396a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000396c:	04451703          	lh	a4,68(a0)
    80003970:	4785                	li	a5,1
    80003972:	00f71a63          	bne	a4,a5,80003986 <dirlookup+0x2a>
    80003976:	892a                	mv	s2,a0
    80003978:	89ae                	mv	s3,a1
    8000397a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000397c:	457c                	lw	a5,76(a0)
    8000397e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003980:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003982:	e39d                	bnez	a5,800039a8 <dirlookup+0x4c>
    80003984:	a095                	j	800039e8 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003986:	00004517          	auipc	a0,0x4
    8000398a:	d8a50513          	addi	a0,a0,-630 # 80007710 <states.0+0x140>
    8000398e:	dfdfc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    80003992:	00004517          	auipc	a0,0x4
    80003996:	d9650513          	addi	a0,a0,-618 # 80007728 <states.0+0x158>
    8000399a:	df1fc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000399e:	24c1                	addiw	s1,s1,16
    800039a0:	04c92783          	lw	a5,76(s2)
    800039a4:	04f4f163          	bgeu	s1,a5,800039e6 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039a8:	4741                	li	a4,16
    800039aa:	86a6                	mv	a3,s1
    800039ac:	fc040613          	addi	a2,s0,-64
    800039b0:	4581                	li	a1,0
    800039b2:	854a                	mv	a0,s2
    800039b4:	dadff0ef          	jal	ra,80003760 <readi>
    800039b8:	47c1                	li	a5,16
    800039ba:	fcf51ce3          	bne	a0,a5,80003992 <dirlookup+0x36>
    if(de.inum == 0)
    800039be:	fc045783          	lhu	a5,-64(s0)
    800039c2:	dff1                	beqz	a5,8000399e <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800039c4:	fc240593          	addi	a1,s0,-62
    800039c8:	854e                	mv	a0,s3
    800039ca:	f7dff0ef          	jal	ra,80003946 <namecmp>
    800039ce:	f961                	bnez	a0,8000399e <dirlookup+0x42>
      if(poff)
    800039d0:	000a0463          	beqz	s4,800039d8 <dirlookup+0x7c>
        *poff = off;
    800039d4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800039d8:	fc045583          	lhu	a1,-64(s0)
    800039dc:	00092503          	lw	a0,0(s2)
    800039e0:	f88ff0ef          	jal	ra,80003168 <iget>
    800039e4:	a011                	j	800039e8 <dirlookup+0x8c>
  return 0;
    800039e6:	4501                	li	a0,0
}
    800039e8:	70e2                	ld	ra,56(sp)
    800039ea:	7442                	ld	s0,48(sp)
    800039ec:	74a2                	ld	s1,40(sp)
    800039ee:	7902                	ld	s2,32(sp)
    800039f0:	69e2                	ld	s3,24(sp)
    800039f2:	6a42                	ld	s4,16(sp)
    800039f4:	6121                	addi	sp,sp,64
    800039f6:	8082                	ret

00000000800039f8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800039f8:	711d                	addi	sp,sp,-96
    800039fa:	ec86                	sd	ra,88(sp)
    800039fc:	e8a2                	sd	s0,80(sp)
    800039fe:	e4a6                	sd	s1,72(sp)
    80003a00:	e0ca                	sd	s2,64(sp)
    80003a02:	fc4e                	sd	s3,56(sp)
    80003a04:	f852                	sd	s4,48(sp)
    80003a06:	f456                	sd	s5,40(sp)
    80003a08:	f05a                	sd	s6,32(sp)
    80003a0a:	ec5e                	sd	s7,24(sp)
    80003a0c:	e862                	sd	s8,16(sp)
    80003a0e:	e466                	sd	s9,8(sp)
    80003a10:	1080                	addi	s0,sp,96
    80003a12:	84aa                	mv	s1,a0
    80003a14:	8aae                	mv	s5,a1
    80003a16:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a18:	00054703          	lbu	a4,0(a0)
    80003a1c:	02f00793          	li	a5,47
    80003a20:	00f70f63          	beq	a4,a5,80003a3e <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a24:	de9fd0ef          	jal	ra,8000180c <myproc>
    80003a28:	15053503          	ld	a0,336(a0)
    80003a2c:	973ff0ef          	jal	ra,8000339e <idup>
    80003a30:	89aa                	mv	s3,a0
  while(*path == '/')
    80003a32:	02f00913          	li	s2,47
  len = path - s;
    80003a36:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003a38:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a3a:	4b85                	li	s7,1
    80003a3c:	a861                	j	80003ad4 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    80003a3e:	4585                	li	a1,1
    80003a40:	4505                	li	a0,1
    80003a42:	f26ff0ef          	jal	ra,80003168 <iget>
    80003a46:	89aa                	mv	s3,a0
    80003a48:	b7ed                	j	80003a32 <namex+0x3a>
      iunlockput(ip);
    80003a4a:	854e                	mv	a0,s3
    80003a4c:	b8fff0ef          	jal	ra,800035da <iunlockput>
      return 0;
    80003a50:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a52:	854e                	mv	a0,s3
    80003a54:	60e6                	ld	ra,88(sp)
    80003a56:	6446                	ld	s0,80(sp)
    80003a58:	64a6                	ld	s1,72(sp)
    80003a5a:	6906                	ld	s2,64(sp)
    80003a5c:	79e2                	ld	s3,56(sp)
    80003a5e:	7a42                	ld	s4,48(sp)
    80003a60:	7aa2                	ld	s5,40(sp)
    80003a62:	7b02                	ld	s6,32(sp)
    80003a64:	6be2                	ld	s7,24(sp)
    80003a66:	6c42                	ld	s8,16(sp)
    80003a68:	6ca2                	ld	s9,8(sp)
    80003a6a:	6125                	addi	sp,sp,96
    80003a6c:	8082                	ret
      iunlock(ip);
    80003a6e:	854e                	mv	a0,s3
    80003a70:	a0fff0ef          	jal	ra,8000347e <iunlock>
      return ip;
    80003a74:	bff9                	j	80003a52 <namex+0x5a>
      iunlockput(ip);
    80003a76:	854e                	mv	a0,s3
    80003a78:	b63ff0ef          	jal	ra,800035da <iunlockput>
      return 0;
    80003a7c:	89e6                	mv	s3,s9
    80003a7e:	bfd1                	j	80003a52 <namex+0x5a>
  len = path - s;
    80003a80:	40b48633          	sub	a2,s1,a1
    80003a84:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003a88:	079c5c63          	bge	s8,s9,80003b00 <namex+0x108>
    memmove(name, s, DIRSIZ);
    80003a8c:	4639                	li	a2,14
    80003a8e:	8552                	mv	a0,s4
    80003a90:	a0cfd0ef          	jal	ra,80000c9c <memmove>
  while(*path == '/')
    80003a94:	0004c783          	lbu	a5,0(s1)
    80003a98:	01279763          	bne	a5,s2,80003aa6 <namex+0xae>
    path++;
    80003a9c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a9e:	0004c783          	lbu	a5,0(s1)
    80003aa2:	ff278de3          	beq	a5,s2,80003a9c <namex+0xa4>
    ilock(ip);
    80003aa6:	854e                	mv	a0,s3
    80003aa8:	92dff0ef          	jal	ra,800033d4 <ilock>
    if(ip->type != T_DIR){
    80003aac:	04499783          	lh	a5,68(s3)
    80003ab0:	f9779de3          	bne	a5,s7,80003a4a <namex+0x52>
    if(nameiparent && *path == '\0'){
    80003ab4:	000a8563          	beqz	s5,80003abe <namex+0xc6>
    80003ab8:	0004c783          	lbu	a5,0(s1)
    80003abc:	dbcd                	beqz	a5,80003a6e <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003abe:	865a                	mv	a2,s6
    80003ac0:	85d2                	mv	a1,s4
    80003ac2:	854e                	mv	a0,s3
    80003ac4:	e99ff0ef          	jal	ra,8000395c <dirlookup>
    80003ac8:	8caa                	mv	s9,a0
    80003aca:	d555                	beqz	a0,80003a76 <namex+0x7e>
    iunlockput(ip);
    80003acc:	854e                	mv	a0,s3
    80003ace:	b0dff0ef          	jal	ra,800035da <iunlockput>
    ip = next;
    80003ad2:	89e6                	mv	s3,s9
  while(*path == '/')
    80003ad4:	0004c783          	lbu	a5,0(s1)
    80003ad8:	05279363          	bne	a5,s2,80003b1e <namex+0x126>
    path++;
    80003adc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ade:	0004c783          	lbu	a5,0(s1)
    80003ae2:	ff278de3          	beq	a5,s2,80003adc <namex+0xe4>
  if(*path == 0)
    80003ae6:	c78d                	beqz	a5,80003b10 <namex+0x118>
    path++;
    80003ae8:	85a6                	mv	a1,s1
  len = path - s;
    80003aea:	8cda                	mv	s9,s6
    80003aec:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003aee:	01278963          	beq	a5,s2,80003b00 <namex+0x108>
    80003af2:	d7d9                	beqz	a5,80003a80 <namex+0x88>
    path++;
    80003af4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003af6:	0004c783          	lbu	a5,0(s1)
    80003afa:	ff279ce3          	bne	a5,s2,80003af2 <namex+0xfa>
    80003afe:	b749                	j	80003a80 <namex+0x88>
    memmove(name, s, len);
    80003b00:	2601                	sext.w	a2,a2
    80003b02:	8552                	mv	a0,s4
    80003b04:	998fd0ef          	jal	ra,80000c9c <memmove>
    name[len] = 0;
    80003b08:	9cd2                	add	s9,s9,s4
    80003b0a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003b0e:	b759                	j	80003a94 <namex+0x9c>
  if(nameiparent){
    80003b10:	f40a81e3          	beqz	s5,80003a52 <namex+0x5a>
    iput(ip);
    80003b14:	854e                	mv	a0,s3
    80003b16:	a3dff0ef          	jal	ra,80003552 <iput>
    return 0;
    80003b1a:	4981                	li	s3,0
    80003b1c:	bf1d                	j	80003a52 <namex+0x5a>
  if(*path == 0)
    80003b1e:	dbed                	beqz	a5,80003b10 <namex+0x118>
  while(*path != '/' && *path != 0)
    80003b20:	0004c783          	lbu	a5,0(s1)
    80003b24:	85a6                	mv	a1,s1
    80003b26:	b7f1                	j	80003af2 <namex+0xfa>

0000000080003b28 <dirlink>:
{
    80003b28:	7139                	addi	sp,sp,-64
    80003b2a:	fc06                	sd	ra,56(sp)
    80003b2c:	f822                	sd	s0,48(sp)
    80003b2e:	f426                	sd	s1,40(sp)
    80003b30:	f04a                	sd	s2,32(sp)
    80003b32:	ec4e                	sd	s3,24(sp)
    80003b34:	e852                	sd	s4,16(sp)
    80003b36:	0080                	addi	s0,sp,64
    80003b38:	892a                	mv	s2,a0
    80003b3a:	8a2e                	mv	s4,a1
    80003b3c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b3e:	4601                	li	a2,0
    80003b40:	e1dff0ef          	jal	ra,8000395c <dirlookup>
    80003b44:	e52d                	bnez	a0,80003bae <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b46:	04c92483          	lw	s1,76(s2)
    80003b4a:	c48d                	beqz	s1,80003b74 <dirlink+0x4c>
    80003b4c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b4e:	4741                	li	a4,16
    80003b50:	86a6                	mv	a3,s1
    80003b52:	fc040613          	addi	a2,s0,-64
    80003b56:	4581                	li	a1,0
    80003b58:	854a                	mv	a0,s2
    80003b5a:	c07ff0ef          	jal	ra,80003760 <readi>
    80003b5e:	47c1                	li	a5,16
    80003b60:	04f51b63          	bne	a0,a5,80003bb6 <dirlink+0x8e>
    if(de.inum == 0)
    80003b64:	fc045783          	lhu	a5,-64(s0)
    80003b68:	c791                	beqz	a5,80003b74 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b6a:	24c1                	addiw	s1,s1,16
    80003b6c:	04c92783          	lw	a5,76(s2)
    80003b70:	fcf4efe3          	bltu	s1,a5,80003b4e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003b74:	4639                	li	a2,14
    80003b76:	85d2                	mv	a1,s4
    80003b78:	fc240513          	addi	a0,s0,-62
    80003b7c:	9ccfd0ef          	jal	ra,80000d48 <strncpy>
  de.inum = inum;
    80003b80:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b84:	4741                	li	a4,16
    80003b86:	86a6                	mv	a3,s1
    80003b88:	fc040613          	addi	a2,s0,-64
    80003b8c:	4581                	li	a1,0
    80003b8e:	854a                	mv	a0,s2
    80003b90:	cb5ff0ef          	jal	ra,80003844 <writei>
    80003b94:	1541                	addi	a0,a0,-16
    80003b96:	00a03533          	snez	a0,a0
    80003b9a:	40a00533          	neg	a0,a0
}
    80003b9e:	70e2                	ld	ra,56(sp)
    80003ba0:	7442                	ld	s0,48(sp)
    80003ba2:	74a2                	ld	s1,40(sp)
    80003ba4:	7902                	ld	s2,32(sp)
    80003ba6:	69e2                	ld	s3,24(sp)
    80003ba8:	6a42                	ld	s4,16(sp)
    80003baa:	6121                	addi	sp,sp,64
    80003bac:	8082                	ret
    iput(ip);
    80003bae:	9a5ff0ef          	jal	ra,80003552 <iput>
    return -1;
    80003bb2:	557d                	li	a0,-1
    80003bb4:	b7ed                	j	80003b9e <dirlink+0x76>
      panic("dirlink read");
    80003bb6:	00004517          	auipc	a0,0x4
    80003bba:	b8250513          	addi	a0,a0,-1150 # 80007738 <states.0+0x168>
    80003bbe:	bcdfc0ef          	jal	ra,8000078a <panic>

0000000080003bc2 <namei>:

struct inode*
namei(char *path)
{
    80003bc2:	1101                	addi	sp,sp,-32
    80003bc4:	ec06                	sd	ra,24(sp)
    80003bc6:	e822                	sd	s0,16(sp)
    80003bc8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003bca:	fe040613          	addi	a2,s0,-32
    80003bce:	4581                	li	a1,0
    80003bd0:	e29ff0ef          	jal	ra,800039f8 <namex>
}
    80003bd4:	60e2                	ld	ra,24(sp)
    80003bd6:	6442                	ld	s0,16(sp)
    80003bd8:	6105                	addi	sp,sp,32
    80003bda:	8082                	ret

0000000080003bdc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003bdc:	1141                	addi	sp,sp,-16
    80003bde:	e406                	sd	ra,8(sp)
    80003be0:	e022                	sd	s0,0(sp)
    80003be2:	0800                	addi	s0,sp,16
    80003be4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003be6:	4585                	li	a1,1
    80003be8:	e11ff0ef          	jal	ra,800039f8 <namex>
}
    80003bec:	60a2                	ld	ra,8(sp)
    80003bee:	6402                	ld	s0,0(sp)
    80003bf0:	0141                	addi	sp,sp,16
    80003bf2:	8082                	ret

0000000080003bf4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003bf4:	1101                	addi	sp,sp,-32
    80003bf6:	ec06                	sd	ra,24(sp)
    80003bf8:	e822                	sd	s0,16(sp)
    80003bfa:	e426                	sd	s1,8(sp)
    80003bfc:	e04a                	sd	s2,0(sp)
    80003bfe:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c00:	0001c917          	auipc	s2,0x1c
    80003c04:	28890913          	addi	s2,s2,648 # 8001fe88 <log>
    80003c08:	01892583          	lw	a1,24(s2)
    80003c0c:	02492503          	lw	a0,36(s2)
    80003c10:	912ff0ef          	jal	ra,80002d22 <bread>
    80003c14:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c16:	02892683          	lw	a3,40(s2)
    80003c1a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c1c:	02d05763          	blez	a3,80003c4a <write_head+0x56>
    80003c20:	0001c797          	auipc	a5,0x1c
    80003c24:	29478793          	addi	a5,a5,660 # 8001feb4 <log+0x2c>
    80003c28:	05c50713          	addi	a4,a0,92
    80003c2c:	36fd                	addiw	a3,a3,-1
    80003c2e:	1682                	slli	a3,a3,0x20
    80003c30:	9281                	srli	a3,a3,0x20
    80003c32:	068a                	slli	a3,a3,0x2
    80003c34:	0001c617          	auipc	a2,0x1c
    80003c38:	28460613          	addi	a2,a2,644 # 8001feb8 <log+0x30>
    80003c3c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003c3e:	4390                	lw	a2,0(a5)
    80003c40:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c42:	0791                	addi	a5,a5,4
    80003c44:	0711                	addi	a4,a4,4
    80003c46:	fed79ce3          	bne	a5,a3,80003c3e <write_head+0x4a>
  }
  bwrite(buf);
    80003c4a:	8526                	mv	a0,s1
    80003c4c:	9acff0ef          	jal	ra,80002df8 <bwrite>
  brelse(buf);
    80003c50:	8526                	mv	a0,s1
    80003c52:	9d8ff0ef          	jal	ra,80002e2a <brelse>
}
    80003c56:	60e2                	ld	ra,24(sp)
    80003c58:	6442                	ld	s0,16(sp)
    80003c5a:	64a2                	ld	s1,8(sp)
    80003c5c:	6902                	ld	s2,0(sp)
    80003c5e:	6105                	addi	sp,sp,32
    80003c60:	8082                	ret

0000000080003c62 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c62:	0001c797          	auipc	a5,0x1c
    80003c66:	24e7a783          	lw	a5,590(a5) # 8001feb0 <log+0x28>
    80003c6a:	0af05e63          	blez	a5,80003d26 <install_trans+0xc4>
{
    80003c6e:	715d                	addi	sp,sp,-80
    80003c70:	e486                	sd	ra,72(sp)
    80003c72:	e0a2                	sd	s0,64(sp)
    80003c74:	fc26                	sd	s1,56(sp)
    80003c76:	f84a                	sd	s2,48(sp)
    80003c78:	f44e                	sd	s3,40(sp)
    80003c7a:	f052                	sd	s4,32(sp)
    80003c7c:	ec56                	sd	s5,24(sp)
    80003c7e:	e85a                	sd	s6,16(sp)
    80003c80:	e45e                	sd	s7,8(sp)
    80003c82:	0880                	addi	s0,sp,80
    80003c84:	8b2a                	mv	s6,a0
    80003c86:	0001ca97          	auipc	s5,0x1c
    80003c8a:	22ea8a93          	addi	s5,s5,558 # 8001feb4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c8e:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c90:	00004b97          	auipc	s7,0x4
    80003c94:	ab8b8b93          	addi	s7,s7,-1352 # 80007748 <states.0+0x178>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c98:	0001ca17          	auipc	s4,0x1c
    80003c9c:	1f0a0a13          	addi	s4,s4,496 # 8001fe88 <log>
    80003ca0:	a025                	j	80003cc8 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ca2:	000aa603          	lw	a2,0(s5)
    80003ca6:	85ce                	mv	a1,s3
    80003ca8:	855e                	mv	a0,s7
    80003caa:	81bfc0ef          	jal	ra,800004c4 <printf>
    80003cae:	a839                	j	80003ccc <install_trans+0x6a>
    brelse(lbuf);
    80003cb0:	854a                	mv	a0,s2
    80003cb2:	978ff0ef          	jal	ra,80002e2a <brelse>
    brelse(dbuf);
    80003cb6:	8526                	mv	a0,s1
    80003cb8:	972ff0ef          	jal	ra,80002e2a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cbc:	2985                	addiw	s3,s3,1
    80003cbe:	0a91                	addi	s5,s5,4
    80003cc0:	028a2783          	lw	a5,40(s4)
    80003cc4:	04f9d663          	bge	s3,a5,80003d10 <install_trans+0xae>
    if(recovering) {
    80003cc8:	fc0b1de3          	bnez	s6,80003ca2 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ccc:	018a2583          	lw	a1,24(s4)
    80003cd0:	013585bb          	addw	a1,a1,s3
    80003cd4:	2585                	addiw	a1,a1,1
    80003cd6:	024a2503          	lw	a0,36(s4)
    80003cda:	848ff0ef          	jal	ra,80002d22 <bread>
    80003cde:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ce0:	000aa583          	lw	a1,0(s5)
    80003ce4:	024a2503          	lw	a0,36(s4)
    80003ce8:	83aff0ef          	jal	ra,80002d22 <bread>
    80003cec:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003cee:	40000613          	li	a2,1024
    80003cf2:	05890593          	addi	a1,s2,88
    80003cf6:	05850513          	addi	a0,a0,88
    80003cfa:	fa3fc0ef          	jal	ra,80000c9c <memmove>
    bwrite(dbuf);  // write dst to disk
    80003cfe:	8526                	mv	a0,s1
    80003d00:	8f8ff0ef          	jal	ra,80002df8 <bwrite>
    if(recovering == 0)
    80003d04:	fa0b16e3          	bnez	s6,80003cb0 <install_trans+0x4e>
      bunpin(dbuf);
    80003d08:	8526                	mv	a0,s1
    80003d0a:	9deff0ef          	jal	ra,80002ee8 <bunpin>
    80003d0e:	b74d                	j	80003cb0 <install_trans+0x4e>
}
    80003d10:	60a6                	ld	ra,72(sp)
    80003d12:	6406                	ld	s0,64(sp)
    80003d14:	74e2                	ld	s1,56(sp)
    80003d16:	7942                	ld	s2,48(sp)
    80003d18:	79a2                	ld	s3,40(sp)
    80003d1a:	7a02                	ld	s4,32(sp)
    80003d1c:	6ae2                	ld	s5,24(sp)
    80003d1e:	6b42                	ld	s6,16(sp)
    80003d20:	6ba2                	ld	s7,8(sp)
    80003d22:	6161                	addi	sp,sp,80
    80003d24:	8082                	ret
    80003d26:	8082                	ret

0000000080003d28 <initlog>:
{
    80003d28:	7179                	addi	sp,sp,-48
    80003d2a:	f406                	sd	ra,40(sp)
    80003d2c:	f022                	sd	s0,32(sp)
    80003d2e:	ec26                	sd	s1,24(sp)
    80003d30:	e84a                	sd	s2,16(sp)
    80003d32:	e44e                	sd	s3,8(sp)
    80003d34:	1800                	addi	s0,sp,48
    80003d36:	892a                	mv	s2,a0
    80003d38:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d3a:	0001c497          	auipc	s1,0x1c
    80003d3e:	14e48493          	addi	s1,s1,334 # 8001fe88 <log>
    80003d42:	00004597          	auipc	a1,0x4
    80003d46:	a2658593          	addi	a1,a1,-1498 # 80007768 <states.0+0x198>
    80003d4a:	8526                	mv	a0,s1
    80003d4c:	da1fc0ef          	jal	ra,80000aec <initlock>
  log.start = sb->logstart;
    80003d50:	0149a583          	lw	a1,20(s3)
    80003d54:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003d56:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003d5a:	854a                	mv	a0,s2
    80003d5c:	fc7fe0ef          	jal	ra,80002d22 <bread>
  log.lh.n = lh->n;
    80003d60:	4d34                	lw	a3,88(a0)
    80003d62:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003d64:	02d05563          	blez	a3,80003d8e <initlog+0x66>
    80003d68:	05c50793          	addi	a5,a0,92
    80003d6c:	0001c717          	auipc	a4,0x1c
    80003d70:	14870713          	addi	a4,a4,328 # 8001feb4 <log+0x2c>
    80003d74:	36fd                	addiw	a3,a3,-1
    80003d76:	1682                	slli	a3,a3,0x20
    80003d78:	9281                	srli	a3,a3,0x20
    80003d7a:	068a                	slli	a3,a3,0x2
    80003d7c:	06050613          	addi	a2,a0,96
    80003d80:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003d82:	4390                	lw	a2,0(a5)
    80003d84:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d86:	0791                	addi	a5,a5,4
    80003d88:	0711                	addi	a4,a4,4
    80003d8a:	fed79ce3          	bne	a5,a3,80003d82 <initlog+0x5a>
  brelse(buf);
    80003d8e:	89cff0ef          	jal	ra,80002e2a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d92:	4505                	li	a0,1
    80003d94:	ecfff0ef          	jal	ra,80003c62 <install_trans>
  log.lh.n = 0;
    80003d98:	0001c797          	auipc	a5,0x1c
    80003d9c:	1007ac23          	sw	zero,280(a5) # 8001feb0 <log+0x28>
  write_head(); // clear the log
    80003da0:	e55ff0ef          	jal	ra,80003bf4 <write_head>
}
    80003da4:	70a2                	ld	ra,40(sp)
    80003da6:	7402                	ld	s0,32(sp)
    80003da8:	64e2                	ld	s1,24(sp)
    80003daa:	6942                	ld	s2,16(sp)
    80003dac:	69a2                	ld	s3,8(sp)
    80003dae:	6145                	addi	sp,sp,48
    80003db0:	8082                	ret

0000000080003db2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003db2:	1101                	addi	sp,sp,-32
    80003db4:	ec06                	sd	ra,24(sp)
    80003db6:	e822                	sd	s0,16(sp)
    80003db8:	e426                	sd	s1,8(sp)
    80003dba:	e04a                	sd	s2,0(sp)
    80003dbc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003dbe:	0001c517          	auipc	a0,0x1c
    80003dc2:	0ca50513          	addi	a0,a0,202 # 8001fe88 <log>
    80003dc6:	da7fc0ef          	jal	ra,80000b6c <acquire>
  while(1){
    if(log.committing){
    80003dca:	0001c497          	auipc	s1,0x1c
    80003dce:	0be48493          	addi	s1,s1,190 # 8001fe88 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003dd2:	4979                	li	s2,30
    80003dd4:	a029                	j	80003dde <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003dd6:	85a6                	mv	a1,s1
    80003dd8:	8526                	mv	a0,s1
    80003dda:	850fe0ef          	jal	ra,80001e2a <sleep>
    if(log.committing){
    80003dde:	509c                	lw	a5,32(s1)
    80003de0:	fbfd                	bnez	a5,80003dd6 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003de2:	4cdc                	lw	a5,28(s1)
    80003de4:	0017871b          	addiw	a4,a5,1
    80003de8:	0007069b          	sext.w	a3,a4
    80003dec:	0027179b          	slliw	a5,a4,0x2
    80003df0:	9fb9                	addw	a5,a5,a4
    80003df2:	0017979b          	slliw	a5,a5,0x1
    80003df6:	5498                	lw	a4,40(s1)
    80003df8:	9fb9                	addw	a5,a5,a4
    80003dfa:	00f95763          	bge	s2,a5,80003e08 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003dfe:	85a6                	mv	a1,s1
    80003e00:	8526                	mv	a0,s1
    80003e02:	828fe0ef          	jal	ra,80001e2a <sleep>
    80003e06:	bfe1                	j	80003dde <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e08:	0001c517          	auipc	a0,0x1c
    80003e0c:	08050513          	addi	a0,a0,128 # 8001fe88 <log>
    80003e10:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003e12:	df3fc0ef          	jal	ra,80000c04 <release>
      break;
    }
  }
}
    80003e16:	60e2                	ld	ra,24(sp)
    80003e18:	6442                	ld	s0,16(sp)
    80003e1a:	64a2                	ld	s1,8(sp)
    80003e1c:	6902                	ld	s2,0(sp)
    80003e1e:	6105                	addi	sp,sp,32
    80003e20:	8082                	ret

0000000080003e22 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e22:	7139                	addi	sp,sp,-64
    80003e24:	fc06                	sd	ra,56(sp)
    80003e26:	f822                	sd	s0,48(sp)
    80003e28:	f426                	sd	s1,40(sp)
    80003e2a:	f04a                	sd	s2,32(sp)
    80003e2c:	ec4e                	sd	s3,24(sp)
    80003e2e:	e852                	sd	s4,16(sp)
    80003e30:	e456                	sd	s5,8(sp)
    80003e32:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e34:	0001c497          	auipc	s1,0x1c
    80003e38:	05448493          	addi	s1,s1,84 # 8001fe88 <log>
    80003e3c:	8526                	mv	a0,s1
    80003e3e:	d2ffc0ef          	jal	ra,80000b6c <acquire>
  log.outstanding -= 1;
    80003e42:	4cdc                	lw	a5,28(s1)
    80003e44:	37fd                	addiw	a5,a5,-1
    80003e46:	0007891b          	sext.w	s2,a5
    80003e4a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003e4c:	509c                	lw	a5,32(s1)
    80003e4e:	ef9d                	bnez	a5,80003e8c <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003e50:	04091463          	bnez	s2,80003e98 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003e54:	0001c497          	auipc	s1,0x1c
    80003e58:	03448493          	addi	s1,s1,52 # 8001fe88 <log>
    80003e5c:	4785                	li	a5,1
    80003e5e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e60:	8526                	mv	a0,s1
    80003e62:	da3fc0ef          	jal	ra,80000c04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e66:	549c                	lw	a5,40(s1)
    80003e68:	04f04b63          	bgtz	a5,80003ebe <end_op+0x9c>
    acquire(&log.lock);
    80003e6c:	0001c497          	auipc	s1,0x1c
    80003e70:	01c48493          	addi	s1,s1,28 # 8001fe88 <log>
    80003e74:	8526                	mv	a0,s1
    80003e76:	cf7fc0ef          	jal	ra,80000b6c <acquire>
    log.committing = 0;
    80003e7a:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003e7e:	8526                	mv	a0,s1
    80003e80:	ff7fd0ef          	jal	ra,80001e76 <wakeup>
    release(&log.lock);
    80003e84:	8526                	mv	a0,s1
    80003e86:	d7ffc0ef          	jal	ra,80000c04 <release>
}
    80003e8a:	a00d                	j	80003eac <end_op+0x8a>
    panic("log.committing");
    80003e8c:	00004517          	auipc	a0,0x4
    80003e90:	8e450513          	addi	a0,a0,-1820 # 80007770 <states.0+0x1a0>
    80003e94:	8f7fc0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    80003e98:	0001c497          	auipc	s1,0x1c
    80003e9c:	ff048493          	addi	s1,s1,-16 # 8001fe88 <log>
    80003ea0:	8526                	mv	a0,s1
    80003ea2:	fd5fd0ef          	jal	ra,80001e76 <wakeup>
  release(&log.lock);
    80003ea6:	8526                	mv	a0,s1
    80003ea8:	d5dfc0ef          	jal	ra,80000c04 <release>
}
    80003eac:	70e2                	ld	ra,56(sp)
    80003eae:	7442                	ld	s0,48(sp)
    80003eb0:	74a2                	ld	s1,40(sp)
    80003eb2:	7902                	ld	s2,32(sp)
    80003eb4:	69e2                	ld	s3,24(sp)
    80003eb6:	6a42                	ld	s4,16(sp)
    80003eb8:	6aa2                	ld	s5,8(sp)
    80003eba:	6121                	addi	sp,sp,64
    80003ebc:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ebe:	0001ca97          	auipc	s5,0x1c
    80003ec2:	ff6a8a93          	addi	s5,s5,-10 # 8001feb4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003ec6:	0001ca17          	auipc	s4,0x1c
    80003eca:	fc2a0a13          	addi	s4,s4,-62 # 8001fe88 <log>
    80003ece:	018a2583          	lw	a1,24(s4)
    80003ed2:	012585bb          	addw	a1,a1,s2
    80003ed6:	2585                	addiw	a1,a1,1
    80003ed8:	024a2503          	lw	a0,36(s4)
    80003edc:	e47fe0ef          	jal	ra,80002d22 <bread>
    80003ee0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003ee2:	000aa583          	lw	a1,0(s5)
    80003ee6:	024a2503          	lw	a0,36(s4)
    80003eea:	e39fe0ef          	jal	ra,80002d22 <bread>
    80003eee:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ef0:	40000613          	li	a2,1024
    80003ef4:	05850593          	addi	a1,a0,88
    80003ef8:	05848513          	addi	a0,s1,88
    80003efc:	da1fc0ef          	jal	ra,80000c9c <memmove>
    bwrite(to);  // write the log
    80003f00:	8526                	mv	a0,s1
    80003f02:	ef7fe0ef          	jal	ra,80002df8 <bwrite>
    brelse(from);
    80003f06:	854e                	mv	a0,s3
    80003f08:	f23fe0ef          	jal	ra,80002e2a <brelse>
    brelse(to);
    80003f0c:	8526                	mv	a0,s1
    80003f0e:	f1dfe0ef          	jal	ra,80002e2a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f12:	2905                	addiw	s2,s2,1
    80003f14:	0a91                	addi	s5,s5,4
    80003f16:	028a2783          	lw	a5,40(s4)
    80003f1a:	faf94ae3          	blt	s2,a5,80003ece <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f1e:	cd7ff0ef          	jal	ra,80003bf4 <write_head>
    install_trans(0); // Now install writes to home locations
    80003f22:	4501                	li	a0,0
    80003f24:	d3fff0ef          	jal	ra,80003c62 <install_trans>
    log.lh.n = 0;
    80003f28:	0001c797          	auipc	a5,0x1c
    80003f2c:	f807a423          	sw	zero,-120(a5) # 8001feb0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003f30:	cc5ff0ef          	jal	ra,80003bf4 <write_head>
    80003f34:	bf25                	j	80003e6c <end_op+0x4a>

0000000080003f36 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f36:	1101                	addi	sp,sp,-32
    80003f38:	ec06                	sd	ra,24(sp)
    80003f3a:	e822                	sd	s0,16(sp)
    80003f3c:	e426                	sd	s1,8(sp)
    80003f3e:	e04a                	sd	s2,0(sp)
    80003f40:	1000                	addi	s0,sp,32
    80003f42:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f44:	0001c917          	auipc	s2,0x1c
    80003f48:	f4490913          	addi	s2,s2,-188 # 8001fe88 <log>
    80003f4c:	854a                	mv	a0,s2
    80003f4e:	c1ffc0ef          	jal	ra,80000b6c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f52:	02892603          	lw	a2,40(s2)
    80003f56:	47f5                	li	a5,29
    80003f58:	04c7cc63          	blt	a5,a2,80003fb0 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f5c:	0001c797          	auipc	a5,0x1c
    80003f60:	f487a783          	lw	a5,-184(a5) # 8001fea4 <log+0x1c>
    80003f64:	04f05c63          	blez	a5,80003fbc <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f68:	4781                	li	a5,0
    80003f6a:	04c05f63          	blez	a2,80003fc8 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f6e:	44cc                	lw	a1,12(s1)
    80003f70:	0001c717          	auipc	a4,0x1c
    80003f74:	f4470713          	addi	a4,a4,-188 # 8001feb4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003f78:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f7a:	4314                	lw	a3,0(a4)
    80003f7c:	04b68663          	beq	a3,a1,80003fc8 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003f80:	2785                	addiw	a5,a5,1
    80003f82:	0711                	addi	a4,a4,4
    80003f84:	fef61be3          	bne	a2,a5,80003f7a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f88:	0621                	addi	a2,a2,8
    80003f8a:	060a                	slli	a2,a2,0x2
    80003f8c:	0001c797          	auipc	a5,0x1c
    80003f90:	efc78793          	addi	a5,a5,-260 # 8001fe88 <log>
    80003f94:	963e                	add	a2,a2,a5
    80003f96:	44dc                	lw	a5,12(s1)
    80003f98:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003f9a:	8526                	mv	a0,s1
    80003f9c:	f19fe0ef          	jal	ra,80002eb4 <bpin>
    log.lh.n++;
    80003fa0:	0001c717          	auipc	a4,0x1c
    80003fa4:	ee870713          	addi	a4,a4,-280 # 8001fe88 <log>
    80003fa8:	571c                	lw	a5,40(a4)
    80003faa:	2785                	addiw	a5,a5,1
    80003fac:	d71c                	sw	a5,40(a4)
    80003fae:	a815                	j	80003fe2 <log_write+0xac>
    panic("too big a transaction");
    80003fb0:	00003517          	auipc	a0,0x3
    80003fb4:	7d050513          	addi	a0,a0,2000 # 80007780 <states.0+0x1b0>
    80003fb8:	fd2fc0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    80003fbc:	00003517          	auipc	a0,0x3
    80003fc0:	7dc50513          	addi	a0,a0,2012 # 80007798 <states.0+0x1c8>
    80003fc4:	fc6fc0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    80003fc8:	00878713          	addi	a4,a5,8
    80003fcc:	00271693          	slli	a3,a4,0x2
    80003fd0:	0001c717          	auipc	a4,0x1c
    80003fd4:	eb870713          	addi	a4,a4,-328 # 8001fe88 <log>
    80003fd8:	9736                	add	a4,a4,a3
    80003fda:	44d4                	lw	a3,12(s1)
    80003fdc:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003fde:	faf60ee3          	beq	a2,a5,80003f9a <log_write+0x64>
  }
  release(&log.lock);
    80003fe2:	0001c517          	auipc	a0,0x1c
    80003fe6:	ea650513          	addi	a0,a0,-346 # 8001fe88 <log>
    80003fea:	c1bfc0ef          	jal	ra,80000c04 <release>
}
    80003fee:	60e2                	ld	ra,24(sp)
    80003ff0:	6442                	ld	s0,16(sp)
    80003ff2:	64a2                	ld	s1,8(sp)
    80003ff4:	6902                	ld	s2,0(sp)
    80003ff6:	6105                	addi	sp,sp,32
    80003ff8:	8082                	ret

0000000080003ffa <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003ffa:	1101                	addi	sp,sp,-32
    80003ffc:	ec06                	sd	ra,24(sp)
    80003ffe:	e822                	sd	s0,16(sp)
    80004000:	e426                	sd	s1,8(sp)
    80004002:	e04a                	sd	s2,0(sp)
    80004004:	1000                	addi	s0,sp,32
    80004006:	84aa                	mv	s1,a0
    80004008:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000400a:	00003597          	auipc	a1,0x3
    8000400e:	7ae58593          	addi	a1,a1,1966 # 800077b8 <states.0+0x1e8>
    80004012:	0521                	addi	a0,a0,8
    80004014:	ad9fc0ef          	jal	ra,80000aec <initlock>
  lk->name = name;
    80004018:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000401c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004020:	0204a423          	sw	zero,40(s1)
}
    80004024:	60e2                	ld	ra,24(sp)
    80004026:	6442                	ld	s0,16(sp)
    80004028:	64a2                	ld	s1,8(sp)
    8000402a:	6902                	ld	s2,0(sp)
    8000402c:	6105                	addi	sp,sp,32
    8000402e:	8082                	ret

0000000080004030 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004030:	1101                	addi	sp,sp,-32
    80004032:	ec06                	sd	ra,24(sp)
    80004034:	e822                	sd	s0,16(sp)
    80004036:	e426                	sd	s1,8(sp)
    80004038:	e04a                	sd	s2,0(sp)
    8000403a:	1000                	addi	s0,sp,32
    8000403c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000403e:	00850913          	addi	s2,a0,8
    80004042:	854a                	mv	a0,s2
    80004044:	b29fc0ef          	jal	ra,80000b6c <acquire>
  while (lk->locked) {
    80004048:	409c                	lw	a5,0(s1)
    8000404a:	c799                	beqz	a5,80004058 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000404c:	85ca                	mv	a1,s2
    8000404e:	8526                	mv	a0,s1
    80004050:	ddbfd0ef          	jal	ra,80001e2a <sleep>
  while (lk->locked) {
    80004054:	409c                	lw	a5,0(s1)
    80004056:	fbfd                	bnez	a5,8000404c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004058:	4785                	li	a5,1
    8000405a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000405c:	fb0fd0ef          	jal	ra,8000180c <myproc>
    80004060:	591c                	lw	a5,48(a0)
    80004062:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004064:	854a                	mv	a0,s2
    80004066:	b9ffc0ef          	jal	ra,80000c04 <release>
}
    8000406a:	60e2                	ld	ra,24(sp)
    8000406c:	6442                	ld	s0,16(sp)
    8000406e:	64a2                	ld	s1,8(sp)
    80004070:	6902                	ld	s2,0(sp)
    80004072:	6105                	addi	sp,sp,32
    80004074:	8082                	ret

0000000080004076 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004076:	1101                	addi	sp,sp,-32
    80004078:	ec06                	sd	ra,24(sp)
    8000407a:	e822                	sd	s0,16(sp)
    8000407c:	e426                	sd	s1,8(sp)
    8000407e:	e04a                	sd	s2,0(sp)
    80004080:	1000                	addi	s0,sp,32
    80004082:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004084:	00850913          	addi	s2,a0,8
    80004088:	854a                	mv	a0,s2
    8000408a:	ae3fc0ef          	jal	ra,80000b6c <acquire>
  lk->locked = 0;
    8000408e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004092:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004096:	8526                	mv	a0,s1
    80004098:	ddffd0ef          	jal	ra,80001e76 <wakeup>
  release(&lk->lk);
    8000409c:	854a                	mv	a0,s2
    8000409e:	b67fc0ef          	jal	ra,80000c04 <release>
}
    800040a2:	60e2                	ld	ra,24(sp)
    800040a4:	6442                	ld	s0,16(sp)
    800040a6:	64a2                	ld	s1,8(sp)
    800040a8:	6902                	ld	s2,0(sp)
    800040aa:	6105                	addi	sp,sp,32
    800040ac:	8082                	ret

00000000800040ae <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800040ae:	7179                	addi	sp,sp,-48
    800040b0:	f406                	sd	ra,40(sp)
    800040b2:	f022                	sd	s0,32(sp)
    800040b4:	ec26                	sd	s1,24(sp)
    800040b6:	e84a                	sd	s2,16(sp)
    800040b8:	e44e                	sd	s3,8(sp)
    800040ba:	1800                	addi	s0,sp,48
    800040bc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800040be:	00850913          	addi	s2,a0,8
    800040c2:	854a                	mv	a0,s2
    800040c4:	aa9fc0ef          	jal	ra,80000b6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040c8:	409c                	lw	a5,0(s1)
    800040ca:	ef89                	bnez	a5,800040e4 <holdingsleep+0x36>
    800040cc:	4481                	li	s1,0
  release(&lk->lk);
    800040ce:	854a                	mv	a0,s2
    800040d0:	b35fc0ef          	jal	ra,80000c04 <release>
  return r;
}
    800040d4:	8526                	mv	a0,s1
    800040d6:	70a2                	ld	ra,40(sp)
    800040d8:	7402                	ld	s0,32(sp)
    800040da:	64e2                	ld	s1,24(sp)
    800040dc:	6942                	ld	s2,16(sp)
    800040de:	69a2                	ld	s3,8(sp)
    800040e0:	6145                	addi	sp,sp,48
    800040e2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800040e4:	0284a983          	lw	s3,40(s1)
    800040e8:	f24fd0ef          	jal	ra,8000180c <myproc>
    800040ec:	5904                	lw	s1,48(a0)
    800040ee:	413484b3          	sub	s1,s1,s3
    800040f2:	0014b493          	seqz	s1,s1
    800040f6:	bfe1                	j	800040ce <holdingsleep+0x20>

00000000800040f8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800040f8:	1141                	addi	sp,sp,-16
    800040fa:	e406                	sd	ra,8(sp)
    800040fc:	e022                	sd	s0,0(sp)
    800040fe:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004100:	00003597          	auipc	a1,0x3
    80004104:	6c858593          	addi	a1,a1,1736 # 800077c8 <states.0+0x1f8>
    80004108:	0001c517          	auipc	a0,0x1c
    8000410c:	ec850513          	addi	a0,a0,-312 # 8001ffd0 <ftable>
    80004110:	9ddfc0ef          	jal	ra,80000aec <initlock>
}
    80004114:	60a2                	ld	ra,8(sp)
    80004116:	6402                	ld	s0,0(sp)
    80004118:	0141                	addi	sp,sp,16
    8000411a:	8082                	ret

000000008000411c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000411c:	1101                	addi	sp,sp,-32
    8000411e:	ec06                	sd	ra,24(sp)
    80004120:	e822                	sd	s0,16(sp)
    80004122:	e426                	sd	s1,8(sp)
    80004124:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004126:	0001c517          	auipc	a0,0x1c
    8000412a:	eaa50513          	addi	a0,a0,-342 # 8001ffd0 <ftable>
    8000412e:	a3ffc0ef          	jal	ra,80000b6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004132:	0001c497          	auipc	s1,0x1c
    80004136:	eb648493          	addi	s1,s1,-330 # 8001ffe8 <ftable+0x18>
    8000413a:	0001d717          	auipc	a4,0x1d
    8000413e:	e4e70713          	addi	a4,a4,-434 # 80020f88 <disk>
    if(f->ref == 0){
    80004142:	40dc                	lw	a5,4(s1)
    80004144:	cf89                	beqz	a5,8000415e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004146:	02848493          	addi	s1,s1,40
    8000414a:	fee49ce3          	bne	s1,a4,80004142 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000414e:	0001c517          	auipc	a0,0x1c
    80004152:	e8250513          	addi	a0,a0,-382 # 8001ffd0 <ftable>
    80004156:	aaffc0ef          	jal	ra,80000c04 <release>
  return 0;
    8000415a:	4481                	li	s1,0
    8000415c:	a809                	j	8000416e <filealloc+0x52>
      f->ref = 1;
    8000415e:	4785                	li	a5,1
    80004160:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004162:	0001c517          	auipc	a0,0x1c
    80004166:	e6e50513          	addi	a0,a0,-402 # 8001ffd0 <ftable>
    8000416a:	a9bfc0ef          	jal	ra,80000c04 <release>
}
    8000416e:	8526                	mv	a0,s1
    80004170:	60e2                	ld	ra,24(sp)
    80004172:	6442                	ld	s0,16(sp)
    80004174:	64a2                	ld	s1,8(sp)
    80004176:	6105                	addi	sp,sp,32
    80004178:	8082                	ret

000000008000417a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000417a:	1101                	addi	sp,sp,-32
    8000417c:	ec06                	sd	ra,24(sp)
    8000417e:	e822                	sd	s0,16(sp)
    80004180:	e426                	sd	s1,8(sp)
    80004182:	1000                	addi	s0,sp,32
    80004184:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004186:	0001c517          	auipc	a0,0x1c
    8000418a:	e4a50513          	addi	a0,a0,-438 # 8001ffd0 <ftable>
    8000418e:	9dffc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    80004192:	40dc                	lw	a5,4(s1)
    80004194:	02f05063          	blez	a5,800041b4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004198:	2785                	addiw	a5,a5,1
    8000419a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000419c:	0001c517          	auipc	a0,0x1c
    800041a0:	e3450513          	addi	a0,a0,-460 # 8001ffd0 <ftable>
    800041a4:	a61fc0ef          	jal	ra,80000c04 <release>
  return f;
}
    800041a8:	8526                	mv	a0,s1
    800041aa:	60e2                	ld	ra,24(sp)
    800041ac:	6442                	ld	s0,16(sp)
    800041ae:	64a2                	ld	s1,8(sp)
    800041b0:	6105                	addi	sp,sp,32
    800041b2:	8082                	ret
    panic("filedup");
    800041b4:	00003517          	auipc	a0,0x3
    800041b8:	61c50513          	addi	a0,a0,1564 # 800077d0 <states.0+0x200>
    800041bc:	dcefc0ef          	jal	ra,8000078a <panic>

00000000800041c0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800041c0:	7139                	addi	sp,sp,-64
    800041c2:	fc06                	sd	ra,56(sp)
    800041c4:	f822                	sd	s0,48(sp)
    800041c6:	f426                	sd	s1,40(sp)
    800041c8:	f04a                	sd	s2,32(sp)
    800041ca:	ec4e                	sd	s3,24(sp)
    800041cc:	e852                	sd	s4,16(sp)
    800041ce:	e456                	sd	s5,8(sp)
    800041d0:	0080                	addi	s0,sp,64
    800041d2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041d4:	0001c517          	auipc	a0,0x1c
    800041d8:	dfc50513          	addi	a0,a0,-516 # 8001ffd0 <ftable>
    800041dc:	991fc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    800041e0:	40dc                	lw	a5,4(s1)
    800041e2:	04f05963          	blez	a5,80004234 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    800041e6:	37fd                	addiw	a5,a5,-1
    800041e8:	0007871b          	sext.w	a4,a5
    800041ec:	c0dc                	sw	a5,4(s1)
    800041ee:	04e04963          	bgtz	a4,80004240 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800041f2:	0004a903          	lw	s2,0(s1)
    800041f6:	0094ca83          	lbu	s5,9(s1)
    800041fa:	0104ba03          	ld	s4,16(s1)
    800041fe:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004202:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004206:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000420a:	0001c517          	auipc	a0,0x1c
    8000420e:	dc650513          	addi	a0,a0,-570 # 8001ffd0 <ftable>
    80004212:	9f3fc0ef          	jal	ra,80000c04 <release>

  if(ff.type == FD_PIPE){
    80004216:	4785                	li	a5,1
    80004218:	04f90363          	beq	s2,a5,8000425e <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000421c:	3979                	addiw	s2,s2,-2
    8000421e:	4785                	li	a5,1
    80004220:	0327e663          	bltu	a5,s2,8000424c <fileclose+0x8c>
    begin_op();
    80004224:	b8fff0ef          	jal	ra,80003db2 <begin_op>
    iput(ff.ip);
    80004228:	854e                	mv	a0,s3
    8000422a:	b28ff0ef          	jal	ra,80003552 <iput>
    end_op();
    8000422e:	bf5ff0ef          	jal	ra,80003e22 <end_op>
    80004232:	a829                	j	8000424c <fileclose+0x8c>
    panic("fileclose");
    80004234:	00003517          	auipc	a0,0x3
    80004238:	5a450513          	addi	a0,a0,1444 # 800077d8 <states.0+0x208>
    8000423c:	d4efc0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    80004240:	0001c517          	auipc	a0,0x1c
    80004244:	d9050513          	addi	a0,a0,-624 # 8001ffd0 <ftable>
    80004248:	9bdfc0ef          	jal	ra,80000c04 <release>
  }
}
    8000424c:	70e2                	ld	ra,56(sp)
    8000424e:	7442                	ld	s0,48(sp)
    80004250:	74a2                	ld	s1,40(sp)
    80004252:	7902                	ld	s2,32(sp)
    80004254:	69e2                	ld	s3,24(sp)
    80004256:	6a42                	ld	s4,16(sp)
    80004258:	6aa2                	ld	s5,8(sp)
    8000425a:	6121                	addi	sp,sp,64
    8000425c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000425e:	85d6                	mv	a1,s5
    80004260:	8552                	mv	a0,s4
    80004262:	2ec000ef          	jal	ra,8000454e <pipeclose>
    80004266:	b7dd                	j	8000424c <fileclose+0x8c>

0000000080004268 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004268:	715d                	addi	sp,sp,-80
    8000426a:	e486                	sd	ra,72(sp)
    8000426c:	e0a2                	sd	s0,64(sp)
    8000426e:	fc26                	sd	s1,56(sp)
    80004270:	f84a                	sd	s2,48(sp)
    80004272:	f44e                	sd	s3,40(sp)
    80004274:	0880                	addi	s0,sp,80
    80004276:	84aa                	mv	s1,a0
    80004278:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000427a:	d92fd0ef          	jal	ra,8000180c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000427e:	409c                	lw	a5,0(s1)
    80004280:	37f9                	addiw	a5,a5,-2
    80004282:	4705                	li	a4,1
    80004284:	02f76f63          	bltu	a4,a5,800042c2 <filestat+0x5a>
    80004288:	892a                	mv	s2,a0
    ilock(f->ip);
    8000428a:	6c88                	ld	a0,24(s1)
    8000428c:	948ff0ef          	jal	ra,800033d4 <ilock>
    stati(f->ip, &st);
    80004290:	fb840593          	addi	a1,s0,-72
    80004294:	6c88                	ld	a0,24(s1)
    80004296:	ca0ff0ef          	jal	ra,80003736 <stati>
    iunlock(f->ip);
    8000429a:	6c88                	ld	a0,24(s1)
    8000429c:	9e2ff0ef          	jal	ra,8000347e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800042a0:	46e1                	li	a3,24
    800042a2:	fb840613          	addi	a2,s0,-72
    800042a6:	85ce                	mv	a1,s3
    800042a8:	05093503          	ld	a0,80(s2)
    800042ac:	aa6fd0ef          	jal	ra,80001552 <copyout>
    800042b0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800042b4:	60a6                	ld	ra,72(sp)
    800042b6:	6406                	ld	s0,64(sp)
    800042b8:	74e2                	ld	s1,56(sp)
    800042ba:	7942                	ld	s2,48(sp)
    800042bc:	79a2                	ld	s3,40(sp)
    800042be:	6161                	addi	sp,sp,80
    800042c0:	8082                	ret
  return -1;
    800042c2:	557d                	li	a0,-1
    800042c4:	bfc5                	j	800042b4 <filestat+0x4c>

00000000800042c6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042c6:	7179                	addi	sp,sp,-48
    800042c8:	f406                	sd	ra,40(sp)
    800042ca:	f022                	sd	s0,32(sp)
    800042cc:	ec26                	sd	s1,24(sp)
    800042ce:	e84a                	sd	s2,16(sp)
    800042d0:	e44e                	sd	s3,8(sp)
    800042d2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800042d4:	00854783          	lbu	a5,8(a0)
    800042d8:	cbc1                	beqz	a5,80004368 <fileread+0xa2>
    800042da:	84aa                	mv	s1,a0
    800042dc:	89ae                	mv	s3,a1
    800042de:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800042e0:	411c                	lw	a5,0(a0)
    800042e2:	4705                	li	a4,1
    800042e4:	04e78363          	beq	a5,a4,8000432a <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042e8:	470d                	li	a4,3
    800042ea:	04e78563          	beq	a5,a4,80004334 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800042ee:	4709                	li	a4,2
    800042f0:	06e79663          	bne	a5,a4,8000435c <fileread+0x96>
    ilock(f->ip);
    800042f4:	6d08                	ld	a0,24(a0)
    800042f6:	8deff0ef          	jal	ra,800033d4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800042fa:	874a                	mv	a4,s2
    800042fc:	5094                	lw	a3,32(s1)
    800042fe:	864e                	mv	a2,s3
    80004300:	4585                	li	a1,1
    80004302:	6c88                	ld	a0,24(s1)
    80004304:	c5cff0ef          	jal	ra,80003760 <readi>
    80004308:	892a                	mv	s2,a0
    8000430a:	00a05563          	blez	a0,80004314 <fileread+0x4e>
      f->off += r;
    8000430e:	509c                	lw	a5,32(s1)
    80004310:	9fa9                	addw	a5,a5,a0
    80004312:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004314:	6c88                	ld	a0,24(s1)
    80004316:	968ff0ef          	jal	ra,8000347e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000431a:	854a                	mv	a0,s2
    8000431c:	70a2                	ld	ra,40(sp)
    8000431e:	7402                	ld	s0,32(sp)
    80004320:	64e2                	ld	s1,24(sp)
    80004322:	6942                	ld	s2,16(sp)
    80004324:	69a2                	ld	s3,8(sp)
    80004326:	6145                	addi	sp,sp,48
    80004328:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000432a:	6908                	ld	a0,16(a0)
    8000432c:	34e000ef          	jal	ra,8000467a <piperead>
    80004330:	892a                	mv	s2,a0
    80004332:	b7e5                	j	8000431a <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004334:	02451783          	lh	a5,36(a0)
    80004338:	03079693          	slli	a3,a5,0x30
    8000433c:	92c1                	srli	a3,a3,0x30
    8000433e:	4725                	li	a4,9
    80004340:	02d76663          	bltu	a4,a3,8000436c <fileread+0xa6>
    80004344:	0792                	slli	a5,a5,0x4
    80004346:	0001c717          	auipc	a4,0x1c
    8000434a:	bea70713          	addi	a4,a4,-1046 # 8001ff30 <devsw>
    8000434e:	97ba                	add	a5,a5,a4
    80004350:	639c                	ld	a5,0(a5)
    80004352:	cf99                	beqz	a5,80004370 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004354:	4505                	li	a0,1
    80004356:	9782                	jalr	a5
    80004358:	892a                	mv	s2,a0
    8000435a:	b7c1                	j	8000431a <fileread+0x54>
    panic("fileread");
    8000435c:	00003517          	auipc	a0,0x3
    80004360:	48c50513          	addi	a0,a0,1164 # 800077e8 <states.0+0x218>
    80004364:	c26fc0ef          	jal	ra,8000078a <panic>
    return -1;
    80004368:	597d                	li	s2,-1
    8000436a:	bf45                	j	8000431a <fileread+0x54>
      return -1;
    8000436c:	597d                	li	s2,-1
    8000436e:	b775                	j	8000431a <fileread+0x54>
    80004370:	597d                	li	s2,-1
    80004372:	b765                	j	8000431a <fileread+0x54>

0000000080004374 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004374:	715d                	addi	sp,sp,-80
    80004376:	e486                	sd	ra,72(sp)
    80004378:	e0a2                	sd	s0,64(sp)
    8000437a:	fc26                	sd	s1,56(sp)
    8000437c:	f84a                	sd	s2,48(sp)
    8000437e:	f44e                	sd	s3,40(sp)
    80004380:	f052                	sd	s4,32(sp)
    80004382:	ec56                	sd	s5,24(sp)
    80004384:	e85a                	sd	s6,16(sp)
    80004386:	e45e                	sd	s7,8(sp)
    80004388:	e062                	sd	s8,0(sp)
    8000438a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000438c:	00954783          	lbu	a5,9(a0)
    80004390:	0e078863          	beqz	a5,80004480 <filewrite+0x10c>
    80004394:	892a                	mv	s2,a0
    80004396:	8aae                	mv	s5,a1
    80004398:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000439a:	411c                	lw	a5,0(a0)
    8000439c:	4705                	li	a4,1
    8000439e:	02e78263          	beq	a5,a4,800043c2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043a2:	470d                	li	a4,3
    800043a4:	02e78463          	beq	a5,a4,800043cc <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800043a8:	4709                	li	a4,2
    800043aa:	0ce79563          	bne	a5,a4,80004474 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800043ae:	0ac05163          	blez	a2,80004450 <filewrite+0xdc>
    int i = 0;
    800043b2:	4981                	li	s3,0
    800043b4:	6b05                	lui	s6,0x1
    800043b6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800043ba:	6b85                	lui	s7,0x1
    800043bc:	c00b8b9b          	addiw	s7,s7,-1024
    800043c0:	a041                	j	80004440 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800043c2:	6908                	ld	a0,16(a0)
    800043c4:	1e2000ef          	jal	ra,800045a6 <pipewrite>
    800043c8:	8a2a                	mv	s4,a0
    800043ca:	a071                	j	80004456 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800043cc:	02451783          	lh	a5,36(a0)
    800043d0:	03079693          	slli	a3,a5,0x30
    800043d4:	92c1                	srli	a3,a3,0x30
    800043d6:	4725                	li	a4,9
    800043d8:	0ad76663          	bltu	a4,a3,80004484 <filewrite+0x110>
    800043dc:	0792                	slli	a5,a5,0x4
    800043de:	0001c717          	auipc	a4,0x1c
    800043e2:	b5270713          	addi	a4,a4,-1198 # 8001ff30 <devsw>
    800043e6:	97ba                	add	a5,a5,a4
    800043e8:	679c                	ld	a5,8(a5)
    800043ea:	cfd9                	beqz	a5,80004488 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    800043ec:	4505                	li	a0,1
    800043ee:	9782                	jalr	a5
    800043f0:	8a2a                	mv	s4,a0
    800043f2:	a095                	j	80004456 <filewrite+0xe2>
    800043f4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800043f8:	9bbff0ef          	jal	ra,80003db2 <begin_op>
      ilock(f->ip);
    800043fc:	01893503          	ld	a0,24(s2)
    80004400:	fd5fe0ef          	jal	ra,800033d4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004404:	8762                	mv	a4,s8
    80004406:	02092683          	lw	a3,32(s2)
    8000440a:	01598633          	add	a2,s3,s5
    8000440e:	4585                	li	a1,1
    80004410:	01893503          	ld	a0,24(s2)
    80004414:	c30ff0ef          	jal	ra,80003844 <writei>
    80004418:	84aa                	mv	s1,a0
    8000441a:	00a05763          	blez	a0,80004428 <filewrite+0xb4>
        f->off += r;
    8000441e:	02092783          	lw	a5,32(s2)
    80004422:	9fa9                	addw	a5,a5,a0
    80004424:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004428:	01893503          	ld	a0,24(s2)
    8000442c:	852ff0ef          	jal	ra,8000347e <iunlock>
      end_op();
    80004430:	9f3ff0ef          	jal	ra,80003e22 <end_op>

      if(r != n1){
    80004434:	009c1f63          	bne	s8,s1,80004452 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004438:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000443c:	0149db63          	bge	s3,s4,80004452 <filewrite+0xde>
      int n1 = n - i;
    80004440:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004444:	84be                	mv	s1,a5
    80004446:	2781                	sext.w	a5,a5
    80004448:	fafb56e3          	bge	s6,a5,800043f4 <filewrite+0x80>
    8000444c:	84de                	mv	s1,s7
    8000444e:	b75d                	j	800043f4 <filewrite+0x80>
    int i = 0;
    80004450:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004452:	013a1f63          	bne	s4,s3,80004470 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004456:	8552                	mv	a0,s4
    80004458:	60a6                	ld	ra,72(sp)
    8000445a:	6406                	ld	s0,64(sp)
    8000445c:	74e2                	ld	s1,56(sp)
    8000445e:	7942                	ld	s2,48(sp)
    80004460:	79a2                	ld	s3,40(sp)
    80004462:	7a02                	ld	s4,32(sp)
    80004464:	6ae2                	ld	s5,24(sp)
    80004466:	6b42                	ld	s6,16(sp)
    80004468:	6ba2                	ld	s7,8(sp)
    8000446a:	6c02                	ld	s8,0(sp)
    8000446c:	6161                	addi	sp,sp,80
    8000446e:	8082                	ret
    ret = (i == n ? n : -1);
    80004470:	5a7d                	li	s4,-1
    80004472:	b7d5                	j	80004456 <filewrite+0xe2>
    panic("filewrite");
    80004474:	00003517          	auipc	a0,0x3
    80004478:	38450513          	addi	a0,a0,900 # 800077f8 <states.0+0x228>
    8000447c:	b0efc0ef          	jal	ra,8000078a <panic>
    return -1;
    80004480:	5a7d                	li	s4,-1
    80004482:	bfd1                	j	80004456 <filewrite+0xe2>
      return -1;
    80004484:	5a7d                	li	s4,-1
    80004486:	bfc1                	j	80004456 <filewrite+0xe2>
    80004488:	5a7d                	li	s4,-1
    8000448a:	b7f1                	j	80004456 <filewrite+0xe2>

000000008000448c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000448c:	7179                	addi	sp,sp,-48
    8000448e:	f406                	sd	ra,40(sp)
    80004490:	f022                	sd	s0,32(sp)
    80004492:	ec26                	sd	s1,24(sp)
    80004494:	e84a                	sd	s2,16(sp)
    80004496:	e44e                	sd	s3,8(sp)
    80004498:	e052                	sd	s4,0(sp)
    8000449a:	1800                	addi	s0,sp,48
    8000449c:	84aa                	mv	s1,a0
    8000449e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800044a0:	0005b023          	sd	zero,0(a1)
    800044a4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044a8:	c75ff0ef          	jal	ra,8000411c <filealloc>
    800044ac:	e088                	sd	a0,0(s1)
    800044ae:	cd35                	beqz	a0,8000452a <pipealloc+0x9e>
    800044b0:	c6dff0ef          	jal	ra,8000411c <filealloc>
    800044b4:	00aa3023          	sd	a0,0(s4)
    800044b8:	c52d                	beqz	a0,80004522 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800044ba:	de2fc0ef          	jal	ra,80000a9c <kalloc>
    800044be:	892a                	mv	s2,a0
    800044c0:	cd31                	beqz	a0,8000451c <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800044c2:	4985                	li	s3,1
    800044c4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800044c8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800044cc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800044d0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800044d4:	00003597          	auipc	a1,0x3
    800044d8:	33458593          	addi	a1,a1,820 # 80007808 <states.0+0x238>
    800044dc:	e10fc0ef          	jal	ra,80000aec <initlock>
  (*f0)->type = FD_PIPE;
    800044e0:	609c                	ld	a5,0(s1)
    800044e2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800044e6:	609c                	ld	a5,0(s1)
    800044e8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800044ec:	609c                	ld	a5,0(s1)
    800044ee:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800044f2:	609c                	ld	a5,0(s1)
    800044f4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800044f8:	000a3783          	ld	a5,0(s4)
    800044fc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004500:	000a3783          	ld	a5,0(s4)
    80004504:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004508:	000a3783          	ld	a5,0(s4)
    8000450c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004510:	000a3783          	ld	a5,0(s4)
    80004514:	0127b823          	sd	s2,16(a5)
  return 0;
    80004518:	4501                	li	a0,0
    8000451a:	a005                	j	8000453a <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000451c:	6088                	ld	a0,0(s1)
    8000451e:	e501                	bnez	a0,80004526 <pipealloc+0x9a>
    80004520:	a029                	j	8000452a <pipealloc+0x9e>
    80004522:	6088                	ld	a0,0(s1)
    80004524:	c11d                	beqz	a0,8000454a <pipealloc+0xbe>
    fileclose(*f0);
    80004526:	c9bff0ef          	jal	ra,800041c0 <fileclose>
  if(*f1)
    8000452a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000452e:	557d                	li	a0,-1
  if(*f1)
    80004530:	c789                	beqz	a5,8000453a <pipealloc+0xae>
    fileclose(*f1);
    80004532:	853e                	mv	a0,a5
    80004534:	c8dff0ef          	jal	ra,800041c0 <fileclose>
  return -1;
    80004538:	557d                	li	a0,-1
}
    8000453a:	70a2                	ld	ra,40(sp)
    8000453c:	7402                	ld	s0,32(sp)
    8000453e:	64e2                	ld	s1,24(sp)
    80004540:	6942                	ld	s2,16(sp)
    80004542:	69a2                	ld	s3,8(sp)
    80004544:	6a02                	ld	s4,0(sp)
    80004546:	6145                	addi	sp,sp,48
    80004548:	8082                	ret
  return -1;
    8000454a:	557d                	li	a0,-1
    8000454c:	b7fd                	j	8000453a <pipealloc+0xae>

000000008000454e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000454e:	1101                	addi	sp,sp,-32
    80004550:	ec06                	sd	ra,24(sp)
    80004552:	e822                	sd	s0,16(sp)
    80004554:	e426                	sd	s1,8(sp)
    80004556:	e04a                	sd	s2,0(sp)
    80004558:	1000                	addi	s0,sp,32
    8000455a:	84aa                	mv	s1,a0
    8000455c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000455e:	e0efc0ef          	jal	ra,80000b6c <acquire>
  if(writable){
    80004562:	02090763          	beqz	s2,80004590 <pipeclose+0x42>
    pi->writeopen = 0;
    80004566:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000456a:	21848513          	addi	a0,s1,536
    8000456e:	909fd0ef          	jal	ra,80001e76 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004572:	2204b783          	ld	a5,544(s1)
    80004576:	e785                	bnez	a5,8000459e <pipeclose+0x50>
    release(&pi->lock);
    80004578:	8526                	mv	a0,s1
    8000457a:	e8afc0ef          	jal	ra,80000c04 <release>
    kfree((char*)pi);
    8000457e:	8526                	mv	a0,s1
    80004580:	c3cfc0ef          	jal	ra,800009bc <kfree>
  } else
    release(&pi->lock);
}
    80004584:	60e2                	ld	ra,24(sp)
    80004586:	6442                	ld	s0,16(sp)
    80004588:	64a2                	ld	s1,8(sp)
    8000458a:	6902                	ld	s2,0(sp)
    8000458c:	6105                	addi	sp,sp,32
    8000458e:	8082                	ret
    pi->readopen = 0;
    80004590:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004594:	21c48513          	addi	a0,s1,540
    80004598:	8dffd0ef          	jal	ra,80001e76 <wakeup>
    8000459c:	bfd9                	j	80004572 <pipeclose+0x24>
    release(&pi->lock);
    8000459e:	8526                	mv	a0,s1
    800045a0:	e64fc0ef          	jal	ra,80000c04 <release>
}
    800045a4:	b7c5                	j	80004584 <pipeclose+0x36>

00000000800045a6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045a6:	711d                	addi	sp,sp,-96
    800045a8:	ec86                	sd	ra,88(sp)
    800045aa:	e8a2                	sd	s0,80(sp)
    800045ac:	e4a6                	sd	s1,72(sp)
    800045ae:	e0ca                	sd	s2,64(sp)
    800045b0:	fc4e                	sd	s3,56(sp)
    800045b2:	f852                	sd	s4,48(sp)
    800045b4:	f456                	sd	s5,40(sp)
    800045b6:	f05a                	sd	s6,32(sp)
    800045b8:	ec5e                	sd	s7,24(sp)
    800045ba:	e862                	sd	s8,16(sp)
    800045bc:	1080                	addi	s0,sp,96
    800045be:	84aa                	mv	s1,a0
    800045c0:	8aae                	mv	s5,a1
    800045c2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800045c4:	a48fd0ef          	jal	ra,8000180c <myproc>
    800045c8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800045ca:	8526                	mv	a0,s1
    800045cc:	da0fc0ef          	jal	ra,80000b6c <acquire>
  while(i < n){
    800045d0:	09405c63          	blez	s4,80004668 <pipewrite+0xc2>
  int i = 0;
    800045d4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045d6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800045d8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800045dc:	21c48b93          	addi	s7,s1,540
    800045e0:	a81d                	j	80004616 <pipewrite+0x70>
      release(&pi->lock);
    800045e2:	8526                	mv	a0,s1
    800045e4:	e20fc0ef          	jal	ra,80000c04 <release>
      return -1;
    800045e8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800045ea:	854a                	mv	a0,s2
    800045ec:	60e6                	ld	ra,88(sp)
    800045ee:	6446                	ld	s0,80(sp)
    800045f0:	64a6                	ld	s1,72(sp)
    800045f2:	6906                	ld	s2,64(sp)
    800045f4:	79e2                	ld	s3,56(sp)
    800045f6:	7a42                	ld	s4,48(sp)
    800045f8:	7aa2                	ld	s5,40(sp)
    800045fa:	7b02                	ld	s6,32(sp)
    800045fc:	6be2                	ld	s7,24(sp)
    800045fe:	6c42                	ld	s8,16(sp)
    80004600:	6125                	addi	sp,sp,96
    80004602:	8082                	ret
      wakeup(&pi->nread);
    80004604:	8562                	mv	a0,s8
    80004606:	871fd0ef          	jal	ra,80001e76 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000460a:	85a6                	mv	a1,s1
    8000460c:	855e                	mv	a0,s7
    8000460e:	81dfd0ef          	jal	ra,80001e2a <sleep>
  while(i < n){
    80004612:	05495c63          	bge	s2,s4,8000466a <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004616:	2204a783          	lw	a5,544(s1)
    8000461a:	d7e1                	beqz	a5,800045e2 <pipewrite+0x3c>
    8000461c:	854e                	mv	a0,s3
    8000461e:	a8ffd0ef          	jal	ra,800020ac <killed>
    80004622:	f161                	bnez	a0,800045e2 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004624:	2184a783          	lw	a5,536(s1)
    80004628:	21c4a703          	lw	a4,540(s1)
    8000462c:	2007879b          	addiw	a5,a5,512
    80004630:	fcf70ae3          	beq	a4,a5,80004604 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004634:	4685                	li	a3,1
    80004636:	01590633          	add	a2,s2,s5
    8000463a:	faf40593          	addi	a1,s0,-81
    8000463e:	0509b503          	ld	a0,80(s3)
    80004642:	fd7fc0ef          	jal	ra,80001618 <copyin>
    80004646:	03650263          	beq	a0,s6,8000466a <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000464a:	21c4a783          	lw	a5,540(s1)
    8000464e:	0017871b          	addiw	a4,a5,1
    80004652:	20e4ae23          	sw	a4,540(s1)
    80004656:	1ff7f793          	andi	a5,a5,511
    8000465a:	97a6                	add	a5,a5,s1
    8000465c:	faf44703          	lbu	a4,-81(s0)
    80004660:	00e78c23          	sb	a4,24(a5)
      i++;
    80004664:	2905                	addiw	s2,s2,1
    80004666:	b775                	j	80004612 <pipewrite+0x6c>
  int i = 0;
    80004668:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000466a:	21848513          	addi	a0,s1,536
    8000466e:	809fd0ef          	jal	ra,80001e76 <wakeup>
  release(&pi->lock);
    80004672:	8526                	mv	a0,s1
    80004674:	d90fc0ef          	jal	ra,80000c04 <release>
  return i;
    80004678:	bf8d                	j	800045ea <pipewrite+0x44>

000000008000467a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000467a:	715d                	addi	sp,sp,-80
    8000467c:	e486                	sd	ra,72(sp)
    8000467e:	e0a2                	sd	s0,64(sp)
    80004680:	fc26                	sd	s1,56(sp)
    80004682:	f84a                	sd	s2,48(sp)
    80004684:	f44e                	sd	s3,40(sp)
    80004686:	f052                	sd	s4,32(sp)
    80004688:	ec56                	sd	s5,24(sp)
    8000468a:	e85a                	sd	s6,16(sp)
    8000468c:	0880                	addi	s0,sp,80
    8000468e:	84aa                	mv	s1,a0
    80004690:	892e                	mv	s2,a1
    80004692:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004694:	978fd0ef          	jal	ra,8000180c <myproc>
    80004698:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000469a:	8526                	mv	a0,s1
    8000469c:	cd0fc0ef          	jal	ra,80000b6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046a0:	2184a703          	lw	a4,536(s1)
    800046a4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046a8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046ac:	02f71363          	bne	a4,a5,800046d2 <piperead+0x58>
    800046b0:	2244a783          	lw	a5,548(s1)
    800046b4:	cf99                	beqz	a5,800046d2 <piperead+0x58>
    if(killed(pr)){
    800046b6:	8552                	mv	a0,s4
    800046b8:	9f5fd0ef          	jal	ra,800020ac <killed>
    800046bc:	e149                	bnez	a0,8000473e <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046be:	85a6                	mv	a1,s1
    800046c0:	854e                	mv	a0,s3
    800046c2:	f68fd0ef          	jal	ra,80001e2a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046c6:	2184a703          	lw	a4,536(s1)
    800046ca:	21c4a783          	lw	a5,540(s1)
    800046ce:	fef701e3          	beq	a4,a5,800046b0 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046d2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800046d4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046d6:	05505263          	blez	s5,8000471a <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    800046da:	2184a783          	lw	a5,536(s1)
    800046de:	21c4a703          	lw	a4,540(s1)
    800046e2:	02f70c63          	beq	a4,a5,8000471a <piperead+0xa0>
    ch = pi->data[pi->nread % PIPESIZE];
    800046e6:	1ff7f793          	andi	a5,a5,511
    800046ea:	97a6                	add	a5,a5,s1
    800046ec:	0187c783          	lbu	a5,24(a5)
    800046f0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800046f4:	4685                	li	a3,1
    800046f6:	fbf40613          	addi	a2,s0,-65
    800046fa:	85ca                	mv	a1,s2
    800046fc:	050a3503          	ld	a0,80(s4)
    80004700:	e53fc0ef          	jal	ra,80001552 <copyout>
    80004704:	05650263          	beq	a0,s6,80004748 <piperead+0xce>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004708:	2184a783          	lw	a5,536(s1)
    8000470c:	2785                	addiw	a5,a5,1
    8000470e:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004712:	2985                	addiw	s3,s3,1
    80004714:	0905                	addi	s2,s2,1
    80004716:	fd3a92e3          	bne	s5,s3,800046da <piperead+0x60>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000471a:	21c48513          	addi	a0,s1,540
    8000471e:	f58fd0ef          	jal	ra,80001e76 <wakeup>
  release(&pi->lock);
    80004722:	8526                	mv	a0,s1
    80004724:	ce0fc0ef          	jal	ra,80000c04 <release>
  return i;
}
    80004728:	854e                	mv	a0,s3
    8000472a:	60a6                	ld	ra,72(sp)
    8000472c:	6406                	ld	s0,64(sp)
    8000472e:	74e2                	ld	s1,56(sp)
    80004730:	7942                	ld	s2,48(sp)
    80004732:	79a2                	ld	s3,40(sp)
    80004734:	7a02                	ld	s4,32(sp)
    80004736:	6ae2                	ld	s5,24(sp)
    80004738:	6b42                	ld	s6,16(sp)
    8000473a:	6161                	addi	sp,sp,80
    8000473c:	8082                	ret
      release(&pi->lock);
    8000473e:	8526                	mv	a0,s1
    80004740:	cc4fc0ef          	jal	ra,80000c04 <release>
      return -1;
    80004744:	59fd                	li	s3,-1
    80004746:	b7cd                	j	80004728 <piperead+0xae>
      if(i == 0)
    80004748:	fc0999e3          	bnez	s3,8000471a <piperead+0xa0>
        i = -1;
    8000474c:	89aa                	mv	s3,a0
    8000474e:	b7f1                	j	8000471a <piperead+0xa0>

0000000080004750 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004750:	1141                	addi	sp,sp,-16
    80004752:	e422                	sd	s0,8(sp)
    80004754:	0800                	addi	s0,sp,16
    80004756:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004758:	8905                	andi	a0,a0,1
    8000475a:	c111                	beqz	a0,8000475e <flags2perm+0xe>
      perm = PTE_X;
    8000475c:	4521                	li	a0,8
    if(flags & 0x2)
    8000475e:	8b89                	andi	a5,a5,2
    80004760:	c399                	beqz	a5,80004766 <flags2perm+0x16>
      perm |= PTE_W;
    80004762:	00456513          	ori	a0,a0,4
    return perm;
}
    80004766:	6422                	ld	s0,8(sp)
    80004768:	0141                	addi	sp,sp,16
    8000476a:	8082                	ret

000000008000476c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000476c:	de010113          	addi	sp,sp,-544
    80004770:	20113c23          	sd	ra,536(sp)
    80004774:	20813823          	sd	s0,528(sp)
    80004778:	20913423          	sd	s1,520(sp)
    8000477c:	21213023          	sd	s2,512(sp)
    80004780:	ffce                	sd	s3,504(sp)
    80004782:	fbd2                	sd	s4,496(sp)
    80004784:	f7d6                	sd	s5,488(sp)
    80004786:	f3da                	sd	s6,480(sp)
    80004788:	efde                	sd	s7,472(sp)
    8000478a:	ebe2                	sd	s8,464(sp)
    8000478c:	e7e6                	sd	s9,456(sp)
    8000478e:	e3ea                	sd	s10,448(sp)
    80004790:	ff6e                	sd	s11,440(sp)
    80004792:	1400                	addi	s0,sp,544
    80004794:	892a                	mv	s2,a0
    80004796:	dea43423          	sd	a0,-536(s0)
    8000479a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000479e:	86efd0ef          	jal	ra,8000180c <myproc>
    800047a2:	84aa                	mv	s1,a0

  begin_op();
    800047a4:	e0eff0ef          	jal	ra,80003db2 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800047a8:	854a                	mv	a0,s2
    800047aa:	c18ff0ef          	jal	ra,80003bc2 <namei>
    800047ae:	c13d                	beqz	a0,80004814 <kexec+0xa8>
    800047b0:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800047b2:	c23fe0ef          	jal	ra,800033d4 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800047b6:	04000713          	li	a4,64
    800047ba:	4681                	li	a3,0
    800047bc:	e5040613          	addi	a2,s0,-432
    800047c0:	4581                	li	a1,0
    800047c2:	8556                	mv	a0,s5
    800047c4:	f9dfe0ef          	jal	ra,80003760 <readi>
    800047c8:	04000793          	li	a5,64
    800047cc:	00f51a63          	bne	a0,a5,800047e0 <kexec+0x74>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800047d0:	e5042703          	lw	a4,-432(s0)
    800047d4:	464c47b7          	lui	a5,0x464c4
    800047d8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800047dc:	04f70063          	beq	a4,a5,8000481c <kexec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800047e0:	8556                	mv	a0,s5
    800047e2:	df9fe0ef          	jal	ra,800035da <iunlockput>
    end_op();
    800047e6:	e3cff0ef          	jal	ra,80003e22 <end_op>
  }
  return -1;
    800047ea:	557d                	li	a0,-1
}
    800047ec:	21813083          	ld	ra,536(sp)
    800047f0:	21013403          	ld	s0,528(sp)
    800047f4:	20813483          	ld	s1,520(sp)
    800047f8:	20013903          	ld	s2,512(sp)
    800047fc:	79fe                	ld	s3,504(sp)
    800047fe:	7a5e                	ld	s4,496(sp)
    80004800:	7abe                	ld	s5,488(sp)
    80004802:	7b1e                	ld	s6,480(sp)
    80004804:	6bfe                	ld	s7,472(sp)
    80004806:	6c5e                	ld	s8,464(sp)
    80004808:	6cbe                	ld	s9,456(sp)
    8000480a:	6d1e                	ld	s10,448(sp)
    8000480c:	7dfa                	ld	s11,440(sp)
    8000480e:	22010113          	addi	sp,sp,544
    80004812:	8082                	ret
    end_op();
    80004814:	e0eff0ef          	jal	ra,80003e22 <end_op>
    return -1;
    80004818:	557d                	li	a0,-1
    8000481a:	bfc9                	j	800047ec <kexec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    8000481c:	8526                	mv	a0,s1
    8000481e:	8f4fd0ef          	jal	ra,80001912 <proc_pagetable>
    80004822:	8b2a                	mv	s6,a0
    80004824:	dd55                	beqz	a0,800047e0 <kexec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004826:	e7042783          	lw	a5,-400(s0)
    8000482a:	e8845703          	lhu	a4,-376(s0)
    8000482e:	c325                	beqz	a4,8000488e <kexec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004830:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004832:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004836:	6a05                	lui	s4,0x1
    80004838:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000483c:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004840:	6d85                	lui	s11,0x1
    80004842:	7d7d                	lui	s10,0xfffff
    80004844:	a411                	j	80004a48 <kexec+0x2dc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004846:	00003517          	auipc	a0,0x3
    8000484a:	fca50513          	addi	a0,a0,-54 # 80007810 <states.0+0x240>
    8000484e:	f3dfb0ef          	jal	ra,8000078a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004852:	874a                	mv	a4,s2
    80004854:	009c86bb          	addw	a3,s9,s1
    80004858:	4581                	li	a1,0
    8000485a:	8556                	mv	a0,s5
    8000485c:	f05fe0ef          	jal	ra,80003760 <readi>
    80004860:	2501                	sext.w	a0,a0
    80004862:	18a91263          	bne	s2,a0,800049e6 <kexec+0x27a>
  for(i = 0; i < sz; i += PGSIZE){
    80004866:	009d84bb          	addw	s1,s11,s1
    8000486a:	013d09bb          	addw	s3,s10,s3
    8000486e:	1b74fd63          	bgeu	s1,s7,80004a28 <kexec+0x2bc>
    pa = walkaddr(pagetable, va + i);
    80004872:	02049593          	slli	a1,s1,0x20
    80004876:	9181                	srli	a1,a1,0x20
    80004878:	95e2                	add	a1,a1,s8
    8000487a:	855a                	mv	a0,s6
    8000487c:	edafc0ef          	jal	ra,80000f56 <walkaddr>
    80004880:	862a                	mv	a2,a0
    if(pa == 0)
    80004882:	d171                	beqz	a0,80004846 <kexec+0xda>
      n = PGSIZE;
    80004884:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004886:	fd49f6e3          	bgeu	s3,s4,80004852 <kexec+0xe6>
      n = sz - i;
    8000488a:	894e                	mv	s2,s3
    8000488c:	b7d9                	j	80004852 <kexec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000488e:	4901                	li	s2,0
  iunlockput(ip);
    80004890:	8556                	mv	a0,s5
    80004892:	d49fe0ef          	jal	ra,800035da <iunlockput>
  end_op();
    80004896:	d8cff0ef          	jal	ra,80003e22 <end_op>
  p = myproc();
    8000489a:	f73fc0ef          	jal	ra,8000180c <myproc>
    8000489e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800048a0:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800048a4:	6785                	lui	a5,0x1
    800048a6:	17fd                	addi	a5,a5,-1
    800048a8:	993e                	add	s2,s2,a5
    800048aa:	77fd                	lui	a5,0xfffff
    800048ac:	00f977b3          	and	a5,s2,a5
    800048b0:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048b4:	4691                	li	a3,4
    800048b6:	6609                	lui	a2,0x2
    800048b8:	963e                	add	a2,a2,a5
    800048ba:	85be                	mv	a1,a5
    800048bc:	855a                	mv	a0,s6
    800048be:	963fc0ef          	jal	ra,80001220 <uvmalloc>
    800048c2:	8c2a                	mv	s8,a0
  ip = 0;
    800048c4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048c6:	12050063          	beqz	a0,800049e6 <kexec+0x27a>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800048ca:	75f9                	lui	a1,0xffffe
    800048cc:	95aa                	add	a1,a1,a0
    800048ce:	855a                	mv	a0,s6
    800048d0:	b17fc0ef          	jal	ra,800013e6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800048d4:	7afd                	lui	s5,0xfffff
    800048d6:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800048d8:	df043783          	ld	a5,-528(s0)
    800048dc:	6388                	ld	a0,0(a5)
    800048de:	c135                	beqz	a0,80004942 <kexec+0x1d6>
    800048e0:	e9040993          	addi	s3,s0,-368
    800048e4:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800048e8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800048ea:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800048ec:	cccfc0ef          	jal	ra,80000db8 <strlen>
    800048f0:	0015079b          	addiw	a5,a0,1
    800048f4:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800048f8:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800048fc:	11596a63          	bltu	s2,s5,80004a10 <kexec+0x2a4>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004900:	df043d83          	ld	s11,-528(s0)
    80004904:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004908:	8552                	mv	a0,s4
    8000490a:	caefc0ef          	jal	ra,80000db8 <strlen>
    8000490e:	0015069b          	addiw	a3,a0,1
    80004912:	8652                	mv	a2,s4
    80004914:	85ca                	mv	a1,s2
    80004916:	855a                	mv	a0,s6
    80004918:	c3bfc0ef          	jal	ra,80001552 <copyout>
    8000491c:	0e054e63          	bltz	a0,80004a18 <kexec+0x2ac>
    ustack[argc] = sp;
    80004920:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004924:	0485                	addi	s1,s1,1
    80004926:	008d8793          	addi	a5,s11,8
    8000492a:	def43823          	sd	a5,-528(s0)
    8000492e:	008db503          	ld	a0,8(s11)
    80004932:	c911                	beqz	a0,80004946 <kexec+0x1da>
    if(argc >= MAXARG)
    80004934:	09a1                	addi	s3,s3,8
    80004936:	fb3c9be3          	bne	s9,s3,800048ec <kexec+0x180>
  sz = sz1;
    8000493a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000493e:	4a81                	li	s5,0
    80004940:	a05d                	j	800049e6 <kexec+0x27a>
  sp = sz;
    80004942:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004944:	4481                	li	s1,0
  ustack[argc] = 0;
    80004946:	00349793          	slli	a5,s1,0x3
    8000494a:	f9040713          	addi	a4,s0,-112
    8000494e:	97ba                	add	a5,a5,a4
    80004950:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdde38>
  sp -= (argc+1) * sizeof(uint64);
    80004954:	00148693          	addi	a3,s1,1
    80004958:	068e                	slli	a3,a3,0x3
    8000495a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000495e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004962:	01597663          	bgeu	s2,s5,8000496e <kexec+0x202>
  sz = sz1;
    80004966:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000496a:	4a81                	li	s5,0
    8000496c:	a8ad                	j	800049e6 <kexec+0x27a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000496e:	e9040613          	addi	a2,s0,-368
    80004972:	85ca                	mv	a1,s2
    80004974:	855a                	mv	a0,s6
    80004976:	bddfc0ef          	jal	ra,80001552 <copyout>
    8000497a:	0a054363          	bltz	a0,80004a20 <kexec+0x2b4>
  p->trapframe->a1 = sp;
    8000497e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004982:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004986:	de843783          	ld	a5,-536(s0)
    8000498a:	0007c703          	lbu	a4,0(a5)
    8000498e:	cf11                	beqz	a4,800049aa <kexec+0x23e>
    80004990:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004992:	02f00693          	li	a3,47
    80004996:	a039                	j	800049a4 <kexec+0x238>
      last = s+1;
    80004998:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000499c:	0785                	addi	a5,a5,1
    8000499e:	fff7c703          	lbu	a4,-1(a5)
    800049a2:	c701                	beqz	a4,800049aa <kexec+0x23e>
    if(*s == '/')
    800049a4:	fed71ce3          	bne	a4,a3,8000499c <kexec+0x230>
    800049a8:	bfc5                	j	80004998 <kexec+0x22c>
  safestrcpy(p->name, last, sizeof(p->name));
    800049aa:	4641                	li	a2,16
    800049ac:	de843583          	ld	a1,-536(s0)
    800049b0:	158b8513          	addi	a0,s7,344
    800049b4:	bd2fc0ef          	jal	ra,80000d86 <safestrcpy>
  oldpagetable = p->pagetable;
    800049b8:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800049bc:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800049c0:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800049c4:	058bb783          	ld	a5,88(s7)
    800049c8:	e6843703          	ld	a4,-408(s0)
    800049cc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800049ce:	058bb783          	ld	a5,88(s7)
    800049d2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800049d6:	85ea                	mv	a1,s10
    800049d8:	fbffc0ef          	jal	ra,80001996 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800049dc:	0004851b          	sext.w	a0,s1
    800049e0:	b531                	j	800047ec <kexec+0x80>
    800049e2:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800049e6:	df843583          	ld	a1,-520(s0)
    800049ea:	855a                	mv	a0,s6
    800049ec:	fabfc0ef          	jal	ra,80001996 <proc_freepagetable>
  if(ip){
    800049f0:	de0a98e3          	bnez	s5,800047e0 <kexec+0x74>
  return -1;
    800049f4:	557d                	li	a0,-1
    800049f6:	bbdd                	j	800047ec <kexec+0x80>
    800049f8:	df243c23          	sd	s2,-520(s0)
    800049fc:	b7ed                	j	800049e6 <kexec+0x27a>
    800049fe:	df243c23          	sd	s2,-520(s0)
    80004a02:	b7d5                	j	800049e6 <kexec+0x27a>
    80004a04:	df243c23          	sd	s2,-520(s0)
    80004a08:	bff9                	j	800049e6 <kexec+0x27a>
    80004a0a:	df243c23          	sd	s2,-520(s0)
    80004a0e:	bfe1                	j	800049e6 <kexec+0x27a>
  sz = sz1;
    80004a10:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004a14:	4a81                	li	s5,0
    80004a16:	bfc1                	j	800049e6 <kexec+0x27a>
  sz = sz1;
    80004a18:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004a1c:	4a81                	li	s5,0
    80004a1e:	b7e1                	j	800049e6 <kexec+0x27a>
  sz = sz1;
    80004a20:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004a24:	4a81                	li	s5,0
    80004a26:	b7c1                	j	800049e6 <kexec+0x27a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a28:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a2c:	e0843783          	ld	a5,-504(s0)
    80004a30:	0017869b          	addiw	a3,a5,1
    80004a34:	e0d43423          	sd	a3,-504(s0)
    80004a38:	e0043783          	ld	a5,-512(s0)
    80004a3c:	0387879b          	addiw	a5,a5,56
    80004a40:	e8845703          	lhu	a4,-376(s0)
    80004a44:	e4e6d6e3          	bge	a3,a4,80004890 <kexec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a48:	2781                	sext.w	a5,a5
    80004a4a:	e0f43023          	sd	a5,-512(s0)
    80004a4e:	03800713          	li	a4,56
    80004a52:	86be                	mv	a3,a5
    80004a54:	e1840613          	addi	a2,s0,-488
    80004a58:	4581                	li	a1,0
    80004a5a:	8556                	mv	a0,s5
    80004a5c:	d05fe0ef          	jal	ra,80003760 <readi>
    80004a60:	03800793          	li	a5,56
    80004a64:	f6f51fe3          	bne	a0,a5,800049e2 <kexec+0x276>
    if(ph.type != ELF_PROG_LOAD)
    80004a68:	e1842783          	lw	a5,-488(s0)
    80004a6c:	4705                	li	a4,1
    80004a6e:	fae79fe3          	bne	a5,a4,80004a2c <kexec+0x2c0>
    if(ph.memsz < ph.filesz)
    80004a72:	e4043483          	ld	s1,-448(s0)
    80004a76:	e3843783          	ld	a5,-456(s0)
    80004a7a:	f6f4efe3          	bltu	s1,a5,800049f8 <kexec+0x28c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a7e:	e2843783          	ld	a5,-472(s0)
    80004a82:	94be                	add	s1,s1,a5
    80004a84:	f6f4ede3          	bltu	s1,a5,800049fe <kexec+0x292>
    if(ph.vaddr % PGSIZE != 0)
    80004a88:	de043703          	ld	a4,-544(s0)
    80004a8c:	8ff9                	and	a5,a5,a4
    80004a8e:	fbbd                	bnez	a5,80004a04 <kexec+0x298>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a90:	e1c42503          	lw	a0,-484(s0)
    80004a94:	cbdff0ef          	jal	ra,80004750 <flags2perm>
    80004a98:	86aa                	mv	a3,a0
    80004a9a:	8626                	mv	a2,s1
    80004a9c:	85ca                	mv	a1,s2
    80004a9e:	855a                	mv	a0,s6
    80004aa0:	f80fc0ef          	jal	ra,80001220 <uvmalloc>
    80004aa4:	dea43c23          	sd	a0,-520(s0)
    80004aa8:	d12d                	beqz	a0,80004a0a <kexec+0x29e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004aaa:	e2843c03          	ld	s8,-472(s0)
    80004aae:	e2042c83          	lw	s9,-480(s0)
    80004ab2:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ab6:	f60b89e3          	beqz	s7,80004a28 <kexec+0x2bc>
    80004aba:	89de                	mv	s3,s7
    80004abc:	4481                	li	s1,0
    80004abe:	bb55                	j	80004872 <kexec+0x106>

0000000080004ac0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ac0:	7179                	addi	sp,sp,-48
    80004ac2:	f406                	sd	ra,40(sp)
    80004ac4:	f022                	sd	s0,32(sp)
    80004ac6:	ec26                	sd	s1,24(sp)
    80004ac8:	e84a                	sd	s2,16(sp)
    80004aca:	1800                	addi	s0,sp,48
    80004acc:	892e                	mv	s2,a1
    80004ace:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ad0:	fdc40593          	addi	a1,s0,-36
    80004ad4:	c9ffd0ef          	jal	ra,80002772 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ad8:	fdc42703          	lw	a4,-36(s0)
    80004adc:	47bd                	li	a5,15
    80004ade:	02e7e963          	bltu	a5,a4,80004b10 <argfd+0x50>
    80004ae2:	d2bfc0ef          	jal	ra,8000180c <myproc>
    80004ae6:	fdc42703          	lw	a4,-36(s0)
    80004aea:	01a70793          	addi	a5,a4,26
    80004aee:	078e                	slli	a5,a5,0x3
    80004af0:	953e                	add	a0,a0,a5
    80004af2:	611c                	ld	a5,0(a0)
    80004af4:	c385                	beqz	a5,80004b14 <argfd+0x54>
    return -1;
  if(pfd)
    80004af6:	00090463          	beqz	s2,80004afe <argfd+0x3e>
    *pfd = fd;
    80004afa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004afe:	4501                	li	a0,0
  if(pf)
    80004b00:	c091                	beqz	s1,80004b04 <argfd+0x44>
    *pf = f;
    80004b02:	e09c                	sd	a5,0(s1)
}
    80004b04:	70a2                	ld	ra,40(sp)
    80004b06:	7402                	ld	s0,32(sp)
    80004b08:	64e2                	ld	s1,24(sp)
    80004b0a:	6942                	ld	s2,16(sp)
    80004b0c:	6145                	addi	sp,sp,48
    80004b0e:	8082                	ret
    return -1;
    80004b10:	557d                	li	a0,-1
    80004b12:	bfcd                	j	80004b04 <argfd+0x44>
    80004b14:	557d                	li	a0,-1
    80004b16:	b7fd                	j	80004b04 <argfd+0x44>

0000000080004b18 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b18:	1101                	addi	sp,sp,-32
    80004b1a:	ec06                	sd	ra,24(sp)
    80004b1c:	e822                	sd	s0,16(sp)
    80004b1e:	e426                	sd	s1,8(sp)
    80004b20:	1000                	addi	s0,sp,32
    80004b22:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004b24:	ce9fc0ef          	jal	ra,8000180c <myproc>
    80004b28:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004b2a:	0d050793          	addi	a5,a0,208
    80004b2e:	4501                	li	a0,0
    80004b30:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004b32:	6398                	ld	a4,0(a5)
    80004b34:	cb19                	beqz	a4,80004b4a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004b36:	2505                	addiw	a0,a0,1
    80004b38:	07a1                	addi	a5,a5,8
    80004b3a:	fed51ce3          	bne	a0,a3,80004b32 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004b3e:	557d                	li	a0,-1
}
    80004b40:	60e2                	ld	ra,24(sp)
    80004b42:	6442                	ld	s0,16(sp)
    80004b44:	64a2                	ld	s1,8(sp)
    80004b46:	6105                	addi	sp,sp,32
    80004b48:	8082                	ret
      p->ofile[fd] = f;
    80004b4a:	01a50793          	addi	a5,a0,26
    80004b4e:	078e                	slli	a5,a5,0x3
    80004b50:	963e                	add	a2,a2,a5
    80004b52:	e204                	sd	s1,0(a2)
      return fd;
    80004b54:	b7f5                	j	80004b40 <fdalloc+0x28>

0000000080004b56 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004b56:	715d                	addi	sp,sp,-80
    80004b58:	e486                	sd	ra,72(sp)
    80004b5a:	e0a2                	sd	s0,64(sp)
    80004b5c:	fc26                	sd	s1,56(sp)
    80004b5e:	f84a                	sd	s2,48(sp)
    80004b60:	f44e                	sd	s3,40(sp)
    80004b62:	f052                	sd	s4,32(sp)
    80004b64:	ec56                	sd	s5,24(sp)
    80004b66:	e85a                	sd	s6,16(sp)
    80004b68:	0880                	addi	s0,sp,80
    80004b6a:	8b2e                	mv	s6,a1
    80004b6c:	89b2                	mv	s3,a2
    80004b6e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b70:	fb040593          	addi	a1,s0,-80
    80004b74:	868ff0ef          	jal	ra,80003bdc <nameiparent>
    80004b78:	84aa                	mv	s1,a0
    80004b7a:	10050b63          	beqz	a0,80004c90 <create+0x13a>
    return 0;

  ilock(dp);
    80004b7e:	857fe0ef          	jal	ra,800033d4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b82:	4601                	li	a2,0
    80004b84:	fb040593          	addi	a1,s0,-80
    80004b88:	8526                	mv	a0,s1
    80004b8a:	dd3fe0ef          	jal	ra,8000395c <dirlookup>
    80004b8e:	8aaa                	mv	s5,a0
    80004b90:	c521                	beqz	a0,80004bd8 <create+0x82>
    iunlockput(dp);
    80004b92:	8526                	mv	a0,s1
    80004b94:	a47fe0ef          	jal	ra,800035da <iunlockput>
    ilock(ip);
    80004b98:	8556                	mv	a0,s5
    80004b9a:	83bfe0ef          	jal	ra,800033d4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b9e:	000b059b          	sext.w	a1,s6
    80004ba2:	4789                	li	a5,2
    80004ba4:	02f59563          	bne	a1,a5,80004bce <create+0x78>
    80004ba8:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffddf7c>
    80004bac:	37f9                	addiw	a5,a5,-2
    80004bae:	17c2                	slli	a5,a5,0x30
    80004bb0:	93c1                	srli	a5,a5,0x30
    80004bb2:	4705                	li	a4,1
    80004bb4:	00f76d63          	bltu	a4,a5,80004bce <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004bb8:	8556                	mv	a0,s5
    80004bba:	60a6                	ld	ra,72(sp)
    80004bbc:	6406                	ld	s0,64(sp)
    80004bbe:	74e2                	ld	s1,56(sp)
    80004bc0:	7942                	ld	s2,48(sp)
    80004bc2:	79a2                	ld	s3,40(sp)
    80004bc4:	7a02                	ld	s4,32(sp)
    80004bc6:	6ae2                	ld	s5,24(sp)
    80004bc8:	6b42                	ld	s6,16(sp)
    80004bca:	6161                	addi	sp,sp,80
    80004bcc:	8082                	ret
    iunlockput(ip);
    80004bce:	8556                	mv	a0,s5
    80004bd0:	a0bfe0ef          	jal	ra,800035da <iunlockput>
    return 0;
    80004bd4:	4a81                	li	s5,0
    80004bd6:	b7cd                	j	80004bb8 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004bd8:	85da                	mv	a1,s6
    80004bda:	4088                	lw	a0,0(s1)
    80004bdc:	e90fe0ef          	jal	ra,8000326c <ialloc>
    80004be0:	8a2a                	mv	s4,a0
    80004be2:	cd1d                	beqz	a0,80004c20 <create+0xca>
  ilock(ip);
    80004be4:	ff0fe0ef          	jal	ra,800033d4 <ilock>
  ip->major = major;
    80004be8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004bec:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004bf0:	4905                	li	s2,1
    80004bf2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004bf6:	8552                	mv	a0,s4
    80004bf8:	f2afe0ef          	jal	ra,80003322 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004bfc:	000b059b          	sext.w	a1,s6
    80004c00:	03258563          	beq	a1,s2,80004c2a <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c04:	004a2603          	lw	a2,4(s4)
    80004c08:	fb040593          	addi	a1,s0,-80
    80004c0c:	8526                	mv	a0,s1
    80004c0e:	f1bfe0ef          	jal	ra,80003b28 <dirlink>
    80004c12:	06054363          	bltz	a0,80004c78 <create+0x122>
  iunlockput(dp);
    80004c16:	8526                	mv	a0,s1
    80004c18:	9c3fe0ef          	jal	ra,800035da <iunlockput>
  return ip;
    80004c1c:	8ad2                	mv	s5,s4
    80004c1e:	bf69                	j	80004bb8 <create+0x62>
    iunlockput(dp);
    80004c20:	8526                	mv	a0,s1
    80004c22:	9b9fe0ef          	jal	ra,800035da <iunlockput>
    return 0;
    80004c26:	8ad2                	mv	s5,s4
    80004c28:	bf41                	j	80004bb8 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004c2a:	004a2603          	lw	a2,4(s4)
    80004c2e:	00003597          	auipc	a1,0x3
    80004c32:	c0258593          	addi	a1,a1,-1022 # 80007830 <states.0+0x260>
    80004c36:	8552                	mv	a0,s4
    80004c38:	ef1fe0ef          	jal	ra,80003b28 <dirlink>
    80004c3c:	02054e63          	bltz	a0,80004c78 <create+0x122>
    80004c40:	40d0                	lw	a2,4(s1)
    80004c42:	00003597          	auipc	a1,0x3
    80004c46:	bf658593          	addi	a1,a1,-1034 # 80007838 <states.0+0x268>
    80004c4a:	8552                	mv	a0,s4
    80004c4c:	eddfe0ef          	jal	ra,80003b28 <dirlink>
    80004c50:	02054463          	bltz	a0,80004c78 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c54:	004a2603          	lw	a2,4(s4)
    80004c58:	fb040593          	addi	a1,s0,-80
    80004c5c:	8526                	mv	a0,s1
    80004c5e:	ecbfe0ef          	jal	ra,80003b28 <dirlink>
    80004c62:	00054b63          	bltz	a0,80004c78 <create+0x122>
    dp->nlink++;  // for ".."
    80004c66:	04a4d783          	lhu	a5,74(s1)
    80004c6a:	2785                	addiw	a5,a5,1
    80004c6c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c70:	8526                	mv	a0,s1
    80004c72:	eb0fe0ef          	jal	ra,80003322 <iupdate>
    80004c76:	b745                	j	80004c16 <create+0xc0>
  ip->nlink = 0;
    80004c78:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004c7c:	8552                	mv	a0,s4
    80004c7e:	ea4fe0ef          	jal	ra,80003322 <iupdate>
  iunlockput(ip);
    80004c82:	8552                	mv	a0,s4
    80004c84:	957fe0ef          	jal	ra,800035da <iunlockput>
  iunlockput(dp);
    80004c88:	8526                	mv	a0,s1
    80004c8a:	951fe0ef          	jal	ra,800035da <iunlockput>
  return 0;
    80004c8e:	b72d                	j	80004bb8 <create+0x62>
    return 0;
    80004c90:	8aaa                	mv	s5,a0
    80004c92:	b71d                	j	80004bb8 <create+0x62>

0000000080004c94 <sys_dup>:
{
    80004c94:	7179                	addi	sp,sp,-48
    80004c96:	f406                	sd	ra,40(sp)
    80004c98:	f022                	sd	s0,32(sp)
    80004c9a:	ec26                	sd	s1,24(sp)
    80004c9c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c9e:	fd840613          	addi	a2,s0,-40
    80004ca2:	4581                	li	a1,0
    80004ca4:	4501                	li	a0,0
    80004ca6:	e1bff0ef          	jal	ra,80004ac0 <argfd>
    return -1;
    80004caa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004cac:	00054f63          	bltz	a0,80004cca <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004cb0:	fd843503          	ld	a0,-40(s0)
    80004cb4:	e65ff0ef          	jal	ra,80004b18 <fdalloc>
    80004cb8:	84aa                	mv	s1,a0
    return -1;
    80004cba:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004cbc:	00054763          	bltz	a0,80004cca <sys_dup+0x36>
  filedup(f);
    80004cc0:	fd843503          	ld	a0,-40(s0)
    80004cc4:	cb6ff0ef          	jal	ra,8000417a <filedup>
  return fd;
    80004cc8:	87a6                	mv	a5,s1
}
    80004cca:	853e                	mv	a0,a5
    80004ccc:	70a2                	ld	ra,40(sp)
    80004cce:	7402                	ld	s0,32(sp)
    80004cd0:	64e2                	ld	s1,24(sp)
    80004cd2:	6145                	addi	sp,sp,48
    80004cd4:	8082                	ret

0000000080004cd6 <sys_read>:
{
    80004cd6:	7179                	addi	sp,sp,-48
    80004cd8:	f406                	sd	ra,40(sp)
    80004cda:	f022                	sd	s0,32(sp)
    80004cdc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cde:	fd840593          	addi	a1,s0,-40
    80004ce2:	4505                	li	a0,1
    80004ce4:	aabfd0ef          	jal	ra,8000278e <argaddr>
  argint(2, &n);
    80004ce8:	fe440593          	addi	a1,s0,-28
    80004cec:	4509                	li	a0,2
    80004cee:	a85fd0ef          	jal	ra,80002772 <argint>
  if(argfd(0, 0, &f) < 0)
    80004cf2:	fe840613          	addi	a2,s0,-24
    80004cf6:	4581                	li	a1,0
    80004cf8:	4501                	li	a0,0
    80004cfa:	dc7ff0ef          	jal	ra,80004ac0 <argfd>
    80004cfe:	87aa                	mv	a5,a0
    return -1;
    80004d00:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d02:	0007ca63          	bltz	a5,80004d16 <sys_read+0x40>
  return fileread(f, p, n);
    80004d06:	fe442603          	lw	a2,-28(s0)
    80004d0a:	fd843583          	ld	a1,-40(s0)
    80004d0e:	fe843503          	ld	a0,-24(s0)
    80004d12:	db4ff0ef          	jal	ra,800042c6 <fileread>
}
    80004d16:	70a2                	ld	ra,40(sp)
    80004d18:	7402                	ld	s0,32(sp)
    80004d1a:	6145                	addi	sp,sp,48
    80004d1c:	8082                	ret

0000000080004d1e <sys_write>:
{
    80004d1e:	7179                	addi	sp,sp,-48
    80004d20:	f406                	sd	ra,40(sp)
    80004d22:	f022                	sd	s0,32(sp)
    80004d24:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d26:	fd840593          	addi	a1,s0,-40
    80004d2a:	4505                	li	a0,1
    80004d2c:	a63fd0ef          	jal	ra,8000278e <argaddr>
  argint(2, &n);
    80004d30:	fe440593          	addi	a1,s0,-28
    80004d34:	4509                	li	a0,2
    80004d36:	a3dfd0ef          	jal	ra,80002772 <argint>
  if(argfd(0, 0, &f) < 0)
    80004d3a:	fe840613          	addi	a2,s0,-24
    80004d3e:	4581                	li	a1,0
    80004d40:	4501                	li	a0,0
    80004d42:	d7fff0ef          	jal	ra,80004ac0 <argfd>
    80004d46:	87aa                	mv	a5,a0
    return -1;
    80004d48:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d4a:	0007ca63          	bltz	a5,80004d5e <sys_write+0x40>
  return filewrite(f, p, n);
    80004d4e:	fe442603          	lw	a2,-28(s0)
    80004d52:	fd843583          	ld	a1,-40(s0)
    80004d56:	fe843503          	ld	a0,-24(s0)
    80004d5a:	e1aff0ef          	jal	ra,80004374 <filewrite>
}
    80004d5e:	70a2                	ld	ra,40(sp)
    80004d60:	7402                	ld	s0,32(sp)
    80004d62:	6145                	addi	sp,sp,48
    80004d64:	8082                	ret

0000000080004d66 <sys_close>:
{
    80004d66:	1101                	addi	sp,sp,-32
    80004d68:	ec06                	sd	ra,24(sp)
    80004d6a:	e822                	sd	s0,16(sp)
    80004d6c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d6e:	fe040613          	addi	a2,s0,-32
    80004d72:	fec40593          	addi	a1,s0,-20
    80004d76:	4501                	li	a0,0
    80004d78:	d49ff0ef          	jal	ra,80004ac0 <argfd>
    return -1;
    80004d7c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d7e:	02054063          	bltz	a0,80004d9e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004d82:	a8bfc0ef          	jal	ra,8000180c <myproc>
    80004d86:	fec42783          	lw	a5,-20(s0)
    80004d8a:	07e9                	addi	a5,a5,26
    80004d8c:	078e                	slli	a5,a5,0x3
    80004d8e:	97aa                	add	a5,a5,a0
    80004d90:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004d94:	fe043503          	ld	a0,-32(s0)
    80004d98:	c28ff0ef          	jal	ra,800041c0 <fileclose>
  return 0;
    80004d9c:	4781                	li	a5,0
}
    80004d9e:	853e                	mv	a0,a5
    80004da0:	60e2                	ld	ra,24(sp)
    80004da2:	6442                	ld	s0,16(sp)
    80004da4:	6105                	addi	sp,sp,32
    80004da6:	8082                	ret

0000000080004da8 <sys_fstat>:
{
    80004da8:	1101                	addi	sp,sp,-32
    80004daa:	ec06                	sd	ra,24(sp)
    80004dac:	e822                	sd	s0,16(sp)
    80004dae:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004db0:	fe040593          	addi	a1,s0,-32
    80004db4:	4505                	li	a0,1
    80004db6:	9d9fd0ef          	jal	ra,8000278e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004dba:	fe840613          	addi	a2,s0,-24
    80004dbe:	4581                	li	a1,0
    80004dc0:	4501                	li	a0,0
    80004dc2:	cffff0ef          	jal	ra,80004ac0 <argfd>
    80004dc6:	87aa                	mv	a5,a0
    return -1;
    80004dc8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004dca:	0007c863          	bltz	a5,80004dda <sys_fstat+0x32>
  return filestat(f, st);
    80004dce:	fe043583          	ld	a1,-32(s0)
    80004dd2:	fe843503          	ld	a0,-24(s0)
    80004dd6:	c92ff0ef          	jal	ra,80004268 <filestat>
}
    80004dda:	60e2                	ld	ra,24(sp)
    80004ddc:	6442                	ld	s0,16(sp)
    80004dde:	6105                	addi	sp,sp,32
    80004de0:	8082                	ret

0000000080004de2 <sys_link>:
{
    80004de2:	7169                	addi	sp,sp,-304
    80004de4:	f606                	sd	ra,296(sp)
    80004de6:	f222                	sd	s0,288(sp)
    80004de8:	ee26                	sd	s1,280(sp)
    80004dea:	ea4a                	sd	s2,272(sp)
    80004dec:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004dee:	08000613          	li	a2,128
    80004df2:	ed040593          	addi	a1,s0,-304
    80004df6:	4501                	li	a0,0
    80004df8:	9b3fd0ef          	jal	ra,800027aa <argstr>
    return -1;
    80004dfc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004dfe:	0c054663          	bltz	a0,80004eca <sys_link+0xe8>
    80004e02:	08000613          	li	a2,128
    80004e06:	f5040593          	addi	a1,s0,-176
    80004e0a:	4505                	li	a0,1
    80004e0c:	99ffd0ef          	jal	ra,800027aa <argstr>
    return -1;
    80004e10:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e12:	0a054c63          	bltz	a0,80004eca <sys_link+0xe8>
  begin_op();
    80004e16:	f9dfe0ef          	jal	ra,80003db2 <begin_op>
  if((ip = namei(old)) == 0){
    80004e1a:	ed040513          	addi	a0,s0,-304
    80004e1e:	da5fe0ef          	jal	ra,80003bc2 <namei>
    80004e22:	84aa                	mv	s1,a0
    80004e24:	c525                	beqz	a0,80004e8c <sys_link+0xaa>
  ilock(ip);
    80004e26:	daefe0ef          	jal	ra,800033d4 <ilock>
  if(ip->type == T_DIR){
    80004e2a:	04449703          	lh	a4,68(s1)
    80004e2e:	4785                	li	a5,1
    80004e30:	06f70263          	beq	a4,a5,80004e94 <sys_link+0xb2>
  ip->nlink++;
    80004e34:	04a4d783          	lhu	a5,74(s1)
    80004e38:	2785                	addiw	a5,a5,1
    80004e3a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e3e:	8526                	mv	a0,s1
    80004e40:	ce2fe0ef          	jal	ra,80003322 <iupdate>
  iunlock(ip);
    80004e44:	8526                	mv	a0,s1
    80004e46:	e38fe0ef          	jal	ra,8000347e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004e4a:	fd040593          	addi	a1,s0,-48
    80004e4e:	f5040513          	addi	a0,s0,-176
    80004e52:	d8bfe0ef          	jal	ra,80003bdc <nameiparent>
    80004e56:	892a                	mv	s2,a0
    80004e58:	c921                	beqz	a0,80004ea8 <sys_link+0xc6>
  ilock(dp);
    80004e5a:	d7afe0ef          	jal	ra,800033d4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004e5e:	00092703          	lw	a4,0(s2)
    80004e62:	409c                	lw	a5,0(s1)
    80004e64:	02f71f63          	bne	a4,a5,80004ea2 <sys_link+0xc0>
    80004e68:	40d0                	lw	a2,4(s1)
    80004e6a:	fd040593          	addi	a1,s0,-48
    80004e6e:	854a                	mv	a0,s2
    80004e70:	cb9fe0ef          	jal	ra,80003b28 <dirlink>
    80004e74:	02054763          	bltz	a0,80004ea2 <sys_link+0xc0>
  iunlockput(dp);
    80004e78:	854a                	mv	a0,s2
    80004e7a:	f60fe0ef          	jal	ra,800035da <iunlockput>
  iput(ip);
    80004e7e:	8526                	mv	a0,s1
    80004e80:	ed2fe0ef          	jal	ra,80003552 <iput>
  end_op();
    80004e84:	f9ffe0ef          	jal	ra,80003e22 <end_op>
  return 0;
    80004e88:	4781                	li	a5,0
    80004e8a:	a081                	j	80004eca <sys_link+0xe8>
    end_op();
    80004e8c:	f97fe0ef          	jal	ra,80003e22 <end_op>
    return -1;
    80004e90:	57fd                	li	a5,-1
    80004e92:	a825                	j	80004eca <sys_link+0xe8>
    iunlockput(ip);
    80004e94:	8526                	mv	a0,s1
    80004e96:	f44fe0ef          	jal	ra,800035da <iunlockput>
    end_op();
    80004e9a:	f89fe0ef          	jal	ra,80003e22 <end_op>
    return -1;
    80004e9e:	57fd                	li	a5,-1
    80004ea0:	a02d                	j	80004eca <sys_link+0xe8>
    iunlockput(dp);
    80004ea2:	854a                	mv	a0,s2
    80004ea4:	f36fe0ef          	jal	ra,800035da <iunlockput>
  ilock(ip);
    80004ea8:	8526                	mv	a0,s1
    80004eaa:	d2afe0ef          	jal	ra,800033d4 <ilock>
  ip->nlink--;
    80004eae:	04a4d783          	lhu	a5,74(s1)
    80004eb2:	37fd                	addiw	a5,a5,-1
    80004eb4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004eb8:	8526                	mv	a0,s1
    80004eba:	c68fe0ef          	jal	ra,80003322 <iupdate>
  iunlockput(ip);
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	f1afe0ef          	jal	ra,800035da <iunlockput>
  end_op();
    80004ec4:	f5ffe0ef          	jal	ra,80003e22 <end_op>
  return -1;
    80004ec8:	57fd                	li	a5,-1
}
    80004eca:	853e                	mv	a0,a5
    80004ecc:	70b2                	ld	ra,296(sp)
    80004ece:	7412                	ld	s0,288(sp)
    80004ed0:	64f2                	ld	s1,280(sp)
    80004ed2:	6952                	ld	s2,272(sp)
    80004ed4:	6155                	addi	sp,sp,304
    80004ed6:	8082                	ret

0000000080004ed8 <sys_unlink>:
{
    80004ed8:	7151                	addi	sp,sp,-240
    80004eda:	f586                	sd	ra,232(sp)
    80004edc:	f1a2                	sd	s0,224(sp)
    80004ede:	eda6                	sd	s1,216(sp)
    80004ee0:	e9ca                	sd	s2,208(sp)
    80004ee2:	e5ce                	sd	s3,200(sp)
    80004ee4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004ee6:	08000613          	li	a2,128
    80004eea:	f3040593          	addi	a1,s0,-208
    80004eee:	4501                	li	a0,0
    80004ef0:	8bbfd0ef          	jal	ra,800027aa <argstr>
    80004ef4:	12054b63          	bltz	a0,8000502a <sys_unlink+0x152>
  begin_op();
    80004ef8:	ebbfe0ef          	jal	ra,80003db2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004efc:	fb040593          	addi	a1,s0,-80
    80004f00:	f3040513          	addi	a0,s0,-208
    80004f04:	cd9fe0ef          	jal	ra,80003bdc <nameiparent>
    80004f08:	84aa                	mv	s1,a0
    80004f0a:	c54d                	beqz	a0,80004fb4 <sys_unlink+0xdc>
  ilock(dp);
    80004f0c:	cc8fe0ef          	jal	ra,800033d4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f10:	00003597          	auipc	a1,0x3
    80004f14:	92058593          	addi	a1,a1,-1760 # 80007830 <states.0+0x260>
    80004f18:	fb040513          	addi	a0,s0,-80
    80004f1c:	a2bfe0ef          	jal	ra,80003946 <namecmp>
    80004f20:	10050a63          	beqz	a0,80005034 <sys_unlink+0x15c>
    80004f24:	00003597          	auipc	a1,0x3
    80004f28:	91458593          	addi	a1,a1,-1772 # 80007838 <states.0+0x268>
    80004f2c:	fb040513          	addi	a0,s0,-80
    80004f30:	a17fe0ef          	jal	ra,80003946 <namecmp>
    80004f34:	10050063          	beqz	a0,80005034 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004f38:	f2c40613          	addi	a2,s0,-212
    80004f3c:	fb040593          	addi	a1,s0,-80
    80004f40:	8526                	mv	a0,s1
    80004f42:	a1bfe0ef          	jal	ra,8000395c <dirlookup>
    80004f46:	892a                	mv	s2,a0
    80004f48:	0e050663          	beqz	a0,80005034 <sys_unlink+0x15c>
  ilock(ip);
    80004f4c:	c88fe0ef          	jal	ra,800033d4 <ilock>
  if(ip->nlink < 1)
    80004f50:	04a91783          	lh	a5,74(s2)
    80004f54:	06f05463          	blez	a5,80004fbc <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004f58:	04491703          	lh	a4,68(s2)
    80004f5c:	4785                	li	a5,1
    80004f5e:	06f70563          	beq	a4,a5,80004fc8 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004f62:	4641                	li	a2,16
    80004f64:	4581                	li	a1,0
    80004f66:	fc040513          	addi	a0,s0,-64
    80004f6a:	cd7fb0ef          	jal	ra,80000c40 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f6e:	4741                	li	a4,16
    80004f70:	f2c42683          	lw	a3,-212(s0)
    80004f74:	fc040613          	addi	a2,s0,-64
    80004f78:	4581                	li	a1,0
    80004f7a:	8526                	mv	a0,s1
    80004f7c:	8c9fe0ef          	jal	ra,80003844 <writei>
    80004f80:	47c1                	li	a5,16
    80004f82:	08f51563          	bne	a0,a5,8000500c <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004f86:	04491703          	lh	a4,68(s2)
    80004f8a:	4785                	li	a5,1
    80004f8c:	08f70663          	beq	a4,a5,80005018 <sys_unlink+0x140>
  iunlockput(dp);
    80004f90:	8526                	mv	a0,s1
    80004f92:	e48fe0ef          	jal	ra,800035da <iunlockput>
  ip->nlink--;
    80004f96:	04a95783          	lhu	a5,74(s2)
    80004f9a:	37fd                	addiw	a5,a5,-1
    80004f9c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004fa0:	854a                	mv	a0,s2
    80004fa2:	b80fe0ef          	jal	ra,80003322 <iupdate>
  iunlockput(ip);
    80004fa6:	854a                	mv	a0,s2
    80004fa8:	e32fe0ef          	jal	ra,800035da <iunlockput>
  end_op();
    80004fac:	e77fe0ef          	jal	ra,80003e22 <end_op>
  return 0;
    80004fb0:	4501                	li	a0,0
    80004fb2:	a079                	j	80005040 <sys_unlink+0x168>
    end_op();
    80004fb4:	e6ffe0ef          	jal	ra,80003e22 <end_op>
    return -1;
    80004fb8:	557d                	li	a0,-1
    80004fba:	a059                	j	80005040 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004fbc:	00003517          	auipc	a0,0x3
    80004fc0:	88450513          	addi	a0,a0,-1916 # 80007840 <states.0+0x270>
    80004fc4:	fc6fb0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fc8:	04c92703          	lw	a4,76(s2)
    80004fcc:	02000793          	li	a5,32
    80004fd0:	f8e7f9e3          	bgeu	a5,a4,80004f62 <sys_unlink+0x8a>
    80004fd4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fd8:	4741                	li	a4,16
    80004fda:	86ce                	mv	a3,s3
    80004fdc:	f1840613          	addi	a2,s0,-232
    80004fe0:	4581                	li	a1,0
    80004fe2:	854a                	mv	a0,s2
    80004fe4:	f7cfe0ef          	jal	ra,80003760 <readi>
    80004fe8:	47c1                	li	a5,16
    80004fea:	00f51b63          	bne	a0,a5,80005000 <sys_unlink+0x128>
    if(de.inum != 0)
    80004fee:	f1845783          	lhu	a5,-232(s0)
    80004ff2:	ef95                	bnez	a5,8000502e <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ff4:	29c1                	addiw	s3,s3,16
    80004ff6:	04c92783          	lw	a5,76(s2)
    80004ffa:	fcf9efe3          	bltu	s3,a5,80004fd8 <sys_unlink+0x100>
    80004ffe:	b795                	j	80004f62 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005000:	00003517          	auipc	a0,0x3
    80005004:	85850513          	addi	a0,a0,-1960 # 80007858 <states.0+0x288>
    80005008:	f82fb0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    8000500c:	00003517          	auipc	a0,0x3
    80005010:	86450513          	addi	a0,a0,-1948 # 80007870 <states.0+0x2a0>
    80005014:	f76fb0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    80005018:	04a4d783          	lhu	a5,74(s1)
    8000501c:	37fd                	addiw	a5,a5,-1
    8000501e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005022:	8526                	mv	a0,s1
    80005024:	afefe0ef          	jal	ra,80003322 <iupdate>
    80005028:	b7a5                	j	80004f90 <sys_unlink+0xb8>
    return -1;
    8000502a:	557d                	li	a0,-1
    8000502c:	a811                	j	80005040 <sys_unlink+0x168>
    iunlockput(ip);
    8000502e:	854a                	mv	a0,s2
    80005030:	daafe0ef          	jal	ra,800035da <iunlockput>
  iunlockput(dp);
    80005034:	8526                	mv	a0,s1
    80005036:	da4fe0ef          	jal	ra,800035da <iunlockput>
  end_op();
    8000503a:	de9fe0ef          	jal	ra,80003e22 <end_op>
  return -1;
    8000503e:	557d                	li	a0,-1
}
    80005040:	70ae                	ld	ra,232(sp)
    80005042:	740e                	ld	s0,224(sp)
    80005044:	64ee                	ld	s1,216(sp)
    80005046:	694e                	ld	s2,208(sp)
    80005048:	69ae                	ld	s3,200(sp)
    8000504a:	616d                	addi	sp,sp,240
    8000504c:	8082                	ret

000000008000504e <sys_open>:

uint64
sys_open(void)
{
    8000504e:	7131                	addi	sp,sp,-192
    80005050:	fd06                	sd	ra,184(sp)
    80005052:	f922                	sd	s0,176(sp)
    80005054:	f526                	sd	s1,168(sp)
    80005056:	f14a                	sd	s2,160(sp)
    80005058:	ed4e                	sd	s3,152(sp)
    8000505a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000505c:	f4c40593          	addi	a1,s0,-180
    80005060:	4505                	li	a0,1
    80005062:	f10fd0ef          	jal	ra,80002772 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005066:	08000613          	li	a2,128
    8000506a:	f5040593          	addi	a1,s0,-176
    8000506e:	4501                	li	a0,0
    80005070:	f3afd0ef          	jal	ra,800027aa <argstr>
    80005074:	87aa                	mv	a5,a0
    return -1;
    80005076:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005078:	0807cd63          	bltz	a5,80005112 <sys_open+0xc4>

  begin_op();
    8000507c:	d37fe0ef          	jal	ra,80003db2 <begin_op>

  if(omode & O_CREATE){
    80005080:	f4c42783          	lw	a5,-180(s0)
    80005084:	2007f793          	andi	a5,a5,512
    80005088:	c3c5                	beqz	a5,80005128 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000508a:	4681                	li	a3,0
    8000508c:	4601                	li	a2,0
    8000508e:	4589                	li	a1,2
    80005090:	f5040513          	addi	a0,s0,-176
    80005094:	ac3ff0ef          	jal	ra,80004b56 <create>
    80005098:	84aa                	mv	s1,a0
    if(ip == 0){
    8000509a:	c159                	beqz	a0,80005120 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000509c:	04449703          	lh	a4,68(s1)
    800050a0:	478d                	li	a5,3
    800050a2:	00f71763          	bne	a4,a5,800050b0 <sys_open+0x62>
    800050a6:	0464d703          	lhu	a4,70(s1)
    800050aa:	47a5                	li	a5,9
    800050ac:	0ae7e963          	bltu	a5,a4,8000515e <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800050b0:	86cff0ef          	jal	ra,8000411c <filealloc>
    800050b4:	89aa                	mv	s3,a0
    800050b6:	0c050963          	beqz	a0,80005188 <sys_open+0x13a>
    800050ba:	a5fff0ef          	jal	ra,80004b18 <fdalloc>
    800050be:	892a                	mv	s2,a0
    800050c0:	0c054163          	bltz	a0,80005182 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800050c4:	04449703          	lh	a4,68(s1)
    800050c8:	478d                	li	a5,3
    800050ca:	0af70163          	beq	a4,a5,8000516c <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800050ce:	4789                	li	a5,2
    800050d0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800050d4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800050d8:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800050dc:	f4c42783          	lw	a5,-180(s0)
    800050e0:	0017c713          	xori	a4,a5,1
    800050e4:	8b05                	andi	a4,a4,1
    800050e6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800050ea:	0037f713          	andi	a4,a5,3
    800050ee:	00e03733          	snez	a4,a4
    800050f2:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800050f6:	4007f793          	andi	a5,a5,1024
    800050fa:	c791                	beqz	a5,80005106 <sys_open+0xb8>
    800050fc:	04449703          	lh	a4,68(s1)
    80005100:	4789                	li	a5,2
    80005102:	06f70c63          	beq	a4,a5,8000517a <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005106:	8526                	mv	a0,s1
    80005108:	b76fe0ef          	jal	ra,8000347e <iunlock>
  end_op();
    8000510c:	d17fe0ef          	jal	ra,80003e22 <end_op>

  return fd;
    80005110:	854a                	mv	a0,s2
}
    80005112:	70ea                	ld	ra,184(sp)
    80005114:	744a                	ld	s0,176(sp)
    80005116:	74aa                	ld	s1,168(sp)
    80005118:	790a                	ld	s2,160(sp)
    8000511a:	69ea                	ld	s3,152(sp)
    8000511c:	6129                	addi	sp,sp,192
    8000511e:	8082                	ret
      end_op();
    80005120:	d03fe0ef          	jal	ra,80003e22 <end_op>
      return -1;
    80005124:	557d                	li	a0,-1
    80005126:	b7f5                	j	80005112 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005128:	f5040513          	addi	a0,s0,-176
    8000512c:	a97fe0ef          	jal	ra,80003bc2 <namei>
    80005130:	84aa                	mv	s1,a0
    80005132:	c115                	beqz	a0,80005156 <sys_open+0x108>
    ilock(ip);
    80005134:	aa0fe0ef          	jal	ra,800033d4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005138:	04449703          	lh	a4,68(s1)
    8000513c:	4785                	li	a5,1
    8000513e:	f4f71fe3          	bne	a4,a5,8000509c <sys_open+0x4e>
    80005142:	f4c42783          	lw	a5,-180(s0)
    80005146:	d7ad                	beqz	a5,800050b0 <sys_open+0x62>
      iunlockput(ip);
    80005148:	8526                	mv	a0,s1
    8000514a:	c90fe0ef          	jal	ra,800035da <iunlockput>
      end_op();
    8000514e:	cd5fe0ef          	jal	ra,80003e22 <end_op>
      return -1;
    80005152:	557d                	li	a0,-1
    80005154:	bf7d                	j	80005112 <sys_open+0xc4>
      end_op();
    80005156:	ccdfe0ef          	jal	ra,80003e22 <end_op>
      return -1;
    8000515a:	557d                	li	a0,-1
    8000515c:	bf5d                	j	80005112 <sys_open+0xc4>
    iunlockput(ip);
    8000515e:	8526                	mv	a0,s1
    80005160:	c7afe0ef          	jal	ra,800035da <iunlockput>
    end_op();
    80005164:	cbffe0ef          	jal	ra,80003e22 <end_op>
    return -1;
    80005168:	557d                	li	a0,-1
    8000516a:	b765                	j	80005112 <sys_open+0xc4>
    f->type = FD_DEVICE;
    8000516c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005170:	04649783          	lh	a5,70(s1)
    80005174:	02f99223          	sh	a5,36(s3)
    80005178:	b785                	j	800050d8 <sys_open+0x8a>
    itrunc(ip);
    8000517a:	8526                	mv	a0,s1
    8000517c:	b42fe0ef          	jal	ra,800034be <itrunc>
    80005180:	b759                	j	80005106 <sys_open+0xb8>
      fileclose(f);
    80005182:	854e                	mv	a0,s3
    80005184:	83cff0ef          	jal	ra,800041c0 <fileclose>
    iunlockput(ip);
    80005188:	8526                	mv	a0,s1
    8000518a:	c50fe0ef          	jal	ra,800035da <iunlockput>
    end_op();
    8000518e:	c95fe0ef          	jal	ra,80003e22 <end_op>
    return -1;
    80005192:	557d                	li	a0,-1
    80005194:	bfbd                	j	80005112 <sys_open+0xc4>

0000000080005196 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005196:	7175                	addi	sp,sp,-144
    80005198:	e506                	sd	ra,136(sp)
    8000519a:	e122                	sd	s0,128(sp)
    8000519c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000519e:	c15fe0ef          	jal	ra,80003db2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800051a2:	08000613          	li	a2,128
    800051a6:	f7040593          	addi	a1,s0,-144
    800051aa:	4501                	li	a0,0
    800051ac:	dfefd0ef          	jal	ra,800027aa <argstr>
    800051b0:	02054363          	bltz	a0,800051d6 <sys_mkdir+0x40>
    800051b4:	4681                	li	a3,0
    800051b6:	4601                	li	a2,0
    800051b8:	4585                	li	a1,1
    800051ba:	f7040513          	addi	a0,s0,-144
    800051be:	999ff0ef          	jal	ra,80004b56 <create>
    800051c2:	c911                	beqz	a0,800051d6 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051c4:	c16fe0ef          	jal	ra,800035da <iunlockput>
  end_op();
    800051c8:	c5bfe0ef          	jal	ra,80003e22 <end_op>
  return 0;
    800051cc:	4501                	li	a0,0
}
    800051ce:	60aa                	ld	ra,136(sp)
    800051d0:	640a                	ld	s0,128(sp)
    800051d2:	6149                	addi	sp,sp,144
    800051d4:	8082                	ret
    end_op();
    800051d6:	c4dfe0ef          	jal	ra,80003e22 <end_op>
    return -1;
    800051da:	557d                	li	a0,-1
    800051dc:	bfcd                	j	800051ce <sys_mkdir+0x38>

00000000800051de <sys_mknod>:

uint64
sys_mknod(void)
{
    800051de:	7135                	addi	sp,sp,-160
    800051e0:	ed06                	sd	ra,152(sp)
    800051e2:	e922                	sd	s0,144(sp)
    800051e4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800051e6:	bcdfe0ef          	jal	ra,80003db2 <begin_op>
  argint(1, &major);
    800051ea:	f6c40593          	addi	a1,s0,-148
    800051ee:	4505                	li	a0,1
    800051f0:	d82fd0ef          	jal	ra,80002772 <argint>
  argint(2, &minor);
    800051f4:	f6840593          	addi	a1,s0,-152
    800051f8:	4509                	li	a0,2
    800051fa:	d78fd0ef          	jal	ra,80002772 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051fe:	08000613          	li	a2,128
    80005202:	f7040593          	addi	a1,s0,-144
    80005206:	4501                	li	a0,0
    80005208:	da2fd0ef          	jal	ra,800027aa <argstr>
    8000520c:	02054563          	bltz	a0,80005236 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005210:	f6841683          	lh	a3,-152(s0)
    80005214:	f6c41603          	lh	a2,-148(s0)
    80005218:	458d                	li	a1,3
    8000521a:	f7040513          	addi	a0,s0,-144
    8000521e:	939ff0ef          	jal	ra,80004b56 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005222:	c911                	beqz	a0,80005236 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005224:	bb6fe0ef          	jal	ra,800035da <iunlockput>
  end_op();
    80005228:	bfbfe0ef          	jal	ra,80003e22 <end_op>
  return 0;
    8000522c:	4501                	li	a0,0
}
    8000522e:	60ea                	ld	ra,152(sp)
    80005230:	644a                	ld	s0,144(sp)
    80005232:	610d                	addi	sp,sp,160
    80005234:	8082                	ret
    end_op();
    80005236:	bedfe0ef          	jal	ra,80003e22 <end_op>
    return -1;
    8000523a:	557d                	li	a0,-1
    8000523c:	bfcd                	j	8000522e <sys_mknod+0x50>

000000008000523e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000523e:	7135                	addi	sp,sp,-160
    80005240:	ed06                	sd	ra,152(sp)
    80005242:	e922                	sd	s0,144(sp)
    80005244:	e526                	sd	s1,136(sp)
    80005246:	e14a                	sd	s2,128(sp)
    80005248:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000524a:	dc2fc0ef          	jal	ra,8000180c <myproc>
    8000524e:	892a                	mv	s2,a0
  
  begin_op();
    80005250:	b63fe0ef          	jal	ra,80003db2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005254:	08000613          	li	a2,128
    80005258:	f6040593          	addi	a1,s0,-160
    8000525c:	4501                	li	a0,0
    8000525e:	d4cfd0ef          	jal	ra,800027aa <argstr>
    80005262:	04054163          	bltz	a0,800052a4 <sys_chdir+0x66>
    80005266:	f6040513          	addi	a0,s0,-160
    8000526a:	959fe0ef          	jal	ra,80003bc2 <namei>
    8000526e:	84aa                	mv	s1,a0
    80005270:	c915                	beqz	a0,800052a4 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005272:	962fe0ef          	jal	ra,800033d4 <ilock>
  if(ip->type != T_DIR){
    80005276:	04449703          	lh	a4,68(s1)
    8000527a:	4785                	li	a5,1
    8000527c:	02f71863          	bne	a4,a5,800052ac <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005280:	8526                	mv	a0,s1
    80005282:	9fcfe0ef          	jal	ra,8000347e <iunlock>
  iput(p->cwd);
    80005286:	15093503          	ld	a0,336(s2)
    8000528a:	ac8fe0ef          	jal	ra,80003552 <iput>
  end_op();
    8000528e:	b95fe0ef          	jal	ra,80003e22 <end_op>
  p->cwd = ip;
    80005292:	14993823          	sd	s1,336(s2)
  return 0;
    80005296:	4501                	li	a0,0
}
    80005298:	60ea                	ld	ra,152(sp)
    8000529a:	644a                	ld	s0,144(sp)
    8000529c:	64aa                	ld	s1,136(sp)
    8000529e:	690a                	ld	s2,128(sp)
    800052a0:	610d                	addi	sp,sp,160
    800052a2:	8082                	ret
    end_op();
    800052a4:	b7ffe0ef          	jal	ra,80003e22 <end_op>
    return -1;
    800052a8:	557d                	li	a0,-1
    800052aa:	b7fd                	j	80005298 <sys_chdir+0x5a>
    iunlockput(ip);
    800052ac:	8526                	mv	a0,s1
    800052ae:	b2cfe0ef          	jal	ra,800035da <iunlockput>
    end_op();
    800052b2:	b71fe0ef          	jal	ra,80003e22 <end_op>
    return -1;
    800052b6:	557d                	li	a0,-1
    800052b8:	b7c5                	j	80005298 <sys_chdir+0x5a>

00000000800052ba <sys_exec>:

uint64
sys_exec(void)
{
    800052ba:	7145                	addi	sp,sp,-464
    800052bc:	e786                	sd	ra,456(sp)
    800052be:	e3a2                	sd	s0,448(sp)
    800052c0:	ff26                	sd	s1,440(sp)
    800052c2:	fb4a                	sd	s2,432(sp)
    800052c4:	f74e                	sd	s3,424(sp)
    800052c6:	f352                	sd	s4,416(sp)
    800052c8:	ef56                	sd	s5,408(sp)
    800052ca:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800052cc:	e3840593          	addi	a1,s0,-456
    800052d0:	4505                	li	a0,1
    800052d2:	cbcfd0ef          	jal	ra,8000278e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800052d6:	08000613          	li	a2,128
    800052da:	f4040593          	addi	a1,s0,-192
    800052de:	4501                	li	a0,0
    800052e0:	ccafd0ef          	jal	ra,800027aa <argstr>
    800052e4:	87aa                	mv	a5,a0
    return -1;
    800052e6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800052e8:	0a07c463          	bltz	a5,80005390 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    800052ec:	10000613          	li	a2,256
    800052f0:	4581                	li	a1,0
    800052f2:	e4040513          	addi	a0,s0,-448
    800052f6:	94bfb0ef          	jal	ra,80000c40 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800052fa:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800052fe:	89a6                	mv	s3,s1
    80005300:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005302:	02000a13          	li	s4,32
    80005306:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000530a:	00391793          	slli	a5,s2,0x3
    8000530e:	e3040593          	addi	a1,s0,-464
    80005312:	e3843503          	ld	a0,-456(s0)
    80005316:	953e                	add	a0,a0,a5
    80005318:	bd0fd0ef          	jal	ra,800026e8 <fetchaddr>
    8000531c:	02054663          	bltz	a0,80005348 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005320:	e3043783          	ld	a5,-464(s0)
    80005324:	cf8d                	beqz	a5,8000535e <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005326:	f76fb0ef          	jal	ra,80000a9c <kalloc>
    8000532a:	85aa                	mv	a1,a0
    8000532c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005330:	cd01                	beqz	a0,80005348 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005332:	6605                	lui	a2,0x1
    80005334:	e3043503          	ld	a0,-464(s0)
    80005338:	bfafd0ef          	jal	ra,80002732 <fetchstr>
    8000533c:	00054663          	bltz	a0,80005348 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005340:	0905                	addi	s2,s2,1
    80005342:	09a1                	addi	s3,s3,8
    80005344:	fd4911e3          	bne	s2,s4,80005306 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005348:	10048913          	addi	s2,s1,256
    8000534c:	6088                	ld	a0,0(s1)
    8000534e:	c121                	beqz	a0,8000538e <sys_exec+0xd4>
    kfree(argv[i]);
    80005350:	e6cfb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005354:	04a1                	addi	s1,s1,8
    80005356:	ff249be3          	bne	s1,s2,8000534c <sys_exec+0x92>
  return -1;
    8000535a:	557d                	li	a0,-1
    8000535c:	a815                	j	80005390 <sys_exec+0xd6>
      argv[i] = 0;
    8000535e:	0a8e                	slli	s5,s5,0x3
    80005360:	fc040793          	addi	a5,s0,-64
    80005364:	9abe                	add	s5,s5,a5
    80005366:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    8000536a:	e4040593          	addi	a1,s0,-448
    8000536e:	f4040513          	addi	a0,s0,-192
    80005372:	bfaff0ef          	jal	ra,8000476c <kexec>
    80005376:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005378:	10048993          	addi	s3,s1,256
    8000537c:	6088                	ld	a0,0(s1)
    8000537e:	c511                	beqz	a0,8000538a <sys_exec+0xd0>
    kfree(argv[i]);
    80005380:	e3cfb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005384:	04a1                	addi	s1,s1,8
    80005386:	ff349be3          	bne	s1,s3,8000537c <sys_exec+0xc2>
  return ret;
    8000538a:	854a                	mv	a0,s2
    8000538c:	a011                	j	80005390 <sys_exec+0xd6>
  return -1;
    8000538e:	557d                	li	a0,-1
}
    80005390:	60be                	ld	ra,456(sp)
    80005392:	641e                	ld	s0,448(sp)
    80005394:	74fa                	ld	s1,440(sp)
    80005396:	795a                	ld	s2,432(sp)
    80005398:	79ba                	ld	s3,424(sp)
    8000539a:	7a1a                	ld	s4,416(sp)
    8000539c:	6afa                	ld	s5,408(sp)
    8000539e:	6179                	addi	sp,sp,464
    800053a0:	8082                	ret

00000000800053a2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800053a2:	7139                	addi	sp,sp,-64
    800053a4:	fc06                	sd	ra,56(sp)
    800053a6:	f822                	sd	s0,48(sp)
    800053a8:	f426                	sd	s1,40(sp)
    800053aa:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800053ac:	c60fc0ef          	jal	ra,8000180c <myproc>
    800053b0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800053b2:	fd840593          	addi	a1,s0,-40
    800053b6:	4501                	li	a0,0
    800053b8:	bd6fd0ef          	jal	ra,8000278e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800053bc:	fc840593          	addi	a1,s0,-56
    800053c0:	fd040513          	addi	a0,s0,-48
    800053c4:	8c8ff0ef          	jal	ra,8000448c <pipealloc>
    return -1;
    800053c8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800053ca:	0a054463          	bltz	a0,80005472 <sys_pipe+0xd0>
  fd0 = -1;
    800053ce:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800053d2:	fd043503          	ld	a0,-48(s0)
    800053d6:	f42ff0ef          	jal	ra,80004b18 <fdalloc>
    800053da:	fca42223          	sw	a0,-60(s0)
    800053de:	08054163          	bltz	a0,80005460 <sys_pipe+0xbe>
    800053e2:	fc843503          	ld	a0,-56(s0)
    800053e6:	f32ff0ef          	jal	ra,80004b18 <fdalloc>
    800053ea:	fca42023          	sw	a0,-64(s0)
    800053ee:	06054063          	bltz	a0,8000544e <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053f2:	4691                	li	a3,4
    800053f4:	fc440613          	addi	a2,s0,-60
    800053f8:	fd843583          	ld	a1,-40(s0)
    800053fc:	68a8                	ld	a0,80(s1)
    800053fe:	954fc0ef          	jal	ra,80001552 <copyout>
    80005402:	00054e63          	bltz	a0,8000541e <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005406:	4691                	li	a3,4
    80005408:	fc040613          	addi	a2,s0,-64
    8000540c:	fd843583          	ld	a1,-40(s0)
    80005410:	0591                	addi	a1,a1,4
    80005412:	68a8                	ld	a0,80(s1)
    80005414:	93efc0ef          	jal	ra,80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005418:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000541a:	04055c63          	bgez	a0,80005472 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000541e:	fc442783          	lw	a5,-60(s0)
    80005422:	07e9                	addi	a5,a5,26
    80005424:	078e                	slli	a5,a5,0x3
    80005426:	97a6                	add	a5,a5,s1
    80005428:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000542c:	fc042503          	lw	a0,-64(s0)
    80005430:	0569                	addi	a0,a0,26
    80005432:	050e                	slli	a0,a0,0x3
    80005434:	94aa                	add	s1,s1,a0
    80005436:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000543a:	fd043503          	ld	a0,-48(s0)
    8000543e:	d83fe0ef          	jal	ra,800041c0 <fileclose>
    fileclose(wf);
    80005442:	fc843503          	ld	a0,-56(s0)
    80005446:	d7bfe0ef          	jal	ra,800041c0 <fileclose>
    return -1;
    8000544a:	57fd                	li	a5,-1
    8000544c:	a01d                	j	80005472 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000544e:	fc442783          	lw	a5,-60(s0)
    80005452:	0007c763          	bltz	a5,80005460 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005456:	07e9                	addi	a5,a5,26
    80005458:	078e                	slli	a5,a5,0x3
    8000545a:	94be                	add	s1,s1,a5
    8000545c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005460:	fd043503          	ld	a0,-48(s0)
    80005464:	d5dfe0ef          	jal	ra,800041c0 <fileclose>
    fileclose(wf);
    80005468:	fc843503          	ld	a0,-56(s0)
    8000546c:	d55fe0ef          	jal	ra,800041c0 <fileclose>
    return -1;
    80005470:	57fd                	li	a5,-1
}
    80005472:	853e                	mv	a0,a5
    80005474:	70e2                	ld	ra,56(sp)
    80005476:	7442                	ld	s0,48(sp)
    80005478:	74a2                	ld	s1,40(sp)
    8000547a:	6121                	addi	sp,sp,64
    8000547c:	8082                	ret
	...

0000000080005480 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005480:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005482:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005484:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005486:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005488:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000548a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000548c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000548e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005490:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005492:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005494:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005496:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005498:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000549a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000549c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000549e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800054a0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800054a2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800054a4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800054a6:	952fd0ef          	jal	ra,800025f8 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800054aa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800054ac:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800054ae:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800054b0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800054b2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800054b4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800054b6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800054b8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800054ba:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800054bc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800054be:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800054c0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800054c2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800054c4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800054c6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800054c8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800054ca:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800054cc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800054ce:	10200073          	sret
	...

00000000800054de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800054de:	1141                	addi	sp,sp,-16
    800054e0:	e422                	sd	s0,8(sp)
    800054e2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800054e4:	0c0007b7          	lui	a5,0xc000
    800054e8:	4705                	li	a4,1
    800054ea:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800054ec:	c3d8                	sw	a4,4(a5)
}
    800054ee:	6422                	ld	s0,8(sp)
    800054f0:	0141                	addi	sp,sp,16
    800054f2:	8082                	ret

00000000800054f4 <plicinithart>:

void
plicinithart(void)
{
    800054f4:	1141                	addi	sp,sp,-16
    800054f6:	e406                	sd	ra,8(sp)
    800054f8:	e022                	sd	s0,0(sp)
    800054fa:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054fc:	ae4fc0ef          	jal	ra,800017e0 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005500:	0085171b          	slliw	a4,a0,0x8
    80005504:	0c0027b7          	lui	a5,0xc002
    80005508:	97ba                	add	a5,a5,a4
    8000550a:	40200713          	li	a4,1026
    8000550e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005512:	00d5151b          	slliw	a0,a0,0xd
    80005516:	0c2017b7          	lui	a5,0xc201
    8000551a:	953e                	add	a0,a0,a5
    8000551c:	00052023          	sw	zero,0(a0)
}
    80005520:	60a2                	ld	ra,8(sp)
    80005522:	6402                	ld	s0,0(sp)
    80005524:	0141                	addi	sp,sp,16
    80005526:	8082                	ret

0000000080005528 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005528:	1141                	addi	sp,sp,-16
    8000552a:	e406                	sd	ra,8(sp)
    8000552c:	e022                	sd	s0,0(sp)
    8000552e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005530:	ab0fc0ef          	jal	ra,800017e0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005534:	00d5179b          	slliw	a5,a0,0xd
    80005538:	0c201537          	lui	a0,0xc201
    8000553c:	953e                	add	a0,a0,a5
  return irq;
}
    8000553e:	4148                	lw	a0,4(a0)
    80005540:	60a2                	ld	ra,8(sp)
    80005542:	6402                	ld	s0,0(sp)
    80005544:	0141                	addi	sp,sp,16
    80005546:	8082                	ret

0000000080005548 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005548:	1101                	addi	sp,sp,-32
    8000554a:	ec06                	sd	ra,24(sp)
    8000554c:	e822                	sd	s0,16(sp)
    8000554e:	e426                	sd	s1,8(sp)
    80005550:	1000                	addi	s0,sp,32
    80005552:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005554:	a8cfc0ef          	jal	ra,800017e0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005558:	00d5151b          	slliw	a0,a0,0xd
    8000555c:	0c2017b7          	lui	a5,0xc201
    80005560:	97aa                	add	a5,a5,a0
    80005562:	c3c4                	sw	s1,4(a5)
}
    80005564:	60e2                	ld	ra,24(sp)
    80005566:	6442                	ld	s0,16(sp)
    80005568:	64a2                	ld	s1,8(sp)
    8000556a:	6105                	addi	sp,sp,32
    8000556c:	8082                	ret

000000008000556e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000556e:	1141                	addi	sp,sp,-16
    80005570:	e406                	sd	ra,8(sp)
    80005572:	e022                	sd	s0,0(sp)
    80005574:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005576:	479d                	li	a5,7
    80005578:	04a7ca63          	blt	a5,a0,800055cc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000557c:	0001c797          	auipc	a5,0x1c
    80005580:	a0c78793          	addi	a5,a5,-1524 # 80020f88 <disk>
    80005584:	97aa                	add	a5,a5,a0
    80005586:	0187c783          	lbu	a5,24(a5)
    8000558a:	e7b9                	bnez	a5,800055d8 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000558c:	00451613          	slli	a2,a0,0x4
    80005590:	0001c797          	auipc	a5,0x1c
    80005594:	9f878793          	addi	a5,a5,-1544 # 80020f88 <disk>
    80005598:	6394                	ld	a3,0(a5)
    8000559a:	96b2                	add	a3,a3,a2
    8000559c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800055a0:	6398                	ld	a4,0(a5)
    800055a2:	9732                	add	a4,a4,a2
    800055a4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800055a8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800055ac:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800055b0:	953e                	add	a0,a0,a5
    800055b2:	4785                	li	a5,1
    800055b4:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800055b8:	0001c517          	auipc	a0,0x1c
    800055bc:	9e850513          	addi	a0,a0,-1560 # 80020fa0 <disk+0x18>
    800055c0:	8b7fc0ef          	jal	ra,80001e76 <wakeup>
}
    800055c4:	60a2                	ld	ra,8(sp)
    800055c6:	6402                	ld	s0,0(sp)
    800055c8:	0141                	addi	sp,sp,16
    800055ca:	8082                	ret
    panic("free_desc 1");
    800055cc:	00002517          	auipc	a0,0x2
    800055d0:	2b450513          	addi	a0,a0,692 # 80007880 <states.0+0x2b0>
    800055d4:	9b6fb0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    800055d8:	00002517          	auipc	a0,0x2
    800055dc:	2b850513          	addi	a0,a0,696 # 80007890 <states.0+0x2c0>
    800055e0:	9aafb0ef          	jal	ra,8000078a <panic>

00000000800055e4 <virtio_disk_init>:
{
    800055e4:	1101                	addi	sp,sp,-32
    800055e6:	ec06                	sd	ra,24(sp)
    800055e8:	e822                	sd	s0,16(sp)
    800055ea:	e426                	sd	s1,8(sp)
    800055ec:	e04a                	sd	s2,0(sp)
    800055ee:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800055f0:	00002597          	auipc	a1,0x2
    800055f4:	2b058593          	addi	a1,a1,688 # 800078a0 <states.0+0x2d0>
    800055f8:	0001c517          	auipc	a0,0x1c
    800055fc:	ab850513          	addi	a0,a0,-1352 # 800210b0 <disk+0x128>
    80005600:	cecfb0ef          	jal	ra,80000aec <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005604:	100017b7          	lui	a5,0x10001
    80005608:	4398                	lw	a4,0(a5)
    8000560a:	2701                	sext.w	a4,a4
    8000560c:	747277b7          	lui	a5,0x74727
    80005610:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005614:	14f71063          	bne	a4,a5,80005754 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005618:	100017b7          	lui	a5,0x10001
    8000561c:	43dc                	lw	a5,4(a5)
    8000561e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005620:	4709                	li	a4,2
    80005622:	12e79963          	bne	a5,a4,80005754 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005626:	100017b7          	lui	a5,0x10001
    8000562a:	479c                	lw	a5,8(a5)
    8000562c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000562e:	12e79363          	bne	a5,a4,80005754 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005632:	100017b7          	lui	a5,0x10001
    80005636:	47d8                	lw	a4,12(a5)
    80005638:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000563a:	554d47b7          	lui	a5,0x554d4
    8000563e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005642:	10f71963          	bne	a4,a5,80005754 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005646:	100017b7          	lui	a5,0x10001
    8000564a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000564e:	4705                	li	a4,1
    80005650:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005652:	470d                	li	a4,3
    80005654:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005656:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005658:	c7ffe737          	lui	a4,0xc7ffe
    8000565c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd697>
    80005660:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005662:	2701                	sext.w	a4,a4
    80005664:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005666:	472d                	li	a4,11
    80005668:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000566a:	5bbc                	lw	a5,112(a5)
    8000566c:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005670:	8ba1                	andi	a5,a5,8
    80005672:	0e078763          	beqz	a5,80005760 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005676:	100017b7          	lui	a5,0x10001
    8000567a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000567e:	43fc                	lw	a5,68(a5)
    80005680:	2781                	sext.w	a5,a5
    80005682:	0e079563          	bnez	a5,8000576c <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005686:	100017b7          	lui	a5,0x10001
    8000568a:	5bdc                	lw	a5,52(a5)
    8000568c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000568e:	0e078563          	beqz	a5,80005778 <virtio_disk_init+0x194>
  if(max < NUM)
    80005692:	471d                	li	a4,7
    80005694:	0ef77863          	bgeu	a4,a5,80005784 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80005698:	c04fb0ef          	jal	ra,80000a9c <kalloc>
    8000569c:	0001c497          	auipc	s1,0x1c
    800056a0:	8ec48493          	addi	s1,s1,-1812 # 80020f88 <disk>
    800056a4:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800056a6:	bf6fb0ef          	jal	ra,80000a9c <kalloc>
    800056aa:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800056ac:	bf0fb0ef          	jal	ra,80000a9c <kalloc>
    800056b0:	87aa                	mv	a5,a0
    800056b2:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800056b4:	6088                	ld	a0,0(s1)
    800056b6:	cd69                	beqz	a0,80005790 <virtio_disk_init+0x1ac>
    800056b8:	0001c717          	auipc	a4,0x1c
    800056bc:	8d873703          	ld	a4,-1832(a4) # 80020f90 <disk+0x8>
    800056c0:	cb61                	beqz	a4,80005790 <virtio_disk_init+0x1ac>
    800056c2:	c7f9                	beqz	a5,80005790 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    800056c4:	6605                	lui	a2,0x1
    800056c6:	4581                	li	a1,0
    800056c8:	d78fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.avail, 0, PGSIZE);
    800056cc:	0001c497          	auipc	s1,0x1c
    800056d0:	8bc48493          	addi	s1,s1,-1860 # 80020f88 <disk>
    800056d4:	6605                	lui	a2,0x1
    800056d6:	4581                	li	a1,0
    800056d8:	6488                	ld	a0,8(s1)
    800056da:	d66fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.used, 0, PGSIZE);
    800056de:	6605                	lui	a2,0x1
    800056e0:	4581                	li	a1,0
    800056e2:	6888                	ld	a0,16(s1)
    800056e4:	d5cfb0ef          	jal	ra,80000c40 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800056e8:	100017b7          	lui	a5,0x10001
    800056ec:	4721                	li	a4,8
    800056ee:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800056f0:	4098                	lw	a4,0(s1)
    800056f2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800056f6:	40d8                	lw	a4,4(s1)
    800056f8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800056fc:	6498                	ld	a4,8(s1)
    800056fe:	0007069b          	sext.w	a3,a4
    80005702:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005706:	9701                	srai	a4,a4,0x20
    80005708:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000570c:	6898                	ld	a4,16(s1)
    8000570e:	0007069b          	sext.w	a3,a4
    80005712:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005716:	9701                	srai	a4,a4,0x20
    80005718:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000571c:	4705                	li	a4,1
    8000571e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005720:	00e48c23          	sb	a4,24(s1)
    80005724:	00e48ca3          	sb	a4,25(s1)
    80005728:	00e48d23          	sb	a4,26(s1)
    8000572c:	00e48da3          	sb	a4,27(s1)
    80005730:	00e48e23          	sb	a4,28(s1)
    80005734:	00e48ea3          	sb	a4,29(s1)
    80005738:	00e48f23          	sb	a4,30(s1)
    8000573c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005740:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005744:	0727a823          	sw	s2,112(a5)
}
    80005748:	60e2                	ld	ra,24(sp)
    8000574a:	6442                	ld	s0,16(sp)
    8000574c:	64a2                	ld	s1,8(sp)
    8000574e:	6902                	ld	s2,0(sp)
    80005750:	6105                	addi	sp,sp,32
    80005752:	8082                	ret
    panic("could not find virtio disk");
    80005754:	00002517          	auipc	a0,0x2
    80005758:	15c50513          	addi	a0,a0,348 # 800078b0 <states.0+0x2e0>
    8000575c:	82efb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    80005760:	00002517          	auipc	a0,0x2
    80005764:	17050513          	addi	a0,a0,368 # 800078d0 <states.0+0x300>
    80005768:	822fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    8000576c:	00002517          	auipc	a0,0x2
    80005770:	18450513          	addi	a0,a0,388 # 800078f0 <states.0+0x320>
    80005774:	816fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    80005778:	00002517          	auipc	a0,0x2
    8000577c:	19850513          	addi	a0,a0,408 # 80007910 <states.0+0x340>
    80005780:	80afb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    80005784:	00002517          	auipc	a0,0x2
    80005788:	1ac50513          	addi	a0,a0,428 # 80007930 <states.0+0x360>
    8000578c:	ffffa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    80005790:	00002517          	auipc	a0,0x2
    80005794:	1c050513          	addi	a0,a0,448 # 80007950 <states.0+0x380>
    80005798:	ff3fa0ef          	jal	ra,8000078a <panic>

000000008000579c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000579c:	7119                	addi	sp,sp,-128
    8000579e:	fc86                	sd	ra,120(sp)
    800057a0:	f8a2                	sd	s0,112(sp)
    800057a2:	f4a6                	sd	s1,104(sp)
    800057a4:	f0ca                	sd	s2,96(sp)
    800057a6:	ecce                	sd	s3,88(sp)
    800057a8:	e8d2                	sd	s4,80(sp)
    800057aa:	e4d6                	sd	s5,72(sp)
    800057ac:	e0da                	sd	s6,64(sp)
    800057ae:	fc5e                	sd	s7,56(sp)
    800057b0:	f862                	sd	s8,48(sp)
    800057b2:	f466                	sd	s9,40(sp)
    800057b4:	f06a                	sd	s10,32(sp)
    800057b6:	ec6e                	sd	s11,24(sp)
    800057b8:	0100                	addi	s0,sp,128
    800057ba:	8aaa                	mv	s5,a0
    800057bc:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800057be:	00c52d03          	lw	s10,12(a0)
    800057c2:	001d1d1b          	slliw	s10,s10,0x1
    800057c6:	1d02                	slli	s10,s10,0x20
    800057c8:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800057cc:	0001c517          	auipc	a0,0x1c
    800057d0:	8e450513          	addi	a0,a0,-1820 # 800210b0 <disk+0x128>
    800057d4:	b98fb0ef          	jal	ra,80000b6c <acquire>
  for(int i = 0; i < 3; i++){
    800057d8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800057da:	44a1                	li	s1,8
      disk.free[i] = 0;
    800057dc:	0001bb97          	auipc	s7,0x1b
    800057e0:	7acb8b93          	addi	s7,s7,1964 # 80020f88 <disk>
  for(int i = 0; i < 3; i++){
    800057e4:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057e6:	0001cc97          	auipc	s9,0x1c
    800057ea:	8cac8c93          	addi	s9,s9,-1846 # 800210b0 <disk+0x128>
    800057ee:	a8a9                	j	80005848 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800057f0:	00fb8733          	add	a4,s7,a5
    800057f4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800057f8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800057fa:	0207c563          	bltz	a5,80005824 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800057fe:	2905                	addiw	s2,s2,1
    80005800:	0611                	addi	a2,a2,4
    80005802:	05690863          	beq	s2,s6,80005852 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005806:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005808:	0001b717          	auipc	a4,0x1b
    8000580c:	78070713          	addi	a4,a4,1920 # 80020f88 <disk>
    80005810:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005812:	01874683          	lbu	a3,24(a4)
    80005816:	fee9                	bnez	a3,800057f0 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005818:	2785                	addiw	a5,a5,1
    8000581a:	0705                	addi	a4,a4,1
    8000581c:	fe979be3          	bne	a5,s1,80005812 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005820:	57fd                	li	a5,-1
    80005822:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005824:	01205b63          	blez	s2,8000583a <virtio_disk_rw+0x9e>
    80005828:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000582a:	000a2503          	lw	a0,0(s4)
    8000582e:	d41ff0ef          	jal	ra,8000556e <free_desc>
      for(int j = 0; j < i; j++)
    80005832:	2d85                	addiw	s11,s11,1
    80005834:	0a11                	addi	s4,s4,4
    80005836:	ffb91ae3          	bne	s2,s11,8000582a <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000583a:	85e6                	mv	a1,s9
    8000583c:	0001b517          	auipc	a0,0x1b
    80005840:	76450513          	addi	a0,a0,1892 # 80020fa0 <disk+0x18>
    80005844:	de6fc0ef          	jal	ra,80001e2a <sleep>
  for(int i = 0; i < 3; i++){
    80005848:	f8040a13          	addi	s4,s0,-128
{
    8000584c:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000584e:	894e                	mv	s2,s3
    80005850:	bf5d                	j	80005806 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005852:	f8042583          	lw	a1,-128(s0)
    80005856:	00a58793          	addi	a5,a1,10
    8000585a:	0792                	slli	a5,a5,0x4

  if(write)
    8000585c:	0001b617          	auipc	a2,0x1b
    80005860:	72c60613          	addi	a2,a2,1836 # 80020f88 <disk>
    80005864:	00f60733          	add	a4,a2,a5
    80005868:	018036b3          	snez	a3,s8
    8000586c:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000586e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005872:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005876:	f6078693          	addi	a3,a5,-160
    8000587a:	6218                	ld	a4,0(a2)
    8000587c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000587e:	00878513          	addi	a0,a5,8
    80005882:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005884:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005886:	6208                	ld	a0,0(a2)
    80005888:	96aa                	add	a3,a3,a0
    8000588a:	4741                	li	a4,16
    8000588c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000588e:	4705                	li	a4,1
    80005890:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005894:	f8442703          	lw	a4,-124(s0)
    80005898:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000589c:	0712                	slli	a4,a4,0x4
    8000589e:	953a                	add	a0,a0,a4
    800058a0:	058a8693          	addi	a3,s5,88
    800058a4:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800058a6:	6208                	ld	a0,0(a2)
    800058a8:	972a                	add	a4,a4,a0
    800058aa:	40000693          	li	a3,1024
    800058ae:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800058b0:	001c3c13          	seqz	s8,s8
    800058b4:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800058b6:	001c6c13          	ori	s8,s8,1
    800058ba:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800058be:	f8842603          	lw	a2,-120(s0)
    800058c2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800058c6:	0001b697          	auipc	a3,0x1b
    800058ca:	6c268693          	addi	a3,a3,1730 # 80020f88 <disk>
    800058ce:	00258713          	addi	a4,a1,2
    800058d2:	0712                	slli	a4,a4,0x4
    800058d4:	9736                	add	a4,a4,a3
    800058d6:	587d                	li	a6,-1
    800058d8:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800058dc:	0612                	slli	a2,a2,0x4
    800058de:	9532                	add	a0,a0,a2
    800058e0:	f9078793          	addi	a5,a5,-112
    800058e4:	97b6                	add	a5,a5,a3
    800058e6:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800058e8:	629c                	ld	a5,0(a3)
    800058ea:	97b2                	add	a5,a5,a2
    800058ec:	4605                	li	a2,1
    800058ee:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800058f0:	4509                	li	a0,2
    800058f2:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800058f6:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800058fa:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800058fe:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005902:	6698                	ld	a4,8(a3)
    80005904:	00275783          	lhu	a5,2(a4)
    80005908:	8b9d                	andi	a5,a5,7
    8000590a:	0786                	slli	a5,a5,0x1
    8000590c:	97ba                	add	a5,a5,a4
    8000590e:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005912:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005916:	6698                	ld	a4,8(a3)
    80005918:	00275783          	lhu	a5,2(a4)
    8000591c:	2785                	addiw	a5,a5,1
    8000591e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005922:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005926:	100017b7          	lui	a5,0x10001
    8000592a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000592e:	004aa783          	lw	a5,4(s5)
    80005932:	00c79f63          	bne	a5,a2,80005950 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80005936:	0001b917          	auipc	s2,0x1b
    8000593a:	77a90913          	addi	s2,s2,1914 # 800210b0 <disk+0x128>
  while(b->disk == 1) {
    8000593e:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005940:	85ca                	mv	a1,s2
    80005942:	8556                	mv	a0,s5
    80005944:	ce6fc0ef          	jal	ra,80001e2a <sleep>
  while(b->disk == 1) {
    80005948:	004aa783          	lw	a5,4(s5)
    8000594c:	fe978ae3          	beq	a5,s1,80005940 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005950:	f8042903          	lw	s2,-128(s0)
    80005954:	00290793          	addi	a5,s2,2
    80005958:	00479713          	slli	a4,a5,0x4
    8000595c:	0001b797          	auipc	a5,0x1b
    80005960:	62c78793          	addi	a5,a5,1580 # 80020f88 <disk>
    80005964:	97ba                	add	a5,a5,a4
    80005966:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000596a:	0001b997          	auipc	s3,0x1b
    8000596e:	61e98993          	addi	s3,s3,1566 # 80020f88 <disk>
    80005972:	00491713          	slli	a4,s2,0x4
    80005976:	0009b783          	ld	a5,0(s3)
    8000597a:	97ba                	add	a5,a5,a4
    8000597c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005980:	854a                	mv	a0,s2
    80005982:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005986:	be9ff0ef          	jal	ra,8000556e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000598a:	8885                	andi	s1,s1,1
    8000598c:	f0fd                	bnez	s1,80005972 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000598e:	0001b517          	auipc	a0,0x1b
    80005992:	72250513          	addi	a0,a0,1826 # 800210b0 <disk+0x128>
    80005996:	a6efb0ef          	jal	ra,80000c04 <release>
}
    8000599a:	70e6                	ld	ra,120(sp)
    8000599c:	7446                	ld	s0,112(sp)
    8000599e:	74a6                	ld	s1,104(sp)
    800059a0:	7906                	ld	s2,96(sp)
    800059a2:	69e6                	ld	s3,88(sp)
    800059a4:	6a46                	ld	s4,80(sp)
    800059a6:	6aa6                	ld	s5,72(sp)
    800059a8:	6b06                	ld	s6,64(sp)
    800059aa:	7be2                	ld	s7,56(sp)
    800059ac:	7c42                	ld	s8,48(sp)
    800059ae:	7ca2                	ld	s9,40(sp)
    800059b0:	7d02                	ld	s10,32(sp)
    800059b2:	6de2                	ld	s11,24(sp)
    800059b4:	6109                	addi	sp,sp,128
    800059b6:	8082                	ret

00000000800059b8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800059b8:	1101                	addi	sp,sp,-32
    800059ba:	ec06                	sd	ra,24(sp)
    800059bc:	e822                	sd	s0,16(sp)
    800059be:	e426                	sd	s1,8(sp)
    800059c0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800059c2:	0001b497          	auipc	s1,0x1b
    800059c6:	5c648493          	addi	s1,s1,1478 # 80020f88 <disk>
    800059ca:	0001b517          	auipc	a0,0x1b
    800059ce:	6e650513          	addi	a0,a0,1766 # 800210b0 <disk+0x128>
    800059d2:	99afb0ef          	jal	ra,80000b6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800059d6:	10001737          	lui	a4,0x10001
    800059da:	533c                	lw	a5,96(a4)
    800059dc:	8b8d                	andi	a5,a5,3
    800059de:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800059e0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800059e4:	689c                	ld	a5,16(s1)
    800059e6:	0204d703          	lhu	a4,32(s1)
    800059ea:	0027d783          	lhu	a5,2(a5)
    800059ee:	04f70663          	beq	a4,a5,80005a3a <virtio_disk_intr+0x82>
    __sync_synchronize();
    800059f2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800059f6:	6898                	ld	a4,16(s1)
    800059f8:	0204d783          	lhu	a5,32(s1)
    800059fc:	8b9d                	andi	a5,a5,7
    800059fe:	078e                	slli	a5,a5,0x3
    80005a00:	97ba                	add	a5,a5,a4
    80005a02:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005a04:	00278713          	addi	a4,a5,2
    80005a08:	0712                	slli	a4,a4,0x4
    80005a0a:	9726                	add	a4,a4,s1
    80005a0c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005a10:	e321                	bnez	a4,80005a50 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a12:	0789                	addi	a5,a5,2
    80005a14:	0792                	slli	a5,a5,0x4
    80005a16:	97a6                	add	a5,a5,s1
    80005a18:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a1a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a1e:	c58fc0ef          	jal	ra,80001e76 <wakeup>

    disk.used_idx += 1;
    80005a22:	0204d783          	lhu	a5,32(s1)
    80005a26:	2785                	addiw	a5,a5,1
    80005a28:	17c2                	slli	a5,a5,0x30
    80005a2a:	93c1                	srli	a5,a5,0x30
    80005a2c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a30:	6898                	ld	a4,16(s1)
    80005a32:	00275703          	lhu	a4,2(a4)
    80005a36:	faf71ee3          	bne	a4,a5,800059f2 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005a3a:	0001b517          	auipc	a0,0x1b
    80005a3e:	67650513          	addi	a0,a0,1654 # 800210b0 <disk+0x128>
    80005a42:	9c2fb0ef          	jal	ra,80000c04 <release>
}
    80005a46:	60e2                	ld	ra,24(sp)
    80005a48:	6442                	ld	s0,16(sp)
    80005a4a:	64a2                	ld	s1,8(sp)
    80005a4c:	6105                	addi	sp,sp,32
    80005a4e:	8082                	ret
      panic("virtio_disk_intr status");
    80005a50:	00002517          	auipc	a0,0x2
    80005a54:	f1850513          	addi	a0,a0,-232 # 80007968 <states.0+0x398>
    80005a58:	d33fa0ef          	jal	ra,8000078a <panic>
	...

0000000080006000 <_trampoline>:
        # user page table.
        #

        # save user a0 in sscratch so
        # a0 can be used to get at TRAPFRAME.
        csrw sscratch, a0
    80006000:	14051073          	csrw	sscratch,a0

        # each process has a separate p->trapframe memory area,
        # but it's mapped to the same virtual address
        # (TRAPFRAME) in every process's user page table.
        li a0, TRAPFRAME
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1
    8000600a:	0536                	slli	a0,a0,0xd
        
        # save the user registers in TRAPFRAME
        sd ra, 40(a0)
    8000600c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        sd sp, 48(a0)
    80006010:	02253823          	sd	sp,48(a0)
        sd gp, 56(a0)
    80006014:	02353c23          	sd	gp,56(a0)
        sd tp, 64(a0)
    80006018:	04453023          	sd	tp,64(a0)
        sd t0, 72(a0)
    8000601c:	04553423          	sd	t0,72(a0)
        sd t1, 80(a0)
    80006020:	04653823          	sd	t1,80(a0)
        sd t2, 88(a0)
    80006024:	04753c23          	sd	t2,88(a0)
        sd s0, 96(a0)
    80006028:	f120                	sd	s0,96(a0)
        sd s1, 104(a0)
    8000602a:	f524                	sd	s1,104(a0)
        sd a1, 120(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
        sd a2, 128(a0)
    8000602e:	e150                	sd	a2,128(a0)
        sd a3, 136(a0)
    80006030:	e554                	sd	a3,136(a0)
        sd a4, 144(a0)
    80006032:	e958                	sd	a4,144(a0)
        sd a5, 152(a0)
    80006034:	ed5c                	sd	a5,152(a0)
        sd a6, 160(a0)
    80006036:	0b053023          	sd	a6,160(a0)
        sd a7, 168(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
        sd s2, 176(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
        sd s3, 184(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
        sd s4, 192(a0)
    80006046:	0d453023          	sd	s4,192(a0)
        sd s5, 200(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
        sd s6, 208(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
        sd s7, 216(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
        sd s8, 224(a0)
    80006056:	0f853023          	sd	s8,224(a0)
        sd s9, 232(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
        sd s10, 240(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
        sd s11, 248(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
        sd t3, 256(a0)
    80006066:	11c53023          	sd	t3,256(a0)
        sd t4, 264(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
        sd t5, 272(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
        sd t6, 280(a0)
    80006072:	11f53c23          	sd	t6,280(a0)

	# save the user a0 in p->trapframe->a0
        csrr t0, sscratch
    80006076:	140022f3          	csrr	t0,sscratch
        sd t0, 112(a0)
    8000607a:	06553823          	sd	t0,112(a0)

        # initialize kernel stack pointer, from p->trapframe->kernel_sp
        ld sp, 8(a0)
    8000607e:	00853103          	ld	sp,8(a0)

        # make tp hold the current hartid, from p->trapframe->kernel_hartid
        ld tp, 32(a0)
    80006082:	02053203          	ld	tp,32(a0)

        # load the address of usertrap(), from p->trapframe->kernel_trap
        ld t0, 16(a0)
    80006086:	01053283          	ld	t0,16(a0)

        # fetch the kernel page table address, from p->trapframe->kernel_satp.
        ld t1, 0(a0)
    8000608a:	00053303          	ld	t1,0(a0)

        # wait for any previous memory operations to complete, so that
        # they use the user page table.
        sfence.vma zero, zero
    8000608e:	12000073          	sfence.vma

        # install the kernel page table.
        csrw satp, t1
    80006092:	18031073          	csrw	satp,t1

        # flush now-stale user entries from the TLB.
        sfence.vma zero, zero
    80006096:	12000073          	sfence.vma

        # call usertrap()
        jalr t0
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
userret:
        # usertrap() returns here, with user satp in a0.
        # return from kernel to user.

        # switch to the user page table.
        sfence.vma zero, zero
    8000609c:	12000073          	sfence.vma
        csrw satp, a0
    800060a0:	18051073          	csrw	satp,a0
        sfence.vma zero, zero
    800060a4:	12000073          	sfence.vma

        li a0, TRAPFRAME
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1
    800060ae:	0536                	slli	a0,a0,0xd

        # restore all but a0 from TRAPFRAME
        ld ra, 40(a0)
    800060b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        ld sp, 48(a0)
    800060b4:	03053103          	ld	sp,48(a0)
        ld gp, 56(a0)
    800060b8:	03853183          	ld	gp,56(a0)
        ld tp, 64(a0)
    800060bc:	04053203          	ld	tp,64(a0)
        ld t0, 72(a0)
    800060c0:	04853283          	ld	t0,72(a0)
        ld t1, 80(a0)
    800060c4:	05053303          	ld	t1,80(a0)
        ld t2, 88(a0)
    800060c8:	05853383          	ld	t2,88(a0)
        ld s0, 96(a0)
    800060cc:	7120                	ld	s0,96(a0)
        ld s1, 104(a0)
    800060ce:	7524                	ld	s1,104(a0)
        ld a1, 120(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
        ld a2, 128(a0)
    800060d2:	6150                	ld	a2,128(a0)
        ld a3, 136(a0)
    800060d4:	6554                	ld	a3,136(a0)
        ld a4, 144(a0)
    800060d6:	6958                	ld	a4,144(a0)
        ld a5, 152(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
        ld a6, 160(a0)
    800060da:	0a053803          	ld	a6,160(a0)
        ld a7, 168(a0)
    800060de:	0a853883          	ld	a7,168(a0)
        ld s2, 176(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
        ld s3, 184(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
        ld s4, 192(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
        ld s5, 200(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
        ld s6, 208(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
        ld s7, 216(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
        ld s8, 224(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
        ld s9, 232(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
        ld s10, 240(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
        ld s11, 248(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
        ld t3, 256(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
        ld t4, 264(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
        ld t5, 272(a0)
    80006112:	11053f03          	ld	t5,272(a0)
        ld t6, 280(a0)
    80006116:	11853f83          	ld	t6,280(a0)

	# restore user a0
        ld a0, 112(a0)
    8000611a:	7928                	ld	a0,112(a0)
        
        # return to user mode and user pc.
        # usertrapret() set up sstatus and sepc.
        sret
    8000611c:	10200073          	sret
	...

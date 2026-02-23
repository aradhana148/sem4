
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
    80000004:	8a010113          	addi	sp,sp,-1888 # 800078a0 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda47>
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
    8000010a:	0b0020ef          	jal	ra,800021ba <either_copyin>
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
    80000172:	0000f517          	auipc	a0,0xf
    80000176:	72e50513          	addi	a0,a0,1838 # 8000f8a0 <cons>
    8000017a:	1f3000ef          	jal	ra,80000b6c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	0000f497          	auipc	s1,0xf
    80000182:	72248493          	addi	s1,s1,1826 # 8000f8a0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	0000f917          	auipc	s2,0xf
    8000018a:	7b290913          	addi	s2,s2,1970 # 8000f938 <cons+0x98>
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
    800001a4:	660010ef          	jal	ra,80001804 <myproc>
    800001a8:	6a5010ef          	jal	ra,8000204c <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	463010ef          	jal	ra,80001e14 <sleep>
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
    800001ea:	787010ef          	jal	ra,80002170 <either_copyout>
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
    800001fe:	6a650513          	addi	a0,a0,1702 # 8000f8a0 <cons>
    80000202:	203000ef          	jal	ra,80000c04 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	0000f517          	auipc	a0,0xf
    80000210:	69450513          	addi	a0,a0,1684 # 8000f8a0 <cons>
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
    8000023e:	0000f717          	auipc	a4,0xf
    80000242:	6ef72d23          	sw	a5,1786(a4) # 8000f938 <cons+0x98>
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
    8000028c:	61850513          	addi	a0,a0,1560 # 8000f8a0 <cons>
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
    800002aa:	75b010ef          	jal	ra,80002204 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	0000f517          	auipc	a0,0xf
    800002b2:	5f250513          	addi	a0,a0,1522 # 8000f8a0 <cons>
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
    800002d2:	5d270713          	addi	a4,a4,1490 # 8000f8a0 <cons>
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
    800002f8:	5ac78793          	addi	a5,a5,1452 # 8000f8a0 <cons>
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
    80000326:	6167a783          	lw	a5,1558(a5) # 8000f938 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	0000f717          	auipc	a4,0xf
    8000033a:	56a70713          	addi	a4,a4,1386 # 8000f8a0 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	0000f497          	auipc	s1,0xf
    8000034a:	55a48493          	addi	s1,s1,1370 # 8000f8a0 <cons>
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
    80000382:	52270713          	addi	a4,a4,1314 # 8000f8a0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	5af72623          	sw	a5,1452(a4) # 8000f940 <cons+0xa0>
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
    800003b6:	4ee78793          	addi	a5,a5,1262 # 8000f8a0 <cons>
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
    800003da:	56c7a323          	sw	a2,1382(a5) # 8000f93c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	55a50513          	addi	a0,a0,1370 # 8000f938 <cons+0x98>
    800003e6:	27b010ef          	jal	ra,80001e60 <wakeup>
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
    80000400:	4a450513          	addi	a0,a0,1188 # 8000f8a0 <cons>
    80000404:	6e8000ef          	jal	ra,80000aec <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00020797          	auipc	a5,0x20
    80000410:	80478793          	addi	a5,a5,-2044 # 8001fc10 <devsw>
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
    800004fa:	37e7a783          	lw	a5,894(a5) # 80007874 <panicking>
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
    80000538:	41450513          	addi	a0,a0,1044 # 8000f948 <pr>
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
    80000756:	1227a783          	lw	a5,290(a5) # 80007874 <panicking>
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
    80000780:	1cc50513          	addi	a0,a0,460 # 8000f948 <pr>
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
    8000079e:	0d27ad23          	sw	s2,218(a5) # 80007874 <panicking>
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
    800007c0:	0b27aa23          	sw	s2,180(a5) # 80007870 <panicked>
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
    800007da:	17250513          	addi	a0,a0,370 # 8000f948 <pr>
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
    80000826:	13e50513          	addi	a0,a0,318 # 8000f960 <tx_lock>
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
    80000854:	11050513          	addi	a0,a0,272 # 8000f960 <tx_lock>
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
    80000872:	00e48493          	addi	s1,s1,14 # 8000787c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	0ea98993          	addi	s3,s3,234 # 8000f960 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	ffa90913          	addi	s2,s2,-6 # 80007878 <tx_chan>
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
    80000892:	582010ef          	jal	ra,80001e14 <sleep>
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
    800008b6:	0ae50513          	addi	a0,a0,174 # 8000f960 <tx_lock>
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
    800008e4:	f947a783          	lw	a5,-108(a5) # 80007874 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	f867a783          	lw	a5,-122(a5) # 80007870 <panicked>
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
    8000091a:	f5e7a783          	lw	a5,-162(a5) # 80007874 <panicking>
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
    8000096e:	ff650513          	addi	a0,a0,-10 # 8000f960 <tx_lock>
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
    80000984:	fe050513          	addi	a0,a0,-32 # 8000f960 <tx_lock>
    80000988:	27c000ef          	jal	ra,80000c04 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000098c:	54fd                	li	s1,-1
    8000098e:	a831                	j	800009aa <uartintr+0x52>
    tx_busy = 0;
    80000990:	00007797          	auipc	a5,0x7
    80000994:	ee07a623          	sw	zero,-276(a5) # 8000787c <tx_busy>
    wakeup(&tx_chan);
    80000998:	00007517          	auipc	a0,0x7
    8000099c:	ee050513          	addi	a0,a0,-288 # 80007878 <tx_chan>
    800009a0:	4c0010ef          	jal	ra,80001e60 <wakeup>
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
    800009d4:	3e878793          	addi	a5,a5,1000 # 80020db8 <end>
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
    800009f0:	f8c90913          	addi	s2,s2,-116 # 8000f978 <kmem>
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
    80000a7c:	f0050513          	addi	a0,a0,-256 # 8000f978 <kmem>
    80000a80:	06c000ef          	jal	ra,80000aec <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a84:	45c5                	li	a1,17
    80000a86:	05ee                	slli	a1,a1,0x1b
    80000a88:	00020517          	auipc	a0,0x20
    80000a8c:	33050513          	addi	a0,a0,816 # 80020db8 <end>
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
    80000aaa:	ed248493          	addi	s1,s1,-302 # 8000f978 <kmem>
    80000aae:	8526                	mv	a0,s1
    80000ab0:	0bc000ef          	jal	ra,80000b6c <acquire>
  r = kmem.freelist;
    80000ab4:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab6:	c485                	beqz	s1,80000ade <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab8:	609c                	ld	a5,0(s1)
    80000aba:	0000f517          	auipc	a0,0xf
    80000abe:	ebe50513          	addi	a0,a0,-322 # 8000f978 <kmem>
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
    80000ae2:	e9a50513          	addi	a0,a0,-358 # 8000f978 <kmem>
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
    80000b16:	4d3000ef          	jal	ra,800017e8 <mycpu>
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
    80000b44:	4a5000ef          	jal	ra,800017e8 <mycpu>
    80000b48:	5d3c                	lw	a5,120(a0)
    80000b4a:	cb99                	beqz	a5,80000b60 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4c:	49d000ef          	jal	ra,800017e8 <mycpu>
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
    80000b60:	489000ef          	jal	ra,800017e8 <mycpu>
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
    80000b94:	455000ef          	jal	ra,800017e8 <mycpu>
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
    80000bb8:	431000ef          	jal	ra,800017e8 <mycpu>
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
    80000dea:	1ef000ef          	jal	ra,800017d8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dee:	00007717          	auipc	a4,0x7
    80000df2:	a9270713          	addi	a4,a4,-1390 # 80007880 <started>
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
    80000e02:	1d7000ef          	jal	ra,800017d8 <cpuid>
    80000e06:	85aa                	mv	a1,a0
    80000e08:	00006517          	auipc	a0,0x6
    80000e0c:	2a850513          	addi	a0,a0,680 # 800070b0 <digits+0x78>
    80000e10:	eb4ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000e14:	080000ef          	jal	ra,80000e94 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e18:	65e010ef          	jal	ra,80002476 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1c:	658040ef          	jal	ra,80005474 <plicinithart>
  }

  scheduler();        
    80000e20:	65d000ef          	jal	ra,80001c7c <scheduler>
    consoleinit();
    80000e24:	dc8ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000e28:	99fff0ef          	jal	ra,800007c6 <printfinit>
    printf("\n");
    80000e2c:	00006517          	auipc	a0,0x6
    80000e30:	29450513          	addi	a0,a0,660 # 800070c0 <digits+0x88>
    80000e34:	e90ff0ef          	jal	ra,800004c4 <printf>
    printf("xv6 kernel is booting\n");
    80000e38:	00006517          	auipc	a0,0x6
    80000e3c:	26050513          	addi	a0,a0,608 # 80007098 <digits+0x60>
    80000e40:	e84ff0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80000e44:	00006517          	auipc	a0,0x6
    80000e48:	27c50513          	addi	a0,a0,636 # 800070c0 <digits+0x88>
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
    80000e60:	5f2010ef          	jal	ra,80002452 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e64:	612010ef          	jal	ra,80002476 <trapinithart>
    plicinit();      // set up interrupt controller
    80000e68:	5f6040ef          	jal	ra,8000545e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6c:	608040ef          	jal	ra,80005474 <plicinithart>
    binit();         // buffer cache
    80000e70:	5a3010ef          	jal	ra,80002c12 <binit>
    iinit();         // inode table
    80000e74:	316020ef          	jal	ra,8000318a <iinit>
    fileinit();      // file table
    80000e78:	1f6030ef          	jal	ra,8000406e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7c:	6e8040ef          	jal	ra,80005564 <virtio_disk_init>
    userinit();      // first user process
    80000e80:	453000ef          	jal	ra,80001ad2 <userinit>
    __sync_synchronize();
    80000e84:	0ff0000f          	fence
    started = 1;
    80000e88:	4785                	li	a5,1
    80000e8a:	00007717          	auipc	a4,0x7
    80000e8e:	9ef72b23          	sw	a5,-1546(a4) # 80007880 <started>
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
    80000ea2:	9ea7b783          	ld	a5,-1558(a5) # 80007888 <kernel_pagetable>
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
    8000112a:	00006797          	auipc	a5,0x6
    8000112e:	74a7bf23          	sd	a0,1886(a5) # 80007888 <kernel_pagetable>
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
    800014f4:	310000ef          	jal	ra,80001804 <myproc>
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
    800016bc:	0000e497          	auipc	s1,0xe
    800016c0:	70c48493          	addi	s1,s1,1804 # 8000fdc8 <proc>
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
    800016da:	2f2a0a13          	addi	s4,s4,754 # 800159c8 <tickslock>
    char *pa = kalloc();
    800016de:	bbeff0ef          	jal	ra,80000a9c <kalloc>
    800016e2:	862a                	mv	a2,a0
    if(pa == 0)
    800016e4:	c121                	beqz	a0,80001724 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800016e6:	416485b3          	sub	a1,s1,s6
    800016ea:	8591                	srai	a1,a1,0x4
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
    80001708:	17048493          	addi	s1,s1,368
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
    80001750:	24c50513          	addi	a0,a0,588 # 8000f998 <pid_lock>
    80001754:	b98ff0ef          	jal	ra,80000aec <initlock>
  initlock(&wait_lock, "wait_lock");
    80001758:	00006597          	auipc	a1,0x6
    8000175c:	a2858593          	addi	a1,a1,-1496 # 80007180 <digits+0x148>
    80001760:	0000e517          	auipc	a0,0xe
    80001764:	25050513          	addi	a0,a0,592 # 8000f9b0 <wait_lock>
    80001768:	b84ff0ef          	jal	ra,80000aec <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176c:	0000e497          	auipc	s1,0xe
    80001770:	65c48493          	addi	s1,s1,1628 # 8000fdc8 <proc>
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
    80001792:	23a98993          	addi	s3,s3,570 # 800159c8 <tickslock>
      initlock(&p->lock, "proc");
    80001796:	85da                	mv	a1,s6
    80001798:	8526                	mv	a0,s1
    8000179a:	b52ff0ef          	jal	ra,80000aec <initlock>
      p->state = UNUSED;
    8000179e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800017a2:	415487b3          	sub	a5,s1,s5
    800017a6:	8791                	srai	a5,a5,0x4
    800017a8:	000a3703          	ld	a4,0(s4)
    800017ac:	02e787b3          	mul	a5,a5,a4
    800017b0:	2785                	addiw	a5,a5,1
    800017b2:	00d7979b          	slliw	a5,a5,0xd
    800017b6:	40f907b3          	sub	a5,s2,a5
    800017ba:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017bc:	17048493          	addi	s1,s1,368
    800017c0:	fd349be3          	bne	s1,s3,80001796 <procinit+0x66>
  }
}
    800017c4:	70e2                	ld	ra,56(sp)
    800017c6:	7442                	ld	s0,48(sp)
    800017c8:	74a2                	ld	s1,40(sp)
    800017ca:	7902                	ld	s2,32(sp)
    800017cc:	69e2                	ld	s3,24(sp)
    800017ce:	6a42                	ld	s4,16(sp)
    800017d0:	6aa2                	ld	s5,8(sp)
    800017d2:	6b02                	ld	s6,0(sp)
    800017d4:	6121                	addi	sp,sp,64
    800017d6:	8082                	ret

00000000800017d8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800017d8:	1141                	addi	sp,sp,-16
    800017da:	e422                	sd	s0,8(sp)
    800017dc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800017de:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800017e0:	2501                	sext.w	a0,a0
    800017e2:	6422                	ld	s0,8(sp)
    800017e4:	0141                	addi	sp,sp,16
    800017e6:	8082                	ret

00000000800017e8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800017e8:	1141                	addi	sp,sp,-16
    800017ea:	e422                	sd	s0,8(sp)
    800017ec:	0800                	addi	s0,sp,16
    800017ee:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800017f0:	2781                	sext.w	a5,a5
    800017f2:	079e                	slli	a5,a5,0x7
  return c;
}
    800017f4:	0000e517          	auipc	a0,0xe
    800017f8:	1d450513          	addi	a0,a0,468 # 8000f9c8 <cpus>
    800017fc:	953e                	add	a0,a0,a5
    800017fe:	6422                	ld	s0,8(sp)
    80001800:	0141                	addi	sp,sp,16
    80001802:	8082                	ret

0000000080001804 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001804:	1101                	addi	sp,sp,-32
    80001806:	ec06                	sd	ra,24(sp)
    80001808:	e822                	sd	s0,16(sp)
    8000180a:	e426                	sd	s1,8(sp)
    8000180c:	1000                	addi	s0,sp,32
  push_off();
    8000180e:	b1eff0ef          	jal	ra,80000b2c <push_off>
    80001812:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001814:	2781                	sext.w	a5,a5
    80001816:	079e                	slli	a5,a5,0x7
    80001818:	0000e717          	auipc	a4,0xe
    8000181c:	18070713          	addi	a4,a4,384 # 8000f998 <pid_lock>
    80001820:	97ba                	add	a5,a5,a4
    80001822:	7b84                	ld	s1,48(a5)
  pop_off();
    80001824:	b8cff0ef          	jal	ra,80000bb0 <pop_off>
  return p;
}
    80001828:	8526                	mv	a0,s1
    8000182a:	60e2                	ld	ra,24(sp)
    8000182c:	6442                	ld	s0,16(sp)
    8000182e:	64a2                	ld	s1,8(sp)
    80001830:	6105                	addi	sp,sp,32
    80001832:	8082                	ret

0000000080001834 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001834:	7179                	addi	sp,sp,-48
    80001836:	f406                	sd	ra,40(sp)
    80001838:	f022                	sd	s0,32(sp)
    8000183a:	ec26                	sd	s1,24(sp)
    8000183c:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000183e:	fc7ff0ef          	jal	ra,80001804 <myproc>
    80001842:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001844:	bc0ff0ef          	jal	ra,80000c04 <release>

  if (first) {
    80001848:	00006797          	auipc	a5,0x6
    8000184c:	0187a783          	lw	a5,24(a5) # 80007860 <first.1>
    80001850:	cf8d                	beqz	a5,8000188a <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001852:	4505                	li	a0,1
    80001854:	5e7010ef          	jal	ra,8000363a <fsinit>

    first = 0;
    80001858:	00006797          	auipc	a5,0x6
    8000185c:	0007a423          	sw	zero,8(a5) # 80007860 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001860:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001864:	00006517          	auipc	a0,0x6
    80001868:	93450513          	addi	a0,a0,-1740 # 80007198 <digits+0x160>
    8000186c:	fca43823          	sd	a0,-48(s0)
    80001870:	fc043c23          	sd	zero,-40(s0)
    80001874:	fd040593          	addi	a1,s0,-48
    80001878:	66b020ef          	jal	ra,800046e2 <kexec>
    8000187c:	6cbc                	ld	a5,88(s1)
    8000187e:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001880:	6cbc                	ld	a5,88(s1)
    80001882:	7bb8                	ld	a4,112(a5)
    80001884:	57fd                	li	a5,-1
    80001886:	02f70d63          	beq	a4,a5,800018c0 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000188a:	405000ef          	jal	ra,8000248e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000188e:	68a8                	ld	a0,80(s1)
    80001890:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001892:	04000737          	lui	a4,0x4000
    80001896:	00005797          	auipc	a5,0x5
    8000189a:	80678793          	addi	a5,a5,-2042 # 8000609c <userret>
    8000189e:	00004697          	auipc	a3,0x4
    800018a2:	76268693          	addi	a3,a3,1890 # 80006000 <_trampoline>
    800018a6:	8f95                	sub	a5,a5,a3
    800018a8:	177d                	addi	a4,a4,-1
    800018aa:	0732                	slli	a4,a4,0xc
    800018ac:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800018ae:	577d                	li	a4,-1
    800018b0:	177e                	slli	a4,a4,0x3f
    800018b2:	8d59                	or	a0,a0,a4
    800018b4:	9782                	jalr	a5
}
    800018b6:	70a2                	ld	ra,40(sp)
    800018b8:	7402                	ld	s0,32(sp)
    800018ba:	64e2                	ld	s1,24(sp)
    800018bc:	6145                	addi	sp,sp,48
    800018be:	8082                	ret
      panic("exec");
    800018c0:	00006517          	auipc	a0,0x6
    800018c4:	8e050513          	addi	a0,a0,-1824 # 800071a0 <digits+0x168>
    800018c8:	ec3fe0ef          	jal	ra,8000078a <panic>

00000000800018cc <allocpid>:
{
    800018cc:	1101                	addi	sp,sp,-32
    800018ce:	ec06                	sd	ra,24(sp)
    800018d0:	e822                	sd	s0,16(sp)
    800018d2:	e426                	sd	s1,8(sp)
    800018d4:	e04a                	sd	s2,0(sp)
    800018d6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018d8:	0000e917          	auipc	s2,0xe
    800018dc:	0c090913          	addi	s2,s2,192 # 8000f998 <pid_lock>
    800018e0:	854a                	mv	a0,s2
    800018e2:	a8aff0ef          	jal	ra,80000b6c <acquire>
  pid = nextpid;
    800018e6:	00006797          	auipc	a5,0x6
    800018ea:	f7e78793          	addi	a5,a5,-130 # 80007864 <nextpid>
    800018ee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018f0:	0014871b          	addiw	a4,s1,1
    800018f4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018f6:	854a                	mv	a0,s2
    800018f8:	b0cff0ef          	jal	ra,80000c04 <release>
}
    800018fc:	8526                	mv	a0,s1
    800018fe:	60e2                	ld	ra,24(sp)
    80001900:	6442                	ld	s0,16(sp)
    80001902:	64a2                	ld	s1,8(sp)
    80001904:	6902                	ld	s2,0(sp)
    80001906:	6105                	addi	sp,sp,32
    80001908:	8082                	ret

000000008000190a <proc_pagetable>:
{
    8000190a:	1101                	addi	sp,sp,-32
    8000190c:	ec06                	sd	ra,24(sp)
    8000190e:	e822                	sd	s0,16(sp)
    80001910:	e426                	sd	s1,8(sp)
    80001912:	e04a                	sd	s2,0(sp)
    80001914:	1000                	addi	s0,sp,32
    80001916:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001918:	823ff0ef          	jal	ra,8000113a <uvmcreate>
    8000191c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000191e:	cd05                	beqz	a0,80001956 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001920:	4729                	li	a4,10
    80001922:	00004697          	auipc	a3,0x4
    80001926:	6de68693          	addi	a3,a3,1758 # 80006000 <_trampoline>
    8000192a:	6605                	lui	a2,0x1
    8000192c:	040005b7          	lui	a1,0x4000
    80001930:	15fd                	addi	a1,a1,-1
    80001932:	05b2                	slli	a1,a1,0xc
    80001934:	e60ff0ef          	jal	ra,80000f94 <mappages>
    80001938:	02054663          	bltz	a0,80001964 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    8000193c:	4719                	li	a4,6
    8000193e:	05893683          	ld	a3,88(s2)
    80001942:	6605                	lui	a2,0x1
    80001944:	020005b7          	lui	a1,0x2000
    80001948:	15fd                	addi	a1,a1,-1
    8000194a:	05b6                	slli	a1,a1,0xd
    8000194c:	8526                	mv	a0,s1
    8000194e:	e46ff0ef          	jal	ra,80000f94 <mappages>
    80001952:	00054f63          	bltz	a0,80001970 <proc_pagetable+0x66>
}
    80001956:	8526                	mv	a0,s1
    80001958:	60e2                	ld	ra,24(sp)
    8000195a:	6442                	ld	s0,16(sp)
    8000195c:	64a2                	ld	s1,8(sp)
    8000195e:	6902                	ld	s2,0(sp)
    80001960:	6105                	addi	sp,sp,32
    80001962:	8082                	ret
    uvmfree(pagetable, 0);
    80001964:	4581                	li	a1,0
    80001966:	8526                	mv	a0,s1
    80001968:	9b1ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    8000196c:	4481                	li	s1,0
    8000196e:	b7e5                	j	80001956 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001970:	4681                	li	a3,0
    80001972:	4605                	li	a2,1
    80001974:	040005b7          	lui	a1,0x4000
    80001978:	15fd                	addi	a1,a1,-1
    8000197a:	05b2                	slli	a1,a1,0xc
    8000197c:	8526                	mv	a0,s1
    8000197e:	fe2ff0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    80001982:	4581                	li	a1,0
    80001984:	8526                	mv	a0,s1
    80001986:	993ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    8000198a:	4481                	li	s1,0
    8000198c:	b7e9                	j	80001956 <proc_pagetable+0x4c>

000000008000198e <proc_freepagetable>:
{
    8000198e:	1101                	addi	sp,sp,-32
    80001990:	ec06                	sd	ra,24(sp)
    80001992:	e822                	sd	s0,16(sp)
    80001994:	e426                	sd	s1,8(sp)
    80001996:	e04a                	sd	s2,0(sp)
    80001998:	1000                	addi	s0,sp,32
    8000199a:	84aa                	mv	s1,a0
    8000199c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000199e:	4681                	li	a3,0
    800019a0:	4605                	li	a2,1
    800019a2:	040005b7          	lui	a1,0x4000
    800019a6:	15fd                	addi	a1,a1,-1
    800019a8:	05b2                	slli	a1,a1,0xc
    800019aa:	fb6ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800019ae:	4681                	li	a3,0
    800019b0:	4605                	li	a2,1
    800019b2:	020005b7          	lui	a1,0x2000
    800019b6:	15fd                	addi	a1,a1,-1
    800019b8:	05b6                	slli	a1,a1,0xd
    800019ba:	8526                	mv	a0,s1
    800019bc:	fa4ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmfree(pagetable, sz);
    800019c0:	85ca                	mv	a1,s2
    800019c2:	8526                	mv	a0,s1
    800019c4:	955ff0ef          	jal	ra,80001318 <uvmfree>
}
    800019c8:	60e2                	ld	ra,24(sp)
    800019ca:	6442                	ld	s0,16(sp)
    800019cc:	64a2                	ld	s1,8(sp)
    800019ce:	6902                	ld	s2,0(sp)
    800019d0:	6105                	addi	sp,sp,32
    800019d2:	8082                	ret

00000000800019d4 <freeproc>:
{
    800019d4:	1101                	addi	sp,sp,-32
    800019d6:	ec06                	sd	ra,24(sp)
    800019d8:	e822                	sd	s0,16(sp)
    800019da:	e426                	sd	s1,8(sp)
    800019dc:	1000                	addi	s0,sp,32
    800019de:	84aa                	mv	s1,a0
  if(p->trapframe)
    800019e0:	6d28                	ld	a0,88(a0)
    800019e2:	c119                	beqz	a0,800019e8 <freeproc+0x14>
    kfree((void*)p->trapframe);
    800019e4:	fd9fe0ef          	jal	ra,800009bc <kfree>
  p->trapframe = 0;
    800019e8:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800019ec:	68a8                	ld	a0,80(s1)
    800019ee:	c501                	beqz	a0,800019f6 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800019f0:	64ac                	ld	a1,72(s1)
    800019f2:	f9dff0ef          	jal	ra,8000198e <proc_freepagetable>
  p->pagetable = 0;
    800019f6:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800019fa:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800019fe:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a02:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a06:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a0a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a0e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a12:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a16:	0004ac23          	sw	zero,24(s1)
  p->shm=0;
    80001a1a:	1604a423          	sw	zero,360(s1)
}
    80001a1e:	60e2                	ld	ra,24(sp)
    80001a20:	6442                	ld	s0,16(sp)
    80001a22:	64a2                	ld	s1,8(sp)
    80001a24:	6105                	addi	sp,sp,32
    80001a26:	8082                	ret

0000000080001a28 <allocproc>:
{
    80001a28:	1101                	addi	sp,sp,-32
    80001a2a:	ec06                	sd	ra,24(sp)
    80001a2c:	e822                	sd	s0,16(sp)
    80001a2e:	e426                	sd	s1,8(sp)
    80001a30:	e04a                	sd	s2,0(sp)
    80001a32:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a34:	0000e497          	auipc	s1,0xe
    80001a38:	39448493          	addi	s1,s1,916 # 8000fdc8 <proc>
    80001a3c:	00014917          	auipc	s2,0x14
    80001a40:	f8c90913          	addi	s2,s2,-116 # 800159c8 <tickslock>
    acquire(&p->lock);
    80001a44:	8526                	mv	a0,s1
    80001a46:	926ff0ef          	jal	ra,80000b6c <acquire>
    if(p->state == UNUSED) {
    80001a4a:	4c9c                	lw	a5,24(s1)
    80001a4c:	cb91                	beqz	a5,80001a60 <allocproc+0x38>
      release(&p->lock);
    80001a4e:	8526                	mv	a0,s1
    80001a50:	9b4ff0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a54:	17048493          	addi	s1,s1,368
    80001a58:	ff2496e3          	bne	s1,s2,80001a44 <allocproc+0x1c>
  return 0;
    80001a5c:	4481                	li	s1,0
    80001a5e:	a099                	j	80001aa4 <allocproc+0x7c>
  p->pid = allocpid();
    80001a60:	e6dff0ef          	jal	ra,800018cc <allocpid>
    80001a64:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001a66:	4785                	li	a5,1
    80001a68:	cc9c                	sw	a5,24(s1)
  p->shm=0;
    80001a6a:	1604a423          	sw	zero,360(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001a6e:	82eff0ef          	jal	ra,80000a9c <kalloc>
    80001a72:	892a                	mv	s2,a0
    80001a74:	eca8                	sd	a0,88(s1)
    80001a76:	cd15                	beqz	a0,80001ab2 <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001a78:	8526                	mv	a0,s1
    80001a7a:	e91ff0ef          	jal	ra,8000190a <proc_pagetable>
    80001a7e:	892a                	mv	s2,a0
    80001a80:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001a82:	c121                	beqz	a0,80001ac2 <allocproc+0x9a>
  memset(&p->context, 0, sizeof(p->context));
    80001a84:	07000613          	li	a2,112
    80001a88:	4581                	li	a1,0
    80001a8a:	06048513          	addi	a0,s1,96
    80001a8e:	9b2ff0ef          	jal	ra,80000c40 <memset>
  p->context.ra = (uint64)forkret;
    80001a92:	00000797          	auipc	a5,0x0
    80001a96:	da278793          	addi	a5,a5,-606 # 80001834 <forkret>
    80001a9a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001a9c:	60bc                	ld	a5,64(s1)
    80001a9e:	6705                	lui	a4,0x1
    80001aa0:	97ba                	add	a5,a5,a4
    80001aa2:	f4bc                	sd	a5,104(s1)
}
    80001aa4:	8526                	mv	a0,s1
    80001aa6:	60e2                	ld	ra,24(sp)
    80001aa8:	6442                	ld	s0,16(sp)
    80001aaa:	64a2                	ld	s1,8(sp)
    80001aac:	6902                	ld	s2,0(sp)
    80001aae:	6105                	addi	sp,sp,32
    80001ab0:	8082                	ret
    freeproc(p);
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	f21ff0ef          	jal	ra,800019d4 <freeproc>
    release(&p->lock);
    80001ab8:	8526                	mv	a0,s1
    80001aba:	94aff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001abe:	84ca                	mv	s1,s2
    80001ac0:	b7d5                	j	80001aa4 <allocproc+0x7c>
    freeproc(p);
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	f11ff0ef          	jal	ra,800019d4 <freeproc>
    release(&p->lock);
    80001ac8:	8526                	mv	a0,s1
    80001aca:	93aff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001ace:	84ca                	mv	s1,s2
    80001ad0:	bfd1                	j	80001aa4 <allocproc+0x7c>

0000000080001ad2 <userinit>:
{
    80001ad2:	1101                	addi	sp,sp,-32
    80001ad4:	ec06                	sd	ra,24(sp)
    80001ad6:	e822                	sd	s0,16(sp)
    80001ad8:	e426                	sd	s1,8(sp)
    80001ada:	1000                	addi	s0,sp,32
  p = allocproc();
    80001adc:	f4dff0ef          	jal	ra,80001a28 <allocproc>
    80001ae0:	84aa                	mv	s1,a0
  initproc = p;
    80001ae2:	00006797          	auipc	a5,0x6
    80001ae6:	daa7b723          	sd	a0,-594(a5) # 80007890 <initproc>
  p->cwd = namei("/");
    80001aea:	00005517          	auipc	a0,0x5
    80001aee:	6be50513          	addi	a0,a0,1726 # 800071a8 <digits+0x170>
    80001af2:	046020ef          	jal	ra,80003b38 <namei>
    80001af6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001afa:	478d                	li	a5,3
    80001afc:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001afe:	8526                	mv	a0,s1
    80001b00:	904ff0ef          	jal	ra,80000c04 <release>
}
    80001b04:	60e2                	ld	ra,24(sp)
    80001b06:	6442                	ld	s0,16(sp)
    80001b08:	64a2                	ld	s1,8(sp)
    80001b0a:	6105                	addi	sp,sp,32
    80001b0c:	8082                	ret

0000000080001b0e <growproc>:
{
    80001b0e:	1101                	addi	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	addi	s0,sp,32
    80001b1a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b1c:	ce9ff0ef          	jal	ra,80001804 <myproc>
    80001b20:	892a                	mv	s2,a0
  sz = p->sz;
    80001b22:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001b24:	02905963          	blez	s1,80001b56 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001b28:	00b48633          	add	a2,s1,a1
    80001b2c:	020007b7          	lui	a5,0x2000
    80001b30:	17fd                	addi	a5,a5,-1
    80001b32:	07b6                	slli	a5,a5,0xd
    80001b34:	02c7ea63          	bltu	a5,a2,80001b68 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001b38:	4691                	li	a3,4
    80001b3a:	6928                	ld	a0,80(a0)
    80001b3c:	ee4ff0ef          	jal	ra,80001220 <uvmalloc>
    80001b40:	85aa                	mv	a1,a0
    80001b42:	c50d                	beqz	a0,80001b6c <growproc+0x5e>
  p->sz = sz;
    80001b44:	04b93423          	sd	a1,72(s2)
  return 0;
    80001b48:	4501                	li	a0,0
}
    80001b4a:	60e2                	ld	ra,24(sp)
    80001b4c:	6442                	ld	s0,16(sp)
    80001b4e:	64a2                	ld	s1,8(sp)
    80001b50:	6902                	ld	s2,0(sp)
    80001b52:	6105                	addi	sp,sp,32
    80001b54:	8082                	ret
  } else if(n < 0){
    80001b56:	fe04d7e3          	bgez	s1,80001b44 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b5a:	00b48633          	add	a2,s1,a1
    80001b5e:	6928                	ld	a0,80(a0)
    80001b60:	e7cff0ef          	jal	ra,800011dc <uvmdealloc>
    80001b64:	85aa                	mv	a1,a0
    80001b66:	bff9                	j	80001b44 <growproc+0x36>
      return -1;
    80001b68:	557d                	li	a0,-1
    80001b6a:	b7c5                	j	80001b4a <growproc+0x3c>
      return -1;
    80001b6c:	557d                	li	a0,-1
    80001b6e:	bff1                	j	80001b4a <growproc+0x3c>

0000000080001b70 <kfork>:
{
    80001b70:	7139                	addi	sp,sp,-64
    80001b72:	fc06                	sd	ra,56(sp)
    80001b74:	f822                	sd	s0,48(sp)
    80001b76:	f426                	sd	s1,40(sp)
    80001b78:	f04a                	sd	s2,32(sp)
    80001b7a:	ec4e                	sd	s3,24(sp)
    80001b7c:	e852                	sd	s4,16(sp)
    80001b7e:	e456                	sd	s5,8(sp)
    80001b80:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001b82:	c83ff0ef          	jal	ra,80001804 <myproc>
    80001b86:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001b88:	ea1ff0ef          	jal	ra,80001a28 <allocproc>
    80001b8c:	0e050663          	beqz	a0,80001c78 <kfork+0x108>
    80001b90:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001b92:	048ab603          	ld	a2,72(s5)
    80001b96:	692c                	ld	a1,80(a0)
    80001b98:	050ab503          	ld	a0,80(s5)
    80001b9c:	facff0ef          	jal	ra,80001348 <uvmcopy>
    80001ba0:	04054863          	bltz	a0,80001bf0 <kfork+0x80>
  np->sz = p->sz;
    80001ba4:	048ab783          	ld	a5,72(s5)
    80001ba8:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001bac:	058ab683          	ld	a3,88(s5)
    80001bb0:	87b6                	mv	a5,a3
    80001bb2:	058a3703          	ld	a4,88(s4)
    80001bb6:	12068693          	addi	a3,a3,288
    80001bba:	0007b803          	ld	a6,0(a5) # 2000000 <_entry-0x7e000000>
    80001bbe:	6788                	ld	a0,8(a5)
    80001bc0:	6b8c                	ld	a1,16(a5)
    80001bc2:	6f90                	ld	a2,24(a5)
    80001bc4:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001bc8:	e708                	sd	a0,8(a4)
    80001bca:	eb0c                	sd	a1,16(a4)
    80001bcc:	ef10                	sd	a2,24(a4)
    80001bce:	02078793          	addi	a5,a5,32
    80001bd2:	02070713          	addi	a4,a4,32
    80001bd6:	fed792e3          	bne	a5,a3,80001bba <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001bda:	058a3783          	ld	a5,88(s4)
    80001bde:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001be2:	0d0a8493          	addi	s1,s5,208
    80001be6:	0d0a0913          	addi	s2,s4,208
    80001bea:	150a8993          	addi	s3,s5,336
    80001bee:	a829                	j	80001c08 <kfork+0x98>
    freeproc(np);
    80001bf0:	8552                	mv	a0,s4
    80001bf2:	de3ff0ef          	jal	ra,800019d4 <freeproc>
    release(&np->lock);
    80001bf6:	8552                	mv	a0,s4
    80001bf8:	80cff0ef          	jal	ra,80000c04 <release>
    return -1;
    80001bfc:	597d                	li	s2,-1
    80001bfe:	a09d                	j	80001c64 <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001c00:	04a1                	addi	s1,s1,8
    80001c02:	0921                	addi	s2,s2,8
    80001c04:	01348963          	beq	s1,s3,80001c16 <kfork+0xa6>
    if(p->ofile[i])
    80001c08:	6088                	ld	a0,0(s1)
    80001c0a:	d97d                	beqz	a0,80001c00 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c0c:	4e4020ef          	jal	ra,800040f0 <filedup>
    80001c10:	00a93023          	sd	a0,0(s2)
    80001c14:	b7f5                	j	80001c00 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001c16:	150ab503          	ld	a0,336(s5)
    80001c1a:	6fa010ef          	jal	ra,80003314 <idup>
    80001c1e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c22:	4641                	li	a2,16
    80001c24:	158a8593          	addi	a1,s5,344
    80001c28:	158a0513          	addi	a0,s4,344
    80001c2c:	95aff0ef          	jal	ra,80000d86 <safestrcpy>
  pid = np->pid;
    80001c30:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001c34:	8552                	mv	a0,s4
    80001c36:	fcffe0ef          	jal	ra,80000c04 <release>
  acquire(&wait_lock);
    80001c3a:	0000e497          	auipc	s1,0xe
    80001c3e:	d7648493          	addi	s1,s1,-650 # 8000f9b0 <wait_lock>
    80001c42:	8526                	mv	a0,s1
    80001c44:	f29fe0ef          	jal	ra,80000b6c <acquire>
  np->parent = p;
    80001c48:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	fb7fe0ef          	jal	ra,80000c04 <release>
  acquire(&np->lock);
    80001c52:	8552                	mv	a0,s4
    80001c54:	f19fe0ef          	jal	ra,80000b6c <acquire>
  np->state = RUNNABLE;
    80001c58:	478d                	li	a5,3
    80001c5a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001c5e:	8552                	mv	a0,s4
    80001c60:	fa5fe0ef          	jal	ra,80000c04 <release>
}
    80001c64:	854a                	mv	a0,s2
    80001c66:	70e2                	ld	ra,56(sp)
    80001c68:	7442                	ld	s0,48(sp)
    80001c6a:	74a2                	ld	s1,40(sp)
    80001c6c:	7902                	ld	s2,32(sp)
    80001c6e:	69e2                	ld	s3,24(sp)
    80001c70:	6a42                	ld	s4,16(sp)
    80001c72:	6aa2                	ld	s5,8(sp)
    80001c74:	6121                	addi	sp,sp,64
    80001c76:	8082                	ret
    return -1;
    80001c78:	597d                	li	s2,-1
    80001c7a:	b7ed                	j	80001c64 <kfork+0xf4>

0000000080001c7c <scheduler>:
{
    80001c7c:	715d                	addi	sp,sp,-80
    80001c7e:	e486                	sd	ra,72(sp)
    80001c80:	e0a2                	sd	s0,64(sp)
    80001c82:	fc26                	sd	s1,56(sp)
    80001c84:	f84a                	sd	s2,48(sp)
    80001c86:	f44e                	sd	s3,40(sp)
    80001c88:	f052                	sd	s4,32(sp)
    80001c8a:	ec56                	sd	s5,24(sp)
    80001c8c:	e85a                	sd	s6,16(sp)
    80001c8e:	e45e                	sd	s7,8(sp)
    80001c90:	e062                	sd	s8,0(sp)
    80001c92:	0880                	addi	s0,sp,80
    80001c94:	8792                	mv	a5,tp
  int id = r_tp();
    80001c96:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001c98:	00779b13          	slli	s6,a5,0x7
    80001c9c:	0000e717          	auipc	a4,0xe
    80001ca0:	cfc70713          	addi	a4,a4,-772 # 8000f998 <pid_lock>
    80001ca4:	975a                	add	a4,a4,s6
    80001ca6:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001caa:	0000e717          	auipc	a4,0xe
    80001cae:	d2670713          	addi	a4,a4,-730 # 8000f9d0 <cpus+0x8>
    80001cb2:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001cb4:	4c11                	li	s8,4
        c->proc = p;
    80001cb6:	079e                	slli	a5,a5,0x7
    80001cb8:	0000ea17          	auipc	s4,0xe
    80001cbc:	ce0a0a13          	addi	s4,s4,-800 # 8000f998 <pid_lock>
    80001cc0:	9a3e                	add	s4,s4,a5
        found = 1;
    80001cc2:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cc4:	00014997          	auipc	s3,0x14
    80001cc8:	d0498993          	addi	s3,s3,-764 # 800159c8 <tickslock>
    80001ccc:	a83d                	j	80001d0a <scheduler+0x8e>
      release(&p->lock);
    80001cce:	8526                	mv	a0,s1
    80001cd0:	f35fe0ef          	jal	ra,80000c04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cd4:	17048493          	addi	s1,s1,368
    80001cd8:	03348563          	beq	s1,s3,80001d02 <scheduler+0x86>
      acquire(&p->lock);
    80001cdc:	8526                	mv	a0,s1
    80001cde:	e8ffe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == RUNNABLE) {
    80001ce2:	4c9c                	lw	a5,24(s1)
    80001ce4:	ff2795e3          	bne	a5,s2,80001cce <scheduler+0x52>
        p->state = RUNNING;
    80001ce8:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001cec:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001cf0:	06048593          	addi	a1,s1,96
    80001cf4:	855a                	mv	a0,s6
    80001cf6:	6f2000ef          	jal	ra,800023e8 <swtch>
        c->proc = 0;
    80001cfa:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001cfe:	8ade                	mv	s5,s7
    80001d00:	b7f9                	j	80001cce <scheduler+0x52>
    if(found == 0) {
    80001d02:	000a9463          	bnez	s5,80001d0a <scheduler+0x8e>
      asm volatile("wfi");
    80001d06:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d0a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d0e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d12:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d16:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001d1a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d1c:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001d20:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d22:	0000e497          	auipc	s1,0xe
    80001d26:	0a648493          	addi	s1,s1,166 # 8000fdc8 <proc>
      if(p->state == RUNNABLE) {
    80001d2a:	490d                	li	s2,3
    80001d2c:	bf45                	j	80001cdc <scheduler+0x60>

0000000080001d2e <sched>:
{
    80001d2e:	7179                	addi	sp,sp,-48
    80001d30:	f406                	sd	ra,40(sp)
    80001d32:	f022                	sd	s0,32(sp)
    80001d34:	ec26                	sd	s1,24(sp)
    80001d36:	e84a                	sd	s2,16(sp)
    80001d38:	e44e                	sd	s3,8(sp)
    80001d3a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d3c:	ac9ff0ef          	jal	ra,80001804 <myproc>
    80001d40:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001d42:	dc1fe0ef          	jal	ra,80000b02 <holding>
    80001d46:	c92d                	beqz	a0,80001db8 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d48:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001d4a:	2781                	sext.w	a5,a5
    80001d4c:	079e                	slli	a5,a5,0x7
    80001d4e:	0000e717          	auipc	a4,0xe
    80001d52:	c4a70713          	addi	a4,a4,-950 # 8000f998 <pid_lock>
    80001d56:	97ba                	add	a5,a5,a4
    80001d58:	0a87a703          	lw	a4,168(a5)
    80001d5c:	4785                	li	a5,1
    80001d5e:	06f71363          	bne	a4,a5,80001dc4 <sched+0x96>
  if(p->state == RUNNING)
    80001d62:	4c98                	lw	a4,24(s1)
    80001d64:	4791                	li	a5,4
    80001d66:	06f70563          	beq	a4,a5,80001dd0 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d6a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001d6e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001d70:	e7b5                	bnez	a5,80001ddc <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d72:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001d74:	0000e917          	auipc	s2,0xe
    80001d78:	c2490913          	addi	s2,s2,-988 # 8000f998 <pid_lock>
    80001d7c:	2781                	sext.w	a5,a5
    80001d7e:	079e                	slli	a5,a5,0x7
    80001d80:	97ca                	add	a5,a5,s2
    80001d82:	0ac7a983          	lw	s3,172(a5)
    80001d86:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001d88:	2781                	sext.w	a5,a5
    80001d8a:	079e                	slli	a5,a5,0x7
    80001d8c:	0000e597          	auipc	a1,0xe
    80001d90:	c4458593          	addi	a1,a1,-956 # 8000f9d0 <cpus+0x8>
    80001d94:	95be                	add	a1,a1,a5
    80001d96:	06048513          	addi	a0,s1,96
    80001d9a:	64e000ef          	jal	ra,800023e8 <swtch>
    80001d9e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001da0:	2781                	sext.w	a5,a5
    80001da2:	079e                	slli	a5,a5,0x7
    80001da4:	97ca                	add	a5,a5,s2
    80001da6:	0b37a623          	sw	s3,172(a5)
}
    80001daa:	70a2                	ld	ra,40(sp)
    80001dac:	7402                	ld	s0,32(sp)
    80001dae:	64e2                	ld	s1,24(sp)
    80001db0:	6942                	ld	s2,16(sp)
    80001db2:	69a2                	ld	s3,8(sp)
    80001db4:	6145                	addi	sp,sp,48
    80001db6:	8082                	ret
    panic("sched p->lock");
    80001db8:	00005517          	auipc	a0,0x5
    80001dbc:	3f850513          	addi	a0,a0,1016 # 800071b0 <digits+0x178>
    80001dc0:	9cbfe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    80001dc4:	00005517          	auipc	a0,0x5
    80001dc8:	3fc50513          	addi	a0,a0,1020 # 800071c0 <digits+0x188>
    80001dcc:	9bffe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    80001dd0:	00005517          	auipc	a0,0x5
    80001dd4:	40050513          	addi	a0,a0,1024 # 800071d0 <digits+0x198>
    80001dd8:	9b3fe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    80001ddc:	00005517          	auipc	a0,0x5
    80001de0:	40450513          	addi	a0,a0,1028 # 800071e0 <digits+0x1a8>
    80001de4:	9a7fe0ef          	jal	ra,8000078a <panic>

0000000080001de8 <yield>:
{
    80001de8:	1101                	addi	sp,sp,-32
    80001dea:	ec06                	sd	ra,24(sp)
    80001dec:	e822                	sd	s0,16(sp)
    80001dee:	e426                	sd	s1,8(sp)
    80001df0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001df2:	a13ff0ef          	jal	ra,80001804 <myproc>
    80001df6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001df8:	d75fe0ef          	jal	ra,80000b6c <acquire>
  p->state = RUNNABLE;
    80001dfc:	478d                	li	a5,3
    80001dfe:	cc9c                	sw	a5,24(s1)
  sched();
    80001e00:	f2fff0ef          	jal	ra,80001d2e <sched>
  release(&p->lock);
    80001e04:	8526                	mv	a0,s1
    80001e06:	dfffe0ef          	jal	ra,80000c04 <release>
}
    80001e0a:	60e2                	ld	ra,24(sp)
    80001e0c:	6442                	ld	s0,16(sp)
    80001e0e:	64a2                	ld	s1,8(sp)
    80001e10:	6105                	addi	sp,sp,32
    80001e12:	8082                	ret

0000000080001e14 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001e14:	7179                	addi	sp,sp,-48
    80001e16:	f406                	sd	ra,40(sp)
    80001e18:	f022                	sd	s0,32(sp)
    80001e1a:	ec26                	sd	s1,24(sp)
    80001e1c:	e84a                	sd	s2,16(sp)
    80001e1e:	e44e                	sd	s3,8(sp)
    80001e20:	1800                	addi	s0,sp,48
    80001e22:	89aa                	mv	s3,a0
    80001e24:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e26:	9dfff0ef          	jal	ra,80001804 <myproc>
    80001e2a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001e2c:	d41fe0ef          	jal	ra,80000b6c <acquire>
  release(lk);
    80001e30:	854a                	mv	a0,s2
    80001e32:	dd3fe0ef          	jal	ra,80000c04 <release>

  // Go to sleep.
  p->chan = chan;
    80001e36:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001e3a:	4789                	li	a5,2
    80001e3c:	cc9c                	sw	a5,24(s1)

  sched();
    80001e3e:	ef1ff0ef          	jal	ra,80001d2e <sched>

  // Tidy up.
  p->chan = 0;
    80001e42:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001e46:	8526                	mv	a0,s1
    80001e48:	dbdfe0ef          	jal	ra,80000c04 <release>
  acquire(lk);
    80001e4c:	854a                	mv	a0,s2
    80001e4e:	d1ffe0ef          	jal	ra,80000b6c <acquire>
}
    80001e52:	70a2                	ld	ra,40(sp)
    80001e54:	7402                	ld	s0,32(sp)
    80001e56:	64e2                	ld	s1,24(sp)
    80001e58:	6942                	ld	s2,16(sp)
    80001e5a:	69a2                	ld	s3,8(sp)
    80001e5c:	6145                	addi	sp,sp,48
    80001e5e:	8082                	ret

0000000080001e60 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001e60:	7139                	addi	sp,sp,-64
    80001e62:	fc06                	sd	ra,56(sp)
    80001e64:	f822                	sd	s0,48(sp)
    80001e66:	f426                	sd	s1,40(sp)
    80001e68:	f04a                	sd	s2,32(sp)
    80001e6a:	ec4e                	sd	s3,24(sp)
    80001e6c:	e852                	sd	s4,16(sp)
    80001e6e:	e456                	sd	s5,8(sp)
    80001e70:	0080                	addi	s0,sp,64
    80001e72:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001e74:	0000e497          	auipc	s1,0xe
    80001e78:	f5448493          	addi	s1,s1,-172 # 8000fdc8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001e7c:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001e7e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e80:	00014917          	auipc	s2,0x14
    80001e84:	b4890913          	addi	s2,s2,-1208 # 800159c8 <tickslock>
    80001e88:	a801                	j	80001e98 <wakeup+0x38>
      }
      release(&p->lock);
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	d79fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e90:	17048493          	addi	s1,s1,368
    80001e94:	03248263          	beq	s1,s2,80001eb8 <wakeup+0x58>
    if(p != myproc()){
    80001e98:	96dff0ef          	jal	ra,80001804 <myproc>
    80001e9c:	fea48ae3          	beq	s1,a0,80001e90 <wakeup+0x30>
      acquire(&p->lock);
    80001ea0:	8526                	mv	a0,s1
    80001ea2:	ccbfe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001ea6:	4c9c                	lw	a5,24(s1)
    80001ea8:	ff3791e3          	bne	a5,s3,80001e8a <wakeup+0x2a>
    80001eac:	709c                	ld	a5,32(s1)
    80001eae:	fd479ee3          	bne	a5,s4,80001e8a <wakeup+0x2a>
        p->state = RUNNABLE;
    80001eb2:	0154ac23          	sw	s5,24(s1)
    80001eb6:	bfd1                	j	80001e8a <wakeup+0x2a>
    }
  }
}
    80001eb8:	70e2                	ld	ra,56(sp)
    80001eba:	7442                	ld	s0,48(sp)
    80001ebc:	74a2                	ld	s1,40(sp)
    80001ebe:	7902                	ld	s2,32(sp)
    80001ec0:	69e2                	ld	s3,24(sp)
    80001ec2:	6a42                	ld	s4,16(sp)
    80001ec4:	6aa2                	ld	s5,8(sp)
    80001ec6:	6121                	addi	sp,sp,64
    80001ec8:	8082                	ret

0000000080001eca <reparent>:
{
    80001eca:	7179                	addi	sp,sp,-48
    80001ecc:	f406                	sd	ra,40(sp)
    80001ece:	f022                	sd	s0,32(sp)
    80001ed0:	ec26                	sd	s1,24(sp)
    80001ed2:	e84a                	sd	s2,16(sp)
    80001ed4:	e44e                	sd	s3,8(sp)
    80001ed6:	e052                	sd	s4,0(sp)
    80001ed8:	1800                	addi	s0,sp,48
    80001eda:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001edc:	0000e497          	auipc	s1,0xe
    80001ee0:	eec48493          	addi	s1,s1,-276 # 8000fdc8 <proc>
      pp->parent = initproc;
    80001ee4:	00006a17          	auipc	s4,0x6
    80001ee8:	9aca0a13          	addi	s4,s4,-1620 # 80007890 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001eec:	00014997          	auipc	s3,0x14
    80001ef0:	adc98993          	addi	s3,s3,-1316 # 800159c8 <tickslock>
    80001ef4:	a029                	j	80001efe <reparent+0x34>
    80001ef6:	17048493          	addi	s1,s1,368
    80001efa:	01348b63          	beq	s1,s3,80001f10 <reparent+0x46>
    if(pp->parent == p){
    80001efe:	7c9c                	ld	a5,56(s1)
    80001f00:	ff279be3          	bne	a5,s2,80001ef6 <reparent+0x2c>
      pp->parent = initproc;
    80001f04:	000a3503          	ld	a0,0(s4)
    80001f08:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001f0a:	f57ff0ef          	jal	ra,80001e60 <wakeup>
    80001f0e:	b7e5                	j	80001ef6 <reparent+0x2c>
}
    80001f10:	70a2                	ld	ra,40(sp)
    80001f12:	7402                	ld	s0,32(sp)
    80001f14:	64e2                	ld	s1,24(sp)
    80001f16:	6942                	ld	s2,16(sp)
    80001f18:	69a2                	ld	s3,8(sp)
    80001f1a:	6a02                	ld	s4,0(sp)
    80001f1c:	6145                	addi	sp,sp,48
    80001f1e:	8082                	ret

0000000080001f20 <kexit>:
{
    80001f20:	7179                	addi	sp,sp,-48
    80001f22:	f406                	sd	ra,40(sp)
    80001f24:	f022                	sd	s0,32(sp)
    80001f26:	ec26                	sd	s1,24(sp)
    80001f28:	e84a                	sd	s2,16(sp)
    80001f2a:	e44e                	sd	s3,8(sp)
    80001f2c:	e052                	sd	s4,0(sp)
    80001f2e:	1800                	addi	s0,sp,48
    80001f30:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001f32:	8d3ff0ef          	jal	ra,80001804 <myproc>
    80001f36:	89aa                	mv	s3,a0
  if(p == initproc)
    80001f38:	00006797          	auipc	a5,0x6
    80001f3c:	9587b783          	ld	a5,-1704(a5) # 80007890 <initproc>
    80001f40:	0d050493          	addi	s1,a0,208
    80001f44:	15050913          	addi	s2,a0,336
    80001f48:	00a79f63          	bne	a5,a0,80001f66 <kexit+0x46>
    panic("init exiting");
    80001f4c:	00005517          	auipc	a0,0x5
    80001f50:	2ac50513          	addi	a0,a0,684 # 800071f8 <digits+0x1c0>
    80001f54:	837fe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    80001f58:	1de020ef          	jal	ra,80004136 <fileclose>
      p->ofile[fd] = 0;
    80001f5c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001f60:	04a1                	addi	s1,s1,8
    80001f62:	01248563          	beq	s1,s2,80001f6c <kexit+0x4c>
    if(p->ofile[fd]){
    80001f66:	6088                	ld	a0,0(s1)
    80001f68:	f965                	bnez	a0,80001f58 <kexit+0x38>
    80001f6a:	bfdd                	j	80001f60 <kexit+0x40>
  begin_op();
    80001f6c:	5bd010ef          	jal	ra,80003d28 <begin_op>
  iput(p->cwd);
    80001f70:	1509b503          	ld	a0,336(s3)
    80001f74:	554010ef          	jal	ra,800034c8 <iput>
  end_op();
    80001f78:	621010ef          	jal	ra,80003d98 <end_op>
  p->cwd = 0;
    80001f7c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001f80:	0000e497          	auipc	s1,0xe
    80001f84:	a3048493          	addi	s1,s1,-1488 # 8000f9b0 <wait_lock>
    80001f88:	8526                	mv	a0,s1
    80001f8a:	be3fe0ef          	jal	ra,80000b6c <acquire>
  reparent(p);
    80001f8e:	854e                	mv	a0,s3
    80001f90:	f3bff0ef          	jal	ra,80001eca <reparent>
  wakeup(p->parent);
    80001f94:	0389b503          	ld	a0,56(s3)
    80001f98:	ec9ff0ef          	jal	ra,80001e60 <wakeup>
  acquire(&p->lock);
    80001f9c:	854e                	mv	a0,s3
    80001f9e:	bcffe0ef          	jal	ra,80000b6c <acquire>
  p->xstate = status;
    80001fa2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001fa6:	4795                	li	a5,5
    80001fa8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001fac:	8526                	mv	a0,s1
    80001fae:	c57fe0ef          	jal	ra,80000c04 <release>
  sched();
    80001fb2:	d7dff0ef          	jal	ra,80001d2e <sched>
  panic("zombie exit");
    80001fb6:	00005517          	auipc	a0,0x5
    80001fba:	25250513          	addi	a0,a0,594 # 80007208 <digits+0x1d0>
    80001fbe:	fccfe0ef          	jal	ra,8000078a <panic>

0000000080001fc2 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80001fc2:	7179                	addi	sp,sp,-48
    80001fc4:	f406                	sd	ra,40(sp)
    80001fc6:	f022                	sd	s0,32(sp)
    80001fc8:	ec26                	sd	s1,24(sp)
    80001fca:	e84a                	sd	s2,16(sp)
    80001fcc:	e44e                	sd	s3,8(sp)
    80001fce:	1800                	addi	s0,sp,48
    80001fd0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001fd2:	0000e497          	auipc	s1,0xe
    80001fd6:	df648493          	addi	s1,s1,-522 # 8000fdc8 <proc>
    80001fda:	00014997          	auipc	s3,0x14
    80001fde:	9ee98993          	addi	s3,s3,-1554 # 800159c8 <tickslock>
    acquire(&p->lock);
    80001fe2:	8526                	mv	a0,s1
    80001fe4:	b89fe0ef          	jal	ra,80000b6c <acquire>
    if(p->pid == pid){
    80001fe8:	589c                	lw	a5,48(s1)
    80001fea:	01278b63          	beq	a5,s2,80002000 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001fee:	8526                	mv	a0,s1
    80001ff0:	c15fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001ff4:	17048493          	addi	s1,s1,368
    80001ff8:	ff3495e3          	bne	s1,s3,80001fe2 <kkill+0x20>
  }
  return -1;
    80001ffc:	557d                	li	a0,-1
    80001ffe:	a819                	j	80002014 <kkill+0x52>
      p->killed = 1;
    80002000:	4785                	li	a5,1
    80002002:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002004:	4c98                	lw	a4,24(s1)
    80002006:	4789                	li	a5,2
    80002008:	00f70d63          	beq	a4,a5,80002022 <kkill+0x60>
      release(&p->lock);
    8000200c:	8526                	mv	a0,s1
    8000200e:	bf7fe0ef          	jal	ra,80000c04 <release>
      return 0;
    80002012:	4501                	li	a0,0
}
    80002014:	70a2                	ld	ra,40(sp)
    80002016:	7402                	ld	s0,32(sp)
    80002018:	64e2                	ld	s1,24(sp)
    8000201a:	6942                	ld	s2,16(sp)
    8000201c:	69a2                	ld	s3,8(sp)
    8000201e:	6145                	addi	sp,sp,48
    80002020:	8082                	ret
        p->state = RUNNABLE;
    80002022:	478d                	li	a5,3
    80002024:	cc9c                	sw	a5,24(s1)
    80002026:	b7dd                	j	8000200c <kkill+0x4a>

0000000080002028 <setkilled>:

void
setkilled(struct proc *p)
{
    80002028:	1101                	addi	sp,sp,-32
    8000202a:	ec06                	sd	ra,24(sp)
    8000202c:	e822                	sd	s0,16(sp)
    8000202e:	e426                	sd	s1,8(sp)
    80002030:	1000                	addi	s0,sp,32
    80002032:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002034:	b39fe0ef          	jal	ra,80000b6c <acquire>
  p->killed = 1;
    80002038:	4785                	li	a5,1
    8000203a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000203c:	8526                	mv	a0,s1
    8000203e:	bc7fe0ef          	jal	ra,80000c04 <release>
}
    80002042:	60e2                	ld	ra,24(sp)
    80002044:	6442                	ld	s0,16(sp)
    80002046:	64a2                	ld	s1,8(sp)
    80002048:	6105                	addi	sp,sp,32
    8000204a:	8082                	ret

000000008000204c <killed>:

int
killed(struct proc *p)
{
    8000204c:	1101                	addi	sp,sp,-32
    8000204e:	ec06                	sd	ra,24(sp)
    80002050:	e822                	sd	s0,16(sp)
    80002052:	e426                	sd	s1,8(sp)
    80002054:	e04a                	sd	s2,0(sp)
    80002056:	1000                	addi	s0,sp,32
    80002058:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000205a:	b13fe0ef          	jal	ra,80000b6c <acquire>
  k = p->killed;
    8000205e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002062:	8526                	mv	a0,s1
    80002064:	ba1fe0ef          	jal	ra,80000c04 <release>
  return k;
}
    80002068:	854a                	mv	a0,s2
    8000206a:	60e2                	ld	ra,24(sp)
    8000206c:	6442                	ld	s0,16(sp)
    8000206e:	64a2                	ld	s1,8(sp)
    80002070:	6902                	ld	s2,0(sp)
    80002072:	6105                	addi	sp,sp,32
    80002074:	8082                	ret

0000000080002076 <kwait>:
{
    80002076:	715d                	addi	sp,sp,-80
    80002078:	e486                	sd	ra,72(sp)
    8000207a:	e0a2                	sd	s0,64(sp)
    8000207c:	fc26                	sd	s1,56(sp)
    8000207e:	f84a                	sd	s2,48(sp)
    80002080:	f44e                	sd	s3,40(sp)
    80002082:	f052                	sd	s4,32(sp)
    80002084:	ec56                	sd	s5,24(sp)
    80002086:	e85a                	sd	s6,16(sp)
    80002088:	e45e                	sd	s7,8(sp)
    8000208a:	e062                	sd	s8,0(sp)
    8000208c:	0880                	addi	s0,sp,80
    8000208e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002090:	f74ff0ef          	jal	ra,80001804 <myproc>
    80002094:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002096:	0000e517          	auipc	a0,0xe
    8000209a:	91a50513          	addi	a0,a0,-1766 # 8000f9b0 <wait_lock>
    8000209e:	acffe0ef          	jal	ra,80000b6c <acquire>
    havekids = 0;
    800020a2:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800020a4:	4a15                	li	s4,5
        havekids = 1;
    800020a6:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800020a8:	00014997          	auipc	s3,0x14
    800020ac:	92098993          	addi	s3,s3,-1760 # 800159c8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800020b0:	0000ec17          	auipc	s8,0xe
    800020b4:	900c0c13          	addi	s8,s8,-1792 # 8000f9b0 <wait_lock>
    havekids = 0;
    800020b8:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800020ba:	0000e497          	auipc	s1,0xe
    800020be:	d0e48493          	addi	s1,s1,-754 # 8000fdc8 <proc>
    800020c2:	a899                	j	80002118 <kwait+0xa2>
          pid = pp->pid;
    800020c4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800020c8:	000b0c63          	beqz	s6,800020e0 <kwait+0x6a>
    800020cc:	4691                	li	a3,4
    800020ce:	02c48613          	addi	a2,s1,44
    800020d2:	85da                	mv	a1,s6
    800020d4:	05093503          	ld	a0,80(s2)
    800020d8:	c7aff0ef          	jal	ra,80001552 <copyout>
    800020dc:	00054f63          	bltz	a0,800020fa <kwait+0x84>
          freeproc(pp);
    800020e0:	8526                	mv	a0,s1
    800020e2:	8f3ff0ef          	jal	ra,800019d4 <freeproc>
          release(&pp->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	b1dfe0ef          	jal	ra,80000c04 <release>
          release(&wait_lock);
    800020ec:	0000e517          	auipc	a0,0xe
    800020f0:	8c450513          	addi	a0,a0,-1852 # 8000f9b0 <wait_lock>
    800020f4:	b11fe0ef          	jal	ra,80000c04 <release>
          return pid;
    800020f8:	a891                	j	8000214c <kwait+0xd6>
            release(&pp->lock);
    800020fa:	8526                	mv	a0,s1
    800020fc:	b09fe0ef          	jal	ra,80000c04 <release>
            release(&wait_lock);
    80002100:	0000e517          	auipc	a0,0xe
    80002104:	8b050513          	addi	a0,a0,-1872 # 8000f9b0 <wait_lock>
    80002108:	afdfe0ef          	jal	ra,80000c04 <release>
            return -1;
    8000210c:	59fd                	li	s3,-1
    8000210e:	a83d                	j	8000214c <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002110:	17048493          	addi	s1,s1,368
    80002114:	03348063          	beq	s1,s3,80002134 <kwait+0xbe>
      if(pp->parent == p){
    80002118:	7c9c                	ld	a5,56(s1)
    8000211a:	ff279be3          	bne	a5,s2,80002110 <kwait+0x9a>
        acquire(&pp->lock);
    8000211e:	8526                	mv	a0,s1
    80002120:	a4dfe0ef          	jal	ra,80000b6c <acquire>
        if(pp->state == ZOMBIE){
    80002124:	4c9c                	lw	a5,24(s1)
    80002126:	f9478fe3          	beq	a5,s4,800020c4 <kwait+0x4e>
        release(&pp->lock);
    8000212a:	8526                	mv	a0,s1
    8000212c:	ad9fe0ef          	jal	ra,80000c04 <release>
        havekids = 1;
    80002130:	8756                	mv	a4,s5
    80002132:	bff9                	j	80002110 <kwait+0x9a>
    if(!havekids || killed(p)){
    80002134:	c709                	beqz	a4,8000213e <kwait+0xc8>
    80002136:	854a                	mv	a0,s2
    80002138:	f15ff0ef          	jal	ra,8000204c <killed>
    8000213c:	c50d                	beqz	a0,80002166 <kwait+0xf0>
      release(&wait_lock);
    8000213e:	0000e517          	auipc	a0,0xe
    80002142:	87250513          	addi	a0,a0,-1934 # 8000f9b0 <wait_lock>
    80002146:	abffe0ef          	jal	ra,80000c04 <release>
      return -1;
    8000214a:	59fd                	li	s3,-1
}
    8000214c:	854e                	mv	a0,s3
    8000214e:	60a6                	ld	ra,72(sp)
    80002150:	6406                	ld	s0,64(sp)
    80002152:	74e2                	ld	s1,56(sp)
    80002154:	7942                	ld	s2,48(sp)
    80002156:	79a2                	ld	s3,40(sp)
    80002158:	7a02                	ld	s4,32(sp)
    8000215a:	6ae2                	ld	s5,24(sp)
    8000215c:	6b42                	ld	s6,16(sp)
    8000215e:	6ba2                	ld	s7,8(sp)
    80002160:	6c02                	ld	s8,0(sp)
    80002162:	6161                	addi	sp,sp,80
    80002164:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002166:	85e2                	mv	a1,s8
    80002168:	854a                	mv	a0,s2
    8000216a:	cabff0ef          	jal	ra,80001e14 <sleep>
    havekids = 0;
    8000216e:	b7a9                	j	800020b8 <kwait+0x42>

0000000080002170 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002170:	7179                	addi	sp,sp,-48
    80002172:	f406                	sd	ra,40(sp)
    80002174:	f022                	sd	s0,32(sp)
    80002176:	ec26                	sd	s1,24(sp)
    80002178:	e84a                	sd	s2,16(sp)
    8000217a:	e44e                	sd	s3,8(sp)
    8000217c:	e052                	sd	s4,0(sp)
    8000217e:	1800                	addi	s0,sp,48
    80002180:	84aa                	mv	s1,a0
    80002182:	892e                	mv	s2,a1
    80002184:	89b2                	mv	s3,a2
    80002186:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002188:	e7cff0ef          	jal	ra,80001804 <myproc>
  if(user_dst){
    8000218c:	cc99                	beqz	s1,800021aa <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000218e:	86d2                	mv	a3,s4
    80002190:	864e                	mv	a2,s3
    80002192:	85ca                	mv	a1,s2
    80002194:	6928                	ld	a0,80(a0)
    80002196:	bbcff0ef          	jal	ra,80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000219a:	70a2                	ld	ra,40(sp)
    8000219c:	7402                	ld	s0,32(sp)
    8000219e:	64e2                	ld	s1,24(sp)
    800021a0:	6942                	ld	s2,16(sp)
    800021a2:	69a2                	ld	s3,8(sp)
    800021a4:	6a02                	ld	s4,0(sp)
    800021a6:	6145                	addi	sp,sp,48
    800021a8:	8082                	ret
    memmove((char *)dst, src, len);
    800021aa:	000a061b          	sext.w	a2,s4
    800021ae:	85ce                	mv	a1,s3
    800021b0:	854a                	mv	a0,s2
    800021b2:	aebfe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    800021b6:	8526                	mv	a0,s1
    800021b8:	b7cd                	j	8000219a <either_copyout+0x2a>

00000000800021ba <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800021ba:	7179                	addi	sp,sp,-48
    800021bc:	f406                	sd	ra,40(sp)
    800021be:	f022                	sd	s0,32(sp)
    800021c0:	ec26                	sd	s1,24(sp)
    800021c2:	e84a                	sd	s2,16(sp)
    800021c4:	e44e                	sd	s3,8(sp)
    800021c6:	e052                	sd	s4,0(sp)
    800021c8:	1800                	addi	s0,sp,48
    800021ca:	892a                	mv	s2,a0
    800021cc:	84ae                	mv	s1,a1
    800021ce:	89b2                	mv	s3,a2
    800021d0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800021d2:	e32ff0ef          	jal	ra,80001804 <myproc>
  if(user_src){
    800021d6:	cc99                	beqz	s1,800021f4 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800021d8:	86d2                	mv	a3,s4
    800021da:	864e                	mv	a2,s3
    800021dc:	85ca                	mv	a1,s2
    800021de:	6928                	ld	a0,80(a0)
    800021e0:	c38ff0ef          	jal	ra,80001618 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800021e4:	70a2                	ld	ra,40(sp)
    800021e6:	7402                	ld	s0,32(sp)
    800021e8:	64e2                	ld	s1,24(sp)
    800021ea:	6942                	ld	s2,16(sp)
    800021ec:	69a2                	ld	s3,8(sp)
    800021ee:	6a02                	ld	s4,0(sp)
    800021f0:	6145                	addi	sp,sp,48
    800021f2:	8082                	ret
    memmove(dst, (char*)src, len);
    800021f4:	000a061b          	sext.w	a2,s4
    800021f8:	85ce                	mv	a1,s3
    800021fa:	854a                	mv	a0,s2
    800021fc:	aa1fe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    80002200:	8526                	mv	a0,s1
    80002202:	b7cd                	j	800021e4 <either_copyin+0x2a>

0000000080002204 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002204:	715d                	addi	sp,sp,-80
    80002206:	e486                	sd	ra,72(sp)
    80002208:	e0a2                	sd	s0,64(sp)
    8000220a:	fc26                	sd	s1,56(sp)
    8000220c:	f84a                	sd	s2,48(sp)
    8000220e:	f44e                	sd	s3,40(sp)
    80002210:	f052                	sd	s4,32(sp)
    80002212:	ec56                	sd	s5,24(sp)
    80002214:	e85a                	sd	s6,16(sp)
    80002216:	e45e                	sd	s7,8(sp)
    80002218:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000221a:	00005517          	auipc	a0,0x5
    8000221e:	ea650513          	addi	a0,a0,-346 # 800070c0 <digits+0x88>
    80002222:	aa2fe0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002226:	0000e497          	auipc	s1,0xe
    8000222a:	cfa48493          	addi	s1,s1,-774 # 8000ff20 <proc+0x158>
    8000222e:	00014917          	auipc	s2,0x14
    80002232:	8f290913          	addi	s2,s2,-1806 # 80015b20 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002236:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002238:	00005997          	auipc	s3,0x5
    8000223c:	fe098993          	addi	s3,s3,-32 # 80007218 <digits+0x1e0>
    printf("%d %s %s", p->pid, state, p->name);
    80002240:	00005a97          	auipc	s5,0x5
    80002244:	fe0a8a93          	addi	s5,s5,-32 # 80007220 <digits+0x1e8>
    printf("\n");
    80002248:	00005a17          	auipc	s4,0x5
    8000224c:	e78a0a13          	addi	s4,s4,-392 # 800070c0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002250:	00005b97          	auipc	s7,0x5
    80002254:	010b8b93          	addi	s7,s7,16 # 80007260 <states.0>
    80002258:	a829                	j	80002272 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000225a:	ed86a583          	lw	a1,-296(a3)
    8000225e:	8556                	mv	a0,s5
    80002260:	a64fe0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80002264:	8552                	mv	a0,s4
    80002266:	a5efe0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000226a:	17048493          	addi	s1,s1,368
    8000226e:	03248163          	beq	s1,s2,80002290 <procdump+0x8c>
    if(p->state == UNUSED)
    80002272:	86a6                	mv	a3,s1
    80002274:	ec04a783          	lw	a5,-320(s1)
    80002278:	dbed                	beqz	a5,8000226a <procdump+0x66>
      state = "???";
    8000227a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000227c:	fcfb6fe3          	bltu	s6,a5,8000225a <procdump+0x56>
    80002280:	1782                	slli	a5,a5,0x20
    80002282:	9381                	srli	a5,a5,0x20
    80002284:	078e                	slli	a5,a5,0x3
    80002286:	97de                	add	a5,a5,s7
    80002288:	6390                	ld	a2,0(a5)
    8000228a:	fa61                	bnez	a2,8000225a <procdump+0x56>
      state = "???";
    8000228c:	864e                	mv	a2,s3
    8000228e:	b7f1                	j	8000225a <procdump+0x56>
  }
}
    80002290:	60a6                	ld	ra,72(sp)
    80002292:	6406                	ld	s0,64(sp)
    80002294:	74e2                	ld	s1,56(sp)
    80002296:	7942                	ld	s2,48(sp)
    80002298:	79a2                	ld	s3,40(sp)
    8000229a:	7a02                	ld	s4,32(sp)
    8000229c:	6ae2                	ld	s5,24(sp)
    8000229e:	6b42                	ld	s6,16(sp)
    800022a0:	6ba2                	ld	s7,8(sp)
    800022a2:	6161                	addi	sp,sp,80
    800022a4:	8082                	ret

00000000800022a6 <findproc>:

struct proc*
findproc(int pid)
{
    800022a6:	1141                	addi	sp,sp,-16
    800022a8:	e422                	sd	s0,8(sp)
    800022aa:	0800                	addi	s0,sp,16
    800022ac:	86aa                	mv	a3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800022ae:	0000e517          	auipc	a0,0xe
    800022b2:	b1a50513          	addi	a0,a0,-1254 # 8000fdc8 <proc>
    800022b6:	00013717          	auipc	a4,0x13
    800022ba:	71270713          	addi	a4,a4,1810 # 800159c8 <tickslock>
    800022be:	a029                	j	800022c8 <findproc+0x22>
    800022c0:	17050513          	addi	a0,a0,368
    800022c4:	00e50a63          	beq	a0,a4,800022d8 <findproc+0x32>
    if(p->state != UNUSED && p->pid==pid){
    800022c8:	4d1c                	lw	a5,24(a0)
    800022ca:	dbfd                	beqz	a5,800022c0 <findproc+0x1a>
    800022cc:	591c                	lw	a5,48(a0)
    800022ce:	fed799e3          	bne	a5,a3,800022c0 <findproc+0x1a>
      return p;
    }
  }
  return 0;
}
    800022d2:	6422                	ld	s0,8(sp)
    800022d4:	0141                	addi	sp,sp,16
    800022d6:	8082                	ret
  return 0;
    800022d8:	4501                	li	a0,0
    800022da:	bfe5                	j	800022d2 <findproc+0x2c>

00000000800022dc <pfork>:

int
pfork(int ppid)
{
    800022dc:	7139                	addi	sp,sp,-64
    800022de:	fc06                	sd	ra,56(sp)
    800022e0:	f822                	sd	s0,48(sp)
    800022e2:	f426                	sd	s1,40(sp)
    800022e4:	f04a                	sd	s2,32(sp)
    800022e6:	ec4e                	sd	s3,24(sp)
    800022e8:	e852                	sd	s4,16(sp)
    800022ea:	e456                	sd	s5,8(sp)
    800022ec:	0080                	addi	s0,sp,64
  int i, pid;
  struct proc *np;
  struct proc *p = findproc(ppid);
    800022ee:	fb9ff0ef          	jal	ra,800022a6 <findproc>
    800022f2:	8aaa                	mv	s5,a0

  // Allocate process.
  if((np = allocproc()) == 0){
    800022f4:	f34ff0ef          	jal	ra,80001a28 <allocproc>
    800022f8:	0e050663          	beqz	a0,800023e4 <pfork+0x108>
    800022fc:	8a2a                	mv	s4,a0
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800022fe:	048ab603          	ld	a2,72(s5)
    80002302:	692c                	ld	a1,80(a0)
    80002304:	050ab503          	ld	a0,80(s5)
    80002308:	840ff0ef          	jal	ra,80001348 <uvmcopy>
    8000230c:	04054863          	bltz	a0,8000235c <pfork+0x80>
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;
    80002310:	048ab783          	ld	a5,72(s5)
    80002314:	04fa3423          	sd	a5,72(s4)

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);
    80002318:	058ab683          	ld	a3,88(s5)
    8000231c:	87b6                	mv	a5,a3
    8000231e:	058a3703          	ld	a4,88(s4)
    80002322:	12068693          	addi	a3,a3,288
    80002326:	0007b803          	ld	a6,0(a5)
    8000232a:	6788                	ld	a0,8(a5)
    8000232c:	6b8c                	ld	a1,16(a5)
    8000232e:	6f90                	ld	a2,24(a5)
    80002330:	01073023          	sd	a6,0(a4)
    80002334:	e708                	sd	a0,8(a4)
    80002336:	eb0c                	sd	a1,16(a4)
    80002338:	ef10                	sd	a2,24(a4)
    8000233a:	02078793          	addi	a5,a5,32
    8000233e:	02070713          	addi	a4,a4,32
    80002342:	fed792e3          	bne	a5,a3,80002326 <pfork+0x4a>

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;
    80002346:	058a3783          	ld	a5,88(s4)
    8000234a:	0607b823          	sd	zero,112(a5)

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    8000234e:	0d0a8493          	addi	s1,s5,208
    80002352:	0d0a0913          	addi	s2,s4,208
    80002356:	150a8993          	addi	s3,s5,336
    8000235a:	a829                	j	80002374 <pfork+0x98>
    freeproc(np);
    8000235c:	8552                	mv	a0,s4
    8000235e:	e76ff0ef          	jal	ra,800019d4 <freeproc>
    release(&np->lock);
    80002362:	8552                	mv	a0,s4
    80002364:	8a1fe0ef          	jal	ra,80000c04 <release>
    return -1;
    80002368:	597d                	li	s2,-1
    8000236a:	a09d                	j	800023d0 <pfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    8000236c:	04a1                	addi	s1,s1,8
    8000236e:	0921                	addi	s2,s2,8
    80002370:	01348963          	beq	s1,s3,80002382 <pfork+0xa6>
    if(p->ofile[i])
    80002374:	6088                	ld	a0,0(s1)
    80002376:	d97d                	beqz	a0,8000236c <pfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80002378:	579010ef          	jal	ra,800040f0 <filedup>
    8000237c:	00a93023          	sd	a0,0(s2)
    80002380:	b7f5                	j	8000236c <pfork+0x90>
  np->cwd = idup(p->cwd);
    80002382:	150ab503          	ld	a0,336(s5)
    80002386:	78f000ef          	jal	ra,80003314 <idup>
    8000238a:	14aa3823          	sd	a0,336(s4)

  safestrcpy(np->name, p->name, sizeof(p->name));
    8000238e:	4641                	li	a2,16
    80002390:	158a8593          	addi	a1,s5,344
    80002394:	158a0513          	addi	a0,s4,344
    80002398:	9effe0ef          	jal	ra,80000d86 <safestrcpy>

  pid = np->pid;
    8000239c:	030a2903          	lw	s2,48(s4)

  release(&np->lock);
    800023a0:	8552                	mv	a0,s4
    800023a2:	863fe0ef          	jal	ra,80000c04 <release>

  acquire(&wait_lock);
    800023a6:	0000d497          	auipc	s1,0xd
    800023aa:	60a48493          	addi	s1,s1,1546 # 8000f9b0 <wait_lock>
    800023ae:	8526                	mv	a0,s1
    800023b0:	fbcfe0ef          	jal	ra,80000b6c <acquire>
  np->parent = p;
    800023b4:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800023b8:	8526                	mv	a0,s1
    800023ba:	84bfe0ef          	jal	ra,80000c04 <release>

  acquire(&np->lock);
    800023be:	8552                	mv	a0,s4
    800023c0:	facfe0ef          	jal	ra,80000b6c <acquire>
  np->state = RUNNABLE;
    800023c4:	478d                	li	a5,3
    800023c6:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800023ca:	8552                	mv	a0,s4
    800023cc:	839fe0ef          	jal	ra,80000c04 <release>

  return pid;
}
    800023d0:	854a                	mv	a0,s2
    800023d2:	70e2                	ld	ra,56(sp)
    800023d4:	7442                	ld	s0,48(sp)
    800023d6:	74a2                	ld	s1,40(sp)
    800023d8:	7902                	ld	s2,32(sp)
    800023da:	69e2                	ld	s3,24(sp)
    800023dc:	6a42                	ld	s4,16(sp)
    800023de:	6aa2                	ld	s5,8(sp)
    800023e0:	6121                	addi	sp,sp,64
    800023e2:	8082                	ret
    return -1;
    800023e4:	597d                	li	s2,-1
    800023e6:	b7ed                	j	800023d0 <pfork+0xf4>

00000000800023e8 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800023e8:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800023ec:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023f0:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023f2:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023f4:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023f8:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023fc:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002400:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002404:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002408:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000240c:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002410:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002414:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002418:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000241c:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002420:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002424:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002426:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002428:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000242c:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002430:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002434:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002438:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000243c:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002440:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002444:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002448:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000244c:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002450:	8082                	ret

0000000080002452 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002452:	1141                	addi	sp,sp,-16
    80002454:	e406                	sd	ra,8(sp)
    80002456:	e022                	sd	s0,0(sp)
    80002458:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000245a:	00005597          	auipc	a1,0x5
    8000245e:	e3658593          	addi	a1,a1,-458 # 80007290 <states.0+0x30>
    80002462:	00013517          	auipc	a0,0x13
    80002466:	56650513          	addi	a0,a0,1382 # 800159c8 <tickslock>
    8000246a:	e82fe0ef          	jal	ra,80000aec <initlock>
}
    8000246e:	60a2                	ld	ra,8(sp)
    80002470:	6402                	ld	s0,0(sp)
    80002472:	0141                	addi	sp,sp,16
    80002474:	8082                	ret

0000000080002476 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002476:	1141                	addi	sp,sp,-16
    80002478:	e422                	sd	s0,8(sp)
    8000247a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000247c:	00003797          	auipc	a5,0x3
    80002480:	f8478793          	addi	a5,a5,-124 # 80005400 <kernelvec>
    80002484:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002488:	6422                	ld	s0,8(sp)
    8000248a:	0141                	addi	sp,sp,16
    8000248c:	8082                	ret

000000008000248e <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000248e:	1141                	addi	sp,sp,-16
    80002490:	e406                	sd	ra,8(sp)
    80002492:	e022                	sd	s0,0(sp)
    80002494:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002496:	b6eff0ef          	jal	ra,80001804 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000249a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000249e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024a0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024a4:	04000737          	lui	a4,0x4000
    800024a8:	00004797          	auipc	a5,0x4
    800024ac:	b5878793          	addi	a5,a5,-1192 # 80006000 <_trampoline>
    800024b0:	00004697          	auipc	a3,0x4
    800024b4:	b5068693          	addi	a3,a3,-1200 # 80006000 <_trampoline>
    800024b8:	8f95                	sub	a5,a5,a3
    800024ba:	177d                	addi	a4,a4,-1
    800024bc:	0732                	slli	a4,a4,0xc
    800024be:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024c0:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024c4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024c6:	18002773          	csrr	a4,satp
    800024ca:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024cc:	6d38                	ld	a4,88(a0)
    800024ce:	613c                	ld	a5,64(a0)
    800024d0:	6685                	lui	a3,0x1
    800024d2:	97b6                	add	a5,a5,a3
    800024d4:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024d6:	6d3c                	ld	a5,88(a0)
    800024d8:	00000717          	auipc	a4,0x0
    800024dc:	0f470713          	addi	a4,a4,244 # 800025cc <usertrap>
    800024e0:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800024e2:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800024e4:	8712                	mv	a4,tp
    800024e6:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024e8:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024ec:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024f0:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024f4:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024f8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024fa:	6f9c                	ld	a5,24(a5)
    800024fc:	14179073          	csrw	sepc,a5
}
    80002500:	60a2                	ld	ra,8(sp)
    80002502:	6402                	ld	s0,0(sp)
    80002504:	0141                	addi	sp,sp,16
    80002506:	8082                	ret

0000000080002508 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002508:	1101                	addi	sp,sp,-32
    8000250a:	ec06                	sd	ra,24(sp)
    8000250c:	e822                	sd	s0,16(sp)
    8000250e:	e426                	sd	s1,8(sp)
    80002510:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002512:	ac6ff0ef          	jal	ra,800017d8 <cpuid>
    80002516:	cd19                	beqz	a0,80002534 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002518:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000251c:	000f4737          	lui	a4,0xf4
    80002520:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002524:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002526:	14d79073          	csrw	0x14d,a5
}
    8000252a:	60e2                	ld	ra,24(sp)
    8000252c:	6442                	ld	s0,16(sp)
    8000252e:	64a2                	ld	s1,8(sp)
    80002530:	6105                	addi	sp,sp,32
    80002532:	8082                	ret
    acquire(&tickslock);
    80002534:	00013497          	auipc	s1,0x13
    80002538:	49448493          	addi	s1,s1,1172 # 800159c8 <tickslock>
    8000253c:	8526                	mv	a0,s1
    8000253e:	e2efe0ef          	jal	ra,80000b6c <acquire>
    ticks++;
    80002542:	00005517          	auipc	a0,0x5
    80002546:	35650513          	addi	a0,a0,854 # 80007898 <ticks>
    8000254a:	411c                	lw	a5,0(a0)
    8000254c:	2785                	addiw	a5,a5,1
    8000254e:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002550:	911ff0ef          	jal	ra,80001e60 <wakeup>
    release(&tickslock);
    80002554:	8526                	mv	a0,s1
    80002556:	eaefe0ef          	jal	ra,80000c04 <release>
    8000255a:	bf7d                	j	80002518 <clockintr+0x10>

000000008000255c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000255c:	1101                	addi	sp,sp,-32
    8000255e:	ec06                	sd	ra,24(sp)
    80002560:	e822                	sd	s0,16(sp)
    80002562:	e426                	sd	s1,8(sp)
    80002564:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002566:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000256a:	57fd                	li	a5,-1
    8000256c:	17fe                	slli	a5,a5,0x3f
    8000256e:	07a5                	addi	a5,a5,9
    80002570:	00f70d63          	beq	a4,a5,8000258a <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002574:	57fd                	li	a5,-1
    80002576:	17fe                	slli	a5,a5,0x3f
    80002578:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000257a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000257c:	04f70463          	beq	a4,a5,800025c4 <devintr+0x68>
  }
}
    80002580:	60e2                	ld	ra,24(sp)
    80002582:	6442                	ld	s0,16(sp)
    80002584:	64a2                	ld	s1,8(sp)
    80002586:	6105                	addi	sp,sp,32
    80002588:	8082                	ret
    int irq = plic_claim();
    8000258a:	71f020ef          	jal	ra,800054a8 <plic_claim>
    8000258e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002590:	47a9                	li	a5,10
    80002592:	02f50363          	beq	a0,a5,800025b8 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002596:	4785                	li	a5,1
    80002598:	02f50363          	beq	a0,a5,800025be <devintr+0x62>
    return 1;
    8000259c:	4505                	li	a0,1
    } else if(irq){
    8000259e:	d0ed                	beqz	s1,80002580 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    800025a0:	85a6                	mv	a1,s1
    800025a2:	00005517          	auipc	a0,0x5
    800025a6:	cf650513          	addi	a0,a0,-778 # 80007298 <states.0+0x38>
    800025aa:	f1bfd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    800025ae:	8526                	mv	a0,s1
    800025b0:	719020ef          	jal	ra,800054c8 <plic_complete>
    return 1;
    800025b4:	4505                	li	a0,1
    800025b6:	b7e9                	j	80002580 <devintr+0x24>
      uartintr();
    800025b8:	ba0fe0ef          	jal	ra,80000958 <uartintr>
    800025bc:	bfcd                	j	800025ae <devintr+0x52>
      virtio_disk_intr();
    800025be:	37a030ef          	jal	ra,80005938 <virtio_disk_intr>
    800025c2:	b7f5                	j	800025ae <devintr+0x52>
    clockintr();
    800025c4:	f45ff0ef          	jal	ra,80002508 <clockintr>
    return 2;
    800025c8:	4509                	li	a0,2
    800025ca:	bf5d                	j	80002580 <devintr+0x24>

00000000800025cc <usertrap>:
{
    800025cc:	1101                	addi	sp,sp,-32
    800025ce:	ec06                	sd	ra,24(sp)
    800025d0:	e822                	sd	s0,16(sp)
    800025d2:	e426                	sd	s1,8(sp)
    800025d4:	e04a                	sd	s2,0(sp)
    800025d6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025d8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025dc:	1007f793          	andi	a5,a5,256
    800025e0:	eba5                	bnez	a5,80002650 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025e2:	00003797          	auipc	a5,0x3
    800025e6:	e1e78793          	addi	a5,a5,-482 # 80005400 <kernelvec>
    800025ea:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025ee:	a16ff0ef          	jal	ra,80001804 <myproc>
    800025f2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025f4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025f6:	14102773          	csrr	a4,sepc
    800025fa:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025fc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002600:	47a1                	li	a5,8
    80002602:	04f70d63          	beq	a4,a5,8000265c <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002606:	f57ff0ef          	jal	ra,8000255c <devintr>
    8000260a:	892a                	mv	s2,a0
    8000260c:	e945                	bnez	a0,800026bc <usertrap+0xf0>
    8000260e:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002612:	47bd                	li	a5,15
    80002614:	08f70863          	beq	a4,a5,800026a4 <usertrap+0xd8>
    80002618:	14202773          	csrr	a4,scause
    8000261c:	47b5                	li	a5,13
    8000261e:	08f70363          	beq	a4,a5,800026a4 <usertrap+0xd8>
    80002622:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002626:	5890                	lw	a2,48(s1)
    80002628:	00005517          	auipc	a0,0x5
    8000262c:	cb050513          	addi	a0,a0,-848 # 800072d8 <states.0+0x78>
    80002630:	e95fd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002634:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002638:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000263c:	00005517          	auipc	a0,0x5
    80002640:	ccc50513          	addi	a0,a0,-820 # 80007308 <states.0+0xa8>
    80002644:	e81fd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    80002648:	8526                	mv	a0,s1
    8000264a:	9dfff0ef          	jal	ra,80002028 <setkilled>
    8000264e:	a035                	j	8000267a <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002650:	00005517          	auipc	a0,0x5
    80002654:	c6850513          	addi	a0,a0,-920 # 800072b8 <states.0+0x58>
    80002658:	932fe0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    8000265c:	9f1ff0ef          	jal	ra,8000204c <killed>
    80002660:	ed15                	bnez	a0,8000269c <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002662:	6cb8                	ld	a4,88(s1)
    80002664:	6f1c                	ld	a5,24(a4)
    80002666:	0791                	addi	a5,a5,4
    80002668:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000266a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000266e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002672:	10079073          	csrw	sstatus,a5
    syscall();
    80002676:	246000ef          	jal	ra,800028bc <syscall>
  if(killed(p))
    8000267a:	8526                	mv	a0,s1
    8000267c:	9d1ff0ef          	jal	ra,8000204c <killed>
    80002680:	e139                	bnez	a0,800026c6 <usertrap+0xfa>
  prepare_return();
    80002682:	e0dff0ef          	jal	ra,8000248e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002686:	68a8                	ld	a0,80(s1)
    80002688:	8131                	srli	a0,a0,0xc
    8000268a:	57fd                	li	a5,-1
    8000268c:	17fe                	slli	a5,a5,0x3f
    8000268e:	8d5d                	or	a0,a0,a5
}
    80002690:	60e2                	ld	ra,24(sp)
    80002692:	6442                	ld	s0,16(sp)
    80002694:	64a2                	ld	s1,8(sp)
    80002696:	6902                	ld	s2,0(sp)
    80002698:	6105                	addi	sp,sp,32
    8000269a:	8082                	ret
      kexit(-1);
    8000269c:	557d                	li	a0,-1
    8000269e:	883ff0ef          	jal	ra,80001f20 <kexit>
    800026a2:	b7c1                	j	80002662 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026a4:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026a8:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026ac:	164d                	addi	a2,a2,-13
    800026ae:	00163613          	seqz	a2,a2
    800026b2:	68a8                	ld	a0,80(s1)
    800026b4:	e2dfe0ef          	jal	ra,800014e0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026b8:	f169                	bnez	a0,8000267a <usertrap+0xae>
    800026ba:	b7a5                	j	80002622 <usertrap+0x56>
  if(killed(p))
    800026bc:	8526                	mv	a0,s1
    800026be:	98fff0ef          	jal	ra,8000204c <killed>
    800026c2:	c511                	beqz	a0,800026ce <usertrap+0x102>
    800026c4:	a011                	j	800026c8 <usertrap+0xfc>
    800026c6:	4901                	li	s2,0
    kexit(-1);
    800026c8:	557d                	li	a0,-1
    800026ca:	857ff0ef          	jal	ra,80001f20 <kexit>
  if(which_dev == 2){
    800026ce:	4789                	li	a5,2
    800026d0:	faf919e3          	bne	s2,a5,80002682 <usertrap+0xb6>
    yield();
    800026d4:	f14ff0ef          	jal	ra,80001de8 <yield>
    800026d8:	b76d                	j	80002682 <usertrap+0xb6>

00000000800026da <kerneltrap>:
{
    800026da:	7179                	addi	sp,sp,-48
    800026dc:	f406                	sd	ra,40(sp)
    800026de:	f022                	sd	s0,32(sp)
    800026e0:	ec26                	sd	s1,24(sp)
    800026e2:	e84a                	sd	s2,16(sp)
    800026e4:	e44e                	sd	s3,8(sp)
    800026e6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026e8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ec:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026f0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800026f4:	1004f793          	andi	a5,s1,256
    800026f8:	c795                	beqz	a5,80002724 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026fa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026fe:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002700:	eb85                	bnez	a5,80002730 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002702:	e5bff0ef          	jal	ra,8000255c <devintr>
    80002706:	c91d                	beqz	a0,8000273c <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002708:	4789                	li	a5,2
    8000270a:	04f50a63          	beq	a0,a5,8000275e <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000270e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002712:	10049073          	csrw	sstatus,s1
}
    80002716:	70a2                	ld	ra,40(sp)
    80002718:	7402                	ld	s0,32(sp)
    8000271a:	64e2                	ld	s1,24(sp)
    8000271c:	6942                	ld	s2,16(sp)
    8000271e:	69a2                	ld	s3,8(sp)
    80002720:	6145                	addi	sp,sp,48
    80002722:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002724:	00005517          	auipc	a0,0x5
    80002728:	c0c50513          	addi	a0,a0,-1012 # 80007330 <states.0+0xd0>
    8000272c:	85efe0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    80002730:	00005517          	auipc	a0,0x5
    80002734:	c2850513          	addi	a0,a0,-984 # 80007358 <states.0+0xf8>
    80002738:	852fe0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000273c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002740:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002744:	85ce                	mv	a1,s3
    80002746:	00005517          	auipc	a0,0x5
    8000274a:	c3250513          	addi	a0,a0,-974 # 80007378 <states.0+0x118>
    8000274e:	d77fd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    80002752:	00005517          	auipc	a0,0x5
    80002756:	c4e50513          	addi	a0,a0,-946 # 800073a0 <states.0+0x140>
    8000275a:	830fe0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    8000275e:	8a6ff0ef          	jal	ra,80001804 <myproc>
    80002762:	d555                	beqz	a0,8000270e <kerneltrap+0x34>
    yield();
    80002764:	e84ff0ef          	jal	ra,80001de8 <yield>
    80002768:	b75d                	j	8000270e <kerneltrap+0x34>

000000008000276a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000276a:	1101                	addi	sp,sp,-32
    8000276c:	ec06                	sd	ra,24(sp)
    8000276e:	e822                	sd	s0,16(sp)
    80002770:	e426                	sd	s1,8(sp)
    80002772:	1000                	addi	s0,sp,32
    80002774:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002776:	88eff0ef          	jal	ra,80001804 <myproc>
  switch (n) {
    8000277a:	4795                	li	a5,5
    8000277c:	0497e163          	bltu	a5,s1,800027be <argraw+0x54>
    80002780:	048a                	slli	s1,s1,0x2
    80002782:	00005717          	auipc	a4,0x5
    80002786:	c5670713          	addi	a4,a4,-938 # 800073d8 <states.0+0x178>
    8000278a:	94ba                	add	s1,s1,a4
    8000278c:	409c                	lw	a5,0(s1)
    8000278e:	97ba                	add	a5,a5,a4
    80002790:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002792:	6d3c                	ld	a5,88(a0)
    80002794:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002796:	60e2                	ld	ra,24(sp)
    80002798:	6442                	ld	s0,16(sp)
    8000279a:	64a2                	ld	s1,8(sp)
    8000279c:	6105                	addi	sp,sp,32
    8000279e:	8082                	ret
    return p->trapframe->a1;
    800027a0:	6d3c                	ld	a5,88(a0)
    800027a2:	7fa8                	ld	a0,120(a5)
    800027a4:	bfcd                	j	80002796 <argraw+0x2c>
    return p->trapframe->a2;
    800027a6:	6d3c                	ld	a5,88(a0)
    800027a8:	63c8                	ld	a0,128(a5)
    800027aa:	b7f5                	j	80002796 <argraw+0x2c>
    return p->trapframe->a3;
    800027ac:	6d3c                	ld	a5,88(a0)
    800027ae:	67c8                	ld	a0,136(a5)
    800027b0:	b7dd                	j	80002796 <argraw+0x2c>
    return p->trapframe->a4;
    800027b2:	6d3c                	ld	a5,88(a0)
    800027b4:	6bc8                	ld	a0,144(a5)
    800027b6:	b7c5                	j	80002796 <argraw+0x2c>
    return p->trapframe->a5;
    800027b8:	6d3c                	ld	a5,88(a0)
    800027ba:	6fc8                	ld	a0,152(a5)
    800027bc:	bfe9                	j	80002796 <argraw+0x2c>
  panic("argraw");
    800027be:	00005517          	auipc	a0,0x5
    800027c2:	bf250513          	addi	a0,a0,-1038 # 800073b0 <states.0+0x150>
    800027c6:	fc5fd0ef          	jal	ra,8000078a <panic>

00000000800027ca <fetchaddr>:
{
    800027ca:	1101                	addi	sp,sp,-32
    800027cc:	ec06                	sd	ra,24(sp)
    800027ce:	e822                	sd	s0,16(sp)
    800027d0:	e426                	sd	s1,8(sp)
    800027d2:	e04a                	sd	s2,0(sp)
    800027d4:	1000                	addi	s0,sp,32
    800027d6:	84aa                	mv	s1,a0
    800027d8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027da:	82aff0ef          	jal	ra,80001804 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027de:	653c                	ld	a5,72(a0)
    800027e0:	02f4f663          	bgeu	s1,a5,8000280c <fetchaddr+0x42>
    800027e4:	00848713          	addi	a4,s1,8
    800027e8:	02e7e463          	bltu	a5,a4,80002810 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027ec:	46a1                	li	a3,8
    800027ee:	8626                	mv	a2,s1
    800027f0:	85ca                	mv	a1,s2
    800027f2:	6928                	ld	a0,80(a0)
    800027f4:	e25fe0ef          	jal	ra,80001618 <copyin>
    800027f8:	00a03533          	snez	a0,a0
    800027fc:	40a00533          	neg	a0,a0
}
    80002800:	60e2                	ld	ra,24(sp)
    80002802:	6442                	ld	s0,16(sp)
    80002804:	64a2                	ld	s1,8(sp)
    80002806:	6902                	ld	s2,0(sp)
    80002808:	6105                	addi	sp,sp,32
    8000280a:	8082                	ret
    return -1;
    8000280c:	557d                	li	a0,-1
    8000280e:	bfcd                	j	80002800 <fetchaddr+0x36>
    80002810:	557d                	li	a0,-1
    80002812:	b7fd                	j	80002800 <fetchaddr+0x36>

0000000080002814 <fetchstr>:
{
    80002814:	7179                	addi	sp,sp,-48
    80002816:	f406                	sd	ra,40(sp)
    80002818:	f022                	sd	s0,32(sp)
    8000281a:	ec26                	sd	s1,24(sp)
    8000281c:	e84a                	sd	s2,16(sp)
    8000281e:	e44e                	sd	s3,8(sp)
    80002820:	1800                	addi	s0,sp,48
    80002822:	892a                	mv	s2,a0
    80002824:	84ae                	mv	s1,a1
    80002826:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002828:	fddfe0ef          	jal	ra,80001804 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000282c:	86ce                	mv	a3,s3
    8000282e:	864a                	mv	a2,s2
    80002830:	85a6                	mv	a1,s1
    80002832:	6928                	ld	a0,80(a0)
    80002834:	bddfe0ef          	jal	ra,80001410 <copyinstr>
    80002838:	00054c63          	bltz	a0,80002850 <fetchstr+0x3c>
  return strlen(buf);
    8000283c:	8526                	mv	a0,s1
    8000283e:	d7afe0ef          	jal	ra,80000db8 <strlen>
}
    80002842:	70a2                	ld	ra,40(sp)
    80002844:	7402                	ld	s0,32(sp)
    80002846:	64e2                	ld	s1,24(sp)
    80002848:	6942                	ld	s2,16(sp)
    8000284a:	69a2                	ld	s3,8(sp)
    8000284c:	6145                	addi	sp,sp,48
    8000284e:	8082                	ret
    return -1;
    80002850:	557d                	li	a0,-1
    80002852:	bfc5                	j	80002842 <fetchstr+0x2e>

0000000080002854 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002854:	1101                	addi	sp,sp,-32
    80002856:	ec06                	sd	ra,24(sp)
    80002858:	e822                	sd	s0,16(sp)
    8000285a:	e426                	sd	s1,8(sp)
    8000285c:	1000                	addi	s0,sp,32
    8000285e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002860:	f0bff0ef          	jal	ra,8000276a <argraw>
    80002864:	c088                	sw	a0,0(s1)
}
    80002866:	60e2                	ld	ra,24(sp)
    80002868:	6442                	ld	s0,16(sp)
    8000286a:	64a2                	ld	s1,8(sp)
    8000286c:	6105                	addi	sp,sp,32
    8000286e:	8082                	ret

0000000080002870 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002870:	1101                	addi	sp,sp,-32
    80002872:	ec06                	sd	ra,24(sp)
    80002874:	e822                	sd	s0,16(sp)
    80002876:	e426                	sd	s1,8(sp)
    80002878:	1000                	addi	s0,sp,32
    8000287a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000287c:	eefff0ef          	jal	ra,8000276a <argraw>
    80002880:	e088                	sd	a0,0(s1)
}
    80002882:	60e2                	ld	ra,24(sp)
    80002884:	6442                	ld	s0,16(sp)
    80002886:	64a2                	ld	s1,8(sp)
    80002888:	6105                	addi	sp,sp,32
    8000288a:	8082                	ret

000000008000288c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000288c:	7179                	addi	sp,sp,-48
    8000288e:	f406                	sd	ra,40(sp)
    80002890:	f022                	sd	s0,32(sp)
    80002892:	ec26                	sd	s1,24(sp)
    80002894:	e84a                	sd	s2,16(sp)
    80002896:	1800                	addi	s0,sp,48
    80002898:	84ae                	mv	s1,a1
    8000289a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000289c:	fd840593          	addi	a1,s0,-40
    800028a0:	fd1ff0ef          	jal	ra,80002870 <argaddr>
  return fetchstr(addr, buf, max);
    800028a4:	864a                	mv	a2,s2
    800028a6:	85a6                	mv	a1,s1
    800028a8:	fd843503          	ld	a0,-40(s0)
    800028ac:	f69ff0ef          	jal	ra,80002814 <fetchstr>
}
    800028b0:	70a2                	ld	ra,40(sp)
    800028b2:	7402                	ld	s0,32(sp)
    800028b4:	64e2                	ld	s1,24(sp)
    800028b6:	6942                	ld	s2,16(sp)
    800028b8:	6145                	addi	sp,sp,48
    800028ba:	8082                	ret

00000000800028bc <syscall>:
// [SYS_kmap]  sys_kmap,
};

void
syscall(void)
{
    800028bc:	1101                	addi	sp,sp,-32
    800028be:	ec06                	sd	ra,24(sp)
    800028c0:	e822                	sd	s0,16(sp)
    800028c2:	e426                	sd	s1,8(sp)
    800028c4:	e04a                	sd	s2,0(sp)
    800028c6:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028c8:	f3dfe0ef          	jal	ra,80001804 <myproc>
    800028cc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800028ce:	05853903          	ld	s2,88(a0)
    800028d2:	0a893783          	ld	a5,168(s2)
    800028d6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028da:	37fd                	addiw	a5,a5,-1
    800028dc:	4771                	li	a4,28
    800028de:	00f76f63          	bltu	a4,a5,800028fc <syscall+0x40>
    800028e2:	00369713          	slli	a4,a3,0x3
    800028e6:	00005797          	auipc	a5,0x5
    800028ea:	b0a78793          	addi	a5,a5,-1270 # 800073f0 <syscalls>
    800028ee:	97ba                	add	a5,a5,a4
    800028f0:	639c                	ld	a5,0(a5)
    800028f2:	c789                	beqz	a5,800028fc <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028f4:	9782                	jalr	a5
    800028f6:	06a93823          	sd	a0,112(s2)
    800028fa:	a829                	j	80002914 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800028fc:	15848613          	addi	a2,s1,344
    80002900:	588c                	lw	a1,48(s1)
    80002902:	00005517          	auipc	a0,0x5
    80002906:	ab650513          	addi	a0,a0,-1354 # 800073b8 <states.0+0x158>
    8000290a:	bbbfd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000290e:	6cbc                	ld	a5,88(s1)
    80002910:	577d                	li	a4,-1
    80002912:	fbb8                	sd	a4,112(a5)
  }
}
    80002914:	60e2                	ld	ra,24(sp)
    80002916:	6442                	ld	s0,16(sp)
    80002918:	64a2                	ld	s1,8(sp)
    8000291a:	6902                	ld	s2,0(sp)
    8000291c:	6105                	addi	sp,sp,32
    8000291e:	8082                	ret

0000000080002920 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002920:	1101                	addi	sp,sp,-32
    80002922:	ec06                	sd	ra,24(sp)
    80002924:	e822                	sd	s0,16(sp)
    80002926:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002928:	fec40593          	addi	a1,s0,-20
    8000292c:	4501                	li	a0,0
    8000292e:	f27ff0ef          	jal	ra,80002854 <argint>
  kexit(n);
    80002932:	fec42503          	lw	a0,-20(s0)
    80002936:	deaff0ef          	jal	ra,80001f20 <kexit>
  return 0;  // not reached
}
    8000293a:	4501                	li	a0,0
    8000293c:	60e2                	ld	ra,24(sp)
    8000293e:	6442                	ld	s0,16(sp)
    80002940:	6105                	addi	sp,sp,32
    80002942:	8082                	ret

0000000080002944 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002944:	1141                	addi	sp,sp,-16
    80002946:	e406                	sd	ra,8(sp)
    80002948:	e022                	sd	s0,0(sp)
    8000294a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000294c:	eb9fe0ef          	jal	ra,80001804 <myproc>
}
    80002950:	5908                	lw	a0,48(a0)
    80002952:	60a2                	ld	ra,8(sp)
    80002954:	6402                	ld	s0,0(sp)
    80002956:	0141                	addi	sp,sp,16
    80002958:	8082                	ret

000000008000295a <sys_fork>:

uint64
sys_fork(void)
{
    8000295a:	1141                	addi	sp,sp,-16
    8000295c:	e406                	sd	ra,8(sp)
    8000295e:	e022                	sd	s0,0(sp)
    80002960:	0800                	addi	s0,sp,16
  return kfork();
    80002962:	a0eff0ef          	jal	ra,80001b70 <kfork>
}
    80002966:	60a2                	ld	ra,8(sp)
    80002968:	6402                	ld	s0,0(sp)
    8000296a:	0141                	addi	sp,sp,16
    8000296c:	8082                	ret

000000008000296e <sys_wait>:

uint64
sys_wait(void)
{
    8000296e:	1101                	addi	sp,sp,-32
    80002970:	ec06                	sd	ra,24(sp)
    80002972:	e822                	sd	s0,16(sp)
    80002974:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002976:	fe840593          	addi	a1,s0,-24
    8000297a:	4501                	li	a0,0
    8000297c:	ef5ff0ef          	jal	ra,80002870 <argaddr>
  return kwait(p);
    80002980:	fe843503          	ld	a0,-24(s0)
    80002984:	ef2ff0ef          	jal	ra,80002076 <kwait>
}
    80002988:	60e2                	ld	ra,24(sp)
    8000298a:	6442                	ld	s0,16(sp)
    8000298c:	6105                	addi	sp,sp,32
    8000298e:	8082                	ret

0000000080002990 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002990:	7179                	addi	sp,sp,-48
    80002992:	f406                	sd	ra,40(sp)
    80002994:	f022                	sd	s0,32(sp)
    80002996:	ec26                	sd	s1,24(sp)
    80002998:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    8000299a:	fd840593          	addi	a1,s0,-40
    8000299e:	4501                	li	a0,0
    800029a0:	eb5ff0ef          	jal	ra,80002854 <argint>
  argint(1, &t);
    800029a4:	fdc40593          	addi	a1,s0,-36
    800029a8:	4505                	li	a0,1
    800029aa:	eabff0ef          	jal	ra,80002854 <argint>
  addr = myproc()->sz;
    800029ae:	e57fe0ef          	jal	ra,80001804 <myproc>
    800029b2:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800029b4:	fdc42703          	lw	a4,-36(s0)
    800029b8:	4785                	li	a5,1
    800029ba:	02f70763          	beq	a4,a5,800029e8 <sys_sbrk+0x58>
    800029be:	fd842783          	lw	a5,-40(s0)
    800029c2:	0207c363          	bltz	a5,800029e8 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800029c6:	97a6                	add	a5,a5,s1
    800029c8:	0297ee63          	bltu	a5,s1,80002a04 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    800029cc:	02000737          	lui	a4,0x2000
    800029d0:	177d                	addi	a4,a4,-1
    800029d2:	0736                	slli	a4,a4,0xd
    800029d4:	02f76a63          	bltu	a4,a5,80002a08 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    800029d8:	e2dfe0ef          	jal	ra,80001804 <myproc>
    800029dc:	fd842703          	lw	a4,-40(s0)
    800029e0:	653c                	ld	a5,72(a0)
    800029e2:	97ba                	add	a5,a5,a4
    800029e4:	e53c                	sd	a5,72(a0)
    800029e6:	a039                	j	800029f4 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    800029e8:	fd842503          	lw	a0,-40(s0)
    800029ec:	922ff0ef          	jal	ra,80001b0e <growproc>
    800029f0:	00054863          	bltz	a0,80002a00 <sys_sbrk+0x70>
  }
  return addr;
}
    800029f4:	8526                	mv	a0,s1
    800029f6:	70a2                	ld	ra,40(sp)
    800029f8:	7402                	ld	s0,32(sp)
    800029fa:	64e2                	ld	s1,24(sp)
    800029fc:	6145                	addi	sp,sp,48
    800029fe:	8082                	ret
      return -1;
    80002a00:	54fd                	li	s1,-1
    80002a02:	bfcd                	j	800029f4 <sys_sbrk+0x64>
      return -1;
    80002a04:	54fd                	li	s1,-1
    80002a06:	b7fd                	j	800029f4 <sys_sbrk+0x64>
      return -1;
    80002a08:	54fd                	li	s1,-1
    80002a0a:	b7ed                	j	800029f4 <sys_sbrk+0x64>

0000000080002a0c <sys_pause>:

uint64
sys_pause(void)
{
    80002a0c:	7139                	addi	sp,sp,-64
    80002a0e:	fc06                	sd	ra,56(sp)
    80002a10:	f822                	sd	s0,48(sp)
    80002a12:	f426                	sd	s1,40(sp)
    80002a14:	f04a                	sd	s2,32(sp)
    80002a16:	ec4e                	sd	s3,24(sp)
    80002a18:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a1a:	fcc40593          	addi	a1,s0,-52
    80002a1e:	4501                	li	a0,0
    80002a20:	e35ff0ef          	jal	ra,80002854 <argint>
  if(n < 0)
    80002a24:	fcc42783          	lw	a5,-52(s0)
    80002a28:	0607c563          	bltz	a5,80002a92 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a2c:	00013517          	auipc	a0,0x13
    80002a30:	f9c50513          	addi	a0,a0,-100 # 800159c8 <tickslock>
    80002a34:	938fe0ef          	jal	ra,80000b6c <acquire>
  ticks0 = ticks;
    80002a38:	00005917          	auipc	s2,0x5
    80002a3c:	e6092903          	lw	s2,-416(s2) # 80007898 <ticks>
  while(ticks - ticks0 < n){
    80002a40:	fcc42783          	lw	a5,-52(s0)
    80002a44:	cb8d                	beqz	a5,80002a76 <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a46:	00013997          	auipc	s3,0x13
    80002a4a:	f8298993          	addi	s3,s3,-126 # 800159c8 <tickslock>
    80002a4e:	00005497          	auipc	s1,0x5
    80002a52:	e4a48493          	addi	s1,s1,-438 # 80007898 <ticks>
    if(killed(myproc())){
    80002a56:	daffe0ef          	jal	ra,80001804 <myproc>
    80002a5a:	df2ff0ef          	jal	ra,8000204c <killed>
    80002a5e:	ed0d                	bnez	a0,80002a98 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a60:	85ce                	mv	a1,s3
    80002a62:	8526                	mv	a0,s1
    80002a64:	bb0ff0ef          	jal	ra,80001e14 <sleep>
  while(ticks - ticks0 < n){
    80002a68:	409c                	lw	a5,0(s1)
    80002a6a:	412787bb          	subw	a5,a5,s2
    80002a6e:	fcc42703          	lw	a4,-52(s0)
    80002a72:	fee7e2e3          	bltu	a5,a4,80002a56 <sys_pause+0x4a>
  }
  release(&tickslock);
    80002a76:	00013517          	auipc	a0,0x13
    80002a7a:	f5250513          	addi	a0,a0,-174 # 800159c8 <tickslock>
    80002a7e:	986fe0ef          	jal	ra,80000c04 <release>
  return 0;
    80002a82:	4501                	li	a0,0
}
    80002a84:	70e2                	ld	ra,56(sp)
    80002a86:	7442                	ld	s0,48(sp)
    80002a88:	74a2                	ld	s1,40(sp)
    80002a8a:	7902                	ld	s2,32(sp)
    80002a8c:	69e2                	ld	s3,24(sp)
    80002a8e:	6121                	addi	sp,sp,64
    80002a90:	8082                	ret
    n = 0;
    80002a92:	fc042623          	sw	zero,-52(s0)
    80002a96:	bf59                	j	80002a2c <sys_pause+0x20>
      release(&tickslock);
    80002a98:	00013517          	auipc	a0,0x13
    80002a9c:	f3050513          	addi	a0,a0,-208 # 800159c8 <tickslock>
    80002aa0:	964fe0ef          	jal	ra,80000c04 <release>
      return -1;
    80002aa4:	557d                	li	a0,-1
    80002aa6:	bff9                	j	80002a84 <sys_pause+0x78>

0000000080002aa8 <sys_kill>:

uint64
sys_kill(void)
{
    80002aa8:	1101                	addi	sp,sp,-32
    80002aaa:	ec06                	sd	ra,24(sp)
    80002aac:	e822                	sd	s0,16(sp)
    80002aae:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ab0:	fec40593          	addi	a1,s0,-20
    80002ab4:	4501                	li	a0,0
    80002ab6:	d9fff0ef          	jal	ra,80002854 <argint>
  return kkill(pid);
    80002aba:	fec42503          	lw	a0,-20(s0)
    80002abe:	d04ff0ef          	jal	ra,80001fc2 <kkill>
}
    80002ac2:	60e2                	ld	ra,24(sp)
    80002ac4:	6442                	ld	s0,16(sp)
    80002ac6:	6105                	addi	sp,sp,32
    80002ac8:	8082                	ret

0000000080002aca <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002aca:	1101                	addi	sp,sp,-32
    80002acc:	ec06                	sd	ra,24(sp)
    80002ace:	e822                	sd	s0,16(sp)
    80002ad0:	e426                	sd	s1,8(sp)
    80002ad2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ad4:	00013517          	auipc	a0,0x13
    80002ad8:	ef450513          	addi	a0,a0,-268 # 800159c8 <tickslock>
    80002adc:	890fe0ef          	jal	ra,80000b6c <acquire>
  xticks = ticks;
    80002ae0:	00005497          	auipc	s1,0x5
    80002ae4:	db84a483          	lw	s1,-584(s1) # 80007898 <ticks>
  release(&tickslock);
    80002ae8:	00013517          	auipc	a0,0x13
    80002aec:	ee050513          	addi	a0,a0,-288 # 800159c8 <tickslock>
    80002af0:	914fe0ef          	jal	ra,80000c04 <release>
  return xticks;
}
    80002af4:	02049513          	slli	a0,s1,0x20
    80002af8:	9101                	srli	a0,a0,0x20
    80002afa:	60e2                	ld	ra,24(sp)
    80002afc:	6442                	ld	s0,16(sp)
    80002afe:	64a2                	ld	s1,8(sp)
    80002b00:	6105                	addi	sp,sp,32
    80002b02:	8082                	ret

0000000080002b04 <sys_tfork>:

uint64
sys_tfork()
{
    80002b04:	7139                	addi	sp,sp,-64
    80002b06:	fc06                	sd	ra,56(sp)
    80002b08:	f822                	sd	s0,48(sp)
    80002b0a:	f426                	sd	s1,40(sp)
    80002b0c:	0080                	addi	s0,sp,64
  int n;
  argint(0,&n);
    80002b0e:	fdc40593          	addi	a1,s0,-36
    80002b12:	4501                	li	a0,0
    80002b14:	d41ff0ef          	jal	ra,80002854 <argint>
  uint64 pids;
  argaddr(1,&pids);
    80002b18:	fd040593          	addi	a1,s0,-48
    80002b1c:	4505                	li	a0,1
    80002b1e:	d53ff0ef          	jal	ra,80002870 <argaddr>

  for(int i=0;i<n;i++){
    80002b22:	fdc42503          	lw	a0,-36(s0)
    80002b26:	04a05463          	blez	a0,80002b6e <sys_tfork+0x6a>
    80002b2a:	4481                	li	s1,0
    80002b2c:	a801                	j	80002b3c <sys_tfork+0x38>
    80002b2e:	fdc42503          	lw	a0,-36(s0)
    80002b32:	0485                	addi	s1,s1,1
    80002b34:	0004879b          	sext.w	a5,s1
    80002b38:	02a7db63          	bge	a5,a0,80002b6e <sys_tfork+0x6a>
    int f= kfork();
    80002b3c:	834ff0ef          	jal	ra,80001b70 <kfork>
    80002b40:	fca42623          	sw	a0,-52(s0)
    if(f==0){
    80002b44:	c505                	beqz	a0,80002b6c <sys_tfork+0x68>
      return 0;
    }
    if(f>0){
    80002b46:	fea054e3          	blez	a0,80002b2e <sys_tfork+0x2a>
      if(copyout(myproc()->pagetable,pids+i*sizeof(int),(char*)&f,sizeof(int))<0){
    80002b4a:	cbbfe0ef          	jal	ra,80001804 <myproc>
    80002b4e:	00249793          	slli	a5,s1,0x2
    80002b52:	4691                	li	a3,4
    80002b54:	fcc40613          	addi	a2,s0,-52
    80002b58:	fd043583          	ld	a1,-48(s0)
    80002b5c:	95be                	add	a1,a1,a5
    80002b5e:	6928                	ld	a0,80(a0)
    80002b60:	9f3fe0ef          	jal	ra,80001552 <copyout>
    80002b64:	fc0555e3          	bgez	a0,80002b2e <sys_tfork+0x2a>
        return -1;
    80002b68:	557d                	li	a0,-1
    80002b6a:	a011                	j	80002b6e <sys_tfork+0x6a>
      return 0;
    80002b6c:	4501                	li	a0,0
      }
    }
  }
  return n;
}
    80002b6e:	70e2                	ld	ra,56(sp)
    80002b70:	7442                	ld	s0,48(sp)
    80002b72:	74a2                	ld	s1,40(sp)
    80002b74:	6121                	addi	sp,sp,64
    80002b76:	8082                	ret

0000000080002b78 <sys_getppid>:

uint64
sys_getppid()
{
    80002b78:	1141                	addi	sp,sp,-16
    80002b7a:	e406                	sd	ra,8(sp)
    80002b7c:	e022                	sd	s0,0(sp)
    80002b7e:	0800                	addi	s0,sp,16
  return myproc()->parent->pid;
    80002b80:	c85fe0ef          	jal	ra,80001804 <myproc>
    80002b84:	7d1c                	ld	a5,56(a0)
}
    80002b86:	5b88                	lw	a0,48(a5)
    80002b88:	60a2                	ld	ra,8(sp)
    80002b8a:	6402                	ld	s0,0(sp)
    80002b8c:	0141                	addi	sp,sp,16
    80002b8e:	8082                	ret

0000000080002b90 <sys_tfork2>:

uint64
sys_tfork2()
{
    80002b90:	7139                	addi	sp,sp,-64
    80002b92:	fc06                	sd	ra,56(sp)
    80002b94:	f822                	sd	s0,48(sp)
    80002b96:	f426                	sd	s1,40(sp)
    80002b98:	0080                	addi	s0,sp,64
  int n;
  argint(0,&n);
    80002b9a:	fdc40593          	addi	a1,s0,-36
    80002b9e:	4501                	li	a0,0
    80002ba0:	cb5ff0ef          	jal	ra,80002854 <argint>
  uint64 pids;
  argaddr(1,&pids);
    80002ba4:	fd040593          	addi	a1,s0,-48
    80002ba8:	4505                	li	a0,1
    80002baa:	cc7ff0ef          	jal	ra,80002870 <argaddr>
  int ppid=myproc()->pid;
    80002bae:	c57fe0ef          	jal	ra,80001804 <myproc>
    80002bb2:	5908                	lw	a0,48(a0)
  for(int i=0;i<n;i++){
    80002bb4:	fdc42783          	lw	a5,-36(s0)
    80002bb8:	04f05763          	blez	a5,80002c06 <sys_tfork2+0x76>
    80002bbc:	4481                	li	s1,0
    80002bbe:	a811                	j	80002bd2 <sys_tfork2+0x42>
    if(f>0){
      if(copyout(myproc()->pagetable,pids+i*sizeof(int),(char*)&f,sizeof(int))<0){
        return -1;
      }
    }
    ppid=f;
    80002bc0:	fcc42503          	lw	a0,-52(s0)
  for(int i=0;i<n;i++){
    80002bc4:	fdc42783          	lw	a5,-36(s0)
    80002bc8:	0485                	addi	s1,s1,1
    80002bca:	0004871b          	sext.w	a4,s1
    80002bce:	02f75c63          	bge	a4,a5,80002c06 <sys_tfork2+0x76>
    int f= pfork(ppid);
    80002bd2:	f0aff0ef          	jal	ra,800022dc <pfork>
    80002bd6:	fca42623          	sw	a0,-52(s0)
    if(f==0){
    80002bda:	c505                	beqz	a0,80002c02 <sys_tfork2+0x72>
    if(f>0){
    80002bdc:	fea052e3          	blez	a0,80002bc0 <sys_tfork2+0x30>
      if(copyout(myproc()->pagetable,pids+i*sizeof(int),(char*)&f,sizeof(int))<0){
    80002be0:	c25fe0ef          	jal	ra,80001804 <myproc>
    80002be4:	00249793          	slli	a5,s1,0x2
    80002be8:	4691                	li	a3,4
    80002bea:	fcc40613          	addi	a2,s0,-52
    80002bee:	fd043583          	ld	a1,-48(s0)
    80002bf2:	95be                	add	a1,a1,a5
    80002bf4:	6928                	ld	a0,80(a0)
    80002bf6:	95dfe0ef          	jal	ra,80001552 <copyout>
    80002bfa:	fc0553e3          	bgez	a0,80002bc0 <sys_tfork2+0x30>
        return -1;
    80002bfe:	557d                	li	a0,-1
    80002c00:	a021                	j	80002c08 <sys_tfork2+0x78>
      return 0;
    80002c02:	4501                	li	a0,0
    80002c04:	a011                	j	80002c08 <sys_tfork2+0x78>
  }
  return n;
    80002c06:	853e                	mv	a0,a5
}
    80002c08:	70e2                	ld	ra,56(sp)
    80002c0a:	7442                	ld	s0,48(sp)
    80002c0c:	74a2                	ld	s1,40(sp)
    80002c0e:	6121                	addi	sp,sp,64
    80002c10:	8082                	ret

0000000080002c12 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c12:	7179                	addi	sp,sp,-48
    80002c14:	f406                	sd	ra,40(sp)
    80002c16:	f022                	sd	s0,32(sp)
    80002c18:	ec26                	sd	s1,24(sp)
    80002c1a:	e84a                	sd	s2,16(sp)
    80002c1c:	e44e                	sd	s3,8(sp)
    80002c1e:	e052                	sd	s4,0(sp)
    80002c20:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c22:	00005597          	auipc	a1,0x5
    80002c26:	8be58593          	addi	a1,a1,-1858 # 800074e0 <syscalls+0xf0>
    80002c2a:	00013517          	auipc	a0,0x13
    80002c2e:	db650513          	addi	a0,a0,-586 # 800159e0 <bcache>
    80002c32:	ebbfd0ef          	jal	ra,80000aec <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c36:	0001b797          	auipc	a5,0x1b
    80002c3a:	daa78793          	addi	a5,a5,-598 # 8001d9e0 <bcache+0x8000>
    80002c3e:	0001b717          	auipc	a4,0x1b
    80002c42:	00a70713          	addi	a4,a4,10 # 8001dc48 <bcache+0x8268>
    80002c46:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c4a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c4e:	00013497          	auipc	s1,0x13
    80002c52:	daa48493          	addi	s1,s1,-598 # 800159f8 <bcache+0x18>
    b->next = bcache.head.next;
    80002c56:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c58:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c5a:	00005a17          	auipc	s4,0x5
    80002c5e:	88ea0a13          	addi	s4,s4,-1906 # 800074e8 <syscalls+0xf8>
    b->next = bcache.head.next;
    80002c62:	2b893783          	ld	a5,696(s2)
    80002c66:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c68:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c6c:	85d2                	mv	a1,s4
    80002c6e:	01048513          	addi	a0,s1,16
    80002c72:	2fe010ef          	jal	ra,80003f70 <initsleeplock>
    bcache.head.next->prev = b;
    80002c76:	2b893783          	ld	a5,696(s2)
    80002c7a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c7c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c80:	45848493          	addi	s1,s1,1112
    80002c84:	fd349fe3          	bne	s1,s3,80002c62 <binit+0x50>
  }
}
    80002c88:	70a2                	ld	ra,40(sp)
    80002c8a:	7402                	ld	s0,32(sp)
    80002c8c:	64e2                	ld	s1,24(sp)
    80002c8e:	6942                	ld	s2,16(sp)
    80002c90:	69a2                	ld	s3,8(sp)
    80002c92:	6a02                	ld	s4,0(sp)
    80002c94:	6145                	addi	sp,sp,48
    80002c96:	8082                	ret

0000000080002c98 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002c98:	7179                	addi	sp,sp,-48
    80002c9a:	f406                	sd	ra,40(sp)
    80002c9c:	f022                	sd	s0,32(sp)
    80002c9e:	ec26                	sd	s1,24(sp)
    80002ca0:	e84a                	sd	s2,16(sp)
    80002ca2:	e44e                	sd	s3,8(sp)
    80002ca4:	1800                	addi	s0,sp,48
    80002ca6:	892a                	mv	s2,a0
    80002ca8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002caa:	00013517          	auipc	a0,0x13
    80002cae:	d3650513          	addi	a0,a0,-714 # 800159e0 <bcache>
    80002cb2:	ebbfd0ef          	jal	ra,80000b6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002cb6:	0001b497          	auipc	s1,0x1b
    80002cba:	fe24b483          	ld	s1,-30(s1) # 8001dc98 <bcache+0x82b8>
    80002cbe:	0001b797          	auipc	a5,0x1b
    80002cc2:	f8a78793          	addi	a5,a5,-118 # 8001dc48 <bcache+0x8268>
    80002cc6:	02f48b63          	beq	s1,a5,80002cfc <bread+0x64>
    80002cca:	873e                	mv	a4,a5
    80002ccc:	a021                	j	80002cd4 <bread+0x3c>
    80002cce:	68a4                	ld	s1,80(s1)
    80002cd0:	02e48663          	beq	s1,a4,80002cfc <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002cd4:	449c                	lw	a5,8(s1)
    80002cd6:	ff279ce3          	bne	a5,s2,80002cce <bread+0x36>
    80002cda:	44dc                	lw	a5,12(s1)
    80002cdc:	ff3799e3          	bne	a5,s3,80002cce <bread+0x36>
      b->refcnt++;
    80002ce0:	40bc                	lw	a5,64(s1)
    80002ce2:	2785                	addiw	a5,a5,1
    80002ce4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ce6:	00013517          	auipc	a0,0x13
    80002cea:	cfa50513          	addi	a0,a0,-774 # 800159e0 <bcache>
    80002cee:	f17fd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002cf2:	01048513          	addi	a0,s1,16
    80002cf6:	2b0010ef          	jal	ra,80003fa6 <acquiresleep>
      return b;
    80002cfa:	a889                	j	80002d4c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002cfc:	0001b497          	auipc	s1,0x1b
    80002d00:	f944b483          	ld	s1,-108(s1) # 8001dc90 <bcache+0x82b0>
    80002d04:	0001b797          	auipc	a5,0x1b
    80002d08:	f4478793          	addi	a5,a5,-188 # 8001dc48 <bcache+0x8268>
    80002d0c:	00f48863          	beq	s1,a5,80002d1c <bread+0x84>
    80002d10:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d12:	40bc                	lw	a5,64(s1)
    80002d14:	cb91                	beqz	a5,80002d28 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d16:	64a4                	ld	s1,72(s1)
    80002d18:	fee49de3          	bne	s1,a4,80002d12 <bread+0x7a>
  panic("bget: no buffers");
    80002d1c:	00004517          	auipc	a0,0x4
    80002d20:	7d450513          	addi	a0,a0,2004 # 800074f0 <syscalls+0x100>
    80002d24:	a67fd0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    80002d28:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d2c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d30:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d34:	4785                	li	a5,1
    80002d36:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d38:	00013517          	auipc	a0,0x13
    80002d3c:	ca850513          	addi	a0,a0,-856 # 800159e0 <bcache>
    80002d40:	ec5fd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002d44:	01048513          	addi	a0,s1,16
    80002d48:	25e010ef          	jal	ra,80003fa6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d4c:	409c                	lw	a5,0(s1)
    80002d4e:	cb89                	beqz	a5,80002d60 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d50:	8526                	mv	a0,s1
    80002d52:	70a2                	ld	ra,40(sp)
    80002d54:	7402                	ld	s0,32(sp)
    80002d56:	64e2                	ld	s1,24(sp)
    80002d58:	6942                	ld	s2,16(sp)
    80002d5a:	69a2                	ld	s3,8(sp)
    80002d5c:	6145                	addi	sp,sp,48
    80002d5e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d60:	4581                	li	a1,0
    80002d62:	8526                	mv	a0,s1
    80002d64:	1b9020ef          	jal	ra,8000571c <virtio_disk_rw>
    b->valid = 1;
    80002d68:	4785                	li	a5,1
    80002d6a:	c09c                	sw	a5,0(s1)
  return b;
    80002d6c:	b7d5                	j	80002d50 <bread+0xb8>

0000000080002d6e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002d6e:	1101                	addi	sp,sp,-32
    80002d70:	ec06                	sd	ra,24(sp)
    80002d72:	e822                	sd	s0,16(sp)
    80002d74:	e426                	sd	s1,8(sp)
    80002d76:	1000                	addi	s0,sp,32
    80002d78:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d7a:	0541                	addi	a0,a0,16
    80002d7c:	2a8010ef          	jal	ra,80004024 <holdingsleep>
    80002d80:	c911                	beqz	a0,80002d94 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d82:	4585                	li	a1,1
    80002d84:	8526                	mv	a0,s1
    80002d86:	197020ef          	jal	ra,8000571c <virtio_disk_rw>
}
    80002d8a:	60e2                	ld	ra,24(sp)
    80002d8c:	6442                	ld	s0,16(sp)
    80002d8e:	64a2                	ld	s1,8(sp)
    80002d90:	6105                	addi	sp,sp,32
    80002d92:	8082                	ret
    panic("bwrite");
    80002d94:	00004517          	auipc	a0,0x4
    80002d98:	77450513          	addi	a0,a0,1908 # 80007508 <syscalls+0x118>
    80002d9c:	9effd0ef          	jal	ra,8000078a <panic>

0000000080002da0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002da0:	1101                	addi	sp,sp,-32
    80002da2:	ec06                	sd	ra,24(sp)
    80002da4:	e822                	sd	s0,16(sp)
    80002da6:	e426                	sd	s1,8(sp)
    80002da8:	e04a                	sd	s2,0(sp)
    80002daa:	1000                	addi	s0,sp,32
    80002dac:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002dae:	01050913          	addi	s2,a0,16
    80002db2:	854a                	mv	a0,s2
    80002db4:	270010ef          	jal	ra,80004024 <holdingsleep>
    80002db8:	c13d                	beqz	a0,80002e1e <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002dba:	854a                	mv	a0,s2
    80002dbc:	230010ef          	jal	ra,80003fec <releasesleep>

  acquire(&bcache.lock);
    80002dc0:	00013517          	auipc	a0,0x13
    80002dc4:	c2050513          	addi	a0,a0,-992 # 800159e0 <bcache>
    80002dc8:	da5fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002dcc:	40bc                	lw	a5,64(s1)
    80002dce:	37fd                	addiw	a5,a5,-1
    80002dd0:	0007871b          	sext.w	a4,a5
    80002dd4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002dd6:	eb05                	bnez	a4,80002e06 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002dd8:	68bc                	ld	a5,80(s1)
    80002dda:	64b8                	ld	a4,72(s1)
    80002ddc:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002dde:	64bc                	ld	a5,72(s1)
    80002de0:	68b8                	ld	a4,80(s1)
    80002de2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002de4:	0001b797          	auipc	a5,0x1b
    80002de8:	bfc78793          	addi	a5,a5,-1028 # 8001d9e0 <bcache+0x8000>
    80002dec:	2b87b703          	ld	a4,696(a5)
    80002df0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002df2:	0001b717          	auipc	a4,0x1b
    80002df6:	e5670713          	addi	a4,a4,-426 # 8001dc48 <bcache+0x8268>
    80002dfa:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002dfc:	2b87b703          	ld	a4,696(a5)
    80002e00:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e02:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002e06:	00013517          	auipc	a0,0x13
    80002e0a:	bda50513          	addi	a0,a0,-1062 # 800159e0 <bcache>
    80002e0e:	df7fd0ef          	jal	ra,80000c04 <release>
}
    80002e12:	60e2                	ld	ra,24(sp)
    80002e14:	6442                	ld	s0,16(sp)
    80002e16:	64a2                	ld	s1,8(sp)
    80002e18:	6902                	ld	s2,0(sp)
    80002e1a:	6105                	addi	sp,sp,32
    80002e1c:	8082                	ret
    panic("brelse");
    80002e1e:	00004517          	auipc	a0,0x4
    80002e22:	6f250513          	addi	a0,a0,1778 # 80007510 <syscalls+0x120>
    80002e26:	965fd0ef          	jal	ra,8000078a <panic>

0000000080002e2a <bpin>:

void
bpin(struct buf *b) {
    80002e2a:	1101                	addi	sp,sp,-32
    80002e2c:	ec06                	sd	ra,24(sp)
    80002e2e:	e822                	sd	s0,16(sp)
    80002e30:	e426                	sd	s1,8(sp)
    80002e32:	1000                	addi	s0,sp,32
    80002e34:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e36:	00013517          	auipc	a0,0x13
    80002e3a:	baa50513          	addi	a0,a0,-1110 # 800159e0 <bcache>
    80002e3e:	d2ffd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt++;
    80002e42:	40bc                	lw	a5,64(s1)
    80002e44:	2785                	addiw	a5,a5,1
    80002e46:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e48:	00013517          	auipc	a0,0x13
    80002e4c:	b9850513          	addi	a0,a0,-1128 # 800159e0 <bcache>
    80002e50:	db5fd0ef          	jal	ra,80000c04 <release>
}
    80002e54:	60e2                	ld	ra,24(sp)
    80002e56:	6442                	ld	s0,16(sp)
    80002e58:	64a2                	ld	s1,8(sp)
    80002e5a:	6105                	addi	sp,sp,32
    80002e5c:	8082                	ret

0000000080002e5e <bunpin>:

void
bunpin(struct buf *b) {
    80002e5e:	1101                	addi	sp,sp,-32
    80002e60:	ec06                	sd	ra,24(sp)
    80002e62:	e822                	sd	s0,16(sp)
    80002e64:	e426                	sd	s1,8(sp)
    80002e66:	1000                	addi	s0,sp,32
    80002e68:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e6a:	00013517          	auipc	a0,0x13
    80002e6e:	b7650513          	addi	a0,a0,-1162 # 800159e0 <bcache>
    80002e72:	cfbfd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002e76:	40bc                	lw	a5,64(s1)
    80002e78:	37fd                	addiw	a5,a5,-1
    80002e7a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e7c:	00013517          	auipc	a0,0x13
    80002e80:	b6450513          	addi	a0,a0,-1180 # 800159e0 <bcache>
    80002e84:	d81fd0ef          	jal	ra,80000c04 <release>
}
    80002e88:	60e2                	ld	ra,24(sp)
    80002e8a:	6442                	ld	s0,16(sp)
    80002e8c:	64a2                	ld	s1,8(sp)
    80002e8e:	6105                	addi	sp,sp,32
    80002e90:	8082                	ret

0000000080002e92 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e92:	1101                	addi	sp,sp,-32
    80002e94:	ec06                	sd	ra,24(sp)
    80002e96:	e822                	sd	s0,16(sp)
    80002e98:	e426                	sd	s1,8(sp)
    80002e9a:	e04a                	sd	s2,0(sp)
    80002e9c:	1000                	addi	s0,sp,32
    80002e9e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ea0:	00d5d59b          	srliw	a1,a1,0xd
    80002ea4:	0001b797          	auipc	a5,0x1b
    80002ea8:	2187a783          	lw	a5,536(a5) # 8001e0bc <sb+0x1c>
    80002eac:	9dbd                	addw	a1,a1,a5
    80002eae:	debff0ef          	jal	ra,80002c98 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002eb2:	0074f713          	andi	a4,s1,7
    80002eb6:	4785                	li	a5,1
    80002eb8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002ebc:	14ce                	slli	s1,s1,0x33
    80002ebe:	90d9                	srli	s1,s1,0x36
    80002ec0:	00950733          	add	a4,a0,s1
    80002ec4:	05874703          	lbu	a4,88(a4)
    80002ec8:	00e7f6b3          	and	a3,a5,a4
    80002ecc:	c29d                	beqz	a3,80002ef2 <bfree+0x60>
    80002ece:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002ed0:	94aa                	add	s1,s1,a0
    80002ed2:	fff7c793          	not	a5,a5
    80002ed6:	8ff9                	and	a5,a5,a4
    80002ed8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002edc:	7d1000ef          	jal	ra,80003eac <log_write>
  brelse(bp);
    80002ee0:	854a                	mv	a0,s2
    80002ee2:	ebfff0ef          	jal	ra,80002da0 <brelse>
}
    80002ee6:	60e2                	ld	ra,24(sp)
    80002ee8:	6442                	ld	s0,16(sp)
    80002eea:	64a2                	ld	s1,8(sp)
    80002eec:	6902                	ld	s2,0(sp)
    80002eee:	6105                	addi	sp,sp,32
    80002ef0:	8082                	ret
    panic("freeing free block");
    80002ef2:	00004517          	auipc	a0,0x4
    80002ef6:	62650513          	addi	a0,a0,1574 # 80007518 <syscalls+0x128>
    80002efa:	891fd0ef          	jal	ra,8000078a <panic>

0000000080002efe <balloc>:
{
    80002efe:	711d                	addi	sp,sp,-96
    80002f00:	ec86                	sd	ra,88(sp)
    80002f02:	e8a2                	sd	s0,80(sp)
    80002f04:	e4a6                	sd	s1,72(sp)
    80002f06:	e0ca                	sd	s2,64(sp)
    80002f08:	fc4e                	sd	s3,56(sp)
    80002f0a:	f852                	sd	s4,48(sp)
    80002f0c:	f456                	sd	s5,40(sp)
    80002f0e:	f05a                	sd	s6,32(sp)
    80002f10:	ec5e                	sd	s7,24(sp)
    80002f12:	e862                	sd	s8,16(sp)
    80002f14:	e466                	sd	s9,8(sp)
    80002f16:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002f18:	0001b797          	auipc	a5,0x1b
    80002f1c:	18c7a783          	lw	a5,396(a5) # 8001e0a4 <sb+0x4>
    80002f20:	0e078163          	beqz	a5,80003002 <balloc+0x104>
    80002f24:	8baa                	mv	s7,a0
    80002f26:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f28:	0001bb17          	auipc	s6,0x1b
    80002f2c:	178b0b13          	addi	s6,s6,376 # 8001e0a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f30:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002f32:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f34:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f36:	6c89                	lui	s9,0x2
    80002f38:	a0b5                	j	80002fa4 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f3a:	974a                	add	a4,a4,s2
    80002f3c:	8fd5                	or	a5,a5,a3
    80002f3e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002f42:	854a                	mv	a0,s2
    80002f44:	769000ef          	jal	ra,80003eac <log_write>
        brelse(bp);
    80002f48:	854a                	mv	a0,s2
    80002f4a:	e57ff0ef          	jal	ra,80002da0 <brelse>
  bp = bread(dev, bno);
    80002f4e:	85a6                	mv	a1,s1
    80002f50:	855e                	mv	a0,s7
    80002f52:	d47ff0ef          	jal	ra,80002c98 <bread>
    80002f56:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f58:	40000613          	li	a2,1024
    80002f5c:	4581                	li	a1,0
    80002f5e:	05850513          	addi	a0,a0,88
    80002f62:	cdffd0ef          	jal	ra,80000c40 <memset>
  log_write(bp);
    80002f66:	854a                	mv	a0,s2
    80002f68:	745000ef          	jal	ra,80003eac <log_write>
  brelse(bp);
    80002f6c:	854a                	mv	a0,s2
    80002f6e:	e33ff0ef          	jal	ra,80002da0 <brelse>
}
    80002f72:	8526                	mv	a0,s1
    80002f74:	60e6                	ld	ra,88(sp)
    80002f76:	6446                	ld	s0,80(sp)
    80002f78:	64a6                	ld	s1,72(sp)
    80002f7a:	6906                	ld	s2,64(sp)
    80002f7c:	79e2                	ld	s3,56(sp)
    80002f7e:	7a42                	ld	s4,48(sp)
    80002f80:	7aa2                	ld	s5,40(sp)
    80002f82:	7b02                	ld	s6,32(sp)
    80002f84:	6be2                	ld	s7,24(sp)
    80002f86:	6c42                	ld	s8,16(sp)
    80002f88:	6ca2                	ld	s9,8(sp)
    80002f8a:	6125                	addi	sp,sp,96
    80002f8c:	8082                	ret
    brelse(bp);
    80002f8e:	854a                	mv	a0,s2
    80002f90:	e11ff0ef          	jal	ra,80002da0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002f94:	015c87bb          	addw	a5,s9,s5
    80002f98:	00078a9b          	sext.w	s5,a5
    80002f9c:	004b2703          	lw	a4,4(s6)
    80002fa0:	06eaf163          	bgeu	s5,a4,80003002 <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80002fa4:	41fad79b          	sraiw	a5,s5,0x1f
    80002fa8:	0137d79b          	srliw	a5,a5,0x13
    80002fac:	015787bb          	addw	a5,a5,s5
    80002fb0:	40d7d79b          	sraiw	a5,a5,0xd
    80002fb4:	01cb2583          	lw	a1,28(s6)
    80002fb8:	9dbd                	addw	a1,a1,a5
    80002fba:	855e                	mv	a0,s7
    80002fbc:	cddff0ef          	jal	ra,80002c98 <bread>
    80002fc0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fc2:	004b2503          	lw	a0,4(s6)
    80002fc6:	000a849b          	sext.w	s1,s5
    80002fca:	8662                	mv	a2,s8
    80002fcc:	fca4f1e3          	bgeu	s1,a0,80002f8e <balloc+0x90>
      m = 1 << (bi % 8);
    80002fd0:	41f6579b          	sraiw	a5,a2,0x1f
    80002fd4:	01d7d69b          	srliw	a3,a5,0x1d
    80002fd8:	00c6873b          	addw	a4,a3,a2
    80002fdc:	00777793          	andi	a5,a4,7
    80002fe0:	9f95                	subw	a5,a5,a3
    80002fe2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002fe6:	4037571b          	sraiw	a4,a4,0x3
    80002fea:	00e906b3          	add	a3,s2,a4
    80002fee:	0586c683          	lbu	a3,88(a3) # 1058 <_entry-0x7fffefa8>
    80002ff2:	00d7f5b3          	and	a1,a5,a3
    80002ff6:	d1b1                	beqz	a1,80002f3a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ff8:	2605                	addiw	a2,a2,1
    80002ffa:	2485                	addiw	s1,s1,1
    80002ffc:	fd4618e3          	bne	a2,s4,80002fcc <balloc+0xce>
    80003000:	b779                	j	80002f8e <balloc+0x90>
  printf("balloc: out of blocks\n");
    80003002:	00004517          	auipc	a0,0x4
    80003006:	52e50513          	addi	a0,a0,1326 # 80007530 <syscalls+0x140>
    8000300a:	cbafd0ef          	jal	ra,800004c4 <printf>
  return 0;
    8000300e:	4481                	li	s1,0
    80003010:	b78d                	j	80002f72 <balloc+0x74>

0000000080003012 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003012:	7179                	addi	sp,sp,-48
    80003014:	f406                	sd	ra,40(sp)
    80003016:	f022                	sd	s0,32(sp)
    80003018:	ec26                	sd	s1,24(sp)
    8000301a:	e84a                	sd	s2,16(sp)
    8000301c:	e44e                	sd	s3,8(sp)
    8000301e:	e052                	sd	s4,0(sp)
    80003020:	1800                	addi	s0,sp,48
    80003022:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003024:	47ad                	li	a5,11
    80003026:	02b7e563          	bltu	a5,a1,80003050 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000302a:	02059493          	slli	s1,a1,0x20
    8000302e:	9081                	srli	s1,s1,0x20
    80003030:	048a                	slli	s1,s1,0x2
    80003032:	94aa                	add	s1,s1,a0
    80003034:	0504a903          	lw	s2,80(s1)
    80003038:	06091663          	bnez	s2,800030a4 <bmap+0x92>
      addr = balloc(ip->dev);
    8000303c:	4108                	lw	a0,0(a0)
    8000303e:	ec1ff0ef          	jal	ra,80002efe <balloc>
    80003042:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003046:	04090f63          	beqz	s2,800030a4 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    8000304a:	0524a823          	sw	s2,80(s1)
    8000304e:	a899                	j	800030a4 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003050:	ff45849b          	addiw	s1,a1,-12
    80003054:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003058:	0ff00793          	li	a5,255
    8000305c:	06e7eb63          	bltu	a5,a4,800030d2 <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003060:	08052903          	lw	s2,128(a0)
    80003064:	00091b63          	bnez	s2,8000307a <bmap+0x68>
      addr = balloc(ip->dev);
    80003068:	4108                	lw	a0,0(a0)
    8000306a:	e95ff0ef          	jal	ra,80002efe <balloc>
    8000306e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003072:	02090963          	beqz	s2,800030a4 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003076:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000307a:	85ca                	mv	a1,s2
    8000307c:	0009a503          	lw	a0,0(s3)
    80003080:	c19ff0ef          	jal	ra,80002c98 <bread>
    80003084:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003086:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000308a:	02049593          	slli	a1,s1,0x20
    8000308e:	9181                	srli	a1,a1,0x20
    80003090:	058a                	slli	a1,a1,0x2
    80003092:	00b784b3          	add	s1,a5,a1
    80003096:	0004a903          	lw	s2,0(s1)
    8000309a:	00090e63          	beqz	s2,800030b6 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000309e:	8552                	mv	a0,s4
    800030a0:	d01ff0ef          	jal	ra,80002da0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800030a4:	854a                	mv	a0,s2
    800030a6:	70a2                	ld	ra,40(sp)
    800030a8:	7402                	ld	s0,32(sp)
    800030aa:	64e2                	ld	s1,24(sp)
    800030ac:	6942                	ld	s2,16(sp)
    800030ae:	69a2                	ld	s3,8(sp)
    800030b0:	6a02                	ld	s4,0(sp)
    800030b2:	6145                	addi	sp,sp,48
    800030b4:	8082                	ret
      addr = balloc(ip->dev);
    800030b6:	0009a503          	lw	a0,0(s3)
    800030ba:	e45ff0ef          	jal	ra,80002efe <balloc>
    800030be:	0005091b          	sext.w	s2,a0
      if(addr){
    800030c2:	fc090ee3          	beqz	s2,8000309e <bmap+0x8c>
        a[bn] = addr;
    800030c6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800030ca:	8552                	mv	a0,s4
    800030cc:	5e1000ef          	jal	ra,80003eac <log_write>
    800030d0:	b7f9                	j	8000309e <bmap+0x8c>
  panic("bmap: out of range");
    800030d2:	00004517          	auipc	a0,0x4
    800030d6:	47650513          	addi	a0,a0,1142 # 80007548 <syscalls+0x158>
    800030da:	eb0fd0ef          	jal	ra,8000078a <panic>

00000000800030de <iget>:
{
    800030de:	7179                	addi	sp,sp,-48
    800030e0:	f406                	sd	ra,40(sp)
    800030e2:	f022                	sd	s0,32(sp)
    800030e4:	ec26                	sd	s1,24(sp)
    800030e6:	e84a                	sd	s2,16(sp)
    800030e8:	e44e                	sd	s3,8(sp)
    800030ea:	e052                	sd	s4,0(sp)
    800030ec:	1800                	addi	s0,sp,48
    800030ee:	89aa                	mv	s3,a0
    800030f0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800030f2:	0001b517          	auipc	a0,0x1b
    800030f6:	fce50513          	addi	a0,a0,-50 # 8001e0c0 <itable>
    800030fa:	a73fd0ef          	jal	ra,80000b6c <acquire>
  empty = 0;
    800030fe:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003100:	0001b497          	auipc	s1,0x1b
    80003104:	fd848493          	addi	s1,s1,-40 # 8001e0d8 <itable+0x18>
    80003108:	0001d697          	auipc	a3,0x1d
    8000310c:	a6068693          	addi	a3,a3,-1440 # 8001fb68 <log>
    80003110:	a039                	j	8000311e <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003112:	02090963          	beqz	s2,80003144 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003116:	08848493          	addi	s1,s1,136
    8000311a:	02d48863          	beq	s1,a3,8000314a <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000311e:	449c                	lw	a5,8(s1)
    80003120:	fef059e3          	blez	a5,80003112 <iget+0x34>
    80003124:	4098                	lw	a4,0(s1)
    80003126:	ff3716e3          	bne	a4,s3,80003112 <iget+0x34>
    8000312a:	40d8                	lw	a4,4(s1)
    8000312c:	ff4713e3          	bne	a4,s4,80003112 <iget+0x34>
      ip->ref++;
    80003130:	2785                	addiw	a5,a5,1
    80003132:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003134:	0001b517          	auipc	a0,0x1b
    80003138:	f8c50513          	addi	a0,a0,-116 # 8001e0c0 <itable>
    8000313c:	ac9fd0ef          	jal	ra,80000c04 <release>
      return ip;
    80003140:	8926                	mv	s2,s1
    80003142:	a02d                	j	8000316c <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003144:	fbe9                	bnez	a5,80003116 <iget+0x38>
    80003146:	8926                	mv	s2,s1
    80003148:	b7f9                	j	80003116 <iget+0x38>
  if(empty == 0)
    8000314a:	02090a63          	beqz	s2,8000317e <iget+0xa0>
  ip->dev = dev;
    8000314e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003152:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003156:	4785                	li	a5,1
    80003158:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000315c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003160:	0001b517          	auipc	a0,0x1b
    80003164:	f6050513          	addi	a0,a0,-160 # 8001e0c0 <itable>
    80003168:	a9dfd0ef          	jal	ra,80000c04 <release>
}
    8000316c:	854a                	mv	a0,s2
    8000316e:	70a2                	ld	ra,40(sp)
    80003170:	7402                	ld	s0,32(sp)
    80003172:	64e2                	ld	s1,24(sp)
    80003174:	6942                	ld	s2,16(sp)
    80003176:	69a2                	ld	s3,8(sp)
    80003178:	6a02                	ld	s4,0(sp)
    8000317a:	6145                	addi	sp,sp,48
    8000317c:	8082                	ret
    panic("iget: no inodes");
    8000317e:	00004517          	auipc	a0,0x4
    80003182:	3e250513          	addi	a0,a0,994 # 80007560 <syscalls+0x170>
    80003186:	e04fd0ef          	jal	ra,8000078a <panic>

000000008000318a <iinit>:
{
    8000318a:	7179                	addi	sp,sp,-48
    8000318c:	f406                	sd	ra,40(sp)
    8000318e:	f022                	sd	s0,32(sp)
    80003190:	ec26                	sd	s1,24(sp)
    80003192:	e84a                	sd	s2,16(sp)
    80003194:	e44e                	sd	s3,8(sp)
    80003196:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003198:	00004597          	auipc	a1,0x4
    8000319c:	3d858593          	addi	a1,a1,984 # 80007570 <syscalls+0x180>
    800031a0:	0001b517          	auipc	a0,0x1b
    800031a4:	f2050513          	addi	a0,a0,-224 # 8001e0c0 <itable>
    800031a8:	945fd0ef          	jal	ra,80000aec <initlock>
  for(i = 0; i < NINODE; i++) {
    800031ac:	0001b497          	auipc	s1,0x1b
    800031b0:	f3c48493          	addi	s1,s1,-196 # 8001e0e8 <itable+0x28>
    800031b4:	0001d997          	auipc	s3,0x1d
    800031b8:	9c498993          	addi	s3,s3,-1596 # 8001fb78 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800031bc:	00004917          	auipc	s2,0x4
    800031c0:	3bc90913          	addi	s2,s2,956 # 80007578 <syscalls+0x188>
    800031c4:	85ca                	mv	a1,s2
    800031c6:	8526                	mv	a0,s1
    800031c8:	5a9000ef          	jal	ra,80003f70 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800031cc:	08848493          	addi	s1,s1,136
    800031d0:	ff349ae3          	bne	s1,s3,800031c4 <iinit+0x3a>
}
    800031d4:	70a2                	ld	ra,40(sp)
    800031d6:	7402                	ld	s0,32(sp)
    800031d8:	64e2                	ld	s1,24(sp)
    800031da:	6942                	ld	s2,16(sp)
    800031dc:	69a2                	ld	s3,8(sp)
    800031de:	6145                	addi	sp,sp,48
    800031e0:	8082                	ret

00000000800031e2 <ialloc>:
{
    800031e2:	715d                	addi	sp,sp,-80
    800031e4:	e486                	sd	ra,72(sp)
    800031e6:	e0a2                	sd	s0,64(sp)
    800031e8:	fc26                	sd	s1,56(sp)
    800031ea:	f84a                	sd	s2,48(sp)
    800031ec:	f44e                	sd	s3,40(sp)
    800031ee:	f052                	sd	s4,32(sp)
    800031f0:	ec56                	sd	s5,24(sp)
    800031f2:	e85a                	sd	s6,16(sp)
    800031f4:	e45e                	sd	s7,8(sp)
    800031f6:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800031f8:	0001b717          	auipc	a4,0x1b
    800031fc:	eb472703          	lw	a4,-332(a4) # 8001e0ac <sb+0xc>
    80003200:	4785                	li	a5,1
    80003202:	04e7f663          	bgeu	a5,a4,8000324e <ialloc+0x6c>
    80003206:	8aaa                	mv	s5,a0
    80003208:	8bae                	mv	s7,a1
    8000320a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000320c:	0001ba17          	auipc	s4,0x1b
    80003210:	e94a0a13          	addi	s4,s4,-364 # 8001e0a0 <sb>
    80003214:	00048b1b          	sext.w	s6,s1
    80003218:	0044d793          	srli	a5,s1,0x4
    8000321c:	018a2583          	lw	a1,24(s4)
    80003220:	9dbd                	addw	a1,a1,a5
    80003222:	8556                	mv	a0,s5
    80003224:	a75ff0ef          	jal	ra,80002c98 <bread>
    80003228:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000322a:	05850993          	addi	s3,a0,88
    8000322e:	00f4f793          	andi	a5,s1,15
    80003232:	079a                	slli	a5,a5,0x6
    80003234:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003236:	00099783          	lh	a5,0(s3)
    8000323a:	cf85                	beqz	a5,80003272 <ialloc+0x90>
    brelse(bp);
    8000323c:	b65ff0ef          	jal	ra,80002da0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003240:	0485                	addi	s1,s1,1
    80003242:	00ca2703          	lw	a4,12(s4)
    80003246:	0004879b          	sext.w	a5,s1
    8000324a:	fce7e5e3          	bltu	a5,a4,80003214 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000324e:	00004517          	auipc	a0,0x4
    80003252:	33250513          	addi	a0,a0,818 # 80007580 <syscalls+0x190>
    80003256:	a6efd0ef          	jal	ra,800004c4 <printf>
  return 0;
    8000325a:	4501                	li	a0,0
}
    8000325c:	60a6                	ld	ra,72(sp)
    8000325e:	6406                	ld	s0,64(sp)
    80003260:	74e2                	ld	s1,56(sp)
    80003262:	7942                	ld	s2,48(sp)
    80003264:	79a2                	ld	s3,40(sp)
    80003266:	7a02                	ld	s4,32(sp)
    80003268:	6ae2                	ld	s5,24(sp)
    8000326a:	6b42                	ld	s6,16(sp)
    8000326c:	6ba2                	ld	s7,8(sp)
    8000326e:	6161                	addi	sp,sp,80
    80003270:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003272:	04000613          	li	a2,64
    80003276:	4581                	li	a1,0
    80003278:	854e                	mv	a0,s3
    8000327a:	9c7fd0ef          	jal	ra,80000c40 <memset>
      dip->type = type;
    8000327e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003282:	854a                	mv	a0,s2
    80003284:	429000ef          	jal	ra,80003eac <log_write>
      brelse(bp);
    80003288:	854a                	mv	a0,s2
    8000328a:	b17ff0ef          	jal	ra,80002da0 <brelse>
      return iget(dev, inum);
    8000328e:	85da                	mv	a1,s6
    80003290:	8556                	mv	a0,s5
    80003292:	e4dff0ef          	jal	ra,800030de <iget>
    80003296:	b7d9                	j	8000325c <ialloc+0x7a>

0000000080003298 <iupdate>:
{
    80003298:	1101                	addi	sp,sp,-32
    8000329a:	ec06                	sd	ra,24(sp)
    8000329c:	e822                	sd	s0,16(sp)
    8000329e:	e426                	sd	s1,8(sp)
    800032a0:	e04a                	sd	s2,0(sp)
    800032a2:	1000                	addi	s0,sp,32
    800032a4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032a6:	415c                	lw	a5,4(a0)
    800032a8:	0047d79b          	srliw	a5,a5,0x4
    800032ac:	0001b597          	auipc	a1,0x1b
    800032b0:	e0c5a583          	lw	a1,-500(a1) # 8001e0b8 <sb+0x18>
    800032b4:	9dbd                	addw	a1,a1,a5
    800032b6:	4108                	lw	a0,0(a0)
    800032b8:	9e1ff0ef          	jal	ra,80002c98 <bread>
    800032bc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032be:	05850793          	addi	a5,a0,88
    800032c2:	40c8                	lw	a0,4(s1)
    800032c4:	893d                	andi	a0,a0,15
    800032c6:	051a                	slli	a0,a0,0x6
    800032c8:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800032ca:	04449703          	lh	a4,68(s1)
    800032ce:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800032d2:	04649703          	lh	a4,70(s1)
    800032d6:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800032da:	04849703          	lh	a4,72(s1)
    800032de:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800032e2:	04a49703          	lh	a4,74(s1)
    800032e6:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800032ea:	44f8                	lw	a4,76(s1)
    800032ec:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800032ee:	03400613          	li	a2,52
    800032f2:	05048593          	addi	a1,s1,80
    800032f6:	0531                	addi	a0,a0,12
    800032f8:	9a5fd0ef          	jal	ra,80000c9c <memmove>
  log_write(bp);
    800032fc:	854a                	mv	a0,s2
    800032fe:	3af000ef          	jal	ra,80003eac <log_write>
  brelse(bp);
    80003302:	854a                	mv	a0,s2
    80003304:	a9dff0ef          	jal	ra,80002da0 <brelse>
}
    80003308:	60e2                	ld	ra,24(sp)
    8000330a:	6442                	ld	s0,16(sp)
    8000330c:	64a2                	ld	s1,8(sp)
    8000330e:	6902                	ld	s2,0(sp)
    80003310:	6105                	addi	sp,sp,32
    80003312:	8082                	ret

0000000080003314 <idup>:
{
    80003314:	1101                	addi	sp,sp,-32
    80003316:	ec06                	sd	ra,24(sp)
    80003318:	e822                	sd	s0,16(sp)
    8000331a:	e426                	sd	s1,8(sp)
    8000331c:	1000                	addi	s0,sp,32
    8000331e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003320:	0001b517          	auipc	a0,0x1b
    80003324:	da050513          	addi	a0,a0,-608 # 8001e0c0 <itable>
    80003328:	845fd0ef          	jal	ra,80000b6c <acquire>
  ip->ref++;
    8000332c:	449c                	lw	a5,8(s1)
    8000332e:	2785                	addiw	a5,a5,1
    80003330:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003332:	0001b517          	auipc	a0,0x1b
    80003336:	d8e50513          	addi	a0,a0,-626 # 8001e0c0 <itable>
    8000333a:	8cbfd0ef          	jal	ra,80000c04 <release>
}
    8000333e:	8526                	mv	a0,s1
    80003340:	60e2                	ld	ra,24(sp)
    80003342:	6442                	ld	s0,16(sp)
    80003344:	64a2                	ld	s1,8(sp)
    80003346:	6105                	addi	sp,sp,32
    80003348:	8082                	ret

000000008000334a <ilock>:
{
    8000334a:	1101                	addi	sp,sp,-32
    8000334c:	ec06                	sd	ra,24(sp)
    8000334e:	e822                	sd	s0,16(sp)
    80003350:	e426                	sd	s1,8(sp)
    80003352:	e04a                	sd	s2,0(sp)
    80003354:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003356:	c105                	beqz	a0,80003376 <ilock+0x2c>
    80003358:	84aa                	mv	s1,a0
    8000335a:	451c                	lw	a5,8(a0)
    8000335c:	00f05d63          	blez	a5,80003376 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003360:	0541                	addi	a0,a0,16
    80003362:	445000ef          	jal	ra,80003fa6 <acquiresleep>
  if(ip->valid == 0){
    80003366:	40bc                	lw	a5,64(s1)
    80003368:	cf89                	beqz	a5,80003382 <ilock+0x38>
}
    8000336a:	60e2                	ld	ra,24(sp)
    8000336c:	6442                	ld	s0,16(sp)
    8000336e:	64a2                	ld	s1,8(sp)
    80003370:	6902                	ld	s2,0(sp)
    80003372:	6105                	addi	sp,sp,32
    80003374:	8082                	ret
    panic("ilock");
    80003376:	00004517          	auipc	a0,0x4
    8000337a:	22250513          	addi	a0,a0,546 # 80007598 <syscalls+0x1a8>
    8000337e:	c0cfd0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003382:	40dc                	lw	a5,4(s1)
    80003384:	0047d79b          	srliw	a5,a5,0x4
    80003388:	0001b597          	auipc	a1,0x1b
    8000338c:	d305a583          	lw	a1,-720(a1) # 8001e0b8 <sb+0x18>
    80003390:	9dbd                	addw	a1,a1,a5
    80003392:	4088                	lw	a0,0(s1)
    80003394:	905ff0ef          	jal	ra,80002c98 <bread>
    80003398:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000339a:	05850593          	addi	a1,a0,88
    8000339e:	40dc                	lw	a5,4(s1)
    800033a0:	8bbd                	andi	a5,a5,15
    800033a2:	079a                	slli	a5,a5,0x6
    800033a4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033a6:	00059783          	lh	a5,0(a1)
    800033aa:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033ae:	00259783          	lh	a5,2(a1)
    800033b2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033b6:	00459783          	lh	a5,4(a1)
    800033ba:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033be:	00659783          	lh	a5,6(a1)
    800033c2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800033c6:	459c                	lw	a5,8(a1)
    800033c8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033ca:	03400613          	li	a2,52
    800033ce:	05b1                	addi	a1,a1,12
    800033d0:	05048513          	addi	a0,s1,80
    800033d4:	8c9fd0ef          	jal	ra,80000c9c <memmove>
    brelse(bp);
    800033d8:	854a                	mv	a0,s2
    800033da:	9c7ff0ef          	jal	ra,80002da0 <brelse>
    ip->valid = 1;
    800033de:	4785                	li	a5,1
    800033e0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800033e2:	04449783          	lh	a5,68(s1)
    800033e6:	f3d1                	bnez	a5,8000336a <ilock+0x20>
      panic("ilock: no type");
    800033e8:	00004517          	auipc	a0,0x4
    800033ec:	1b850513          	addi	a0,a0,440 # 800075a0 <syscalls+0x1b0>
    800033f0:	b9afd0ef          	jal	ra,8000078a <panic>

00000000800033f4 <iunlock>:
{
    800033f4:	1101                	addi	sp,sp,-32
    800033f6:	ec06                	sd	ra,24(sp)
    800033f8:	e822                	sd	s0,16(sp)
    800033fa:	e426                	sd	s1,8(sp)
    800033fc:	e04a                	sd	s2,0(sp)
    800033fe:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003400:	c505                	beqz	a0,80003428 <iunlock+0x34>
    80003402:	84aa                	mv	s1,a0
    80003404:	01050913          	addi	s2,a0,16
    80003408:	854a                	mv	a0,s2
    8000340a:	41b000ef          	jal	ra,80004024 <holdingsleep>
    8000340e:	cd09                	beqz	a0,80003428 <iunlock+0x34>
    80003410:	449c                	lw	a5,8(s1)
    80003412:	00f05b63          	blez	a5,80003428 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003416:	854a                	mv	a0,s2
    80003418:	3d5000ef          	jal	ra,80003fec <releasesleep>
}
    8000341c:	60e2                	ld	ra,24(sp)
    8000341e:	6442                	ld	s0,16(sp)
    80003420:	64a2                	ld	s1,8(sp)
    80003422:	6902                	ld	s2,0(sp)
    80003424:	6105                	addi	sp,sp,32
    80003426:	8082                	ret
    panic("iunlock");
    80003428:	00004517          	auipc	a0,0x4
    8000342c:	18850513          	addi	a0,a0,392 # 800075b0 <syscalls+0x1c0>
    80003430:	b5afd0ef          	jal	ra,8000078a <panic>

0000000080003434 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003434:	7179                	addi	sp,sp,-48
    80003436:	f406                	sd	ra,40(sp)
    80003438:	f022                	sd	s0,32(sp)
    8000343a:	ec26                	sd	s1,24(sp)
    8000343c:	e84a                	sd	s2,16(sp)
    8000343e:	e44e                	sd	s3,8(sp)
    80003440:	e052                	sd	s4,0(sp)
    80003442:	1800                	addi	s0,sp,48
    80003444:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003446:	05050493          	addi	s1,a0,80
    8000344a:	08050913          	addi	s2,a0,128
    8000344e:	a021                	j	80003456 <itrunc+0x22>
    80003450:	0491                	addi	s1,s1,4
    80003452:	01248b63          	beq	s1,s2,80003468 <itrunc+0x34>
    if(ip->addrs[i]){
    80003456:	408c                	lw	a1,0(s1)
    80003458:	dde5                	beqz	a1,80003450 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000345a:	0009a503          	lw	a0,0(s3)
    8000345e:	a35ff0ef          	jal	ra,80002e92 <bfree>
      ip->addrs[i] = 0;
    80003462:	0004a023          	sw	zero,0(s1)
    80003466:	b7ed                	j	80003450 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003468:	0809a583          	lw	a1,128(s3)
    8000346c:	ed91                	bnez	a1,80003488 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000346e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003472:	854e                	mv	a0,s3
    80003474:	e25ff0ef          	jal	ra,80003298 <iupdate>
}
    80003478:	70a2                	ld	ra,40(sp)
    8000347a:	7402                	ld	s0,32(sp)
    8000347c:	64e2                	ld	s1,24(sp)
    8000347e:	6942                	ld	s2,16(sp)
    80003480:	69a2                	ld	s3,8(sp)
    80003482:	6a02                	ld	s4,0(sp)
    80003484:	6145                	addi	sp,sp,48
    80003486:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003488:	0009a503          	lw	a0,0(s3)
    8000348c:	80dff0ef          	jal	ra,80002c98 <bread>
    80003490:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003492:	05850493          	addi	s1,a0,88
    80003496:	45850913          	addi	s2,a0,1112
    8000349a:	a021                	j	800034a2 <itrunc+0x6e>
    8000349c:	0491                	addi	s1,s1,4
    8000349e:	01248963          	beq	s1,s2,800034b0 <itrunc+0x7c>
      if(a[j])
    800034a2:	408c                	lw	a1,0(s1)
    800034a4:	dde5                	beqz	a1,8000349c <itrunc+0x68>
        bfree(ip->dev, a[j]);
    800034a6:	0009a503          	lw	a0,0(s3)
    800034aa:	9e9ff0ef          	jal	ra,80002e92 <bfree>
    800034ae:	b7fd                	j	8000349c <itrunc+0x68>
    brelse(bp);
    800034b0:	8552                	mv	a0,s4
    800034b2:	8efff0ef          	jal	ra,80002da0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800034b6:	0809a583          	lw	a1,128(s3)
    800034ba:	0009a503          	lw	a0,0(s3)
    800034be:	9d5ff0ef          	jal	ra,80002e92 <bfree>
    ip->addrs[NDIRECT] = 0;
    800034c2:	0809a023          	sw	zero,128(s3)
    800034c6:	b765                	j	8000346e <itrunc+0x3a>

00000000800034c8 <iput>:
{
    800034c8:	1101                	addi	sp,sp,-32
    800034ca:	ec06                	sd	ra,24(sp)
    800034cc:	e822                	sd	s0,16(sp)
    800034ce:	e426                	sd	s1,8(sp)
    800034d0:	e04a                	sd	s2,0(sp)
    800034d2:	1000                	addi	s0,sp,32
    800034d4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034d6:	0001b517          	auipc	a0,0x1b
    800034da:	bea50513          	addi	a0,a0,-1046 # 8001e0c0 <itable>
    800034de:	e8efd0ef          	jal	ra,80000b6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034e2:	4498                	lw	a4,8(s1)
    800034e4:	4785                	li	a5,1
    800034e6:	02f70163          	beq	a4,a5,80003508 <iput+0x40>
  ip->ref--;
    800034ea:	449c                	lw	a5,8(s1)
    800034ec:	37fd                	addiw	a5,a5,-1
    800034ee:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034f0:	0001b517          	auipc	a0,0x1b
    800034f4:	bd050513          	addi	a0,a0,-1072 # 8001e0c0 <itable>
    800034f8:	f0cfd0ef          	jal	ra,80000c04 <release>
}
    800034fc:	60e2                	ld	ra,24(sp)
    800034fe:	6442                	ld	s0,16(sp)
    80003500:	64a2                	ld	s1,8(sp)
    80003502:	6902                	ld	s2,0(sp)
    80003504:	6105                	addi	sp,sp,32
    80003506:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003508:	40bc                	lw	a5,64(s1)
    8000350a:	d3e5                	beqz	a5,800034ea <iput+0x22>
    8000350c:	04a49783          	lh	a5,74(s1)
    80003510:	ffe9                	bnez	a5,800034ea <iput+0x22>
    acquiresleep(&ip->lock);
    80003512:	01048913          	addi	s2,s1,16
    80003516:	854a                	mv	a0,s2
    80003518:	28f000ef          	jal	ra,80003fa6 <acquiresleep>
    release(&itable.lock);
    8000351c:	0001b517          	auipc	a0,0x1b
    80003520:	ba450513          	addi	a0,a0,-1116 # 8001e0c0 <itable>
    80003524:	ee0fd0ef          	jal	ra,80000c04 <release>
    itrunc(ip);
    80003528:	8526                	mv	a0,s1
    8000352a:	f0bff0ef          	jal	ra,80003434 <itrunc>
    ip->type = 0;
    8000352e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003532:	8526                	mv	a0,s1
    80003534:	d65ff0ef          	jal	ra,80003298 <iupdate>
    ip->valid = 0;
    80003538:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000353c:	854a                	mv	a0,s2
    8000353e:	2af000ef          	jal	ra,80003fec <releasesleep>
    acquire(&itable.lock);
    80003542:	0001b517          	auipc	a0,0x1b
    80003546:	b7e50513          	addi	a0,a0,-1154 # 8001e0c0 <itable>
    8000354a:	e22fd0ef          	jal	ra,80000b6c <acquire>
    8000354e:	bf71                	j	800034ea <iput+0x22>

0000000080003550 <iunlockput>:
{
    80003550:	1101                	addi	sp,sp,-32
    80003552:	ec06                	sd	ra,24(sp)
    80003554:	e822                	sd	s0,16(sp)
    80003556:	e426                	sd	s1,8(sp)
    80003558:	1000                	addi	s0,sp,32
    8000355a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000355c:	e99ff0ef          	jal	ra,800033f4 <iunlock>
  iput(ip);
    80003560:	8526                	mv	a0,s1
    80003562:	f67ff0ef          	jal	ra,800034c8 <iput>
}
    80003566:	60e2                	ld	ra,24(sp)
    80003568:	6442                	ld	s0,16(sp)
    8000356a:	64a2                	ld	s1,8(sp)
    8000356c:	6105                	addi	sp,sp,32
    8000356e:	8082                	ret

0000000080003570 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003570:	0001b717          	auipc	a4,0x1b
    80003574:	b3c72703          	lw	a4,-1220(a4) # 8001e0ac <sb+0xc>
    80003578:	4785                	li	a5,1
    8000357a:	0ae7ff63          	bgeu	a5,a4,80003638 <ireclaim+0xc8>
{
    8000357e:	7139                	addi	sp,sp,-64
    80003580:	fc06                	sd	ra,56(sp)
    80003582:	f822                	sd	s0,48(sp)
    80003584:	f426                	sd	s1,40(sp)
    80003586:	f04a                	sd	s2,32(sp)
    80003588:	ec4e                	sd	s3,24(sp)
    8000358a:	e852                	sd	s4,16(sp)
    8000358c:	e456                	sd	s5,8(sp)
    8000358e:	e05a                	sd	s6,0(sp)
    80003590:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003592:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003594:	00050a1b          	sext.w	s4,a0
    80003598:	0001ba97          	auipc	s5,0x1b
    8000359c:	b08a8a93          	addi	s5,s5,-1272 # 8001e0a0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800035a0:	00004b17          	auipc	s6,0x4
    800035a4:	018b0b13          	addi	s6,s6,24 # 800075b8 <syscalls+0x1c8>
    800035a8:	a099                	j	800035ee <ireclaim+0x7e>
    800035aa:	85ce                	mv	a1,s3
    800035ac:	855a                	mv	a0,s6
    800035ae:	f17fc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    800035b2:	85ce                	mv	a1,s3
    800035b4:	8552                	mv	a0,s4
    800035b6:	b29ff0ef          	jal	ra,800030de <iget>
    800035ba:	89aa                	mv	s3,a0
    brelse(bp);
    800035bc:	854a                	mv	a0,s2
    800035be:	fe2ff0ef          	jal	ra,80002da0 <brelse>
    if (ip) {
    800035c2:	00098f63          	beqz	s3,800035e0 <ireclaim+0x70>
      begin_op();
    800035c6:	762000ef          	jal	ra,80003d28 <begin_op>
      ilock(ip);
    800035ca:	854e                	mv	a0,s3
    800035cc:	d7fff0ef          	jal	ra,8000334a <ilock>
      iunlock(ip);
    800035d0:	854e                	mv	a0,s3
    800035d2:	e23ff0ef          	jal	ra,800033f4 <iunlock>
      iput(ip);
    800035d6:	854e                	mv	a0,s3
    800035d8:	ef1ff0ef          	jal	ra,800034c8 <iput>
      end_op();
    800035dc:	7bc000ef          	jal	ra,80003d98 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035e0:	0485                	addi	s1,s1,1
    800035e2:	00caa703          	lw	a4,12(s5)
    800035e6:	0004879b          	sext.w	a5,s1
    800035ea:	02e7fd63          	bgeu	a5,a4,80003624 <ireclaim+0xb4>
    800035ee:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035f2:	0044d793          	srli	a5,s1,0x4
    800035f6:	018aa583          	lw	a1,24(s5)
    800035fa:	9dbd                	addw	a1,a1,a5
    800035fc:	8552                	mv	a0,s4
    800035fe:	e9aff0ef          	jal	ra,80002c98 <bread>
    80003602:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003604:	05850793          	addi	a5,a0,88
    80003608:	00f9f713          	andi	a4,s3,15
    8000360c:	071a                	slli	a4,a4,0x6
    8000360e:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003610:	00079703          	lh	a4,0(a5)
    80003614:	c701                	beqz	a4,8000361c <ireclaim+0xac>
    80003616:	00679783          	lh	a5,6(a5)
    8000361a:	dbc1                	beqz	a5,800035aa <ireclaim+0x3a>
    brelse(bp);
    8000361c:	854a                	mv	a0,s2
    8000361e:	f82ff0ef          	jal	ra,80002da0 <brelse>
    if (ip) {
    80003622:	bf7d                	j	800035e0 <ireclaim+0x70>
}
    80003624:	70e2                	ld	ra,56(sp)
    80003626:	7442                	ld	s0,48(sp)
    80003628:	74a2                	ld	s1,40(sp)
    8000362a:	7902                	ld	s2,32(sp)
    8000362c:	69e2                	ld	s3,24(sp)
    8000362e:	6a42                	ld	s4,16(sp)
    80003630:	6aa2                	ld	s5,8(sp)
    80003632:	6b02                	ld	s6,0(sp)
    80003634:	6121                	addi	sp,sp,64
    80003636:	8082                	ret
    80003638:	8082                	ret

000000008000363a <fsinit>:
fsinit(int dev) {
    8000363a:	7179                	addi	sp,sp,-48
    8000363c:	f406                	sd	ra,40(sp)
    8000363e:	f022                	sd	s0,32(sp)
    80003640:	ec26                	sd	s1,24(sp)
    80003642:	e84a                	sd	s2,16(sp)
    80003644:	e44e                	sd	s3,8(sp)
    80003646:	1800                	addi	s0,sp,48
    80003648:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    8000364a:	4585                	li	a1,1
    8000364c:	e4cff0ef          	jal	ra,80002c98 <bread>
    80003650:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003652:	0001b997          	auipc	s3,0x1b
    80003656:	a4e98993          	addi	s3,s3,-1458 # 8001e0a0 <sb>
    8000365a:	02000613          	li	a2,32
    8000365e:	05850593          	addi	a1,a0,88
    80003662:	854e                	mv	a0,s3
    80003664:	e38fd0ef          	jal	ra,80000c9c <memmove>
  brelse(bp);
    80003668:	854a                	mv	a0,s2
    8000366a:	f36ff0ef          	jal	ra,80002da0 <brelse>
  if(sb.magic != FSMAGIC)
    8000366e:	0009a703          	lw	a4,0(s3)
    80003672:	102037b7          	lui	a5,0x10203
    80003676:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000367a:	02f71363          	bne	a4,a5,800036a0 <fsinit+0x66>
  initlog(dev, &sb);
    8000367e:	0001b597          	auipc	a1,0x1b
    80003682:	a2258593          	addi	a1,a1,-1502 # 8001e0a0 <sb>
    80003686:	8526                	mv	a0,s1
    80003688:	616000ef          	jal	ra,80003c9e <initlog>
  ireclaim(dev);
    8000368c:	8526                	mv	a0,s1
    8000368e:	ee3ff0ef          	jal	ra,80003570 <ireclaim>
}
    80003692:	70a2                	ld	ra,40(sp)
    80003694:	7402                	ld	s0,32(sp)
    80003696:	64e2                	ld	s1,24(sp)
    80003698:	6942                	ld	s2,16(sp)
    8000369a:	69a2                	ld	s3,8(sp)
    8000369c:	6145                	addi	sp,sp,48
    8000369e:	8082                	ret
    panic("invalid file system");
    800036a0:	00004517          	auipc	a0,0x4
    800036a4:	f3850513          	addi	a0,a0,-200 # 800075d8 <syscalls+0x1e8>
    800036a8:	8e2fd0ef          	jal	ra,8000078a <panic>

00000000800036ac <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800036ac:	1141                	addi	sp,sp,-16
    800036ae:	e422                	sd	s0,8(sp)
    800036b0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800036b2:	411c                	lw	a5,0(a0)
    800036b4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800036b6:	415c                	lw	a5,4(a0)
    800036b8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036ba:	04451783          	lh	a5,68(a0)
    800036be:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036c2:	04a51783          	lh	a5,74(a0)
    800036c6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800036ca:	04c56783          	lwu	a5,76(a0)
    800036ce:	e99c                	sd	a5,16(a1)
}
    800036d0:	6422                	ld	s0,8(sp)
    800036d2:	0141                	addi	sp,sp,16
    800036d4:	8082                	ret

00000000800036d6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800036d6:	457c                	lw	a5,76(a0)
    800036d8:	0cd7ef63          	bltu	a5,a3,800037b6 <readi+0xe0>
{
    800036dc:	7159                	addi	sp,sp,-112
    800036de:	f486                	sd	ra,104(sp)
    800036e0:	f0a2                	sd	s0,96(sp)
    800036e2:	eca6                	sd	s1,88(sp)
    800036e4:	e8ca                	sd	s2,80(sp)
    800036e6:	e4ce                	sd	s3,72(sp)
    800036e8:	e0d2                	sd	s4,64(sp)
    800036ea:	fc56                	sd	s5,56(sp)
    800036ec:	f85a                	sd	s6,48(sp)
    800036ee:	f45e                	sd	s7,40(sp)
    800036f0:	f062                	sd	s8,32(sp)
    800036f2:	ec66                	sd	s9,24(sp)
    800036f4:	e86a                	sd	s10,16(sp)
    800036f6:	e46e                	sd	s11,8(sp)
    800036f8:	1880                	addi	s0,sp,112
    800036fa:	8b2a                	mv	s6,a0
    800036fc:	8bae                	mv	s7,a1
    800036fe:	8a32                	mv	s4,a2
    80003700:	84b6                	mv	s1,a3
    80003702:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003704:	9f35                	addw	a4,a4,a3
    return 0;
    80003706:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003708:	08d76663          	bltu	a4,a3,80003794 <readi+0xbe>
  if(off + n > ip->size)
    8000370c:	00e7f463          	bgeu	a5,a4,80003714 <readi+0x3e>
    n = ip->size - off;
    80003710:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003714:	080a8f63          	beqz	s5,800037b2 <readi+0xdc>
    80003718:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000371a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000371e:	5c7d                	li	s8,-1
    80003720:	a80d                	j	80003752 <readi+0x7c>
    80003722:	020d1d93          	slli	s11,s10,0x20
    80003726:	020ddd93          	srli	s11,s11,0x20
    8000372a:	05890793          	addi	a5,s2,88
    8000372e:	86ee                	mv	a3,s11
    80003730:	963e                	add	a2,a2,a5
    80003732:	85d2                	mv	a1,s4
    80003734:	855e                	mv	a0,s7
    80003736:	a3bfe0ef          	jal	ra,80002170 <either_copyout>
    8000373a:	05850763          	beq	a0,s8,80003788 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000373e:	854a                	mv	a0,s2
    80003740:	e60ff0ef          	jal	ra,80002da0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003744:	013d09bb          	addw	s3,s10,s3
    80003748:	009d04bb          	addw	s1,s10,s1
    8000374c:	9a6e                	add	s4,s4,s11
    8000374e:	0559f163          	bgeu	s3,s5,80003790 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003752:	00a4d59b          	srliw	a1,s1,0xa
    80003756:	855a                	mv	a0,s6
    80003758:	8bbff0ef          	jal	ra,80003012 <bmap>
    8000375c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003760:	c985                	beqz	a1,80003790 <readi+0xba>
    bp = bread(ip->dev, addr);
    80003762:	000b2503          	lw	a0,0(s6)
    80003766:	d32ff0ef          	jal	ra,80002c98 <bread>
    8000376a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000376c:	3ff4f613          	andi	a2,s1,1023
    80003770:	40cc87bb          	subw	a5,s9,a2
    80003774:	413a873b          	subw	a4,s5,s3
    80003778:	8d3e                	mv	s10,a5
    8000377a:	2781                	sext.w	a5,a5
    8000377c:	0007069b          	sext.w	a3,a4
    80003780:	faf6f1e3          	bgeu	a3,a5,80003722 <readi+0x4c>
    80003784:	8d3a                	mv	s10,a4
    80003786:	bf71                	j	80003722 <readi+0x4c>
      brelse(bp);
    80003788:	854a                	mv	a0,s2
    8000378a:	e16ff0ef          	jal	ra,80002da0 <brelse>
      tot = -1;
    8000378e:	59fd                	li	s3,-1
  }
  return tot;
    80003790:	0009851b          	sext.w	a0,s3
}
    80003794:	70a6                	ld	ra,104(sp)
    80003796:	7406                	ld	s0,96(sp)
    80003798:	64e6                	ld	s1,88(sp)
    8000379a:	6946                	ld	s2,80(sp)
    8000379c:	69a6                	ld	s3,72(sp)
    8000379e:	6a06                	ld	s4,64(sp)
    800037a0:	7ae2                	ld	s5,56(sp)
    800037a2:	7b42                	ld	s6,48(sp)
    800037a4:	7ba2                	ld	s7,40(sp)
    800037a6:	7c02                	ld	s8,32(sp)
    800037a8:	6ce2                	ld	s9,24(sp)
    800037aa:	6d42                	ld	s10,16(sp)
    800037ac:	6da2                	ld	s11,8(sp)
    800037ae:	6165                	addi	sp,sp,112
    800037b0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037b2:	89d6                	mv	s3,s5
    800037b4:	bff1                	j	80003790 <readi+0xba>
    return 0;
    800037b6:	4501                	li	a0,0
}
    800037b8:	8082                	ret

00000000800037ba <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037ba:	457c                	lw	a5,76(a0)
    800037bc:	0ed7ea63          	bltu	a5,a3,800038b0 <writei+0xf6>
{
    800037c0:	7159                	addi	sp,sp,-112
    800037c2:	f486                	sd	ra,104(sp)
    800037c4:	f0a2                	sd	s0,96(sp)
    800037c6:	eca6                	sd	s1,88(sp)
    800037c8:	e8ca                	sd	s2,80(sp)
    800037ca:	e4ce                	sd	s3,72(sp)
    800037cc:	e0d2                	sd	s4,64(sp)
    800037ce:	fc56                	sd	s5,56(sp)
    800037d0:	f85a                	sd	s6,48(sp)
    800037d2:	f45e                	sd	s7,40(sp)
    800037d4:	f062                	sd	s8,32(sp)
    800037d6:	ec66                	sd	s9,24(sp)
    800037d8:	e86a                	sd	s10,16(sp)
    800037da:	e46e                	sd	s11,8(sp)
    800037dc:	1880                	addi	s0,sp,112
    800037de:	8aaa                	mv	s5,a0
    800037e0:	8bae                	mv	s7,a1
    800037e2:	8a32                	mv	s4,a2
    800037e4:	8936                	mv	s2,a3
    800037e6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800037e8:	00e687bb          	addw	a5,a3,a4
    800037ec:	0cd7e463          	bltu	a5,a3,800038b4 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800037f0:	00043737          	lui	a4,0x43
    800037f4:	0cf76263          	bltu	a4,a5,800038b8 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037f8:	0a0b0a63          	beqz	s6,800038ac <writei+0xf2>
    800037fc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037fe:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003802:	5c7d                	li	s8,-1
    80003804:	a825                	j	8000383c <writei+0x82>
    80003806:	020d1d93          	slli	s11,s10,0x20
    8000380a:	020ddd93          	srli	s11,s11,0x20
    8000380e:	05848793          	addi	a5,s1,88
    80003812:	86ee                	mv	a3,s11
    80003814:	8652                	mv	a2,s4
    80003816:	85de                	mv	a1,s7
    80003818:	953e                	add	a0,a0,a5
    8000381a:	9a1fe0ef          	jal	ra,800021ba <either_copyin>
    8000381e:	05850a63          	beq	a0,s8,80003872 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003822:	8526                	mv	a0,s1
    80003824:	688000ef          	jal	ra,80003eac <log_write>
    brelse(bp);
    80003828:	8526                	mv	a0,s1
    8000382a:	d76ff0ef          	jal	ra,80002da0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000382e:	013d09bb          	addw	s3,s10,s3
    80003832:	012d093b          	addw	s2,s10,s2
    80003836:	9a6e                	add	s4,s4,s11
    80003838:	0569f063          	bgeu	s3,s6,80003878 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000383c:	00a9559b          	srliw	a1,s2,0xa
    80003840:	8556                	mv	a0,s5
    80003842:	fd0ff0ef          	jal	ra,80003012 <bmap>
    80003846:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000384a:	c59d                	beqz	a1,80003878 <writei+0xbe>
    bp = bread(ip->dev, addr);
    8000384c:	000aa503          	lw	a0,0(s5)
    80003850:	c48ff0ef          	jal	ra,80002c98 <bread>
    80003854:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003856:	3ff97513          	andi	a0,s2,1023
    8000385a:	40ac87bb          	subw	a5,s9,a0
    8000385e:	413b073b          	subw	a4,s6,s3
    80003862:	8d3e                	mv	s10,a5
    80003864:	2781                	sext.w	a5,a5
    80003866:	0007069b          	sext.w	a3,a4
    8000386a:	f8f6fee3          	bgeu	a3,a5,80003806 <writei+0x4c>
    8000386e:	8d3a                	mv	s10,a4
    80003870:	bf59                	j	80003806 <writei+0x4c>
      brelse(bp);
    80003872:	8526                	mv	a0,s1
    80003874:	d2cff0ef          	jal	ra,80002da0 <brelse>
  }

  if(off > ip->size)
    80003878:	04caa783          	lw	a5,76(s5)
    8000387c:	0127f463          	bgeu	a5,s2,80003884 <writei+0xca>
    ip->size = off;
    80003880:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003884:	8556                	mv	a0,s5
    80003886:	a13ff0ef          	jal	ra,80003298 <iupdate>

  return tot;
    8000388a:	0009851b          	sext.w	a0,s3
}
    8000388e:	70a6                	ld	ra,104(sp)
    80003890:	7406                	ld	s0,96(sp)
    80003892:	64e6                	ld	s1,88(sp)
    80003894:	6946                	ld	s2,80(sp)
    80003896:	69a6                	ld	s3,72(sp)
    80003898:	6a06                	ld	s4,64(sp)
    8000389a:	7ae2                	ld	s5,56(sp)
    8000389c:	7b42                	ld	s6,48(sp)
    8000389e:	7ba2                	ld	s7,40(sp)
    800038a0:	7c02                	ld	s8,32(sp)
    800038a2:	6ce2                	ld	s9,24(sp)
    800038a4:	6d42                	ld	s10,16(sp)
    800038a6:	6da2                	ld	s11,8(sp)
    800038a8:	6165                	addi	sp,sp,112
    800038aa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038ac:	89da                	mv	s3,s6
    800038ae:	bfd9                	j	80003884 <writei+0xca>
    return -1;
    800038b0:	557d                	li	a0,-1
}
    800038b2:	8082                	ret
    return -1;
    800038b4:	557d                	li	a0,-1
    800038b6:	bfe1                	j	8000388e <writei+0xd4>
    return -1;
    800038b8:	557d                	li	a0,-1
    800038ba:	bfd1                	j	8000388e <writei+0xd4>

00000000800038bc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800038bc:	1141                	addi	sp,sp,-16
    800038be:	e406                	sd	ra,8(sp)
    800038c0:	e022                	sd	s0,0(sp)
    800038c2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800038c4:	4639                	li	a2,14
    800038c6:	c46fd0ef          	jal	ra,80000d0c <strncmp>
}
    800038ca:	60a2                	ld	ra,8(sp)
    800038cc:	6402                	ld	s0,0(sp)
    800038ce:	0141                	addi	sp,sp,16
    800038d0:	8082                	ret

00000000800038d2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800038d2:	7139                	addi	sp,sp,-64
    800038d4:	fc06                	sd	ra,56(sp)
    800038d6:	f822                	sd	s0,48(sp)
    800038d8:	f426                	sd	s1,40(sp)
    800038da:	f04a                	sd	s2,32(sp)
    800038dc:	ec4e                	sd	s3,24(sp)
    800038de:	e852                	sd	s4,16(sp)
    800038e0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800038e2:	04451703          	lh	a4,68(a0)
    800038e6:	4785                	li	a5,1
    800038e8:	00f71a63          	bne	a4,a5,800038fc <dirlookup+0x2a>
    800038ec:	892a                	mv	s2,a0
    800038ee:	89ae                	mv	s3,a1
    800038f0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800038f2:	457c                	lw	a5,76(a0)
    800038f4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800038f6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038f8:	e39d                	bnez	a5,8000391e <dirlookup+0x4c>
    800038fa:	a095                	j	8000395e <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800038fc:	00004517          	auipc	a0,0x4
    80003900:	cf450513          	addi	a0,a0,-780 # 800075f0 <syscalls+0x200>
    80003904:	e87fc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    80003908:	00004517          	auipc	a0,0x4
    8000390c:	d0050513          	addi	a0,a0,-768 # 80007608 <syscalls+0x218>
    80003910:	e7bfc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003914:	24c1                	addiw	s1,s1,16
    80003916:	04c92783          	lw	a5,76(s2)
    8000391a:	04f4f163          	bgeu	s1,a5,8000395c <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000391e:	4741                	li	a4,16
    80003920:	86a6                	mv	a3,s1
    80003922:	fc040613          	addi	a2,s0,-64
    80003926:	4581                	li	a1,0
    80003928:	854a                	mv	a0,s2
    8000392a:	dadff0ef          	jal	ra,800036d6 <readi>
    8000392e:	47c1                	li	a5,16
    80003930:	fcf51ce3          	bne	a0,a5,80003908 <dirlookup+0x36>
    if(de.inum == 0)
    80003934:	fc045783          	lhu	a5,-64(s0)
    80003938:	dff1                	beqz	a5,80003914 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    8000393a:	fc240593          	addi	a1,s0,-62
    8000393e:	854e                	mv	a0,s3
    80003940:	f7dff0ef          	jal	ra,800038bc <namecmp>
    80003944:	f961                	bnez	a0,80003914 <dirlookup+0x42>
      if(poff)
    80003946:	000a0463          	beqz	s4,8000394e <dirlookup+0x7c>
        *poff = off;
    8000394a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000394e:	fc045583          	lhu	a1,-64(s0)
    80003952:	00092503          	lw	a0,0(s2)
    80003956:	f88ff0ef          	jal	ra,800030de <iget>
    8000395a:	a011                	j	8000395e <dirlookup+0x8c>
  return 0;
    8000395c:	4501                	li	a0,0
}
    8000395e:	70e2                	ld	ra,56(sp)
    80003960:	7442                	ld	s0,48(sp)
    80003962:	74a2                	ld	s1,40(sp)
    80003964:	7902                	ld	s2,32(sp)
    80003966:	69e2                	ld	s3,24(sp)
    80003968:	6a42                	ld	s4,16(sp)
    8000396a:	6121                	addi	sp,sp,64
    8000396c:	8082                	ret

000000008000396e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000396e:	711d                	addi	sp,sp,-96
    80003970:	ec86                	sd	ra,88(sp)
    80003972:	e8a2                	sd	s0,80(sp)
    80003974:	e4a6                	sd	s1,72(sp)
    80003976:	e0ca                	sd	s2,64(sp)
    80003978:	fc4e                	sd	s3,56(sp)
    8000397a:	f852                	sd	s4,48(sp)
    8000397c:	f456                	sd	s5,40(sp)
    8000397e:	f05a                	sd	s6,32(sp)
    80003980:	ec5e                	sd	s7,24(sp)
    80003982:	e862                	sd	s8,16(sp)
    80003984:	e466                	sd	s9,8(sp)
    80003986:	1080                	addi	s0,sp,96
    80003988:	84aa                	mv	s1,a0
    8000398a:	8aae                	mv	s5,a1
    8000398c:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000398e:	00054703          	lbu	a4,0(a0)
    80003992:	02f00793          	li	a5,47
    80003996:	00f70f63          	beq	a4,a5,800039b4 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000399a:	e6bfd0ef          	jal	ra,80001804 <myproc>
    8000399e:	15053503          	ld	a0,336(a0)
    800039a2:	973ff0ef          	jal	ra,80003314 <idup>
    800039a6:	89aa                	mv	s3,a0
  while(*path == '/')
    800039a8:	02f00913          	li	s2,47
  len = path - s;
    800039ac:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800039ae:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800039b0:	4b85                	li	s7,1
    800039b2:	a861                	j	80003a4a <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    800039b4:	4585                	li	a1,1
    800039b6:	4505                	li	a0,1
    800039b8:	f26ff0ef          	jal	ra,800030de <iget>
    800039bc:	89aa                	mv	s3,a0
    800039be:	b7ed                	j	800039a8 <namex+0x3a>
      iunlockput(ip);
    800039c0:	854e                	mv	a0,s3
    800039c2:	b8fff0ef          	jal	ra,80003550 <iunlockput>
      return 0;
    800039c6:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800039c8:	854e                	mv	a0,s3
    800039ca:	60e6                	ld	ra,88(sp)
    800039cc:	6446                	ld	s0,80(sp)
    800039ce:	64a6                	ld	s1,72(sp)
    800039d0:	6906                	ld	s2,64(sp)
    800039d2:	79e2                	ld	s3,56(sp)
    800039d4:	7a42                	ld	s4,48(sp)
    800039d6:	7aa2                	ld	s5,40(sp)
    800039d8:	7b02                	ld	s6,32(sp)
    800039da:	6be2                	ld	s7,24(sp)
    800039dc:	6c42                	ld	s8,16(sp)
    800039de:	6ca2                	ld	s9,8(sp)
    800039e0:	6125                	addi	sp,sp,96
    800039e2:	8082                	ret
      iunlock(ip);
    800039e4:	854e                	mv	a0,s3
    800039e6:	a0fff0ef          	jal	ra,800033f4 <iunlock>
      return ip;
    800039ea:	bff9                	j	800039c8 <namex+0x5a>
      iunlockput(ip);
    800039ec:	854e                	mv	a0,s3
    800039ee:	b63ff0ef          	jal	ra,80003550 <iunlockput>
      return 0;
    800039f2:	89e6                	mv	s3,s9
    800039f4:	bfd1                	j	800039c8 <namex+0x5a>
  len = path - s;
    800039f6:	40b48633          	sub	a2,s1,a1
    800039fa:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800039fe:	079c5c63          	bge	s8,s9,80003a76 <namex+0x108>
    memmove(name, s, DIRSIZ);
    80003a02:	4639                	li	a2,14
    80003a04:	8552                	mv	a0,s4
    80003a06:	a96fd0ef          	jal	ra,80000c9c <memmove>
  while(*path == '/')
    80003a0a:	0004c783          	lbu	a5,0(s1)
    80003a0e:	01279763          	bne	a5,s2,80003a1c <namex+0xae>
    path++;
    80003a12:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a14:	0004c783          	lbu	a5,0(s1)
    80003a18:	ff278de3          	beq	a5,s2,80003a12 <namex+0xa4>
    ilock(ip);
    80003a1c:	854e                	mv	a0,s3
    80003a1e:	92dff0ef          	jal	ra,8000334a <ilock>
    if(ip->type != T_DIR){
    80003a22:	04499783          	lh	a5,68(s3)
    80003a26:	f9779de3          	bne	a5,s7,800039c0 <namex+0x52>
    if(nameiparent && *path == '\0'){
    80003a2a:	000a8563          	beqz	s5,80003a34 <namex+0xc6>
    80003a2e:	0004c783          	lbu	a5,0(s1)
    80003a32:	dbcd                	beqz	a5,800039e4 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003a34:	865a                	mv	a2,s6
    80003a36:	85d2                	mv	a1,s4
    80003a38:	854e                	mv	a0,s3
    80003a3a:	e99ff0ef          	jal	ra,800038d2 <dirlookup>
    80003a3e:	8caa                	mv	s9,a0
    80003a40:	d555                	beqz	a0,800039ec <namex+0x7e>
    iunlockput(ip);
    80003a42:	854e                	mv	a0,s3
    80003a44:	b0dff0ef          	jal	ra,80003550 <iunlockput>
    ip = next;
    80003a48:	89e6                	mv	s3,s9
  while(*path == '/')
    80003a4a:	0004c783          	lbu	a5,0(s1)
    80003a4e:	05279363          	bne	a5,s2,80003a94 <namex+0x126>
    path++;
    80003a52:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a54:	0004c783          	lbu	a5,0(s1)
    80003a58:	ff278de3          	beq	a5,s2,80003a52 <namex+0xe4>
  if(*path == 0)
    80003a5c:	c78d                	beqz	a5,80003a86 <namex+0x118>
    path++;
    80003a5e:	85a6                	mv	a1,s1
  len = path - s;
    80003a60:	8cda                	mv	s9,s6
    80003a62:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003a64:	01278963          	beq	a5,s2,80003a76 <namex+0x108>
    80003a68:	d7d9                	beqz	a5,800039f6 <namex+0x88>
    path++;
    80003a6a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003a6c:	0004c783          	lbu	a5,0(s1)
    80003a70:	ff279ce3          	bne	a5,s2,80003a68 <namex+0xfa>
    80003a74:	b749                	j	800039f6 <namex+0x88>
    memmove(name, s, len);
    80003a76:	2601                	sext.w	a2,a2
    80003a78:	8552                	mv	a0,s4
    80003a7a:	a22fd0ef          	jal	ra,80000c9c <memmove>
    name[len] = 0;
    80003a7e:	9cd2                	add	s9,s9,s4
    80003a80:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003a84:	b759                	j	80003a0a <namex+0x9c>
  if(nameiparent){
    80003a86:	f40a81e3          	beqz	s5,800039c8 <namex+0x5a>
    iput(ip);
    80003a8a:	854e                	mv	a0,s3
    80003a8c:	a3dff0ef          	jal	ra,800034c8 <iput>
    return 0;
    80003a90:	4981                	li	s3,0
    80003a92:	bf1d                	j	800039c8 <namex+0x5a>
  if(*path == 0)
    80003a94:	dbed                	beqz	a5,80003a86 <namex+0x118>
  while(*path != '/' && *path != 0)
    80003a96:	0004c783          	lbu	a5,0(s1)
    80003a9a:	85a6                	mv	a1,s1
    80003a9c:	b7f1                	j	80003a68 <namex+0xfa>

0000000080003a9e <dirlink>:
{
    80003a9e:	7139                	addi	sp,sp,-64
    80003aa0:	fc06                	sd	ra,56(sp)
    80003aa2:	f822                	sd	s0,48(sp)
    80003aa4:	f426                	sd	s1,40(sp)
    80003aa6:	f04a                	sd	s2,32(sp)
    80003aa8:	ec4e                	sd	s3,24(sp)
    80003aaa:	e852                	sd	s4,16(sp)
    80003aac:	0080                	addi	s0,sp,64
    80003aae:	892a                	mv	s2,a0
    80003ab0:	8a2e                	mv	s4,a1
    80003ab2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ab4:	4601                	li	a2,0
    80003ab6:	e1dff0ef          	jal	ra,800038d2 <dirlookup>
    80003aba:	e52d                	bnez	a0,80003b24 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003abc:	04c92483          	lw	s1,76(s2)
    80003ac0:	c48d                	beqz	s1,80003aea <dirlink+0x4c>
    80003ac2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ac4:	4741                	li	a4,16
    80003ac6:	86a6                	mv	a3,s1
    80003ac8:	fc040613          	addi	a2,s0,-64
    80003acc:	4581                	li	a1,0
    80003ace:	854a                	mv	a0,s2
    80003ad0:	c07ff0ef          	jal	ra,800036d6 <readi>
    80003ad4:	47c1                	li	a5,16
    80003ad6:	04f51b63          	bne	a0,a5,80003b2c <dirlink+0x8e>
    if(de.inum == 0)
    80003ada:	fc045783          	lhu	a5,-64(s0)
    80003ade:	c791                	beqz	a5,80003aea <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ae0:	24c1                	addiw	s1,s1,16
    80003ae2:	04c92783          	lw	a5,76(s2)
    80003ae6:	fcf4efe3          	bltu	s1,a5,80003ac4 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003aea:	4639                	li	a2,14
    80003aec:	85d2                	mv	a1,s4
    80003aee:	fc240513          	addi	a0,s0,-62
    80003af2:	a56fd0ef          	jal	ra,80000d48 <strncpy>
  de.inum = inum;
    80003af6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003afa:	4741                	li	a4,16
    80003afc:	86a6                	mv	a3,s1
    80003afe:	fc040613          	addi	a2,s0,-64
    80003b02:	4581                	li	a1,0
    80003b04:	854a                	mv	a0,s2
    80003b06:	cb5ff0ef          	jal	ra,800037ba <writei>
    80003b0a:	1541                	addi	a0,a0,-16
    80003b0c:	00a03533          	snez	a0,a0
    80003b10:	40a00533          	neg	a0,a0
}
    80003b14:	70e2                	ld	ra,56(sp)
    80003b16:	7442                	ld	s0,48(sp)
    80003b18:	74a2                	ld	s1,40(sp)
    80003b1a:	7902                	ld	s2,32(sp)
    80003b1c:	69e2                	ld	s3,24(sp)
    80003b1e:	6a42                	ld	s4,16(sp)
    80003b20:	6121                	addi	sp,sp,64
    80003b22:	8082                	ret
    iput(ip);
    80003b24:	9a5ff0ef          	jal	ra,800034c8 <iput>
    return -1;
    80003b28:	557d                	li	a0,-1
    80003b2a:	b7ed                	j	80003b14 <dirlink+0x76>
      panic("dirlink read");
    80003b2c:	00004517          	auipc	a0,0x4
    80003b30:	aec50513          	addi	a0,a0,-1300 # 80007618 <syscalls+0x228>
    80003b34:	c57fc0ef          	jal	ra,8000078a <panic>

0000000080003b38 <namei>:

struct inode*
namei(char *path)
{
    80003b38:	1101                	addi	sp,sp,-32
    80003b3a:	ec06                	sd	ra,24(sp)
    80003b3c:	e822                	sd	s0,16(sp)
    80003b3e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b40:	fe040613          	addi	a2,s0,-32
    80003b44:	4581                	li	a1,0
    80003b46:	e29ff0ef          	jal	ra,8000396e <namex>
}
    80003b4a:	60e2                	ld	ra,24(sp)
    80003b4c:	6442                	ld	s0,16(sp)
    80003b4e:	6105                	addi	sp,sp,32
    80003b50:	8082                	ret

0000000080003b52 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b52:	1141                	addi	sp,sp,-16
    80003b54:	e406                	sd	ra,8(sp)
    80003b56:	e022                	sd	s0,0(sp)
    80003b58:	0800                	addi	s0,sp,16
    80003b5a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b5c:	4585                	li	a1,1
    80003b5e:	e11ff0ef          	jal	ra,8000396e <namex>
}
    80003b62:	60a2                	ld	ra,8(sp)
    80003b64:	6402                	ld	s0,0(sp)
    80003b66:	0141                	addi	sp,sp,16
    80003b68:	8082                	ret

0000000080003b6a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b6a:	1101                	addi	sp,sp,-32
    80003b6c:	ec06                	sd	ra,24(sp)
    80003b6e:	e822                	sd	s0,16(sp)
    80003b70:	e426                	sd	s1,8(sp)
    80003b72:	e04a                	sd	s2,0(sp)
    80003b74:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b76:	0001c917          	auipc	s2,0x1c
    80003b7a:	ff290913          	addi	s2,s2,-14 # 8001fb68 <log>
    80003b7e:	01892583          	lw	a1,24(s2)
    80003b82:	02492503          	lw	a0,36(s2)
    80003b86:	912ff0ef          	jal	ra,80002c98 <bread>
    80003b8a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b8c:	02892683          	lw	a3,40(s2)
    80003b90:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b92:	02d05763          	blez	a3,80003bc0 <write_head+0x56>
    80003b96:	0001c797          	auipc	a5,0x1c
    80003b9a:	ffe78793          	addi	a5,a5,-2 # 8001fb94 <log+0x2c>
    80003b9e:	05c50713          	addi	a4,a0,92
    80003ba2:	36fd                	addiw	a3,a3,-1
    80003ba4:	1682                	slli	a3,a3,0x20
    80003ba6:	9281                	srli	a3,a3,0x20
    80003ba8:	068a                	slli	a3,a3,0x2
    80003baa:	0001c617          	auipc	a2,0x1c
    80003bae:	fee60613          	addi	a2,a2,-18 # 8001fb98 <log+0x30>
    80003bb2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003bb4:	4390                	lw	a2,0(a5)
    80003bb6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003bb8:	0791                	addi	a5,a5,4
    80003bba:	0711                	addi	a4,a4,4
    80003bbc:	fed79ce3          	bne	a5,a3,80003bb4 <write_head+0x4a>
  }
  bwrite(buf);
    80003bc0:	8526                	mv	a0,s1
    80003bc2:	9acff0ef          	jal	ra,80002d6e <bwrite>
  brelse(buf);
    80003bc6:	8526                	mv	a0,s1
    80003bc8:	9d8ff0ef          	jal	ra,80002da0 <brelse>
}
    80003bcc:	60e2                	ld	ra,24(sp)
    80003bce:	6442                	ld	s0,16(sp)
    80003bd0:	64a2                	ld	s1,8(sp)
    80003bd2:	6902                	ld	s2,0(sp)
    80003bd4:	6105                	addi	sp,sp,32
    80003bd6:	8082                	ret

0000000080003bd8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bd8:	0001c797          	auipc	a5,0x1c
    80003bdc:	fb87a783          	lw	a5,-72(a5) # 8001fb90 <log+0x28>
    80003be0:	0af05e63          	blez	a5,80003c9c <install_trans+0xc4>
{
    80003be4:	715d                	addi	sp,sp,-80
    80003be6:	e486                	sd	ra,72(sp)
    80003be8:	e0a2                	sd	s0,64(sp)
    80003bea:	fc26                	sd	s1,56(sp)
    80003bec:	f84a                	sd	s2,48(sp)
    80003bee:	f44e                	sd	s3,40(sp)
    80003bf0:	f052                	sd	s4,32(sp)
    80003bf2:	ec56                	sd	s5,24(sp)
    80003bf4:	e85a                	sd	s6,16(sp)
    80003bf6:	e45e                	sd	s7,8(sp)
    80003bf8:	0880                	addi	s0,sp,80
    80003bfa:	8b2a                	mv	s6,a0
    80003bfc:	0001ca97          	auipc	s5,0x1c
    80003c00:	f98a8a93          	addi	s5,s5,-104 # 8001fb94 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c04:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c06:	00004b97          	auipc	s7,0x4
    80003c0a:	a22b8b93          	addi	s7,s7,-1502 # 80007628 <syscalls+0x238>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c0e:	0001ca17          	auipc	s4,0x1c
    80003c12:	f5aa0a13          	addi	s4,s4,-166 # 8001fb68 <log>
    80003c16:	a025                	j	80003c3e <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c18:	000aa603          	lw	a2,0(s5)
    80003c1c:	85ce                	mv	a1,s3
    80003c1e:	855e                	mv	a0,s7
    80003c20:	8a5fc0ef          	jal	ra,800004c4 <printf>
    80003c24:	a839                	j	80003c42 <install_trans+0x6a>
    brelse(lbuf);
    80003c26:	854a                	mv	a0,s2
    80003c28:	978ff0ef          	jal	ra,80002da0 <brelse>
    brelse(dbuf);
    80003c2c:	8526                	mv	a0,s1
    80003c2e:	972ff0ef          	jal	ra,80002da0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c32:	2985                	addiw	s3,s3,1
    80003c34:	0a91                	addi	s5,s5,4
    80003c36:	028a2783          	lw	a5,40(s4)
    80003c3a:	04f9d663          	bge	s3,a5,80003c86 <install_trans+0xae>
    if(recovering) {
    80003c3e:	fc0b1de3          	bnez	s6,80003c18 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c42:	018a2583          	lw	a1,24(s4)
    80003c46:	013585bb          	addw	a1,a1,s3
    80003c4a:	2585                	addiw	a1,a1,1
    80003c4c:	024a2503          	lw	a0,36(s4)
    80003c50:	848ff0ef          	jal	ra,80002c98 <bread>
    80003c54:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003c56:	000aa583          	lw	a1,0(s5)
    80003c5a:	024a2503          	lw	a0,36(s4)
    80003c5e:	83aff0ef          	jal	ra,80002c98 <bread>
    80003c62:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c64:	40000613          	li	a2,1024
    80003c68:	05890593          	addi	a1,s2,88
    80003c6c:	05850513          	addi	a0,a0,88
    80003c70:	82cfd0ef          	jal	ra,80000c9c <memmove>
    bwrite(dbuf);  // write dst to disk
    80003c74:	8526                	mv	a0,s1
    80003c76:	8f8ff0ef          	jal	ra,80002d6e <bwrite>
    if(recovering == 0)
    80003c7a:	fa0b16e3          	bnez	s6,80003c26 <install_trans+0x4e>
      bunpin(dbuf);
    80003c7e:	8526                	mv	a0,s1
    80003c80:	9deff0ef          	jal	ra,80002e5e <bunpin>
    80003c84:	b74d                	j	80003c26 <install_trans+0x4e>
}
    80003c86:	60a6                	ld	ra,72(sp)
    80003c88:	6406                	ld	s0,64(sp)
    80003c8a:	74e2                	ld	s1,56(sp)
    80003c8c:	7942                	ld	s2,48(sp)
    80003c8e:	79a2                	ld	s3,40(sp)
    80003c90:	7a02                	ld	s4,32(sp)
    80003c92:	6ae2                	ld	s5,24(sp)
    80003c94:	6b42                	ld	s6,16(sp)
    80003c96:	6ba2                	ld	s7,8(sp)
    80003c98:	6161                	addi	sp,sp,80
    80003c9a:	8082                	ret
    80003c9c:	8082                	ret

0000000080003c9e <initlog>:
{
    80003c9e:	7179                	addi	sp,sp,-48
    80003ca0:	f406                	sd	ra,40(sp)
    80003ca2:	f022                	sd	s0,32(sp)
    80003ca4:	ec26                	sd	s1,24(sp)
    80003ca6:	e84a                	sd	s2,16(sp)
    80003ca8:	e44e                	sd	s3,8(sp)
    80003caa:	1800                	addi	s0,sp,48
    80003cac:	892a                	mv	s2,a0
    80003cae:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003cb0:	0001c497          	auipc	s1,0x1c
    80003cb4:	eb848493          	addi	s1,s1,-328 # 8001fb68 <log>
    80003cb8:	00004597          	auipc	a1,0x4
    80003cbc:	99058593          	addi	a1,a1,-1648 # 80007648 <syscalls+0x258>
    80003cc0:	8526                	mv	a0,s1
    80003cc2:	e2bfc0ef          	jal	ra,80000aec <initlock>
  log.start = sb->logstart;
    80003cc6:	0149a583          	lw	a1,20(s3)
    80003cca:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003ccc:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003cd0:	854a                	mv	a0,s2
    80003cd2:	fc7fe0ef          	jal	ra,80002c98 <bread>
  log.lh.n = lh->n;
    80003cd6:	4d34                	lw	a3,88(a0)
    80003cd8:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003cda:	02d05563          	blez	a3,80003d04 <initlog+0x66>
    80003cde:	05c50793          	addi	a5,a0,92
    80003ce2:	0001c717          	auipc	a4,0x1c
    80003ce6:	eb270713          	addi	a4,a4,-334 # 8001fb94 <log+0x2c>
    80003cea:	36fd                	addiw	a3,a3,-1
    80003cec:	1682                	slli	a3,a3,0x20
    80003cee:	9281                	srli	a3,a3,0x20
    80003cf0:	068a                	slli	a3,a3,0x2
    80003cf2:	06050613          	addi	a2,a0,96
    80003cf6:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003cf8:	4390                	lw	a2,0(a5)
    80003cfa:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003cfc:	0791                	addi	a5,a5,4
    80003cfe:	0711                	addi	a4,a4,4
    80003d00:	fed79ce3          	bne	a5,a3,80003cf8 <initlog+0x5a>
  brelse(buf);
    80003d04:	89cff0ef          	jal	ra,80002da0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d08:	4505                	li	a0,1
    80003d0a:	ecfff0ef          	jal	ra,80003bd8 <install_trans>
  log.lh.n = 0;
    80003d0e:	0001c797          	auipc	a5,0x1c
    80003d12:	e807a123          	sw	zero,-382(a5) # 8001fb90 <log+0x28>
  write_head(); // clear the log
    80003d16:	e55ff0ef          	jal	ra,80003b6a <write_head>
}
    80003d1a:	70a2                	ld	ra,40(sp)
    80003d1c:	7402                	ld	s0,32(sp)
    80003d1e:	64e2                	ld	s1,24(sp)
    80003d20:	6942                	ld	s2,16(sp)
    80003d22:	69a2                	ld	s3,8(sp)
    80003d24:	6145                	addi	sp,sp,48
    80003d26:	8082                	ret

0000000080003d28 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d28:	1101                	addi	sp,sp,-32
    80003d2a:	ec06                	sd	ra,24(sp)
    80003d2c:	e822                	sd	s0,16(sp)
    80003d2e:	e426                	sd	s1,8(sp)
    80003d30:	e04a                	sd	s2,0(sp)
    80003d32:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d34:	0001c517          	auipc	a0,0x1c
    80003d38:	e3450513          	addi	a0,a0,-460 # 8001fb68 <log>
    80003d3c:	e31fc0ef          	jal	ra,80000b6c <acquire>
  while(1){
    if(log.committing){
    80003d40:	0001c497          	auipc	s1,0x1c
    80003d44:	e2848493          	addi	s1,s1,-472 # 8001fb68 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d48:	4979                	li	s2,30
    80003d4a:	a029                	j	80003d54 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003d4c:	85a6                	mv	a1,s1
    80003d4e:	8526                	mv	a0,s1
    80003d50:	8c4fe0ef          	jal	ra,80001e14 <sleep>
    if(log.committing){
    80003d54:	509c                	lw	a5,32(s1)
    80003d56:	fbfd                	bnez	a5,80003d4c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d58:	4cdc                	lw	a5,28(s1)
    80003d5a:	0017871b          	addiw	a4,a5,1
    80003d5e:	0007069b          	sext.w	a3,a4
    80003d62:	0027179b          	slliw	a5,a4,0x2
    80003d66:	9fb9                	addw	a5,a5,a4
    80003d68:	0017979b          	slliw	a5,a5,0x1
    80003d6c:	5498                	lw	a4,40(s1)
    80003d6e:	9fb9                	addw	a5,a5,a4
    80003d70:	00f95763          	bge	s2,a5,80003d7e <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003d74:	85a6                	mv	a1,s1
    80003d76:	8526                	mv	a0,s1
    80003d78:	89cfe0ef          	jal	ra,80001e14 <sleep>
    80003d7c:	bfe1                	j	80003d54 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003d7e:	0001c517          	auipc	a0,0x1c
    80003d82:	dea50513          	addi	a0,a0,-534 # 8001fb68 <log>
    80003d86:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003d88:	e7dfc0ef          	jal	ra,80000c04 <release>
      break;
    }
  }
}
    80003d8c:	60e2                	ld	ra,24(sp)
    80003d8e:	6442                	ld	s0,16(sp)
    80003d90:	64a2                	ld	s1,8(sp)
    80003d92:	6902                	ld	s2,0(sp)
    80003d94:	6105                	addi	sp,sp,32
    80003d96:	8082                	ret

0000000080003d98 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d98:	7139                	addi	sp,sp,-64
    80003d9a:	fc06                	sd	ra,56(sp)
    80003d9c:	f822                	sd	s0,48(sp)
    80003d9e:	f426                	sd	s1,40(sp)
    80003da0:	f04a                	sd	s2,32(sp)
    80003da2:	ec4e                	sd	s3,24(sp)
    80003da4:	e852                	sd	s4,16(sp)
    80003da6:	e456                	sd	s5,8(sp)
    80003da8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003daa:	0001c497          	auipc	s1,0x1c
    80003dae:	dbe48493          	addi	s1,s1,-578 # 8001fb68 <log>
    80003db2:	8526                	mv	a0,s1
    80003db4:	db9fc0ef          	jal	ra,80000b6c <acquire>
  log.outstanding -= 1;
    80003db8:	4cdc                	lw	a5,28(s1)
    80003dba:	37fd                	addiw	a5,a5,-1
    80003dbc:	0007891b          	sext.w	s2,a5
    80003dc0:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003dc2:	509c                	lw	a5,32(s1)
    80003dc4:	ef9d                	bnez	a5,80003e02 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003dc6:	04091463          	bnez	s2,80003e0e <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003dca:	0001c497          	auipc	s1,0x1c
    80003dce:	d9e48493          	addi	s1,s1,-610 # 8001fb68 <log>
    80003dd2:	4785                	li	a5,1
    80003dd4:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003dd6:	8526                	mv	a0,s1
    80003dd8:	e2dfc0ef          	jal	ra,80000c04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ddc:	549c                	lw	a5,40(s1)
    80003dde:	04f04b63          	bgtz	a5,80003e34 <end_op+0x9c>
    acquire(&log.lock);
    80003de2:	0001c497          	auipc	s1,0x1c
    80003de6:	d8648493          	addi	s1,s1,-634 # 8001fb68 <log>
    80003dea:	8526                	mv	a0,s1
    80003dec:	d81fc0ef          	jal	ra,80000b6c <acquire>
    log.committing = 0;
    80003df0:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003df4:	8526                	mv	a0,s1
    80003df6:	86afe0ef          	jal	ra,80001e60 <wakeup>
    release(&log.lock);
    80003dfa:	8526                	mv	a0,s1
    80003dfc:	e09fc0ef          	jal	ra,80000c04 <release>
}
    80003e00:	a00d                	j	80003e22 <end_op+0x8a>
    panic("log.committing");
    80003e02:	00004517          	auipc	a0,0x4
    80003e06:	84e50513          	addi	a0,a0,-1970 # 80007650 <syscalls+0x260>
    80003e0a:	981fc0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    80003e0e:	0001c497          	auipc	s1,0x1c
    80003e12:	d5a48493          	addi	s1,s1,-678 # 8001fb68 <log>
    80003e16:	8526                	mv	a0,s1
    80003e18:	848fe0ef          	jal	ra,80001e60 <wakeup>
  release(&log.lock);
    80003e1c:	8526                	mv	a0,s1
    80003e1e:	de7fc0ef          	jal	ra,80000c04 <release>
}
    80003e22:	70e2                	ld	ra,56(sp)
    80003e24:	7442                	ld	s0,48(sp)
    80003e26:	74a2                	ld	s1,40(sp)
    80003e28:	7902                	ld	s2,32(sp)
    80003e2a:	69e2                	ld	s3,24(sp)
    80003e2c:	6a42                	ld	s4,16(sp)
    80003e2e:	6aa2                	ld	s5,8(sp)
    80003e30:	6121                	addi	sp,sp,64
    80003e32:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e34:	0001ca97          	auipc	s5,0x1c
    80003e38:	d60a8a93          	addi	s5,s5,-672 # 8001fb94 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003e3c:	0001ca17          	auipc	s4,0x1c
    80003e40:	d2ca0a13          	addi	s4,s4,-724 # 8001fb68 <log>
    80003e44:	018a2583          	lw	a1,24(s4)
    80003e48:	012585bb          	addw	a1,a1,s2
    80003e4c:	2585                	addiw	a1,a1,1
    80003e4e:	024a2503          	lw	a0,36(s4)
    80003e52:	e47fe0ef          	jal	ra,80002c98 <bread>
    80003e56:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e58:	000aa583          	lw	a1,0(s5)
    80003e5c:	024a2503          	lw	a0,36(s4)
    80003e60:	e39fe0ef          	jal	ra,80002c98 <bread>
    80003e64:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e66:	40000613          	li	a2,1024
    80003e6a:	05850593          	addi	a1,a0,88
    80003e6e:	05848513          	addi	a0,s1,88
    80003e72:	e2bfc0ef          	jal	ra,80000c9c <memmove>
    bwrite(to);  // write the log
    80003e76:	8526                	mv	a0,s1
    80003e78:	ef7fe0ef          	jal	ra,80002d6e <bwrite>
    brelse(from);
    80003e7c:	854e                	mv	a0,s3
    80003e7e:	f23fe0ef          	jal	ra,80002da0 <brelse>
    brelse(to);
    80003e82:	8526                	mv	a0,s1
    80003e84:	f1dfe0ef          	jal	ra,80002da0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e88:	2905                	addiw	s2,s2,1
    80003e8a:	0a91                	addi	s5,s5,4
    80003e8c:	028a2783          	lw	a5,40(s4)
    80003e90:	faf94ae3          	blt	s2,a5,80003e44 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e94:	cd7ff0ef          	jal	ra,80003b6a <write_head>
    install_trans(0); // Now install writes to home locations
    80003e98:	4501                	li	a0,0
    80003e9a:	d3fff0ef          	jal	ra,80003bd8 <install_trans>
    log.lh.n = 0;
    80003e9e:	0001c797          	auipc	a5,0x1c
    80003ea2:	ce07a923          	sw	zero,-782(a5) # 8001fb90 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003ea6:	cc5ff0ef          	jal	ra,80003b6a <write_head>
    80003eaa:	bf25                	j	80003de2 <end_op+0x4a>

0000000080003eac <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003eac:	1101                	addi	sp,sp,-32
    80003eae:	ec06                	sd	ra,24(sp)
    80003eb0:	e822                	sd	s0,16(sp)
    80003eb2:	e426                	sd	s1,8(sp)
    80003eb4:	e04a                	sd	s2,0(sp)
    80003eb6:	1000                	addi	s0,sp,32
    80003eb8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003eba:	0001c917          	auipc	s2,0x1c
    80003ebe:	cae90913          	addi	s2,s2,-850 # 8001fb68 <log>
    80003ec2:	854a                	mv	a0,s2
    80003ec4:	ca9fc0ef          	jal	ra,80000b6c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003ec8:	02892603          	lw	a2,40(s2)
    80003ecc:	47f5                	li	a5,29
    80003ece:	04c7cc63          	blt	a5,a2,80003f26 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003ed2:	0001c797          	auipc	a5,0x1c
    80003ed6:	cb27a783          	lw	a5,-846(a5) # 8001fb84 <log+0x1c>
    80003eda:	04f05c63          	blez	a5,80003f32 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003ede:	4781                	li	a5,0
    80003ee0:	04c05f63          	blez	a2,80003f3e <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ee4:	44cc                	lw	a1,12(s1)
    80003ee6:	0001c717          	auipc	a4,0x1c
    80003eea:	cae70713          	addi	a4,a4,-850 # 8001fb94 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003eee:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ef0:	4314                	lw	a3,0(a4)
    80003ef2:	04b68663          	beq	a3,a1,80003f3e <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003ef6:	2785                	addiw	a5,a5,1
    80003ef8:	0711                	addi	a4,a4,4
    80003efa:	fef61be3          	bne	a2,a5,80003ef0 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003efe:	0621                	addi	a2,a2,8
    80003f00:	060a                	slli	a2,a2,0x2
    80003f02:	0001c797          	auipc	a5,0x1c
    80003f06:	c6678793          	addi	a5,a5,-922 # 8001fb68 <log>
    80003f0a:	963e                	add	a2,a2,a5
    80003f0c:	44dc                	lw	a5,12(s1)
    80003f0e:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003f10:	8526                	mv	a0,s1
    80003f12:	f19fe0ef          	jal	ra,80002e2a <bpin>
    log.lh.n++;
    80003f16:	0001c717          	auipc	a4,0x1c
    80003f1a:	c5270713          	addi	a4,a4,-942 # 8001fb68 <log>
    80003f1e:	571c                	lw	a5,40(a4)
    80003f20:	2785                	addiw	a5,a5,1
    80003f22:	d71c                	sw	a5,40(a4)
    80003f24:	a815                	j	80003f58 <log_write+0xac>
    panic("too big a transaction");
    80003f26:	00003517          	auipc	a0,0x3
    80003f2a:	73a50513          	addi	a0,a0,1850 # 80007660 <syscalls+0x270>
    80003f2e:	85dfc0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    80003f32:	00003517          	auipc	a0,0x3
    80003f36:	74650513          	addi	a0,a0,1862 # 80007678 <syscalls+0x288>
    80003f3a:	851fc0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    80003f3e:	00878713          	addi	a4,a5,8
    80003f42:	00271693          	slli	a3,a4,0x2
    80003f46:	0001c717          	auipc	a4,0x1c
    80003f4a:	c2270713          	addi	a4,a4,-990 # 8001fb68 <log>
    80003f4e:	9736                	add	a4,a4,a3
    80003f50:	44d4                	lw	a3,12(s1)
    80003f52:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003f54:	faf60ee3          	beq	a2,a5,80003f10 <log_write+0x64>
  }
  release(&log.lock);
    80003f58:	0001c517          	auipc	a0,0x1c
    80003f5c:	c1050513          	addi	a0,a0,-1008 # 8001fb68 <log>
    80003f60:	ca5fc0ef          	jal	ra,80000c04 <release>
}
    80003f64:	60e2                	ld	ra,24(sp)
    80003f66:	6442                	ld	s0,16(sp)
    80003f68:	64a2                	ld	s1,8(sp)
    80003f6a:	6902                	ld	s2,0(sp)
    80003f6c:	6105                	addi	sp,sp,32
    80003f6e:	8082                	ret

0000000080003f70 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f70:	1101                	addi	sp,sp,-32
    80003f72:	ec06                	sd	ra,24(sp)
    80003f74:	e822                	sd	s0,16(sp)
    80003f76:	e426                	sd	s1,8(sp)
    80003f78:	e04a                	sd	s2,0(sp)
    80003f7a:	1000                	addi	s0,sp,32
    80003f7c:	84aa                	mv	s1,a0
    80003f7e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f80:	00003597          	auipc	a1,0x3
    80003f84:	71858593          	addi	a1,a1,1816 # 80007698 <syscalls+0x2a8>
    80003f88:	0521                	addi	a0,a0,8
    80003f8a:	b63fc0ef          	jal	ra,80000aec <initlock>
  lk->name = name;
    80003f8e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f92:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f96:	0204a423          	sw	zero,40(s1)
}
    80003f9a:	60e2                	ld	ra,24(sp)
    80003f9c:	6442                	ld	s0,16(sp)
    80003f9e:	64a2                	ld	s1,8(sp)
    80003fa0:	6902                	ld	s2,0(sp)
    80003fa2:	6105                	addi	sp,sp,32
    80003fa4:	8082                	ret

0000000080003fa6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003fa6:	1101                	addi	sp,sp,-32
    80003fa8:	ec06                	sd	ra,24(sp)
    80003faa:	e822                	sd	s0,16(sp)
    80003fac:	e426                	sd	s1,8(sp)
    80003fae:	e04a                	sd	s2,0(sp)
    80003fb0:	1000                	addi	s0,sp,32
    80003fb2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fb4:	00850913          	addi	s2,a0,8
    80003fb8:	854a                	mv	a0,s2
    80003fba:	bb3fc0ef          	jal	ra,80000b6c <acquire>
  while (lk->locked) {
    80003fbe:	409c                	lw	a5,0(s1)
    80003fc0:	c799                	beqz	a5,80003fce <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003fc2:	85ca                	mv	a1,s2
    80003fc4:	8526                	mv	a0,s1
    80003fc6:	e4ffd0ef          	jal	ra,80001e14 <sleep>
  while (lk->locked) {
    80003fca:	409c                	lw	a5,0(s1)
    80003fcc:	fbfd                	bnez	a5,80003fc2 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003fce:	4785                	li	a5,1
    80003fd0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003fd2:	833fd0ef          	jal	ra,80001804 <myproc>
    80003fd6:	591c                	lw	a5,48(a0)
    80003fd8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003fda:	854a                	mv	a0,s2
    80003fdc:	c29fc0ef          	jal	ra,80000c04 <release>
}
    80003fe0:	60e2                	ld	ra,24(sp)
    80003fe2:	6442                	ld	s0,16(sp)
    80003fe4:	64a2                	ld	s1,8(sp)
    80003fe6:	6902                	ld	s2,0(sp)
    80003fe8:	6105                	addi	sp,sp,32
    80003fea:	8082                	ret

0000000080003fec <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003fec:	1101                	addi	sp,sp,-32
    80003fee:	ec06                	sd	ra,24(sp)
    80003ff0:	e822                	sd	s0,16(sp)
    80003ff2:	e426                	sd	s1,8(sp)
    80003ff4:	e04a                	sd	s2,0(sp)
    80003ff6:	1000                	addi	s0,sp,32
    80003ff8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003ffa:	00850913          	addi	s2,a0,8
    80003ffe:	854a                	mv	a0,s2
    80004000:	b6dfc0ef          	jal	ra,80000b6c <acquire>
  lk->locked = 0;
    80004004:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004008:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000400c:	8526                	mv	a0,s1
    8000400e:	e53fd0ef          	jal	ra,80001e60 <wakeup>
  release(&lk->lk);
    80004012:	854a                	mv	a0,s2
    80004014:	bf1fc0ef          	jal	ra,80000c04 <release>
}
    80004018:	60e2                	ld	ra,24(sp)
    8000401a:	6442                	ld	s0,16(sp)
    8000401c:	64a2                	ld	s1,8(sp)
    8000401e:	6902                	ld	s2,0(sp)
    80004020:	6105                	addi	sp,sp,32
    80004022:	8082                	ret

0000000080004024 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004024:	7179                	addi	sp,sp,-48
    80004026:	f406                	sd	ra,40(sp)
    80004028:	f022                	sd	s0,32(sp)
    8000402a:	ec26                	sd	s1,24(sp)
    8000402c:	e84a                	sd	s2,16(sp)
    8000402e:	e44e                	sd	s3,8(sp)
    80004030:	1800                	addi	s0,sp,48
    80004032:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004034:	00850913          	addi	s2,a0,8
    80004038:	854a                	mv	a0,s2
    8000403a:	b33fc0ef          	jal	ra,80000b6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000403e:	409c                	lw	a5,0(s1)
    80004040:	ef89                	bnez	a5,8000405a <holdingsleep+0x36>
    80004042:	4481                	li	s1,0
  release(&lk->lk);
    80004044:	854a                	mv	a0,s2
    80004046:	bbffc0ef          	jal	ra,80000c04 <release>
  return r;
}
    8000404a:	8526                	mv	a0,s1
    8000404c:	70a2                	ld	ra,40(sp)
    8000404e:	7402                	ld	s0,32(sp)
    80004050:	64e2                	ld	s1,24(sp)
    80004052:	6942                	ld	s2,16(sp)
    80004054:	69a2                	ld	s3,8(sp)
    80004056:	6145                	addi	sp,sp,48
    80004058:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000405a:	0284a983          	lw	s3,40(s1)
    8000405e:	fa6fd0ef          	jal	ra,80001804 <myproc>
    80004062:	5904                	lw	s1,48(a0)
    80004064:	413484b3          	sub	s1,s1,s3
    80004068:	0014b493          	seqz	s1,s1
    8000406c:	bfe1                	j	80004044 <holdingsleep+0x20>

000000008000406e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000406e:	1141                	addi	sp,sp,-16
    80004070:	e406                	sd	ra,8(sp)
    80004072:	e022                	sd	s0,0(sp)
    80004074:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004076:	00003597          	auipc	a1,0x3
    8000407a:	63258593          	addi	a1,a1,1586 # 800076a8 <syscalls+0x2b8>
    8000407e:	0001c517          	auipc	a0,0x1c
    80004082:	c3250513          	addi	a0,a0,-974 # 8001fcb0 <ftable>
    80004086:	a67fc0ef          	jal	ra,80000aec <initlock>
}
    8000408a:	60a2                	ld	ra,8(sp)
    8000408c:	6402                	ld	s0,0(sp)
    8000408e:	0141                	addi	sp,sp,16
    80004090:	8082                	ret

0000000080004092 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004092:	1101                	addi	sp,sp,-32
    80004094:	ec06                	sd	ra,24(sp)
    80004096:	e822                	sd	s0,16(sp)
    80004098:	e426                	sd	s1,8(sp)
    8000409a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000409c:	0001c517          	auipc	a0,0x1c
    800040a0:	c1450513          	addi	a0,a0,-1004 # 8001fcb0 <ftable>
    800040a4:	ac9fc0ef          	jal	ra,80000b6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040a8:	0001c497          	auipc	s1,0x1c
    800040ac:	c2048493          	addi	s1,s1,-992 # 8001fcc8 <ftable+0x18>
    800040b0:	0001d717          	auipc	a4,0x1d
    800040b4:	bb870713          	addi	a4,a4,-1096 # 80020c68 <disk>
    if(f->ref == 0){
    800040b8:	40dc                	lw	a5,4(s1)
    800040ba:	cf89                	beqz	a5,800040d4 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040bc:	02848493          	addi	s1,s1,40
    800040c0:	fee49ce3          	bne	s1,a4,800040b8 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800040c4:	0001c517          	auipc	a0,0x1c
    800040c8:	bec50513          	addi	a0,a0,-1044 # 8001fcb0 <ftable>
    800040cc:	b39fc0ef          	jal	ra,80000c04 <release>
  return 0;
    800040d0:	4481                	li	s1,0
    800040d2:	a809                	j	800040e4 <filealloc+0x52>
      f->ref = 1;
    800040d4:	4785                	li	a5,1
    800040d6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800040d8:	0001c517          	auipc	a0,0x1c
    800040dc:	bd850513          	addi	a0,a0,-1064 # 8001fcb0 <ftable>
    800040e0:	b25fc0ef          	jal	ra,80000c04 <release>
}
    800040e4:	8526                	mv	a0,s1
    800040e6:	60e2                	ld	ra,24(sp)
    800040e8:	6442                	ld	s0,16(sp)
    800040ea:	64a2                	ld	s1,8(sp)
    800040ec:	6105                	addi	sp,sp,32
    800040ee:	8082                	ret

00000000800040f0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800040f0:	1101                	addi	sp,sp,-32
    800040f2:	ec06                	sd	ra,24(sp)
    800040f4:	e822                	sd	s0,16(sp)
    800040f6:	e426                	sd	s1,8(sp)
    800040f8:	1000                	addi	s0,sp,32
    800040fa:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800040fc:	0001c517          	auipc	a0,0x1c
    80004100:	bb450513          	addi	a0,a0,-1100 # 8001fcb0 <ftable>
    80004104:	a69fc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    80004108:	40dc                	lw	a5,4(s1)
    8000410a:	02f05063          	blez	a5,8000412a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000410e:	2785                	addiw	a5,a5,1
    80004110:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004112:	0001c517          	auipc	a0,0x1c
    80004116:	b9e50513          	addi	a0,a0,-1122 # 8001fcb0 <ftable>
    8000411a:	aebfc0ef          	jal	ra,80000c04 <release>
  return f;
}
    8000411e:	8526                	mv	a0,s1
    80004120:	60e2                	ld	ra,24(sp)
    80004122:	6442                	ld	s0,16(sp)
    80004124:	64a2                	ld	s1,8(sp)
    80004126:	6105                	addi	sp,sp,32
    80004128:	8082                	ret
    panic("filedup");
    8000412a:	00003517          	auipc	a0,0x3
    8000412e:	58650513          	addi	a0,a0,1414 # 800076b0 <syscalls+0x2c0>
    80004132:	e58fc0ef          	jal	ra,8000078a <panic>

0000000080004136 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004136:	7139                	addi	sp,sp,-64
    80004138:	fc06                	sd	ra,56(sp)
    8000413a:	f822                	sd	s0,48(sp)
    8000413c:	f426                	sd	s1,40(sp)
    8000413e:	f04a                	sd	s2,32(sp)
    80004140:	ec4e                	sd	s3,24(sp)
    80004142:	e852                	sd	s4,16(sp)
    80004144:	e456                	sd	s5,8(sp)
    80004146:	0080                	addi	s0,sp,64
    80004148:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000414a:	0001c517          	auipc	a0,0x1c
    8000414e:	b6650513          	addi	a0,a0,-1178 # 8001fcb0 <ftable>
    80004152:	a1bfc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    80004156:	40dc                	lw	a5,4(s1)
    80004158:	04f05963          	blez	a5,800041aa <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    8000415c:	37fd                	addiw	a5,a5,-1
    8000415e:	0007871b          	sext.w	a4,a5
    80004162:	c0dc                	sw	a5,4(s1)
    80004164:	04e04963          	bgtz	a4,800041b6 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004168:	0004a903          	lw	s2,0(s1)
    8000416c:	0094ca83          	lbu	s5,9(s1)
    80004170:	0104ba03          	ld	s4,16(s1)
    80004174:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004178:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000417c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004180:	0001c517          	auipc	a0,0x1c
    80004184:	b3050513          	addi	a0,a0,-1232 # 8001fcb0 <ftable>
    80004188:	a7dfc0ef          	jal	ra,80000c04 <release>

  if(ff.type == FD_PIPE){
    8000418c:	4785                	li	a5,1
    8000418e:	04f90363          	beq	s2,a5,800041d4 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004192:	3979                	addiw	s2,s2,-2
    80004194:	4785                	li	a5,1
    80004196:	0327e663          	bltu	a5,s2,800041c2 <fileclose+0x8c>
    begin_op();
    8000419a:	b8fff0ef          	jal	ra,80003d28 <begin_op>
    iput(ff.ip);
    8000419e:	854e                	mv	a0,s3
    800041a0:	b28ff0ef          	jal	ra,800034c8 <iput>
    end_op();
    800041a4:	bf5ff0ef          	jal	ra,80003d98 <end_op>
    800041a8:	a829                	j	800041c2 <fileclose+0x8c>
    panic("fileclose");
    800041aa:	00003517          	auipc	a0,0x3
    800041ae:	50e50513          	addi	a0,a0,1294 # 800076b8 <syscalls+0x2c8>
    800041b2:	dd8fc0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    800041b6:	0001c517          	auipc	a0,0x1c
    800041ba:	afa50513          	addi	a0,a0,-1286 # 8001fcb0 <ftable>
    800041be:	a47fc0ef          	jal	ra,80000c04 <release>
  }
}
    800041c2:	70e2                	ld	ra,56(sp)
    800041c4:	7442                	ld	s0,48(sp)
    800041c6:	74a2                	ld	s1,40(sp)
    800041c8:	7902                	ld	s2,32(sp)
    800041ca:	69e2                	ld	s3,24(sp)
    800041cc:	6a42                	ld	s4,16(sp)
    800041ce:	6aa2                	ld	s5,8(sp)
    800041d0:	6121                	addi	sp,sp,64
    800041d2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800041d4:	85d6                	mv	a1,s5
    800041d6:	8552                	mv	a0,s4
    800041d8:	2ec000ef          	jal	ra,800044c4 <pipeclose>
    800041dc:	b7dd                	j	800041c2 <fileclose+0x8c>

00000000800041de <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800041de:	715d                	addi	sp,sp,-80
    800041e0:	e486                	sd	ra,72(sp)
    800041e2:	e0a2                	sd	s0,64(sp)
    800041e4:	fc26                	sd	s1,56(sp)
    800041e6:	f84a                	sd	s2,48(sp)
    800041e8:	f44e                	sd	s3,40(sp)
    800041ea:	0880                	addi	s0,sp,80
    800041ec:	84aa                	mv	s1,a0
    800041ee:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800041f0:	e14fd0ef          	jal	ra,80001804 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800041f4:	409c                	lw	a5,0(s1)
    800041f6:	37f9                	addiw	a5,a5,-2
    800041f8:	4705                	li	a4,1
    800041fa:	02f76f63          	bltu	a4,a5,80004238 <filestat+0x5a>
    800041fe:	892a                	mv	s2,a0
    ilock(f->ip);
    80004200:	6c88                	ld	a0,24(s1)
    80004202:	948ff0ef          	jal	ra,8000334a <ilock>
    stati(f->ip, &st);
    80004206:	fb840593          	addi	a1,s0,-72
    8000420a:	6c88                	ld	a0,24(s1)
    8000420c:	ca0ff0ef          	jal	ra,800036ac <stati>
    iunlock(f->ip);
    80004210:	6c88                	ld	a0,24(s1)
    80004212:	9e2ff0ef          	jal	ra,800033f4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004216:	46e1                	li	a3,24
    80004218:	fb840613          	addi	a2,s0,-72
    8000421c:	85ce                	mv	a1,s3
    8000421e:	05093503          	ld	a0,80(s2)
    80004222:	b30fd0ef          	jal	ra,80001552 <copyout>
    80004226:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000422a:	60a6                	ld	ra,72(sp)
    8000422c:	6406                	ld	s0,64(sp)
    8000422e:	74e2                	ld	s1,56(sp)
    80004230:	7942                	ld	s2,48(sp)
    80004232:	79a2                	ld	s3,40(sp)
    80004234:	6161                	addi	sp,sp,80
    80004236:	8082                	ret
  return -1;
    80004238:	557d                	li	a0,-1
    8000423a:	bfc5                	j	8000422a <filestat+0x4c>

000000008000423c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000423c:	7179                	addi	sp,sp,-48
    8000423e:	f406                	sd	ra,40(sp)
    80004240:	f022                	sd	s0,32(sp)
    80004242:	ec26                	sd	s1,24(sp)
    80004244:	e84a                	sd	s2,16(sp)
    80004246:	e44e                	sd	s3,8(sp)
    80004248:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000424a:	00854783          	lbu	a5,8(a0)
    8000424e:	cbc1                	beqz	a5,800042de <fileread+0xa2>
    80004250:	84aa                	mv	s1,a0
    80004252:	89ae                	mv	s3,a1
    80004254:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004256:	411c                	lw	a5,0(a0)
    80004258:	4705                	li	a4,1
    8000425a:	04e78363          	beq	a5,a4,800042a0 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000425e:	470d                	li	a4,3
    80004260:	04e78563          	beq	a5,a4,800042aa <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004264:	4709                	li	a4,2
    80004266:	06e79663          	bne	a5,a4,800042d2 <fileread+0x96>
    ilock(f->ip);
    8000426a:	6d08                	ld	a0,24(a0)
    8000426c:	8deff0ef          	jal	ra,8000334a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004270:	874a                	mv	a4,s2
    80004272:	5094                	lw	a3,32(s1)
    80004274:	864e                	mv	a2,s3
    80004276:	4585                	li	a1,1
    80004278:	6c88                	ld	a0,24(s1)
    8000427a:	c5cff0ef          	jal	ra,800036d6 <readi>
    8000427e:	892a                	mv	s2,a0
    80004280:	00a05563          	blez	a0,8000428a <fileread+0x4e>
      f->off += r;
    80004284:	509c                	lw	a5,32(s1)
    80004286:	9fa9                	addw	a5,a5,a0
    80004288:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000428a:	6c88                	ld	a0,24(s1)
    8000428c:	968ff0ef          	jal	ra,800033f4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004290:	854a                	mv	a0,s2
    80004292:	70a2                	ld	ra,40(sp)
    80004294:	7402                	ld	s0,32(sp)
    80004296:	64e2                	ld	s1,24(sp)
    80004298:	6942                	ld	s2,16(sp)
    8000429a:	69a2                	ld	s3,8(sp)
    8000429c:	6145                	addi	sp,sp,48
    8000429e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800042a0:	6908                	ld	a0,16(a0)
    800042a2:	34e000ef          	jal	ra,800045f0 <piperead>
    800042a6:	892a                	mv	s2,a0
    800042a8:	b7e5                	j	80004290 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800042aa:	02451783          	lh	a5,36(a0)
    800042ae:	03079693          	slli	a3,a5,0x30
    800042b2:	92c1                	srli	a3,a3,0x30
    800042b4:	4725                	li	a4,9
    800042b6:	02d76663          	bltu	a4,a3,800042e2 <fileread+0xa6>
    800042ba:	0792                	slli	a5,a5,0x4
    800042bc:	0001c717          	auipc	a4,0x1c
    800042c0:	95470713          	addi	a4,a4,-1708 # 8001fc10 <devsw>
    800042c4:	97ba                	add	a5,a5,a4
    800042c6:	639c                	ld	a5,0(a5)
    800042c8:	cf99                	beqz	a5,800042e6 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800042ca:	4505                	li	a0,1
    800042cc:	9782                	jalr	a5
    800042ce:	892a                	mv	s2,a0
    800042d0:	b7c1                	j	80004290 <fileread+0x54>
    panic("fileread");
    800042d2:	00003517          	auipc	a0,0x3
    800042d6:	3f650513          	addi	a0,a0,1014 # 800076c8 <syscalls+0x2d8>
    800042da:	cb0fc0ef          	jal	ra,8000078a <panic>
    return -1;
    800042de:	597d                	li	s2,-1
    800042e0:	bf45                	j	80004290 <fileread+0x54>
      return -1;
    800042e2:	597d                	li	s2,-1
    800042e4:	b775                	j	80004290 <fileread+0x54>
    800042e6:	597d                	li	s2,-1
    800042e8:	b765                	j	80004290 <fileread+0x54>

00000000800042ea <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800042ea:	715d                	addi	sp,sp,-80
    800042ec:	e486                	sd	ra,72(sp)
    800042ee:	e0a2                	sd	s0,64(sp)
    800042f0:	fc26                	sd	s1,56(sp)
    800042f2:	f84a                	sd	s2,48(sp)
    800042f4:	f44e                	sd	s3,40(sp)
    800042f6:	f052                	sd	s4,32(sp)
    800042f8:	ec56                	sd	s5,24(sp)
    800042fa:	e85a                	sd	s6,16(sp)
    800042fc:	e45e                	sd	s7,8(sp)
    800042fe:	e062                	sd	s8,0(sp)
    80004300:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004302:	00954783          	lbu	a5,9(a0)
    80004306:	0e078863          	beqz	a5,800043f6 <filewrite+0x10c>
    8000430a:	892a                	mv	s2,a0
    8000430c:	8aae                	mv	s5,a1
    8000430e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004310:	411c                	lw	a5,0(a0)
    80004312:	4705                	li	a4,1
    80004314:	02e78263          	beq	a5,a4,80004338 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004318:	470d                	li	a4,3
    8000431a:	02e78463          	beq	a5,a4,80004342 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000431e:	4709                	li	a4,2
    80004320:	0ce79563          	bne	a5,a4,800043ea <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004324:	0ac05163          	blez	a2,800043c6 <filewrite+0xdc>
    int i = 0;
    80004328:	4981                	li	s3,0
    8000432a:	6b05                	lui	s6,0x1
    8000432c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004330:	6b85                	lui	s7,0x1
    80004332:	c00b8b9b          	addiw	s7,s7,-1024
    80004336:	a041                	j	800043b6 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004338:	6908                	ld	a0,16(a0)
    8000433a:	1e2000ef          	jal	ra,8000451c <pipewrite>
    8000433e:	8a2a                	mv	s4,a0
    80004340:	a071                	j	800043cc <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004342:	02451783          	lh	a5,36(a0)
    80004346:	03079693          	slli	a3,a5,0x30
    8000434a:	92c1                	srli	a3,a3,0x30
    8000434c:	4725                	li	a4,9
    8000434e:	0ad76663          	bltu	a4,a3,800043fa <filewrite+0x110>
    80004352:	0792                	slli	a5,a5,0x4
    80004354:	0001c717          	auipc	a4,0x1c
    80004358:	8bc70713          	addi	a4,a4,-1860 # 8001fc10 <devsw>
    8000435c:	97ba                	add	a5,a5,a4
    8000435e:	679c                	ld	a5,8(a5)
    80004360:	cfd9                	beqz	a5,800043fe <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004362:	4505                	li	a0,1
    80004364:	9782                	jalr	a5
    80004366:	8a2a                	mv	s4,a0
    80004368:	a095                	j	800043cc <filewrite+0xe2>
    8000436a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000436e:	9bbff0ef          	jal	ra,80003d28 <begin_op>
      ilock(f->ip);
    80004372:	01893503          	ld	a0,24(s2)
    80004376:	fd5fe0ef          	jal	ra,8000334a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000437a:	8762                	mv	a4,s8
    8000437c:	02092683          	lw	a3,32(s2)
    80004380:	01598633          	add	a2,s3,s5
    80004384:	4585                	li	a1,1
    80004386:	01893503          	ld	a0,24(s2)
    8000438a:	c30ff0ef          	jal	ra,800037ba <writei>
    8000438e:	84aa                	mv	s1,a0
    80004390:	00a05763          	blez	a0,8000439e <filewrite+0xb4>
        f->off += r;
    80004394:	02092783          	lw	a5,32(s2)
    80004398:	9fa9                	addw	a5,a5,a0
    8000439a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000439e:	01893503          	ld	a0,24(s2)
    800043a2:	852ff0ef          	jal	ra,800033f4 <iunlock>
      end_op();
    800043a6:	9f3ff0ef          	jal	ra,80003d98 <end_op>

      if(r != n1){
    800043aa:	009c1f63          	bne	s8,s1,800043c8 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800043ae:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800043b2:	0149db63          	bge	s3,s4,800043c8 <filewrite+0xde>
      int n1 = n - i;
    800043b6:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800043ba:	84be                	mv	s1,a5
    800043bc:	2781                	sext.w	a5,a5
    800043be:	fafb56e3          	bge	s6,a5,8000436a <filewrite+0x80>
    800043c2:	84de                	mv	s1,s7
    800043c4:	b75d                	j	8000436a <filewrite+0x80>
    int i = 0;
    800043c6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800043c8:	013a1f63          	bne	s4,s3,800043e6 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800043cc:	8552                	mv	a0,s4
    800043ce:	60a6                	ld	ra,72(sp)
    800043d0:	6406                	ld	s0,64(sp)
    800043d2:	74e2                	ld	s1,56(sp)
    800043d4:	7942                	ld	s2,48(sp)
    800043d6:	79a2                	ld	s3,40(sp)
    800043d8:	7a02                	ld	s4,32(sp)
    800043da:	6ae2                	ld	s5,24(sp)
    800043dc:	6b42                	ld	s6,16(sp)
    800043de:	6ba2                	ld	s7,8(sp)
    800043e0:	6c02                	ld	s8,0(sp)
    800043e2:	6161                	addi	sp,sp,80
    800043e4:	8082                	ret
    ret = (i == n ? n : -1);
    800043e6:	5a7d                	li	s4,-1
    800043e8:	b7d5                	j	800043cc <filewrite+0xe2>
    panic("filewrite");
    800043ea:	00003517          	auipc	a0,0x3
    800043ee:	2ee50513          	addi	a0,a0,750 # 800076d8 <syscalls+0x2e8>
    800043f2:	b98fc0ef          	jal	ra,8000078a <panic>
    return -1;
    800043f6:	5a7d                	li	s4,-1
    800043f8:	bfd1                	j	800043cc <filewrite+0xe2>
      return -1;
    800043fa:	5a7d                	li	s4,-1
    800043fc:	bfc1                	j	800043cc <filewrite+0xe2>
    800043fe:	5a7d                	li	s4,-1
    80004400:	b7f1                	j	800043cc <filewrite+0xe2>

0000000080004402 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004402:	7179                	addi	sp,sp,-48
    80004404:	f406                	sd	ra,40(sp)
    80004406:	f022                	sd	s0,32(sp)
    80004408:	ec26                	sd	s1,24(sp)
    8000440a:	e84a                	sd	s2,16(sp)
    8000440c:	e44e                	sd	s3,8(sp)
    8000440e:	e052                	sd	s4,0(sp)
    80004410:	1800                	addi	s0,sp,48
    80004412:	84aa                	mv	s1,a0
    80004414:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004416:	0005b023          	sd	zero,0(a1)
    8000441a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000441e:	c75ff0ef          	jal	ra,80004092 <filealloc>
    80004422:	e088                	sd	a0,0(s1)
    80004424:	cd35                	beqz	a0,800044a0 <pipealloc+0x9e>
    80004426:	c6dff0ef          	jal	ra,80004092 <filealloc>
    8000442a:	00aa3023          	sd	a0,0(s4)
    8000442e:	c52d                	beqz	a0,80004498 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004430:	e6cfc0ef          	jal	ra,80000a9c <kalloc>
    80004434:	892a                	mv	s2,a0
    80004436:	cd31                	beqz	a0,80004492 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004438:	4985                	li	s3,1
    8000443a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000443e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004442:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004446:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000444a:	00003597          	auipc	a1,0x3
    8000444e:	29e58593          	addi	a1,a1,670 # 800076e8 <syscalls+0x2f8>
    80004452:	e9afc0ef          	jal	ra,80000aec <initlock>
  (*f0)->type = FD_PIPE;
    80004456:	609c                	ld	a5,0(s1)
    80004458:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000445c:	609c                	ld	a5,0(s1)
    8000445e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004462:	609c                	ld	a5,0(s1)
    80004464:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004468:	609c                	ld	a5,0(s1)
    8000446a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000446e:	000a3783          	ld	a5,0(s4)
    80004472:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004476:	000a3783          	ld	a5,0(s4)
    8000447a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000447e:	000a3783          	ld	a5,0(s4)
    80004482:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004486:	000a3783          	ld	a5,0(s4)
    8000448a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000448e:	4501                	li	a0,0
    80004490:	a005                	j	800044b0 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004492:	6088                	ld	a0,0(s1)
    80004494:	e501                	bnez	a0,8000449c <pipealloc+0x9a>
    80004496:	a029                	j	800044a0 <pipealloc+0x9e>
    80004498:	6088                	ld	a0,0(s1)
    8000449a:	c11d                	beqz	a0,800044c0 <pipealloc+0xbe>
    fileclose(*f0);
    8000449c:	c9bff0ef          	jal	ra,80004136 <fileclose>
  if(*f1)
    800044a0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800044a4:	557d                	li	a0,-1
  if(*f1)
    800044a6:	c789                	beqz	a5,800044b0 <pipealloc+0xae>
    fileclose(*f1);
    800044a8:	853e                	mv	a0,a5
    800044aa:	c8dff0ef          	jal	ra,80004136 <fileclose>
  return -1;
    800044ae:	557d                	li	a0,-1
}
    800044b0:	70a2                	ld	ra,40(sp)
    800044b2:	7402                	ld	s0,32(sp)
    800044b4:	64e2                	ld	s1,24(sp)
    800044b6:	6942                	ld	s2,16(sp)
    800044b8:	69a2                	ld	s3,8(sp)
    800044ba:	6a02                	ld	s4,0(sp)
    800044bc:	6145                	addi	sp,sp,48
    800044be:	8082                	ret
  return -1;
    800044c0:	557d                	li	a0,-1
    800044c2:	b7fd                	j	800044b0 <pipealloc+0xae>

00000000800044c4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800044c4:	1101                	addi	sp,sp,-32
    800044c6:	ec06                	sd	ra,24(sp)
    800044c8:	e822                	sd	s0,16(sp)
    800044ca:	e426                	sd	s1,8(sp)
    800044cc:	e04a                	sd	s2,0(sp)
    800044ce:	1000                	addi	s0,sp,32
    800044d0:	84aa                	mv	s1,a0
    800044d2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800044d4:	e98fc0ef          	jal	ra,80000b6c <acquire>
  if(writable){
    800044d8:	02090763          	beqz	s2,80004506 <pipeclose+0x42>
    pi->writeopen = 0;
    800044dc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800044e0:	21848513          	addi	a0,s1,536
    800044e4:	97dfd0ef          	jal	ra,80001e60 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800044e8:	2204b783          	ld	a5,544(s1)
    800044ec:	e785                	bnez	a5,80004514 <pipeclose+0x50>
    release(&pi->lock);
    800044ee:	8526                	mv	a0,s1
    800044f0:	f14fc0ef          	jal	ra,80000c04 <release>
    kfree((char*)pi);
    800044f4:	8526                	mv	a0,s1
    800044f6:	cc6fc0ef          	jal	ra,800009bc <kfree>
  } else
    release(&pi->lock);
}
    800044fa:	60e2                	ld	ra,24(sp)
    800044fc:	6442                	ld	s0,16(sp)
    800044fe:	64a2                	ld	s1,8(sp)
    80004500:	6902                	ld	s2,0(sp)
    80004502:	6105                	addi	sp,sp,32
    80004504:	8082                	ret
    pi->readopen = 0;
    80004506:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000450a:	21c48513          	addi	a0,s1,540
    8000450e:	953fd0ef          	jal	ra,80001e60 <wakeup>
    80004512:	bfd9                	j	800044e8 <pipeclose+0x24>
    release(&pi->lock);
    80004514:	8526                	mv	a0,s1
    80004516:	eeefc0ef          	jal	ra,80000c04 <release>
}
    8000451a:	b7c5                	j	800044fa <pipeclose+0x36>

000000008000451c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000451c:	711d                	addi	sp,sp,-96
    8000451e:	ec86                	sd	ra,88(sp)
    80004520:	e8a2                	sd	s0,80(sp)
    80004522:	e4a6                	sd	s1,72(sp)
    80004524:	e0ca                	sd	s2,64(sp)
    80004526:	fc4e                	sd	s3,56(sp)
    80004528:	f852                	sd	s4,48(sp)
    8000452a:	f456                	sd	s5,40(sp)
    8000452c:	f05a                	sd	s6,32(sp)
    8000452e:	ec5e                	sd	s7,24(sp)
    80004530:	e862                	sd	s8,16(sp)
    80004532:	1080                	addi	s0,sp,96
    80004534:	84aa                	mv	s1,a0
    80004536:	8aae                	mv	s5,a1
    80004538:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000453a:	acafd0ef          	jal	ra,80001804 <myproc>
    8000453e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004540:	8526                	mv	a0,s1
    80004542:	e2afc0ef          	jal	ra,80000b6c <acquire>
  while(i < n){
    80004546:	09405c63          	blez	s4,800045de <pipewrite+0xc2>
  int i = 0;
    8000454a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000454c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000454e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004552:	21c48b93          	addi	s7,s1,540
    80004556:	a81d                	j	8000458c <pipewrite+0x70>
      release(&pi->lock);
    80004558:	8526                	mv	a0,s1
    8000455a:	eaafc0ef          	jal	ra,80000c04 <release>
      return -1;
    8000455e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004560:	854a                	mv	a0,s2
    80004562:	60e6                	ld	ra,88(sp)
    80004564:	6446                	ld	s0,80(sp)
    80004566:	64a6                	ld	s1,72(sp)
    80004568:	6906                	ld	s2,64(sp)
    8000456a:	79e2                	ld	s3,56(sp)
    8000456c:	7a42                	ld	s4,48(sp)
    8000456e:	7aa2                	ld	s5,40(sp)
    80004570:	7b02                	ld	s6,32(sp)
    80004572:	6be2                	ld	s7,24(sp)
    80004574:	6c42                	ld	s8,16(sp)
    80004576:	6125                	addi	sp,sp,96
    80004578:	8082                	ret
      wakeup(&pi->nread);
    8000457a:	8562                	mv	a0,s8
    8000457c:	8e5fd0ef          	jal	ra,80001e60 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004580:	85a6                	mv	a1,s1
    80004582:	855e                	mv	a0,s7
    80004584:	891fd0ef          	jal	ra,80001e14 <sleep>
  while(i < n){
    80004588:	05495c63          	bge	s2,s4,800045e0 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    8000458c:	2204a783          	lw	a5,544(s1)
    80004590:	d7e1                	beqz	a5,80004558 <pipewrite+0x3c>
    80004592:	854e                	mv	a0,s3
    80004594:	ab9fd0ef          	jal	ra,8000204c <killed>
    80004598:	f161                	bnez	a0,80004558 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000459a:	2184a783          	lw	a5,536(s1)
    8000459e:	21c4a703          	lw	a4,540(s1)
    800045a2:	2007879b          	addiw	a5,a5,512
    800045a6:	fcf70ae3          	beq	a4,a5,8000457a <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045aa:	4685                	li	a3,1
    800045ac:	01590633          	add	a2,s2,s5
    800045b0:	faf40593          	addi	a1,s0,-81
    800045b4:	0509b503          	ld	a0,80(s3)
    800045b8:	860fd0ef          	jal	ra,80001618 <copyin>
    800045bc:	03650263          	beq	a0,s6,800045e0 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800045c0:	21c4a783          	lw	a5,540(s1)
    800045c4:	0017871b          	addiw	a4,a5,1
    800045c8:	20e4ae23          	sw	a4,540(s1)
    800045cc:	1ff7f793          	andi	a5,a5,511
    800045d0:	97a6                	add	a5,a5,s1
    800045d2:	faf44703          	lbu	a4,-81(s0)
    800045d6:	00e78c23          	sb	a4,24(a5)
      i++;
    800045da:	2905                	addiw	s2,s2,1
    800045dc:	b775                	j	80004588 <pipewrite+0x6c>
  int i = 0;
    800045de:	4901                	li	s2,0
  wakeup(&pi->nread);
    800045e0:	21848513          	addi	a0,s1,536
    800045e4:	87dfd0ef          	jal	ra,80001e60 <wakeup>
  release(&pi->lock);
    800045e8:	8526                	mv	a0,s1
    800045ea:	e1afc0ef          	jal	ra,80000c04 <release>
  return i;
    800045ee:	bf8d                	j	80004560 <pipewrite+0x44>

00000000800045f0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800045f0:	715d                	addi	sp,sp,-80
    800045f2:	e486                	sd	ra,72(sp)
    800045f4:	e0a2                	sd	s0,64(sp)
    800045f6:	fc26                	sd	s1,56(sp)
    800045f8:	f84a                	sd	s2,48(sp)
    800045fa:	f44e                	sd	s3,40(sp)
    800045fc:	f052                	sd	s4,32(sp)
    800045fe:	ec56                	sd	s5,24(sp)
    80004600:	e85a                	sd	s6,16(sp)
    80004602:	0880                	addi	s0,sp,80
    80004604:	84aa                	mv	s1,a0
    80004606:	892e                	mv	s2,a1
    80004608:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000460a:	9fafd0ef          	jal	ra,80001804 <myproc>
    8000460e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004610:	8526                	mv	a0,s1
    80004612:	d5afc0ef          	jal	ra,80000b6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004616:	2184a703          	lw	a4,536(s1)
    8000461a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000461e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004622:	02f71363          	bne	a4,a5,80004648 <piperead+0x58>
    80004626:	2244a783          	lw	a5,548(s1)
    8000462a:	cf99                	beqz	a5,80004648 <piperead+0x58>
    if(killed(pr)){
    8000462c:	8552                	mv	a0,s4
    8000462e:	a1ffd0ef          	jal	ra,8000204c <killed>
    80004632:	e149                	bnez	a0,800046b4 <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004634:	85a6                	mv	a1,s1
    80004636:	854e                	mv	a0,s3
    80004638:	fdcfd0ef          	jal	ra,80001e14 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000463c:	2184a703          	lw	a4,536(s1)
    80004640:	21c4a783          	lw	a5,540(s1)
    80004644:	fef701e3          	beq	a4,a5,80004626 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004648:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000464a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000464c:	05505263          	blez	s5,80004690 <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    80004650:	2184a783          	lw	a5,536(s1)
    80004654:	21c4a703          	lw	a4,540(s1)
    80004658:	02f70c63          	beq	a4,a5,80004690 <piperead+0xa0>
    ch = pi->data[pi->nread % PIPESIZE];
    8000465c:	1ff7f793          	andi	a5,a5,511
    80004660:	97a6                	add	a5,a5,s1
    80004662:	0187c783          	lbu	a5,24(a5)
    80004666:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000466a:	4685                	li	a3,1
    8000466c:	fbf40613          	addi	a2,s0,-65
    80004670:	85ca                	mv	a1,s2
    80004672:	050a3503          	ld	a0,80(s4)
    80004676:	eddfc0ef          	jal	ra,80001552 <copyout>
    8000467a:	05650263          	beq	a0,s6,800046be <piperead+0xce>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000467e:	2184a783          	lw	a5,536(s1)
    80004682:	2785                	addiw	a5,a5,1
    80004684:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004688:	2985                	addiw	s3,s3,1
    8000468a:	0905                	addi	s2,s2,1
    8000468c:	fd3a92e3          	bne	s5,s3,80004650 <piperead+0x60>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004690:	21c48513          	addi	a0,s1,540
    80004694:	fccfd0ef          	jal	ra,80001e60 <wakeup>
  release(&pi->lock);
    80004698:	8526                	mv	a0,s1
    8000469a:	d6afc0ef          	jal	ra,80000c04 <release>
  return i;
}
    8000469e:	854e                	mv	a0,s3
    800046a0:	60a6                	ld	ra,72(sp)
    800046a2:	6406                	ld	s0,64(sp)
    800046a4:	74e2                	ld	s1,56(sp)
    800046a6:	7942                	ld	s2,48(sp)
    800046a8:	79a2                	ld	s3,40(sp)
    800046aa:	7a02                	ld	s4,32(sp)
    800046ac:	6ae2                	ld	s5,24(sp)
    800046ae:	6b42                	ld	s6,16(sp)
    800046b0:	6161                	addi	sp,sp,80
    800046b2:	8082                	ret
      release(&pi->lock);
    800046b4:	8526                	mv	a0,s1
    800046b6:	d4efc0ef          	jal	ra,80000c04 <release>
      return -1;
    800046ba:	59fd                	li	s3,-1
    800046bc:	b7cd                	j	8000469e <piperead+0xae>
      if(i == 0)
    800046be:	fc0999e3          	bnez	s3,80004690 <piperead+0xa0>
        i = -1;
    800046c2:	89aa                	mv	s3,a0
    800046c4:	b7f1                	j	80004690 <piperead+0xa0>

00000000800046c6 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800046c6:	1141                	addi	sp,sp,-16
    800046c8:	e422                	sd	s0,8(sp)
    800046ca:	0800                	addi	s0,sp,16
    800046cc:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800046ce:	8905                	andi	a0,a0,1
    800046d0:	c111                	beqz	a0,800046d4 <flags2perm+0xe>
      perm = PTE_X;
    800046d2:	4521                	li	a0,8
    if(flags & 0x2)
    800046d4:	8b89                	andi	a5,a5,2
    800046d6:	c399                	beqz	a5,800046dc <flags2perm+0x16>
      perm |= PTE_W;
    800046d8:	00456513          	ori	a0,a0,4
    return perm;
}
    800046dc:	6422                	ld	s0,8(sp)
    800046de:	0141                	addi	sp,sp,16
    800046e0:	8082                	ret

00000000800046e2 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800046e2:	de010113          	addi	sp,sp,-544
    800046e6:	20113c23          	sd	ra,536(sp)
    800046ea:	20813823          	sd	s0,528(sp)
    800046ee:	20913423          	sd	s1,520(sp)
    800046f2:	21213023          	sd	s2,512(sp)
    800046f6:	ffce                	sd	s3,504(sp)
    800046f8:	fbd2                	sd	s4,496(sp)
    800046fa:	f7d6                	sd	s5,488(sp)
    800046fc:	f3da                	sd	s6,480(sp)
    800046fe:	efde                	sd	s7,472(sp)
    80004700:	ebe2                	sd	s8,464(sp)
    80004702:	e7e6                	sd	s9,456(sp)
    80004704:	e3ea                	sd	s10,448(sp)
    80004706:	ff6e                	sd	s11,440(sp)
    80004708:	1400                	addi	s0,sp,544
    8000470a:	892a                	mv	s2,a0
    8000470c:	dea43423          	sd	a0,-536(s0)
    80004710:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004714:	8f0fd0ef          	jal	ra,80001804 <myproc>
    80004718:	84aa                	mv	s1,a0

  begin_op();
    8000471a:	e0eff0ef          	jal	ra,80003d28 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000471e:	854a                	mv	a0,s2
    80004720:	c18ff0ef          	jal	ra,80003b38 <namei>
    80004724:	c13d                	beqz	a0,8000478a <kexec+0xa8>
    80004726:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004728:	c23fe0ef          	jal	ra,8000334a <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000472c:	04000713          	li	a4,64
    80004730:	4681                	li	a3,0
    80004732:	e5040613          	addi	a2,s0,-432
    80004736:	4581                	li	a1,0
    80004738:	8556                	mv	a0,s5
    8000473a:	f9dfe0ef          	jal	ra,800036d6 <readi>
    8000473e:	04000793          	li	a5,64
    80004742:	00f51a63          	bne	a0,a5,80004756 <kexec+0x74>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004746:	e5042703          	lw	a4,-432(s0)
    8000474a:	464c47b7          	lui	a5,0x464c4
    8000474e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004752:	04f70063          	beq	a4,a5,80004792 <kexec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004756:	8556                	mv	a0,s5
    80004758:	df9fe0ef          	jal	ra,80003550 <iunlockput>
    end_op();
    8000475c:	e3cff0ef          	jal	ra,80003d98 <end_op>
  }
  return -1;
    80004760:	557d                	li	a0,-1
}
    80004762:	21813083          	ld	ra,536(sp)
    80004766:	21013403          	ld	s0,528(sp)
    8000476a:	20813483          	ld	s1,520(sp)
    8000476e:	20013903          	ld	s2,512(sp)
    80004772:	79fe                	ld	s3,504(sp)
    80004774:	7a5e                	ld	s4,496(sp)
    80004776:	7abe                	ld	s5,488(sp)
    80004778:	7b1e                	ld	s6,480(sp)
    8000477a:	6bfe                	ld	s7,472(sp)
    8000477c:	6c5e                	ld	s8,464(sp)
    8000477e:	6cbe                	ld	s9,456(sp)
    80004780:	6d1e                	ld	s10,448(sp)
    80004782:	7dfa                	ld	s11,440(sp)
    80004784:	22010113          	addi	sp,sp,544
    80004788:	8082                	ret
    end_op();
    8000478a:	e0eff0ef          	jal	ra,80003d98 <end_op>
    return -1;
    8000478e:	557d                	li	a0,-1
    80004790:	bfc9                	j	80004762 <kexec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    80004792:	8526                	mv	a0,s1
    80004794:	976fd0ef          	jal	ra,8000190a <proc_pagetable>
    80004798:	8b2a                	mv	s6,a0
    8000479a:	dd55                	beqz	a0,80004756 <kexec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000479c:	e7042783          	lw	a5,-400(s0)
    800047a0:	e8845703          	lhu	a4,-376(s0)
    800047a4:	c325                	beqz	a4,80004804 <kexec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047a6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047a8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800047ac:	6a05                	lui	s4,0x1
    800047ae:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800047b2:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800047b6:	6d85                	lui	s11,0x1
    800047b8:	7d7d                	lui	s10,0xfffff
    800047ba:	a411                	j	800049be <kexec+0x2dc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800047bc:	00003517          	auipc	a0,0x3
    800047c0:	f3450513          	addi	a0,a0,-204 # 800076f0 <syscalls+0x300>
    800047c4:	fc7fb0ef          	jal	ra,8000078a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800047c8:	874a                	mv	a4,s2
    800047ca:	009c86bb          	addw	a3,s9,s1
    800047ce:	4581                	li	a1,0
    800047d0:	8556                	mv	a0,s5
    800047d2:	f05fe0ef          	jal	ra,800036d6 <readi>
    800047d6:	2501                	sext.w	a0,a0
    800047d8:	18a91263          	bne	s2,a0,8000495c <kexec+0x27a>
  for(i = 0; i < sz; i += PGSIZE){
    800047dc:	009d84bb          	addw	s1,s11,s1
    800047e0:	013d09bb          	addw	s3,s10,s3
    800047e4:	1b74fd63          	bgeu	s1,s7,8000499e <kexec+0x2bc>
    pa = walkaddr(pagetable, va + i);
    800047e8:	02049593          	slli	a1,s1,0x20
    800047ec:	9181                	srli	a1,a1,0x20
    800047ee:	95e2                	add	a1,a1,s8
    800047f0:	855a                	mv	a0,s6
    800047f2:	f64fc0ef          	jal	ra,80000f56 <walkaddr>
    800047f6:	862a                	mv	a2,a0
    if(pa == 0)
    800047f8:	d171                	beqz	a0,800047bc <kexec+0xda>
      n = PGSIZE;
    800047fa:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800047fc:	fd49f6e3          	bgeu	s3,s4,800047c8 <kexec+0xe6>
      n = sz - i;
    80004800:	894e                	mv	s2,s3
    80004802:	b7d9                	j	800047c8 <kexec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004804:	4901                	li	s2,0
  iunlockput(ip);
    80004806:	8556                	mv	a0,s5
    80004808:	d49fe0ef          	jal	ra,80003550 <iunlockput>
  end_op();
    8000480c:	d8cff0ef          	jal	ra,80003d98 <end_op>
  p = myproc();
    80004810:	ff5fc0ef          	jal	ra,80001804 <myproc>
    80004814:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004816:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000481a:	6785                	lui	a5,0x1
    8000481c:	17fd                	addi	a5,a5,-1
    8000481e:	993e                	add	s2,s2,a5
    80004820:	77fd                	lui	a5,0xfffff
    80004822:	00f977b3          	and	a5,s2,a5
    80004826:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000482a:	4691                	li	a3,4
    8000482c:	6609                	lui	a2,0x2
    8000482e:	963e                	add	a2,a2,a5
    80004830:	85be                	mv	a1,a5
    80004832:	855a                	mv	a0,s6
    80004834:	9edfc0ef          	jal	ra,80001220 <uvmalloc>
    80004838:	8c2a                	mv	s8,a0
  ip = 0;
    8000483a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000483c:	12050063          	beqz	a0,8000495c <kexec+0x27a>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004840:	75f9                	lui	a1,0xffffe
    80004842:	95aa                	add	a1,a1,a0
    80004844:	855a                	mv	a0,s6
    80004846:	ba1fc0ef          	jal	ra,800013e6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000484a:	7afd                	lui	s5,0xfffff
    8000484c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000484e:	df043783          	ld	a5,-528(s0)
    80004852:	6388                	ld	a0,0(a5)
    80004854:	c135                	beqz	a0,800048b8 <kexec+0x1d6>
    80004856:	e9040993          	addi	s3,s0,-368
    8000485a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000485e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004860:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004862:	d56fc0ef          	jal	ra,80000db8 <strlen>
    80004866:	0015079b          	addiw	a5,a0,1
    8000486a:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000486e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004872:	11596a63          	bltu	s2,s5,80004986 <kexec+0x2a4>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004876:	df043d83          	ld	s11,-528(s0)
    8000487a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000487e:	8552                	mv	a0,s4
    80004880:	d38fc0ef          	jal	ra,80000db8 <strlen>
    80004884:	0015069b          	addiw	a3,a0,1
    80004888:	8652                	mv	a2,s4
    8000488a:	85ca                	mv	a1,s2
    8000488c:	855a                	mv	a0,s6
    8000488e:	cc5fc0ef          	jal	ra,80001552 <copyout>
    80004892:	0e054e63          	bltz	a0,8000498e <kexec+0x2ac>
    ustack[argc] = sp;
    80004896:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000489a:	0485                	addi	s1,s1,1
    8000489c:	008d8793          	addi	a5,s11,8
    800048a0:	def43823          	sd	a5,-528(s0)
    800048a4:	008db503          	ld	a0,8(s11)
    800048a8:	c911                	beqz	a0,800048bc <kexec+0x1da>
    if(argc >= MAXARG)
    800048aa:	09a1                	addi	s3,s3,8
    800048ac:	fb3c9be3          	bne	s9,s3,80004862 <kexec+0x180>
  sz = sz1;
    800048b0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800048b4:	4a81                	li	s5,0
    800048b6:	a05d                	j	8000495c <kexec+0x27a>
  sp = sz;
    800048b8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800048ba:	4481                	li	s1,0
  ustack[argc] = 0;
    800048bc:	00349793          	slli	a5,s1,0x3
    800048c0:	f9040713          	addi	a4,s0,-112
    800048c4:	97ba                	add	a5,a5,a4
    800048c6:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffde148>
  sp -= (argc+1) * sizeof(uint64);
    800048ca:	00148693          	addi	a3,s1,1
    800048ce:	068e                	slli	a3,a3,0x3
    800048d0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800048d4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800048d8:	01597663          	bgeu	s2,s5,800048e4 <kexec+0x202>
  sz = sz1;
    800048dc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800048e0:	4a81                	li	s5,0
    800048e2:	a8ad                	j	8000495c <kexec+0x27a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800048e4:	e9040613          	addi	a2,s0,-368
    800048e8:	85ca                	mv	a1,s2
    800048ea:	855a                	mv	a0,s6
    800048ec:	c67fc0ef          	jal	ra,80001552 <copyout>
    800048f0:	0a054363          	bltz	a0,80004996 <kexec+0x2b4>
  p->trapframe->a1 = sp;
    800048f4:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800048f8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800048fc:	de843783          	ld	a5,-536(s0)
    80004900:	0007c703          	lbu	a4,0(a5)
    80004904:	cf11                	beqz	a4,80004920 <kexec+0x23e>
    80004906:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004908:	02f00693          	li	a3,47
    8000490c:	a039                	j	8000491a <kexec+0x238>
      last = s+1;
    8000490e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004912:	0785                	addi	a5,a5,1
    80004914:	fff7c703          	lbu	a4,-1(a5)
    80004918:	c701                	beqz	a4,80004920 <kexec+0x23e>
    if(*s == '/')
    8000491a:	fed71ce3          	bne	a4,a3,80004912 <kexec+0x230>
    8000491e:	bfc5                	j	8000490e <kexec+0x22c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004920:	4641                	li	a2,16
    80004922:	de843583          	ld	a1,-536(s0)
    80004926:	158b8513          	addi	a0,s7,344
    8000492a:	c5cfc0ef          	jal	ra,80000d86 <safestrcpy>
  oldpagetable = p->pagetable;
    8000492e:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004932:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004936:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    8000493a:	058bb783          	ld	a5,88(s7)
    8000493e:	e6843703          	ld	a4,-408(s0)
    80004942:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004944:	058bb783          	ld	a5,88(s7)
    80004948:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000494c:	85ea                	mv	a1,s10
    8000494e:	840fd0ef          	jal	ra,8000198e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004952:	0004851b          	sext.w	a0,s1
    80004956:	b531                	j	80004762 <kexec+0x80>
    80004958:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000495c:	df843583          	ld	a1,-520(s0)
    80004960:	855a                	mv	a0,s6
    80004962:	82cfd0ef          	jal	ra,8000198e <proc_freepagetable>
  if(ip){
    80004966:	de0a98e3          	bnez	s5,80004756 <kexec+0x74>
  return -1;
    8000496a:	557d                	li	a0,-1
    8000496c:	bbdd                	j	80004762 <kexec+0x80>
    8000496e:	df243c23          	sd	s2,-520(s0)
    80004972:	b7ed                	j	8000495c <kexec+0x27a>
    80004974:	df243c23          	sd	s2,-520(s0)
    80004978:	b7d5                	j	8000495c <kexec+0x27a>
    8000497a:	df243c23          	sd	s2,-520(s0)
    8000497e:	bff9                	j	8000495c <kexec+0x27a>
    80004980:	df243c23          	sd	s2,-520(s0)
    80004984:	bfe1                	j	8000495c <kexec+0x27a>
  sz = sz1;
    80004986:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000498a:	4a81                	li	s5,0
    8000498c:	bfc1                	j	8000495c <kexec+0x27a>
  sz = sz1;
    8000498e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004992:	4a81                	li	s5,0
    80004994:	b7e1                	j	8000495c <kexec+0x27a>
  sz = sz1;
    80004996:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000499a:	4a81                	li	s5,0
    8000499c:	b7c1                	j	8000495c <kexec+0x27a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000499e:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049a2:	e0843783          	ld	a5,-504(s0)
    800049a6:	0017869b          	addiw	a3,a5,1
    800049aa:	e0d43423          	sd	a3,-504(s0)
    800049ae:	e0043783          	ld	a5,-512(s0)
    800049b2:	0387879b          	addiw	a5,a5,56
    800049b6:	e8845703          	lhu	a4,-376(s0)
    800049ba:	e4e6d6e3          	bge	a3,a4,80004806 <kexec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049be:	2781                	sext.w	a5,a5
    800049c0:	e0f43023          	sd	a5,-512(s0)
    800049c4:	03800713          	li	a4,56
    800049c8:	86be                	mv	a3,a5
    800049ca:	e1840613          	addi	a2,s0,-488
    800049ce:	4581                	li	a1,0
    800049d0:	8556                	mv	a0,s5
    800049d2:	d05fe0ef          	jal	ra,800036d6 <readi>
    800049d6:	03800793          	li	a5,56
    800049da:	f6f51fe3          	bne	a0,a5,80004958 <kexec+0x276>
    if(ph.type != ELF_PROG_LOAD)
    800049de:	e1842783          	lw	a5,-488(s0)
    800049e2:	4705                	li	a4,1
    800049e4:	fae79fe3          	bne	a5,a4,800049a2 <kexec+0x2c0>
    if(ph.memsz < ph.filesz)
    800049e8:	e4043483          	ld	s1,-448(s0)
    800049ec:	e3843783          	ld	a5,-456(s0)
    800049f0:	f6f4efe3          	bltu	s1,a5,8000496e <kexec+0x28c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800049f4:	e2843783          	ld	a5,-472(s0)
    800049f8:	94be                	add	s1,s1,a5
    800049fa:	f6f4ede3          	bltu	s1,a5,80004974 <kexec+0x292>
    if(ph.vaddr % PGSIZE != 0)
    800049fe:	de043703          	ld	a4,-544(s0)
    80004a02:	8ff9                	and	a5,a5,a4
    80004a04:	fbbd                	bnez	a5,8000497a <kexec+0x298>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a06:	e1c42503          	lw	a0,-484(s0)
    80004a0a:	cbdff0ef          	jal	ra,800046c6 <flags2perm>
    80004a0e:	86aa                	mv	a3,a0
    80004a10:	8626                	mv	a2,s1
    80004a12:	85ca                	mv	a1,s2
    80004a14:	855a                	mv	a0,s6
    80004a16:	80bfc0ef          	jal	ra,80001220 <uvmalloc>
    80004a1a:	dea43c23          	sd	a0,-520(s0)
    80004a1e:	d12d                	beqz	a0,80004980 <kexec+0x29e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a20:	e2843c03          	ld	s8,-472(s0)
    80004a24:	e2042c83          	lw	s9,-480(s0)
    80004a28:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a2c:	f60b89e3          	beqz	s7,8000499e <kexec+0x2bc>
    80004a30:	89de                	mv	s3,s7
    80004a32:	4481                	li	s1,0
    80004a34:	bb55                	j	800047e8 <kexec+0x106>

0000000080004a36 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a36:	7179                	addi	sp,sp,-48
    80004a38:	f406                	sd	ra,40(sp)
    80004a3a:	f022                	sd	s0,32(sp)
    80004a3c:	ec26                	sd	s1,24(sp)
    80004a3e:	e84a                	sd	s2,16(sp)
    80004a40:	1800                	addi	s0,sp,48
    80004a42:	892e                	mv	s2,a1
    80004a44:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a46:	fdc40593          	addi	a1,s0,-36
    80004a4a:	e0bfd0ef          	jal	ra,80002854 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a4e:	fdc42703          	lw	a4,-36(s0)
    80004a52:	47bd                	li	a5,15
    80004a54:	02e7e963          	bltu	a5,a4,80004a86 <argfd+0x50>
    80004a58:	dadfc0ef          	jal	ra,80001804 <myproc>
    80004a5c:	fdc42703          	lw	a4,-36(s0)
    80004a60:	01a70793          	addi	a5,a4,26
    80004a64:	078e                	slli	a5,a5,0x3
    80004a66:	953e                	add	a0,a0,a5
    80004a68:	611c                	ld	a5,0(a0)
    80004a6a:	c385                	beqz	a5,80004a8a <argfd+0x54>
    return -1;
  if(pfd)
    80004a6c:	00090463          	beqz	s2,80004a74 <argfd+0x3e>
    *pfd = fd;
    80004a70:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004a74:	4501                	li	a0,0
  if(pf)
    80004a76:	c091                	beqz	s1,80004a7a <argfd+0x44>
    *pf = f;
    80004a78:	e09c                	sd	a5,0(s1)
}
    80004a7a:	70a2                	ld	ra,40(sp)
    80004a7c:	7402                	ld	s0,32(sp)
    80004a7e:	64e2                	ld	s1,24(sp)
    80004a80:	6942                	ld	s2,16(sp)
    80004a82:	6145                	addi	sp,sp,48
    80004a84:	8082                	ret
    return -1;
    80004a86:	557d                	li	a0,-1
    80004a88:	bfcd                	j	80004a7a <argfd+0x44>
    80004a8a:	557d                	li	a0,-1
    80004a8c:	b7fd                	j	80004a7a <argfd+0x44>

0000000080004a8e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004a8e:	1101                	addi	sp,sp,-32
    80004a90:	ec06                	sd	ra,24(sp)
    80004a92:	e822                	sd	s0,16(sp)
    80004a94:	e426                	sd	s1,8(sp)
    80004a96:	1000                	addi	s0,sp,32
    80004a98:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004a9a:	d6bfc0ef          	jal	ra,80001804 <myproc>
    80004a9e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004aa0:	0d050793          	addi	a5,a0,208
    80004aa4:	4501                	li	a0,0
    80004aa6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004aa8:	6398                	ld	a4,0(a5)
    80004aaa:	cb19                	beqz	a4,80004ac0 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004aac:	2505                	addiw	a0,a0,1
    80004aae:	07a1                	addi	a5,a5,8
    80004ab0:	fed51ce3          	bne	a0,a3,80004aa8 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ab4:	557d                	li	a0,-1
}
    80004ab6:	60e2                	ld	ra,24(sp)
    80004ab8:	6442                	ld	s0,16(sp)
    80004aba:	64a2                	ld	s1,8(sp)
    80004abc:	6105                	addi	sp,sp,32
    80004abe:	8082                	ret
      p->ofile[fd] = f;
    80004ac0:	01a50793          	addi	a5,a0,26
    80004ac4:	078e                	slli	a5,a5,0x3
    80004ac6:	963e                	add	a2,a2,a5
    80004ac8:	e204                	sd	s1,0(a2)
      return fd;
    80004aca:	b7f5                	j	80004ab6 <fdalloc+0x28>

0000000080004acc <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004acc:	715d                	addi	sp,sp,-80
    80004ace:	e486                	sd	ra,72(sp)
    80004ad0:	e0a2                	sd	s0,64(sp)
    80004ad2:	fc26                	sd	s1,56(sp)
    80004ad4:	f84a                	sd	s2,48(sp)
    80004ad6:	f44e                	sd	s3,40(sp)
    80004ad8:	f052                	sd	s4,32(sp)
    80004ada:	ec56                	sd	s5,24(sp)
    80004adc:	e85a                	sd	s6,16(sp)
    80004ade:	0880                	addi	s0,sp,80
    80004ae0:	8b2e                	mv	s6,a1
    80004ae2:	89b2                	mv	s3,a2
    80004ae4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004ae6:	fb040593          	addi	a1,s0,-80
    80004aea:	868ff0ef          	jal	ra,80003b52 <nameiparent>
    80004aee:	84aa                	mv	s1,a0
    80004af0:	10050b63          	beqz	a0,80004c06 <create+0x13a>
    return 0;

  ilock(dp);
    80004af4:	857fe0ef          	jal	ra,8000334a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004af8:	4601                	li	a2,0
    80004afa:	fb040593          	addi	a1,s0,-80
    80004afe:	8526                	mv	a0,s1
    80004b00:	dd3fe0ef          	jal	ra,800038d2 <dirlookup>
    80004b04:	8aaa                	mv	s5,a0
    80004b06:	c521                	beqz	a0,80004b4e <create+0x82>
    iunlockput(dp);
    80004b08:	8526                	mv	a0,s1
    80004b0a:	a47fe0ef          	jal	ra,80003550 <iunlockput>
    ilock(ip);
    80004b0e:	8556                	mv	a0,s5
    80004b10:	83bfe0ef          	jal	ra,8000334a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b14:	000b059b          	sext.w	a1,s6
    80004b18:	4789                	li	a5,2
    80004b1a:	02f59563          	bne	a1,a5,80004b44 <create+0x78>
    80004b1e:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde28c>
    80004b22:	37f9                	addiw	a5,a5,-2
    80004b24:	17c2                	slli	a5,a5,0x30
    80004b26:	93c1                	srli	a5,a5,0x30
    80004b28:	4705                	li	a4,1
    80004b2a:	00f76d63          	bltu	a4,a5,80004b44 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b2e:	8556                	mv	a0,s5
    80004b30:	60a6                	ld	ra,72(sp)
    80004b32:	6406                	ld	s0,64(sp)
    80004b34:	74e2                	ld	s1,56(sp)
    80004b36:	7942                	ld	s2,48(sp)
    80004b38:	79a2                	ld	s3,40(sp)
    80004b3a:	7a02                	ld	s4,32(sp)
    80004b3c:	6ae2                	ld	s5,24(sp)
    80004b3e:	6b42                	ld	s6,16(sp)
    80004b40:	6161                	addi	sp,sp,80
    80004b42:	8082                	ret
    iunlockput(ip);
    80004b44:	8556                	mv	a0,s5
    80004b46:	a0bfe0ef          	jal	ra,80003550 <iunlockput>
    return 0;
    80004b4a:	4a81                	li	s5,0
    80004b4c:	b7cd                	j	80004b2e <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b4e:	85da                	mv	a1,s6
    80004b50:	4088                	lw	a0,0(s1)
    80004b52:	e90fe0ef          	jal	ra,800031e2 <ialloc>
    80004b56:	8a2a                	mv	s4,a0
    80004b58:	cd1d                	beqz	a0,80004b96 <create+0xca>
  ilock(ip);
    80004b5a:	ff0fe0ef          	jal	ra,8000334a <ilock>
  ip->major = major;
    80004b5e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004b62:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004b66:	4905                	li	s2,1
    80004b68:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004b6c:	8552                	mv	a0,s4
    80004b6e:	f2afe0ef          	jal	ra,80003298 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b72:	000b059b          	sext.w	a1,s6
    80004b76:	03258563          	beq	a1,s2,80004ba0 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b7a:	004a2603          	lw	a2,4(s4)
    80004b7e:	fb040593          	addi	a1,s0,-80
    80004b82:	8526                	mv	a0,s1
    80004b84:	f1bfe0ef          	jal	ra,80003a9e <dirlink>
    80004b88:	06054363          	bltz	a0,80004bee <create+0x122>
  iunlockput(dp);
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	9c3fe0ef          	jal	ra,80003550 <iunlockput>
  return ip;
    80004b92:	8ad2                	mv	s5,s4
    80004b94:	bf69                	j	80004b2e <create+0x62>
    iunlockput(dp);
    80004b96:	8526                	mv	a0,s1
    80004b98:	9b9fe0ef          	jal	ra,80003550 <iunlockput>
    return 0;
    80004b9c:	8ad2                	mv	s5,s4
    80004b9e:	bf41                	j	80004b2e <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ba0:	004a2603          	lw	a2,4(s4)
    80004ba4:	00003597          	auipc	a1,0x3
    80004ba8:	b6c58593          	addi	a1,a1,-1172 # 80007710 <syscalls+0x320>
    80004bac:	8552                	mv	a0,s4
    80004bae:	ef1fe0ef          	jal	ra,80003a9e <dirlink>
    80004bb2:	02054e63          	bltz	a0,80004bee <create+0x122>
    80004bb6:	40d0                	lw	a2,4(s1)
    80004bb8:	00003597          	auipc	a1,0x3
    80004bbc:	b6058593          	addi	a1,a1,-1184 # 80007718 <syscalls+0x328>
    80004bc0:	8552                	mv	a0,s4
    80004bc2:	eddfe0ef          	jal	ra,80003a9e <dirlink>
    80004bc6:	02054463          	bltz	a0,80004bee <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bca:	004a2603          	lw	a2,4(s4)
    80004bce:	fb040593          	addi	a1,s0,-80
    80004bd2:	8526                	mv	a0,s1
    80004bd4:	ecbfe0ef          	jal	ra,80003a9e <dirlink>
    80004bd8:	00054b63          	bltz	a0,80004bee <create+0x122>
    dp->nlink++;  // for ".."
    80004bdc:	04a4d783          	lhu	a5,74(s1)
    80004be0:	2785                	addiw	a5,a5,1
    80004be2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004be6:	8526                	mv	a0,s1
    80004be8:	eb0fe0ef          	jal	ra,80003298 <iupdate>
    80004bec:	b745                	j	80004b8c <create+0xc0>
  ip->nlink = 0;
    80004bee:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004bf2:	8552                	mv	a0,s4
    80004bf4:	ea4fe0ef          	jal	ra,80003298 <iupdate>
  iunlockput(ip);
    80004bf8:	8552                	mv	a0,s4
    80004bfa:	957fe0ef          	jal	ra,80003550 <iunlockput>
  iunlockput(dp);
    80004bfe:	8526                	mv	a0,s1
    80004c00:	951fe0ef          	jal	ra,80003550 <iunlockput>
  return 0;
    80004c04:	b72d                	j	80004b2e <create+0x62>
    return 0;
    80004c06:	8aaa                	mv	s5,a0
    80004c08:	b71d                	j	80004b2e <create+0x62>

0000000080004c0a <sys_dup>:
{
    80004c0a:	7179                	addi	sp,sp,-48
    80004c0c:	f406                	sd	ra,40(sp)
    80004c0e:	f022                	sd	s0,32(sp)
    80004c10:	ec26                	sd	s1,24(sp)
    80004c12:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c14:	fd840613          	addi	a2,s0,-40
    80004c18:	4581                	li	a1,0
    80004c1a:	4501                	li	a0,0
    80004c1c:	e1bff0ef          	jal	ra,80004a36 <argfd>
    return -1;
    80004c20:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c22:	00054f63          	bltz	a0,80004c40 <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004c26:	fd843503          	ld	a0,-40(s0)
    80004c2a:	e65ff0ef          	jal	ra,80004a8e <fdalloc>
    80004c2e:	84aa                	mv	s1,a0
    return -1;
    80004c30:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c32:	00054763          	bltz	a0,80004c40 <sys_dup+0x36>
  filedup(f);
    80004c36:	fd843503          	ld	a0,-40(s0)
    80004c3a:	cb6ff0ef          	jal	ra,800040f0 <filedup>
  return fd;
    80004c3e:	87a6                	mv	a5,s1
}
    80004c40:	853e                	mv	a0,a5
    80004c42:	70a2                	ld	ra,40(sp)
    80004c44:	7402                	ld	s0,32(sp)
    80004c46:	64e2                	ld	s1,24(sp)
    80004c48:	6145                	addi	sp,sp,48
    80004c4a:	8082                	ret

0000000080004c4c <sys_read>:
{
    80004c4c:	7179                	addi	sp,sp,-48
    80004c4e:	f406                	sd	ra,40(sp)
    80004c50:	f022                	sd	s0,32(sp)
    80004c52:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c54:	fd840593          	addi	a1,s0,-40
    80004c58:	4505                	li	a0,1
    80004c5a:	c17fd0ef          	jal	ra,80002870 <argaddr>
  argint(2, &n);
    80004c5e:	fe440593          	addi	a1,s0,-28
    80004c62:	4509                	li	a0,2
    80004c64:	bf1fd0ef          	jal	ra,80002854 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c68:	fe840613          	addi	a2,s0,-24
    80004c6c:	4581                	li	a1,0
    80004c6e:	4501                	li	a0,0
    80004c70:	dc7ff0ef          	jal	ra,80004a36 <argfd>
    80004c74:	87aa                	mv	a5,a0
    return -1;
    80004c76:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c78:	0007ca63          	bltz	a5,80004c8c <sys_read+0x40>
  return fileread(f, p, n);
    80004c7c:	fe442603          	lw	a2,-28(s0)
    80004c80:	fd843583          	ld	a1,-40(s0)
    80004c84:	fe843503          	ld	a0,-24(s0)
    80004c88:	db4ff0ef          	jal	ra,8000423c <fileread>
}
    80004c8c:	70a2                	ld	ra,40(sp)
    80004c8e:	7402                	ld	s0,32(sp)
    80004c90:	6145                	addi	sp,sp,48
    80004c92:	8082                	ret

0000000080004c94 <sys_write>:
{
    80004c94:	7179                	addi	sp,sp,-48
    80004c96:	f406                	sd	ra,40(sp)
    80004c98:	f022                	sd	s0,32(sp)
    80004c9a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c9c:	fd840593          	addi	a1,s0,-40
    80004ca0:	4505                	li	a0,1
    80004ca2:	bcffd0ef          	jal	ra,80002870 <argaddr>
  argint(2, &n);
    80004ca6:	fe440593          	addi	a1,s0,-28
    80004caa:	4509                	li	a0,2
    80004cac:	ba9fd0ef          	jal	ra,80002854 <argint>
  if(argfd(0, 0, &f) < 0)
    80004cb0:	fe840613          	addi	a2,s0,-24
    80004cb4:	4581                	li	a1,0
    80004cb6:	4501                	li	a0,0
    80004cb8:	d7fff0ef          	jal	ra,80004a36 <argfd>
    80004cbc:	87aa                	mv	a5,a0
    return -1;
    80004cbe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cc0:	0007ca63          	bltz	a5,80004cd4 <sys_write+0x40>
  return filewrite(f, p, n);
    80004cc4:	fe442603          	lw	a2,-28(s0)
    80004cc8:	fd843583          	ld	a1,-40(s0)
    80004ccc:	fe843503          	ld	a0,-24(s0)
    80004cd0:	e1aff0ef          	jal	ra,800042ea <filewrite>
}
    80004cd4:	70a2                	ld	ra,40(sp)
    80004cd6:	7402                	ld	s0,32(sp)
    80004cd8:	6145                	addi	sp,sp,48
    80004cda:	8082                	ret

0000000080004cdc <sys_close>:
{
    80004cdc:	1101                	addi	sp,sp,-32
    80004cde:	ec06                	sd	ra,24(sp)
    80004ce0:	e822                	sd	s0,16(sp)
    80004ce2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004ce4:	fe040613          	addi	a2,s0,-32
    80004ce8:	fec40593          	addi	a1,s0,-20
    80004cec:	4501                	li	a0,0
    80004cee:	d49ff0ef          	jal	ra,80004a36 <argfd>
    return -1;
    80004cf2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004cf4:	02054063          	bltz	a0,80004d14 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004cf8:	b0dfc0ef          	jal	ra,80001804 <myproc>
    80004cfc:	fec42783          	lw	a5,-20(s0)
    80004d00:	07e9                	addi	a5,a5,26
    80004d02:	078e                	slli	a5,a5,0x3
    80004d04:	97aa                	add	a5,a5,a0
    80004d06:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004d0a:	fe043503          	ld	a0,-32(s0)
    80004d0e:	c28ff0ef          	jal	ra,80004136 <fileclose>
  return 0;
    80004d12:	4781                	li	a5,0
}
    80004d14:	853e                	mv	a0,a5
    80004d16:	60e2                	ld	ra,24(sp)
    80004d18:	6442                	ld	s0,16(sp)
    80004d1a:	6105                	addi	sp,sp,32
    80004d1c:	8082                	ret

0000000080004d1e <sys_fstat>:
{
    80004d1e:	1101                	addi	sp,sp,-32
    80004d20:	ec06                	sd	ra,24(sp)
    80004d22:	e822                	sd	s0,16(sp)
    80004d24:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d26:	fe040593          	addi	a1,s0,-32
    80004d2a:	4505                	li	a0,1
    80004d2c:	b45fd0ef          	jal	ra,80002870 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d30:	fe840613          	addi	a2,s0,-24
    80004d34:	4581                	li	a1,0
    80004d36:	4501                	li	a0,0
    80004d38:	cffff0ef          	jal	ra,80004a36 <argfd>
    80004d3c:	87aa                	mv	a5,a0
    return -1;
    80004d3e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d40:	0007c863          	bltz	a5,80004d50 <sys_fstat+0x32>
  return filestat(f, st);
    80004d44:	fe043583          	ld	a1,-32(s0)
    80004d48:	fe843503          	ld	a0,-24(s0)
    80004d4c:	c92ff0ef          	jal	ra,800041de <filestat>
}
    80004d50:	60e2                	ld	ra,24(sp)
    80004d52:	6442                	ld	s0,16(sp)
    80004d54:	6105                	addi	sp,sp,32
    80004d56:	8082                	ret

0000000080004d58 <sys_link>:
{
    80004d58:	7169                	addi	sp,sp,-304
    80004d5a:	f606                	sd	ra,296(sp)
    80004d5c:	f222                	sd	s0,288(sp)
    80004d5e:	ee26                	sd	s1,280(sp)
    80004d60:	ea4a                	sd	s2,272(sp)
    80004d62:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d64:	08000613          	li	a2,128
    80004d68:	ed040593          	addi	a1,s0,-304
    80004d6c:	4501                	li	a0,0
    80004d6e:	b1ffd0ef          	jal	ra,8000288c <argstr>
    return -1;
    80004d72:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d74:	0c054663          	bltz	a0,80004e40 <sys_link+0xe8>
    80004d78:	08000613          	li	a2,128
    80004d7c:	f5040593          	addi	a1,s0,-176
    80004d80:	4505                	li	a0,1
    80004d82:	b0bfd0ef          	jal	ra,8000288c <argstr>
    return -1;
    80004d86:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d88:	0a054c63          	bltz	a0,80004e40 <sys_link+0xe8>
  begin_op();
    80004d8c:	f9dfe0ef          	jal	ra,80003d28 <begin_op>
  if((ip = namei(old)) == 0){
    80004d90:	ed040513          	addi	a0,s0,-304
    80004d94:	da5fe0ef          	jal	ra,80003b38 <namei>
    80004d98:	84aa                	mv	s1,a0
    80004d9a:	c525                	beqz	a0,80004e02 <sys_link+0xaa>
  ilock(ip);
    80004d9c:	daefe0ef          	jal	ra,8000334a <ilock>
  if(ip->type == T_DIR){
    80004da0:	04449703          	lh	a4,68(s1)
    80004da4:	4785                	li	a5,1
    80004da6:	06f70263          	beq	a4,a5,80004e0a <sys_link+0xb2>
  ip->nlink++;
    80004daa:	04a4d783          	lhu	a5,74(s1)
    80004dae:	2785                	addiw	a5,a5,1
    80004db0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004db4:	8526                	mv	a0,s1
    80004db6:	ce2fe0ef          	jal	ra,80003298 <iupdate>
  iunlock(ip);
    80004dba:	8526                	mv	a0,s1
    80004dbc:	e38fe0ef          	jal	ra,800033f4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004dc0:	fd040593          	addi	a1,s0,-48
    80004dc4:	f5040513          	addi	a0,s0,-176
    80004dc8:	d8bfe0ef          	jal	ra,80003b52 <nameiparent>
    80004dcc:	892a                	mv	s2,a0
    80004dce:	c921                	beqz	a0,80004e1e <sys_link+0xc6>
  ilock(dp);
    80004dd0:	d7afe0ef          	jal	ra,8000334a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004dd4:	00092703          	lw	a4,0(s2)
    80004dd8:	409c                	lw	a5,0(s1)
    80004dda:	02f71f63          	bne	a4,a5,80004e18 <sys_link+0xc0>
    80004dde:	40d0                	lw	a2,4(s1)
    80004de0:	fd040593          	addi	a1,s0,-48
    80004de4:	854a                	mv	a0,s2
    80004de6:	cb9fe0ef          	jal	ra,80003a9e <dirlink>
    80004dea:	02054763          	bltz	a0,80004e18 <sys_link+0xc0>
  iunlockput(dp);
    80004dee:	854a                	mv	a0,s2
    80004df0:	f60fe0ef          	jal	ra,80003550 <iunlockput>
  iput(ip);
    80004df4:	8526                	mv	a0,s1
    80004df6:	ed2fe0ef          	jal	ra,800034c8 <iput>
  end_op();
    80004dfa:	f9ffe0ef          	jal	ra,80003d98 <end_op>
  return 0;
    80004dfe:	4781                	li	a5,0
    80004e00:	a081                	j	80004e40 <sys_link+0xe8>
    end_op();
    80004e02:	f97fe0ef          	jal	ra,80003d98 <end_op>
    return -1;
    80004e06:	57fd                	li	a5,-1
    80004e08:	a825                	j	80004e40 <sys_link+0xe8>
    iunlockput(ip);
    80004e0a:	8526                	mv	a0,s1
    80004e0c:	f44fe0ef          	jal	ra,80003550 <iunlockput>
    end_op();
    80004e10:	f89fe0ef          	jal	ra,80003d98 <end_op>
    return -1;
    80004e14:	57fd                	li	a5,-1
    80004e16:	a02d                	j	80004e40 <sys_link+0xe8>
    iunlockput(dp);
    80004e18:	854a                	mv	a0,s2
    80004e1a:	f36fe0ef          	jal	ra,80003550 <iunlockput>
  ilock(ip);
    80004e1e:	8526                	mv	a0,s1
    80004e20:	d2afe0ef          	jal	ra,8000334a <ilock>
  ip->nlink--;
    80004e24:	04a4d783          	lhu	a5,74(s1)
    80004e28:	37fd                	addiw	a5,a5,-1
    80004e2a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e2e:	8526                	mv	a0,s1
    80004e30:	c68fe0ef          	jal	ra,80003298 <iupdate>
  iunlockput(ip);
    80004e34:	8526                	mv	a0,s1
    80004e36:	f1afe0ef          	jal	ra,80003550 <iunlockput>
  end_op();
    80004e3a:	f5ffe0ef          	jal	ra,80003d98 <end_op>
  return -1;
    80004e3e:	57fd                	li	a5,-1
}
    80004e40:	853e                	mv	a0,a5
    80004e42:	70b2                	ld	ra,296(sp)
    80004e44:	7412                	ld	s0,288(sp)
    80004e46:	64f2                	ld	s1,280(sp)
    80004e48:	6952                	ld	s2,272(sp)
    80004e4a:	6155                	addi	sp,sp,304
    80004e4c:	8082                	ret

0000000080004e4e <sys_unlink>:
{
    80004e4e:	7151                	addi	sp,sp,-240
    80004e50:	f586                	sd	ra,232(sp)
    80004e52:	f1a2                	sd	s0,224(sp)
    80004e54:	eda6                	sd	s1,216(sp)
    80004e56:	e9ca                	sd	s2,208(sp)
    80004e58:	e5ce                	sd	s3,200(sp)
    80004e5a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e5c:	08000613          	li	a2,128
    80004e60:	f3040593          	addi	a1,s0,-208
    80004e64:	4501                	li	a0,0
    80004e66:	a27fd0ef          	jal	ra,8000288c <argstr>
    80004e6a:	12054b63          	bltz	a0,80004fa0 <sys_unlink+0x152>
  begin_op();
    80004e6e:	ebbfe0ef          	jal	ra,80003d28 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004e72:	fb040593          	addi	a1,s0,-80
    80004e76:	f3040513          	addi	a0,s0,-208
    80004e7a:	cd9fe0ef          	jal	ra,80003b52 <nameiparent>
    80004e7e:	84aa                	mv	s1,a0
    80004e80:	c54d                	beqz	a0,80004f2a <sys_unlink+0xdc>
  ilock(dp);
    80004e82:	cc8fe0ef          	jal	ra,8000334a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004e86:	00003597          	auipc	a1,0x3
    80004e8a:	88a58593          	addi	a1,a1,-1910 # 80007710 <syscalls+0x320>
    80004e8e:	fb040513          	addi	a0,s0,-80
    80004e92:	a2bfe0ef          	jal	ra,800038bc <namecmp>
    80004e96:	10050a63          	beqz	a0,80004faa <sys_unlink+0x15c>
    80004e9a:	00003597          	auipc	a1,0x3
    80004e9e:	87e58593          	addi	a1,a1,-1922 # 80007718 <syscalls+0x328>
    80004ea2:	fb040513          	addi	a0,s0,-80
    80004ea6:	a17fe0ef          	jal	ra,800038bc <namecmp>
    80004eaa:	10050063          	beqz	a0,80004faa <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004eae:	f2c40613          	addi	a2,s0,-212
    80004eb2:	fb040593          	addi	a1,s0,-80
    80004eb6:	8526                	mv	a0,s1
    80004eb8:	a1bfe0ef          	jal	ra,800038d2 <dirlookup>
    80004ebc:	892a                	mv	s2,a0
    80004ebe:	0e050663          	beqz	a0,80004faa <sys_unlink+0x15c>
  ilock(ip);
    80004ec2:	c88fe0ef          	jal	ra,8000334a <ilock>
  if(ip->nlink < 1)
    80004ec6:	04a91783          	lh	a5,74(s2)
    80004eca:	06f05463          	blez	a5,80004f32 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004ece:	04491703          	lh	a4,68(s2)
    80004ed2:	4785                	li	a5,1
    80004ed4:	06f70563          	beq	a4,a5,80004f3e <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004ed8:	4641                	li	a2,16
    80004eda:	4581                	li	a1,0
    80004edc:	fc040513          	addi	a0,s0,-64
    80004ee0:	d61fb0ef          	jal	ra,80000c40 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ee4:	4741                	li	a4,16
    80004ee6:	f2c42683          	lw	a3,-212(s0)
    80004eea:	fc040613          	addi	a2,s0,-64
    80004eee:	4581                	li	a1,0
    80004ef0:	8526                	mv	a0,s1
    80004ef2:	8c9fe0ef          	jal	ra,800037ba <writei>
    80004ef6:	47c1                	li	a5,16
    80004ef8:	08f51563          	bne	a0,a5,80004f82 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004efc:	04491703          	lh	a4,68(s2)
    80004f00:	4785                	li	a5,1
    80004f02:	08f70663          	beq	a4,a5,80004f8e <sys_unlink+0x140>
  iunlockput(dp);
    80004f06:	8526                	mv	a0,s1
    80004f08:	e48fe0ef          	jal	ra,80003550 <iunlockput>
  ip->nlink--;
    80004f0c:	04a95783          	lhu	a5,74(s2)
    80004f10:	37fd                	addiw	a5,a5,-1
    80004f12:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f16:	854a                	mv	a0,s2
    80004f18:	b80fe0ef          	jal	ra,80003298 <iupdate>
  iunlockput(ip);
    80004f1c:	854a                	mv	a0,s2
    80004f1e:	e32fe0ef          	jal	ra,80003550 <iunlockput>
  end_op();
    80004f22:	e77fe0ef          	jal	ra,80003d98 <end_op>
  return 0;
    80004f26:	4501                	li	a0,0
    80004f28:	a079                	j	80004fb6 <sys_unlink+0x168>
    end_op();
    80004f2a:	e6ffe0ef          	jal	ra,80003d98 <end_op>
    return -1;
    80004f2e:	557d                	li	a0,-1
    80004f30:	a059                	j	80004fb6 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004f32:	00002517          	auipc	a0,0x2
    80004f36:	7ee50513          	addi	a0,a0,2030 # 80007720 <syscalls+0x330>
    80004f3a:	851fb0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f3e:	04c92703          	lw	a4,76(s2)
    80004f42:	02000793          	li	a5,32
    80004f46:	f8e7f9e3          	bgeu	a5,a4,80004ed8 <sys_unlink+0x8a>
    80004f4a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f4e:	4741                	li	a4,16
    80004f50:	86ce                	mv	a3,s3
    80004f52:	f1840613          	addi	a2,s0,-232
    80004f56:	4581                	li	a1,0
    80004f58:	854a                	mv	a0,s2
    80004f5a:	f7cfe0ef          	jal	ra,800036d6 <readi>
    80004f5e:	47c1                	li	a5,16
    80004f60:	00f51b63          	bne	a0,a5,80004f76 <sys_unlink+0x128>
    if(de.inum != 0)
    80004f64:	f1845783          	lhu	a5,-232(s0)
    80004f68:	ef95                	bnez	a5,80004fa4 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f6a:	29c1                	addiw	s3,s3,16
    80004f6c:	04c92783          	lw	a5,76(s2)
    80004f70:	fcf9efe3          	bltu	s3,a5,80004f4e <sys_unlink+0x100>
    80004f74:	b795                	j	80004ed8 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004f76:	00002517          	auipc	a0,0x2
    80004f7a:	7c250513          	addi	a0,a0,1986 # 80007738 <syscalls+0x348>
    80004f7e:	80dfb0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    80004f82:	00002517          	auipc	a0,0x2
    80004f86:	7ce50513          	addi	a0,a0,1998 # 80007750 <syscalls+0x360>
    80004f8a:	801fb0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    80004f8e:	04a4d783          	lhu	a5,74(s1)
    80004f92:	37fd                	addiw	a5,a5,-1
    80004f94:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f98:	8526                	mv	a0,s1
    80004f9a:	afefe0ef          	jal	ra,80003298 <iupdate>
    80004f9e:	b7a5                	j	80004f06 <sys_unlink+0xb8>
    return -1;
    80004fa0:	557d                	li	a0,-1
    80004fa2:	a811                	j	80004fb6 <sys_unlink+0x168>
    iunlockput(ip);
    80004fa4:	854a                	mv	a0,s2
    80004fa6:	daafe0ef          	jal	ra,80003550 <iunlockput>
  iunlockput(dp);
    80004faa:	8526                	mv	a0,s1
    80004fac:	da4fe0ef          	jal	ra,80003550 <iunlockput>
  end_op();
    80004fb0:	de9fe0ef          	jal	ra,80003d98 <end_op>
  return -1;
    80004fb4:	557d                	li	a0,-1
}
    80004fb6:	70ae                	ld	ra,232(sp)
    80004fb8:	740e                	ld	s0,224(sp)
    80004fba:	64ee                	ld	s1,216(sp)
    80004fbc:	694e                	ld	s2,208(sp)
    80004fbe:	69ae                	ld	s3,200(sp)
    80004fc0:	616d                	addi	sp,sp,240
    80004fc2:	8082                	ret

0000000080004fc4 <sys_open>:

uint64
sys_open(void)
{
    80004fc4:	7131                	addi	sp,sp,-192
    80004fc6:	fd06                	sd	ra,184(sp)
    80004fc8:	f922                	sd	s0,176(sp)
    80004fca:	f526                	sd	s1,168(sp)
    80004fcc:	f14a                	sd	s2,160(sp)
    80004fce:	ed4e                	sd	s3,152(sp)
    80004fd0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004fd2:	f4c40593          	addi	a1,s0,-180
    80004fd6:	4505                	li	a0,1
    80004fd8:	87dfd0ef          	jal	ra,80002854 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004fdc:	08000613          	li	a2,128
    80004fe0:	f5040593          	addi	a1,s0,-176
    80004fe4:	4501                	li	a0,0
    80004fe6:	8a7fd0ef          	jal	ra,8000288c <argstr>
    80004fea:	87aa                	mv	a5,a0
    return -1;
    80004fec:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004fee:	0807cd63          	bltz	a5,80005088 <sys_open+0xc4>

  begin_op();
    80004ff2:	d37fe0ef          	jal	ra,80003d28 <begin_op>

  if(omode & O_CREATE){
    80004ff6:	f4c42783          	lw	a5,-180(s0)
    80004ffa:	2007f793          	andi	a5,a5,512
    80004ffe:	c3c5                	beqz	a5,8000509e <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005000:	4681                	li	a3,0
    80005002:	4601                	li	a2,0
    80005004:	4589                	li	a1,2
    80005006:	f5040513          	addi	a0,s0,-176
    8000500a:	ac3ff0ef          	jal	ra,80004acc <create>
    8000500e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005010:	c159                	beqz	a0,80005096 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005012:	04449703          	lh	a4,68(s1)
    80005016:	478d                	li	a5,3
    80005018:	00f71763          	bne	a4,a5,80005026 <sys_open+0x62>
    8000501c:	0464d703          	lhu	a4,70(s1)
    80005020:	47a5                	li	a5,9
    80005022:	0ae7e963          	bltu	a5,a4,800050d4 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005026:	86cff0ef          	jal	ra,80004092 <filealloc>
    8000502a:	89aa                	mv	s3,a0
    8000502c:	0c050963          	beqz	a0,800050fe <sys_open+0x13a>
    80005030:	a5fff0ef          	jal	ra,80004a8e <fdalloc>
    80005034:	892a                	mv	s2,a0
    80005036:	0c054163          	bltz	a0,800050f8 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000503a:	04449703          	lh	a4,68(s1)
    8000503e:	478d                	li	a5,3
    80005040:	0af70163          	beq	a4,a5,800050e2 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005044:	4789                	li	a5,2
    80005046:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000504a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000504e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005052:	f4c42783          	lw	a5,-180(s0)
    80005056:	0017c713          	xori	a4,a5,1
    8000505a:	8b05                	andi	a4,a4,1
    8000505c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005060:	0037f713          	andi	a4,a5,3
    80005064:	00e03733          	snez	a4,a4
    80005068:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000506c:	4007f793          	andi	a5,a5,1024
    80005070:	c791                	beqz	a5,8000507c <sys_open+0xb8>
    80005072:	04449703          	lh	a4,68(s1)
    80005076:	4789                	li	a5,2
    80005078:	06f70c63          	beq	a4,a5,800050f0 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    8000507c:	8526                	mv	a0,s1
    8000507e:	b76fe0ef          	jal	ra,800033f4 <iunlock>
  end_op();
    80005082:	d17fe0ef          	jal	ra,80003d98 <end_op>

  return fd;
    80005086:	854a                	mv	a0,s2
}
    80005088:	70ea                	ld	ra,184(sp)
    8000508a:	744a                	ld	s0,176(sp)
    8000508c:	74aa                	ld	s1,168(sp)
    8000508e:	790a                	ld	s2,160(sp)
    80005090:	69ea                	ld	s3,152(sp)
    80005092:	6129                	addi	sp,sp,192
    80005094:	8082                	ret
      end_op();
    80005096:	d03fe0ef          	jal	ra,80003d98 <end_op>
      return -1;
    8000509a:	557d                	li	a0,-1
    8000509c:	b7f5                	j	80005088 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    8000509e:	f5040513          	addi	a0,s0,-176
    800050a2:	a97fe0ef          	jal	ra,80003b38 <namei>
    800050a6:	84aa                	mv	s1,a0
    800050a8:	c115                	beqz	a0,800050cc <sys_open+0x108>
    ilock(ip);
    800050aa:	aa0fe0ef          	jal	ra,8000334a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050ae:	04449703          	lh	a4,68(s1)
    800050b2:	4785                	li	a5,1
    800050b4:	f4f71fe3          	bne	a4,a5,80005012 <sys_open+0x4e>
    800050b8:	f4c42783          	lw	a5,-180(s0)
    800050bc:	d7ad                	beqz	a5,80005026 <sys_open+0x62>
      iunlockput(ip);
    800050be:	8526                	mv	a0,s1
    800050c0:	c90fe0ef          	jal	ra,80003550 <iunlockput>
      end_op();
    800050c4:	cd5fe0ef          	jal	ra,80003d98 <end_op>
      return -1;
    800050c8:	557d                	li	a0,-1
    800050ca:	bf7d                	j	80005088 <sys_open+0xc4>
      end_op();
    800050cc:	ccdfe0ef          	jal	ra,80003d98 <end_op>
      return -1;
    800050d0:	557d                	li	a0,-1
    800050d2:	bf5d                	j	80005088 <sys_open+0xc4>
    iunlockput(ip);
    800050d4:	8526                	mv	a0,s1
    800050d6:	c7afe0ef          	jal	ra,80003550 <iunlockput>
    end_op();
    800050da:	cbffe0ef          	jal	ra,80003d98 <end_op>
    return -1;
    800050de:	557d                	li	a0,-1
    800050e0:	b765                	j	80005088 <sys_open+0xc4>
    f->type = FD_DEVICE;
    800050e2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800050e6:	04649783          	lh	a5,70(s1)
    800050ea:	02f99223          	sh	a5,36(s3)
    800050ee:	b785                	j	8000504e <sys_open+0x8a>
    itrunc(ip);
    800050f0:	8526                	mv	a0,s1
    800050f2:	b42fe0ef          	jal	ra,80003434 <itrunc>
    800050f6:	b759                	j	8000507c <sys_open+0xb8>
      fileclose(f);
    800050f8:	854e                	mv	a0,s3
    800050fa:	83cff0ef          	jal	ra,80004136 <fileclose>
    iunlockput(ip);
    800050fe:	8526                	mv	a0,s1
    80005100:	c50fe0ef          	jal	ra,80003550 <iunlockput>
    end_op();
    80005104:	c95fe0ef          	jal	ra,80003d98 <end_op>
    return -1;
    80005108:	557d                	li	a0,-1
    8000510a:	bfbd                	j	80005088 <sys_open+0xc4>

000000008000510c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000510c:	7175                	addi	sp,sp,-144
    8000510e:	e506                	sd	ra,136(sp)
    80005110:	e122                	sd	s0,128(sp)
    80005112:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005114:	c15fe0ef          	jal	ra,80003d28 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005118:	08000613          	li	a2,128
    8000511c:	f7040593          	addi	a1,s0,-144
    80005120:	4501                	li	a0,0
    80005122:	f6afd0ef          	jal	ra,8000288c <argstr>
    80005126:	02054363          	bltz	a0,8000514c <sys_mkdir+0x40>
    8000512a:	4681                	li	a3,0
    8000512c:	4601                	li	a2,0
    8000512e:	4585                	li	a1,1
    80005130:	f7040513          	addi	a0,s0,-144
    80005134:	999ff0ef          	jal	ra,80004acc <create>
    80005138:	c911                	beqz	a0,8000514c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000513a:	c16fe0ef          	jal	ra,80003550 <iunlockput>
  end_op();
    8000513e:	c5bfe0ef          	jal	ra,80003d98 <end_op>
  return 0;
    80005142:	4501                	li	a0,0
}
    80005144:	60aa                	ld	ra,136(sp)
    80005146:	640a                	ld	s0,128(sp)
    80005148:	6149                	addi	sp,sp,144
    8000514a:	8082                	ret
    end_op();
    8000514c:	c4dfe0ef          	jal	ra,80003d98 <end_op>
    return -1;
    80005150:	557d                	li	a0,-1
    80005152:	bfcd                	j	80005144 <sys_mkdir+0x38>

0000000080005154 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005154:	7135                	addi	sp,sp,-160
    80005156:	ed06                	sd	ra,152(sp)
    80005158:	e922                	sd	s0,144(sp)
    8000515a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000515c:	bcdfe0ef          	jal	ra,80003d28 <begin_op>
  argint(1, &major);
    80005160:	f6c40593          	addi	a1,s0,-148
    80005164:	4505                	li	a0,1
    80005166:	eeefd0ef          	jal	ra,80002854 <argint>
  argint(2, &minor);
    8000516a:	f6840593          	addi	a1,s0,-152
    8000516e:	4509                	li	a0,2
    80005170:	ee4fd0ef          	jal	ra,80002854 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005174:	08000613          	li	a2,128
    80005178:	f7040593          	addi	a1,s0,-144
    8000517c:	4501                	li	a0,0
    8000517e:	f0efd0ef          	jal	ra,8000288c <argstr>
    80005182:	02054563          	bltz	a0,800051ac <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005186:	f6841683          	lh	a3,-152(s0)
    8000518a:	f6c41603          	lh	a2,-148(s0)
    8000518e:	458d                	li	a1,3
    80005190:	f7040513          	addi	a0,s0,-144
    80005194:	939ff0ef          	jal	ra,80004acc <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005198:	c911                	beqz	a0,800051ac <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000519a:	bb6fe0ef          	jal	ra,80003550 <iunlockput>
  end_op();
    8000519e:	bfbfe0ef          	jal	ra,80003d98 <end_op>
  return 0;
    800051a2:	4501                	li	a0,0
}
    800051a4:	60ea                	ld	ra,152(sp)
    800051a6:	644a                	ld	s0,144(sp)
    800051a8:	610d                	addi	sp,sp,160
    800051aa:	8082                	ret
    end_op();
    800051ac:	bedfe0ef          	jal	ra,80003d98 <end_op>
    return -1;
    800051b0:	557d                	li	a0,-1
    800051b2:	bfcd                	j	800051a4 <sys_mknod+0x50>

00000000800051b4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800051b4:	7135                	addi	sp,sp,-160
    800051b6:	ed06                	sd	ra,152(sp)
    800051b8:	e922                	sd	s0,144(sp)
    800051ba:	e526                	sd	s1,136(sp)
    800051bc:	e14a                	sd	s2,128(sp)
    800051be:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800051c0:	e44fc0ef          	jal	ra,80001804 <myproc>
    800051c4:	892a                	mv	s2,a0
  
  begin_op();
    800051c6:	b63fe0ef          	jal	ra,80003d28 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800051ca:	08000613          	li	a2,128
    800051ce:	f6040593          	addi	a1,s0,-160
    800051d2:	4501                	li	a0,0
    800051d4:	eb8fd0ef          	jal	ra,8000288c <argstr>
    800051d8:	04054163          	bltz	a0,8000521a <sys_chdir+0x66>
    800051dc:	f6040513          	addi	a0,s0,-160
    800051e0:	959fe0ef          	jal	ra,80003b38 <namei>
    800051e4:	84aa                	mv	s1,a0
    800051e6:	c915                	beqz	a0,8000521a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800051e8:	962fe0ef          	jal	ra,8000334a <ilock>
  if(ip->type != T_DIR){
    800051ec:	04449703          	lh	a4,68(s1)
    800051f0:	4785                	li	a5,1
    800051f2:	02f71863          	bne	a4,a5,80005222 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800051f6:	8526                	mv	a0,s1
    800051f8:	9fcfe0ef          	jal	ra,800033f4 <iunlock>
  iput(p->cwd);
    800051fc:	15093503          	ld	a0,336(s2)
    80005200:	ac8fe0ef          	jal	ra,800034c8 <iput>
  end_op();
    80005204:	b95fe0ef          	jal	ra,80003d98 <end_op>
  p->cwd = ip;
    80005208:	14993823          	sd	s1,336(s2)
  return 0;
    8000520c:	4501                	li	a0,0
}
    8000520e:	60ea                	ld	ra,152(sp)
    80005210:	644a                	ld	s0,144(sp)
    80005212:	64aa                	ld	s1,136(sp)
    80005214:	690a                	ld	s2,128(sp)
    80005216:	610d                	addi	sp,sp,160
    80005218:	8082                	ret
    end_op();
    8000521a:	b7ffe0ef          	jal	ra,80003d98 <end_op>
    return -1;
    8000521e:	557d                	li	a0,-1
    80005220:	b7fd                	j	8000520e <sys_chdir+0x5a>
    iunlockput(ip);
    80005222:	8526                	mv	a0,s1
    80005224:	b2cfe0ef          	jal	ra,80003550 <iunlockput>
    end_op();
    80005228:	b71fe0ef          	jal	ra,80003d98 <end_op>
    return -1;
    8000522c:	557d                	li	a0,-1
    8000522e:	b7c5                	j	8000520e <sys_chdir+0x5a>

0000000080005230 <sys_exec>:

uint64
sys_exec(void)
{
    80005230:	7145                	addi	sp,sp,-464
    80005232:	e786                	sd	ra,456(sp)
    80005234:	e3a2                	sd	s0,448(sp)
    80005236:	ff26                	sd	s1,440(sp)
    80005238:	fb4a                	sd	s2,432(sp)
    8000523a:	f74e                	sd	s3,424(sp)
    8000523c:	f352                	sd	s4,416(sp)
    8000523e:	ef56                	sd	s5,408(sp)
    80005240:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005242:	e3840593          	addi	a1,s0,-456
    80005246:	4505                	li	a0,1
    80005248:	e28fd0ef          	jal	ra,80002870 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000524c:	08000613          	li	a2,128
    80005250:	f4040593          	addi	a1,s0,-192
    80005254:	4501                	li	a0,0
    80005256:	e36fd0ef          	jal	ra,8000288c <argstr>
    8000525a:	87aa                	mv	a5,a0
    return -1;
    8000525c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000525e:	0a07c463          	bltz	a5,80005306 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80005262:	10000613          	li	a2,256
    80005266:	4581                	li	a1,0
    80005268:	e4040513          	addi	a0,s0,-448
    8000526c:	9d5fb0ef          	jal	ra,80000c40 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005270:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005274:	89a6                	mv	s3,s1
    80005276:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005278:	02000a13          	li	s4,32
    8000527c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005280:	00391793          	slli	a5,s2,0x3
    80005284:	e3040593          	addi	a1,s0,-464
    80005288:	e3843503          	ld	a0,-456(s0)
    8000528c:	953e                	add	a0,a0,a5
    8000528e:	d3cfd0ef          	jal	ra,800027ca <fetchaddr>
    80005292:	02054663          	bltz	a0,800052be <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005296:	e3043783          	ld	a5,-464(s0)
    8000529a:	cf8d                	beqz	a5,800052d4 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000529c:	801fb0ef          	jal	ra,80000a9c <kalloc>
    800052a0:	85aa                	mv	a1,a0
    800052a2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800052a6:	cd01                	beqz	a0,800052be <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052a8:	6605                	lui	a2,0x1
    800052aa:	e3043503          	ld	a0,-464(s0)
    800052ae:	d66fd0ef          	jal	ra,80002814 <fetchstr>
    800052b2:	00054663          	bltz	a0,800052be <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800052b6:	0905                	addi	s2,s2,1
    800052b8:	09a1                	addi	s3,s3,8
    800052ba:	fd4911e3          	bne	s2,s4,8000527c <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052be:	10048913          	addi	s2,s1,256
    800052c2:	6088                	ld	a0,0(s1)
    800052c4:	c121                	beqz	a0,80005304 <sys_exec+0xd4>
    kfree(argv[i]);
    800052c6:	ef6fb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052ca:	04a1                	addi	s1,s1,8
    800052cc:	ff249be3          	bne	s1,s2,800052c2 <sys_exec+0x92>
  return -1;
    800052d0:	557d                	li	a0,-1
    800052d2:	a815                	j	80005306 <sys_exec+0xd6>
      argv[i] = 0;
    800052d4:	0a8e                	slli	s5,s5,0x3
    800052d6:	fc040793          	addi	a5,s0,-64
    800052da:	9abe                	add	s5,s5,a5
    800052dc:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    800052e0:	e4040593          	addi	a1,s0,-448
    800052e4:	f4040513          	addi	a0,s0,-192
    800052e8:	bfaff0ef          	jal	ra,800046e2 <kexec>
    800052ec:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052ee:	10048993          	addi	s3,s1,256
    800052f2:	6088                	ld	a0,0(s1)
    800052f4:	c511                	beqz	a0,80005300 <sys_exec+0xd0>
    kfree(argv[i]);
    800052f6:	ec6fb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052fa:	04a1                	addi	s1,s1,8
    800052fc:	ff349be3          	bne	s1,s3,800052f2 <sys_exec+0xc2>
  return ret;
    80005300:	854a                	mv	a0,s2
    80005302:	a011                	j	80005306 <sys_exec+0xd6>
  return -1;
    80005304:	557d                	li	a0,-1
}
    80005306:	60be                	ld	ra,456(sp)
    80005308:	641e                	ld	s0,448(sp)
    8000530a:	74fa                	ld	s1,440(sp)
    8000530c:	795a                	ld	s2,432(sp)
    8000530e:	79ba                	ld	s3,424(sp)
    80005310:	7a1a                	ld	s4,416(sp)
    80005312:	6afa                	ld	s5,408(sp)
    80005314:	6179                	addi	sp,sp,464
    80005316:	8082                	ret

0000000080005318 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005318:	7139                	addi	sp,sp,-64
    8000531a:	fc06                	sd	ra,56(sp)
    8000531c:	f822                	sd	s0,48(sp)
    8000531e:	f426                	sd	s1,40(sp)
    80005320:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005322:	ce2fc0ef          	jal	ra,80001804 <myproc>
    80005326:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005328:	fd840593          	addi	a1,s0,-40
    8000532c:	4501                	li	a0,0
    8000532e:	d42fd0ef          	jal	ra,80002870 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005332:	fc840593          	addi	a1,s0,-56
    80005336:	fd040513          	addi	a0,s0,-48
    8000533a:	8c8ff0ef          	jal	ra,80004402 <pipealloc>
    return -1;
    8000533e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005340:	0a054463          	bltz	a0,800053e8 <sys_pipe+0xd0>
  fd0 = -1;
    80005344:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005348:	fd043503          	ld	a0,-48(s0)
    8000534c:	f42ff0ef          	jal	ra,80004a8e <fdalloc>
    80005350:	fca42223          	sw	a0,-60(s0)
    80005354:	08054163          	bltz	a0,800053d6 <sys_pipe+0xbe>
    80005358:	fc843503          	ld	a0,-56(s0)
    8000535c:	f32ff0ef          	jal	ra,80004a8e <fdalloc>
    80005360:	fca42023          	sw	a0,-64(s0)
    80005364:	06054063          	bltz	a0,800053c4 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005368:	4691                	li	a3,4
    8000536a:	fc440613          	addi	a2,s0,-60
    8000536e:	fd843583          	ld	a1,-40(s0)
    80005372:	68a8                	ld	a0,80(s1)
    80005374:	9defc0ef          	jal	ra,80001552 <copyout>
    80005378:	00054e63          	bltz	a0,80005394 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000537c:	4691                	li	a3,4
    8000537e:	fc040613          	addi	a2,s0,-64
    80005382:	fd843583          	ld	a1,-40(s0)
    80005386:	0591                	addi	a1,a1,4
    80005388:	68a8                	ld	a0,80(s1)
    8000538a:	9c8fc0ef          	jal	ra,80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000538e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005390:	04055c63          	bgez	a0,800053e8 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005394:	fc442783          	lw	a5,-60(s0)
    80005398:	07e9                	addi	a5,a5,26
    8000539a:	078e                	slli	a5,a5,0x3
    8000539c:	97a6                	add	a5,a5,s1
    8000539e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800053a2:	fc042503          	lw	a0,-64(s0)
    800053a6:	0569                	addi	a0,a0,26
    800053a8:	050e                	slli	a0,a0,0x3
    800053aa:	94aa                	add	s1,s1,a0
    800053ac:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800053b0:	fd043503          	ld	a0,-48(s0)
    800053b4:	d83fe0ef          	jal	ra,80004136 <fileclose>
    fileclose(wf);
    800053b8:	fc843503          	ld	a0,-56(s0)
    800053bc:	d7bfe0ef          	jal	ra,80004136 <fileclose>
    return -1;
    800053c0:	57fd                	li	a5,-1
    800053c2:	a01d                	j	800053e8 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800053c4:	fc442783          	lw	a5,-60(s0)
    800053c8:	0007c763          	bltz	a5,800053d6 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800053cc:	07e9                	addi	a5,a5,26
    800053ce:	078e                	slli	a5,a5,0x3
    800053d0:	94be                	add	s1,s1,a5
    800053d2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800053d6:	fd043503          	ld	a0,-48(s0)
    800053da:	d5dfe0ef          	jal	ra,80004136 <fileclose>
    fileclose(wf);
    800053de:	fc843503          	ld	a0,-56(s0)
    800053e2:	d55fe0ef          	jal	ra,80004136 <fileclose>
    return -1;
    800053e6:	57fd                	li	a5,-1
}
    800053e8:	853e                	mv	a0,a5
    800053ea:	70e2                	ld	ra,56(sp)
    800053ec:	7442                	ld	s0,48(sp)
    800053ee:	74a2                	ld	s1,40(sp)
    800053f0:	6121                	addi	sp,sp,64
    800053f2:	8082                	ret
	...

0000000080005400 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005400:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005402:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005404:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005406:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005408:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000540a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000540c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000540e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005410:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005412:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005414:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005416:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005418:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000541a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000541c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000541e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005420:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005422:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005424:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005426:	ab4fd0ef          	jal	ra,800026da <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000542a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000542c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000542e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005430:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005432:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005434:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005436:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005438:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000543a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000543c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000543e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005440:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005442:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005444:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005446:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005448:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000544a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000544c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000544e:	10200073          	sret
	...

000000008000545e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000545e:	1141                	addi	sp,sp,-16
    80005460:	e422                	sd	s0,8(sp)
    80005462:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005464:	0c0007b7          	lui	a5,0xc000
    80005468:	4705                	li	a4,1
    8000546a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000546c:	c3d8                	sw	a4,4(a5)
}
    8000546e:	6422                	ld	s0,8(sp)
    80005470:	0141                	addi	sp,sp,16
    80005472:	8082                	ret

0000000080005474 <plicinithart>:

void
plicinithart(void)
{
    80005474:	1141                	addi	sp,sp,-16
    80005476:	e406                	sd	ra,8(sp)
    80005478:	e022                	sd	s0,0(sp)
    8000547a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000547c:	b5cfc0ef          	jal	ra,800017d8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005480:	0085171b          	slliw	a4,a0,0x8
    80005484:	0c0027b7          	lui	a5,0xc002
    80005488:	97ba                	add	a5,a5,a4
    8000548a:	40200713          	li	a4,1026
    8000548e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005492:	00d5151b          	slliw	a0,a0,0xd
    80005496:	0c2017b7          	lui	a5,0xc201
    8000549a:	953e                	add	a0,a0,a5
    8000549c:	00052023          	sw	zero,0(a0)
}
    800054a0:	60a2                	ld	ra,8(sp)
    800054a2:	6402                	ld	s0,0(sp)
    800054a4:	0141                	addi	sp,sp,16
    800054a6:	8082                	ret

00000000800054a8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800054a8:	1141                	addi	sp,sp,-16
    800054aa:	e406                	sd	ra,8(sp)
    800054ac:	e022                	sd	s0,0(sp)
    800054ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054b0:	b28fc0ef          	jal	ra,800017d8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800054b4:	00d5179b          	slliw	a5,a0,0xd
    800054b8:	0c201537          	lui	a0,0xc201
    800054bc:	953e                	add	a0,a0,a5
  return irq;
}
    800054be:	4148                	lw	a0,4(a0)
    800054c0:	60a2                	ld	ra,8(sp)
    800054c2:	6402                	ld	s0,0(sp)
    800054c4:	0141                	addi	sp,sp,16
    800054c6:	8082                	ret

00000000800054c8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800054c8:	1101                	addi	sp,sp,-32
    800054ca:	ec06                	sd	ra,24(sp)
    800054cc:	e822                	sd	s0,16(sp)
    800054ce:	e426                	sd	s1,8(sp)
    800054d0:	1000                	addi	s0,sp,32
    800054d2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800054d4:	b04fc0ef          	jal	ra,800017d8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800054d8:	00d5151b          	slliw	a0,a0,0xd
    800054dc:	0c2017b7          	lui	a5,0xc201
    800054e0:	97aa                	add	a5,a5,a0
    800054e2:	c3c4                	sw	s1,4(a5)
}
    800054e4:	60e2                	ld	ra,24(sp)
    800054e6:	6442                	ld	s0,16(sp)
    800054e8:	64a2                	ld	s1,8(sp)
    800054ea:	6105                	addi	sp,sp,32
    800054ec:	8082                	ret

00000000800054ee <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800054ee:	1141                	addi	sp,sp,-16
    800054f0:	e406                	sd	ra,8(sp)
    800054f2:	e022                	sd	s0,0(sp)
    800054f4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800054f6:	479d                	li	a5,7
    800054f8:	04a7ca63          	blt	a5,a0,8000554c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800054fc:	0001b797          	auipc	a5,0x1b
    80005500:	76c78793          	addi	a5,a5,1900 # 80020c68 <disk>
    80005504:	97aa                	add	a5,a5,a0
    80005506:	0187c783          	lbu	a5,24(a5)
    8000550a:	e7b9                	bnez	a5,80005558 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000550c:	00451613          	slli	a2,a0,0x4
    80005510:	0001b797          	auipc	a5,0x1b
    80005514:	75878793          	addi	a5,a5,1880 # 80020c68 <disk>
    80005518:	6394                	ld	a3,0(a5)
    8000551a:	96b2                	add	a3,a3,a2
    8000551c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005520:	6398                	ld	a4,0(a5)
    80005522:	9732                	add	a4,a4,a2
    80005524:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005528:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000552c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005530:	953e                	add	a0,a0,a5
    80005532:	4785                	li	a5,1
    80005534:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005538:	0001b517          	auipc	a0,0x1b
    8000553c:	74850513          	addi	a0,a0,1864 # 80020c80 <disk+0x18>
    80005540:	921fc0ef          	jal	ra,80001e60 <wakeup>
}
    80005544:	60a2                	ld	ra,8(sp)
    80005546:	6402                	ld	s0,0(sp)
    80005548:	0141                	addi	sp,sp,16
    8000554a:	8082                	ret
    panic("free_desc 1");
    8000554c:	00002517          	auipc	a0,0x2
    80005550:	21450513          	addi	a0,a0,532 # 80007760 <syscalls+0x370>
    80005554:	a36fb0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    80005558:	00002517          	auipc	a0,0x2
    8000555c:	21850513          	addi	a0,a0,536 # 80007770 <syscalls+0x380>
    80005560:	a2afb0ef          	jal	ra,8000078a <panic>

0000000080005564 <virtio_disk_init>:
{
    80005564:	1101                	addi	sp,sp,-32
    80005566:	ec06                	sd	ra,24(sp)
    80005568:	e822                	sd	s0,16(sp)
    8000556a:	e426                	sd	s1,8(sp)
    8000556c:	e04a                	sd	s2,0(sp)
    8000556e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005570:	00002597          	auipc	a1,0x2
    80005574:	21058593          	addi	a1,a1,528 # 80007780 <syscalls+0x390>
    80005578:	0001c517          	auipc	a0,0x1c
    8000557c:	81850513          	addi	a0,a0,-2024 # 80020d90 <disk+0x128>
    80005580:	d6cfb0ef          	jal	ra,80000aec <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005584:	100017b7          	lui	a5,0x10001
    80005588:	4398                	lw	a4,0(a5)
    8000558a:	2701                	sext.w	a4,a4
    8000558c:	747277b7          	lui	a5,0x74727
    80005590:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005594:	14f71063          	bne	a4,a5,800056d4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005598:	100017b7          	lui	a5,0x10001
    8000559c:	43dc                	lw	a5,4(a5)
    8000559e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055a0:	4709                	li	a4,2
    800055a2:	12e79963          	bne	a5,a4,800056d4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055a6:	100017b7          	lui	a5,0x10001
    800055aa:	479c                	lw	a5,8(a5)
    800055ac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055ae:	12e79363          	bne	a5,a4,800056d4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800055b2:	100017b7          	lui	a5,0x10001
    800055b6:	47d8                	lw	a4,12(a5)
    800055b8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055ba:	554d47b7          	lui	a5,0x554d4
    800055be:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800055c2:	10f71963          	bne	a4,a5,800056d4 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055c6:	100017b7          	lui	a5,0x10001
    800055ca:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055ce:	4705                	li	a4,1
    800055d0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055d2:	470d                	li	a4,3
    800055d4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800055d6:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800055d8:	c7ffe737          	lui	a4,0xc7ffe
    800055dc:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd9a7>
    800055e0:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800055e2:	2701                	sext.w	a4,a4
    800055e4:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055e6:	472d                	li	a4,11
    800055e8:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800055ea:	5bbc                	lw	a5,112(a5)
    800055ec:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800055f0:	8ba1                	andi	a5,a5,8
    800055f2:	0e078763          	beqz	a5,800056e0 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800055f6:	100017b7          	lui	a5,0x10001
    800055fa:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800055fe:	43fc                	lw	a5,68(a5)
    80005600:	2781                	sext.w	a5,a5
    80005602:	0e079563          	bnez	a5,800056ec <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005606:	100017b7          	lui	a5,0x10001
    8000560a:	5bdc                	lw	a5,52(a5)
    8000560c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000560e:	0e078563          	beqz	a5,800056f8 <virtio_disk_init+0x194>
  if(max < NUM)
    80005612:	471d                	li	a4,7
    80005614:	0ef77863          	bgeu	a4,a5,80005704 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80005618:	c84fb0ef          	jal	ra,80000a9c <kalloc>
    8000561c:	0001b497          	auipc	s1,0x1b
    80005620:	64c48493          	addi	s1,s1,1612 # 80020c68 <disk>
    80005624:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005626:	c76fb0ef          	jal	ra,80000a9c <kalloc>
    8000562a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000562c:	c70fb0ef          	jal	ra,80000a9c <kalloc>
    80005630:	87aa                	mv	a5,a0
    80005632:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005634:	6088                	ld	a0,0(s1)
    80005636:	cd69                	beqz	a0,80005710 <virtio_disk_init+0x1ac>
    80005638:	0001b717          	auipc	a4,0x1b
    8000563c:	63873703          	ld	a4,1592(a4) # 80020c70 <disk+0x8>
    80005640:	cb61                	beqz	a4,80005710 <virtio_disk_init+0x1ac>
    80005642:	c7f9                	beqz	a5,80005710 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    80005644:	6605                	lui	a2,0x1
    80005646:	4581                	li	a1,0
    80005648:	df8fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000564c:	0001b497          	auipc	s1,0x1b
    80005650:	61c48493          	addi	s1,s1,1564 # 80020c68 <disk>
    80005654:	6605                	lui	a2,0x1
    80005656:	4581                	li	a1,0
    80005658:	6488                	ld	a0,8(s1)
    8000565a:	de6fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.used, 0, PGSIZE);
    8000565e:	6605                	lui	a2,0x1
    80005660:	4581                	li	a1,0
    80005662:	6888                	ld	a0,16(s1)
    80005664:	ddcfb0ef          	jal	ra,80000c40 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005668:	100017b7          	lui	a5,0x10001
    8000566c:	4721                	li	a4,8
    8000566e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005670:	4098                	lw	a4,0(s1)
    80005672:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005676:	40d8                	lw	a4,4(s1)
    80005678:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000567c:	6498                	ld	a4,8(s1)
    8000567e:	0007069b          	sext.w	a3,a4
    80005682:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005686:	9701                	srai	a4,a4,0x20
    80005688:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000568c:	6898                	ld	a4,16(s1)
    8000568e:	0007069b          	sext.w	a3,a4
    80005692:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005696:	9701                	srai	a4,a4,0x20
    80005698:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000569c:	4705                	li	a4,1
    8000569e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800056a0:	00e48c23          	sb	a4,24(s1)
    800056a4:	00e48ca3          	sb	a4,25(s1)
    800056a8:	00e48d23          	sb	a4,26(s1)
    800056ac:	00e48da3          	sb	a4,27(s1)
    800056b0:	00e48e23          	sb	a4,28(s1)
    800056b4:	00e48ea3          	sb	a4,29(s1)
    800056b8:	00e48f23          	sb	a4,30(s1)
    800056bc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800056c0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800056c4:	0727a823          	sw	s2,112(a5)
}
    800056c8:	60e2                	ld	ra,24(sp)
    800056ca:	6442                	ld	s0,16(sp)
    800056cc:	64a2                	ld	s1,8(sp)
    800056ce:	6902                	ld	s2,0(sp)
    800056d0:	6105                	addi	sp,sp,32
    800056d2:	8082                	ret
    panic("could not find virtio disk");
    800056d4:	00002517          	auipc	a0,0x2
    800056d8:	0bc50513          	addi	a0,a0,188 # 80007790 <syscalls+0x3a0>
    800056dc:	8aefb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    800056e0:	00002517          	auipc	a0,0x2
    800056e4:	0d050513          	addi	a0,a0,208 # 800077b0 <syscalls+0x3c0>
    800056e8:	8a2fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    800056ec:	00002517          	auipc	a0,0x2
    800056f0:	0e450513          	addi	a0,a0,228 # 800077d0 <syscalls+0x3e0>
    800056f4:	896fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    800056f8:	00002517          	auipc	a0,0x2
    800056fc:	0f850513          	addi	a0,a0,248 # 800077f0 <syscalls+0x400>
    80005700:	88afb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    80005704:	00002517          	auipc	a0,0x2
    80005708:	10c50513          	addi	a0,a0,268 # 80007810 <syscalls+0x420>
    8000570c:	87efb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    80005710:	00002517          	auipc	a0,0x2
    80005714:	12050513          	addi	a0,a0,288 # 80007830 <syscalls+0x440>
    80005718:	872fb0ef          	jal	ra,8000078a <panic>

000000008000571c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000571c:	7119                	addi	sp,sp,-128
    8000571e:	fc86                	sd	ra,120(sp)
    80005720:	f8a2                	sd	s0,112(sp)
    80005722:	f4a6                	sd	s1,104(sp)
    80005724:	f0ca                	sd	s2,96(sp)
    80005726:	ecce                	sd	s3,88(sp)
    80005728:	e8d2                	sd	s4,80(sp)
    8000572a:	e4d6                	sd	s5,72(sp)
    8000572c:	e0da                	sd	s6,64(sp)
    8000572e:	fc5e                	sd	s7,56(sp)
    80005730:	f862                	sd	s8,48(sp)
    80005732:	f466                	sd	s9,40(sp)
    80005734:	f06a                	sd	s10,32(sp)
    80005736:	ec6e                	sd	s11,24(sp)
    80005738:	0100                	addi	s0,sp,128
    8000573a:	8aaa                	mv	s5,a0
    8000573c:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000573e:	00c52d03          	lw	s10,12(a0)
    80005742:	001d1d1b          	slliw	s10,s10,0x1
    80005746:	1d02                	slli	s10,s10,0x20
    80005748:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000574c:	0001b517          	auipc	a0,0x1b
    80005750:	64450513          	addi	a0,a0,1604 # 80020d90 <disk+0x128>
    80005754:	c18fb0ef          	jal	ra,80000b6c <acquire>
  for(int i = 0; i < 3; i++){
    80005758:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000575a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000575c:	0001bb97          	auipc	s7,0x1b
    80005760:	50cb8b93          	addi	s7,s7,1292 # 80020c68 <disk>
  for(int i = 0; i < 3; i++){
    80005764:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005766:	0001bc97          	auipc	s9,0x1b
    8000576a:	62ac8c93          	addi	s9,s9,1578 # 80020d90 <disk+0x128>
    8000576e:	a8a9                	j	800057c8 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005770:	00fb8733          	add	a4,s7,a5
    80005774:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005778:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000577a:	0207c563          	bltz	a5,800057a4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000577e:	2905                	addiw	s2,s2,1
    80005780:	0611                	addi	a2,a2,4
    80005782:	05690863          	beq	s2,s6,800057d2 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005786:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005788:	0001b717          	auipc	a4,0x1b
    8000578c:	4e070713          	addi	a4,a4,1248 # 80020c68 <disk>
    80005790:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005792:	01874683          	lbu	a3,24(a4)
    80005796:	fee9                	bnez	a3,80005770 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005798:	2785                	addiw	a5,a5,1
    8000579a:	0705                	addi	a4,a4,1
    8000579c:	fe979be3          	bne	a5,s1,80005792 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800057a0:	57fd                	li	a5,-1
    800057a2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800057a4:	01205b63          	blez	s2,800057ba <virtio_disk_rw+0x9e>
    800057a8:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800057aa:	000a2503          	lw	a0,0(s4)
    800057ae:	d41ff0ef          	jal	ra,800054ee <free_desc>
      for(int j = 0; j < i; j++)
    800057b2:	2d85                	addiw	s11,s11,1
    800057b4:	0a11                	addi	s4,s4,4
    800057b6:	ffb91ae3          	bne	s2,s11,800057aa <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057ba:	85e6                	mv	a1,s9
    800057bc:	0001b517          	auipc	a0,0x1b
    800057c0:	4c450513          	addi	a0,a0,1220 # 80020c80 <disk+0x18>
    800057c4:	e50fc0ef          	jal	ra,80001e14 <sleep>
  for(int i = 0; i < 3; i++){
    800057c8:	f8040a13          	addi	s4,s0,-128
{
    800057cc:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800057ce:	894e                	mv	s2,s3
    800057d0:	bf5d                	j	80005786 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057d2:	f8042583          	lw	a1,-128(s0)
    800057d6:	00a58793          	addi	a5,a1,10
    800057da:	0792                	slli	a5,a5,0x4

  if(write)
    800057dc:	0001b617          	auipc	a2,0x1b
    800057e0:	48c60613          	addi	a2,a2,1164 # 80020c68 <disk>
    800057e4:	00f60733          	add	a4,a2,a5
    800057e8:	018036b3          	snez	a3,s8
    800057ec:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800057ee:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800057f2:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800057f6:	f6078693          	addi	a3,a5,-160
    800057fa:	6218                	ld	a4,0(a2)
    800057fc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057fe:	00878513          	addi	a0,a5,8
    80005802:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005804:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005806:	6208                	ld	a0,0(a2)
    80005808:	96aa                	add	a3,a3,a0
    8000580a:	4741                	li	a4,16
    8000580c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000580e:	4705                	li	a4,1
    80005810:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005814:	f8442703          	lw	a4,-124(s0)
    80005818:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000581c:	0712                	slli	a4,a4,0x4
    8000581e:	953a                	add	a0,a0,a4
    80005820:	058a8693          	addi	a3,s5,88
    80005824:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80005826:	6208                	ld	a0,0(a2)
    80005828:	972a                	add	a4,a4,a0
    8000582a:	40000693          	li	a3,1024
    8000582e:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005830:	001c3c13          	seqz	s8,s8
    80005834:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005836:	001c6c13          	ori	s8,s8,1
    8000583a:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000583e:	f8842603          	lw	a2,-120(s0)
    80005842:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005846:	0001b697          	auipc	a3,0x1b
    8000584a:	42268693          	addi	a3,a3,1058 # 80020c68 <disk>
    8000584e:	00258713          	addi	a4,a1,2
    80005852:	0712                	slli	a4,a4,0x4
    80005854:	9736                	add	a4,a4,a3
    80005856:	587d                	li	a6,-1
    80005858:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000585c:	0612                	slli	a2,a2,0x4
    8000585e:	9532                	add	a0,a0,a2
    80005860:	f9078793          	addi	a5,a5,-112
    80005864:	97b6                	add	a5,a5,a3
    80005866:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    80005868:	629c                	ld	a5,0(a3)
    8000586a:	97b2                	add	a5,a5,a2
    8000586c:	4605                	li	a2,1
    8000586e:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005870:	4509                	li	a0,2
    80005872:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    80005876:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000587a:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000587e:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005882:	6698                	ld	a4,8(a3)
    80005884:	00275783          	lhu	a5,2(a4)
    80005888:	8b9d                	andi	a5,a5,7
    8000588a:	0786                	slli	a5,a5,0x1
    8000588c:	97ba                	add	a5,a5,a4
    8000588e:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005892:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005896:	6698                	ld	a4,8(a3)
    80005898:	00275783          	lhu	a5,2(a4)
    8000589c:	2785                	addiw	a5,a5,1
    8000589e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800058a2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800058a6:	100017b7          	lui	a5,0x10001
    800058aa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800058ae:	004aa783          	lw	a5,4(s5)
    800058b2:	00c79f63          	bne	a5,a2,800058d0 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    800058b6:	0001b917          	auipc	s2,0x1b
    800058ba:	4da90913          	addi	s2,s2,1242 # 80020d90 <disk+0x128>
  while(b->disk == 1) {
    800058be:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800058c0:	85ca                	mv	a1,s2
    800058c2:	8556                	mv	a0,s5
    800058c4:	d50fc0ef          	jal	ra,80001e14 <sleep>
  while(b->disk == 1) {
    800058c8:	004aa783          	lw	a5,4(s5)
    800058cc:	fe978ae3          	beq	a5,s1,800058c0 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    800058d0:	f8042903          	lw	s2,-128(s0)
    800058d4:	00290793          	addi	a5,s2,2
    800058d8:	00479713          	slli	a4,a5,0x4
    800058dc:	0001b797          	auipc	a5,0x1b
    800058e0:	38c78793          	addi	a5,a5,908 # 80020c68 <disk>
    800058e4:	97ba                	add	a5,a5,a4
    800058e6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800058ea:	0001b997          	auipc	s3,0x1b
    800058ee:	37e98993          	addi	s3,s3,894 # 80020c68 <disk>
    800058f2:	00491713          	slli	a4,s2,0x4
    800058f6:	0009b783          	ld	a5,0(s3)
    800058fa:	97ba                	add	a5,a5,a4
    800058fc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005900:	854a                	mv	a0,s2
    80005902:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005906:	be9ff0ef          	jal	ra,800054ee <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000590a:	8885                	andi	s1,s1,1
    8000590c:	f0fd                	bnez	s1,800058f2 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000590e:	0001b517          	auipc	a0,0x1b
    80005912:	48250513          	addi	a0,a0,1154 # 80020d90 <disk+0x128>
    80005916:	aeefb0ef          	jal	ra,80000c04 <release>
}
    8000591a:	70e6                	ld	ra,120(sp)
    8000591c:	7446                	ld	s0,112(sp)
    8000591e:	74a6                	ld	s1,104(sp)
    80005920:	7906                	ld	s2,96(sp)
    80005922:	69e6                	ld	s3,88(sp)
    80005924:	6a46                	ld	s4,80(sp)
    80005926:	6aa6                	ld	s5,72(sp)
    80005928:	6b06                	ld	s6,64(sp)
    8000592a:	7be2                	ld	s7,56(sp)
    8000592c:	7c42                	ld	s8,48(sp)
    8000592e:	7ca2                	ld	s9,40(sp)
    80005930:	7d02                	ld	s10,32(sp)
    80005932:	6de2                	ld	s11,24(sp)
    80005934:	6109                	addi	sp,sp,128
    80005936:	8082                	ret

0000000080005938 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005938:	1101                	addi	sp,sp,-32
    8000593a:	ec06                	sd	ra,24(sp)
    8000593c:	e822                	sd	s0,16(sp)
    8000593e:	e426                	sd	s1,8(sp)
    80005940:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005942:	0001b497          	auipc	s1,0x1b
    80005946:	32648493          	addi	s1,s1,806 # 80020c68 <disk>
    8000594a:	0001b517          	auipc	a0,0x1b
    8000594e:	44650513          	addi	a0,a0,1094 # 80020d90 <disk+0x128>
    80005952:	a1afb0ef          	jal	ra,80000b6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005956:	10001737          	lui	a4,0x10001
    8000595a:	533c                	lw	a5,96(a4)
    8000595c:	8b8d                	andi	a5,a5,3
    8000595e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005960:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005964:	689c                	ld	a5,16(s1)
    80005966:	0204d703          	lhu	a4,32(s1)
    8000596a:	0027d783          	lhu	a5,2(a5)
    8000596e:	04f70663          	beq	a4,a5,800059ba <virtio_disk_intr+0x82>
    __sync_synchronize();
    80005972:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005976:	6898                	ld	a4,16(s1)
    80005978:	0204d783          	lhu	a5,32(s1)
    8000597c:	8b9d                	andi	a5,a5,7
    8000597e:	078e                	slli	a5,a5,0x3
    80005980:	97ba                	add	a5,a5,a4
    80005982:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005984:	00278713          	addi	a4,a5,2
    80005988:	0712                	slli	a4,a4,0x4
    8000598a:	9726                	add	a4,a4,s1
    8000598c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005990:	e321                	bnez	a4,800059d0 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005992:	0789                	addi	a5,a5,2
    80005994:	0792                	slli	a5,a5,0x4
    80005996:	97a6                	add	a5,a5,s1
    80005998:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000599a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000599e:	cc2fc0ef          	jal	ra,80001e60 <wakeup>

    disk.used_idx += 1;
    800059a2:	0204d783          	lhu	a5,32(s1)
    800059a6:	2785                	addiw	a5,a5,1
    800059a8:	17c2                	slli	a5,a5,0x30
    800059aa:	93c1                	srli	a5,a5,0x30
    800059ac:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800059b0:	6898                	ld	a4,16(s1)
    800059b2:	00275703          	lhu	a4,2(a4)
    800059b6:	faf71ee3          	bne	a4,a5,80005972 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    800059ba:	0001b517          	auipc	a0,0x1b
    800059be:	3d650513          	addi	a0,a0,982 # 80020d90 <disk+0x128>
    800059c2:	a42fb0ef          	jal	ra,80000c04 <release>
}
    800059c6:	60e2                	ld	ra,24(sp)
    800059c8:	6442                	ld	s0,16(sp)
    800059ca:	64a2                	ld	s1,8(sp)
    800059cc:	6105                	addi	sp,sp,32
    800059ce:	8082                	ret
      panic("virtio_disk_intr status");
    800059d0:	00002517          	auipc	a0,0x2
    800059d4:	e7850513          	addi	a0,a0,-392 # 80007848 <syscalls+0x458>
    800059d8:	db3fa0ef          	jal	ra,8000078a <panic>

00000000800059dc <sys_shm_init>:
#include "shm.h"

uint64
sys_shm_init(void)
{
    if(shm.valid){
    800059dc:	0001b797          	auipc	a5,0x1b
    800059e0:	3cc7a783          	lw	a5,972(a5) # 80020da8 <shm>
        return -1;
    800059e4:	557d                	li	a0,-1
    if(shm.valid){
    800059e6:	ef85                	bnez	a5,80005a1e <sys_shm_init+0x42>
{
    800059e8:	1101                	addi	sp,sp,-32
    800059ea:	ec06                	sd	ra,24(sp)
    800059ec:	e822                	sd	s0,16(sp)
    800059ee:	e426                	sd	s1,8(sp)
    800059f0:	1000                	addi	s0,sp,32
    }
    else{
        void* pa=kalloc();
    800059f2:	8aafb0ef          	jal	ra,80000a9c <kalloc>
    800059f6:	84aa                	mv	s1,a0
        memset(pa, 0, PGSIZE);
    800059f8:	6605                	lui	a2,0x1
    800059fa:	4581                	li	a1,0
    800059fc:	a44fb0ef          	jal	ra,80000c40 <memset>
        shm.kva=(uint64)pa;
    80005a00:	0001b797          	auipc	a5,0x1b
    80005a04:	3a878793          	addi	a5,a5,936 # 80020da8 <shm>
    80005a08:	e784                	sd	s1,8(a5)
        shm.refcnt=0;
    80005a0a:	0007a223          	sw	zero,4(a5)
        shm.valid=1;
    80005a0e:	4705                	li	a4,1
    80005a10:	c398                	sw	a4,0(a5)
    }
    return 0;
    80005a12:	4501                	li	a0,0
    
}
    80005a14:	60e2                	ld	ra,24(sp)
    80005a16:	6442                	ld	s0,16(sp)
    80005a18:	64a2                	ld	s1,8(sp)
    80005a1a:	6105                	addi	sp,sp,32
    80005a1c:	8082                	ret
    80005a1e:	8082                	ret

0000000080005a20 <sys_shm_attach>:

uint64
sys_shm_attach(void)
{
    80005a20:	1141                	addi	sp,sp,-16
    80005a22:	e406                	sd	ra,8(sp)
    80005a24:	e022                	sd	s0,0(sp)
    80005a26:	0800                	addi	s0,sp,16
    struct proc *p=myproc();
    80005a28:	dddfb0ef          	jal	ra,80001804 <myproc>
    80005a2c:	87aa                	mv	a5,a0
    if(!shm.valid){
    80005a2e:	0001b717          	auipc	a4,0x1b
    80005a32:	37a72703          	lw	a4,890(a4) # 80020da8 <shm>
        return -1;
    80005a36:	557d                	li	a0,-1
    if(!shm.valid){
    80005a38:	c701                	beqz	a4,80005a40 <sys_shm_attach+0x20>
    }
    if(p->shm) return -1;
    80005a3a:	1687a703          	lw	a4,360(a5)
    80005a3e:	c709                	beqz	a4,80005a48 <sys_shm_attach+0x28>
    p->shm=1;
    shm.refcnt++;
    int a=mappages(p->pagetable,SHMEM,PGSIZE,shm.kva,PTE_U | PTE_R |PTE_W);
    if(a==0) return SHMEM;
    return -1;
}
    80005a40:	60a2                	ld	ra,8(sp)
    80005a42:	6402                	ld	s0,0(sp)
    80005a44:	0141                	addi	sp,sp,16
    80005a46:	8082                	ret
    p->shm=1;
    80005a48:	4705                	li	a4,1
    80005a4a:	16e7a423          	sw	a4,360(a5)
    shm.refcnt++;
    80005a4e:	0001b697          	auipc	a3,0x1b
    80005a52:	35a68693          	addi	a3,a3,858 # 80020da8 <shm>
    80005a56:	42d8                	lw	a4,4(a3)
    80005a58:	2705                	addiw	a4,a4,1
    80005a5a:	c2d8                	sw	a4,4(a3)
    int a=mappages(p->pagetable,SHMEM,PGSIZE,shm.kva,PTE_U | PTE_R |PTE_W);
    80005a5c:	4759                	li	a4,22
    80005a5e:	6694                	ld	a3,8(a3)
    80005a60:	6605                	lui	a2,0x1
    80005a62:	040005b7          	lui	a1,0x4000
    80005a66:	15f5                	addi	a1,a1,-3
    80005a68:	05b2                	slli	a1,a1,0xc
    80005a6a:	6ba8                	ld	a0,80(a5)
    80005a6c:	d28fb0ef          	jal	ra,80000f94 <mappages>
    80005a70:	87aa                	mv	a5,a0
    return -1;
    80005a72:	557d                	li	a0,-1
    if(a==0) return SHMEM;
    80005a74:	f7f1                	bnez	a5,80005a40 <sys_shm_attach+0x20>
    80005a76:	04000537          	lui	a0,0x4000
    80005a7a:	1575                	addi	a0,a0,-3
    80005a7c:	0532                	slli	a0,a0,0xc
    80005a7e:	b7c9                	j	80005a40 <sys_shm_attach+0x20>

0000000080005a80 <sys_shm_detach>:

uint64
sys_shm_detach(void)
{
    80005a80:	1141                	addi	sp,sp,-16
    80005a82:	e406                	sd	ra,8(sp)
    80005a84:	e022                	sd	s0,0(sp)
    80005a86:	0800                	addi	s0,sp,16
    struct proc *p=myproc();
    80005a88:	d7dfb0ef          	jal	ra,80001804 <myproc>
    80005a8c:	87aa                	mv	a5,a0
    if(!shm.valid){
    80005a8e:	0001b717          	auipc	a4,0x1b
    80005a92:	31a72703          	lw	a4,794(a4) # 80020da8 <shm>
        return -1;
    80005a96:	557d                	li	a0,-1
    if(!shm.valid){
    80005a98:	c71d                	beqz	a4,80005ac6 <sys_shm_detach+0x46>
    }
    if(!p->shm) return -1;
    80005a9a:	1687a703          	lw	a4,360(a5)
    80005a9e:	c705                	beqz	a4,80005ac6 <sys_shm_detach+0x46>
    p->shm=0;
    80005aa0:	1607a423          	sw	zero,360(a5)
    shm.refcnt--;
    80005aa4:	0001b697          	auipc	a3,0x1b
    80005aa8:	30468693          	addi	a3,a3,772 # 80020da8 <shm>
    80005aac:	42d8                	lw	a4,4(a3)
    80005aae:	377d                	addiw	a4,a4,-1
    80005ab0:	c2d8                	sw	a4,4(a3)
    uvmunmap(p->pagetable, SHMEM, 1, 0);
    80005ab2:	4681                	li	a3,0
    80005ab4:	4605                	li	a2,1
    80005ab6:	040005b7          	lui	a1,0x4000
    80005aba:	15f5                	addi	a1,a1,-3
    80005abc:	05b2                	slli	a1,a1,0xc
    80005abe:	6ba8                	ld	a0,80(a5)
    80005ac0:	ea0fb0ef          	jal	ra,80001160 <uvmunmap>
    return 0;
    80005ac4:	4501                	li	a0,0
}
    80005ac6:	60a2                	ld	ra,8(sp)
    80005ac8:	6402                	ld	s0,0(sp)
    80005aca:	0141                	addi	sp,sp,16
    80005acc:	8082                	ret

0000000080005ace <sys_shm_destroy>:

uint64
sys_shm_destroy(void)
{
    if(!shm.valid){
    80005ace:	0001b797          	auipc	a5,0x1b
    80005ad2:	2da7a783          	lw	a5,730(a5) # 80020da8 <shm>
        return -1;
    80005ad6:	557d                	li	a0,-1
    if(!shm.valid){
    80005ad8:	cb85                	beqz	a5,80005b08 <sys_shm_destroy+0x3a>
    }
    if(shm.refcnt!=0) return -1;
    80005ada:	0001b797          	auipc	a5,0x1b
    80005ade:	2d27a783          	lw	a5,722(a5) # 80020dac <shm+0x4>
    80005ae2:	e39d                	bnez	a5,80005b08 <sys_shm_destroy+0x3a>
{
    80005ae4:	1141                	addi	sp,sp,-16
    80005ae6:	e406                	sd	ra,8(sp)
    80005ae8:	e022                	sd	s0,0(sp)
    80005aea:	0800                	addi	s0,sp,16
    shm.valid=0;
    80005aec:	0001b797          	auipc	a5,0x1b
    80005af0:	2bc78793          	addi	a5,a5,700 # 80020da8 <shm>
    80005af4:	0007a023          	sw	zero,0(a5)
    kfree((void*)shm.kva);
    80005af8:	6788                	ld	a0,8(a5)
    80005afa:	ec3fa0ef          	jal	ra,800009bc <kfree>
    return 0;
    80005afe:	4501                	li	a0,0
}
    80005b00:	60a2                	ld	ra,8(sp)
    80005b02:	6402                	ld	s0,0(sp)
    80005b04:	0141                	addi	sp,sp,16
    80005b06:	8082                	ret
    80005b08:	8082                	ret

0000000080005b0a <sys_shm_refcount>:

uint64
sys_shm_refcount(void)
{
    80005b0a:	1141                	addi	sp,sp,-16
    80005b0c:	e422                	sd	s0,8(sp)
    80005b0e:	0800                	addi	s0,sp,16
    if(!shm.valid){
    80005b10:	0001b797          	auipc	a5,0x1b
    80005b14:	2987a783          	lw	a5,664(a5) # 80020da8 <shm>
        return -1;
    80005b18:	557d                	li	a0,-1
    if(!shm.valid){
    80005b1a:	c789                	beqz	a5,80005b24 <sys_shm_refcount+0x1a>
    }
    return shm.refcnt;
    80005b1c:	0001b517          	auipc	a0,0x1b
    80005b20:	29052503          	lw	a0,656(a0) # 80020dac <shm+0x4>
}
    80005b24:	6422                	ld	s0,8(sp)
    80005b26:	0141                	addi	sp,sp,16
    80005b28:	8082                	ret
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

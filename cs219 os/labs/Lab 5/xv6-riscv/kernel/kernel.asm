
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
    80000004:	96010113          	addi	sp,sp,-1696 # 80007960 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd797>
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
    8000010a:	146020ef          	jal	ra,80002250 <either_copyin>
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
    80000176:	7ee50513          	addi	a0,a0,2030 # 8000f960 <cons>
    8000017a:	1f3000ef          	jal	ra,80000b6c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	0000f497          	auipc	s1,0xf
    80000182:	7e248493          	addi	s1,s1,2018 # 8000f960 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00010917          	auipc	s2,0x10
    8000018a:	87290913          	addi	s2,s2,-1934 # 8000f9f8 <cons+0x98>
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
    800001a4:	664010ef          	jal	ra,80001808 <myproc>
    800001a8:	73b010ef          	jal	ra,800020e2 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	4f9010ef          	jal	ra,80001eaa <sleep>
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
    800001ea:	01c020ef          	jal	ra,80002206 <either_copyout>
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
    800001fe:	76650513          	addi	a0,a0,1894 # 8000f960 <cons>
    80000202:	203000ef          	jal	ra,80000c04 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	0000f517          	auipc	a0,0xf
    80000210:	75450513          	addi	a0,a0,1876 # 8000f960 <cons>
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
    80000242:	7af72d23          	sw	a5,1978(a4) # 8000f9f8 <cons+0x98>
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
    8000028c:	6d850513          	addi	a0,a0,1752 # 8000f960 <cons>
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
    800002aa:	7f1010ef          	jal	ra,8000229a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	0000f517          	auipc	a0,0xf
    800002b2:	6b250513          	addi	a0,a0,1714 # 8000f960 <cons>
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
    800002d2:	69270713          	addi	a4,a4,1682 # 8000f960 <cons>
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
    800002f8:	66c78793          	addi	a5,a5,1644 # 8000f960 <cons>
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
    80000326:	6d67a783          	lw	a5,1750(a5) # 8000f9f8 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	0000f717          	auipc	a4,0xf
    8000033a:	62a70713          	addi	a4,a4,1578 # 8000f960 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	0000f497          	auipc	s1,0xf
    8000034a:	61a48493          	addi	s1,s1,1562 # 8000f960 <cons>
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
    80000382:	5e270713          	addi	a4,a4,1506 # 8000f960 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	66f72623          	sw	a5,1644(a4) # 8000fa00 <cons+0xa0>
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
    800003b6:	5ae78793          	addi	a5,a5,1454 # 8000f960 <cons>
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
    800003da:	62c7a323          	sw	a2,1574(a5) # 8000f9fc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	61a50513          	addi	a0,a0,1562 # 8000f9f8 <cons+0x98>
    800003e6:	311010ef          	jal	ra,80001ef6 <wakeup>
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
    80000400:	56450513          	addi	a0,a0,1380 # 8000f960 <cons>
    80000404:	6e8000ef          	jal	ra,80000aec <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00020797          	auipc	a5,0x20
    80000410:	ac478793          	addi	a5,a5,-1340 # 8001fed0 <devsw>
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
    800004fa:	43e7a783          	lw	a5,1086(a5) # 80007934 <panicking>
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
    80000538:	4d450513          	addi	a0,a0,1236 # 8000fa08 <pr>
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
    80000756:	1e27a783          	lw	a5,482(a5) # 80007934 <panicking>
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
    80000780:	28c50513          	addi	a0,a0,652 # 8000fa08 <pr>
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
    8000079e:	1927ad23          	sw	s2,410(a5) # 80007934 <panicking>
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
    800007c0:	1727aa23          	sw	s2,372(a5) # 80007930 <panicked>
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
    800007da:	23250513          	addi	a0,a0,562 # 8000fa08 <pr>
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
    80000826:	1fe50513          	addi	a0,a0,510 # 8000fa20 <tx_lock>
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
    80000854:	1d050513          	addi	a0,a0,464 # 8000fa20 <tx_lock>
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
    80000872:	0ce48493          	addi	s1,s1,206 # 8000793c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	1aa98993          	addi	s3,s3,426 # 8000fa20 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	0ba90913          	addi	s2,s2,186 # 80007938 <tx_chan>
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
    80000892:	618010ef          	jal	ra,80001eaa <sleep>
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
    800008b6:	16e50513          	addi	a0,a0,366 # 8000fa20 <tx_lock>
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
    800008e4:	0547a783          	lw	a5,84(a5) # 80007934 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	0467a783          	lw	a5,70(a5) # 80007930 <panicked>
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
    8000091a:	01e7a783          	lw	a5,30(a5) # 80007934 <panicking>
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
    8000096e:	0b650513          	addi	a0,a0,182 # 8000fa20 <tx_lock>
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
    80000984:	0a050513          	addi	a0,a0,160 # 8000fa20 <tx_lock>
    80000988:	27c000ef          	jal	ra,80000c04 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000098c:	54fd                	li	s1,-1
    8000098e:	a831                	j	800009aa <uartintr+0x52>
    tx_busy = 0;
    80000990:	00007797          	auipc	a5,0x7
    80000994:	fa07a623          	sw	zero,-84(a5) # 8000793c <tx_busy>
    wakeup(&tx_chan);
    80000998:	00007517          	auipc	a0,0x7
    8000099c:	fa050513          	addi	a0,a0,-96 # 80007938 <tx_chan>
    800009a0:	556010ef          	jal	ra,80001ef6 <wakeup>
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
    800009d4:	69878793          	addi	a5,a5,1688 # 80021068 <end>
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
    800009f0:	04c90913          	addi	s2,s2,76 # 8000fa38 <kmem>
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
    80000a7c:	fc050513          	addi	a0,a0,-64 # 8000fa38 <kmem>
    80000a80:	06c000ef          	jal	ra,80000aec <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a84:	45c5                	li	a1,17
    80000a86:	05ee                	slli	a1,a1,0x1b
    80000a88:	00020517          	auipc	a0,0x20
    80000a8c:	5e050513          	addi	a0,a0,1504 # 80021068 <end>
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
    80000aaa:	f9248493          	addi	s1,s1,-110 # 8000fa38 <kmem>
    80000aae:	8526                	mv	a0,s1
    80000ab0:	0bc000ef          	jal	ra,80000b6c <acquire>
  r = kmem.freelist;
    80000ab4:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab6:	c485                	beqz	s1,80000ade <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab8:	609c                	ld	a5,0(s1)
    80000aba:	0000f517          	auipc	a0,0xf
    80000abe:	f7e50513          	addi	a0,a0,-130 # 8000fa38 <kmem>
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
    80000ae2:	f5a50513          	addi	a0,a0,-166 # 8000fa38 <kmem>
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
    80000b16:	4d7000ef          	jal	ra,800017ec <mycpu>
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
    80000b44:	4a9000ef          	jal	ra,800017ec <mycpu>
    80000b48:	5d3c                	lw	a5,120(a0)
    80000b4a:	cb99                	beqz	a5,80000b60 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4c:	4a1000ef          	jal	ra,800017ec <mycpu>
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
    80000b60:	48d000ef          	jal	ra,800017ec <mycpu>
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
    80000b94:	459000ef          	jal	ra,800017ec <mycpu>
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
    80000bb8:	435000ef          	jal	ra,800017ec <mycpu>
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
    80000dea:	1f3000ef          	jal	ra,800017dc <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dee:	00007717          	auipc	a4,0x7
    80000df2:	b5270713          	addi	a4,a4,-1198 # 80007940 <started>
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
    80000e02:	1db000ef          	jal	ra,800017dc <cpuid>
    80000e06:	85aa                	mv	a1,a0
    80000e08:	00006517          	auipc	a0,0x6
    80000e0c:	2a850513          	addi	a0,a0,680 # 800070b0 <digits+0x78>
    80000e10:	eb4ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000e14:	080000ef          	jal	ra,80000e94 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e18:	5b2010ef          	jal	ra,800023ca <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1c:	768040ef          	jal	ra,80005584 <plicinithart>
  }

  scheduler();        
    80000e20:	6f3000ef          	jal	ra,80001d12 <scheduler>
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
    80000e60:	546010ef          	jal	ra,800023a6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e64:	566010ef          	jal	ra,800023ca <trapinithart>
    plicinit();      // set up interrupt controller
    80000e68:	706040ef          	jal	ra,8000556e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6c:	718040ef          	jal	ra,80005584 <plicinithart>
    binit();         // buffer cache
    80000e70:	6b1010ef          	jal	ra,80002d20 <binit>
    iinit();         // inode table
    80000e74:	424020ef          	jal	ra,80003298 <iinit>
    fileinit();      // file table
    80000e78:	304030ef          	jal	ra,8000417c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7c:	7f8040ef          	jal	ra,80005674 <virtio_disk_init>
    userinit();      // first user process
    80000e80:	4e9000ef          	jal	ra,80001b68 <userinit>
    __sync_synchronize();
    80000e84:	0ff0000f          	fence
    started = 1;
    80000e88:	4785                	li	a5,1
    80000e8a:	00007717          	auipc	a4,0x7
    80000e8e:	aaf72b23          	sw	a5,-1354(a4) # 80007940 <started>
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
    80000ea2:	aaa7b783          	ld	a5,-1366(a5) # 80007948 <kernel_pagetable>
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
    8000112e:	80a7bf23          	sd	a0,-2018(a5) # 80007948 <kernel_pagetable>
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
    800014f4:	314000ef          	jal	ra,80001808 <myproc>
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
    800016c0:	7cc48493          	addi	s1,s1,1996 # 8000fe88 <proc>
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
    800016da:	5b2a0a13          	addi	s4,s4,1458 # 80015c88 <tickslock>
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
    80001750:	30c50513          	addi	a0,a0,780 # 8000fa58 <pid_lock>
    80001754:	b98ff0ef          	jal	ra,80000aec <initlock>
  initlock(&wait_lock, "wait_lock");
    80001758:	00006597          	auipc	a1,0x6
    8000175c:	a2858593          	addi	a1,a1,-1496 # 80007180 <digits+0x148>
    80001760:	0000e517          	auipc	a0,0xe
    80001764:	31050513          	addi	a0,a0,784 # 8000fa70 <wait_lock>
    80001768:	b84ff0ef          	jal	ra,80000aec <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176c:	0000e497          	auipc	s1,0xe
    80001770:	71c48493          	addi	s1,s1,1820 # 8000fe88 <proc>
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
    80001792:	4fa98993          	addi	s3,s3,1274 # 80015c88 <tickslock>
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
      p->pf_count=0;
    800017bc:	1604a423          	sw	zero,360(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c0:	17848493          	addi	s1,s1,376
    800017c4:	fd3499e3          	bne	s1,s3,80001796 <procinit+0x66>
  }
}
    800017c8:	70e2                	ld	ra,56(sp)
    800017ca:	7442                	ld	s0,48(sp)
    800017cc:	74a2                	ld	s1,40(sp)
    800017ce:	7902                	ld	s2,32(sp)
    800017d0:	69e2                	ld	s3,24(sp)
    800017d2:	6a42                	ld	s4,16(sp)
    800017d4:	6aa2                	ld	s5,8(sp)
    800017d6:	6b02                	ld	s6,0(sp)
    800017d8:	6121                	addi	sp,sp,64
    800017da:	8082                	ret

00000000800017dc <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800017dc:	1141                	addi	sp,sp,-16
    800017de:	e422                	sd	s0,8(sp)
    800017e0:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800017e2:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800017e4:	2501                	sext.w	a0,a0
    800017e6:	6422                	ld	s0,8(sp)
    800017e8:	0141                	addi	sp,sp,16
    800017ea:	8082                	ret

00000000800017ec <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800017ec:	1141                	addi	sp,sp,-16
    800017ee:	e422                	sd	s0,8(sp)
    800017f0:	0800                	addi	s0,sp,16
    800017f2:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800017f4:	2781                	sext.w	a5,a5
    800017f6:	079e                	slli	a5,a5,0x7
  return c;
}
    800017f8:	0000e517          	auipc	a0,0xe
    800017fc:	29050513          	addi	a0,a0,656 # 8000fa88 <cpus>
    80001800:	953e                	add	a0,a0,a5
    80001802:	6422                	ld	s0,8(sp)
    80001804:	0141                	addi	sp,sp,16
    80001806:	8082                	ret

0000000080001808 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001808:	1101                	addi	sp,sp,-32
    8000180a:	ec06                	sd	ra,24(sp)
    8000180c:	e822                	sd	s0,16(sp)
    8000180e:	e426                	sd	s1,8(sp)
    80001810:	1000                	addi	s0,sp,32
  push_off();
    80001812:	b1aff0ef          	jal	ra,80000b2c <push_off>
    80001816:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001818:	2781                	sext.w	a5,a5
    8000181a:	079e                	slli	a5,a5,0x7
    8000181c:	0000e717          	auipc	a4,0xe
    80001820:	23c70713          	addi	a4,a4,572 # 8000fa58 <pid_lock>
    80001824:	97ba                	add	a5,a5,a4
    80001826:	7b84                	ld	s1,48(a5)
  pop_off();
    80001828:	b88ff0ef          	jal	ra,80000bb0 <pop_off>
  return p;
}
    8000182c:	8526                	mv	a0,s1
    8000182e:	60e2                	ld	ra,24(sp)
    80001830:	6442                	ld	s0,16(sp)
    80001832:	64a2                	ld	s1,8(sp)
    80001834:	6105                	addi	sp,sp,32
    80001836:	8082                	ret

0000000080001838 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001838:	7179                	addi	sp,sp,-48
    8000183a:	f406                	sd	ra,40(sp)
    8000183c:	f022                	sd	s0,32(sp)
    8000183e:	ec26                	sd	s1,24(sp)
    80001840:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001842:	fc7ff0ef          	jal	ra,80001808 <myproc>
    80001846:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001848:	bbcff0ef          	jal	ra,80000c04 <release>

  if (first) {
    8000184c:	00006797          	auipc	a5,0x6
    80001850:	0d47a783          	lw	a5,212(a5) # 80007920 <first.1>
    80001854:	cf8d                	beqz	a5,8000188e <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001856:	4505                	li	a0,1
    80001858:	6f1010ef          	jal	ra,80003748 <fsinit>

    first = 0;
    8000185c:	00006797          	auipc	a5,0x6
    80001860:	0c07a223          	sw	zero,196(a5) # 80007920 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001864:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001868:	00006517          	auipc	a0,0x6
    8000186c:	93050513          	addi	a0,a0,-1744 # 80007198 <digits+0x160>
    80001870:	fca43823          	sd	a0,-48(s0)
    80001874:	fc043c23          	sd	zero,-40(s0)
    80001878:	fd040593          	addi	a1,s0,-48
    8000187c:	775020ef          	jal	ra,800047f0 <kexec>
    80001880:	6cbc                	ld	a5,88(s1)
    80001882:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001884:	6cbc                	ld	a5,88(s1)
    80001886:	7bb8                	ld	a4,112(a5)
    80001888:	57fd                	li	a5,-1
    8000188a:	02f70d63          	beq	a4,a5,800018c4 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000188e:	355000ef          	jal	ra,800023e2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001892:	68a8                	ld	a0,80(s1)
    80001894:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001896:	04000737          	lui	a4,0x4000
    8000189a:	00005797          	auipc	a5,0x5
    8000189e:	80278793          	addi	a5,a5,-2046 # 8000609c <userret>
    800018a2:	00004697          	auipc	a3,0x4
    800018a6:	75e68693          	addi	a3,a3,1886 # 80006000 <_trampoline>
    800018aa:	8f95                	sub	a5,a5,a3
    800018ac:	177d                	addi	a4,a4,-1
    800018ae:	0732                	slli	a4,a4,0xc
    800018b0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800018b2:	577d                	li	a4,-1
    800018b4:	177e                	slli	a4,a4,0x3f
    800018b6:	8d59                	or	a0,a0,a4
    800018b8:	9782                	jalr	a5
}
    800018ba:	70a2                	ld	ra,40(sp)
    800018bc:	7402                	ld	s0,32(sp)
    800018be:	64e2                	ld	s1,24(sp)
    800018c0:	6145                	addi	sp,sp,48
    800018c2:	8082                	ret
      panic("exec");
    800018c4:	00006517          	auipc	a0,0x6
    800018c8:	8dc50513          	addi	a0,a0,-1828 # 800071a0 <digits+0x168>
    800018cc:	ebffe0ef          	jal	ra,8000078a <panic>

00000000800018d0 <allocpid>:
{
    800018d0:	1101                	addi	sp,sp,-32
    800018d2:	ec06                	sd	ra,24(sp)
    800018d4:	e822                	sd	s0,16(sp)
    800018d6:	e426                	sd	s1,8(sp)
    800018d8:	e04a                	sd	s2,0(sp)
    800018da:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018dc:	0000e917          	auipc	s2,0xe
    800018e0:	17c90913          	addi	s2,s2,380 # 8000fa58 <pid_lock>
    800018e4:	854a                	mv	a0,s2
    800018e6:	a86ff0ef          	jal	ra,80000b6c <acquire>
  pid = nextpid;
    800018ea:	00006797          	auipc	a5,0x6
    800018ee:	03a78793          	addi	a5,a5,58 # 80007924 <nextpid>
    800018f2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018f4:	0014871b          	addiw	a4,s1,1
    800018f8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018fa:	854a                	mv	a0,s2
    800018fc:	b08ff0ef          	jal	ra,80000c04 <release>
}
    80001900:	8526                	mv	a0,s1
    80001902:	60e2                	ld	ra,24(sp)
    80001904:	6442                	ld	s0,16(sp)
    80001906:	64a2                	ld	s1,8(sp)
    80001908:	6902                	ld	s2,0(sp)
    8000190a:	6105                	addi	sp,sp,32
    8000190c:	8082                	ret

000000008000190e <proc_pagetable>:
{
    8000190e:	1101                	addi	sp,sp,-32
    80001910:	ec06                	sd	ra,24(sp)
    80001912:	e822                	sd	s0,16(sp)
    80001914:	e426                	sd	s1,8(sp)
    80001916:	e04a                	sd	s2,0(sp)
    80001918:	1000                	addi	s0,sp,32
    8000191a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000191c:	81fff0ef          	jal	ra,8000113a <uvmcreate>
    80001920:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001922:	c929                	beqz	a0,80001974 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001924:	4729                	li	a4,10
    80001926:	00004697          	auipc	a3,0x4
    8000192a:	6da68693          	addi	a3,a3,1754 # 80006000 <_trampoline>
    8000192e:	6605                	lui	a2,0x1
    80001930:	040005b7          	lui	a1,0x4000
    80001934:	15fd                	addi	a1,a1,-1
    80001936:	05b2                	slli	a1,a1,0xc
    80001938:	e5cff0ef          	jal	ra,80000f94 <mappages>
    8000193c:	04054363          	bltz	a0,80001982 <proc_pagetable+0x74>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001940:	4719                	li	a4,6
    80001942:	05893683          	ld	a3,88(s2)
    80001946:	6605                	lui	a2,0x1
    80001948:	020005b7          	lui	a1,0x2000
    8000194c:	15fd                	addi	a1,a1,-1
    8000194e:	05b6                	slli	a1,a1,0xd
    80001950:	8526                	mv	a0,s1
    80001952:	e42ff0ef          	jal	ra,80000f94 <mappages>
    80001956:	02054c63          	bltz	a0,8000198e <proc_pagetable+0x80>
  if(mappages(pagetable,UGET,PGSIZE,(uint64)(p->ugetpgt),PTE_R | PTE_U)<0){
    8000195a:	4749                	li	a4,18
    8000195c:	17093683          	ld	a3,368(s2)
    80001960:	6605                	lui	a2,0x1
    80001962:	040005b7          	lui	a1,0x4000
    80001966:	15f5                	addi	a1,a1,-3
    80001968:	05b2                	slli	a1,a1,0xc
    8000196a:	8526                	mv	a0,s1
    8000196c:	e28ff0ef          	jal	ra,80000f94 <mappages>
    80001970:	02054e63          	bltz	a0,800019ac <proc_pagetable+0x9e>
}
    80001974:	8526                	mv	a0,s1
    80001976:	60e2                	ld	ra,24(sp)
    80001978:	6442                	ld	s0,16(sp)
    8000197a:	64a2                	ld	s1,8(sp)
    8000197c:	6902                	ld	s2,0(sp)
    8000197e:	6105                	addi	sp,sp,32
    80001980:	8082                	ret
    uvmfree(pagetable, 0);
    80001982:	4581                	li	a1,0
    80001984:	8526                	mv	a0,s1
    80001986:	993ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    8000198a:	4481                	li	s1,0
    8000198c:	b7e5                	j	80001974 <proc_pagetable+0x66>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000198e:	4681                	li	a3,0
    80001990:	4605                	li	a2,1
    80001992:	040005b7          	lui	a1,0x4000
    80001996:	15fd                	addi	a1,a1,-1
    80001998:	05b2                	slli	a1,a1,0xc
    8000199a:	8526                	mv	a0,s1
    8000199c:	fc4ff0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    800019a0:	4581                	li	a1,0
    800019a2:	8526                	mv	a0,s1
    800019a4:	975ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    800019a8:	4481                	li	s1,0
    800019aa:	b7e9                	j	80001974 <proc_pagetable+0x66>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ac:	4681                	li	a3,0
    800019ae:	4605                	li	a2,1
    800019b0:	040005b7          	lui	a1,0x4000
    800019b4:	15fd                	addi	a1,a1,-1
    800019b6:	05b2                	slli	a1,a1,0xc
    800019b8:	8526                	mv	a0,s1
    800019ba:	fa6ff0ef          	jal	ra,80001160 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800019be:	4681                	li	a3,0
    800019c0:	4605                	li	a2,1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	f94ff0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    800019d0:	4581                	li	a1,0
    800019d2:	8526                	mv	a0,s1
    800019d4:	945ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    800019d8:	4481                	li	s1,0
    800019da:	bf69                	j	80001974 <proc_pagetable+0x66>

00000000800019dc <proc_freepagetable>:
{
    800019dc:	7179                	addi	sp,sp,-48
    800019de:	f406                	sd	ra,40(sp)
    800019e0:	f022                	sd	s0,32(sp)
    800019e2:	ec26                	sd	s1,24(sp)
    800019e4:	e84a                	sd	s2,16(sp)
    800019e6:	e44e                	sd	s3,8(sp)
    800019e8:	1800                	addi	s0,sp,48
    800019ea:	84aa                	mv	s1,a0
    800019ec:	89ae                	mv	s3,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	04000937          	lui	s2,0x4000
    800019f6:	fff90593          	addi	a1,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019fa:	05b2                	slli	a1,a1,0xc
    800019fc:	f64ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a00:	4681                	li	a3,0
    80001a02:	4605                	li	a2,1
    80001a04:	020005b7          	lui	a1,0x2000
    80001a08:	15fd                	addi	a1,a1,-1
    80001a0a:	05b6                	slli	a1,a1,0xd
    80001a0c:	8526                	mv	a0,s1
    80001a0e:	f52ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable,UGET,1,0);
    80001a12:	4681                	li	a3,0
    80001a14:	4605                	li	a2,1
    80001a16:	1975                	addi	s2,s2,-3
    80001a18:	00c91593          	slli	a1,s2,0xc
    80001a1c:	8526                	mv	a0,s1
    80001a1e:	f42ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a22:	85ce                	mv	a1,s3
    80001a24:	8526                	mv	a0,s1
    80001a26:	8f3ff0ef          	jal	ra,80001318 <uvmfree>
}
    80001a2a:	70a2                	ld	ra,40(sp)
    80001a2c:	7402                	ld	s0,32(sp)
    80001a2e:	64e2                	ld	s1,24(sp)
    80001a30:	6942                	ld	s2,16(sp)
    80001a32:	69a2                	ld	s3,8(sp)
    80001a34:	6145                	addi	sp,sp,48
    80001a36:	8082                	ret

0000000080001a38 <freeproc>:
{
    80001a38:	1101                	addi	sp,sp,-32
    80001a3a:	ec06                	sd	ra,24(sp)
    80001a3c:	e822                	sd	s0,16(sp)
    80001a3e:	e426                	sd	s1,8(sp)
    80001a40:	1000                	addi	s0,sp,32
    80001a42:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a44:	6d28                	ld	a0,88(a0)
    80001a46:	c119                	beqz	a0,80001a4c <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a48:	f75fe0ef          	jal	ra,800009bc <kfree>
  p->trapframe = 0;
    80001a4c:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a50:	68a8                	ld	a0,80(s1)
    80001a52:	c501                	beqz	a0,80001a5a <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a54:	64ac                	ld	a1,72(s1)
    80001a56:	f87ff0ef          	jal	ra,800019dc <proc_freepagetable>
  p->pagetable = 0;
    80001a5a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a5e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a62:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a66:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a6a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a6e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a72:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a76:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a7a:	0004ac23          	sw	zero,24(s1)
  if(p->ugetpgt){
    80001a7e:	1704b503          	ld	a0,368(s1)
    80001a82:	c509                	beqz	a0,80001a8c <freeproc+0x54>
    kfree((void*)p->ugetpgt);
    80001a84:	f39fe0ef          	jal	ra,800009bc <kfree>
    p->ugetpgt=0;
    80001a88:	1604b823          	sd	zero,368(s1)
}
    80001a8c:	60e2                	ld	ra,24(sp)
    80001a8e:	6442                	ld	s0,16(sp)
    80001a90:	64a2                	ld	s1,8(sp)
    80001a92:	6105                	addi	sp,sp,32
    80001a94:	8082                	ret

0000000080001a96 <allocproc>:
{
    80001a96:	1101                	addi	sp,sp,-32
    80001a98:	ec06                	sd	ra,24(sp)
    80001a9a:	e822                	sd	s0,16(sp)
    80001a9c:	e426                	sd	s1,8(sp)
    80001a9e:	e04a                	sd	s2,0(sp)
    80001aa0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aa2:	0000e497          	auipc	s1,0xe
    80001aa6:	3e648493          	addi	s1,s1,998 # 8000fe88 <proc>
    80001aaa:	00014917          	auipc	s2,0x14
    80001aae:	1de90913          	addi	s2,s2,478 # 80015c88 <tickslock>
    acquire(&p->lock);
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	8b8ff0ef          	jal	ra,80000b6c <acquire>
    if(p->state == UNUSED) {
    80001ab8:	4c9c                	lw	a5,24(s1)
    80001aba:	cb91                	beqz	a5,80001ace <allocproc+0x38>
      release(&p->lock);
    80001abc:	8526                	mv	a0,s1
    80001abe:	946ff0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ac2:	17848493          	addi	s1,s1,376
    80001ac6:	ff2496e3          	bne	s1,s2,80001ab2 <allocproc+0x1c>
  return 0;
    80001aca:	4481                	li	s1,0
    80001acc:	a8b9                	j	80001b2a <allocproc+0x94>
  p->pid = allocpid();
    80001ace:	e03ff0ef          	jal	ra,800018d0 <allocpid>
    80001ad2:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ad4:	4785                	li	a5,1
    80001ad6:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ad8:	fc5fe0ef          	jal	ra,80000a9c <kalloc>
    80001adc:	892a                	mv	s2,a0
    80001ade:	eca8                	sd	a0,88(s1)
    80001ae0:	cd21                	beqz	a0,80001b38 <allocproc+0xa2>
  if((p->ugetpgt = (uint64* )kalloc())==0){
    80001ae2:	fbbfe0ef          	jal	ra,80000a9c <kalloc>
    80001ae6:	892a                	mv	s2,a0
    80001ae8:	16a4b823          	sd	a0,368(s1)
    80001aec:	cd31                	beqz	a0,80001b48 <allocproc+0xb2>
  memset(p->ugetpgt,0,PGSIZE);
    80001aee:	6605                	lui	a2,0x1
    80001af0:	4581                	li	a1,0
    80001af2:	94eff0ef          	jal	ra,80000c40 <memset>
  *(p->ugetpgt)=p->pid;
    80001af6:	1704b783          	ld	a5,368(s1)
    80001afa:	5898                	lw	a4,48(s1)
    80001afc:	e398                	sd	a4,0(a5)
  p->pagetable = proc_pagetable(p);
    80001afe:	8526                	mv	a0,s1
    80001b00:	e0fff0ef          	jal	ra,8000190e <proc_pagetable>
    80001b04:	892a                	mv	s2,a0
    80001b06:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b08:	c921                	beqz	a0,80001b58 <allocproc+0xc2>
  memset(&p->context, 0, sizeof(p->context));
    80001b0a:	07000613          	li	a2,112
    80001b0e:	4581                	li	a1,0
    80001b10:	06048513          	addi	a0,s1,96
    80001b14:	92cff0ef          	jal	ra,80000c40 <memset>
  p->context.ra = (uint64)forkret;
    80001b18:	00000797          	auipc	a5,0x0
    80001b1c:	d2078793          	addi	a5,a5,-736 # 80001838 <forkret>
    80001b20:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b22:	60bc                	ld	a5,64(s1)
    80001b24:	6705                	lui	a4,0x1
    80001b26:	97ba                	add	a5,a5,a4
    80001b28:	f4bc                	sd	a5,104(s1)
}
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	60e2                	ld	ra,24(sp)
    80001b2e:	6442                	ld	s0,16(sp)
    80001b30:	64a2                	ld	s1,8(sp)
    80001b32:	6902                	ld	s2,0(sp)
    80001b34:	6105                	addi	sp,sp,32
    80001b36:	8082                	ret
    freeproc(p);
    80001b38:	8526                	mv	a0,s1
    80001b3a:	effff0ef          	jal	ra,80001a38 <freeproc>
    release(&p->lock);
    80001b3e:	8526                	mv	a0,s1
    80001b40:	8c4ff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001b44:	84ca                	mv	s1,s2
    80001b46:	b7d5                	j	80001b2a <allocproc+0x94>
    freeproc(p);
    80001b48:	8526                	mv	a0,s1
    80001b4a:	eefff0ef          	jal	ra,80001a38 <freeproc>
    release(&p->lock);
    80001b4e:	8526                	mv	a0,s1
    80001b50:	8b4ff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001b54:	84ca                	mv	s1,s2
    80001b56:	bfd1                	j	80001b2a <allocproc+0x94>
    freeproc(p);
    80001b58:	8526                	mv	a0,s1
    80001b5a:	edfff0ef          	jal	ra,80001a38 <freeproc>
    release(&p->lock);
    80001b5e:	8526                	mv	a0,s1
    80001b60:	8a4ff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001b64:	84ca                	mv	s1,s2
    80001b66:	b7d1                	j	80001b2a <allocproc+0x94>

0000000080001b68 <userinit>:
{
    80001b68:	1101                	addi	sp,sp,-32
    80001b6a:	ec06                	sd	ra,24(sp)
    80001b6c:	e822                	sd	s0,16(sp)
    80001b6e:	e426                	sd	s1,8(sp)
    80001b70:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b72:	f25ff0ef          	jal	ra,80001a96 <allocproc>
    80001b76:	84aa                	mv	s1,a0
  initproc = p;
    80001b78:	00006797          	auipc	a5,0x6
    80001b7c:	dca7bc23          	sd	a0,-552(a5) # 80007950 <initproc>
  p->cwd = namei("/");
    80001b80:	00005517          	auipc	a0,0x5
    80001b84:	62850513          	addi	a0,a0,1576 # 800071a8 <digits+0x170>
    80001b88:	0be020ef          	jal	ra,80003c46 <namei>
    80001b8c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b90:	478d                	li	a5,3
    80001b92:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b94:	8526                	mv	a0,s1
    80001b96:	86eff0ef          	jal	ra,80000c04 <release>
}
    80001b9a:	60e2                	ld	ra,24(sp)
    80001b9c:	6442                	ld	s0,16(sp)
    80001b9e:	64a2                	ld	s1,8(sp)
    80001ba0:	6105                	addi	sp,sp,32
    80001ba2:	8082                	ret

0000000080001ba4 <growproc>:
{
    80001ba4:	1101                	addi	sp,sp,-32
    80001ba6:	ec06                	sd	ra,24(sp)
    80001ba8:	e822                	sd	s0,16(sp)
    80001baa:	e426                	sd	s1,8(sp)
    80001bac:	e04a                	sd	s2,0(sp)
    80001bae:	1000                	addi	s0,sp,32
    80001bb0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bb2:	c57ff0ef          	jal	ra,80001808 <myproc>
    80001bb6:	892a                	mv	s2,a0
  sz = p->sz;
    80001bb8:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bba:	02905963          	blez	s1,80001bec <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001bbe:	00b48633          	add	a2,s1,a1
    80001bc2:	020007b7          	lui	a5,0x2000
    80001bc6:	17fd                	addi	a5,a5,-1
    80001bc8:	07b6                	slli	a5,a5,0xd
    80001bca:	02c7ea63          	bltu	a5,a2,80001bfe <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bce:	4691                	li	a3,4
    80001bd0:	6928                	ld	a0,80(a0)
    80001bd2:	e4eff0ef          	jal	ra,80001220 <uvmalloc>
    80001bd6:	85aa                	mv	a1,a0
    80001bd8:	c50d                	beqz	a0,80001c02 <growproc+0x5e>
  p->sz = sz;
    80001bda:	04b93423          	sd	a1,72(s2)
  return 0;
    80001bde:	4501                	li	a0,0
}
    80001be0:	60e2                	ld	ra,24(sp)
    80001be2:	6442                	ld	s0,16(sp)
    80001be4:	64a2                	ld	s1,8(sp)
    80001be6:	6902                	ld	s2,0(sp)
    80001be8:	6105                	addi	sp,sp,32
    80001bea:	8082                	ret
  } else if(n < 0){
    80001bec:	fe04d7e3          	bgez	s1,80001bda <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf0:	00b48633          	add	a2,s1,a1
    80001bf4:	6928                	ld	a0,80(a0)
    80001bf6:	de6ff0ef          	jal	ra,800011dc <uvmdealloc>
    80001bfa:	85aa                	mv	a1,a0
    80001bfc:	bff9                	j	80001bda <growproc+0x36>
      return -1;
    80001bfe:	557d                	li	a0,-1
    80001c00:	b7c5                	j	80001be0 <growproc+0x3c>
      return -1;
    80001c02:	557d                	li	a0,-1
    80001c04:	bff1                	j	80001be0 <growproc+0x3c>

0000000080001c06 <kfork>:
{
    80001c06:	7139                	addi	sp,sp,-64
    80001c08:	fc06                	sd	ra,56(sp)
    80001c0a:	f822                	sd	s0,48(sp)
    80001c0c:	f426                	sd	s1,40(sp)
    80001c0e:	f04a                	sd	s2,32(sp)
    80001c10:	ec4e                	sd	s3,24(sp)
    80001c12:	e852                	sd	s4,16(sp)
    80001c14:	e456                	sd	s5,8(sp)
    80001c16:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c18:	bf1ff0ef          	jal	ra,80001808 <myproc>
    80001c1c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c1e:	e79ff0ef          	jal	ra,80001a96 <allocproc>
    80001c22:	0e050663          	beqz	a0,80001d0e <kfork+0x108>
    80001c26:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c28:	048ab603          	ld	a2,72(s5)
    80001c2c:	692c                	ld	a1,80(a0)
    80001c2e:	050ab503          	ld	a0,80(s5)
    80001c32:	f16ff0ef          	jal	ra,80001348 <uvmcopy>
    80001c36:	04054863          	bltz	a0,80001c86 <kfork+0x80>
  np->sz = p->sz;
    80001c3a:	048ab783          	ld	a5,72(s5)
    80001c3e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c42:	058ab683          	ld	a3,88(s5)
    80001c46:	87b6                	mv	a5,a3
    80001c48:	058a3703          	ld	a4,88(s4)
    80001c4c:	12068693          	addi	a3,a3,288
    80001c50:	0007b803          	ld	a6,0(a5) # 2000000 <_entry-0x7e000000>
    80001c54:	6788                	ld	a0,8(a5)
    80001c56:	6b8c                	ld	a1,16(a5)
    80001c58:	6f90                	ld	a2,24(a5)
    80001c5a:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c5e:	e708                	sd	a0,8(a4)
    80001c60:	eb0c                	sd	a1,16(a4)
    80001c62:	ef10                	sd	a2,24(a4)
    80001c64:	02078793          	addi	a5,a5,32
    80001c68:	02070713          	addi	a4,a4,32
    80001c6c:	fed792e3          	bne	a5,a3,80001c50 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001c70:	058a3783          	ld	a5,88(s4)
    80001c74:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c78:	0d0a8493          	addi	s1,s5,208
    80001c7c:	0d0a0913          	addi	s2,s4,208
    80001c80:	150a8993          	addi	s3,s5,336
    80001c84:	a829                	j	80001c9e <kfork+0x98>
    freeproc(np);
    80001c86:	8552                	mv	a0,s4
    80001c88:	db1ff0ef          	jal	ra,80001a38 <freeproc>
    release(&np->lock);
    80001c8c:	8552                	mv	a0,s4
    80001c8e:	f77fe0ef          	jal	ra,80000c04 <release>
    return -1;
    80001c92:	597d                	li	s2,-1
    80001c94:	a09d                	j	80001cfa <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001c96:	04a1                	addi	s1,s1,8
    80001c98:	0921                	addi	s2,s2,8
    80001c9a:	01348963          	beq	s1,s3,80001cac <kfork+0xa6>
    if(p->ofile[i])
    80001c9e:	6088                	ld	a0,0(s1)
    80001ca0:	d97d                	beqz	a0,80001c96 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ca2:	55c020ef          	jal	ra,800041fe <filedup>
    80001ca6:	00a93023          	sd	a0,0(s2)
    80001caa:	b7f5                	j	80001c96 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001cac:	150ab503          	ld	a0,336(s5)
    80001cb0:	772010ef          	jal	ra,80003422 <idup>
    80001cb4:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cb8:	4641                	li	a2,16
    80001cba:	158a8593          	addi	a1,s5,344
    80001cbe:	158a0513          	addi	a0,s4,344
    80001cc2:	8c4ff0ef          	jal	ra,80000d86 <safestrcpy>
  pid = np->pid;
    80001cc6:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cca:	8552                	mv	a0,s4
    80001ccc:	f39fe0ef          	jal	ra,80000c04 <release>
  acquire(&wait_lock);
    80001cd0:	0000e497          	auipc	s1,0xe
    80001cd4:	da048493          	addi	s1,s1,-608 # 8000fa70 <wait_lock>
    80001cd8:	8526                	mv	a0,s1
    80001cda:	e93fe0ef          	jal	ra,80000b6c <acquire>
  np->parent = p;
    80001cde:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	f21fe0ef          	jal	ra,80000c04 <release>
  acquire(&np->lock);
    80001ce8:	8552                	mv	a0,s4
    80001cea:	e83fe0ef          	jal	ra,80000b6c <acquire>
  np->state = RUNNABLE;
    80001cee:	478d                	li	a5,3
    80001cf0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cf4:	8552                	mv	a0,s4
    80001cf6:	f0ffe0ef          	jal	ra,80000c04 <release>
}
    80001cfa:	854a                	mv	a0,s2
    80001cfc:	70e2                	ld	ra,56(sp)
    80001cfe:	7442                	ld	s0,48(sp)
    80001d00:	74a2                	ld	s1,40(sp)
    80001d02:	7902                	ld	s2,32(sp)
    80001d04:	69e2                	ld	s3,24(sp)
    80001d06:	6a42                	ld	s4,16(sp)
    80001d08:	6aa2                	ld	s5,8(sp)
    80001d0a:	6121                	addi	sp,sp,64
    80001d0c:	8082                	ret
    return -1;
    80001d0e:	597d                	li	s2,-1
    80001d10:	b7ed                	j	80001cfa <kfork+0xf4>

0000000080001d12 <scheduler>:
{
    80001d12:	715d                	addi	sp,sp,-80
    80001d14:	e486                	sd	ra,72(sp)
    80001d16:	e0a2                	sd	s0,64(sp)
    80001d18:	fc26                	sd	s1,56(sp)
    80001d1a:	f84a                	sd	s2,48(sp)
    80001d1c:	f44e                	sd	s3,40(sp)
    80001d1e:	f052                	sd	s4,32(sp)
    80001d20:	ec56                	sd	s5,24(sp)
    80001d22:	e85a                	sd	s6,16(sp)
    80001d24:	e45e                	sd	s7,8(sp)
    80001d26:	e062                	sd	s8,0(sp)
    80001d28:	0880                	addi	s0,sp,80
    80001d2a:	8792                	mv	a5,tp
  int id = r_tp();
    80001d2c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d2e:	00779b13          	slli	s6,a5,0x7
    80001d32:	0000e717          	auipc	a4,0xe
    80001d36:	d2670713          	addi	a4,a4,-730 # 8000fa58 <pid_lock>
    80001d3a:	975a                	add	a4,a4,s6
    80001d3c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d40:	0000e717          	auipc	a4,0xe
    80001d44:	d5070713          	addi	a4,a4,-688 # 8000fa90 <cpus+0x8>
    80001d48:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d4a:	4c11                	li	s8,4
        c->proc = p;
    80001d4c:	079e                	slli	a5,a5,0x7
    80001d4e:	0000ea17          	auipc	s4,0xe
    80001d52:	d0aa0a13          	addi	s4,s4,-758 # 8000fa58 <pid_lock>
    80001d56:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d58:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d5a:	00014997          	auipc	s3,0x14
    80001d5e:	f2e98993          	addi	s3,s3,-210 # 80015c88 <tickslock>
    80001d62:	a83d                	j	80001da0 <scheduler+0x8e>
      release(&p->lock);
    80001d64:	8526                	mv	a0,s1
    80001d66:	e9ffe0ef          	jal	ra,80000c04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d6a:	17848493          	addi	s1,s1,376
    80001d6e:	03348563          	beq	s1,s3,80001d98 <scheduler+0x86>
      acquire(&p->lock);
    80001d72:	8526                	mv	a0,s1
    80001d74:	df9fe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == RUNNABLE) {
    80001d78:	4c9c                	lw	a5,24(s1)
    80001d7a:	ff2795e3          	bne	a5,s2,80001d64 <scheduler+0x52>
        p->state = RUNNING;
    80001d7e:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d82:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d86:	06048593          	addi	a1,s1,96
    80001d8a:	855a                	mv	a0,s6
    80001d8c:	5b0000ef          	jal	ra,8000233c <swtch>
        c->proc = 0;
    80001d90:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d94:	8ade                	mv	s5,s7
    80001d96:	b7f9                	j	80001d64 <scheduler+0x52>
    if(found == 0) {
    80001d98:	000a9463          	bnez	s5,80001da0 <scheduler+0x8e>
      asm volatile("wfi");
    80001d9c:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001da0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001da8:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001db0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001db2:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001db6:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001db8:	0000e497          	auipc	s1,0xe
    80001dbc:	0d048493          	addi	s1,s1,208 # 8000fe88 <proc>
      if(p->state == RUNNABLE) {
    80001dc0:	490d                	li	s2,3
    80001dc2:	bf45                	j	80001d72 <scheduler+0x60>

0000000080001dc4 <sched>:
{
    80001dc4:	7179                	addi	sp,sp,-48
    80001dc6:	f406                	sd	ra,40(sp)
    80001dc8:	f022                	sd	s0,32(sp)
    80001dca:	ec26                	sd	s1,24(sp)
    80001dcc:	e84a                	sd	s2,16(sp)
    80001dce:	e44e                	sd	s3,8(sp)
    80001dd0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd2:	a37ff0ef          	jal	ra,80001808 <myproc>
    80001dd6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001dd8:	d2bfe0ef          	jal	ra,80000b02 <holding>
    80001ddc:	c92d                	beqz	a0,80001e4e <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dde:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001de0:	2781                	sext.w	a5,a5
    80001de2:	079e                	slli	a5,a5,0x7
    80001de4:	0000e717          	auipc	a4,0xe
    80001de8:	c7470713          	addi	a4,a4,-908 # 8000fa58 <pid_lock>
    80001dec:	97ba                	add	a5,a5,a4
    80001dee:	0a87a703          	lw	a4,168(a5)
    80001df2:	4785                	li	a5,1
    80001df4:	06f71363          	bne	a4,a5,80001e5a <sched+0x96>
  if(p->state == RUNNING)
    80001df8:	4c98                	lw	a4,24(s1)
    80001dfa:	4791                	li	a5,4
    80001dfc:	06f70563          	beq	a4,a5,80001e66 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e00:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e04:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e06:	e7b5                	bnez	a5,80001e72 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e08:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e0a:	0000e917          	auipc	s2,0xe
    80001e0e:	c4e90913          	addi	s2,s2,-946 # 8000fa58 <pid_lock>
    80001e12:	2781                	sext.w	a5,a5
    80001e14:	079e                	slli	a5,a5,0x7
    80001e16:	97ca                	add	a5,a5,s2
    80001e18:	0ac7a983          	lw	s3,172(a5)
    80001e1c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e1e:	2781                	sext.w	a5,a5
    80001e20:	079e                	slli	a5,a5,0x7
    80001e22:	0000e597          	auipc	a1,0xe
    80001e26:	c6e58593          	addi	a1,a1,-914 # 8000fa90 <cpus+0x8>
    80001e2a:	95be                	add	a1,a1,a5
    80001e2c:	06048513          	addi	a0,s1,96
    80001e30:	50c000ef          	jal	ra,8000233c <swtch>
    80001e34:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e36:	2781                	sext.w	a5,a5
    80001e38:	079e                	slli	a5,a5,0x7
    80001e3a:	97ca                	add	a5,a5,s2
    80001e3c:	0b37a623          	sw	s3,172(a5)
}
    80001e40:	70a2                	ld	ra,40(sp)
    80001e42:	7402                	ld	s0,32(sp)
    80001e44:	64e2                	ld	s1,24(sp)
    80001e46:	6942                	ld	s2,16(sp)
    80001e48:	69a2                	ld	s3,8(sp)
    80001e4a:	6145                	addi	sp,sp,48
    80001e4c:	8082                	ret
    panic("sched p->lock");
    80001e4e:	00005517          	auipc	a0,0x5
    80001e52:	36250513          	addi	a0,a0,866 # 800071b0 <digits+0x178>
    80001e56:	935fe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    80001e5a:	00005517          	auipc	a0,0x5
    80001e5e:	36650513          	addi	a0,a0,870 # 800071c0 <digits+0x188>
    80001e62:	929fe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    80001e66:	00005517          	auipc	a0,0x5
    80001e6a:	36a50513          	addi	a0,a0,874 # 800071d0 <digits+0x198>
    80001e6e:	91dfe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    80001e72:	00005517          	auipc	a0,0x5
    80001e76:	36e50513          	addi	a0,a0,878 # 800071e0 <digits+0x1a8>
    80001e7a:	911fe0ef          	jal	ra,8000078a <panic>

0000000080001e7e <yield>:
{
    80001e7e:	1101                	addi	sp,sp,-32
    80001e80:	ec06                	sd	ra,24(sp)
    80001e82:	e822                	sd	s0,16(sp)
    80001e84:	e426                	sd	s1,8(sp)
    80001e86:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e88:	981ff0ef          	jal	ra,80001808 <myproc>
    80001e8c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e8e:	cdffe0ef          	jal	ra,80000b6c <acquire>
  p->state = RUNNABLE;
    80001e92:	478d                	li	a5,3
    80001e94:	cc9c                	sw	a5,24(s1)
  sched();
    80001e96:	f2fff0ef          	jal	ra,80001dc4 <sched>
  release(&p->lock);
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	d69fe0ef          	jal	ra,80000c04 <release>
}
    80001ea0:	60e2                	ld	ra,24(sp)
    80001ea2:	6442                	ld	s0,16(sp)
    80001ea4:	64a2                	ld	s1,8(sp)
    80001ea6:	6105                	addi	sp,sp,32
    80001ea8:	8082                	ret

0000000080001eaa <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eaa:	7179                	addi	sp,sp,-48
    80001eac:	f406                	sd	ra,40(sp)
    80001eae:	f022                	sd	s0,32(sp)
    80001eb0:	ec26                	sd	s1,24(sp)
    80001eb2:	e84a                	sd	s2,16(sp)
    80001eb4:	e44e                	sd	s3,8(sp)
    80001eb6:	1800                	addi	s0,sp,48
    80001eb8:	89aa                	mv	s3,a0
    80001eba:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ebc:	94dff0ef          	jal	ra,80001808 <myproc>
    80001ec0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ec2:	cabfe0ef          	jal	ra,80000b6c <acquire>
  release(lk);
    80001ec6:	854a                	mv	a0,s2
    80001ec8:	d3dfe0ef          	jal	ra,80000c04 <release>

  // Go to sleep.
  p->chan = chan;
    80001ecc:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ed0:	4789                	li	a5,2
    80001ed2:	cc9c                	sw	a5,24(s1)

  sched();
    80001ed4:	ef1ff0ef          	jal	ra,80001dc4 <sched>

  // Tidy up.
  p->chan = 0;
    80001ed8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001edc:	8526                	mv	a0,s1
    80001ede:	d27fe0ef          	jal	ra,80000c04 <release>
  acquire(lk);
    80001ee2:	854a                	mv	a0,s2
    80001ee4:	c89fe0ef          	jal	ra,80000b6c <acquire>
}
    80001ee8:	70a2                	ld	ra,40(sp)
    80001eea:	7402                	ld	s0,32(sp)
    80001eec:	64e2                	ld	s1,24(sp)
    80001eee:	6942                	ld	s2,16(sp)
    80001ef0:	69a2                	ld	s3,8(sp)
    80001ef2:	6145                	addi	sp,sp,48
    80001ef4:	8082                	ret

0000000080001ef6 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001ef6:	7139                	addi	sp,sp,-64
    80001ef8:	fc06                	sd	ra,56(sp)
    80001efa:	f822                	sd	s0,48(sp)
    80001efc:	f426                	sd	s1,40(sp)
    80001efe:	f04a                	sd	s2,32(sp)
    80001f00:	ec4e                	sd	s3,24(sp)
    80001f02:	e852                	sd	s4,16(sp)
    80001f04:	e456                	sd	s5,8(sp)
    80001f06:	0080                	addi	s0,sp,64
    80001f08:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f0a:	0000e497          	auipc	s1,0xe
    80001f0e:	f7e48493          	addi	s1,s1,-130 # 8000fe88 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f12:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f14:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f16:	00014917          	auipc	s2,0x14
    80001f1a:	d7290913          	addi	s2,s2,-654 # 80015c88 <tickslock>
    80001f1e:	a801                	j	80001f2e <wakeup+0x38>
      }
      release(&p->lock);
    80001f20:	8526                	mv	a0,s1
    80001f22:	ce3fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f26:	17848493          	addi	s1,s1,376
    80001f2a:	03248263          	beq	s1,s2,80001f4e <wakeup+0x58>
    if(p != myproc()){
    80001f2e:	8dbff0ef          	jal	ra,80001808 <myproc>
    80001f32:	fea48ae3          	beq	s1,a0,80001f26 <wakeup+0x30>
      acquire(&p->lock);
    80001f36:	8526                	mv	a0,s1
    80001f38:	c35fe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f3c:	4c9c                	lw	a5,24(s1)
    80001f3e:	ff3791e3          	bne	a5,s3,80001f20 <wakeup+0x2a>
    80001f42:	709c                	ld	a5,32(s1)
    80001f44:	fd479ee3          	bne	a5,s4,80001f20 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f48:	0154ac23          	sw	s5,24(s1)
    80001f4c:	bfd1                	j	80001f20 <wakeup+0x2a>
    }
  }
}
    80001f4e:	70e2                	ld	ra,56(sp)
    80001f50:	7442                	ld	s0,48(sp)
    80001f52:	74a2                	ld	s1,40(sp)
    80001f54:	7902                	ld	s2,32(sp)
    80001f56:	69e2                	ld	s3,24(sp)
    80001f58:	6a42                	ld	s4,16(sp)
    80001f5a:	6aa2                	ld	s5,8(sp)
    80001f5c:	6121                	addi	sp,sp,64
    80001f5e:	8082                	ret

0000000080001f60 <reparent>:
{
    80001f60:	7179                	addi	sp,sp,-48
    80001f62:	f406                	sd	ra,40(sp)
    80001f64:	f022                	sd	s0,32(sp)
    80001f66:	ec26                	sd	s1,24(sp)
    80001f68:	e84a                	sd	s2,16(sp)
    80001f6a:	e44e                	sd	s3,8(sp)
    80001f6c:	e052                	sd	s4,0(sp)
    80001f6e:	1800                	addi	s0,sp,48
    80001f70:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f72:	0000e497          	auipc	s1,0xe
    80001f76:	f1648493          	addi	s1,s1,-234 # 8000fe88 <proc>
      pp->parent = initproc;
    80001f7a:	00006a17          	auipc	s4,0x6
    80001f7e:	9d6a0a13          	addi	s4,s4,-1578 # 80007950 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f82:	00014997          	auipc	s3,0x14
    80001f86:	d0698993          	addi	s3,s3,-762 # 80015c88 <tickslock>
    80001f8a:	a029                	j	80001f94 <reparent+0x34>
    80001f8c:	17848493          	addi	s1,s1,376
    80001f90:	01348b63          	beq	s1,s3,80001fa6 <reparent+0x46>
    if(pp->parent == p){
    80001f94:	7c9c                	ld	a5,56(s1)
    80001f96:	ff279be3          	bne	a5,s2,80001f8c <reparent+0x2c>
      pp->parent = initproc;
    80001f9a:	000a3503          	ld	a0,0(s4)
    80001f9e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fa0:	f57ff0ef          	jal	ra,80001ef6 <wakeup>
    80001fa4:	b7e5                	j	80001f8c <reparent+0x2c>
}
    80001fa6:	70a2                	ld	ra,40(sp)
    80001fa8:	7402                	ld	s0,32(sp)
    80001faa:	64e2                	ld	s1,24(sp)
    80001fac:	6942                	ld	s2,16(sp)
    80001fae:	69a2                	ld	s3,8(sp)
    80001fb0:	6a02                	ld	s4,0(sp)
    80001fb2:	6145                	addi	sp,sp,48
    80001fb4:	8082                	ret

0000000080001fb6 <kexit>:
{
    80001fb6:	7179                	addi	sp,sp,-48
    80001fb8:	f406                	sd	ra,40(sp)
    80001fba:	f022                	sd	s0,32(sp)
    80001fbc:	ec26                	sd	s1,24(sp)
    80001fbe:	e84a                	sd	s2,16(sp)
    80001fc0:	e44e                	sd	s3,8(sp)
    80001fc2:	e052                	sd	s4,0(sp)
    80001fc4:	1800                	addi	s0,sp,48
    80001fc6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fc8:	841ff0ef          	jal	ra,80001808 <myproc>
    80001fcc:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fce:	00006797          	auipc	a5,0x6
    80001fd2:	9827b783          	ld	a5,-1662(a5) # 80007950 <initproc>
    80001fd6:	0d050493          	addi	s1,a0,208
    80001fda:	15050913          	addi	s2,a0,336
    80001fde:	00a79f63          	bne	a5,a0,80001ffc <kexit+0x46>
    panic("init exiting");
    80001fe2:	00005517          	auipc	a0,0x5
    80001fe6:	21650513          	addi	a0,a0,534 # 800071f8 <digits+0x1c0>
    80001fea:	fa0fe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    80001fee:	256020ef          	jal	ra,80004244 <fileclose>
      p->ofile[fd] = 0;
    80001ff2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001ff6:	04a1                	addi	s1,s1,8
    80001ff8:	01248563          	beq	s1,s2,80002002 <kexit+0x4c>
    if(p->ofile[fd]){
    80001ffc:	6088                	ld	a0,0(s1)
    80001ffe:	f965                	bnez	a0,80001fee <kexit+0x38>
    80002000:	bfdd                	j	80001ff6 <kexit+0x40>
  begin_op();
    80002002:	635010ef          	jal	ra,80003e36 <begin_op>
  iput(p->cwd);
    80002006:	1509b503          	ld	a0,336(s3)
    8000200a:	5cc010ef          	jal	ra,800035d6 <iput>
  end_op();
    8000200e:	699010ef          	jal	ra,80003ea6 <end_op>
  p->cwd = 0;
    80002012:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002016:	0000e497          	auipc	s1,0xe
    8000201a:	a5a48493          	addi	s1,s1,-1446 # 8000fa70 <wait_lock>
    8000201e:	8526                	mv	a0,s1
    80002020:	b4dfe0ef          	jal	ra,80000b6c <acquire>
  reparent(p);
    80002024:	854e                	mv	a0,s3
    80002026:	f3bff0ef          	jal	ra,80001f60 <reparent>
  wakeup(p->parent);
    8000202a:	0389b503          	ld	a0,56(s3)
    8000202e:	ec9ff0ef          	jal	ra,80001ef6 <wakeup>
  acquire(&p->lock);
    80002032:	854e                	mv	a0,s3
    80002034:	b39fe0ef          	jal	ra,80000b6c <acquire>
  p->xstate = status;
    80002038:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000203c:	4795                	li	a5,5
    8000203e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002042:	8526                	mv	a0,s1
    80002044:	bc1fe0ef          	jal	ra,80000c04 <release>
  sched();
    80002048:	d7dff0ef          	jal	ra,80001dc4 <sched>
  panic("zombie exit");
    8000204c:	00005517          	auipc	a0,0x5
    80002050:	1bc50513          	addi	a0,a0,444 # 80007208 <digits+0x1d0>
    80002054:	f36fe0ef          	jal	ra,8000078a <panic>

0000000080002058 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002058:	7179                	addi	sp,sp,-48
    8000205a:	f406                	sd	ra,40(sp)
    8000205c:	f022                	sd	s0,32(sp)
    8000205e:	ec26                	sd	s1,24(sp)
    80002060:	e84a                	sd	s2,16(sp)
    80002062:	e44e                	sd	s3,8(sp)
    80002064:	1800                	addi	s0,sp,48
    80002066:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002068:	0000e497          	auipc	s1,0xe
    8000206c:	e2048493          	addi	s1,s1,-480 # 8000fe88 <proc>
    80002070:	00014997          	auipc	s3,0x14
    80002074:	c1898993          	addi	s3,s3,-1000 # 80015c88 <tickslock>
    acquire(&p->lock);
    80002078:	8526                	mv	a0,s1
    8000207a:	af3fe0ef          	jal	ra,80000b6c <acquire>
    if(p->pid == pid){
    8000207e:	589c                	lw	a5,48(s1)
    80002080:	01278b63          	beq	a5,s2,80002096 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002084:	8526                	mv	a0,s1
    80002086:	b7ffe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000208a:	17848493          	addi	s1,s1,376
    8000208e:	ff3495e3          	bne	s1,s3,80002078 <kkill+0x20>
  }
  return -1;
    80002092:	557d                	li	a0,-1
    80002094:	a819                	j	800020aa <kkill+0x52>
      p->killed = 1;
    80002096:	4785                	li	a5,1
    80002098:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000209a:	4c98                	lw	a4,24(s1)
    8000209c:	4789                	li	a5,2
    8000209e:	00f70d63          	beq	a4,a5,800020b8 <kkill+0x60>
      release(&p->lock);
    800020a2:	8526                	mv	a0,s1
    800020a4:	b61fe0ef          	jal	ra,80000c04 <release>
      return 0;
    800020a8:	4501                	li	a0,0
}
    800020aa:	70a2                	ld	ra,40(sp)
    800020ac:	7402                	ld	s0,32(sp)
    800020ae:	64e2                	ld	s1,24(sp)
    800020b0:	6942                	ld	s2,16(sp)
    800020b2:	69a2                	ld	s3,8(sp)
    800020b4:	6145                	addi	sp,sp,48
    800020b6:	8082                	ret
        p->state = RUNNABLE;
    800020b8:	478d                	li	a5,3
    800020ba:	cc9c                	sw	a5,24(s1)
    800020bc:	b7dd                	j	800020a2 <kkill+0x4a>

00000000800020be <setkilled>:

void
setkilled(struct proc *p)
{
    800020be:	1101                	addi	sp,sp,-32
    800020c0:	ec06                	sd	ra,24(sp)
    800020c2:	e822                	sd	s0,16(sp)
    800020c4:	e426                	sd	s1,8(sp)
    800020c6:	1000                	addi	s0,sp,32
    800020c8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ca:	aa3fe0ef          	jal	ra,80000b6c <acquire>
  p->killed = 1;
    800020ce:	4785                	li	a5,1
    800020d0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020d2:	8526                	mv	a0,s1
    800020d4:	b31fe0ef          	jal	ra,80000c04 <release>
}
    800020d8:	60e2                	ld	ra,24(sp)
    800020da:	6442                	ld	s0,16(sp)
    800020dc:	64a2                	ld	s1,8(sp)
    800020de:	6105                	addi	sp,sp,32
    800020e0:	8082                	ret

00000000800020e2 <killed>:

int
killed(struct proc *p)
{
    800020e2:	1101                	addi	sp,sp,-32
    800020e4:	ec06                	sd	ra,24(sp)
    800020e6:	e822                	sd	s0,16(sp)
    800020e8:	e426                	sd	s1,8(sp)
    800020ea:	e04a                	sd	s2,0(sp)
    800020ec:	1000                	addi	s0,sp,32
    800020ee:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020f0:	a7dfe0ef          	jal	ra,80000b6c <acquire>
  k = p->killed;
    800020f4:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800020f8:	8526                	mv	a0,s1
    800020fa:	b0bfe0ef          	jal	ra,80000c04 <release>
  return k;
}
    800020fe:	854a                	mv	a0,s2
    80002100:	60e2                	ld	ra,24(sp)
    80002102:	6442                	ld	s0,16(sp)
    80002104:	64a2                	ld	s1,8(sp)
    80002106:	6902                	ld	s2,0(sp)
    80002108:	6105                	addi	sp,sp,32
    8000210a:	8082                	ret

000000008000210c <kwait>:
{
    8000210c:	715d                	addi	sp,sp,-80
    8000210e:	e486                	sd	ra,72(sp)
    80002110:	e0a2                	sd	s0,64(sp)
    80002112:	fc26                	sd	s1,56(sp)
    80002114:	f84a                	sd	s2,48(sp)
    80002116:	f44e                	sd	s3,40(sp)
    80002118:	f052                	sd	s4,32(sp)
    8000211a:	ec56                	sd	s5,24(sp)
    8000211c:	e85a                	sd	s6,16(sp)
    8000211e:	e45e                	sd	s7,8(sp)
    80002120:	e062                	sd	s8,0(sp)
    80002122:	0880                	addi	s0,sp,80
    80002124:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002126:	ee2ff0ef          	jal	ra,80001808 <myproc>
    8000212a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000212c:	0000e517          	auipc	a0,0xe
    80002130:	94450513          	addi	a0,a0,-1724 # 8000fa70 <wait_lock>
    80002134:	a39fe0ef          	jal	ra,80000b6c <acquire>
    havekids = 0;
    80002138:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000213a:	4a15                	li	s4,5
        havekids = 1;
    8000213c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000213e:	00014997          	auipc	s3,0x14
    80002142:	b4a98993          	addi	s3,s3,-1206 # 80015c88 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002146:	0000ec17          	auipc	s8,0xe
    8000214a:	92ac0c13          	addi	s8,s8,-1750 # 8000fa70 <wait_lock>
    havekids = 0;
    8000214e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002150:	0000e497          	auipc	s1,0xe
    80002154:	d3848493          	addi	s1,s1,-712 # 8000fe88 <proc>
    80002158:	a899                	j	800021ae <kwait+0xa2>
          pid = pp->pid;
    8000215a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000215e:	000b0c63          	beqz	s6,80002176 <kwait+0x6a>
    80002162:	4691                	li	a3,4
    80002164:	02c48613          	addi	a2,s1,44
    80002168:	85da                	mv	a1,s6
    8000216a:	05093503          	ld	a0,80(s2)
    8000216e:	be4ff0ef          	jal	ra,80001552 <copyout>
    80002172:	00054f63          	bltz	a0,80002190 <kwait+0x84>
          freeproc(pp);
    80002176:	8526                	mv	a0,s1
    80002178:	8c1ff0ef          	jal	ra,80001a38 <freeproc>
          release(&pp->lock);
    8000217c:	8526                	mv	a0,s1
    8000217e:	a87fe0ef          	jal	ra,80000c04 <release>
          release(&wait_lock);
    80002182:	0000e517          	auipc	a0,0xe
    80002186:	8ee50513          	addi	a0,a0,-1810 # 8000fa70 <wait_lock>
    8000218a:	a7bfe0ef          	jal	ra,80000c04 <release>
          return pid;
    8000218e:	a891                	j	800021e2 <kwait+0xd6>
            release(&pp->lock);
    80002190:	8526                	mv	a0,s1
    80002192:	a73fe0ef          	jal	ra,80000c04 <release>
            release(&wait_lock);
    80002196:	0000e517          	auipc	a0,0xe
    8000219a:	8da50513          	addi	a0,a0,-1830 # 8000fa70 <wait_lock>
    8000219e:	a67fe0ef          	jal	ra,80000c04 <release>
            return -1;
    800021a2:	59fd                	li	s3,-1
    800021a4:	a83d                	j	800021e2 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021a6:	17848493          	addi	s1,s1,376
    800021aa:	03348063          	beq	s1,s3,800021ca <kwait+0xbe>
      if(pp->parent == p){
    800021ae:	7c9c                	ld	a5,56(s1)
    800021b0:	ff279be3          	bne	a5,s2,800021a6 <kwait+0x9a>
        acquire(&pp->lock);
    800021b4:	8526                	mv	a0,s1
    800021b6:	9b7fe0ef          	jal	ra,80000b6c <acquire>
        if(pp->state == ZOMBIE){
    800021ba:	4c9c                	lw	a5,24(s1)
    800021bc:	f9478fe3          	beq	a5,s4,8000215a <kwait+0x4e>
        release(&pp->lock);
    800021c0:	8526                	mv	a0,s1
    800021c2:	a43fe0ef          	jal	ra,80000c04 <release>
        havekids = 1;
    800021c6:	8756                	mv	a4,s5
    800021c8:	bff9                	j	800021a6 <kwait+0x9a>
    if(!havekids || killed(p)){
    800021ca:	c709                	beqz	a4,800021d4 <kwait+0xc8>
    800021cc:	854a                	mv	a0,s2
    800021ce:	f15ff0ef          	jal	ra,800020e2 <killed>
    800021d2:	c50d                	beqz	a0,800021fc <kwait+0xf0>
      release(&wait_lock);
    800021d4:	0000e517          	auipc	a0,0xe
    800021d8:	89c50513          	addi	a0,a0,-1892 # 8000fa70 <wait_lock>
    800021dc:	a29fe0ef          	jal	ra,80000c04 <release>
      return -1;
    800021e0:	59fd                	li	s3,-1
}
    800021e2:	854e                	mv	a0,s3
    800021e4:	60a6                	ld	ra,72(sp)
    800021e6:	6406                	ld	s0,64(sp)
    800021e8:	74e2                	ld	s1,56(sp)
    800021ea:	7942                	ld	s2,48(sp)
    800021ec:	79a2                	ld	s3,40(sp)
    800021ee:	7a02                	ld	s4,32(sp)
    800021f0:	6ae2                	ld	s5,24(sp)
    800021f2:	6b42                	ld	s6,16(sp)
    800021f4:	6ba2                	ld	s7,8(sp)
    800021f6:	6c02                	ld	s8,0(sp)
    800021f8:	6161                	addi	sp,sp,80
    800021fa:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021fc:	85e2                	mv	a1,s8
    800021fe:	854a                	mv	a0,s2
    80002200:	cabff0ef          	jal	ra,80001eaa <sleep>
    havekids = 0;
    80002204:	b7a9                	j	8000214e <kwait+0x42>

0000000080002206 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002206:	7179                	addi	sp,sp,-48
    80002208:	f406                	sd	ra,40(sp)
    8000220a:	f022                	sd	s0,32(sp)
    8000220c:	ec26                	sd	s1,24(sp)
    8000220e:	e84a                	sd	s2,16(sp)
    80002210:	e44e                	sd	s3,8(sp)
    80002212:	e052                	sd	s4,0(sp)
    80002214:	1800                	addi	s0,sp,48
    80002216:	84aa                	mv	s1,a0
    80002218:	892e                	mv	s2,a1
    8000221a:	89b2                	mv	s3,a2
    8000221c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000221e:	deaff0ef          	jal	ra,80001808 <myproc>
  if(user_dst){
    80002222:	cc99                	beqz	s1,80002240 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002224:	86d2                	mv	a3,s4
    80002226:	864e                	mv	a2,s3
    80002228:	85ca                	mv	a1,s2
    8000222a:	6928                	ld	a0,80(a0)
    8000222c:	b26ff0ef          	jal	ra,80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002230:	70a2                	ld	ra,40(sp)
    80002232:	7402                	ld	s0,32(sp)
    80002234:	64e2                	ld	s1,24(sp)
    80002236:	6942                	ld	s2,16(sp)
    80002238:	69a2                	ld	s3,8(sp)
    8000223a:	6a02                	ld	s4,0(sp)
    8000223c:	6145                	addi	sp,sp,48
    8000223e:	8082                	ret
    memmove((char *)dst, src, len);
    80002240:	000a061b          	sext.w	a2,s4
    80002244:	85ce                	mv	a1,s3
    80002246:	854a                	mv	a0,s2
    80002248:	a55fe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    8000224c:	8526                	mv	a0,s1
    8000224e:	b7cd                	j	80002230 <either_copyout+0x2a>

0000000080002250 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002250:	7179                	addi	sp,sp,-48
    80002252:	f406                	sd	ra,40(sp)
    80002254:	f022                	sd	s0,32(sp)
    80002256:	ec26                	sd	s1,24(sp)
    80002258:	e84a                	sd	s2,16(sp)
    8000225a:	e44e                	sd	s3,8(sp)
    8000225c:	e052                	sd	s4,0(sp)
    8000225e:	1800                	addi	s0,sp,48
    80002260:	892a                	mv	s2,a0
    80002262:	84ae                	mv	s1,a1
    80002264:	89b2                	mv	s3,a2
    80002266:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002268:	da0ff0ef          	jal	ra,80001808 <myproc>
  if(user_src){
    8000226c:	cc99                	beqz	s1,8000228a <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000226e:	86d2                	mv	a3,s4
    80002270:	864e                	mv	a2,s3
    80002272:	85ca                	mv	a1,s2
    80002274:	6928                	ld	a0,80(a0)
    80002276:	ba2ff0ef          	jal	ra,80001618 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000227a:	70a2                	ld	ra,40(sp)
    8000227c:	7402                	ld	s0,32(sp)
    8000227e:	64e2                	ld	s1,24(sp)
    80002280:	6942                	ld	s2,16(sp)
    80002282:	69a2                	ld	s3,8(sp)
    80002284:	6a02                	ld	s4,0(sp)
    80002286:	6145                	addi	sp,sp,48
    80002288:	8082                	ret
    memmove(dst, (char*)src, len);
    8000228a:	000a061b          	sext.w	a2,s4
    8000228e:	85ce                	mv	a1,s3
    80002290:	854a                	mv	a0,s2
    80002292:	a0bfe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    80002296:	8526                	mv	a0,s1
    80002298:	b7cd                	j	8000227a <either_copyin+0x2a>

000000008000229a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000229a:	715d                	addi	sp,sp,-80
    8000229c:	e486                	sd	ra,72(sp)
    8000229e:	e0a2                	sd	s0,64(sp)
    800022a0:	fc26                	sd	s1,56(sp)
    800022a2:	f84a                	sd	s2,48(sp)
    800022a4:	f44e                	sd	s3,40(sp)
    800022a6:	f052                	sd	s4,32(sp)
    800022a8:	ec56                	sd	s5,24(sp)
    800022aa:	e85a                	sd	s6,16(sp)
    800022ac:	e45e                	sd	s7,8(sp)
    800022ae:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022b0:	00005517          	auipc	a0,0x5
    800022b4:	e1050513          	addi	a0,a0,-496 # 800070c0 <digits+0x88>
    800022b8:	a0cfe0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022bc:	0000e497          	auipc	s1,0xe
    800022c0:	d2448493          	addi	s1,s1,-732 # 8000ffe0 <proc+0x158>
    800022c4:	00014917          	auipc	s2,0x14
    800022c8:	b1c90913          	addi	s2,s2,-1252 # 80015de0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022cc:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022ce:	00005997          	auipc	s3,0x5
    800022d2:	f4a98993          	addi	s3,s3,-182 # 80007218 <digits+0x1e0>
    printf("%d %s %s", p->pid, state, p->name);
    800022d6:	00005a97          	auipc	s5,0x5
    800022da:	f4aa8a93          	addi	s5,s5,-182 # 80007220 <digits+0x1e8>
    printf("\n");
    800022de:	00005a17          	auipc	s4,0x5
    800022e2:	de2a0a13          	addi	s4,s4,-542 # 800070c0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022e6:	00005b97          	auipc	s7,0x5
    800022ea:	f7ab8b93          	addi	s7,s7,-134 # 80007260 <states.0>
    800022ee:	a829                	j	80002308 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022f0:	ed86a583          	lw	a1,-296(a3)
    800022f4:	8556                	mv	a0,s5
    800022f6:	9cefe0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    800022fa:	8552                	mv	a0,s4
    800022fc:	9c8fe0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002300:	17848493          	addi	s1,s1,376
    80002304:	03248163          	beq	s1,s2,80002326 <procdump+0x8c>
    if(p->state == UNUSED)
    80002308:	86a6                	mv	a3,s1
    8000230a:	ec04a783          	lw	a5,-320(s1)
    8000230e:	dbed                	beqz	a5,80002300 <procdump+0x66>
      state = "???";
    80002310:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002312:	fcfb6fe3          	bltu	s6,a5,800022f0 <procdump+0x56>
    80002316:	1782                	slli	a5,a5,0x20
    80002318:	9381                	srli	a5,a5,0x20
    8000231a:	078e                	slli	a5,a5,0x3
    8000231c:	97de                	add	a5,a5,s7
    8000231e:	6390                	ld	a2,0(a5)
    80002320:	fa61                	bnez	a2,800022f0 <procdump+0x56>
      state = "???";
    80002322:	864e                	mv	a2,s3
    80002324:	b7f1                	j	800022f0 <procdump+0x56>
  }
}
    80002326:	60a6                	ld	ra,72(sp)
    80002328:	6406                	ld	s0,64(sp)
    8000232a:	74e2                	ld	s1,56(sp)
    8000232c:	7942                	ld	s2,48(sp)
    8000232e:	79a2                	ld	s3,40(sp)
    80002330:	7a02                	ld	s4,32(sp)
    80002332:	6ae2                	ld	s5,24(sp)
    80002334:	6b42                	ld	s6,16(sp)
    80002336:	6ba2                	ld	s7,8(sp)
    80002338:	6161                	addi	sp,sp,80
    8000233a:	8082                	ret

000000008000233c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000233c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002340:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002344:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002346:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002348:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000234c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002350:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002354:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002358:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000235c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002360:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002364:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002368:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000236c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002370:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002374:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002378:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000237a:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000237c:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002380:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002384:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002388:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000238c:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002390:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002394:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002398:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000239c:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023a0:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023a4:	8082                	ret

00000000800023a6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023a6:	1141                	addi	sp,sp,-16
    800023a8:	e406                	sd	ra,8(sp)
    800023aa:	e022                	sd	s0,0(sp)
    800023ac:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023ae:	00005597          	auipc	a1,0x5
    800023b2:	ee258593          	addi	a1,a1,-286 # 80007290 <states.0+0x30>
    800023b6:	00014517          	auipc	a0,0x14
    800023ba:	8d250513          	addi	a0,a0,-1838 # 80015c88 <tickslock>
    800023be:	f2efe0ef          	jal	ra,80000aec <initlock>
}
    800023c2:	60a2                	ld	ra,8(sp)
    800023c4:	6402                	ld	s0,0(sp)
    800023c6:	0141                	addi	sp,sp,16
    800023c8:	8082                	ret

00000000800023ca <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023ca:	1141                	addi	sp,sp,-16
    800023cc:	e422                	sd	s0,8(sp)
    800023ce:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023d0:	00003797          	auipc	a5,0x3
    800023d4:	14078793          	addi	a5,a5,320 # 80005510 <kernelvec>
    800023d8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023dc:	6422                	ld	s0,8(sp)
    800023de:	0141                	addi	sp,sp,16
    800023e0:	8082                	ret

00000000800023e2 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800023e2:	1141                	addi	sp,sp,-16
    800023e4:	e406                	sd	ra,8(sp)
    800023e6:	e022                	sd	s0,0(sp)
    800023e8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800023ea:	c1eff0ef          	jal	ra,80001808 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023f2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023f4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800023f8:	04000737          	lui	a4,0x4000
    800023fc:	00004797          	auipc	a5,0x4
    80002400:	c0478793          	addi	a5,a5,-1020 # 80006000 <_trampoline>
    80002404:	00004697          	auipc	a3,0x4
    80002408:	bfc68693          	addi	a3,a3,-1028 # 80006000 <_trampoline>
    8000240c:	8f95                	sub	a5,a5,a3
    8000240e:	177d                	addi	a4,a4,-1
    80002410:	0732                	slli	a4,a4,0xc
    80002412:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002414:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002418:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000241a:	18002773          	csrr	a4,satp
    8000241e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002420:	6d38                	ld	a4,88(a0)
    80002422:	613c                	ld	a5,64(a0)
    80002424:	6685                	lui	a3,0x1
    80002426:	97b6                	add	a5,a5,a3
    80002428:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000242a:	6d3c                	ld	a5,88(a0)
    8000242c:	00000717          	auipc	a4,0x0
    80002430:	0f470713          	addi	a4,a4,244 # 80002520 <usertrap>
    80002434:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002436:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002438:	8712                	mv	a4,tp
    8000243a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000243c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002440:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002444:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002448:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000244c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000244e:	6f9c                	ld	a5,24(a5)
    80002450:	14179073          	csrw	sepc,a5
}
    80002454:	60a2                	ld	ra,8(sp)
    80002456:	6402                	ld	s0,0(sp)
    80002458:	0141                	addi	sp,sp,16
    8000245a:	8082                	ret

000000008000245c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000245c:	1101                	addi	sp,sp,-32
    8000245e:	ec06                	sd	ra,24(sp)
    80002460:	e822                	sd	s0,16(sp)
    80002462:	e426                	sd	s1,8(sp)
    80002464:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002466:	b76ff0ef          	jal	ra,800017dc <cpuid>
    8000246a:	cd19                	beqz	a0,80002488 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000246c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002470:	000f4737          	lui	a4,0xf4
    80002474:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002478:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000247a:	14d79073          	csrw	0x14d,a5
}
    8000247e:	60e2                	ld	ra,24(sp)
    80002480:	6442                	ld	s0,16(sp)
    80002482:	64a2                	ld	s1,8(sp)
    80002484:	6105                	addi	sp,sp,32
    80002486:	8082                	ret
    acquire(&tickslock);
    80002488:	00014497          	auipc	s1,0x14
    8000248c:	80048493          	addi	s1,s1,-2048 # 80015c88 <tickslock>
    80002490:	8526                	mv	a0,s1
    80002492:	edafe0ef          	jal	ra,80000b6c <acquire>
    ticks++;
    80002496:	00005517          	auipc	a0,0x5
    8000249a:	4c250513          	addi	a0,a0,1218 # 80007958 <ticks>
    8000249e:	411c                	lw	a5,0(a0)
    800024a0:	2785                	addiw	a5,a5,1
    800024a2:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024a4:	a53ff0ef          	jal	ra,80001ef6 <wakeup>
    release(&tickslock);
    800024a8:	8526                	mv	a0,s1
    800024aa:	f5afe0ef          	jal	ra,80000c04 <release>
    800024ae:	bf7d                	j	8000246c <clockintr+0x10>

00000000800024b0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024b0:	1101                	addi	sp,sp,-32
    800024b2:	ec06                	sd	ra,24(sp)
    800024b4:	e822                	sd	s0,16(sp)
    800024b6:	e426                	sd	s1,8(sp)
    800024b8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024ba:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024be:	57fd                	li	a5,-1
    800024c0:	17fe                	slli	a5,a5,0x3f
    800024c2:	07a5                	addi	a5,a5,9
    800024c4:	00f70d63          	beq	a4,a5,800024de <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024c8:	57fd                	li	a5,-1
    800024ca:	17fe                	slli	a5,a5,0x3f
    800024cc:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024ce:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800024d0:	04f70463          	beq	a4,a5,80002518 <devintr+0x68>
  }
}
    800024d4:	60e2                	ld	ra,24(sp)
    800024d6:	6442                	ld	s0,16(sp)
    800024d8:	64a2                	ld	s1,8(sp)
    800024da:	6105                	addi	sp,sp,32
    800024dc:	8082                	ret
    int irq = plic_claim();
    800024de:	0da030ef          	jal	ra,800055b8 <plic_claim>
    800024e2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800024e4:	47a9                	li	a5,10
    800024e6:	02f50363          	beq	a0,a5,8000250c <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    800024ea:	4785                	li	a5,1
    800024ec:	02f50363          	beq	a0,a5,80002512 <devintr+0x62>
    return 1;
    800024f0:	4505                	li	a0,1
    } else if(irq){
    800024f2:	d0ed                	beqz	s1,800024d4 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    800024f4:	85a6                	mv	a1,s1
    800024f6:	00005517          	auipc	a0,0x5
    800024fa:	da250513          	addi	a0,a0,-606 # 80007298 <states.0+0x38>
    800024fe:	fc7fd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    80002502:	8526                	mv	a0,s1
    80002504:	0d4030ef          	jal	ra,800055d8 <plic_complete>
    return 1;
    80002508:	4505                	li	a0,1
    8000250a:	b7e9                	j	800024d4 <devintr+0x24>
      uartintr();
    8000250c:	c4cfe0ef          	jal	ra,80000958 <uartintr>
    80002510:	bfcd                	j	80002502 <devintr+0x52>
      virtio_disk_intr();
    80002512:	536030ef          	jal	ra,80005a48 <virtio_disk_intr>
    80002516:	b7f5                	j	80002502 <devintr+0x52>
    clockintr();
    80002518:	f45ff0ef          	jal	ra,8000245c <clockintr>
    return 2;
    8000251c:	4509                	li	a0,2
    8000251e:	bf5d                	j	800024d4 <devintr+0x24>

0000000080002520 <usertrap>:
{
    80002520:	1101                	addi	sp,sp,-32
    80002522:	ec06                	sd	ra,24(sp)
    80002524:	e822                	sd	s0,16(sp)
    80002526:	e426                	sd	s1,8(sp)
    80002528:	e04a                	sd	s2,0(sp)
    8000252a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000252c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002530:	1007f793          	andi	a5,a5,256
    80002534:	eba5                	bnez	a5,800025a4 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002536:	00003797          	auipc	a5,0x3
    8000253a:	fda78793          	addi	a5,a5,-38 # 80005510 <kernelvec>
    8000253e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002542:	ac6ff0ef          	jal	ra,80001808 <myproc>
    80002546:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002548:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000254a:	14102773          	csrr	a4,sepc
    8000254e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002550:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002554:	47a1                	li	a5,8
    80002556:	04f70d63          	beq	a4,a5,800025b0 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000255a:	f57ff0ef          	jal	ra,800024b0 <devintr>
    8000255e:	892a                	mv	s2,a0
    80002560:	ed5d                	bnez	a0,8000261e <usertrap+0xfe>
    80002562:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002566:	47bd                	li	a5,15
    80002568:	08f70863          	beq	a4,a5,800025f8 <usertrap+0xd8>
    8000256c:	14202773          	csrr	a4,scause
    80002570:	47b5                	li	a5,13
    80002572:	08f70363          	beq	a4,a5,800025f8 <usertrap+0xd8>
    80002576:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000257a:	5890                	lw	a2,48(s1)
    8000257c:	00005517          	auipc	a0,0x5
    80002580:	d5c50513          	addi	a0,a0,-676 # 800072d8 <states.0+0x78>
    80002584:	f41fd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002588:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000258c:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002590:	00005517          	auipc	a0,0x5
    80002594:	d7850513          	addi	a0,a0,-648 # 80007308 <states.0+0xa8>
    80002598:	f2dfd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    8000259c:	8526                	mv	a0,s1
    8000259e:	b21ff0ef          	jal	ra,800020be <setkilled>
    800025a2:	a035                	j	800025ce <usertrap+0xae>
    panic("usertrap: not from user mode");
    800025a4:	00005517          	auipc	a0,0x5
    800025a8:	d1450513          	addi	a0,a0,-748 # 800072b8 <states.0+0x58>
    800025ac:	9defe0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    800025b0:	b33ff0ef          	jal	ra,800020e2 <killed>
    800025b4:	ed15                	bnez	a0,800025f0 <usertrap+0xd0>
    p->trapframe->epc += 4;
    800025b6:	6cb8                	ld	a4,88(s1)
    800025b8:	6f1c                	ld	a5,24(a4)
    800025ba:	0791                	addi	a5,a5,4
    800025bc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025be:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025c2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025c6:	10079073          	csrw	sstatus,a5
    syscall();
    800025ca:	254000ef          	jal	ra,8000281e <syscall>
  if(killed(p))
    800025ce:	8526                	mv	a0,s1
    800025d0:	b13ff0ef          	jal	ra,800020e2 <killed>
    800025d4:	e931                	bnez	a0,80002628 <usertrap+0x108>
  prepare_return();
    800025d6:	e0dff0ef          	jal	ra,800023e2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800025da:	68a8                	ld	a0,80(s1)
    800025dc:	8131                	srli	a0,a0,0xc
    800025de:	57fd                	li	a5,-1
    800025e0:	17fe                	slli	a5,a5,0x3f
    800025e2:	8d5d                	or	a0,a0,a5
}
    800025e4:	60e2                	ld	ra,24(sp)
    800025e6:	6442                	ld	s0,16(sp)
    800025e8:	64a2                	ld	s1,8(sp)
    800025ea:	6902                	ld	s2,0(sp)
    800025ec:	6105                	addi	sp,sp,32
    800025ee:	8082                	ret
      kexit(-1);
    800025f0:	557d                	li	a0,-1
    800025f2:	9c5ff0ef          	jal	ra,80001fb6 <kexit>
    800025f6:	b7c1                	j	800025b6 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025f8:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025fc:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002600:	164d                	addi	a2,a2,-13
    80002602:	00163613          	seqz	a2,a2
    80002606:	68a8                	ld	a0,80(s1)
    80002608:	ed9fe0ef          	jal	ra,800014e0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000260c:	d52d                	beqz	a0,80002576 <usertrap+0x56>
    myproc()->pf_count++;
    8000260e:	9faff0ef          	jal	ra,80001808 <myproc>
    80002612:	16852783          	lw	a5,360(a0)
    80002616:	2785                	addiw	a5,a5,1
    80002618:	16f52423          	sw	a5,360(a0)
    8000261c:	bf4d                	j	800025ce <usertrap+0xae>
  if(killed(p))
    8000261e:	8526                	mv	a0,s1
    80002620:	ac3ff0ef          	jal	ra,800020e2 <killed>
    80002624:	c511                	beqz	a0,80002630 <usertrap+0x110>
    80002626:	a011                	j	8000262a <usertrap+0x10a>
    80002628:	4901                	li	s2,0
    kexit(-1);
    8000262a:	557d                	li	a0,-1
    8000262c:	98bff0ef          	jal	ra,80001fb6 <kexit>
  if(which_dev == 2)
    80002630:	4789                	li	a5,2
    80002632:	faf912e3          	bne	s2,a5,800025d6 <usertrap+0xb6>
    yield();
    80002636:	849ff0ef          	jal	ra,80001e7e <yield>
    8000263a:	bf71                	j	800025d6 <usertrap+0xb6>

000000008000263c <kerneltrap>:
{
    8000263c:	7179                	addi	sp,sp,-48
    8000263e:	f406                	sd	ra,40(sp)
    80002640:	f022                	sd	s0,32(sp)
    80002642:	ec26                	sd	s1,24(sp)
    80002644:	e84a                	sd	s2,16(sp)
    80002646:	e44e                	sd	s3,8(sp)
    80002648:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000264a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000264e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002652:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002656:	1004f793          	andi	a5,s1,256
    8000265a:	c795                	beqz	a5,80002686 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000265c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002660:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002662:	eb85                	bnez	a5,80002692 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002664:	e4dff0ef          	jal	ra,800024b0 <devintr>
    80002668:	c91d                	beqz	a0,8000269e <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000266a:	4789                	li	a5,2
    8000266c:	04f50a63          	beq	a0,a5,800026c0 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002670:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002674:	10049073          	csrw	sstatus,s1
}
    80002678:	70a2                	ld	ra,40(sp)
    8000267a:	7402                	ld	s0,32(sp)
    8000267c:	64e2                	ld	s1,24(sp)
    8000267e:	6942                	ld	s2,16(sp)
    80002680:	69a2                	ld	s3,8(sp)
    80002682:	6145                	addi	sp,sp,48
    80002684:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002686:	00005517          	auipc	a0,0x5
    8000268a:	caa50513          	addi	a0,a0,-854 # 80007330 <states.0+0xd0>
    8000268e:	8fcfe0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    80002692:	00005517          	auipc	a0,0x5
    80002696:	cc650513          	addi	a0,a0,-826 # 80007358 <states.0+0xf8>
    8000269a:	8f0fe0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000269e:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026a2:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026a6:	85ce                	mv	a1,s3
    800026a8:	00005517          	auipc	a0,0x5
    800026ac:	cd050513          	addi	a0,a0,-816 # 80007378 <states.0+0x118>
    800026b0:	e15fd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    800026b4:	00005517          	auipc	a0,0x5
    800026b8:	cec50513          	addi	a0,a0,-788 # 800073a0 <states.0+0x140>
    800026bc:	8cefe0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    800026c0:	948ff0ef          	jal	ra,80001808 <myproc>
    800026c4:	d555                	beqz	a0,80002670 <kerneltrap+0x34>
    yield();
    800026c6:	fb8ff0ef          	jal	ra,80001e7e <yield>
    800026ca:	b75d                	j	80002670 <kerneltrap+0x34>

00000000800026cc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026cc:	1101                	addi	sp,sp,-32
    800026ce:	ec06                	sd	ra,24(sp)
    800026d0:	e822                	sd	s0,16(sp)
    800026d2:	e426                	sd	s1,8(sp)
    800026d4:	1000                	addi	s0,sp,32
    800026d6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026d8:	930ff0ef          	jal	ra,80001808 <myproc>
  switch (n) {
    800026dc:	4795                	li	a5,5
    800026de:	0497e163          	bltu	a5,s1,80002720 <argraw+0x54>
    800026e2:	048a                	slli	s1,s1,0x2
    800026e4:	00005717          	auipc	a4,0x5
    800026e8:	cf470713          	addi	a4,a4,-780 # 800073d8 <states.0+0x178>
    800026ec:	94ba                	add	s1,s1,a4
    800026ee:	409c                	lw	a5,0(s1)
    800026f0:	97ba                	add	a5,a5,a4
    800026f2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800026f4:	6d3c                	ld	a5,88(a0)
    800026f6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800026f8:	60e2                	ld	ra,24(sp)
    800026fa:	6442                	ld	s0,16(sp)
    800026fc:	64a2                	ld	s1,8(sp)
    800026fe:	6105                	addi	sp,sp,32
    80002700:	8082                	ret
    return p->trapframe->a1;
    80002702:	6d3c                	ld	a5,88(a0)
    80002704:	7fa8                	ld	a0,120(a5)
    80002706:	bfcd                	j	800026f8 <argraw+0x2c>
    return p->trapframe->a2;
    80002708:	6d3c                	ld	a5,88(a0)
    8000270a:	63c8                	ld	a0,128(a5)
    8000270c:	b7f5                	j	800026f8 <argraw+0x2c>
    return p->trapframe->a3;
    8000270e:	6d3c                	ld	a5,88(a0)
    80002710:	67c8                	ld	a0,136(a5)
    80002712:	b7dd                	j	800026f8 <argraw+0x2c>
    return p->trapframe->a4;
    80002714:	6d3c                	ld	a5,88(a0)
    80002716:	6bc8                	ld	a0,144(a5)
    80002718:	b7c5                	j	800026f8 <argraw+0x2c>
    return p->trapframe->a5;
    8000271a:	6d3c                	ld	a5,88(a0)
    8000271c:	6fc8                	ld	a0,152(a5)
    8000271e:	bfe9                	j	800026f8 <argraw+0x2c>
  panic("argraw");
    80002720:	00005517          	auipc	a0,0x5
    80002724:	c9050513          	addi	a0,a0,-880 # 800073b0 <states.0+0x150>
    80002728:	862fe0ef          	jal	ra,8000078a <panic>

000000008000272c <fetchaddr>:
{
    8000272c:	1101                	addi	sp,sp,-32
    8000272e:	ec06                	sd	ra,24(sp)
    80002730:	e822                	sd	s0,16(sp)
    80002732:	e426                	sd	s1,8(sp)
    80002734:	e04a                	sd	s2,0(sp)
    80002736:	1000                	addi	s0,sp,32
    80002738:	84aa                	mv	s1,a0
    8000273a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000273c:	8ccff0ef          	jal	ra,80001808 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002740:	653c                	ld	a5,72(a0)
    80002742:	02f4f663          	bgeu	s1,a5,8000276e <fetchaddr+0x42>
    80002746:	00848713          	addi	a4,s1,8
    8000274a:	02e7e463          	bltu	a5,a4,80002772 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000274e:	46a1                	li	a3,8
    80002750:	8626                	mv	a2,s1
    80002752:	85ca                	mv	a1,s2
    80002754:	6928                	ld	a0,80(a0)
    80002756:	ec3fe0ef          	jal	ra,80001618 <copyin>
    8000275a:	00a03533          	snez	a0,a0
    8000275e:	40a00533          	neg	a0,a0
}
    80002762:	60e2                	ld	ra,24(sp)
    80002764:	6442                	ld	s0,16(sp)
    80002766:	64a2                	ld	s1,8(sp)
    80002768:	6902                	ld	s2,0(sp)
    8000276a:	6105                	addi	sp,sp,32
    8000276c:	8082                	ret
    return -1;
    8000276e:	557d                	li	a0,-1
    80002770:	bfcd                	j	80002762 <fetchaddr+0x36>
    80002772:	557d                	li	a0,-1
    80002774:	b7fd                	j	80002762 <fetchaddr+0x36>

0000000080002776 <fetchstr>:
{
    80002776:	7179                	addi	sp,sp,-48
    80002778:	f406                	sd	ra,40(sp)
    8000277a:	f022                	sd	s0,32(sp)
    8000277c:	ec26                	sd	s1,24(sp)
    8000277e:	e84a                	sd	s2,16(sp)
    80002780:	e44e                	sd	s3,8(sp)
    80002782:	1800                	addi	s0,sp,48
    80002784:	892a                	mv	s2,a0
    80002786:	84ae                	mv	s1,a1
    80002788:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000278a:	87eff0ef          	jal	ra,80001808 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000278e:	86ce                	mv	a3,s3
    80002790:	864a                	mv	a2,s2
    80002792:	85a6                	mv	a1,s1
    80002794:	6928                	ld	a0,80(a0)
    80002796:	c7bfe0ef          	jal	ra,80001410 <copyinstr>
    8000279a:	00054c63          	bltz	a0,800027b2 <fetchstr+0x3c>
  return strlen(buf);
    8000279e:	8526                	mv	a0,s1
    800027a0:	e18fe0ef          	jal	ra,80000db8 <strlen>
}
    800027a4:	70a2                	ld	ra,40(sp)
    800027a6:	7402                	ld	s0,32(sp)
    800027a8:	64e2                	ld	s1,24(sp)
    800027aa:	6942                	ld	s2,16(sp)
    800027ac:	69a2                	ld	s3,8(sp)
    800027ae:	6145                	addi	sp,sp,48
    800027b0:	8082                	ret
    return -1;
    800027b2:	557d                	li	a0,-1
    800027b4:	bfc5                	j	800027a4 <fetchstr+0x2e>

00000000800027b6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027b6:	1101                	addi	sp,sp,-32
    800027b8:	ec06                	sd	ra,24(sp)
    800027ba:	e822                	sd	s0,16(sp)
    800027bc:	e426                	sd	s1,8(sp)
    800027be:	1000                	addi	s0,sp,32
    800027c0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027c2:	f0bff0ef          	jal	ra,800026cc <argraw>
    800027c6:	c088                	sw	a0,0(s1)
}
    800027c8:	60e2                	ld	ra,24(sp)
    800027ca:	6442                	ld	s0,16(sp)
    800027cc:	64a2                	ld	s1,8(sp)
    800027ce:	6105                	addi	sp,sp,32
    800027d0:	8082                	ret

00000000800027d2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027d2:	1101                	addi	sp,sp,-32
    800027d4:	ec06                	sd	ra,24(sp)
    800027d6:	e822                	sd	s0,16(sp)
    800027d8:	e426                	sd	s1,8(sp)
    800027da:	1000                	addi	s0,sp,32
    800027dc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027de:	eefff0ef          	jal	ra,800026cc <argraw>
    800027e2:	e088                	sd	a0,0(s1)
}
    800027e4:	60e2                	ld	ra,24(sp)
    800027e6:	6442                	ld	s0,16(sp)
    800027e8:	64a2                	ld	s1,8(sp)
    800027ea:	6105                	addi	sp,sp,32
    800027ec:	8082                	ret

00000000800027ee <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027ee:	7179                	addi	sp,sp,-48
    800027f0:	f406                	sd	ra,40(sp)
    800027f2:	f022                	sd	s0,32(sp)
    800027f4:	ec26                	sd	s1,24(sp)
    800027f6:	e84a                	sd	s2,16(sp)
    800027f8:	1800                	addi	s0,sp,48
    800027fa:	84ae                	mv	s1,a1
    800027fc:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800027fe:	fd840593          	addi	a1,s0,-40
    80002802:	fd1ff0ef          	jal	ra,800027d2 <argaddr>
  return fetchstr(addr, buf, max);
    80002806:	864a                	mv	a2,s2
    80002808:	85a6                	mv	a1,s1
    8000280a:	fd843503          	ld	a0,-40(s0)
    8000280e:	f69ff0ef          	jal	ra,80002776 <fetchstr>
}
    80002812:	70a2                	ld	ra,40(sp)
    80002814:	7402                	ld	s0,32(sp)
    80002816:	64e2                	ld	s1,24(sp)
    80002818:	6942                	ld	s2,16(sp)
    8000281a:	6145                	addi	sp,sp,48
    8000281c:	8082                	ret

000000008000281e <syscall>:
[SYS_kva_to_pa]  sys_kva_to_pa,
};

void
syscall(void)
{
    8000281e:	1101                	addi	sp,sp,-32
    80002820:	ec06                	sd	ra,24(sp)
    80002822:	e822                	sd	s0,16(sp)
    80002824:	e426                	sd	s1,8(sp)
    80002826:	e04a                	sd	s2,0(sp)
    80002828:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000282a:	fdffe0ef          	jal	ra,80001808 <myproc>
    8000282e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002830:	05853903          	ld	s2,88(a0)
    80002834:	0a893783          	ld	a5,168(s2)
    80002838:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000283c:	37fd                	addiw	a5,a5,-1
    8000283e:	4775                	li	a4,29
    80002840:	00f76f63          	bltu	a4,a5,8000285e <syscall+0x40>
    80002844:	00369713          	slli	a4,a3,0x3
    80002848:	00005797          	auipc	a5,0x5
    8000284c:	ba878793          	addi	a5,a5,-1112 # 800073f0 <syscalls>
    80002850:	97ba                	add	a5,a5,a4
    80002852:	639c                	ld	a5,0(a5)
    80002854:	c789                	beqz	a5,8000285e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002856:	9782                	jalr	a5
    80002858:	06a93823          	sd	a0,112(s2)
    8000285c:	a829                	j	80002876 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000285e:	15848613          	addi	a2,s1,344
    80002862:	588c                	lw	a1,48(s1)
    80002864:	00005517          	auipc	a0,0x5
    80002868:	b5450513          	addi	a0,a0,-1196 # 800073b8 <states.0+0x158>
    8000286c:	c59fd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002870:	6cbc                	ld	a5,88(s1)
    80002872:	577d                	li	a4,-1
    80002874:	fbb8                	sd	a4,112(a5)
  }
}
    80002876:	60e2                	ld	ra,24(sp)
    80002878:	6442                	ld	s0,16(sp)
    8000287a:	64a2                	ld	s1,8(sp)
    8000287c:	6902                	ld	s2,0(sp)
    8000287e:	6105                	addi	sp,sp,32
    80002880:	8082                	ret

0000000080002882 <sys_exit>:

extern pagetable_t kernel_pagetable;

uint64
sys_exit(void)
{
    80002882:	1101                	addi	sp,sp,-32
    80002884:	ec06                	sd	ra,24(sp)
    80002886:	e822                	sd	s0,16(sp)
    80002888:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000288a:	fec40593          	addi	a1,s0,-20
    8000288e:	4501                	li	a0,0
    80002890:	f27ff0ef          	jal	ra,800027b6 <argint>
  kexit(n);
    80002894:	fec42503          	lw	a0,-20(s0)
    80002898:	f1eff0ef          	jal	ra,80001fb6 <kexit>
  return 0;  // not reached
}
    8000289c:	4501                	li	a0,0
    8000289e:	60e2                	ld	ra,24(sp)
    800028a0:	6442                	ld	s0,16(sp)
    800028a2:	6105                	addi	sp,sp,32
    800028a4:	8082                	ret

00000000800028a6 <sys_getpid>:

uint64
sys_getpid(void)
{
    800028a6:	1141                	addi	sp,sp,-16
    800028a8:	e406                	sd	ra,8(sp)
    800028aa:	e022                	sd	s0,0(sp)
    800028ac:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028ae:	f5bfe0ef          	jal	ra,80001808 <myproc>
}
    800028b2:	5908                	lw	a0,48(a0)
    800028b4:	60a2                	ld	ra,8(sp)
    800028b6:	6402                	ld	s0,0(sp)
    800028b8:	0141                	addi	sp,sp,16
    800028ba:	8082                	ret

00000000800028bc <sys_fork>:

uint64
sys_fork(void)
{
    800028bc:	1141                	addi	sp,sp,-16
    800028be:	e406                	sd	ra,8(sp)
    800028c0:	e022                	sd	s0,0(sp)
    800028c2:	0800                	addi	s0,sp,16
  return kfork();
    800028c4:	b42ff0ef          	jal	ra,80001c06 <kfork>
}
    800028c8:	60a2                	ld	ra,8(sp)
    800028ca:	6402                	ld	s0,0(sp)
    800028cc:	0141                	addi	sp,sp,16
    800028ce:	8082                	ret

00000000800028d0 <sys_wait>:

uint64
sys_wait(void)
{
    800028d0:	1101                	addi	sp,sp,-32
    800028d2:	ec06                	sd	ra,24(sp)
    800028d4:	e822                	sd	s0,16(sp)
    800028d6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028d8:	fe840593          	addi	a1,s0,-24
    800028dc:	4501                	li	a0,0
    800028de:	ef5ff0ef          	jal	ra,800027d2 <argaddr>
  return kwait(p);
    800028e2:	fe843503          	ld	a0,-24(s0)
    800028e6:	827ff0ef          	jal	ra,8000210c <kwait>
}
    800028ea:	60e2                	ld	ra,24(sp)
    800028ec:	6442                	ld	s0,16(sp)
    800028ee:	6105                	addi	sp,sp,32
    800028f0:	8082                	ret

00000000800028f2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800028f2:	7179                	addi	sp,sp,-48
    800028f4:	f406                	sd	ra,40(sp)
    800028f6:	f022                	sd	s0,32(sp)
    800028f8:	ec26                	sd	s1,24(sp)
    800028fa:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800028fc:	fd840593          	addi	a1,s0,-40
    80002900:	4501                	li	a0,0
    80002902:	eb5ff0ef          	jal	ra,800027b6 <argint>
  argint(1, &t);
    80002906:	fdc40593          	addi	a1,s0,-36
    8000290a:	4505                	li	a0,1
    8000290c:	eabff0ef          	jal	ra,800027b6 <argint>
  addr = myproc()->sz;
    80002910:	ef9fe0ef          	jal	ra,80001808 <myproc>
    80002914:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002916:	fdc42703          	lw	a4,-36(s0)
    8000291a:	4785                	li	a5,1
    8000291c:	02f70763          	beq	a4,a5,8000294a <sys_sbrk+0x58>
    80002920:	fd842783          	lw	a5,-40(s0)
    80002924:	0207c363          	bltz	a5,8000294a <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002928:	97a6                	add	a5,a5,s1
    8000292a:	0297ee63          	bltu	a5,s1,80002966 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    8000292e:	02000737          	lui	a4,0x2000
    80002932:	177d                	addi	a4,a4,-1
    80002934:	0736                	slli	a4,a4,0xd
    80002936:	02f76a63          	bltu	a4,a5,8000296a <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    8000293a:	ecffe0ef          	jal	ra,80001808 <myproc>
    8000293e:	fd842703          	lw	a4,-40(s0)
    80002942:	653c                	ld	a5,72(a0)
    80002944:	97ba                	add	a5,a5,a4
    80002946:	e53c                	sd	a5,72(a0)
    80002948:	a039                	j	80002956 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    8000294a:	fd842503          	lw	a0,-40(s0)
    8000294e:	a56ff0ef          	jal	ra,80001ba4 <growproc>
    80002952:	00054863          	bltz	a0,80002962 <sys_sbrk+0x70>
  }
  return addr;
}
    80002956:	8526                	mv	a0,s1
    80002958:	70a2                	ld	ra,40(sp)
    8000295a:	7402                	ld	s0,32(sp)
    8000295c:	64e2                	ld	s1,24(sp)
    8000295e:	6145                	addi	sp,sp,48
    80002960:	8082                	ret
      return -1;
    80002962:	54fd                	li	s1,-1
    80002964:	bfcd                	j	80002956 <sys_sbrk+0x64>
      return -1;
    80002966:	54fd                	li	s1,-1
    80002968:	b7fd                	j	80002956 <sys_sbrk+0x64>
      return -1;
    8000296a:	54fd                	li	s1,-1
    8000296c:	b7ed                	j	80002956 <sys_sbrk+0x64>

000000008000296e <sys_pause>:

uint64
sys_pause(void)
{
    8000296e:	7139                	addi	sp,sp,-64
    80002970:	fc06                	sd	ra,56(sp)
    80002972:	f822                	sd	s0,48(sp)
    80002974:	f426                	sd	s1,40(sp)
    80002976:	f04a                	sd	s2,32(sp)
    80002978:	ec4e                	sd	s3,24(sp)
    8000297a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000297c:	fcc40593          	addi	a1,s0,-52
    80002980:	4501                	li	a0,0
    80002982:	e35ff0ef          	jal	ra,800027b6 <argint>
  if(n < 0)
    80002986:	fcc42783          	lw	a5,-52(s0)
    8000298a:	0607c563          	bltz	a5,800029f4 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    8000298e:	00013517          	auipc	a0,0x13
    80002992:	2fa50513          	addi	a0,a0,762 # 80015c88 <tickslock>
    80002996:	9d6fe0ef          	jal	ra,80000b6c <acquire>
  ticks0 = ticks;
    8000299a:	00005917          	auipc	s2,0x5
    8000299e:	fbe92903          	lw	s2,-66(s2) # 80007958 <ticks>
  while(ticks - ticks0 < n){
    800029a2:	fcc42783          	lw	a5,-52(s0)
    800029a6:	cb8d                	beqz	a5,800029d8 <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029a8:	00013997          	auipc	s3,0x13
    800029ac:	2e098993          	addi	s3,s3,736 # 80015c88 <tickslock>
    800029b0:	00005497          	auipc	s1,0x5
    800029b4:	fa848493          	addi	s1,s1,-88 # 80007958 <ticks>
    if(killed(myproc())){
    800029b8:	e51fe0ef          	jal	ra,80001808 <myproc>
    800029bc:	f26ff0ef          	jal	ra,800020e2 <killed>
    800029c0:	ed0d                	bnez	a0,800029fa <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800029c2:	85ce                	mv	a1,s3
    800029c4:	8526                	mv	a0,s1
    800029c6:	ce4ff0ef          	jal	ra,80001eaa <sleep>
  while(ticks - ticks0 < n){
    800029ca:	409c                	lw	a5,0(s1)
    800029cc:	412787bb          	subw	a5,a5,s2
    800029d0:	fcc42703          	lw	a4,-52(s0)
    800029d4:	fee7e2e3          	bltu	a5,a4,800029b8 <sys_pause+0x4a>
  }
  release(&tickslock);
    800029d8:	00013517          	auipc	a0,0x13
    800029dc:	2b050513          	addi	a0,a0,688 # 80015c88 <tickslock>
    800029e0:	a24fe0ef          	jal	ra,80000c04 <release>
  return 0;
    800029e4:	4501                	li	a0,0
}
    800029e6:	70e2                	ld	ra,56(sp)
    800029e8:	7442                	ld	s0,48(sp)
    800029ea:	74a2                	ld	s1,40(sp)
    800029ec:	7902                	ld	s2,32(sp)
    800029ee:	69e2                	ld	s3,24(sp)
    800029f0:	6121                	addi	sp,sp,64
    800029f2:	8082                	ret
    n = 0;
    800029f4:	fc042623          	sw	zero,-52(s0)
    800029f8:	bf59                	j	8000298e <sys_pause+0x20>
      release(&tickslock);
    800029fa:	00013517          	auipc	a0,0x13
    800029fe:	28e50513          	addi	a0,a0,654 # 80015c88 <tickslock>
    80002a02:	a02fe0ef          	jal	ra,80000c04 <release>
      return -1;
    80002a06:	557d                	li	a0,-1
    80002a08:	bff9                	j	800029e6 <sys_pause+0x78>

0000000080002a0a <sys_kill>:

uint64
sys_kill(void)
{
    80002a0a:	1101                	addi	sp,sp,-32
    80002a0c:	ec06                	sd	ra,24(sp)
    80002a0e:	e822                	sd	s0,16(sp)
    80002a10:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a12:	fec40593          	addi	a1,s0,-20
    80002a16:	4501                	li	a0,0
    80002a18:	d9fff0ef          	jal	ra,800027b6 <argint>
  return kkill(pid);
    80002a1c:	fec42503          	lw	a0,-20(s0)
    80002a20:	e38ff0ef          	jal	ra,80002058 <kkill>
}
    80002a24:	60e2                	ld	ra,24(sp)
    80002a26:	6442                	ld	s0,16(sp)
    80002a28:	6105                	addi	sp,sp,32
    80002a2a:	8082                	ret

0000000080002a2c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a2c:	1101                	addi	sp,sp,-32
    80002a2e:	ec06                	sd	ra,24(sp)
    80002a30:	e822                	sd	s0,16(sp)
    80002a32:	e426                	sd	s1,8(sp)
    80002a34:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a36:	00013517          	auipc	a0,0x13
    80002a3a:	25250513          	addi	a0,a0,594 # 80015c88 <tickslock>
    80002a3e:	92efe0ef          	jal	ra,80000b6c <acquire>
  xticks = ticks;
    80002a42:	00005497          	auipc	s1,0x5
    80002a46:	f164a483          	lw	s1,-234(s1) # 80007958 <ticks>
  release(&tickslock);
    80002a4a:	00013517          	auipc	a0,0x13
    80002a4e:	23e50513          	addi	a0,a0,574 # 80015c88 <tickslock>
    80002a52:	9b2fe0ef          	jal	ra,80000c04 <release>
  return xticks;
}
    80002a56:	02049513          	slli	a0,s1,0x20
    80002a5a:	9101                	srli	a0,a0,0x20
    80002a5c:	60e2                	ld	ra,24(sp)
    80002a5e:	6442                	ld	s0,16(sp)
    80002a60:	64a2                	ld	s1,8(sp)
    80002a62:	6105                	addi	sp,sp,32
    80002a64:	8082                	ret

0000000080002a66 <sys_pte_valid>:

uint64
sys_pte_valid(void)
{
    80002a66:	1101                	addi	sp,sp,-32
    80002a68:	ec06                	sd	ra,24(sp)
    80002a6a:	e822                	sd	s0,16(sp)
    80002a6c:	1000                	addi	s0,sp,32
  uint64 va;
  argaddr(0, &va);
    80002a6e:	fe840593          	addi	a1,s0,-24
    80002a72:	4501                	li	a0,0
    80002a74:	d5fff0ef          	jal	ra,800027d2 <argaddr>
  return ismapped(myproc()->pagetable,va);
    80002a78:	d91fe0ef          	jal	ra,80001808 <myproc>
    80002a7c:	fe843583          	ld	a1,-24(s0)
    80002a80:	6928                	ld	a0,80(a0)
    80002a82:	a3ffe0ef          	jal	ra,800014c0 <ismapped>
}
    80002a86:	60e2                	ld	ra,24(sp)
    80002a88:	6442                	ld	s0,16(sp)
    80002a8a:	6105                	addi	sp,sp,32
    80002a8c:	8082                	ret

0000000080002a8e <sys_get_pteflags>:

uint64
sys_get_pteflags(void)
{
    80002a8e:	1101                	addi	sp,sp,-32
    80002a90:	ec06                	sd	ra,24(sp)
    80002a92:	e822                	sd	s0,16(sp)
    80002a94:	1000                	addi	s0,sp,32
  uint64 va;
  argaddr(0, &va);
    80002a96:	fe840593          	addi	a1,s0,-24
    80002a9a:	4501                	li	a0,0
    80002a9c:	d37ff0ef          	jal	ra,800027d2 <argaddr>

  pte_t *pte = walk(myproc()->pagetable, va, 0);
    80002aa0:	d69fe0ef          	jal	ra,80001808 <myproc>
    80002aa4:	4601                	li	a2,0
    80002aa6:	fe843583          	ld	a1,-24(s0)
    80002aaa:	6928                	ld	a0,80(a0)
    80002aac:	c10fe0ef          	jal	ra,80000ebc <walk>
  if (pte == 0) {
    80002ab0:	c509                	beqz	a0,80002aba <sys_get_pteflags+0x2c>
    return 0;
  }
  if (*pte & PTE_V){
    80002ab2:	6110                	ld	a2,0(a0)
    80002ab4:	00167793          	andi	a5,a2,1
    80002ab8:	e791                	bnez	a5,80002ac4 <sys_get_pteflags+0x36>
    printf("VA: 0x%lx -> R:%d  W:%d  X:%d  U:%d\n",va,(*pte & PTE_R)? 1:0 ,(*pte & PTE_W)? 1:0,(*pte & PTE_X)? 1:0,(*pte & PTE_U)? 1:0);
    return 0;
  }
  return 0;
}
    80002aba:	4501                	li	a0,0
    80002abc:	60e2                	ld	ra,24(sp)
    80002abe:	6442                	ld	s0,16(sp)
    80002ac0:	6105                	addi	sp,sp,32
    80002ac2:	8082                	ret
    printf("VA: 0x%lx -> R:%d  W:%d  X:%d  U:%d\n",va,(*pte & PTE_R)? 1:0 ,(*pte & PTE_W)? 1:0,(*pte & PTE_X)? 1:0,(*pte & PTE_U)? 1:0);
    80002ac4:	00465793          	srli	a5,a2,0x4
    80002ac8:	00365713          	srli	a4,a2,0x3
    80002acc:	00265693          	srli	a3,a2,0x2
    80002ad0:	8205                	srli	a2,a2,0x1
    80002ad2:	8b85                	andi	a5,a5,1
    80002ad4:	8b05                	andi	a4,a4,1
    80002ad6:	8a85                	andi	a3,a3,1
    80002ad8:	8a05                	andi	a2,a2,1
    80002ada:	fe843583          	ld	a1,-24(s0)
    80002ade:	00005517          	auipc	a0,0x5
    80002ae2:	a0a50513          	addi	a0,a0,-1526 # 800074e8 <syscalls+0xf8>
    80002ae6:	9dffd0ef          	jal	ra,800004c4 <printf>
    return 0;
    80002aea:	bfc1                	j	80002aba <sys_get_pteflags+0x2c>

0000000080002aec <sys_print_pgdirs>:

uint64
sys_print_pgdirs(void)
{
    80002aec:	1141                	addi	sp,sp,-16
    80002aee:	e406                	sd	ra,8(sp)
    80002af0:	e022                	sd	s0,0(sp)
    80002af2:	0800                	addi	s0,sp,16
  printf("Physical Address of Kernel root pagetable : %p\n",(void *)kernel_pagetable);
    80002af4:	00005597          	auipc	a1,0x5
    80002af8:	e545b583          	ld	a1,-428(a1) # 80007948 <kernel_pagetable>
    80002afc:	00005517          	auipc	a0,0x5
    80002b00:	a1450513          	addi	a0,a0,-1516 # 80007510 <syscalls+0x120>
    80002b04:	9c1fd0ef          	jal	ra,800004c4 <printf>
  printf("Physical Address of User root pagetable   : %p\n",(void *)(myproc()->pagetable));
    80002b08:	d01fe0ef          	jal	ra,80001808 <myproc>
    80002b0c:	692c                	ld	a1,80(a0)
    80002b0e:	00005517          	auipc	a0,0x5
    80002b12:	a3250513          	addi	a0,a0,-1486 # 80007540 <syscalls+0x150>
    80002b16:	9affd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b1a:	180025f3          	csrr	a1,satp
  printf("Physical Address of Current satp register : %p\n",(void *)((r_satp() &((1L<<44)-1))<<12));
    80002b1e:	05b2                	slli	a1,a1,0xc
    80002b20:	fff007b7          	lui	a5,0xfff00
    80002b24:	83a1                	srli	a5,a5,0x8
    80002b26:	8dfd                	and	a1,a1,a5
    80002b28:	00005517          	auipc	a0,0x5
    80002b2c:	a4850513          	addi	a0,a0,-1464 # 80007570 <syscalls+0x180>
    80002b30:	995fd0ef          	jal	ra,800004c4 <printf>
  return 0;
}
    80002b34:	4501                	li	a0,0
    80002b36:	60a2                	ld	ra,8(sp)
    80002b38:	6402                	ld	s0,0(sp)
    80002b3a:	0141                	addi	sp,sp,16
    80002b3c:	8082                	ret

0000000080002b3e <sys_va_to_pte>:

uint64
sys_va_to_pte(void)
{
    80002b3e:	1101                	addi	sp,sp,-32
    80002b40:	ec06                	sd	ra,24(sp)
    80002b42:	e822                	sd	s0,16(sp)
    80002b44:	1000                	addi	s0,sp,32
  uint64 va;
  argaddr(0, &va);
    80002b46:	fe840593          	addi	a1,s0,-24
    80002b4a:	4501                	li	a0,0
    80002b4c:	c87ff0ef          	jal	ra,800027d2 <argaddr>
  pagetable_t pagetable=myproc()->pagetable;
    80002b50:	cb9fe0ef          	jal	ra,80001808 <myproc>
  for(int level = 2; level > 0; level--) {
    pte_t pte = pagetable[PX(level, va)];
    80002b54:	fe843783          	ld	a5,-24(s0)
    80002b58:	01e7d713          	srli	a4,a5,0x1e
    80002b5c:	1ff77713          	andi	a4,a4,511
    80002b60:	6934                	ld	a3,80(a0)
    80002b62:	070e                	slli	a4,a4,0x3
    80002b64:	9736                	add	a4,a4,a3
    80002b66:	6318                	ld	a4,0(a4)
    if(pte & PTE_V) {
    80002b68:	00177693          	andi	a3,a4,1
    80002b6c:	ca9d                	beqz	a3,80002ba2 <sys_va_to_pte+0x64>
      pagetable = (pagetable_t)PTE2PA(pte);
    80002b6e:	8329                	srli	a4,a4,0xa
    80002b70:	0732                	slli	a4,a4,0xc
    pte_t pte = pagetable[PX(level, va)];
    80002b72:	0157d693          	srli	a3,a5,0x15
    80002b76:	1ff6f693          	andi	a3,a3,511
    80002b7a:	068e                	slli	a3,a3,0x3
    80002b7c:	9736                	add	a4,a4,a3
    80002b7e:	6318                	ld	a4,0(a4)
    if(pte & PTE_V) {
    80002b80:	00177693          	andi	a3,a4,1
    80002b84:	c28d                	beqz	a3,80002ba6 <sys_va_to_pte+0x68>
      pagetable = (pagetable_t)PTE2PA(pte);
    80002b86:	8329                	srli	a4,a4,0xa
    80002b88:	0732                	slli	a4,a4,0xc
    } else {
      return -1;
    }
  }
  return PTE2PA(pagetable[PX(0, va)]);
    80002b8a:	83b1                	srli	a5,a5,0xc
    80002b8c:	1ff7f793          	andi	a5,a5,511
    80002b90:	078e                	slli	a5,a5,0x3
    80002b92:	97ba                	add	a5,a5,a4
    80002b94:	6388                	ld	a0,0(a5)
    80002b96:	8129                	srli	a0,a0,0xa
    80002b98:	0532                	slli	a0,a0,0xc
}
    80002b9a:	60e2                	ld	ra,24(sp)
    80002b9c:	6442                	ld	s0,16(sp)
    80002b9e:	6105                	addi	sp,sp,32
    80002ba0:	8082                	ret
      return -1;
    80002ba2:	557d                	li	a0,-1
    80002ba4:	bfdd                	j	80002b9a <sys_va_to_pte+0x5c>
    80002ba6:	557d                	li	a0,-1
    80002ba8:	bfcd                	j	80002b9a <sys_va_to_pte+0x5c>

0000000080002baa <sys_va_to_pa>:

uint64
sys_va_to_pa(void)
{
    80002baa:	1101                	addi	sp,sp,-32
    80002bac:	ec06                	sd	ra,24(sp)
    80002bae:	e822                	sd	s0,16(sp)
    80002bb0:	1000                	addi	s0,sp,32
  uint64 va;
  argaddr(0, &va);
    80002bb2:	fe840593          	addi	a1,s0,-24
    80002bb6:	4501                	li	a0,0
    80002bb8:	c1bff0ef          	jal	ra,800027d2 <argaddr>

  pagetable_t pagetable=myproc()->pagetable;
    80002bbc:	c4dfe0ef          	jal	ra,80001808 <myproc>
  for(int level = 2; level > 0; level--) {
    pte_t pte = pagetable[PX(level, va)];
    80002bc0:	fe843703          	ld	a4,-24(s0)
    80002bc4:	01e75793          	srli	a5,a4,0x1e
    80002bc8:	1ff7f793          	andi	a5,a5,511
    80002bcc:	6934                	ld	a3,80(a0)
    80002bce:	078e                	slli	a5,a5,0x3
    80002bd0:	97b6                	add	a5,a5,a3
    80002bd2:	639c                	ld	a5,0(a5)
    if(pte & PTE_V) {
    80002bd4:	0017f693          	andi	a3,a5,1
    80002bd8:	c2a1                	beqz	a3,80002c18 <sys_va_to_pa+0x6e>
      pagetable = (pagetable_t)PTE2PA(pte);
    80002bda:	83a9                	srli	a5,a5,0xa
    80002bdc:	07b2                	slli	a5,a5,0xc
    pte_t pte = pagetable[PX(level, va)];
    80002bde:	01575693          	srli	a3,a4,0x15
    80002be2:	1ff6f693          	andi	a3,a3,511
    80002be6:	068e                	slli	a3,a3,0x3
    80002be8:	97b6                	add	a5,a5,a3
    80002bea:	639c                	ld	a5,0(a5)
    if(pte & PTE_V) {
    80002bec:	0017f693          	andi	a3,a5,1
    80002bf0:	c695                	beqz	a3,80002c1c <sys_va_to_pa+0x72>
      pagetable = (pagetable_t)PTE2PA(pte);
    80002bf2:	83a9                	srli	a5,a5,0xa
    80002bf4:	00c79693          	slli	a3,a5,0xc
      
    } else {
      return -1;
    }
  }
  return PTE2PA(pagetable[PX(0, va)])+(va&((1L<<12)-1));
    80002bf8:	00c75793          	srli	a5,a4,0xc
    80002bfc:	1ff7f793          	andi	a5,a5,511
    80002c00:	078e                	slli	a5,a5,0x3
    80002c02:	97b6                	add	a5,a5,a3
    80002c04:	6388                	ld	a0,0(a5)
    80002c06:	8129                	srli	a0,a0,0xa
    80002c08:	0532                	slli	a0,a0,0xc
    80002c0a:	1752                	slli	a4,a4,0x34
    80002c0c:	9351                	srli	a4,a4,0x34
    80002c0e:	953a                	add	a0,a0,a4
}
    80002c10:	60e2                	ld	ra,24(sp)
    80002c12:	6442                	ld	s0,16(sp)
    80002c14:	6105                	addi	sp,sp,32
    80002c16:	8082                	ret
      return -1;
    80002c18:	557d                	li	a0,-1
    80002c1a:	bfdd                	j	80002c10 <sys_va_to_pa+0x66>
    80002c1c:	557d                	li	a0,-1
    80002c1e:	bfcd                	j	80002c10 <sys_va_to_pa+0x66>

0000000080002c20 <sys_getvasize>:

uint64
sys_getvasize(void)
{
    80002c20:	1141                	addi	sp,sp,-16
    80002c22:	e406                	sd	ra,8(sp)
    80002c24:	e022                	sd	s0,0(sp)
    80002c26:	0800                	addi	s0,sp,16
  return myproc()->sz;
    80002c28:	be1fe0ef          	jal	ra,80001808 <myproc>
}
    80002c2c:	6528                	ld	a0,72(a0)
    80002c2e:	60a2                	ld	ra,8(sp)
    80002c30:	6402                	ld	s0,0(sp)
    80002c32:	0141                	addi	sp,sp,16
    80002c34:	8082                	ret

0000000080002c36 <sys_getpasize>:

uint64
sys_getpasize(void)
{
    80002c36:	7179                	addi	sp,sp,-48
    80002c38:	f406                	sd	ra,40(sp)
    80002c3a:	f022                	sd	s0,32(sp)
    80002c3c:	ec26                	sd	s1,24(sp)
    80002c3e:	e84a                	sd	s2,16(sp)
    80002c40:	e44e                	sd	s3,8(sp)
    80002c42:	e052                	sd	s4,0(sp)
    80002c44:	1800                	addi	s0,sp,48
  int n=myproc()->sz;
    80002c46:	bc3fe0ef          	jal	ra,80001808 <myproc>
  int count=0;
  for(uint64 i=0;i<n;i+=PGSIZE){
    80002c4a:	04852983          	lw	s3,72(a0)
    80002c4e:	02098a63          	beqz	s3,80002c82 <sys_getpasize+0x4c>
    80002c52:	4481                	li	s1,0
  int count=0;
    80002c54:	4901                	li	s2,0
  for(uint64 i=0;i<n;i+=PGSIZE){
    80002c56:	6a05                	lui	s4,0x1
    
    count+=ismapped(myproc()->pagetable,i);
    80002c58:	bb1fe0ef          	jal	ra,80001808 <myproc>
    80002c5c:	85a6                	mv	a1,s1
    80002c5e:	6928                	ld	a0,80(a0)
    80002c60:	861fe0ef          	jal	ra,800014c0 <ismapped>
    80002c64:	0125093b          	addw	s2,a0,s2
  for(uint64 i=0;i<n;i+=PGSIZE){
    80002c68:	94d2                	add	s1,s1,s4
    80002c6a:	ff34e7e3          	bltu	s1,s3,80002c58 <sys_getpasize+0x22>
  }
  return count*PGSIZE;
}
    80002c6e:	00c9151b          	slliw	a0,s2,0xc
    80002c72:	70a2                	ld	ra,40(sp)
    80002c74:	7402                	ld	s0,32(sp)
    80002c76:	64e2                	ld	s1,24(sp)
    80002c78:	6942                	ld	s2,16(sp)
    80002c7a:	69a2                	ld	s3,8(sp)
    80002c7c:	6a02                	ld	s4,0(sp)
    80002c7e:	6145                	addi	sp,sp,48
    80002c80:	8082                	ret
  int count=0;
    80002c82:	4901                	li	s2,0
    80002c84:	b7ed                	j	80002c6e <sys_getpasize+0x38>

0000000080002c86 <sys_getlazyfaults>:

uint64
sys_getlazyfaults(void)
{
    80002c86:	1141                	addi	sp,sp,-16
    80002c88:	e406                	sd	ra,8(sp)
    80002c8a:	e022                	sd	s0,0(sp)
    80002c8c:	0800                	addi	s0,sp,16
  return (myproc()->pf_count);
    80002c8e:	b7bfe0ef          	jal	ra,80001808 <myproc>
}
    80002c92:	16852503          	lw	a0,360(a0)
    80002c96:	60a2                	ld	ra,8(sp)
    80002c98:	6402                	ld	s0,0(sp)
    80002c9a:	0141                	addi	sp,sp,16
    80002c9c:	8082                	ret

0000000080002c9e <sys_kva_to_pa>:

uint64
sys_kva_to_pa(void)
{
    80002c9e:	1101                	addi	sp,sp,-32
    80002ca0:	ec06                	sd	ra,24(sp)
    80002ca2:	e822                	sd	s0,16(sp)
    80002ca4:	1000                	addi	s0,sp,32
  uint64 va;
  argaddr(0, &va);
    80002ca6:	fe840593          	addi	a1,s0,-24
    80002caa:	4501                	li	a0,0
    80002cac:	b27ff0ef          	jal	ra,800027d2 <argaddr>
  pagetable_t pagetable=kernel_pagetable;
  for(int level = 2; level > 0; level--) {
    pte_t pte = pagetable[PX(level, va)];
    80002cb0:	fe843703          	ld	a4,-24(s0)
    80002cb4:	01e75793          	srli	a5,a4,0x1e
    80002cb8:	1ff7f793          	andi	a5,a5,511
    80002cbc:	078e                	slli	a5,a5,0x3
    80002cbe:	00005697          	auipc	a3,0x5
    80002cc2:	c8a6b683          	ld	a3,-886(a3) # 80007948 <kernel_pagetable>
    80002cc6:	97b6                	add	a5,a5,a3
    80002cc8:	639c                	ld	a5,0(a5)
    if(pte & PTE_V) {
    80002cca:	0017f693          	andi	a3,a5,1
    80002cce:	c6a9                	beqz	a3,80002d18 <sys_kva_to_pa+0x7a>
      pagetable = (pagetable_t)PTE2PA(pte);
    80002cd0:	83a9                	srli	a5,a5,0xa
    80002cd2:	07b2                	slli	a5,a5,0xc
    pte_t pte = pagetable[PX(level, va)];
    80002cd4:	01575693          	srli	a3,a4,0x15
    80002cd8:	1ff6f693          	andi	a3,a3,511
    80002cdc:	068e                	slli	a3,a3,0x3
    80002cde:	97b6                	add	a5,a5,a3
    80002ce0:	639c                	ld	a5,0(a5)
    if(pte & PTE_V) {
    80002ce2:	0017f693          	andi	a3,a5,1
    80002ce6:	ca9d                	beqz	a3,80002d1c <sys_kva_to_pa+0x7e>
      pagetable = (pagetable_t)PTE2PA(pte);
    80002ce8:	83a9                	srli	a5,a5,0xa
    80002cea:	00c79693          	slli	a3,a5,0xc
      
    } else {
      return -1;
    }
  }
  if(!(pagetable[PX(0, va)] & PTE_V)){
    80002cee:	00c75793          	srli	a5,a4,0xc
    80002cf2:	1ff7f793          	andi	a5,a5,511
    80002cf6:	078e                	slli	a5,a5,0x3
    80002cf8:	97b6                	add	a5,a5,a3
    80002cfa:	639c                	ld	a5,0(a5)
    80002cfc:	0017f693          	andi	a3,a5,1
    return -1;
    80002d00:	557d                	li	a0,-1
  if(!(pagetable[PX(0, va)] & PTE_V)){
    80002d02:	c699                	beqz	a3,80002d10 <sys_kva_to_pa+0x72>
  }
  return PTE2PA(pagetable[PX(0, va)])+(va&((1L<<12)-1));
    80002d04:	00a7d513          	srli	a0,a5,0xa
    80002d08:	0532                	slli	a0,a0,0xc
    80002d0a:	1752                	slli	a4,a4,0x34
    80002d0c:	9351                	srli	a4,a4,0x34
    80002d0e:	953a                	add	a0,a0,a4
}
    80002d10:	60e2                	ld	ra,24(sp)
    80002d12:	6442                	ld	s0,16(sp)
    80002d14:	6105                	addi	sp,sp,32
    80002d16:	8082                	ret
      return -1;
    80002d18:	557d                	li	a0,-1
    80002d1a:	bfdd                	j	80002d10 <sys_kva_to_pa+0x72>
    80002d1c:	557d                	li	a0,-1
    80002d1e:	bfcd                	j	80002d10 <sys_kva_to_pa+0x72>

0000000080002d20 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d20:	7179                	addi	sp,sp,-48
    80002d22:	f406                	sd	ra,40(sp)
    80002d24:	f022                	sd	s0,32(sp)
    80002d26:	ec26                	sd	s1,24(sp)
    80002d28:	e84a                	sd	s2,16(sp)
    80002d2a:	e44e                	sd	s3,8(sp)
    80002d2c:	e052                	sd	s4,0(sp)
    80002d2e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d30:	00005597          	auipc	a1,0x5
    80002d34:	87058593          	addi	a1,a1,-1936 # 800075a0 <syscalls+0x1b0>
    80002d38:	00013517          	auipc	a0,0x13
    80002d3c:	f6850513          	addi	a0,a0,-152 # 80015ca0 <bcache>
    80002d40:	dadfd0ef          	jal	ra,80000aec <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d44:	0001b797          	auipc	a5,0x1b
    80002d48:	f5c78793          	addi	a5,a5,-164 # 8001dca0 <bcache+0x8000>
    80002d4c:	0001b717          	auipc	a4,0x1b
    80002d50:	1bc70713          	addi	a4,a4,444 # 8001df08 <bcache+0x8268>
    80002d54:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d58:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d5c:	00013497          	auipc	s1,0x13
    80002d60:	f5c48493          	addi	s1,s1,-164 # 80015cb8 <bcache+0x18>
    b->next = bcache.head.next;
    80002d64:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d66:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d68:	00005a17          	auipc	s4,0x5
    80002d6c:	840a0a13          	addi	s4,s4,-1984 # 800075a8 <syscalls+0x1b8>
    b->next = bcache.head.next;
    80002d70:	2b893783          	ld	a5,696(s2)
    80002d74:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d76:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d7a:	85d2                	mv	a1,s4
    80002d7c:	01048513          	addi	a0,s1,16
    80002d80:	2fe010ef          	jal	ra,8000407e <initsleeplock>
    bcache.head.next->prev = b;
    80002d84:	2b893783          	ld	a5,696(s2)
    80002d88:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d8a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d8e:	45848493          	addi	s1,s1,1112
    80002d92:	fd349fe3          	bne	s1,s3,80002d70 <binit+0x50>
  }
}
    80002d96:	70a2                	ld	ra,40(sp)
    80002d98:	7402                	ld	s0,32(sp)
    80002d9a:	64e2                	ld	s1,24(sp)
    80002d9c:	6942                	ld	s2,16(sp)
    80002d9e:	69a2                	ld	s3,8(sp)
    80002da0:	6a02                	ld	s4,0(sp)
    80002da2:	6145                	addi	sp,sp,48
    80002da4:	8082                	ret

0000000080002da6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002da6:	7179                	addi	sp,sp,-48
    80002da8:	f406                	sd	ra,40(sp)
    80002daa:	f022                	sd	s0,32(sp)
    80002dac:	ec26                	sd	s1,24(sp)
    80002dae:	e84a                	sd	s2,16(sp)
    80002db0:	e44e                	sd	s3,8(sp)
    80002db2:	1800                	addi	s0,sp,48
    80002db4:	892a                	mv	s2,a0
    80002db6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002db8:	00013517          	auipc	a0,0x13
    80002dbc:	ee850513          	addi	a0,a0,-280 # 80015ca0 <bcache>
    80002dc0:	dadfd0ef          	jal	ra,80000b6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002dc4:	0001b497          	auipc	s1,0x1b
    80002dc8:	1944b483          	ld	s1,404(s1) # 8001df58 <bcache+0x82b8>
    80002dcc:	0001b797          	auipc	a5,0x1b
    80002dd0:	13c78793          	addi	a5,a5,316 # 8001df08 <bcache+0x8268>
    80002dd4:	02f48b63          	beq	s1,a5,80002e0a <bread+0x64>
    80002dd8:	873e                	mv	a4,a5
    80002dda:	a021                	j	80002de2 <bread+0x3c>
    80002ddc:	68a4                	ld	s1,80(s1)
    80002dde:	02e48663          	beq	s1,a4,80002e0a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002de2:	449c                	lw	a5,8(s1)
    80002de4:	ff279ce3          	bne	a5,s2,80002ddc <bread+0x36>
    80002de8:	44dc                	lw	a5,12(s1)
    80002dea:	ff3799e3          	bne	a5,s3,80002ddc <bread+0x36>
      b->refcnt++;
    80002dee:	40bc                	lw	a5,64(s1)
    80002df0:	2785                	addiw	a5,a5,1
    80002df2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002df4:	00013517          	auipc	a0,0x13
    80002df8:	eac50513          	addi	a0,a0,-340 # 80015ca0 <bcache>
    80002dfc:	e09fd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002e00:	01048513          	addi	a0,s1,16
    80002e04:	2b0010ef          	jal	ra,800040b4 <acquiresleep>
      return b;
    80002e08:	a889                	j	80002e5a <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e0a:	0001b497          	auipc	s1,0x1b
    80002e0e:	1464b483          	ld	s1,326(s1) # 8001df50 <bcache+0x82b0>
    80002e12:	0001b797          	auipc	a5,0x1b
    80002e16:	0f678793          	addi	a5,a5,246 # 8001df08 <bcache+0x8268>
    80002e1a:	00f48863          	beq	s1,a5,80002e2a <bread+0x84>
    80002e1e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e20:	40bc                	lw	a5,64(s1)
    80002e22:	cb91                	beqz	a5,80002e36 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e24:	64a4                	ld	s1,72(s1)
    80002e26:	fee49de3          	bne	s1,a4,80002e20 <bread+0x7a>
  panic("bget: no buffers");
    80002e2a:	00004517          	auipc	a0,0x4
    80002e2e:	78650513          	addi	a0,a0,1926 # 800075b0 <syscalls+0x1c0>
    80002e32:	959fd0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    80002e36:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e3a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e3e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e42:	4785                	li	a5,1
    80002e44:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e46:	00013517          	auipc	a0,0x13
    80002e4a:	e5a50513          	addi	a0,a0,-422 # 80015ca0 <bcache>
    80002e4e:	db7fd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002e52:	01048513          	addi	a0,s1,16
    80002e56:	25e010ef          	jal	ra,800040b4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e5a:	409c                	lw	a5,0(s1)
    80002e5c:	cb89                	beqz	a5,80002e6e <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e5e:	8526                	mv	a0,s1
    80002e60:	70a2                	ld	ra,40(sp)
    80002e62:	7402                	ld	s0,32(sp)
    80002e64:	64e2                	ld	s1,24(sp)
    80002e66:	6942                	ld	s2,16(sp)
    80002e68:	69a2                	ld	s3,8(sp)
    80002e6a:	6145                	addi	sp,sp,48
    80002e6c:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e6e:	4581                	li	a1,0
    80002e70:	8526                	mv	a0,s1
    80002e72:	1bb020ef          	jal	ra,8000582c <virtio_disk_rw>
    b->valid = 1;
    80002e76:	4785                	li	a5,1
    80002e78:	c09c                	sw	a5,0(s1)
  return b;
    80002e7a:	b7d5                	j	80002e5e <bread+0xb8>

0000000080002e7c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e7c:	1101                	addi	sp,sp,-32
    80002e7e:	ec06                	sd	ra,24(sp)
    80002e80:	e822                	sd	s0,16(sp)
    80002e82:	e426                	sd	s1,8(sp)
    80002e84:	1000                	addi	s0,sp,32
    80002e86:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e88:	0541                	addi	a0,a0,16
    80002e8a:	2a8010ef          	jal	ra,80004132 <holdingsleep>
    80002e8e:	c911                	beqz	a0,80002ea2 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e90:	4585                	li	a1,1
    80002e92:	8526                	mv	a0,s1
    80002e94:	199020ef          	jal	ra,8000582c <virtio_disk_rw>
}
    80002e98:	60e2                	ld	ra,24(sp)
    80002e9a:	6442                	ld	s0,16(sp)
    80002e9c:	64a2                	ld	s1,8(sp)
    80002e9e:	6105                	addi	sp,sp,32
    80002ea0:	8082                	ret
    panic("bwrite");
    80002ea2:	00004517          	auipc	a0,0x4
    80002ea6:	72650513          	addi	a0,a0,1830 # 800075c8 <syscalls+0x1d8>
    80002eaa:	8e1fd0ef          	jal	ra,8000078a <panic>

0000000080002eae <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002eae:	1101                	addi	sp,sp,-32
    80002eb0:	ec06                	sd	ra,24(sp)
    80002eb2:	e822                	sd	s0,16(sp)
    80002eb4:	e426                	sd	s1,8(sp)
    80002eb6:	e04a                	sd	s2,0(sp)
    80002eb8:	1000                	addi	s0,sp,32
    80002eba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ebc:	01050913          	addi	s2,a0,16
    80002ec0:	854a                	mv	a0,s2
    80002ec2:	270010ef          	jal	ra,80004132 <holdingsleep>
    80002ec6:	c13d                	beqz	a0,80002f2c <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002ec8:	854a                	mv	a0,s2
    80002eca:	230010ef          	jal	ra,800040fa <releasesleep>

  acquire(&bcache.lock);
    80002ece:	00013517          	auipc	a0,0x13
    80002ed2:	dd250513          	addi	a0,a0,-558 # 80015ca0 <bcache>
    80002ed6:	c97fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002eda:	40bc                	lw	a5,64(s1)
    80002edc:	37fd                	addiw	a5,a5,-1
    80002ede:	0007871b          	sext.w	a4,a5
    80002ee2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002ee4:	eb05                	bnez	a4,80002f14 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002ee6:	68bc                	ld	a5,80(s1)
    80002ee8:	64b8                	ld	a4,72(s1)
    80002eea:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002eec:	64bc                	ld	a5,72(s1)
    80002eee:	68b8                	ld	a4,80(s1)
    80002ef0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ef2:	0001b797          	auipc	a5,0x1b
    80002ef6:	dae78793          	addi	a5,a5,-594 # 8001dca0 <bcache+0x8000>
    80002efa:	2b87b703          	ld	a4,696(a5)
    80002efe:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f00:	0001b717          	auipc	a4,0x1b
    80002f04:	00870713          	addi	a4,a4,8 # 8001df08 <bcache+0x8268>
    80002f08:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f0a:	2b87b703          	ld	a4,696(a5)
    80002f0e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f10:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f14:	00013517          	auipc	a0,0x13
    80002f18:	d8c50513          	addi	a0,a0,-628 # 80015ca0 <bcache>
    80002f1c:	ce9fd0ef          	jal	ra,80000c04 <release>
}
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	64a2                	ld	s1,8(sp)
    80002f26:	6902                	ld	s2,0(sp)
    80002f28:	6105                	addi	sp,sp,32
    80002f2a:	8082                	ret
    panic("brelse");
    80002f2c:	00004517          	auipc	a0,0x4
    80002f30:	6a450513          	addi	a0,a0,1700 # 800075d0 <syscalls+0x1e0>
    80002f34:	857fd0ef          	jal	ra,8000078a <panic>

0000000080002f38 <bpin>:

void
bpin(struct buf *b) {
    80002f38:	1101                	addi	sp,sp,-32
    80002f3a:	ec06                	sd	ra,24(sp)
    80002f3c:	e822                	sd	s0,16(sp)
    80002f3e:	e426                	sd	s1,8(sp)
    80002f40:	1000                	addi	s0,sp,32
    80002f42:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f44:	00013517          	auipc	a0,0x13
    80002f48:	d5c50513          	addi	a0,a0,-676 # 80015ca0 <bcache>
    80002f4c:	c21fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt++;
    80002f50:	40bc                	lw	a5,64(s1)
    80002f52:	2785                	addiw	a5,a5,1
    80002f54:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f56:	00013517          	auipc	a0,0x13
    80002f5a:	d4a50513          	addi	a0,a0,-694 # 80015ca0 <bcache>
    80002f5e:	ca7fd0ef          	jal	ra,80000c04 <release>
}
    80002f62:	60e2                	ld	ra,24(sp)
    80002f64:	6442                	ld	s0,16(sp)
    80002f66:	64a2                	ld	s1,8(sp)
    80002f68:	6105                	addi	sp,sp,32
    80002f6a:	8082                	ret

0000000080002f6c <bunpin>:

void
bunpin(struct buf *b) {
    80002f6c:	1101                	addi	sp,sp,-32
    80002f6e:	ec06                	sd	ra,24(sp)
    80002f70:	e822                	sd	s0,16(sp)
    80002f72:	e426                	sd	s1,8(sp)
    80002f74:	1000                	addi	s0,sp,32
    80002f76:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f78:	00013517          	auipc	a0,0x13
    80002f7c:	d2850513          	addi	a0,a0,-728 # 80015ca0 <bcache>
    80002f80:	bedfd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002f84:	40bc                	lw	a5,64(s1)
    80002f86:	37fd                	addiw	a5,a5,-1
    80002f88:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f8a:	00013517          	auipc	a0,0x13
    80002f8e:	d1650513          	addi	a0,a0,-746 # 80015ca0 <bcache>
    80002f92:	c73fd0ef          	jal	ra,80000c04 <release>
}
    80002f96:	60e2                	ld	ra,24(sp)
    80002f98:	6442                	ld	s0,16(sp)
    80002f9a:	64a2                	ld	s1,8(sp)
    80002f9c:	6105                	addi	sp,sp,32
    80002f9e:	8082                	ret

0000000080002fa0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002fa0:	1101                	addi	sp,sp,-32
    80002fa2:	ec06                	sd	ra,24(sp)
    80002fa4:	e822                	sd	s0,16(sp)
    80002fa6:	e426                	sd	s1,8(sp)
    80002fa8:	e04a                	sd	s2,0(sp)
    80002faa:	1000                	addi	s0,sp,32
    80002fac:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002fae:	00d5d59b          	srliw	a1,a1,0xd
    80002fb2:	0001b797          	auipc	a5,0x1b
    80002fb6:	3ca7a783          	lw	a5,970(a5) # 8001e37c <sb+0x1c>
    80002fba:	9dbd                	addw	a1,a1,a5
    80002fbc:	debff0ef          	jal	ra,80002da6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002fc0:	0074f713          	andi	a4,s1,7
    80002fc4:	4785                	li	a5,1
    80002fc6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002fca:	14ce                	slli	s1,s1,0x33
    80002fcc:	90d9                	srli	s1,s1,0x36
    80002fce:	00950733          	add	a4,a0,s1
    80002fd2:	05874703          	lbu	a4,88(a4)
    80002fd6:	00e7f6b3          	and	a3,a5,a4
    80002fda:	c29d                	beqz	a3,80003000 <bfree+0x60>
    80002fdc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002fde:	94aa                	add	s1,s1,a0
    80002fe0:	fff7c793          	not	a5,a5
    80002fe4:	8ff9                	and	a5,a5,a4
    80002fe6:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002fea:	7d1000ef          	jal	ra,80003fba <log_write>
  brelse(bp);
    80002fee:	854a                	mv	a0,s2
    80002ff0:	ebfff0ef          	jal	ra,80002eae <brelse>
}
    80002ff4:	60e2                	ld	ra,24(sp)
    80002ff6:	6442                	ld	s0,16(sp)
    80002ff8:	64a2                	ld	s1,8(sp)
    80002ffa:	6902                	ld	s2,0(sp)
    80002ffc:	6105                	addi	sp,sp,32
    80002ffe:	8082                	ret
    panic("freeing free block");
    80003000:	00004517          	auipc	a0,0x4
    80003004:	5d850513          	addi	a0,a0,1496 # 800075d8 <syscalls+0x1e8>
    80003008:	f82fd0ef          	jal	ra,8000078a <panic>

000000008000300c <balloc>:
{
    8000300c:	711d                	addi	sp,sp,-96
    8000300e:	ec86                	sd	ra,88(sp)
    80003010:	e8a2                	sd	s0,80(sp)
    80003012:	e4a6                	sd	s1,72(sp)
    80003014:	e0ca                	sd	s2,64(sp)
    80003016:	fc4e                	sd	s3,56(sp)
    80003018:	f852                	sd	s4,48(sp)
    8000301a:	f456                	sd	s5,40(sp)
    8000301c:	f05a                	sd	s6,32(sp)
    8000301e:	ec5e                	sd	s7,24(sp)
    80003020:	e862                	sd	s8,16(sp)
    80003022:	e466                	sd	s9,8(sp)
    80003024:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003026:	0001b797          	auipc	a5,0x1b
    8000302a:	33e7a783          	lw	a5,830(a5) # 8001e364 <sb+0x4>
    8000302e:	0e078163          	beqz	a5,80003110 <balloc+0x104>
    80003032:	8baa                	mv	s7,a0
    80003034:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003036:	0001bb17          	auipc	s6,0x1b
    8000303a:	32ab0b13          	addi	s6,s6,810 # 8001e360 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000303e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003040:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003042:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003044:	6c89                	lui	s9,0x2
    80003046:	a0b5                	j	800030b2 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003048:	974a                	add	a4,a4,s2
    8000304a:	8fd5                	or	a5,a5,a3
    8000304c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003050:	854a                	mv	a0,s2
    80003052:	769000ef          	jal	ra,80003fba <log_write>
        brelse(bp);
    80003056:	854a                	mv	a0,s2
    80003058:	e57ff0ef          	jal	ra,80002eae <brelse>
  bp = bread(dev, bno);
    8000305c:	85a6                	mv	a1,s1
    8000305e:	855e                	mv	a0,s7
    80003060:	d47ff0ef          	jal	ra,80002da6 <bread>
    80003064:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003066:	40000613          	li	a2,1024
    8000306a:	4581                	li	a1,0
    8000306c:	05850513          	addi	a0,a0,88
    80003070:	bd1fd0ef          	jal	ra,80000c40 <memset>
  log_write(bp);
    80003074:	854a                	mv	a0,s2
    80003076:	745000ef          	jal	ra,80003fba <log_write>
  brelse(bp);
    8000307a:	854a                	mv	a0,s2
    8000307c:	e33ff0ef          	jal	ra,80002eae <brelse>
}
    80003080:	8526                	mv	a0,s1
    80003082:	60e6                	ld	ra,88(sp)
    80003084:	6446                	ld	s0,80(sp)
    80003086:	64a6                	ld	s1,72(sp)
    80003088:	6906                	ld	s2,64(sp)
    8000308a:	79e2                	ld	s3,56(sp)
    8000308c:	7a42                	ld	s4,48(sp)
    8000308e:	7aa2                	ld	s5,40(sp)
    80003090:	7b02                	ld	s6,32(sp)
    80003092:	6be2                	ld	s7,24(sp)
    80003094:	6c42                	ld	s8,16(sp)
    80003096:	6ca2                	ld	s9,8(sp)
    80003098:	6125                	addi	sp,sp,96
    8000309a:	8082                	ret
    brelse(bp);
    8000309c:	854a                	mv	a0,s2
    8000309e:	e11ff0ef          	jal	ra,80002eae <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800030a2:	015c87bb          	addw	a5,s9,s5
    800030a6:	00078a9b          	sext.w	s5,a5
    800030aa:	004b2703          	lw	a4,4(s6)
    800030ae:	06eaf163          	bgeu	s5,a4,80003110 <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    800030b2:	41fad79b          	sraiw	a5,s5,0x1f
    800030b6:	0137d79b          	srliw	a5,a5,0x13
    800030ba:	015787bb          	addw	a5,a5,s5
    800030be:	40d7d79b          	sraiw	a5,a5,0xd
    800030c2:	01cb2583          	lw	a1,28(s6)
    800030c6:	9dbd                	addw	a1,a1,a5
    800030c8:	855e                	mv	a0,s7
    800030ca:	cddff0ef          	jal	ra,80002da6 <bread>
    800030ce:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030d0:	004b2503          	lw	a0,4(s6)
    800030d4:	000a849b          	sext.w	s1,s5
    800030d8:	8662                	mv	a2,s8
    800030da:	fca4f1e3          	bgeu	s1,a0,8000309c <balloc+0x90>
      m = 1 << (bi % 8);
    800030de:	41f6579b          	sraiw	a5,a2,0x1f
    800030e2:	01d7d69b          	srliw	a3,a5,0x1d
    800030e6:	00c6873b          	addw	a4,a3,a2
    800030ea:	00777793          	andi	a5,a4,7
    800030ee:	9f95                	subw	a5,a5,a3
    800030f0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800030f4:	4037571b          	sraiw	a4,a4,0x3
    800030f8:	00e906b3          	add	a3,s2,a4
    800030fc:	0586c683          	lbu	a3,88(a3)
    80003100:	00d7f5b3          	and	a1,a5,a3
    80003104:	d1b1                	beqz	a1,80003048 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003106:	2605                	addiw	a2,a2,1
    80003108:	2485                	addiw	s1,s1,1
    8000310a:	fd4618e3          	bne	a2,s4,800030da <balloc+0xce>
    8000310e:	b779                	j	8000309c <balloc+0x90>
  printf("balloc: out of blocks\n");
    80003110:	00004517          	auipc	a0,0x4
    80003114:	4e050513          	addi	a0,a0,1248 # 800075f0 <syscalls+0x200>
    80003118:	bacfd0ef          	jal	ra,800004c4 <printf>
  return 0;
    8000311c:	4481                	li	s1,0
    8000311e:	b78d                	j	80003080 <balloc+0x74>

0000000080003120 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003120:	7179                	addi	sp,sp,-48
    80003122:	f406                	sd	ra,40(sp)
    80003124:	f022                	sd	s0,32(sp)
    80003126:	ec26                	sd	s1,24(sp)
    80003128:	e84a                	sd	s2,16(sp)
    8000312a:	e44e                	sd	s3,8(sp)
    8000312c:	e052                	sd	s4,0(sp)
    8000312e:	1800                	addi	s0,sp,48
    80003130:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003132:	47ad                	li	a5,11
    80003134:	02b7e563          	bltu	a5,a1,8000315e <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003138:	02059493          	slli	s1,a1,0x20
    8000313c:	9081                	srli	s1,s1,0x20
    8000313e:	048a                	slli	s1,s1,0x2
    80003140:	94aa                	add	s1,s1,a0
    80003142:	0504a903          	lw	s2,80(s1)
    80003146:	06091663          	bnez	s2,800031b2 <bmap+0x92>
      addr = balloc(ip->dev);
    8000314a:	4108                	lw	a0,0(a0)
    8000314c:	ec1ff0ef          	jal	ra,8000300c <balloc>
    80003150:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003154:	04090f63          	beqz	s2,800031b2 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80003158:	0524a823          	sw	s2,80(s1)
    8000315c:	a899                	j	800031b2 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000315e:	ff45849b          	addiw	s1,a1,-12
    80003162:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003166:	0ff00793          	li	a5,255
    8000316a:	06e7eb63          	bltu	a5,a4,800031e0 <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000316e:	08052903          	lw	s2,128(a0)
    80003172:	00091b63          	bnez	s2,80003188 <bmap+0x68>
      addr = balloc(ip->dev);
    80003176:	4108                	lw	a0,0(a0)
    80003178:	e95ff0ef          	jal	ra,8000300c <balloc>
    8000317c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003180:	02090963          	beqz	s2,800031b2 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003184:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003188:	85ca                	mv	a1,s2
    8000318a:	0009a503          	lw	a0,0(s3)
    8000318e:	c19ff0ef          	jal	ra,80002da6 <bread>
    80003192:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003194:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003198:	02049593          	slli	a1,s1,0x20
    8000319c:	9181                	srli	a1,a1,0x20
    8000319e:	058a                	slli	a1,a1,0x2
    800031a0:	00b784b3          	add	s1,a5,a1
    800031a4:	0004a903          	lw	s2,0(s1)
    800031a8:	00090e63          	beqz	s2,800031c4 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800031ac:	8552                	mv	a0,s4
    800031ae:	d01ff0ef          	jal	ra,80002eae <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800031b2:	854a                	mv	a0,s2
    800031b4:	70a2                	ld	ra,40(sp)
    800031b6:	7402                	ld	s0,32(sp)
    800031b8:	64e2                	ld	s1,24(sp)
    800031ba:	6942                	ld	s2,16(sp)
    800031bc:	69a2                	ld	s3,8(sp)
    800031be:	6a02                	ld	s4,0(sp)
    800031c0:	6145                	addi	sp,sp,48
    800031c2:	8082                	ret
      addr = balloc(ip->dev);
    800031c4:	0009a503          	lw	a0,0(s3)
    800031c8:	e45ff0ef          	jal	ra,8000300c <balloc>
    800031cc:	0005091b          	sext.w	s2,a0
      if(addr){
    800031d0:	fc090ee3          	beqz	s2,800031ac <bmap+0x8c>
        a[bn] = addr;
    800031d4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800031d8:	8552                	mv	a0,s4
    800031da:	5e1000ef          	jal	ra,80003fba <log_write>
    800031de:	b7f9                	j	800031ac <bmap+0x8c>
  panic("bmap: out of range");
    800031e0:	00004517          	auipc	a0,0x4
    800031e4:	42850513          	addi	a0,a0,1064 # 80007608 <syscalls+0x218>
    800031e8:	da2fd0ef          	jal	ra,8000078a <panic>

00000000800031ec <iget>:
{
    800031ec:	7179                	addi	sp,sp,-48
    800031ee:	f406                	sd	ra,40(sp)
    800031f0:	f022                	sd	s0,32(sp)
    800031f2:	ec26                	sd	s1,24(sp)
    800031f4:	e84a                	sd	s2,16(sp)
    800031f6:	e44e                	sd	s3,8(sp)
    800031f8:	e052                	sd	s4,0(sp)
    800031fa:	1800                	addi	s0,sp,48
    800031fc:	89aa                	mv	s3,a0
    800031fe:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003200:	0001b517          	auipc	a0,0x1b
    80003204:	18050513          	addi	a0,a0,384 # 8001e380 <itable>
    80003208:	965fd0ef          	jal	ra,80000b6c <acquire>
  empty = 0;
    8000320c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000320e:	0001b497          	auipc	s1,0x1b
    80003212:	18a48493          	addi	s1,s1,394 # 8001e398 <itable+0x18>
    80003216:	0001d697          	auipc	a3,0x1d
    8000321a:	c1268693          	addi	a3,a3,-1006 # 8001fe28 <log>
    8000321e:	a039                	j	8000322c <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003220:	02090963          	beqz	s2,80003252 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003224:	08848493          	addi	s1,s1,136
    80003228:	02d48863          	beq	s1,a3,80003258 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000322c:	449c                	lw	a5,8(s1)
    8000322e:	fef059e3          	blez	a5,80003220 <iget+0x34>
    80003232:	4098                	lw	a4,0(s1)
    80003234:	ff3716e3          	bne	a4,s3,80003220 <iget+0x34>
    80003238:	40d8                	lw	a4,4(s1)
    8000323a:	ff4713e3          	bne	a4,s4,80003220 <iget+0x34>
      ip->ref++;
    8000323e:	2785                	addiw	a5,a5,1
    80003240:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003242:	0001b517          	auipc	a0,0x1b
    80003246:	13e50513          	addi	a0,a0,318 # 8001e380 <itable>
    8000324a:	9bbfd0ef          	jal	ra,80000c04 <release>
      return ip;
    8000324e:	8926                	mv	s2,s1
    80003250:	a02d                	j	8000327a <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003252:	fbe9                	bnez	a5,80003224 <iget+0x38>
    80003254:	8926                	mv	s2,s1
    80003256:	b7f9                	j	80003224 <iget+0x38>
  if(empty == 0)
    80003258:	02090a63          	beqz	s2,8000328c <iget+0xa0>
  ip->dev = dev;
    8000325c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003260:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003264:	4785                	li	a5,1
    80003266:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000326a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000326e:	0001b517          	auipc	a0,0x1b
    80003272:	11250513          	addi	a0,a0,274 # 8001e380 <itable>
    80003276:	98ffd0ef          	jal	ra,80000c04 <release>
}
    8000327a:	854a                	mv	a0,s2
    8000327c:	70a2                	ld	ra,40(sp)
    8000327e:	7402                	ld	s0,32(sp)
    80003280:	64e2                	ld	s1,24(sp)
    80003282:	6942                	ld	s2,16(sp)
    80003284:	69a2                	ld	s3,8(sp)
    80003286:	6a02                	ld	s4,0(sp)
    80003288:	6145                	addi	sp,sp,48
    8000328a:	8082                	ret
    panic("iget: no inodes");
    8000328c:	00004517          	auipc	a0,0x4
    80003290:	39450513          	addi	a0,a0,916 # 80007620 <syscalls+0x230>
    80003294:	cf6fd0ef          	jal	ra,8000078a <panic>

0000000080003298 <iinit>:
{
    80003298:	7179                	addi	sp,sp,-48
    8000329a:	f406                	sd	ra,40(sp)
    8000329c:	f022                	sd	s0,32(sp)
    8000329e:	ec26                	sd	s1,24(sp)
    800032a0:	e84a                	sd	s2,16(sp)
    800032a2:	e44e                	sd	s3,8(sp)
    800032a4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800032a6:	00004597          	auipc	a1,0x4
    800032aa:	38a58593          	addi	a1,a1,906 # 80007630 <syscalls+0x240>
    800032ae:	0001b517          	auipc	a0,0x1b
    800032b2:	0d250513          	addi	a0,a0,210 # 8001e380 <itable>
    800032b6:	837fd0ef          	jal	ra,80000aec <initlock>
  for(i = 0; i < NINODE; i++) {
    800032ba:	0001b497          	auipc	s1,0x1b
    800032be:	0ee48493          	addi	s1,s1,238 # 8001e3a8 <itable+0x28>
    800032c2:	0001d997          	auipc	s3,0x1d
    800032c6:	b7698993          	addi	s3,s3,-1162 # 8001fe38 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800032ca:	00004917          	auipc	s2,0x4
    800032ce:	36e90913          	addi	s2,s2,878 # 80007638 <syscalls+0x248>
    800032d2:	85ca                	mv	a1,s2
    800032d4:	8526                	mv	a0,s1
    800032d6:	5a9000ef          	jal	ra,8000407e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800032da:	08848493          	addi	s1,s1,136
    800032de:	ff349ae3          	bne	s1,s3,800032d2 <iinit+0x3a>
}
    800032e2:	70a2                	ld	ra,40(sp)
    800032e4:	7402                	ld	s0,32(sp)
    800032e6:	64e2                	ld	s1,24(sp)
    800032e8:	6942                	ld	s2,16(sp)
    800032ea:	69a2                	ld	s3,8(sp)
    800032ec:	6145                	addi	sp,sp,48
    800032ee:	8082                	ret

00000000800032f0 <ialloc>:
{
    800032f0:	715d                	addi	sp,sp,-80
    800032f2:	e486                	sd	ra,72(sp)
    800032f4:	e0a2                	sd	s0,64(sp)
    800032f6:	fc26                	sd	s1,56(sp)
    800032f8:	f84a                	sd	s2,48(sp)
    800032fa:	f44e                	sd	s3,40(sp)
    800032fc:	f052                	sd	s4,32(sp)
    800032fe:	ec56                	sd	s5,24(sp)
    80003300:	e85a                	sd	s6,16(sp)
    80003302:	e45e                	sd	s7,8(sp)
    80003304:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003306:	0001b717          	auipc	a4,0x1b
    8000330a:	06672703          	lw	a4,102(a4) # 8001e36c <sb+0xc>
    8000330e:	4785                	li	a5,1
    80003310:	04e7f663          	bgeu	a5,a4,8000335c <ialloc+0x6c>
    80003314:	8aaa                	mv	s5,a0
    80003316:	8bae                	mv	s7,a1
    80003318:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000331a:	0001ba17          	auipc	s4,0x1b
    8000331e:	046a0a13          	addi	s4,s4,70 # 8001e360 <sb>
    80003322:	00048b1b          	sext.w	s6,s1
    80003326:	0044d793          	srli	a5,s1,0x4
    8000332a:	018a2583          	lw	a1,24(s4)
    8000332e:	9dbd                	addw	a1,a1,a5
    80003330:	8556                	mv	a0,s5
    80003332:	a75ff0ef          	jal	ra,80002da6 <bread>
    80003336:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003338:	05850993          	addi	s3,a0,88
    8000333c:	00f4f793          	andi	a5,s1,15
    80003340:	079a                	slli	a5,a5,0x6
    80003342:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003344:	00099783          	lh	a5,0(s3)
    80003348:	cf85                	beqz	a5,80003380 <ialloc+0x90>
    brelse(bp);
    8000334a:	b65ff0ef          	jal	ra,80002eae <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000334e:	0485                	addi	s1,s1,1
    80003350:	00ca2703          	lw	a4,12(s4)
    80003354:	0004879b          	sext.w	a5,s1
    80003358:	fce7e5e3          	bltu	a5,a4,80003322 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000335c:	00004517          	auipc	a0,0x4
    80003360:	2e450513          	addi	a0,a0,740 # 80007640 <syscalls+0x250>
    80003364:	960fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003368:	4501                	li	a0,0
}
    8000336a:	60a6                	ld	ra,72(sp)
    8000336c:	6406                	ld	s0,64(sp)
    8000336e:	74e2                	ld	s1,56(sp)
    80003370:	7942                	ld	s2,48(sp)
    80003372:	79a2                	ld	s3,40(sp)
    80003374:	7a02                	ld	s4,32(sp)
    80003376:	6ae2                	ld	s5,24(sp)
    80003378:	6b42                	ld	s6,16(sp)
    8000337a:	6ba2                	ld	s7,8(sp)
    8000337c:	6161                	addi	sp,sp,80
    8000337e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003380:	04000613          	li	a2,64
    80003384:	4581                	li	a1,0
    80003386:	854e                	mv	a0,s3
    80003388:	8b9fd0ef          	jal	ra,80000c40 <memset>
      dip->type = type;
    8000338c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003390:	854a                	mv	a0,s2
    80003392:	429000ef          	jal	ra,80003fba <log_write>
      brelse(bp);
    80003396:	854a                	mv	a0,s2
    80003398:	b17ff0ef          	jal	ra,80002eae <brelse>
      return iget(dev, inum);
    8000339c:	85da                	mv	a1,s6
    8000339e:	8556                	mv	a0,s5
    800033a0:	e4dff0ef          	jal	ra,800031ec <iget>
    800033a4:	b7d9                	j	8000336a <ialloc+0x7a>

00000000800033a6 <iupdate>:
{
    800033a6:	1101                	addi	sp,sp,-32
    800033a8:	ec06                	sd	ra,24(sp)
    800033aa:	e822                	sd	s0,16(sp)
    800033ac:	e426                	sd	s1,8(sp)
    800033ae:	e04a                	sd	s2,0(sp)
    800033b0:	1000                	addi	s0,sp,32
    800033b2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033b4:	415c                	lw	a5,4(a0)
    800033b6:	0047d79b          	srliw	a5,a5,0x4
    800033ba:	0001b597          	auipc	a1,0x1b
    800033be:	fbe5a583          	lw	a1,-66(a1) # 8001e378 <sb+0x18>
    800033c2:	9dbd                	addw	a1,a1,a5
    800033c4:	4108                	lw	a0,0(a0)
    800033c6:	9e1ff0ef          	jal	ra,80002da6 <bread>
    800033ca:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033cc:	05850793          	addi	a5,a0,88
    800033d0:	40c8                	lw	a0,4(s1)
    800033d2:	893d                	andi	a0,a0,15
    800033d4:	051a                	slli	a0,a0,0x6
    800033d6:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800033d8:	04449703          	lh	a4,68(s1)
    800033dc:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800033e0:	04649703          	lh	a4,70(s1)
    800033e4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800033e8:	04849703          	lh	a4,72(s1)
    800033ec:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800033f0:	04a49703          	lh	a4,74(s1)
    800033f4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800033f8:	44f8                	lw	a4,76(s1)
    800033fa:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800033fc:	03400613          	li	a2,52
    80003400:	05048593          	addi	a1,s1,80
    80003404:	0531                	addi	a0,a0,12
    80003406:	897fd0ef          	jal	ra,80000c9c <memmove>
  log_write(bp);
    8000340a:	854a                	mv	a0,s2
    8000340c:	3af000ef          	jal	ra,80003fba <log_write>
  brelse(bp);
    80003410:	854a                	mv	a0,s2
    80003412:	a9dff0ef          	jal	ra,80002eae <brelse>
}
    80003416:	60e2                	ld	ra,24(sp)
    80003418:	6442                	ld	s0,16(sp)
    8000341a:	64a2                	ld	s1,8(sp)
    8000341c:	6902                	ld	s2,0(sp)
    8000341e:	6105                	addi	sp,sp,32
    80003420:	8082                	ret

0000000080003422 <idup>:
{
    80003422:	1101                	addi	sp,sp,-32
    80003424:	ec06                	sd	ra,24(sp)
    80003426:	e822                	sd	s0,16(sp)
    80003428:	e426                	sd	s1,8(sp)
    8000342a:	1000                	addi	s0,sp,32
    8000342c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000342e:	0001b517          	auipc	a0,0x1b
    80003432:	f5250513          	addi	a0,a0,-174 # 8001e380 <itable>
    80003436:	f36fd0ef          	jal	ra,80000b6c <acquire>
  ip->ref++;
    8000343a:	449c                	lw	a5,8(s1)
    8000343c:	2785                	addiw	a5,a5,1
    8000343e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003440:	0001b517          	auipc	a0,0x1b
    80003444:	f4050513          	addi	a0,a0,-192 # 8001e380 <itable>
    80003448:	fbcfd0ef          	jal	ra,80000c04 <release>
}
    8000344c:	8526                	mv	a0,s1
    8000344e:	60e2                	ld	ra,24(sp)
    80003450:	6442                	ld	s0,16(sp)
    80003452:	64a2                	ld	s1,8(sp)
    80003454:	6105                	addi	sp,sp,32
    80003456:	8082                	ret

0000000080003458 <ilock>:
{
    80003458:	1101                	addi	sp,sp,-32
    8000345a:	ec06                	sd	ra,24(sp)
    8000345c:	e822                	sd	s0,16(sp)
    8000345e:	e426                	sd	s1,8(sp)
    80003460:	e04a                	sd	s2,0(sp)
    80003462:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003464:	c105                	beqz	a0,80003484 <ilock+0x2c>
    80003466:	84aa                	mv	s1,a0
    80003468:	451c                	lw	a5,8(a0)
    8000346a:	00f05d63          	blez	a5,80003484 <ilock+0x2c>
  acquiresleep(&ip->lock);
    8000346e:	0541                	addi	a0,a0,16
    80003470:	445000ef          	jal	ra,800040b4 <acquiresleep>
  if(ip->valid == 0){
    80003474:	40bc                	lw	a5,64(s1)
    80003476:	cf89                	beqz	a5,80003490 <ilock+0x38>
}
    80003478:	60e2                	ld	ra,24(sp)
    8000347a:	6442                	ld	s0,16(sp)
    8000347c:	64a2                	ld	s1,8(sp)
    8000347e:	6902                	ld	s2,0(sp)
    80003480:	6105                	addi	sp,sp,32
    80003482:	8082                	ret
    panic("ilock");
    80003484:	00004517          	auipc	a0,0x4
    80003488:	1d450513          	addi	a0,a0,468 # 80007658 <syscalls+0x268>
    8000348c:	afefd0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003490:	40dc                	lw	a5,4(s1)
    80003492:	0047d79b          	srliw	a5,a5,0x4
    80003496:	0001b597          	auipc	a1,0x1b
    8000349a:	ee25a583          	lw	a1,-286(a1) # 8001e378 <sb+0x18>
    8000349e:	9dbd                	addw	a1,a1,a5
    800034a0:	4088                	lw	a0,0(s1)
    800034a2:	905ff0ef          	jal	ra,80002da6 <bread>
    800034a6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800034a8:	05850593          	addi	a1,a0,88
    800034ac:	40dc                	lw	a5,4(s1)
    800034ae:	8bbd                	andi	a5,a5,15
    800034b0:	079a                	slli	a5,a5,0x6
    800034b2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800034b4:	00059783          	lh	a5,0(a1)
    800034b8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800034bc:	00259783          	lh	a5,2(a1)
    800034c0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800034c4:	00459783          	lh	a5,4(a1)
    800034c8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800034cc:	00659783          	lh	a5,6(a1)
    800034d0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800034d4:	459c                	lw	a5,8(a1)
    800034d6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800034d8:	03400613          	li	a2,52
    800034dc:	05b1                	addi	a1,a1,12
    800034de:	05048513          	addi	a0,s1,80
    800034e2:	fbafd0ef          	jal	ra,80000c9c <memmove>
    brelse(bp);
    800034e6:	854a                	mv	a0,s2
    800034e8:	9c7ff0ef          	jal	ra,80002eae <brelse>
    ip->valid = 1;
    800034ec:	4785                	li	a5,1
    800034ee:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800034f0:	04449783          	lh	a5,68(s1)
    800034f4:	f3d1                	bnez	a5,80003478 <ilock+0x20>
      panic("ilock: no type");
    800034f6:	00004517          	auipc	a0,0x4
    800034fa:	16a50513          	addi	a0,a0,362 # 80007660 <syscalls+0x270>
    800034fe:	a8cfd0ef          	jal	ra,8000078a <panic>

0000000080003502 <iunlock>:
{
    80003502:	1101                	addi	sp,sp,-32
    80003504:	ec06                	sd	ra,24(sp)
    80003506:	e822                	sd	s0,16(sp)
    80003508:	e426                	sd	s1,8(sp)
    8000350a:	e04a                	sd	s2,0(sp)
    8000350c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000350e:	c505                	beqz	a0,80003536 <iunlock+0x34>
    80003510:	84aa                	mv	s1,a0
    80003512:	01050913          	addi	s2,a0,16
    80003516:	854a                	mv	a0,s2
    80003518:	41b000ef          	jal	ra,80004132 <holdingsleep>
    8000351c:	cd09                	beqz	a0,80003536 <iunlock+0x34>
    8000351e:	449c                	lw	a5,8(s1)
    80003520:	00f05b63          	blez	a5,80003536 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003524:	854a                	mv	a0,s2
    80003526:	3d5000ef          	jal	ra,800040fa <releasesleep>
}
    8000352a:	60e2                	ld	ra,24(sp)
    8000352c:	6442                	ld	s0,16(sp)
    8000352e:	64a2                	ld	s1,8(sp)
    80003530:	6902                	ld	s2,0(sp)
    80003532:	6105                	addi	sp,sp,32
    80003534:	8082                	ret
    panic("iunlock");
    80003536:	00004517          	auipc	a0,0x4
    8000353a:	13a50513          	addi	a0,a0,314 # 80007670 <syscalls+0x280>
    8000353e:	a4cfd0ef          	jal	ra,8000078a <panic>

0000000080003542 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003542:	7179                	addi	sp,sp,-48
    80003544:	f406                	sd	ra,40(sp)
    80003546:	f022                	sd	s0,32(sp)
    80003548:	ec26                	sd	s1,24(sp)
    8000354a:	e84a                	sd	s2,16(sp)
    8000354c:	e44e                	sd	s3,8(sp)
    8000354e:	e052                	sd	s4,0(sp)
    80003550:	1800                	addi	s0,sp,48
    80003552:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003554:	05050493          	addi	s1,a0,80
    80003558:	08050913          	addi	s2,a0,128
    8000355c:	a021                	j	80003564 <itrunc+0x22>
    8000355e:	0491                	addi	s1,s1,4
    80003560:	01248b63          	beq	s1,s2,80003576 <itrunc+0x34>
    if(ip->addrs[i]){
    80003564:	408c                	lw	a1,0(s1)
    80003566:	dde5                	beqz	a1,8000355e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003568:	0009a503          	lw	a0,0(s3)
    8000356c:	a35ff0ef          	jal	ra,80002fa0 <bfree>
      ip->addrs[i] = 0;
    80003570:	0004a023          	sw	zero,0(s1)
    80003574:	b7ed                	j	8000355e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003576:	0809a583          	lw	a1,128(s3)
    8000357a:	ed91                	bnez	a1,80003596 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000357c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003580:	854e                	mv	a0,s3
    80003582:	e25ff0ef          	jal	ra,800033a6 <iupdate>
}
    80003586:	70a2                	ld	ra,40(sp)
    80003588:	7402                	ld	s0,32(sp)
    8000358a:	64e2                	ld	s1,24(sp)
    8000358c:	6942                	ld	s2,16(sp)
    8000358e:	69a2                	ld	s3,8(sp)
    80003590:	6a02                	ld	s4,0(sp)
    80003592:	6145                	addi	sp,sp,48
    80003594:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003596:	0009a503          	lw	a0,0(s3)
    8000359a:	80dff0ef          	jal	ra,80002da6 <bread>
    8000359e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800035a0:	05850493          	addi	s1,a0,88
    800035a4:	45850913          	addi	s2,a0,1112
    800035a8:	a021                	j	800035b0 <itrunc+0x6e>
    800035aa:	0491                	addi	s1,s1,4
    800035ac:	01248963          	beq	s1,s2,800035be <itrunc+0x7c>
      if(a[j])
    800035b0:	408c                	lw	a1,0(s1)
    800035b2:	dde5                	beqz	a1,800035aa <itrunc+0x68>
        bfree(ip->dev, a[j]);
    800035b4:	0009a503          	lw	a0,0(s3)
    800035b8:	9e9ff0ef          	jal	ra,80002fa0 <bfree>
    800035bc:	b7fd                	j	800035aa <itrunc+0x68>
    brelse(bp);
    800035be:	8552                	mv	a0,s4
    800035c0:	8efff0ef          	jal	ra,80002eae <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800035c4:	0809a583          	lw	a1,128(s3)
    800035c8:	0009a503          	lw	a0,0(s3)
    800035cc:	9d5ff0ef          	jal	ra,80002fa0 <bfree>
    ip->addrs[NDIRECT] = 0;
    800035d0:	0809a023          	sw	zero,128(s3)
    800035d4:	b765                	j	8000357c <itrunc+0x3a>

00000000800035d6 <iput>:
{
    800035d6:	1101                	addi	sp,sp,-32
    800035d8:	ec06                	sd	ra,24(sp)
    800035da:	e822                	sd	s0,16(sp)
    800035dc:	e426                	sd	s1,8(sp)
    800035de:	e04a                	sd	s2,0(sp)
    800035e0:	1000                	addi	s0,sp,32
    800035e2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035e4:	0001b517          	auipc	a0,0x1b
    800035e8:	d9c50513          	addi	a0,a0,-612 # 8001e380 <itable>
    800035ec:	d80fd0ef          	jal	ra,80000b6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035f0:	4498                	lw	a4,8(s1)
    800035f2:	4785                	li	a5,1
    800035f4:	02f70163          	beq	a4,a5,80003616 <iput+0x40>
  ip->ref--;
    800035f8:	449c                	lw	a5,8(s1)
    800035fa:	37fd                	addiw	a5,a5,-1
    800035fc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035fe:	0001b517          	auipc	a0,0x1b
    80003602:	d8250513          	addi	a0,a0,-638 # 8001e380 <itable>
    80003606:	dfefd0ef          	jal	ra,80000c04 <release>
}
    8000360a:	60e2                	ld	ra,24(sp)
    8000360c:	6442                	ld	s0,16(sp)
    8000360e:	64a2                	ld	s1,8(sp)
    80003610:	6902                	ld	s2,0(sp)
    80003612:	6105                	addi	sp,sp,32
    80003614:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003616:	40bc                	lw	a5,64(s1)
    80003618:	d3e5                	beqz	a5,800035f8 <iput+0x22>
    8000361a:	04a49783          	lh	a5,74(s1)
    8000361e:	ffe9                	bnez	a5,800035f8 <iput+0x22>
    acquiresleep(&ip->lock);
    80003620:	01048913          	addi	s2,s1,16
    80003624:	854a                	mv	a0,s2
    80003626:	28f000ef          	jal	ra,800040b4 <acquiresleep>
    release(&itable.lock);
    8000362a:	0001b517          	auipc	a0,0x1b
    8000362e:	d5650513          	addi	a0,a0,-682 # 8001e380 <itable>
    80003632:	dd2fd0ef          	jal	ra,80000c04 <release>
    itrunc(ip);
    80003636:	8526                	mv	a0,s1
    80003638:	f0bff0ef          	jal	ra,80003542 <itrunc>
    ip->type = 0;
    8000363c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003640:	8526                	mv	a0,s1
    80003642:	d65ff0ef          	jal	ra,800033a6 <iupdate>
    ip->valid = 0;
    80003646:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000364a:	854a                	mv	a0,s2
    8000364c:	2af000ef          	jal	ra,800040fa <releasesleep>
    acquire(&itable.lock);
    80003650:	0001b517          	auipc	a0,0x1b
    80003654:	d3050513          	addi	a0,a0,-720 # 8001e380 <itable>
    80003658:	d14fd0ef          	jal	ra,80000b6c <acquire>
    8000365c:	bf71                	j	800035f8 <iput+0x22>

000000008000365e <iunlockput>:
{
    8000365e:	1101                	addi	sp,sp,-32
    80003660:	ec06                	sd	ra,24(sp)
    80003662:	e822                	sd	s0,16(sp)
    80003664:	e426                	sd	s1,8(sp)
    80003666:	1000                	addi	s0,sp,32
    80003668:	84aa                	mv	s1,a0
  iunlock(ip);
    8000366a:	e99ff0ef          	jal	ra,80003502 <iunlock>
  iput(ip);
    8000366e:	8526                	mv	a0,s1
    80003670:	f67ff0ef          	jal	ra,800035d6 <iput>
}
    80003674:	60e2                	ld	ra,24(sp)
    80003676:	6442                	ld	s0,16(sp)
    80003678:	64a2                	ld	s1,8(sp)
    8000367a:	6105                	addi	sp,sp,32
    8000367c:	8082                	ret

000000008000367e <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000367e:	0001b717          	auipc	a4,0x1b
    80003682:	cee72703          	lw	a4,-786(a4) # 8001e36c <sb+0xc>
    80003686:	4785                	li	a5,1
    80003688:	0ae7ff63          	bgeu	a5,a4,80003746 <ireclaim+0xc8>
{
    8000368c:	7139                	addi	sp,sp,-64
    8000368e:	fc06                	sd	ra,56(sp)
    80003690:	f822                	sd	s0,48(sp)
    80003692:	f426                	sd	s1,40(sp)
    80003694:	f04a                	sd	s2,32(sp)
    80003696:	ec4e                	sd	s3,24(sp)
    80003698:	e852                	sd	s4,16(sp)
    8000369a:	e456                	sd	s5,8(sp)
    8000369c:	e05a                	sd	s6,0(sp)
    8000369e:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036a0:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036a2:	00050a1b          	sext.w	s4,a0
    800036a6:	0001ba97          	auipc	s5,0x1b
    800036aa:	cbaa8a93          	addi	s5,s5,-838 # 8001e360 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800036ae:	00004b17          	auipc	s6,0x4
    800036b2:	fcab0b13          	addi	s6,s6,-54 # 80007678 <syscalls+0x288>
    800036b6:	a099                	j	800036fc <ireclaim+0x7e>
    800036b8:	85ce                	mv	a1,s3
    800036ba:	855a                	mv	a0,s6
    800036bc:	e09fc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    800036c0:	85ce                	mv	a1,s3
    800036c2:	8552                	mv	a0,s4
    800036c4:	b29ff0ef          	jal	ra,800031ec <iget>
    800036c8:	89aa                	mv	s3,a0
    brelse(bp);
    800036ca:	854a                	mv	a0,s2
    800036cc:	fe2ff0ef          	jal	ra,80002eae <brelse>
    if (ip) {
    800036d0:	00098f63          	beqz	s3,800036ee <ireclaim+0x70>
      begin_op();
    800036d4:	762000ef          	jal	ra,80003e36 <begin_op>
      ilock(ip);
    800036d8:	854e                	mv	a0,s3
    800036da:	d7fff0ef          	jal	ra,80003458 <ilock>
      iunlock(ip);
    800036de:	854e                	mv	a0,s3
    800036e0:	e23ff0ef          	jal	ra,80003502 <iunlock>
      iput(ip);
    800036e4:	854e                	mv	a0,s3
    800036e6:	ef1ff0ef          	jal	ra,800035d6 <iput>
      end_op();
    800036ea:	7bc000ef          	jal	ra,80003ea6 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036ee:	0485                	addi	s1,s1,1
    800036f0:	00caa703          	lw	a4,12(s5)
    800036f4:	0004879b          	sext.w	a5,s1
    800036f8:	02e7fd63          	bgeu	a5,a4,80003732 <ireclaim+0xb4>
    800036fc:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003700:	0044d793          	srli	a5,s1,0x4
    80003704:	018aa583          	lw	a1,24(s5)
    80003708:	9dbd                	addw	a1,a1,a5
    8000370a:	8552                	mv	a0,s4
    8000370c:	e9aff0ef          	jal	ra,80002da6 <bread>
    80003710:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003712:	05850793          	addi	a5,a0,88
    80003716:	00f9f713          	andi	a4,s3,15
    8000371a:	071a                	slli	a4,a4,0x6
    8000371c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000371e:	00079703          	lh	a4,0(a5)
    80003722:	c701                	beqz	a4,8000372a <ireclaim+0xac>
    80003724:	00679783          	lh	a5,6(a5)
    80003728:	dbc1                	beqz	a5,800036b8 <ireclaim+0x3a>
    brelse(bp);
    8000372a:	854a                	mv	a0,s2
    8000372c:	f82ff0ef          	jal	ra,80002eae <brelse>
    if (ip) {
    80003730:	bf7d                	j	800036ee <ireclaim+0x70>
}
    80003732:	70e2                	ld	ra,56(sp)
    80003734:	7442                	ld	s0,48(sp)
    80003736:	74a2                	ld	s1,40(sp)
    80003738:	7902                	ld	s2,32(sp)
    8000373a:	69e2                	ld	s3,24(sp)
    8000373c:	6a42                	ld	s4,16(sp)
    8000373e:	6aa2                	ld	s5,8(sp)
    80003740:	6b02                	ld	s6,0(sp)
    80003742:	6121                	addi	sp,sp,64
    80003744:	8082                	ret
    80003746:	8082                	ret

0000000080003748 <fsinit>:
fsinit(int dev) {
    80003748:	7179                	addi	sp,sp,-48
    8000374a:	f406                	sd	ra,40(sp)
    8000374c:	f022                	sd	s0,32(sp)
    8000374e:	ec26                	sd	s1,24(sp)
    80003750:	e84a                	sd	s2,16(sp)
    80003752:	e44e                	sd	s3,8(sp)
    80003754:	1800                	addi	s0,sp,48
    80003756:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003758:	4585                	li	a1,1
    8000375a:	e4cff0ef          	jal	ra,80002da6 <bread>
    8000375e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003760:	0001b997          	auipc	s3,0x1b
    80003764:	c0098993          	addi	s3,s3,-1024 # 8001e360 <sb>
    80003768:	02000613          	li	a2,32
    8000376c:	05850593          	addi	a1,a0,88
    80003770:	854e                	mv	a0,s3
    80003772:	d2afd0ef          	jal	ra,80000c9c <memmove>
  brelse(bp);
    80003776:	854a                	mv	a0,s2
    80003778:	f36ff0ef          	jal	ra,80002eae <brelse>
  if(sb.magic != FSMAGIC)
    8000377c:	0009a703          	lw	a4,0(s3)
    80003780:	102037b7          	lui	a5,0x10203
    80003784:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003788:	02f71363          	bne	a4,a5,800037ae <fsinit+0x66>
  initlog(dev, &sb);
    8000378c:	0001b597          	auipc	a1,0x1b
    80003790:	bd458593          	addi	a1,a1,-1068 # 8001e360 <sb>
    80003794:	8526                	mv	a0,s1
    80003796:	616000ef          	jal	ra,80003dac <initlog>
  ireclaim(dev);
    8000379a:	8526                	mv	a0,s1
    8000379c:	ee3ff0ef          	jal	ra,8000367e <ireclaim>
}
    800037a0:	70a2                	ld	ra,40(sp)
    800037a2:	7402                	ld	s0,32(sp)
    800037a4:	64e2                	ld	s1,24(sp)
    800037a6:	6942                	ld	s2,16(sp)
    800037a8:	69a2                	ld	s3,8(sp)
    800037aa:	6145                	addi	sp,sp,48
    800037ac:	8082                	ret
    panic("invalid file system");
    800037ae:	00004517          	auipc	a0,0x4
    800037b2:	eea50513          	addi	a0,a0,-278 # 80007698 <syscalls+0x2a8>
    800037b6:	fd5fc0ef          	jal	ra,8000078a <panic>

00000000800037ba <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037ba:	1141                	addi	sp,sp,-16
    800037bc:	e422                	sd	s0,8(sp)
    800037be:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037c0:	411c                	lw	a5,0(a0)
    800037c2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037c4:	415c                	lw	a5,4(a0)
    800037c6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037c8:	04451783          	lh	a5,68(a0)
    800037cc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037d0:	04a51783          	lh	a5,74(a0)
    800037d4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037d8:	04c56783          	lwu	a5,76(a0)
    800037dc:	e99c                	sd	a5,16(a1)
}
    800037de:	6422                	ld	s0,8(sp)
    800037e0:	0141                	addi	sp,sp,16
    800037e2:	8082                	ret

00000000800037e4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037e4:	457c                	lw	a5,76(a0)
    800037e6:	0cd7ef63          	bltu	a5,a3,800038c4 <readi+0xe0>
{
    800037ea:	7159                	addi	sp,sp,-112
    800037ec:	f486                	sd	ra,104(sp)
    800037ee:	f0a2                	sd	s0,96(sp)
    800037f0:	eca6                	sd	s1,88(sp)
    800037f2:	e8ca                	sd	s2,80(sp)
    800037f4:	e4ce                	sd	s3,72(sp)
    800037f6:	e0d2                	sd	s4,64(sp)
    800037f8:	fc56                	sd	s5,56(sp)
    800037fa:	f85a                	sd	s6,48(sp)
    800037fc:	f45e                	sd	s7,40(sp)
    800037fe:	f062                	sd	s8,32(sp)
    80003800:	ec66                	sd	s9,24(sp)
    80003802:	e86a                	sd	s10,16(sp)
    80003804:	e46e                	sd	s11,8(sp)
    80003806:	1880                	addi	s0,sp,112
    80003808:	8b2a                	mv	s6,a0
    8000380a:	8bae                	mv	s7,a1
    8000380c:	8a32                	mv	s4,a2
    8000380e:	84b6                	mv	s1,a3
    80003810:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003812:	9f35                	addw	a4,a4,a3
    return 0;
    80003814:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003816:	08d76663          	bltu	a4,a3,800038a2 <readi+0xbe>
  if(off + n > ip->size)
    8000381a:	00e7f463          	bgeu	a5,a4,80003822 <readi+0x3e>
    n = ip->size - off;
    8000381e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003822:	080a8f63          	beqz	s5,800038c0 <readi+0xdc>
    80003826:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003828:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000382c:	5c7d                	li	s8,-1
    8000382e:	a80d                	j	80003860 <readi+0x7c>
    80003830:	020d1d93          	slli	s11,s10,0x20
    80003834:	020ddd93          	srli	s11,s11,0x20
    80003838:	05890793          	addi	a5,s2,88
    8000383c:	86ee                	mv	a3,s11
    8000383e:	963e                	add	a2,a2,a5
    80003840:	85d2                	mv	a1,s4
    80003842:	855e                	mv	a0,s7
    80003844:	9c3fe0ef          	jal	ra,80002206 <either_copyout>
    80003848:	05850763          	beq	a0,s8,80003896 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000384c:	854a                	mv	a0,s2
    8000384e:	e60ff0ef          	jal	ra,80002eae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003852:	013d09bb          	addw	s3,s10,s3
    80003856:	009d04bb          	addw	s1,s10,s1
    8000385a:	9a6e                	add	s4,s4,s11
    8000385c:	0559f163          	bgeu	s3,s5,8000389e <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003860:	00a4d59b          	srliw	a1,s1,0xa
    80003864:	855a                	mv	a0,s6
    80003866:	8bbff0ef          	jal	ra,80003120 <bmap>
    8000386a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000386e:	c985                	beqz	a1,8000389e <readi+0xba>
    bp = bread(ip->dev, addr);
    80003870:	000b2503          	lw	a0,0(s6)
    80003874:	d32ff0ef          	jal	ra,80002da6 <bread>
    80003878:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000387a:	3ff4f613          	andi	a2,s1,1023
    8000387e:	40cc87bb          	subw	a5,s9,a2
    80003882:	413a873b          	subw	a4,s5,s3
    80003886:	8d3e                	mv	s10,a5
    80003888:	2781                	sext.w	a5,a5
    8000388a:	0007069b          	sext.w	a3,a4
    8000388e:	faf6f1e3          	bgeu	a3,a5,80003830 <readi+0x4c>
    80003892:	8d3a                	mv	s10,a4
    80003894:	bf71                	j	80003830 <readi+0x4c>
      brelse(bp);
    80003896:	854a                	mv	a0,s2
    80003898:	e16ff0ef          	jal	ra,80002eae <brelse>
      tot = -1;
    8000389c:	59fd                	li	s3,-1
  }
  return tot;
    8000389e:	0009851b          	sext.w	a0,s3
}
    800038a2:	70a6                	ld	ra,104(sp)
    800038a4:	7406                	ld	s0,96(sp)
    800038a6:	64e6                	ld	s1,88(sp)
    800038a8:	6946                	ld	s2,80(sp)
    800038aa:	69a6                	ld	s3,72(sp)
    800038ac:	6a06                	ld	s4,64(sp)
    800038ae:	7ae2                	ld	s5,56(sp)
    800038b0:	7b42                	ld	s6,48(sp)
    800038b2:	7ba2                	ld	s7,40(sp)
    800038b4:	7c02                	ld	s8,32(sp)
    800038b6:	6ce2                	ld	s9,24(sp)
    800038b8:	6d42                	ld	s10,16(sp)
    800038ba:	6da2                	ld	s11,8(sp)
    800038bc:	6165                	addi	sp,sp,112
    800038be:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038c0:	89d6                	mv	s3,s5
    800038c2:	bff1                	j	8000389e <readi+0xba>
    return 0;
    800038c4:	4501                	li	a0,0
}
    800038c6:	8082                	ret

00000000800038c8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038c8:	457c                	lw	a5,76(a0)
    800038ca:	0ed7ea63          	bltu	a5,a3,800039be <writei+0xf6>
{
    800038ce:	7159                	addi	sp,sp,-112
    800038d0:	f486                	sd	ra,104(sp)
    800038d2:	f0a2                	sd	s0,96(sp)
    800038d4:	eca6                	sd	s1,88(sp)
    800038d6:	e8ca                	sd	s2,80(sp)
    800038d8:	e4ce                	sd	s3,72(sp)
    800038da:	e0d2                	sd	s4,64(sp)
    800038dc:	fc56                	sd	s5,56(sp)
    800038de:	f85a                	sd	s6,48(sp)
    800038e0:	f45e                	sd	s7,40(sp)
    800038e2:	f062                	sd	s8,32(sp)
    800038e4:	ec66                	sd	s9,24(sp)
    800038e6:	e86a                	sd	s10,16(sp)
    800038e8:	e46e                	sd	s11,8(sp)
    800038ea:	1880                	addi	s0,sp,112
    800038ec:	8aaa                	mv	s5,a0
    800038ee:	8bae                	mv	s7,a1
    800038f0:	8a32                	mv	s4,a2
    800038f2:	8936                	mv	s2,a3
    800038f4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800038f6:	00e687bb          	addw	a5,a3,a4
    800038fa:	0cd7e463          	bltu	a5,a3,800039c2 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800038fe:	00043737          	lui	a4,0x43
    80003902:	0cf76263          	bltu	a4,a5,800039c6 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003906:	0a0b0a63          	beqz	s6,800039ba <writei+0xf2>
    8000390a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000390c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003910:	5c7d                	li	s8,-1
    80003912:	a825                	j	8000394a <writei+0x82>
    80003914:	020d1d93          	slli	s11,s10,0x20
    80003918:	020ddd93          	srli	s11,s11,0x20
    8000391c:	05848793          	addi	a5,s1,88
    80003920:	86ee                	mv	a3,s11
    80003922:	8652                	mv	a2,s4
    80003924:	85de                	mv	a1,s7
    80003926:	953e                	add	a0,a0,a5
    80003928:	929fe0ef          	jal	ra,80002250 <either_copyin>
    8000392c:	05850a63          	beq	a0,s8,80003980 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003930:	8526                	mv	a0,s1
    80003932:	688000ef          	jal	ra,80003fba <log_write>
    brelse(bp);
    80003936:	8526                	mv	a0,s1
    80003938:	d76ff0ef          	jal	ra,80002eae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000393c:	013d09bb          	addw	s3,s10,s3
    80003940:	012d093b          	addw	s2,s10,s2
    80003944:	9a6e                	add	s4,s4,s11
    80003946:	0569f063          	bgeu	s3,s6,80003986 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000394a:	00a9559b          	srliw	a1,s2,0xa
    8000394e:	8556                	mv	a0,s5
    80003950:	fd0ff0ef          	jal	ra,80003120 <bmap>
    80003954:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003958:	c59d                	beqz	a1,80003986 <writei+0xbe>
    bp = bread(ip->dev, addr);
    8000395a:	000aa503          	lw	a0,0(s5)
    8000395e:	c48ff0ef          	jal	ra,80002da6 <bread>
    80003962:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003964:	3ff97513          	andi	a0,s2,1023
    80003968:	40ac87bb          	subw	a5,s9,a0
    8000396c:	413b073b          	subw	a4,s6,s3
    80003970:	8d3e                	mv	s10,a5
    80003972:	2781                	sext.w	a5,a5
    80003974:	0007069b          	sext.w	a3,a4
    80003978:	f8f6fee3          	bgeu	a3,a5,80003914 <writei+0x4c>
    8000397c:	8d3a                	mv	s10,a4
    8000397e:	bf59                	j	80003914 <writei+0x4c>
      brelse(bp);
    80003980:	8526                	mv	a0,s1
    80003982:	d2cff0ef          	jal	ra,80002eae <brelse>
  }

  if(off > ip->size)
    80003986:	04caa783          	lw	a5,76(s5)
    8000398a:	0127f463          	bgeu	a5,s2,80003992 <writei+0xca>
    ip->size = off;
    8000398e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003992:	8556                	mv	a0,s5
    80003994:	a13ff0ef          	jal	ra,800033a6 <iupdate>

  return tot;
    80003998:	0009851b          	sext.w	a0,s3
}
    8000399c:	70a6                	ld	ra,104(sp)
    8000399e:	7406                	ld	s0,96(sp)
    800039a0:	64e6                	ld	s1,88(sp)
    800039a2:	6946                	ld	s2,80(sp)
    800039a4:	69a6                	ld	s3,72(sp)
    800039a6:	6a06                	ld	s4,64(sp)
    800039a8:	7ae2                	ld	s5,56(sp)
    800039aa:	7b42                	ld	s6,48(sp)
    800039ac:	7ba2                	ld	s7,40(sp)
    800039ae:	7c02                	ld	s8,32(sp)
    800039b0:	6ce2                	ld	s9,24(sp)
    800039b2:	6d42                	ld	s10,16(sp)
    800039b4:	6da2                	ld	s11,8(sp)
    800039b6:	6165                	addi	sp,sp,112
    800039b8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039ba:	89da                	mv	s3,s6
    800039bc:	bfd9                	j	80003992 <writei+0xca>
    return -1;
    800039be:	557d                	li	a0,-1
}
    800039c0:	8082                	ret
    return -1;
    800039c2:	557d                	li	a0,-1
    800039c4:	bfe1                	j	8000399c <writei+0xd4>
    return -1;
    800039c6:	557d                	li	a0,-1
    800039c8:	bfd1                	j	8000399c <writei+0xd4>

00000000800039ca <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039ca:	1141                	addi	sp,sp,-16
    800039cc:	e406                	sd	ra,8(sp)
    800039ce:	e022                	sd	s0,0(sp)
    800039d0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039d2:	4639                	li	a2,14
    800039d4:	b38fd0ef          	jal	ra,80000d0c <strncmp>
}
    800039d8:	60a2                	ld	ra,8(sp)
    800039da:	6402                	ld	s0,0(sp)
    800039dc:	0141                	addi	sp,sp,16
    800039de:	8082                	ret

00000000800039e0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800039e0:	7139                	addi	sp,sp,-64
    800039e2:	fc06                	sd	ra,56(sp)
    800039e4:	f822                	sd	s0,48(sp)
    800039e6:	f426                	sd	s1,40(sp)
    800039e8:	f04a                	sd	s2,32(sp)
    800039ea:	ec4e                	sd	s3,24(sp)
    800039ec:	e852                	sd	s4,16(sp)
    800039ee:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800039f0:	04451703          	lh	a4,68(a0)
    800039f4:	4785                	li	a5,1
    800039f6:	00f71a63          	bne	a4,a5,80003a0a <dirlookup+0x2a>
    800039fa:	892a                	mv	s2,a0
    800039fc:	89ae                	mv	s3,a1
    800039fe:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a00:	457c                	lw	a5,76(a0)
    80003a02:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a04:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a06:	e39d                	bnez	a5,80003a2c <dirlookup+0x4c>
    80003a08:	a095                	j	80003a6c <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003a0a:	00004517          	auipc	a0,0x4
    80003a0e:	ca650513          	addi	a0,a0,-858 # 800076b0 <syscalls+0x2c0>
    80003a12:	d79fc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    80003a16:	00004517          	auipc	a0,0x4
    80003a1a:	cb250513          	addi	a0,a0,-846 # 800076c8 <syscalls+0x2d8>
    80003a1e:	d6dfc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a22:	24c1                	addiw	s1,s1,16
    80003a24:	04c92783          	lw	a5,76(s2)
    80003a28:	04f4f163          	bgeu	s1,a5,80003a6a <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a2c:	4741                	li	a4,16
    80003a2e:	86a6                	mv	a3,s1
    80003a30:	fc040613          	addi	a2,s0,-64
    80003a34:	4581                	li	a1,0
    80003a36:	854a                	mv	a0,s2
    80003a38:	dadff0ef          	jal	ra,800037e4 <readi>
    80003a3c:	47c1                	li	a5,16
    80003a3e:	fcf51ce3          	bne	a0,a5,80003a16 <dirlookup+0x36>
    if(de.inum == 0)
    80003a42:	fc045783          	lhu	a5,-64(s0)
    80003a46:	dff1                	beqz	a5,80003a22 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003a48:	fc240593          	addi	a1,s0,-62
    80003a4c:	854e                	mv	a0,s3
    80003a4e:	f7dff0ef          	jal	ra,800039ca <namecmp>
    80003a52:	f961                	bnez	a0,80003a22 <dirlookup+0x42>
      if(poff)
    80003a54:	000a0463          	beqz	s4,80003a5c <dirlookup+0x7c>
        *poff = off;
    80003a58:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003a5c:	fc045583          	lhu	a1,-64(s0)
    80003a60:	00092503          	lw	a0,0(s2)
    80003a64:	f88ff0ef          	jal	ra,800031ec <iget>
    80003a68:	a011                	j	80003a6c <dirlookup+0x8c>
  return 0;
    80003a6a:	4501                	li	a0,0
}
    80003a6c:	70e2                	ld	ra,56(sp)
    80003a6e:	7442                	ld	s0,48(sp)
    80003a70:	74a2                	ld	s1,40(sp)
    80003a72:	7902                	ld	s2,32(sp)
    80003a74:	69e2                	ld	s3,24(sp)
    80003a76:	6a42                	ld	s4,16(sp)
    80003a78:	6121                	addi	sp,sp,64
    80003a7a:	8082                	ret

0000000080003a7c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003a7c:	711d                	addi	sp,sp,-96
    80003a7e:	ec86                	sd	ra,88(sp)
    80003a80:	e8a2                	sd	s0,80(sp)
    80003a82:	e4a6                	sd	s1,72(sp)
    80003a84:	e0ca                	sd	s2,64(sp)
    80003a86:	fc4e                	sd	s3,56(sp)
    80003a88:	f852                	sd	s4,48(sp)
    80003a8a:	f456                	sd	s5,40(sp)
    80003a8c:	f05a                	sd	s6,32(sp)
    80003a8e:	ec5e                	sd	s7,24(sp)
    80003a90:	e862                	sd	s8,16(sp)
    80003a92:	e466                	sd	s9,8(sp)
    80003a94:	1080                	addi	s0,sp,96
    80003a96:	84aa                	mv	s1,a0
    80003a98:	8aae                	mv	s5,a1
    80003a9a:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a9c:	00054703          	lbu	a4,0(a0)
    80003aa0:	02f00793          	li	a5,47
    80003aa4:	00f70f63          	beq	a4,a5,80003ac2 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003aa8:	d61fd0ef          	jal	ra,80001808 <myproc>
    80003aac:	15053503          	ld	a0,336(a0)
    80003ab0:	973ff0ef          	jal	ra,80003422 <idup>
    80003ab4:	89aa                	mv	s3,a0
  while(*path == '/')
    80003ab6:	02f00913          	li	s2,47
  len = path - s;
    80003aba:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003abc:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003abe:	4b85                	li	s7,1
    80003ac0:	a861                	j	80003b58 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    80003ac2:	4585                	li	a1,1
    80003ac4:	4505                	li	a0,1
    80003ac6:	f26ff0ef          	jal	ra,800031ec <iget>
    80003aca:	89aa                	mv	s3,a0
    80003acc:	b7ed                	j	80003ab6 <namex+0x3a>
      iunlockput(ip);
    80003ace:	854e                	mv	a0,s3
    80003ad0:	b8fff0ef          	jal	ra,8000365e <iunlockput>
      return 0;
    80003ad4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ad6:	854e                	mv	a0,s3
    80003ad8:	60e6                	ld	ra,88(sp)
    80003ada:	6446                	ld	s0,80(sp)
    80003adc:	64a6                	ld	s1,72(sp)
    80003ade:	6906                	ld	s2,64(sp)
    80003ae0:	79e2                	ld	s3,56(sp)
    80003ae2:	7a42                	ld	s4,48(sp)
    80003ae4:	7aa2                	ld	s5,40(sp)
    80003ae6:	7b02                	ld	s6,32(sp)
    80003ae8:	6be2                	ld	s7,24(sp)
    80003aea:	6c42                	ld	s8,16(sp)
    80003aec:	6ca2                	ld	s9,8(sp)
    80003aee:	6125                	addi	sp,sp,96
    80003af0:	8082                	ret
      iunlock(ip);
    80003af2:	854e                	mv	a0,s3
    80003af4:	a0fff0ef          	jal	ra,80003502 <iunlock>
      return ip;
    80003af8:	bff9                	j	80003ad6 <namex+0x5a>
      iunlockput(ip);
    80003afa:	854e                	mv	a0,s3
    80003afc:	b63ff0ef          	jal	ra,8000365e <iunlockput>
      return 0;
    80003b00:	89e6                	mv	s3,s9
    80003b02:	bfd1                	j	80003ad6 <namex+0x5a>
  len = path - s;
    80003b04:	40b48633          	sub	a2,s1,a1
    80003b08:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003b0c:	079c5c63          	bge	s8,s9,80003b84 <namex+0x108>
    memmove(name, s, DIRSIZ);
    80003b10:	4639                	li	a2,14
    80003b12:	8552                	mv	a0,s4
    80003b14:	988fd0ef          	jal	ra,80000c9c <memmove>
  while(*path == '/')
    80003b18:	0004c783          	lbu	a5,0(s1)
    80003b1c:	01279763          	bne	a5,s2,80003b2a <namex+0xae>
    path++;
    80003b20:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b22:	0004c783          	lbu	a5,0(s1)
    80003b26:	ff278de3          	beq	a5,s2,80003b20 <namex+0xa4>
    ilock(ip);
    80003b2a:	854e                	mv	a0,s3
    80003b2c:	92dff0ef          	jal	ra,80003458 <ilock>
    if(ip->type != T_DIR){
    80003b30:	04499783          	lh	a5,68(s3)
    80003b34:	f9779de3          	bne	a5,s7,80003ace <namex+0x52>
    if(nameiparent && *path == '\0'){
    80003b38:	000a8563          	beqz	s5,80003b42 <namex+0xc6>
    80003b3c:	0004c783          	lbu	a5,0(s1)
    80003b40:	dbcd                	beqz	a5,80003af2 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b42:	865a                	mv	a2,s6
    80003b44:	85d2                	mv	a1,s4
    80003b46:	854e                	mv	a0,s3
    80003b48:	e99ff0ef          	jal	ra,800039e0 <dirlookup>
    80003b4c:	8caa                	mv	s9,a0
    80003b4e:	d555                	beqz	a0,80003afa <namex+0x7e>
    iunlockput(ip);
    80003b50:	854e                	mv	a0,s3
    80003b52:	b0dff0ef          	jal	ra,8000365e <iunlockput>
    ip = next;
    80003b56:	89e6                	mv	s3,s9
  while(*path == '/')
    80003b58:	0004c783          	lbu	a5,0(s1)
    80003b5c:	05279363          	bne	a5,s2,80003ba2 <namex+0x126>
    path++;
    80003b60:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b62:	0004c783          	lbu	a5,0(s1)
    80003b66:	ff278de3          	beq	a5,s2,80003b60 <namex+0xe4>
  if(*path == 0)
    80003b6a:	c78d                	beqz	a5,80003b94 <namex+0x118>
    path++;
    80003b6c:	85a6                	mv	a1,s1
  len = path - s;
    80003b6e:	8cda                	mv	s9,s6
    80003b70:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003b72:	01278963          	beq	a5,s2,80003b84 <namex+0x108>
    80003b76:	d7d9                	beqz	a5,80003b04 <namex+0x88>
    path++;
    80003b78:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003b7a:	0004c783          	lbu	a5,0(s1)
    80003b7e:	ff279ce3          	bne	a5,s2,80003b76 <namex+0xfa>
    80003b82:	b749                	j	80003b04 <namex+0x88>
    memmove(name, s, len);
    80003b84:	2601                	sext.w	a2,a2
    80003b86:	8552                	mv	a0,s4
    80003b88:	914fd0ef          	jal	ra,80000c9c <memmove>
    name[len] = 0;
    80003b8c:	9cd2                	add	s9,s9,s4
    80003b8e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003b92:	b759                	j	80003b18 <namex+0x9c>
  if(nameiparent){
    80003b94:	f40a81e3          	beqz	s5,80003ad6 <namex+0x5a>
    iput(ip);
    80003b98:	854e                	mv	a0,s3
    80003b9a:	a3dff0ef          	jal	ra,800035d6 <iput>
    return 0;
    80003b9e:	4981                	li	s3,0
    80003ba0:	bf1d                	j	80003ad6 <namex+0x5a>
  if(*path == 0)
    80003ba2:	dbed                	beqz	a5,80003b94 <namex+0x118>
  while(*path != '/' && *path != 0)
    80003ba4:	0004c783          	lbu	a5,0(s1)
    80003ba8:	85a6                	mv	a1,s1
    80003baa:	b7f1                	j	80003b76 <namex+0xfa>

0000000080003bac <dirlink>:
{
    80003bac:	7139                	addi	sp,sp,-64
    80003bae:	fc06                	sd	ra,56(sp)
    80003bb0:	f822                	sd	s0,48(sp)
    80003bb2:	f426                	sd	s1,40(sp)
    80003bb4:	f04a                	sd	s2,32(sp)
    80003bb6:	ec4e                	sd	s3,24(sp)
    80003bb8:	e852                	sd	s4,16(sp)
    80003bba:	0080                	addi	s0,sp,64
    80003bbc:	892a                	mv	s2,a0
    80003bbe:	8a2e                	mv	s4,a1
    80003bc0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003bc2:	4601                	li	a2,0
    80003bc4:	e1dff0ef          	jal	ra,800039e0 <dirlookup>
    80003bc8:	e52d                	bnez	a0,80003c32 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bca:	04c92483          	lw	s1,76(s2)
    80003bce:	c48d                	beqz	s1,80003bf8 <dirlink+0x4c>
    80003bd0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bd2:	4741                	li	a4,16
    80003bd4:	86a6                	mv	a3,s1
    80003bd6:	fc040613          	addi	a2,s0,-64
    80003bda:	4581                	li	a1,0
    80003bdc:	854a                	mv	a0,s2
    80003bde:	c07ff0ef          	jal	ra,800037e4 <readi>
    80003be2:	47c1                	li	a5,16
    80003be4:	04f51b63          	bne	a0,a5,80003c3a <dirlink+0x8e>
    if(de.inum == 0)
    80003be8:	fc045783          	lhu	a5,-64(s0)
    80003bec:	c791                	beqz	a5,80003bf8 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bee:	24c1                	addiw	s1,s1,16
    80003bf0:	04c92783          	lw	a5,76(s2)
    80003bf4:	fcf4efe3          	bltu	s1,a5,80003bd2 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003bf8:	4639                	li	a2,14
    80003bfa:	85d2                	mv	a1,s4
    80003bfc:	fc240513          	addi	a0,s0,-62
    80003c00:	948fd0ef          	jal	ra,80000d48 <strncpy>
  de.inum = inum;
    80003c04:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c08:	4741                	li	a4,16
    80003c0a:	86a6                	mv	a3,s1
    80003c0c:	fc040613          	addi	a2,s0,-64
    80003c10:	4581                	li	a1,0
    80003c12:	854a                	mv	a0,s2
    80003c14:	cb5ff0ef          	jal	ra,800038c8 <writei>
    80003c18:	1541                	addi	a0,a0,-16
    80003c1a:	00a03533          	snez	a0,a0
    80003c1e:	40a00533          	neg	a0,a0
}
    80003c22:	70e2                	ld	ra,56(sp)
    80003c24:	7442                	ld	s0,48(sp)
    80003c26:	74a2                	ld	s1,40(sp)
    80003c28:	7902                	ld	s2,32(sp)
    80003c2a:	69e2                	ld	s3,24(sp)
    80003c2c:	6a42                	ld	s4,16(sp)
    80003c2e:	6121                	addi	sp,sp,64
    80003c30:	8082                	ret
    iput(ip);
    80003c32:	9a5ff0ef          	jal	ra,800035d6 <iput>
    return -1;
    80003c36:	557d                	li	a0,-1
    80003c38:	b7ed                	j	80003c22 <dirlink+0x76>
      panic("dirlink read");
    80003c3a:	00004517          	auipc	a0,0x4
    80003c3e:	a9e50513          	addi	a0,a0,-1378 # 800076d8 <syscalls+0x2e8>
    80003c42:	b49fc0ef          	jal	ra,8000078a <panic>

0000000080003c46 <namei>:

struct inode*
namei(char *path)
{
    80003c46:	1101                	addi	sp,sp,-32
    80003c48:	ec06                	sd	ra,24(sp)
    80003c4a:	e822                	sd	s0,16(sp)
    80003c4c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c4e:	fe040613          	addi	a2,s0,-32
    80003c52:	4581                	li	a1,0
    80003c54:	e29ff0ef          	jal	ra,80003a7c <namex>
}
    80003c58:	60e2                	ld	ra,24(sp)
    80003c5a:	6442                	ld	s0,16(sp)
    80003c5c:	6105                	addi	sp,sp,32
    80003c5e:	8082                	ret

0000000080003c60 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003c60:	1141                	addi	sp,sp,-16
    80003c62:	e406                	sd	ra,8(sp)
    80003c64:	e022                	sd	s0,0(sp)
    80003c66:	0800                	addi	s0,sp,16
    80003c68:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c6a:	4585                	li	a1,1
    80003c6c:	e11ff0ef          	jal	ra,80003a7c <namex>
}
    80003c70:	60a2                	ld	ra,8(sp)
    80003c72:	6402                	ld	s0,0(sp)
    80003c74:	0141                	addi	sp,sp,16
    80003c76:	8082                	ret

0000000080003c78 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c78:	1101                	addi	sp,sp,-32
    80003c7a:	ec06                	sd	ra,24(sp)
    80003c7c:	e822                	sd	s0,16(sp)
    80003c7e:	e426                	sd	s1,8(sp)
    80003c80:	e04a                	sd	s2,0(sp)
    80003c82:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c84:	0001c917          	auipc	s2,0x1c
    80003c88:	1a490913          	addi	s2,s2,420 # 8001fe28 <log>
    80003c8c:	01892583          	lw	a1,24(s2)
    80003c90:	02492503          	lw	a0,36(s2)
    80003c94:	912ff0ef          	jal	ra,80002da6 <bread>
    80003c98:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c9a:	02892683          	lw	a3,40(s2)
    80003c9e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ca0:	02d05763          	blez	a3,80003cce <write_head+0x56>
    80003ca4:	0001c797          	auipc	a5,0x1c
    80003ca8:	1b078793          	addi	a5,a5,432 # 8001fe54 <log+0x2c>
    80003cac:	05c50713          	addi	a4,a0,92
    80003cb0:	36fd                	addiw	a3,a3,-1
    80003cb2:	1682                	slli	a3,a3,0x20
    80003cb4:	9281                	srli	a3,a3,0x20
    80003cb6:	068a                	slli	a3,a3,0x2
    80003cb8:	0001c617          	auipc	a2,0x1c
    80003cbc:	1a060613          	addi	a2,a2,416 # 8001fe58 <log+0x30>
    80003cc0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003cc2:	4390                	lw	a2,0(a5)
    80003cc4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003cc6:	0791                	addi	a5,a5,4
    80003cc8:	0711                	addi	a4,a4,4
    80003cca:	fed79ce3          	bne	a5,a3,80003cc2 <write_head+0x4a>
  }
  bwrite(buf);
    80003cce:	8526                	mv	a0,s1
    80003cd0:	9acff0ef          	jal	ra,80002e7c <bwrite>
  brelse(buf);
    80003cd4:	8526                	mv	a0,s1
    80003cd6:	9d8ff0ef          	jal	ra,80002eae <brelse>
}
    80003cda:	60e2                	ld	ra,24(sp)
    80003cdc:	6442                	ld	s0,16(sp)
    80003cde:	64a2                	ld	s1,8(sp)
    80003ce0:	6902                	ld	s2,0(sp)
    80003ce2:	6105                	addi	sp,sp,32
    80003ce4:	8082                	ret

0000000080003ce6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ce6:	0001c797          	auipc	a5,0x1c
    80003cea:	16a7a783          	lw	a5,362(a5) # 8001fe50 <log+0x28>
    80003cee:	0af05e63          	blez	a5,80003daa <install_trans+0xc4>
{
    80003cf2:	715d                	addi	sp,sp,-80
    80003cf4:	e486                	sd	ra,72(sp)
    80003cf6:	e0a2                	sd	s0,64(sp)
    80003cf8:	fc26                	sd	s1,56(sp)
    80003cfa:	f84a                	sd	s2,48(sp)
    80003cfc:	f44e                	sd	s3,40(sp)
    80003cfe:	f052                	sd	s4,32(sp)
    80003d00:	ec56                	sd	s5,24(sp)
    80003d02:	e85a                	sd	s6,16(sp)
    80003d04:	e45e                	sd	s7,8(sp)
    80003d06:	0880                	addi	s0,sp,80
    80003d08:	8b2a                	mv	s6,a0
    80003d0a:	0001ca97          	auipc	s5,0x1c
    80003d0e:	14aa8a93          	addi	s5,s5,330 # 8001fe54 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d12:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d14:	00004b97          	auipc	s7,0x4
    80003d18:	9d4b8b93          	addi	s7,s7,-1580 # 800076e8 <syscalls+0x2f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d1c:	0001ca17          	auipc	s4,0x1c
    80003d20:	10ca0a13          	addi	s4,s4,268 # 8001fe28 <log>
    80003d24:	a025                	j	80003d4c <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d26:	000aa603          	lw	a2,0(s5)
    80003d2a:	85ce                	mv	a1,s3
    80003d2c:	855e                	mv	a0,s7
    80003d2e:	f96fc0ef          	jal	ra,800004c4 <printf>
    80003d32:	a839                	j	80003d50 <install_trans+0x6a>
    brelse(lbuf);
    80003d34:	854a                	mv	a0,s2
    80003d36:	978ff0ef          	jal	ra,80002eae <brelse>
    brelse(dbuf);
    80003d3a:	8526                	mv	a0,s1
    80003d3c:	972ff0ef          	jal	ra,80002eae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d40:	2985                	addiw	s3,s3,1
    80003d42:	0a91                	addi	s5,s5,4
    80003d44:	028a2783          	lw	a5,40(s4)
    80003d48:	04f9d663          	bge	s3,a5,80003d94 <install_trans+0xae>
    if(recovering) {
    80003d4c:	fc0b1de3          	bnez	s6,80003d26 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d50:	018a2583          	lw	a1,24(s4)
    80003d54:	013585bb          	addw	a1,a1,s3
    80003d58:	2585                	addiw	a1,a1,1
    80003d5a:	024a2503          	lw	a0,36(s4)
    80003d5e:	848ff0ef          	jal	ra,80002da6 <bread>
    80003d62:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003d64:	000aa583          	lw	a1,0(s5)
    80003d68:	024a2503          	lw	a0,36(s4)
    80003d6c:	83aff0ef          	jal	ra,80002da6 <bread>
    80003d70:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d72:	40000613          	li	a2,1024
    80003d76:	05890593          	addi	a1,s2,88
    80003d7a:	05850513          	addi	a0,a0,88
    80003d7e:	f1ffc0ef          	jal	ra,80000c9c <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d82:	8526                	mv	a0,s1
    80003d84:	8f8ff0ef          	jal	ra,80002e7c <bwrite>
    if(recovering == 0)
    80003d88:	fa0b16e3          	bnez	s6,80003d34 <install_trans+0x4e>
      bunpin(dbuf);
    80003d8c:	8526                	mv	a0,s1
    80003d8e:	9deff0ef          	jal	ra,80002f6c <bunpin>
    80003d92:	b74d                	j	80003d34 <install_trans+0x4e>
}
    80003d94:	60a6                	ld	ra,72(sp)
    80003d96:	6406                	ld	s0,64(sp)
    80003d98:	74e2                	ld	s1,56(sp)
    80003d9a:	7942                	ld	s2,48(sp)
    80003d9c:	79a2                	ld	s3,40(sp)
    80003d9e:	7a02                	ld	s4,32(sp)
    80003da0:	6ae2                	ld	s5,24(sp)
    80003da2:	6b42                	ld	s6,16(sp)
    80003da4:	6ba2                	ld	s7,8(sp)
    80003da6:	6161                	addi	sp,sp,80
    80003da8:	8082                	ret
    80003daa:	8082                	ret

0000000080003dac <initlog>:
{
    80003dac:	7179                	addi	sp,sp,-48
    80003dae:	f406                	sd	ra,40(sp)
    80003db0:	f022                	sd	s0,32(sp)
    80003db2:	ec26                	sd	s1,24(sp)
    80003db4:	e84a                	sd	s2,16(sp)
    80003db6:	e44e                	sd	s3,8(sp)
    80003db8:	1800                	addi	s0,sp,48
    80003dba:	892a                	mv	s2,a0
    80003dbc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003dbe:	0001c497          	auipc	s1,0x1c
    80003dc2:	06a48493          	addi	s1,s1,106 # 8001fe28 <log>
    80003dc6:	00004597          	auipc	a1,0x4
    80003dca:	94258593          	addi	a1,a1,-1726 # 80007708 <syscalls+0x318>
    80003dce:	8526                	mv	a0,s1
    80003dd0:	d1dfc0ef          	jal	ra,80000aec <initlock>
  log.start = sb->logstart;
    80003dd4:	0149a583          	lw	a1,20(s3)
    80003dd8:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003dda:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003dde:	854a                	mv	a0,s2
    80003de0:	fc7fe0ef          	jal	ra,80002da6 <bread>
  log.lh.n = lh->n;
    80003de4:	4d34                	lw	a3,88(a0)
    80003de6:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003de8:	02d05563          	blez	a3,80003e12 <initlog+0x66>
    80003dec:	05c50793          	addi	a5,a0,92
    80003df0:	0001c717          	auipc	a4,0x1c
    80003df4:	06470713          	addi	a4,a4,100 # 8001fe54 <log+0x2c>
    80003df8:	36fd                	addiw	a3,a3,-1
    80003dfa:	1682                	slli	a3,a3,0x20
    80003dfc:	9281                	srli	a3,a3,0x20
    80003dfe:	068a                	slli	a3,a3,0x2
    80003e00:	06050613          	addi	a2,a0,96
    80003e04:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003e06:	4390                	lw	a2,0(a5)
    80003e08:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e0a:	0791                	addi	a5,a5,4
    80003e0c:	0711                	addi	a4,a4,4
    80003e0e:	fed79ce3          	bne	a5,a3,80003e06 <initlog+0x5a>
  brelse(buf);
    80003e12:	89cff0ef          	jal	ra,80002eae <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e16:	4505                	li	a0,1
    80003e18:	ecfff0ef          	jal	ra,80003ce6 <install_trans>
  log.lh.n = 0;
    80003e1c:	0001c797          	auipc	a5,0x1c
    80003e20:	0207aa23          	sw	zero,52(a5) # 8001fe50 <log+0x28>
  write_head(); // clear the log
    80003e24:	e55ff0ef          	jal	ra,80003c78 <write_head>
}
    80003e28:	70a2                	ld	ra,40(sp)
    80003e2a:	7402                	ld	s0,32(sp)
    80003e2c:	64e2                	ld	s1,24(sp)
    80003e2e:	6942                	ld	s2,16(sp)
    80003e30:	69a2                	ld	s3,8(sp)
    80003e32:	6145                	addi	sp,sp,48
    80003e34:	8082                	ret

0000000080003e36 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e36:	1101                	addi	sp,sp,-32
    80003e38:	ec06                	sd	ra,24(sp)
    80003e3a:	e822                	sd	s0,16(sp)
    80003e3c:	e426                	sd	s1,8(sp)
    80003e3e:	e04a                	sd	s2,0(sp)
    80003e40:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e42:	0001c517          	auipc	a0,0x1c
    80003e46:	fe650513          	addi	a0,a0,-26 # 8001fe28 <log>
    80003e4a:	d23fc0ef          	jal	ra,80000b6c <acquire>
  while(1){
    if(log.committing){
    80003e4e:	0001c497          	auipc	s1,0x1c
    80003e52:	fda48493          	addi	s1,s1,-38 # 8001fe28 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e56:	4979                	li	s2,30
    80003e58:	a029                	j	80003e62 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003e5a:	85a6                	mv	a1,s1
    80003e5c:	8526                	mv	a0,s1
    80003e5e:	84cfe0ef          	jal	ra,80001eaa <sleep>
    if(log.committing){
    80003e62:	509c                	lw	a5,32(s1)
    80003e64:	fbfd                	bnez	a5,80003e5a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e66:	4cdc                	lw	a5,28(s1)
    80003e68:	0017871b          	addiw	a4,a5,1
    80003e6c:	0007069b          	sext.w	a3,a4
    80003e70:	0027179b          	slliw	a5,a4,0x2
    80003e74:	9fb9                	addw	a5,a5,a4
    80003e76:	0017979b          	slliw	a5,a5,0x1
    80003e7a:	5498                	lw	a4,40(s1)
    80003e7c:	9fb9                	addw	a5,a5,a4
    80003e7e:	00f95763          	bge	s2,a5,80003e8c <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003e82:	85a6                	mv	a1,s1
    80003e84:	8526                	mv	a0,s1
    80003e86:	824fe0ef          	jal	ra,80001eaa <sleep>
    80003e8a:	bfe1                	j	80003e62 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e8c:	0001c517          	auipc	a0,0x1c
    80003e90:	f9c50513          	addi	a0,a0,-100 # 8001fe28 <log>
    80003e94:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003e96:	d6ffc0ef          	jal	ra,80000c04 <release>
      break;
    }
  }
}
    80003e9a:	60e2                	ld	ra,24(sp)
    80003e9c:	6442                	ld	s0,16(sp)
    80003e9e:	64a2                	ld	s1,8(sp)
    80003ea0:	6902                	ld	s2,0(sp)
    80003ea2:	6105                	addi	sp,sp,32
    80003ea4:	8082                	ret

0000000080003ea6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ea6:	7139                	addi	sp,sp,-64
    80003ea8:	fc06                	sd	ra,56(sp)
    80003eaa:	f822                	sd	s0,48(sp)
    80003eac:	f426                	sd	s1,40(sp)
    80003eae:	f04a                	sd	s2,32(sp)
    80003eb0:	ec4e                	sd	s3,24(sp)
    80003eb2:	e852                	sd	s4,16(sp)
    80003eb4:	e456                	sd	s5,8(sp)
    80003eb6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003eb8:	0001c497          	auipc	s1,0x1c
    80003ebc:	f7048493          	addi	s1,s1,-144 # 8001fe28 <log>
    80003ec0:	8526                	mv	a0,s1
    80003ec2:	cabfc0ef          	jal	ra,80000b6c <acquire>
  log.outstanding -= 1;
    80003ec6:	4cdc                	lw	a5,28(s1)
    80003ec8:	37fd                	addiw	a5,a5,-1
    80003eca:	0007891b          	sext.w	s2,a5
    80003ece:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003ed0:	509c                	lw	a5,32(s1)
    80003ed2:	ef9d                	bnez	a5,80003f10 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003ed4:	04091463          	bnez	s2,80003f1c <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003ed8:	0001c497          	auipc	s1,0x1c
    80003edc:	f5048493          	addi	s1,s1,-176 # 8001fe28 <log>
    80003ee0:	4785                	li	a5,1
    80003ee2:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003ee4:	8526                	mv	a0,s1
    80003ee6:	d1ffc0ef          	jal	ra,80000c04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003eea:	549c                	lw	a5,40(s1)
    80003eec:	04f04b63          	bgtz	a5,80003f42 <end_op+0x9c>
    acquire(&log.lock);
    80003ef0:	0001c497          	auipc	s1,0x1c
    80003ef4:	f3848493          	addi	s1,s1,-200 # 8001fe28 <log>
    80003ef8:	8526                	mv	a0,s1
    80003efa:	c73fc0ef          	jal	ra,80000b6c <acquire>
    log.committing = 0;
    80003efe:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003f02:	8526                	mv	a0,s1
    80003f04:	ff3fd0ef          	jal	ra,80001ef6 <wakeup>
    release(&log.lock);
    80003f08:	8526                	mv	a0,s1
    80003f0a:	cfbfc0ef          	jal	ra,80000c04 <release>
}
    80003f0e:	a00d                	j	80003f30 <end_op+0x8a>
    panic("log.committing");
    80003f10:	00004517          	auipc	a0,0x4
    80003f14:	80050513          	addi	a0,a0,-2048 # 80007710 <syscalls+0x320>
    80003f18:	873fc0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    80003f1c:	0001c497          	auipc	s1,0x1c
    80003f20:	f0c48493          	addi	s1,s1,-244 # 8001fe28 <log>
    80003f24:	8526                	mv	a0,s1
    80003f26:	fd1fd0ef          	jal	ra,80001ef6 <wakeup>
  release(&log.lock);
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	cd9fc0ef          	jal	ra,80000c04 <release>
}
    80003f30:	70e2                	ld	ra,56(sp)
    80003f32:	7442                	ld	s0,48(sp)
    80003f34:	74a2                	ld	s1,40(sp)
    80003f36:	7902                	ld	s2,32(sp)
    80003f38:	69e2                	ld	s3,24(sp)
    80003f3a:	6a42                	ld	s4,16(sp)
    80003f3c:	6aa2                	ld	s5,8(sp)
    80003f3e:	6121                	addi	sp,sp,64
    80003f40:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f42:	0001ca97          	auipc	s5,0x1c
    80003f46:	f12a8a93          	addi	s5,s5,-238 # 8001fe54 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f4a:	0001ca17          	auipc	s4,0x1c
    80003f4e:	edea0a13          	addi	s4,s4,-290 # 8001fe28 <log>
    80003f52:	018a2583          	lw	a1,24(s4)
    80003f56:	012585bb          	addw	a1,a1,s2
    80003f5a:	2585                	addiw	a1,a1,1
    80003f5c:	024a2503          	lw	a0,36(s4)
    80003f60:	e47fe0ef          	jal	ra,80002da6 <bread>
    80003f64:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f66:	000aa583          	lw	a1,0(s5)
    80003f6a:	024a2503          	lw	a0,36(s4)
    80003f6e:	e39fe0ef          	jal	ra,80002da6 <bread>
    80003f72:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f74:	40000613          	li	a2,1024
    80003f78:	05850593          	addi	a1,a0,88
    80003f7c:	05848513          	addi	a0,s1,88
    80003f80:	d1dfc0ef          	jal	ra,80000c9c <memmove>
    bwrite(to);  // write the log
    80003f84:	8526                	mv	a0,s1
    80003f86:	ef7fe0ef          	jal	ra,80002e7c <bwrite>
    brelse(from);
    80003f8a:	854e                	mv	a0,s3
    80003f8c:	f23fe0ef          	jal	ra,80002eae <brelse>
    brelse(to);
    80003f90:	8526                	mv	a0,s1
    80003f92:	f1dfe0ef          	jal	ra,80002eae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f96:	2905                	addiw	s2,s2,1
    80003f98:	0a91                	addi	s5,s5,4
    80003f9a:	028a2783          	lw	a5,40(s4)
    80003f9e:	faf94ae3          	blt	s2,a5,80003f52 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003fa2:	cd7ff0ef          	jal	ra,80003c78 <write_head>
    install_trans(0); // Now install writes to home locations
    80003fa6:	4501                	li	a0,0
    80003fa8:	d3fff0ef          	jal	ra,80003ce6 <install_trans>
    log.lh.n = 0;
    80003fac:	0001c797          	auipc	a5,0x1c
    80003fb0:	ea07a223          	sw	zero,-348(a5) # 8001fe50 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003fb4:	cc5ff0ef          	jal	ra,80003c78 <write_head>
    80003fb8:	bf25                	j	80003ef0 <end_op+0x4a>

0000000080003fba <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003fba:	1101                	addi	sp,sp,-32
    80003fbc:	ec06                	sd	ra,24(sp)
    80003fbe:	e822                	sd	s0,16(sp)
    80003fc0:	e426                	sd	s1,8(sp)
    80003fc2:	e04a                	sd	s2,0(sp)
    80003fc4:	1000                	addi	s0,sp,32
    80003fc6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fc8:	0001c917          	auipc	s2,0x1c
    80003fcc:	e6090913          	addi	s2,s2,-416 # 8001fe28 <log>
    80003fd0:	854a                	mv	a0,s2
    80003fd2:	b9bfc0ef          	jal	ra,80000b6c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003fd6:	02892603          	lw	a2,40(s2)
    80003fda:	47f5                	li	a5,29
    80003fdc:	04c7cc63          	blt	a5,a2,80004034 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003fe0:	0001c797          	auipc	a5,0x1c
    80003fe4:	e647a783          	lw	a5,-412(a5) # 8001fe44 <log+0x1c>
    80003fe8:	04f05c63          	blez	a5,80004040 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003fec:	4781                	li	a5,0
    80003fee:	04c05f63          	blez	a2,8000404c <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ff2:	44cc                	lw	a1,12(s1)
    80003ff4:	0001c717          	auipc	a4,0x1c
    80003ff8:	e6070713          	addi	a4,a4,-416 # 8001fe54 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003ffc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ffe:	4314                	lw	a3,0(a4)
    80004000:	04b68663          	beq	a3,a1,8000404c <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004004:	2785                	addiw	a5,a5,1
    80004006:	0711                	addi	a4,a4,4
    80004008:	fef61be3          	bne	a2,a5,80003ffe <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000400c:	0621                	addi	a2,a2,8
    8000400e:	060a                	slli	a2,a2,0x2
    80004010:	0001c797          	auipc	a5,0x1c
    80004014:	e1878793          	addi	a5,a5,-488 # 8001fe28 <log>
    80004018:	963e                	add	a2,a2,a5
    8000401a:	44dc                	lw	a5,12(s1)
    8000401c:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000401e:	8526                	mv	a0,s1
    80004020:	f19fe0ef          	jal	ra,80002f38 <bpin>
    log.lh.n++;
    80004024:	0001c717          	auipc	a4,0x1c
    80004028:	e0470713          	addi	a4,a4,-508 # 8001fe28 <log>
    8000402c:	571c                	lw	a5,40(a4)
    8000402e:	2785                	addiw	a5,a5,1
    80004030:	d71c                	sw	a5,40(a4)
    80004032:	a815                	j	80004066 <log_write+0xac>
    panic("too big a transaction");
    80004034:	00003517          	auipc	a0,0x3
    80004038:	6ec50513          	addi	a0,a0,1772 # 80007720 <syscalls+0x330>
    8000403c:	f4efc0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    80004040:	00003517          	auipc	a0,0x3
    80004044:	6f850513          	addi	a0,a0,1784 # 80007738 <syscalls+0x348>
    80004048:	f42fc0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    8000404c:	00878713          	addi	a4,a5,8
    80004050:	00271693          	slli	a3,a4,0x2
    80004054:	0001c717          	auipc	a4,0x1c
    80004058:	dd470713          	addi	a4,a4,-556 # 8001fe28 <log>
    8000405c:	9736                	add	a4,a4,a3
    8000405e:	44d4                	lw	a3,12(s1)
    80004060:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004062:	faf60ee3          	beq	a2,a5,8000401e <log_write+0x64>
  }
  release(&log.lock);
    80004066:	0001c517          	auipc	a0,0x1c
    8000406a:	dc250513          	addi	a0,a0,-574 # 8001fe28 <log>
    8000406e:	b97fc0ef          	jal	ra,80000c04 <release>
}
    80004072:	60e2                	ld	ra,24(sp)
    80004074:	6442                	ld	s0,16(sp)
    80004076:	64a2                	ld	s1,8(sp)
    80004078:	6902                	ld	s2,0(sp)
    8000407a:	6105                	addi	sp,sp,32
    8000407c:	8082                	ret

000000008000407e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000407e:	1101                	addi	sp,sp,-32
    80004080:	ec06                	sd	ra,24(sp)
    80004082:	e822                	sd	s0,16(sp)
    80004084:	e426                	sd	s1,8(sp)
    80004086:	e04a                	sd	s2,0(sp)
    80004088:	1000                	addi	s0,sp,32
    8000408a:	84aa                	mv	s1,a0
    8000408c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000408e:	00003597          	auipc	a1,0x3
    80004092:	6ca58593          	addi	a1,a1,1738 # 80007758 <syscalls+0x368>
    80004096:	0521                	addi	a0,a0,8
    80004098:	a55fc0ef          	jal	ra,80000aec <initlock>
  lk->name = name;
    8000409c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800040a0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040a4:	0204a423          	sw	zero,40(s1)
}
    800040a8:	60e2                	ld	ra,24(sp)
    800040aa:	6442                	ld	s0,16(sp)
    800040ac:	64a2                	ld	s1,8(sp)
    800040ae:	6902                	ld	s2,0(sp)
    800040b0:	6105                	addi	sp,sp,32
    800040b2:	8082                	ret

00000000800040b4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800040b4:	1101                	addi	sp,sp,-32
    800040b6:	ec06                	sd	ra,24(sp)
    800040b8:	e822                	sd	s0,16(sp)
    800040ba:	e426                	sd	s1,8(sp)
    800040bc:	e04a                	sd	s2,0(sp)
    800040be:	1000                	addi	s0,sp,32
    800040c0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040c2:	00850913          	addi	s2,a0,8
    800040c6:	854a                	mv	a0,s2
    800040c8:	aa5fc0ef          	jal	ra,80000b6c <acquire>
  while (lk->locked) {
    800040cc:	409c                	lw	a5,0(s1)
    800040ce:	c799                	beqz	a5,800040dc <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800040d0:	85ca                	mv	a1,s2
    800040d2:	8526                	mv	a0,s1
    800040d4:	dd7fd0ef          	jal	ra,80001eaa <sleep>
  while (lk->locked) {
    800040d8:	409c                	lw	a5,0(s1)
    800040da:	fbfd                	bnez	a5,800040d0 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040dc:	4785                	li	a5,1
    800040de:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800040e0:	f28fd0ef          	jal	ra,80001808 <myproc>
    800040e4:	591c                	lw	a5,48(a0)
    800040e6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800040e8:	854a                	mv	a0,s2
    800040ea:	b1bfc0ef          	jal	ra,80000c04 <release>
}
    800040ee:	60e2                	ld	ra,24(sp)
    800040f0:	6442                	ld	s0,16(sp)
    800040f2:	64a2                	ld	s1,8(sp)
    800040f4:	6902                	ld	s2,0(sp)
    800040f6:	6105                	addi	sp,sp,32
    800040f8:	8082                	ret

00000000800040fa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800040fa:	1101                	addi	sp,sp,-32
    800040fc:	ec06                	sd	ra,24(sp)
    800040fe:	e822                	sd	s0,16(sp)
    80004100:	e426                	sd	s1,8(sp)
    80004102:	e04a                	sd	s2,0(sp)
    80004104:	1000                	addi	s0,sp,32
    80004106:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004108:	00850913          	addi	s2,a0,8
    8000410c:	854a                	mv	a0,s2
    8000410e:	a5ffc0ef          	jal	ra,80000b6c <acquire>
  lk->locked = 0;
    80004112:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004116:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000411a:	8526                	mv	a0,s1
    8000411c:	ddbfd0ef          	jal	ra,80001ef6 <wakeup>
  release(&lk->lk);
    80004120:	854a                	mv	a0,s2
    80004122:	ae3fc0ef          	jal	ra,80000c04 <release>
}
    80004126:	60e2                	ld	ra,24(sp)
    80004128:	6442                	ld	s0,16(sp)
    8000412a:	64a2                	ld	s1,8(sp)
    8000412c:	6902                	ld	s2,0(sp)
    8000412e:	6105                	addi	sp,sp,32
    80004130:	8082                	ret

0000000080004132 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004132:	7179                	addi	sp,sp,-48
    80004134:	f406                	sd	ra,40(sp)
    80004136:	f022                	sd	s0,32(sp)
    80004138:	ec26                	sd	s1,24(sp)
    8000413a:	e84a                	sd	s2,16(sp)
    8000413c:	e44e                	sd	s3,8(sp)
    8000413e:	1800                	addi	s0,sp,48
    80004140:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004142:	00850913          	addi	s2,a0,8
    80004146:	854a                	mv	a0,s2
    80004148:	a25fc0ef          	jal	ra,80000b6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000414c:	409c                	lw	a5,0(s1)
    8000414e:	ef89                	bnez	a5,80004168 <holdingsleep+0x36>
    80004150:	4481                	li	s1,0
  release(&lk->lk);
    80004152:	854a                	mv	a0,s2
    80004154:	ab1fc0ef          	jal	ra,80000c04 <release>
  return r;
}
    80004158:	8526                	mv	a0,s1
    8000415a:	70a2                	ld	ra,40(sp)
    8000415c:	7402                	ld	s0,32(sp)
    8000415e:	64e2                	ld	s1,24(sp)
    80004160:	6942                	ld	s2,16(sp)
    80004162:	69a2                	ld	s3,8(sp)
    80004164:	6145                	addi	sp,sp,48
    80004166:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004168:	0284a983          	lw	s3,40(s1)
    8000416c:	e9cfd0ef          	jal	ra,80001808 <myproc>
    80004170:	5904                	lw	s1,48(a0)
    80004172:	413484b3          	sub	s1,s1,s3
    80004176:	0014b493          	seqz	s1,s1
    8000417a:	bfe1                	j	80004152 <holdingsleep+0x20>

000000008000417c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000417c:	1141                	addi	sp,sp,-16
    8000417e:	e406                	sd	ra,8(sp)
    80004180:	e022                	sd	s0,0(sp)
    80004182:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004184:	00003597          	auipc	a1,0x3
    80004188:	5e458593          	addi	a1,a1,1508 # 80007768 <syscalls+0x378>
    8000418c:	0001c517          	auipc	a0,0x1c
    80004190:	de450513          	addi	a0,a0,-540 # 8001ff70 <ftable>
    80004194:	959fc0ef          	jal	ra,80000aec <initlock>
}
    80004198:	60a2                	ld	ra,8(sp)
    8000419a:	6402                	ld	s0,0(sp)
    8000419c:	0141                	addi	sp,sp,16
    8000419e:	8082                	ret

00000000800041a0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800041a0:	1101                	addi	sp,sp,-32
    800041a2:	ec06                	sd	ra,24(sp)
    800041a4:	e822                	sd	s0,16(sp)
    800041a6:	e426                	sd	s1,8(sp)
    800041a8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800041aa:	0001c517          	auipc	a0,0x1c
    800041ae:	dc650513          	addi	a0,a0,-570 # 8001ff70 <ftable>
    800041b2:	9bbfc0ef          	jal	ra,80000b6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041b6:	0001c497          	auipc	s1,0x1c
    800041ba:	dd248493          	addi	s1,s1,-558 # 8001ff88 <ftable+0x18>
    800041be:	0001d717          	auipc	a4,0x1d
    800041c2:	d6a70713          	addi	a4,a4,-662 # 80020f28 <disk>
    if(f->ref == 0){
    800041c6:	40dc                	lw	a5,4(s1)
    800041c8:	cf89                	beqz	a5,800041e2 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041ca:	02848493          	addi	s1,s1,40
    800041ce:	fee49ce3          	bne	s1,a4,800041c6 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041d2:	0001c517          	auipc	a0,0x1c
    800041d6:	d9e50513          	addi	a0,a0,-610 # 8001ff70 <ftable>
    800041da:	a2bfc0ef          	jal	ra,80000c04 <release>
  return 0;
    800041de:	4481                	li	s1,0
    800041e0:	a809                	j	800041f2 <filealloc+0x52>
      f->ref = 1;
    800041e2:	4785                	li	a5,1
    800041e4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800041e6:	0001c517          	auipc	a0,0x1c
    800041ea:	d8a50513          	addi	a0,a0,-630 # 8001ff70 <ftable>
    800041ee:	a17fc0ef          	jal	ra,80000c04 <release>
}
    800041f2:	8526                	mv	a0,s1
    800041f4:	60e2                	ld	ra,24(sp)
    800041f6:	6442                	ld	s0,16(sp)
    800041f8:	64a2                	ld	s1,8(sp)
    800041fa:	6105                	addi	sp,sp,32
    800041fc:	8082                	ret

00000000800041fe <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800041fe:	1101                	addi	sp,sp,-32
    80004200:	ec06                	sd	ra,24(sp)
    80004202:	e822                	sd	s0,16(sp)
    80004204:	e426                	sd	s1,8(sp)
    80004206:	1000                	addi	s0,sp,32
    80004208:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000420a:	0001c517          	auipc	a0,0x1c
    8000420e:	d6650513          	addi	a0,a0,-666 # 8001ff70 <ftable>
    80004212:	95bfc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    80004216:	40dc                	lw	a5,4(s1)
    80004218:	02f05063          	blez	a5,80004238 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000421c:	2785                	addiw	a5,a5,1
    8000421e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004220:	0001c517          	auipc	a0,0x1c
    80004224:	d5050513          	addi	a0,a0,-688 # 8001ff70 <ftable>
    80004228:	9ddfc0ef          	jal	ra,80000c04 <release>
  return f;
}
    8000422c:	8526                	mv	a0,s1
    8000422e:	60e2                	ld	ra,24(sp)
    80004230:	6442                	ld	s0,16(sp)
    80004232:	64a2                	ld	s1,8(sp)
    80004234:	6105                	addi	sp,sp,32
    80004236:	8082                	ret
    panic("filedup");
    80004238:	00003517          	auipc	a0,0x3
    8000423c:	53850513          	addi	a0,a0,1336 # 80007770 <syscalls+0x380>
    80004240:	d4afc0ef          	jal	ra,8000078a <panic>

0000000080004244 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004244:	7139                	addi	sp,sp,-64
    80004246:	fc06                	sd	ra,56(sp)
    80004248:	f822                	sd	s0,48(sp)
    8000424a:	f426                	sd	s1,40(sp)
    8000424c:	f04a                	sd	s2,32(sp)
    8000424e:	ec4e                	sd	s3,24(sp)
    80004250:	e852                	sd	s4,16(sp)
    80004252:	e456                	sd	s5,8(sp)
    80004254:	0080                	addi	s0,sp,64
    80004256:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004258:	0001c517          	auipc	a0,0x1c
    8000425c:	d1850513          	addi	a0,a0,-744 # 8001ff70 <ftable>
    80004260:	90dfc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    80004264:	40dc                	lw	a5,4(s1)
    80004266:	04f05963          	blez	a5,800042b8 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    8000426a:	37fd                	addiw	a5,a5,-1
    8000426c:	0007871b          	sext.w	a4,a5
    80004270:	c0dc                	sw	a5,4(s1)
    80004272:	04e04963          	bgtz	a4,800042c4 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004276:	0004a903          	lw	s2,0(s1)
    8000427a:	0094ca83          	lbu	s5,9(s1)
    8000427e:	0104ba03          	ld	s4,16(s1)
    80004282:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004286:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000428a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000428e:	0001c517          	auipc	a0,0x1c
    80004292:	ce250513          	addi	a0,a0,-798 # 8001ff70 <ftable>
    80004296:	96ffc0ef          	jal	ra,80000c04 <release>

  if(ff.type == FD_PIPE){
    8000429a:	4785                	li	a5,1
    8000429c:	04f90363          	beq	s2,a5,800042e2 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800042a0:	3979                	addiw	s2,s2,-2
    800042a2:	4785                	li	a5,1
    800042a4:	0327e663          	bltu	a5,s2,800042d0 <fileclose+0x8c>
    begin_op();
    800042a8:	b8fff0ef          	jal	ra,80003e36 <begin_op>
    iput(ff.ip);
    800042ac:	854e                	mv	a0,s3
    800042ae:	b28ff0ef          	jal	ra,800035d6 <iput>
    end_op();
    800042b2:	bf5ff0ef          	jal	ra,80003ea6 <end_op>
    800042b6:	a829                	j	800042d0 <fileclose+0x8c>
    panic("fileclose");
    800042b8:	00003517          	auipc	a0,0x3
    800042bc:	4c050513          	addi	a0,a0,1216 # 80007778 <syscalls+0x388>
    800042c0:	ccafc0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    800042c4:	0001c517          	auipc	a0,0x1c
    800042c8:	cac50513          	addi	a0,a0,-852 # 8001ff70 <ftable>
    800042cc:	939fc0ef          	jal	ra,80000c04 <release>
  }
}
    800042d0:	70e2                	ld	ra,56(sp)
    800042d2:	7442                	ld	s0,48(sp)
    800042d4:	74a2                	ld	s1,40(sp)
    800042d6:	7902                	ld	s2,32(sp)
    800042d8:	69e2                	ld	s3,24(sp)
    800042da:	6a42                	ld	s4,16(sp)
    800042dc:	6aa2                	ld	s5,8(sp)
    800042de:	6121                	addi	sp,sp,64
    800042e0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042e2:	85d6                	mv	a1,s5
    800042e4:	8552                	mv	a0,s4
    800042e6:	2ec000ef          	jal	ra,800045d2 <pipeclose>
    800042ea:	b7dd                	j	800042d0 <fileclose+0x8c>

00000000800042ec <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800042ec:	715d                	addi	sp,sp,-80
    800042ee:	e486                	sd	ra,72(sp)
    800042f0:	e0a2                	sd	s0,64(sp)
    800042f2:	fc26                	sd	s1,56(sp)
    800042f4:	f84a                	sd	s2,48(sp)
    800042f6:	f44e                	sd	s3,40(sp)
    800042f8:	0880                	addi	s0,sp,80
    800042fa:	84aa                	mv	s1,a0
    800042fc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800042fe:	d0afd0ef          	jal	ra,80001808 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004302:	409c                	lw	a5,0(s1)
    80004304:	37f9                	addiw	a5,a5,-2
    80004306:	4705                	li	a4,1
    80004308:	02f76f63          	bltu	a4,a5,80004346 <filestat+0x5a>
    8000430c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000430e:	6c88                	ld	a0,24(s1)
    80004310:	948ff0ef          	jal	ra,80003458 <ilock>
    stati(f->ip, &st);
    80004314:	fb840593          	addi	a1,s0,-72
    80004318:	6c88                	ld	a0,24(s1)
    8000431a:	ca0ff0ef          	jal	ra,800037ba <stati>
    iunlock(f->ip);
    8000431e:	6c88                	ld	a0,24(s1)
    80004320:	9e2ff0ef          	jal	ra,80003502 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004324:	46e1                	li	a3,24
    80004326:	fb840613          	addi	a2,s0,-72
    8000432a:	85ce                	mv	a1,s3
    8000432c:	05093503          	ld	a0,80(s2)
    80004330:	a22fd0ef          	jal	ra,80001552 <copyout>
    80004334:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004338:	60a6                	ld	ra,72(sp)
    8000433a:	6406                	ld	s0,64(sp)
    8000433c:	74e2                	ld	s1,56(sp)
    8000433e:	7942                	ld	s2,48(sp)
    80004340:	79a2                	ld	s3,40(sp)
    80004342:	6161                	addi	sp,sp,80
    80004344:	8082                	ret
  return -1;
    80004346:	557d                	li	a0,-1
    80004348:	bfc5                	j	80004338 <filestat+0x4c>

000000008000434a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000434a:	7179                	addi	sp,sp,-48
    8000434c:	f406                	sd	ra,40(sp)
    8000434e:	f022                	sd	s0,32(sp)
    80004350:	ec26                	sd	s1,24(sp)
    80004352:	e84a                	sd	s2,16(sp)
    80004354:	e44e                	sd	s3,8(sp)
    80004356:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004358:	00854783          	lbu	a5,8(a0)
    8000435c:	cbc1                	beqz	a5,800043ec <fileread+0xa2>
    8000435e:	84aa                	mv	s1,a0
    80004360:	89ae                	mv	s3,a1
    80004362:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004364:	411c                	lw	a5,0(a0)
    80004366:	4705                	li	a4,1
    80004368:	04e78363          	beq	a5,a4,800043ae <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000436c:	470d                	li	a4,3
    8000436e:	04e78563          	beq	a5,a4,800043b8 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004372:	4709                	li	a4,2
    80004374:	06e79663          	bne	a5,a4,800043e0 <fileread+0x96>
    ilock(f->ip);
    80004378:	6d08                	ld	a0,24(a0)
    8000437a:	8deff0ef          	jal	ra,80003458 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000437e:	874a                	mv	a4,s2
    80004380:	5094                	lw	a3,32(s1)
    80004382:	864e                	mv	a2,s3
    80004384:	4585                	li	a1,1
    80004386:	6c88                	ld	a0,24(s1)
    80004388:	c5cff0ef          	jal	ra,800037e4 <readi>
    8000438c:	892a                	mv	s2,a0
    8000438e:	00a05563          	blez	a0,80004398 <fileread+0x4e>
      f->off += r;
    80004392:	509c                	lw	a5,32(s1)
    80004394:	9fa9                	addw	a5,a5,a0
    80004396:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004398:	6c88                	ld	a0,24(s1)
    8000439a:	968ff0ef          	jal	ra,80003502 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000439e:	854a                	mv	a0,s2
    800043a0:	70a2                	ld	ra,40(sp)
    800043a2:	7402                	ld	s0,32(sp)
    800043a4:	64e2                	ld	s1,24(sp)
    800043a6:	6942                	ld	s2,16(sp)
    800043a8:	69a2                	ld	s3,8(sp)
    800043aa:	6145                	addi	sp,sp,48
    800043ac:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043ae:	6908                	ld	a0,16(a0)
    800043b0:	34e000ef          	jal	ra,800046fe <piperead>
    800043b4:	892a                	mv	s2,a0
    800043b6:	b7e5                	j	8000439e <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800043b8:	02451783          	lh	a5,36(a0)
    800043bc:	03079693          	slli	a3,a5,0x30
    800043c0:	92c1                	srli	a3,a3,0x30
    800043c2:	4725                	li	a4,9
    800043c4:	02d76663          	bltu	a4,a3,800043f0 <fileread+0xa6>
    800043c8:	0792                	slli	a5,a5,0x4
    800043ca:	0001c717          	auipc	a4,0x1c
    800043ce:	b0670713          	addi	a4,a4,-1274 # 8001fed0 <devsw>
    800043d2:	97ba                	add	a5,a5,a4
    800043d4:	639c                	ld	a5,0(a5)
    800043d6:	cf99                	beqz	a5,800043f4 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800043d8:	4505                	li	a0,1
    800043da:	9782                	jalr	a5
    800043dc:	892a                	mv	s2,a0
    800043de:	b7c1                	j	8000439e <fileread+0x54>
    panic("fileread");
    800043e0:	00003517          	auipc	a0,0x3
    800043e4:	3a850513          	addi	a0,a0,936 # 80007788 <syscalls+0x398>
    800043e8:	ba2fc0ef          	jal	ra,8000078a <panic>
    return -1;
    800043ec:	597d                	li	s2,-1
    800043ee:	bf45                	j	8000439e <fileread+0x54>
      return -1;
    800043f0:	597d                	li	s2,-1
    800043f2:	b775                	j	8000439e <fileread+0x54>
    800043f4:	597d                	li	s2,-1
    800043f6:	b765                	j	8000439e <fileread+0x54>

00000000800043f8 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800043f8:	715d                	addi	sp,sp,-80
    800043fa:	e486                	sd	ra,72(sp)
    800043fc:	e0a2                	sd	s0,64(sp)
    800043fe:	fc26                	sd	s1,56(sp)
    80004400:	f84a                	sd	s2,48(sp)
    80004402:	f44e                	sd	s3,40(sp)
    80004404:	f052                	sd	s4,32(sp)
    80004406:	ec56                	sd	s5,24(sp)
    80004408:	e85a                	sd	s6,16(sp)
    8000440a:	e45e                	sd	s7,8(sp)
    8000440c:	e062                	sd	s8,0(sp)
    8000440e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004410:	00954783          	lbu	a5,9(a0)
    80004414:	0e078863          	beqz	a5,80004504 <filewrite+0x10c>
    80004418:	892a                	mv	s2,a0
    8000441a:	8aae                	mv	s5,a1
    8000441c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000441e:	411c                	lw	a5,0(a0)
    80004420:	4705                	li	a4,1
    80004422:	02e78263          	beq	a5,a4,80004446 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004426:	470d                	li	a4,3
    80004428:	02e78463          	beq	a5,a4,80004450 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000442c:	4709                	li	a4,2
    8000442e:	0ce79563          	bne	a5,a4,800044f8 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004432:	0ac05163          	blez	a2,800044d4 <filewrite+0xdc>
    int i = 0;
    80004436:	4981                	li	s3,0
    80004438:	6b05                	lui	s6,0x1
    8000443a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000443e:	6b85                	lui	s7,0x1
    80004440:	c00b8b9b          	addiw	s7,s7,-1024
    80004444:	a041                	j	800044c4 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004446:	6908                	ld	a0,16(a0)
    80004448:	1e2000ef          	jal	ra,8000462a <pipewrite>
    8000444c:	8a2a                	mv	s4,a0
    8000444e:	a071                	j	800044da <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004450:	02451783          	lh	a5,36(a0)
    80004454:	03079693          	slli	a3,a5,0x30
    80004458:	92c1                	srli	a3,a3,0x30
    8000445a:	4725                	li	a4,9
    8000445c:	0ad76663          	bltu	a4,a3,80004508 <filewrite+0x110>
    80004460:	0792                	slli	a5,a5,0x4
    80004462:	0001c717          	auipc	a4,0x1c
    80004466:	a6e70713          	addi	a4,a4,-1426 # 8001fed0 <devsw>
    8000446a:	97ba                	add	a5,a5,a4
    8000446c:	679c                	ld	a5,8(a5)
    8000446e:	cfd9                	beqz	a5,8000450c <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004470:	4505                	li	a0,1
    80004472:	9782                	jalr	a5
    80004474:	8a2a                	mv	s4,a0
    80004476:	a095                	j	800044da <filewrite+0xe2>
    80004478:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000447c:	9bbff0ef          	jal	ra,80003e36 <begin_op>
      ilock(f->ip);
    80004480:	01893503          	ld	a0,24(s2)
    80004484:	fd5fe0ef          	jal	ra,80003458 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004488:	8762                	mv	a4,s8
    8000448a:	02092683          	lw	a3,32(s2)
    8000448e:	01598633          	add	a2,s3,s5
    80004492:	4585                	li	a1,1
    80004494:	01893503          	ld	a0,24(s2)
    80004498:	c30ff0ef          	jal	ra,800038c8 <writei>
    8000449c:	84aa                	mv	s1,a0
    8000449e:	00a05763          	blez	a0,800044ac <filewrite+0xb4>
        f->off += r;
    800044a2:	02092783          	lw	a5,32(s2)
    800044a6:	9fa9                	addw	a5,a5,a0
    800044a8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800044ac:	01893503          	ld	a0,24(s2)
    800044b0:	852ff0ef          	jal	ra,80003502 <iunlock>
      end_op();
    800044b4:	9f3ff0ef          	jal	ra,80003ea6 <end_op>

      if(r != n1){
    800044b8:	009c1f63          	bne	s8,s1,800044d6 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800044bc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800044c0:	0149db63          	bge	s3,s4,800044d6 <filewrite+0xde>
      int n1 = n - i;
    800044c4:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800044c8:	84be                	mv	s1,a5
    800044ca:	2781                	sext.w	a5,a5
    800044cc:	fafb56e3          	bge	s6,a5,80004478 <filewrite+0x80>
    800044d0:	84de                	mv	s1,s7
    800044d2:	b75d                	j	80004478 <filewrite+0x80>
    int i = 0;
    800044d4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800044d6:	013a1f63          	bne	s4,s3,800044f4 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800044da:	8552                	mv	a0,s4
    800044dc:	60a6                	ld	ra,72(sp)
    800044de:	6406                	ld	s0,64(sp)
    800044e0:	74e2                	ld	s1,56(sp)
    800044e2:	7942                	ld	s2,48(sp)
    800044e4:	79a2                	ld	s3,40(sp)
    800044e6:	7a02                	ld	s4,32(sp)
    800044e8:	6ae2                	ld	s5,24(sp)
    800044ea:	6b42                	ld	s6,16(sp)
    800044ec:	6ba2                	ld	s7,8(sp)
    800044ee:	6c02                	ld	s8,0(sp)
    800044f0:	6161                	addi	sp,sp,80
    800044f2:	8082                	ret
    ret = (i == n ? n : -1);
    800044f4:	5a7d                	li	s4,-1
    800044f6:	b7d5                	j	800044da <filewrite+0xe2>
    panic("filewrite");
    800044f8:	00003517          	auipc	a0,0x3
    800044fc:	2a050513          	addi	a0,a0,672 # 80007798 <syscalls+0x3a8>
    80004500:	a8afc0ef          	jal	ra,8000078a <panic>
    return -1;
    80004504:	5a7d                	li	s4,-1
    80004506:	bfd1                	j	800044da <filewrite+0xe2>
      return -1;
    80004508:	5a7d                	li	s4,-1
    8000450a:	bfc1                	j	800044da <filewrite+0xe2>
    8000450c:	5a7d                	li	s4,-1
    8000450e:	b7f1                	j	800044da <filewrite+0xe2>

0000000080004510 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004510:	7179                	addi	sp,sp,-48
    80004512:	f406                	sd	ra,40(sp)
    80004514:	f022                	sd	s0,32(sp)
    80004516:	ec26                	sd	s1,24(sp)
    80004518:	e84a                	sd	s2,16(sp)
    8000451a:	e44e                	sd	s3,8(sp)
    8000451c:	e052                	sd	s4,0(sp)
    8000451e:	1800                	addi	s0,sp,48
    80004520:	84aa                	mv	s1,a0
    80004522:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004524:	0005b023          	sd	zero,0(a1)
    80004528:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000452c:	c75ff0ef          	jal	ra,800041a0 <filealloc>
    80004530:	e088                	sd	a0,0(s1)
    80004532:	cd35                	beqz	a0,800045ae <pipealloc+0x9e>
    80004534:	c6dff0ef          	jal	ra,800041a0 <filealloc>
    80004538:	00aa3023          	sd	a0,0(s4)
    8000453c:	c52d                	beqz	a0,800045a6 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000453e:	d5efc0ef          	jal	ra,80000a9c <kalloc>
    80004542:	892a                	mv	s2,a0
    80004544:	cd31                	beqz	a0,800045a0 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004546:	4985                	li	s3,1
    80004548:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000454c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004550:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004554:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004558:	00003597          	auipc	a1,0x3
    8000455c:	25058593          	addi	a1,a1,592 # 800077a8 <syscalls+0x3b8>
    80004560:	d8cfc0ef          	jal	ra,80000aec <initlock>
  (*f0)->type = FD_PIPE;
    80004564:	609c                	ld	a5,0(s1)
    80004566:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000456a:	609c                	ld	a5,0(s1)
    8000456c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004570:	609c                	ld	a5,0(s1)
    80004572:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004576:	609c                	ld	a5,0(s1)
    80004578:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000457c:	000a3783          	ld	a5,0(s4)
    80004580:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004584:	000a3783          	ld	a5,0(s4)
    80004588:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000458c:	000a3783          	ld	a5,0(s4)
    80004590:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004594:	000a3783          	ld	a5,0(s4)
    80004598:	0127b823          	sd	s2,16(a5)
  return 0;
    8000459c:	4501                	li	a0,0
    8000459e:	a005                	j	800045be <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800045a0:	6088                	ld	a0,0(s1)
    800045a2:	e501                	bnez	a0,800045aa <pipealloc+0x9a>
    800045a4:	a029                	j	800045ae <pipealloc+0x9e>
    800045a6:	6088                	ld	a0,0(s1)
    800045a8:	c11d                	beqz	a0,800045ce <pipealloc+0xbe>
    fileclose(*f0);
    800045aa:	c9bff0ef          	jal	ra,80004244 <fileclose>
  if(*f1)
    800045ae:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800045b2:	557d                	li	a0,-1
  if(*f1)
    800045b4:	c789                	beqz	a5,800045be <pipealloc+0xae>
    fileclose(*f1);
    800045b6:	853e                	mv	a0,a5
    800045b8:	c8dff0ef          	jal	ra,80004244 <fileclose>
  return -1;
    800045bc:	557d                	li	a0,-1
}
    800045be:	70a2                	ld	ra,40(sp)
    800045c0:	7402                	ld	s0,32(sp)
    800045c2:	64e2                	ld	s1,24(sp)
    800045c4:	6942                	ld	s2,16(sp)
    800045c6:	69a2                	ld	s3,8(sp)
    800045c8:	6a02                	ld	s4,0(sp)
    800045ca:	6145                	addi	sp,sp,48
    800045cc:	8082                	ret
  return -1;
    800045ce:	557d                	li	a0,-1
    800045d0:	b7fd                	j	800045be <pipealloc+0xae>

00000000800045d2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800045d2:	1101                	addi	sp,sp,-32
    800045d4:	ec06                	sd	ra,24(sp)
    800045d6:	e822                	sd	s0,16(sp)
    800045d8:	e426                	sd	s1,8(sp)
    800045da:	e04a                	sd	s2,0(sp)
    800045dc:	1000                	addi	s0,sp,32
    800045de:	84aa                	mv	s1,a0
    800045e0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800045e2:	d8afc0ef          	jal	ra,80000b6c <acquire>
  if(writable){
    800045e6:	02090763          	beqz	s2,80004614 <pipeclose+0x42>
    pi->writeopen = 0;
    800045ea:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800045ee:	21848513          	addi	a0,s1,536
    800045f2:	905fd0ef          	jal	ra,80001ef6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800045f6:	2204b783          	ld	a5,544(s1)
    800045fa:	e785                	bnez	a5,80004622 <pipeclose+0x50>
    release(&pi->lock);
    800045fc:	8526                	mv	a0,s1
    800045fe:	e06fc0ef          	jal	ra,80000c04 <release>
    kfree((char*)pi);
    80004602:	8526                	mv	a0,s1
    80004604:	bb8fc0ef          	jal	ra,800009bc <kfree>
  } else
    release(&pi->lock);
}
    80004608:	60e2                	ld	ra,24(sp)
    8000460a:	6442                	ld	s0,16(sp)
    8000460c:	64a2                	ld	s1,8(sp)
    8000460e:	6902                	ld	s2,0(sp)
    80004610:	6105                	addi	sp,sp,32
    80004612:	8082                	ret
    pi->readopen = 0;
    80004614:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004618:	21c48513          	addi	a0,s1,540
    8000461c:	8dbfd0ef          	jal	ra,80001ef6 <wakeup>
    80004620:	bfd9                	j	800045f6 <pipeclose+0x24>
    release(&pi->lock);
    80004622:	8526                	mv	a0,s1
    80004624:	de0fc0ef          	jal	ra,80000c04 <release>
}
    80004628:	b7c5                	j	80004608 <pipeclose+0x36>

000000008000462a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000462a:	711d                	addi	sp,sp,-96
    8000462c:	ec86                	sd	ra,88(sp)
    8000462e:	e8a2                	sd	s0,80(sp)
    80004630:	e4a6                	sd	s1,72(sp)
    80004632:	e0ca                	sd	s2,64(sp)
    80004634:	fc4e                	sd	s3,56(sp)
    80004636:	f852                	sd	s4,48(sp)
    80004638:	f456                	sd	s5,40(sp)
    8000463a:	f05a                	sd	s6,32(sp)
    8000463c:	ec5e                	sd	s7,24(sp)
    8000463e:	e862                	sd	s8,16(sp)
    80004640:	1080                	addi	s0,sp,96
    80004642:	84aa                	mv	s1,a0
    80004644:	8aae                	mv	s5,a1
    80004646:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004648:	9c0fd0ef          	jal	ra,80001808 <myproc>
    8000464c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000464e:	8526                	mv	a0,s1
    80004650:	d1cfc0ef          	jal	ra,80000b6c <acquire>
  while(i < n){
    80004654:	09405c63          	blez	s4,800046ec <pipewrite+0xc2>
  int i = 0;
    80004658:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000465a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000465c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004660:	21c48b93          	addi	s7,s1,540
    80004664:	a81d                	j	8000469a <pipewrite+0x70>
      release(&pi->lock);
    80004666:	8526                	mv	a0,s1
    80004668:	d9cfc0ef          	jal	ra,80000c04 <release>
      return -1;
    8000466c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000466e:	854a                	mv	a0,s2
    80004670:	60e6                	ld	ra,88(sp)
    80004672:	6446                	ld	s0,80(sp)
    80004674:	64a6                	ld	s1,72(sp)
    80004676:	6906                	ld	s2,64(sp)
    80004678:	79e2                	ld	s3,56(sp)
    8000467a:	7a42                	ld	s4,48(sp)
    8000467c:	7aa2                	ld	s5,40(sp)
    8000467e:	7b02                	ld	s6,32(sp)
    80004680:	6be2                	ld	s7,24(sp)
    80004682:	6c42                	ld	s8,16(sp)
    80004684:	6125                	addi	sp,sp,96
    80004686:	8082                	ret
      wakeup(&pi->nread);
    80004688:	8562                	mv	a0,s8
    8000468a:	86dfd0ef          	jal	ra,80001ef6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000468e:	85a6                	mv	a1,s1
    80004690:	855e                	mv	a0,s7
    80004692:	819fd0ef          	jal	ra,80001eaa <sleep>
  while(i < n){
    80004696:	05495c63          	bge	s2,s4,800046ee <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    8000469a:	2204a783          	lw	a5,544(s1)
    8000469e:	d7e1                	beqz	a5,80004666 <pipewrite+0x3c>
    800046a0:	854e                	mv	a0,s3
    800046a2:	a41fd0ef          	jal	ra,800020e2 <killed>
    800046a6:	f161                	bnez	a0,80004666 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800046a8:	2184a783          	lw	a5,536(s1)
    800046ac:	21c4a703          	lw	a4,540(s1)
    800046b0:	2007879b          	addiw	a5,a5,512
    800046b4:	fcf70ae3          	beq	a4,a5,80004688 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800046b8:	4685                	li	a3,1
    800046ba:	01590633          	add	a2,s2,s5
    800046be:	faf40593          	addi	a1,s0,-81
    800046c2:	0509b503          	ld	a0,80(s3)
    800046c6:	f53fc0ef          	jal	ra,80001618 <copyin>
    800046ca:	03650263          	beq	a0,s6,800046ee <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800046ce:	21c4a783          	lw	a5,540(s1)
    800046d2:	0017871b          	addiw	a4,a5,1
    800046d6:	20e4ae23          	sw	a4,540(s1)
    800046da:	1ff7f793          	andi	a5,a5,511
    800046de:	97a6                	add	a5,a5,s1
    800046e0:	faf44703          	lbu	a4,-81(s0)
    800046e4:	00e78c23          	sb	a4,24(a5)
      i++;
    800046e8:	2905                	addiw	s2,s2,1
    800046ea:	b775                	j	80004696 <pipewrite+0x6c>
  int i = 0;
    800046ec:	4901                	li	s2,0
  wakeup(&pi->nread);
    800046ee:	21848513          	addi	a0,s1,536
    800046f2:	805fd0ef          	jal	ra,80001ef6 <wakeup>
  release(&pi->lock);
    800046f6:	8526                	mv	a0,s1
    800046f8:	d0cfc0ef          	jal	ra,80000c04 <release>
  return i;
    800046fc:	bf8d                	j	8000466e <pipewrite+0x44>

00000000800046fe <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800046fe:	715d                	addi	sp,sp,-80
    80004700:	e486                	sd	ra,72(sp)
    80004702:	e0a2                	sd	s0,64(sp)
    80004704:	fc26                	sd	s1,56(sp)
    80004706:	f84a                	sd	s2,48(sp)
    80004708:	f44e                	sd	s3,40(sp)
    8000470a:	f052                	sd	s4,32(sp)
    8000470c:	ec56                	sd	s5,24(sp)
    8000470e:	e85a                	sd	s6,16(sp)
    80004710:	0880                	addi	s0,sp,80
    80004712:	84aa                	mv	s1,a0
    80004714:	892e                	mv	s2,a1
    80004716:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004718:	8f0fd0ef          	jal	ra,80001808 <myproc>
    8000471c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000471e:	8526                	mv	a0,s1
    80004720:	c4cfc0ef          	jal	ra,80000b6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004724:	2184a703          	lw	a4,536(s1)
    80004728:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000472c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004730:	02f71363          	bne	a4,a5,80004756 <piperead+0x58>
    80004734:	2244a783          	lw	a5,548(s1)
    80004738:	cf99                	beqz	a5,80004756 <piperead+0x58>
    if(killed(pr)){
    8000473a:	8552                	mv	a0,s4
    8000473c:	9a7fd0ef          	jal	ra,800020e2 <killed>
    80004740:	e149                	bnez	a0,800047c2 <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004742:	85a6                	mv	a1,s1
    80004744:	854e                	mv	a0,s3
    80004746:	f64fd0ef          	jal	ra,80001eaa <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000474a:	2184a703          	lw	a4,536(s1)
    8000474e:	21c4a783          	lw	a5,540(s1)
    80004752:	fef701e3          	beq	a4,a5,80004734 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004756:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004758:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000475a:	05505263          	blez	s5,8000479e <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    8000475e:	2184a783          	lw	a5,536(s1)
    80004762:	21c4a703          	lw	a4,540(s1)
    80004766:	02f70c63          	beq	a4,a5,8000479e <piperead+0xa0>
    ch = pi->data[pi->nread % PIPESIZE];
    8000476a:	1ff7f793          	andi	a5,a5,511
    8000476e:	97a6                	add	a5,a5,s1
    80004770:	0187c783          	lbu	a5,24(a5)
    80004774:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004778:	4685                	li	a3,1
    8000477a:	fbf40613          	addi	a2,s0,-65
    8000477e:	85ca                	mv	a1,s2
    80004780:	050a3503          	ld	a0,80(s4)
    80004784:	dcffc0ef          	jal	ra,80001552 <copyout>
    80004788:	05650263          	beq	a0,s6,800047cc <piperead+0xce>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000478c:	2184a783          	lw	a5,536(s1)
    80004790:	2785                	addiw	a5,a5,1
    80004792:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004796:	2985                	addiw	s3,s3,1
    80004798:	0905                	addi	s2,s2,1
    8000479a:	fd3a92e3          	bne	s5,s3,8000475e <piperead+0x60>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000479e:	21c48513          	addi	a0,s1,540
    800047a2:	f54fd0ef          	jal	ra,80001ef6 <wakeup>
  release(&pi->lock);
    800047a6:	8526                	mv	a0,s1
    800047a8:	c5cfc0ef          	jal	ra,80000c04 <release>
  return i;
}
    800047ac:	854e                	mv	a0,s3
    800047ae:	60a6                	ld	ra,72(sp)
    800047b0:	6406                	ld	s0,64(sp)
    800047b2:	74e2                	ld	s1,56(sp)
    800047b4:	7942                	ld	s2,48(sp)
    800047b6:	79a2                	ld	s3,40(sp)
    800047b8:	7a02                	ld	s4,32(sp)
    800047ba:	6ae2                	ld	s5,24(sp)
    800047bc:	6b42                	ld	s6,16(sp)
    800047be:	6161                	addi	sp,sp,80
    800047c0:	8082                	ret
      release(&pi->lock);
    800047c2:	8526                	mv	a0,s1
    800047c4:	c40fc0ef          	jal	ra,80000c04 <release>
      return -1;
    800047c8:	59fd                	li	s3,-1
    800047ca:	b7cd                	j	800047ac <piperead+0xae>
      if(i == 0)
    800047cc:	fc0999e3          	bnez	s3,8000479e <piperead+0xa0>
        i = -1;
    800047d0:	89aa                	mv	s3,a0
    800047d2:	b7f1                	j	8000479e <piperead+0xa0>

00000000800047d4 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800047d4:	1141                	addi	sp,sp,-16
    800047d6:	e422                	sd	s0,8(sp)
    800047d8:	0800                	addi	s0,sp,16
    800047da:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800047dc:	8905                	andi	a0,a0,1
    800047de:	c111                	beqz	a0,800047e2 <flags2perm+0xe>
      perm = PTE_X;
    800047e0:	4521                	li	a0,8
    if(flags & 0x2)
    800047e2:	8b89                	andi	a5,a5,2
    800047e4:	c399                	beqz	a5,800047ea <flags2perm+0x16>
      perm |= PTE_W;
    800047e6:	00456513          	ori	a0,a0,4
    return perm;
}
    800047ea:	6422                	ld	s0,8(sp)
    800047ec:	0141                	addi	sp,sp,16
    800047ee:	8082                	ret

00000000800047f0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800047f0:	de010113          	addi	sp,sp,-544
    800047f4:	20113c23          	sd	ra,536(sp)
    800047f8:	20813823          	sd	s0,528(sp)
    800047fc:	20913423          	sd	s1,520(sp)
    80004800:	21213023          	sd	s2,512(sp)
    80004804:	ffce                	sd	s3,504(sp)
    80004806:	fbd2                	sd	s4,496(sp)
    80004808:	f7d6                	sd	s5,488(sp)
    8000480a:	f3da                	sd	s6,480(sp)
    8000480c:	efde                	sd	s7,472(sp)
    8000480e:	ebe2                	sd	s8,464(sp)
    80004810:	e7e6                	sd	s9,456(sp)
    80004812:	e3ea                	sd	s10,448(sp)
    80004814:	ff6e                	sd	s11,440(sp)
    80004816:	1400                	addi	s0,sp,544
    80004818:	892a                	mv	s2,a0
    8000481a:	dea43423          	sd	a0,-536(s0)
    8000481e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004822:	fe7fc0ef          	jal	ra,80001808 <myproc>
    80004826:	84aa                	mv	s1,a0

  begin_op();
    80004828:	e0eff0ef          	jal	ra,80003e36 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000482c:	854a                	mv	a0,s2
    8000482e:	c18ff0ef          	jal	ra,80003c46 <namei>
    80004832:	c13d                	beqz	a0,80004898 <kexec+0xa8>
    80004834:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004836:	c23fe0ef          	jal	ra,80003458 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000483a:	04000713          	li	a4,64
    8000483e:	4681                	li	a3,0
    80004840:	e5040613          	addi	a2,s0,-432
    80004844:	4581                	li	a1,0
    80004846:	8556                	mv	a0,s5
    80004848:	f9dfe0ef          	jal	ra,800037e4 <readi>
    8000484c:	04000793          	li	a5,64
    80004850:	00f51a63          	bne	a0,a5,80004864 <kexec+0x74>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004854:	e5042703          	lw	a4,-432(s0)
    80004858:	464c47b7          	lui	a5,0x464c4
    8000485c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004860:	04f70063          	beq	a4,a5,800048a0 <kexec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004864:	8556                	mv	a0,s5
    80004866:	df9fe0ef          	jal	ra,8000365e <iunlockput>
    end_op();
    8000486a:	e3cff0ef          	jal	ra,80003ea6 <end_op>
  }
  return -1;
    8000486e:	557d                	li	a0,-1
}
    80004870:	21813083          	ld	ra,536(sp)
    80004874:	21013403          	ld	s0,528(sp)
    80004878:	20813483          	ld	s1,520(sp)
    8000487c:	20013903          	ld	s2,512(sp)
    80004880:	79fe                	ld	s3,504(sp)
    80004882:	7a5e                	ld	s4,496(sp)
    80004884:	7abe                	ld	s5,488(sp)
    80004886:	7b1e                	ld	s6,480(sp)
    80004888:	6bfe                	ld	s7,472(sp)
    8000488a:	6c5e                	ld	s8,464(sp)
    8000488c:	6cbe                	ld	s9,456(sp)
    8000488e:	6d1e                	ld	s10,448(sp)
    80004890:	7dfa                	ld	s11,440(sp)
    80004892:	22010113          	addi	sp,sp,544
    80004896:	8082                	ret
    end_op();
    80004898:	e0eff0ef          	jal	ra,80003ea6 <end_op>
    return -1;
    8000489c:	557d                	li	a0,-1
    8000489e:	bfc9                	j	80004870 <kexec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    800048a0:	8526                	mv	a0,s1
    800048a2:	86cfd0ef          	jal	ra,8000190e <proc_pagetable>
    800048a6:	8b2a                	mv	s6,a0
    800048a8:	dd55                	beqz	a0,80004864 <kexec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048aa:	e7042783          	lw	a5,-400(s0)
    800048ae:	e8845703          	lhu	a4,-376(s0)
    800048b2:	c325                	beqz	a4,80004912 <kexec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048b4:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048b6:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800048ba:	6a05                	lui	s4,0x1
    800048bc:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800048c0:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800048c4:	6d85                	lui	s11,0x1
    800048c6:	7d7d                	lui	s10,0xfffff
    800048c8:	a411                	j	80004acc <kexec+0x2dc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800048ca:	00003517          	auipc	a0,0x3
    800048ce:	ee650513          	addi	a0,a0,-282 # 800077b0 <syscalls+0x3c0>
    800048d2:	eb9fb0ef          	jal	ra,8000078a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800048d6:	874a                	mv	a4,s2
    800048d8:	009c86bb          	addw	a3,s9,s1
    800048dc:	4581                	li	a1,0
    800048de:	8556                	mv	a0,s5
    800048e0:	f05fe0ef          	jal	ra,800037e4 <readi>
    800048e4:	2501                	sext.w	a0,a0
    800048e6:	18a91263          	bne	s2,a0,80004a6a <kexec+0x27a>
  for(i = 0; i < sz; i += PGSIZE){
    800048ea:	009d84bb          	addw	s1,s11,s1
    800048ee:	013d09bb          	addw	s3,s10,s3
    800048f2:	1b74fd63          	bgeu	s1,s7,80004aac <kexec+0x2bc>
    pa = walkaddr(pagetable, va + i);
    800048f6:	02049593          	slli	a1,s1,0x20
    800048fa:	9181                	srli	a1,a1,0x20
    800048fc:	95e2                	add	a1,a1,s8
    800048fe:	855a                	mv	a0,s6
    80004900:	e56fc0ef          	jal	ra,80000f56 <walkaddr>
    80004904:	862a                	mv	a2,a0
    if(pa == 0)
    80004906:	d171                	beqz	a0,800048ca <kexec+0xda>
      n = PGSIZE;
    80004908:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000490a:	fd49f6e3          	bgeu	s3,s4,800048d6 <kexec+0xe6>
      n = sz - i;
    8000490e:	894e                	mv	s2,s3
    80004910:	b7d9                	j	800048d6 <kexec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004912:	4901                	li	s2,0
  iunlockput(ip);
    80004914:	8556                	mv	a0,s5
    80004916:	d49fe0ef          	jal	ra,8000365e <iunlockput>
  end_op();
    8000491a:	d8cff0ef          	jal	ra,80003ea6 <end_op>
  p = myproc();
    8000491e:	eebfc0ef          	jal	ra,80001808 <myproc>
    80004922:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004924:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004928:	6785                	lui	a5,0x1
    8000492a:	17fd                	addi	a5,a5,-1
    8000492c:	993e                	add	s2,s2,a5
    8000492e:	77fd                	lui	a5,0xfffff
    80004930:	00f977b3          	and	a5,s2,a5
    80004934:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004938:	4691                	li	a3,4
    8000493a:	6609                	lui	a2,0x2
    8000493c:	963e                	add	a2,a2,a5
    8000493e:	85be                	mv	a1,a5
    80004940:	855a                	mv	a0,s6
    80004942:	8dffc0ef          	jal	ra,80001220 <uvmalloc>
    80004946:	8c2a                	mv	s8,a0
  ip = 0;
    80004948:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000494a:	12050063          	beqz	a0,80004a6a <kexec+0x27a>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000494e:	75f9                	lui	a1,0xffffe
    80004950:	95aa                	add	a1,a1,a0
    80004952:	855a                	mv	a0,s6
    80004954:	a93fc0ef          	jal	ra,800013e6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004958:	7afd                	lui	s5,0xfffff
    8000495a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000495c:	df043783          	ld	a5,-528(s0)
    80004960:	6388                	ld	a0,0(a5)
    80004962:	c135                	beqz	a0,800049c6 <kexec+0x1d6>
    80004964:	e9040993          	addi	s3,s0,-368
    80004968:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000496c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000496e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004970:	c48fc0ef          	jal	ra,80000db8 <strlen>
    80004974:	0015079b          	addiw	a5,a0,1
    80004978:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000497c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004980:	11596a63          	bltu	s2,s5,80004a94 <kexec+0x2a4>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004984:	df043d83          	ld	s11,-528(s0)
    80004988:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000498c:	8552                	mv	a0,s4
    8000498e:	c2afc0ef          	jal	ra,80000db8 <strlen>
    80004992:	0015069b          	addiw	a3,a0,1
    80004996:	8652                	mv	a2,s4
    80004998:	85ca                	mv	a1,s2
    8000499a:	855a                	mv	a0,s6
    8000499c:	bb7fc0ef          	jal	ra,80001552 <copyout>
    800049a0:	0e054e63          	bltz	a0,80004a9c <kexec+0x2ac>
    ustack[argc] = sp;
    800049a4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800049a8:	0485                	addi	s1,s1,1
    800049aa:	008d8793          	addi	a5,s11,8
    800049ae:	def43823          	sd	a5,-528(s0)
    800049b2:	008db503          	ld	a0,8(s11)
    800049b6:	c911                	beqz	a0,800049ca <kexec+0x1da>
    if(argc >= MAXARG)
    800049b8:	09a1                	addi	s3,s3,8
    800049ba:	fb3c9be3          	bne	s9,s3,80004970 <kexec+0x180>
  sz = sz1;
    800049be:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800049c2:	4a81                	li	s5,0
    800049c4:	a05d                	j	80004a6a <kexec+0x27a>
  sp = sz;
    800049c6:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800049c8:	4481                	li	s1,0
  ustack[argc] = 0;
    800049ca:	00349793          	slli	a5,s1,0x3
    800049ce:	f9040713          	addi	a4,s0,-112
    800049d2:	97ba                	add	a5,a5,a4
    800049d4:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdde98>
  sp -= (argc+1) * sizeof(uint64);
    800049d8:	00148693          	addi	a3,s1,1
    800049dc:	068e                	slli	a3,a3,0x3
    800049de:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800049e2:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800049e6:	01597663          	bgeu	s2,s5,800049f2 <kexec+0x202>
  sz = sz1;
    800049ea:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800049ee:	4a81                	li	s5,0
    800049f0:	a8ad                	j	80004a6a <kexec+0x27a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800049f2:	e9040613          	addi	a2,s0,-368
    800049f6:	85ca                	mv	a1,s2
    800049f8:	855a                	mv	a0,s6
    800049fa:	b59fc0ef          	jal	ra,80001552 <copyout>
    800049fe:	0a054363          	bltz	a0,80004aa4 <kexec+0x2b4>
  p->trapframe->a1 = sp;
    80004a02:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004a06:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004a0a:	de843783          	ld	a5,-536(s0)
    80004a0e:	0007c703          	lbu	a4,0(a5)
    80004a12:	cf11                	beqz	a4,80004a2e <kexec+0x23e>
    80004a14:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004a16:	02f00693          	li	a3,47
    80004a1a:	a039                	j	80004a28 <kexec+0x238>
      last = s+1;
    80004a1c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004a20:	0785                	addi	a5,a5,1
    80004a22:	fff7c703          	lbu	a4,-1(a5)
    80004a26:	c701                	beqz	a4,80004a2e <kexec+0x23e>
    if(*s == '/')
    80004a28:	fed71ce3          	bne	a4,a3,80004a20 <kexec+0x230>
    80004a2c:	bfc5                	j	80004a1c <kexec+0x22c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004a2e:	4641                	li	a2,16
    80004a30:	de843583          	ld	a1,-536(s0)
    80004a34:	158b8513          	addi	a0,s7,344
    80004a38:	b4efc0ef          	jal	ra,80000d86 <safestrcpy>
  oldpagetable = p->pagetable;
    80004a3c:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004a40:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004a44:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004a48:	058bb783          	ld	a5,88(s7)
    80004a4c:	e6843703          	ld	a4,-408(s0)
    80004a50:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004a52:	058bb783          	ld	a5,88(s7)
    80004a56:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a5a:	85ea                	mv	a1,s10
    80004a5c:	f81fc0ef          	jal	ra,800019dc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004a60:	0004851b          	sext.w	a0,s1
    80004a64:	b531                	j	80004870 <kexec+0x80>
    80004a66:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004a6a:	df843583          	ld	a1,-520(s0)
    80004a6e:	855a                	mv	a0,s6
    80004a70:	f6dfc0ef          	jal	ra,800019dc <proc_freepagetable>
  if(ip){
    80004a74:	de0a98e3          	bnez	s5,80004864 <kexec+0x74>
  return -1;
    80004a78:	557d                	li	a0,-1
    80004a7a:	bbdd                	j	80004870 <kexec+0x80>
    80004a7c:	df243c23          	sd	s2,-520(s0)
    80004a80:	b7ed                	j	80004a6a <kexec+0x27a>
    80004a82:	df243c23          	sd	s2,-520(s0)
    80004a86:	b7d5                	j	80004a6a <kexec+0x27a>
    80004a88:	df243c23          	sd	s2,-520(s0)
    80004a8c:	bff9                	j	80004a6a <kexec+0x27a>
    80004a8e:	df243c23          	sd	s2,-520(s0)
    80004a92:	bfe1                	j	80004a6a <kexec+0x27a>
  sz = sz1;
    80004a94:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004a98:	4a81                	li	s5,0
    80004a9a:	bfc1                	j	80004a6a <kexec+0x27a>
  sz = sz1;
    80004a9c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004aa0:	4a81                	li	s5,0
    80004aa2:	b7e1                	j	80004a6a <kexec+0x27a>
  sz = sz1;
    80004aa4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004aa8:	4a81                	li	s5,0
    80004aaa:	b7c1                	j	80004a6a <kexec+0x27a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004aac:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ab0:	e0843783          	ld	a5,-504(s0)
    80004ab4:	0017869b          	addiw	a3,a5,1
    80004ab8:	e0d43423          	sd	a3,-504(s0)
    80004abc:	e0043783          	ld	a5,-512(s0)
    80004ac0:	0387879b          	addiw	a5,a5,56
    80004ac4:	e8845703          	lhu	a4,-376(s0)
    80004ac8:	e4e6d6e3          	bge	a3,a4,80004914 <kexec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004acc:	2781                	sext.w	a5,a5
    80004ace:	e0f43023          	sd	a5,-512(s0)
    80004ad2:	03800713          	li	a4,56
    80004ad6:	86be                	mv	a3,a5
    80004ad8:	e1840613          	addi	a2,s0,-488
    80004adc:	4581                	li	a1,0
    80004ade:	8556                	mv	a0,s5
    80004ae0:	d05fe0ef          	jal	ra,800037e4 <readi>
    80004ae4:	03800793          	li	a5,56
    80004ae8:	f6f51fe3          	bne	a0,a5,80004a66 <kexec+0x276>
    if(ph.type != ELF_PROG_LOAD)
    80004aec:	e1842783          	lw	a5,-488(s0)
    80004af0:	4705                	li	a4,1
    80004af2:	fae79fe3          	bne	a5,a4,80004ab0 <kexec+0x2c0>
    if(ph.memsz < ph.filesz)
    80004af6:	e4043483          	ld	s1,-448(s0)
    80004afa:	e3843783          	ld	a5,-456(s0)
    80004afe:	f6f4efe3          	bltu	s1,a5,80004a7c <kexec+0x28c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004b02:	e2843783          	ld	a5,-472(s0)
    80004b06:	94be                	add	s1,s1,a5
    80004b08:	f6f4ede3          	bltu	s1,a5,80004a82 <kexec+0x292>
    if(ph.vaddr % PGSIZE != 0)
    80004b0c:	de043703          	ld	a4,-544(s0)
    80004b10:	8ff9                	and	a5,a5,a4
    80004b12:	fbbd                	bnez	a5,80004a88 <kexec+0x298>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004b14:	e1c42503          	lw	a0,-484(s0)
    80004b18:	cbdff0ef          	jal	ra,800047d4 <flags2perm>
    80004b1c:	86aa                	mv	a3,a0
    80004b1e:	8626                	mv	a2,s1
    80004b20:	85ca                	mv	a1,s2
    80004b22:	855a                	mv	a0,s6
    80004b24:	efcfc0ef          	jal	ra,80001220 <uvmalloc>
    80004b28:	dea43c23          	sd	a0,-520(s0)
    80004b2c:	d12d                	beqz	a0,80004a8e <kexec+0x29e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b2e:	e2843c03          	ld	s8,-472(s0)
    80004b32:	e2042c83          	lw	s9,-480(s0)
    80004b36:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004b3a:	f60b89e3          	beqz	s7,80004aac <kexec+0x2bc>
    80004b3e:	89de                	mv	s3,s7
    80004b40:	4481                	li	s1,0
    80004b42:	bb55                	j	800048f6 <kexec+0x106>

0000000080004b44 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004b44:	7179                	addi	sp,sp,-48
    80004b46:	f406                	sd	ra,40(sp)
    80004b48:	f022                	sd	s0,32(sp)
    80004b4a:	ec26                	sd	s1,24(sp)
    80004b4c:	e84a                	sd	s2,16(sp)
    80004b4e:	1800                	addi	s0,sp,48
    80004b50:	892e                	mv	s2,a1
    80004b52:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004b54:	fdc40593          	addi	a1,s0,-36
    80004b58:	c5ffd0ef          	jal	ra,800027b6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004b5c:	fdc42703          	lw	a4,-36(s0)
    80004b60:	47bd                	li	a5,15
    80004b62:	02e7e963          	bltu	a5,a4,80004b94 <argfd+0x50>
    80004b66:	ca3fc0ef          	jal	ra,80001808 <myproc>
    80004b6a:	fdc42703          	lw	a4,-36(s0)
    80004b6e:	01a70793          	addi	a5,a4,26
    80004b72:	078e                	slli	a5,a5,0x3
    80004b74:	953e                	add	a0,a0,a5
    80004b76:	611c                	ld	a5,0(a0)
    80004b78:	c385                	beqz	a5,80004b98 <argfd+0x54>
    return -1;
  if(pfd)
    80004b7a:	00090463          	beqz	s2,80004b82 <argfd+0x3e>
    *pfd = fd;
    80004b7e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004b82:	4501                	li	a0,0
  if(pf)
    80004b84:	c091                	beqz	s1,80004b88 <argfd+0x44>
    *pf = f;
    80004b86:	e09c                	sd	a5,0(s1)
}
    80004b88:	70a2                	ld	ra,40(sp)
    80004b8a:	7402                	ld	s0,32(sp)
    80004b8c:	64e2                	ld	s1,24(sp)
    80004b8e:	6942                	ld	s2,16(sp)
    80004b90:	6145                	addi	sp,sp,48
    80004b92:	8082                	ret
    return -1;
    80004b94:	557d                	li	a0,-1
    80004b96:	bfcd                	j	80004b88 <argfd+0x44>
    80004b98:	557d                	li	a0,-1
    80004b9a:	b7fd                	j	80004b88 <argfd+0x44>

0000000080004b9c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b9c:	1101                	addi	sp,sp,-32
    80004b9e:	ec06                	sd	ra,24(sp)
    80004ba0:	e822                	sd	s0,16(sp)
    80004ba2:	e426                	sd	s1,8(sp)
    80004ba4:	1000                	addi	s0,sp,32
    80004ba6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ba8:	c61fc0ef          	jal	ra,80001808 <myproc>
    80004bac:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004bae:	0d050793          	addi	a5,a0,208
    80004bb2:	4501                	li	a0,0
    80004bb4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004bb6:	6398                	ld	a4,0(a5)
    80004bb8:	cb19                	beqz	a4,80004bce <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004bba:	2505                	addiw	a0,a0,1
    80004bbc:	07a1                	addi	a5,a5,8
    80004bbe:	fed51ce3          	bne	a0,a3,80004bb6 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004bc2:	557d                	li	a0,-1
}
    80004bc4:	60e2                	ld	ra,24(sp)
    80004bc6:	6442                	ld	s0,16(sp)
    80004bc8:	64a2                	ld	s1,8(sp)
    80004bca:	6105                	addi	sp,sp,32
    80004bcc:	8082                	ret
      p->ofile[fd] = f;
    80004bce:	01a50793          	addi	a5,a0,26
    80004bd2:	078e                	slli	a5,a5,0x3
    80004bd4:	963e                	add	a2,a2,a5
    80004bd6:	e204                	sd	s1,0(a2)
      return fd;
    80004bd8:	b7f5                	j	80004bc4 <fdalloc+0x28>

0000000080004bda <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004bda:	715d                	addi	sp,sp,-80
    80004bdc:	e486                	sd	ra,72(sp)
    80004bde:	e0a2                	sd	s0,64(sp)
    80004be0:	fc26                	sd	s1,56(sp)
    80004be2:	f84a                	sd	s2,48(sp)
    80004be4:	f44e                	sd	s3,40(sp)
    80004be6:	f052                	sd	s4,32(sp)
    80004be8:	ec56                	sd	s5,24(sp)
    80004bea:	e85a                	sd	s6,16(sp)
    80004bec:	0880                	addi	s0,sp,80
    80004bee:	8b2e                	mv	s6,a1
    80004bf0:	89b2                	mv	s3,a2
    80004bf2:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004bf4:	fb040593          	addi	a1,s0,-80
    80004bf8:	868ff0ef          	jal	ra,80003c60 <nameiparent>
    80004bfc:	84aa                	mv	s1,a0
    80004bfe:	10050b63          	beqz	a0,80004d14 <create+0x13a>
    return 0;

  ilock(dp);
    80004c02:	857fe0ef          	jal	ra,80003458 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004c06:	4601                	li	a2,0
    80004c08:	fb040593          	addi	a1,s0,-80
    80004c0c:	8526                	mv	a0,s1
    80004c0e:	dd3fe0ef          	jal	ra,800039e0 <dirlookup>
    80004c12:	8aaa                	mv	s5,a0
    80004c14:	c521                	beqz	a0,80004c5c <create+0x82>
    iunlockput(dp);
    80004c16:	8526                	mv	a0,s1
    80004c18:	a47fe0ef          	jal	ra,8000365e <iunlockput>
    ilock(ip);
    80004c1c:	8556                	mv	a0,s5
    80004c1e:	83bfe0ef          	jal	ra,80003458 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004c22:	000b059b          	sext.w	a1,s6
    80004c26:	4789                	li	a5,2
    80004c28:	02f59563          	bne	a1,a5,80004c52 <create+0x78>
    80004c2c:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffddfdc>
    80004c30:	37f9                	addiw	a5,a5,-2
    80004c32:	17c2                	slli	a5,a5,0x30
    80004c34:	93c1                	srli	a5,a5,0x30
    80004c36:	4705                	li	a4,1
    80004c38:	00f76d63          	bltu	a4,a5,80004c52 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004c3c:	8556                	mv	a0,s5
    80004c3e:	60a6                	ld	ra,72(sp)
    80004c40:	6406                	ld	s0,64(sp)
    80004c42:	74e2                	ld	s1,56(sp)
    80004c44:	7942                	ld	s2,48(sp)
    80004c46:	79a2                	ld	s3,40(sp)
    80004c48:	7a02                	ld	s4,32(sp)
    80004c4a:	6ae2                	ld	s5,24(sp)
    80004c4c:	6b42                	ld	s6,16(sp)
    80004c4e:	6161                	addi	sp,sp,80
    80004c50:	8082                	ret
    iunlockput(ip);
    80004c52:	8556                	mv	a0,s5
    80004c54:	a0bfe0ef          	jal	ra,8000365e <iunlockput>
    return 0;
    80004c58:	4a81                	li	s5,0
    80004c5a:	b7cd                	j	80004c3c <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004c5c:	85da                	mv	a1,s6
    80004c5e:	4088                	lw	a0,0(s1)
    80004c60:	e90fe0ef          	jal	ra,800032f0 <ialloc>
    80004c64:	8a2a                	mv	s4,a0
    80004c66:	cd1d                	beqz	a0,80004ca4 <create+0xca>
  ilock(ip);
    80004c68:	ff0fe0ef          	jal	ra,80003458 <ilock>
  ip->major = major;
    80004c6c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004c70:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004c74:	4905                	li	s2,1
    80004c76:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004c7a:	8552                	mv	a0,s4
    80004c7c:	f2afe0ef          	jal	ra,800033a6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004c80:	000b059b          	sext.w	a1,s6
    80004c84:	03258563          	beq	a1,s2,80004cae <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c88:	004a2603          	lw	a2,4(s4)
    80004c8c:	fb040593          	addi	a1,s0,-80
    80004c90:	8526                	mv	a0,s1
    80004c92:	f1bfe0ef          	jal	ra,80003bac <dirlink>
    80004c96:	06054363          	bltz	a0,80004cfc <create+0x122>
  iunlockput(dp);
    80004c9a:	8526                	mv	a0,s1
    80004c9c:	9c3fe0ef          	jal	ra,8000365e <iunlockput>
  return ip;
    80004ca0:	8ad2                	mv	s5,s4
    80004ca2:	bf69                	j	80004c3c <create+0x62>
    iunlockput(dp);
    80004ca4:	8526                	mv	a0,s1
    80004ca6:	9b9fe0ef          	jal	ra,8000365e <iunlockput>
    return 0;
    80004caa:	8ad2                	mv	s5,s4
    80004cac:	bf41                	j	80004c3c <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004cae:	004a2603          	lw	a2,4(s4)
    80004cb2:	00003597          	auipc	a1,0x3
    80004cb6:	b1e58593          	addi	a1,a1,-1250 # 800077d0 <syscalls+0x3e0>
    80004cba:	8552                	mv	a0,s4
    80004cbc:	ef1fe0ef          	jal	ra,80003bac <dirlink>
    80004cc0:	02054e63          	bltz	a0,80004cfc <create+0x122>
    80004cc4:	40d0                	lw	a2,4(s1)
    80004cc6:	00003597          	auipc	a1,0x3
    80004cca:	b1258593          	addi	a1,a1,-1262 # 800077d8 <syscalls+0x3e8>
    80004cce:	8552                	mv	a0,s4
    80004cd0:	eddfe0ef          	jal	ra,80003bac <dirlink>
    80004cd4:	02054463          	bltz	a0,80004cfc <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004cd8:	004a2603          	lw	a2,4(s4)
    80004cdc:	fb040593          	addi	a1,s0,-80
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	ecbfe0ef          	jal	ra,80003bac <dirlink>
    80004ce6:	00054b63          	bltz	a0,80004cfc <create+0x122>
    dp->nlink++;  // for ".."
    80004cea:	04a4d783          	lhu	a5,74(s1)
    80004cee:	2785                	addiw	a5,a5,1
    80004cf0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004cf4:	8526                	mv	a0,s1
    80004cf6:	eb0fe0ef          	jal	ra,800033a6 <iupdate>
    80004cfa:	b745                	j	80004c9a <create+0xc0>
  ip->nlink = 0;
    80004cfc:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004d00:	8552                	mv	a0,s4
    80004d02:	ea4fe0ef          	jal	ra,800033a6 <iupdate>
  iunlockput(ip);
    80004d06:	8552                	mv	a0,s4
    80004d08:	957fe0ef          	jal	ra,8000365e <iunlockput>
  iunlockput(dp);
    80004d0c:	8526                	mv	a0,s1
    80004d0e:	951fe0ef          	jal	ra,8000365e <iunlockput>
  return 0;
    80004d12:	b72d                	j	80004c3c <create+0x62>
    return 0;
    80004d14:	8aaa                	mv	s5,a0
    80004d16:	b71d                	j	80004c3c <create+0x62>

0000000080004d18 <sys_dup>:
{
    80004d18:	7179                	addi	sp,sp,-48
    80004d1a:	f406                	sd	ra,40(sp)
    80004d1c:	f022                	sd	s0,32(sp)
    80004d1e:	ec26                	sd	s1,24(sp)
    80004d20:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004d22:	fd840613          	addi	a2,s0,-40
    80004d26:	4581                	li	a1,0
    80004d28:	4501                	li	a0,0
    80004d2a:	e1bff0ef          	jal	ra,80004b44 <argfd>
    return -1;
    80004d2e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004d30:	00054f63          	bltz	a0,80004d4e <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004d34:	fd843503          	ld	a0,-40(s0)
    80004d38:	e65ff0ef          	jal	ra,80004b9c <fdalloc>
    80004d3c:	84aa                	mv	s1,a0
    return -1;
    80004d3e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004d40:	00054763          	bltz	a0,80004d4e <sys_dup+0x36>
  filedup(f);
    80004d44:	fd843503          	ld	a0,-40(s0)
    80004d48:	cb6ff0ef          	jal	ra,800041fe <filedup>
  return fd;
    80004d4c:	87a6                	mv	a5,s1
}
    80004d4e:	853e                	mv	a0,a5
    80004d50:	70a2                	ld	ra,40(sp)
    80004d52:	7402                	ld	s0,32(sp)
    80004d54:	64e2                	ld	s1,24(sp)
    80004d56:	6145                	addi	sp,sp,48
    80004d58:	8082                	ret

0000000080004d5a <sys_read>:
{
    80004d5a:	7179                	addi	sp,sp,-48
    80004d5c:	f406                	sd	ra,40(sp)
    80004d5e:	f022                	sd	s0,32(sp)
    80004d60:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d62:	fd840593          	addi	a1,s0,-40
    80004d66:	4505                	li	a0,1
    80004d68:	a6bfd0ef          	jal	ra,800027d2 <argaddr>
  argint(2, &n);
    80004d6c:	fe440593          	addi	a1,s0,-28
    80004d70:	4509                	li	a0,2
    80004d72:	a45fd0ef          	jal	ra,800027b6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004d76:	fe840613          	addi	a2,s0,-24
    80004d7a:	4581                	li	a1,0
    80004d7c:	4501                	li	a0,0
    80004d7e:	dc7ff0ef          	jal	ra,80004b44 <argfd>
    80004d82:	87aa                	mv	a5,a0
    return -1;
    80004d84:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d86:	0007ca63          	bltz	a5,80004d9a <sys_read+0x40>
  return fileread(f, p, n);
    80004d8a:	fe442603          	lw	a2,-28(s0)
    80004d8e:	fd843583          	ld	a1,-40(s0)
    80004d92:	fe843503          	ld	a0,-24(s0)
    80004d96:	db4ff0ef          	jal	ra,8000434a <fileread>
}
    80004d9a:	70a2                	ld	ra,40(sp)
    80004d9c:	7402                	ld	s0,32(sp)
    80004d9e:	6145                	addi	sp,sp,48
    80004da0:	8082                	ret

0000000080004da2 <sys_write>:
{
    80004da2:	7179                	addi	sp,sp,-48
    80004da4:	f406                	sd	ra,40(sp)
    80004da6:	f022                	sd	s0,32(sp)
    80004da8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004daa:	fd840593          	addi	a1,s0,-40
    80004dae:	4505                	li	a0,1
    80004db0:	a23fd0ef          	jal	ra,800027d2 <argaddr>
  argint(2, &n);
    80004db4:	fe440593          	addi	a1,s0,-28
    80004db8:	4509                	li	a0,2
    80004dba:	9fdfd0ef          	jal	ra,800027b6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004dbe:	fe840613          	addi	a2,s0,-24
    80004dc2:	4581                	li	a1,0
    80004dc4:	4501                	li	a0,0
    80004dc6:	d7fff0ef          	jal	ra,80004b44 <argfd>
    80004dca:	87aa                	mv	a5,a0
    return -1;
    80004dcc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004dce:	0007ca63          	bltz	a5,80004de2 <sys_write+0x40>
  return filewrite(f, p, n);
    80004dd2:	fe442603          	lw	a2,-28(s0)
    80004dd6:	fd843583          	ld	a1,-40(s0)
    80004dda:	fe843503          	ld	a0,-24(s0)
    80004dde:	e1aff0ef          	jal	ra,800043f8 <filewrite>
}
    80004de2:	70a2                	ld	ra,40(sp)
    80004de4:	7402                	ld	s0,32(sp)
    80004de6:	6145                	addi	sp,sp,48
    80004de8:	8082                	ret

0000000080004dea <sys_close>:
{
    80004dea:	1101                	addi	sp,sp,-32
    80004dec:	ec06                	sd	ra,24(sp)
    80004dee:	e822                	sd	s0,16(sp)
    80004df0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004df2:	fe040613          	addi	a2,s0,-32
    80004df6:	fec40593          	addi	a1,s0,-20
    80004dfa:	4501                	li	a0,0
    80004dfc:	d49ff0ef          	jal	ra,80004b44 <argfd>
    return -1;
    80004e00:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004e02:	02054063          	bltz	a0,80004e22 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004e06:	a03fc0ef          	jal	ra,80001808 <myproc>
    80004e0a:	fec42783          	lw	a5,-20(s0)
    80004e0e:	07e9                	addi	a5,a5,26
    80004e10:	078e                	slli	a5,a5,0x3
    80004e12:	97aa                	add	a5,a5,a0
    80004e14:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004e18:	fe043503          	ld	a0,-32(s0)
    80004e1c:	c28ff0ef          	jal	ra,80004244 <fileclose>
  return 0;
    80004e20:	4781                	li	a5,0
}
    80004e22:	853e                	mv	a0,a5
    80004e24:	60e2                	ld	ra,24(sp)
    80004e26:	6442                	ld	s0,16(sp)
    80004e28:	6105                	addi	sp,sp,32
    80004e2a:	8082                	ret

0000000080004e2c <sys_fstat>:
{
    80004e2c:	1101                	addi	sp,sp,-32
    80004e2e:	ec06                	sd	ra,24(sp)
    80004e30:	e822                	sd	s0,16(sp)
    80004e32:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004e34:	fe040593          	addi	a1,s0,-32
    80004e38:	4505                	li	a0,1
    80004e3a:	999fd0ef          	jal	ra,800027d2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004e3e:	fe840613          	addi	a2,s0,-24
    80004e42:	4581                	li	a1,0
    80004e44:	4501                	li	a0,0
    80004e46:	cffff0ef          	jal	ra,80004b44 <argfd>
    80004e4a:	87aa                	mv	a5,a0
    return -1;
    80004e4c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e4e:	0007c863          	bltz	a5,80004e5e <sys_fstat+0x32>
  return filestat(f, st);
    80004e52:	fe043583          	ld	a1,-32(s0)
    80004e56:	fe843503          	ld	a0,-24(s0)
    80004e5a:	c92ff0ef          	jal	ra,800042ec <filestat>
}
    80004e5e:	60e2                	ld	ra,24(sp)
    80004e60:	6442                	ld	s0,16(sp)
    80004e62:	6105                	addi	sp,sp,32
    80004e64:	8082                	ret

0000000080004e66 <sys_link>:
{
    80004e66:	7169                	addi	sp,sp,-304
    80004e68:	f606                	sd	ra,296(sp)
    80004e6a:	f222                	sd	s0,288(sp)
    80004e6c:	ee26                	sd	s1,280(sp)
    80004e6e:	ea4a                	sd	s2,272(sp)
    80004e70:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e72:	08000613          	li	a2,128
    80004e76:	ed040593          	addi	a1,s0,-304
    80004e7a:	4501                	li	a0,0
    80004e7c:	973fd0ef          	jal	ra,800027ee <argstr>
    return -1;
    80004e80:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e82:	0c054663          	bltz	a0,80004f4e <sys_link+0xe8>
    80004e86:	08000613          	li	a2,128
    80004e8a:	f5040593          	addi	a1,s0,-176
    80004e8e:	4505                	li	a0,1
    80004e90:	95ffd0ef          	jal	ra,800027ee <argstr>
    return -1;
    80004e94:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e96:	0a054c63          	bltz	a0,80004f4e <sys_link+0xe8>
  begin_op();
    80004e9a:	f9dfe0ef          	jal	ra,80003e36 <begin_op>
  if((ip = namei(old)) == 0){
    80004e9e:	ed040513          	addi	a0,s0,-304
    80004ea2:	da5fe0ef          	jal	ra,80003c46 <namei>
    80004ea6:	84aa                	mv	s1,a0
    80004ea8:	c525                	beqz	a0,80004f10 <sys_link+0xaa>
  ilock(ip);
    80004eaa:	daefe0ef          	jal	ra,80003458 <ilock>
  if(ip->type == T_DIR){
    80004eae:	04449703          	lh	a4,68(s1)
    80004eb2:	4785                	li	a5,1
    80004eb4:	06f70263          	beq	a4,a5,80004f18 <sys_link+0xb2>
  ip->nlink++;
    80004eb8:	04a4d783          	lhu	a5,74(s1)
    80004ebc:	2785                	addiw	a5,a5,1
    80004ebe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ec2:	8526                	mv	a0,s1
    80004ec4:	ce2fe0ef          	jal	ra,800033a6 <iupdate>
  iunlock(ip);
    80004ec8:	8526                	mv	a0,s1
    80004eca:	e38fe0ef          	jal	ra,80003502 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004ece:	fd040593          	addi	a1,s0,-48
    80004ed2:	f5040513          	addi	a0,s0,-176
    80004ed6:	d8bfe0ef          	jal	ra,80003c60 <nameiparent>
    80004eda:	892a                	mv	s2,a0
    80004edc:	c921                	beqz	a0,80004f2c <sys_link+0xc6>
  ilock(dp);
    80004ede:	d7afe0ef          	jal	ra,80003458 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004ee2:	00092703          	lw	a4,0(s2)
    80004ee6:	409c                	lw	a5,0(s1)
    80004ee8:	02f71f63          	bne	a4,a5,80004f26 <sys_link+0xc0>
    80004eec:	40d0                	lw	a2,4(s1)
    80004eee:	fd040593          	addi	a1,s0,-48
    80004ef2:	854a                	mv	a0,s2
    80004ef4:	cb9fe0ef          	jal	ra,80003bac <dirlink>
    80004ef8:	02054763          	bltz	a0,80004f26 <sys_link+0xc0>
  iunlockput(dp);
    80004efc:	854a                	mv	a0,s2
    80004efe:	f60fe0ef          	jal	ra,8000365e <iunlockput>
  iput(ip);
    80004f02:	8526                	mv	a0,s1
    80004f04:	ed2fe0ef          	jal	ra,800035d6 <iput>
  end_op();
    80004f08:	f9ffe0ef          	jal	ra,80003ea6 <end_op>
  return 0;
    80004f0c:	4781                	li	a5,0
    80004f0e:	a081                	j	80004f4e <sys_link+0xe8>
    end_op();
    80004f10:	f97fe0ef          	jal	ra,80003ea6 <end_op>
    return -1;
    80004f14:	57fd                	li	a5,-1
    80004f16:	a825                	j	80004f4e <sys_link+0xe8>
    iunlockput(ip);
    80004f18:	8526                	mv	a0,s1
    80004f1a:	f44fe0ef          	jal	ra,8000365e <iunlockput>
    end_op();
    80004f1e:	f89fe0ef          	jal	ra,80003ea6 <end_op>
    return -1;
    80004f22:	57fd                	li	a5,-1
    80004f24:	a02d                	j	80004f4e <sys_link+0xe8>
    iunlockput(dp);
    80004f26:	854a                	mv	a0,s2
    80004f28:	f36fe0ef          	jal	ra,8000365e <iunlockput>
  ilock(ip);
    80004f2c:	8526                	mv	a0,s1
    80004f2e:	d2afe0ef          	jal	ra,80003458 <ilock>
  ip->nlink--;
    80004f32:	04a4d783          	lhu	a5,74(s1)
    80004f36:	37fd                	addiw	a5,a5,-1
    80004f38:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	c68fe0ef          	jal	ra,800033a6 <iupdate>
  iunlockput(ip);
    80004f42:	8526                	mv	a0,s1
    80004f44:	f1afe0ef          	jal	ra,8000365e <iunlockput>
  end_op();
    80004f48:	f5ffe0ef          	jal	ra,80003ea6 <end_op>
  return -1;
    80004f4c:	57fd                	li	a5,-1
}
    80004f4e:	853e                	mv	a0,a5
    80004f50:	70b2                	ld	ra,296(sp)
    80004f52:	7412                	ld	s0,288(sp)
    80004f54:	64f2                	ld	s1,280(sp)
    80004f56:	6952                	ld	s2,272(sp)
    80004f58:	6155                	addi	sp,sp,304
    80004f5a:	8082                	ret

0000000080004f5c <sys_unlink>:
{
    80004f5c:	7151                	addi	sp,sp,-240
    80004f5e:	f586                	sd	ra,232(sp)
    80004f60:	f1a2                	sd	s0,224(sp)
    80004f62:	eda6                	sd	s1,216(sp)
    80004f64:	e9ca                	sd	s2,208(sp)
    80004f66:	e5ce                	sd	s3,200(sp)
    80004f68:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004f6a:	08000613          	li	a2,128
    80004f6e:	f3040593          	addi	a1,s0,-208
    80004f72:	4501                	li	a0,0
    80004f74:	87bfd0ef          	jal	ra,800027ee <argstr>
    80004f78:	12054b63          	bltz	a0,800050ae <sys_unlink+0x152>
  begin_op();
    80004f7c:	ebbfe0ef          	jal	ra,80003e36 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004f80:	fb040593          	addi	a1,s0,-80
    80004f84:	f3040513          	addi	a0,s0,-208
    80004f88:	cd9fe0ef          	jal	ra,80003c60 <nameiparent>
    80004f8c:	84aa                	mv	s1,a0
    80004f8e:	c54d                	beqz	a0,80005038 <sys_unlink+0xdc>
  ilock(dp);
    80004f90:	cc8fe0ef          	jal	ra,80003458 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f94:	00003597          	auipc	a1,0x3
    80004f98:	83c58593          	addi	a1,a1,-1988 # 800077d0 <syscalls+0x3e0>
    80004f9c:	fb040513          	addi	a0,s0,-80
    80004fa0:	a2bfe0ef          	jal	ra,800039ca <namecmp>
    80004fa4:	10050a63          	beqz	a0,800050b8 <sys_unlink+0x15c>
    80004fa8:	00003597          	auipc	a1,0x3
    80004fac:	83058593          	addi	a1,a1,-2000 # 800077d8 <syscalls+0x3e8>
    80004fb0:	fb040513          	addi	a0,s0,-80
    80004fb4:	a17fe0ef          	jal	ra,800039ca <namecmp>
    80004fb8:	10050063          	beqz	a0,800050b8 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004fbc:	f2c40613          	addi	a2,s0,-212
    80004fc0:	fb040593          	addi	a1,s0,-80
    80004fc4:	8526                	mv	a0,s1
    80004fc6:	a1bfe0ef          	jal	ra,800039e0 <dirlookup>
    80004fca:	892a                	mv	s2,a0
    80004fcc:	0e050663          	beqz	a0,800050b8 <sys_unlink+0x15c>
  ilock(ip);
    80004fd0:	c88fe0ef          	jal	ra,80003458 <ilock>
  if(ip->nlink < 1)
    80004fd4:	04a91783          	lh	a5,74(s2)
    80004fd8:	06f05463          	blez	a5,80005040 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004fdc:	04491703          	lh	a4,68(s2)
    80004fe0:	4785                	li	a5,1
    80004fe2:	06f70563          	beq	a4,a5,8000504c <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004fe6:	4641                	li	a2,16
    80004fe8:	4581                	li	a1,0
    80004fea:	fc040513          	addi	a0,s0,-64
    80004fee:	c53fb0ef          	jal	ra,80000c40 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ff2:	4741                	li	a4,16
    80004ff4:	f2c42683          	lw	a3,-212(s0)
    80004ff8:	fc040613          	addi	a2,s0,-64
    80004ffc:	4581                	li	a1,0
    80004ffe:	8526                	mv	a0,s1
    80005000:	8c9fe0ef          	jal	ra,800038c8 <writei>
    80005004:	47c1                	li	a5,16
    80005006:	08f51563          	bne	a0,a5,80005090 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    8000500a:	04491703          	lh	a4,68(s2)
    8000500e:	4785                	li	a5,1
    80005010:	08f70663          	beq	a4,a5,8000509c <sys_unlink+0x140>
  iunlockput(dp);
    80005014:	8526                	mv	a0,s1
    80005016:	e48fe0ef          	jal	ra,8000365e <iunlockput>
  ip->nlink--;
    8000501a:	04a95783          	lhu	a5,74(s2)
    8000501e:	37fd                	addiw	a5,a5,-1
    80005020:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005024:	854a                	mv	a0,s2
    80005026:	b80fe0ef          	jal	ra,800033a6 <iupdate>
  iunlockput(ip);
    8000502a:	854a                	mv	a0,s2
    8000502c:	e32fe0ef          	jal	ra,8000365e <iunlockput>
  end_op();
    80005030:	e77fe0ef          	jal	ra,80003ea6 <end_op>
  return 0;
    80005034:	4501                	li	a0,0
    80005036:	a079                	j	800050c4 <sys_unlink+0x168>
    end_op();
    80005038:	e6ffe0ef          	jal	ra,80003ea6 <end_op>
    return -1;
    8000503c:	557d                	li	a0,-1
    8000503e:	a059                	j	800050c4 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005040:	00002517          	auipc	a0,0x2
    80005044:	7a050513          	addi	a0,a0,1952 # 800077e0 <syscalls+0x3f0>
    80005048:	f42fb0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000504c:	04c92703          	lw	a4,76(s2)
    80005050:	02000793          	li	a5,32
    80005054:	f8e7f9e3          	bgeu	a5,a4,80004fe6 <sys_unlink+0x8a>
    80005058:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000505c:	4741                	li	a4,16
    8000505e:	86ce                	mv	a3,s3
    80005060:	f1840613          	addi	a2,s0,-232
    80005064:	4581                	li	a1,0
    80005066:	854a                	mv	a0,s2
    80005068:	f7cfe0ef          	jal	ra,800037e4 <readi>
    8000506c:	47c1                	li	a5,16
    8000506e:	00f51b63          	bne	a0,a5,80005084 <sys_unlink+0x128>
    if(de.inum != 0)
    80005072:	f1845783          	lhu	a5,-232(s0)
    80005076:	ef95                	bnez	a5,800050b2 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005078:	29c1                	addiw	s3,s3,16
    8000507a:	04c92783          	lw	a5,76(s2)
    8000507e:	fcf9efe3          	bltu	s3,a5,8000505c <sys_unlink+0x100>
    80005082:	b795                	j	80004fe6 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005084:	00002517          	auipc	a0,0x2
    80005088:	77450513          	addi	a0,a0,1908 # 800077f8 <syscalls+0x408>
    8000508c:	efefb0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    80005090:	00002517          	auipc	a0,0x2
    80005094:	78050513          	addi	a0,a0,1920 # 80007810 <syscalls+0x420>
    80005098:	ef2fb0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    8000509c:	04a4d783          	lhu	a5,74(s1)
    800050a0:	37fd                	addiw	a5,a5,-1
    800050a2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050a6:	8526                	mv	a0,s1
    800050a8:	afefe0ef          	jal	ra,800033a6 <iupdate>
    800050ac:	b7a5                	j	80005014 <sys_unlink+0xb8>
    return -1;
    800050ae:	557d                	li	a0,-1
    800050b0:	a811                	j	800050c4 <sys_unlink+0x168>
    iunlockput(ip);
    800050b2:	854a                	mv	a0,s2
    800050b4:	daafe0ef          	jal	ra,8000365e <iunlockput>
  iunlockput(dp);
    800050b8:	8526                	mv	a0,s1
    800050ba:	da4fe0ef          	jal	ra,8000365e <iunlockput>
  end_op();
    800050be:	de9fe0ef          	jal	ra,80003ea6 <end_op>
  return -1;
    800050c2:	557d                	li	a0,-1
}
    800050c4:	70ae                	ld	ra,232(sp)
    800050c6:	740e                	ld	s0,224(sp)
    800050c8:	64ee                	ld	s1,216(sp)
    800050ca:	694e                	ld	s2,208(sp)
    800050cc:	69ae                	ld	s3,200(sp)
    800050ce:	616d                	addi	sp,sp,240
    800050d0:	8082                	ret

00000000800050d2 <sys_open>:

uint64
sys_open(void)
{
    800050d2:	7131                	addi	sp,sp,-192
    800050d4:	fd06                	sd	ra,184(sp)
    800050d6:	f922                	sd	s0,176(sp)
    800050d8:	f526                	sd	s1,168(sp)
    800050da:	f14a                	sd	s2,160(sp)
    800050dc:	ed4e                	sd	s3,152(sp)
    800050de:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800050e0:	f4c40593          	addi	a1,s0,-180
    800050e4:	4505                	li	a0,1
    800050e6:	ed0fd0ef          	jal	ra,800027b6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800050ea:	08000613          	li	a2,128
    800050ee:	f5040593          	addi	a1,s0,-176
    800050f2:	4501                	li	a0,0
    800050f4:	efafd0ef          	jal	ra,800027ee <argstr>
    800050f8:	87aa                	mv	a5,a0
    return -1;
    800050fa:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800050fc:	0807cd63          	bltz	a5,80005196 <sys_open+0xc4>

  begin_op();
    80005100:	d37fe0ef          	jal	ra,80003e36 <begin_op>

  if(omode & O_CREATE){
    80005104:	f4c42783          	lw	a5,-180(s0)
    80005108:	2007f793          	andi	a5,a5,512
    8000510c:	c3c5                	beqz	a5,800051ac <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000510e:	4681                	li	a3,0
    80005110:	4601                	li	a2,0
    80005112:	4589                	li	a1,2
    80005114:	f5040513          	addi	a0,s0,-176
    80005118:	ac3ff0ef          	jal	ra,80004bda <create>
    8000511c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000511e:	c159                	beqz	a0,800051a4 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005120:	04449703          	lh	a4,68(s1)
    80005124:	478d                	li	a5,3
    80005126:	00f71763          	bne	a4,a5,80005134 <sys_open+0x62>
    8000512a:	0464d703          	lhu	a4,70(s1)
    8000512e:	47a5                	li	a5,9
    80005130:	0ae7e963          	bltu	a5,a4,800051e2 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005134:	86cff0ef          	jal	ra,800041a0 <filealloc>
    80005138:	89aa                	mv	s3,a0
    8000513a:	0c050963          	beqz	a0,8000520c <sys_open+0x13a>
    8000513e:	a5fff0ef          	jal	ra,80004b9c <fdalloc>
    80005142:	892a                	mv	s2,a0
    80005144:	0c054163          	bltz	a0,80005206 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005148:	04449703          	lh	a4,68(s1)
    8000514c:	478d                	li	a5,3
    8000514e:	0af70163          	beq	a4,a5,800051f0 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005152:	4789                	li	a5,2
    80005154:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005158:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000515c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005160:	f4c42783          	lw	a5,-180(s0)
    80005164:	0017c713          	xori	a4,a5,1
    80005168:	8b05                	andi	a4,a4,1
    8000516a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000516e:	0037f713          	andi	a4,a5,3
    80005172:	00e03733          	snez	a4,a4
    80005176:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000517a:	4007f793          	andi	a5,a5,1024
    8000517e:	c791                	beqz	a5,8000518a <sys_open+0xb8>
    80005180:	04449703          	lh	a4,68(s1)
    80005184:	4789                	li	a5,2
    80005186:	06f70c63          	beq	a4,a5,800051fe <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    8000518a:	8526                	mv	a0,s1
    8000518c:	b76fe0ef          	jal	ra,80003502 <iunlock>
  end_op();
    80005190:	d17fe0ef          	jal	ra,80003ea6 <end_op>

  return fd;
    80005194:	854a                	mv	a0,s2
}
    80005196:	70ea                	ld	ra,184(sp)
    80005198:	744a                	ld	s0,176(sp)
    8000519a:	74aa                	ld	s1,168(sp)
    8000519c:	790a                	ld	s2,160(sp)
    8000519e:	69ea                	ld	s3,152(sp)
    800051a0:	6129                	addi	sp,sp,192
    800051a2:	8082                	ret
      end_op();
    800051a4:	d03fe0ef          	jal	ra,80003ea6 <end_op>
      return -1;
    800051a8:	557d                	li	a0,-1
    800051aa:	b7f5                	j	80005196 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    800051ac:	f5040513          	addi	a0,s0,-176
    800051b0:	a97fe0ef          	jal	ra,80003c46 <namei>
    800051b4:	84aa                	mv	s1,a0
    800051b6:	c115                	beqz	a0,800051da <sys_open+0x108>
    ilock(ip);
    800051b8:	aa0fe0ef          	jal	ra,80003458 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800051bc:	04449703          	lh	a4,68(s1)
    800051c0:	4785                	li	a5,1
    800051c2:	f4f71fe3          	bne	a4,a5,80005120 <sys_open+0x4e>
    800051c6:	f4c42783          	lw	a5,-180(s0)
    800051ca:	d7ad                	beqz	a5,80005134 <sys_open+0x62>
      iunlockput(ip);
    800051cc:	8526                	mv	a0,s1
    800051ce:	c90fe0ef          	jal	ra,8000365e <iunlockput>
      end_op();
    800051d2:	cd5fe0ef          	jal	ra,80003ea6 <end_op>
      return -1;
    800051d6:	557d                	li	a0,-1
    800051d8:	bf7d                	j	80005196 <sys_open+0xc4>
      end_op();
    800051da:	ccdfe0ef          	jal	ra,80003ea6 <end_op>
      return -1;
    800051de:	557d                	li	a0,-1
    800051e0:	bf5d                	j	80005196 <sys_open+0xc4>
    iunlockput(ip);
    800051e2:	8526                	mv	a0,s1
    800051e4:	c7afe0ef          	jal	ra,8000365e <iunlockput>
    end_op();
    800051e8:	cbffe0ef          	jal	ra,80003ea6 <end_op>
    return -1;
    800051ec:	557d                	li	a0,-1
    800051ee:	b765                	j	80005196 <sys_open+0xc4>
    f->type = FD_DEVICE;
    800051f0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800051f4:	04649783          	lh	a5,70(s1)
    800051f8:	02f99223          	sh	a5,36(s3)
    800051fc:	b785                	j	8000515c <sys_open+0x8a>
    itrunc(ip);
    800051fe:	8526                	mv	a0,s1
    80005200:	b42fe0ef          	jal	ra,80003542 <itrunc>
    80005204:	b759                	j	8000518a <sys_open+0xb8>
      fileclose(f);
    80005206:	854e                	mv	a0,s3
    80005208:	83cff0ef          	jal	ra,80004244 <fileclose>
    iunlockput(ip);
    8000520c:	8526                	mv	a0,s1
    8000520e:	c50fe0ef          	jal	ra,8000365e <iunlockput>
    end_op();
    80005212:	c95fe0ef          	jal	ra,80003ea6 <end_op>
    return -1;
    80005216:	557d                	li	a0,-1
    80005218:	bfbd                	j	80005196 <sys_open+0xc4>

000000008000521a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000521a:	7175                	addi	sp,sp,-144
    8000521c:	e506                	sd	ra,136(sp)
    8000521e:	e122                	sd	s0,128(sp)
    80005220:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005222:	c15fe0ef          	jal	ra,80003e36 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005226:	08000613          	li	a2,128
    8000522a:	f7040593          	addi	a1,s0,-144
    8000522e:	4501                	li	a0,0
    80005230:	dbefd0ef          	jal	ra,800027ee <argstr>
    80005234:	02054363          	bltz	a0,8000525a <sys_mkdir+0x40>
    80005238:	4681                	li	a3,0
    8000523a:	4601                	li	a2,0
    8000523c:	4585                	li	a1,1
    8000523e:	f7040513          	addi	a0,s0,-144
    80005242:	999ff0ef          	jal	ra,80004bda <create>
    80005246:	c911                	beqz	a0,8000525a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005248:	c16fe0ef          	jal	ra,8000365e <iunlockput>
  end_op();
    8000524c:	c5bfe0ef          	jal	ra,80003ea6 <end_op>
  return 0;
    80005250:	4501                	li	a0,0
}
    80005252:	60aa                	ld	ra,136(sp)
    80005254:	640a                	ld	s0,128(sp)
    80005256:	6149                	addi	sp,sp,144
    80005258:	8082                	ret
    end_op();
    8000525a:	c4dfe0ef          	jal	ra,80003ea6 <end_op>
    return -1;
    8000525e:	557d                	li	a0,-1
    80005260:	bfcd                	j	80005252 <sys_mkdir+0x38>

0000000080005262 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005262:	7135                	addi	sp,sp,-160
    80005264:	ed06                	sd	ra,152(sp)
    80005266:	e922                	sd	s0,144(sp)
    80005268:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000526a:	bcdfe0ef          	jal	ra,80003e36 <begin_op>
  argint(1, &major);
    8000526e:	f6c40593          	addi	a1,s0,-148
    80005272:	4505                	li	a0,1
    80005274:	d42fd0ef          	jal	ra,800027b6 <argint>
  argint(2, &minor);
    80005278:	f6840593          	addi	a1,s0,-152
    8000527c:	4509                	li	a0,2
    8000527e:	d38fd0ef          	jal	ra,800027b6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005282:	08000613          	li	a2,128
    80005286:	f7040593          	addi	a1,s0,-144
    8000528a:	4501                	li	a0,0
    8000528c:	d62fd0ef          	jal	ra,800027ee <argstr>
    80005290:	02054563          	bltz	a0,800052ba <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005294:	f6841683          	lh	a3,-152(s0)
    80005298:	f6c41603          	lh	a2,-148(s0)
    8000529c:	458d                	li	a1,3
    8000529e:	f7040513          	addi	a0,s0,-144
    800052a2:	939ff0ef          	jal	ra,80004bda <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800052a6:	c911                	beqz	a0,800052ba <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800052a8:	bb6fe0ef          	jal	ra,8000365e <iunlockput>
  end_op();
    800052ac:	bfbfe0ef          	jal	ra,80003ea6 <end_op>
  return 0;
    800052b0:	4501                	li	a0,0
}
    800052b2:	60ea                	ld	ra,152(sp)
    800052b4:	644a                	ld	s0,144(sp)
    800052b6:	610d                	addi	sp,sp,160
    800052b8:	8082                	ret
    end_op();
    800052ba:	bedfe0ef          	jal	ra,80003ea6 <end_op>
    return -1;
    800052be:	557d                	li	a0,-1
    800052c0:	bfcd                	j	800052b2 <sys_mknod+0x50>

00000000800052c2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800052c2:	7135                	addi	sp,sp,-160
    800052c4:	ed06                	sd	ra,152(sp)
    800052c6:	e922                	sd	s0,144(sp)
    800052c8:	e526                	sd	s1,136(sp)
    800052ca:	e14a                	sd	s2,128(sp)
    800052cc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800052ce:	d3afc0ef          	jal	ra,80001808 <myproc>
    800052d2:	892a                	mv	s2,a0
  
  begin_op();
    800052d4:	b63fe0ef          	jal	ra,80003e36 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800052d8:	08000613          	li	a2,128
    800052dc:	f6040593          	addi	a1,s0,-160
    800052e0:	4501                	li	a0,0
    800052e2:	d0cfd0ef          	jal	ra,800027ee <argstr>
    800052e6:	04054163          	bltz	a0,80005328 <sys_chdir+0x66>
    800052ea:	f6040513          	addi	a0,s0,-160
    800052ee:	959fe0ef          	jal	ra,80003c46 <namei>
    800052f2:	84aa                	mv	s1,a0
    800052f4:	c915                	beqz	a0,80005328 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800052f6:	962fe0ef          	jal	ra,80003458 <ilock>
  if(ip->type != T_DIR){
    800052fa:	04449703          	lh	a4,68(s1)
    800052fe:	4785                	li	a5,1
    80005300:	02f71863          	bne	a4,a5,80005330 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005304:	8526                	mv	a0,s1
    80005306:	9fcfe0ef          	jal	ra,80003502 <iunlock>
  iput(p->cwd);
    8000530a:	15093503          	ld	a0,336(s2)
    8000530e:	ac8fe0ef          	jal	ra,800035d6 <iput>
  end_op();
    80005312:	b95fe0ef          	jal	ra,80003ea6 <end_op>
  p->cwd = ip;
    80005316:	14993823          	sd	s1,336(s2)
  return 0;
    8000531a:	4501                	li	a0,0
}
    8000531c:	60ea                	ld	ra,152(sp)
    8000531e:	644a                	ld	s0,144(sp)
    80005320:	64aa                	ld	s1,136(sp)
    80005322:	690a                	ld	s2,128(sp)
    80005324:	610d                	addi	sp,sp,160
    80005326:	8082                	ret
    end_op();
    80005328:	b7ffe0ef          	jal	ra,80003ea6 <end_op>
    return -1;
    8000532c:	557d                	li	a0,-1
    8000532e:	b7fd                	j	8000531c <sys_chdir+0x5a>
    iunlockput(ip);
    80005330:	8526                	mv	a0,s1
    80005332:	b2cfe0ef          	jal	ra,8000365e <iunlockput>
    end_op();
    80005336:	b71fe0ef          	jal	ra,80003ea6 <end_op>
    return -1;
    8000533a:	557d                	li	a0,-1
    8000533c:	b7c5                	j	8000531c <sys_chdir+0x5a>

000000008000533e <sys_exec>:

uint64
sys_exec(void)
{
    8000533e:	7145                	addi	sp,sp,-464
    80005340:	e786                	sd	ra,456(sp)
    80005342:	e3a2                	sd	s0,448(sp)
    80005344:	ff26                	sd	s1,440(sp)
    80005346:	fb4a                	sd	s2,432(sp)
    80005348:	f74e                	sd	s3,424(sp)
    8000534a:	f352                	sd	s4,416(sp)
    8000534c:	ef56                	sd	s5,408(sp)
    8000534e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005350:	e3840593          	addi	a1,s0,-456
    80005354:	4505                	li	a0,1
    80005356:	c7cfd0ef          	jal	ra,800027d2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000535a:	08000613          	li	a2,128
    8000535e:	f4040593          	addi	a1,s0,-192
    80005362:	4501                	li	a0,0
    80005364:	c8afd0ef          	jal	ra,800027ee <argstr>
    80005368:	87aa                	mv	a5,a0
    return -1;
    8000536a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000536c:	0a07c463          	bltz	a5,80005414 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80005370:	10000613          	li	a2,256
    80005374:	4581                	li	a1,0
    80005376:	e4040513          	addi	a0,s0,-448
    8000537a:	8c7fb0ef          	jal	ra,80000c40 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000537e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005382:	89a6                	mv	s3,s1
    80005384:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005386:	02000a13          	li	s4,32
    8000538a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000538e:	00391793          	slli	a5,s2,0x3
    80005392:	e3040593          	addi	a1,s0,-464
    80005396:	e3843503          	ld	a0,-456(s0)
    8000539a:	953e                	add	a0,a0,a5
    8000539c:	b90fd0ef          	jal	ra,8000272c <fetchaddr>
    800053a0:	02054663          	bltz	a0,800053cc <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    800053a4:	e3043783          	ld	a5,-464(s0)
    800053a8:	cf8d                	beqz	a5,800053e2 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800053aa:	ef2fb0ef          	jal	ra,80000a9c <kalloc>
    800053ae:	85aa                	mv	a1,a0
    800053b0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800053b4:	cd01                	beqz	a0,800053cc <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800053b6:	6605                	lui	a2,0x1
    800053b8:	e3043503          	ld	a0,-464(s0)
    800053bc:	bbafd0ef          	jal	ra,80002776 <fetchstr>
    800053c0:	00054663          	bltz	a0,800053cc <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800053c4:	0905                	addi	s2,s2,1
    800053c6:	09a1                	addi	s3,s3,8
    800053c8:	fd4911e3          	bne	s2,s4,8000538a <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053cc:	10048913          	addi	s2,s1,256
    800053d0:	6088                	ld	a0,0(s1)
    800053d2:	c121                	beqz	a0,80005412 <sys_exec+0xd4>
    kfree(argv[i]);
    800053d4:	de8fb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053d8:	04a1                	addi	s1,s1,8
    800053da:	ff249be3          	bne	s1,s2,800053d0 <sys_exec+0x92>
  return -1;
    800053de:	557d                	li	a0,-1
    800053e0:	a815                	j	80005414 <sys_exec+0xd6>
      argv[i] = 0;
    800053e2:	0a8e                	slli	s5,s5,0x3
    800053e4:	fc040793          	addi	a5,s0,-64
    800053e8:	9abe                	add	s5,s5,a5
    800053ea:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    800053ee:	e4040593          	addi	a1,s0,-448
    800053f2:	f4040513          	addi	a0,s0,-192
    800053f6:	bfaff0ef          	jal	ra,800047f0 <kexec>
    800053fa:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053fc:	10048993          	addi	s3,s1,256
    80005400:	6088                	ld	a0,0(s1)
    80005402:	c511                	beqz	a0,8000540e <sys_exec+0xd0>
    kfree(argv[i]);
    80005404:	db8fb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005408:	04a1                	addi	s1,s1,8
    8000540a:	ff349be3          	bne	s1,s3,80005400 <sys_exec+0xc2>
  return ret;
    8000540e:	854a                	mv	a0,s2
    80005410:	a011                	j	80005414 <sys_exec+0xd6>
  return -1;
    80005412:	557d                	li	a0,-1
}
    80005414:	60be                	ld	ra,456(sp)
    80005416:	641e                	ld	s0,448(sp)
    80005418:	74fa                	ld	s1,440(sp)
    8000541a:	795a                	ld	s2,432(sp)
    8000541c:	79ba                	ld	s3,424(sp)
    8000541e:	7a1a                	ld	s4,416(sp)
    80005420:	6afa                	ld	s5,408(sp)
    80005422:	6179                	addi	sp,sp,464
    80005424:	8082                	ret

0000000080005426 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005426:	7139                	addi	sp,sp,-64
    80005428:	fc06                	sd	ra,56(sp)
    8000542a:	f822                	sd	s0,48(sp)
    8000542c:	f426                	sd	s1,40(sp)
    8000542e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005430:	bd8fc0ef          	jal	ra,80001808 <myproc>
    80005434:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005436:	fd840593          	addi	a1,s0,-40
    8000543a:	4501                	li	a0,0
    8000543c:	b96fd0ef          	jal	ra,800027d2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005440:	fc840593          	addi	a1,s0,-56
    80005444:	fd040513          	addi	a0,s0,-48
    80005448:	8c8ff0ef          	jal	ra,80004510 <pipealloc>
    return -1;
    8000544c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000544e:	0a054463          	bltz	a0,800054f6 <sys_pipe+0xd0>
  fd0 = -1;
    80005452:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005456:	fd043503          	ld	a0,-48(s0)
    8000545a:	f42ff0ef          	jal	ra,80004b9c <fdalloc>
    8000545e:	fca42223          	sw	a0,-60(s0)
    80005462:	08054163          	bltz	a0,800054e4 <sys_pipe+0xbe>
    80005466:	fc843503          	ld	a0,-56(s0)
    8000546a:	f32ff0ef          	jal	ra,80004b9c <fdalloc>
    8000546e:	fca42023          	sw	a0,-64(s0)
    80005472:	06054063          	bltz	a0,800054d2 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005476:	4691                	li	a3,4
    80005478:	fc440613          	addi	a2,s0,-60
    8000547c:	fd843583          	ld	a1,-40(s0)
    80005480:	68a8                	ld	a0,80(s1)
    80005482:	8d0fc0ef          	jal	ra,80001552 <copyout>
    80005486:	00054e63          	bltz	a0,800054a2 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000548a:	4691                	li	a3,4
    8000548c:	fc040613          	addi	a2,s0,-64
    80005490:	fd843583          	ld	a1,-40(s0)
    80005494:	0591                	addi	a1,a1,4
    80005496:	68a8                	ld	a0,80(s1)
    80005498:	8bafc0ef          	jal	ra,80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000549c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000549e:	04055c63          	bgez	a0,800054f6 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800054a2:	fc442783          	lw	a5,-60(s0)
    800054a6:	07e9                	addi	a5,a5,26
    800054a8:	078e                	slli	a5,a5,0x3
    800054aa:	97a6                	add	a5,a5,s1
    800054ac:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800054b0:	fc042503          	lw	a0,-64(s0)
    800054b4:	0569                	addi	a0,a0,26
    800054b6:	050e                	slli	a0,a0,0x3
    800054b8:	94aa                	add	s1,s1,a0
    800054ba:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800054be:	fd043503          	ld	a0,-48(s0)
    800054c2:	d83fe0ef          	jal	ra,80004244 <fileclose>
    fileclose(wf);
    800054c6:	fc843503          	ld	a0,-56(s0)
    800054ca:	d7bfe0ef          	jal	ra,80004244 <fileclose>
    return -1;
    800054ce:	57fd                	li	a5,-1
    800054d0:	a01d                	j	800054f6 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800054d2:	fc442783          	lw	a5,-60(s0)
    800054d6:	0007c763          	bltz	a5,800054e4 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800054da:	07e9                	addi	a5,a5,26
    800054dc:	078e                	slli	a5,a5,0x3
    800054de:	94be                	add	s1,s1,a5
    800054e0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800054e4:	fd043503          	ld	a0,-48(s0)
    800054e8:	d5dfe0ef          	jal	ra,80004244 <fileclose>
    fileclose(wf);
    800054ec:	fc843503          	ld	a0,-56(s0)
    800054f0:	d55fe0ef          	jal	ra,80004244 <fileclose>
    return -1;
    800054f4:	57fd                	li	a5,-1
}
    800054f6:	853e                	mv	a0,a5
    800054f8:	70e2                	ld	ra,56(sp)
    800054fa:	7442                	ld	s0,48(sp)
    800054fc:	74a2                	ld	s1,40(sp)
    800054fe:	6121                	addi	sp,sp,64
    80005500:	8082                	ret
	...

0000000080005510 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005510:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005512:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005514:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005516:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005518:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000551a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000551c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000551e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005520:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005522:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005524:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005526:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005528:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000552a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000552c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000552e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005530:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005532:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005534:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005536:	906fd0ef          	jal	ra,8000263c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000553a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000553c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000553e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005540:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005542:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005544:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005546:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005548:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000554a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000554c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000554e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005550:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005552:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005554:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005556:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005558:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000555a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000555c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000555e:	10200073          	sret
	...

000000008000556e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000556e:	1141                	addi	sp,sp,-16
    80005570:	e422                	sd	s0,8(sp)
    80005572:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005574:	0c0007b7          	lui	a5,0xc000
    80005578:	4705                	li	a4,1
    8000557a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000557c:	c3d8                	sw	a4,4(a5)
}
    8000557e:	6422                	ld	s0,8(sp)
    80005580:	0141                	addi	sp,sp,16
    80005582:	8082                	ret

0000000080005584 <plicinithart>:

void
plicinithart(void)
{
    80005584:	1141                	addi	sp,sp,-16
    80005586:	e406                	sd	ra,8(sp)
    80005588:	e022                	sd	s0,0(sp)
    8000558a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000558c:	a50fc0ef          	jal	ra,800017dc <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005590:	0085171b          	slliw	a4,a0,0x8
    80005594:	0c0027b7          	lui	a5,0xc002
    80005598:	97ba                	add	a5,a5,a4
    8000559a:	40200713          	li	a4,1026
    8000559e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800055a2:	00d5151b          	slliw	a0,a0,0xd
    800055a6:	0c2017b7          	lui	a5,0xc201
    800055aa:	953e                	add	a0,a0,a5
    800055ac:	00052023          	sw	zero,0(a0)
}
    800055b0:	60a2                	ld	ra,8(sp)
    800055b2:	6402                	ld	s0,0(sp)
    800055b4:	0141                	addi	sp,sp,16
    800055b6:	8082                	ret

00000000800055b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800055b8:	1141                	addi	sp,sp,-16
    800055ba:	e406                	sd	ra,8(sp)
    800055bc:	e022                	sd	s0,0(sp)
    800055be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800055c0:	a1cfc0ef          	jal	ra,800017dc <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800055c4:	00d5179b          	slliw	a5,a0,0xd
    800055c8:	0c201537          	lui	a0,0xc201
    800055cc:	953e                	add	a0,a0,a5
  return irq;
}
    800055ce:	4148                	lw	a0,4(a0)
    800055d0:	60a2                	ld	ra,8(sp)
    800055d2:	6402                	ld	s0,0(sp)
    800055d4:	0141                	addi	sp,sp,16
    800055d6:	8082                	ret

00000000800055d8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800055d8:	1101                	addi	sp,sp,-32
    800055da:	ec06                	sd	ra,24(sp)
    800055dc:	e822                	sd	s0,16(sp)
    800055de:	e426                	sd	s1,8(sp)
    800055e0:	1000                	addi	s0,sp,32
    800055e2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800055e4:	9f8fc0ef          	jal	ra,800017dc <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800055e8:	00d5151b          	slliw	a0,a0,0xd
    800055ec:	0c2017b7          	lui	a5,0xc201
    800055f0:	97aa                	add	a5,a5,a0
    800055f2:	c3c4                	sw	s1,4(a5)
}
    800055f4:	60e2                	ld	ra,24(sp)
    800055f6:	6442                	ld	s0,16(sp)
    800055f8:	64a2                	ld	s1,8(sp)
    800055fa:	6105                	addi	sp,sp,32
    800055fc:	8082                	ret

00000000800055fe <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800055fe:	1141                	addi	sp,sp,-16
    80005600:	e406                	sd	ra,8(sp)
    80005602:	e022                	sd	s0,0(sp)
    80005604:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005606:	479d                	li	a5,7
    80005608:	04a7ca63          	blt	a5,a0,8000565c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000560c:	0001c797          	auipc	a5,0x1c
    80005610:	91c78793          	addi	a5,a5,-1764 # 80020f28 <disk>
    80005614:	97aa                	add	a5,a5,a0
    80005616:	0187c783          	lbu	a5,24(a5)
    8000561a:	e7b9                	bnez	a5,80005668 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000561c:	00451613          	slli	a2,a0,0x4
    80005620:	0001c797          	auipc	a5,0x1c
    80005624:	90878793          	addi	a5,a5,-1784 # 80020f28 <disk>
    80005628:	6394                	ld	a3,0(a5)
    8000562a:	96b2                	add	a3,a3,a2
    8000562c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005630:	6398                	ld	a4,0(a5)
    80005632:	9732                	add	a4,a4,a2
    80005634:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005638:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000563c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005640:	953e                	add	a0,a0,a5
    80005642:	4785                	li	a5,1
    80005644:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005648:	0001c517          	auipc	a0,0x1c
    8000564c:	8f850513          	addi	a0,a0,-1800 # 80020f40 <disk+0x18>
    80005650:	8a7fc0ef          	jal	ra,80001ef6 <wakeup>
}
    80005654:	60a2                	ld	ra,8(sp)
    80005656:	6402                	ld	s0,0(sp)
    80005658:	0141                	addi	sp,sp,16
    8000565a:	8082                	ret
    panic("free_desc 1");
    8000565c:	00002517          	auipc	a0,0x2
    80005660:	1c450513          	addi	a0,a0,452 # 80007820 <syscalls+0x430>
    80005664:	926fb0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    80005668:	00002517          	auipc	a0,0x2
    8000566c:	1c850513          	addi	a0,a0,456 # 80007830 <syscalls+0x440>
    80005670:	91afb0ef          	jal	ra,8000078a <panic>

0000000080005674 <virtio_disk_init>:
{
    80005674:	1101                	addi	sp,sp,-32
    80005676:	ec06                	sd	ra,24(sp)
    80005678:	e822                	sd	s0,16(sp)
    8000567a:	e426                	sd	s1,8(sp)
    8000567c:	e04a                	sd	s2,0(sp)
    8000567e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005680:	00002597          	auipc	a1,0x2
    80005684:	1c058593          	addi	a1,a1,448 # 80007840 <syscalls+0x450>
    80005688:	0001c517          	auipc	a0,0x1c
    8000568c:	9c850513          	addi	a0,a0,-1592 # 80021050 <disk+0x128>
    80005690:	c5cfb0ef          	jal	ra,80000aec <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005694:	100017b7          	lui	a5,0x10001
    80005698:	4398                	lw	a4,0(a5)
    8000569a:	2701                	sext.w	a4,a4
    8000569c:	747277b7          	lui	a5,0x74727
    800056a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800056a4:	14f71063          	bne	a4,a5,800057e4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800056a8:	100017b7          	lui	a5,0x10001
    800056ac:	43dc                	lw	a5,4(a5)
    800056ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800056b0:	4709                	li	a4,2
    800056b2:	12e79963          	bne	a5,a4,800057e4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800056b6:	100017b7          	lui	a5,0x10001
    800056ba:	479c                	lw	a5,8(a5)
    800056bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800056be:	12e79363          	bne	a5,a4,800057e4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800056c2:	100017b7          	lui	a5,0x10001
    800056c6:	47d8                	lw	a4,12(a5)
    800056c8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800056ca:	554d47b7          	lui	a5,0x554d4
    800056ce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800056d2:	10f71963          	bne	a4,a5,800057e4 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    800056d6:	100017b7          	lui	a5,0x10001
    800056da:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800056de:	4705                	li	a4,1
    800056e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056e2:	470d                	li	a4,3
    800056e4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800056e6:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800056e8:	c7ffe737          	lui	a4,0xc7ffe
    800056ec:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd6f7>
    800056f0:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800056f2:	2701                	sext.w	a4,a4
    800056f4:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056f6:	472d                	li	a4,11
    800056f8:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800056fa:	5bbc                	lw	a5,112(a5)
    800056fc:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005700:	8ba1                	andi	a5,a5,8
    80005702:	0e078763          	beqz	a5,800057f0 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005706:	100017b7          	lui	a5,0x10001
    8000570a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000570e:	43fc                	lw	a5,68(a5)
    80005710:	2781                	sext.w	a5,a5
    80005712:	0e079563          	bnez	a5,800057fc <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005716:	100017b7          	lui	a5,0x10001
    8000571a:	5bdc                	lw	a5,52(a5)
    8000571c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000571e:	0e078563          	beqz	a5,80005808 <virtio_disk_init+0x194>
  if(max < NUM)
    80005722:	471d                	li	a4,7
    80005724:	0ef77863          	bgeu	a4,a5,80005814 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80005728:	b74fb0ef          	jal	ra,80000a9c <kalloc>
    8000572c:	0001b497          	auipc	s1,0x1b
    80005730:	7fc48493          	addi	s1,s1,2044 # 80020f28 <disk>
    80005734:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005736:	b66fb0ef          	jal	ra,80000a9c <kalloc>
    8000573a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000573c:	b60fb0ef          	jal	ra,80000a9c <kalloc>
    80005740:	87aa                	mv	a5,a0
    80005742:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005744:	6088                	ld	a0,0(s1)
    80005746:	cd69                	beqz	a0,80005820 <virtio_disk_init+0x1ac>
    80005748:	0001b717          	auipc	a4,0x1b
    8000574c:	7e873703          	ld	a4,2024(a4) # 80020f30 <disk+0x8>
    80005750:	cb61                	beqz	a4,80005820 <virtio_disk_init+0x1ac>
    80005752:	c7f9                	beqz	a5,80005820 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    80005754:	6605                	lui	a2,0x1
    80005756:	4581                	li	a1,0
    80005758:	ce8fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000575c:	0001b497          	auipc	s1,0x1b
    80005760:	7cc48493          	addi	s1,s1,1996 # 80020f28 <disk>
    80005764:	6605                	lui	a2,0x1
    80005766:	4581                	li	a1,0
    80005768:	6488                	ld	a0,8(s1)
    8000576a:	cd6fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.used, 0, PGSIZE);
    8000576e:	6605                	lui	a2,0x1
    80005770:	4581                	li	a1,0
    80005772:	6888                	ld	a0,16(s1)
    80005774:	cccfb0ef          	jal	ra,80000c40 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005778:	100017b7          	lui	a5,0x10001
    8000577c:	4721                	li	a4,8
    8000577e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005780:	4098                	lw	a4,0(s1)
    80005782:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005786:	40d8                	lw	a4,4(s1)
    80005788:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000578c:	6498                	ld	a4,8(s1)
    8000578e:	0007069b          	sext.w	a3,a4
    80005792:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005796:	9701                	srai	a4,a4,0x20
    80005798:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000579c:	6898                	ld	a4,16(s1)
    8000579e:	0007069b          	sext.w	a3,a4
    800057a2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800057a6:	9701                	srai	a4,a4,0x20
    800057a8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800057ac:	4705                	li	a4,1
    800057ae:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800057b0:	00e48c23          	sb	a4,24(s1)
    800057b4:	00e48ca3          	sb	a4,25(s1)
    800057b8:	00e48d23          	sb	a4,26(s1)
    800057bc:	00e48da3          	sb	a4,27(s1)
    800057c0:	00e48e23          	sb	a4,28(s1)
    800057c4:	00e48ea3          	sb	a4,29(s1)
    800057c8:	00e48f23          	sb	a4,30(s1)
    800057cc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800057d0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800057d4:	0727a823          	sw	s2,112(a5)
}
    800057d8:	60e2                	ld	ra,24(sp)
    800057da:	6442                	ld	s0,16(sp)
    800057dc:	64a2                	ld	s1,8(sp)
    800057de:	6902                	ld	s2,0(sp)
    800057e0:	6105                	addi	sp,sp,32
    800057e2:	8082                	ret
    panic("could not find virtio disk");
    800057e4:	00002517          	auipc	a0,0x2
    800057e8:	06c50513          	addi	a0,a0,108 # 80007850 <syscalls+0x460>
    800057ec:	f9ffa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    800057f0:	00002517          	auipc	a0,0x2
    800057f4:	08050513          	addi	a0,a0,128 # 80007870 <syscalls+0x480>
    800057f8:	f93fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    800057fc:	00002517          	auipc	a0,0x2
    80005800:	09450513          	addi	a0,a0,148 # 80007890 <syscalls+0x4a0>
    80005804:	f87fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    80005808:	00002517          	auipc	a0,0x2
    8000580c:	0a850513          	addi	a0,a0,168 # 800078b0 <syscalls+0x4c0>
    80005810:	f7bfa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    80005814:	00002517          	auipc	a0,0x2
    80005818:	0bc50513          	addi	a0,a0,188 # 800078d0 <syscalls+0x4e0>
    8000581c:	f6ffa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    80005820:	00002517          	auipc	a0,0x2
    80005824:	0d050513          	addi	a0,a0,208 # 800078f0 <syscalls+0x500>
    80005828:	f63fa0ef          	jal	ra,8000078a <panic>

000000008000582c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000582c:	7119                	addi	sp,sp,-128
    8000582e:	fc86                	sd	ra,120(sp)
    80005830:	f8a2                	sd	s0,112(sp)
    80005832:	f4a6                	sd	s1,104(sp)
    80005834:	f0ca                	sd	s2,96(sp)
    80005836:	ecce                	sd	s3,88(sp)
    80005838:	e8d2                	sd	s4,80(sp)
    8000583a:	e4d6                	sd	s5,72(sp)
    8000583c:	e0da                	sd	s6,64(sp)
    8000583e:	fc5e                	sd	s7,56(sp)
    80005840:	f862                	sd	s8,48(sp)
    80005842:	f466                	sd	s9,40(sp)
    80005844:	f06a                	sd	s10,32(sp)
    80005846:	ec6e                	sd	s11,24(sp)
    80005848:	0100                	addi	s0,sp,128
    8000584a:	8aaa                	mv	s5,a0
    8000584c:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000584e:	00c52d03          	lw	s10,12(a0)
    80005852:	001d1d1b          	slliw	s10,s10,0x1
    80005856:	1d02                	slli	s10,s10,0x20
    80005858:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000585c:	0001b517          	auipc	a0,0x1b
    80005860:	7f450513          	addi	a0,a0,2036 # 80021050 <disk+0x128>
    80005864:	b08fb0ef          	jal	ra,80000b6c <acquire>
  for(int i = 0; i < 3; i++){
    80005868:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000586a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000586c:	0001bb97          	auipc	s7,0x1b
    80005870:	6bcb8b93          	addi	s7,s7,1724 # 80020f28 <disk>
  for(int i = 0; i < 3; i++){
    80005874:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005876:	0001bc97          	auipc	s9,0x1b
    8000587a:	7dac8c93          	addi	s9,s9,2010 # 80021050 <disk+0x128>
    8000587e:	a8a9                	j	800058d8 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005880:	00fb8733          	add	a4,s7,a5
    80005884:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005888:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000588a:	0207c563          	bltz	a5,800058b4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000588e:	2905                	addiw	s2,s2,1
    80005890:	0611                	addi	a2,a2,4
    80005892:	05690863          	beq	s2,s6,800058e2 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005896:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005898:	0001b717          	auipc	a4,0x1b
    8000589c:	69070713          	addi	a4,a4,1680 # 80020f28 <disk>
    800058a0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800058a2:	01874683          	lbu	a3,24(a4)
    800058a6:	fee9                	bnez	a3,80005880 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800058a8:	2785                	addiw	a5,a5,1
    800058aa:	0705                	addi	a4,a4,1
    800058ac:	fe979be3          	bne	a5,s1,800058a2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800058b0:	57fd                	li	a5,-1
    800058b2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800058b4:	01205b63          	blez	s2,800058ca <virtio_disk_rw+0x9e>
    800058b8:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800058ba:	000a2503          	lw	a0,0(s4)
    800058be:	d41ff0ef          	jal	ra,800055fe <free_desc>
      for(int j = 0; j < i; j++)
    800058c2:	2d85                	addiw	s11,s11,1
    800058c4:	0a11                	addi	s4,s4,4
    800058c6:	ffb91ae3          	bne	s2,s11,800058ba <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800058ca:	85e6                	mv	a1,s9
    800058cc:	0001b517          	auipc	a0,0x1b
    800058d0:	67450513          	addi	a0,a0,1652 # 80020f40 <disk+0x18>
    800058d4:	dd6fc0ef          	jal	ra,80001eaa <sleep>
  for(int i = 0; i < 3; i++){
    800058d8:	f8040a13          	addi	s4,s0,-128
{
    800058dc:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800058de:	894e                	mv	s2,s3
    800058e0:	bf5d                	j	80005896 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800058e2:	f8042583          	lw	a1,-128(s0)
    800058e6:	00a58793          	addi	a5,a1,10
    800058ea:	0792                	slli	a5,a5,0x4

  if(write)
    800058ec:	0001b617          	auipc	a2,0x1b
    800058f0:	63c60613          	addi	a2,a2,1596 # 80020f28 <disk>
    800058f4:	00f60733          	add	a4,a2,a5
    800058f8:	018036b3          	snez	a3,s8
    800058fc:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800058fe:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005902:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005906:	f6078693          	addi	a3,a5,-160
    8000590a:	6218                	ld	a4,0(a2)
    8000590c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000590e:	00878513          	addi	a0,a5,8
    80005912:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005914:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005916:	6208                	ld	a0,0(a2)
    80005918:	96aa                	add	a3,a3,a0
    8000591a:	4741                	li	a4,16
    8000591c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000591e:	4705                	li	a4,1
    80005920:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005924:	f8442703          	lw	a4,-124(s0)
    80005928:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000592c:	0712                	slli	a4,a4,0x4
    8000592e:	953a                	add	a0,a0,a4
    80005930:	058a8693          	addi	a3,s5,88
    80005934:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80005936:	6208                	ld	a0,0(a2)
    80005938:	972a                	add	a4,a4,a0
    8000593a:	40000693          	li	a3,1024
    8000593e:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005940:	001c3c13          	seqz	s8,s8
    80005944:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005946:	001c6c13          	ori	s8,s8,1
    8000594a:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000594e:	f8842603          	lw	a2,-120(s0)
    80005952:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005956:	0001b697          	auipc	a3,0x1b
    8000595a:	5d268693          	addi	a3,a3,1490 # 80020f28 <disk>
    8000595e:	00258713          	addi	a4,a1,2
    80005962:	0712                	slli	a4,a4,0x4
    80005964:	9736                	add	a4,a4,a3
    80005966:	587d                	li	a6,-1
    80005968:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000596c:	0612                	slli	a2,a2,0x4
    8000596e:	9532                	add	a0,a0,a2
    80005970:	f9078793          	addi	a5,a5,-112
    80005974:	97b6                	add	a5,a5,a3
    80005976:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    80005978:	629c                	ld	a5,0(a3)
    8000597a:	97b2                	add	a5,a5,a2
    8000597c:	4605                	li	a2,1
    8000597e:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005980:	4509                	li	a0,2
    80005982:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    80005986:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000598a:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000598e:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005992:	6698                	ld	a4,8(a3)
    80005994:	00275783          	lhu	a5,2(a4)
    80005998:	8b9d                	andi	a5,a5,7
    8000599a:	0786                	slli	a5,a5,0x1
    8000599c:	97ba                	add	a5,a5,a4
    8000599e:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800059a2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800059a6:	6698                	ld	a4,8(a3)
    800059a8:	00275783          	lhu	a5,2(a4)
    800059ac:	2785                	addiw	a5,a5,1
    800059ae:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800059b2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800059b6:	100017b7          	lui	a5,0x10001
    800059ba:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800059be:	004aa783          	lw	a5,4(s5)
    800059c2:	00c79f63          	bne	a5,a2,800059e0 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    800059c6:	0001b917          	auipc	s2,0x1b
    800059ca:	68a90913          	addi	s2,s2,1674 # 80021050 <disk+0x128>
  while(b->disk == 1) {
    800059ce:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800059d0:	85ca                	mv	a1,s2
    800059d2:	8556                	mv	a0,s5
    800059d4:	cd6fc0ef          	jal	ra,80001eaa <sleep>
  while(b->disk == 1) {
    800059d8:	004aa783          	lw	a5,4(s5)
    800059dc:	fe978ae3          	beq	a5,s1,800059d0 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    800059e0:	f8042903          	lw	s2,-128(s0)
    800059e4:	00290793          	addi	a5,s2,2
    800059e8:	00479713          	slli	a4,a5,0x4
    800059ec:	0001b797          	auipc	a5,0x1b
    800059f0:	53c78793          	addi	a5,a5,1340 # 80020f28 <disk>
    800059f4:	97ba                	add	a5,a5,a4
    800059f6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800059fa:	0001b997          	auipc	s3,0x1b
    800059fe:	52e98993          	addi	s3,s3,1326 # 80020f28 <disk>
    80005a02:	00491713          	slli	a4,s2,0x4
    80005a06:	0009b783          	ld	a5,0(s3)
    80005a0a:	97ba                	add	a5,a5,a4
    80005a0c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005a10:	854a                	mv	a0,s2
    80005a12:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005a16:	be9ff0ef          	jal	ra,800055fe <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005a1a:	8885                	andi	s1,s1,1
    80005a1c:	f0fd                	bnez	s1,80005a02 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005a1e:	0001b517          	auipc	a0,0x1b
    80005a22:	63250513          	addi	a0,a0,1586 # 80021050 <disk+0x128>
    80005a26:	9defb0ef          	jal	ra,80000c04 <release>
}
    80005a2a:	70e6                	ld	ra,120(sp)
    80005a2c:	7446                	ld	s0,112(sp)
    80005a2e:	74a6                	ld	s1,104(sp)
    80005a30:	7906                	ld	s2,96(sp)
    80005a32:	69e6                	ld	s3,88(sp)
    80005a34:	6a46                	ld	s4,80(sp)
    80005a36:	6aa6                	ld	s5,72(sp)
    80005a38:	6b06                	ld	s6,64(sp)
    80005a3a:	7be2                	ld	s7,56(sp)
    80005a3c:	7c42                	ld	s8,48(sp)
    80005a3e:	7ca2                	ld	s9,40(sp)
    80005a40:	7d02                	ld	s10,32(sp)
    80005a42:	6de2                	ld	s11,24(sp)
    80005a44:	6109                	addi	sp,sp,128
    80005a46:	8082                	ret

0000000080005a48 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005a48:	1101                	addi	sp,sp,-32
    80005a4a:	ec06                	sd	ra,24(sp)
    80005a4c:	e822                	sd	s0,16(sp)
    80005a4e:	e426                	sd	s1,8(sp)
    80005a50:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005a52:	0001b497          	auipc	s1,0x1b
    80005a56:	4d648493          	addi	s1,s1,1238 # 80020f28 <disk>
    80005a5a:	0001b517          	auipc	a0,0x1b
    80005a5e:	5f650513          	addi	a0,a0,1526 # 80021050 <disk+0x128>
    80005a62:	90afb0ef          	jal	ra,80000b6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005a66:	10001737          	lui	a4,0x10001
    80005a6a:	533c                	lw	a5,96(a4)
    80005a6c:	8b8d                	andi	a5,a5,3
    80005a6e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005a70:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005a74:	689c                	ld	a5,16(s1)
    80005a76:	0204d703          	lhu	a4,32(s1)
    80005a7a:	0027d783          	lhu	a5,2(a5)
    80005a7e:	04f70663          	beq	a4,a5,80005aca <virtio_disk_intr+0x82>
    __sync_synchronize();
    80005a82:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005a86:	6898                	ld	a4,16(s1)
    80005a88:	0204d783          	lhu	a5,32(s1)
    80005a8c:	8b9d                	andi	a5,a5,7
    80005a8e:	078e                	slli	a5,a5,0x3
    80005a90:	97ba                	add	a5,a5,a4
    80005a92:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005a94:	00278713          	addi	a4,a5,2
    80005a98:	0712                	slli	a4,a4,0x4
    80005a9a:	9726                	add	a4,a4,s1
    80005a9c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005aa0:	e321                	bnez	a4,80005ae0 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005aa2:	0789                	addi	a5,a5,2
    80005aa4:	0792                	slli	a5,a5,0x4
    80005aa6:	97a6                	add	a5,a5,s1
    80005aa8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005aaa:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005aae:	c48fc0ef          	jal	ra,80001ef6 <wakeup>

    disk.used_idx += 1;
    80005ab2:	0204d783          	lhu	a5,32(s1)
    80005ab6:	2785                	addiw	a5,a5,1
    80005ab8:	17c2                	slli	a5,a5,0x30
    80005aba:	93c1                	srli	a5,a5,0x30
    80005abc:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005ac0:	6898                	ld	a4,16(s1)
    80005ac2:	00275703          	lhu	a4,2(a4)
    80005ac6:	faf71ee3          	bne	a4,a5,80005a82 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005aca:	0001b517          	auipc	a0,0x1b
    80005ace:	58650513          	addi	a0,a0,1414 # 80021050 <disk+0x128>
    80005ad2:	932fb0ef          	jal	ra,80000c04 <release>
}
    80005ad6:	60e2                	ld	ra,24(sp)
    80005ad8:	6442                	ld	s0,16(sp)
    80005ada:	64a2                	ld	s1,8(sp)
    80005adc:	6105                	addi	sp,sp,32
    80005ade:	8082                	ret
      panic("virtio_disk_intr status");
    80005ae0:	00002517          	auipc	a0,0x2
    80005ae4:	e2850513          	addi	a0,a0,-472 # 80007908 <syscalls+0x518>
    80005ae8:	ca3fa0ef          	jal	ra,8000078a <panic>
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

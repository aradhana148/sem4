
user/_p3b:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"
#include "kernel/vm.h"

int main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("----------------SBRK LAZY:----------------\n");
   8:	00001517          	auipc	a0,0x1
   c:	99850513          	addi	a0,a0,-1640 # 9a0 <malloc+0xe8>
  10:	7ee000ef          	jal	ra,7fe <printf>
    int pasize = getpasize();
  14:	456000ef          	jal	ra,46a <getpasize>
    printf("Physical memory size before: %d bytes\n", pasize);
  18:	0005059b          	sext.w	a1,a0
  1c:	00001517          	auipc	a0,0x1
  20:	9b450513          	addi	a0,a0,-1612 # 9d0 <malloc+0x118>
  24:	7da000ef          	jal	ra,7fe <printf>
    int vasize = getvasize();
  28:	43a000ef          	jal	ra,462 <getvasize>
    printf("Virtual memory size before: %d bytes\n\n", vasize);
  2c:	0005059b          	sext.w	a1,a0
  30:	00001517          	auipc	a0,0x1
  34:	9c850513          	addi	a0,a0,-1592 # 9f8 <malloc+0x140>
  38:	7c6000ef          	jal	ra,7fe <printf>
    printf("Allocating 4096 bytes lazily...\n");
  3c:	00001517          	auipc	a0,0x1
  40:	9e450513          	addi	a0,a0,-1564 # a20 <malloc+0x168>
  44:	7ba000ef          	jal	ra,7fe <printf>
    sys_sbrk(4096, SBRK_LAZY);
  48:	4589                	li	a1,2
  4a:	6505                	lui	a0,0x1
  4c:	3d6000ef          	jal	ra,422 <sys_sbrk>
    pasize = getpasize();
  50:	41a000ef          	jal	ra,46a <getpasize>
    printf("Physical memory size after: %d bytes\n", pasize);
  54:	0005059b          	sext.w	a1,a0
  58:	00001517          	auipc	a0,0x1
  5c:	9f050513          	addi	a0,a0,-1552 # a48 <malloc+0x190>
  60:	79e000ef          	jal	ra,7fe <printf>
    vasize = getvasize();
  64:	3fe000ef          	jal	ra,462 <getvasize>
    printf("Virtual memory size after: %d bytes\n\n", vasize);
  68:	0005059b          	sext.w	a1,a0
  6c:	00001517          	auipc	a0,0x1
  70:	a0450513          	addi	a0,a0,-1532 # a70 <malloc+0x1b8>
  74:	78a000ef          	jal	ra,7fe <printf>

    printf("----------------SBRK EAGER:---------------\n");
  78:	00001517          	auipc	a0,0x1
  7c:	a2050513          	addi	a0,a0,-1504 # a98 <malloc+0x1e0>
  80:	77e000ef          	jal	ra,7fe <printf>
    pasize = getpasize();
  84:	3e6000ef          	jal	ra,46a <getpasize>
    printf("Physical memory size before: %d bytes\n", pasize);
  88:	0005059b          	sext.w	a1,a0
  8c:	00001517          	auipc	a0,0x1
  90:	94450513          	addi	a0,a0,-1724 # 9d0 <malloc+0x118>
  94:	76a000ef          	jal	ra,7fe <printf>
    vasize = getvasize();
  98:	3ca000ef          	jal	ra,462 <getvasize>
    printf("Virtual memory size before: %d bytes\n\n", vasize);
  9c:	0005059b          	sext.w	a1,a0
  a0:	00001517          	auipc	a0,0x1
  a4:	95850513          	addi	a0,a0,-1704 # 9f8 <malloc+0x140>
  a8:	756000ef          	jal	ra,7fe <printf>
    printf("Allocating 4096 bytes eagerly...\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	a1c50513          	addi	a0,a0,-1508 # ac8 <malloc+0x210>
  b4:	74a000ef          	jal	ra,7fe <printf>
    sys_sbrk(4096, SBRK_EAGER);
  b8:	4585                	li	a1,1
  ba:	6505                	lui	a0,0x1
  bc:	366000ef          	jal	ra,422 <sys_sbrk>
    pasize = getpasize();
  c0:	3aa000ef          	jal	ra,46a <getpasize>
    printf("Physical memory size after: %d bytes\n", pasize);
  c4:	0005059b          	sext.w	a1,a0
  c8:	00001517          	auipc	a0,0x1
  cc:	98050513          	addi	a0,a0,-1664 # a48 <malloc+0x190>
  d0:	72e000ef          	jal	ra,7fe <printf>
    vasize = getvasize();
  d4:	38e000ef          	jal	ra,462 <getvasize>
    printf("Virtual memory size after: %d bytes\n\n", vasize);
  d8:	0005059b          	sext.w	a1,a0
  dc:	00001517          	auipc	a0,0x1
  e0:	99450513          	addi	a0,a0,-1644 # a70 <malloc+0x1b8>
  e4:	71a000ef          	jal	ra,7fe <printf>

    exit(0);
  e8:	4501                	li	a0,0
  ea:	2b0000ef          	jal	ra,39a <exit>

00000000000000ee <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e406                	sd	ra,8(sp)
  f2:	e022                	sd	s0,0(sp)
  f4:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  f6:	f0bff0ef          	jal	ra,0 <main>
  exit(r);
  fa:	2a0000ef          	jal	ra,39a <exit>

00000000000000fe <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  fe:	1141                	addi	sp,sp,-16
 100:	e422                	sd	s0,8(sp)
 102:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 104:	87aa                	mv	a5,a0
 106:	0585                	addi	a1,a1,1
 108:	0785                	addi	a5,a5,1
 10a:	fff5c703          	lbu	a4,-1(a1)
 10e:	fee78fa3          	sb	a4,-1(a5)
 112:	fb75                	bnez	a4,106 <strcpy+0x8>
    ;
  return os;
}
 114:	6422                	ld	s0,8(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret

000000000000011a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 120:	00054783          	lbu	a5,0(a0)
 124:	cb91                	beqz	a5,138 <strcmp+0x1e>
 126:	0005c703          	lbu	a4,0(a1)
 12a:	00f71763          	bne	a4,a5,138 <strcmp+0x1e>
    p++, q++;
 12e:	0505                	addi	a0,a0,1
 130:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 132:	00054783          	lbu	a5,0(a0)
 136:	fbe5                	bnez	a5,126 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 138:	0005c503          	lbu	a0,0(a1)
}
 13c:	40a7853b          	subw	a0,a5,a0
 140:	6422                	ld	s0,8(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret

0000000000000146 <strlen>:

uint
strlen(const char *s)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 14c:	00054783          	lbu	a5,0(a0)
 150:	cf91                	beqz	a5,16c <strlen+0x26>
 152:	0505                	addi	a0,a0,1
 154:	87aa                	mv	a5,a0
 156:	4685                	li	a3,1
 158:	9e89                	subw	a3,a3,a0
 15a:	00f6853b          	addw	a0,a3,a5
 15e:	0785                	addi	a5,a5,1
 160:	fff7c703          	lbu	a4,-1(a5)
 164:	fb7d                	bnez	a4,15a <strlen+0x14>
    ;
  return n;
}
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret
  for(n = 0; s[n]; n++)
 16c:	4501                	li	a0,0
 16e:	bfe5                	j	166 <strlen+0x20>

0000000000000170 <memset>:

void*
memset(void *dst, int c, uint n)
{
 170:	1141                	addi	sp,sp,-16
 172:	e422                	sd	s0,8(sp)
 174:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 176:	ca19                	beqz	a2,18c <memset+0x1c>
 178:	87aa                	mv	a5,a0
 17a:	1602                	slli	a2,a2,0x20
 17c:	9201                	srli	a2,a2,0x20
 17e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 182:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 186:	0785                	addi	a5,a5,1
 188:	fee79de3          	bne	a5,a4,182 <memset+0x12>
  }
  return dst;
}
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret

0000000000000192 <strchr>:

char*
strchr(const char *s, char c)
{
 192:	1141                	addi	sp,sp,-16
 194:	e422                	sd	s0,8(sp)
 196:	0800                	addi	s0,sp,16
  for(; *s; s++)
 198:	00054783          	lbu	a5,0(a0)
 19c:	cb99                	beqz	a5,1b2 <strchr+0x20>
    if(*s == c)
 19e:	00f58763          	beq	a1,a5,1ac <strchr+0x1a>
  for(; *s; s++)
 1a2:	0505                	addi	a0,a0,1
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	fbfd                	bnez	a5,19e <strchr+0xc>
      return (char*)s;
  return 0;
 1aa:	4501                	li	a0,0
}
 1ac:	6422                	ld	s0,8(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret
  return 0;
 1b2:	4501                	li	a0,0
 1b4:	bfe5                	j	1ac <strchr+0x1a>

00000000000001b6 <gets>:

char*
gets(char *buf, int max)
{
 1b6:	711d                	addi	sp,sp,-96
 1b8:	ec86                	sd	ra,88(sp)
 1ba:	e8a2                	sd	s0,80(sp)
 1bc:	e4a6                	sd	s1,72(sp)
 1be:	e0ca                	sd	s2,64(sp)
 1c0:	fc4e                	sd	s3,56(sp)
 1c2:	f852                	sd	s4,48(sp)
 1c4:	f456                	sd	s5,40(sp)
 1c6:	f05a                	sd	s6,32(sp)
 1c8:	ec5e                	sd	s7,24(sp)
 1ca:	1080                	addi	s0,sp,96
 1cc:	8baa                	mv	s7,a0
 1ce:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d0:	892a                	mv	s2,a0
 1d2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d4:	4aa9                	li	s5,10
 1d6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d8:	89a6                	mv	s3,s1
 1da:	2485                	addiw	s1,s1,1
 1dc:	0344d663          	bge	s1,s4,208 <gets+0x52>
    cc = read(0, &c, 1);
 1e0:	4605                	li	a2,1
 1e2:	faf40593          	addi	a1,s0,-81
 1e6:	4501                	li	a0,0
 1e8:	1ca000ef          	jal	ra,3b2 <read>
    if(cc < 1)
 1ec:	00a05e63          	blez	a0,208 <gets+0x52>
    buf[i++] = c;
 1f0:	faf44783          	lbu	a5,-81(s0)
 1f4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f8:	01578763          	beq	a5,s5,206 <gets+0x50>
 1fc:	0905                	addi	s2,s2,1
 1fe:	fd679de3          	bne	a5,s6,1d8 <gets+0x22>
  for(i=0; i+1 < max; ){
 202:	89a6                	mv	s3,s1
 204:	a011                	j	208 <gets+0x52>
 206:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 208:	99de                	add	s3,s3,s7
 20a:	00098023          	sb	zero,0(s3)
  return buf;
}
 20e:	855e                	mv	a0,s7
 210:	60e6                	ld	ra,88(sp)
 212:	6446                	ld	s0,80(sp)
 214:	64a6                	ld	s1,72(sp)
 216:	6906                	ld	s2,64(sp)
 218:	79e2                	ld	s3,56(sp)
 21a:	7a42                	ld	s4,48(sp)
 21c:	7aa2                	ld	s5,40(sp)
 21e:	7b02                	ld	s6,32(sp)
 220:	6be2                	ld	s7,24(sp)
 222:	6125                	addi	sp,sp,96
 224:	8082                	ret

0000000000000226 <stat>:

int
stat(const char *n, struct stat *st)
{
 226:	1101                	addi	sp,sp,-32
 228:	ec06                	sd	ra,24(sp)
 22a:	e822                	sd	s0,16(sp)
 22c:	e426                	sd	s1,8(sp)
 22e:	e04a                	sd	s2,0(sp)
 230:	1000                	addi	s0,sp,32
 232:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 234:	4581                	li	a1,0
 236:	1a4000ef          	jal	ra,3da <open>
  if(fd < 0)
 23a:	02054163          	bltz	a0,25c <stat+0x36>
 23e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 240:	85ca                	mv	a1,s2
 242:	1b0000ef          	jal	ra,3f2 <fstat>
 246:	892a                	mv	s2,a0
  close(fd);
 248:	8526                	mv	a0,s1
 24a:	178000ef          	jal	ra,3c2 <close>
  return r;
}
 24e:	854a                	mv	a0,s2
 250:	60e2                	ld	ra,24(sp)
 252:	6442                	ld	s0,16(sp)
 254:	64a2                	ld	s1,8(sp)
 256:	6902                	ld	s2,0(sp)
 258:	6105                	addi	sp,sp,32
 25a:	8082                	ret
    return -1;
 25c:	597d                	li	s2,-1
 25e:	bfc5                	j	24e <stat+0x28>

0000000000000260 <atoi>:

int
atoi(const char *s)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 266:	00054603          	lbu	a2,0(a0)
 26a:	fd06079b          	addiw	a5,a2,-48
 26e:	0ff7f793          	andi	a5,a5,255
 272:	4725                	li	a4,9
 274:	02f76963          	bltu	a4,a5,2a6 <atoi+0x46>
 278:	86aa                	mv	a3,a0
  n = 0;
 27a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 27c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 27e:	0685                	addi	a3,a3,1
 280:	0025179b          	slliw	a5,a0,0x2
 284:	9fa9                	addw	a5,a5,a0
 286:	0017979b          	slliw	a5,a5,0x1
 28a:	9fb1                	addw	a5,a5,a2
 28c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 290:	0006c603          	lbu	a2,0(a3)
 294:	fd06071b          	addiw	a4,a2,-48
 298:	0ff77713          	andi	a4,a4,255
 29c:	fee5f1e3          	bgeu	a1,a4,27e <atoi+0x1e>
  return n;
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret
  n = 0;
 2a6:	4501                	li	a0,0
 2a8:	bfe5                	j	2a0 <atoi+0x40>

00000000000002aa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b0:	02b57463          	bgeu	a0,a1,2d8 <memmove+0x2e>
    while(n-- > 0)
 2b4:	00c05f63          	blez	a2,2d2 <memmove+0x28>
 2b8:	1602                	slli	a2,a2,0x20
 2ba:	9201                	srli	a2,a2,0x20
 2bc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c2:	0585                	addi	a1,a1,1
 2c4:	0705                	addi	a4,a4,1
 2c6:	fff5c683          	lbu	a3,-1(a1)
 2ca:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ce:	fee79ae3          	bne	a5,a4,2c2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
    dst += n;
 2d8:	00c50733          	add	a4,a0,a2
    src += n;
 2dc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2de:	fec05ae3          	blez	a2,2d2 <memmove+0x28>
 2e2:	fff6079b          	addiw	a5,a2,-1
 2e6:	1782                	slli	a5,a5,0x20
 2e8:	9381                	srli	a5,a5,0x20
 2ea:	fff7c793          	not	a5,a5
 2ee:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f0:	15fd                	addi	a1,a1,-1
 2f2:	177d                	addi	a4,a4,-1
 2f4:	0005c683          	lbu	a3,0(a1)
 2f8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2fc:	fee79ae3          	bne	a5,a4,2f0 <memmove+0x46>
 300:	bfc9                	j	2d2 <memmove+0x28>

0000000000000302 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 302:	1141                	addi	sp,sp,-16
 304:	e422                	sd	s0,8(sp)
 306:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 308:	ca05                	beqz	a2,338 <memcmp+0x36>
 30a:	fff6069b          	addiw	a3,a2,-1
 30e:	1682                	slli	a3,a3,0x20
 310:	9281                	srli	a3,a3,0x20
 312:	0685                	addi	a3,a3,1
 314:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 316:	00054783          	lbu	a5,0(a0)
 31a:	0005c703          	lbu	a4,0(a1)
 31e:	00e79863          	bne	a5,a4,32e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 322:	0505                	addi	a0,a0,1
    p2++;
 324:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 326:	fed518e3          	bne	a0,a3,316 <memcmp+0x14>
  }
  return 0;
 32a:	4501                	li	a0,0
 32c:	a019                	j	332 <memcmp+0x30>
      return *p1 - *p2;
 32e:	40e7853b          	subw	a0,a5,a4
}
 332:	6422                	ld	s0,8(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret
  return 0;
 338:	4501                	li	a0,0
 33a:	bfe5                	j	332 <memcmp+0x30>

000000000000033c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 33c:	1141                	addi	sp,sp,-16
 33e:	e406                	sd	ra,8(sp)
 340:	e022                	sd	s0,0(sp)
 342:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 344:	f67ff0ef          	jal	ra,2aa <memmove>
}
 348:	60a2                	ld	ra,8(sp)
 34a:	6402                	ld	s0,0(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret

0000000000000350 <sbrk>:

char *
sbrk(int n) {
 350:	1141                	addi	sp,sp,-16
 352:	e406                	sd	ra,8(sp)
 354:	e022                	sd	s0,0(sp)
 356:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 358:	4585                	li	a1,1
 35a:	0c8000ef          	jal	ra,422 <sys_sbrk>
}
 35e:	60a2                	ld	ra,8(sp)
 360:	6402                	ld	s0,0(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret

0000000000000366 <sbrklazy>:

char *
sbrklazy(int n) {
 366:	1141                	addi	sp,sp,-16
 368:	e406                	sd	ra,8(sp)
 36a:	e022                	sd	s0,0(sp)
 36c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 36e:	4589                	li	a1,2
 370:	0b2000ef          	jal	ra,422 <sys_sbrk>
}
 374:	60a2                	ld	ra,8(sp)
 376:	6402                	ld	s0,0(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret

000000000000037c <ugetpid>:

int
ugetpid(void)
{
 37c:	1141                	addi	sp,sp,-16
 37e:	e422                	sd	s0,8(sp)
 380:	0800                	addi	s0,sp,16
  return (*(int*)UGET);
 382:	040007b7          	lui	a5,0x4000
 386:	17f5                	addi	a5,a5,-3
 388:	07b2                	slli	a5,a5,0xc
 38a:	4388                	lw	a0,0(a5)
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret

0000000000000392 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 392:	4885                	li	a7,1
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <exit>:
.global exit
exit:
 li a7, SYS_exit
 39a:	4889                	li	a7,2
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a2:	488d                	li	a7,3
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3aa:	4891                	li	a7,4
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <read>:
.global read
read:
 li a7, SYS_read
 3b2:	4895                	li	a7,5
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <write>:
.global write
write:
 li a7, SYS_write
 3ba:	48c1                	li	a7,16
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <close>:
.global close
close:
 li a7, SYS_close
 3c2:	48d5                	li	a7,21
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ca:	4899                	li	a7,6
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d2:	489d                	li	a7,7
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <open>:
.global open
open:
 li a7, SYS_open
 3da:	48bd                	li	a7,15
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e2:	48c5                	li	a7,17
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ea:	48c9                	li	a7,18
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f2:	48a1                	li	a7,8
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <link>:
.global link
link:
 li a7, SYS_link
 3fa:	48cd                	li	a7,19
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 402:	48d1                	li	a7,20
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 40a:	48a5                	li	a7,9
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <dup>:
.global dup
dup:
 li a7, SYS_dup
 412:	48a9                	li	a7,10
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 41a:	48ad                	li	a7,11
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 422:	48b1                	li	a7,12
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <pause>:
.global pause
pause:
 li a7, SYS_pause
 42a:	48b5                	li	a7,13
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 432:	48b9                	li	a7,14
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <pte_valid>:
.global pte_valid
pte_valid:
 li a7, SYS_pte_valid
 43a:	48d9                	li	a7,22
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <get_pteflags>:
.global get_pteflags
get_pteflags:
 li a7, SYS_get_pteflags
 442:	48dd                	li	a7,23
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <print_pgdirs>:
.global print_pgdirs
print_pgdirs:
 li a7, SYS_print_pgdirs
 44a:	48e1                	li	a7,24
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <va_to_pte>:
.global va_to_pte
va_to_pte:
 li a7, SYS_va_to_pte
 452:	48e5                	li	a7,25
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <va_to_pa>:
.global va_to_pa
va_to_pa:
 li a7, SYS_va_to_pa
 45a:	48e9                	li	a7,26
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <getvasize>:
.global getvasize
getvasize:
 li a7, SYS_getvasize
 462:	48ed                	li	a7,27
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <getpasize>:
.global getpasize
getpasize:
 li a7, SYS_getpasize
 46a:	48f1                	li	a7,28
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <getlazyfaults>:
.global getlazyfaults
getlazyfaults:
 li a7, SYS_getlazyfaults
 472:	48f5                	li	a7,29
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <kva_to_pa>:
.global kva_to_pa
kva_to_pa:
 li a7, SYS_kva_to_pa
 47a:	48f9                	li	a7,30
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 482:	1101                	addi	sp,sp,-32
 484:	ec06                	sd	ra,24(sp)
 486:	e822                	sd	s0,16(sp)
 488:	1000                	addi	s0,sp,32
 48a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48e:	4605                	li	a2,1
 490:	fef40593          	addi	a1,s0,-17
 494:	f27ff0ef          	jal	ra,3ba <write>
}
 498:	60e2                	ld	ra,24(sp)
 49a:	6442                	ld	s0,16(sp)
 49c:	6105                	addi	sp,sp,32
 49e:	8082                	ret

00000000000004a0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4a0:	715d                	addi	sp,sp,-80
 4a2:	e486                	sd	ra,72(sp)
 4a4:	e0a2                	sd	s0,64(sp)
 4a6:	fc26                	sd	s1,56(sp)
 4a8:	f84a                	sd	s2,48(sp)
 4aa:	f44e                	sd	s3,40(sp)
 4ac:	0880                	addi	s0,sp,80
 4ae:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4b0:	c299                	beqz	a3,4b6 <printint+0x16>
 4b2:	0805c163          	bltz	a1,534 <printint+0x94>
  neg = 0;
 4b6:	4881                	li	a7,0
 4b8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4bc:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4be:	00000517          	auipc	a0,0x0
 4c2:	63a50513          	addi	a0,a0,1594 # af8 <digits>
 4c6:	883e                	mv	a6,a5
 4c8:	2785                	addiw	a5,a5,1
 4ca:	02c5f733          	remu	a4,a1,a2
 4ce:	972a                	add	a4,a4,a0
 4d0:	00074703          	lbu	a4,0(a4)
 4d4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4d8:	872e                	mv	a4,a1
 4da:	02c5d5b3          	divu	a1,a1,a2
 4de:	0685                	addi	a3,a3,1
 4e0:	fec773e3          	bgeu	a4,a2,4c6 <printint+0x26>
  if(neg)
 4e4:	00088b63          	beqz	a7,4fa <printint+0x5a>
    buf[i++] = '-';
 4e8:	fd040713          	addi	a4,s0,-48
 4ec:	97ba                	add	a5,a5,a4
 4ee:	02d00713          	li	a4,45
 4f2:	fee78423          	sb	a4,-24(a5) # 3ffffe8 <base+0x3ffefd8>
 4f6:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4fa:	02f05663          	blez	a5,526 <printint+0x86>
 4fe:	fb840713          	addi	a4,s0,-72
 502:	00f704b3          	add	s1,a4,a5
 506:	fff70993          	addi	s3,a4,-1
 50a:	99be                	add	s3,s3,a5
 50c:	37fd                	addiw	a5,a5,-1
 50e:	1782                	slli	a5,a5,0x20
 510:	9381                	srli	a5,a5,0x20
 512:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 516:	fff4c583          	lbu	a1,-1(s1)
 51a:	854a                	mv	a0,s2
 51c:	f67ff0ef          	jal	ra,482 <putc>
  while(--i >= 0)
 520:	14fd                	addi	s1,s1,-1
 522:	ff349ae3          	bne	s1,s3,516 <printint+0x76>
}
 526:	60a6                	ld	ra,72(sp)
 528:	6406                	ld	s0,64(sp)
 52a:	74e2                	ld	s1,56(sp)
 52c:	7942                	ld	s2,48(sp)
 52e:	79a2                	ld	s3,40(sp)
 530:	6161                	addi	sp,sp,80
 532:	8082                	ret
    x = -xx;
 534:	40b005b3          	neg	a1,a1
    neg = 1;
 538:	4885                	li	a7,1
    x = -xx;
 53a:	bfbd                	j	4b8 <printint+0x18>

000000000000053c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 53c:	7119                	addi	sp,sp,-128
 53e:	fc86                	sd	ra,120(sp)
 540:	f8a2                	sd	s0,112(sp)
 542:	f4a6                	sd	s1,104(sp)
 544:	f0ca                	sd	s2,96(sp)
 546:	ecce                	sd	s3,88(sp)
 548:	e8d2                	sd	s4,80(sp)
 54a:	e4d6                	sd	s5,72(sp)
 54c:	e0da                	sd	s6,64(sp)
 54e:	fc5e                	sd	s7,56(sp)
 550:	f862                	sd	s8,48(sp)
 552:	f466                	sd	s9,40(sp)
 554:	f06a                	sd	s10,32(sp)
 556:	ec6e                	sd	s11,24(sp)
 558:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 55a:	0005c903          	lbu	s2,0(a1)
 55e:	24090c63          	beqz	s2,7b6 <vprintf+0x27a>
 562:	8b2a                	mv	s6,a0
 564:	8a2e                	mv	s4,a1
 566:	8bb2                	mv	s7,a2
  state = 0;
 568:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 56a:	4481                	li	s1,0
 56c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 56e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 572:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 576:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 57a:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 57e:	00000c97          	auipc	s9,0x0
 582:	57ac8c93          	addi	s9,s9,1402 # af8 <digits>
 586:	a005                	j	5a6 <vprintf+0x6a>
        putc(fd, c0);
 588:	85ca                	mv	a1,s2
 58a:	855a                	mv	a0,s6
 58c:	ef7ff0ef          	jal	ra,482 <putc>
 590:	a019                	j	596 <vprintf+0x5a>
    } else if(state == '%'){
 592:	03598263          	beq	s3,s5,5b6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 596:	2485                	addiw	s1,s1,1
 598:	8726                	mv	a4,s1
 59a:	009a07b3          	add	a5,s4,s1
 59e:	0007c903          	lbu	s2,0(a5)
 5a2:	20090a63          	beqz	s2,7b6 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5a6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5aa:	fe0994e3          	bnez	s3,592 <vprintf+0x56>
      if(c0 == '%'){
 5ae:	fd579de3          	bne	a5,s5,588 <vprintf+0x4c>
        state = '%';
 5b2:	89be                	mv	s3,a5
 5b4:	b7cd                	j	596 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5b6:	c3c1                	beqz	a5,636 <vprintf+0xfa>
 5b8:	00ea06b3          	add	a3,s4,a4
 5bc:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5c0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5c2:	c681                	beqz	a3,5ca <vprintf+0x8e>
 5c4:	9752                	add	a4,a4,s4
 5c6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5ca:	03878e63          	beq	a5,s8,606 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5ce:	05a78863          	beq	a5,s10,61e <vprintf+0xe2>
      } else if(c0 == 'u'){
 5d2:	0db78b63          	beq	a5,s11,6a8 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5d6:	07800713          	li	a4,120
 5da:	10e78d63          	beq	a5,a4,6f4 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5de:	07000713          	li	a4,112
 5e2:	14e78263          	beq	a5,a4,726 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5e6:	06300713          	li	a4,99
 5ea:	16e78f63          	beq	a5,a4,768 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5ee:	07300713          	li	a4,115
 5f2:	18e78563          	beq	a5,a4,77c <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5f6:	05579063          	bne	a5,s5,636 <vprintf+0xfa>
        putc(fd, '%');
 5fa:	85d6                	mv	a1,s5
 5fc:	855a                	mv	a0,s6
 5fe:	e85ff0ef          	jal	ra,482 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 602:	4981                	li	s3,0
 604:	bf49                	j	596 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 606:	008b8913          	addi	s2,s7,8
 60a:	4685                	li	a3,1
 60c:	4629                	li	a2,10
 60e:	000ba583          	lw	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	e8dff0ef          	jal	ra,4a0 <printint>
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bfad                	j	596 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 61e:	03868663          	beq	a3,s8,64a <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 622:	05a68163          	beq	a3,s10,664 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 626:	09b68d63          	beq	a3,s11,6c0 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 62a:	03a68f63          	beq	a3,s10,668 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 62e:	07800793          	li	a5,120
 632:	0cf68d63          	beq	a3,a5,70c <vprintf+0x1d0>
        putc(fd, '%');
 636:	85d6                	mv	a1,s5
 638:	855a                	mv	a0,s6
 63a:	e49ff0ef          	jal	ra,482 <putc>
        putc(fd, c0);
 63e:	85ca                	mv	a1,s2
 640:	855a                	mv	a0,s6
 642:	e41ff0ef          	jal	ra,482 <putc>
      state = 0;
 646:	4981                	li	s3,0
 648:	b7b9                	j	596 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 64a:	008b8913          	addi	s2,s7,8
 64e:	4685                	li	a3,1
 650:	4629                	li	a2,10
 652:	000bb583          	ld	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	e49ff0ef          	jal	ra,4a0 <printint>
        i += 1;
 65c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
        i += 1;
 662:	bf15                	j	596 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 664:	03860563          	beq	a2,s8,68e <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 668:	07b60963          	beq	a2,s11,6da <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 66c:	07800793          	li	a5,120
 670:	fcf613e3          	bne	a2,a5,636 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 674:	008b8913          	addi	s2,s7,8
 678:	4681                	li	a3,0
 67a:	4641                	li	a2,16
 67c:	000bb583          	ld	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	e1fff0ef          	jal	ra,4a0 <printint>
        i += 2;
 686:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 688:	8bca                	mv	s7,s2
      state = 0;
 68a:	4981                	li	s3,0
        i += 2;
 68c:	b729                	j	596 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 68e:	008b8913          	addi	s2,s7,8
 692:	4685                	li	a3,1
 694:	4629                	li	a2,10
 696:	000bb583          	ld	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	e05ff0ef          	jal	ra,4a0 <printint>
        i += 2;
 6a0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a2:	8bca                	mv	s7,s2
      state = 0;
 6a4:	4981                	li	s3,0
        i += 2;
 6a6:	bdc5                	j	596 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	4681                	li	a3,0
 6ae:	4629                	li	a2,10
 6b0:	000be583          	lwu	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	debff0ef          	jal	ra,4a0 <printint>
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bde1                	j	596 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4629                	li	a2,10
 6c8:	000bb583          	ld	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	dd3ff0ef          	jal	ra,4a0 <printint>
        i += 1;
 6d2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
        i += 1;
 6d8:	bd7d                	j	596 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4681                	li	a3,0
 6e0:	4629                	li	a2,10
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	db9ff0ef          	jal	ra,4a0 <printint>
        i += 2;
 6ec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
        i += 2;
 6f2:	b555                	j	596 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	4681                	li	a3,0
 6fa:	4641                	li	a2,16
 6fc:	000be583          	lwu	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	d9fff0ef          	jal	ra,4a0 <printint>
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	b571                	j	596 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 70c:	008b8913          	addi	s2,s7,8
 710:	4681                	li	a3,0
 712:	4641                	li	a2,16
 714:	000bb583          	ld	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	d87ff0ef          	jal	ra,4a0 <printint>
        i += 1;
 71e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
        i += 1;
 724:	bd8d                	j	596 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 726:	008b8793          	addi	a5,s7,8
 72a:	f8f43423          	sd	a5,-120(s0)
 72e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 732:	03000593          	li	a1,48
 736:	855a                	mv	a0,s6
 738:	d4bff0ef          	jal	ra,482 <putc>
  putc(fd, 'x');
 73c:	07800593          	li	a1,120
 740:	855a                	mv	a0,s6
 742:	d41ff0ef          	jal	ra,482 <putc>
 746:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 748:	03c9d793          	srli	a5,s3,0x3c
 74c:	97e6                	add	a5,a5,s9
 74e:	0007c583          	lbu	a1,0(a5)
 752:	855a                	mv	a0,s6
 754:	d2fff0ef          	jal	ra,482 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 758:	0992                	slli	s3,s3,0x4
 75a:	397d                	addiw	s2,s2,-1
 75c:	fe0916e3          	bnez	s2,748 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 760:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 764:	4981                	li	s3,0
 766:	bd05                	j	596 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 768:	008b8913          	addi	s2,s7,8
 76c:	000bc583          	lbu	a1,0(s7)
 770:	855a                	mv	a0,s6
 772:	d11ff0ef          	jal	ra,482 <putc>
 776:	8bca                	mv	s7,s2
      state = 0;
 778:	4981                	li	s3,0
 77a:	bd31                	j	596 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 77c:	008b8993          	addi	s3,s7,8
 780:	000bb903          	ld	s2,0(s7)
 784:	00090f63          	beqz	s2,7a2 <vprintf+0x266>
        for(; *s; s++)
 788:	00094583          	lbu	a1,0(s2)
 78c:	c195                	beqz	a1,7b0 <vprintf+0x274>
          putc(fd, *s);
 78e:	855a                	mv	a0,s6
 790:	cf3ff0ef          	jal	ra,482 <putc>
        for(; *s; s++)
 794:	0905                	addi	s2,s2,1
 796:	00094583          	lbu	a1,0(s2)
 79a:	f9f5                	bnez	a1,78e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 79c:	8bce                	mv	s7,s3
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	bbdd                	j	596 <vprintf+0x5a>
          s = "(null)";
 7a2:	00000917          	auipc	s2,0x0
 7a6:	34e90913          	addi	s2,s2,846 # af0 <malloc+0x238>
        for(; *s; s++)
 7aa:	02800593          	li	a1,40
 7ae:	b7c5                	j	78e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7b0:	8bce                	mv	s7,s3
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	b3cd                	j	596 <vprintf+0x5a>
    }
  }
}
 7b6:	70e6                	ld	ra,120(sp)
 7b8:	7446                	ld	s0,112(sp)
 7ba:	74a6                	ld	s1,104(sp)
 7bc:	7906                	ld	s2,96(sp)
 7be:	69e6                	ld	s3,88(sp)
 7c0:	6a46                	ld	s4,80(sp)
 7c2:	6aa6                	ld	s5,72(sp)
 7c4:	6b06                	ld	s6,64(sp)
 7c6:	7be2                	ld	s7,56(sp)
 7c8:	7c42                	ld	s8,48(sp)
 7ca:	7ca2                	ld	s9,40(sp)
 7cc:	7d02                	ld	s10,32(sp)
 7ce:	6de2                	ld	s11,24(sp)
 7d0:	6109                	addi	sp,sp,128
 7d2:	8082                	ret

00000000000007d4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d4:	715d                	addi	sp,sp,-80
 7d6:	ec06                	sd	ra,24(sp)
 7d8:	e822                	sd	s0,16(sp)
 7da:	1000                	addi	s0,sp,32
 7dc:	e010                	sd	a2,0(s0)
 7de:	e414                	sd	a3,8(s0)
 7e0:	e818                	sd	a4,16(s0)
 7e2:	ec1c                	sd	a5,24(s0)
 7e4:	03043023          	sd	a6,32(s0)
 7e8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f0:	8622                	mv	a2,s0
 7f2:	d4bff0ef          	jal	ra,53c <vprintf>
}
 7f6:	60e2                	ld	ra,24(sp)
 7f8:	6442                	ld	s0,16(sp)
 7fa:	6161                	addi	sp,sp,80
 7fc:	8082                	ret

00000000000007fe <printf>:

void
printf(const char *fmt, ...)
{
 7fe:	711d                	addi	sp,sp,-96
 800:	ec06                	sd	ra,24(sp)
 802:	e822                	sd	s0,16(sp)
 804:	1000                	addi	s0,sp,32
 806:	e40c                	sd	a1,8(s0)
 808:	e810                	sd	a2,16(s0)
 80a:	ec14                	sd	a3,24(s0)
 80c:	f018                	sd	a4,32(s0)
 80e:	f41c                	sd	a5,40(s0)
 810:	03043823          	sd	a6,48(s0)
 814:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 818:	00840613          	addi	a2,s0,8
 81c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 820:	85aa                	mv	a1,a0
 822:	4505                	li	a0,1
 824:	d19ff0ef          	jal	ra,53c <vprintf>
}
 828:	60e2                	ld	ra,24(sp)
 82a:	6442                	ld	s0,16(sp)
 82c:	6125                	addi	sp,sp,96
 82e:	8082                	ret

0000000000000830 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 830:	1141                	addi	sp,sp,-16
 832:	e422                	sd	s0,8(sp)
 834:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 836:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83a:	00000797          	auipc	a5,0x0
 83e:	7c67b783          	ld	a5,1990(a5) # 1000 <freep>
 842:	a805                	j	872 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 844:	4618                	lw	a4,8(a2)
 846:	9db9                	addw	a1,a1,a4
 848:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 84c:	6398                	ld	a4,0(a5)
 84e:	6318                	ld	a4,0(a4)
 850:	fee53823          	sd	a4,-16(a0)
 854:	a091                	j	898 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 856:	ff852703          	lw	a4,-8(a0)
 85a:	9e39                	addw	a2,a2,a4
 85c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 85e:	ff053703          	ld	a4,-16(a0)
 862:	e398                	sd	a4,0(a5)
 864:	a099                	j	8aa <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 866:	6398                	ld	a4,0(a5)
 868:	00e7e463          	bltu	a5,a4,870 <free+0x40>
 86c:	00e6ea63          	bltu	a3,a4,880 <free+0x50>
{
 870:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 872:	fed7fae3          	bgeu	a5,a3,866 <free+0x36>
 876:	6398                	ld	a4,0(a5)
 878:	00e6e463          	bltu	a3,a4,880 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87c:	fee7eae3          	bltu	a5,a4,870 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 880:	ff852583          	lw	a1,-8(a0)
 884:	6390                	ld	a2,0(a5)
 886:	02059713          	slli	a4,a1,0x20
 88a:	9301                	srli	a4,a4,0x20
 88c:	0712                	slli	a4,a4,0x4
 88e:	9736                	add	a4,a4,a3
 890:	fae60ae3          	beq	a2,a4,844 <free+0x14>
    bp->s.ptr = p->s.ptr;
 894:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 898:	4790                	lw	a2,8(a5)
 89a:	02061713          	slli	a4,a2,0x20
 89e:	9301                	srli	a4,a4,0x20
 8a0:	0712                	slli	a4,a4,0x4
 8a2:	973e                	add	a4,a4,a5
 8a4:	fae689e3          	beq	a3,a4,856 <free+0x26>
  } else
    p->s.ptr = bp;
 8a8:	e394                	sd	a3,0(a5)
  freep = p;
 8aa:	00000717          	auipc	a4,0x0
 8ae:	74f73b23          	sd	a5,1878(a4) # 1000 <freep>
}
 8b2:	6422                	ld	s0,8(sp)
 8b4:	0141                	addi	sp,sp,16
 8b6:	8082                	ret

00000000000008b8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b8:	7139                	addi	sp,sp,-64
 8ba:	fc06                	sd	ra,56(sp)
 8bc:	f822                	sd	s0,48(sp)
 8be:	f426                	sd	s1,40(sp)
 8c0:	f04a                	sd	s2,32(sp)
 8c2:	ec4e                	sd	s3,24(sp)
 8c4:	e852                	sd	s4,16(sp)
 8c6:	e456                	sd	s5,8(sp)
 8c8:	e05a                	sd	s6,0(sp)
 8ca:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8cc:	02051493          	slli	s1,a0,0x20
 8d0:	9081                	srli	s1,s1,0x20
 8d2:	04bd                	addi	s1,s1,15
 8d4:	8091                	srli	s1,s1,0x4
 8d6:	0014899b          	addiw	s3,s1,1
 8da:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8dc:	00000517          	auipc	a0,0x0
 8e0:	72453503          	ld	a0,1828(a0) # 1000 <freep>
 8e4:	c515                	beqz	a0,910 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e8:	4798                	lw	a4,8(a5)
 8ea:	02977f63          	bgeu	a4,s1,928 <malloc+0x70>
 8ee:	8a4e                	mv	s4,s3
 8f0:	0009871b          	sext.w	a4,s3
 8f4:	6685                	lui	a3,0x1
 8f6:	00d77363          	bgeu	a4,a3,8fc <malloc+0x44>
 8fa:	6a05                	lui	s4,0x1
 8fc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 900:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 904:	00000917          	auipc	s2,0x0
 908:	6fc90913          	addi	s2,s2,1788 # 1000 <freep>
  if(p == SBRK_ERROR)
 90c:	5afd                	li	s5,-1
 90e:	a0bd                	j	97c <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 910:	00000797          	auipc	a5,0x0
 914:	70078793          	addi	a5,a5,1792 # 1010 <base>
 918:	00000717          	auipc	a4,0x0
 91c:	6ef73423          	sd	a5,1768(a4) # 1000 <freep>
 920:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 922:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 926:	b7e1                	j	8ee <malloc+0x36>
      if(p->s.size == nunits)
 928:	02e48b63          	beq	s1,a4,95e <malloc+0xa6>
        p->s.size -= nunits;
 92c:	4137073b          	subw	a4,a4,s3
 930:	c798                	sw	a4,8(a5)
        p += p->s.size;
 932:	1702                	slli	a4,a4,0x20
 934:	9301                	srli	a4,a4,0x20
 936:	0712                	slli	a4,a4,0x4
 938:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 93a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 93e:	00000717          	auipc	a4,0x0
 942:	6ca73123          	sd	a0,1730(a4) # 1000 <freep>
      return (void*)(p + 1);
 946:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 94a:	70e2                	ld	ra,56(sp)
 94c:	7442                	ld	s0,48(sp)
 94e:	74a2                	ld	s1,40(sp)
 950:	7902                	ld	s2,32(sp)
 952:	69e2                	ld	s3,24(sp)
 954:	6a42                	ld	s4,16(sp)
 956:	6aa2                	ld	s5,8(sp)
 958:	6b02                	ld	s6,0(sp)
 95a:	6121                	addi	sp,sp,64
 95c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 95e:	6398                	ld	a4,0(a5)
 960:	e118                	sd	a4,0(a0)
 962:	bff1                	j	93e <malloc+0x86>
  hp->s.size = nu;
 964:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 968:	0541                	addi	a0,a0,16
 96a:	ec7ff0ef          	jal	ra,830 <free>
  return freep;
 96e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 972:	dd61                	beqz	a0,94a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 974:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 976:	4798                	lw	a4,8(a5)
 978:	fa9778e3          	bgeu	a4,s1,928 <malloc+0x70>
    if(p == freep)
 97c:	00093703          	ld	a4,0(s2)
 980:	853e                	mv	a0,a5
 982:	fef719e3          	bne	a4,a5,974 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 986:	8552                	mv	a0,s4
 988:	9c9ff0ef          	jal	ra,350 <sbrk>
  if(p == SBRK_ERROR)
 98c:	fd551ce3          	bne	a0,s5,964 <malloc+0xac>
        return 0;
 990:	4501                	li	a0,0
 992:	bf65                	j	94a <malloc+0x92>


user/_p3c:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/vm.h"

#define PGSIZE 4096

int main(int argc, char *argv[]) 
{
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	f852                	sd	s4,48(sp)
   e:	f456                	sd	s5,40(sp)
  10:	f05a                	sd	s6,32(sp)
  12:	ec5e                	sd	s7,24(sp)
  14:	e862                	sd	s8,16(sp)
  16:	e466                	sd	s9,8(sp)
  18:	1080                	addi	s0,sp,96
    printf("Page faults Before sbrk: %d\n", getlazyfaults());
  1a:	448000ef          	jal	ra,462 <getlazyfaults>
  1e:	85aa                	mv	a1,a0
  20:	00001517          	auipc	a0,0x1
  24:	97050513          	addi	a0,a0,-1680 # 990 <malloc+0xe8>
  28:	7c6000ef          	jal	ra,7ee <printf>
    uint64 va_size = getvasize();
  2c:	426000ef          	jal	ra,452 <getvasize>
  30:	85aa                	mv	a1,a0
    printf("Virtual address space size before sbrk lazy: %ld bytes\n\n", va_size);
  32:	00001517          	auipc	a0,0x1
  36:	97e50513          	addi	a0,a0,-1666 # 9b0 <malloc+0x108>
  3a:	7b4000ef          	jal	ra,7ee <printf>

    char *p = sys_sbrk(PGSIZE * 5 , SBRK_LAZY);
  3e:	4589                	li	a1,2
  40:	6515                	lui	a0,0x5
  42:	3d0000ef          	jal	ra,412 <sys_sbrk>
  46:	892a                	mv	s2,a0
    printf("Allocating 5 pages lazily where each page is of size %d bytes...\n", PGSIZE);
  48:	6585                	lui	a1,0x1
  4a:	00001517          	auipc	a0,0x1
  4e:	9a650513          	addi	a0,a0,-1626 # 9f0 <malloc+0x148>
  52:	79c000ef          	jal	ra,7ee <printf>
    va_size = getvasize();
  56:	3fc000ef          	jal	ra,452 <getvasize>
  5a:	85aa                	mv	a1,a0
    printf("Virtual address space size after sbrk lazy: %ld bytes\n\n", va_size);
  5c:	00001517          	auipc	a0,0x1
  60:	9dc50513          	addi	a0,a0,-1572 # a38 <malloc+0x190>
  64:	78a000ef          	jal	ra,7ee <printf>

    for(int i = 0; i < PGSIZE * 5; i += PGSIZE){
  68:	4481                	li	s1,0
        p[i] = 1;
  6a:	4c85                	li	s9,1
        printf("Touched page at virtual address: %p\n", (void *)(p + i));
  6c:	00001c17          	auipc	s8,0x1
  70:	a04c0c13          	addi	s8,s8,-1532 # a70 <malloc+0x1c8>
        printf("Page faults after touching page %d: %d\n", i/PGSIZE, getlazyfaults());
  74:	00001b97          	auipc	s7,0x1
  78:	a24b8b93          	addi	s7,s7,-1500 # a98 <malloc+0x1f0>
        printf("PA size after each page touch: %ld bytes\n\n", getpasize());
  7c:	00001b17          	auipc	s6,0x1
  80:	a44b0b13          	addi	s6,s6,-1468 # ac0 <malloc+0x218>
    for(int i = 0; i < PGSIZE * 5; i += PGSIZE){
  84:	6a85                	lui	s5,0x1
  86:	6a05                	lui	s4,0x1
  88:	6995                	lui	s3,0x5
        p[i] = 1;
  8a:	01990023          	sb	s9,0(s2)
        printf("Touched page at virtual address: %p\n", (void *)(p + i));
  8e:	85ca                	mv	a1,s2
  90:	8562                	mv	a0,s8
  92:	75c000ef          	jal	ra,7ee <printf>
        printf("Page faults after touching page %d: %d\n", i/PGSIZE, getlazyfaults());
  96:	3cc000ef          	jal	ra,462 <getlazyfaults>
  9a:	862a                	mv	a2,a0
  9c:	41f4d59b          	sraiw	a1,s1,0x1f
  a0:	0145d59b          	srliw	a1,a1,0x14
  a4:	9da5                	addw	a1,a1,s1
  a6:	40c5d59b          	sraiw	a1,a1,0xc
  aa:	855e                	mv	a0,s7
  ac:	742000ef          	jal	ra,7ee <printf>
        printf("PA size after each page touch: %ld bytes\n\n", getpasize());
  b0:	3aa000ef          	jal	ra,45a <getpasize>
  b4:	85aa                	mv	a1,a0
  b6:	855a                	mv	a0,s6
  b8:	736000ef          	jal	ra,7ee <printf>
    for(int i = 0; i < PGSIZE * 5; i += PGSIZE){
  bc:	009a84bb          	addw	s1,s5,s1
  c0:	9952                	add	s2,s2,s4
  c2:	fd3494e3          	bne	s1,s3,8a <main+0x8a>
    }

    printf("Total Page faults After touching pages: %d\n", getlazyfaults());
  c6:	39c000ef          	jal	ra,462 <getlazyfaults>
  ca:	85aa                	mv	a1,a0
  cc:	00001517          	auipc	a0,0x1
  d0:	a2450513          	addi	a0,a0,-1500 # af0 <malloc+0x248>
  d4:	71a000ef          	jal	ra,7ee <printf>
    exit(0);
  d8:	4501                	li	a0,0
  da:	2b0000ef          	jal	ra,38a <exit>

00000000000000de <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e406                	sd	ra,8(sp)
  e2:	e022                	sd	s0,0(sp)
  e4:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  e6:	f1bff0ef          	jal	ra,0 <main>
  exit(r);
  ea:	2a0000ef          	jal	ra,38a <exit>

00000000000000ee <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  f4:	87aa                	mv	a5,a0
  f6:	0585                	addi	a1,a1,1
  f8:	0785                	addi	a5,a5,1
  fa:	fff5c703          	lbu	a4,-1(a1) # fff <digits+0x4d7>
  fe:	fee78fa3          	sb	a4,-1(a5)
 102:	fb75                	bnez	a4,f6 <strcpy+0x8>
    ;
  return os;
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret

000000000000010a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 110:	00054783          	lbu	a5,0(a0)
 114:	cb91                	beqz	a5,128 <strcmp+0x1e>
 116:	0005c703          	lbu	a4,0(a1)
 11a:	00f71763          	bne	a4,a5,128 <strcmp+0x1e>
    p++, q++;
 11e:	0505                	addi	a0,a0,1
 120:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 122:	00054783          	lbu	a5,0(a0)
 126:	fbe5                	bnez	a5,116 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 128:	0005c503          	lbu	a0,0(a1)
}
 12c:	40a7853b          	subw	a0,a5,a0
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strlen>:

uint
strlen(const char *s)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 13c:	00054783          	lbu	a5,0(a0)
 140:	cf91                	beqz	a5,15c <strlen+0x26>
 142:	0505                	addi	a0,a0,1
 144:	87aa                	mv	a5,a0
 146:	4685                	li	a3,1
 148:	9e89                	subw	a3,a3,a0
 14a:	00f6853b          	addw	a0,a3,a5
 14e:	0785                	addi	a5,a5,1
 150:	fff7c703          	lbu	a4,-1(a5)
 154:	fb7d                	bnez	a4,14a <strlen+0x14>
    ;
  return n;
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  for(n = 0; s[n]; n++)
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strlen+0x20>

0000000000000160 <memset>:

void*
memset(void *dst, int c, uint n)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 166:	ca19                	beqz	a2,17c <memset+0x1c>
 168:	87aa                	mv	a5,a0
 16a:	1602                	slli	a2,a2,0x20
 16c:	9201                	srli	a2,a2,0x20
 16e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 172:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 176:	0785                	addi	a5,a5,1
 178:	fee79de3          	bne	a5,a4,172 <memset+0x12>
  }
  return dst;
}
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret

0000000000000182 <strchr>:

char*
strchr(const char *s, char c)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  for(; *s; s++)
 188:	00054783          	lbu	a5,0(a0)
 18c:	cb99                	beqz	a5,1a2 <strchr+0x20>
    if(*s == c)
 18e:	00f58763          	beq	a1,a5,19c <strchr+0x1a>
  for(; *s; s++)
 192:	0505                	addi	a0,a0,1
 194:	00054783          	lbu	a5,0(a0)
 198:	fbfd                	bnez	a5,18e <strchr+0xc>
      return (char*)s;
  return 0;
 19a:	4501                	li	a0,0
}
 19c:	6422                	ld	s0,8(sp)
 19e:	0141                	addi	sp,sp,16
 1a0:	8082                	ret
  return 0;
 1a2:	4501                	li	a0,0
 1a4:	bfe5                	j	19c <strchr+0x1a>

00000000000001a6 <gets>:

char*
gets(char *buf, int max)
{
 1a6:	711d                	addi	sp,sp,-96
 1a8:	ec86                	sd	ra,88(sp)
 1aa:	e8a2                	sd	s0,80(sp)
 1ac:	e4a6                	sd	s1,72(sp)
 1ae:	e0ca                	sd	s2,64(sp)
 1b0:	fc4e                	sd	s3,56(sp)
 1b2:	f852                	sd	s4,48(sp)
 1b4:	f456                	sd	s5,40(sp)
 1b6:	f05a                	sd	s6,32(sp)
 1b8:	ec5e                	sd	s7,24(sp)
 1ba:	1080                	addi	s0,sp,96
 1bc:	8baa                	mv	s7,a0
 1be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c0:	892a                	mv	s2,a0
 1c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1c4:	4aa9                	li	s5,10
 1c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c8:	89a6                	mv	s3,s1
 1ca:	2485                	addiw	s1,s1,1
 1cc:	0344d663          	bge	s1,s4,1f8 <gets+0x52>
    cc = read(0, &c, 1);
 1d0:	4605                	li	a2,1
 1d2:	faf40593          	addi	a1,s0,-81
 1d6:	4501                	li	a0,0
 1d8:	1ca000ef          	jal	ra,3a2 <read>
    if(cc < 1)
 1dc:	00a05e63          	blez	a0,1f8 <gets+0x52>
    buf[i++] = c;
 1e0:	faf44783          	lbu	a5,-81(s0)
 1e4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e8:	01578763          	beq	a5,s5,1f6 <gets+0x50>
 1ec:	0905                	addi	s2,s2,1
 1ee:	fd679de3          	bne	a5,s6,1c8 <gets+0x22>
  for(i=0; i+1 < max; ){
 1f2:	89a6                	mv	s3,s1
 1f4:	a011                	j	1f8 <gets+0x52>
 1f6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f8:	99de                	add	s3,s3,s7
 1fa:	00098023          	sb	zero,0(s3) # 5000 <base+0x3ff0>
  return buf;
}
 1fe:	855e                	mv	a0,s7
 200:	60e6                	ld	ra,88(sp)
 202:	6446                	ld	s0,80(sp)
 204:	64a6                	ld	s1,72(sp)
 206:	6906                	ld	s2,64(sp)
 208:	79e2                	ld	s3,56(sp)
 20a:	7a42                	ld	s4,48(sp)
 20c:	7aa2                	ld	s5,40(sp)
 20e:	7b02                	ld	s6,32(sp)
 210:	6be2                	ld	s7,24(sp)
 212:	6125                	addi	sp,sp,96
 214:	8082                	ret

0000000000000216 <stat>:

int
stat(const char *n, struct stat *st)
{
 216:	1101                	addi	sp,sp,-32
 218:	ec06                	sd	ra,24(sp)
 21a:	e822                	sd	s0,16(sp)
 21c:	e426                	sd	s1,8(sp)
 21e:	e04a                	sd	s2,0(sp)
 220:	1000                	addi	s0,sp,32
 222:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 224:	4581                	li	a1,0
 226:	1a4000ef          	jal	ra,3ca <open>
  if(fd < 0)
 22a:	02054163          	bltz	a0,24c <stat+0x36>
 22e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 230:	85ca                	mv	a1,s2
 232:	1b0000ef          	jal	ra,3e2 <fstat>
 236:	892a                	mv	s2,a0
  close(fd);
 238:	8526                	mv	a0,s1
 23a:	178000ef          	jal	ra,3b2 <close>
  return r;
}
 23e:	854a                	mv	a0,s2
 240:	60e2                	ld	ra,24(sp)
 242:	6442                	ld	s0,16(sp)
 244:	64a2                	ld	s1,8(sp)
 246:	6902                	ld	s2,0(sp)
 248:	6105                	addi	sp,sp,32
 24a:	8082                	ret
    return -1;
 24c:	597d                	li	s2,-1
 24e:	bfc5                	j	23e <stat+0x28>

0000000000000250 <atoi>:

int
atoi(const char *s)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 256:	00054603          	lbu	a2,0(a0)
 25a:	fd06079b          	addiw	a5,a2,-48
 25e:	0ff7f793          	andi	a5,a5,255
 262:	4725                	li	a4,9
 264:	02f76963          	bltu	a4,a5,296 <atoi+0x46>
 268:	86aa                	mv	a3,a0
  n = 0;
 26a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 26c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 26e:	0685                	addi	a3,a3,1
 270:	0025179b          	slliw	a5,a0,0x2
 274:	9fa9                	addw	a5,a5,a0
 276:	0017979b          	slliw	a5,a5,0x1
 27a:	9fb1                	addw	a5,a5,a2
 27c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 280:	0006c603          	lbu	a2,0(a3)
 284:	fd06071b          	addiw	a4,a2,-48
 288:	0ff77713          	andi	a4,a4,255
 28c:	fee5f1e3          	bgeu	a1,a4,26e <atoi+0x1e>
  return n;
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
  n = 0;
 296:	4501                	li	a0,0
 298:	bfe5                	j	290 <atoi+0x40>

000000000000029a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a0:	02b57463          	bgeu	a0,a1,2c8 <memmove+0x2e>
    while(n-- > 0)
 2a4:	00c05f63          	blez	a2,2c2 <memmove+0x28>
 2a8:	1602                	slli	a2,a2,0x20
 2aa:	9201                	srli	a2,a2,0x20
 2ac:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b2:	0585                	addi	a1,a1,1
 2b4:	0705                	addi	a4,a4,1
 2b6:	fff5c683          	lbu	a3,-1(a1)
 2ba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2be:	fee79ae3          	bne	a5,a4,2b2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
    dst += n;
 2c8:	00c50733          	add	a4,a0,a2
    src += n;
 2cc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ce:	fec05ae3          	blez	a2,2c2 <memmove+0x28>
 2d2:	fff6079b          	addiw	a5,a2,-1
 2d6:	1782                	slli	a5,a5,0x20
 2d8:	9381                	srli	a5,a5,0x20
 2da:	fff7c793          	not	a5,a5
 2de:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e0:	15fd                	addi	a1,a1,-1
 2e2:	177d                	addi	a4,a4,-1
 2e4:	0005c683          	lbu	a3,0(a1)
 2e8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ec:	fee79ae3          	bne	a5,a4,2e0 <memmove+0x46>
 2f0:	bfc9                	j	2c2 <memmove+0x28>

00000000000002f2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f8:	ca05                	beqz	a2,328 <memcmp+0x36>
 2fa:	fff6069b          	addiw	a3,a2,-1
 2fe:	1682                	slli	a3,a3,0x20
 300:	9281                	srli	a3,a3,0x20
 302:	0685                	addi	a3,a3,1
 304:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 306:	00054783          	lbu	a5,0(a0)
 30a:	0005c703          	lbu	a4,0(a1)
 30e:	00e79863          	bne	a5,a4,31e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 312:	0505                	addi	a0,a0,1
    p2++;
 314:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 316:	fed518e3          	bne	a0,a3,306 <memcmp+0x14>
  }
  return 0;
 31a:	4501                	li	a0,0
 31c:	a019                	j	322 <memcmp+0x30>
      return *p1 - *p2;
 31e:	40e7853b          	subw	a0,a5,a4
}
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret
  return 0;
 328:	4501                	li	a0,0
 32a:	bfe5                	j	322 <memcmp+0x30>

000000000000032c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 32c:	1141                	addi	sp,sp,-16
 32e:	e406                	sd	ra,8(sp)
 330:	e022                	sd	s0,0(sp)
 332:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 334:	f67ff0ef          	jal	ra,29a <memmove>
}
 338:	60a2                	ld	ra,8(sp)
 33a:	6402                	ld	s0,0(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret

0000000000000340 <sbrk>:

char *
sbrk(int n) {
 340:	1141                	addi	sp,sp,-16
 342:	e406                	sd	ra,8(sp)
 344:	e022                	sd	s0,0(sp)
 346:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 348:	4585                	li	a1,1
 34a:	0c8000ef          	jal	ra,412 <sys_sbrk>
}
 34e:	60a2                	ld	ra,8(sp)
 350:	6402                	ld	s0,0(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret

0000000000000356 <sbrklazy>:

char *
sbrklazy(int n) {
 356:	1141                	addi	sp,sp,-16
 358:	e406                	sd	ra,8(sp)
 35a:	e022                	sd	s0,0(sp)
 35c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 35e:	4589                	li	a1,2
 360:	0b2000ef          	jal	ra,412 <sys_sbrk>
}
 364:	60a2                	ld	ra,8(sp)
 366:	6402                	ld	s0,0(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret

000000000000036c <ugetpid>:

int
ugetpid(void)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  return (*(int*)UGET);
 372:	040007b7          	lui	a5,0x4000
 376:	17f5                	addi	a5,a5,-3
 378:	07b2                	slli	a5,a5,0xc
 37a:	4388                	lw	a0,0(a5)
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret

0000000000000382 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 382:	4885                	li	a7,1
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <exit>:
.global exit
exit:
 li a7, SYS_exit
 38a:	4889                	li	a7,2
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <wait>:
.global wait
wait:
 li a7, SYS_wait
 392:	488d                	li	a7,3
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39a:	4891                	li	a7,4
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <read>:
.global read
read:
 li a7, SYS_read
 3a2:	4895                	li	a7,5
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <write>:
.global write
write:
 li a7, SYS_write
 3aa:	48c1                	li	a7,16
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <close>:
.global close
close:
 li a7, SYS_close
 3b2:	48d5                	li	a7,21
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ba:	4899                	li	a7,6
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c2:	489d                	li	a7,7
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <open>:
.global open
open:
 li a7, SYS_open
 3ca:	48bd                	li	a7,15
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d2:	48c5                	li	a7,17
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3da:	48c9                	li	a7,18
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e2:	48a1                	li	a7,8
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <link>:
.global link
link:
 li a7, SYS_link
 3ea:	48cd                	li	a7,19
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f2:	48d1                	li	a7,20
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3fa:	48a5                	li	a7,9
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <dup>:
.global dup
dup:
 li a7, SYS_dup
 402:	48a9                	li	a7,10
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 40a:	48ad                	li	a7,11
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 412:	48b1                	li	a7,12
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <pause>:
.global pause
pause:
 li a7, SYS_pause
 41a:	48b5                	li	a7,13
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 422:	48b9                	li	a7,14
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <pte_valid>:
.global pte_valid
pte_valid:
 li a7, SYS_pte_valid
 42a:	48d9                	li	a7,22
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <get_pteflags>:
.global get_pteflags
get_pteflags:
 li a7, SYS_get_pteflags
 432:	48dd                	li	a7,23
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <print_pgdirs>:
.global print_pgdirs
print_pgdirs:
 li a7, SYS_print_pgdirs
 43a:	48e1                	li	a7,24
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <va_to_pte>:
.global va_to_pte
va_to_pte:
 li a7, SYS_va_to_pte
 442:	48e5                	li	a7,25
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <va_to_pa>:
.global va_to_pa
va_to_pa:
 li a7, SYS_va_to_pa
 44a:	48e9                	li	a7,26
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <getvasize>:
.global getvasize
getvasize:
 li a7, SYS_getvasize
 452:	48ed                	li	a7,27
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <getpasize>:
.global getpasize
getpasize:
 li a7, SYS_getpasize
 45a:	48f1                	li	a7,28
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <getlazyfaults>:
.global getlazyfaults
getlazyfaults:
 li a7, SYS_getlazyfaults
 462:	48f5                	li	a7,29
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <kva_to_pa>:
.global kva_to_pa
kva_to_pa:
 li a7, SYS_kva_to_pa
 46a:	48f9                	li	a7,30
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 472:	1101                	addi	sp,sp,-32
 474:	ec06                	sd	ra,24(sp)
 476:	e822                	sd	s0,16(sp)
 478:	1000                	addi	s0,sp,32
 47a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 47e:	4605                	li	a2,1
 480:	fef40593          	addi	a1,s0,-17
 484:	f27ff0ef          	jal	ra,3aa <write>
}
 488:	60e2                	ld	ra,24(sp)
 48a:	6442                	ld	s0,16(sp)
 48c:	6105                	addi	sp,sp,32
 48e:	8082                	ret

0000000000000490 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 490:	715d                	addi	sp,sp,-80
 492:	e486                	sd	ra,72(sp)
 494:	e0a2                	sd	s0,64(sp)
 496:	fc26                	sd	s1,56(sp)
 498:	f84a                	sd	s2,48(sp)
 49a:	f44e                	sd	s3,40(sp)
 49c:	0880                	addi	s0,sp,80
 49e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4a0:	c299                	beqz	a3,4a6 <printint+0x16>
 4a2:	0805c163          	bltz	a1,524 <printint+0x94>
  neg = 0;
 4a6:	4881                	li	a7,0
 4a8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4ac:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4ae:	00000517          	auipc	a0,0x0
 4b2:	67a50513          	addi	a0,a0,1658 # b28 <digits>
 4b6:	883e                	mv	a6,a5
 4b8:	2785                	addiw	a5,a5,1
 4ba:	02c5f733          	remu	a4,a1,a2
 4be:	972a                	add	a4,a4,a0
 4c0:	00074703          	lbu	a4,0(a4)
 4c4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4c8:	872e                	mv	a4,a1
 4ca:	02c5d5b3          	divu	a1,a1,a2
 4ce:	0685                	addi	a3,a3,1
 4d0:	fec773e3          	bgeu	a4,a2,4b6 <printint+0x26>
  if(neg)
 4d4:	00088b63          	beqz	a7,4ea <printint+0x5a>
    buf[i++] = '-';
 4d8:	fd040713          	addi	a4,s0,-48
 4dc:	97ba                	add	a5,a5,a4
 4de:	02d00713          	li	a4,45
 4e2:	fee78423          	sb	a4,-24(a5) # 3ffffe8 <base+0x3ffefd8>
 4e6:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4ea:	02f05663          	blez	a5,516 <printint+0x86>
 4ee:	fb840713          	addi	a4,s0,-72
 4f2:	00f704b3          	add	s1,a4,a5
 4f6:	fff70993          	addi	s3,a4,-1
 4fa:	99be                	add	s3,s3,a5
 4fc:	37fd                	addiw	a5,a5,-1
 4fe:	1782                	slli	a5,a5,0x20
 500:	9381                	srli	a5,a5,0x20
 502:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 506:	fff4c583          	lbu	a1,-1(s1)
 50a:	854a                	mv	a0,s2
 50c:	f67ff0ef          	jal	ra,472 <putc>
  while(--i >= 0)
 510:	14fd                	addi	s1,s1,-1
 512:	ff349ae3          	bne	s1,s3,506 <printint+0x76>
}
 516:	60a6                	ld	ra,72(sp)
 518:	6406                	ld	s0,64(sp)
 51a:	74e2                	ld	s1,56(sp)
 51c:	7942                	ld	s2,48(sp)
 51e:	79a2                	ld	s3,40(sp)
 520:	6161                	addi	sp,sp,80
 522:	8082                	ret
    x = -xx;
 524:	40b005b3          	neg	a1,a1
    neg = 1;
 528:	4885                	li	a7,1
    x = -xx;
 52a:	bfbd                	j	4a8 <printint+0x18>

000000000000052c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 52c:	7119                	addi	sp,sp,-128
 52e:	fc86                	sd	ra,120(sp)
 530:	f8a2                	sd	s0,112(sp)
 532:	f4a6                	sd	s1,104(sp)
 534:	f0ca                	sd	s2,96(sp)
 536:	ecce                	sd	s3,88(sp)
 538:	e8d2                	sd	s4,80(sp)
 53a:	e4d6                	sd	s5,72(sp)
 53c:	e0da                	sd	s6,64(sp)
 53e:	fc5e                	sd	s7,56(sp)
 540:	f862                	sd	s8,48(sp)
 542:	f466                	sd	s9,40(sp)
 544:	f06a                	sd	s10,32(sp)
 546:	ec6e                	sd	s11,24(sp)
 548:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 54a:	0005c903          	lbu	s2,0(a1)
 54e:	24090c63          	beqz	s2,7a6 <vprintf+0x27a>
 552:	8b2a                	mv	s6,a0
 554:	8a2e                	mv	s4,a1
 556:	8bb2                	mv	s7,a2
  state = 0;
 558:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 55a:	4481                	li	s1,0
 55c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 55e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 562:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 566:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 56a:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56e:	00000c97          	auipc	s9,0x0
 572:	5bac8c93          	addi	s9,s9,1466 # b28 <digits>
 576:	a005                	j	596 <vprintf+0x6a>
        putc(fd, c0);
 578:	85ca                	mv	a1,s2
 57a:	855a                	mv	a0,s6
 57c:	ef7ff0ef          	jal	ra,472 <putc>
 580:	a019                	j	586 <vprintf+0x5a>
    } else if(state == '%'){
 582:	03598263          	beq	s3,s5,5a6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 586:	2485                	addiw	s1,s1,1
 588:	8726                	mv	a4,s1
 58a:	009a07b3          	add	a5,s4,s1
 58e:	0007c903          	lbu	s2,0(a5)
 592:	20090a63          	beqz	s2,7a6 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 596:	0009079b          	sext.w	a5,s2
    if(state == 0){
 59a:	fe0994e3          	bnez	s3,582 <vprintf+0x56>
      if(c0 == '%'){
 59e:	fd579de3          	bne	a5,s5,578 <vprintf+0x4c>
        state = '%';
 5a2:	89be                	mv	s3,a5
 5a4:	b7cd                	j	586 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5a6:	c3c1                	beqz	a5,626 <vprintf+0xfa>
 5a8:	00ea06b3          	add	a3,s4,a4
 5ac:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5b0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5b2:	c681                	beqz	a3,5ba <vprintf+0x8e>
 5b4:	9752                	add	a4,a4,s4
 5b6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5ba:	03878e63          	beq	a5,s8,5f6 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5be:	05a78863          	beq	a5,s10,60e <vprintf+0xe2>
      } else if(c0 == 'u'){
 5c2:	0db78b63          	beq	a5,s11,698 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5c6:	07800713          	li	a4,120
 5ca:	10e78d63          	beq	a5,a4,6e4 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ce:	07000713          	li	a4,112
 5d2:	14e78263          	beq	a5,a4,716 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5d6:	06300713          	li	a4,99
 5da:	16e78f63          	beq	a5,a4,758 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5de:	07300713          	li	a4,115
 5e2:	18e78563          	beq	a5,a4,76c <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5e6:	05579063          	bne	a5,s5,626 <vprintf+0xfa>
        putc(fd, '%');
 5ea:	85d6                	mv	a1,s5
 5ec:	855a                	mv	a0,s6
 5ee:	e85ff0ef          	jal	ra,472 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	bf49                	j	586 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5f6:	008b8913          	addi	s2,s7,8
 5fa:	4685                	li	a3,1
 5fc:	4629                	li	a2,10
 5fe:	000ba583          	lw	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	e8dff0ef          	jal	ra,490 <printint>
 608:	8bca                	mv	s7,s2
      state = 0;
 60a:	4981                	li	s3,0
 60c:	bfad                	j	586 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 60e:	03868663          	beq	a3,s8,63a <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 612:	05a68163          	beq	a3,s10,654 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 616:	09b68d63          	beq	a3,s11,6b0 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 61a:	03a68f63          	beq	a3,s10,658 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 61e:	07800793          	li	a5,120
 622:	0cf68d63          	beq	a3,a5,6fc <vprintf+0x1d0>
        putc(fd, '%');
 626:	85d6                	mv	a1,s5
 628:	855a                	mv	a0,s6
 62a:	e49ff0ef          	jal	ra,472 <putc>
        putc(fd, c0);
 62e:	85ca                	mv	a1,s2
 630:	855a                	mv	a0,s6
 632:	e41ff0ef          	jal	ra,472 <putc>
      state = 0;
 636:	4981                	li	s3,0
 638:	b7b9                	j	586 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 63a:	008b8913          	addi	s2,s7,8
 63e:	4685                	li	a3,1
 640:	4629                	li	a2,10
 642:	000bb583          	ld	a1,0(s7)
 646:	855a                	mv	a0,s6
 648:	e49ff0ef          	jal	ra,490 <printint>
        i += 1;
 64c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
        i += 1;
 652:	bf15                	j	586 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 654:	03860563          	beq	a2,s8,67e <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 658:	07b60963          	beq	a2,s11,6ca <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 65c:	07800793          	li	a5,120
 660:	fcf613e3          	bne	a2,a5,626 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 664:	008b8913          	addi	s2,s7,8
 668:	4681                	li	a3,0
 66a:	4641                	li	a2,16
 66c:	000bb583          	ld	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	e1fff0ef          	jal	ra,490 <printint>
        i += 2;
 676:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
        i += 2;
 67c:	b729                	j	586 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 67e:	008b8913          	addi	s2,s7,8
 682:	4685                	li	a3,1
 684:	4629                	li	a2,10
 686:	000bb583          	ld	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	e05ff0ef          	jal	ra,490 <printint>
        i += 2;
 690:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 692:	8bca                	mv	s7,s2
      state = 0;
 694:	4981                	li	s3,0
        i += 2;
 696:	bdc5                	j	586 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 698:	008b8913          	addi	s2,s7,8
 69c:	4681                	li	a3,0
 69e:	4629                	li	a2,10
 6a0:	000be583          	lwu	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	debff0ef          	jal	ra,490 <printint>
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	bde1                	j	586 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b0:	008b8913          	addi	s2,s7,8
 6b4:	4681                	li	a3,0
 6b6:	4629                	li	a2,10
 6b8:	000bb583          	ld	a1,0(s7)
 6bc:	855a                	mv	a0,s6
 6be:	dd3ff0ef          	jal	ra,490 <printint>
        i += 1;
 6c2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c4:	8bca                	mv	s7,s2
      state = 0;
 6c6:	4981                	li	s3,0
        i += 1;
 6c8:	bd7d                	j	586 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ca:	008b8913          	addi	s2,s7,8
 6ce:	4681                	li	a3,0
 6d0:	4629                	li	a2,10
 6d2:	000bb583          	ld	a1,0(s7)
 6d6:	855a                	mv	a0,s6
 6d8:	db9ff0ef          	jal	ra,490 <printint>
        i += 2;
 6dc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6de:	8bca                	mv	s7,s2
      state = 0;
 6e0:	4981                	li	s3,0
        i += 2;
 6e2:	b555                	j	586 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6e4:	008b8913          	addi	s2,s7,8
 6e8:	4681                	li	a3,0
 6ea:	4641                	li	a2,16
 6ec:	000be583          	lwu	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	d9fff0ef          	jal	ra,490 <printint>
 6f6:	8bca                	mv	s7,s2
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b571                	j	586 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fc:	008b8913          	addi	s2,s7,8
 700:	4681                	li	a3,0
 702:	4641                	li	a2,16
 704:	000bb583          	ld	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	d87ff0ef          	jal	ra,490 <printint>
        i += 1;
 70e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 710:	8bca                	mv	s7,s2
      state = 0;
 712:	4981                	li	s3,0
        i += 1;
 714:	bd8d                	j	586 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 716:	008b8793          	addi	a5,s7,8
 71a:	f8f43423          	sd	a5,-120(s0)
 71e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 722:	03000593          	li	a1,48
 726:	855a                	mv	a0,s6
 728:	d4bff0ef          	jal	ra,472 <putc>
  putc(fd, 'x');
 72c:	07800593          	li	a1,120
 730:	855a                	mv	a0,s6
 732:	d41ff0ef          	jal	ra,472 <putc>
 736:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 738:	03c9d793          	srli	a5,s3,0x3c
 73c:	97e6                	add	a5,a5,s9
 73e:	0007c583          	lbu	a1,0(a5)
 742:	855a                	mv	a0,s6
 744:	d2fff0ef          	jal	ra,472 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 748:	0992                	slli	s3,s3,0x4
 74a:	397d                	addiw	s2,s2,-1
 74c:	fe0916e3          	bnez	s2,738 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 750:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 754:	4981                	li	s3,0
 756:	bd05                	j	586 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 758:	008b8913          	addi	s2,s7,8
 75c:	000bc583          	lbu	a1,0(s7)
 760:	855a                	mv	a0,s6
 762:	d11ff0ef          	jal	ra,472 <putc>
 766:	8bca                	mv	s7,s2
      state = 0;
 768:	4981                	li	s3,0
 76a:	bd31                	j	586 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 76c:	008b8993          	addi	s3,s7,8
 770:	000bb903          	ld	s2,0(s7)
 774:	00090f63          	beqz	s2,792 <vprintf+0x266>
        for(; *s; s++)
 778:	00094583          	lbu	a1,0(s2)
 77c:	c195                	beqz	a1,7a0 <vprintf+0x274>
          putc(fd, *s);
 77e:	855a                	mv	a0,s6
 780:	cf3ff0ef          	jal	ra,472 <putc>
        for(; *s; s++)
 784:	0905                	addi	s2,s2,1
 786:	00094583          	lbu	a1,0(s2)
 78a:	f9f5                	bnez	a1,77e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 78c:	8bce                	mv	s7,s3
      state = 0;
 78e:	4981                	li	s3,0
 790:	bbdd                	j	586 <vprintf+0x5a>
          s = "(null)";
 792:	00000917          	auipc	s2,0x0
 796:	38e90913          	addi	s2,s2,910 # b20 <malloc+0x278>
        for(; *s; s++)
 79a:	02800593          	li	a1,40
 79e:	b7c5                	j	77e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7a0:	8bce                	mv	s7,s3
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b3cd                	j	586 <vprintf+0x5a>
    }
  }
}
 7a6:	70e6                	ld	ra,120(sp)
 7a8:	7446                	ld	s0,112(sp)
 7aa:	74a6                	ld	s1,104(sp)
 7ac:	7906                	ld	s2,96(sp)
 7ae:	69e6                	ld	s3,88(sp)
 7b0:	6a46                	ld	s4,80(sp)
 7b2:	6aa6                	ld	s5,72(sp)
 7b4:	6b06                	ld	s6,64(sp)
 7b6:	7be2                	ld	s7,56(sp)
 7b8:	7c42                	ld	s8,48(sp)
 7ba:	7ca2                	ld	s9,40(sp)
 7bc:	7d02                	ld	s10,32(sp)
 7be:	6de2                	ld	s11,24(sp)
 7c0:	6109                	addi	sp,sp,128
 7c2:	8082                	ret

00000000000007c4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7c4:	715d                	addi	sp,sp,-80
 7c6:	ec06                	sd	ra,24(sp)
 7c8:	e822                	sd	s0,16(sp)
 7ca:	1000                	addi	s0,sp,32
 7cc:	e010                	sd	a2,0(s0)
 7ce:	e414                	sd	a3,8(s0)
 7d0:	e818                	sd	a4,16(s0)
 7d2:	ec1c                	sd	a5,24(s0)
 7d4:	03043023          	sd	a6,32(s0)
 7d8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7dc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e0:	8622                	mv	a2,s0
 7e2:	d4bff0ef          	jal	ra,52c <vprintf>
}
 7e6:	60e2                	ld	ra,24(sp)
 7e8:	6442                	ld	s0,16(sp)
 7ea:	6161                	addi	sp,sp,80
 7ec:	8082                	ret

00000000000007ee <printf>:

void
printf(const char *fmt, ...)
{
 7ee:	711d                	addi	sp,sp,-96
 7f0:	ec06                	sd	ra,24(sp)
 7f2:	e822                	sd	s0,16(sp)
 7f4:	1000                	addi	s0,sp,32
 7f6:	e40c                	sd	a1,8(s0)
 7f8:	e810                	sd	a2,16(s0)
 7fa:	ec14                	sd	a3,24(s0)
 7fc:	f018                	sd	a4,32(s0)
 7fe:	f41c                	sd	a5,40(s0)
 800:	03043823          	sd	a6,48(s0)
 804:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 808:	00840613          	addi	a2,s0,8
 80c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 810:	85aa                	mv	a1,a0
 812:	4505                	li	a0,1
 814:	d19ff0ef          	jal	ra,52c <vprintf>
}
 818:	60e2                	ld	ra,24(sp)
 81a:	6442                	ld	s0,16(sp)
 81c:	6125                	addi	sp,sp,96
 81e:	8082                	ret

0000000000000820 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 820:	1141                	addi	sp,sp,-16
 822:	e422                	sd	s0,8(sp)
 824:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 826:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82a:	00000797          	auipc	a5,0x0
 82e:	7d67b783          	ld	a5,2006(a5) # 1000 <freep>
 832:	a805                	j	862 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 834:	4618                	lw	a4,8(a2)
 836:	9db9                	addw	a1,a1,a4
 838:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 83c:	6398                	ld	a4,0(a5)
 83e:	6318                	ld	a4,0(a4)
 840:	fee53823          	sd	a4,-16(a0)
 844:	a091                	j	888 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 846:	ff852703          	lw	a4,-8(a0)
 84a:	9e39                	addw	a2,a2,a4
 84c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 84e:	ff053703          	ld	a4,-16(a0)
 852:	e398                	sd	a4,0(a5)
 854:	a099                	j	89a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 856:	6398                	ld	a4,0(a5)
 858:	00e7e463          	bltu	a5,a4,860 <free+0x40>
 85c:	00e6ea63          	bltu	a3,a4,870 <free+0x50>
{
 860:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 862:	fed7fae3          	bgeu	a5,a3,856 <free+0x36>
 866:	6398                	ld	a4,0(a5)
 868:	00e6e463          	bltu	a3,a4,870 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86c:	fee7eae3          	bltu	a5,a4,860 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 870:	ff852583          	lw	a1,-8(a0)
 874:	6390                	ld	a2,0(a5)
 876:	02059713          	slli	a4,a1,0x20
 87a:	9301                	srli	a4,a4,0x20
 87c:	0712                	slli	a4,a4,0x4
 87e:	9736                	add	a4,a4,a3
 880:	fae60ae3          	beq	a2,a4,834 <free+0x14>
    bp->s.ptr = p->s.ptr;
 884:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 888:	4790                	lw	a2,8(a5)
 88a:	02061713          	slli	a4,a2,0x20
 88e:	9301                	srli	a4,a4,0x20
 890:	0712                	slli	a4,a4,0x4
 892:	973e                	add	a4,a4,a5
 894:	fae689e3          	beq	a3,a4,846 <free+0x26>
  } else
    p->s.ptr = bp;
 898:	e394                	sd	a3,0(a5)
  freep = p;
 89a:	00000717          	auipc	a4,0x0
 89e:	76f73323          	sd	a5,1894(a4) # 1000 <freep>
}
 8a2:	6422                	ld	s0,8(sp)
 8a4:	0141                	addi	sp,sp,16
 8a6:	8082                	ret

00000000000008a8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a8:	7139                	addi	sp,sp,-64
 8aa:	fc06                	sd	ra,56(sp)
 8ac:	f822                	sd	s0,48(sp)
 8ae:	f426                	sd	s1,40(sp)
 8b0:	f04a                	sd	s2,32(sp)
 8b2:	ec4e                	sd	s3,24(sp)
 8b4:	e852                	sd	s4,16(sp)
 8b6:	e456                	sd	s5,8(sp)
 8b8:	e05a                	sd	s6,0(sp)
 8ba:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8bc:	02051493          	slli	s1,a0,0x20
 8c0:	9081                	srli	s1,s1,0x20
 8c2:	04bd                	addi	s1,s1,15
 8c4:	8091                	srli	s1,s1,0x4
 8c6:	0014899b          	addiw	s3,s1,1
 8ca:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8cc:	00000517          	auipc	a0,0x0
 8d0:	73453503          	ld	a0,1844(a0) # 1000 <freep>
 8d4:	c515                	beqz	a0,900 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d8:	4798                	lw	a4,8(a5)
 8da:	02977f63          	bgeu	a4,s1,918 <malloc+0x70>
 8de:	8a4e                	mv	s4,s3
 8e0:	0009871b          	sext.w	a4,s3
 8e4:	6685                	lui	a3,0x1
 8e6:	00d77363          	bgeu	a4,a3,8ec <malloc+0x44>
 8ea:	6a05                	lui	s4,0x1
 8ec:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8f4:	00000917          	auipc	s2,0x0
 8f8:	70c90913          	addi	s2,s2,1804 # 1000 <freep>
  if(p == SBRK_ERROR)
 8fc:	5afd                	li	s5,-1
 8fe:	a0bd                	j	96c <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 900:	00000797          	auipc	a5,0x0
 904:	71078793          	addi	a5,a5,1808 # 1010 <base>
 908:	00000717          	auipc	a4,0x0
 90c:	6ef73c23          	sd	a5,1784(a4) # 1000 <freep>
 910:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 912:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 916:	b7e1                	j	8de <malloc+0x36>
      if(p->s.size == nunits)
 918:	02e48b63          	beq	s1,a4,94e <malloc+0xa6>
        p->s.size -= nunits;
 91c:	4137073b          	subw	a4,a4,s3
 920:	c798                	sw	a4,8(a5)
        p += p->s.size;
 922:	1702                	slli	a4,a4,0x20
 924:	9301                	srli	a4,a4,0x20
 926:	0712                	slli	a4,a4,0x4
 928:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 92a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 92e:	00000717          	auipc	a4,0x0
 932:	6ca73923          	sd	a0,1746(a4) # 1000 <freep>
      return (void*)(p + 1);
 936:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 93a:	70e2                	ld	ra,56(sp)
 93c:	7442                	ld	s0,48(sp)
 93e:	74a2                	ld	s1,40(sp)
 940:	7902                	ld	s2,32(sp)
 942:	69e2                	ld	s3,24(sp)
 944:	6a42                	ld	s4,16(sp)
 946:	6aa2                	ld	s5,8(sp)
 948:	6b02                	ld	s6,0(sp)
 94a:	6121                	addi	sp,sp,64
 94c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 94e:	6398                	ld	a4,0(a5)
 950:	e118                	sd	a4,0(a0)
 952:	bff1                	j	92e <malloc+0x86>
  hp->s.size = nu;
 954:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 958:	0541                	addi	a0,a0,16
 95a:	ec7ff0ef          	jal	ra,820 <free>
  return freep;
 95e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 962:	dd61                	beqz	a0,93a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 964:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 966:	4798                	lw	a4,8(a5)
 968:	fa9778e3          	bgeu	a4,s1,918 <malloc+0x70>
    if(p == freep)
 96c:	00093703          	ld	a4,0(s2)
 970:	853e                	mv	a0,a5
 972:	fef719e3          	bne	a4,a5,964 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 976:	8552                	mv	a0,s4
 978:	9c9ff0ef          	jal	ra,340 <sbrk>
  if(p == SBRK_ERROR)
 97c:	fd551ce3          	bne	a0,s5,954 <malloc+0xac>
        return 0;
 980:	4501                	li	a0,0
 982:	bf65                	j	93a <malloc+0x92>

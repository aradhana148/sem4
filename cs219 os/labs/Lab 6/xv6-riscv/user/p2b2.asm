
user/_p2b2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
    int pid = fork();
   a:	3ca000ef          	jal	ra,3d4 <fork>
    if (pid < 0) {
   e:	02054a63          	bltz	a0,42 <main+0x42>
        printf("fork failed\n");
        exit(1);
    }

    if (pid == 0) {
  12:	e545                	bnez	a0,ba <main+0xba>
        if (shm_init() < 0) {
  14:	480000ef          	jal	ra,494 <shm_init>
  18:	02054e63          	bltz	a0,54 <main+0x54>
            printf("[Child] shm_init failed\n");
            exit(1);
        }
        printf("[Child] shm_init succeeded\n");
  1c:	00001517          	auipc	a0,0x1
  20:	9e450513          	addi	a0,a0,-1564 # a00 <malloc+0x10e>
  24:	015000ef          	jal	ra,838 <printf>

        char* p = (char*)shm_attach();
  28:	474000ef          	jal	ra,49c <shm_attach>
  2c:	84aa                	mv	s1,a0
        if (p == 0) {
  2e:	ed05                	bnez	a0,66 <main+0x66>
            printf("[Child] shm_attach failed\n");
  30:	00001517          	auipc	a0,0x1
  34:	9f050513          	addi	a0,a0,-1552 # a20 <malloc+0x12e>
  38:	001000ef          	jal	ra,838 <printf>
            exit(1);
  3c:	4505                	li	a0,1
  3e:	39e000ef          	jal	ra,3dc <exit>
        printf("fork failed\n");
  42:	00001517          	auipc	a0,0x1
  46:	98e50513          	addi	a0,a0,-1650 # 9d0 <malloc+0xde>
  4a:	7ee000ef          	jal	ra,838 <printf>
        exit(1);
  4e:	4505                	li	a0,1
  50:	38c000ef          	jal	ra,3dc <exit>
            printf("[Child] shm_init failed\n");
  54:	00001517          	auipc	a0,0x1
  58:	98c50513          	addi	a0,a0,-1652 # 9e0 <malloc+0xee>
  5c:	7dc000ef          	jal	ra,838 <printf>
            exit(1);
  60:	4505                	li	a0,1
  62:	37a000ef          	jal	ra,3dc <exit>
        }
        printf("[Child] shm_attach succeeded\n");
  66:	00001517          	auipc	a0,0x1
  6a:	9da50513          	addi	a0,a0,-1574 # a40 <malloc+0x14e>
  6e:	7ca000ef          	jal	ra,838 <printf>

        strcpy(p, "Message from child");
  72:	00001597          	auipc	a1,0x1
  76:	9ee58593          	addi	a1,a1,-1554 # a60 <malloc+0x16e>
  7a:	8526                	mv	a0,s1
  7c:	0da000ef          	jal	ra,156 <strcpy>
        printf("[Child] wrote: %s\n", p);
  80:	85a6                	mv	a1,s1
  82:	00001517          	auipc	a0,0x1
  86:	9f650513          	addi	a0,a0,-1546 # a78 <malloc+0x186>
  8a:	7ae000ef          	jal	ra,838 <printf>

        if (shm_detach() < 0) {
  8e:	416000ef          	jal	ra,4a4 <shm_detach>
  92:	00054b63          	bltz	a0,a8 <main+0xa8>
            printf("[Child] shm_detach failed\n");
            exit(1);
        }
        printf("[Child] shm_detach succeeded\n");
  96:	00001517          	auipc	a0,0x1
  9a:	a1a50513          	addi	a0,a0,-1510 # ab0 <malloc+0x1be>
  9e:	79a000ef          	jal	ra,838 <printf>

        exit(0);
  a2:	4501                	li	a0,0
  a4:	338000ef          	jal	ra,3dc <exit>
            printf("[Child] shm_detach failed\n");
  a8:	00001517          	auipc	a0,0x1
  ac:	9e850513          	addi	a0,a0,-1560 # a90 <malloc+0x19e>
  b0:	788000ef          	jal	ra,838 <printf>
            exit(1);
  b4:	4505                	li	a0,1
  b6:	326000ef          	jal	ra,3dc <exit>
    } else {
        wait(0);
  ba:	4501                	li	a0,0
  bc:	328000ef          	jal	ra,3e4 <wait>

        char* p = (char*)shm_attach();
  c0:	3dc000ef          	jal	ra,49c <shm_attach>
  c4:	84aa                	mv	s1,a0
        if (p == 0) {
  c6:	e911                	bnez	a0,da <main+0xda>
            printf("[Parent] shm_attach failed\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	a0850513          	addi	a0,a0,-1528 # ad0 <malloc+0x1de>
  d0:	768000ef          	jal	ra,838 <printf>
            exit(1);
  d4:	4505                	li	a0,1
  d6:	306000ef          	jal	ra,3dc <exit>
        }
        printf("[Parent] shm_attach succeeded\n");
  da:	00001517          	auipc	a0,0x1
  de:	a1650513          	addi	a0,a0,-1514 # af0 <malloc+0x1fe>
  e2:	756000ef          	jal	ra,838 <printf>

        printf("[Parent] reads: %s\n", p);
  e6:	85a6                	mv	a1,s1
  e8:	00001517          	auipc	a0,0x1
  ec:	a2850513          	addi	a0,a0,-1496 # b10 <malloc+0x21e>
  f0:	748000ef          	jal	ra,838 <printf>

        if (shm_detach() < 0) {
  f4:	3b0000ef          	jal	ra,4a4 <shm_detach>
  f8:	02054563          	bltz	a0,122 <main+0x122>
            printf("[Parent] shm_detach failed\n");
            exit(1);
        }
        printf("[Parent] shm_detach succeeded\n");
  fc:	00001517          	auipc	a0,0x1
 100:	a4c50513          	addi	a0,a0,-1460 # b48 <malloc+0x256>
 104:	734000ef          	jal	ra,838 <printf>

        if (shm_destroy() < 0) {
 108:	3a4000ef          	jal	ra,4ac <shm_destroy>
 10c:	02054463          	bltz	a0,134 <main+0x134>
            printf("[Parent] shm_destroy failed\n");
            exit(1);
        }
        printf("[Parent] shm_destroy succeeded\n");
 110:	00001517          	auipc	a0,0x1
 114:	a7850513          	addi	a0,a0,-1416 # b88 <malloc+0x296>
 118:	720000ef          	jal	ra,838 <printf>

        exit(0);
 11c:	4501                	li	a0,0
 11e:	2be000ef          	jal	ra,3dc <exit>
            printf("[Parent] shm_detach failed\n");
 122:	00001517          	auipc	a0,0x1
 126:	a0650513          	addi	a0,a0,-1530 # b28 <malloc+0x236>
 12a:	70e000ef          	jal	ra,838 <printf>
            exit(1);
 12e:	4505                	li	a0,1
 130:	2ac000ef          	jal	ra,3dc <exit>
            printf("[Parent] shm_destroy failed\n");
 134:	00001517          	auipc	a0,0x1
 138:	a3450513          	addi	a0,a0,-1484 # b68 <malloc+0x276>
 13c:	6fc000ef          	jal	ra,838 <printf>
            exit(1);
 140:	4505                	li	a0,1
 142:	29a000ef          	jal	ra,3dc <exit>

0000000000000146 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 146:	1141                	addi	sp,sp,-16
 148:	e406                	sd	ra,8(sp)
 14a:	e022                	sd	s0,0(sp)
 14c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 14e:	eb3ff0ef          	jal	ra,0 <main>
  exit(r);
 152:	28a000ef          	jal	ra,3dc <exit>

0000000000000156 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 156:	1141                	addi	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 15c:	87aa                	mv	a5,a0
 15e:	0585                	addi	a1,a1,1
 160:	0785                	addi	a5,a5,1
 162:	fff5c703          	lbu	a4,-1(a1)
 166:	fee78fa3          	sb	a4,-1(a5)
 16a:	fb75                	bnez	a4,15e <strcpy+0x8>
    ;
  return os;
}
 16c:	6422                	ld	s0,8(sp)
 16e:	0141                	addi	sp,sp,16
 170:	8082                	ret

0000000000000172 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 172:	1141                	addi	sp,sp,-16
 174:	e422                	sd	s0,8(sp)
 176:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 178:	00054783          	lbu	a5,0(a0)
 17c:	cb91                	beqz	a5,190 <strcmp+0x1e>
 17e:	0005c703          	lbu	a4,0(a1)
 182:	00f71763          	bne	a4,a5,190 <strcmp+0x1e>
    p++, q++;
 186:	0505                	addi	a0,a0,1
 188:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 18a:	00054783          	lbu	a5,0(a0)
 18e:	fbe5                	bnez	a5,17e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 190:	0005c503          	lbu	a0,0(a1)
}
 194:	40a7853b          	subw	a0,a5,a0
 198:	6422                	ld	s0,8(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret

000000000000019e <strlen>:

uint
strlen(const char *s)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	cf91                	beqz	a5,1c4 <strlen+0x26>
 1aa:	0505                	addi	a0,a0,1
 1ac:	87aa                	mv	a5,a0
 1ae:	4685                	li	a3,1
 1b0:	9e89                	subw	a3,a3,a0
 1b2:	00f6853b          	addw	a0,a3,a5
 1b6:	0785                	addi	a5,a5,1
 1b8:	fff7c703          	lbu	a4,-1(a5)
 1bc:	fb7d                	bnez	a4,1b2 <strlen+0x14>
    ;
  return n;
}
 1be:	6422                	ld	s0,8(sp)
 1c0:	0141                	addi	sp,sp,16
 1c2:	8082                	ret
  for(n = 0; s[n]; n++)
 1c4:	4501                	li	a0,0
 1c6:	bfe5                	j	1be <strlen+0x20>

00000000000001c8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e422                	sd	s0,8(sp)
 1cc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ce:	ca19                	beqz	a2,1e4 <memset+0x1c>
 1d0:	87aa                	mv	a5,a0
 1d2:	1602                	slli	a2,a2,0x20
 1d4:	9201                	srli	a2,a2,0x20
 1d6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1da:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1de:	0785                	addi	a5,a5,1
 1e0:	fee79de3          	bne	a5,a4,1da <memset+0x12>
  }
  return dst;
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strchr>:

char*
strchr(const char *s, char c)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	cb99                	beqz	a5,20a <strchr+0x20>
    if(*s == c)
 1f6:	00f58763          	beq	a1,a5,204 <strchr+0x1a>
  for(; *s; s++)
 1fa:	0505                	addi	a0,a0,1
 1fc:	00054783          	lbu	a5,0(a0)
 200:	fbfd                	bnez	a5,1f6 <strchr+0xc>
      return (char*)s;
  return 0;
 202:	4501                	li	a0,0
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret
  return 0;
 20a:	4501                	li	a0,0
 20c:	bfe5                	j	204 <strchr+0x1a>

000000000000020e <gets>:

char*
gets(char *buf, int max)
{
 20e:	711d                	addi	sp,sp,-96
 210:	ec86                	sd	ra,88(sp)
 212:	e8a2                	sd	s0,80(sp)
 214:	e4a6                	sd	s1,72(sp)
 216:	e0ca                	sd	s2,64(sp)
 218:	fc4e                	sd	s3,56(sp)
 21a:	f852                	sd	s4,48(sp)
 21c:	f456                	sd	s5,40(sp)
 21e:	f05a                	sd	s6,32(sp)
 220:	ec5e                	sd	s7,24(sp)
 222:	1080                	addi	s0,sp,96
 224:	8baa                	mv	s7,a0
 226:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 228:	892a                	mv	s2,a0
 22a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 22c:	4aa9                	li	s5,10
 22e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 230:	89a6                	mv	s3,s1
 232:	2485                	addiw	s1,s1,1
 234:	0344d663          	bge	s1,s4,260 <gets+0x52>
    cc = read(0, &c, 1);
 238:	4605                	li	a2,1
 23a:	faf40593          	addi	a1,s0,-81
 23e:	4501                	li	a0,0
 240:	1b4000ef          	jal	ra,3f4 <read>
    if(cc < 1)
 244:	00a05e63          	blez	a0,260 <gets+0x52>
    buf[i++] = c;
 248:	faf44783          	lbu	a5,-81(s0)
 24c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 250:	01578763          	beq	a5,s5,25e <gets+0x50>
 254:	0905                	addi	s2,s2,1
 256:	fd679de3          	bne	a5,s6,230 <gets+0x22>
  for(i=0; i+1 < max; ){
 25a:	89a6                	mv	s3,s1
 25c:	a011                	j	260 <gets+0x52>
 25e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 260:	99de                	add	s3,s3,s7
 262:	00098023          	sb	zero,0(s3)
  return buf;
}
 266:	855e                	mv	a0,s7
 268:	60e6                	ld	ra,88(sp)
 26a:	6446                	ld	s0,80(sp)
 26c:	64a6                	ld	s1,72(sp)
 26e:	6906                	ld	s2,64(sp)
 270:	79e2                	ld	s3,56(sp)
 272:	7a42                	ld	s4,48(sp)
 274:	7aa2                	ld	s5,40(sp)
 276:	7b02                	ld	s6,32(sp)
 278:	6be2                	ld	s7,24(sp)
 27a:	6125                	addi	sp,sp,96
 27c:	8082                	ret

000000000000027e <stat>:

int
stat(const char *n, struct stat *st)
{
 27e:	1101                	addi	sp,sp,-32
 280:	ec06                	sd	ra,24(sp)
 282:	e822                	sd	s0,16(sp)
 284:	e426                	sd	s1,8(sp)
 286:	e04a                	sd	s2,0(sp)
 288:	1000                	addi	s0,sp,32
 28a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28c:	4581                	li	a1,0
 28e:	18e000ef          	jal	ra,41c <open>
  if(fd < 0)
 292:	02054163          	bltz	a0,2b4 <stat+0x36>
 296:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 298:	85ca                	mv	a1,s2
 29a:	19a000ef          	jal	ra,434 <fstat>
 29e:	892a                	mv	s2,a0
  close(fd);
 2a0:	8526                	mv	a0,s1
 2a2:	162000ef          	jal	ra,404 <close>
  return r;
}
 2a6:	854a                	mv	a0,s2
 2a8:	60e2                	ld	ra,24(sp)
 2aa:	6442                	ld	s0,16(sp)
 2ac:	64a2                	ld	s1,8(sp)
 2ae:	6902                	ld	s2,0(sp)
 2b0:	6105                	addi	sp,sp,32
 2b2:	8082                	ret
    return -1;
 2b4:	597d                	li	s2,-1
 2b6:	bfc5                	j	2a6 <stat+0x28>

00000000000002b8 <atoi>:

int
atoi(const char *s)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2be:	00054603          	lbu	a2,0(a0)
 2c2:	fd06079b          	addiw	a5,a2,-48
 2c6:	0ff7f793          	andi	a5,a5,255
 2ca:	4725                	li	a4,9
 2cc:	02f76963          	bltu	a4,a5,2fe <atoi+0x46>
 2d0:	86aa                	mv	a3,a0
  n = 0;
 2d2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2d4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2d6:	0685                	addi	a3,a3,1
 2d8:	0025179b          	slliw	a5,a0,0x2
 2dc:	9fa9                	addw	a5,a5,a0
 2de:	0017979b          	slliw	a5,a5,0x1
 2e2:	9fb1                	addw	a5,a5,a2
 2e4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2e8:	0006c603          	lbu	a2,0(a3)
 2ec:	fd06071b          	addiw	a4,a2,-48
 2f0:	0ff77713          	andi	a4,a4,255
 2f4:	fee5f1e3          	bgeu	a1,a4,2d6 <atoi+0x1e>
  return n;
}
 2f8:	6422                	ld	s0,8(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret
  n = 0;
 2fe:	4501                	li	a0,0
 300:	bfe5                	j	2f8 <atoi+0x40>

0000000000000302 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 302:	1141                	addi	sp,sp,-16
 304:	e422                	sd	s0,8(sp)
 306:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 308:	02b57463          	bgeu	a0,a1,330 <memmove+0x2e>
    while(n-- > 0)
 30c:	00c05f63          	blez	a2,32a <memmove+0x28>
 310:	1602                	slli	a2,a2,0x20
 312:	9201                	srli	a2,a2,0x20
 314:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 318:	872a                	mv	a4,a0
      *dst++ = *src++;
 31a:	0585                	addi	a1,a1,1
 31c:	0705                	addi	a4,a4,1
 31e:	fff5c683          	lbu	a3,-1(a1)
 322:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 326:	fee79ae3          	bne	a5,a4,31a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
    dst += n;
 330:	00c50733          	add	a4,a0,a2
    src += n;
 334:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 336:	fec05ae3          	blez	a2,32a <memmove+0x28>
 33a:	fff6079b          	addiw	a5,a2,-1
 33e:	1782                	slli	a5,a5,0x20
 340:	9381                	srli	a5,a5,0x20
 342:	fff7c793          	not	a5,a5
 346:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 348:	15fd                	addi	a1,a1,-1
 34a:	177d                	addi	a4,a4,-1
 34c:	0005c683          	lbu	a3,0(a1)
 350:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 354:	fee79ae3          	bne	a5,a4,348 <memmove+0x46>
 358:	bfc9                	j	32a <memmove+0x28>

000000000000035a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e422                	sd	s0,8(sp)
 35e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 360:	ca05                	beqz	a2,390 <memcmp+0x36>
 362:	fff6069b          	addiw	a3,a2,-1
 366:	1682                	slli	a3,a3,0x20
 368:	9281                	srli	a3,a3,0x20
 36a:	0685                	addi	a3,a3,1
 36c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 36e:	00054783          	lbu	a5,0(a0)
 372:	0005c703          	lbu	a4,0(a1)
 376:	00e79863          	bne	a5,a4,386 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 37a:	0505                	addi	a0,a0,1
    p2++;
 37c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 37e:	fed518e3          	bne	a0,a3,36e <memcmp+0x14>
  }
  return 0;
 382:	4501                	li	a0,0
 384:	a019                	j	38a <memcmp+0x30>
      return *p1 - *p2;
 386:	40e7853b          	subw	a0,a5,a4
}
 38a:	6422                	ld	s0,8(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret
  return 0;
 390:	4501                	li	a0,0
 392:	bfe5                	j	38a <memcmp+0x30>

0000000000000394 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 394:	1141                	addi	sp,sp,-16
 396:	e406                	sd	ra,8(sp)
 398:	e022                	sd	s0,0(sp)
 39a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 39c:	f67ff0ef          	jal	ra,302 <memmove>
}
 3a0:	60a2                	ld	ra,8(sp)
 3a2:	6402                	ld	s0,0(sp)
 3a4:	0141                	addi	sp,sp,16
 3a6:	8082                	ret

00000000000003a8 <sbrk>:

char *
sbrk(int n) {
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e406                	sd	ra,8(sp)
 3ac:	e022                	sd	s0,0(sp)
 3ae:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3b0:	4585                	li	a1,1
 3b2:	0b2000ef          	jal	ra,464 <sys_sbrk>
}
 3b6:	60a2                	ld	ra,8(sp)
 3b8:	6402                	ld	s0,0(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret

00000000000003be <sbrklazy>:

char *
sbrklazy(int n) {
 3be:	1141                	addi	sp,sp,-16
 3c0:	e406                	sd	ra,8(sp)
 3c2:	e022                	sd	s0,0(sp)
 3c4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3c6:	4589                	li	a1,2
 3c8:	09c000ef          	jal	ra,464 <sys_sbrk>
}
 3cc:	60a2                	ld	ra,8(sp)
 3ce:	6402                	ld	s0,0(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret

00000000000003d4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d4:	4885                	li	a7,1
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3dc:	4889                	li	a7,2
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e4:	488d                	li	a7,3
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ec:	4891                	li	a7,4
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <read>:
.global read
read:
 li a7, SYS_read
 3f4:	4895                	li	a7,5
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <write>:
.global write
write:
 li a7, SYS_write
 3fc:	48c1                	li	a7,16
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <close>:
.global close
close:
 li a7, SYS_close
 404:	48d5                	li	a7,21
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <kill>:
.global kill
kill:
 li a7, SYS_kill
 40c:	4899                	li	a7,6
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <exec>:
.global exec
exec:
 li a7, SYS_exec
 414:	489d                	li	a7,7
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <open>:
.global open
open:
 li a7, SYS_open
 41c:	48bd                	li	a7,15
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 424:	48c5                	li	a7,17
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 42c:	48c9                	li	a7,18
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 434:	48a1                	li	a7,8
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <link>:
.global link
link:
 li a7, SYS_link
 43c:	48cd                	li	a7,19
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 444:	48d1                	li	a7,20
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 44c:	48a5                	li	a7,9
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <dup>:
.global dup
dup:
 li a7, SYS_dup
 454:	48a9                	li	a7,10
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 45c:	48ad                	li	a7,11
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 464:	48b1                	li	a7,12
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <pause>:
.global pause
pause:
 li a7, SYS_pause
 46c:	48b5                	li	a7,13
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 474:	48b9                	li	a7,14
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <tfork>:
.global tfork
tfork:
 li a7, SYS_tfork
 47c:	48d9                	li	a7,22
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 484:	48dd                	li	a7,23
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <tfork2>:
.global tfork2
tfork2:
 li a7, SYS_tfork2
 48c:	48e1                	li	a7,24
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <shm_init>:
.global shm_init
shm_init:
 li a7, SYS_shm_init
 494:	48e5                	li	a7,25
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <shm_attach>:
.global shm_attach
shm_attach:
 li a7, SYS_shm_attach
 49c:	48e9                	li	a7,26
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <shm_detach>:
.global shm_detach
shm_detach:
 li a7, SYS_shm_detach
 4a4:	48ed                	li	a7,27
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <shm_destroy>:
.global shm_destroy
shm_destroy:
 li a7, SYS_shm_destroy
 4ac:	48f1                	li	a7,28
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <shm_refcount>:
.global shm_refcount
shm_refcount:
 li a7, SYS_shm_refcount
 4b4:	48f5                	li	a7,29
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4bc:	1101                	addi	sp,sp,-32
 4be:	ec06                	sd	ra,24(sp)
 4c0:	e822                	sd	s0,16(sp)
 4c2:	1000                	addi	s0,sp,32
 4c4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c8:	4605                	li	a2,1
 4ca:	fef40593          	addi	a1,s0,-17
 4ce:	f2fff0ef          	jal	ra,3fc <write>
}
 4d2:	60e2                	ld	ra,24(sp)
 4d4:	6442                	ld	s0,16(sp)
 4d6:	6105                	addi	sp,sp,32
 4d8:	8082                	ret

00000000000004da <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4da:	715d                	addi	sp,sp,-80
 4dc:	e486                	sd	ra,72(sp)
 4de:	e0a2                	sd	s0,64(sp)
 4e0:	fc26                	sd	s1,56(sp)
 4e2:	f84a                	sd	s2,48(sp)
 4e4:	f44e                	sd	s3,40(sp)
 4e6:	0880                	addi	s0,sp,80
 4e8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4ea:	c299                	beqz	a3,4f0 <printint+0x16>
 4ec:	0805c163          	bltz	a1,56e <printint+0x94>
  neg = 0;
 4f0:	4881                	li	a7,0
 4f2:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4f6:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4f8:	00000517          	auipc	a0,0x0
 4fc:	6b850513          	addi	a0,a0,1720 # bb0 <digits>
 500:	883e                	mv	a6,a5
 502:	2785                	addiw	a5,a5,1
 504:	02c5f733          	remu	a4,a1,a2
 508:	972a                	add	a4,a4,a0
 50a:	00074703          	lbu	a4,0(a4)
 50e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 512:	872e                	mv	a4,a1
 514:	02c5d5b3          	divu	a1,a1,a2
 518:	0685                	addi	a3,a3,1
 51a:	fec773e3          	bgeu	a4,a2,500 <printint+0x26>
  if(neg)
 51e:	00088b63          	beqz	a7,534 <printint+0x5a>
    buf[i++] = '-';
 522:	fd040713          	addi	a4,s0,-48
 526:	97ba                	add	a5,a5,a4
 528:	02d00713          	li	a4,45
 52c:	fee78423          	sb	a4,-24(a5)
 530:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 534:	02f05663          	blez	a5,560 <printint+0x86>
 538:	fb840713          	addi	a4,s0,-72
 53c:	00f704b3          	add	s1,a4,a5
 540:	fff70993          	addi	s3,a4,-1
 544:	99be                	add	s3,s3,a5
 546:	37fd                	addiw	a5,a5,-1
 548:	1782                	slli	a5,a5,0x20
 54a:	9381                	srli	a5,a5,0x20
 54c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 550:	fff4c583          	lbu	a1,-1(s1)
 554:	854a                	mv	a0,s2
 556:	f67ff0ef          	jal	ra,4bc <putc>
  while(--i >= 0)
 55a:	14fd                	addi	s1,s1,-1
 55c:	ff349ae3          	bne	s1,s3,550 <printint+0x76>
}
 560:	60a6                	ld	ra,72(sp)
 562:	6406                	ld	s0,64(sp)
 564:	74e2                	ld	s1,56(sp)
 566:	7942                	ld	s2,48(sp)
 568:	79a2                	ld	s3,40(sp)
 56a:	6161                	addi	sp,sp,80
 56c:	8082                	ret
    x = -xx;
 56e:	40b005b3          	neg	a1,a1
    neg = 1;
 572:	4885                	li	a7,1
    x = -xx;
 574:	bfbd                	j	4f2 <printint+0x18>

0000000000000576 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 576:	7119                	addi	sp,sp,-128
 578:	fc86                	sd	ra,120(sp)
 57a:	f8a2                	sd	s0,112(sp)
 57c:	f4a6                	sd	s1,104(sp)
 57e:	f0ca                	sd	s2,96(sp)
 580:	ecce                	sd	s3,88(sp)
 582:	e8d2                	sd	s4,80(sp)
 584:	e4d6                	sd	s5,72(sp)
 586:	e0da                	sd	s6,64(sp)
 588:	fc5e                	sd	s7,56(sp)
 58a:	f862                	sd	s8,48(sp)
 58c:	f466                	sd	s9,40(sp)
 58e:	f06a                	sd	s10,32(sp)
 590:	ec6e                	sd	s11,24(sp)
 592:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 594:	0005c903          	lbu	s2,0(a1)
 598:	24090c63          	beqz	s2,7f0 <vprintf+0x27a>
 59c:	8b2a                	mv	s6,a0
 59e:	8a2e                	mv	s4,a1
 5a0:	8bb2                	mv	s7,a2
  state = 0;
 5a2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5a4:	4481                	li	s1,0
 5a6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5a8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5ac:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5b0:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5b4:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b8:	00000c97          	auipc	s9,0x0
 5bc:	5f8c8c93          	addi	s9,s9,1528 # bb0 <digits>
 5c0:	a005                	j	5e0 <vprintf+0x6a>
        putc(fd, c0);
 5c2:	85ca                	mv	a1,s2
 5c4:	855a                	mv	a0,s6
 5c6:	ef7ff0ef          	jal	ra,4bc <putc>
 5ca:	a019                	j	5d0 <vprintf+0x5a>
    } else if(state == '%'){
 5cc:	03598263          	beq	s3,s5,5f0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5d0:	2485                	addiw	s1,s1,1
 5d2:	8726                	mv	a4,s1
 5d4:	009a07b3          	add	a5,s4,s1
 5d8:	0007c903          	lbu	s2,0(a5)
 5dc:	20090a63          	beqz	s2,7f0 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5e0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e4:	fe0994e3          	bnez	s3,5cc <vprintf+0x56>
      if(c0 == '%'){
 5e8:	fd579de3          	bne	a5,s5,5c2 <vprintf+0x4c>
        state = '%';
 5ec:	89be                	mv	s3,a5
 5ee:	b7cd                	j	5d0 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5f0:	c3c1                	beqz	a5,670 <vprintf+0xfa>
 5f2:	00ea06b3          	add	a3,s4,a4
 5f6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5fa:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5fc:	c681                	beqz	a3,604 <vprintf+0x8e>
 5fe:	9752                	add	a4,a4,s4
 600:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 604:	03878e63          	beq	a5,s8,640 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 608:	05a78863          	beq	a5,s10,658 <vprintf+0xe2>
      } else if(c0 == 'u'){
 60c:	0db78b63          	beq	a5,s11,6e2 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 610:	07800713          	li	a4,120
 614:	10e78d63          	beq	a5,a4,72e <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 618:	07000713          	li	a4,112
 61c:	14e78263          	beq	a5,a4,760 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 620:	06300713          	li	a4,99
 624:	16e78f63          	beq	a5,a4,7a2 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 628:	07300713          	li	a4,115
 62c:	18e78563          	beq	a5,a4,7b6 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 630:	05579063          	bne	a5,s5,670 <vprintf+0xfa>
        putc(fd, '%');
 634:	85d6                	mv	a1,s5
 636:	855a                	mv	a0,s6
 638:	e85ff0ef          	jal	ra,4bc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 63c:	4981                	li	s3,0
 63e:	bf49                	j	5d0 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 640:	008b8913          	addi	s2,s7,8
 644:	4685                	li	a3,1
 646:	4629                	li	a2,10
 648:	000ba583          	lw	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e8dff0ef          	jal	ra,4da <printint>
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
 656:	bfad                	j	5d0 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 658:	03868663          	beq	a3,s8,684 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 65c:	05a68163          	beq	a3,s10,69e <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 660:	09b68d63          	beq	a3,s11,6fa <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 664:	03a68f63          	beq	a3,s10,6a2 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 668:	07800793          	li	a5,120
 66c:	0cf68d63          	beq	a3,a5,746 <vprintf+0x1d0>
        putc(fd, '%');
 670:	85d6                	mv	a1,s5
 672:	855a                	mv	a0,s6
 674:	e49ff0ef          	jal	ra,4bc <putc>
        putc(fd, c0);
 678:	85ca                	mv	a1,s2
 67a:	855a                	mv	a0,s6
 67c:	e41ff0ef          	jal	ra,4bc <putc>
      state = 0;
 680:	4981                	li	s3,0
 682:	b7b9                	j	5d0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 684:	008b8913          	addi	s2,s7,8
 688:	4685                	li	a3,1
 68a:	4629                	li	a2,10
 68c:	000bb583          	ld	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	e49ff0ef          	jal	ra,4da <printint>
        i += 1;
 696:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
        i += 1;
 69c:	bf15                	j	5d0 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 69e:	03860563          	beq	a2,s8,6c8 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6a2:	07b60963          	beq	a2,s11,714 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6a6:	07800793          	li	a5,120
 6aa:	fcf613e3          	bne	a2,a5,670 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4641                	li	a2,16
 6b6:	000bb583          	ld	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	e1fff0ef          	jal	ra,4da <printint>
        i += 2;
 6c0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c2:	8bca                	mv	s7,s2
      state = 0;
 6c4:	4981                	li	s3,0
        i += 2;
 6c6:	b729                	j	5d0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c8:	008b8913          	addi	s2,s7,8
 6cc:	4685                	li	a3,1
 6ce:	4629                	li	a2,10
 6d0:	000bb583          	ld	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	e05ff0ef          	jal	ra,4da <printint>
        i += 2;
 6da:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6dc:	8bca                	mv	s7,s2
      state = 0;
 6de:	4981                	li	s3,0
        i += 2;
 6e0:	bdc5                	j	5d0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6e2:	008b8913          	addi	s2,s7,8
 6e6:	4681                	li	a3,0
 6e8:	4629                	li	a2,10
 6ea:	000be583          	lwu	a1,0(s7)
 6ee:	855a                	mv	a0,s6
 6f0:	debff0ef          	jal	ra,4da <printint>
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bde1                	j	5d0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fa:	008b8913          	addi	s2,s7,8
 6fe:	4681                	li	a3,0
 700:	4629                	li	a2,10
 702:	000bb583          	ld	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	dd3ff0ef          	jal	ra,4da <printint>
        i += 1;
 70c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 70e:	8bca                	mv	s7,s2
      state = 0;
 710:	4981                	li	s3,0
        i += 1;
 712:	bd7d                	j	5d0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 714:	008b8913          	addi	s2,s7,8
 718:	4681                	li	a3,0
 71a:	4629                	li	a2,10
 71c:	000bb583          	ld	a1,0(s7)
 720:	855a                	mv	a0,s6
 722:	db9ff0ef          	jal	ra,4da <printint>
        i += 2;
 726:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 728:	8bca                	mv	s7,s2
      state = 0;
 72a:	4981                	li	s3,0
        i += 2;
 72c:	b555                	j	5d0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 72e:	008b8913          	addi	s2,s7,8
 732:	4681                	li	a3,0
 734:	4641                	li	a2,16
 736:	000be583          	lwu	a1,0(s7)
 73a:	855a                	mv	a0,s6
 73c:	d9fff0ef          	jal	ra,4da <printint>
 740:	8bca                	mv	s7,s2
      state = 0;
 742:	4981                	li	s3,0
 744:	b571                	j	5d0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 746:	008b8913          	addi	s2,s7,8
 74a:	4681                	li	a3,0
 74c:	4641                	li	a2,16
 74e:	000bb583          	ld	a1,0(s7)
 752:	855a                	mv	a0,s6
 754:	d87ff0ef          	jal	ra,4da <printint>
        i += 1;
 758:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 75a:	8bca                	mv	s7,s2
      state = 0;
 75c:	4981                	li	s3,0
        i += 1;
 75e:	bd8d                	j	5d0 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 760:	008b8793          	addi	a5,s7,8
 764:	f8f43423          	sd	a5,-120(s0)
 768:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 76c:	03000593          	li	a1,48
 770:	855a                	mv	a0,s6
 772:	d4bff0ef          	jal	ra,4bc <putc>
  putc(fd, 'x');
 776:	07800593          	li	a1,120
 77a:	855a                	mv	a0,s6
 77c:	d41ff0ef          	jal	ra,4bc <putc>
 780:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 782:	03c9d793          	srli	a5,s3,0x3c
 786:	97e6                	add	a5,a5,s9
 788:	0007c583          	lbu	a1,0(a5)
 78c:	855a                	mv	a0,s6
 78e:	d2fff0ef          	jal	ra,4bc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 792:	0992                	slli	s3,s3,0x4
 794:	397d                	addiw	s2,s2,-1
 796:	fe0916e3          	bnez	s2,782 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 79a:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	bd05                	j	5d0 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 7a2:	008b8913          	addi	s2,s7,8
 7a6:	000bc583          	lbu	a1,0(s7)
 7aa:	855a                	mv	a0,s6
 7ac:	d11ff0ef          	jal	ra,4bc <putc>
 7b0:	8bca                	mv	s7,s2
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	bd31                	j	5d0 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7b6:	008b8993          	addi	s3,s7,8
 7ba:	000bb903          	ld	s2,0(s7)
 7be:	00090f63          	beqz	s2,7dc <vprintf+0x266>
        for(; *s; s++)
 7c2:	00094583          	lbu	a1,0(s2)
 7c6:	c195                	beqz	a1,7ea <vprintf+0x274>
          putc(fd, *s);
 7c8:	855a                	mv	a0,s6
 7ca:	cf3ff0ef          	jal	ra,4bc <putc>
        for(; *s; s++)
 7ce:	0905                	addi	s2,s2,1
 7d0:	00094583          	lbu	a1,0(s2)
 7d4:	f9f5                	bnez	a1,7c8 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7d6:	8bce                	mv	s7,s3
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	bbdd                	j	5d0 <vprintf+0x5a>
          s = "(null)";
 7dc:	00000917          	auipc	s2,0x0
 7e0:	3cc90913          	addi	s2,s2,972 # ba8 <malloc+0x2b6>
        for(; *s; s++)
 7e4:	02800593          	li	a1,40
 7e8:	b7c5                	j	7c8 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7ea:	8bce                	mv	s7,s3
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	b3cd                	j	5d0 <vprintf+0x5a>
    }
  }
}
 7f0:	70e6                	ld	ra,120(sp)
 7f2:	7446                	ld	s0,112(sp)
 7f4:	74a6                	ld	s1,104(sp)
 7f6:	7906                	ld	s2,96(sp)
 7f8:	69e6                	ld	s3,88(sp)
 7fa:	6a46                	ld	s4,80(sp)
 7fc:	6aa6                	ld	s5,72(sp)
 7fe:	6b06                	ld	s6,64(sp)
 800:	7be2                	ld	s7,56(sp)
 802:	7c42                	ld	s8,48(sp)
 804:	7ca2                	ld	s9,40(sp)
 806:	7d02                	ld	s10,32(sp)
 808:	6de2                	ld	s11,24(sp)
 80a:	6109                	addi	sp,sp,128
 80c:	8082                	ret

000000000000080e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 80e:	715d                	addi	sp,sp,-80
 810:	ec06                	sd	ra,24(sp)
 812:	e822                	sd	s0,16(sp)
 814:	1000                	addi	s0,sp,32
 816:	e010                	sd	a2,0(s0)
 818:	e414                	sd	a3,8(s0)
 81a:	e818                	sd	a4,16(s0)
 81c:	ec1c                	sd	a5,24(s0)
 81e:	03043023          	sd	a6,32(s0)
 822:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 826:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 82a:	8622                	mv	a2,s0
 82c:	d4bff0ef          	jal	ra,576 <vprintf>
}
 830:	60e2                	ld	ra,24(sp)
 832:	6442                	ld	s0,16(sp)
 834:	6161                	addi	sp,sp,80
 836:	8082                	ret

0000000000000838 <printf>:

void
printf(const char *fmt, ...)
{
 838:	711d                	addi	sp,sp,-96
 83a:	ec06                	sd	ra,24(sp)
 83c:	e822                	sd	s0,16(sp)
 83e:	1000                	addi	s0,sp,32
 840:	e40c                	sd	a1,8(s0)
 842:	e810                	sd	a2,16(s0)
 844:	ec14                	sd	a3,24(s0)
 846:	f018                	sd	a4,32(s0)
 848:	f41c                	sd	a5,40(s0)
 84a:	03043823          	sd	a6,48(s0)
 84e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 852:	00840613          	addi	a2,s0,8
 856:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 85a:	85aa                	mv	a1,a0
 85c:	4505                	li	a0,1
 85e:	d19ff0ef          	jal	ra,576 <vprintf>
}
 862:	60e2                	ld	ra,24(sp)
 864:	6442                	ld	s0,16(sp)
 866:	6125                	addi	sp,sp,96
 868:	8082                	ret

000000000000086a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 86a:	1141                	addi	sp,sp,-16
 86c:	e422                	sd	s0,8(sp)
 86e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 870:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 874:	00000797          	auipc	a5,0x0
 878:	78c7b783          	ld	a5,1932(a5) # 1000 <freep>
 87c:	a805                	j	8ac <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 87e:	4618                	lw	a4,8(a2)
 880:	9db9                	addw	a1,a1,a4
 882:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 886:	6398                	ld	a4,0(a5)
 888:	6318                	ld	a4,0(a4)
 88a:	fee53823          	sd	a4,-16(a0)
 88e:	a091                	j	8d2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 890:	ff852703          	lw	a4,-8(a0)
 894:	9e39                	addw	a2,a2,a4
 896:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 898:	ff053703          	ld	a4,-16(a0)
 89c:	e398                	sd	a4,0(a5)
 89e:	a099                	j	8e4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a0:	6398                	ld	a4,0(a5)
 8a2:	00e7e463          	bltu	a5,a4,8aa <free+0x40>
 8a6:	00e6ea63          	bltu	a3,a4,8ba <free+0x50>
{
 8aa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ac:	fed7fae3          	bgeu	a5,a3,8a0 <free+0x36>
 8b0:	6398                	ld	a4,0(a5)
 8b2:	00e6e463          	bltu	a3,a4,8ba <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b6:	fee7eae3          	bltu	a5,a4,8aa <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8ba:	ff852583          	lw	a1,-8(a0)
 8be:	6390                	ld	a2,0(a5)
 8c0:	02059713          	slli	a4,a1,0x20
 8c4:	9301                	srli	a4,a4,0x20
 8c6:	0712                	slli	a4,a4,0x4
 8c8:	9736                	add	a4,a4,a3
 8ca:	fae60ae3          	beq	a2,a4,87e <free+0x14>
    bp->s.ptr = p->s.ptr;
 8ce:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8d2:	4790                	lw	a2,8(a5)
 8d4:	02061713          	slli	a4,a2,0x20
 8d8:	9301                	srli	a4,a4,0x20
 8da:	0712                	slli	a4,a4,0x4
 8dc:	973e                	add	a4,a4,a5
 8de:	fae689e3          	beq	a3,a4,890 <free+0x26>
  } else
    p->s.ptr = bp;
 8e2:	e394                	sd	a3,0(a5)
  freep = p;
 8e4:	00000717          	auipc	a4,0x0
 8e8:	70f73e23          	sd	a5,1820(a4) # 1000 <freep>
}
 8ec:	6422                	ld	s0,8(sp)
 8ee:	0141                	addi	sp,sp,16
 8f0:	8082                	ret

00000000000008f2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8f2:	7139                	addi	sp,sp,-64
 8f4:	fc06                	sd	ra,56(sp)
 8f6:	f822                	sd	s0,48(sp)
 8f8:	f426                	sd	s1,40(sp)
 8fa:	f04a                	sd	s2,32(sp)
 8fc:	ec4e                	sd	s3,24(sp)
 8fe:	e852                	sd	s4,16(sp)
 900:	e456                	sd	s5,8(sp)
 902:	e05a                	sd	s6,0(sp)
 904:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 906:	02051493          	slli	s1,a0,0x20
 90a:	9081                	srli	s1,s1,0x20
 90c:	04bd                	addi	s1,s1,15
 90e:	8091                	srli	s1,s1,0x4
 910:	0014899b          	addiw	s3,s1,1
 914:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 916:	00000517          	auipc	a0,0x0
 91a:	6ea53503          	ld	a0,1770(a0) # 1000 <freep>
 91e:	c515                	beqz	a0,94a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 920:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 922:	4798                	lw	a4,8(a5)
 924:	02977f63          	bgeu	a4,s1,962 <malloc+0x70>
 928:	8a4e                	mv	s4,s3
 92a:	0009871b          	sext.w	a4,s3
 92e:	6685                	lui	a3,0x1
 930:	00d77363          	bgeu	a4,a3,936 <malloc+0x44>
 934:	6a05                	lui	s4,0x1
 936:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 93a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 93e:	00000917          	auipc	s2,0x0
 942:	6c290913          	addi	s2,s2,1730 # 1000 <freep>
  if(p == SBRK_ERROR)
 946:	5afd                	li	s5,-1
 948:	a0bd                	j	9b6 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 94a:	00000797          	auipc	a5,0x0
 94e:	6c678793          	addi	a5,a5,1734 # 1010 <base>
 952:	00000717          	auipc	a4,0x0
 956:	6af73723          	sd	a5,1710(a4) # 1000 <freep>
 95a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 95c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 960:	b7e1                	j	928 <malloc+0x36>
      if(p->s.size == nunits)
 962:	02e48b63          	beq	s1,a4,998 <malloc+0xa6>
        p->s.size -= nunits;
 966:	4137073b          	subw	a4,a4,s3
 96a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 96c:	1702                	slli	a4,a4,0x20
 96e:	9301                	srli	a4,a4,0x20
 970:	0712                	slli	a4,a4,0x4
 972:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 974:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 978:	00000717          	auipc	a4,0x0
 97c:	68a73423          	sd	a0,1672(a4) # 1000 <freep>
      return (void*)(p + 1);
 980:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 984:	70e2                	ld	ra,56(sp)
 986:	7442                	ld	s0,48(sp)
 988:	74a2                	ld	s1,40(sp)
 98a:	7902                	ld	s2,32(sp)
 98c:	69e2                	ld	s3,24(sp)
 98e:	6a42                	ld	s4,16(sp)
 990:	6aa2                	ld	s5,8(sp)
 992:	6b02                	ld	s6,0(sp)
 994:	6121                	addi	sp,sp,64
 996:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 998:	6398                	ld	a4,0(a5)
 99a:	e118                	sd	a4,0(a0)
 99c:	bff1                	j	978 <malloc+0x86>
  hp->s.size = nu;
 99e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9a2:	0541                	addi	a0,a0,16
 9a4:	ec7ff0ef          	jal	ra,86a <free>
  return freep;
 9a8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ac:	dd61                	beqz	a0,984 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b0:	4798                	lw	a4,8(a5)
 9b2:	fa9778e3          	bgeu	a4,s1,962 <malloc+0x70>
    if(p == freep)
 9b6:	00093703          	ld	a4,0(s2)
 9ba:	853e                	mv	a0,a5
 9bc:	fef719e3          	bne	a4,a5,9ae <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 9c0:	8552                	mv	a0,s4
 9c2:	9e7ff0ef          	jal	ra,3a8 <sbrk>
  if(p == SBRK_ERROR)
 9c6:	fd551ce3          	bne	a0,s5,99e <malloc+0xac>
        return 0;
 9ca:	4501                	li	a0,0
 9cc:	bf65                	j	984 <malloc+0x92>

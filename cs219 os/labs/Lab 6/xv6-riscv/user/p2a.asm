
user/_p2a:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char* argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
    int N = 2, i;
    if (argc > 1) N = atoi(argv[1]);
   c:	4785                	li	a5,1
   e:	0ca7c263          	blt	a5,a0,d2 <main+0xd2>

    // Initialize shared memory (refcount should become 0)
    printf("[Parent] Calling shm_init()...\n");
  12:	00001517          	auipc	a0,0x1
  16:	a2e50513          	addi	a0,a0,-1490 # a40 <malloc+0xe4>
  1a:	089000ef          	jal	ra,8a2 <printf>
    if (shm_init() < 0) {
  1e:	4e0000ef          	jal	ra,4fe <shm_init>
  22:	0e054863          	bltz	a0,112 <main+0x112>
        printf("[Parent] ERROR: shm_init failed\n");
        exit(1);
    }
    printf("[Parent] shm_init SUCCESS\n");
  26:	00001517          	auipc	a0,0x1
  2a:	a6250513          	addi	a0,a0,-1438 # a88 <malloc+0x12c>
  2e:	075000ef          	jal	ra,8a2 <printf>

    printf("[Parent] Initial Refcount: %d (Expected: 0)\n", shm_refcount());
  32:	4ec000ef          	jal	ra,51e <shm_refcount>
  36:	85aa                	mv	a1,a0
  38:	00001517          	auipc	a0,0x1
  3c:	a7050513          	addi	a0,a0,-1424 # aa8 <malloc+0x14c>
  40:	063000ef          	jal	ra,8a2 <printf>
    int N = 2, i;
  44:	4909                	li	s2,2
  46:	4481                	li	s1,0

    // Create child processes that attach
    for (i = 0; i < N; i++) {
        if (fork() == 0) {
  48:	3f6000ef          	jal	ra,43e <fork>
  4c:	0c050c63          	beqz	a0,124 <main+0x124>

            printf("[Child %d] Detached | Refcount: %d\n", i, shm_refcount());
            exit(0);
        }

        pause(2);
  50:	4509                	li	a0,2
  52:	484000ef          	jal	ra,4d6 <pause>
    for (i = 0; i < N; i++) {
  56:	2485                	addiw	s1,s1,1
  58:	ff24c8e3          	blt	s1,s2,48 <main+0x48>
    }

    // Try to destroy while children are still attached
    printf("\n[Parent] Attempting shm_destroy() while refcount > 0...\n");
  5c:	00001517          	auipc	a0,0x1
  60:	b4450513          	addi	a0,a0,-1212 # ba0 <malloc+0x244>
  64:	03f000ef          	jal	ra,8a2 <printf>
    if (shm_destroy() < 0)
  68:	4ae000ef          	jal	ra,516 <shm_destroy>
  6c:	12054463          	bltz	a0,194 <main+0x194>
        printf("[Parent] CORRECT: shm_destroy FAILED (refcount not zero)\n");
    else
        printf("[Parent] ERROR: shm_destroy should not succeed!\n");
  70:	00001517          	auipc	a0,0x1
  74:	bb050513          	addi	a0,a0,-1104 # c20 <malloc+0x2c4>
  78:	02b000ef          	jal	ra,8a2 <printf>

    // Wait for all children to finish (they will detach)
    for (i = 0; i < N; i++) wait(0);
  7c:	4481                	li	s1,0
  7e:	01205863          	blez	s2,8e <main+0x8e>
  82:	4501                	li	a0,0
  84:	3ca000ef          	jal	ra,44e <wait>
  88:	2485                	addiw	s1,s1,1
  8a:	ff249ce3          	bne	s1,s2,82 <main+0x82>

    // Refcount should now be 0
    printf("\n[Parent] All children finished.\n");
  8e:	00001517          	auipc	a0,0x1
  92:	bca50513          	addi	a0,a0,-1078 # c58 <malloc+0x2fc>
  96:	00d000ef          	jal	ra,8a2 <printf>
    printf("[Parent] Current Refcount: %d (Expected: 0)\n", shm_refcount());
  9a:	484000ef          	jal	ra,51e <shm_refcount>
  9e:	85aa                	mv	a1,a0
  a0:	00001517          	auipc	a0,0x1
  a4:	be050513          	addi	a0,a0,-1056 # c80 <malloc+0x324>
  a8:	7fa000ef          	jal	ra,8a2 <printf>

    // Step 4: Now destroy should succeed
    printf("[Parent] Attempting shm_destroy() again...\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	c0450513          	addi	a0,a0,-1020 # cb0 <malloc+0x354>
  b4:	7ee000ef          	jal	ra,8a2 <printf>
    if (shm_destroy() < 0)
  b8:	45e000ef          	jal	ra,516 <shm_destroy>
  bc:	0e054363          	bltz	a0,1a2 <main+0x1a2>
        printf("[Parent] ERROR: shm_destroy failed unexpectedly\n");
    else
        printf("[Parent] SUCCESS: shm_destroy worked (refcount = 0)\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	c5850513          	addi	a0,a0,-936 # d18 <malloc+0x3bc>
  c8:	7da000ef          	jal	ra,8a2 <printf>

    exit(0);
  cc:	4501                	li	a0,0
  ce:	378000ef          	jal	ra,446 <exit>
    if (argc > 1) N = atoi(argv[1]);
  d2:	6588                	ld	a0,8(a1)
  d4:	24e000ef          	jal	ra,322 <atoi>
  d8:	892a                	mv	s2,a0
    printf("[Parent] Calling shm_init()...\n");
  da:	00001517          	auipc	a0,0x1
  de:	96650513          	addi	a0,a0,-1690 # a40 <malloc+0xe4>
  e2:	7c0000ef          	jal	ra,8a2 <printf>
    if (shm_init() < 0) {
  e6:	418000ef          	jal	ra,4fe <shm_init>
  ea:	02054463          	bltz	a0,112 <main+0x112>
    printf("[Parent] shm_init SUCCESS\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	99a50513          	addi	a0,a0,-1638 # a88 <malloc+0x12c>
  f6:	7ac000ef          	jal	ra,8a2 <printf>
    printf("[Parent] Initial Refcount: %d (Expected: 0)\n", shm_refcount());
  fa:	424000ef          	jal	ra,51e <shm_refcount>
  fe:	85aa                	mv	a1,a0
 100:	00001517          	auipc	a0,0x1
 104:	9a850513          	addi	a0,a0,-1624 # aa8 <malloc+0x14c>
 108:	79a000ef          	jal	ra,8a2 <printf>
    for (i = 0; i < N; i++) {
 10c:	f3204de3          	bgtz	s2,46 <main+0x46>
 110:	b7b1                	j	5c <main+0x5c>
        printf("[Parent] ERROR: shm_init failed\n");
 112:	00001517          	auipc	a0,0x1
 116:	94e50513          	addi	a0,a0,-1714 # a60 <malloc+0x104>
 11a:	788000ef          	jal	ra,8a2 <printf>
        exit(1);
 11e:	4505                	li	a0,1
 120:	326000ef          	jal	ra,446 <exit>
            printf("[Child %d] Calling shm_attach()...\n", i);
 124:	85a6                	mv	a1,s1
 126:	00001517          	auipc	a0,0x1
 12a:	9b250513          	addi	a0,a0,-1614 # ad8 <malloc+0x17c>
 12e:	774000ef          	jal	ra,8a2 <printf>
            if (shm_attach() < 0) {
 132:	3d4000ef          	jal	ra,506 <shm_attach>
            printf("[Child %d] Attached | Refcount: %d\n", i, shm_refcount());
 136:	3e8000ef          	jal	ra,51e <shm_refcount>
 13a:	862a                	mv	a2,a0
 13c:	85a6                	mv	a1,s1
 13e:	00001517          	auipc	a0,0x1
 142:	9c250513          	addi	a0,a0,-1598 # b00 <malloc+0x1a4>
 146:	75c000ef          	jal	ra,8a2 <printf>
            pause(20);
 14a:	4551                	li	a0,20
 14c:	38a000ef          	jal	ra,4d6 <pause>
            printf("[Child %d] Calling shm_detach()...\n", i);
 150:	85a6                	mv	a1,s1
 152:	00001517          	auipc	a0,0x1
 156:	9d650513          	addi	a0,a0,-1578 # b28 <malloc+0x1cc>
 15a:	748000ef          	jal	ra,8a2 <printf>
            if (shm_detach() < 0) {
 15e:	3b0000ef          	jal	ra,50e <shm_detach>
 162:	00054f63          	bltz	a0,180 <main+0x180>
            printf("[Child %d] Detached | Refcount: %d\n", i, shm_refcount());
 166:	3b8000ef          	jal	ra,51e <shm_refcount>
 16a:	862a                	mv	a2,a0
 16c:	85a6                	mv	a1,s1
 16e:	00001517          	auipc	a0,0x1
 172:	a0a50513          	addi	a0,a0,-1526 # b78 <malloc+0x21c>
 176:	72c000ef          	jal	ra,8a2 <printf>
            exit(0);
 17a:	4501                	li	a0,0
 17c:	2ca000ef          	jal	ra,446 <exit>
                printf("[Child %d] ERROR: shm_detach failed\n", i);
 180:	85a6                	mv	a1,s1
 182:	00001517          	auipc	a0,0x1
 186:	9ce50513          	addi	a0,a0,-1586 # b50 <malloc+0x1f4>
 18a:	718000ef          	jal	ra,8a2 <printf>
                exit(1);
 18e:	4505                	li	a0,1
 190:	2b6000ef          	jal	ra,446 <exit>
        printf("[Parent] CORRECT: shm_destroy FAILED (refcount not zero)\n");
 194:	00001517          	auipc	a0,0x1
 198:	a4c50513          	addi	a0,a0,-1460 # be0 <malloc+0x284>
 19c:	706000ef          	jal	ra,8a2 <printf>
 1a0:	bdf1                	j	7c <main+0x7c>
        printf("[Parent] ERROR: shm_destroy failed unexpectedly\n");
 1a2:	00001517          	auipc	a0,0x1
 1a6:	b3e50513          	addi	a0,a0,-1218 # ce0 <malloc+0x384>
 1aa:	6f8000ef          	jal	ra,8a2 <printf>
 1ae:	bf39                	j	cc <main+0xcc>

00000000000001b0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e406                	sd	ra,8(sp)
 1b4:	e022                	sd	s0,0(sp)
 1b6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1b8:	e49ff0ef          	jal	ra,0 <main>
  exit(r);
 1bc:	28a000ef          	jal	ra,446 <exit>

00000000000001c0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1c6:	87aa                	mv	a5,a0
 1c8:	0585                	addi	a1,a1,1
 1ca:	0785                	addi	a5,a5,1
 1cc:	fff5c703          	lbu	a4,-1(a1)
 1d0:	fee78fa3          	sb	a4,-1(a5)
 1d4:	fb75                	bnez	a4,1c8 <strcpy+0x8>
    ;
  return os;
}
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret

00000000000001dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e422                	sd	s0,8(sp)
 1e0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	cb91                	beqz	a5,1fa <strcmp+0x1e>
 1e8:	0005c703          	lbu	a4,0(a1)
 1ec:	00f71763          	bne	a4,a5,1fa <strcmp+0x1e>
    p++, q++;
 1f0:	0505                	addi	a0,a0,1
 1f2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1f4:	00054783          	lbu	a5,0(a0)
 1f8:	fbe5                	bnez	a5,1e8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1fa:	0005c503          	lbu	a0,0(a1)
}
 1fe:	40a7853b          	subw	a0,a5,a0
 202:	6422                	ld	s0,8(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret

0000000000000208 <strlen>:

uint
strlen(const char *s)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 20e:	00054783          	lbu	a5,0(a0)
 212:	cf91                	beqz	a5,22e <strlen+0x26>
 214:	0505                	addi	a0,a0,1
 216:	87aa                	mv	a5,a0
 218:	4685                	li	a3,1
 21a:	9e89                	subw	a3,a3,a0
 21c:	00f6853b          	addw	a0,a3,a5
 220:	0785                	addi	a5,a5,1
 222:	fff7c703          	lbu	a4,-1(a5)
 226:	fb7d                	bnez	a4,21c <strlen+0x14>
    ;
  return n;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
  for(n = 0; s[n]; n++)
 22e:	4501                	li	a0,0
 230:	bfe5                	j	228 <strlen+0x20>

0000000000000232 <memset>:

void*
memset(void *dst, int c, uint n)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 238:	ca19                	beqz	a2,24e <memset+0x1c>
 23a:	87aa                	mv	a5,a0
 23c:	1602                	slli	a2,a2,0x20
 23e:	9201                	srli	a2,a2,0x20
 240:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 244:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 248:	0785                	addi	a5,a5,1
 24a:	fee79de3          	bne	a5,a4,244 <memset+0x12>
  }
  return dst;
}
 24e:	6422                	ld	s0,8(sp)
 250:	0141                	addi	sp,sp,16
 252:	8082                	ret

0000000000000254 <strchr>:

char*
strchr(const char *s, char c)
{
 254:	1141                	addi	sp,sp,-16
 256:	e422                	sd	s0,8(sp)
 258:	0800                	addi	s0,sp,16
  for(; *s; s++)
 25a:	00054783          	lbu	a5,0(a0)
 25e:	cb99                	beqz	a5,274 <strchr+0x20>
    if(*s == c)
 260:	00f58763          	beq	a1,a5,26e <strchr+0x1a>
  for(; *s; s++)
 264:	0505                	addi	a0,a0,1
 266:	00054783          	lbu	a5,0(a0)
 26a:	fbfd                	bnez	a5,260 <strchr+0xc>
      return (char*)s;
  return 0;
 26c:	4501                	li	a0,0
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret
  return 0;
 274:	4501                	li	a0,0
 276:	bfe5                	j	26e <strchr+0x1a>

0000000000000278 <gets>:

char*
gets(char *buf, int max)
{
 278:	711d                	addi	sp,sp,-96
 27a:	ec86                	sd	ra,88(sp)
 27c:	e8a2                	sd	s0,80(sp)
 27e:	e4a6                	sd	s1,72(sp)
 280:	e0ca                	sd	s2,64(sp)
 282:	fc4e                	sd	s3,56(sp)
 284:	f852                	sd	s4,48(sp)
 286:	f456                	sd	s5,40(sp)
 288:	f05a                	sd	s6,32(sp)
 28a:	ec5e                	sd	s7,24(sp)
 28c:	1080                	addi	s0,sp,96
 28e:	8baa                	mv	s7,a0
 290:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 292:	892a                	mv	s2,a0
 294:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 296:	4aa9                	li	s5,10
 298:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 29a:	89a6                	mv	s3,s1
 29c:	2485                	addiw	s1,s1,1
 29e:	0344d663          	bge	s1,s4,2ca <gets+0x52>
    cc = read(0, &c, 1);
 2a2:	4605                	li	a2,1
 2a4:	faf40593          	addi	a1,s0,-81
 2a8:	4501                	li	a0,0
 2aa:	1b4000ef          	jal	ra,45e <read>
    if(cc < 1)
 2ae:	00a05e63          	blez	a0,2ca <gets+0x52>
    buf[i++] = c;
 2b2:	faf44783          	lbu	a5,-81(s0)
 2b6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ba:	01578763          	beq	a5,s5,2c8 <gets+0x50>
 2be:	0905                	addi	s2,s2,1
 2c0:	fd679de3          	bne	a5,s6,29a <gets+0x22>
  for(i=0; i+1 < max; ){
 2c4:	89a6                	mv	s3,s1
 2c6:	a011                	j	2ca <gets+0x52>
 2c8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2ca:	99de                	add	s3,s3,s7
 2cc:	00098023          	sb	zero,0(s3)
  return buf;
}
 2d0:	855e                	mv	a0,s7
 2d2:	60e6                	ld	ra,88(sp)
 2d4:	6446                	ld	s0,80(sp)
 2d6:	64a6                	ld	s1,72(sp)
 2d8:	6906                	ld	s2,64(sp)
 2da:	79e2                	ld	s3,56(sp)
 2dc:	7a42                	ld	s4,48(sp)
 2de:	7aa2                	ld	s5,40(sp)
 2e0:	7b02                	ld	s6,32(sp)
 2e2:	6be2                	ld	s7,24(sp)
 2e4:	6125                	addi	sp,sp,96
 2e6:	8082                	ret

00000000000002e8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2e8:	1101                	addi	sp,sp,-32
 2ea:	ec06                	sd	ra,24(sp)
 2ec:	e822                	sd	s0,16(sp)
 2ee:	e426                	sd	s1,8(sp)
 2f0:	e04a                	sd	s2,0(sp)
 2f2:	1000                	addi	s0,sp,32
 2f4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2f6:	4581                	li	a1,0
 2f8:	18e000ef          	jal	ra,486 <open>
  if(fd < 0)
 2fc:	02054163          	bltz	a0,31e <stat+0x36>
 300:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 302:	85ca                	mv	a1,s2
 304:	19a000ef          	jal	ra,49e <fstat>
 308:	892a                	mv	s2,a0
  close(fd);
 30a:	8526                	mv	a0,s1
 30c:	162000ef          	jal	ra,46e <close>
  return r;
}
 310:	854a                	mv	a0,s2
 312:	60e2                	ld	ra,24(sp)
 314:	6442                	ld	s0,16(sp)
 316:	64a2                	ld	s1,8(sp)
 318:	6902                	ld	s2,0(sp)
 31a:	6105                	addi	sp,sp,32
 31c:	8082                	ret
    return -1;
 31e:	597d                	li	s2,-1
 320:	bfc5                	j	310 <stat+0x28>

0000000000000322 <atoi>:

int
atoi(const char *s)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 328:	00054603          	lbu	a2,0(a0)
 32c:	fd06079b          	addiw	a5,a2,-48
 330:	0ff7f793          	andi	a5,a5,255
 334:	4725                	li	a4,9
 336:	02f76963          	bltu	a4,a5,368 <atoi+0x46>
 33a:	86aa                	mv	a3,a0
  n = 0;
 33c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 33e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 340:	0685                	addi	a3,a3,1
 342:	0025179b          	slliw	a5,a0,0x2
 346:	9fa9                	addw	a5,a5,a0
 348:	0017979b          	slliw	a5,a5,0x1
 34c:	9fb1                	addw	a5,a5,a2
 34e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 352:	0006c603          	lbu	a2,0(a3)
 356:	fd06071b          	addiw	a4,a2,-48
 35a:	0ff77713          	andi	a4,a4,255
 35e:	fee5f1e3          	bgeu	a1,a4,340 <atoi+0x1e>
  return n;
}
 362:	6422                	ld	s0,8(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret
  n = 0;
 368:	4501                	li	a0,0
 36a:	bfe5                	j	362 <atoi+0x40>

000000000000036c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 372:	02b57463          	bgeu	a0,a1,39a <memmove+0x2e>
    while(n-- > 0)
 376:	00c05f63          	blez	a2,394 <memmove+0x28>
 37a:	1602                	slli	a2,a2,0x20
 37c:	9201                	srli	a2,a2,0x20
 37e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 382:	872a                	mv	a4,a0
      *dst++ = *src++;
 384:	0585                	addi	a1,a1,1
 386:	0705                	addi	a4,a4,1
 388:	fff5c683          	lbu	a3,-1(a1)
 38c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 390:	fee79ae3          	bne	a5,a4,384 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 394:	6422                	ld	s0,8(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret
    dst += n;
 39a:	00c50733          	add	a4,a0,a2
    src += n;
 39e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3a0:	fec05ae3          	blez	a2,394 <memmove+0x28>
 3a4:	fff6079b          	addiw	a5,a2,-1
 3a8:	1782                	slli	a5,a5,0x20
 3aa:	9381                	srli	a5,a5,0x20
 3ac:	fff7c793          	not	a5,a5
 3b0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3b2:	15fd                	addi	a1,a1,-1
 3b4:	177d                	addi	a4,a4,-1
 3b6:	0005c683          	lbu	a3,0(a1)
 3ba:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3be:	fee79ae3          	bne	a5,a4,3b2 <memmove+0x46>
 3c2:	bfc9                	j	394 <memmove+0x28>

00000000000003c4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e422                	sd	s0,8(sp)
 3c8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ca:	ca05                	beqz	a2,3fa <memcmp+0x36>
 3cc:	fff6069b          	addiw	a3,a2,-1
 3d0:	1682                	slli	a3,a3,0x20
 3d2:	9281                	srli	a3,a3,0x20
 3d4:	0685                	addi	a3,a3,1
 3d6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3d8:	00054783          	lbu	a5,0(a0)
 3dc:	0005c703          	lbu	a4,0(a1)
 3e0:	00e79863          	bne	a5,a4,3f0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3e4:	0505                	addi	a0,a0,1
    p2++;
 3e6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3e8:	fed518e3          	bne	a0,a3,3d8 <memcmp+0x14>
  }
  return 0;
 3ec:	4501                	li	a0,0
 3ee:	a019                	j	3f4 <memcmp+0x30>
      return *p1 - *p2;
 3f0:	40e7853b          	subw	a0,a5,a4
}
 3f4:	6422                	ld	s0,8(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret
  return 0;
 3fa:	4501                	li	a0,0
 3fc:	bfe5                	j	3f4 <memcmp+0x30>

00000000000003fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3fe:	1141                	addi	sp,sp,-16
 400:	e406                	sd	ra,8(sp)
 402:	e022                	sd	s0,0(sp)
 404:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 406:	f67ff0ef          	jal	ra,36c <memmove>
}
 40a:	60a2                	ld	ra,8(sp)
 40c:	6402                	ld	s0,0(sp)
 40e:	0141                	addi	sp,sp,16
 410:	8082                	ret

0000000000000412 <sbrk>:

char *
sbrk(int n) {
 412:	1141                	addi	sp,sp,-16
 414:	e406                	sd	ra,8(sp)
 416:	e022                	sd	s0,0(sp)
 418:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 41a:	4585                	li	a1,1
 41c:	0b2000ef          	jal	ra,4ce <sys_sbrk>
}
 420:	60a2                	ld	ra,8(sp)
 422:	6402                	ld	s0,0(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret

0000000000000428 <sbrklazy>:

char *
sbrklazy(int n) {
 428:	1141                	addi	sp,sp,-16
 42a:	e406                	sd	ra,8(sp)
 42c:	e022                	sd	s0,0(sp)
 42e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 430:	4589                	li	a1,2
 432:	09c000ef          	jal	ra,4ce <sys_sbrk>
}
 436:	60a2                	ld	ra,8(sp)
 438:	6402                	ld	s0,0(sp)
 43a:	0141                	addi	sp,sp,16
 43c:	8082                	ret

000000000000043e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 43e:	4885                	li	a7,1
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <exit>:
.global exit
exit:
 li a7, SYS_exit
 446:	4889                	li	a7,2
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <wait>:
.global wait
wait:
 li a7, SYS_wait
 44e:	488d                	li	a7,3
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 456:	4891                	li	a7,4
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <read>:
.global read
read:
 li a7, SYS_read
 45e:	4895                	li	a7,5
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <write>:
.global write
write:
 li a7, SYS_write
 466:	48c1                	li	a7,16
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <close>:
.global close
close:
 li a7, SYS_close
 46e:	48d5                	li	a7,21
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <kill>:
.global kill
kill:
 li a7, SYS_kill
 476:	4899                	li	a7,6
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <exec>:
.global exec
exec:
 li a7, SYS_exec
 47e:	489d                	li	a7,7
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <open>:
.global open
open:
 li a7, SYS_open
 486:	48bd                	li	a7,15
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 48e:	48c5                	li	a7,17
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 496:	48c9                	li	a7,18
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 49e:	48a1                	li	a7,8
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <link>:
.global link
link:
 li a7, SYS_link
 4a6:	48cd                	li	a7,19
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ae:	48d1                	li	a7,20
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b6:	48a5                	li	a7,9
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <dup>:
.global dup
dup:
 li a7, SYS_dup
 4be:	48a9                	li	a7,10
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c6:	48ad                	li	a7,11
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4ce:	48b1                	li	a7,12
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4d6:	48b5                	li	a7,13
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4de:	48b9                	li	a7,14
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <tfork>:
.global tfork
tfork:
 li a7, SYS_tfork
 4e6:	48d9                	li	a7,22
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 4ee:	48dd                	li	a7,23
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <tfork2>:
.global tfork2
tfork2:
 li a7, SYS_tfork2
 4f6:	48e1                	li	a7,24
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <shm_init>:
.global shm_init
shm_init:
 li a7, SYS_shm_init
 4fe:	48e5                	li	a7,25
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <shm_attach>:
.global shm_attach
shm_attach:
 li a7, SYS_shm_attach
 506:	48e9                	li	a7,26
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <shm_detach>:
.global shm_detach
shm_detach:
 li a7, SYS_shm_detach
 50e:	48ed                	li	a7,27
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <shm_destroy>:
.global shm_destroy
shm_destroy:
 li a7, SYS_shm_destroy
 516:	48f1                	li	a7,28
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <shm_refcount>:
.global shm_refcount
shm_refcount:
 li a7, SYS_shm_refcount
 51e:	48f5                	li	a7,29
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 526:	1101                	addi	sp,sp,-32
 528:	ec06                	sd	ra,24(sp)
 52a:	e822                	sd	s0,16(sp)
 52c:	1000                	addi	s0,sp,32
 52e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 532:	4605                	li	a2,1
 534:	fef40593          	addi	a1,s0,-17
 538:	f2fff0ef          	jal	ra,466 <write>
}
 53c:	60e2                	ld	ra,24(sp)
 53e:	6442                	ld	s0,16(sp)
 540:	6105                	addi	sp,sp,32
 542:	8082                	ret

0000000000000544 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 544:	715d                	addi	sp,sp,-80
 546:	e486                	sd	ra,72(sp)
 548:	e0a2                	sd	s0,64(sp)
 54a:	fc26                	sd	s1,56(sp)
 54c:	f84a                	sd	s2,48(sp)
 54e:	f44e                	sd	s3,40(sp)
 550:	0880                	addi	s0,sp,80
 552:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 554:	c299                	beqz	a3,55a <printint+0x16>
 556:	0805c163          	bltz	a1,5d8 <printint+0x94>
  neg = 0;
 55a:	4881                	li	a7,0
 55c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 560:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 562:	00000517          	auipc	a0,0x0
 566:	7f650513          	addi	a0,a0,2038 # d58 <digits>
 56a:	883e                	mv	a6,a5
 56c:	2785                	addiw	a5,a5,1
 56e:	02c5f733          	remu	a4,a1,a2
 572:	972a                	add	a4,a4,a0
 574:	00074703          	lbu	a4,0(a4)
 578:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 57c:	872e                	mv	a4,a1
 57e:	02c5d5b3          	divu	a1,a1,a2
 582:	0685                	addi	a3,a3,1
 584:	fec773e3          	bgeu	a4,a2,56a <printint+0x26>
  if(neg)
 588:	00088b63          	beqz	a7,59e <printint+0x5a>
    buf[i++] = '-';
 58c:	fd040713          	addi	a4,s0,-48
 590:	97ba                	add	a5,a5,a4
 592:	02d00713          	li	a4,45
 596:	fee78423          	sb	a4,-24(a5)
 59a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 59e:	02f05663          	blez	a5,5ca <printint+0x86>
 5a2:	fb840713          	addi	a4,s0,-72
 5a6:	00f704b3          	add	s1,a4,a5
 5aa:	fff70993          	addi	s3,a4,-1
 5ae:	99be                	add	s3,s3,a5
 5b0:	37fd                	addiw	a5,a5,-1
 5b2:	1782                	slli	a5,a5,0x20
 5b4:	9381                	srli	a5,a5,0x20
 5b6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5ba:	fff4c583          	lbu	a1,-1(s1)
 5be:	854a                	mv	a0,s2
 5c0:	f67ff0ef          	jal	ra,526 <putc>
  while(--i >= 0)
 5c4:	14fd                	addi	s1,s1,-1
 5c6:	ff349ae3          	bne	s1,s3,5ba <printint+0x76>
}
 5ca:	60a6                	ld	ra,72(sp)
 5cc:	6406                	ld	s0,64(sp)
 5ce:	74e2                	ld	s1,56(sp)
 5d0:	7942                	ld	s2,48(sp)
 5d2:	79a2                	ld	s3,40(sp)
 5d4:	6161                	addi	sp,sp,80
 5d6:	8082                	ret
    x = -xx;
 5d8:	40b005b3          	neg	a1,a1
    neg = 1;
 5dc:	4885                	li	a7,1
    x = -xx;
 5de:	bfbd                	j	55c <printint+0x18>

00000000000005e0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5e0:	7119                	addi	sp,sp,-128
 5e2:	fc86                	sd	ra,120(sp)
 5e4:	f8a2                	sd	s0,112(sp)
 5e6:	f4a6                	sd	s1,104(sp)
 5e8:	f0ca                	sd	s2,96(sp)
 5ea:	ecce                	sd	s3,88(sp)
 5ec:	e8d2                	sd	s4,80(sp)
 5ee:	e4d6                	sd	s5,72(sp)
 5f0:	e0da                	sd	s6,64(sp)
 5f2:	fc5e                	sd	s7,56(sp)
 5f4:	f862                	sd	s8,48(sp)
 5f6:	f466                	sd	s9,40(sp)
 5f8:	f06a                	sd	s10,32(sp)
 5fa:	ec6e                	sd	s11,24(sp)
 5fc:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5fe:	0005c903          	lbu	s2,0(a1)
 602:	24090c63          	beqz	s2,85a <vprintf+0x27a>
 606:	8b2a                	mv	s6,a0
 608:	8a2e                	mv	s4,a1
 60a:	8bb2                	mv	s7,a2
  state = 0;
 60c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 60e:	4481                	li	s1,0
 610:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 612:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 616:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 61a:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 61e:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 622:	00000c97          	auipc	s9,0x0
 626:	736c8c93          	addi	s9,s9,1846 # d58 <digits>
 62a:	a005                	j	64a <vprintf+0x6a>
        putc(fd, c0);
 62c:	85ca                	mv	a1,s2
 62e:	855a                	mv	a0,s6
 630:	ef7ff0ef          	jal	ra,526 <putc>
 634:	a019                	j	63a <vprintf+0x5a>
    } else if(state == '%'){
 636:	03598263          	beq	s3,s5,65a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 63a:	2485                	addiw	s1,s1,1
 63c:	8726                	mv	a4,s1
 63e:	009a07b3          	add	a5,s4,s1
 642:	0007c903          	lbu	s2,0(a5)
 646:	20090a63          	beqz	s2,85a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 64a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 64e:	fe0994e3          	bnez	s3,636 <vprintf+0x56>
      if(c0 == '%'){
 652:	fd579de3          	bne	a5,s5,62c <vprintf+0x4c>
        state = '%';
 656:	89be                	mv	s3,a5
 658:	b7cd                	j	63a <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 65a:	c3c1                	beqz	a5,6da <vprintf+0xfa>
 65c:	00ea06b3          	add	a3,s4,a4
 660:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 664:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 666:	c681                	beqz	a3,66e <vprintf+0x8e>
 668:	9752                	add	a4,a4,s4
 66a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 66e:	03878e63          	beq	a5,s8,6aa <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 672:	05a78863          	beq	a5,s10,6c2 <vprintf+0xe2>
      } else if(c0 == 'u'){
 676:	0db78b63          	beq	a5,s11,74c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 67a:	07800713          	li	a4,120
 67e:	10e78d63          	beq	a5,a4,798 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 682:	07000713          	li	a4,112
 686:	14e78263          	beq	a5,a4,7ca <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 68a:	06300713          	li	a4,99
 68e:	16e78f63          	beq	a5,a4,80c <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 692:	07300713          	li	a4,115
 696:	18e78563          	beq	a5,a4,820 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 69a:	05579063          	bne	a5,s5,6da <vprintf+0xfa>
        putc(fd, '%');
 69e:	85d6                	mv	a1,s5
 6a0:	855a                	mv	a0,s6
 6a2:	e85ff0ef          	jal	ra,526 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bf49                	j	63a <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4685                	li	a3,1
 6b0:	4629                	li	a2,10
 6b2:	000ba583          	lw	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	e8dff0ef          	jal	ra,544 <printint>
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bfad                	j	63a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 6c2:	03868663          	beq	a3,s8,6ee <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6c6:	05a68163          	beq	a3,s10,708 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 6ca:	09b68d63          	beq	a3,s11,764 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6ce:	03a68f63          	beq	a3,s10,70c <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 6d2:	07800793          	li	a5,120
 6d6:	0cf68d63          	beq	a3,a5,7b0 <vprintf+0x1d0>
        putc(fd, '%');
 6da:	85d6                	mv	a1,s5
 6dc:	855a                	mv	a0,s6
 6de:	e49ff0ef          	jal	ra,526 <putc>
        putc(fd, c0);
 6e2:	85ca                	mv	a1,s2
 6e4:	855a                	mv	a0,s6
 6e6:	e41ff0ef          	jal	ra,526 <putc>
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	b7b9                	j	63a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ee:	008b8913          	addi	s2,s7,8
 6f2:	4685                	li	a3,1
 6f4:	4629                	li	a2,10
 6f6:	000bb583          	ld	a1,0(s7)
 6fa:	855a                	mv	a0,s6
 6fc:	e49ff0ef          	jal	ra,544 <printint>
        i += 1;
 700:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 702:	8bca                	mv	s7,s2
      state = 0;
 704:	4981                	li	s3,0
        i += 1;
 706:	bf15                	j	63a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 708:	03860563          	beq	a2,s8,732 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 70c:	07b60963          	beq	a2,s11,77e <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 710:	07800793          	li	a5,120
 714:	fcf613e3          	bne	a2,a5,6da <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 718:	008b8913          	addi	s2,s7,8
 71c:	4681                	li	a3,0
 71e:	4641                	li	a2,16
 720:	000bb583          	ld	a1,0(s7)
 724:	855a                	mv	a0,s6
 726:	e1fff0ef          	jal	ra,544 <printint>
        i += 2;
 72a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 72c:	8bca                	mv	s7,s2
      state = 0;
 72e:	4981                	li	s3,0
        i += 2;
 730:	b729                	j	63a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 732:	008b8913          	addi	s2,s7,8
 736:	4685                	li	a3,1
 738:	4629                	li	a2,10
 73a:	000bb583          	ld	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	e05ff0ef          	jal	ra,544 <printint>
        i += 2;
 744:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 746:	8bca                	mv	s7,s2
      state = 0;
 748:	4981                	li	s3,0
        i += 2;
 74a:	bdc5                	j	63a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 74c:	008b8913          	addi	s2,s7,8
 750:	4681                	li	a3,0
 752:	4629                	li	a2,10
 754:	000be583          	lwu	a1,0(s7)
 758:	855a                	mv	a0,s6
 75a:	debff0ef          	jal	ra,544 <printint>
 75e:	8bca                	mv	s7,s2
      state = 0;
 760:	4981                	li	s3,0
 762:	bde1                	j	63a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 764:	008b8913          	addi	s2,s7,8
 768:	4681                	li	a3,0
 76a:	4629                	li	a2,10
 76c:	000bb583          	ld	a1,0(s7)
 770:	855a                	mv	a0,s6
 772:	dd3ff0ef          	jal	ra,544 <printint>
        i += 1;
 776:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 778:	8bca                	mv	s7,s2
      state = 0;
 77a:	4981                	li	s3,0
        i += 1;
 77c:	bd7d                	j	63a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 77e:	008b8913          	addi	s2,s7,8
 782:	4681                	li	a3,0
 784:	4629                	li	a2,10
 786:	000bb583          	ld	a1,0(s7)
 78a:	855a                	mv	a0,s6
 78c:	db9ff0ef          	jal	ra,544 <printint>
        i += 2;
 790:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 792:	8bca                	mv	s7,s2
      state = 0;
 794:	4981                	li	s3,0
        i += 2;
 796:	b555                	j	63a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 798:	008b8913          	addi	s2,s7,8
 79c:	4681                	li	a3,0
 79e:	4641                	li	a2,16
 7a0:	000be583          	lwu	a1,0(s7)
 7a4:	855a                	mv	a0,s6
 7a6:	d9fff0ef          	jal	ra,544 <printint>
 7aa:	8bca                	mv	s7,s2
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	b571                	j	63a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b0:	008b8913          	addi	s2,s7,8
 7b4:	4681                	li	a3,0
 7b6:	4641                	li	a2,16
 7b8:	000bb583          	ld	a1,0(s7)
 7bc:	855a                	mv	a0,s6
 7be:	d87ff0ef          	jal	ra,544 <printint>
        i += 1;
 7c2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c4:	8bca                	mv	s7,s2
      state = 0;
 7c6:	4981                	li	s3,0
        i += 1;
 7c8:	bd8d                	j	63a <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 7ca:	008b8793          	addi	a5,s7,8
 7ce:	f8f43423          	sd	a5,-120(s0)
 7d2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7d6:	03000593          	li	a1,48
 7da:	855a                	mv	a0,s6
 7dc:	d4bff0ef          	jal	ra,526 <putc>
  putc(fd, 'x');
 7e0:	07800593          	li	a1,120
 7e4:	855a                	mv	a0,s6
 7e6:	d41ff0ef          	jal	ra,526 <putc>
 7ea:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7ec:	03c9d793          	srli	a5,s3,0x3c
 7f0:	97e6                	add	a5,a5,s9
 7f2:	0007c583          	lbu	a1,0(a5)
 7f6:	855a                	mv	a0,s6
 7f8:	d2fff0ef          	jal	ra,526 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7fc:	0992                	slli	s3,s3,0x4
 7fe:	397d                	addiw	s2,s2,-1
 800:	fe0916e3          	bnez	s2,7ec <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 804:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 808:	4981                	li	s3,0
 80a:	bd05                	j	63a <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 80c:	008b8913          	addi	s2,s7,8
 810:	000bc583          	lbu	a1,0(s7)
 814:	855a                	mv	a0,s6
 816:	d11ff0ef          	jal	ra,526 <putc>
 81a:	8bca                	mv	s7,s2
      state = 0;
 81c:	4981                	li	s3,0
 81e:	bd31                	j	63a <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 820:	008b8993          	addi	s3,s7,8
 824:	000bb903          	ld	s2,0(s7)
 828:	00090f63          	beqz	s2,846 <vprintf+0x266>
        for(; *s; s++)
 82c:	00094583          	lbu	a1,0(s2)
 830:	c195                	beqz	a1,854 <vprintf+0x274>
          putc(fd, *s);
 832:	855a                	mv	a0,s6
 834:	cf3ff0ef          	jal	ra,526 <putc>
        for(; *s; s++)
 838:	0905                	addi	s2,s2,1
 83a:	00094583          	lbu	a1,0(s2)
 83e:	f9f5                	bnez	a1,832 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 840:	8bce                	mv	s7,s3
      state = 0;
 842:	4981                	li	s3,0
 844:	bbdd                	j	63a <vprintf+0x5a>
          s = "(null)";
 846:	00000917          	auipc	s2,0x0
 84a:	50a90913          	addi	s2,s2,1290 # d50 <malloc+0x3f4>
        for(; *s; s++)
 84e:	02800593          	li	a1,40
 852:	b7c5                	j	832 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 854:	8bce                	mv	s7,s3
      state = 0;
 856:	4981                	li	s3,0
 858:	b3cd                	j	63a <vprintf+0x5a>
    }
  }
}
 85a:	70e6                	ld	ra,120(sp)
 85c:	7446                	ld	s0,112(sp)
 85e:	74a6                	ld	s1,104(sp)
 860:	7906                	ld	s2,96(sp)
 862:	69e6                	ld	s3,88(sp)
 864:	6a46                	ld	s4,80(sp)
 866:	6aa6                	ld	s5,72(sp)
 868:	6b06                	ld	s6,64(sp)
 86a:	7be2                	ld	s7,56(sp)
 86c:	7c42                	ld	s8,48(sp)
 86e:	7ca2                	ld	s9,40(sp)
 870:	7d02                	ld	s10,32(sp)
 872:	6de2                	ld	s11,24(sp)
 874:	6109                	addi	sp,sp,128
 876:	8082                	ret

0000000000000878 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 878:	715d                	addi	sp,sp,-80
 87a:	ec06                	sd	ra,24(sp)
 87c:	e822                	sd	s0,16(sp)
 87e:	1000                	addi	s0,sp,32
 880:	e010                	sd	a2,0(s0)
 882:	e414                	sd	a3,8(s0)
 884:	e818                	sd	a4,16(s0)
 886:	ec1c                	sd	a5,24(s0)
 888:	03043023          	sd	a6,32(s0)
 88c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 890:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 894:	8622                	mv	a2,s0
 896:	d4bff0ef          	jal	ra,5e0 <vprintf>
}
 89a:	60e2                	ld	ra,24(sp)
 89c:	6442                	ld	s0,16(sp)
 89e:	6161                	addi	sp,sp,80
 8a0:	8082                	ret

00000000000008a2 <printf>:

void
printf(const char *fmt, ...)
{
 8a2:	711d                	addi	sp,sp,-96
 8a4:	ec06                	sd	ra,24(sp)
 8a6:	e822                	sd	s0,16(sp)
 8a8:	1000                	addi	s0,sp,32
 8aa:	e40c                	sd	a1,8(s0)
 8ac:	e810                	sd	a2,16(s0)
 8ae:	ec14                	sd	a3,24(s0)
 8b0:	f018                	sd	a4,32(s0)
 8b2:	f41c                	sd	a5,40(s0)
 8b4:	03043823          	sd	a6,48(s0)
 8b8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8bc:	00840613          	addi	a2,s0,8
 8c0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8c4:	85aa                	mv	a1,a0
 8c6:	4505                	li	a0,1
 8c8:	d19ff0ef          	jal	ra,5e0 <vprintf>
}
 8cc:	60e2                	ld	ra,24(sp)
 8ce:	6442                	ld	s0,16(sp)
 8d0:	6125                	addi	sp,sp,96
 8d2:	8082                	ret

00000000000008d4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8d4:	1141                	addi	sp,sp,-16
 8d6:	e422                	sd	s0,8(sp)
 8d8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8da:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8de:	00000797          	auipc	a5,0x0
 8e2:	7227b783          	ld	a5,1826(a5) # 1000 <freep>
 8e6:	a805                	j	916 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8e8:	4618                	lw	a4,8(a2)
 8ea:	9db9                	addw	a1,a1,a4
 8ec:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f0:	6398                	ld	a4,0(a5)
 8f2:	6318                	ld	a4,0(a4)
 8f4:	fee53823          	sd	a4,-16(a0)
 8f8:	a091                	j	93c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8fa:	ff852703          	lw	a4,-8(a0)
 8fe:	9e39                	addw	a2,a2,a4
 900:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 902:	ff053703          	ld	a4,-16(a0)
 906:	e398                	sd	a4,0(a5)
 908:	a099                	j	94e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90a:	6398                	ld	a4,0(a5)
 90c:	00e7e463          	bltu	a5,a4,914 <free+0x40>
 910:	00e6ea63          	bltu	a3,a4,924 <free+0x50>
{
 914:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 916:	fed7fae3          	bgeu	a5,a3,90a <free+0x36>
 91a:	6398                	ld	a4,0(a5)
 91c:	00e6e463          	bltu	a3,a4,924 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 920:	fee7eae3          	bltu	a5,a4,914 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 924:	ff852583          	lw	a1,-8(a0)
 928:	6390                	ld	a2,0(a5)
 92a:	02059713          	slli	a4,a1,0x20
 92e:	9301                	srli	a4,a4,0x20
 930:	0712                	slli	a4,a4,0x4
 932:	9736                	add	a4,a4,a3
 934:	fae60ae3          	beq	a2,a4,8e8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 938:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 93c:	4790                	lw	a2,8(a5)
 93e:	02061713          	slli	a4,a2,0x20
 942:	9301                	srli	a4,a4,0x20
 944:	0712                	slli	a4,a4,0x4
 946:	973e                	add	a4,a4,a5
 948:	fae689e3          	beq	a3,a4,8fa <free+0x26>
  } else
    p->s.ptr = bp;
 94c:	e394                	sd	a3,0(a5)
  freep = p;
 94e:	00000717          	auipc	a4,0x0
 952:	6af73923          	sd	a5,1714(a4) # 1000 <freep>
}
 956:	6422                	ld	s0,8(sp)
 958:	0141                	addi	sp,sp,16
 95a:	8082                	ret

000000000000095c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 95c:	7139                	addi	sp,sp,-64
 95e:	fc06                	sd	ra,56(sp)
 960:	f822                	sd	s0,48(sp)
 962:	f426                	sd	s1,40(sp)
 964:	f04a                	sd	s2,32(sp)
 966:	ec4e                	sd	s3,24(sp)
 968:	e852                	sd	s4,16(sp)
 96a:	e456                	sd	s5,8(sp)
 96c:	e05a                	sd	s6,0(sp)
 96e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 970:	02051493          	slli	s1,a0,0x20
 974:	9081                	srli	s1,s1,0x20
 976:	04bd                	addi	s1,s1,15
 978:	8091                	srli	s1,s1,0x4
 97a:	0014899b          	addiw	s3,s1,1
 97e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 980:	00000517          	auipc	a0,0x0
 984:	68053503          	ld	a0,1664(a0) # 1000 <freep>
 988:	c515                	beqz	a0,9b4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 98c:	4798                	lw	a4,8(a5)
 98e:	02977f63          	bgeu	a4,s1,9cc <malloc+0x70>
 992:	8a4e                	mv	s4,s3
 994:	0009871b          	sext.w	a4,s3
 998:	6685                	lui	a3,0x1
 99a:	00d77363          	bgeu	a4,a3,9a0 <malloc+0x44>
 99e:	6a05                	lui	s4,0x1
 9a0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9a4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9a8:	00000917          	auipc	s2,0x0
 9ac:	65890913          	addi	s2,s2,1624 # 1000 <freep>
  if(p == SBRK_ERROR)
 9b0:	5afd                	li	s5,-1
 9b2:	a0bd                	j	a20 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 9b4:	00000797          	auipc	a5,0x0
 9b8:	65c78793          	addi	a5,a5,1628 # 1010 <base>
 9bc:	00000717          	auipc	a4,0x0
 9c0:	64f73223          	sd	a5,1604(a4) # 1000 <freep>
 9c4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9c6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9ca:	b7e1                	j	992 <malloc+0x36>
      if(p->s.size == nunits)
 9cc:	02e48b63          	beq	s1,a4,a02 <malloc+0xa6>
        p->s.size -= nunits;
 9d0:	4137073b          	subw	a4,a4,s3
 9d4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9d6:	1702                	slli	a4,a4,0x20
 9d8:	9301                	srli	a4,a4,0x20
 9da:	0712                	slli	a4,a4,0x4
 9dc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9de:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9e2:	00000717          	auipc	a4,0x0
 9e6:	60a73f23          	sd	a0,1566(a4) # 1000 <freep>
      return (void*)(p + 1);
 9ea:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9ee:	70e2                	ld	ra,56(sp)
 9f0:	7442                	ld	s0,48(sp)
 9f2:	74a2                	ld	s1,40(sp)
 9f4:	7902                	ld	s2,32(sp)
 9f6:	69e2                	ld	s3,24(sp)
 9f8:	6a42                	ld	s4,16(sp)
 9fa:	6aa2                	ld	s5,8(sp)
 9fc:	6b02                	ld	s6,0(sp)
 9fe:	6121                	addi	sp,sp,64
 a00:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a02:	6398                	ld	a4,0(a5)
 a04:	e118                	sd	a4,0(a0)
 a06:	bff1                	j	9e2 <malloc+0x86>
  hp->s.size = nu;
 a08:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a0c:	0541                	addi	a0,a0,16
 a0e:	ec7ff0ef          	jal	ra,8d4 <free>
  return freep;
 a12:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a16:	dd61                	beqz	a0,9ee <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a18:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a1a:	4798                	lw	a4,8(a5)
 a1c:	fa9778e3          	bgeu	a4,s1,9cc <malloc+0x70>
    if(p == freep)
 a20:	00093703          	ld	a4,0(s2)
 a24:	853e                	mv	a0,a5
 a26:	fef719e3          	bne	a4,a5,a18 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 a2a:	8552                	mv	a0,s4
 a2c:	9e7ff0ef          	jal	ra,412 <sbrk>
  if(p == SBRK_ERROR)
 a30:	fd551ce3          	bne	a0,s5,a08 <malloc+0xac>
        return 0;
 a34:	4501                	li	a0,0
 a36:	bf65                	j	9ee <malloc+0x92>


user/_p2b1:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    // 1. Attach without init
    printf("[Test 1] Attach without shm_init()...\n");
   8:	00001517          	auipc	a0,0x1
   c:	a7850513          	addi	a0,a0,-1416 # a80 <malloc+0xdc>
  10:	0db000ef          	jal	ra,8ea <printf>
    if (shm_attach() == -1)
  14:	53a000ef          	jal	ra,54e <shm_attach>
  18:	57fd                	li	a5,-1
  1a:	0ef50d63          	beq	a0,a5,114 <main+0x114>
        printf("PASS: shm_attach() correctly failed\n\n");
    else
        printf("FAIL: shm_attach() should not succeed\n\n");
  1e:	00001517          	auipc	a0,0x1
  22:	ab250513          	addi	a0,a0,-1358 # ad0 <malloc+0x12c>
  26:	0c5000ef          	jal	ra,8ea <printf>

    // 2. Destroy without init
    printf("[Test 2] Destroy without shm_init()...\n");
  2a:	00001517          	auipc	a0,0x1
  2e:	ace50513          	addi	a0,a0,-1330 # af8 <malloc+0x154>
  32:	0b9000ef          	jal	ra,8ea <printf>
    if (shm_destroy() == -1)
  36:	528000ef          	jal	ra,55e <shm_destroy>
  3a:	57fd                	li	a5,-1
  3c:	0ef50363          	beq	a0,a5,122 <main+0x122>
        printf("PASS: shm_destroy() correctly failed\n\n");
    else
        printf("FAIL: shm_destroy() should not succeed\n\n");
  40:	00001517          	auipc	a0,0x1
  44:	b0850513          	addi	a0,a0,-1272 # b48 <malloc+0x1a4>
  48:	0a3000ef          	jal	ra,8ea <printf>

    // 3. Early detach
    printf("[Test 3] Detach before attach...\n");
  4c:	00001517          	auipc	a0,0x1
  50:	b2c50513          	addi	a0,a0,-1236 # b78 <malloc+0x1d4>
  54:	097000ef          	jal	ra,8ea <printf>
    shm_init();
  58:	4ee000ef          	jal	ra,546 <shm_init>
    if (shm_detach() == -1)
  5c:	4fa000ef          	jal	ra,556 <shm_detach>
  60:	57fd                	li	a5,-1
  62:	0cf50763          	beq	a0,a5,130 <main+0x130>
        printf("PASS: shm_detach() correctly failed before attach\n\n");
    else
        printf("FAIL: shm_detach() should not succeed\n\n");
  66:	00001517          	auipc	a0,0x1
  6a:	b7250513          	addi	a0,a0,-1166 # bd8 <malloc+0x234>
  6e:	07d000ef          	jal	ra,8ea <printf>

    // 4. Multiple detaches in same process
    printf("[Test 4] Multiple detaches in same process...\n");
  72:	00001517          	auipc	a0,0x1
  76:	b8e50513          	addi	a0,a0,-1138 # c00 <malloc+0x25c>
  7a:	071000ef          	jal	ra,8ea <printf>
    if (shm_attach()) printf("First attach succeeded\n");
  7e:	4d0000ef          	jal	ra,54e <shm_attach>
  82:	0a051e63          	bnez	a0,13e <main+0x13e>
    if (shm_detach() == 0) printf("First detach succeeded\n");
  86:	4d0000ef          	jal	ra,556 <shm_detach>
  8a:	0c050163          	beqz	a0,14c <main+0x14c>

    if (shm_detach() == -1)
  8e:	4c8000ef          	jal	ra,556 <shm_detach>
  92:	57fd                	li	a5,-1
  94:	0cf50363          	beq	a0,a5,15a <main+0x15a>
        printf("PASS: Second detach correctly failed\n\n");
    else
        printf("FAIL: Second detach should not succeed\n\n");
  98:	00001517          	auipc	a0,0x1
  9c:	bf050513          	addi	a0,a0,-1040 # c88 <malloc+0x2e4>
  a0:	04b000ef          	jal	ra,8ea <printf>

    // 5. Attach twice in same process
    printf("[Test 5] Attach twice in same process...\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	c1450513          	addi	a0,a0,-1004 # cb8 <malloc+0x314>
  ac:	03f000ef          	jal	ra,8ea <printf>
    if (shm_attach())
  b0:	49e000ef          	jal	ra,54e <shm_attach>
  b4:	e955                	bnez	a0,168 <main+0x168>
        printf(
            "PASS: Re-attach succeeded (should allow attach after detach)\n");

    if (shm_attach() == -1)
  b6:	498000ef          	jal	ra,54e <shm_attach>
  ba:	57fd                	li	a5,-1
  bc:	0af50d63          	beq	a0,a5,176 <main+0x176>
        printf("PASS: Second attach correctly failed\n\n");
    else
        printf("FAIL: Second attach should not succeed\n\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	c9050513          	addi	a0,a0,-880 # d50 <malloc+0x3ac>
  c8:	023000ef          	jal	ra,8ea <printf>

    printf("Detaching shared memory... \n");
  cc:	00001517          	auipc	a0,0x1
  d0:	cb450513          	addi	a0,a0,-844 # d80 <malloc+0x3dc>
  d4:	017000ef          	jal	ra,8ea <printf>
    if (shm_detach() == 0)
  d8:	47e000ef          	jal	ra,556 <shm_detach>
  dc:	e545                	bnez	a0,184 <main+0x184>
        printf("SUCCESS\n\n");
  de:	00001517          	auipc	a0,0x1
  e2:	cc250513          	addi	a0,a0,-830 # da0 <malloc+0x3fc>
  e6:	005000ef          	jal	ra,8ea <printf>
    else
        printf("ERROR\n\n");

    // 6. Destroy while another process is attached
    printf("[Test 6] Destroy while child attached...\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	cce50513          	addi	a0,a0,-818 # db8 <malloc+0x414>
  f2:	7f8000ef          	jal	ra,8ea <printf>
    if (fork() == 0) {
  f6:	390000ef          	jal	ra,486 <fork>
  fa:	e955                	bnez	a0,1ae <main+0x1ae>
        // Child
        if (shm_attach()) printf("[Child] Attached to shared memory\n");
  fc:	452000ef          	jal	ra,54e <shm_attach>
 100:	e949                	bnez	a0,192 <main+0x192>

        pause(7);  // allow parent to attempt destroy
 102:	451d                	li	a0,7
 104:	41a000ef          	jal	ra,51e <pause>
        if (shm_detach() == 0) printf("[Child] Detached successfully\n");
 108:	44e000ef          	jal	ra,556 <shm_detach>
 10c:	c951                	beqz	a0,1a0 <main+0x1a0>

        exit(0);
 10e:	4501                	li	a0,0
 110:	37e000ef          	jal	ra,48e <exit>
        printf("PASS: shm_attach() correctly failed\n\n");
 114:	00001517          	auipc	a0,0x1
 118:	99450513          	addi	a0,a0,-1644 # aa8 <malloc+0x104>
 11c:	7ce000ef          	jal	ra,8ea <printf>
 120:	b729                	j	2a <main+0x2a>
        printf("PASS: shm_destroy() correctly failed\n\n");
 122:	00001517          	auipc	a0,0x1
 126:	9fe50513          	addi	a0,a0,-1538 # b20 <malloc+0x17c>
 12a:	7c0000ef          	jal	ra,8ea <printf>
 12e:	bf39                	j	4c <main+0x4c>
        printf("PASS: shm_detach() correctly failed before attach\n\n");
 130:	00001517          	auipc	a0,0x1
 134:	a7050513          	addi	a0,a0,-1424 # ba0 <malloc+0x1fc>
 138:	7b2000ef          	jal	ra,8ea <printf>
 13c:	bf1d                	j	72 <main+0x72>
    if (shm_attach()) printf("First attach succeeded\n");
 13e:	00001517          	auipc	a0,0x1
 142:	af250513          	addi	a0,a0,-1294 # c30 <malloc+0x28c>
 146:	7a4000ef          	jal	ra,8ea <printf>
 14a:	bf35                	j	86 <main+0x86>
    if (shm_detach() == 0) printf("First detach succeeded\n");
 14c:	00001517          	auipc	a0,0x1
 150:	afc50513          	addi	a0,a0,-1284 # c48 <malloc+0x2a4>
 154:	796000ef          	jal	ra,8ea <printf>
 158:	bf1d                	j	8e <main+0x8e>
        printf("PASS: Second detach correctly failed\n\n");
 15a:	00001517          	auipc	a0,0x1
 15e:	b0650513          	addi	a0,a0,-1274 # c60 <malloc+0x2bc>
 162:	788000ef          	jal	ra,8ea <printf>
 166:	bf3d                	j	a4 <main+0xa4>
        printf(
 168:	00001517          	auipc	a0,0x1
 16c:	b8050513          	addi	a0,a0,-1152 # ce8 <malloc+0x344>
 170:	77a000ef          	jal	ra,8ea <printf>
 174:	b789                	j	b6 <main+0xb6>
        printf("PASS: Second attach correctly failed\n\n");
 176:	00001517          	auipc	a0,0x1
 17a:	bb250513          	addi	a0,a0,-1102 # d28 <malloc+0x384>
 17e:	76c000ef          	jal	ra,8ea <printf>
 182:	b7a9                	j	cc <main+0xcc>
        printf("ERROR\n\n");
 184:	00001517          	auipc	a0,0x1
 188:	c2c50513          	addi	a0,a0,-980 # db0 <malloc+0x40c>
 18c:	75e000ef          	jal	ra,8ea <printf>
 190:	bfa9                	j	ea <main+0xea>
        if (shm_attach()) printf("[Child] Attached to shared memory\n");
 192:	00001517          	auipc	a0,0x1
 196:	c5650513          	addi	a0,a0,-938 # de8 <malloc+0x444>
 19a:	750000ef          	jal	ra,8ea <printf>
 19e:	b795                	j	102 <main+0x102>
        if (shm_detach() == 0) printf("[Child] Detached successfully\n");
 1a0:	00001517          	auipc	a0,0x1
 1a4:	c7050513          	addi	a0,a0,-912 # e10 <malloc+0x46c>
 1a8:	742000ef          	jal	ra,8ea <printf>
 1ac:	b78d                	j	10e <main+0x10e>
    } else {
        // Parent
        pause(2);  // give child time to attach
 1ae:	4509                	li	a0,2
 1b0:	36e000ef          	jal	ra,51e <pause>
        
        if (shm_destroy() == -1)
 1b4:	3aa000ef          	jal	ra,55e <shm_destroy>
 1b8:	57fd                	li	a5,-1
 1ba:	02f50163          	beq	a0,a5,1dc <main+0x1dc>
            printf(
                "[Parent] PASS: shm_destroy() failed while child attached\n");
        else
            printf("[Parent] FAIL: shm_destroy() should not succeed\n");
 1be:	00001517          	auipc	a0,0x1
 1c2:	cb250513          	addi	a0,a0,-846 # e70 <malloc+0x4cc>
 1c6:	724000ef          	jal	ra,8ea <printf>

        wait(0);
 1ca:	4501                	li	a0,0
 1cc:	2ca000ef          	jal	ra,496 <wait>
        if (shm_destroy() == 0)
 1d0:	38e000ef          	jal	ra,55e <shm_destroy>
 1d4:	c919                	beqz	a0,1ea <main+0x1ea>
            printf(
                "[Parent] PASS: shm_destroy() succeeded after child "
                "detached\n");
    }

    exit(0);
 1d6:	4501                	li	a0,0
 1d8:	2b6000ef          	jal	ra,48e <exit>
            printf(
 1dc:	00001517          	auipc	a0,0x1
 1e0:	c5450513          	addi	a0,a0,-940 # e30 <malloc+0x48c>
 1e4:	706000ef          	jal	ra,8ea <printf>
 1e8:	b7cd                	j	1ca <main+0x1ca>
            printf(
 1ea:	00001517          	auipc	a0,0x1
 1ee:	cbe50513          	addi	a0,a0,-834 # ea8 <malloc+0x504>
 1f2:	6f8000ef          	jal	ra,8ea <printf>
 1f6:	b7c5                	j	1d6 <main+0x1d6>

00000000000001f8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e406                	sd	ra,8(sp)
 1fc:	e022                	sd	s0,0(sp)
 1fe:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 200:	e01ff0ef          	jal	ra,0 <main>
  exit(r);
 204:	28a000ef          	jal	ra,48e <exit>

0000000000000208 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 20e:	87aa                	mv	a5,a0
 210:	0585                	addi	a1,a1,1
 212:	0785                	addi	a5,a5,1
 214:	fff5c703          	lbu	a4,-1(a1)
 218:	fee78fa3          	sb	a4,-1(a5)
 21c:	fb75                	bnez	a4,210 <strcpy+0x8>
    ;
  return os;
}
 21e:	6422                	ld	s0,8(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret

0000000000000224 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 224:	1141                	addi	sp,sp,-16
 226:	e422                	sd	s0,8(sp)
 228:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 22a:	00054783          	lbu	a5,0(a0)
 22e:	cb91                	beqz	a5,242 <strcmp+0x1e>
 230:	0005c703          	lbu	a4,0(a1)
 234:	00f71763          	bne	a4,a5,242 <strcmp+0x1e>
    p++, q++;
 238:	0505                	addi	a0,a0,1
 23a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 23c:	00054783          	lbu	a5,0(a0)
 240:	fbe5                	bnez	a5,230 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 242:	0005c503          	lbu	a0,0(a1)
}
 246:	40a7853b          	subw	a0,a5,a0
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret

0000000000000250 <strlen>:

uint
strlen(const char *s)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 256:	00054783          	lbu	a5,0(a0)
 25a:	cf91                	beqz	a5,276 <strlen+0x26>
 25c:	0505                	addi	a0,a0,1
 25e:	87aa                	mv	a5,a0
 260:	4685                	li	a3,1
 262:	9e89                	subw	a3,a3,a0
 264:	00f6853b          	addw	a0,a3,a5
 268:	0785                	addi	a5,a5,1
 26a:	fff7c703          	lbu	a4,-1(a5)
 26e:	fb7d                	bnez	a4,264 <strlen+0x14>
    ;
  return n;
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret
  for(n = 0; s[n]; n++)
 276:	4501                	li	a0,0
 278:	bfe5                	j	270 <strlen+0x20>

000000000000027a <memset>:

void*
memset(void *dst, int c, uint n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 280:	ca19                	beqz	a2,296 <memset+0x1c>
 282:	87aa                	mv	a5,a0
 284:	1602                	slli	a2,a2,0x20
 286:	9201                	srli	a2,a2,0x20
 288:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 28c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 290:	0785                	addi	a5,a5,1
 292:	fee79de3          	bne	a5,a4,28c <memset+0x12>
  }
  return dst;
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret

000000000000029c <strchr>:

char*
strchr(const char *s, char c)
{
 29c:	1141                	addi	sp,sp,-16
 29e:	e422                	sd	s0,8(sp)
 2a0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2a2:	00054783          	lbu	a5,0(a0)
 2a6:	cb99                	beqz	a5,2bc <strchr+0x20>
    if(*s == c)
 2a8:	00f58763          	beq	a1,a5,2b6 <strchr+0x1a>
  for(; *s; s++)
 2ac:	0505                	addi	a0,a0,1
 2ae:	00054783          	lbu	a5,0(a0)
 2b2:	fbfd                	bnez	a5,2a8 <strchr+0xc>
      return (char*)s;
  return 0;
 2b4:	4501                	li	a0,0
}
 2b6:	6422                	ld	s0,8(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret
  return 0;
 2bc:	4501                	li	a0,0
 2be:	bfe5                	j	2b6 <strchr+0x1a>

00000000000002c0 <gets>:

char*
gets(char *buf, int max)
{
 2c0:	711d                	addi	sp,sp,-96
 2c2:	ec86                	sd	ra,88(sp)
 2c4:	e8a2                	sd	s0,80(sp)
 2c6:	e4a6                	sd	s1,72(sp)
 2c8:	e0ca                	sd	s2,64(sp)
 2ca:	fc4e                	sd	s3,56(sp)
 2cc:	f852                	sd	s4,48(sp)
 2ce:	f456                	sd	s5,40(sp)
 2d0:	f05a                	sd	s6,32(sp)
 2d2:	ec5e                	sd	s7,24(sp)
 2d4:	1080                	addi	s0,sp,96
 2d6:	8baa                	mv	s7,a0
 2d8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2da:	892a                	mv	s2,a0
 2dc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2de:	4aa9                	li	s5,10
 2e0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2e2:	89a6                	mv	s3,s1
 2e4:	2485                	addiw	s1,s1,1
 2e6:	0344d663          	bge	s1,s4,312 <gets+0x52>
    cc = read(0, &c, 1);
 2ea:	4605                	li	a2,1
 2ec:	faf40593          	addi	a1,s0,-81
 2f0:	4501                	li	a0,0
 2f2:	1b4000ef          	jal	ra,4a6 <read>
    if(cc < 1)
 2f6:	00a05e63          	blez	a0,312 <gets+0x52>
    buf[i++] = c;
 2fa:	faf44783          	lbu	a5,-81(s0)
 2fe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 302:	01578763          	beq	a5,s5,310 <gets+0x50>
 306:	0905                	addi	s2,s2,1
 308:	fd679de3          	bne	a5,s6,2e2 <gets+0x22>
  for(i=0; i+1 < max; ){
 30c:	89a6                	mv	s3,s1
 30e:	a011                	j	312 <gets+0x52>
 310:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 312:	99de                	add	s3,s3,s7
 314:	00098023          	sb	zero,0(s3)
  return buf;
}
 318:	855e                	mv	a0,s7
 31a:	60e6                	ld	ra,88(sp)
 31c:	6446                	ld	s0,80(sp)
 31e:	64a6                	ld	s1,72(sp)
 320:	6906                	ld	s2,64(sp)
 322:	79e2                	ld	s3,56(sp)
 324:	7a42                	ld	s4,48(sp)
 326:	7aa2                	ld	s5,40(sp)
 328:	7b02                	ld	s6,32(sp)
 32a:	6be2                	ld	s7,24(sp)
 32c:	6125                	addi	sp,sp,96
 32e:	8082                	ret

0000000000000330 <stat>:

int
stat(const char *n, struct stat *st)
{
 330:	1101                	addi	sp,sp,-32
 332:	ec06                	sd	ra,24(sp)
 334:	e822                	sd	s0,16(sp)
 336:	e426                	sd	s1,8(sp)
 338:	e04a                	sd	s2,0(sp)
 33a:	1000                	addi	s0,sp,32
 33c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 33e:	4581                	li	a1,0
 340:	18e000ef          	jal	ra,4ce <open>
  if(fd < 0)
 344:	02054163          	bltz	a0,366 <stat+0x36>
 348:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 34a:	85ca                	mv	a1,s2
 34c:	19a000ef          	jal	ra,4e6 <fstat>
 350:	892a                	mv	s2,a0
  close(fd);
 352:	8526                	mv	a0,s1
 354:	162000ef          	jal	ra,4b6 <close>
  return r;
}
 358:	854a                	mv	a0,s2
 35a:	60e2                	ld	ra,24(sp)
 35c:	6442                	ld	s0,16(sp)
 35e:	64a2                	ld	s1,8(sp)
 360:	6902                	ld	s2,0(sp)
 362:	6105                	addi	sp,sp,32
 364:	8082                	ret
    return -1;
 366:	597d                	li	s2,-1
 368:	bfc5                	j	358 <stat+0x28>

000000000000036a <atoi>:

int
atoi(const char *s)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 370:	00054603          	lbu	a2,0(a0)
 374:	fd06079b          	addiw	a5,a2,-48
 378:	0ff7f793          	andi	a5,a5,255
 37c:	4725                	li	a4,9
 37e:	02f76963          	bltu	a4,a5,3b0 <atoi+0x46>
 382:	86aa                	mv	a3,a0
  n = 0;
 384:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 386:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 388:	0685                	addi	a3,a3,1
 38a:	0025179b          	slliw	a5,a0,0x2
 38e:	9fa9                	addw	a5,a5,a0
 390:	0017979b          	slliw	a5,a5,0x1
 394:	9fb1                	addw	a5,a5,a2
 396:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 39a:	0006c603          	lbu	a2,0(a3)
 39e:	fd06071b          	addiw	a4,a2,-48
 3a2:	0ff77713          	andi	a4,a4,255
 3a6:	fee5f1e3          	bgeu	a1,a4,388 <atoi+0x1e>
  return n;
}
 3aa:	6422                	ld	s0,8(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
  n = 0;
 3b0:	4501                	li	a0,0
 3b2:	bfe5                	j	3aa <atoi+0x40>

00000000000003b4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e422                	sd	s0,8(sp)
 3b8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ba:	02b57463          	bgeu	a0,a1,3e2 <memmove+0x2e>
    while(n-- > 0)
 3be:	00c05f63          	blez	a2,3dc <memmove+0x28>
 3c2:	1602                	slli	a2,a2,0x20
 3c4:	9201                	srli	a2,a2,0x20
 3c6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ca:	872a                	mv	a4,a0
      *dst++ = *src++;
 3cc:	0585                	addi	a1,a1,1
 3ce:	0705                	addi	a4,a4,1
 3d0:	fff5c683          	lbu	a3,-1(a1)
 3d4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d8:	fee79ae3          	bne	a5,a4,3cc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3dc:	6422                	ld	s0,8(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret
    dst += n;
 3e2:	00c50733          	add	a4,a0,a2
    src += n;
 3e6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e8:	fec05ae3          	blez	a2,3dc <memmove+0x28>
 3ec:	fff6079b          	addiw	a5,a2,-1
 3f0:	1782                	slli	a5,a5,0x20
 3f2:	9381                	srli	a5,a5,0x20
 3f4:	fff7c793          	not	a5,a5
 3f8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3fa:	15fd                	addi	a1,a1,-1
 3fc:	177d                	addi	a4,a4,-1
 3fe:	0005c683          	lbu	a3,0(a1)
 402:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 406:	fee79ae3          	bne	a5,a4,3fa <memmove+0x46>
 40a:	bfc9                	j	3dc <memmove+0x28>

000000000000040c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40c:	1141                	addi	sp,sp,-16
 40e:	e422                	sd	s0,8(sp)
 410:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 412:	ca05                	beqz	a2,442 <memcmp+0x36>
 414:	fff6069b          	addiw	a3,a2,-1
 418:	1682                	slli	a3,a3,0x20
 41a:	9281                	srli	a3,a3,0x20
 41c:	0685                	addi	a3,a3,1
 41e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 420:	00054783          	lbu	a5,0(a0)
 424:	0005c703          	lbu	a4,0(a1)
 428:	00e79863          	bne	a5,a4,438 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 42c:	0505                	addi	a0,a0,1
    p2++;
 42e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 430:	fed518e3          	bne	a0,a3,420 <memcmp+0x14>
  }
  return 0;
 434:	4501                	li	a0,0
 436:	a019                	j	43c <memcmp+0x30>
      return *p1 - *p2;
 438:	40e7853b          	subw	a0,a5,a4
}
 43c:	6422                	ld	s0,8(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret
  return 0;
 442:	4501                	li	a0,0
 444:	bfe5                	j	43c <memcmp+0x30>

0000000000000446 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 446:	1141                	addi	sp,sp,-16
 448:	e406                	sd	ra,8(sp)
 44a:	e022                	sd	s0,0(sp)
 44c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 44e:	f67ff0ef          	jal	ra,3b4 <memmove>
}
 452:	60a2                	ld	ra,8(sp)
 454:	6402                	ld	s0,0(sp)
 456:	0141                	addi	sp,sp,16
 458:	8082                	ret

000000000000045a <sbrk>:

char *
sbrk(int n) {
 45a:	1141                	addi	sp,sp,-16
 45c:	e406                	sd	ra,8(sp)
 45e:	e022                	sd	s0,0(sp)
 460:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 462:	4585                	li	a1,1
 464:	0b2000ef          	jal	ra,516 <sys_sbrk>
}
 468:	60a2                	ld	ra,8(sp)
 46a:	6402                	ld	s0,0(sp)
 46c:	0141                	addi	sp,sp,16
 46e:	8082                	ret

0000000000000470 <sbrklazy>:

char *
sbrklazy(int n) {
 470:	1141                	addi	sp,sp,-16
 472:	e406                	sd	ra,8(sp)
 474:	e022                	sd	s0,0(sp)
 476:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 478:	4589                	li	a1,2
 47a:	09c000ef          	jal	ra,516 <sys_sbrk>
}
 47e:	60a2                	ld	ra,8(sp)
 480:	6402                	ld	s0,0(sp)
 482:	0141                	addi	sp,sp,16
 484:	8082                	ret

0000000000000486 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 486:	4885                	li	a7,1
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <exit>:
.global exit
exit:
 li a7, SYS_exit
 48e:	4889                	li	a7,2
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <wait>:
.global wait
wait:
 li a7, SYS_wait
 496:	488d                	li	a7,3
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 49e:	4891                	li	a7,4
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <read>:
.global read
read:
 li a7, SYS_read
 4a6:	4895                	li	a7,5
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <write>:
.global write
write:
 li a7, SYS_write
 4ae:	48c1                	li	a7,16
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <close>:
.global close
close:
 li a7, SYS_close
 4b6:	48d5                	li	a7,21
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <kill>:
.global kill
kill:
 li a7, SYS_kill
 4be:	4899                	li	a7,6
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4c6:	489d                	li	a7,7
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <open>:
.global open
open:
 li a7, SYS_open
 4ce:	48bd                	li	a7,15
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4d6:	48c5                	li	a7,17
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4de:	48c9                	li	a7,18
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e6:	48a1                	li	a7,8
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <link>:
.global link
link:
 li a7, SYS_link
 4ee:	48cd                	li	a7,19
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4f6:	48d1                	li	a7,20
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4fe:	48a5                	li	a7,9
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <dup>:
.global dup
dup:
 li a7, SYS_dup
 506:	48a9                	li	a7,10
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 50e:	48ad                	li	a7,11
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 516:	48b1                	li	a7,12
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <pause>:
.global pause
pause:
 li a7, SYS_pause
 51e:	48b5                	li	a7,13
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 526:	48b9                	li	a7,14
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <tfork>:
.global tfork
tfork:
 li a7, SYS_tfork
 52e:	48d9                	li	a7,22
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 536:	48dd                	li	a7,23
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <tfork2>:
.global tfork2
tfork2:
 li a7, SYS_tfork2
 53e:	48e1                	li	a7,24
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <shm_init>:
.global shm_init
shm_init:
 li a7, SYS_shm_init
 546:	48e5                	li	a7,25
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <shm_attach>:
.global shm_attach
shm_attach:
 li a7, SYS_shm_attach
 54e:	48e9                	li	a7,26
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <shm_detach>:
.global shm_detach
shm_detach:
 li a7, SYS_shm_detach
 556:	48ed                	li	a7,27
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <shm_destroy>:
.global shm_destroy
shm_destroy:
 li a7, SYS_shm_destroy
 55e:	48f1                	li	a7,28
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <shm_refcount>:
.global shm_refcount
shm_refcount:
 li a7, SYS_shm_refcount
 566:	48f5                	li	a7,29
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 56e:	1101                	addi	sp,sp,-32
 570:	ec06                	sd	ra,24(sp)
 572:	e822                	sd	s0,16(sp)
 574:	1000                	addi	s0,sp,32
 576:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 57a:	4605                	li	a2,1
 57c:	fef40593          	addi	a1,s0,-17
 580:	f2fff0ef          	jal	ra,4ae <write>
}
 584:	60e2                	ld	ra,24(sp)
 586:	6442                	ld	s0,16(sp)
 588:	6105                	addi	sp,sp,32
 58a:	8082                	ret

000000000000058c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 58c:	715d                	addi	sp,sp,-80
 58e:	e486                	sd	ra,72(sp)
 590:	e0a2                	sd	s0,64(sp)
 592:	fc26                	sd	s1,56(sp)
 594:	f84a                	sd	s2,48(sp)
 596:	f44e                	sd	s3,40(sp)
 598:	0880                	addi	s0,sp,80
 59a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 59c:	c299                	beqz	a3,5a2 <printint+0x16>
 59e:	0805c163          	bltz	a1,620 <printint+0x94>
  neg = 0;
 5a2:	4881                	li	a7,0
 5a4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5a8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5aa:	00001517          	auipc	a0,0x1
 5ae:	94650513          	addi	a0,a0,-1722 # ef0 <digits>
 5b2:	883e                	mv	a6,a5
 5b4:	2785                	addiw	a5,a5,1
 5b6:	02c5f733          	remu	a4,a1,a2
 5ba:	972a                	add	a4,a4,a0
 5bc:	00074703          	lbu	a4,0(a4)
 5c0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5c4:	872e                	mv	a4,a1
 5c6:	02c5d5b3          	divu	a1,a1,a2
 5ca:	0685                	addi	a3,a3,1
 5cc:	fec773e3          	bgeu	a4,a2,5b2 <printint+0x26>
  if(neg)
 5d0:	00088b63          	beqz	a7,5e6 <printint+0x5a>
    buf[i++] = '-';
 5d4:	fd040713          	addi	a4,s0,-48
 5d8:	97ba                	add	a5,a5,a4
 5da:	02d00713          	li	a4,45
 5de:	fee78423          	sb	a4,-24(a5)
 5e2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5e6:	02f05663          	blez	a5,612 <printint+0x86>
 5ea:	fb840713          	addi	a4,s0,-72
 5ee:	00f704b3          	add	s1,a4,a5
 5f2:	fff70993          	addi	s3,a4,-1
 5f6:	99be                	add	s3,s3,a5
 5f8:	37fd                	addiw	a5,a5,-1
 5fa:	1782                	slli	a5,a5,0x20
 5fc:	9381                	srli	a5,a5,0x20
 5fe:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 602:	fff4c583          	lbu	a1,-1(s1)
 606:	854a                	mv	a0,s2
 608:	f67ff0ef          	jal	ra,56e <putc>
  while(--i >= 0)
 60c:	14fd                	addi	s1,s1,-1
 60e:	ff349ae3          	bne	s1,s3,602 <printint+0x76>
}
 612:	60a6                	ld	ra,72(sp)
 614:	6406                	ld	s0,64(sp)
 616:	74e2                	ld	s1,56(sp)
 618:	7942                	ld	s2,48(sp)
 61a:	79a2                	ld	s3,40(sp)
 61c:	6161                	addi	sp,sp,80
 61e:	8082                	ret
    x = -xx;
 620:	40b005b3          	neg	a1,a1
    neg = 1;
 624:	4885                	li	a7,1
    x = -xx;
 626:	bfbd                	j	5a4 <printint+0x18>

0000000000000628 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 628:	7119                	addi	sp,sp,-128
 62a:	fc86                	sd	ra,120(sp)
 62c:	f8a2                	sd	s0,112(sp)
 62e:	f4a6                	sd	s1,104(sp)
 630:	f0ca                	sd	s2,96(sp)
 632:	ecce                	sd	s3,88(sp)
 634:	e8d2                	sd	s4,80(sp)
 636:	e4d6                	sd	s5,72(sp)
 638:	e0da                	sd	s6,64(sp)
 63a:	fc5e                	sd	s7,56(sp)
 63c:	f862                	sd	s8,48(sp)
 63e:	f466                	sd	s9,40(sp)
 640:	f06a                	sd	s10,32(sp)
 642:	ec6e                	sd	s11,24(sp)
 644:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 646:	0005c903          	lbu	s2,0(a1)
 64a:	24090c63          	beqz	s2,8a2 <vprintf+0x27a>
 64e:	8b2a                	mv	s6,a0
 650:	8a2e                	mv	s4,a1
 652:	8bb2                	mv	s7,a2
  state = 0;
 654:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 656:	4481                	li	s1,0
 658:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 65a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 65e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 662:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 666:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66a:	00001c97          	auipc	s9,0x1
 66e:	886c8c93          	addi	s9,s9,-1914 # ef0 <digits>
 672:	a005                	j	692 <vprintf+0x6a>
        putc(fd, c0);
 674:	85ca                	mv	a1,s2
 676:	855a                	mv	a0,s6
 678:	ef7ff0ef          	jal	ra,56e <putc>
 67c:	a019                	j	682 <vprintf+0x5a>
    } else if(state == '%'){
 67e:	03598263          	beq	s3,s5,6a2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 682:	2485                	addiw	s1,s1,1
 684:	8726                	mv	a4,s1
 686:	009a07b3          	add	a5,s4,s1
 68a:	0007c903          	lbu	s2,0(a5)
 68e:	20090a63          	beqz	s2,8a2 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 692:	0009079b          	sext.w	a5,s2
    if(state == 0){
 696:	fe0994e3          	bnez	s3,67e <vprintf+0x56>
      if(c0 == '%'){
 69a:	fd579de3          	bne	a5,s5,674 <vprintf+0x4c>
        state = '%';
 69e:	89be                	mv	s3,a5
 6a0:	b7cd                	j	682 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6a2:	c3c1                	beqz	a5,722 <vprintf+0xfa>
 6a4:	00ea06b3          	add	a3,s4,a4
 6a8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6ac:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6ae:	c681                	beqz	a3,6b6 <vprintf+0x8e>
 6b0:	9752                	add	a4,a4,s4
 6b2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6b6:	03878e63          	beq	a5,s8,6f2 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 6ba:	05a78863          	beq	a5,s10,70a <vprintf+0xe2>
      } else if(c0 == 'u'){
 6be:	0db78b63          	beq	a5,s11,794 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6c2:	07800713          	li	a4,120
 6c6:	10e78d63          	beq	a5,a4,7e0 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6ca:	07000713          	li	a4,112
 6ce:	14e78263          	beq	a5,a4,812 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 6d2:	06300713          	li	a4,99
 6d6:	16e78f63          	beq	a5,a4,854 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 6da:	07300713          	li	a4,115
 6de:	18e78563          	beq	a5,a4,868 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6e2:	05579063          	bne	a5,s5,722 <vprintf+0xfa>
        putc(fd, '%');
 6e6:	85d6                	mv	a1,s5
 6e8:	855a                	mv	a0,s6
 6ea:	e85ff0ef          	jal	ra,56e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bf49                	j	682 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 6f2:	008b8913          	addi	s2,s7,8
 6f6:	4685                	li	a3,1
 6f8:	4629                	li	a2,10
 6fa:	000ba583          	lw	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	e8dff0ef          	jal	ra,58c <printint>
 704:	8bca                	mv	s7,s2
      state = 0;
 706:	4981                	li	s3,0
 708:	bfad                	j	682 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 70a:	03868663          	beq	a3,s8,736 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 70e:	05a68163          	beq	a3,s10,750 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 712:	09b68d63          	beq	a3,s11,7ac <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 716:	03a68f63          	beq	a3,s10,754 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 71a:	07800793          	li	a5,120
 71e:	0cf68d63          	beq	a3,a5,7f8 <vprintf+0x1d0>
        putc(fd, '%');
 722:	85d6                	mv	a1,s5
 724:	855a                	mv	a0,s6
 726:	e49ff0ef          	jal	ra,56e <putc>
        putc(fd, c0);
 72a:	85ca                	mv	a1,s2
 72c:	855a                	mv	a0,s6
 72e:	e41ff0ef          	jal	ra,56e <putc>
      state = 0;
 732:	4981                	li	s3,0
 734:	b7b9                	j	682 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 736:	008b8913          	addi	s2,s7,8
 73a:	4685                	li	a3,1
 73c:	4629                	li	a2,10
 73e:	000bb583          	ld	a1,0(s7)
 742:	855a                	mv	a0,s6
 744:	e49ff0ef          	jal	ra,58c <printint>
        i += 1;
 748:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 74a:	8bca                	mv	s7,s2
      state = 0;
 74c:	4981                	li	s3,0
        i += 1;
 74e:	bf15                	j	682 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 750:	03860563          	beq	a2,s8,77a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 754:	07b60963          	beq	a2,s11,7c6 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 758:	07800793          	li	a5,120
 75c:	fcf613e3          	bne	a2,a5,722 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 760:	008b8913          	addi	s2,s7,8
 764:	4681                	li	a3,0
 766:	4641                	li	a2,16
 768:	000bb583          	ld	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	e1fff0ef          	jal	ra,58c <printint>
        i += 2;
 772:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 774:	8bca                	mv	s7,s2
      state = 0;
 776:	4981                	li	s3,0
        i += 2;
 778:	b729                	j	682 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 77a:	008b8913          	addi	s2,s7,8
 77e:	4685                	li	a3,1
 780:	4629                	li	a2,10
 782:	000bb583          	ld	a1,0(s7)
 786:	855a                	mv	a0,s6
 788:	e05ff0ef          	jal	ra,58c <printint>
        i += 2;
 78c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 78e:	8bca                	mv	s7,s2
      state = 0;
 790:	4981                	li	s3,0
        i += 2;
 792:	bdc5                	j	682 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 794:	008b8913          	addi	s2,s7,8
 798:	4681                	li	a3,0
 79a:	4629                	li	a2,10
 79c:	000be583          	lwu	a1,0(s7)
 7a0:	855a                	mv	a0,s6
 7a2:	debff0ef          	jal	ra,58c <printint>
 7a6:	8bca                	mv	s7,s2
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bde1                	j	682 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ac:	008b8913          	addi	s2,s7,8
 7b0:	4681                	li	a3,0
 7b2:	4629                	li	a2,10
 7b4:	000bb583          	ld	a1,0(s7)
 7b8:	855a                	mv	a0,s6
 7ba:	dd3ff0ef          	jal	ra,58c <printint>
        i += 1;
 7be:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c0:	8bca                	mv	s7,s2
      state = 0;
 7c2:	4981                	li	s3,0
        i += 1;
 7c4:	bd7d                	j	682 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c6:	008b8913          	addi	s2,s7,8
 7ca:	4681                	li	a3,0
 7cc:	4629                	li	a2,10
 7ce:	000bb583          	ld	a1,0(s7)
 7d2:	855a                	mv	a0,s6
 7d4:	db9ff0ef          	jal	ra,58c <printint>
        i += 2;
 7d8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7da:	8bca                	mv	s7,s2
      state = 0;
 7dc:	4981                	li	s3,0
        i += 2;
 7de:	b555                	j	682 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7e0:	008b8913          	addi	s2,s7,8
 7e4:	4681                	li	a3,0
 7e6:	4641                	li	a2,16
 7e8:	000be583          	lwu	a1,0(s7)
 7ec:	855a                	mv	a0,s6
 7ee:	d9fff0ef          	jal	ra,58c <printint>
 7f2:	8bca                	mv	s7,s2
      state = 0;
 7f4:	4981                	li	s3,0
 7f6:	b571                	j	682 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7f8:	008b8913          	addi	s2,s7,8
 7fc:	4681                	li	a3,0
 7fe:	4641                	li	a2,16
 800:	000bb583          	ld	a1,0(s7)
 804:	855a                	mv	a0,s6
 806:	d87ff0ef          	jal	ra,58c <printint>
        i += 1;
 80a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 80c:	8bca                	mv	s7,s2
      state = 0;
 80e:	4981                	li	s3,0
        i += 1;
 810:	bd8d                	j	682 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 812:	008b8793          	addi	a5,s7,8
 816:	f8f43423          	sd	a5,-120(s0)
 81a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 81e:	03000593          	li	a1,48
 822:	855a                	mv	a0,s6
 824:	d4bff0ef          	jal	ra,56e <putc>
  putc(fd, 'x');
 828:	07800593          	li	a1,120
 82c:	855a                	mv	a0,s6
 82e:	d41ff0ef          	jal	ra,56e <putc>
 832:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 834:	03c9d793          	srli	a5,s3,0x3c
 838:	97e6                	add	a5,a5,s9
 83a:	0007c583          	lbu	a1,0(a5)
 83e:	855a                	mv	a0,s6
 840:	d2fff0ef          	jal	ra,56e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 844:	0992                	slli	s3,s3,0x4
 846:	397d                	addiw	s2,s2,-1
 848:	fe0916e3          	bnez	s2,834 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 84c:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 850:	4981                	li	s3,0
 852:	bd05                	j	682 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 854:	008b8913          	addi	s2,s7,8
 858:	000bc583          	lbu	a1,0(s7)
 85c:	855a                	mv	a0,s6
 85e:	d11ff0ef          	jal	ra,56e <putc>
 862:	8bca                	mv	s7,s2
      state = 0;
 864:	4981                	li	s3,0
 866:	bd31                	j	682 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 868:	008b8993          	addi	s3,s7,8
 86c:	000bb903          	ld	s2,0(s7)
 870:	00090f63          	beqz	s2,88e <vprintf+0x266>
        for(; *s; s++)
 874:	00094583          	lbu	a1,0(s2)
 878:	c195                	beqz	a1,89c <vprintf+0x274>
          putc(fd, *s);
 87a:	855a                	mv	a0,s6
 87c:	cf3ff0ef          	jal	ra,56e <putc>
        for(; *s; s++)
 880:	0905                	addi	s2,s2,1
 882:	00094583          	lbu	a1,0(s2)
 886:	f9f5                	bnez	a1,87a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 888:	8bce                	mv	s7,s3
      state = 0;
 88a:	4981                	li	s3,0
 88c:	bbdd                	j	682 <vprintf+0x5a>
          s = "(null)";
 88e:	00000917          	auipc	s2,0x0
 892:	65a90913          	addi	s2,s2,1626 # ee8 <malloc+0x544>
        for(; *s; s++)
 896:	02800593          	li	a1,40
 89a:	b7c5                	j	87a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 89c:	8bce                	mv	s7,s3
      state = 0;
 89e:	4981                	li	s3,0
 8a0:	b3cd                	j	682 <vprintf+0x5a>
    }
  }
}
 8a2:	70e6                	ld	ra,120(sp)
 8a4:	7446                	ld	s0,112(sp)
 8a6:	74a6                	ld	s1,104(sp)
 8a8:	7906                	ld	s2,96(sp)
 8aa:	69e6                	ld	s3,88(sp)
 8ac:	6a46                	ld	s4,80(sp)
 8ae:	6aa6                	ld	s5,72(sp)
 8b0:	6b06                	ld	s6,64(sp)
 8b2:	7be2                	ld	s7,56(sp)
 8b4:	7c42                	ld	s8,48(sp)
 8b6:	7ca2                	ld	s9,40(sp)
 8b8:	7d02                	ld	s10,32(sp)
 8ba:	6de2                	ld	s11,24(sp)
 8bc:	6109                	addi	sp,sp,128
 8be:	8082                	ret

00000000000008c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8c0:	715d                	addi	sp,sp,-80
 8c2:	ec06                	sd	ra,24(sp)
 8c4:	e822                	sd	s0,16(sp)
 8c6:	1000                	addi	s0,sp,32
 8c8:	e010                	sd	a2,0(s0)
 8ca:	e414                	sd	a3,8(s0)
 8cc:	e818                	sd	a4,16(s0)
 8ce:	ec1c                	sd	a5,24(s0)
 8d0:	03043023          	sd	a6,32(s0)
 8d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8d8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8dc:	8622                	mv	a2,s0
 8de:	d4bff0ef          	jal	ra,628 <vprintf>
}
 8e2:	60e2                	ld	ra,24(sp)
 8e4:	6442                	ld	s0,16(sp)
 8e6:	6161                	addi	sp,sp,80
 8e8:	8082                	ret

00000000000008ea <printf>:

void
printf(const char *fmt, ...)
{
 8ea:	711d                	addi	sp,sp,-96
 8ec:	ec06                	sd	ra,24(sp)
 8ee:	e822                	sd	s0,16(sp)
 8f0:	1000                	addi	s0,sp,32
 8f2:	e40c                	sd	a1,8(s0)
 8f4:	e810                	sd	a2,16(s0)
 8f6:	ec14                	sd	a3,24(s0)
 8f8:	f018                	sd	a4,32(s0)
 8fa:	f41c                	sd	a5,40(s0)
 8fc:	03043823          	sd	a6,48(s0)
 900:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 904:	00840613          	addi	a2,s0,8
 908:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 90c:	85aa                	mv	a1,a0
 90e:	4505                	li	a0,1
 910:	d19ff0ef          	jal	ra,628 <vprintf>
}
 914:	60e2                	ld	ra,24(sp)
 916:	6442                	ld	s0,16(sp)
 918:	6125                	addi	sp,sp,96
 91a:	8082                	ret

000000000000091c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 91c:	1141                	addi	sp,sp,-16
 91e:	e422                	sd	s0,8(sp)
 920:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 922:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 926:	00000797          	auipc	a5,0x0
 92a:	6da7b783          	ld	a5,1754(a5) # 1000 <freep>
 92e:	a805                	j	95e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 930:	4618                	lw	a4,8(a2)
 932:	9db9                	addw	a1,a1,a4
 934:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 938:	6398                	ld	a4,0(a5)
 93a:	6318                	ld	a4,0(a4)
 93c:	fee53823          	sd	a4,-16(a0)
 940:	a091                	j	984 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 942:	ff852703          	lw	a4,-8(a0)
 946:	9e39                	addw	a2,a2,a4
 948:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 94a:	ff053703          	ld	a4,-16(a0)
 94e:	e398                	sd	a4,0(a5)
 950:	a099                	j	996 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 952:	6398                	ld	a4,0(a5)
 954:	00e7e463          	bltu	a5,a4,95c <free+0x40>
 958:	00e6ea63          	bltu	a3,a4,96c <free+0x50>
{
 95c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 95e:	fed7fae3          	bgeu	a5,a3,952 <free+0x36>
 962:	6398                	ld	a4,0(a5)
 964:	00e6e463          	bltu	a3,a4,96c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 968:	fee7eae3          	bltu	a5,a4,95c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 96c:	ff852583          	lw	a1,-8(a0)
 970:	6390                	ld	a2,0(a5)
 972:	02059713          	slli	a4,a1,0x20
 976:	9301                	srli	a4,a4,0x20
 978:	0712                	slli	a4,a4,0x4
 97a:	9736                	add	a4,a4,a3
 97c:	fae60ae3          	beq	a2,a4,930 <free+0x14>
    bp->s.ptr = p->s.ptr;
 980:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 984:	4790                	lw	a2,8(a5)
 986:	02061713          	slli	a4,a2,0x20
 98a:	9301                	srli	a4,a4,0x20
 98c:	0712                	slli	a4,a4,0x4
 98e:	973e                	add	a4,a4,a5
 990:	fae689e3          	beq	a3,a4,942 <free+0x26>
  } else
    p->s.ptr = bp;
 994:	e394                	sd	a3,0(a5)
  freep = p;
 996:	00000717          	auipc	a4,0x0
 99a:	66f73523          	sd	a5,1642(a4) # 1000 <freep>
}
 99e:	6422                	ld	s0,8(sp)
 9a0:	0141                	addi	sp,sp,16
 9a2:	8082                	ret

00000000000009a4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9a4:	7139                	addi	sp,sp,-64
 9a6:	fc06                	sd	ra,56(sp)
 9a8:	f822                	sd	s0,48(sp)
 9aa:	f426                	sd	s1,40(sp)
 9ac:	f04a                	sd	s2,32(sp)
 9ae:	ec4e                	sd	s3,24(sp)
 9b0:	e852                	sd	s4,16(sp)
 9b2:	e456                	sd	s5,8(sp)
 9b4:	e05a                	sd	s6,0(sp)
 9b6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9b8:	02051493          	slli	s1,a0,0x20
 9bc:	9081                	srli	s1,s1,0x20
 9be:	04bd                	addi	s1,s1,15
 9c0:	8091                	srli	s1,s1,0x4
 9c2:	0014899b          	addiw	s3,s1,1
 9c6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9c8:	00000517          	auipc	a0,0x0
 9cc:	63853503          	ld	a0,1592(a0) # 1000 <freep>
 9d0:	c515                	beqz	a0,9fc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9d4:	4798                	lw	a4,8(a5)
 9d6:	02977f63          	bgeu	a4,s1,a14 <malloc+0x70>
 9da:	8a4e                	mv	s4,s3
 9dc:	0009871b          	sext.w	a4,s3
 9e0:	6685                	lui	a3,0x1
 9e2:	00d77363          	bgeu	a4,a3,9e8 <malloc+0x44>
 9e6:	6a05                	lui	s4,0x1
 9e8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ec:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9f0:	00000917          	auipc	s2,0x0
 9f4:	61090913          	addi	s2,s2,1552 # 1000 <freep>
  if(p == SBRK_ERROR)
 9f8:	5afd                	li	s5,-1
 9fa:	a0bd                	j	a68 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 9fc:	00000797          	auipc	a5,0x0
 a00:	61478793          	addi	a5,a5,1556 # 1010 <base>
 a04:	00000717          	auipc	a4,0x0
 a08:	5ef73e23          	sd	a5,1532(a4) # 1000 <freep>
 a0c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a0e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a12:	b7e1                	j	9da <malloc+0x36>
      if(p->s.size == nunits)
 a14:	02e48b63          	beq	s1,a4,a4a <malloc+0xa6>
        p->s.size -= nunits;
 a18:	4137073b          	subw	a4,a4,s3
 a1c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a1e:	1702                	slli	a4,a4,0x20
 a20:	9301                	srli	a4,a4,0x20
 a22:	0712                	slli	a4,a4,0x4
 a24:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a26:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a2a:	00000717          	auipc	a4,0x0
 a2e:	5ca73b23          	sd	a0,1494(a4) # 1000 <freep>
      return (void*)(p + 1);
 a32:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a36:	70e2                	ld	ra,56(sp)
 a38:	7442                	ld	s0,48(sp)
 a3a:	74a2                	ld	s1,40(sp)
 a3c:	7902                	ld	s2,32(sp)
 a3e:	69e2                	ld	s3,24(sp)
 a40:	6a42                	ld	s4,16(sp)
 a42:	6aa2                	ld	s5,8(sp)
 a44:	6b02                	ld	s6,0(sp)
 a46:	6121                	addi	sp,sp,64
 a48:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a4a:	6398                	ld	a4,0(a5)
 a4c:	e118                	sd	a4,0(a0)
 a4e:	bff1                	j	a2a <malloc+0x86>
  hp->s.size = nu;
 a50:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a54:	0541                	addi	a0,a0,16
 a56:	ec7ff0ef          	jal	ra,91c <free>
  return freep;
 a5a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a5e:	dd61                	beqz	a0,a36 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a60:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a62:	4798                	lw	a4,8(a5)
 a64:	fa9778e3          	bgeu	a4,s1,a14 <malloc+0x70>
    if(p == freep)
 a68:	00093703          	ld	a4,0(s2)
 a6c:	853e                	mv	a0,a5
 a6e:	fef719e3          	bne	a4,a5,a60 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 a72:	8552                	mv	a0,s4
 a74:	9e7ff0ef          	jal	ra,45a <sbrk>
  if(p == SBRK_ERROR)
 a78:	fd551ce3          	bne	a0,s5,a50 <malloc+0xac>
        return 0;
 a7c:	4501                	li	a0,0
 a7e:	bf65                	j	a36 <malloc+0x92>


user/_p2b:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

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
    char *var = (char *)sbrk(8192); // Allocate 8192 bytes (2 pages)
  1a:	6509                	lui	a0,0x2
  1c:	33a000ef          	jal	ra,356 <sbrk>
  20:	84aa                	mv	s1,a0
    // Implement the logic for pte accordingly
    uint64 user_pte1, user_pte2, user_pte3;

    // Virtual address of a user-space variable
    user_va1 = (uint64)var;
    user_va2 = (uint64)(var + 1);
  22:	00150b93          	addi	s7,a0,1 # 2001 <base+0xff1>
    user_va3 = (uint64)(var + 4096);
  26:	6905                	lui	s2,0x1
  28:	992a                	add	s2,s2,a0

    // Translate user virtual address to physical address
    user_pa1 = va_to_pa(user_va1);
  2a:	436000ef          	jal	ra,460 <va_to_pa>
  2e:	8caa                	mv	s9,a0
    user_pa2 = va_to_pa(user_va2);
  30:	855e                	mv	a0,s7
  32:	42e000ef          	jal	ra,460 <va_to_pa>
  36:	8b2a                	mv	s6,a0
    user_pa3 = va_to_pa(user_va3);
  38:	854a                	mv	a0,s2
  3a:	426000ef          	jal	ra,460 <va_to_pa>
  3e:	8a2a                	mv	s4,a0

    user_pte1=va_to_pte(user_va1);
  40:	8526                	mv	a0,s1
  42:	416000ef          	jal	ra,458 <va_to_pte>
  46:	8c2a                	mv	s8,a0
    user_pte2=va_to_pte(user_va2);
  48:	855e                	mv	a0,s7
  4a:	40e000ef          	jal	ra,458 <va_to_pte>
  4e:	8aaa                	mv	s5,a0
    user_pte3=va_to_pte(user_va3);
  50:	854a                	mv	a0,s2
  52:	406000ef          	jal	ra,458 <va_to_pte>
  56:	89aa                	mv	s3,a0

    printf("User VA  : %p\n", (void *)user_va1);
  58:	85a6                	mv	a1,s1
  5a:	00001517          	auipc	a0,0x1
  5e:	94650513          	addi	a0,a0,-1722 # 9a0 <malloc+0xe2>
  62:	7a2000ef          	jal	ra,804 <printf>
    printf("User PA  : %p\n", (void *)user_pa1);
  66:	85e6                	mv	a1,s9
  68:	00001517          	auipc	a0,0x1
  6c:	94850513          	addi	a0,a0,-1720 # 9b0 <malloc+0xf2>
  70:	794000ef          	jal	ra,804 <printf>
    printf("User PTE : %p\n", (void *)user_pte1);
  74:	85e2                	mv	a1,s8
  76:	00001517          	auipc	a0,0x1
  7a:	94a50513          	addi	a0,a0,-1718 # 9c0 <malloc+0x102>
  7e:	786000ef          	jal	ra,804 <printf>

    printf("---\n");
  82:	00001517          	auipc	a0,0x1
  86:	94e50513          	addi	a0,a0,-1714 # 9d0 <malloc+0x112>
  8a:	77a000ef          	jal	ra,804 <printf>
    printf("User VA  : %p\n", (void *)user_va2);
  8e:	85de                	mv	a1,s7
  90:	00001517          	auipc	a0,0x1
  94:	91050513          	addi	a0,a0,-1776 # 9a0 <malloc+0xe2>
  98:	76c000ef          	jal	ra,804 <printf>
    printf("User PA  : %p\n", (void *)user_pa2);
  9c:	85da                	mv	a1,s6
  9e:	00001517          	auipc	a0,0x1
  a2:	91250513          	addi	a0,a0,-1774 # 9b0 <malloc+0xf2>
  a6:	75e000ef          	jal	ra,804 <printf>
    printf("User PTE : %p\n", (void *)user_pte2);
  aa:	85d6                	mv	a1,s5
  ac:	00001517          	auipc	a0,0x1
  b0:	91450513          	addi	a0,a0,-1772 # 9c0 <malloc+0x102>
  b4:	750000ef          	jal	ra,804 <printf>

    printf("---\n");
  b8:	00001517          	auipc	a0,0x1
  bc:	91850513          	addi	a0,a0,-1768 # 9d0 <malloc+0x112>
  c0:	744000ef          	jal	ra,804 <printf>
    printf("User VA  : %p\n", (void *)user_va3);
  c4:	85ca                	mv	a1,s2
  c6:	00001517          	auipc	a0,0x1
  ca:	8da50513          	addi	a0,a0,-1830 # 9a0 <malloc+0xe2>
  ce:	736000ef          	jal	ra,804 <printf>
    printf("User PA  : %p\n", (void *)user_pa3);
  d2:	85d2                	mv	a1,s4
  d4:	00001517          	auipc	a0,0x1
  d8:	8dc50513          	addi	a0,a0,-1828 # 9b0 <malloc+0xf2>
  dc:	728000ef          	jal	ra,804 <printf>
    printf("User PTE : %p\n", (void *)user_pte3);
  e0:	85ce                	mv	a1,s3
  e2:	00001517          	auipc	a0,0x1
  e6:	8de50513          	addi	a0,a0,-1826 # 9c0 <malloc+0x102>
  ea:	71a000ef          	jal	ra,804 <printf>

    exit(0);
  ee:	4501                	li	a0,0
  f0:	2b0000ef          	jal	ra,3a0 <exit>

00000000000000f4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e406                	sd	ra,8(sp)
  f8:	e022                	sd	s0,0(sp)
  fa:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  fc:	f05ff0ef          	jal	ra,0 <main>
  exit(r);
 100:	2a0000ef          	jal	ra,3a0 <exit>

0000000000000104 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10a:	87aa                	mv	a5,a0
 10c:	0585                	addi	a1,a1,1
 10e:	0785                	addi	a5,a5,1
 110:	fff5c703          	lbu	a4,-1(a1)
 114:	fee78fa3          	sb	a4,-1(a5)
 118:	fb75                	bnez	a4,10c <strcpy+0x8>
    ;
  return os;
}
 11a:	6422                	ld	s0,8(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret

0000000000000120 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 120:	1141                	addi	sp,sp,-16
 122:	e422                	sd	s0,8(sp)
 124:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 126:	00054783          	lbu	a5,0(a0)
 12a:	cb91                	beqz	a5,13e <strcmp+0x1e>
 12c:	0005c703          	lbu	a4,0(a1)
 130:	00f71763          	bne	a4,a5,13e <strcmp+0x1e>
    p++, q++;
 134:	0505                	addi	a0,a0,1
 136:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 138:	00054783          	lbu	a5,0(a0)
 13c:	fbe5                	bnez	a5,12c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 13e:	0005c503          	lbu	a0,0(a1)
}
 142:	40a7853b          	subw	a0,a5,a0
 146:	6422                	ld	s0,8(sp)
 148:	0141                	addi	sp,sp,16
 14a:	8082                	ret

000000000000014c <strlen>:

uint
strlen(const char *s)
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e422                	sd	s0,8(sp)
 150:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 152:	00054783          	lbu	a5,0(a0)
 156:	cf91                	beqz	a5,172 <strlen+0x26>
 158:	0505                	addi	a0,a0,1
 15a:	87aa                	mv	a5,a0
 15c:	4685                	li	a3,1
 15e:	9e89                	subw	a3,a3,a0
 160:	00f6853b          	addw	a0,a3,a5
 164:	0785                	addi	a5,a5,1
 166:	fff7c703          	lbu	a4,-1(a5)
 16a:	fb7d                	bnez	a4,160 <strlen+0x14>
    ;
  return n;
}
 16c:	6422                	ld	s0,8(sp)
 16e:	0141                	addi	sp,sp,16
 170:	8082                	ret
  for(n = 0; s[n]; n++)
 172:	4501                	li	a0,0
 174:	bfe5                	j	16c <strlen+0x20>

0000000000000176 <memset>:

void*
memset(void *dst, int c, uint n)
{
 176:	1141                	addi	sp,sp,-16
 178:	e422                	sd	s0,8(sp)
 17a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 17c:	ca19                	beqz	a2,192 <memset+0x1c>
 17e:	87aa                	mv	a5,a0
 180:	1602                	slli	a2,a2,0x20
 182:	9201                	srli	a2,a2,0x20
 184:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 188:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 18c:	0785                	addi	a5,a5,1
 18e:	fee79de3          	bne	a5,a4,188 <memset+0x12>
  }
  return dst;
}
 192:	6422                	ld	s0,8(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strchr>:

char*
strchr(const char *s, char c)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	cb99                	beqz	a5,1b8 <strchr+0x20>
    if(*s == c)
 1a4:	00f58763          	beq	a1,a5,1b2 <strchr+0x1a>
  for(; *s; s++)
 1a8:	0505                	addi	a0,a0,1
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	fbfd                	bnez	a5,1a4 <strchr+0xc>
      return (char*)s;
  return 0;
 1b0:	4501                	li	a0,0
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret
  return 0;
 1b8:	4501                	li	a0,0
 1ba:	bfe5                	j	1b2 <strchr+0x1a>

00000000000001bc <gets>:

char*
gets(char *buf, int max)
{
 1bc:	711d                	addi	sp,sp,-96
 1be:	ec86                	sd	ra,88(sp)
 1c0:	e8a2                	sd	s0,80(sp)
 1c2:	e4a6                	sd	s1,72(sp)
 1c4:	e0ca                	sd	s2,64(sp)
 1c6:	fc4e                	sd	s3,56(sp)
 1c8:	f852                	sd	s4,48(sp)
 1ca:	f456                	sd	s5,40(sp)
 1cc:	f05a                	sd	s6,32(sp)
 1ce:	ec5e                	sd	s7,24(sp)
 1d0:	1080                	addi	s0,sp,96
 1d2:	8baa                	mv	s7,a0
 1d4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d6:	892a                	mv	s2,a0
 1d8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1da:	4aa9                	li	s5,10
 1dc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1de:	89a6                	mv	s3,s1
 1e0:	2485                	addiw	s1,s1,1
 1e2:	0344d663          	bge	s1,s4,20e <gets+0x52>
    cc = read(0, &c, 1);
 1e6:	4605                	li	a2,1
 1e8:	faf40593          	addi	a1,s0,-81
 1ec:	4501                	li	a0,0
 1ee:	1ca000ef          	jal	ra,3b8 <read>
    if(cc < 1)
 1f2:	00a05e63          	blez	a0,20e <gets+0x52>
    buf[i++] = c;
 1f6:	faf44783          	lbu	a5,-81(s0)
 1fa:	00f90023          	sb	a5,0(s2) # 1000 <freep>
    if(c == '\n' || c == '\r')
 1fe:	01578763          	beq	a5,s5,20c <gets+0x50>
 202:	0905                	addi	s2,s2,1
 204:	fd679de3          	bne	a5,s6,1de <gets+0x22>
  for(i=0; i+1 < max; ){
 208:	89a6                	mv	s3,s1
 20a:	a011                	j	20e <gets+0x52>
 20c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20e:	99de                	add	s3,s3,s7
 210:	00098023          	sb	zero,0(s3)
  return buf;
}
 214:	855e                	mv	a0,s7
 216:	60e6                	ld	ra,88(sp)
 218:	6446                	ld	s0,80(sp)
 21a:	64a6                	ld	s1,72(sp)
 21c:	6906                	ld	s2,64(sp)
 21e:	79e2                	ld	s3,56(sp)
 220:	7a42                	ld	s4,48(sp)
 222:	7aa2                	ld	s5,40(sp)
 224:	7b02                	ld	s6,32(sp)
 226:	6be2                	ld	s7,24(sp)
 228:	6125                	addi	sp,sp,96
 22a:	8082                	ret

000000000000022c <stat>:

int
stat(const char *n, struct stat *st)
{
 22c:	1101                	addi	sp,sp,-32
 22e:	ec06                	sd	ra,24(sp)
 230:	e822                	sd	s0,16(sp)
 232:	e426                	sd	s1,8(sp)
 234:	e04a                	sd	s2,0(sp)
 236:	1000                	addi	s0,sp,32
 238:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 23a:	4581                	li	a1,0
 23c:	1a4000ef          	jal	ra,3e0 <open>
  if(fd < 0)
 240:	02054163          	bltz	a0,262 <stat+0x36>
 244:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 246:	85ca                	mv	a1,s2
 248:	1b0000ef          	jal	ra,3f8 <fstat>
 24c:	892a                	mv	s2,a0
  close(fd);
 24e:	8526                	mv	a0,s1
 250:	178000ef          	jal	ra,3c8 <close>
  return r;
}
 254:	854a                	mv	a0,s2
 256:	60e2                	ld	ra,24(sp)
 258:	6442                	ld	s0,16(sp)
 25a:	64a2                	ld	s1,8(sp)
 25c:	6902                	ld	s2,0(sp)
 25e:	6105                	addi	sp,sp,32
 260:	8082                	ret
    return -1;
 262:	597d                	li	s2,-1
 264:	bfc5                	j	254 <stat+0x28>

0000000000000266 <atoi>:

int
atoi(const char *s)
{
 266:	1141                	addi	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26c:	00054603          	lbu	a2,0(a0)
 270:	fd06079b          	addiw	a5,a2,-48
 274:	0ff7f793          	andi	a5,a5,255
 278:	4725                	li	a4,9
 27a:	02f76963          	bltu	a4,a5,2ac <atoi+0x46>
 27e:	86aa                	mv	a3,a0
  n = 0;
 280:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 282:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 284:	0685                	addi	a3,a3,1
 286:	0025179b          	slliw	a5,a0,0x2
 28a:	9fa9                	addw	a5,a5,a0
 28c:	0017979b          	slliw	a5,a5,0x1
 290:	9fb1                	addw	a5,a5,a2
 292:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 296:	0006c603          	lbu	a2,0(a3)
 29a:	fd06071b          	addiw	a4,a2,-48
 29e:	0ff77713          	andi	a4,a4,255
 2a2:	fee5f1e3          	bgeu	a1,a4,284 <atoi+0x1e>
  return n;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  n = 0;
 2ac:	4501                	li	a0,0
 2ae:	bfe5                	j	2a6 <atoi+0x40>

00000000000002b0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e422                	sd	s0,8(sp)
 2b4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b6:	02b57463          	bgeu	a0,a1,2de <memmove+0x2e>
    while(n-- > 0)
 2ba:	00c05f63          	blez	a2,2d8 <memmove+0x28>
 2be:	1602                	slli	a2,a2,0x20
 2c0:	9201                	srli	a2,a2,0x20
 2c2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c8:	0585                	addi	a1,a1,1
 2ca:	0705                	addi	a4,a4,1
 2cc:	fff5c683          	lbu	a3,-1(a1)
 2d0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d4:	fee79ae3          	bne	a5,a4,2c8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d8:	6422                	ld	s0,8(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret
    dst += n;
 2de:	00c50733          	add	a4,a0,a2
    src += n;
 2e2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e4:	fec05ae3          	blez	a2,2d8 <memmove+0x28>
 2e8:	fff6079b          	addiw	a5,a2,-1
 2ec:	1782                	slli	a5,a5,0x20
 2ee:	9381                	srli	a5,a5,0x20
 2f0:	fff7c793          	not	a5,a5
 2f4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f6:	15fd                	addi	a1,a1,-1
 2f8:	177d                	addi	a4,a4,-1
 2fa:	0005c683          	lbu	a3,0(a1)
 2fe:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 302:	fee79ae3          	bne	a5,a4,2f6 <memmove+0x46>
 306:	bfc9                	j	2d8 <memmove+0x28>

0000000000000308 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e422                	sd	s0,8(sp)
 30c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 30e:	ca05                	beqz	a2,33e <memcmp+0x36>
 310:	fff6069b          	addiw	a3,a2,-1
 314:	1682                	slli	a3,a3,0x20
 316:	9281                	srli	a3,a3,0x20
 318:	0685                	addi	a3,a3,1
 31a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 31c:	00054783          	lbu	a5,0(a0)
 320:	0005c703          	lbu	a4,0(a1)
 324:	00e79863          	bne	a5,a4,334 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 328:	0505                	addi	a0,a0,1
    p2++;
 32a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 32c:	fed518e3          	bne	a0,a3,31c <memcmp+0x14>
  }
  return 0;
 330:	4501                	li	a0,0
 332:	a019                	j	338 <memcmp+0x30>
      return *p1 - *p2;
 334:	40e7853b          	subw	a0,a5,a4
}
 338:	6422                	ld	s0,8(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret
  return 0;
 33e:	4501                	li	a0,0
 340:	bfe5                	j	338 <memcmp+0x30>

0000000000000342 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 342:	1141                	addi	sp,sp,-16
 344:	e406                	sd	ra,8(sp)
 346:	e022                	sd	s0,0(sp)
 348:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 34a:	f67ff0ef          	jal	ra,2b0 <memmove>
}
 34e:	60a2                	ld	ra,8(sp)
 350:	6402                	ld	s0,0(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret

0000000000000356 <sbrk>:

char *
sbrk(int n) {
 356:	1141                	addi	sp,sp,-16
 358:	e406                	sd	ra,8(sp)
 35a:	e022                	sd	s0,0(sp)
 35c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 35e:	4585                	li	a1,1
 360:	0c8000ef          	jal	ra,428 <sys_sbrk>
}
 364:	60a2                	ld	ra,8(sp)
 366:	6402                	ld	s0,0(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret

000000000000036c <sbrklazy>:

char *
sbrklazy(int n) {
 36c:	1141                	addi	sp,sp,-16
 36e:	e406                	sd	ra,8(sp)
 370:	e022                	sd	s0,0(sp)
 372:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 374:	4589                	li	a1,2
 376:	0b2000ef          	jal	ra,428 <sys_sbrk>
}
 37a:	60a2                	ld	ra,8(sp)
 37c:	6402                	ld	s0,0(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret

0000000000000382 <ugetpid>:

int
ugetpid(void)
{
 382:	1141                	addi	sp,sp,-16
 384:	e422                	sd	s0,8(sp)
 386:	0800                	addi	s0,sp,16
  return (*(int*)UGET);
 388:	040007b7          	lui	a5,0x4000
 38c:	17f5                	addi	a5,a5,-3
 38e:	07b2                	slli	a5,a5,0xc
 390:	4388                	lw	a0,0(a5)
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret

0000000000000398 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 398:	4885                	li	a7,1
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a0:	4889                	li	a7,2
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a8:	488d                	li	a7,3
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b0:	4891                	li	a7,4
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <read>:
.global read
read:
 li a7, SYS_read
 3b8:	4895                	li	a7,5
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <write>:
.global write
write:
 li a7, SYS_write
 3c0:	48c1                	li	a7,16
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <close>:
.global close
close:
 li a7, SYS_close
 3c8:	48d5                	li	a7,21
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d0:	4899                	li	a7,6
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d8:	489d                	li	a7,7
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <open>:
.global open
open:
 li a7, SYS_open
 3e0:	48bd                	li	a7,15
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e8:	48c5                	li	a7,17
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f0:	48c9                	li	a7,18
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f8:	48a1                	li	a7,8
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <link>:
.global link
link:
 li a7, SYS_link
 400:	48cd                	li	a7,19
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 408:	48d1                	li	a7,20
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 410:	48a5                	li	a7,9
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <dup>:
.global dup
dup:
 li a7, SYS_dup
 418:	48a9                	li	a7,10
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 420:	48ad                	li	a7,11
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 428:	48b1                	li	a7,12
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <pause>:
.global pause
pause:
 li a7, SYS_pause
 430:	48b5                	li	a7,13
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 438:	48b9                	li	a7,14
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <pte_valid>:
.global pte_valid
pte_valid:
 li a7, SYS_pte_valid
 440:	48d9                	li	a7,22
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <get_pteflags>:
.global get_pteflags
get_pteflags:
 li a7, SYS_get_pteflags
 448:	48dd                	li	a7,23
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <print_pgdirs>:
.global print_pgdirs
print_pgdirs:
 li a7, SYS_print_pgdirs
 450:	48e1                	li	a7,24
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <va_to_pte>:
.global va_to_pte
va_to_pte:
 li a7, SYS_va_to_pte
 458:	48e5                	li	a7,25
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <va_to_pa>:
.global va_to_pa
va_to_pa:
 li a7, SYS_va_to_pa
 460:	48e9                	li	a7,26
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <getvasize>:
.global getvasize
getvasize:
 li a7, SYS_getvasize
 468:	48ed                	li	a7,27
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <getpasize>:
.global getpasize
getpasize:
 li a7, SYS_getpasize
 470:	48f1                	li	a7,28
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <getlazyfaults>:
.global getlazyfaults
getlazyfaults:
 li a7, SYS_getlazyfaults
 478:	48f5                	li	a7,29
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <kva_to_pa>:
.global kva_to_pa
kva_to_pa:
 li a7, SYS_kva_to_pa
 480:	48f9                	li	a7,30
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 488:	1101                	addi	sp,sp,-32
 48a:	ec06                	sd	ra,24(sp)
 48c:	e822                	sd	s0,16(sp)
 48e:	1000                	addi	s0,sp,32
 490:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 494:	4605                	li	a2,1
 496:	fef40593          	addi	a1,s0,-17
 49a:	f27ff0ef          	jal	ra,3c0 <write>
}
 49e:	60e2                	ld	ra,24(sp)
 4a0:	6442                	ld	s0,16(sp)
 4a2:	6105                	addi	sp,sp,32
 4a4:	8082                	ret

00000000000004a6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4a6:	715d                	addi	sp,sp,-80
 4a8:	e486                	sd	ra,72(sp)
 4aa:	e0a2                	sd	s0,64(sp)
 4ac:	fc26                	sd	s1,56(sp)
 4ae:	f84a                	sd	s2,48(sp)
 4b0:	f44e                	sd	s3,40(sp)
 4b2:	0880                	addi	s0,sp,80
 4b4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4b6:	c299                	beqz	a3,4bc <printint+0x16>
 4b8:	0805c163          	bltz	a1,53a <printint+0x94>
  neg = 0;
 4bc:	4881                	li	a7,0
 4be:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4c2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4c4:	00000517          	auipc	a0,0x0
 4c8:	51c50513          	addi	a0,a0,1308 # 9e0 <digits>
 4cc:	883e                	mv	a6,a5
 4ce:	2785                	addiw	a5,a5,1
 4d0:	02c5f733          	remu	a4,a1,a2
 4d4:	972a                	add	a4,a4,a0
 4d6:	00074703          	lbu	a4,0(a4)
 4da:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4de:	872e                	mv	a4,a1
 4e0:	02c5d5b3          	divu	a1,a1,a2
 4e4:	0685                	addi	a3,a3,1
 4e6:	fec773e3          	bgeu	a4,a2,4cc <printint+0x26>
  if(neg)
 4ea:	00088b63          	beqz	a7,500 <printint+0x5a>
    buf[i++] = '-';
 4ee:	fd040713          	addi	a4,s0,-48
 4f2:	97ba                	add	a5,a5,a4
 4f4:	02d00713          	li	a4,45
 4f8:	fee78423          	sb	a4,-24(a5) # 3ffffe8 <base+0x3ffefd8>
 4fc:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 500:	02f05663          	blez	a5,52c <printint+0x86>
 504:	fb840713          	addi	a4,s0,-72
 508:	00f704b3          	add	s1,a4,a5
 50c:	fff70993          	addi	s3,a4,-1
 510:	99be                	add	s3,s3,a5
 512:	37fd                	addiw	a5,a5,-1
 514:	1782                	slli	a5,a5,0x20
 516:	9381                	srli	a5,a5,0x20
 518:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 51c:	fff4c583          	lbu	a1,-1(s1)
 520:	854a                	mv	a0,s2
 522:	f67ff0ef          	jal	ra,488 <putc>
  while(--i >= 0)
 526:	14fd                	addi	s1,s1,-1
 528:	ff349ae3          	bne	s1,s3,51c <printint+0x76>
}
 52c:	60a6                	ld	ra,72(sp)
 52e:	6406                	ld	s0,64(sp)
 530:	74e2                	ld	s1,56(sp)
 532:	7942                	ld	s2,48(sp)
 534:	79a2                	ld	s3,40(sp)
 536:	6161                	addi	sp,sp,80
 538:	8082                	ret
    x = -xx;
 53a:	40b005b3          	neg	a1,a1
    neg = 1;
 53e:	4885                	li	a7,1
    x = -xx;
 540:	bfbd                	j	4be <printint+0x18>

0000000000000542 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 542:	7119                	addi	sp,sp,-128
 544:	fc86                	sd	ra,120(sp)
 546:	f8a2                	sd	s0,112(sp)
 548:	f4a6                	sd	s1,104(sp)
 54a:	f0ca                	sd	s2,96(sp)
 54c:	ecce                	sd	s3,88(sp)
 54e:	e8d2                	sd	s4,80(sp)
 550:	e4d6                	sd	s5,72(sp)
 552:	e0da                	sd	s6,64(sp)
 554:	fc5e                	sd	s7,56(sp)
 556:	f862                	sd	s8,48(sp)
 558:	f466                	sd	s9,40(sp)
 55a:	f06a                	sd	s10,32(sp)
 55c:	ec6e                	sd	s11,24(sp)
 55e:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 560:	0005c903          	lbu	s2,0(a1)
 564:	24090c63          	beqz	s2,7bc <vprintf+0x27a>
 568:	8b2a                	mv	s6,a0
 56a:	8a2e                	mv	s4,a1
 56c:	8bb2                	mv	s7,a2
  state = 0;
 56e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 570:	4481                	li	s1,0
 572:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 574:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 578:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 57c:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 580:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 584:	00000c97          	auipc	s9,0x0
 588:	45cc8c93          	addi	s9,s9,1116 # 9e0 <digits>
 58c:	a005                	j	5ac <vprintf+0x6a>
        putc(fd, c0);
 58e:	85ca                	mv	a1,s2
 590:	855a                	mv	a0,s6
 592:	ef7ff0ef          	jal	ra,488 <putc>
 596:	a019                	j	59c <vprintf+0x5a>
    } else if(state == '%'){
 598:	03598263          	beq	s3,s5,5bc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 59c:	2485                	addiw	s1,s1,1
 59e:	8726                	mv	a4,s1
 5a0:	009a07b3          	add	a5,s4,s1
 5a4:	0007c903          	lbu	s2,0(a5)
 5a8:	20090a63          	beqz	s2,7bc <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5ac:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5b0:	fe0994e3          	bnez	s3,598 <vprintf+0x56>
      if(c0 == '%'){
 5b4:	fd579de3          	bne	a5,s5,58e <vprintf+0x4c>
        state = '%';
 5b8:	89be                	mv	s3,a5
 5ba:	b7cd                	j	59c <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5bc:	c3c1                	beqz	a5,63c <vprintf+0xfa>
 5be:	00ea06b3          	add	a3,s4,a4
 5c2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5c6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5c8:	c681                	beqz	a3,5d0 <vprintf+0x8e>
 5ca:	9752                	add	a4,a4,s4
 5cc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5d0:	03878e63          	beq	a5,s8,60c <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5d4:	05a78863          	beq	a5,s10,624 <vprintf+0xe2>
      } else if(c0 == 'u'){
 5d8:	0db78b63          	beq	a5,s11,6ae <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5dc:	07800713          	li	a4,120
 5e0:	10e78d63          	beq	a5,a4,6fa <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5e4:	07000713          	li	a4,112
 5e8:	14e78263          	beq	a5,a4,72c <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5ec:	06300713          	li	a4,99
 5f0:	16e78f63          	beq	a5,a4,76e <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5f4:	07300713          	li	a4,115
 5f8:	18e78563          	beq	a5,a4,782 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5fc:	05579063          	bne	a5,s5,63c <vprintf+0xfa>
        putc(fd, '%');
 600:	85d6                	mv	a1,s5
 602:	855a                	mv	a0,s6
 604:	e85ff0ef          	jal	ra,488 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 608:	4981                	li	s3,0
 60a:	bf49                	j	59c <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 60c:	008b8913          	addi	s2,s7,8
 610:	4685                	li	a3,1
 612:	4629                	li	a2,10
 614:	000ba583          	lw	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	e8dff0ef          	jal	ra,4a6 <printint>
 61e:	8bca                	mv	s7,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	bfad                	j	59c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 624:	03868663          	beq	a3,s8,650 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 628:	05a68163          	beq	a3,s10,66a <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 62c:	09b68d63          	beq	a3,s11,6c6 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 630:	03a68f63          	beq	a3,s10,66e <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 634:	07800793          	li	a5,120
 638:	0cf68d63          	beq	a3,a5,712 <vprintf+0x1d0>
        putc(fd, '%');
 63c:	85d6                	mv	a1,s5
 63e:	855a                	mv	a0,s6
 640:	e49ff0ef          	jal	ra,488 <putc>
        putc(fd, c0);
 644:	85ca                	mv	a1,s2
 646:	855a                	mv	a0,s6
 648:	e41ff0ef          	jal	ra,488 <putc>
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b7b9                	j	59c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 650:	008b8913          	addi	s2,s7,8
 654:	4685                	li	a3,1
 656:	4629                	li	a2,10
 658:	000bb583          	ld	a1,0(s7)
 65c:	855a                	mv	a0,s6
 65e:	e49ff0ef          	jal	ra,4a6 <printint>
        i += 1;
 662:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
        i += 1;
 668:	bf15                	j	59c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 66a:	03860563          	beq	a2,s8,694 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 66e:	07b60963          	beq	a2,s11,6e0 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 672:	07800793          	li	a5,120
 676:	fcf613e3          	bne	a2,a5,63c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4681                	li	a3,0
 680:	4641                	li	a2,16
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	e1fff0ef          	jal	ra,4a6 <printint>
        i += 2;
 68c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 2;
 692:	b729                	j	59c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 694:	008b8913          	addi	s2,s7,8
 698:	4685                	li	a3,1
 69a:	4629                	li	a2,10
 69c:	000bb583          	ld	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	e05ff0ef          	jal	ra,4a6 <printint>
        i += 2;
 6a6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
        i += 2;
 6ac:	bdc5                	j	59c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4629                	li	a2,10
 6b6:	000be583          	lwu	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	debff0ef          	jal	ra,4a6 <printint>
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bde1                	j	59c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c6:	008b8913          	addi	s2,s7,8
 6ca:	4681                	li	a3,0
 6cc:	4629                	li	a2,10
 6ce:	000bb583          	ld	a1,0(s7)
 6d2:	855a                	mv	a0,s6
 6d4:	dd3ff0ef          	jal	ra,4a6 <printint>
        i += 1;
 6d8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
        i += 1;
 6de:	bd7d                	j	59c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	4681                	li	a3,0
 6e6:	4629                	li	a2,10
 6e8:	000bb583          	ld	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	db9ff0ef          	jal	ra,4a6 <printint>
        i += 2;
 6f2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
        i += 2;
 6f8:	b555                	j	59c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6fa:	008b8913          	addi	s2,s7,8
 6fe:	4681                	li	a3,0
 700:	4641                	li	a2,16
 702:	000be583          	lwu	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	d9fff0ef          	jal	ra,4a6 <printint>
 70c:	8bca                	mv	s7,s2
      state = 0;
 70e:	4981                	li	s3,0
 710:	b571                	j	59c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 712:	008b8913          	addi	s2,s7,8
 716:	4681                	li	a3,0
 718:	4641                	li	a2,16
 71a:	000bb583          	ld	a1,0(s7)
 71e:	855a                	mv	a0,s6
 720:	d87ff0ef          	jal	ra,4a6 <printint>
        i += 1;
 724:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 726:	8bca                	mv	s7,s2
      state = 0;
 728:	4981                	li	s3,0
        i += 1;
 72a:	bd8d                	j	59c <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 72c:	008b8793          	addi	a5,s7,8
 730:	f8f43423          	sd	a5,-120(s0)
 734:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 738:	03000593          	li	a1,48
 73c:	855a                	mv	a0,s6
 73e:	d4bff0ef          	jal	ra,488 <putc>
  putc(fd, 'x');
 742:	07800593          	li	a1,120
 746:	855a                	mv	a0,s6
 748:	d41ff0ef          	jal	ra,488 <putc>
 74c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 74e:	03c9d793          	srli	a5,s3,0x3c
 752:	97e6                	add	a5,a5,s9
 754:	0007c583          	lbu	a1,0(a5)
 758:	855a                	mv	a0,s6
 75a:	d2fff0ef          	jal	ra,488 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 75e:	0992                	slli	s3,s3,0x4
 760:	397d                	addiw	s2,s2,-1
 762:	fe0916e3          	bnez	s2,74e <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 766:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 76a:	4981                	li	s3,0
 76c:	bd05                	j	59c <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 76e:	008b8913          	addi	s2,s7,8
 772:	000bc583          	lbu	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	d11ff0ef          	jal	ra,488 <putc>
 77c:	8bca                	mv	s7,s2
      state = 0;
 77e:	4981                	li	s3,0
 780:	bd31                	j	59c <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 782:	008b8993          	addi	s3,s7,8
 786:	000bb903          	ld	s2,0(s7)
 78a:	00090f63          	beqz	s2,7a8 <vprintf+0x266>
        for(; *s; s++)
 78e:	00094583          	lbu	a1,0(s2)
 792:	c195                	beqz	a1,7b6 <vprintf+0x274>
          putc(fd, *s);
 794:	855a                	mv	a0,s6
 796:	cf3ff0ef          	jal	ra,488 <putc>
        for(; *s; s++)
 79a:	0905                	addi	s2,s2,1
 79c:	00094583          	lbu	a1,0(s2)
 7a0:	f9f5                	bnez	a1,794 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7a2:	8bce                	mv	s7,s3
      state = 0;
 7a4:	4981                	li	s3,0
 7a6:	bbdd                	j	59c <vprintf+0x5a>
          s = "(null)";
 7a8:	00000917          	auipc	s2,0x0
 7ac:	23090913          	addi	s2,s2,560 # 9d8 <malloc+0x11a>
        for(; *s; s++)
 7b0:	02800593          	li	a1,40
 7b4:	b7c5                	j	794 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7b6:	8bce                	mv	s7,s3
      state = 0;
 7b8:	4981                	li	s3,0
 7ba:	b3cd                	j	59c <vprintf+0x5a>
    }
  }
}
 7bc:	70e6                	ld	ra,120(sp)
 7be:	7446                	ld	s0,112(sp)
 7c0:	74a6                	ld	s1,104(sp)
 7c2:	7906                	ld	s2,96(sp)
 7c4:	69e6                	ld	s3,88(sp)
 7c6:	6a46                	ld	s4,80(sp)
 7c8:	6aa6                	ld	s5,72(sp)
 7ca:	6b06                	ld	s6,64(sp)
 7cc:	7be2                	ld	s7,56(sp)
 7ce:	7c42                	ld	s8,48(sp)
 7d0:	7ca2                	ld	s9,40(sp)
 7d2:	7d02                	ld	s10,32(sp)
 7d4:	6de2                	ld	s11,24(sp)
 7d6:	6109                	addi	sp,sp,128
 7d8:	8082                	ret

00000000000007da <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7da:	715d                	addi	sp,sp,-80
 7dc:	ec06                	sd	ra,24(sp)
 7de:	e822                	sd	s0,16(sp)
 7e0:	1000                	addi	s0,sp,32
 7e2:	e010                	sd	a2,0(s0)
 7e4:	e414                	sd	a3,8(s0)
 7e6:	e818                	sd	a4,16(s0)
 7e8:	ec1c                	sd	a5,24(s0)
 7ea:	03043023          	sd	a6,32(s0)
 7ee:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7f2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f6:	8622                	mv	a2,s0
 7f8:	d4bff0ef          	jal	ra,542 <vprintf>
}
 7fc:	60e2                	ld	ra,24(sp)
 7fe:	6442                	ld	s0,16(sp)
 800:	6161                	addi	sp,sp,80
 802:	8082                	ret

0000000000000804 <printf>:

void
printf(const char *fmt, ...)
{
 804:	711d                	addi	sp,sp,-96
 806:	ec06                	sd	ra,24(sp)
 808:	e822                	sd	s0,16(sp)
 80a:	1000                	addi	s0,sp,32
 80c:	e40c                	sd	a1,8(s0)
 80e:	e810                	sd	a2,16(s0)
 810:	ec14                	sd	a3,24(s0)
 812:	f018                	sd	a4,32(s0)
 814:	f41c                	sd	a5,40(s0)
 816:	03043823          	sd	a6,48(s0)
 81a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 81e:	00840613          	addi	a2,s0,8
 822:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 826:	85aa                	mv	a1,a0
 828:	4505                	li	a0,1
 82a:	d19ff0ef          	jal	ra,542 <vprintf>
}
 82e:	60e2                	ld	ra,24(sp)
 830:	6442                	ld	s0,16(sp)
 832:	6125                	addi	sp,sp,96
 834:	8082                	ret

0000000000000836 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 836:	1141                	addi	sp,sp,-16
 838:	e422                	sd	s0,8(sp)
 83a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 840:	00000797          	auipc	a5,0x0
 844:	7c07b783          	ld	a5,1984(a5) # 1000 <freep>
 848:	a805                	j	878 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 84a:	4618                	lw	a4,8(a2)
 84c:	9db9                	addw	a1,a1,a4
 84e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 852:	6398                	ld	a4,0(a5)
 854:	6318                	ld	a4,0(a4)
 856:	fee53823          	sd	a4,-16(a0)
 85a:	a091                	j	89e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 85c:	ff852703          	lw	a4,-8(a0)
 860:	9e39                	addw	a2,a2,a4
 862:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 864:	ff053703          	ld	a4,-16(a0)
 868:	e398                	sd	a4,0(a5)
 86a:	a099                	j	8b0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86c:	6398                	ld	a4,0(a5)
 86e:	00e7e463          	bltu	a5,a4,876 <free+0x40>
 872:	00e6ea63          	bltu	a3,a4,886 <free+0x50>
{
 876:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 878:	fed7fae3          	bgeu	a5,a3,86c <free+0x36>
 87c:	6398                	ld	a4,0(a5)
 87e:	00e6e463          	bltu	a3,a4,886 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 882:	fee7eae3          	bltu	a5,a4,876 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 886:	ff852583          	lw	a1,-8(a0)
 88a:	6390                	ld	a2,0(a5)
 88c:	02059713          	slli	a4,a1,0x20
 890:	9301                	srli	a4,a4,0x20
 892:	0712                	slli	a4,a4,0x4
 894:	9736                	add	a4,a4,a3
 896:	fae60ae3          	beq	a2,a4,84a <free+0x14>
    bp->s.ptr = p->s.ptr;
 89a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 89e:	4790                	lw	a2,8(a5)
 8a0:	02061713          	slli	a4,a2,0x20
 8a4:	9301                	srli	a4,a4,0x20
 8a6:	0712                	slli	a4,a4,0x4
 8a8:	973e                	add	a4,a4,a5
 8aa:	fae689e3          	beq	a3,a4,85c <free+0x26>
  } else
    p->s.ptr = bp;
 8ae:	e394                	sd	a3,0(a5)
  freep = p;
 8b0:	00000717          	auipc	a4,0x0
 8b4:	74f73823          	sd	a5,1872(a4) # 1000 <freep>
}
 8b8:	6422                	ld	s0,8(sp)
 8ba:	0141                	addi	sp,sp,16
 8bc:	8082                	ret

00000000000008be <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8be:	7139                	addi	sp,sp,-64
 8c0:	fc06                	sd	ra,56(sp)
 8c2:	f822                	sd	s0,48(sp)
 8c4:	f426                	sd	s1,40(sp)
 8c6:	f04a                	sd	s2,32(sp)
 8c8:	ec4e                	sd	s3,24(sp)
 8ca:	e852                	sd	s4,16(sp)
 8cc:	e456                	sd	s5,8(sp)
 8ce:	e05a                	sd	s6,0(sp)
 8d0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d2:	02051493          	slli	s1,a0,0x20
 8d6:	9081                	srli	s1,s1,0x20
 8d8:	04bd                	addi	s1,s1,15
 8da:	8091                	srli	s1,s1,0x4
 8dc:	0014899b          	addiw	s3,s1,1
 8e0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8e2:	00000517          	auipc	a0,0x0
 8e6:	71e53503          	ld	a0,1822(a0) # 1000 <freep>
 8ea:	c515                	beqz	a0,916 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ee:	4798                	lw	a4,8(a5)
 8f0:	02977f63          	bgeu	a4,s1,92e <malloc+0x70>
 8f4:	8a4e                	mv	s4,s3
 8f6:	0009871b          	sext.w	a4,s3
 8fa:	6685                	lui	a3,0x1
 8fc:	00d77363          	bgeu	a4,a3,902 <malloc+0x44>
 900:	6a05                	lui	s4,0x1
 902:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 906:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 90a:	00000917          	auipc	s2,0x0
 90e:	6f690913          	addi	s2,s2,1782 # 1000 <freep>
  if(p == SBRK_ERROR)
 912:	5afd                	li	s5,-1
 914:	a0bd                	j	982 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 916:	00000797          	auipc	a5,0x0
 91a:	6fa78793          	addi	a5,a5,1786 # 1010 <base>
 91e:	00000717          	auipc	a4,0x0
 922:	6ef73123          	sd	a5,1762(a4) # 1000 <freep>
 926:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 928:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92c:	b7e1                	j	8f4 <malloc+0x36>
      if(p->s.size == nunits)
 92e:	02e48b63          	beq	s1,a4,964 <malloc+0xa6>
        p->s.size -= nunits;
 932:	4137073b          	subw	a4,a4,s3
 936:	c798                	sw	a4,8(a5)
        p += p->s.size;
 938:	1702                	slli	a4,a4,0x20
 93a:	9301                	srli	a4,a4,0x20
 93c:	0712                	slli	a4,a4,0x4
 93e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 940:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 944:	00000717          	auipc	a4,0x0
 948:	6aa73e23          	sd	a0,1724(a4) # 1000 <freep>
      return (void*)(p + 1);
 94c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 950:	70e2                	ld	ra,56(sp)
 952:	7442                	ld	s0,48(sp)
 954:	74a2                	ld	s1,40(sp)
 956:	7902                	ld	s2,32(sp)
 958:	69e2                	ld	s3,24(sp)
 95a:	6a42                	ld	s4,16(sp)
 95c:	6aa2                	ld	s5,8(sp)
 95e:	6b02                	ld	s6,0(sp)
 960:	6121                	addi	sp,sp,64
 962:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 964:	6398                	ld	a4,0(a5)
 966:	e118                	sd	a4,0(a0)
 968:	bff1                	j	944 <malloc+0x86>
  hp->s.size = nu;
 96a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 96e:	0541                	addi	a0,a0,16
 970:	ec7ff0ef          	jal	ra,836 <free>
  return freep;
 974:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 978:	dd61                	beqz	a0,950 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 97c:	4798                	lw	a4,8(a5)
 97e:	fa9778e3          	bgeu	a4,s1,92e <malloc+0x70>
    if(p == freep)
 982:	00093703          	ld	a4,0(s2)
 986:	853e                	mv	a0,a5
 988:	fef719e3          	bne	a4,a5,97a <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 98c:	8552                	mv	a0,s4
 98e:	9c9ff0ef          	jal	ra,356 <sbrk>
  if(p == SBRK_ERROR)
 992:	fd551ce3          	bne	a0,s5,96a <malloc+0xac>
        return 0;
 996:	4501                	li	a0,0
 998:	bf65                	j	950 <malloc+0x92>

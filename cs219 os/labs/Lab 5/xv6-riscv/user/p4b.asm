
user/_p4b:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#define PGSIZE 4096  // bytes per page
#define MAXVA (1L << (9 + 9 + 9 + 12 - 1))

int main(int argc, char* argv[]) 
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	e05a                	sd	s6,0(sp)
  12:	0080                	addi	s0,sp,64
    uint64 kernbase = KERNBASE;
    uint64 maxva = MAXVA;

    printf("VA TO PA for 10 pages starting from KERNBASE:\n");
  14:	00001517          	auipc	a0,0x1
  18:	97c50513          	addi	a0,a0,-1668 # 990 <malloc+0xe2>
  1c:	7d8000ef          	jal	ra,7f4 <printf>
    printf("Kernel virtual address => physical address\n");
  20:	00001517          	auipc	a0,0x1
  24:	9a050513          	addi	a0,a0,-1632 # 9c0 <malloc+0x112>
  28:	7cc000ef          	jal	ra,7f4 <printf>
    for (uint64 addr = kernbase; addr < kernbase + 10 * PGSIZE; addr += PGSIZE){
  2c:	4485                	li	s1,1
  2e:	04fe                	slli	s1,s1,0x1f
        uint64 pa = kva_to_pa(addr);
        if (pa == -1) {
  30:	5a7d                	li	s4,-1
            printf("%p => Invalid address\n", (void*)addr);
        } else
            printf("%p => %p\n", (void*)addr, (void*)pa);
  32:	00001a97          	auipc	s5,0x1
  36:	9d6a8a93          	addi	s5,s5,-1578 # a08 <malloc+0x15a>
            printf("%p => Invalid address\n", (void*)addr);
  3a:	00001b17          	auipc	s6,0x1
  3e:	9b6b0b13          	addi	s6,s6,-1610 # 9f0 <malloc+0x142>
    for (uint64 addr = kernbase; addr < kernbase + 10 * PGSIZE; addr += PGSIZE){
  42:	6985                	lui	s3,0x1
  44:	40005937          	lui	s2,0x40005
  48:	0906                	slli	s2,s2,0x1
  4a:	a801                	j	5a <main+0x5a>
            printf("%p => Invalid address\n", (void*)addr);
  4c:	85a6                	mv	a1,s1
  4e:	855a                	mv	a0,s6
  50:	7a4000ef          	jal	ra,7f4 <printf>
    for (uint64 addr = kernbase; addr < kernbase + 10 * PGSIZE; addr += PGSIZE){
  54:	94ce                	add	s1,s1,s3
  56:	01248d63          	beq	s1,s2,70 <main+0x70>
        uint64 pa = kva_to_pa(addr);
  5a:	8526                	mv	a0,s1
  5c:	414000ef          	jal	ra,470 <kva_to_pa>
  60:	862a                	mv	a2,a0
        if (pa == -1) {
  62:	ff4505e3          	beq	a0,s4,4c <main+0x4c>
            printf("%p => %p\n", (void*)addr, (void*)pa);
  66:	85a6                	mv	a1,s1
  68:	8556                	mv	a0,s5
  6a:	78a000ef          	jal	ra,7f4 <printf>
  6e:	b7dd                	j	54 <main+0x54>
    }
    printf("\n\n");
  70:	00001517          	auipc	a0,0x1
  74:	9a850513          	addi	a0,a0,-1624 # a18 <malloc+0x16a>
  78:	77c000ef          	jal	ra,7f4 <printf>

    printf("VA TO PA for 10 pages from MAXVA\n");
  7c:	00001517          	auipc	a0,0x1
  80:	9a450513          	addi	a0,a0,-1628 # a20 <malloc+0x172>
  84:	770000ef          	jal	ra,7f4 <printf>
    printf("Kernel virtual address => physical address\n");
  88:	00001517          	auipc	a0,0x1
  8c:	93850513          	addi	a0,a0,-1736 # 9c0 <malloc+0x112>
  90:	764000ef          	jal	ra,7f4 <printf>
    for (uint64 addr = maxva - PGSIZE; addr >= maxva - 10 * PGSIZE; addr -= PGSIZE){
  94:	040004b7          	lui	s1,0x4000
  98:	14fd                	addi	s1,s1,-1
  9a:	04b2                	slli	s1,s1,0xc
        uint64 pa = kva_to_pa(addr);
        if (pa == -1) {
  9c:	5a7d                	li	s4,-1
            printf("%p => Invalid address\n", (void*)addr);
        } else
            printf("%p => %p\n", (void*)addr, (void*)pa);
  9e:	00001a97          	auipc	s5,0x1
  a2:	96aa8a93          	addi	s5,s5,-1686 # a08 <malloc+0x15a>
            printf("%p => Invalid address\n", (void*)addr);
  a6:	00001b17          	auipc	s6,0x1
  aa:	94ab0b13          	addi	s6,s6,-1718 # 9f0 <malloc+0x142>
    for (uint64 addr = maxva - PGSIZE; addr >= maxva - 10 * PGSIZE; addr -= PGSIZE){
  ae:	79fd                	lui	s3,0xfffff
  b0:	04000937          	lui	s2,0x4000
  b4:	1955                	addi	s2,s2,-11
  b6:	0932                	slli	s2,s2,0xc
  b8:	a801                	j	c8 <main+0xc8>
            printf("%p => Invalid address\n", (void*)addr);
  ba:	85a6                	mv	a1,s1
  bc:	855a                	mv	a0,s6
  be:	736000ef          	jal	ra,7f4 <printf>
    for (uint64 addr = maxva - PGSIZE; addr >= maxva - 10 * PGSIZE; addr -= PGSIZE){
  c2:	94ce                	add	s1,s1,s3
  c4:	01248d63          	beq	s1,s2,de <main+0xde>
        uint64 pa = kva_to_pa(addr);
  c8:	8526                	mv	a0,s1
  ca:	3a6000ef          	jal	ra,470 <kva_to_pa>
  ce:	862a                	mv	a2,a0
        if (pa == -1) {
  d0:	ff4505e3          	beq	a0,s4,ba <main+0xba>
            printf("%p => %p\n", (void*)addr, (void*)pa);
  d4:	85a6                	mv	a1,s1
  d6:	8556                	mv	a0,s5
  d8:	71c000ef          	jal	ra,7f4 <printf>
  dc:	b7dd                	j	c2 <main+0xc2>
    }
    exit(0);
  de:	4501                	li	a0,0
  e0:	2b0000ef          	jal	ra,390 <exit>

00000000000000e4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ec:	f15ff0ef          	jal	ra,0 <main>
  exit(r);
  f0:	2a0000ef          	jal	ra,390 <exit>

00000000000000f4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  fa:	87aa                	mv	a5,a0
  fc:	0585                	addi	a1,a1,1
  fe:	0785                	addi	a5,a5,1
 100:	fff5c703          	lbu	a4,-1(a1)
 104:	fee78fa3          	sb	a4,-1(a5)
 108:	fb75                	bnez	a4,fc <strcpy+0x8>
    ;
  return os;
}
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret

0000000000000110 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 116:	00054783          	lbu	a5,0(a0)
 11a:	cb91                	beqz	a5,12e <strcmp+0x1e>
 11c:	0005c703          	lbu	a4,0(a1)
 120:	00f71763          	bne	a4,a5,12e <strcmp+0x1e>
    p++, q++;
 124:	0505                	addi	a0,a0,1
 126:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 128:	00054783          	lbu	a5,0(a0)
 12c:	fbe5                	bnez	a5,11c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 12e:	0005c503          	lbu	a0,0(a1)
}
 132:	40a7853b          	subw	a0,a5,a0
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strlen>:

uint
strlen(const char *s)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 142:	00054783          	lbu	a5,0(a0)
 146:	cf91                	beqz	a5,162 <strlen+0x26>
 148:	0505                	addi	a0,a0,1
 14a:	87aa                	mv	a5,a0
 14c:	4685                	li	a3,1
 14e:	9e89                	subw	a3,a3,a0
 150:	00f6853b          	addw	a0,a3,a5
 154:	0785                	addi	a5,a5,1
 156:	fff7c703          	lbu	a4,-1(a5)
 15a:	fb7d                	bnez	a4,150 <strlen+0x14>
    ;
  return n;
}
 15c:	6422                	ld	s0,8(sp)
 15e:	0141                	addi	sp,sp,16
 160:	8082                	ret
  for(n = 0; s[n]; n++)
 162:	4501                	li	a0,0
 164:	bfe5                	j	15c <strlen+0x20>

0000000000000166 <memset>:

void*
memset(void *dst, int c, uint n)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 16c:	ca19                	beqz	a2,182 <memset+0x1c>
 16e:	87aa                	mv	a5,a0
 170:	1602                	slli	a2,a2,0x20
 172:	9201                	srli	a2,a2,0x20
 174:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 178:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 17c:	0785                	addi	a5,a5,1
 17e:	fee79de3          	bne	a5,a4,178 <memset+0x12>
  }
  return dst;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret

0000000000000188 <strchr>:

char*
strchr(const char *s, char c)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb99                	beqz	a5,1a8 <strchr+0x20>
    if(*s == c)
 194:	00f58763          	beq	a1,a5,1a2 <strchr+0x1a>
  for(; *s; s++)
 198:	0505                	addi	a0,a0,1
 19a:	00054783          	lbu	a5,0(a0)
 19e:	fbfd                	bnez	a5,194 <strchr+0xc>
      return (char*)s;
  return 0;
 1a0:	4501                	li	a0,0
}
 1a2:	6422                	ld	s0,8(sp)
 1a4:	0141                	addi	sp,sp,16
 1a6:	8082                	ret
  return 0;
 1a8:	4501                	li	a0,0
 1aa:	bfe5                	j	1a2 <strchr+0x1a>

00000000000001ac <gets>:

char*
gets(char *buf, int max)
{
 1ac:	711d                	addi	sp,sp,-96
 1ae:	ec86                	sd	ra,88(sp)
 1b0:	e8a2                	sd	s0,80(sp)
 1b2:	e4a6                	sd	s1,72(sp)
 1b4:	e0ca                	sd	s2,64(sp)
 1b6:	fc4e                	sd	s3,56(sp)
 1b8:	f852                	sd	s4,48(sp)
 1ba:	f456                	sd	s5,40(sp)
 1bc:	f05a                	sd	s6,32(sp)
 1be:	ec5e                	sd	s7,24(sp)
 1c0:	1080                	addi	s0,sp,96
 1c2:	8baa                	mv	s7,a0
 1c4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c6:	892a                	mv	s2,a0
 1c8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ca:	4aa9                	li	s5,10
 1cc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ce:	89a6                	mv	s3,s1
 1d0:	2485                	addiw	s1,s1,1
 1d2:	0344d663          	bge	s1,s4,1fe <gets+0x52>
    cc = read(0, &c, 1);
 1d6:	4605                	li	a2,1
 1d8:	faf40593          	addi	a1,s0,-81
 1dc:	4501                	li	a0,0
 1de:	1ca000ef          	jal	ra,3a8 <read>
    if(cc < 1)
 1e2:	00a05e63          	blez	a0,1fe <gets+0x52>
    buf[i++] = c;
 1e6:	faf44783          	lbu	a5,-81(s0)
 1ea:	00f90023          	sb	a5,0(s2) # 4000000 <base+0x3ffeff0>
    if(c == '\n' || c == '\r')
 1ee:	01578763          	beq	a5,s5,1fc <gets+0x50>
 1f2:	0905                	addi	s2,s2,1
 1f4:	fd679de3          	bne	a5,s6,1ce <gets+0x22>
  for(i=0; i+1 < max; ){
 1f8:	89a6                	mv	s3,s1
 1fa:	a011                	j	1fe <gets+0x52>
 1fc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1fe:	99de                	add	s3,s3,s7
 200:	00098023          	sb	zero,0(s3) # fffffffffffff000 <base+0xffffffffffffdff0>
  return buf;
}
 204:	855e                	mv	a0,s7
 206:	60e6                	ld	ra,88(sp)
 208:	6446                	ld	s0,80(sp)
 20a:	64a6                	ld	s1,72(sp)
 20c:	6906                	ld	s2,64(sp)
 20e:	79e2                	ld	s3,56(sp)
 210:	7a42                	ld	s4,48(sp)
 212:	7aa2                	ld	s5,40(sp)
 214:	7b02                	ld	s6,32(sp)
 216:	6be2                	ld	s7,24(sp)
 218:	6125                	addi	sp,sp,96
 21a:	8082                	ret

000000000000021c <stat>:

int
stat(const char *n, struct stat *st)
{
 21c:	1101                	addi	sp,sp,-32
 21e:	ec06                	sd	ra,24(sp)
 220:	e822                	sd	s0,16(sp)
 222:	e426                	sd	s1,8(sp)
 224:	e04a                	sd	s2,0(sp)
 226:	1000                	addi	s0,sp,32
 228:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22a:	4581                	li	a1,0
 22c:	1a4000ef          	jal	ra,3d0 <open>
  if(fd < 0)
 230:	02054163          	bltz	a0,252 <stat+0x36>
 234:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 236:	85ca                	mv	a1,s2
 238:	1b0000ef          	jal	ra,3e8 <fstat>
 23c:	892a                	mv	s2,a0
  close(fd);
 23e:	8526                	mv	a0,s1
 240:	178000ef          	jal	ra,3b8 <close>
  return r;
}
 244:	854a                	mv	a0,s2
 246:	60e2                	ld	ra,24(sp)
 248:	6442                	ld	s0,16(sp)
 24a:	64a2                	ld	s1,8(sp)
 24c:	6902                	ld	s2,0(sp)
 24e:	6105                	addi	sp,sp,32
 250:	8082                	ret
    return -1;
 252:	597d                	li	s2,-1
 254:	bfc5                	j	244 <stat+0x28>

0000000000000256 <atoi>:

int
atoi(const char *s)
{
 256:	1141                	addi	sp,sp,-16
 258:	e422                	sd	s0,8(sp)
 25a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25c:	00054603          	lbu	a2,0(a0)
 260:	fd06079b          	addiw	a5,a2,-48
 264:	0ff7f793          	andi	a5,a5,255
 268:	4725                	li	a4,9
 26a:	02f76963          	bltu	a4,a5,29c <atoi+0x46>
 26e:	86aa                	mv	a3,a0
  n = 0;
 270:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 272:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 274:	0685                	addi	a3,a3,1
 276:	0025179b          	slliw	a5,a0,0x2
 27a:	9fa9                	addw	a5,a5,a0
 27c:	0017979b          	slliw	a5,a5,0x1
 280:	9fb1                	addw	a5,a5,a2
 282:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 286:	0006c603          	lbu	a2,0(a3)
 28a:	fd06071b          	addiw	a4,a2,-48
 28e:	0ff77713          	andi	a4,a4,255
 292:	fee5f1e3          	bgeu	a1,a4,274 <atoi+0x1e>
  return n;
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
  n = 0;
 29c:	4501                	li	a0,0
 29e:	bfe5                	j	296 <atoi+0x40>

00000000000002a0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a6:	02b57463          	bgeu	a0,a1,2ce <memmove+0x2e>
    while(n-- > 0)
 2aa:	00c05f63          	blez	a2,2c8 <memmove+0x28>
 2ae:	1602                	slli	a2,a2,0x20
 2b0:	9201                	srli	a2,a2,0x20
 2b2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b8:	0585                	addi	a1,a1,1
 2ba:	0705                	addi	a4,a4,1
 2bc:	fff5c683          	lbu	a3,-1(a1)
 2c0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c4:	fee79ae3          	bne	a5,a4,2b8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
    dst += n;
 2ce:	00c50733          	add	a4,a0,a2
    src += n;
 2d2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d4:	fec05ae3          	blez	a2,2c8 <memmove+0x28>
 2d8:	fff6079b          	addiw	a5,a2,-1
 2dc:	1782                	slli	a5,a5,0x20
 2de:	9381                	srli	a5,a5,0x20
 2e0:	fff7c793          	not	a5,a5
 2e4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e6:	15fd                	addi	a1,a1,-1
 2e8:	177d                	addi	a4,a4,-1
 2ea:	0005c683          	lbu	a3,0(a1)
 2ee:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f2:	fee79ae3          	bne	a5,a4,2e6 <memmove+0x46>
 2f6:	bfc9                	j	2c8 <memmove+0x28>

00000000000002f8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e422                	sd	s0,8(sp)
 2fc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2fe:	ca05                	beqz	a2,32e <memcmp+0x36>
 300:	fff6069b          	addiw	a3,a2,-1
 304:	1682                	slli	a3,a3,0x20
 306:	9281                	srli	a3,a3,0x20
 308:	0685                	addi	a3,a3,1
 30a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 30c:	00054783          	lbu	a5,0(a0)
 310:	0005c703          	lbu	a4,0(a1)
 314:	00e79863          	bne	a5,a4,324 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 318:	0505                	addi	a0,a0,1
    p2++;
 31a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 31c:	fed518e3          	bne	a0,a3,30c <memcmp+0x14>
  }
  return 0;
 320:	4501                	li	a0,0
 322:	a019                	j	328 <memcmp+0x30>
      return *p1 - *p2;
 324:	40e7853b          	subw	a0,a5,a4
}
 328:	6422                	ld	s0,8(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret
  return 0;
 32e:	4501                	li	a0,0
 330:	bfe5                	j	328 <memcmp+0x30>

0000000000000332 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 332:	1141                	addi	sp,sp,-16
 334:	e406                	sd	ra,8(sp)
 336:	e022                	sd	s0,0(sp)
 338:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 33a:	f67ff0ef          	jal	ra,2a0 <memmove>
}
 33e:	60a2                	ld	ra,8(sp)
 340:	6402                	ld	s0,0(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret

0000000000000346 <sbrk>:

char *
sbrk(int n) {
 346:	1141                	addi	sp,sp,-16
 348:	e406                	sd	ra,8(sp)
 34a:	e022                	sd	s0,0(sp)
 34c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 34e:	4585                	li	a1,1
 350:	0c8000ef          	jal	ra,418 <sys_sbrk>
}
 354:	60a2                	ld	ra,8(sp)
 356:	6402                	ld	s0,0(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret

000000000000035c <sbrklazy>:

char *
sbrklazy(int n) {
 35c:	1141                	addi	sp,sp,-16
 35e:	e406                	sd	ra,8(sp)
 360:	e022                	sd	s0,0(sp)
 362:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 364:	4589                	li	a1,2
 366:	0b2000ef          	jal	ra,418 <sys_sbrk>
}
 36a:	60a2                	ld	ra,8(sp)
 36c:	6402                	ld	s0,0(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret

0000000000000372 <ugetpid>:

int
ugetpid(void)
{
 372:	1141                	addi	sp,sp,-16
 374:	e422                	sd	s0,8(sp)
 376:	0800                	addi	s0,sp,16
  return (*(int*)UGET);
 378:	040007b7          	lui	a5,0x4000
 37c:	17f5                	addi	a5,a5,-3
 37e:	07b2                	slli	a5,a5,0xc
 380:	4388                	lw	a0,0(a5)
 382:	6422                	ld	s0,8(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret

0000000000000388 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 388:	4885                	li	a7,1
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exit>:
.global exit
exit:
 li a7, SYS_exit
 390:	4889                	li	a7,2
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <wait>:
.global wait
wait:
 li a7, SYS_wait
 398:	488d                	li	a7,3
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a0:	4891                	li	a7,4
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <read>:
.global read
read:
 li a7, SYS_read
 3a8:	4895                	li	a7,5
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <write>:
.global write
write:
 li a7, SYS_write
 3b0:	48c1                	li	a7,16
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <close>:
.global close
close:
 li a7, SYS_close
 3b8:	48d5                	li	a7,21
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c0:	4899                	li	a7,6
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c8:	489d                	li	a7,7
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <open>:
.global open
open:
 li a7, SYS_open
 3d0:	48bd                	li	a7,15
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d8:	48c5                	li	a7,17
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e0:	48c9                	li	a7,18
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e8:	48a1                	li	a7,8
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <link>:
.global link
link:
 li a7, SYS_link
 3f0:	48cd                	li	a7,19
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f8:	48d1                	li	a7,20
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 400:	48a5                	li	a7,9
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <dup>:
.global dup
dup:
 li a7, SYS_dup
 408:	48a9                	li	a7,10
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 410:	48ad                	li	a7,11
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 418:	48b1                	li	a7,12
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <pause>:
.global pause
pause:
 li a7, SYS_pause
 420:	48b5                	li	a7,13
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 428:	48b9                	li	a7,14
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <pte_valid>:
.global pte_valid
pte_valid:
 li a7, SYS_pte_valid
 430:	48d9                	li	a7,22
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <get_pteflags>:
.global get_pteflags
get_pteflags:
 li a7, SYS_get_pteflags
 438:	48dd                	li	a7,23
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <print_pgdirs>:
.global print_pgdirs
print_pgdirs:
 li a7, SYS_print_pgdirs
 440:	48e1                	li	a7,24
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <va_to_pte>:
.global va_to_pte
va_to_pte:
 li a7, SYS_va_to_pte
 448:	48e5                	li	a7,25
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <va_to_pa>:
.global va_to_pa
va_to_pa:
 li a7, SYS_va_to_pa
 450:	48e9                	li	a7,26
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <getvasize>:
.global getvasize
getvasize:
 li a7, SYS_getvasize
 458:	48ed                	li	a7,27
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <getpasize>:
.global getpasize
getpasize:
 li a7, SYS_getpasize
 460:	48f1                	li	a7,28
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <getlazyfaults>:
.global getlazyfaults
getlazyfaults:
 li a7, SYS_getlazyfaults
 468:	48f5                	li	a7,29
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <kva_to_pa>:
.global kva_to_pa
kva_to_pa:
 li a7, SYS_kva_to_pa
 470:	48f9                	li	a7,30
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 478:	1101                	addi	sp,sp,-32
 47a:	ec06                	sd	ra,24(sp)
 47c:	e822                	sd	s0,16(sp)
 47e:	1000                	addi	s0,sp,32
 480:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 484:	4605                	li	a2,1
 486:	fef40593          	addi	a1,s0,-17
 48a:	f27ff0ef          	jal	ra,3b0 <write>
}
 48e:	60e2                	ld	ra,24(sp)
 490:	6442                	ld	s0,16(sp)
 492:	6105                	addi	sp,sp,32
 494:	8082                	ret

0000000000000496 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 496:	715d                	addi	sp,sp,-80
 498:	e486                	sd	ra,72(sp)
 49a:	e0a2                	sd	s0,64(sp)
 49c:	fc26                	sd	s1,56(sp)
 49e:	f84a                	sd	s2,48(sp)
 4a0:	f44e                	sd	s3,40(sp)
 4a2:	0880                	addi	s0,sp,80
 4a4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4a6:	c299                	beqz	a3,4ac <printint+0x16>
 4a8:	0805c163          	bltz	a1,52a <printint+0x94>
  neg = 0;
 4ac:	4881                	li	a7,0
 4ae:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4b2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4b4:	00000517          	auipc	a0,0x0
 4b8:	59c50513          	addi	a0,a0,1436 # a50 <digits>
 4bc:	883e                	mv	a6,a5
 4be:	2785                	addiw	a5,a5,1
 4c0:	02c5f733          	remu	a4,a1,a2
 4c4:	972a                	add	a4,a4,a0
 4c6:	00074703          	lbu	a4,0(a4)
 4ca:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4ce:	872e                	mv	a4,a1
 4d0:	02c5d5b3          	divu	a1,a1,a2
 4d4:	0685                	addi	a3,a3,1
 4d6:	fec773e3          	bgeu	a4,a2,4bc <printint+0x26>
  if(neg)
 4da:	00088b63          	beqz	a7,4f0 <printint+0x5a>
    buf[i++] = '-';
 4de:	fd040713          	addi	a4,s0,-48
 4e2:	97ba                	add	a5,a5,a4
 4e4:	02d00713          	li	a4,45
 4e8:	fee78423          	sb	a4,-24(a5) # 3ffffe8 <base+0x3ffefd8>
 4ec:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4f0:	02f05663          	blez	a5,51c <printint+0x86>
 4f4:	fb840713          	addi	a4,s0,-72
 4f8:	00f704b3          	add	s1,a4,a5
 4fc:	fff70993          	addi	s3,a4,-1
 500:	99be                	add	s3,s3,a5
 502:	37fd                	addiw	a5,a5,-1
 504:	1782                	slli	a5,a5,0x20
 506:	9381                	srli	a5,a5,0x20
 508:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 50c:	fff4c583          	lbu	a1,-1(s1) # 3ffffff <base+0x3ffefef>
 510:	854a                	mv	a0,s2
 512:	f67ff0ef          	jal	ra,478 <putc>
  while(--i >= 0)
 516:	14fd                	addi	s1,s1,-1
 518:	ff349ae3          	bne	s1,s3,50c <printint+0x76>
}
 51c:	60a6                	ld	ra,72(sp)
 51e:	6406                	ld	s0,64(sp)
 520:	74e2                	ld	s1,56(sp)
 522:	7942                	ld	s2,48(sp)
 524:	79a2                	ld	s3,40(sp)
 526:	6161                	addi	sp,sp,80
 528:	8082                	ret
    x = -xx;
 52a:	40b005b3          	neg	a1,a1
    neg = 1;
 52e:	4885                	li	a7,1
    x = -xx;
 530:	bfbd                	j	4ae <printint+0x18>

0000000000000532 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 532:	7119                	addi	sp,sp,-128
 534:	fc86                	sd	ra,120(sp)
 536:	f8a2                	sd	s0,112(sp)
 538:	f4a6                	sd	s1,104(sp)
 53a:	f0ca                	sd	s2,96(sp)
 53c:	ecce                	sd	s3,88(sp)
 53e:	e8d2                	sd	s4,80(sp)
 540:	e4d6                	sd	s5,72(sp)
 542:	e0da                	sd	s6,64(sp)
 544:	fc5e                	sd	s7,56(sp)
 546:	f862                	sd	s8,48(sp)
 548:	f466                	sd	s9,40(sp)
 54a:	f06a                	sd	s10,32(sp)
 54c:	ec6e                	sd	s11,24(sp)
 54e:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 550:	0005c903          	lbu	s2,0(a1)
 554:	24090c63          	beqz	s2,7ac <vprintf+0x27a>
 558:	8b2a                	mv	s6,a0
 55a:	8a2e                	mv	s4,a1
 55c:	8bb2                	mv	s7,a2
  state = 0;
 55e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 560:	4481                	li	s1,0
 562:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 564:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 568:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 56c:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 570:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 574:	00000c97          	auipc	s9,0x0
 578:	4dcc8c93          	addi	s9,s9,1244 # a50 <digits>
 57c:	a005                	j	59c <vprintf+0x6a>
        putc(fd, c0);
 57e:	85ca                	mv	a1,s2
 580:	855a                	mv	a0,s6
 582:	ef7ff0ef          	jal	ra,478 <putc>
 586:	a019                	j	58c <vprintf+0x5a>
    } else if(state == '%'){
 588:	03598263          	beq	s3,s5,5ac <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 58c:	2485                	addiw	s1,s1,1
 58e:	8726                	mv	a4,s1
 590:	009a07b3          	add	a5,s4,s1
 594:	0007c903          	lbu	s2,0(a5)
 598:	20090a63          	beqz	s2,7ac <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 59c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5a0:	fe0994e3          	bnez	s3,588 <vprintf+0x56>
      if(c0 == '%'){
 5a4:	fd579de3          	bne	a5,s5,57e <vprintf+0x4c>
        state = '%';
 5a8:	89be                	mv	s3,a5
 5aa:	b7cd                	j	58c <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5ac:	c3c1                	beqz	a5,62c <vprintf+0xfa>
 5ae:	00ea06b3          	add	a3,s4,a4
 5b2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5b6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5b8:	c681                	beqz	a3,5c0 <vprintf+0x8e>
 5ba:	9752                	add	a4,a4,s4
 5bc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5c0:	03878e63          	beq	a5,s8,5fc <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5c4:	05a78863          	beq	a5,s10,614 <vprintf+0xe2>
      } else if(c0 == 'u'){
 5c8:	0db78b63          	beq	a5,s11,69e <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5cc:	07800713          	li	a4,120
 5d0:	10e78d63          	beq	a5,a4,6ea <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5d4:	07000713          	li	a4,112
 5d8:	14e78263          	beq	a5,a4,71c <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5dc:	06300713          	li	a4,99
 5e0:	16e78f63          	beq	a5,a4,75e <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5e4:	07300713          	li	a4,115
 5e8:	18e78563          	beq	a5,a4,772 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5ec:	05579063          	bne	a5,s5,62c <vprintf+0xfa>
        putc(fd, '%');
 5f0:	85d6                	mv	a1,s5
 5f2:	855a                	mv	a0,s6
 5f4:	e85ff0ef          	jal	ra,478 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	bf49                	j	58c <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5fc:	008b8913          	addi	s2,s7,8
 600:	4685                	li	a3,1
 602:	4629                	li	a2,10
 604:	000ba583          	lw	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	e8dff0ef          	jal	ra,496 <printint>
 60e:	8bca                	mv	s7,s2
      state = 0;
 610:	4981                	li	s3,0
 612:	bfad                	j	58c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 614:	03868663          	beq	a3,s8,640 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 618:	05a68163          	beq	a3,s10,65a <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 61c:	09b68d63          	beq	a3,s11,6b6 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 620:	03a68f63          	beq	a3,s10,65e <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 624:	07800793          	li	a5,120
 628:	0cf68d63          	beq	a3,a5,702 <vprintf+0x1d0>
        putc(fd, '%');
 62c:	85d6                	mv	a1,s5
 62e:	855a                	mv	a0,s6
 630:	e49ff0ef          	jal	ra,478 <putc>
        putc(fd, c0);
 634:	85ca                	mv	a1,s2
 636:	855a                	mv	a0,s6
 638:	e41ff0ef          	jal	ra,478 <putc>
      state = 0;
 63c:	4981                	li	s3,0
 63e:	b7b9                	j	58c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 640:	008b8913          	addi	s2,s7,8
 644:	4685                	li	a3,1
 646:	4629                	li	a2,10
 648:	000bb583          	ld	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e49ff0ef          	jal	ra,496 <printint>
        i += 1;
 652:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
        i += 1;
 658:	bf15                	j	58c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 65a:	03860563          	beq	a2,s8,684 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 65e:	07b60963          	beq	a2,s11,6d0 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 662:	07800793          	li	a5,120
 666:	fcf613e3          	bne	a2,a5,62c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4681                	li	a3,0
 670:	4641                	li	a2,16
 672:	000bb583          	ld	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	e1fff0ef          	jal	ra,496 <printint>
        i += 2;
 67c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
        i += 2;
 682:	b729                	j	58c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 684:	008b8913          	addi	s2,s7,8
 688:	4685                	li	a3,1
 68a:	4629                	li	a2,10
 68c:	000bb583          	ld	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	e05ff0ef          	jal	ra,496 <printint>
        i += 2;
 696:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
        i += 2;
 69c:	bdc5                	j	58c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 69e:	008b8913          	addi	s2,s7,8
 6a2:	4681                	li	a3,0
 6a4:	4629                	li	a2,10
 6a6:	000be583          	lwu	a1,0(s7)
 6aa:	855a                	mv	a0,s6
 6ac:	debff0ef          	jal	ra,496 <printint>
 6b0:	8bca                	mv	s7,s2
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bde1                	j	58c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b6:	008b8913          	addi	s2,s7,8
 6ba:	4681                	li	a3,0
 6bc:	4629                	li	a2,10
 6be:	000bb583          	ld	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	dd3ff0ef          	jal	ra,496 <printint>
        i += 1;
 6c8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ca:	8bca                	mv	s7,s2
      state = 0;
 6cc:	4981                	li	s3,0
        i += 1;
 6ce:	bd7d                	j	58c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d0:	008b8913          	addi	s2,s7,8
 6d4:	4681                	li	a3,0
 6d6:	4629                	li	a2,10
 6d8:	000bb583          	ld	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	db9ff0ef          	jal	ra,496 <printint>
        i += 2;
 6e2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e4:	8bca                	mv	s7,s2
      state = 0;
 6e6:	4981                	li	s3,0
        i += 2;
 6e8:	b555                	j	58c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ea:	008b8913          	addi	s2,s7,8
 6ee:	4681                	li	a3,0
 6f0:	4641                	li	a2,16
 6f2:	000be583          	lwu	a1,0(s7)
 6f6:	855a                	mv	a0,s6
 6f8:	d9fff0ef          	jal	ra,496 <printint>
 6fc:	8bca                	mv	s7,s2
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b571                	j	58c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 702:	008b8913          	addi	s2,s7,8
 706:	4681                	li	a3,0
 708:	4641                	li	a2,16
 70a:	000bb583          	ld	a1,0(s7)
 70e:	855a                	mv	a0,s6
 710:	d87ff0ef          	jal	ra,496 <printint>
        i += 1;
 714:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 716:	8bca                	mv	s7,s2
      state = 0;
 718:	4981                	li	s3,0
        i += 1;
 71a:	bd8d                	j	58c <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 71c:	008b8793          	addi	a5,s7,8
 720:	f8f43423          	sd	a5,-120(s0)
 724:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 728:	03000593          	li	a1,48
 72c:	855a                	mv	a0,s6
 72e:	d4bff0ef          	jal	ra,478 <putc>
  putc(fd, 'x');
 732:	07800593          	li	a1,120
 736:	855a                	mv	a0,s6
 738:	d41ff0ef          	jal	ra,478 <putc>
 73c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 73e:	03c9d793          	srli	a5,s3,0x3c
 742:	97e6                	add	a5,a5,s9
 744:	0007c583          	lbu	a1,0(a5)
 748:	855a                	mv	a0,s6
 74a:	d2fff0ef          	jal	ra,478 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 74e:	0992                	slli	s3,s3,0x4
 750:	397d                	addiw	s2,s2,-1
 752:	fe0916e3          	bnez	s2,73e <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 756:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 75a:	4981                	li	s3,0
 75c:	bd05                	j	58c <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 75e:	008b8913          	addi	s2,s7,8
 762:	000bc583          	lbu	a1,0(s7)
 766:	855a                	mv	a0,s6
 768:	d11ff0ef          	jal	ra,478 <putc>
 76c:	8bca                	mv	s7,s2
      state = 0;
 76e:	4981                	li	s3,0
 770:	bd31                	j	58c <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 772:	008b8993          	addi	s3,s7,8
 776:	000bb903          	ld	s2,0(s7)
 77a:	00090f63          	beqz	s2,798 <vprintf+0x266>
        for(; *s; s++)
 77e:	00094583          	lbu	a1,0(s2)
 782:	c195                	beqz	a1,7a6 <vprintf+0x274>
          putc(fd, *s);
 784:	855a                	mv	a0,s6
 786:	cf3ff0ef          	jal	ra,478 <putc>
        for(; *s; s++)
 78a:	0905                	addi	s2,s2,1
 78c:	00094583          	lbu	a1,0(s2)
 790:	f9f5                	bnez	a1,784 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 792:	8bce                	mv	s7,s3
      state = 0;
 794:	4981                	li	s3,0
 796:	bbdd                	j	58c <vprintf+0x5a>
          s = "(null)";
 798:	00000917          	auipc	s2,0x0
 79c:	2b090913          	addi	s2,s2,688 # a48 <malloc+0x19a>
        for(; *s; s++)
 7a0:	02800593          	li	a1,40
 7a4:	b7c5                	j	784 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7a6:	8bce                	mv	s7,s3
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	b3cd                	j	58c <vprintf+0x5a>
    }
  }
}
 7ac:	70e6                	ld	ra,120(sp)
 7ae:	7446                	ld	s0,112(sp)
 7b0:	74a6                	ld	s1,104(sp)
 7b2:	7906                	ld	s2,96(sp)
 7b4:	69e6                	ld	s3,88(sp)
 7b6:	6a46                	ld	s4,80(sp)
 7b8:	6aa6                	ld	s5,72(sp)
 7ba:	6b06                	ld	s6,64(sp)
 7bc:	7be2                	ld	s7,56(sp)
 7be:	7c42                	ld	s8,48(sp)
 7c0:	7ca2                	ld	s9,40(sp)
 7c2:	7d02                	ld	s10,32(sp)
 7c4:	6de2                	ld	s11,24(sp)
 7c6:	6109                	addi	sp,sp,128
 7c8:	8082                	ret

00000000000007ca <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ca:	715d                	addi	sp,sp,-80
 7cc:	ec06                	sd	ra,24(sp)
 7ce:	e822                	sd	s0,16(sp)
 7d0:	1000                	addi	s0,sp,32
 7d2:	e010                	sd	a2,0(s0)
 7d4:	e414                	sd	a3,8(s0)
 7d6:	e818                	sd	a4,16(s0)
 7d8:	ec1c                	sd	a5,24(s0)
 7da:	03043023          	sd	a6,32(s0)
 7de:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e6:	8622                	mv	a2,s0
 7e8:	d4bff0ef          	jal	ra,532 <vprintf>
}
 7ec:	60e2                	ld	ra,24(sp)
 7ee:	6442                	ld	s0,16(sp)
 7f0:	6161                	addi	sp,sp,80
 7f2:	8082                	ret

00000000000007f4 <printf>:

void
printf(const char *fmt, ...)
{
 7f4:	711d                	addi	sp,sp,-96
 7f6:	ec06                	sd	ra,24(sp)
 7f8:	e822                	sd	s0,16(sp)
 7fa:	1000                	addi	s0,sp,32
 7fc:	e40c                	sd	a1,8(s0)
 7fe:	e810                	sd	a2,16(s0)
 800:	ec14                	sd	a3,24(s0)
 802:	f018                	sd	a4,32(s0)
 804:	f41c                	sd	a5,40(s0)
 806:	03043823          	sd	a6,48(s0)
 80a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 80e:	00840613          	addi	a2,s0,8
 812:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 816:	85aa                	mv	a1,a0
 818:	4505                	li	a0,1
 81a:	d19ff0ef          	jal	ra,532 <vprintf>
}
 81e:	60e2                	ld	ra,24(sp)
 820:	6442                	ld	s0,16(sp)
 822:	6125                	addi	sp,sp,96
 824:	8082                	ret

0000000000000826 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 826:	1141                	addi	sp,sp,-16
 828:	e422                	sd	s0,8(sp)
 82a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 82c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 830:	00000797          	auipc	a5,0x0
 834:	7d07b783          	ld	a5,2000(a5) # 1000 <freep>
 838:	a805                	j	868 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 83a:	4618                	lw	a4,8(a2)
 83c:	9db9                	addw	a1,a1,a4
 83e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 842:	6398                	ld	a4,0(a5)
 844:	6318                	ld	a4,0(a4)
 846:	fee53823          	sd	a4,-16(a0)
 84a:	a091                	j	88e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 84c:	ff852703          	lw	a4,-8(a0)
 850:	9e39                	addw	a2,a2,a4
 852:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 854:	ff053703          	ld	a4,-16(a0)
 858:	e398                	sd	a4,0(a5)
 85a:	a099                	j	8a0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85c:	6398                	ld	a4,0(a5)
 85e:	00e7e463          	bltu	a5,a4,866 <free+0x40>
 862:	00e6ea63          	bltu	a3,a4,876 <free+0x50>
{
 866:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 868:	fed7fae3          	bgeu	a5,a3,85c <free+0x36>
 86c:	6398                	ld	a4,0(a5)
 86e:	00e6e463          	bltu	a3,a4,876 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 872:	fee7eae3          	bltu	a5,a4,866 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 876:	ff852583          	lw	a1,-8(a0)
 87a:	6390                	ld	a2,0(a5)
 87c:	02059713          	slli	a4,a1,0x20
 880:	9301                	srli	a4,a4,0x20
 882:	0712                	slli	a4,a4,0x4
 884:	9736                	add	a4,a4,a3
 886:	fae60ae3          	beq	a2,a4,83a <free+0x14>
    bp->s.ptr = p->s.ptr;
 88a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 88e:	4790                	lw	a2,8(a5)
 890:	02061713          	slli	a4,a2,0x20
 894:	9301                	srli	a4,a4,0x20
 896:	0712                	slli	a4,a4,0x4
 898:	973e                	add	a4,a4,a5
 89a:	fae689e3          	beq	a3,a4,84c <free+0x26>
  } else
    p->s.ptr = bp;
 89e:	e394                	sd	a3,0(a5)
  freep = p;
 8a0:	00000717          	auipc	a4,0x0
 8a4:	76f73023          	sd	a5,1888(a4) # 1000 <freep>
}
 8a8:	6422                	ld	s0,8(sp)
 8aa:	0141                	addi	sp,sp,16
 8ac:	8082                	ret

00000000000008ae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ae:	7139                	addi	sp,sp,-64
 8b0:	fc06                	sd	ra,56(sp)
 8b2:	f822                	sd	s0,48(sp)
 8b4:	f426                	sd	s1,40(sp)
 8b6:	f04a                	sd	s2,32(sp)
 8b8:	ec4e                	sd	s3,24(sp)
 8ba:	e852                	sd	s4,16(sp)
 8bc:	e456                	sd	s5,8(sp)
 8be:	e05a                	sd	s6,0(sp)
 8c0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c2:	02051493          	slli	s1,a0,0x20
 8c6:	9081                	srli	s1,s1,0x20
 8c8:	04bd                	addi	s1,s1,15
 8ca:	8091                	srli	s1,s1,0x4
 8cc:	0014899b          	addiw	s3,s1,1
 8d0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d2:	00000517          	auipc	a0,0x0
 8d6:	72e53503          	ld	a0,1838(a0) # 1000 <freep>
 8da:	c515                	beqz	a0,906 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8de:	4798                	lw	a4,8(a5)
 8e0:	02977f63          	bgeu	a4,s1,91e <malloc+0x70>
 8e4:	8a4e                	mv	s4,s3
 8e6:	0009871b          	sext.w	a4,s3
 8ea:	6685                	lui	a3,0x1
 8ec:	00d77363          	bgeu	a4,a3,8f2 <malloc+0x44>
 8f0:	6a05                	lui	s4,0x1
 8f2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8fa:	00000917          	auipc	s2,0x0
 8fe:	70690913          	addi	s2,s2,1798 # 1000 <freep>
  if(p == SBRK_ERROR)
 902:	5afd                	li	s5,-1
 904:	a0bd                	j	972 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 906:	00000797          	auipc	a5,0x0
 90a:	70a78793          	addi	a5,a5,1802 # 1010 <base>
 90e:	00000717          	auipc	a4,0x0
 912:	6ef73923          	sd	a5,1778(a4) # 1000 <freep>
 916:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 918:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 91c:	b7e1                	j	8e4 <malloc+0x36>
      if(p->s.size == nunits)
 91e:	02e48b63          	beq	s1,a4,954 <malloc+0xa6>
        p->s.size -= nunits;
 922:	4137073b          	subw	a4,a4,s3
 926:	c798                	sw	a4,8(a5)
        p += p->s.size;
 928:	1702                	slli	a4,a4,0x20
 92a:	9301                	srli	a4,a4,0x20
 92c:	0712                	slli	a4,a4,0x4
 92e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 930:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 934:	00000717          	auipc	a4,0x0
 938:	6ca73623          	sd	a0,1740(a4) # 1000 <freep>
      return (void*)(p + 1);
 93c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 940:	70e2                	ld	ra,56(sp)
 942:	7442                	ld	s0,48(sp)
 944:	74a2                	ld	s1,40(sp)
 946:	7902                	ld	s2,32(sp)
 948:	69e2                	ld	s3,24(sp)
 94a:	6a42                	ld	s4,16(sp)
 94c:	6aa2                	ld	s5,8(sp)
 94e:	6b02                	ld	s6,0(sp)
 950:	6121                	addi	sp,sp,64
 952:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 954:	6398                	ld	a4,0(a5)
 956:	e118                	sd	a4,0(a0)
 958:	bff1                	j	934 <malloc+0x86>
  hp->s.size = nu;
 95a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 95e:	0541                	addi	a0,a0,16
 960:	ec7ff0ef          	jal	ra,826 <free>
  return freep;
 964:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 968:	dd61                	beqz	a0,940 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 96c:	4798                	lw	a4,8(a5)
 96e:	fa9778e3          	bgeu	a4,s1,91e <malloc+0x70>
    if(p == freep)
 972:	00093703          	ld	a4,0(s2)
 976:	853e                	mv	a0,a5
 978:	fef719e3          	bne	a4,a5,96a <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 97c:	8552                	mv	a0,s4
 97e:	9c9ff0ef          	jal	ra,346 <sbrk>
  if(p == SBRK_ERROR)
 982:	fd551ce3          	bne	a0,s5,95a <malloc+0xac>
        return 0;
 986:	4501                	li	a0,0
 988:	bf65                	j	940 <malloc+0x92>

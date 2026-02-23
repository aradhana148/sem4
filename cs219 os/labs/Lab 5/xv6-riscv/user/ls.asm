
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	2b0000ef          	jal	ra,2c0 <strlen>
  14:	02051793          	slli	a5,a0,0x20
  18:	9381                	srli	a5,a5,0x20
  1a:	97a6                	add	a5,a5,s1
  1c:	02f00693          	li	a3,47
  20:	0097e963          	bltu	a5,s1,32 <fmtname+0x32>
  24:	0007c703          	lbu	a4,0(a5)
  28:	00d70563          	beq	a4,a3,32 <fmtname+0x32>
  2c:	17fd                	addi	a5,a5,-1
  2e:	fe97fbe3          	bgeu	a5,s1,24 <fmtname+0x24>
    ;
  p++;
  32:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  36:	8526                	mv	a0,s1
  38:	288000ef          	jal	ra,2c0 <strlen>
  3c:	2501                	sext.w	a0,a0
  3e:	47b5                	li	a5,13
  40:	00a7fa63          	bgeu	a5,a0,54 <fmtname+0x54>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';
  return buf;
}
  44:	8526                	mv	a0,s1
  46:	70a2                	ld	ra,40(sp)
  48:	7402                	ld	s0,32(sp)
  4a:	64e2                	ld	s1,24(sp)
  4c:	6942                	ld	s2,16(sp)
  4e:	69a2                	ld	s3,8(sp)
  50:	6145                	addi	sp,sp,48
  52:	8082                	ret
  memmove(buf, p, strlen(p));
  54:	8526                	mv	a0,s1
  56:	26a000ef          	jal	ra,2c0 <strlen>
  5a:	00001997          	auipc	s3,0x1
  5e:	fb698993          	addi	s3,s3,-74 # 1010 <buf.0>
  62:	0005061b          	sext.w	a2,a0
  66:	85a6                	mv	a1,s1
  68:	854e                	mv	a0,s3
  6a:	3ba000ef          	jal	ra,424 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6e:	8526                	mv	a0,s1
  70:	250000ef          	jal	ra,2c0 <strlen>
  74:	0005091b          	sext.w	s2,a0
  78:	8526                	mv	a0,s1
  7a:	246000ef          	jal	ra,2c0 <strlen>
  7e:	1902                	slli	s2,s2,0x20
  80:	02095913          	srli	s2,s2,0x20
  84:	4639                	li	a2,14
  86:	9e09                	subw	a2,a2,a0
  88:	02000593          	li	a1,32
  8c:	01298533          	add	a0,s3,s2
  90:	25a000ef          	jal	ra,2ea <memset>
  buf[sizeof(buf)-1] = '\0';
  94:	00098723          	sb	zero,14(s3)
  return buf;
  98:	84ce                	mv	s1,s3
  9a:	b76d                	j	44 <fmtname+0x44>

000000000000009c <ls>:

void
ls(char *path)
{
  9c:	d9010113          	addi	sp,sp,-624
  a0:	26113423          	sd	ra,616(sp)
  a4:	26813023          	sd	s0,608(sp)
  a8:	24913c23          	sd	s1,600(sp)
  ac:	25213823          	sd	s2,592(sp)
  b0:	25313423          	sd	s3,584(sp)
  b4:	25413023          	sd	s4,576(sp)
  b8:	23513c23          	sd	s5,568(sp)
  bc:	1c80                	addi	s0,sp,624
  be:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, O_RDONLY)) < 0){
  c0:	4581                	li	a1,0
  c2:	492000ef          	jal	ra,554 <open>
  c6:	06054963          	bltz	a0,138 <ls+0x9c>
  ca:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  cc:	d9840593          	addi	a1,s0,-616
  d0:	49c000ef          	jal	ra,56c <fstat>
  d4:	06054b63          	bltz	a0,14a <ls+0xae>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  d8:	da041783          	lh	a5,-608(s0)
  dc:	0007869b          	sext.w	a3,a5
  e0:	4705                	li	a4,1
  e2:	08e68063          	beq	a3,a4,162 <ls+0xc6>
  e6:	37f9                	addiw	a5,a5,-2
  e8:	17c2                	slli	a5,a5,0x30
  ea:	93c1                	srli	a5,a5,0x30
  ec:	02f76263          	bltu	a4,a5,110 <ls+0x74>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
  f0:	854a                	mv	a0,s2
  f2:	f0fff0ef          	jal	ra,0 <fmtname>
  f6:	85aa                	mv	a1,a0
  f8:	da842703          	lw	a4,-600(s0)
  fc:	d9c42683          	lw	a3,-612(s0)
 100:	da041603          	lh	a2,-608(s0)
 104:	00001517          	auipc	a0,0x1
 108:	a3c50513          	addi	a0,a0,-1476 # b40 <malloc+0x10e>
 10c:	06d000ef          	jal	ra,978 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
    }
    break;
  }
  close(fd);
 110:	8526                	mv	a0,s1
 112:	42a000ef          	jal	ra,53c <close>
}
 116:	26813083          	ld	ra,616(sp)
 11a:	26013403          	ld	s0,608(sp)
 11e:	25813483          	ld	s1,600(sp)
 122:	25013903          	ld	s2,592(sp)
 126:	24813983          	ld	s3,584(sp)
 12a:	24013a03          	ld	s4,576(sp)
 12e:	23813a83          	ld	s5,568(sp)
 132:	27010113          	addi	sp,sp,624
 136:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 138:	864a                	mv	a2,s2
 13a:	00001597          	auipc	a1,0x1
 13e:	9d658593          	addi	a1,a1,-1578 # b10 <malloc+0xde>
 142:	4509                	li	a0,2
 144:	00b000ef          	jal	ra,94e <fprintf>
    return;
 148:	b7f9                	j	116 <ls+0x7a>
    fprintf(2, "ls: cannot stat %s\n", path);
 14a:	864a                	mv	a2,s2
 14c:	00001597          	auipc	a1,0x1
 150:	9dc58593          	addi	a1,a1,-1572 # b28 <malloc+0xf6>
 154:	4509                	li	a0,2
 156:	7f8000ef          	jal	ra,94e <fprintf>
    close(fd);
 15a:	8526                	mv	a0,s1
 15c:	3e0000ef          	jal	ra,53c <close>
    return;
 160:	bf5d                	j	116 <ls+0x7a>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 162:	854a                	mv	a0,s2
 164:	15c000ef          	jal	ra,2c0 <strlen>
 168:	2541                	addiw	a0,a0,16
 16a:	20000793          	li	a5,512
 16e:	00a7f963          	bgeu	a5,a0,180 <ls+0xe4>
      printf("ls: path too long\n");
 172:	00001517          	auipc	a0,0x1
 176:	9de50513          	addi	a0,a0,-1570 # b50 <malloc+0x11e>
 17a:	7fe000ef          	jal	ra,978 <printf>
      break;
 17e:	bf49                	j	110 <ls+0x74>
    strcpy(buf, path);
 180:	85ca                	mv	a1,s2
 182:	dc040513          	addi	a0,s0,-576
 186:	0f2000ef          	jal	ra,278 <strcpy>
    p = buf+strlen(buf);
 18a:	dc040513          	addi	a0,s0,-576
 18e:	132000ef          	jal	ra,2c0 <strlen>
 192:	02051913          	slli	s2,a0,0x20
 196:	02095913          	srli	s2,s2,0x20
 19a:	dc040793          	addi	a5,s0,-576
 19e:	993e                	add	s2,s2,a5
    *p++ = '/';
 1a0:	00190993          	addi	s3,s2,1
 1a4:	02f00793          	li	a5,47
 1a8:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 1ac:	00001a17          	auipc	s4,0x1
 1b0:	994a0a13          	addi	s4,s4,-1644 # b40 <malloc+0x10e>
        printf("ls: cannot stat %s\n", buf);
 1b4:	00001a97          	auipc	s5,0x1
 1b8:	974a8a93          	addi	s5,s5,-1676 # b28 <malloc+0xf6>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1bc:	a031                	j	1c8 <ls+0x12c>
        printf("ls: cannot stat %s\n", buf);
 1be:	dc040593          	addi	a1,s0,-576
 1c2:	8556                	mv	a0,s5
 1c4:	7b4000ef          	jal	ra,978 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1c8:	4641                	li	a2,16
 1ca:	db040593          	addi	a1,s0,-592
 1ce:	8526                	mv	a0,s1
 1d0:	35c000ef          	jal	ra,52c <read>
 1d4:	47c1                	li	a5,16
 1d6:	f2f51de3          	bne	a0,a5,110 <ls+0x74>
      if(de.inum == 0)
 1da:	db045783          	lhu	a5,-592(s0)
 1de:	d7ed                	beqz	a5,1c8 <ls+0x12c>
      memmove(p, de.name, DIRSIZ);
 1e0:	4639                	li	a2,14
 1e2:	db240593          	addi	a1,s0,-590
 1e6:	854e                	mv	a0,s3
 1e8:	23c000ef          	jal	ra,424 <memmove>
      p[DIRSIZ] = 0;
 1ec:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 1f0:	d9840593          	addi	a1,s0,-616
 1f4:	dc040513          	addi	a0,s0,-576
 1f8:	1a8000ef          	jal	ra,3a0 <stat>
 1fc:	fc0541e3          	bltz	a0,1be <ls+0x122>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 200:	dc040513          	addi	a0,s0,-576
 204:	dfdff0ef          	jal	ra,0 <fmtname>
 208:	85aa                	mv	a1,a0
 20a:	da842703          	lw	a4,-600(s0)
 20e:	d9c42683          	lw	a3,-612(s0)
 212:	da041603          	lh	a2,-608(s0)
 216:	8552                	mv	a0,s4
 218:	760000ef          	jal	ra,978 <printf>
 21c:	b775                	j	1c8 <ls+0x12c>

000000000000021e <main>:

int
main(int argc, char *argv[])
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	e426                	sd	s1,8(sp)
 226:	e04a                	sd	s2,0(sp)
 228:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 22a:	4785                	li	a5,1
 22c:	02a7d563          	bge	a5,a0,256 <main+0x38>
 230:	00858493          	addi	s1,a1,8
 234:	ffe5091b          	addiw	s2,a0,-2
 238:	1902                	slli	s2,s2,0x20
 23a:	02095913          	srli	s2,s2,0x20
 23e:	090e                	slli	s2,s2,0x3
 240:	05c1                	addi	a1,a1,16
 242:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 244:	6088                	ld	a0,0(s1)
 246:	e57ff0ef          	jal	ra,9c <ls>
  for(i=1; i<argc; i++)
 24a:	04a1                	addi	s1,s1,8
 24c:	ff249ce3          	bne	s1,s2,244 <main+0x26>
  exit(0);
 250:	4501                	li	a0,0
 252:	2c2000ef          	jal	ra,514 <exit>
    ls(".");
 256:	00001517          	auipc	a0,0x1
 25a:	91250513          	addi	a0,a0,-1774 # b68 <malloc+0x136>
 25e:	e3fff0ef          	jal	ra,9c <ls>
    exit(0);
 262:	4501                	li	a0,0
 264:	2b0000ef          	jal	ra,514 <exit>

0000000000000268 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 270:	fafff0ef          	jal	ra,21e <main>
  exit(r);
 274:	2a0000ef          	jal	ra,514 <exit>

0000000000000278 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 27e:	87aa                	mv	a5,a0
 280:	0585                	addi	a1,a1,1
 282:	0785                	addi	a5,a5,1
 284:	fff5c703          	lbu	a4,-1(a1)
 288:	fee78fa3          	sb	a4,-1(a5)
 28c:	fb75                	bnez	a4,280 <strcpy+0x8>
    ;
  return os;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29a:	00054783          	lbu	a5,0(a0)
 29e:	cb91                	beqz	a5,2b2 <strcmp+0x1e>
 2a0:	0005c703          	lbu	a4,0(a1)
 2a4:	00f71763          	bne	a4,a5,2b2 <strcmp+0x1e>
    p++, q++;
 2a8:	0505                	addi	a0,a0,1
 2aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	fbe5                	bnez	a5,2a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b2:	0005c503          	lbu	a0,0(a1)
}
 2b6:	40a7853b          	subw	a0,a5,a0
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <strlen>:

uint
strlen(const char *s)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	cf91                	beqz	a5,2e6 <strlen+0x26>
 2cc:	0505                	addi	a0,a0,1
 2ce:	87aa                	mv	a5,a0
 2d0:	4685                	li	a3,1
 2d2:	9e89                	subw	a3,a3,a0
 2d4:	00f6853b          	addw	a0,a3,a5
 2d8:	0785                	addi	a5,a5,1
 2da:	fff7c703          	lbu	a4,-1(a5)
 2de:	fb7d                	bnez	a4,2d4 <strlen+0x14>
    ;
  return n;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
  for(n = 0; s[n]; n++)
 2e6:	4501                	li	a0,0
 2e8:	bfe5                	j	2e0 <strlen+0x20>

00000000000002ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f0:	ca19                	beqz	a2,306 <memset+0x1c>
 2f2:	87aa                	mv	a5,a0
 2f4:	1602                	slli	a2,a2,0x20
 2f6:	9201                	srli	a2,a2,0x20
 2f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 300:	0785                	addi	a5,a5,1
 302:	fee79de3          	bne	a5,a4,2fc <memset+0x12>
  }
  return dst;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <strchr>:

char*
strchr(const char *s, char c)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  for(; *s; s++)
 312:	00054783          	lbu	a5,0(a0)
 316:	cb99                	beqz	a5,32c <strchr+0x20>
    if(*s == c)
 318:	00f58763          	beq	a1,a5,326 <strchr+0x1a>
  for(; *s; s++)
 31c:	0505                	addi	a0,a0,1
 31e:	00054783          	lbu	a5,0(a0)
 322:	fbfd                	bnez	a5,318 <strchr+0xc>
      return (char*)s;
  return 0;
 324:	4501                	li	a0,0
}
 326:	6422                	ld	s0,8(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret
  return 0;
 32c:	4501                	li	a0,0
 32e:	bfe5                	j	326 <strchr+0x1a>

0000000000000330 <gets>:

char*
gets(char *buf, int max)
{
 330:	711d                	addi	sp,sp,-96
 332:	ec86                	sd	ra,88(sp)
 334:	e8a2                	sd	s0,80(sp)
 336:	e4a6                	sd	s1,72(sp)
 338:	e0ca                	sd	s2,64(sp)
 33a:	fc4e                	sd	s3,56(sp)
 33c:	f852                	sd	s4,48(sp)
 33e:	f456                	sd	s5,40(sp)
 340:	f05a                	sd	s6,32(sp)
 342:	ec5e                	sd	s7,24(sp)
 344:	1080                	addi	s0,sp,96
 346:	8baa                	mv	s7,a0
 348:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34a:	892a                	mv	s2,a0
 34c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 34e:	4aa9                	li	s5,10
 350:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 352:	89a6                	mv	s3,s1
 354:	2485                	addiw	s1,s1,1
 356:	0344d663          	bge	s1,s4,382 <gets+0x52>
    cc = read(0, &c, 1);
 35a:	4605                	li	a2,1
 35c:	faf40593          	addi	a1,s0,-81
 360:	4501                	li	a0,0
 362:	1ca000ef          	jal	ra,52c <read>
    if(cc < 1)
 366:	00a05e63          	blez	a0,382 <gets+0x52>
    buf[i++] = c;
 36a:	faf44783          	lbu	a5,-81(s0)
 36e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 372:	01578763          	beq	a5,s5,380 <gets+0x50>
 376:	0905                	addi	s2,s2,1
 378:	fd679de3          	bne	a5,s6,352 <gets+0x22>
  for(i=0; i+1 < max; ){
 37c:	89a6                	mv	s3,s1
 37e:	a011                	j	382 <gets+0x52>
 380:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 382:	99de                	add	s3,s3,s7
 384:	00098023          	sb	zero,0(s3)
  return buf;
}
 388:	855e                	mv	a0,s7
 38a:	60e6                	ld	ra,88(sp)
 38c:	6446                	ld	s0,80(sp)
 38e:	64a6                	ld	s1,72(sp)
 390:	6906                	ld	s2,64(sp)
 392:	79e2                	ld	s3,56(sp)
 394:	7a42                	ld	s4,48(sp)
 396:	7aa2                	ld	s5,40(sp)
 398:	7b02                	ld	s6,32(sp)
 39a:	6be2                	ld	s7,24(sp)
 39c:	6125                	addi	sp,sp,96
 39e:	8082                	ret

00000000000003a0 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a0:	1101                	addi	sp,sp,-32
 3a2:	ec06                	sd	ra,24(sp)
 3a4:	e822                	sd	s0,16(sp)
 3a6:	e426                	sd	s1,8(sp)
 3a8:	e04a                	sd	s2,0(sp)
 3aa:	1000                	addi	s0,sp,32
 3ac:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3ae:	4581                	li	a1,0
 3b0:	1a4000ef          	jal	ra,554 <open>
  if(fd < 0)
 3b4:	02054163          	bltz	a0,3d6 <stat+0x36>
 3b8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3ba:	85ca                	mv	a1,s2
 3bc:	1b0000ef          	jal	ra,56c <fstat>
 3c0:	892a                	mv	s2,a0
  close(fd);
 3c2:	8526                	mv	a0,s1
 3c4:	178000ef          	jal	ra,53c <close>
  return r;
}
 3c8:	854a                	mv	a0,s2
 3ca:	60e2                	ld	ra,24(sp)
 3cc:	6442                	ld	s0,16(sp)
 3ce:	64a2                	ld	s1,8(sp)
 3d0:	6902                	ld	s2,0(sp)
 3d2:	6105                	addi	sp,sp,32
 3d4:	8082                	ret
    return -1;
 3d6:	597d                	li	s2,-1
 3d8:	bfc5                	j	3c8 <stat+0x28>

00000000000003da <atoi>:

int
atoi(const char *s)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e422                	sd	s0,8(sp)
 3de:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e0:	00054603          	lbu	a2,0(a0)
 3e4:	fd06079b          	addiw	a5,a2,-48
 3e8:	0ff7f793          	andi	a5,a5,255
 3ec:	4725                	li	a4,9
 3ee:	02f76963          	bltu	a4,a5,420 <atoi+0x46>
 3f2:	86aa                	mv	a3,a0
  n = 0;
 3f4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3f6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3f8:	0685                	addi	a3,a3,1
 3fa:	0025179b          	slliw	a5,a0,0x2
 3fe:	9fa9                	addw	a5,a5,a0
 400:	0017979b          	slliw	a5,a5,0x1
 404:	9fb1                	addw	a5,a5,a2
 406:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 40a:	0006c603          	lbu	a2,0(a3)
 40e:	fd06071b          	addiw	a4,a2,-48
 412:	0ff77713          	andi	a4,a4,255
 416:	fee5f1e3          	bgeu	a1,a4,3f8 <atoi+0x1e>
  return n;
}
 41a:	6422                	ld	s0,8(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
  n = 0;
 420:	4501                	li	a0,0
 422:	bfe5                	j	41a <atoi+0x40>

0000000000000424 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 424:	1141                	addi	sp,sp,-16
 426:	e422                	sd	s0,8(sp)
 428:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42a:	02b57463          	bgeu	a0,a1,452 <memmove+0x2e>
    while(n-- > 0)
 42e:	00c05f63          	blez	a2,44c <memmove+0x28>
 432:	1602                	slli	a2,a2,0x20
 434:	9201                	srli	a2,a2,0x20
 436:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43a:	872a                	mv	a4,a0
      *dst++ = *src++;
 43c:	0585                	addi	a1,a1,1
 43e:	0705                	addi	a4,a4,1
 440:	fff5c683          	lbu	a3,-1(a1)
 444:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 448:	fee79ae3          	bne	a5,a4,43c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret
    dst += n;
 452:	00c50733          	add	a4,a0,a2
    src += n;
 456:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 458:	fec05ae3          	blez	a2,44c <memmove+0x28>
 45c:	fff6079b          	addiw	a5,a2,-1
 460:	1782                	slli	a5,a5,0x20
 462:	9381                	srli	a5,a5,0x20
 464:	fff7c793          	not	a5,a5
 468:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46a:	15fd                	addi	a1,a1,-1
 46c:	177d                	addi	a4,a4,-1
 46e:	0005c683          	lbu	a3,0(a1)
 472:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 476:	fee79ae3          	bne	a5,a4,46a <memmove+0x46>
 47a:	bfc9                	j	44c <memmove+0x28>

000000000000047c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 47c:	1141                	addi	sp,sp,-16
 47e:	e422                	sd	s0,8(sp)
 480:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 482:	ca05                	beqz	a2,4b2 <memcmp+0x36>
 484:	fff6069b          	addiw	a3,a2,-1
 488:	1682                	slli	a3,a3,0x20
 48a:	9281                	srli	a3,a3,0x20
 48c:	0685                	addi	a3,a3,1
 48e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 490:	00054783          	lbu	a5,0(a0)
 494:	0005c703          	lbu	a4,0(a1)
 498:	00e79863          	bne	a5,a4,4a8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 49c:	0505                	addi	a0,a0,1
    p2++;
 49e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a0:	fed518e3          	bne	a0,a3,490 <memcmp+0x14>
  }
  return 0;
 4a4:	4501                	li	a0,0
 4a6:	a019                	j	4ac <memcmp+0x30>
      return *p1 - *p2;
 4a8:	40e7853b          	subw	a0,a5,a4
}
 4ac:	6422                	ld	s0,8(sp)
 4ae:	0141                	addi	sp,sp,16
 4b0:	8082                	ret
  return 0;
 4b2:	4501                	li	a0,0
 4b4:	bfe5                	j	4ac <memcmp+0x30>

00000000000004b6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4b6:	1141                	addi	sp,sp,-16
 4b8:	e406                	sd	ra,8(sp)
 4ba:	e022                	sd	s0,0(sp)
 4bc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4be:	f67ff0ef          	jal	ra,424 <memmove>
}
 4c2:	60a2                	ld	ra,8(sp)
 4c4:	6402                	ld	s0,0(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret

00000000000004ca <sbrk>:

char *
sbrk(int n) {
 4ca:	1141                	addi	sp,sp,-16
 4cc:	e406                	sd	ra,8(sp)
 4ce:	e022                	sd	s0,0(sp)
 4d0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d2:	4585                	li	a1,1
 4d4:	0c8000ef          	jal	ra,59c <sys_sbrk>
}
 4d8:	60a2                	ld	ra,8(sp)
 4da:	6402                	ld	s0,0(sp)
 4dc:	0141                	addi	sp,sp,16
 4de:	8082                	ret

00000000000004e0 <sbrklazy>:

char *
sbrklazy(int n) {
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e406                	sd	ra,8(sp)
 4e4:	e022                	sd	s0,0(sp)
 4e6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4e8:	4589                	li	a1,2
 4ea:	0b2000ef          	jal	ra,59c <sys_sbrk>
}
 4ee:	60a2                	ld	ra,8(sp)
 4f0:	6402                	ld	s0,0(sp)
 4f2:	0141                	addi	sp,sp,16
 4f4:	8082                	ret

00000000000004f6 <ugetpid>:

int
ugetpid(void)
{
 4f6:	1141                	addi	sp,sp,-16
 4f8:	e422                	sd	s0,8(sp)
 4fa:	0800                	addi	s0,sp,16
  return (*(int*)UGET);
 4fc:	040007b7          	lui	a5,0x4000
 500:	17f5                	addi	a5,a5,-3
 502:	07b2                	slli	a5,a5,0xc
 504:	4388                	lw	a0,0(a5)
 506:	6422                	ld	s0,8(sp)
 508:	0141                	addi	sp,sp,16
 50a:	8082                	ret

000000000000050c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 50c:	4885                	li	a7,1
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <exit>:
.global exit
exit:
 li a7, SYS_exit
 514:	4889                	li	a7,2
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <wait>:
.global wait
wait:
 li a7, SYS_wait
 51c:	488d                	li	a7,3
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 524:	4891                	li	a7,4
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <read>:
.global read
read:
 li a7, SYS_read
 52c:	4895                	li	a7,5
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <write>:
.global write
write:
 li a7, SYS_write
 534:	48c1                	li	a7,16
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <close>:
.global close
close:
 li a7, SYS_close
 53c:	48d5                	li	a7,21
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <kill>:
.global kill
kill:
 li a7, SYS_kill
 544:	4899                	li	a7,6
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <exec>:
.global exec
exec:
 li a7, SYS_exec
 54c:	489d                	li	a7,7
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <open>:
.global open
open:
 li a7, SYS_open
 554:	48bd                	li	a7,15
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 55c:	48c5                	li	a7,17
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 564:	48c9                	li	a7,18
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 56c:	48a1                	li	a7,8
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <link>:
.global link
link:
 li a7, SYS_link
 574:	48cd                	li	a7,19
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 57c:	48d1                	li	a7,20
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 584:	48a5                	li	a7,9
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <dup>:
.global dup
dup:
 li a7, SYS_dup
 58c:	48a9                	li	a7,10
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 594:	48ad                	li	a7,11
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 59c:	48b1                	li	a7,12
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 5a4:	48b5                	li	a7,13
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5ac:	48b9                	li	a7,14
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <pte_valid>:
.global pte_valid
pte_valid:
 li a7, SYS_pte_valid
 5b4:	48d9                	li	a7,22
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <get_pteflags>:
.global get_pteflags
get_pteflags:
 li a7, SYS_get_pteflags
 5bc:	48dd                	li	a7,23
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <print_pgdirs>:
.global print_pgdirs
print_pgdirs:
 li a7, SYS_print_pgdirs
 5c4:	48e1                	li	a7,24
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <va_to_pte>:
.global va_to_pte
va_to_pte:
 li a7, SYS_va_to_pte
 5cc:	48e5                	li	a7,25
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <va_to_pa>:
.global va_to_pa
va_to_pa:
 li a7, SYS_va_to_pa
 5d4:	48e9                	li	a7,26
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <getvasize>:
.global getvasize
getvasize:
 li a7, SYS_getvasize
 5dc:	48ed                	li	a7,27
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <getpasize>:
.global getpasize
getpasize:
 li a7, SYS_getpasize
 5e4:	48f1                	li	a7,28
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <getlazyfaults>:
.global getlazyfaults
getlazyfaults:
 li a7, SYS_getlazyfaults
 5ec:	48f5                	li	a7,29
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <kva_to_pa>:
.global kva_to_pa
kva_to_pa:
 li a7, SYS_kva_to_pa
 5f4:	48f9                	li	a7,30
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5fc:	1101                	addi	sp,sp,-32
 5fe:	ec06                	sd	ra,24(sp)
 600:	e822                	sd	s0,16(sp)
 602:	1000                	addi	s0,sp,32
 604:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 608:	4605                	li	a2,1
 60a:	fef40593          	addi	a1,s0,-17
 60e:	f27ff0ef          	jal	ra,534 <write>
}
 612:	60e2                	ld	ra,24(sp)
 614:	6442                	ld	s0,16(sp)
 616:	6105                	addi	sp,sp,32
 618:	8082                	ret

000000000000061a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 61a:	715d                	addi	sp,sp,-80
 61c:	e486                	sd	ra,72(sp)
 61e:	e0a2                	sd	s0,64(sp)
 620:	fc26                	sd	s1,56(sp)
 622:	f84a                	sd	s2,48(sp)
 624:	f44e                	sd	s3,40(sp)
 626:	0880                	addi	s0,sp,80
 628:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 62a:	c299                	beqz	a3,630 <printint+0x16>
 62c:	0805c163          	bltz	a1,6ae <printint+0x94>
  neg = 0;
 630:	4881                	li	a7,0
 632:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 636:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 638:	00000517          	auipc	a0,0x0
 63c:	54050513          	addi	a0,a0,1344 # b78 <digits>
 640:	883e                	mv	a6,a5
 642:	2785                	addiw	a5,a5,1
 644:	02c5f733          	remu	a4,a1,a2
 648:	972a                	add	a4,a4,a0
 64a:	00074703          	lbu	a4,0(a4)
 64e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 652:	872e                	mv	a4,a1
 654:	02c5d5b3          	divu	a1,a1,a2
 658:	0685                	addi	a3,a3,1
 65a:	fec773e3          	bgeu	a4,a2,640 <printint+0x26>
  if(neg)
 65e:	00088b63          	beqz	a7,674 <printint+0x5a>
    buf[i++] = '-';
 662:	fd040713          	addi	a4,s0,-48
 666:	97ba                	add	a5,a5,a4
 668:	02d00713          	li	a4,45
 66c:	fee78423          	sb	a4,-24(a5) # 3ffffe8 <base+0x3ffefc8>
 670:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 674:	02f05663          	blez	a5,6a0 <printint+0x86>
 678:	fb840713          	addi	a4,s0,-72
 67c:	00f704b3          	add	s1,a4,a5
 680:	fff70993          	addi	s3,a4,-1
 684:	99be                	add	s3,s3,a5
 686:	37fd                	addiw	a5,a5,-1
 688:	1782                	slli	a5,a5,0x20
 68a:	9381                	srli	a5,a5,0x20
 68c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 690:	fff4c583          	lbu	a1,-1(s1)
 694:	854a                	mv	a0,s2
 696:	f67ff0ef          	jal	ra,5fc <putc>
  while(--i >= 0)
 69a:	14fd                	addi	s1,s1,-1
 69c:	ff349ae3          	bne	s1,s3,690 <printint+0x76>
}
 6a0:	60a6                	ld	ra,72(sp)
 6a2:	6406                	ld	s0,64(sp)
 6a4:	74e2                	ld	s1,56(sp)
 6a6:	7942                	ld	s2,48(sp)
 6a8:	79a2                	ld	s3,40(sp)
 6aa:	6161                	addi	sp,sp,80
 6ac:	8082                	ret
    x = -xx;
 6ae:	40b005b3          	neg	a1,a1
    neg = 1;
 6b2:	4885                	li	a7,1
    x = -xx;
 6b4:	bfbd                	j	632 <printint+0x18>

00000000000006b6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6b6:	7119                	addi	sp,sp,-128
 6b8:	fc86                	sd	ra,120(sp)
 6ba:	f8a2                	sd	s0,112(sp)
 6bc:	f4a6                	sd	s1,104(sp)
 6be:	f0ca                	sd	s2,96(sp)
 6c0:	ecce                	sd	s3,88(sp)
 6c2:	e8d2                	sd	s4,80(sp)
 6c4:	e4d6                	sd	s5,72(sp)
 6c6:	e0da                	sd	s6,64(sp)
 6c8:	fc5e                	sd	s7,56(sp)
 6ca:	f862                	sd	s8,48(sp)
 6cc:	f466                	sd	s9,40(sp)
 6ce:	f06a                	sd	s10,32(sp)
 6d0:	ec6e                	sd	s11,24(sp)
 6d2:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6d4:	0005c903          	lbu	s2,0(a1)
 6d8:	24090c63          	beqz	s2,930 <vprintf+0x27a>
 6dc:	8b2a                	mv	s6,a0
 6de:	8a2e                	mv	s4,a1
 6e0:	8bb2                	mv	s7,a2
  state = 0;
 6e2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6e4:	4481                	li	s1,0
 6e6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6e8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6ec:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6f0:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6f4:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6f8:	00000c97          	auipc	s9,0x0
 6fc:	480c8c93          	addi	s9,s9,1152 # b78 <digits>
 700:	a005                	j	720 <vprintf+0x6a>
        putc(fd, c0);
 702:	85ca                	mv	a1,s2
 704:	855a                	mv	a0,s6
 706:	ef7ff0ef          	jal	ra,5fc <putc>
 70a:	a019                	j	710 <vprintf+0x5a>
    } else if(state == '%'){
 70c:	03598263          	beq	s3,s5,730 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 710:	2485                	addiw	s1,s1,1
 712:	8726                	mv	a4,s1
 714:	009a07b3          	add	a5,s4,s1
 718:	0007c903          	lbu	s2,0(a5)
 71c:	20090a63          	beqz	s2,930 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 720:	0009079b          	sext.w	a5,s2
    if(state == 0){
 724:	fe0994e3          	bnez	s3,70c <vprintf+0x56>
      if(c0 == '%'){
 728:	fd579de3          	bne	a5,s5,702 <vprintf+0x4c>
        state = '%';
 72c:	89be                	mv	s3,a5
 72e:	b7cd                	j	710 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 730:	c3c1                	beqz	a5,7b0 <vprintf+0xfa>
 732:	00ea06b3          	add	a3,s4,a4
 736:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 73a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 73c:	c681                	beqz	a3,744 <vprintf+0x8e>
 73e:	9752                	add	a4,a4,s4
 740:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 744:	03878e63          	beq	a5,s8,780 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 748:	05a78863          	beq	a5,s10,798 <vprintf+0xe2>
      } else if(c0 == 'u'){
 74c:	0db78b63          	beq	a5,s11,822 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 750:	07800713          	li	a4,120
 754:	10e78d63          	beq	a5,a4,86e <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 758:	07000713          	li	a4,112
 75c:	14e78263          	beq	a5,a4,8a0 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 760:	06300713          	li	a4,99
 764:	16e78f63          	beq	a5,a4,8e2 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 768:	07300713          	li	a4,115
 76c:	18e78563          	beq	a5,a4,8f6 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 770:	05579063          	bne	a5,s5,7b0 <vprintf+0xfa>
        putc(fd, '%');
 774:	85d6                	mv	a1,s5
 776:	855a                	mv	a0,s6
 778:	e85ff0ef          	jal	ra,5fc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 77c:	4981                	li	s3,0
 77e:	bf49                	j	710 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 780:	008b8913          	addi	s2,s7,8
 784:	4685                	li	a3,1
 786:	4629                	li	a2,10
 788:	000ba583          	lw	a1,0(s7)
 78c:	855a                	mv	a0,s6
 78e:	e8dff0ef          	jal	ra,61a <printint>
 792:	8bca                	mv	s7,s2
      state = 0;
 794:	4981                	li	s3,0
 796:	bfad                	j	710 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 798:	03868663          	beq	a3,s8,7c4 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 79c:	05a68163          	beq	a3,s10,7de <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 7a0:	09b68d63          	beq	a3,s11,83a <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7a4:	03a68f63          	beq	a3,s10,7e2 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 7a8:	07800793          	li	a5,120
 7ac:	0cf68d63          	beq	a3,a5,886 <vprintf+0x1d0>
        putc(fd, '%');
 7b0:	85d6                	mv	a1,s5
 7b2:	855a                	mv	a0,s6
 7b4:	e49ff0ef          	jal	ra,5fc <putc>
        putc(fd, c0);
 7b8:	85ca                	mv	a1,s2
 7ba:	855a                	mv	a0,s6
 7bc:	e41ff0ef          	jal	ra,5fc <putc>
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	b7b9                	j	710 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7c4:	008b8913          	addi	s2,s7,8
 7c8:	4685                	li	a3,1
 7ca:	4629                	li	a2,10
 7cc:	000bb583          	ld	a1,0(s7)
 7d0:	855a                	mv	a0,s6
 7d2:	e49ff0ef          	jal	ra,61a <printint>
        i += 1;
 7d6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d8:	8bca                	mv	s7,s2
      state = 0;
 7da:	4981                	li	s3,0
        i += 1;
 7dc:	bf15                	j	710 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7de:	03860563          	beq	a2,s8,808 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7e2:	07b60963          	beq	a2,s11,854 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7e6:	07800793          	li	a5,120
 7ea:	fcf613e3          	bne	a2,a5,7b0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ee:	008b8913          	addi	s2,s7,8
 7f2:	4681                	li	a3,0
 7f4:	4641                	li	a2,16
 7f6:	000bb583          	ld	a1,0(s7)
 7fa:	855a                	mv	a0,s6
 7fc:	e1fff0ef          	jal	ra,61a <printint>
        i += 2;
 800:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 802:	8bca                	mv	s7,s2
      state = 0;
 804:	4981                	li	s3,0
        i += 2;
 806:	b729                	j	710 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 808:	008b8913          	addi	s2,s7,8
 80c:	4685                	li	a3,1
 80e:	4629                	li	a2,10
 810:	000bb583          	ld	a1,0(s7)
 814:	855a                	mv	a0,s6
 816:	e05ff0ef          	jal	ra,61a <printint>
        i += 2;
 81a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 81c:	8bca                	mv	s7,s2
      state = 0;
 81e:	4981                	li	s3,0
        i += 2;
 820:	bdc5                	j	710 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 822:	008b8913          	addi	s2,s7,8
 826:	4681                	li	a3,0
 828:	4629                	li	a2,10
 82a:	000be583          	lwu	a1,0(s7)
 82e:	855a                	mv	a0,s6
 830:	debff0ef          	jal	ra,61a <printint>
 834:	8bca                	mv	s7,s2
      state = 0;
 836:	4981                	li	s3,0
 838:	bde1                	j	710 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 83a:	008b8913          	addi	s2,s7,8
 83e:	4681                	li	a3,0
 840:	4629                	li	a2,10
 842:	000bb583          	ld	a1,0(s7)
 846:	855a                	mv	a0,s6
 848:	dd3ff0ef          	jal	ra,61a <printint>
        i += 1;
 84c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 84e:	8bca                	mv	s7,s2
      state = 0;
 850:	4981                	li	s3,0
        i += 1;
 852:	bd7d                	j	710 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 854:	008b8913          	addi	s2,s7,8
 858:	4681                	li	a3,0
 85a:	4629                	li	a2,10
 85c:	000bb583          	ld	a1,0(s7)
 860:	855a                	mv	a0,s6
 862:	db9ff0ef          	jal	ra,61a <printint>
        i += 2;
 866:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 868:	8bca                	mv	s7,s2
      state = 0;
 86a:	4981                	li	s3,0
        i += 2;
 86c:	b555                	j	710 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 86e:	008b8913          	addi	s2,s7,8
 872:	4681                	li	a3,0
 874:	4641                	li	a2,16
 876:	000be583          	lwu	a1,0(s7)
 87a:	855a                	mv	a0,s6
 87c:	d9fff0ef          	jal	ra,61a <printint>
 880:	8bca                	mv	s7,s2
      state = 0;
 882:	4981                	li	s3,0
 884:	b571                	j	710 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 886:	008b8913          	addi	s2,s7,8
 88a:	4681                	li	a3,0
 88c:	4641                	li	a2,16
 88e:	000bb583          	ld	a1,0(s7)
 892:	855a                	mv	a0,s6
 894:	d87ff0ef          	jal	ra,61a <printint>
        i += 1;
 898:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 89a:	8bca                	mv	s7,s2
      state = 0;
 89c:	4981                	li	s3,0
        i += 1;
 89e:	bd8d                	j	710 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 8a0:	008b8793          	addi	a5,s7,8
 8a4:	f8f43423          	sd	a5,-120(s0)
 8a8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8ac:	03000593          	li	a1,48
 8b0:	855a                	mv	a0,s6
 8b2:	d4bff0ef          	jal	ra,5fc <putc>
  putc(fd, 'x');
 8b6:	07800593          	li	a1,120
 8ba:	855a                	mv	a0,s6
 8bc:	d41ff0ef          	jal	ra,5fc <putc>
 8c0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8c2:	03c9d793          	srli	a5,s3,0x3c
 8c6:	97e6                	add	a5,a5,s9
 8c8:	0007c583          	lbu	a1,0(a5)
 8cc:	855a                	mv	a0,s6
 8ce:	d2fff0ef          	jal	ra,5fc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8d2:	0992                	slli	s3,s3,0x4
 8d4:	397d                	addiw	s2,s2,-1
 8d6:	fe0916e3          	bnez	s2,8c2 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 8da:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 8de:	4981                	li	s3,0
 8e0:	bd05                	j	710 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 8e2:	008b8913          	addi	s2,s7,8
 8e6:	000bc583          	lbu	a1,0(s7)
 8ea:	855a                	mv	a0,s6
 8ec:	d11ff0ef          	jal	ra,5fc <putc>
 8f0:	8bca                	mv	s7,s2
      state = 0;
 8f2:	4981                	li	s3,0
 8f4:	bd31                	j	710 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 8f6:	008b8993          	addi	s3,s7,8
 8fa:	000bb903          	ld	s2,0(s7)
 8fe:	00090f63          	beqz	s2,91c <vprintf+0x266>
        for(; *s; s++)
 902:	00094583          	lbu	a1,0(s2)
 906:	c195                	beqz	a1,92a <vprintf+0x274>
          putc(fd, *s);
 908:	855a                	mv	a0,s6
 90a:	cf3ff0ef          	jal	ra,5fc <putc>
        for(; *s; s++)
 90e:	0905                	addi	s2,s2,1
 910:	00094583          	lbu	a1,0(s2)
 914:	f9f5                	bnez	a1,908 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 916:	8bce                	mv	s7,s3
      state = 0;
 918:	4981                	li	s3,0
 91a:	bbdd                	j	710 <vprintf+0x5a>
          s = "(null)";
 91c:	00000917          	auipc	s2,0x0
 920:	25490913          	addi	s2,s2,596 # b70 <malloc+0x13e>
        for(; *s; s++)
 924:	02800593          	li	a1,40
 928:	b7c5                	j	908 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 92a:	8bce                	mv	s7,s3
      state = 0;
 92c:	4981                	li	s3,0
 92e:	b3cd                	j	710 <vprintf+0x5a>
    }
  }
}
 930:	70e6                	ld	ra,120(sp)
 932:	7446                	ld	s0,112(sp)
 934:	74a6                	ld	s1,104(sp)
 936:	7906                	ld	s2,96(sp)
 938:	69e6                	ld	s3,88(sp)
 93a:	6a46                	ld	s4,80(sp)
 93c:	6aa6                	ld	s5,72(sp)
 93e:	6b06                	ld	s6,64(sp)
 940:	7be2                	ld	s7,56(sp)
 942:	7c42                	ld	s8,48(sp)
 944:	7ca2                	ld	s9,40(sp)
 946:	7d02                	ld	s10,32(sp)
 948:	6de2                	ld	s11,24(sp)
 94a:	6109                	addi	sp,sp,128
 94c:	8082                	ret

000000000000094e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 94e:	715d                	addi	sp,sp,-80
 950:	ec06                	sd	ra,24(sp)
 952:	e822                	sd	s0,16(sp)
 954:	1000                	addi	s0,sp,32
 956:	e010                	sd	a2,0(s0)
 958:	e414                	sd	a3,8(s0)
 95a:	e818                	sd	a4,16(s0)
 95c:	ec1c                	sd	a5,24(s0)
 95e:	03043023          	sd	a6,32(s0)
 962:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 966:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 96a:	8622                	mv	a2,s0
 96c:	d4bff0ef          	jal	ra,6b6 <vprintf>
}
 970:	60e2                	ld	ra,24(sp)
 972:	6442                	ld	s0,16(sp)
 974:	6161                	addi	sp,sp,80
 976:	8082                	ret

0000000000000978 <printf>:

void
printf(const char *fmt, ...)
{
 978:	711d                	addi	sp,sp,-96
 97a:	ec06                	sd	ra,24(sp)
 97c:	e822                	sd	s0,16(sp)
 97e:	1000                	addi	s0,sp,32
 980:	e40c                	sd	a1,8(s0)
 982:	e810                	sd	a2,16(s0)
 984:	ec14                	sd	a3,24(s0)
 986:	f018                	sd	a4,32(s0)
 988:	f41c                	sd	a5,40(s0)
 98a:	03043823          	sd	a6,48(s0)
 98e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 992:	00840613          	addi	a2,s0,8
 996:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 99a:	85aa                	mv	a1,a0
 99c:	4505                	li	a0,1
 99e:	d19ff0ef          	jal	ra,6b6 <vprintf>
}
 9a2:	60e2                	ld	ra,24(sp)
 9a4:	6442                	ld	s0,16(sp)
 9a6:	6125                	addi	sp,sp,96
 9a8:	8082                	ret

00000000000009aa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9aa:	1141                	addi	sp,sp,-16
 9ac:	e422                	sd	s0,8(sp)
 9ae:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9b0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b4:	00000797          	auipc	a5,0x0
 9b8:	64c7b783          	ld	a5,1612(a5) # 1000 <freep>
 9bc:	a805                	j	9ec <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9be:	4618                	lw	a4,8(a2)
 9c0:	9db9                	addw	a1,a1,a4
 9c2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9c6:	6398                	ld	a4,0(a5)
 9c8:	6318                	ld	a4,0(a4)
 9ca:	fee53823          	sd	a4,-16(a0)
 9ce:	a091                	j	a12 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9d0:	ff852703          	lw	a4,-8(a0)
 9d4:	9e39                	addw	a2,a2,a4
 9d6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9d8:	ff053703          	ld	a4,-16(a0)
 9dc:	e398                	sd	a4,0(a5)
 9de:	a099                	j	a24 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9e0:	6398                	ld	a4,0(a5)
 9e2:	00e7e463          	bltu	a5,a4,9ea <free+0x40>
 9e6:	00e6ea63          	bltu	a3,a4,9fa <free+0x50>
{
 9ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ec:	fed7fae3          	bgeu	a5,a3,9e0 <free+0x36>
 9f0:	6398                	ld	a4,0(a5)
 9f2:	00e6e463          	bltu	a3,a4,9fa <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9f6:	fee7eae3          	bltu	a5,a4,9ea <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9fa:	ff852583          	lw	a1,-8(a0)
 9fe:	6390                	ld	a2,0(a5)
 a00:	02059713          	slli	a4,a1,0x20
 a04:	9301                	srli	a4,a4,0x20
 a06:	0712                	slli	a4,a4,0x4
 a08:	9736                	add	a4,a4,a3
 a0a:	fae60ae3          	beq	a2,a4,9be <free+0x14>
    bp->s.ptr = p->s.ptr;
 a0e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a12:	4790                	lw	a2,8(a5)
 a14:	02061713          	slli	a4,a2,0x20
 a18:	9301                	srli	a4,a4,0x20
 a1a:	0712                	slli	a4,a4,0x4
 a1c:	973e                	add	a4,a4,a5
 a1e:	fae689e3          	beq	a3,a4,9d0 <free+0x26>
  } else
    p->s.ptr = bp;
 a22:	e394                	sd	a3,0(a5)
  freep = p;
 a24:	00000717          	auipc	a4,0x0
 a28:	5cf73e23          	sd	a5,1500(a4) # 1000 <freep>
}
 a2c:	6422                	ld	s0,8(sp)
 a2e:	0141                	addi	sp,sp,16
 a30:	8082                	ret

0000000000000a32 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a32:	7139                	addi	sp,sp,-64
 a34:	fc06                	sd	ra,56(sp)
 a36:	f822                	sd	s0,48(sp)
 a38:	f426                	sd	s1,40(sp)
 a3a:	f04a                	sd	s2,32(sp)
 a3c:	ec4e                	sd	s3,24(sp)
 a3e:	e852                	sd	s4,16(sp)
 a40:	e456                	sd	s5,8(sp)
 a42:	e05a                	sd	s6,0(sp)
 a44:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a46:	02051493          	slli	s1,a0,0x20
 a4a:	9081                	srli	s1,s1,0x20
 a4c:	04bd                	addi	s1,s1,15
 a4e:	8091                	srli	s1,s1,0x4
 a50:	0014899b          	addiw	s3,s1,1
 a54:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a56:	00000517          	auipc	a0,0x0
 a5a:	5aa53503          	ld	a0,1450(a0) # 1000 <freep>
 a5e:	c515                	beqz	a0,a8a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a60:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a62:	4798                	lw	a4,8(a5)
 a64:	02977f63          	bgeu	a4,s1,aa2 <malloc+0x70>
 a68:	8a4e                	mv	s4,s3
 a6a:	0009871b          	sext.w	a4,s3
 a6e:	6685                	lui	a3,0x1
 a70:	00d77363          	bgeu	a4,a3,a76 <malloc+0x44>
 a74:	6a05                	lui	s4,0x1
 a76:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a7a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a7e:	00000917          	auipc	s2,0x0
 a82:	58290913          	addi	s2,s2,1410 # 1000 <freep>
  if(p == SBRK_ERROR)
 a86:	5afd                	li	s5,-1
 a88:	a0bd                	j	af6 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 a8a:	00000797          	auipc	a5,0x0
 a8e:	59678793          	addi	a5,a5,1430 # 1020 <base>
 a92:	00000717          	auipc	a4,0x0
 a96:	56f73723          	sd	a5,1390(a4) # 1000 <freep>
 a9a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a9c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 aa0:	b7e1                	j	a68 <malloc+0x36>
      if(p->s.size == nunits)
 aa2:	02e48b63          	beq	s1,a4,ad8 <malloc+0xa6>
        p->s.size -= nunits;
 aa6:	4137073b          	subw	a4,a4,s3
 aaa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 aac:	1702                	slli	a4,a4,0x20
 aae:	9301                	srli	a4,a4,0x20
 ab0:	0712                	slli	a4,a4,0x4
 ab2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ab4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ab8:	00000717          	auipc	a4,0x0
 abc:	54a73423          	sd	a0,1352(a4) # 1000 <freep>
      return (void*)(p + 1);
 ac0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 ac4:	70e2                	ld	ra,56(sp)
 ac6:	7442                	ld	s0,48(sp)
 ac8:	74a2                	ld	s1,40(sp)
 aca:	7902                	ld	s2,32(sp)
 acc:	69e2                	ld	s3,24(sp)
 ace:	6a42                	ld	s4,16(sp)
 ad0:	6aa2                	ld	s5,8(sp)
 ad2:	6b02                	ld	s6,0(sp)
 ad4:	6121                	addi	sp,sp,64
 ad6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ad8:	6398                	ld	a4,0(a5)
 ada:	e118                	sd	a4,0(a0)
 adc:	bff1                	j	ab8 <malloc+0x86>
  hp->s.size = nu;
 ade:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ae2:	0541                	addi	a0,a0,16
 ae4:	ec7ff0ef          	jal	ra,9aa <free>
  return freep;
 ae8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 aec:	dd61                	beqz	a0,ac4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 af0:	4798                	lw	a4,8(a5)
 af2:	fa9778e3          	bgeu	a4,s1,aa2 <malloc+0x70>
    if(p == freep)
 af6:	00093703          	ld	a4,0(s2)
 afa:	853e                	mv	a0,a5
 afc:	fef719e3          	bne	a4,a5,aee <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 b00:	8552                	mv	a0,s4
 b02:	9c9ff0ef          	jal	ra,4ca <sbrk>
  if(p == SBRK_ERROR)
 b06:	fd551ce3          	bne	a0,s5,ade <malloc+0xac>
        return 0;
 b0a:	4501                	li	a0,0
 b0c:	bf65                	j	ac4 <malloc+0x92>

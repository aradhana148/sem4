
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	02c000ef          	jal	ra,4a <matchhere>
  22:	e919                	bnez	a0,38 <matchstar+0x38>
  }while(*text!='\0' && (*text++==c || c=='.'));
  24:	0004c783          	lbu	a5,0(s1)
  28:	cb89                	beqz	a5,3a <matchstar+0x3a>
  2a:	0485                	addi	s1,s1,1
  2c:	2781                	sext.w	a5,a5
  2e:	ff2786e3          	beq	a5,s2,1a <matchstar+0x1a>
  32:	ff4904e3          	beq	s2,s4,1a <matchstar+0x1a>
  36:	a011                	j	3a <matchstar+0x3a>
      return 1;
  38:	4505                	li	a0,1
  return 0;
}
  3a:	70a2                	ld	ra,40(sp)
  3c:	7402                	ld	s0,32(sp)
  3e:	64e2                	ld	s1,24(sp)
  40:	6942                	ld	s2,16(sp)
  42:	69a2                	ld	s3,8(sp)
  44:	6a02                	ld	s4,0(sp)
  46:	6145                	addi	sp,sp,48
  48:	8082                	ret

000000000000004a <matchhere>:
  if(re[0] == '\0')
  4a:	00054703          	lbu	a4,0(a0)
  4e:	c73d                	beqz	a4,bc <matchhere+0x72>
{
  50:	1141                	addi	sp,sp,-16
  52:	e406                	sd	ra,8(sp)
  54:	e022                	sd	s0,0(sp)
  56:	0800                	addi	s0,sp,16
  58:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5a:	00154683          	lbu	a3,1(a0)
  5e:	02a00613          	li	a2,42
  62:	02c68563          	beq	a3,a2,8c <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  66:	02400613          	li	a2,36
  6a:	02c70863          	beq	a4,a2,9a <matchhere+0x50>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  6e:	0005c683          	lbu	a3,0(a1)
  return 0;
  72:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  74:	ca81                	beqz	a3,84 <matchhere+0x3a>
  76:	02e00613          	li	a2,46
  7a:	02c70b63          	beq	a4,a2,b0 <matchhere+0x66>
  return 0;
  7e:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  80:	02d70863          	beq	a4,a3,b0 <matchhere+0x66>
}
  84:	60a2                	ld	ra,8(sp)
  86:	6402                	ld	s0,0(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret
    return matchstar(re[0], re+2, text);
  8c:	862e                	mv	a2,a1
  8e:	00250593          	addi	a1,a0,2
  92:	853a                	mv	a0,a4
  94:	f6dff0ef          	jal	ra,0 <matchstar>
  98:	b7f5                	j	84 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  9a:	c691                	beqz	a3,a6 <matchhere+0x5c>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  9c:	0005c683          	lbu	a3,0(a1)
  a0:	fef9                	bnez	a3,7e <matchhere+0x34>
  return 0;
  a2:	4501                	li	a0,0
  a4:	b7c5                	j	84 <matchhere+0x3a>
    return *text == '\0';
  a6:	0005c503          	lbu	a0,0(a1)
  aa:	00153513          	seqz	a0,a0
  ae:	bfd9                	j	84 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b0:	0585                	addi	a1,a1,1
  b2:	00178513          	addi	a0,a5,1
  b6:	f95ff0ef          	jal	ra,4a <matchhere>
  ba:	b7e9                	j	84 <matchhere+0x3a>
    return 1;
  bc:	4505                	li	a0,1
}
  be:	8082                	ret

00000000000000c0 <match>:
{
  c0:	1101                	addi	sp,sp,-32
  c2:	ec06                	sd	ra,24(sp)
  c4:	e822                	sd	s0,16(sp)
  c6:	e426                	sd	s1,8(sp)
  c8:	e04a                	sd	s2,0(sp)
  ca:	1000                	addi	s0,sp,32
  cc:	892a                	mv	s2,a0
  ce:	84ae                	mv	s1,a1
  if(re[0] == '^')
  d0:	00054703          	lbu	a4,0(a0)
  d4:	05e00793          	li	a5,94
  d8:	00f70c63          	beq	a4,a5,f0 <match+0x30>
    if(matchhere(re, text))
  dc:	85a6                	mv	a1,s1
  de:	854a                	mv	a0,s2
  e0:	f6bff0ef          	jal	ra,4a <matchhere>
  e4:	e911                	bnez	a0,f8 <match+0x38>
  }while(*text++ != '\0');
  e6:	0485                	addi	s1,s1,1
  e8:	fff4c783          	lbu	a5,-1(s1)
  ec:	fbe5                	bnez	a5,dc <match+0x1c>
  ee:	a031                	j	fa <match+0x3a>
    return matchhere(re+1, text);
  f0:	0505                	addi	a0,a0,1
  f2:	f59ff0ef          	jal	ra,4a <matchhere>
  f6:	a011                	j	fa <match+0x3a>
      return 1;
  f8:	4505                	li	a0,1
}
  fa:	60e2                	ld	ra,24(sp)
  fc:	6442                	ld	s0,16(sp)
  fe:	64a2                	ld	s1,8(sp)
 100:	6902                	ld	s2,0(sp)
 102:	6105                	addi	sp,sp,32
 104:	8082                	ret

0000000000000106 <grep>:
{
 106:	715d                	addi	sp,sp,-80
 108:	e486                	sd	ra,72(sp)
 10a:	e0a2                	sd	s0,64(sp)
 10c:	fc26                	sd	s1,56(sp)
 10e:	f84a                	sd	s2,48(sp)
 110:	f44e                	sd	s3,40(sp)
 112:	f052                	sd	s4,32(sp)
 114:	ec56                	sd	s5,24(sp)
 116:	e85a                	sd	s6,16(sp)
 118:	e45e                	sd	s7,8(sp)
 11a:	0880                	addi	s0,sp,80
 11c:	89aa                	mv	s3,a0
 11e:	8b2e                	mv	s6,a1
  m = 0;
 120:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 122:	3ff00b93          	li	s7,1023
 126:	00001a97          	auipc	s5,0x1
 12a:	eeaa8a93          	addi	s5,s5,-278 # 1010 <buf>
 12e:	a835                	j	16a <grep+0x64>
      p = q+1;
 130:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 134:	45a9                	li	a1,10
 136:	854a                	mv	a0,s2
 138:	1ba000ef          	jal	ra,2f2 <strchr>
 13c:	84aa                	mv	s1,a0
 13e:	c505                	beqz	a0,166 <grep+0x60>
      *q = 0;
 140:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 144:	85ca                	mv	a1,s2
 146:	854e                	mv	a0,s3
 148:	f79ff0ef          	jal	ra,c0 <match>
 14c:	d175                	beqz	a0,130 <grep+0x2a>
        *q = '\n';
 14e:	47a9                	li	a5,10
 150:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 154:	00148613          	addi	a2,s1,1
 158:	4126063b          	subw	a2,a2,s2
 15c:	85ca                	mv	a1,s2
 15e:	4505                	li	a0,1
 160:	3ba000ef          	jal	ra,51a <write>
 164:	b7f1                	j	130 <grep+0x2a>
    if(m > 0){
 166:	03404363          	bgtz	s4,18c <grep+0x86>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 16a:	414b863b          	subw	a2,s7,s4
 16e:	014a85b3          	add	a1,s5,s4
 172:	855a                	mv	a0,s6
 174:	39e000ef          	jal	ra,512 <read>
 178:	02a05463          	blez	a0,1a0 <grep+0x9a>
    m += n;
 17c:	00aa0a3b          	addw	s4,s4,a0
    buf[m] = '\0';
 180:	014a87b3          	add	a5,s5,s4
 184:	00078023          	sb	zero,0(a5)
    p = buf;
 188:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 18a:	b76d                	j	134 <grep+0x2e>
      m -= p - buf;
 18c:	415907b3          	sub	a5,s2,s5
 190:	40fa0a3b          	subw	s4,s4,a5
      memmove(buf, p, m);
 194:	8652                	mv	a2,s4
 196:	85ca                	mv	a1,s2
 198:	8556                	mv	a0,s5
 19a:	270000ef          	jal	ra,40a <memmove>
 19e:	b7f1                	j	16a <grep+0x64>
}
 1a0:	60a6                	ld	ra,72(sp)
 1a2:	6406                	ld	s0,64(sp)
 1a4:	74e2                	ld	s1,56(sp)
 1a6:	7942                	ld	s2,48(sp)
 1a8:	79a2                	ld	s3,40(sp)
 1aa:	7a02                	ld	s4,32(sp)
 1ac:	6ae2                	ld	s5,24(sp)
 1ae:	6b42                	ld	s6,16(sp)
 1b0:	6ba2                	ld	s7,8(sp)
 1b2:	6161                	addi	sp,sp,80
 1b4:	8082                	ret

00000000000001b6 <main>:
{
 1b6:	7139                	addi	sp,sp,-64
 1b8:	fc06                	sd	ra,56(sp)
 1ba:	f822                	sd	s0,48(sp)
 1bc:	f426                	sd	s1,40(sp)
 1be:	f04a                	sd	s2,32(sp)
 1c0:	ec4e                	sd	s3,24(sp)
 1c2:	e852                	sd	s4,16(sp)
 1c4:	e456                	sd	s5,8(sp)
 1c6:	0080                	addi	s0,sp,64
  if(argc <= 1){
 1c8:	4785                	li	a5,1
 1ca:	04a7d663          	bge	a5,a0,216 <main+0x60>
  pattern = argv[1];
 1ce:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1d2:	4789                	li	a5,2
 1d4:	04a7db63          	bge	a5,a0,22a <main+0x74>
 1d8:	01058913          	addi	s2,a1,16
 1dc:	ffd5099b          	addiw	s3,a0,-3
 1e0:	1982                	slli	s3,s3,0x20
 1e2:	0209d993          	srli	s3,s3,0x20
 1e6:	098e                	slli	s3,s3,0x3
 1e8:	05e1                	addi	a1,a1,24
 1ea:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], O_RDONLY)) < 0){
 1ec:	4581                	li	a1,0
 1ee:	00093503          	ld	a0,0(s2)
 1f2:	348000ef          	jal	ra,53a <open>
 1f6:	84aa                	mv	s1,a0
 1f8:	04054063          	bltz	a0,238 <main+0x82>
    grep(pattern, fd);
 1fc:	85aa                	mv	a1,a0
 1fe:	8552                	mv	a0,s4
 200:	f07ff0ef          	jal	ra,106 <grep>
    close(fd);
 204:	8526                	mv	a0,s1
 206:	31c000ef          	jal	ra,522 <close>
  for(i = 2; i < argc; i++){
 20a:	0921                	addi	s2,s2,8
 20c:	ff3910e3          	bne	s2,s3,1ec <main+0x36>
  exit(0);
 210:	4501                	li	a0,0
 212:	2e8000ef          	jal	ra,4fa <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 216:	00001597          	auipc	a1,0x1
 21a:	8ea58593          	addi	a1,a1,-1814 # b00 <malloc+0xe8>
 21e:	4509                	li	a0,2
 220:	714000ef          	jal	ra,934 <fprintf>
    exit(1);
 224:	4505                	li	a0,1
 226:	2d4000ef          	jal	ra,4fa <exit>
    grep(pattern, 0);
 22a:	4581                	li	a1,0
 22c:	8552                	mv	a0,s4
 22e:	ed9ff0ef          	jal	ra,106 <grep>
    exit(0);
 232:	4501                	li	a0,0
 234:	2c6000ef          	jal	ra,4fa <exit>
      printf("grep: cannot open %s\n", argv[i]);
 238:	00093583          	ld	a1,0(s2)
 23c:	00001517          	auipc	a0,0x1
 240:	8e450513          	addi	a0,a0,-1820 # b20 <malloc+0x108>
 244:	71a000ef          	jal	ra,95e <printf>
      exit(1);
 248:	4505                	li	a0,1
 24a:	2b0000ef          	jal	ra,4fa <exit>

000000000000024e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e406                	sd	ra,8(sp)
 252:	e022                	sd	s0,0(sp)
 254:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 256:	f61ff0ef          	jal	ra,1b6 <main>
  exit(r);
 25a:	2a0000ef          	jal	ra,4fa <exit>

000000000000025e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 264:	87aa                	mv	a5,a0
 266:	0585                	addi	a1,a1,1
 268:	0785                	addi	a5,a5,1
 26a:	fff5c703          	lbu	a4,-1(a1)
 26e:	fee78fa3          	sb	a4,-1(a5)
 272:	fb75                	bnez	a4,266 <strcpy+0x8>
    ;
  return os;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret

000000000000027a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 280:	00054783          	lbu	a5,0(a0)
 284:	cb91                	beqz	a5,298 <strcmp+0x1e>
 286:	0005c703          	lbu	a4,0(a1)
 28a:	00f71763          	bne	a4,a5,298 <strcmp+0x1e>
    p++, q++;
 28e:	0505                	addi	a0,a0,1
 290:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 292:	00054783          	lbu	a5,0(a0)
 296:	fbe5                	bnez	a5,286 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 298:	0005c503          	lbu	a0,0(a1)
}
 29c:	40a7853b          	subw	a0,a5,a0
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret

00000000000002a6 <strlen>:

uint
strlen(const char *s)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e422                	sd	s0,8(sp)
 2aa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	cf91                	beqz	a5,2cc <strlen+0x26>
 2b2:	0505                	addi	a0,a0,1
 2b4:	87aa                	mv	a5,a0
 2b6:	4685                	li	a3,1
 2b8:	9e89                	subw	a3,a3,a0
 2ba:	00f6853b          	addw	a0,a3,a5
 2be:	0785                	addi	a5,a5,1
 2c0:	fff7c703          	lbu	a4,-1(a5)
 2c4:	fb7d                	bnez	a4,2ba <strlen+0x14>
    ;
  return n;
}
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
  for(n = 0; s[n]; n++)
 2cc:	4501                	li	a0,0
 2ce:	bfe5                	j	2c6 <strlen+0x20>

00000000000002d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e422                	sd	s0,8(sp)
 2d4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2d6:	ca19                	beqz	a2,2ec <memset+0x1c>
 2d8:	87aa                	mv	a5,a0
 2da:	1602                	slli	a2,a2,0x20
 2dc:	9201                	srli	a2,a2,0x20
 2de:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2e6:	0785                	addi	a5,a5,1
 2e8:	fee79de3          	bne	a5,a4,2e2 <memset+0x12>
  }
  return dst;
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret

00000000000002f2 <strchr>:

char*
strchr(const char *s, char c)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	cb99                	beqz	a5,312 <strchr+0x20>
    if(*s == c)
 2fe:	00f58763          	beq	a1,a5,30c <strchr+0x1a>
  for(; *s; s++)
 302:	0505                	addi	a0,a0,1
 304:	00054783          	lbu	a5,0(a0)
 308:	fbfd                	bnez	a5,2fe <strchr+0xc>
      return (char*)s;
  return 0;
 30a:	4501                	li	a0,0
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  return 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <strchr+0x1a>

0000000000000316 <gets>:

char*
gets(char *buf, int max)
{
 316:	711d                	addi	sp,sp,-96
 318:	ec86                	sd	ra,88(sp)
 31a:	e8a2                	sd	s0,80(sp)
 31c:	e4a6                	sd	s1,72(sp)
 31e:	e0ca                	sd	s2,64(sp)
 320:	fc4e                	sd	s3,56(sp)
 322:	f852                	sd	s4,48(sp)
 324:	f456                	sd	s5,40(sp)
 326:	f05a                	sd	s6,32(sp)
 328:	ec5e                	sd	s7,24(sp)
 32a:	1080                	addi	s0,sp,96
 32c:	8baa                	mv	s7,a0
 32e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 330:	892a                	mv	s2,a0
 332:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 334:	4aa9                	li	s5,10
 336:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 338:	89a6                	mv	s3,s1
 33a:	2485                	addiw	s1,s1,1
 33c:	0344d663          	bge	s1,s4,368 <gets+0x52>
    cc = read(0, &c, 1);
 340:	4605                	li	a2,1
 342:	faf40593          	addi	a1,s0,-81
 346:	4501                	li	a0,0
 348:	1ca000ef          	jal	ra,512 <read>
    if(cc < 1)
 34c:	00a05e63          	blez	a0,368 <gets+0x52>
    buf[i++] = c;
 350:	faf44783          	lbu	a5,-81(s0)
 354:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 358:	01578763          	beq	a5,s5,366 <gets+0x50>
 35c:	0905                	addi	s2,s2,1
 35e:	fd679de3          	bne	a5,s6,338 <gets+0x22>
  for(i=0; i+1 < max; ){
 362:	89a6                	mv	s3,s1
 364:	a011                	j	368 <gets+0x52>
 366:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 368:	99de                	add	s3,s3,s7
 36a:	00098023          	sb	zero,0(s3)
  return buf;
}
 36e:	855e                	mv	a0,s7
 370:	60e6                	ld	ra,88(sp)
 372:	6446                	ld	s0,80(sp)
 374:	64a6                	ld	s1,72(sp)
 376:	6906                	ld	s2,64(sp)
 378:	79e2                	ld	s3,56(sp)
 37a:	7a42                	ld	s4,48(sp)
 37c:	7aa2                	ld	s5,40(sp)
 37e:	7b02                	ld	s6,32(sp)
 380:	6be2                	ld	s7,24(sp)
 382:	6125                	addi	sp,sp,96
 384:	8082                	ret

0000000000000386 <stat>:

int
stat(const char *n, struct stat *st)
{
 386:	1101                	addi	sp,sp,-32
 388:	ec06                	sd	ra,24(sp)
 38a:	e822                	sd	s0,16(sp)
 38c:	e426                	sd	s1,8(sp)
 38e:	e04a                	sd	s2,0(sp)
 390:	1000                	addi	s0,sp,32
 392:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 394:	4581                	li	a1,0
 396:	1a4000ef          	jal	ra,53a <open>
  if(fd < 0)
 39a:	02054163          	bltz	a0,3bc <stat+0x36>
 39e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a0:	85ca                	mv	a1,s2
 3a2:	1b0000ef          	jal	ra,552 <fstat>
 3a6:	892a                	mv	s2,a0
  close(fd);
 3a8:	8526                	mv	a0,s1
 3aa:	178000ef          	jal	ra,522 <close>
  return r;
}
 3ae:	854a                	mv	a0,s2
 3b0:	60e2                	ld	ra,24(sp)
 3b2:	6442                	ld	s0,16(sp)
 3b4:	64a2                	ld	s1,8(sp)
 3b6:	6902                	ld	s2,0(sp)
 3b8:	6105                	addi	sp,sp,32
 3ba:	8082                	ret
    return -1;
 3bc:	597d                	li	s2,-1
 3be:	bfc5                	j	3ae <stat+0x28>

00000000000003c0 <atoi>:

int
atoi(const char *s)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e422                	sd	s0,8(sp)
 3c4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c6:	00054603          	lbu	a2,0(a0)
 3ca:	fd06079b          	addiw	a5,a2,-48
 3ce:	0ff7f793          	andi	a5,a5,255
 3d2:	4725                	li	a4,9
 3d4:	02f76963          	bltu	a4,a5,406 <atoi+0x46>
 3d8:	86aa                	mv	a3,a0
  n = 0;
 3da:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3dc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3de:	0685                	addi	a3,a3,1
 3e0:	0025179b          	slliw	a5,a0,0x2
 3e4:	9fa9                	addw	a5,a5,a0
 3e6:	0017979b          	slliw	a5,a5,0x1
 3ea:	9fb1                	addw	a5,a5,a2
 3ec:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3f0:	0006c603          	lbu	a2,0(a3)
 3f4:	fd06071b          	addiw	a4,a2,-48
 3f8:	0ff77713          	andi	a4,a4,255
 3fc:	fee5f1e3          	bgeu	a1,a4,3de <atoi+0x1e>
  return n;
}
 400:	6422                	ld	s0,8(sp)
 402:	0141                	addi	sp,sp,16
 404:	8082                	ret
  n = 0;
 406:	4501                	li	a0,0
 408:	bfe5                	j	400 <atoi+0x40>

000000000000040a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e422                	sd	s0,8(sp)
 40e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 410:	02b57463          	bgeu	a0,a1,438 <memmove+0x2e>
    while(n-- > 0)
 414:	00c05f63          	blez	a2,432 <memmove+0x28>
 418:	1602                	slli	a2,a2,0x20
 41a:	9201                	srli	a2,a2,0x20
 41c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 420:	872a                	mv	a4,a0
      *dst++ = *src++;
 422:	0585                	addi	a1,a1,1
 424:	0705                	addi	a4,a4,1
 426:	fff5c683          	lbu	a3,-1(a1)
 42a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 42e:	fee79ae3          	bne	a5,a4,422 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 432:	6422                	ld	s0,8(sp)
 434:	0141                	addi	sp,sp,16
 436:	8082                	ret
    dst += n;
 438:	00c50733          	add	a4,a0,a2
    src += n;
 43c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 43e:	fec05ae3          	blez	a2,432 <memmove+0x28>
 442:	fff6079b          	addiw	a5,a2,-1
 446:	1782                	slli	a5,a5,0x20
 448:	9381                	srli	a5,a5,0x20
 44a:	fff7c793          	not	a5,a5
 44e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 450:	15fd                	addi	a1,a1,-1
 452:	177d                	addi	a4,a4,-1
 454:	0005c683          	lbu	a3,0(a1)
 458:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 45c:	fee79ae3          	bne	a5,a4,450 <memmove+0x46>
 460:	bfc9                	j	432 <memmove+0x28>

0000000000000462 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 462:	1141                	addi	sp,sp,-16
 464:	e422                	sd	s0,8(sp)
 466:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 468:	ca05                	beqz	a2,498 <memcmp+0x36>
 46a:	fff6069b          	addiw	a3,a2,-1
 46e:	1682                	slli	a3,a3,0x20
 470:	9281                	srli	a3,a3,0x20
 472:	0685                	addi	a3,a3,1
 474:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 476:	00054783          	lbu	a5,0(a0)
 47a:	0005c703          	lbu	a4,0(a1)
 47e:	00e79863          	bne	a5,a4,48e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 482:	0505                	addi	a0,a0,1
    p2++;
 484:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 486:	fed518e3          	bne	a0,a3,476 <memcmp+0x14>
  }
  return 0;
 48a:	4501                	li	a0,0
 48c:	a019                	j	492 <memcmp+0x30>
      return *p1 - *p2;
 48e:	40e7853b          	subw	a0,a5,a4
}
 492:	6422                	ld	s0,8(sp)
 494:	0141                	addi	sp,sp,16
 496:	8082                	ret
  return 0;
 498:	4501                	li	a0,0
 49a:	bfe5                	j	492 <memcmp+0x30>

000000000000049c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 49c:	1141                	addi	sp,sp,-16
 49e:	e406                	sd	ra,8(sp)
 4a0:	e022                	sd	s0,0(sp)
 4a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4a4:	f67ff0ef          	jal	ra,40a <memmove>
}
 4a8:	60a2                	ld	ra,8(sp)
 4aa:	6402                	ld	s0,0(sp)
 4ac:	0141                	addi	sp,sp,16
 4ae:	8082                	ret

00000000000004b0 <sbrk>:

char *
sbrk(int n) {
 4b0:	1141                	addi	sp,sp,-16
 4b2:	e406                	sd	ra,8(sp)
 4b4:	e022                	sd	s0,0(sp)
 4b6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4b8:	4585                	li	a1,1
 4ba:	0c8000ef          	jal	ra,582 <sys_sbrk>
}
 4be:	60a2                	ld	ra,8(sp)
 4c0:	6402                	ld	s0,0(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret

00000000000004c6 <sbrklazy>:

char *
sbrklazy(int n) {
 4c6:	1141                	addi	sp,sp,-16
 4c8:	e406                	sd	ra,8(sp)
 4ca:	e022                	sd	s0,0(sp)
 4cc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ce:	4589                	li	a1,2
 4d0:	0b2000ef          	jal	ra,582 <sys_sbrk>
}
 4d4:	60a2                	ld	ra,8(sp)
 4d6:	6402                	ld	s0,0(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret

00000000000004dc <ugetpid>:

int
ugetpid(void)
{
 4dc:	1141                	addi	sp,sp,-16
 4de:	e422                	sd	s0,8(sp)
 4e0:	0800                	addi	s0,sp,16
  return (*(int*)UGET);
 4e2:	040007b7          	lui	a5,0x4000
 4e6:	17f5                	addi	a5,a5,-3
 4e8:	07b2                	slli	a5,a5,0xc
 4ea:	4388                	lw	a0,0(a5)
 4ec:	6422                	ld	s0,8(sp)
 4ee:	0141                	addi	sp,sp,16
 4f0:	8082                	ret

00000000000004f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f2:	4885                	li	a7,1
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 4fa:	4889                	li	a7,2
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <wait>:
.global wait
wait:
 li a7, SYS_wait
 502:	488d                	li	a7,3
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 50a:	4891                	li	a7,4
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <read>:
.global read
read:
 li a7, SYS_read
 512:	4895                	li	a7,5
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <write>:
.global write
write:
 li a7, SYS_write
 51a:	48c1                	li	a7,16
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <close>:
.global close
close:
 li a7, SYS_close
 522:	48d5                	li	a7,21
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <kill>:
.global kill
kill:
 li a7, SYS_kill
 52a:	4899                	li	a7,6
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <exec>:
.global exec
exec:
 li a7, SYS_exec
 532:	489d                	li	a7,7
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <open>:
.global open
open:
 li a7, SYS_open
 53a:	48bd                	li	a7,15
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 542:	48c5                	li	a7,17
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 54a:	48c9                	li	a7,18
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 552:	48a1                	li	a7,8
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <link>:
.global link
link:
 li a7, SYS_link
 55a:	48cd                	li	a7,19
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 562:	48d1                	li	a7,20
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 56a:	48a5                	li	a7,9
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <dup>:
.global dup
dup:
 li a7, SYS_dup
 572:	48a9                	li	a7,10
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 57a:	48ad                	li	a7,11
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 582:	48b1                	li	a7,12
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <pause>:
.global pause
pause:
 li a7, SYS_pause
 58a:	48b5                	li	a7,13
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 592:	48b9                	li	a7,14
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <pte_valid>:
.global pte_valid
pte_valid:
 li a7, SYS_pte_valid
 59a:	48d9                	li	a7,22
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <get_pteflags>:
.global get_pteflags
get_pteflags:
 li a7, SYS_get_pteflags
 5a2:	48dd                	li	a7,23
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <print_pgdirs>:
.global print_pgdirs
print_pgdirs:
 li a7, SYS_print_pgdirs
 5aa:	48e1                	li	a7,24
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <va_to_pte>:
.global va_to_pte
va_to_pte:
 li a7, SYS_va_to_pte
 5b2:	48e5                	li	a7,25
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <va_to_pa>:
.global va_to_pa
va_to_pa:
 li a7, SYS_va_to_pa
 5ba:	48e9                	li	a7,26
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <getvasize>:
.global getvasize
getvasize:
 li a7, SYS_getvasize
 5c2:	48ed                	li	a7,27
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <getpasize>:
.global getpasize
getpasize:
 li a7, SYS_getpasize
 5ca:	48f1                	li	a7,28
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <getlazyfaults>:
.global getlazyfaults
getlazyfaults:
 li a7, SYS_getlazyfaults
 5d2:	48f5                	li	a7,29
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <kva_to_pa>:
.global kva_to_pa
kva_to_pa:
 li a7, SYS_kva_to_pa
 5da:	48f9                	li	a7,30
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5e2:	1101                	addi	sp,sp,-32
 5e4:	ec06                	sd	ra,24(sp)
 5e6:	e822                	sd	s0,16(sp)
 5e8:	1000                	addi	s0,sp,32
 5ea:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5ee:	4605                	li	a2,1
 5f0:	fef40593          	addi	a1,s0,-17
 5f4:	f27ff0ef          	jal	ra,51a <write>
}
 5f8:	60e2                	ld	ra,24(sp)
 5fa:	6442                	ld	s0,16(sp)
 5fc:	6105                	addi	sp,sp,32
 5fe:	8082                	ret

0000000000000600 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 600:	715d                	addi	sp,sp,-80
 602:	e486                	sd	ra,72(sp)
 604:	e0a2                	sd	s0,64(sp)
 606:	fc26                	sd	s1,56(sp)
 608:	f84a                	sd	s2,48(sp)
 60a:	f44e                	sd	s3,40(sp)
 60c:	0880                	addi	s0,sp,80
 60e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 610:	c299                	beqz	a3,616 <printint+0x16>
 612:	0805c163          	bltz	a1,694 <printint+0x94>
  neg = 0;
 616:	4881                	li	a7,0
 618:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 61c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 61e:	00000517          	auipc	a0,0x0
 622:	52250513          	addi	a0,a0,1314 # b40 <digits>
 626:	883e                	mv	a6,a5
 628:	2785                	addiw	a5,a5,1
 62a:	02c5f733          	remu	a4,a1,a2
 62e:	972a                	add	a4,a4,a0
 630:	00074703          	lbu	a4,0(a4)
 634:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 638:	872e                	mv	a4,a1
 63a:	02c5d5b3          	divu	a1,a1,a2
 63e:	0685                	addi	a3,a3,1
 640:	fec773e3          	bgeu	a4,a2,626 <printint+0x26>
  if(neg)
 644:	00088b63          	beqz	a7,65a <printint+0x5a>
    buf[i++] = '-';
 648:	fd040713          	addi	a4,s0,-48
 64c:	97ba                	add	a5,a5,a4
 64e:	02d00713          	li	a4,45
 652:	fee78423          	sb	a4,-24(a5) # 3ffffe8 <base+0x3ffebd8>
 656:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 65a:	02f05663          	blez	a5,686 <printint+0x86>
 65e:	fb840713          	addi	a4,s0,-72
 662:	00f704b3          	add	s1,a4,a5
 666:	fff70993          	addi	s3,a4,-1
 66a:	99be                	add	s3,s3,a5
 66c:	37fd                	addiw	a5,a5,-1
 66e:	1782                	slli	a5,a5,0x20
 670:	9381                	srli	a5,a5,0x20
 672:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 676:	fff4c583          	lbu	a1,-1(s1)
 67a:	854a                	mv	a0,s2
 67c:	f67ff0ef          	jal	ra,5e2 <putc>
  while(--i >= 0)
 680:	14fd                	addi	s1,s1,-1
 682:	ff349ae3          	bne	s1,s3,676 <printint+0x76>
}
 686:	60a6                	ld	ra,72(sp)
 688:	6406                	ld	s0,64(sp)
 68a:	74e2                	ld	s1,56(sp)
 68c:	7942                	ld	s2,48(sp)
 68e:	79a2                	ld	s3,40(sp)
 690:	6161                	addi	sp,sp,80
 692:	8082                	ret
    x = -xx;
 694:	40b005b3          	neg	a1,a1
    neg = 1;
 698:	4885                	li	a7,1
    x = -xx;
 69a:	bfbd                	j	618 <printint+0x18>

000000000000069c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 69c:	7119                	addi	sp,sp,-128
 69e:	fc86                	sd	ra,120(sp)
 6a0:	f8a2                	sd	s0,112(sp)
 6a2:	f4a6                	sd	s1,104(sp)
 6a4:	f0ca                	sd	s2,96(sp)
 6a6:	ecce                	sd	s3,88(sp)
 6a8:	e8d2                	sd	s4,80(sp)
 6aa:	e4d6                	sd	s5,72(sp)
 6ac:	e0da                	sd	s6,64(sp)
 6ae:	fc5e                	sd	s7,56(sp)
 6b0:	f862                	sd	s8,48(sp)
 6b2:	f466                	sd	s9,40(sp)
 6b4:	f06a                	sd	s10,32(sp)
 6b6:	ec6e                	sd	s11,24(sp)
 6b8:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6ba:	0005c903          	lbu	s2,0(a1)
 6be:	24090c63          	beqz	s2,916 <vprintf+0x27a>
 6c2:	8b2a                	mv	s6,a0
 6c4:	8a2e                	mv	s4,a1
 6c6:	8bb2                	mv	s7,a2
  state = 0;
 6c8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6ca:	4481                	li	s1,0
 6cc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6ce:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6d2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6d6:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6da:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6de:	00000c97          	auipc	s9,0x0
 6e2:	462c8c93          	addi	s9,s9,1122 # b40 <digits>
 6e6:	a005                	j	706 <vprintf+0x6a>
        putc(fd, c0);
 6e8:	85ca                	mv	a1,s2
 6ea:	855a                	mv	a0,s6
 6ec:	ef7ff0ef          	jal	ra,5e2 <putc>
 6f0:	a019                	j	6f6 <vprintf+0x5a>
    } else if(state == '%'){
 6f2:	03598263          	beq	s3,s5,716 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6f6:	2485                	addiw	s1,s1,1
 6f8:	8726                	mv	a4,s1
 6fa:	009a07b3          	add	a5,s4,s1
 6fe:	0007c903          	lbu	s2,0(a5)
 702:	20090a63          	beqz	s2,916 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 706:	0009079b          	sext.w	a5,s2
    if(state == 0){
 70a:	fe0994e3          	bnez	s3,6f2 <vprintf+0x56>
      if(c0 == '%'){
 70e:	fd579de3          	bne	a5,s5,6e8 <vprintf+0x4c>
        state = '%';
 712:	89be                	mv	s3,a5
 714:	b7cd                	j	6f6 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 716:	c3c1                	beqz	a5,796 <vprintf+0xfa>
 718:	00ea06b3          	add	a3,s4,a4
 71c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 720:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 722:	c681                	beqz	a3,72a <vprintf+0x8e>
 724:	9752                	add	a4,a4,s4
 726:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 72a:	03878e63          	beq	a5,s8,766 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 72e:	05a78863          	beq	a5,s10,77e <vprintf+0xe2>
      } else if(c0 == 'u'){
 732:	0db78b63          	beq	a5,s11,808 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 736:	07800713          	li	a4,120
 73a:	10e78d63          	beq	a5,a4,854 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 73e:	07000713          	li	a4,112
 742:	14e78263          	beq	a5,a4,886 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 746:	06300713          	li	a4,99
 74a:	16e78f63          	beq	a5,a4,8c8 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 74e:	07300713          	li	a4,115
 752:	18e78563          	beq	a5,a4,8dc <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 756:	05579063          	bne	a5,s5,796 <vprintf+0xfa>
        putc(fd, '%');
 75a:	85d6                	mv	a1,s5
 75c:	855a                	mv	a0,s6
 75e:	e85ff0ef          	jal	ra,5e2 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 762:	4981                	li	s3,0
 764:	bf49                	j	6f6 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 766:	008b8913          	addi	s2,s7,8
 76a:	4685                	li	a3,1
 76c:	4629                	li	a2,10
 76e:	000ba583          	lw	a1,0(s7)
 772:	855a                	mv	a0,s6
 774:	e8dff0ef          	jal	ra,600 <printint>
 778:	8bca                	mv	s7,s2
      state = 0;
 77a:	4981                	li	s3,0
 77c:	bfad                	j	6f6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 77e:	03868663          	beq	a3,s8,7aa <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 782:	05a68163          	beq	a3,s10,7c4 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 786:	09b68d63          	beq	a3,s11,820 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 78a:	03a68f63          	beq	a3,s10,7c8 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 78e:	07800793          	li	a5,120
 792:	0cf68d63          	beq	a3,a5,86c <vprintf+0x1d0>
        putc(fd, '%');
 796:	85d6                	mv	a1,s5
 798:	855a                	mv	a0,s6
 79a:	e49ff0ef          	jal	ra,5e2 <putc>
        putc(fd, c0);
 79e:	85ca                	mv	a1,s2
 7a0:	855a                	mv	a0,s6
 7a2:	e41ff0ef          	jal	ra,5e2 <putc>
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	b7b9                	j	6f6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7aa:	008b8913          	addi	s2,s7,8
 7ae:	4685                	li	a3,1
 7b0:	4629                	li	a2,10
 7b2:	000bb583          	ld	a1,0(s7)
 7b6:	855a                	mv	a0,s6
 7b8:	e49ff0ef          	jal	ra,600 <printint>
        i += 1;
 7bc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7be:	8bca                	mv	s7,s2
      state = 0;
 7c0:	4981                	li	s3,0
        i += 1;
 7c2:	bf15                	j	6f6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7c4:	03860563          	beq	a2,s8,7ee <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7c8:	07b60963          	beq	a2,s11,83a <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7cc:	07800793          	li	a5,120
 7d0:	fcf613e3          	bne	a2,a5,796 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d4:	008b8913          	addi	s2,s7,8
 7d8:	4681                	li	a3,0
 7da:	4641                	li	a2,16
 7dc:	000bb583          	ld	a1,0(s7)
 7e0:	855a                	mv	a0,s6
 7e2:	e1fff0ef          	jal	ra,600 <printint>
        i += 2;
 7e6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7e8:	8bca                	mv	s7,s2
      state = 0;
 7ea:	4981                	li	s3,0
        i += 2;
 7ec:	b729                	j	6f6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ee:	008b8913          	addi	s2,s7,8
 7f2:	4685                	li	a3,1
 7f4:	4629                	li	a2,10
 7f6:	000bb583          	ld	a1,0(s7)
 7fa:	855a                	mv	a0,s6
 7fc:	e05ff0ef          	jal	ra,600 <printint>
        i += 2;
 800:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 802:	8bca                	mv	s7,s2
      state = 0;
 804:	4981                	li	s3,0
        i += 2;
 806:	bdc5                	j	6f6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 808:	008b8913          	addi	s2,s7,8
 80c:	4681                	li	a3,0
 80e:	4629                	li	a2,10
 810:	000be583          	lwu	a1,0(s7)
 814:	855a                	mv	a0,s6
 816:	debff0ef          	jal	ra,600 <printint>
 81a:	8bca                	mv	s7,s2
      state = 0;
 81c:	4981                	li	s3,0
 81e:	bde1                	j	6f6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 820:	008b8913          	addi	s2,s7,8
 824:	4681                	li	a3,0
 826:	4629                	li	a2,10
 828:	000bb583          	ld	a1,0(s7)
 82c:	855a                	mv	a0,s6
 82e:	dd3ff0ef          	jal	ra,600 <printint>
        i += 1;
 832:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 834:	8bca                	mv	s7,s2
      state = 0;
 836:	4981                	li	s3,0
        i += 1;
 838:	bd7d                	j	6f6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 83a:	008b8913          	addi	s2,s7,8
 83e:	4681                	li	a3,0
 840:	4629                	li	a2,10
 842:	000bb583          	ld	a1,0(s7)
 846:	855a                	mv	a0,s6
 848:	db9ff0ef          	jal	ra,600 <printint>
        i += 2;
 84c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 84e:	8bca                	mv	s7,s2
      state = 0;
 850:	4981                	li	s3,0
        i += 2;
 852:	b555                	j	6f6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 854:	008b8913          	addi	s2,s7,8
 858:	4681                	li	a3,0
 85a:	4641                	li	a2,16
 85c:	000be583          	lwu	a1,0(s7)
 860:	855a                	mv	a0,s6
 862:	d9fff0ef          	jal	ra,600 <printint>
 866:	8bca                	mv	s7,s2
      state = 0;
 868:	4981                	li	s3,0
 86a:	b571                	j	6f6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 86c:	008b8913          	addi	s2,s7,8
 870:	4681                	li	a3,0
 872:	4641                	li	a2,16
 874:	000bb583          	ld	a1,0(s7)
 878:	855a                	mv	a0,s6
 87a:	d87ff0ef          	jal	ra,600 <printint>
        i += 1;
 87e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 880:	8bca                	mv	s7,s2
      state = 0;
 882:	4981                	li	s3,0
        i += 1;
 884:	bd8d                	j	6f6 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 886:	008b8793          	addi	a5,s7,8
 88a:	f8f43423          	sd	a5,-120(s0)
 88e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 892:	03000593          	li	a1,48
 896:	855a                	mv	a0,s6
 898:	d4bff0ef          	jal	ra,5e2 <putc>
  putc(fd, 'x');
 89c:	07800593          	li	a1,120
 8a0:	855a                	mv	a0,s6
 8a2:	d41ff0ef          	jal	ra,5e2 <putc>
 8a6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8a8:	03c9d793          	srli	a5,s3,0x3c
 8ac:	97e6                	add	a5,a5,s9
 8ae:	0007c583          	lbu	a1,0(a5)
 8b2:	855a                	mv	a0,s6
 8b4:	d2fff0ef          	jal	ra,5e2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8b8:	0992                	slli	s3,s3,0x4
 8ba:	397d                	addiw	s2,s2,-1
 8bc:	fe0916e3          	bnez	s2,8a8 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 8c0:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 8c4:	4981                	li	s3,0
 8c6:	bd05                	j	6f6 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 8c8:	008b8913          	addi	s2,s7,8
 8cc:	000bc583          	lbu	a1,0(s7)
 8d0:	855a                	mv	a0,s6
 8d2:	d11ff0ef          	jal	ra,5e2 <putc>
 8d6:	8bca                	mv	s7,s2
      state = 0;
 8d8:	4981                	li	s3,0
 8da:	bd31                	j	6f6 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 8dc:	008b8993          	addi	s3,s7,8
 8e0:	000bb903          	ld	s2,0(s7)
 8e4:	00090f63          	beqz	s2,902 <vprintf+0x266>
        for(; *s; s++)
 8e8:	00094583          	lbu	a1,0(s2)
 8ec:	c195                	beqz	a1,910 <vprintf+0x274>
          putc(fd, *s);
 8ee:	855a                	mv	a0,s6
 8f0:	cf3ff0ef          	jal	ra,5e2 <putc>
        for(; *s; s++)
 8f4:	0905                	addi	s2,s2,1
 8f6:	00094583          	lbu	a1,0(s2)
 8fa:	f9f5                	bnez	a1,8ee <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 8fc:	8bce                	mv	s7,s3
      state = 0;
 8fe:	4981                	li	s3,0
 900:	bbdd                	j	6f6 <vprintf+0x5a>
          s = "(null)";
 902:	00000917          	auipc	s2,0x0
 906:	23690913          	addi	s2,s2,566 # b38 <malloc+0x120>
        for(; *s; s++)
 90a:	02800593          	li	a1,40
 90e:	b7c5                	j	8ee <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 910:	8bce                	mv	s7,s3
      state = 0;
 912:	4981                	li	s3,0
 914:	b3cd                	j	6f6 <vprintf+0x5a>
    }
  }
}
 916:	70e6                	ld	ra,120(sp)
 918:	7446                	ld	s0,112(sp)
 91a:	74a6                	ld	s1,104(sp)
 91c:	7906                	ld	s2,96(sp)
 91e:	69e6                	ld	s3,88(sp)
 920:	6a46                	ld	s4,80(sp)
 922:	6aa6                	ld	s5,72(sp)
 924:	6b06                	ld	s6,64(sp)
 926:	7be2                	ld	s7,56(sp)
 928:	7c42                	ld	s8,48(sp)
 92a:	7ca2                	ld	s9,40(sp)
 92c:	7d02                	ld	s10,32(sp)
 92e:	6de2                	ld	s11,24(sp)
 930:	6109                	addi	sp,sp,128
 932:	8082                	ret

0000000000000934 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 934:	715d                	addi	sp,sp,-80
 936:	ec06                	sd	ra,24(sp)
 938:	e822                	sd	s0,16(sp)
 93a:	1000                	addi	s0,sp,32
 93c:	e010                	sd	a2,0(s0)
 93e:	e414                	sd	a3,8(s0)
 940:	e818                	sd	a4,16(s0)
 942:	ec1c                	sd	a5,24(s0)
 944:	03043023          	sd	a6,32(s0)
 948:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 94c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 950:	8622                	mv	a2,s0
 952:	d4bff0ef          	jal	ra,69c <vprintf>
}
 956:	60e2                	ld	ra,24(sp)
 958:	6442                	ld	s0,16(sp)
 95a:	6161                	addi	sp,sp,80
 95c:	8082                	ret

000000000000095e <printf>:

void
printf(const char *fmt, ...)
{
 95e:	711d                	addi	sp,sp,-96
 960:	ec06                	sd	ra,24(sp)
 962:	e822                	sd	s0,16(sp)
 964:	1000                	addi	s0,sp,32
 966:	e40c                	sd	a1,8(s0)
 968:	e810                	sd	a2,16(s0)
 96a:	ec14                	sd	a3,24(s0)
 96c:	f018                	sd	a4,32(s0)
 96e:	f41c                	sd	a5,40(s0)
 970:	03043823          	sd	a6,48(s0)
 974:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 978:	00840613          	addi	a2,s0,8
 97c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 980:	85aa                	mv	a1,a0
 982:	4505                	li	a0,1
 984:	d19ff0ef          	jal	ra,69c <vprintf>
}
 988:	60e2                	ld	ra,24(sp)
 98a:	6442                	ld	s0,16(sp)
 98c:	6125                	addi	sp,sp,96
 98e:	8082                	ret

0000000000000990 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 990:	1141                	addi	sp,sp,-16
 992:	e422                	sd	s0,8(sp)
 994:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 996:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99a:	00000797          	auipc	a5,0x0
 99e:	6667b783          	ld	a5,1638(a5) # 1000 <freep>
 9a2:	a805                	j	9d2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9a4:	4618                	lw	a4,8(a2)
 9a6:	9db9                	addw	a1,a1,a4
 9a8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9ac:	6398                	ld	a4,0(a5)
 9ae:	6318                	ld	a4,0(a4)
 9b0:	fee53823          	sd	a4,-16(a0)
 9b4:	a091                	j	9f8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9b6:	ff852703          	lw	a4,-8(a0)
 9ba:	9e39                	addw	a2,a2,a4
 9bc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9be:	ff053703          	ld	a4,-16(a0)
 9c2:	e398                	sd	a4,0(a5)
 9c4:	a099                	j	a0a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c6:	6398                	ld	a4,0(a5)
 9c8:	00e7e463          	bltu	a5,a4,9d0 <free+0x40>
 9cc:	00e6ea63          	bltu	a3,a4,9e0 <free+0x50>
{
 9d0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d2:	fed7fae3          	bgeu	a5,a3,9c6 <free+0x36>
 9d6:	6398                	ld	a4,0(a5)
 9d8:	00e6e463          	bltu	a3,a4,9e0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9dc:	fee7eae3          	bltu	a5,a4,9d0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9e0:	ff852583          	lw	a1,-8(a0)
 9e4:	6390                	ld	a2,0(a5)
 9e6:	02059713          	slli	a4,a1,0x20
 9ea:	9301                	srli	a4,a4,0x20
 9ec:	0712                	slli	a4,a4,0x4
 9ee:	9736                	add	a4,a4,a3
 9f0:	fae60ae3          	beq	a2,a4,9a4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9f4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9f8:	4790                	lw	a2,8(a5)
 9fa:	02061713          	slli	a4,a2,0x20
 9fe:	9301                	srli	a4,a4,0x20
 a00:	0712                	slli	a4,a4,0x4
 a02:	973e                	add	a4,a4,a5
 a04:	fae689e3          	beq	a3,a4,9b6 <free+0x26>
  } else
    p->s.ptr = bp;
 a08:	e394                	sd	a3,0(a5)
  freep = p;
 a0a:	00000717          	auipc	a4,0x0
 a0e:	5ef73b23          	sd	a5,1526(a4) # 1000 <freep>
}
 a12:	6422                	ld	s0,8(sp)
 a14:	0141                	addi	sp,sp,16
 a16:	8082                	ret

0000000000000a18 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a18:	7139                	addi	sp,sp,-64
 a1a:	fc06                	sd	ra,56(sp)
 a1c:	f822                	sd	s0,48(sp)
 a1e:	f426                	sd	s1,40(sp)
 a20:	f04a                	sd	s2,32(sp)
 a22:	ec4e                	sd	s3,24(sp)
 a24:	e852                	sd	s4,16(sp)
 a26:	e456                	sd	s5,8(sp)
 a28:	e05a                	sd	s6,0(sp)
 a2a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a2c:	02051493          	slli	s1,a0,0x20
 a30:	9081                	srli	s1,s1,0x20
 a32:	04bd                	addi	s1,s1,15
 a34:	8091                	srli	s1,s1,0x4
 a36:	0014899b          	addiw	s3,s1,1
 a3a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a3c:	00000517          	auipc	a0,0x0
 a40:	5c453503          	ld	a0,1476(a0) # 1000 <freep>
 a44:	c515                	beqz	a0,a70 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a46:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a48:	4798                	lw	a4,8(a5)
 a4a:	02977f63          	bgeu	a4,s1,a88 <malloc+0x70>
 a4e:	8a4e                	mv	s4,s3
 a50:	0009871b          	sext.w	a4,s3
 a54:	6685                	lui	a3,0x1
 a56:	00d77363          	bgeu	a4,a3,a5c <malloc+0x44>
 a5a:	6a05                	lui	s4,0x1
 a5c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a60:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a64:	00000917          	auipc	s2,0x0
 a68:	59c90913          	addi	s2,s2,1436 # 1000 <freep>
  if(p == SBRK_ERROR)
 a6c:	5afd                	li	s5,-1
 a6e:	a0bd                	j	adc <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 a70:	00001797          	auipc	a5,0x1
 a74:	9a078793          	addi	a5,a5,-1632 # 1410 <base>
 a78:	00000717          	auipc	a4,0x0
 a7c:	58f73423          	sd	a5,1416(a4) # 1000 <freep>
 a80:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a82:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a86:	b7e1                	j	a4e <malloc+0x36>
      if(p->s.size == nunits)
 a88:	02e48b63          	beq	s1,a4,abe <malloc+0xa6>
        p->s.size -= nunits;
 a8c:	4137073b          	subw	a4,a4,s3
 a90:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a92:	1702                	slli	a4,a4,0x20
 a94:	9301                	srli	a4,a4,0x20
 a96:	0712                	slli	a4,a4,0x4
 a98:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a9a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a9e:	00000717          	auipc	a4,0x0
 aa2:	56a73123          	sd	a0,1378(a4) # 1000 <freep>
      return (void*)(p + 1);
 aa6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 aaa:	70e2                	ld	ra,56(sp)
 aac:	7442                	ld	s0,48(sp)
 aae:	74a2                	ld	s1,40(sp)
 ab0:	7902                	ld	s2,32(sp)
 ab2:	69e2                	ld	s3,24(sp)
 ab4:	6a42                	ld	s4,16(sp)
 ab6:	6aa2                	ld	s5,8(sp)
 ab8:	6b02                	ld	s6,0(sp)
 aba:	6121                	addi	sp,sp,64
 abc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 abe:	6398                	ld	a4,0(a5)
 ac0:	e118                	sd	a4,0(a0)
 ac2:	bff1                	j	a9e <malloc+0x86>
  hp->s.size = nu;
 ac4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ac8:	0541                	addi	a0,a0,16
 aca:	ec7ff0ef          	jal	ra,990 <free>
  return freep;
 ace:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ad2:	dd61                	beqz	a0,aaa <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ad6:	4798                	lw	a4,8(a5)
 ad8:	fa9778e3          	bgeu	a4,s1,a88 <malloc+0x70>
    if(p == freep)
 adc:	00093703          	ld	a4,0(s2)
 ae0:	853e                	mv	a0,a5
 ae2:	fef719e3          	bne	a4,a5,ad4 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 ae6:	8552                	mv	a0,s4
 ae8:	9c9ff0ef          	jal	ra,4b0 <sbrk>
  if(p == SBRK_ERROR)
 aec:	fd551ce3          	bne	a0,s5,ac4 <malloc+0xac>
        return 0;
 af0:	4501                	li	a0,0
 af2:	bf65                	j	aaa <malloc+0x92>


kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a7013103          	ld	sp,-1424(sp) # 80008a70 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	a9070713          	addi	a4,a4,-1392 # 80008ae0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	21e78793          	addi	a5,a5,542 # 80006280 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff9c8af>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	f6278793          	addi	a5,a5,-158 # 8000100e <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	74e080e7          	jalr	1870(ra) # 80002878 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	796080e7          	jalr	1942(ra) # 800008d0 <uartputc>
    for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    }

    return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
    for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000186:	00060b1b          	sext.w	s6,a2
    acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	a9650513          	addi	a0,a0,-1386 # 80010c20 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	bda080e7          	jalr	-1062(ra) # 80000d6c <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	a8648493          	addi	s1,s1,-1402 # 80010c20 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	b1690913          	addi	s2,s2,-1258 # 80010cb8 <cons+0x98>
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

        if (c == C('D'))
    800001aa:	4b91                	li	s7,4
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
            break;

        dst++;
        --n;

        if (c == '\n')
    800001ae:	4ca9                	li	s9,10
    while (n > 0)
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
        while (cons.r == cons.w)
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
            if (killed(myproc()))
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	a9a080e7          	jalr	-1382(ra) # 80001c5a <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	4fa080e7          	jalr	1274(ra) # 800026c2 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
            sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	244080e7          	jalr	580(ra) # 8000241a <sleep>
        while (cons.r == cons.w)
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
        if (c == C('D'))
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
        cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	610080e7          	jalr	1552(ra) # 80002822 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
        dst++;
    8000021e:	0a05                	addi	s4,s4,1
        --n;
    80000220:	39fd                	addiw	s3,s3,-1
        if (c == '\n')
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
            // a whole line has arrived, return to
            // the user-level read().
            break;
        }
    }
    release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	9fa50513          	addi	a0,a0,-1542 # 80010c20 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	bf2080e7          	jalr	-1038(ra) # 80000e20 <release>

    return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
                release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	9e450513          	addi	a0,a0,-1564 # 80010c20 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	bdc080e7          	jalr	-1060(ra) # 80000e20 <release>
                return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
            if (n < target)
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
                cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	a4f72323          	sw	a5,-1466(a4) # 80010cb8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
        uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	572080e7          	jalr	1394(ra) # 800007fe <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
        uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	560080e7          	jalr	1376(ra) # 800007fe <uartputc_sync>
        uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	554080e7          	jalr	1364(ra) # 800007fe <uartputc_sync>
        uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	54a080e7          	jalr	1354(ra) # 800007fe <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	95450513          	addi	a0,a0,-1708 # 80010c20 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	a98080e7          	jalr	-1384(ra) # 80000d6c <acquire>

    switch (c)
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
    {
    case C('P'): // Print process list.
        procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	5dc080e7          	jalr	1500(ra) # 800028ce <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	92650513          	addi	a0,a0,-1754 # 80010c20 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	b1e080e7          	jalr	-1250(ra) # 80000e20 <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
    switch (c)
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	90270713          	addi	a4,a4,-1790 # 80010c20 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
            c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
            consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	8d878793          	addi	a5,a5,-1832 # 80010c20 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	9427a783          	lw	a5,-1726(a5) # 80010cb8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
        while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	89670713          	addi	a4,a4,-1898 # 80010c20 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	88648493          	addi	s1,s1,-1914 # 80010c20 <cons>
        while (cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
            cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
        while (cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
        if (cons.e != cons.w)
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	84a70713          	addi	a4,a4,-1974 # 80010c20 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
            cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	8cf72a23          	sw	a5,-1836(a4) # 80010cc0 <cons+0xa0>
            consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
            consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	80e78793          	addi	a5,a5,-2034 # 80010c20 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	88c7a323          	sw	a2,-1914(a5) # 80010cbc <cons+0x9c>
                wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	87a50513          	addi	a0,a0,-1926 # 80010cb8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	038080e7          	jalr	56(ra) # 8000247e <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bc858593          	addi	a1,a1,-1080 # 80008020 <__func__.1+0x18>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	7c050513          	addi	a0,a0,1984 # 80010c20 <cons>
    80000468:	00001097          	auipc	ra,0x1
    8000046c:	874080e7          	jalr	-1932(ra) # 80000cdc <initlock>

    uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	33e080e7          	jalr	830(ra) # 800007ae <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000478:	00061797          	auipc	a5,0x61
    8000047c:	94078793          	addi	a5,a5,-1728 # 80060db8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
    char buf[16];
    int i;
    uint x;

    if (sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
        x = -xx;
    else
        x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

    i = 0;
    800004b6:	4701                	li	a4,0
    do
    {
        buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b9660613          	addi	a2,a2,-1130 # 80008050 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

    if (sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
        buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
        consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
    while (--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
        x = -xx;
    80000538:	40a0053b          	negw	a0,a0
    if (sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
        x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    80000540:	711d                	addi	sp,sp,-96
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
    8000054c:	e40c                	sd	a1,8(s0)
    8000054e:	e810                	sd	a2,16(s0)
    80000550:	ec14                	sd	a3,24(s0)
    80000552:	f018                	sd	a4,32(s0)
    80000554:	f41c                	sd	a5,40(s0)
    80000556:	03043823          	sd	a6,48(s0)
    8000055a:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    8000055e:	00010797          	auipc	a5,0x10
    80000562:	7807a123          	sw	zero,1922(a5) # 80010ce0 <pr+0x18>
    printf("panic: ");
    80000566:	00008517          	auipc	a0,0x8
    8000056a:	ac250513          	addi	a0,a0,-1342 # 80008028 <__func__.1+0x20>
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	02e080e7          	jalr	46(ra) # 8000059c <printf>
    printf(s);
    80000576:	8526                	mv	a0,s1
    80000578:	00000097          	auipc	ra,0x0
    8000057c:	024080e7          	jalr	36(ra) # 8000059c <printf>
    printf("\n");
    80000580:	00008517          	auipc	a0,0x8
    80000584:	f4050513          	addi	a0,a0,-192 # 800084c0 <states.0+0xb0>
    80000588:	00000097          	auipc	ra,0x0
    8000058c:	014080e7          	jalr	20(ra) # 8000059c <printf>
    panicked = 1; // freeze uart output from other CPUs
    80000590:	4785                	li	a5,1
    80000592:	00008717          	auipc	a4,0x8
    80000596:	4ef72f23          	sw	a5,1278(a4) # 80008a90 <panicked>
    for (;;)
    8000059a:	a001                	j	8000059a <panic+0x5a>

000000008000059c <printf>:
{
    8000059c:	7131                	addi	sp,sp,-192
    8000059e:	fc86                	sd	ra,120(sp)
    800005a0:	f8a2                	sd	s0,112(sp)
    800005a2:	f4a6                	sd	s1,104(sp)
    800005a4:	f0ca                	sd	s2,96(sp)
    800005a6:	ecce                	sd	s3,88(sp)
    800005a8:	e8d2                	sd	s4,80(sp)
    800005aa:	e4d6                	sd	s5,72(sp)
    800005ac:	e0da                	sd	s6,64(sp)
    800005ae:	fc5e                	sd	s7,56(sp)
    800005b0:	f862                	sd	s8,48(sp)
    800005b2:	f466                	sd	s9,40(sp)
    800005b4:	f06a                	sd	s10,32(sp)
    800005b6:	ec6e                	sd	s11,24(sp)
    800005b8:	0100                	addi	s0,sp,128
    800005ba:	8a2a                	mv	s4,a0
    800005bc:	e40c                	sd	a1,8(s0)
    800005be:	e810                	sd	a2,16(s0)
    800005c0:	ec14                	sd	a3,24(s0)
    800005c2:	f018                	sd	a4,32(s0)
    800005c4:	f41c                	sd	a5,40(s0)
    800005c6:	03043823          	sd	a6,48(s0)
    800005ca:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005ce:	00010d97          	auipc	s11,0x10
    800005d2:	712dad83          	lw	s11,1810(s11) # 80010ce0 <pr+0x18>
    if (locking)
    800005d6:	020d9b63          	bnez	s11,8000060c <printf+0x70>
    if (fmt == 0)
    800005da:	040a0263          	beqz	s4,8000061e <printf+0x82>
    va_start(ap, fmt);
    800005de:	00840793          	addi	a5,s0,8
    800005e2:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005e6:	000a4503          	lbu	a0,0(s4)
    800005ea:	14050f63          	beqz	a0,80000748 <printf+0x1ac>
    800005ee:	4981                	li	s3,0
        if (c != '%')
    800005f0:	02500a93          	li	s5,37
        switch (c)
    800005f4:	07000b93          	li	s7,112
    consputc('x');
    800005f8:	4d41                	li	s10,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005fa:	00008b17          	auipc	s6,0x8
    800005fe:	a56b0b13          	addi	s6,s6,-1450 # 80008050 <digits>
        switch (c)
    80000602:	07300c93          	li	s9,115
    80000606:	06400c13          	li	s8,100
    8000060a:	a82d                	j	80000644 <printf+0xa8>
        acquire(&pr.lock);
    8000060c:	00010517          	auipc	a0,0x10
    80000610:	6bc50513          	addi	a0,a0,1724 # 80010cc8 <pr>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	758080e7          	jalr	1880(ra) # 80000d6c <acquire>
    8000061c:	bf7d                	j	800005da <printf+0x3e>
        panic("null fmt");
    8000061e:	00008517          	auipc	a0,0x8
    80000622:	a1a50513          	addi	a0,a0,-1510 # 80008038 <__func__.1+0x30>
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	f1a080e7          	jalr	-230(ra) # 80000540 <panic>
            consputc(c);
    8000062e:	00000097          	auipc	ra,0x0
    80000632:	c4e080e7          	jalr	-946(ra) # 8000027c <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c503          	lbu	a0,0(a5)
    80000640:	10050463          	beqz	a0,80000748 <printf+0x1ac>
        if (c != '%')
    80000644:	ff5515e3          	bne	a0,s5,8000062e <printf+0x92>
        c = fmt[++i] & 0xff;
    80000648:	2985                	addiw	s3,s3,1
    8000064a:	013a07b3          	add	a5,s4,s3
    8000064e:	0007c783          	lbu	a5,0(a5)
    80000652:	0007849b          	sext.w	s1,a5
        if (c == 0)
    80000656:	cbed                	beqz	a5,80000748 <printf+0x1ac>
        switch (c)
    80000658:	05778a63          	beq	a5,s7,800006ac <printf+0x110>
    8000065c:	02fbf663          	bgeu	s7,a5,80000688 <printf+0xec>
    80000660:	09978863          	beq	a5,s9,800006f0 <printf+0x154>
    80000664:	07800713          	li	a4,120
    80000668:	0ce79563          	bne	a5,a4,80000732 <printf+0x196>
            printint(va_arg(ap, int), 16, 1);
    8000066c:	f8843783          	ld	a5,-120(s0)
    80000670:	00878713          	addi	a4,a5,8
    80000674:	f8e43423          	sd	a4,-120(s0)
    80000678:	4605                	li	a2,1
    8000067a:	85ea                	mv	a1,s10
    8000067c:	4388                	lw	a0,0(a5)
    8000067e:	00000097          	auipc	ra,0x0
    80000682:	e1e080e7          	jalr	-482(ra) # 8000049c <printint>
            break;
    80000686:	bf45                	j	80000636 <printf+0x9a>
        switch (c)
    80000688:	09578f63          	beq	a5,s5,80000726 <printf+0x18a>
    8000068c:	0b879363          	bne	a5,s8,80000732 <printf+0x196>
            printint(va_arg(ap, int), 10, 1);
    80000690:	f8843783          	ld	a5,-120(s0)
    80000694:	00878713          	addi	a4,a5,8
    80000698:	f8e43423          	sd	a4,-120(s0)
    8000069c:	4605                	li	a2,1
    8000069e:	45a9                	li	a1,10
    800006a0:	4388                	lw	a0,0(a5)
    800006a2:	00000097          	auipc	ra,0x0
    800006a6:	dfa080e7          	jalr	-518(ra) # 8000049c <printint>
            break;
    800006aa:	b771                	j	80000636 <printf+0x9a>
            printptr(va_arg(ap, uint64));
    800006ac:	f8843783          	ld	a5,-120(s0)
    800006b0:	00878713          	addi	a4,a5,8
    800006b4:	f8e43423          	sd	a4,-120(s0)
    800006b8:	0007b903          	ld	s2,0(a5)
    consputc('0');
    800006bc:	03000513          	li	a0,48
    800006c0:	00000097          	auipc	ra,0x0
    800006c4:	bbc080e7          	jalr	-1092(ra) # 8000027c <consputc>
    consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
    800006d4:	84ea                	mv	s1,s10
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d6:	03c95793          	srli	a5,s2,0x3c
    800006da:	97da                	add	a5,a5,s6
    800006dc:	0007c503          	lbu	a0,0(a5)
    800006e0:	00000097          	auipc	ra,0x0
    800006e4:	b9c080e7          	jalr	-1124(ra) # 8000027c <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0912                	slli	s2,s2,0x4
    800006ea:	34fd                	addiw	s1,s1,-1
    800006ec:	f4ed                	bnez	s1,800006d6 <printf+0x13a>
    800006ee:	b7a1                	j	80000636 <printf+0x9a>
            if ((s = va_arg(ap, char *)) == 0)
    800006f0:	f8843783          	ld	a5,-120(s0)
    800006f4:	00878713          	addi	a4,a5,8
    800006f8:	f8e43423          	sd	a4,-120(s0)
    800006fc:	6384                	ld	s1,0(a5)
    800006fe:	cc89                	beqz	s1,80000718 <printf+0x17c>
            for (; *s; s++)
    80000700:	0004c503          	lbu	a0,0(s1)
    80000704:	d90d                	beqz	a0,80000636 <printf+0x9a>
                consputc(*s);
    80000706:	00000097          	auipc	ra,0x0
    8000070a:	b76080e7          	jalr	-1162(ra) # 8000027c <consputc>
            for (; *s; s++)
    8000070e:	0485                	addi	s1,s1,1
    80000710:	0004c503          	lbu	a0,0(s1)
    80000714:	f96d                	bnez	a0,80000706 <printf+0x16a>
    80000716:	b705                	j	80000636 <printf+0x9a>
                s = "(null)";
    80000718:	00008497          	auipc	s1,0x8
    8000071c:	91848493          	addi	s1,s1,-1768 # 80008030 <__func__.1+0x28>
            for (; *s; s++)
    80000720:	02800513          	li	a0,40
    80000724:	b7cd                	j	80000706 <printf+0x16a>
            consputc('%');
    80000726:	8556                	mv	a0,s5
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b54080e7          	jalr	-1196(ra) # 8000027c <consputc>
            break;
    80000730:	b719                	j	80000636 <printf+0x9a>
            consputc('%');
    80000732:	8556                	mv	a0,s5
    80000734:	00000097          	auipc	ra,0x0
    80000738:	b48080e7          	jalr	-1208(ra) # 8000027c <consputc>
            consputc(c);
    8000073c:	8526                	mv	a0,s1
    8000073e:	00000097          	auipc	ra,0x0
    80000742:	b3e080e7          	jalr	-1218(ra) # 8000027c <consputc>
            break;
    80000746:	bdc5                	j	80000636 <printf+0x9a>
    if (locking)
    80000748:	020d9163          	bnez	s11,8000076a <printf+0x1ce>
}
    8000074c:	70e6                	ld	ra,120(sp)
    8000074e:	7446                	ld	s0,112(sp)
    80000750:	74a6                	ld	s1,104(sp)
    80000752:	7906                	ld	s2,96(sp)
    80000754:	69e6                	ld	s3,88(sp)
    80000756:	6a46                	ld	s4,80(sp)
    80000758:	6aa6                	ld	s5,72(sp)
    8000075a:	6b06                	ld	s6,64(sp)
    8000075c:	7be2                	ld	s7,56(sp)
    8000075e:	7c42                	ld	s8,48(sp)
    80000760:	7ca2                	ld	s9,40(sp)
    80000762:	7d02                	ld	s10,32(sp)
    80000764:	6de2                	ld	s11,24(sp)
    80000766:	6129                	addi	sp,sp,192
    80000768:	8082                	ret
        release(&pr.lock);
    8000076a:	00010517          	auipc	a0,0x10
    8000076e:	55e50513          	addi	a0,a0,1374 # 80010cc8 <pr>
    80000772:	00000097          	auipc	ra,0x0
    80000776:	6ae080e7          	jalr	1710(ra) # 80000e20 <release>
}
    8000077a:	bfc9                	j	8000074c <printf+0x1b0>

000000008000077c <printfinit>:
        ;
}

void printfinit(void)
{
    8000077c:	1101                	addi	sp,sp,-32
    8000077e:	ec06                	sd	ra,24(sp)
    80000780:	e822                	sd	s0,16(sp)
    80000782:	e426                	sd	s1,8(sp)
    80000784:	1000                	addi	s0,sp,32
    initlock(&pr.lock, "pr");
    80000786:	00010497          	auipc	s1,0x10
    8000078a:	54248493          	addi	s1,s1,1346 # 80010cc8 <pr>
    8000078e:	00008597          	auipc	a1,0x8
    80000792:	8ba58593          	addi	a1,a1,-1862 # 80008048 <__func__.1+0x40>
    80000796:	8526                	mv	a0,s1
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	544080e7          	jalr	1348(ra) # 80000cdc <initlock>
    pr.locking = 1;
    800007a0:	4785                	li	a5,1
    800007a2:	cc9c                	sw	a5,24(s1)
}
    800007a4:	60e2                	ld	ra,24(sp)
    800007a6:	6442                	ld	s0,16(sp)
    800007a8:	64a2                	ld	s1,8(sp)
    800007aa:	6105                	addi	sp,sp,32
    800007ac:	8082                	ret

00000000800007ae <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007ae:	1141                	addi	sp,sp,-16
    800007b0:	e406                	sd	ra,8(sp)
    800007b2:	e022                	sd	s0,0(sp)
    800007b4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b6:	100007b7          	lui	a5,0x10000
    800007ba:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007be:	f8000713          	li	a4,-128
    800007c2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c6:	470d                	li	a4,3
    800007c8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007cc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007d0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d4:	469d                	li	a3,7
    800007d6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007da:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007de:	00008597          	auipc	a1,0x8
    800007e2:	88a58593          	addi	a1,a1,-1910 # 80008068 <digits+0x18>
    800007e6:	00010517          	auipc	a0,0x10
    800007ea:	50250513          	addi	a0,a0,1282 # 80010ce8 <uart_tx_lock>
    800007ee:	00000097          	auipc	ra,0x0
    800007f2:	4ee080e7          	jalr	1262(ra) # 80000cdc <initlock>
}
    800007f6:	60a2                	ld	ra,8(sp)
    800007f8:	6402                	ld	s0,0(sp)
    800007fa:	0141                	addi	sp,sp,16
    800007fc:	8082                	ret

00000000800007fe <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fe:	1101                	addi	sp,sp,-32
    80000800:	ec06                	sd	ra,24(sp)
    80000802:	e822                	sd	s0,16(sp)
    80000804:	e426                	sd	s1,8(sp)
    80000806:	1000                	addi	s0,sp,32
    80000808:	84aa                	mv	s1,a0
  push_off();
    8000080a:	00000097          	auipc	ra,0x0
    8000080e:	516080e7          	jalr	1302(ra) # 80000d20 <push_off>

  if(panicked){
    80000812:	00008797          	auipc	a5,0x8
    80000816:	27e7a783          	lw	a5,638(a5) # 80008a90 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081e:	c391                	beqz	a5,80000822 <uartputc_sync+0x24>
    for(;;)
    80000820:	a001                	j	80000820 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000822:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dfe5                	beqz	a5,80000822 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f513          	zext.b	a0,s1
    80000830:	100007b7          	lui	a5,0x10000
    80000834:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	588080e7          	jalr	1416(ra) # 80000dc0 <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	24e7b783          	ld	a5,590(a5) # 80008a98 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	24e73703          	ld	a4,590(a4) # 80008aa0 <uart_tx_w>
    8000085a:	06f70a63          	beq	a4,a5,800008ce <uartstart+0x84>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000874:	00010a17          	auipc	s4,0x10
    80000878:	474a0a13          	addi	s4,s4,1140 # 80010ce8 <uart_tx_lock>
    uart_tx_r += 1;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	21c48493          	addi	s1,s1,540 # 80008a98 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	21c98993          	addi	s3,s3,540 # 80008aa0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	02077713          	andi	a4,a4,32
    80000894:	c705                	beqz	a4,800008bc <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f7f713          	andi	a4,a5,31
    8000089a:	9752                	add	a4,a4,s4
    8000089c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800008a0:	0785                	addi	a5,a5,1
    800008a2:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	bd8080e7          	jalr	-1064(ra) # 8000247e <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	609c                	ld	a5,0(s1)
    800008b4:	0009b703          	ld	a4,0(s3)
    800008b8:	fcf71ae3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	40650513          	addi	a0,a0,1030 # 80010ce8 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	482080e7          	jalr	1154(ra) # 80000d6c <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	19e7a783          	lw	a5,414(a5) # 80008a90 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008717          	auipc	a4,0x8
    80000900:	1a473703          	ld	a4,420(a4) # 80008aa0 <uart_tx_w>
    80000904:	00008797          	auipc	a5,0x8
    80000908:	1947b783          	ld	a5,404(a5) # 80008a98 <uart_tx_r>
    8000090c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010997          	auipc	s3,0x10
    80000914:	3d898993          	addi	s3,s3,984 # 80010ce8 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	18048493          	addi	s1,s1,384 # 80008a98 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	18090913          	addi	s2,s2,384 # 80008aa0 <uart_tx_w>
    80000928:	00e79f63          	bne	a5,a4,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85ce                	mv	a1,s3
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	aea080e7          	jalr	-1302(ra) # 8000241a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093703          	ld	a4,0(s2)
    8000093c:	609c                	ld	a5,0(s1)
    8000093e:	02078793          	addi	a5,a5,32
    80000942:	fee785e3          	beq	a5,a4,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	3a248493          	addi	s1,s1,930 # 80010ce8 <uart_tx_lock>
    8000094e:	01f77793          	andi	a5,a4,31
    80000952:	97a6                	add	a5,a5,s1
    80000954:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000958:	0705                	addi	a4,a4,1
    8000095a:	00008797          	auipc	a5,0x8
    8000095e:	14e7b323          	sd	a4,326(a5) # 80008aa0 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee8080e7          	jalr	-280(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	4b4080e7          	jalr	1204(ra) # 80000e20 <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb81                	beqz	a5,800009a6 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a0:	6422                	ld	s0,8(sp)
    800009a2:	0141                	addi	sp,sp,16
    800009a4:	8082                	ret
    return -1;
    800009a6:	557d                	li	a0,-1
    800009a8:	bfe5                	j	800009a0 <uartgetc+0x1a>

00000000800009aa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009aa:	1101                	addi	sp,sp,-32
    800009ac:	ec06                	sd	ra,24(sp)
    800009ae:	e822                	sd	s0,16(sp)
    800009b0:	e426                	sd	s1,8(sp)
    800009b2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b4:	54fd                	li	s1,-1
    800009b6:	a029                	j	800009c0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009b8:	00000097          	auipc	ra,0x0
    800009bc:	906080e7          	jalr	-1786(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	fc6080e7          	jalr	-58(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c8:	fe9518e3          	bne	a0,s1,800009b8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009cc:	00010497          	auipc	s1,0x10
    800009d0:	31c48493          	addi	s1,s1,796 # 80010ce8 <uart_tx_lock>
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	396080e7          	jalr	918(ra) # 80000d6c <acquire>
  uartstart();
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	e6c080e7          	jalr	-404(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    800009e6:	8526                	mv	a0,s1
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	438080e7          	jalr	1080(ra) # 80000e20 <release>
}
    800009f0:	60e2                	ld	ra,24(sp)
    800009f2:	6442                	ld	s0,16(sp)
    800009f4:	64a2                	ld	s1,8(sp)
    800009f6:	6105                	addi	sp,sp,32
    800009f8:	8082                	ret

00000000800009fa <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    800009fa:	1101                	addi	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	e04a                	sd	s2,0(sp)
    80000a04:	1000                	addi	s0,sp,32
    80000a06:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000a08:	00008797          	auipc	a5,0x8
    80000a0c:	0a87b783          	ld	a5,168(a5) # 80008ab0 <MAX_PAGES>
    80000a10:	c799                	beqz	a5,80000a1e <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a12:	00008717          	auipc	a4,0x8
    80000a16:	09673703          	ld	a4,150(a4) # 80008aa8 <FREE_PAGES>
    80000a1a:	06f77663          	bgeu	a4,a5,80000a86 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a1e:	03449793          	slli	a5,s1,0x34
    80000a22:	efc1                	bnez	a5,80000aba <kfree+0xc0>
    80000a24:	00061797          	auipc	a5,0x61
    80000a28:	52c78793          	addi	a5,a5,1324 # 80061f50 <end>
    80000a2c:	08f4e763          	bltu	s1,a5,80000aba <kfree+0xc0>
    80000a30:	47c5                	li	a5,17
    80000a32:	07ee                	slli	a5,a5,0x1b
    80000a34:	08f4f363          	bgeu	s1,a5,80000aba <kfree+0xc0>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000a38:	6605                	lui	a2,0x1
    80000a3a:	4585                	li	a1,1
    80000a3c:	8526                	mv	a0,s1
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	42a080e7          	jalr	1066(ra) # 80000e68 <memset>

    r = (struct run *)pa;

    acquire(&kmem.lock);
    80000a46:	00010917          	auipc	s2,0x10
    80000a4a:	2da90913          	addi	s2,s2,730 # 80010d20 <kmem>
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	31c080e7          	jalr	796(ra) # 80000d6c <acquire>
    r->next = kmem.freelist;
    80000a58:	01893783          	ld	a5,24(s2)
    80000a5c:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000a5e:	00993c23          	sd	s1,24(s2)
    FREE_PAGES++;
    80000a62:	00008717          	auipc	a4,0x8
    80000a66:	04670713          	addi	a4,a4,70 # 80008aa8 <FREE_PAGES>
    80000a6a:	631c                	ld	a5,0(a4)
    80000a6c:	0785                	addi	a5,a5,1
    80000a6e:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000a70:	854a                	mv	a0,s2
    80000a72:	00000097          	auipc	ra,0x0
    80000a76:	3ae080e7          	jalr	942(ra) # 80000e20 <release>
}
    80000a7a:	60e2                	ld	ra,24(sp)
    80000a7c:	6442                	ld	s0,16(sp)
    80000a7e:	64a2                	ld	s1,8(sp)
    80000a80:	6902                	ld	s2,0(sp)
    80000a82:	6105                	addi	sp,sp,32
    80000a84:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000a86:	03800693          	li	a3,56
    80000a8a:	00007617          	auipc	a2,0x7
    80000a8e:	57e60613          	addi	a2,a2,1406 # 80008008 <__func__.1>
    80000a92:	00007597          	auipc	a1,0x7
    80000a96:	5de58593          	addi	a1,a1,1502 # 80008070 <digits+0x20>
    80000a9a:	00007517          	auipc	a0,0x7
    80000a9e:	5e650513          	addi	a0,a0,1510 # 80008080 <digits+0x30>
    80000aa2:	00000097          	auipc	ra,0x0
    80000aa6:	afa080e7          	jalr	-1286(ra) # 8000059c <printf>
    80000aaa:	00007517          	auipc	a0,0x7
    80000aae:	5e650513          	addi	a0,a0,1510 # 80008090 <digits+0x40>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	a8e080e7          	jalr	-1394(ra) # 80000540 <panic>
        panic("kfree");
    80000aba:	00007517          	auipc	a0,0x7
    80000abe:	5e650513          	addi	a0,a0,1510 # 800080a0 <digits+0x50>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	a7e080e7          	jalr	-1410(ra) # 80000540 <panic>

0000000080000aca <freerange>:
{
    80000aca:	7179                	addi	sp,sp,-48
    80000acc:	f406                	sd	ra,40(sp)
    80000ace:	f022                	sd	s0,32(sp)
    80000ad0:	ec26                	sd	s1,24(sp)
    80000ad2:	e84a                	sd	s2,16(sp)
    80000ad4:	e44e                	sd	s3,8(sp)
    80000ad6:	e052                	sd	s4,0(sp)
    80000ad8:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000ada:	6785                	lui	a5,0x1
    80000adc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae0:	00e504b3          	add	s1,a0,a4
    80000ae4:	777d                	lui	a4,0xfffff
    80000ae6:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ae8:	94be                	add	s1,s1,a5
    80000aea:	0095ee63          	bltu	a1,s1,80000b06 <freerange+0x3c>
    80000aee:	892e                	mv	s2,a1
        kfree(p);
    80000af0:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000af2:	6985                	lui	s3,0x1
        kfree(p);
    80000af4:	01448533          	add	a0,s1,s4
    80000af8:	00000097          	auipc	ra,0x0
    80000afc:	f02080e7          	jalr	-254(ra) # 800009fa <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b00:	94ce                	add	s1,s1,s3
    80000b02:	fe9979e3          	bgeu	s2,s1,80000af4 <freerange+0x2a>
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6942                	ld	s2,16(sp)
    80000b0e:	69a2                	ld	s3,8(sp)
    80000b10:	6a02                	ld	s4,0(sp)
    80000b12:	6145                	addi	sp,sp,48
    80000b14:	8082                	ret

0000000080000b16 <kinit>:
{
    80000b16:	1141                	addi	sp,sp,-16
    80000b18:	e406                	sd	ra,8(sp)
    80000b1a:	e022                	sd	s0,0(sp)
    80000b1c:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000b1e:	00007597          	auipc	a1,0x7
    80000b22:	58a58593          	addi	a1,a1,1418 # 800080a8 <digits+0x58>
    80000b26:	00010517          	auipc	a0,0x10
    80000b2a:	1fa50513          	addi	a0,a0,506 # 80010d20 <kmem>
    80000b2e:	00000097          	auipc	ra,0x0
    80000b32:	1ae080e7          	jalr	430(ra) # 80000cdc <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00061517          	auipc	a0,0x61
    80000b3e:	41650513          	addi	a0,a0,1046 # 80061f50 <end>
    80000b42:	00000097          	auipc	ra,0x0
    80000b46:	f88080e7          	jalr	-120(ra) # 80000aca <freerange>
    MAX_PAGES = FREE_PAGES;
    80000b4a:	00008797          	auipc	a5,0x8
    80000b4e:	f5e7b783          	ld	a5,-162(a5) # 80008aa8 <FREE_PAGES>
    80000b52:	00008717          	auipc	a4,0x8
    80000b56:	f4f73f23          	sd	a5,-162(a4) # 80008ab0 <MAX_PAGES>
}
    80000b5a:	60a2                	ld	ra,8(sp)
    80000b5c:	6402                	ld	s0,0(sp)
    80000b5e:	0141                	addi	sp,sp,16
    80000b60:	8082                	ret

0000000080000b62 <get_ref_index>:
    // we need to free page
    kfree(pa);
  }
}

int get_ref_index(void *pa) {
    80000b62:	1141                	addi	sp,sp,-16
    80000b64:	e422                	sd	s0,8(sp)
    80000b66:	0800                	addi	s0,sp,16
  if ((uint64)pa % PGSIZE != 0) {
    80000b68:	03451793          	slli	a5,a0,0x34
    80000b6c:	ef89                	bnez	a5,80000b86 <get_ref_index+0x24>
    return -1;
  }
  if ((uint64)pa < KERNBASE) {
    80000b6e:	800007b7          	lui	a5,0x80000
    80000b72:	953e                	add	a0,a0,a5
    80000b74:	080007b7          	lui	a5,0x8000
    80000b78:	00f57963          	bgeu	a0,a5,80000b8a <get_ref_index+0x28>
    return -1;
  }
  if ((uint64)pa >= PHYSTOP) {
    return -1;
  }
  return (((uint64)pa - KERNBASE) / PGSIZE);
    80000b7c:	8131                	srli	a0,a0,0xc
    80000b7e:	2501                	sext.w	a0,a0
    80000b80:	6422                	ld	s0,8(sp)
    80000b82:	0141                	addi	sp,sp,16
    80000b84:	8082                	ret
    return -1;
    80000b86:	557d                	li	a0,-1
    80000b88:	bfe5                	j	80000b80 <get_ref_index+0x1e>
    return -1;
    80000b8a:	557d                	li	a0,-1
    80000b8c:	bfd5                	j	80000b80 <get_ref_index+0x1e>

0000000080000b8e <add_ref>:
void add_ref(void *pa) {
    80000b8e:	1141                	addi	sp,sp,-16
    80000b90:	e406                	sd	ra,8(sp)
    80000b92:	e022                	sd	s0,0(sp)
    80000b94:	0800                	addi	s0,sp,16
  int index = get_ref_index(pa);
    80000b96:	00000097          	auipc	ra,0x0
    80000b9a:	fcc080e7          	jalr	-52(ra) # 80000b62 <get_ref_index>
  if (index == -1) {
    80000b9e:	57fd                	li	a5,-1
    80000ba0:	00f50b63          	beq	a0,a5,80000bb6 <add_ref+0x28>
  refc[index] = refc[index] + 1;
    80000ba4:	050e                	slli	a0,a0,0x3
    80000ba6:	00010797          	auipc	a5,0x10
    80000baa:	19a78793          	addi	a5,a5,410 # 80010d40 <refc>
    80000bae:	97aa                	add	a5,a5,a0
    80000bb0:	6398                	ld	a4,0(a5)
    80000bb2:	0705                	addi	a4,a4,1
    80000bb4:	e398                	sd	a4,0(a5)
}
    80000bb6:	60a2                	ld	ra,8(sp)
    80000bb8:	6402                	ld	s0,0(sp)
    80000bba:	0141                	addi	sp,sp,16
    80000bbc:	8082                	ret

0000000080000bbe <kalloc>:
{
    80000bbe:	1101                	addi	sp,sp,-32
    80000bc0:	ec06                	sd	ra,24(sp)
    80000bc2:	e822                	sd	s0,16(sp)
    80000bc4:	e426                	sd	s1,8(sp)
    80000bc6:	1000                	addi	s0,sp,32
    assert(FREE_PAGES > 0);
    80000bc8:	00008797          	auipc	a5,0x8
    80000bcc:	ee07b783          	ld	a5,-288(a5) # 80008aa8 <FREE_PAGES>
    80000bd0:	cfb9                	beqz	a5,80000c2e <kalloc+0x70>
    acquire(&kmem.lock);
    80000bd2:	00010497          	auipc	s1,0x10
    80000bd6:	14e48493          	addi	s1,s1,334 # 80010d20 <kmem>
    80000bda:	8526                	mv	a0,s1
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	190080e7          	jalr	400(ra) # 80000d6c <acquire>
    r = kmem.freelist;
    80000be4:	6c84                	ld	s1,24(s1)
    if (r)
    80000be6:	ccb5                	beqz	s1,80000c62 <kalloc+0xa4>
        kmem.freelist = r->next;
    80000be8:	609c                	ld	a5,0(s1)
    80000bea:	00010517          	auipc	a0,0x10
    80000bee:	13650513          	addi	a0,a0,310 # 80010d20 <kmem>
    80000bf2:	ed1c                	sd	a5,24(a0)
    release(&kmem.lock);
    80000bf4:	00000097          	auipc	ra,0x0
    80000bf8:	22c080e7          	jalr	556(ra) # 80000e20 <release>
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000bfc:	6605                	lui	a2,0x1
    80000bfe:	4595                	li	a1,5
    80000c00:	8526                	mv	a0,s1
    80000c02:	00000097          	auipc	ra,0x0
    80000c06:	266080e7          	jalr	614(ra) # 80000e68 <memset>
    FREE_PAGES--;
    80000c0a:	00008717          	auipc	a4,0x8
    80000c0e:	e9e70713          	addi	a4,a4,-354 # 80008aa8 <FREE_PAGES>
    80000c12:	631c                	ld	a5,0(a4)
    80000c14:	17fd                	addi	a5,a5,-1
    80000c16:	e31c                	sd	a5,0(a4)
    add_ref((void *)r);
    80000c18:	8526                	mv	a0,s1
    80000c1a:	00000097          	auipc	ra,0x0
    80000c1e:	f74080e7          	jalr	-140(ra) # 80000b8e <add_ref>
}
    80000c22:	8526                	mv	a0,s1
    80000c24:	60e2                	ld	ra,24(sp)
    80000c26:	6442                	ld	s0,16(sp)
    80000c28:	64a2                	ld	s1,8(sp)
    80000c2a:	6105                	addi	sp,sp,32
    80000c2c:	8082                	ret
    assert(FREE_PAGES > 0);
    80000c2e:	05000693          	li	a3,80
    80000c32:	00007617          	auipc	a2,0x7
    80000c36:	3ce60613          	addi	a2,a2,974 # 80008000 <etext>
    80000c3a:	00007597          	auipc	a1,0x7
    80000c3e:	43658593          	addi	a1,a1,1078 # 80008070 <digits+0x20>
    80000c42:	00007517          	auipc	a0,0x7
    80000c46:	43e50513          	addi	a0,a0,1086 # 80008080 <digits+0x30>
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	952080e7          	jalr	-1710(ra) # 8000059c <printf>
    80000c52:	00007517          	auipc	a0,0x7
    80000c56:	43e50513          	addi	a0,a0,1086 # 80008090 <digits+0x40>
    80000c5a:	00000097          	auipc	ra,0x0
    80000c5e:	8e6080e7          	jalr	-1818(ra) # 80000540 <panic>
    release(&kmem.lock);
    80000c62:	00010517          	auipc	a0,0x10
    80000c66:	0be50513          	addi	a0,a0,190 # 80010d20 <kmem>
    80000c6a:	00000097          	auipc	ra,0x0
    80000c6e:	1b6080e7          	jalr	438(ra) # 80000e20 <release>
    if (r)
    80000c72:	bf61                	j	80000c0a <kalloc+0x4c>

0000000080000c74 <dec_ref>:
void dec_ref(void *pa) {
    80000c74:	1101                	addi	sp,sp,-32
    80000c76:	ec06                	sd	ra,24(sp)
    80000c78:	e822                	sd	s0,16(sp)
    80000c7a:	e426                	sd	s1,8(sp)
    80000c7c:	1000                	addi	s0,sp,32
    80000c7e:	84aa                	mv	s1,a0
  int index = get_ref_index(pa);
    80000c80:	00000097          	auipc	ra,0x0
    80000c84:	ee2080e7          	jalr	-286(ra) # 80000b62 <get_ref_index>
  if (index == -1) {
    80000c88:	57fd                	li	a5,-1
    80000c8a:	02f50663          	beq	a0,a5,80000cb6 <dec_ref+0x42>
  int cur_count = refc[index];
    80000c8e:	00351713          	slli	a4,a0,0x3
    80000c92:	00010797          	auipc	a5,0x10
    80000c96:	0ae78793          	addi	a5,a5,174 # 80010d40 <refc>
    80000c9a:	97ba                	add	a5,a5,a4
    80000c9c:	4398                	lw	a4,0(a5)
  if (cur_count <= 0) {
    80000c9e:	02e05163          	blez	a4,80000cc0 <dec_ref+0x4c>
  refc[index] = cur_count - 1;
    80000ca2:	377d                	addiw	a4,a4,-1
    80000ca4:	00351793          	slli	a5,a0,0x3
    80000ca8:	00010697          	auipc	a3,0x10
    80000cac:	09868693          	addi	a3,a3,152 # 80010d40 <refc>
    80000cb0:	97b6                	add	a5,a5,a3
    80000cb2:	e398                	sd	a4,0(a5)
  if (refc[index] == 0) {
    80000cb4:	cf11                	beqz	a4,80000cd0 <dec_ref+0x5c>
}
    80000cb6:	60e2                	ld	ra,24(sp)
    80000cb8:	6442                	ld	s0,16(sp)
    80000cba:	64a2                	ld	s1,8(sp)
    80000cbc:	6105                	addi	sp,sp,32
    80000cbe:	8082                	ret
    panic("def a freed page!");
    80000cc0:	00007517          	auipc	a0,0x7
    80000cc4:	3f050513          	addi	a0,a0,1008 # 800080b0 <digits+0x60>
    80000cc8:	00000097          	auipc	ra,0x0
    80000ccc:	878080e7          	jalr	-1928(ra) # 80000540 <panic>
    kfree(pa);
    80000cd0:	8526                	mv	a0,s1
    80000cd2:	00000097          	auipc	ra,0x0
    80000cd6:	d28080e7          	jalr	-728(ra) # 800009fa <kfree>
    80000cda:	bff1                	j	80000cb6 <dec_ref+0x42>

0000000080000cdc <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000cdc:	1141                	addi	sp,sp,-16
    80000cde:	e422                	sd	s0,8(sp)
    80000ce0:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ce2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ce4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000ce8:	00053823          	sd	zero,16(a0)
}
    80000cec:	6422                	ld	s0,8(sp)
    80000cee:	0141                	addi	sp,sp,16
    80000cf0:	8082                	ret

0000000080000cf2 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000cf2:	411c                	lw	a5,0(a0)
    80000cf4:	e399                	bnez	a5,80000cfa <holding+0x8>
    80000cf6:	4501                	li	a0,0
  return r;
}
    80000cf8:	8082                	ret
{
    80000cfa:	1101                	addi	sp,sp,-32
    80000cfc:	ec06                	sd	ra,24(sp)
    80000cfe:	e822                	sd	s0,16(sp)
    80000d00:	e426                	sd	s1,8(sp)
    80000d02:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d04:	6904                	ld	s1,16(a0)
    80000d06:	00001097          	auipc	ra,0x1
    80000d0a:	f38080e7          	jalr	-200(ra) # 80001c3e <mycpu>
    80000d0e:	40a48533          	sub	a0,s1,a0
    80000d12:	00153513          	seqz	a0,a0
}
    80000d16:	60e2                	ld	ra,24(sp)
    80000d18:	6442                	ld	s0,16(sp)
    80000d1a:	64a2                	ld	s1,8(sp)
    80000d1c:	6105                	addi	sp,sp,32
    80000d1e:	8082                	ret

0000000080000d20 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d20:	1101                	addi	sp,sp,-32
    80000d22:	ec06                	sd	ra,24(sp)
    80000d24:	e822                	sd	s0,16(sp)
    80000d26:	e426                	sd	s1,8(sp)
    80000d28:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d2a:	100024f3          	csrr	s1,sstatus
    80000d2e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d32:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d34:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000d38:	00001097          	auipc	ra,0x1
    80000d3c:	f06080e7          	jalr	-250(ra) # 80001c3e <mycpu>
    80000d40:	5d3c                	lw	a5,120(a0)
    80000d42:	cf89                	beqz	a5,80000d5c <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d44:	00001097          	auipc	ra,0x1
    80000d48:	efa080e7          	jalr	-262(ra) # 80001c3e <mycpu>
    80000d4c:	5d3c                	lw	a5,120(a0)
    80000d4e:	2785                	addiw	a5,a5,1
    80000d50:	dd3c                	sw	a5,120(a0)
}
    80000d52:	60e2                	ld	ra,24(sp)
    80000d54:	6442                	ld	s0,16(sp)
    80000d56:	64a2                	ld	s1,8(sp)
    80000d58:	6105                	addi	sp,sp,32
    80000d5a:	8082                	ret
    mycpu()->intena = old;
    80000d5c:	00001097          	auipc	ra,0x1
    80000d60:	ee2080e7          	jalr	-286(ra) # 80001c3e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d64:	8085                	srli	s1,s1,0x1
    80000d66:	8885                	andi	s1,s1,1
    80000d68:	dd64                	sw	s1,124(a0)
    80000d6a:	bfe9                	j	80000d44 <push_off+0x24>

0000000080000d6c <acquire>:
{
    80000d6c:	1101                	addi	sp,sp,-32
    80000d6e:	ec06                	sd	ra,24(sp)
    80000d70:	e822                	sd	s0,16(sp)
    80000d72:	e426                	sd	s1,8(sp)
    80000d74:	1000                	addi	s0,sp,32
    80000d76:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d78:	00000097          	auipc	ra,0x0
    80000d7c:	fa8080e7          	jalr	-88(ra) # 80000d20 <push_off>
  if(holding(lk))
    80000d80:	8526                	mv	a0,s1
    80000d82:	00000097          	auipc	ra,0x0
    80000d86:	f70080e7          	jalr	-144(ra) # 80000cf2 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d8a:	4705                	li	a4,1
  if(holding(lk))
    80000d8c:	e115                	bnez	a0,80000db0 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d8e:	87ba                	mv	a5,a4
    80000d90:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d94:	2781                	sext.w	a5,a5
    80000d96:	ffe5                	bnez	a5,80000d8e <acquire+0x22>
  __sync_synchronize();
    80000d98:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d9c:	00001097          	auipc	ra,0x1
    80000da0:	ea2080e7          	jalr	-350(ra) # 80001c3e <mycpu>
    80000da4:	e888                	sd	a0,16(s1)
}
    80000da6:	60e2                	ld	ra,24(sp)
    80000da8:	6442                	ld	s0,16(sp)
    80000daa:	64a2                	ld	s1,8(sp)
    80000dac:	6105                	addi	sp,sp,32
    80000dae:	8082                	ret
    panic("acquire");
    80000db0:	00007517          	auipc	a0,0x7
    80000db4:	31850513          	addi	a0,a0,792 # 800080c8 <digits+0x78>
    80000db8:	fffff097          	auipc	ra,0xfffff
    80000dbc:	788080e7          	jalr	1928(ra) # 80000540 <panic>

0000000080000dc0 <pop_off>:

void
pop_off(void)
{
    80000dc0:	1141                	addi	sp,sp,-16
    80000dc2:	e406                	sd	ra,8(sp)
    80000dc4:	e022                	sd	s0,0(sp)
    80000dc6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000dc8:	00001097          	auipc	ra,0x1
    80000dcc:	e76080e7          	jalr	-394(ra) # 80001c3e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dd0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000dd4:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000dd6:	e78d                	bnez	a5,80000e00 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000dd8:	5d3c                	lw	a5,120(a0)
    80000dda:	02f05b63          	blez	a5,80000e10 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000dde:	37fd                	addiw	a5,a5,-1
    80000de0:	0007871b          	sext.w	a4,a5
    80000de4:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000de6:	eb09                	bnez	a4,80000df8 <pop_off+0x38>
    80000de8:	5d7c                	lw	a5,124(a0)
    80000dea:	c799                	beqz	a5,80000df8 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000df0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000df4:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000df8:	60a2                	ld	ra,8(sp)
    80000dfa:	6402                	ld	s0,0(sp)
    80000dfc:	0141                	addi	sp,sp,16
    80000dfe:	8082                	ret
    panic("pop_off - interruptible");
    80000e00:	00007517          	auipc	a0,0x7
    80000e04:	2d050513          	addi	a0,a0,720 # 800080d0 <digits+0x80>
    80000e08:	fffff097          	auipc	ra,0xfffff
    80000e0c:	738080e7          	jalr	1848(ra) # 80000540 <panic>
    panic("pop_off");
    80000e10:	00007517          	auipc	a0,0x7
    80000e14:	2d850513          	addi	a0,a0,728 # 800080e8 <digits+0x98>
    80000e18:	fffff097          	auipc	ra,0xfffff
    80000e1c:	728080e7          	jalr	1832(ra) # 80000540 <panic>

0000000080000e20 <release>:
{
    80000e20:	1101                	addi	sp,sp,-32
    80000e22:	ec06                	sd	ra,24(sp)
    80000e24:	e822                	sd	s0,16(sp)
    80000e26:	e426                	sd	s1,8(sp)
    80000e28:	1000                	addi	s0,sp,32
    80000e2a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e2c:	00000097          	auipc	ra,0x0
    80000e30:	ec6080e7          	jalr	-314(ra) # 80000cf2 <holding>
    80000e34:	c115                	beqz	a0,80000e58 <release+0x38>
  lk->cpu = 0;
    80000e36:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e3a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e3e:	0f50000f          	fence	iorw,ow
    80000e42:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e46:	00000097          	auipc	ra,0x0
    80000e4a:	f7a080e7          	jalr	-134(ra) # 80000dc0 <pop_off>
}
    80000e4e:	60e2                	ld	ra,24(sp)
    80000e50:	6442                	ld	s0,16(sp)
    80000e52:	64a2                	ld	s1,8(sp)
    80000e54:	6105                	addi	sp,sp,32
    80000e56:	8082                	ret
    panic("release");
    80000e58:	00007517          	auipc	a0,0x7
    80000e5c:	29850513          	addi	a0,a0,664 # 800080f0 <digits+0xa0>
    80000e60:	fffff097          	auipc	ra,0xfffff
    80000e64:	6e0080e7          	jalr	1760(ra) # 80000540 <panic>

0000000080000e68 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e68:	1141                	addi	sp,sp,-16
    80000e6a:	e422                	sd	s0,8(sp)
    80000e6c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e6e:	ca19                	beqz	a2,80000e84 <memset+0x1c>
    80000e70:	87aa                	mv	a5,a0
    80000e72:	1602                	slli	a2,a2,0x20
    80000e74:	9201                	srli	a2,a2,0x20
    80000e76:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e7a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e7e:	0785                	addi	a5,a5,1
    80000e80:	fee79de3          	bne	a5,a4,80000e7a <memset+0x12>
  }
  return dst;
}
    80000e84:	6422                	ld	s0,8(sp)
    80000e86:	0141                	addi	sp,sp,16
    80000e88:	8082                	ret

0000000080000e8a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e8a:	1141                	addi	sp,sp,-16
    80000e8c:	e422                	sd	s0,8(sp)
    80000e8e:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e90:	ca05                	beqz	a2,80000ec0 <memcmp+0x36>
    80000e92:	fff6069b          	addiw	a3,a2,-1
    80000e96:	1682                	slli	a3,a3,0x20
    80000e98:	9281                	srli	a3,a3,0x20
    80000e9a:	0685                	addi	a3,a3,1
    80000e9c:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e9e:	00054783          	lbu	a5,0(a0)
    80000ea2:	0005c703          	lbu	a4,0(a1)
    80000ea6:	00e79863          	bne	a5,a4,80000eb6 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000eaa:	0505                	addi	a0,a0,1
    80000eac:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000eae:	fed518e3          	bne	a0,a3,80000e9e <memcmp+0x14>
  }

  return 0;
    80000eb2:	4501                	li	a0,0
    80000eb4:	a019                	j	80000eba <memcmp+0x30>
      return *s1 - *s2;
    80000eb6:	40e7853b          	subw	a0,a5,a4
}
    80000eba:	6422                	ld	s0,8(sp)
    80000ebc:	0141                	addi	sp,sp,16
    80000ebe:	8082                	ret
  return 0;
    80000ec0:	4501                	li	a0,0
    80000ec2:	bfe5                	j	80000eba <memcmp+0x30>

0000000080000ec4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000ec4:	1141                	addi	sp,sp,-16
    80000ec6:	e422                	sd	s0,8(sp)
    80000ec8:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000eca:	c205                	beqz	a2,80000eea <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ecc:	02a5e263          	bltu	a1,a0,80000ef0 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ed0:	1602                	slli	a2,a2,0x20
    80000ed2:	9201                	srli	a2,a2,0x20
    80000ed4:	00c587b3          	add	a5,a1,a2
{
    80000ed8:	872a                	mv	a4,a0
      *d++ = *s++;
    80000eda:	0585                	addi	a1,a1,1
    80000edc:	0705                	addi	a4,a4,1
    80000ede:	fff5c683          	lbu	a3,-1(a1)
    80000ee2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000ee6:	fef59ae3          	bne	a1,a5,80000eda <memmove+0x16>

  return dst;
}
    80000eea:	6422                	ld	s0,8(sp)
    80000eec:	0141                	addi	sp,sp,16
    80000eee:	8082                	ret
  if(s < d && s + n > d){
    80000ef0:	02061693          	slli	a3,a2,0x20
    80000ef4:	9281                	srli	a3,a3,0x20
    80000ef6:	00d58733          	add	a4,a1,a3
    80000efa:	fce57be3          	bgeu	a0,a4,80000ed0 <memmove+0xc>
    d += n;
    80000efe:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000f00:	fff6079b          	addiw	a5,a2,-1
    80000f04:	1782                	slli	a5,a5,0x20
    80000f06:	9381                	srli	a5,a5,0x20
    80000f08:	fff7c793          	not	a5,a5
    80000f0c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000f0e:	177d                	addi	a4,a4,-1
    80000f10:	16fd                	addi	a3,a3,-1
    80000f12:	00074603          	lbu	a2,0(a4)
    80000f16:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000f1a:	fee79ae3          	bne	a5,a4,80000f0e <memmove+0x4a>
    80000f1e:	b7f1                	j	80000eea <memmove+0x26>

0000000080000f20 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f20:	1141                	addi	sp,sp,-16
    80000f22:	e406                	sd	ra,8(sp)
    80000f24:	e022                	sd	s0,0(sp)
    80000f26:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f28:	00000097          	auipc	ra,0x0
    80000f2c:	f9c080e7          	jalr	-100(ra) # 80000ec4 <memmove>
}
    80000f30:	60a2                	ld	ra,8(sp)
    80000f32:	6402                	ld	s0,0(sp)
    80000f34:	0141                	addi	sp,sp,16
    80000f36:	8082                	ret

0000000080000f38 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f38:	1141                	addi	sp,sp,-16
    80000f3a:	e422                	sd	s0,8(sp)
    80000f3c:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f3e:	ce11                	beqz	a2,80000f5a <strncmp+0x22>
    80000f40:	00054783          	lbu	a5,0(a0)
    80000f44:	cf89                	beqz	a5,80000f5e <strncmp+0x26>
    80000f46:	0005c703          	lbu	a4,0(a1)
    80000f4a:	00f71a63          	bne	a4,a5,80000f5e <strncmp+0x26>
    n--, p++, q++;
    80000f4e:	367d                	addiw	a2,a2,-1
    80000f50:	0505                	addi	a0,a0,1
    80000f52:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000f54:	f675                	bnez	a2,80000f40 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f56:	4501                	li	a0,0
    80000f58:	a809                	j	80000f6a <strncmp+0x32>
    80000f5a:	4501                	li	a0,0
    80000f5c:	a039                	j	80000f6a <strncmp+0x32>
  if(n == 0)
    80000f5e:	ca09                	beqz	a2,80000f70 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f60:	00054503          	lbu	a0,0(a0)
    80000f64:	0005c783          	lbu	a5,0(a1)
    80000f68:	9d1d                	subw	a0,a0,a5
}
    80000f6a:	6422                	ld	s0,8(sp)
    80000f6c:	0141                	addi	sp,sp,16
    80000f6e:	8082                	ret
    return 0;
    80000f70:	4501                	li	a0,0
    80000f72:	bfe5                	j	80000f6a <strncmp+0x32>

0000000080000f74 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f74:	1141                	addi	sp,sp,-16
    80000f76:	e422                	sd	s0,8(sp)
    80000f78:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f7a:	872a                	mv	a4,a0
    80000f7c:	8832                	mv	a6,a2
    80000f7e:	367d                	addiw	a2,a2,-1
    80000f80:	01005963          	blez	a6,80000f92 <strncpy+0x1e>
    80000f84:	0705                	addi	a4,a4,1
    80000f86:	0005c783          	lbu	a5,0(a1)
    80000f8a:	fef70fa3          	sb	a5,-1(a4)
    80000f8e:	0585                	addi	a1,a1,1
    80000f90:	f7f5                	bnez	a5,80000f7c <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f92:	86ba                	mv	a3,a4
    80000f94:	00c05c63          	blez	a2,80000fac <strncpy+0x38>
    *s++ = 0;
    80000f98:	0685                	addi	a3,a3,1
    80000f9a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000f9e:	40d707bb          	subw	a5,a4,a3
    80000fa2:	37fd                	addiw	a5,a5,-1
    80000fa4:	010787bb          	addw	a5,a5,a6
    80000fa8:	fef048e3          	bgtz	a5,80000f98 <strncpy+0x24>
  return os;
}
    80000fac:	6422                	ld	s0,8(sp)
    80000fae:	0141                	addi	sp,sp,16
    80000fb0:	8082                	ret

0000000080000fb2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000fb2:	1141                	addi	sp,sp,-16
    80000fb4:	e422                	sd	s0,8(sp)
    80000fb6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000fb8:	02c05363          	blez	a2,80000fde <safestrcpy+0x2c>
    80000fbc:	fff6069b          	addiw	a3,a2,-1
    80000fc0:	1682                	slli	a3,a3,0x20
    80000fc2:	9281                	srli	a3,a3,0x20
    80000fc4:	96ae                	add	a3,a3,a1
    80000fc6:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000fc8:	00d58963          	beq	a1,a3,80000fda <safestrcpy+0x28>
    80000fcc:	0585                	addi	a1,a1,1
    80000fce:	0785                	addi	a5,a5,1
    80000fd0:	fff5c703          	lbu	a4,-1(a1)
    80000fd4:	fee78fa3          	sb	a4,-1(a5)
    80000fd8:	fb65                	bnez	a4,80000fc8 <safestrcpy+0x16>
    ;
  *s = 0;
    80000fda:	00078023          	sb	zero,0(a5)
  return os;
}
    80000fde:	6422                	ld	s0,8(sp)
    80000fe0:	0141                	addi	sp,sp,16
    80000fe2:	8082                	ret

0000000080000fe4 <strlen>:

int
strlen(const char *s)
{
    80000fe4:	1141                	addi	sp,sp,-16
    80000fe6:	e422                	sd	s0,8(sp)
    80000fe8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000fea:	00054783          	lbu	a5,0(a0)
    80000fee:	cf91                	beqz	a5,8000100a <strlen+0x26>
    80000ff0:	0505                	addi	a0,a0,1
    80000ff2:	87aa                	mv	a5,a0
    80000ff4:	4685                	li	a3,1
    80000ff6:	9e89                	subw	a3,a3,a0
    80000ff8:	00f6853b          	addw	a0,a3,a5
    80000ffc:	0785                	addi	a5,a5,1
    80000ffe:	fff7c703          	lbu	a4,-1(a5)
    80001002:	fb7d                	bnez	a4,80000ff8 <strlen+0x14>
    ;
  return n;
}
    80001004:	6422                	ld	s0,8(sp)
    80001006:	0141                	addi	sp,sp,16
    80001008:	8082                	ret
  for(n = 0; s[n]; n++)
    8000100a:	4501                	li	a0,0
    8000100c:	bfe5                	j	80001004 <strlen+0x20>

000000008000100e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000100e:	1141                	addi	sp,sp,-16
    80001010:	e406                	sd	ra,8(sp)
    80001012:	e022                	sd	s0,0(sp)
    80001014:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001016:	00001097          	auipc	ra,0x1
    8000101a:	c18080e7          	jalr	-1000(ra) # 80001c2e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000101e:	00008717          	auipc	a4,0x8
    80001022:	a9a70713          	addi	a4,a4,-1382 # 80008ab8 <started>
  if(cpuid() == 0){
    80001026:	c139                	beqz	a0,8000106c <main+0x5e>
    while(started == 0)
    80001028:	431c                	lw	a5,0(a4)
    8000102a:	2781                	sext.w	a5,a5
    8000102c:	dff5                	beqz	a5,80001028 <main+0x1a>
      ;
    __sync_synchronize();
    8000102e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001032:	00001097          	auipc	ra,0x1
    80001036:	bfc080e7          	jalr	-1028(ra) # 80001c2e <cpuid>
    8000103a:	85aa                	mv	a1,a0
    8000103c:	00007517          	auipc	a0,0x7
    80001040:	0d450513          	addi	a0,a0,212 # 80008110 <digits+0xc0>
    80001044:	fffff097          	auipc	ra,0xfffff
    80001048:	558080e7          	jalr	1368(ra) # 8000059c <printf>
    kvminithart();    // turn on paging
    8000104c:	00000097          	auipc	ra,0x0
    80001050:	0d8080e7          	jalr	216(ra) # 80001124 <kvminithart>
    trapinithart();   // install kernel trap vector
    80001054:	00002097          	auipc	ra,0x2
    80001058:	ad2080e7          	jalr	-1326(ra) # 80002b26 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000105c:	00005097          	auipc	ra,0x5
    80001060:	264080e7          	jalr	612(ra) # 800062c0 <plicinithart>
  }

  scheduler();        
    80001064:	00001097          	auipc	ra,0x1
    80001068:	294080e7          	jalr	660(ra) # 800022f8 <scheduler>
    consoleinit();
    8000106c:	fffff097          	auipc	ra,0xfffff
    80001070:	3e4080e7          	jalr	996(ra) # 80000450 <consoleinit>
    printfinit();
    80001074:	fffff097          	auipc	ra,0xfffff
    80001078:	708080e7          	jalr	1800(ra) # 8000077c <printfinit>
    printf("\n");
    8000107c:	00007517          	auipc	a0,0x7
    80001080:	44450513          	addi	a0,a0,1092 # 800084c0 <states.0+0xb0>
    80001084:	fffff097          	auipc	ra,0xfffff
    80001088:	518080e7          	jalr	1304(ra) # 8000059c <printf>
    printf("xv6 kernel is booting\n");
    8000108c:	00007517          	auipc	a0,0x7
    80001090:	06c50513          	addi	a0,a0,108 # 800080f8 <digits+0xa8>
    80001094:	fffff097          	auipc	ra,0xfffff
    80001098:	508080e7          	jalr	1288(ra) # 8000059c <printf>
    printf("\n");
    8000109c:	00007517          	auipc	a0,0x7
    800010a0:	42450513          	addi	a0,a0,1060 # 800084c0 <states.0+0xb0>
    800010a4:	fffff097          	auipc	ra,0xfffff
    800010a8:	4f8080e7          	jalr	1272(ra) # 8000059c <printf>
    kinit();         // physical page allocator
    800010ac:	00000097          	auipc	ra,0x0
    800010b0:	a6a080e7          	jalr	-1430(ra) # 80000b16 <kinit>
    kvminit();       // create kernel page table
    800010b4:	00000097          	auipc	ra,0x0
    800010b8:	326080e7          	jalr	806(ra) # 800013da <kvminit>
    kvminithart();   // turn on paging
    800010bc:	00000097          	auipc	ra,0x0
    800010c0:	068080e7          	jalr	104(ra) # 80001124 <kvminithart>
    procinit();      // process table
    800010c4:	00001097          	auipc	ra,0x1
    800010c8:	a88080e7          	jalr	-1400(ra) # 80001b4c <procinit>
    trapinit();      // trap vectors
    800010cc:	00002097          	auipc	ra,0x2
    800010d0:	a32080e7          	jalr	-1486(ra) # 80002afe <trapinit>
    trapinithart();  // install kernel trap vector
    800010d4:	00002097          	auipc	ra,0x2
    800010d8:	a52080e7          	jalr	-1454(ra) # 80002b26 <trapinithart>
    plicinit();      // set up interrupt controller
    800010dc:	00005097          	auipc	ra,0x5
    800010e0:	1ce080e7          	jalr	462(ra) # 800062aa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800010e4:	00005097          	auipc	ra,0x5
    800010e8:	1dc080e7          	jalr	476(ra) # 800062c0 <plicinithart>
    binit();         // buffer cache
    800010ec:	00002097          	auipc	ra,0x2
    800010f0:	37a080e7          	jalr	890(ra) # 80003466 <binit>
    iinit();         // inode table
    800010f4:	00003097          	auipc	ra,0x3
    800010f8:	a1a080e7          	jalr	-1510(ra) # 80003b0e <iinit>
    fileinit();      // file table
    800010fc:	00004097          	auipc	ra,0x4
    80001100:	9c0080e7          	jalr	-1600(ra) # 80004abc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001104:	00005097          	auipc	ra,0x5
    80001108:	2c4080e7          	jalr	708(ra) # 800063c8 <virtio_disk_init>
    userinit();      // first user process
    8000110c:	00001097          	auipc	ra,0x1
    80001110:	e26080e7          	jalr	-474(ra) # 80001f32 <userinit>
    __sync_synchronize();
    80001114:	0ff0000f          	fence
    started = 1;
    80001118:	4785                	li	a5,1
    8000111a:	00008717          	auipc	a4,0x8
    8000111e:	98f72f23          	sw	a5,-1634(a4) # 80008ab8 <started>
    80001122:	b789                	j	80001064 <main+0x56>

0000000080001124 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001124:	1141                	addi	sp,sp,-16
    80001126:	e422                	sd	s0,8(sp)
    80001128:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000112a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000112e:	00008797          	auipc	a5,0x8
    80001132:	9927b783          	ld	a5,-1646(a5) # 80008ac0 <kernel_pagetable>
    80001136:	83b1                	srli	a5,a5,0xc
    80001138:	577d                	li	a4,-1
    8000113a:	177e                	slli	a4,a4,0x3f
    8000113c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000113e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001142:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001146:	6422                	ld	s0,8(sp)
    80001148:	0141                	addi	sp,sp,16
    8000114a:	8082                	ret

000000008000114c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000114c:	7139                	addi	sp,sp,-64
    8000114e:	fc06                	sd	ra,56(sp)
    80001150:	f822                	sd	s0,48(sp)
    80001152:	f426                	sd	s1,40(sp)
    80001154:	f04a                	sd	s2,32(sp)
    80001156:	ec4e                	sd	s3,24(sp)
    80001158:	e852                	sd	s4,16(sp)
    8000115a:	e456                	sd	s5,8(sp)
    8000115c:	e05a                	sd	s6,0(sp)
    8000115e:	0080                	addi	s0,sp,64
    80001160:	84aa                	mv	s1,a0
    80001162:	89ae                	mv	s3,a1
    80001164:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001166:	57fd                	li	a5,-1
    80001168:	83e9                	srli	a5,a5,0x1a
    8000116a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000116c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000116e:	04b7f263          	bgeu	a5,a1,800011b2 <walk+0x66>
    panic("walk");
    80001172:	00007517          	auipc	a0,0x7
    80001176:	fb650513          	addi	a0,a0,-74 # 80008128 <digits+0xd8>
    8000117a:	fffff097          	auipc	ra,0xfffff
    8000117e:	3c6080e7          	jalr	966(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001182:	060a8663          	beqz	s5,800011ee <walk+0xa2>
    80001186:	00000097          	auipc	ra,0x0
    8000118a:	a38080e7          	jalr	-1480(ra) # 80000bbe <kalloc>
    8000118e:	84aa                	mv	s1,a0
    80001190:	c529                	beqz	a0,800011da <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001192:	6605                	lui	a2,0x1
    80001194:	4581                	li	a1,0
    80001196:	00000097          	auipc	ra,0x0
    8000119a:	cd2080e7          	jalr	-814(ra) # 80000e68 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000119e:	00c4d793          	srli	a5,s1,0xc
    800011a2:	07aa                	slli	a5,a5,0xa
    800011a4:	0017e793          	ori	a5,a5,1
    800011a8:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800011ac:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ff9d0a7>
    800011ae:	036a0063          	beq	s4,s6,800011ce <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800011b2:	0149d933          	srl	s2,s3,s4
    800011b6:	1ff97913          	andi	s2,s2,511
    800011ba:	090e                	slli	s2,s2,0x3
    800011bc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800011be:	00093483          	ld	s1,0(s2)
    800011c2:	0014f793          	andi	a5,s1,1
    800011c6:	dfd5                	beqz	a5,80001182 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800011c8:	80a9                	srli	s1,s1,0xa
    800011ca:	04b2                	slli	s1,s1,0xc
    800011cc:	b7c5                	j	800011ac <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800011ce:	00c9d513          	srli	a0,s3,0xc
    800011d2:	1ff57513          	andi	a0,a0,511
    800011d6:	050e                	slli	a0,a0,0x3
    800011d8:	9526                	add	a0,a0,s1
}
    800011da:	70e2                	ld	ra,56(sp)
    800011dc:	7442                	ld	s0,48(sp)
    800011de:	74a2                	ld	s1,40(sp)
    800011e0:	7902                	ld	s2,32(sp)
    800011e2:	69e2                	ld	s3,24(sp)
    800011e4:	6a42                	ld	s4,16(sp)
    800011e6:	6aa2                	ld	s5,8(sp)
    800011e8:	6b02                	ld	s6,0(sp)
    800011ea:	6121                	addi	sp,sp,64
    800011ec:	8082                	ret
        return 0;
    800011ee:	4501                	li	a0,0
    800011f0:	b7ed                	j	800011da <walk+0x8e>

00000000800011f2 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800011f2:	57fd                	li	a5,-1
    800011f4:	83e9                	srli	a5,a5,0x1a
    800011f6:	00b7f463          	bgeu	a5,a1,800011fe <walkaddr+0xc>
    return 0;
    800011fa:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800011fc:	8082                	ret
{
    800011fe:	1141                	addi	sp,sp,-16
    80001200:	e406                	sd	ra,8(sp)
    80001202:	e022                	sd	s0,0(sp)
    80001204:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001206:	4601                	li	a2,0
    80001208:	00000097          	auipc	ra,0x0
    8000120c:	f44080e7          	jalr	-188(ra) # 8000114c <walk>
  if(pte == 0)
    80001210:	c105                	beqz	a0,80001230 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001212:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001214:	0117f693          	andi	a3,a5,17
    80001218:	4745                	li	a4,17
    return 0;
    8000121a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000121c:	00e68663          	beq	a3,a4,80001228 <walkaddr+0x36>
}
    80001220:	60a2                	ld	ra,8(sp)
    80001222:	6402                	ld	s0,0(sp)
    80001224:	0141                	addi	sp,sp,16
    80001226:	8082                	ret
  pa = PTE2PA(*pte);
    80001228:	83a9                	srli	a5,a5,0xa
    8000122a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000122e:	bfcd                	j	80001220 <walkaddr+0x2e>
    return 0;
    80001230:	4501                	li	a0,0
    80001232:	b7fd                	j	80001220 <walkaddr+0x2e>

0000000080001234 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001234:	715d                	addi	sp,sp,-80
    80001236:	e486                	sd	ra,72(sp)
    80001238:	e0a2                	sd	s0,64(sp)
    8000123a:	fc26                	sd	s1,56(sp)
    8000123c:	f84a                	sd	s2,48(sp)
    8000123e:	f44e                	sd	s3,40(sp)
    80001240:	f052                	sd	s4,32(sp)
    80001242:	ec56                	sd	s5,24(sp)
    80001244:	e85a                	sd	s6,16(sp)
    80001246:	e45e                	sd	s7,8(sp)
    80001248:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000124a:	c639                	beqz	a2,80001298 <mappages+0x64>
    8000124c:	8aaa                	mv	s5,a0
    8000124e:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001250:	777d                	lui	a4,0xfffff
    80001252:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001256:	fff58993          	addi	s3,a1,-1
    8000125a:	99b2                	add	s3,s3,a2
    8000125c:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001260:	893e                	mv	s2,a5
    80001262:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001266:	6b85                	lui	s7,0x1
    80001268:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000126c:	4605                	li	a2,1
    8000126e:	85ca                	mv	a1,s2
    80001270:	8556                	mv	a0,s5
    80001272:	00000097          	auipc	ra,0x0
    80001276:	eda080e7          	jalr	-294(ra) # 8000114c <walk>
    8000127a:	cd1d                	beqz	a0,800012b8 <mappages+0x84>
    if(*pte & PTE_V)
    8000127c:	611c                	ld	a5,0(a0)
    8000127e:	8b85                	andi	a5,a5,1
    80001280:	e785                	bnez	a5,800012a8 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001282:	80b1                	srli	s1,s1,0xc
    80001284:	04aa                	slli	s1,s1,0xa
    80001286:	0164e4b3          	or	s1,s1,s6
    8000128a:	0014e493          	ori	s1,s1,1
    8000128e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001290:	05390063          	beq	s2,s3,800012d0 <mappages+0x9c>
    a += PGSIZE;
    80001294:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001296:	bfc9                	j	80001268 <mappages+0x34>
    panic("mappages: size");
    80001298:	00007517          	auipc	a0,0x7
    8000129c:	e9850513          	addi	a0,a0,-360 # 80008130 <digits+0xe0>
    800012a0:	fffff097          	auipc	ra,0xfffff
    800012a4:	2a0080e7          	jalr	672(ra) # 80000540 <panic>
      panic("mappages: remap");
    800012a8:	00007517          	auipc	a0,0x7
    800012ac:	e9850513          	addi	a0,a0,-360 # 80008140 <digits+0xf0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	290080e7          	jalr	656(ra) # 80000540 <panic>
      return -1;
    800012b8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800012ba:	60a6                	ld	ra,72(sp)
    800012bc:	6406                	ld	s0,64(sp)
    800012be:	74e2                	ld	s1,56(sp)
    800012c0:	7942                	ld	s2,48(sp)
    800012c2:	79a2                	ld	s3,40(sp)
    800012c4:	7a02                	ld	s4,32(sp)
    800012c6:	6ae2                	ld	s5,24(sp)
    800012c8:	6b42                	ld	s6,16(sp)
    800012ca:	6ba2                	ld	s7,8(sp)
    800012cc:	6161                	addi	sp,sp,80
    800012ce:	8082                	ret
  return 0;
    800012d0:	4501                	li	a0,0
    800012d2:	b7e5                	j	800012ba <mappages+0x86>

00000000800012d4 <kvmmap>:
{
    800012d4:	1141                	addi	sp,sp,-16
    800012d6:	e406                	sd	ra,8(sp)
    800012d8:	e022                	sd	s0,0(sp)
    800012da:	0800                	addi	s0,sp,16
    800012dc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800012de:	86b2                	mv	a3,a2
    800012e0:	863e                	mv	a2,a5
    800012e2:	00000097          	auipc	ra,0x0
    800012e6:	f52080e7          	jalr	-174(ra) # 80001234 <mappages>
    800012ea:	e509                	bnez	a0,800012f4 <kvmmap+0x20>
}
    800012ec:	60a2                	ld	ra,8(sp)
    800012ee:	6402                	ld	s0,0(sp)
    800012f0:	0141                	addi	sp,sp,16
    800012f2:	8082                	ret
    panic("kvmmap");
    800012f4:	00007517          	auipc	a0,0x7
    800012f8:	e5c50513          	addi	a0,a0,-420 # 80008150 <digits+0x100>
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	244080e7          	jalr	580(ra) # 80000540 <panic>

0000000080001304 <kvmmake>:
{
    80001304:	1101                	addi	sp,sp,-32
    80001306:	ec06                	sd	ra,24(sp)
    80001308:	e822                	sd	s0,16(sp)
    8000130a:	e426                	sd	s1,8(sp)
    8000130c:	e04a                	sd	s2,0(sp)
    8000130e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001310:	00000097          	auipc	ra,0x0
    80001314:	8ae080e7          	jalr	-1874(ra) # 80000bbe <kalloc>
    80001318:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000131a:	6605                	lui	a2,0x1
    8000131c:	4581                	li	a1,0
    8000131e:	00000097          	auipc	ra,0x0
    80001322:	b4a080e7          	jalr	-1206(ra) # 80000e68 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001326:	4719                	li	a4,6
    80001328:	6685                	lui	a3,0x1
    8000132a:	10000637          	lui	a2,0x10000
    8000132e:	100005b7          	lui	a1,0x10000
    80001332:	8526                	mv	a0,s1
    80001334:	00000097          	auipc	ra,0x0
    80001338:	fa0080e7          	jalr	-96(ra) # 800012d4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000133c:	4719                	li	a4,6
    8000133e:	6685                	lui	a3,0x1
    80001340:	10001637          	lui	a2,0x10001
    80001344:	100015b7          	lui	a1,0x10001
    80001348:	8526                	mv	a0,s1
    8000134a:	00000097          	auipc	ra,0x0
    8000134e:	f8a080e7          	jalr	-118(ra) # 800012d4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001352:	4719                	li	a4,6
    80001354:	004006b7          	lui	a3,0x400
    80001358:	0c000637          	lui	a2,0xc000
    8000135c:	0c0005b7          	lui	a1,0xc000
    80001360:	8526                	mv	a0,s1
    80001362:	00000097          	auipc	ra,0x0
    80001366:	f72080e7          	jalr	-142(ra) # 800012d4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000136a:	00007917          	auipc	s2,0x7
    8000136e:	c9690913          	addi	s2,s2,-874 # 80008000 <etext>
    80001372:	4729                	li	a4,10
    80001374:	80007697          	auipc	a3,0x80007
    80001378:	c8c68693          	addi	a3,a3,-884 # 8000 <_entry-0x7fff8000>
    8000137c:	4605                	li	a2,1
    8000137e:	067e                	slli	a2,a2,0x1f
    80001380:	85b2                	mv	a1,a2
    80001382:	8526                	mv	a0,s1
    80001384:	00000097          	auipc	ra,0x0
    80001388:	f50080e7          	jalr	-176(ra) # 800012d4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000138c:	4719                	li	a4,6
    8000138e:	46c5                	li	a3,17
    80001390:	06ee                	slli	a3,a3,0x1b
    80001392:	412686b3          	sub	a3,a3,s2
    80001396:	864a                	mv	a2,s2
    80001398:	85ca                	mv	a1,s2
    8000139a:	8526                	mv	a0,s1
    8000139c:	00000097          	auipc	ra,0x0
    800013a0:	f38080e7          	jalr	-200(ra) # 800012d4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800013a4:	4729                	li	a4,10
    800013a6:	6685                	lui	a3,0x1
    800013a8:	00006617          	auipc	a2,0x6
    800013ac:	c5860613          	addi	a2,a2,-936 # 80007000 <_trampoline>
    800013b0:	040005b7          	lui	a1,0x4000
    800013b4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800013b6:	05b2                	slli	a1,a1,0xc
    800013b8:	8526                	mv	a0,s1
    800013ba:	00000097          	auipc	ra,0x0
    800013be:	f1a080e7          	jalr	-230(ra) # 800012d4 <kvmmap>
  proc_mapstacks(kpgtbl);
    800013c2:	8526                	mv	a0,s1
    800013c4:	00000097          	auipc	ra,0x0
    800013c8:	6f2080e7          	jalr	1778(ra) # 80001ab6 <proc_mapstacks>
}
    800013cc:	8526                	mv	a0,s1
    800013ce:	60e2                	ld	ra,24(sp)
    800013d0:	6442                	ld	s0,16(sp)
    800013d2:	64a2                	ld	s1,8(sp)
    800013d4:	6902                	ld	s2,0(sp)
    800013d6:	6105                	addi	sp,sp,32
    800013d8:	8082                	ret

00000000800013da <kvminit>:
{
    800013da:	1141                	addi	sp,sp,-16
    800013dc:	e406                	sd	ra,8(sp)
    800013de:	e022                	sd	s0,0(sp)
    800013e0:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800013e2:	00000097          	auipc	ra,0x0
    800013e6:	f22080e7          	jalr	-222(ra) # 80001304 <kvmmake>
    800013ea:	00007797          	auipc	a5,0x7
    800013ee:	6ca7bb23          	sd	a0,1750(a5) # 80008ac0 <kernel_pagetable>
}
    800013f2:	60a2                	ld	ra,8(sp)
    800013f4:	6402                	ld	s0,0(sp)
    800013f6:	0141                	addi	sp,sp,16
    800013f8:	8082                	ret

00000000800013fa <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013fa:	715d                	addi	sp,sp,-80
    800013fc:	e486                	sd	ra,72(sp)
    800013fe:	e0a2                	sd	s0,64(sp)
    80001400:	fc26                	sd	s1,56(sp)
    80001402:	f84a                	sd	s2,48(sp)
    80001404:	f44e                	sd	s3,40(sp)
    80001406:	f052                	sd	s4,32(sp)
    80001408:	ec56                	sd	s5,24(sp)
    8000140a:	e85a                	sd	s6,16(sp)
    8000140c:	e45e                	sd	s7,8(sp)
    8000140e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001410:	03459793          	slli	a5,a1,0x34
    80001414:	e795                	bnez	a5,80001440 <uvmunmap+0x46>
    80001416:	8a2a                	mv	s4,a0
    80001418:	892e                	mv	s2,a1
    8000141a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000141c:	0632                	slli	a2,a2,0xc
    8000141e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001422:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001424:	6b05                	lui	s6,0x1
    80001426:	0735e263          	bltu	a1,s3,8000148a <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      dec_ref((void*)pa);
    }
    *pte = 0;
  }
}
    8000142a:	60a6                	ld	ra,72(sp)
    8000142c:	6406                	ld	s0,64(sp)
    8000142e:	74e2                	ld	s1,56(sp)
    80001430:	7942                	ld	s2,48(sp)
    80001432:	79a2                	ld	s3,40(sp)
    80001434:	7a02                	ld	s4,32(sp)
    80001436:	6ae2                	ld	s5,24(sp)
    80001438:	6b42                	ld	s6,16(sp)
    8000143a:	6ba2                	ld	s7,8(sp)
    8000143c:	6161                	addi	sp,sp,80
    8000143e:	8082                	ret
    panic("uvmunmap: not aligned");
    80001440:	00007517          	auipc	a0,0x7
    80001444:	d1850513          	addi	a0,a0,-744 # 80008158 <digits+0x108>
    80001448:	fffff097          	auipc	ra,0xfffff
    8000144c:	0f8080e7          	jalr	248(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    80001450:	00007517          	auipc	a0,0x7
    80001454:	d2050513          	addi	a0,a0,-736 # 80008170 <digits+0x120>
    80001458:	fffff097          	auipc	ra,0xfffff
    8000145c:	0e8080e7          	jalr	232(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    80001460:	00007517          	auipc	a0,0x7
    80001464:	d2050513          	addi	a0,a0,-736 # 80008180 <digits+0x130>
    80001468:	fffff097          	auipc	ra,0xfffff
    8000146c:	0d8080e7          	jalr	216(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    80001470:	00007517          	auipc	a0,0x7
    80001474:	d2850513          	addi	a0,a0,-728 # 80008198 <digits+0x148>
    80001478:	fffff097          	auipc	ra,0xfffff
    8000147c:	0c8080e7          	jalr	200(ra) # 80000540 <panic>
    *pte = 0;
    80001480:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001484:	995a                	add	s2,s2,s6
    80001486:	fb3972e3          	bgeu	s2,s3,8000142a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000148a:	4601                	li	a2,0
    8000148c:	85ca                	mv	a1,s2
    8000148e:	8552                	mv	a0,s4
    80001490:	00000097          	auipc	ra,0x0
    80001494:	cbc080e7          	jalr	-836(ra) # 8000114c <walk>
    80001498:	84aa                	mv	s1,a0
    8000149a:	d95d                	beqz	a0,80001450 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000149c:	6108                	ld	a0,0(a0)
    8000149e:	00157793          	andi	a5,a0,1
    800014a2:	dfdd                	beqz	a5,80001460 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800014a4:	3ff57793          	andi	a5,a0,1023
    800014a8:	fd7784e3          	beq	a5,s7,80001470 <uvmunmap+0x76>
    if(do_free){
    800014ac:	fc0a8ae3          	beqz	s5,80001480 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800014b0:	8129                	srli	a0,a0,0xa
      dec_ref((void*)pa);
    800014b2:	0532                	slli	a0,a0,0xc
    800014b4:	fffff097          	auipc	ra,0xfffff
    800014b8:	7c0080e7          	jalr	1984(ra) # 80000c74 <dec_ref>
    800014bc:	b7d1                	j	80001480 <uvmunmap+0x86>

00000000800014be <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800014be:	1101                	addi	sp,sp,-32
    800014c0:	ec06                	sd	ra,24(sp)
    800014c2:	e822                	sd	s0,16(sp)
    800014c4:	e426                	sd	s1,8(sp)
    800014c6:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800014c8:	fffff097          	auipc	ra,0xfffff
    800014cc:	6f6080e7          	jalr	1782(ra) # 80000bbe <kalloc>
    800014d0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800014d2:	c519                	beqz	a0,800014e0 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800014d4:	6605                	lui	a2,0x1
    800014d6:	4581                	li	a1,0
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	990080e7          	jalr	-1648(ra) # 80000e68 <memset>
  return pagetable;
}
    800014e0:	8526                	mv	a0,s1
    800014e2:	60e2                	ld	ra,24(sp)
    800014e4:	6442                	ld	s0,16(sp)
    800014e6:	64a2                	ld	s1,8(sp)
    800014e8:	6105                	addi	sp,sp,32
    800014ea:	8082                	ret

00000000800014ec <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800014ec:	7179                	addi	sp,sp,-48
    800014ee:	f406                	sd	ra,40(sp)
    800014f0:	f022                	sd	s0,32(sp)
    800014f2:	ec26                	sd	s1,24(sp)
    800014f4:	e84a                	sd	s2,16(sp)
    800014f6:	e44e                	sd	s3,8(sp)
    800014f8:	e052                	sd	s4,0(sp)
    800014fa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800014fc:	6785                	lui	a5,0x1
    800014fe:	04f67863          	bgeu	a2,a5,8000154e <uvmfirst+0x62>
    80001502:	8a2a                	mv	s4,a0
    80001504:	89ae                	mv	s3,a1
    80001506:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001508:	fffff097          	auipc	ra,0xfffff
    8000150c:	6b6080e7          	jalr	1718(ra) # 80000bbe <kalloc>
    80001510:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001512:	6605                	lui	a2,0x1
    80001514:	4581                	li	a1,0
    80001516:	00000097          	auipc	ra,0x0
    8000151a:	952080e7          	jalr	-1710(ra) # 80000e68 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000151e:	4779                	li	a4,30
    80001520:	86ca                	mv	a3,s2
    80001522:	6605                	lui	a2,0x1
    80001524:	4581                	li	a1,0
    80001526:	8552                	mv	a0,s4
    80001528:	00000097          	auipc	ra,0x0
    8000152c:	d0c080e7          	jalr	-756(ra) # 80001234 <mappages>
  memmove(mem, src, sz);
    80001530:	8626                	mv	a2,s1
    80001532:	85ce                	mv	a1,s3
    80001534:	854a                	mv	a0,s2
    80001536:	00000097          	auipc	ra,0x0
    8000153a:	98e080e7          	jalr	-1650(ra) # 80000ec4 <memmove>
}
    8000153e:	70a2                	ld	ra,40(sp)
    80001540:	7402                	ld	s0,32(sp)
    80001542:	64e2                	ld	s1,24(sp)
    80001544:	6942                	ld	s2,16(sp)
    80001546:	69a2                	ld	s3,8(sp)
    80001548:	6a02                	ld	s4,0(sp)
    8000154a:	6145                	addi	sp,sp,48
    8000154c:	8082                	ret
    panic("uvmfirst: more than a page");
    8000154e:	00007517          	auipc	a0,0x7
    80001552:	c6250513          	addi	a0,a0,-926 # 800081b0 <digits+0x160>
    80001556:	fffff097          	auipc	ra,0xfffff
    8000155a:	fea080e7          	jalr	-22(ra) # 80000540 <panic>

000000008000155e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000155e:	1101                	addi	sp,sp,-32
    80001560:	ec06                	sd	ra,24(sp)
    80001562:	e822                	sd	s0,16(sp)
    80001564:	e426                	sd	s1,8(sp)
    80001566:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001568:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000156a:	00b67d63          	bgeu	a2,a1,80001584 <uvmdealloc+0x26>
    8000156e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001570:	6785                	lui	a5,0x1
    80001572:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001574:	00f60733          	add	a4,a2,a5
    80001578:	76fd                	lui	a3,0xfffff
    8000157a:	8f75                	and	a4,a4,a3
    8000157c:	97ae                	add	a5,a5,a1
    8000157e:	8ff5                	and	a5,a5,a3
    80001580:	00f76863          	bltu	a4,a5,80001590 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001584:	8526                	mv	a0,s1
    80001586:	60e2                	ld	ra,24(sp)
    80001588:	6442                	ld	s0,16(sp)
    8000158a:	64a2                	ld	s1,8(sp)
    8000158c:	6105                	addi	sp,sp,32
    8000158e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001590:	8f99                	sub	a5,a5,a4
    80001592:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001594:	4685                	li	a3,1
    80001596:	0007861b          	sext.w	a2,a5
    8000159a:	85ba                	mv	a1,a4
    8000159c:	00000097          	auipc	ra,0x0
    800015a0:	e5e080e7          	jalr	-418(ra) # 800013fa <uvmunmap>
    800015a4:	b7c5                	j	80001584 <uvmdealloc+0x26>

00000000800015a6 <uvmalloc>:
  if(newsz < oldsz)
    800015a6:	0ab66563          	bltu	a2,a1,80001650 <uvmalloc+0xaa>
{
    800015aa:	7139                	addi	sp,sp,-64
    800015ac:	fc06                	sd	ra,56(sp)
    800015ae:	f822                	sd	s0,48(sp)
    800015b0:	f426                	sd	s1,40(sp)
    800015b2:	f04a                	sd	s2,32(sp)
    800015b4:	ec4e                	sd	s3,24(sp)
    800015b6:	e852                	sd	s4,16(sp)
    800015b8:	e456                	sd	s5,8(sp)
    800015ba:	e05a                	sd	s6,0(sp)
    800015bc:	0080                	addi	s0,sp,64
    800015be:	8aaa                	mv	s5,a0
    800015c0:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800015c2:	6785                	lui	a5,0x1
    800015c4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015c6:	95be                	add	a1,a1,a5
    800015c8:	77fd                	lui	a5,0xfffff
    800015ca:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015ce:	08c9f363          	bgeu	s3,a2,80001654 <uvmalloc+0xae>
    800015d2:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800015d4:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	5e6080e7          	jalr	1510(ra) # 80000bbe <kalloc>
    800015e0:	84aa                	mv	s1,a0
    if(mem == 0){
    800015e2:	c51d                	beqz	a0,80001610 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    800015e4:	6605                	lui	a2,0x1
    800015e6:	4581                	li	a1,0
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	880080e7          	jalr	-1920(ra) # 80000e68 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800015f0:	875a                	mv	a4,s6
    800015f2:	86a6                	mv	a3,s1
    800015f4:	6605                	lui	a2,0x1
    800015f6:	85ca                	mv	a1,s2
    800015f8:	8556                	mv	a0,s5
    800015fa:	00000097          	auipc	ra,0x0
    800015fe:	c3a080e7          	jalr	-966(ra) # 80001234 <mappages>
    80001602:	e90d                	bnez	a0,80001634 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001604:	6785                	lui	a5,0x1
    80001606:	993e                	add	s2,s2,a5
    80001608:	fd4968e3          	bltu	s2,s4,800015d8 <uvmalloc+0x32>
  return newsz;
    8000160c:	8552                	mv	a0,s4
    8000160e:	a809                	j	80001620 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001610:	864e                	mv	a2,s3
    80001612:	85ca                	mv	a1,s2
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	f48080e7          	jalr	-184(ra) # 8000155e <uvmdealloc>
      return 0;
    8000161e:	4501                	li	a0,0
}
    80001620:	70e2                	ld	ra,56(sp)
    80001622:	7442                	ld	s0,48(sp)
    80001624:	74a2                	ld	s1,40(sp)
    80001626:	7902                	ld	s2,32(sp)
    80001628:	69e2                	ld	s3,24(sp)
    8000162a:	6a42                	ld	s4,16(sp)
    8000162c:	6aa2                	ld	s5,8(sp)
    8000162e:	6b02                	ld	s6,0(sp)
    80001630:	6121                	addi	sp,sp,64
    80001632:	8082                	ret
      dec_ref(mem);
    80001634:	8526                	mv	a0,s1
    80001636:	fffff097          	auipc	ra,0xfffff
    8000163a:	63e080e7          	jalr	1598(ra) # 80000c74 <dec_ref>
      uvmdealloc(pagetable, a, oldsz);
    8000163e:	864e                	mv	a2,s3
    80001640:	85ca                	mv	a1,s2
    80001642:	8556                	mv	a0,s5
    80001644:	00000097          	auipc	ra,0x0
    80001648:	f1a080e7          	jalr	-230(ra) # 8000155e <uvmdealloc>
      return 0;
    8000164c:	4501                	li	a0,0
    8000164e:	bfc9                	j	80001620 <uvmalloc+0x7a>
    return oldsz;
    80001650:	852e                	mv	a0,a1
}
    80001652:	8082                	ret
  return newsz;
    80001654:	8532                	mv	a0,a2
    80001656:	b7e9                	j	80001620 <uvmalloc+0x7a>

0000000080001658 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001658:	7179                	addi	sp,sp,-48
    8000165a:	f406                	sd	ra,40(sp)
    8000165c:	f022                	sd	s0,32(sp)
    8000165e:	ec26                	sd	s1,24(sp)
    80001660:	e84a                	sd	s2,16(sp)
    80001662:	e44e                	sd	s3,8(sp)
    80001664:	e052                	sd	s4,0(sp)
    80001666:	1800                	addi	s0,sp,48
    80001668:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000166a:	84aa                	mv	s1,a0
    8000166c:	6905                	lui	s2,0x1
    8000166e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001670:	4985                	li	s3,1
    80001672:	a829                	j	8000168c <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001674:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001676:	00c79513          	slli	a0,a5,0xc
    8000167a:	00000097          	auipc	ra,0x0
    8000167e:	fde080e7          	jalr	-34(ra) # 80001658 <freewalk>
      pagetable[i] = 0;
    80001682:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001686:	04a1                	addi	s1,s1,8
    80001688:	03248163          	beq	s1,s2,800016aa <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000168c:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000168e:	00f7f713          	andi	a4,a5,15
    80001692:	ff3701e3          	beq	a4,s3,80001674 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001696:	8b85                	andi	a5,a5,1
    80001698:	d7fd                	beqz	a5,80001686 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000169a:	00007517          	auipc	a0,0x7
    8000169e:	b3650513          	addi	a0,a0,-1226 # 800081d0 <digits+0x180>
    800016a2:	fffff097          	auipc	ra,0xfffff
    800016a6:	e9e080e7          	jalr	-354(ra) # 80000540 <panic>
    }
  }
  dec_ref((void*)pagetable);
    800016aa:	8552                	mv	a0,s4
    800016ac:	fffff097          	auipc	ra,0xfffff
    800016b0:	5c8080e7          	jalr	1480(ra) # 80000c74 <dec_ref>
}
    800016b4:	70a2                	ld	ra,40(sp)
    800016b6:	7402                	ld	s0,32(sp)
    800016b8:	64e2                	ld	s1,24(sp)
    800016ba:	6942                	ld	s2,16(sp)
    800016bc:	69a2                	ld	s3,8(sp)
    800016be:	6a02                	ld	s4,0(sp)
    800016c0:	6145                	addi	sp,sp,48
    800016c2:	8082                	ret

00000000800016c4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800016c4:	1101                	addi	sp,sp,-32
    800016c6:	ec06                	sd	ra,24(sp)
    800016c8:	e822                	sd	s0,16(sp)
    800016ca:	e426                	sd	s1,8(sp)
    800016cc:	1000                	addi	s0,sp,32
    800016ce:	84aa                	mv	s1,a0
  if(sz > 0)
    800016d0:	e999                	bnez	a1,800016e6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800016d2:	8526                	mv	a0,s1
    800016d4:	00000097          	auipc	ra,0x0
    800016d8:	f84080e7          	jalr	-124(ra) # 80001658 <freewalk>
}
    800016dc:	60e2                	ld	ra,24(sp)
    800016de:	6442                	ld	s0,16(sp)
    800016e0:	64a2                	ld	s1,8(sp)
    800016e2:	6105                	addi	sp,sp,32
    800016e4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800016e6:	6785                	lui	a5,0x1
    800016e8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800016ea:	95be                	add	a1,a1,a5
    800016ec:	4685                	li	a3,1
    800016ee:	00c5d613          	srli	a2,a1,0xc
    800016f2:	4581                	li	a1,0
    800016f4:	00000097          	auipc	ra,0x0
    800016f8:	d06080e7          	jalr	-762(ra) # 800013fa <uvmunmap>
    800016fc:	bfd9                	j	800016d2 <uvmfree+0xe>

00000000800016fe <uvmcopy>:
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  for(i = 0; i < sz; i += PGSIZE){
    800016fe:	c665                	beqz	a2,800017e6 <uvmcopy+0xe8>
{
    80001700:	7139                	addi	sp,sp,-64
    80001702:	fc06                	sd	ra,56(sp)
    80001704:	f822                	sd	s0,48(sp)
    80001706:	f426                	sd	s1,40(sp)
    80001708:	f04a                	sd	s2,32(sp)
    8000170a:	ec4e                	sd	s3,24(sp)
    8000170c:	e852                	sd	s4,16(sp)
    8000170e:	e456                	sd	s5,8(sp)
    80001710:	e05a                	sd	s6,0(sp)
    80001712:	0080                	addi	s0,sp,64
    80001714:	8a2a                	mv	s4,a0
    80001716:	8aae                	mv	s5,a1
    80001718:	8b32                	mv	s6,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000171a:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    8000171c:	4601                	li	a2,0
    8000171e:	85ca                	mv	a1,s2
    80001720:	8552                	mv	a0,s4
    80001722:	00000097          	auipc	ra,0x0
    80001726:	a2a080e7          	jalr	-1494(ra) # 8000114c <walk>
    8000172a:	c135                	beqz	a0,8000178e <uvmcopy+0x90>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000172c:	6118                	ld	a4,0(a0)
    8000172e:	00177793          	andi	a5,a4,1
    80001732:	c7b5                	beqz	a5,8000179e <uvmcopy+0xa0>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001734:	00a75993          	srli	s3,a4,0xa
    80001738:	09b2                	slli	s3,s3,0xc
    flags = PTE_FLAGS(*pte);
    // Record the page is COW mapping.
    flags |= PTE_RSW;
    // clear PTE_W in the PTEs of both child and parent*
    flags &= (~PTE_W);
    8000173a:	3fb77713          	andi	a4,a4,1019

    // map the parent’s physical pages into the child
    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){
    8000173e:	02076493          	ori	s1,a4,32
    80001742:	8726                	mv	a4,s1
    80001744:	86ce                	mv	a3,s3
    80001746:	6605                	lui	a2,0x1
    80001748:	85ca                	mv	a1,s2
    8000174a:	8556                	mv	a0,s5
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	ae8080e7          	jalr	-1304(ra) # 80001234 <mappages>
    80001754:	ed29                	bnez	a0,800017ae <uvmcopy+0xb0>
      //dec_ref(mem);
      goto err;
    }
    // Bump the reference count of the physical page.
    add_ref((void*)pa);
    80001756:	854e                	mv	a0,s3
    80001758:	fffff097          	auipc	ra,0xfffff
    8000175c:	436080e7          	jalr	1078(ra) # 80000b8e <add_ref>
    // Remove parent page table mapping.
    uvmunmap(old, i, 1, 0);
    80001760:	4681                	li	a3,0
    80001762:	4605                	li	a2,1
    80001764:	85ca                	mv	a1,s2
    80001766:	8552                	mv	a0,s4
    80001768:	00000097          	auipc	ra,0x0
    8000176c:	c92080e7          	jalr	-878(ra) # 800013fa <uvmunmap>
    // Re-add the mapping with write bit cleared flags.
    if (mappages(old, i, PGSIZE, pa, flags) != 0) {
    80001770:	8726                	mv	a4,s1
    80001772:	86ce                	mv	a3,s3
    80001774:	6605                	lui	a2,0x1
    80001776:	85ca                	mv	a1,s2
    80001778:	8552                	mv	a0,s4
    8000177a:	00000097          	auipc	ra,0x0
    8000177e:	aba080e7          	jalr	-1350(ra) # 80001234 <mappages>
    80001782:	e515                	bnez	a0,800017ae <uvmcopy+0xb0>
  for(i = 0; i < sz; i += PGSIZE){
    80001784:	6785                	lui	a5,0x1
    80001786:	993e                	add	s2,s2,a5
    80001788:	f9696ae3          	bltu	s2,s6,8000171c <uvmcopy+0x1e>
    8000178c:	a099                	j	800017d2 <uvmcopy+0xd4>
      panic("uvmcopy: pte should exist");
    8000178e:	00007517          	auipc	a0,0x7
    80001792:	a5250513          	addi	a0,a0,-1454 # 800081e0 <digits+0x190>
    80001796:	fffff097          	auipc	ra,0xfffff
    8000179a:	daa080e7          	jalr	-598(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    8000179e:	00007517          	auipc	a0,0x7
    800017a2:	a6250513          	addi	a0,a0,-1438 # 80008200 <digits+0x1b0>
    800017a6:	fffff097          	auipc	ra,0xfffff
    800017aa:	d9a080e7          	jalr	-614(ra) # 80000540 <panic>
    }
  }
  return 0;

 err:
 printf("uvmcopy: error\n");
    800017ae:	00007517          	auipc	a0,0x7
    800017b2:	a7250513          	addi	a0,a0,-1422 # 80008220 <digits+0x1d0>
    800017b6:	fffff097          	auipc	ra,0xfffff
    800017ba:	de6080e7          	jalr	-538(ra) # 8000059c <printf>
  uvmunmap(new, 0, i / PGSIZE, 1);
    800017be:	4685                	li	a3,1
    800017c0:	00c95613          	srli	a2,s2,0xc
    800017c4:	4581                	li	a1,0
    800017c6:	8556                	mv	a0,s5
    800017c8:	00000097          	auipc	ra,0x0
    800017cc:	c32080e7          	jalr	-974(ra) # 800013fa <uvmunmap>
  return -1;
    800017d0:	557d                	li	a0,-1
}
    800017d2:	70e2                	ld	ra,56(sp)
    800017d4:	7442                	ld	s0,48(sp)
    800017d6:	74a2                	ld	s1,40(sp)
    800017d8:	7902                	ld	s2,32(sp)
    800017da:	69e2                	ld	s3,24(sp)
    800017dc:	6a42                	ld	s4,16(sp)
    800017de:	6aa2                	ld	s5,8(sp)
    800017e0:	6b02                	ld	s6,0(sp)
    800017e2:	6121                	addi	sp,sp,64
    800017e4:	8082                	ret
  return 0;
    800017e6:	4501                	li	a0,0
}
    800017e8:	8082                	ret

00000000800017ea <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800017ea:	1141                	addi	sp,sp,-16
    800017ec:	e406                	sd	ra,8(sp)
    800017ee:	e022                	sd	s0,0(sp)
    800017f0:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800017f2:	4601                	li	a2,0
    800017f4:	00000097          	auipc	ra,0x0
    800017f8:	958080e7          	jalr	-1704(ra) # 8000114c <walk>
  if(pte == 0)
    800017fc:	c901                	beqz	a0,8000180c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800017fe:	611c                	ld	a5,0(a0)
    80001800:	9bbd                	andi	a5,a5,-17
    80001802:	e11c                	sd	a5,0(a0)
}
    80001804:	60a2                	ld	ra,8(sp)
    80001806:	6402                	ld	s0,0(sp)
    80001808:	0141                	addi	sp,sp,16
    8000180a:	8082                	ret
    panic("uvmclear");
    8000180c:	00007517          	auipc	a0,0x7
    80001810:	a2450513          	addi	a0,a0,-1500 # 80008230 <digits+0x1e0>
    80001814:	fffff097          	auipc	ra,0xfffff
    80001818:	d2c080e7          	jalr	-724(ra) # 80000540 <panic>

000000008000181c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000181c:	c6bd                	beqz	a3,8000188a <copyout+0x6e>
{
    8000181e:	715d                	addi	sp,sp,-80
    80001820:	e486                	sd	ra,72(sp)
    80001822:	e0a2                	sd	s0,64(sp)
    80001824:	fc26                	sd	s1,56(sp)
    80001826:	f84a                	sd	s2,48(sp)
    80001828:	f44e                	sd	s3,40(sp)
    8000182a:	f052                	sd	s4,32(sp)
    8000182c:	ec56                	sd	s5,24(sp)
    8000182e:	e85a                	sd	s6,16(sp)
    80001830:	e45e                	sd	s7,8(sp)
    80001832:	e062                	sd	s8,0(sp)
    80001834:	0880                	addi	s0,sp,80
    80001836:	8b2a                	mv	s6,a0
    80001838:	8c2e                	mv	s8,a1
    8000183a:	8a32                	mv	s4,a2
    8000183c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000183e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001840:	6a85                	lui	s5,0x1
    80001842:	a015                	j	80001866 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001844:	9562                	add	a0,a0,s8
    80001846:	0004861b          	sext.w	a2,s1
    8000184a:	85d2                	mv	a1,s4
    8000184c:	41250533          	sub	a0,a0,s2
    80001850:	fffff097          	auipc	ra,0xfffff
    80001854:	674080e7          	jalr	1652(ra) # 80000ec4 <memmove>

    len -= n;
    80001858:	409989b3          	sub	s3,s3,s1
    src += n;
    8000185c:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000185e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001862:	02098263          	beqz	s3,80001886 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001866:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000186a:	85ca                	mv	a1,s2
    8000186c:	855a                	mv	a0,s6
    8000186e:	00000097          	auipc	ra,0x0
    80001872:	984080e7          	jalr	-1660(ra) # 800011f2 <walkaddr>
    if(pa0 == 0)
    80001876:	cd01                	beqz	a0,8000188e <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001878:	418904b3          	sub	s1,s2,s8
    8000187c:	94d6                	add	s1,s1,s5
    8000187e:	fc99f3e3          	bgeu	s3,s1,80001844 <copyout+0x28>
    80001882:	84ce                	mv	s1,s3
    80001884:	b7c1                	j	80001844 <copyout+0x28>
  }
  return 0;
    80001886:	4501                	li	a0,0
    80001888:	a021                	j	80001890 <copyout+0x74>
    8000188a:	4501                	li	a0,0
}
    8000188c:	8082                	ret
      return -1;
    8000188e:	557d                	li	a0,-1
}
    80001890:	60a6                	ld	ra,72(sp)
    80001892:	6406                	ld	s0,64(sp)
    80001894:	74e2                	ld	s1,56(sp)
    80001896:	7942                	ld	s2,48(sp)
    80001898:	79a2                	ld	s3,40(sp)
    8000189a:	7a02                	ld	s4,32(sp)
    8000189c:	6ae2                	ld	s5,24(sp)
    8000189e:	6b42                	ld	s6,16(sp)
    800018a0:	6ba2                	ld	s7,8(sp)
    800018a2:	6c02                	ld	s8,0(sp)
    800018a4:	6161                	addi	sp,sp,80
    800018a6:	8082                	ret

00000000800018a8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018a8:	caa5                	beqz	a3,80001918 <copyin+0x70>
{
    800018aa:	715d                	addi	sp,sp,-80
    800018ac:	e486                	sd	ra,72(sp)
    800018ae:	e0a2                	sd	s0,64(sp)
    800018b0:	fc26                	sd	s1,56(sp)
    800018b2:	f84a                	sd	s2,48(sp)
    800018b4:	f44e                	sd	s3,40(sp)
    800018b6:	f052                	sd	s4,32(sp)
    800018b8:	ec56                	sd	s5,24(sp)
    800018ba:	e85a                	sd	s6,16(sp)
    800018bc:	e45e                	sd	s7,8(sp)
    800018be:	e062                	sd	s8,0(sp)
    800018c0:	0880                	addi	s0,sp,80
    800018c2:	8b2a                	mv	s6,a0
    800018c4:	8a2e                	mv	s4,a1
    800018c6:	8c32                	mv	s8,a2
    800018c8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800018ca:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018cc:	6a85                	lui	s5,0x1
    800018ce:	a01d                	j	800018f4 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018d0:	018505b3          	add	a1,a0,s8
    800018d4:	0004861b          	sext.w	a2,s1
    800018d8:	412585b3          	sub	a1,a1,s2
    800018dc:	8552                	mv	a0,s4
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	5e6080e7          	jalr	1510(ra) # 80000ec4 <memmove>

    len -= n;
    800018e6:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018ea:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018ec:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018f0:	02098263          	beqz	s3,80001914 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018f4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018f8:	85ca                	mv	a1,s2
    800018fa:	855a                	mv	a0,s6
    800018fc:	00000097          	auipc	ra,0x0
    80001900:	8f6080e7          	jalr	-1802(ra) # 800011f2 <walkaddr>
    if(pa0 == 0)
    80001904:	cd01                	beqz	a0,8000191c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001906:	418904b3          	sub	s1,s2,s8
    8000190a:	94d6                	add	s1,s1,s5
    8000190c:	fc99f2e3          	bgeu	s3,s1,800018d0 <copyin+0x28>
    80001910:	84ce                	mv	s1,s3
    80001912:	bf7d                	j	800018d0 <copyin+0x28>
  }
  return 0;
    80001914:	4501                	li	a0,0
    80001916:	a021                	j	8000191e <copyin+0x76>
    80001918:	4501                	li	a0,0
}
    8000191a:	8082                	ret
      return -1;
    8000191c:	557d                	li	a0,-1
}
    8000191e:	60a6                	ld	ra,72(sp)
    80001920:	6406                	ld	s0,64(sp)
    80001922:	74e2                	ld	s1,56(sp)
    80001924:	7942                	ld	s2,48(sp)
    80001926:	79a2                	ld	s3,40(sp)
    80001928:	7a02                	ld	s4,32(sp)
    8000192a:	6ae2                	ld	s5,24(sp)
    8000192c:	6b42                	ld	s6,16(sp)
    8000192e:	6ba2                	ld	s7,8(sp)
    80001930:	6c02                	ld	s8,0(sp)
    80001932:	6161                	addi	sp,sp,80
    80001934:	8082                	ret

0000000080001936 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001936:	c2dd                	beqz	a3,800019dc <copyinstr+0xa6>
{
    80001938:	715d                	addi	sp,sp,-80
    8000193a:	e486                	sd	ra,72(sp)
    8000193c:	e0a2                	sd	s0,64(sp)
    8000193e:	fc26                	sd	s1,56(sp)
    80001940:	f84a                	sd	s2,48(sp)
    80001942:	f44e                	sd	s3,40(sp)
    80001944:	f052                	sd	s4,32(sp)
    80001946:	ec56                	sd	s5,24(sp)
    80001948:	e85a                	sd	s6,16(sp)
    8000194a:	e45e                	sd	s7,8(sp)
    8000194c:	0880                	addi	s0,sp,80
    8000194e:	8a2a                	mv	s4,a0
    80001950:	8b2e                	mv	s6,a1
    80001952:	8bb2                	mv	s7,a2
    80001954:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001956:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001958:	6985                	lui	s3,0x1
    8000195a:	a02d                	j	80001984 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000195c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001960:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001962:	37fd                	addiw	a5,a5,-1
    80001964:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001968:	60a6                	ld	ra,72(sp)
    8000196a:	6406                	ld	s0,64(sp)
    8000196c:	74e2                	ld	s1,56(sp)
    8000196e:	7942                	ld	s2,48(sp)
    80001970:	79a2                	ld	s3,40(sp)
    80001972:	7a02                	ld	s4,32(sp)
    80001974:	6ae2                	ld	s5,24(sp)
    80001976:	6b42                	ld	s6,16(sp)
    80001978:	6ba2                	ld	s7,8(sp)
    8000197a:	6161                	addi	sp,sp,80
    8000197c:	8082                	ret
    srcva = va0 + PGSIZE;
    8000197e:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001982:	c8a9                	beqz	s1,800019d4 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80001984:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001988:	85ca                	mv	a1,s2
    8000198a:	8552                	mv	a0,s4
    8000198c:	00000097          	auipc	ra,0x0
    80001990:	866080e7          	jalr	-1946(ra) # 800011f2 <walkaddr>
    if(pa0 == 0)
    80001994:	c131                	beqz	a0,800019d8 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001996:	417906b3          	sub	a3,s2,s7
    8000199a:	96ce                	add	a3,a3,s3
    8000199c:	00d4f363          	bgeu	s1,a3,800019a2 <copyinstr+0x6c>
    800019a0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800019a2:	955e                	add	a0,a0,s7
    800019a4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800019a8:	daf9                	beqz	a3,8000197e <copyinstr+0x48>
    800019aa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800019ac:	41650633          	sub	a2,a0,s6
    800019b0:	fff48593          	addi	a1,s1,-1
    800019b4:	95da                	add	a1,a1,s6
    while(n > 0){
    800019b6:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800019b8:	00f60733          	add	a4,a2,a5
    800019bc:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ff9d0b0>
    800019c0:	df51                	beqz	a4,8000195c <copyinstr+0x26>
        *dst = *p;
    800019c2:	00e78023          	sb	a4,0(a5)
      --max;
    800019c6:	40f584b3          	sub	s1,a1,a5
      dst++;
    800019ca:	0785                	addi	a5,a5,1
    while(n > 0){
    800019cc:	fed796e3          	bne	a5,a3,800019b8 <copyinstr+0x82>
      dst++;
    800019d0:	8b3e                	mv	s6,a5
    800019d2:	b775                	j	8000197e <copyinstr+0x48>
    800019d4:	4781                	li	a5,0
    800019d6:	b771                	j	80001962 <copyinstr+0x2c>
      return -1;
    800019d8:	557d                	li	a0,-1
    800019da:	b779                	j	80001968 <copyinstr+0x32>
  int got_null = 0;
    800019dc:	4781                	li	a5,0
  if(got_null){
    800019de:	37fd                	addiw	a5,a5,-1
    800019e0:	0007851b          	sext.w	a0,a5
}
    800019e4:	8082                	ret

00000000800019e6 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    800019e6:	715d                	addi	sp,sp,-80
    800019e8:	e486                	sd	ra,72(sp)
    800019ea:	e0a2                	sd	s0,64(sp)
    800019ec:	fc26                	sd	s1,56(sp)
    800019ee:	f84a                	sd	s2,48(sp)
    800019f0:	f44e                	sd	s3,40(sp)
    800019f2:	f052                	sd	s4,32(sp)
    800019f4:	ec56                	sd	s5,24(sp)
    800019f6:	e85a                	sd	s6,16(sp)
    800019f8:	e45e                	sd	s7,8(sp)
    800019fa:	e062                	sd	s8,0(sp)
    800019fc:	0880                	addi	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    800019fe:	8792                	mv	a5,tp
    int id = r_tp();
    80001a00:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001a02:	0004fa97          	auipc	s5,0x4f
    80001a06:	33ea8a93          	addi	s5,s5,830 # 80050d40 <cpus>
    80001a0a:	00779713          	slli	a4,a5,0x7
    80001a0e:	00ea86b3          	add	a3,s5,a4
    80001a12:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ff9d0b0>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001a16:	0721                	addi	a4,a4,8
    80001a18:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001a1a:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001a1c:	00007c17          	auipc	s8,0x7
    80001a20:	fdcc0c13          	addi	s8,s8,-36 # 800089f8 <sched_pointer>
    80001a24:	00000b97          	auipc	s7,0x0
    80001a28:	fc2b8b93          	addi	s7,s7,-62 # 800019e6 <rr_scheduler>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a2c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001a30:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a34:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001a38:	0004f497          	auipc	s1,0x4f
    80001a3c:	73848493          	addi	s1,s1,1848 # 80051170 <proc>
            if (p->state == RUNNABLE)
    80001a40:	498d                	li	s3,3
                p->state = RUNNING;
    80001a42:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001a44:	00055a17          	auipc	s4,0x55
    80001a48:	12ca0a13          	addi	s4,s4,300 # 80056b70 <tickslock>
    80001a4c:	a81d                	j	80001a82 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001a4e:	8526                	mv	a0,s1
    80001a50:	fffff097          	auipc	ra,0xfffff
    80001a54:	3d0080e7          	jalr	976(ra) # 80000e20 <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001a58:	60a6                	ld	ra,72(sp)
    80001a5a:	6406                	ld	s0,64(sp)
    80001a5c:	74e2                	ld	s1,56(sp)
    80001a5e:	7942                	ld	s2,48(sp)
    80001a60:	79a2                	ld	s3,40(sp)
    80001a62:	7a02                	ld	s4,32(sp)
    80001a64:	6ae2                	ld	s5,24(sp)
    80001a66:	6b42                	ld	s6,16(sp)
    80001a68:	6ba2                	ld	s7,8(sp)
    80001a6a:	6c02                	ld	s8,0(sp)
    80001a6c:	6161                	addi	sp,sp,80
    80001a6e:	8082                	ret
            release(&p->lock);
    80001a70:	8526                	mv	a0,s1
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	3ae080e7          	jalr	942(ra) # 80000e20 <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001a7a:	16848493          	addi	s1,s1,360
    80001a7e:	fb4487e3          	beq	s1,s4,80001a2c <rr_scheduler+0x46>
            acquire(&p->lock);
    80001a82:	8526                	mv	a0,s1
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	2e8080e7          	jalr	744(ra) # 80000d6c <acquire>
            if (p->state == RUNNABLE)
    80001a8c:	4c9c                	lw	a5,24(s1)
    80001a8e:	ff3791e3          	bne	a5,s3,80001a70 <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001a92:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001a96:	00993023          	sd	s1,0(s2) # 1000 <_entry-0x7ffff000>
                swtch(&c->context, &p->context);
    80001a9a:	06048593          	addi	a1,s1,96
    80001a9e:	8556                	mv	a0,s5
    80001aa0:	00001097          	auipc	ra,0x1
    80001aa4:	ff4080e7          	jalr	-12(ra) # 80002a94 <swtch>
                if (sched_pointer != &rr_scheduler)
    80001aa8:	000c3783          	ld	a5,0(s8)
    80001aac:	fb7791e3          	bne	a5,s7,80001a4e <rr_scheduler+0x68>
                c->proc = 0;
    80001ab0:	00093023          	sd	zero,0(s2)
    80001ab4:	bf75                	j	80001a70 <rr_scheduler+0x8a>

0000000080001ab6 <proc_mapstacks>:
{
    80001ab6:	7139                	addi	sp,sp,-64
    80001ab8:	fc06                	sd	ra,56(sp)
    80001aba:	f822                	sd	s0,48(sp)
    80001abc:	f426                	sd	s1,40(sp)
    80001abe:	f04a                	sd	s2,32(sp)
    80001ac0:	ec4e                	sd	s3,24(sp)
    80001ac2:	e852                	sd	s4,16(sp)
    80001ac4:	e456                	sd	s5,8(sp)
    80001ac6:	e05a                	sd	s6,0(sp)
    80001ac8:	0080                	addi	s0,sp,64
    80001aca:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001acc:	0004f497          	auipc	s1,0x4f
    80001ad0:	6a448493          	addi	s1,s1,1700 # 80051170 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001ad4:	8b26                	mv	s6,s1
    80001ad6:	00006a97          	auipc	s5,0x6
    80001ada:	53aa8a93          	addi	s5,s5,1338 # 80008010 <__func__.1+0x8>
    80001ade:	04000937          	lui	s2,0x4000
    80001ae2:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001ae4:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001ae6:	00055a17          	auipc	s4,0x55
    80001aea:	08aa0a13          	addi	s4,s4,138 # 80056b70 <tickslock>
        char *pa = kalloc();
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	0d0080e7          	jalr	208(ra) # 80000bbe <kalloc>
    80001af6:	862a                	mv	a2,a0
        if (pa == 0)
    80001af8:	c131                	beqz	a0,80001b3c <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001afa:	416485b3          	sub	a1,s1,s6
    80001afe:	858d                	srai	a1,a1,0x3
    80001b00:	000ab783          	ld	a5,0(s5)
    80001b04:	02f585b3          	mul	a1,a1,a5
    80001b08:	2585                	addiw	a1,a1,1
    80001b0a:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b0e:	4719                	li	a4,6
    80001b10:	6685                	lui	a3,0x1
    80001b12:	40b905b3          	sub	a1,s2,a1
    80001b16:	854e                	mv	a0,s3
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	7bc080e7          	jalr	1980(ra) # 800012d4 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b20:	16848493          	addi	s1,s1,360
    80001b24:	fd4495e3          	bne	s1,s4,80001aee <proc_mapstacks+0x38>
}
    80001b28:	70e2                	ld	ra,56(sp)
    80001b2a:	7442                	ld	s0,48(sp)
    80001b2c:	74a2                	ld	s1,40(sp)
    80001b2e:	7902                	ld	s2,32(sp)
    80001b30:	69e2                	ld	s3,24(sp)
    80001b32:	6a42                	ld	s4,16(sp)
    80001b34:	6aa2                	ld	s5,8(sp)
    80001b36:	6b02                	ld	s6,0(sp)
    80001b38:	6121                	addi	sp,sp,64
    80001b3a:	8082                	ret
            panic("kalloc");
    80001b3c:	00006517          	auipc	a0,0x6
    80001b40:	70450513          	addi	a0,a0,1796 # 80008240 <digits+0x1f0>
    80001b44:	fffff097          	auipc	ra,0xfffff
    80001b48:	9fc080e7          	jalr	-1540(ra) # 80000540 <panic>

0000000080001b4c <procinit>:
{
    80001b4c:	7139                	addi	sp,sp,-64
    80001b4e:	fc06                	sd	ra,56(sp)
    80001b50:	f822                	sd	s0,48(sp)
    80001b52:	f426                	sd	s1,40(sp)
    80001b54:	f04a                	sd	s2,32(sp)
    80001b56:	ec4e                	sd	s3,24(sp)
    80001b58:	e852                	sd	s4,16(sp)
    80001b5a:	e456                	sd	s5,8(sp)
    80001b5c:	e05a                	sd	s6,0(sp)
    80001b5e:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001b60:	00006597          	auipc	a1,0x6
    80001b64:	6e858593          	addi	a1,a1,1768 # 80008248 <digits+0x1f8>
    80001b68:	0004f517          	auipc	a0,0x4f
    80001b6c:	5d850513          	addi	a0,a0,1496 # 80051140 <pid_lock>
    80001b70:	fffff097          	auipc	ra,0xfffff
    80001b74:	16c080e7          	jalr	364(ra) # 80000cdc <initlock>
    initlock(&wait_lock, "wait_lock");
    80001b78:	00006597          	auipc	a1,0x6
    80001b7c:	6d858593          	addi	a1,a1,1752 # 80008250 <digits+0x200>
    80001b80:	0004f517          	auipc	a0,0x4f
    80001b84:	5d850513          	addi	a0,a0,1496 # 80051158 <wait_lock>
    80001b88:	fffff097          	auipc	ra,0xfffff
    80001b8c:	154080e7          	jalr	340(ra) # 80000cdc <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b90:	0004f497          	auipc	s1,0x4f
    80001b94:	5e048493          	addi	s1,s1,1504 # 80051170 <proc>
        initlock(&p->lock, "proc");
    80001b98:	00006b17          	auipc	s6,0x6
    80001b9c:	6c8b0b13          	addi	s6,s6,1736 # 80008260 <digits+0x210>
        p->kstack = KSTACK((int)(p - proc));
    80001ba0:	8aa6                	mv	s5,s1
    80001ba2:	00006a17          	auipc	s4,0x6
    80001ba6:	46ea0a13          	addi	s4,s4,1134 # 80008010 <__func__.1+0x8>
    80001baa:	04000937          	lui	s2,0x4000
    80001bae:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001bb0:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001bb2:	00055997          	auipc	s3,0x55
    80001bb6:	fbe98993          	addi	s3,s3,-66 # 80056b70 <tickslock>
        initlock(&p->lock, "proc");
    80001bba:	85da                	mv	a1,s6
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	11e080e7          	jalr	286(ra) # 80000cdc <initlock>
        p->state = UNUSED;
    80001bc6:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001bca:	415487b3          	sub	a5,s1,s5
    80001bce:	878d                	srai	a5,a5,0x3
    80001bd0:	000a3703          	ld	a4,0(s4)
    80001bd4:	02e787b3          	mul	a5,a5,a4
    80001bd8:	2785                	addiw	a5,a5,1
    80001bda:	00d7979b          	slliw	a5,a5,0xd
    80001bde:	40f907b3          	sub	a5,s2,a5
    80001be2:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001be4:	16848493          	addi	s1,s1,360
    80001be8:	fd3499e3          	bne	s1,s3,80001bba <procinit+0x6e>
}
    80001bec:	70e2                	ld	ra,56(sp)
    80001bee:	7442                	ld	s0,48(sp)
    80001bf0:	74a2                	ld	s1,40(sp)
    80001bf2:	7902                	ld	s2,32(sp)
    80001bf4:	69e2                	ld	s3,24(sp)
    80001bf6:	6a42                	ld	s4,16(sp)
    80001bf8:	6aa2                	ld	s5,8(sp)
    80001bfa:	6b02                	ld	s6,0(sp)
    80001bfc:	6121                	addi	sp,sp,64
    80001bfe:	8082                	ret

0000000080001c00 <copy_array>:
{
    80001c00:	1141                	addi	sp,sp,-16
    80001c02:	e422                	sd	s0,8(sp)
    80001c04:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001c06:	02c05163          	blez	a2,80001c28 <copy_array+0x28>
    80001c0a:	87aa                	mv	a5,a0
    80001c0c:	0505                	addi	a0,a0,1
    80001c0e:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001c10:	1602                	slli	a2,a2,0x20
    80001c12:	9201                	srli	a2,a2,0x20
    80001c14:	00c506b3          	add	a3,a0,a2
        dst[i] = src[i];
    80001c18:	0007c703          	lbu	a4,0(a5)
    80001c1c:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001c20:	0785                	addi	a5,a5,1
    80001c22:	0585                	addi	a1,a1,1
    80001c24:	fed79ae3          	bne	a5,a3,80001c18 <copy_array+0x18>
}
    80001c28:	6422                	ld	s0,8(sp)
    80001c2a:	0141                	addi	sp,sp,16
    80001c2c:	8082                	ret

0000000080001c2e <cpuid>:
{
    80001c2e:	1141                	addi	sp,sp,-16
    80001c30:	e422                	sd	s0,8(sp)
    80001c32:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c34:	8512                	mv	a0,tp
}
    80001c36:	2501                	sext.w	a0,a0
    80001c38:	6422                	ld	s0,8(sp)
    80001c3a:	0141                	addi	sp,sp,16
    80001c3c:	8082                	ret

0000000080001c3e <mycpu>:
{
    80001c3e:	1141                	addi	sp,sp,-16
    80001c40:	e422                	sd	s0,8(sp)
    80001c42:	0800                	addi	s0,sp,16
    80001c44:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001c46:	2781                	sext.w	a5,a5
    80001c48:	079e                	slli	a5,a5,0x7
}
    80001c4a:	0004f517          	auipc	a0,0x4f
    80001c4e:	0f650513          	addi	a0,a0,246 # 80050d40 <cpus>
    80001c52:	953e                	add	a0,a0,a5
    80001c54:	6422                	ld	s0,8(sp)
    80001c56:	0141                	addi	sp,sp,16
    80001c58:	8082                	ret

0000000080001c5a <myproc>:
{
    80001c5a:	1101                	addi	sp,sp,-32
    80001c5c:	ec06                	sd	ra,24(sp)
    80001c5e:	e822                	sd	s0,16(sp)
    80001c60:	e426                	sd	s1,8(sp)
    80001c62:	1000                	addi	s0,sp,32
    push_off();
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	0bc080e7          	jalr	188(ra) # 80000d20 <push_off>
    80001c6c:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001c6e:	2781                	sext.w	a5,a5
    80001c70:	079e                	slli	a5,a5,0x7
    80001c72:	0004f717          	auipc	a4,0x4f
    80001c76:	0ce70713          	addi	a4,a4,206 # 80050d40 <cpus>
    80001c7a:	97ba                	add	a5,a5,a4
    80001c7c:	6384                	ld	s1,0(a5)
    pop_off();
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	142080e7          	jalr	322(ra) # 80000dc0 <pop_off>
}
    80001c86:	8526                	mv	a0,s1
    80001c88:	60e2                	ld	ra,24(sp)
    80001c8a:	6442                	ld	s0,16(sp)
    80001c8c:	64a2                	ld	s1,8(sp)
    80001c8e:	6105                	addi	sp,sp,32
    80001c90:	8082                	ret

0000000080001c92 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c92:	1141                	addi	sp,sp,-16
    80001c94:	e406                	sd	ra,8(sp)
    80001c96:	e022                	sd	s0,0(sp)
    80001c98:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001c9a:	00000097          	auipc	ra,0x0
    80001c9e:	fc0080e7          	jalr	-64(ra) # 80001c5a <myproc>
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	17e080e7          	jalr	382(ra) # 80000e20 <release>

    if (first)
    80001caa:	00007797          	auipc	a5,0x7
    80001cae:	d467a783          	lw	a5,-698(a5) # 800089f0 <first.1>
    80001cb2:	eb89                	bnez	a5,80001cc4 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001cb4:	00001097          	auipc	ra,0x1
    80001cb8:	e8a080e7          	jalr	-374(ra) # 80002b3e <usertrapret>
}
    80001cbc:	60a2                	ld	ra,8(sp)
    80001cbe:	6402                	ld	s0,0(sp)
    80001cc0:	0141                	addi	sp,sp,16
    80001cc2:	8082                	ret
        first = 0;
    80001cc4:	00007797          	auipc	a5,0x7
    80001cc8:	d207a623          	sw	zero,-724(a5) # 800089f0 <first.1>
        fsinit(ROOTDEV);
    80001ccc:	4505                	li	a0,1
    80001cce:	00002097          	auipc	ra,0x2
    80001cd2:	dc0080e7          	jalr	-576(ra) # 80003a8e <fsinit>
    80001cd6:	bff9                	j	80001cb4 <forkret+0x22>

0000000080001cd8 <allocpid>:
{
    80001cd8:	1101                	addi	sp,sp,-32
    80001cda:	ec06                	sd	ra,24(sp)
    80001cdc:	e822                	sd	s0,16(sp)
    80001cde:	e426                	sd	s1,8(sp)
    80001ce0:	e04a                	sd	s2,0(sp)
    80001ce2:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001ce4:	0004f917          	auipc	s2,0x4f
    80001ce8:	45c90913          	addi	s2,s2,1116 # 80051140 <pid_lock>
    80001cec:	854a                	mv	a0,s2
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	07e080e7          	jalr	126(ra) # 80000d6c <acquire>
    pid = nextpid;
    80001cf6:	00007797          	auipc	a5,0x7
    80001cfa:	d0a78793          	addi	a5,a5,-758 # 80008a00 <nextpid>
    80001cfe:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001d00:	0014871b          	addiw	a4,s1,1
    80001d04:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001d06:	854a                	mv	a0,s2
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	118080e7          	jalr	280(ra) # 80000e20 <release>
}
    80001d10:	8526                	mv	a0,s1
    80001d12:	60e2                	ld	ra,24(sp)
    80001d14:	6442                	ld	s0,16(sp)
    80001d16:	64a2                	ld	s1,8(sp)
    80001d18:	6902                	ld	s2,0(sp)
    80001d1a:	6105                	addi	sp,sp,32
    80001d1c:	8082                	ret

0000000080001d1e <proc_pagetable>:
{
    80001d1e:	1101                	addi	sp,sp,-32
    80001d20:	ec06                	sd	ra,24(sp)
    80001d22:	e822                	sd	s0,16(sp)
    80001d24:	e426                	sd	s1,8(sp)
    80001d26:	e04a                	sd	s2,0(sp)
    80001d28:	1000                	addi	s0,sp,32
    80001d2a:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	792080e7          	jalr	1938(ra) # 800014be <uvmcreate>
    80001d34:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001d36:	c121                	beqz	a0,80001d76 <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d38:	4729                	li	a4,10
    80001d3a:	00005697          	auipc	a3,0x5
    80001d3e:	2c668693          	addi	a3,a3,710 # 80007000 <_trampoline>
    80001d42:	6605                	lui	a2,0x1
    80001d44:	040005b7          	lui	a1,0x4000
    80001d48:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d4a:	05b2                	slli	a1,a1,0xc
    80001d4c:	fffff097          	auipc	ra,0xfffff
    80001d50:	4e8080e7          	jalr	1256(ra) # 80001234 <mappages>
    80001d54:	02054863          	bltz	a0,80001d84 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d58:	4719                	li	a4,6
    80001d5a:	05893683          	ld	a3,88(s2)
    80001d5e:	6605                	lui	a2,0x1
    80001d60:	020005b7          	lui	a1,0x2000
    80001d64:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d66:	05b6                	slli	a1,a1,0xd
    80001d68:	8526                	mv	a0,s1
    80001d6a:	fffff097          	auipc	ra,0xfffff
    80001d6e:	4ca080e7          	jalr	1226(ra) # 80001234 <mappages>
    80001d72:	02054163          	bltz	a0,80001d94 <proc_pagetable+0x76>
}
    80001d76:	8526                	mv	a0,s1
    80001d78:	60e2                	ld	ra,24(sp)
    80001d7a:	6442                	ld	s0,16(sp)
    80001d7c:	64a2                	ld	s1,8(sp)
    80001d7e:	6902                	ld	s2,0(sp)
    80001d80:	6105                	addi	sp,sp,32
    80001d82:	8082                	ret
        uvmfree(pagetable, 0);
    80001d84:	4581                	li	a1,0
    80001d86:	8526                	mv	a0,s1
    80001d88:	00000097          	auipc	ra,0x0
    80001d8c:	93c080e7          	jalr	-1732(ra) # 800016c4 <uvmfree>
        return 0;
    80001d90:	4481                	li	s1,0
    80001d92:	b7d5                	j	80001d76 <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d94:	4681                	li	a3,0
    80001d96:	4605                	li	a2,1
    80001d98:	040005b7          	lui	a1,0x4000
    80001d9c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d9e:	05b2                	slli	a1,a1,0xc
    80001da0:	8526                	mv	a0,s1
    80001da2:	fffff097          	auipc	ra,0xfffff
    80001da6:	658080e7          	jalr	1624(ra) # 800013fa <uvmunmap>
        uvmfree(pagetable, 0);
    80001daa:	4581                	li	a1,0
    80001dac:	8526                	mv	a0,s1
    80001dae:	00000097          	auipc	ra,0x0
    80001db2:	916080e7          	jalr	-1770(ra) # 800016c4 <uvmfree>
        return 0;
    80001db6:	4481                	li	s1,0
    80001db8:	bf7d                	j	80001d76 <proc_pagetable+0x58>

0000000080001dba <proc_freepagetable>:
{
    80001dba:	1101                	addi	sp,sp,-32
    80001dbc:	ec06                	sd	ra,24(sp)
    80001dbe:	e822                	sd	s0,16(sp)
    80001dc0:	e426                	sd	s1,8(sp)
    80001dc2:	e04a                	sd	s2,0(sp)
    80001dc4:	1000                	addi	s0,sp,32
    80001dc6:	84aa                	mv	s1,a0
    80001dc8:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dca:	4681                	li	a3,0
    80001dcc:	4605                	li	a2,1
    80001dce:	040005b7          	lui	a1,0x4000
    80001dd2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dd4:	05b2                	slli	a1,a1,0xc
    80001dd6:	fffff097          	auipc	ra,0xfffff
    80001dda:	624080e7          	jalr	1572(ra) # 800013fa <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001dde:	4681                	li	a3,0
    80001de0:	4605                	li	a2,1
    80001de2:	020005b7          	lui	a1,0x2000
    80001de6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001de8:	05b6                	slli	a1,a1,0xd
    80001dea:	8526                	mv	a0,s1
    80001dec:	fffff097          	auipc	ra,0xfffff
    80001df0:	60e080e7          	jalr	1550(ra) # 800013fa <uvmunmap>
    uvmfree(pagetable, sz);
    80001df4:	85ca                	mv	a1,s2
    80001df6:	8526                	mv	a0,s1
    80001df8:	00000097          	auipc	ra,0x0
    80001dfc:	8cc080e7          	jalr	-1844(ra) # 800016c4 <uvmfree>
}
    80001e00:	60e2                	ld	ra,24(sp)
    80001e02:	6442                	ld	s0,16(sp)
    80001e04:	64a2                	ld	s1,8(sp)
    80001e06:	6902                	ld	s2,0(sp)
    80001e08:	6105                	addi	sp,sp,32
    80001e0a:	8082                	ret

0000000080001e0c <freeproc>:
{
    80001e0c:	1101                	addi	sp,sp,-32
    80001e0e:	ec06                	sd	ra,24(sp)
    80001e10:	e822                	sd	s0,16(sp)
    80001e12:	e426                	sd	s1,8(sp)
    80001e14:	1000                	addi	s0,sp,32
    80001e16:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001e18:	6d28                	ld	a0,88(a0)
    80001e1a:	c509                	beqz	a0,80001e24 <freeproc+0x18>
        dec_ref((void *)p->trapframe);
    80001e1c:	fffff097          	auipc	ra,0xfffff
    80001e20:	e58080e7          	jalr	-424(ra) # 80000c74 <dec_ref>
    p->trapframe = 0;
    80001e24:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001e28:	68a8                	ld	a0,80(s1)
    80001e2a:	c511                	beqz	a0,80001e36 <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001e2c:	64ac                	ld	a1,72(s1)
    80001e2e:	00000097          	auipc	ra,0x0
    80001e32:	f8c080e7          	jalr	-116(ra) # 80001dba <proc_freepagetable>
    p->pagetable = 0;
    80001e36:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001e3a:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001e3e:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001e42:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001e46:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001e4a:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001e4e:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001e52:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001e56:	0004ac23          	sw	zero,24(s1)
}
    80001e5a:	60e2                	ld	ra,24(sp)
    80001e5c:	6442                	ld	s0,16(sp)
    80001e5e:	64a2                	ld	s1,8(sp)
    80001e60:	6105                	addi	sp,sp,32
    80001e62:	8082                	ret

0000000080001e64 <allocproc>:
{
    80001e64:	1101                	addi	sp,sp,-32
    80001e66:	ec06                	sd	ra,24(sp)
    80001e68:	e822                	sd	s0,16(sp)
    80001e6a:	e426                	sd	s1,8(sp)
    80001e6c:	e04a                	sd	s2,0(sp)
    80001e6e:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001e70:	0004f497          	auipc	s1,0x4f
    80001e74:	30048493          	addi	s1,s1,768 # 80051170 <proc>
    80001e78:	00055917          	auipc	s2,0x55
    80001e7c:	cf890913          	addi	s2,s2,-776 # 80056b70 <tickslock>
        acquire(&p->lock);
    80001e80:	8526                	mv	a0,s1
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	eea080e7          	jalr	-278(ra) # 80000d6c <acquire>
        if (p->state == UNUSED)
    80001e8a:	4c9c                	lw	a5,24(s1)
    80001e8c:	cf81                	beqz	a5,80001ea4 <allocproc+0x40>
            release(&p->lock);
    80001e8e:	8526                	mv	a0,s1
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	f90080e7          	jalr	-112(ra) # 80000e20 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001e98:	16848493          	addi	s1,s1,360
    80001e9c:	ff2492e3          	bne	s1,s2,80001e80 <allocproc+0x1c>
    return 0;
    80001ea0:	4481                	li	s1,0
    80001ea2:	a889                	j	80001ef4 <allocproc+0x90>
    p->pid = allocpid();
    80001ea4:	00000097          	auipc	ra,0x0
    80001ea8:	e34080e7          	jalr	-460(ra) # 80001cd8 <allocpid>
    80001eac:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001eae:	4785                	li	a5,1
    80001eb0:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001eb2:	fffff097          	auipc	ra,0xfffff
    80001eb6:	d0c080e7          	jalr	-756(ra) # 80000bbe <kalloc>
    80001eba:	892a                	mv	s2,a0
    80001ebc:	eca8                	sd	a0,88(s1)
    80001ebe:	c131                	beqz	a0,80001f02 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001ec0:	8526                	mv	a0,s1
    80001ec2:	00000097          	auipc	ra,0x0
    80001ec6:	e5c080e7          	jalr	-420(ra) # 80001d1e <proc_pagetable>
    80001eca:	892a                	mv	s2,a0
    80001ecc:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001ece:	c531                	beqz	a0,80001f1a <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001ed0:	07000613          	li	a2,112
    80001ed4:	4581                	li	a1,0
    80001ed6:	06048513          	addi	a0,s1,96
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f8e080e7          	jalr	-114(ra) # 80000e68 <memset>
    p->context.ra = (uint64)forkret;
    80001ee2:	00000797          	auipc	a5,0x0
    80001ee6:	db078793          	addi	a5,a5,-592 # 80001c92 <forkret>
    80001eea:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001eec:	60bc                	ld	a5,64(s1)
    80001eee:	6705                	lui	a4,0x1
    80001ef0:	97ba                	add	a5,a5,a4
    80001ef2:	f4bc                	sd	a5,104(s1)
}
    80001ef4:	8526                	mv	a0,s1
    80001ef6:	60e2                	ld	ra,24(sp)
    80001ef8:	6442                	ld	s0,16(sp)
    80001efa:	64a2                	ld	s1,8(sp)
    80001efc:	6902                	ld	s2,0(sp)
    80001efe:	6105                	addi	sp,sp,32
    80001f00:	8082                	ret
        freeproc(p);
    80001f02:	8526                	mv	a0,s1
    80001f04:	00000097          	auipc	ra,0x0
    80001f08:	f08080e7          	jalr	-248(ra) # 80001e0c <freeproc>
        release(&p->lock);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	f12080e7          	jalr	-238(ra) # 80000e20 <release>
        return 0;
    80001f16:	84ca                	mv	s1,s2
    80001f18:	bff1                	j	80001ef4 <allocproc+0x90>
        freeproc(p);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	00000097          	auipc	ra,0x0
    80001f20:	ef0080e7          	jalr	-272(ra) # 80001e0c <freeproc>
        release(&p->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	efa080e7          	jalr	-262(ra) # 80000e20 <release>
        return 0;
    80001f2e:	84ca                	mv	s1,s2
    80001f30:	b7d1                	j	80001ef4 <allocproc+0x90>

0000000080001f32 <userinit>:
{
    80001f32:	1101                	addi	sp,sp,-32
    80001f34:	ec06                	sd	ra,24(sp)
    80001f36:	e822                	sd	s0,16(sp)
    80001f38:	e426                	sd	s1,8(sp)
    80001f3a:	1000                	addi	s0,sp,32
    p = allocproc();
    80001f3c:	00000097          	auipc	ra,0x0
    80001f40:	f28080e7          	jalr	-216(ra) # 80001e64 <allocproc>
    80001f44:	84aa                	mv	s1,a0
    initproc = p;
    80001f46:	00007797          	auipc	a5,0x7
    80001f4a:	b8a7b123          	sd	a0,-1150(a5) # 80008ac8 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f4e:	03400613          	li	a2,52
    80001f52:	00007597          	auipc	a1,0x7
    80001f56:	abe58593          	addi	a1,a1,-1346 # 80008a10 <initcode>
    80001f5a:	6928                	ld	a0,80(a0)
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	590080e7          	jalr	1424(ra) # 800014ec <uvmfirst>
    p->sz = PGSIZE;
    80001f64:	6785                	lui	a5,0x1
    80001f66:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001f68:	6cb8                	ld	a4,88(s1)
    80001f6a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001f6e:	6cb8                	ld	a4,88(s1)
    80001f70:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f72:	4641                	li	a2,16
    80001f74:	00006597          	auipc	a1,0x6
    80001f78:	2f458593          	addi	a1,a1,756 # 80008268 <digits+0x218>
    80001f7c:	15848513          	addi	a0,s1,344
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	032080e7          	jalr	50(ra) # 80000fb2 <safestrcpy>
    p->cwd = namei("/");
    80001f88:	00006517          	auipc	a0,0x6
    80001f8c:	2f050513          	addi	a0,a0,752 # 80008278 <digits+0x228>
    80001f90:	00002097          	auipc	ra,0x2
    80001f94:	528080e7          	jalr	1320(ra) # 800044b8 <namei>
    80001f98:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001f9c:	478d                	li	a5,3
    80001f9e:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001fa0:	8526                	mv	a0,s1
    80001fa2:	fffff097          	auipc	ra,0xfffff
    80001fa6:	e7e080e7          	jalr	-386(ra) # 80000e20 <release>
}
    80001faa:	60e2                	ld	ra,24(sp)
    80001fac:	6442                	ld	s0,16(sp)
    80001fae:	64a2                	ld	s1,8(sp)
    80001fb0:	6105                	addi	sp,sp,32
    80001fb2:	8082                	ret

0000000080001fb4 <growproc>:
{
    80001fb4:	1101                	addi	sp,sp,-32
    80001fb6:	ec06                	sd	ra,24(sp)
    80001fb8:	e822                	sd	s0,16(sp)
    80001fba:	e426                	sd	s1,8(sp)
    80001fbc:	e04a                	sd	s2,0(sp)
    80001fbe:	1000                	addi	s0,sp,32
    80001fc0:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001fc2:	00000097          	auipc	ra,0x0
    80001fc6:	c98080e7          	jalr	-872(ra) # 80001c5a <myproc>
    80001fca:	84aa                	mv	s1,a0
    sz = p->sz;
    80001fcc:	652c                	ld	a1,72(a0)
    if (n > 0)
    80001fce:	01204c63          	bgtz	s2,80001fe6 <growproc+0x32>
    else if (n < 0)
    80001fd2:	02094663          	bltz	s2,80001ffe <growproc+0x4a>
    p->sz = sz;
    80001fd6:	e4ac                	sd	a1,72(s1)
    return 0;
    80001fd8:	4501                	li	a0,0
}
    80001fda:	60e2                	ld	ra,24(sp)
    80001fdc:	6442                	ld	s0,16(sp)
    80001fde:	64a2                	ld	s1,8(sp)
    80001fe0:	6902                	ld	s2,0(sp)
    80001fe2:	6105                	addi	sp,sp,32
    80001fe4:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001fe6:	4691                	li	a3,4
    80001fe8:	00b90633          	add	a2,s2,a1
    80001fec:	6928                	ld	a0,80(a0)
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	5b8080e7          	jalr	1464(ra) # 800015a6 <uvmalloc>
    80001ff6:	85aa                	mv	a1,a0
    80001ff8:	fd79                	bnez	a0,80001fd6 <growproc+0x22>
            return -1;
    80001ffa:	557d                	li	a0,-1
    80001ffc:	bff9                	j	80001fda <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ffe:	00b90633          	add	a2,s2,a1
    80002002:	6928                	ld	a0,80(a0)
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	55a080e7          	jalr	1370(ra) # 8000155e <uvmdealloc>
    8000200c:	85aa                	mv	a1,a0
    8000200e:	b7e1                	j	80001fd6 <growproc+0x22>

0000000080002010 <ps>:
{
    80002010:	715d                	addi	sp,sp,-80
    80002012:	e486                	sd	ra,72(sp)
    80002014:	e0a2                	sd	s0,64(sp)
    80002016:	fc26                	sd	s1,56(sp)
    80002018:	f84a                	sd	s2,48(sp)
    8000201a:	f44e                	sd	s3,40(sp)
    8000201c:	f052                	sd	s4,32(sp)
    8000201e:	ec56                	sd	s5,24(sp)
    80002020:	e85a                	sd	s6,16(sp)
    80002022:	e45e                	sd	s7,8(sp)
    80002024:	e062                	sd	s8,0(sp)
    80002026:	0880                	addi	s0,sp,80
    80002028:	84aa                	mv	s1,a0
    8000202a:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	c2e080e7          	jalr	-978(ra) # 80001c5a <myproc>
        return result;
    80002034:	4901                	li	s2,0
    if (count == 0)
    80002036:	0c0b8563          	beqz	s7,80002100 <ps+0xf0>
    void *result = (void *)myproc()->sz;
    8000203a:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    8000203e:	003b951b          	slliw	a0,s7,0x3
    80002042:	0175053b          	addw	a0,a0,s7
    80002046:	0025151b          	slliw	a0,a0,0x2
    8000204a:	00000097          	auipc	ra,0x0
    8000204e:	f6a080e7          	jalr	-150(ra) # 80001fb4 <growproc>
    80002052:	12054f63          	bltz	a0,80002190 <ps+0x180>
    struct user_proc loc_result[count];
    80002056:	003b9a13          	slli	s4,s7,0x3
    8000205a:	9a5e                	add	s4,s4,s7
    8000205c:	0a0a                	slli	s4,s4,0x2
    8000205e:	00fa0793          	addi	a5,s4,15
    80002062:	8391                	srli	a5,a5,0x4
    80002064:	0792                	slli	a5,a5,0x4
    80002066:	40f10133          	sub	sp,sp,a5
    8000206a:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    8000206c:	16800793          	li	a5,360
    80002070:	02f484b3          	mul	s1,s1,a5
    80002074:	0004f797          	auipc	a5,0x4f
    80002078:	0fc78793          	addi	a5,a5,252 # 80051170 <proc>
    8000207c:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    8000207e:	00055797          	auipc	a5,0x55
    80002082:	af278793          	addi	a5,a5,-1294 # 80056b70 <tickslock>
        return result;
    80002086:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    80002088:	06f4fc63          	bgeu	s1,a5,80002100 <ps+0xf0>
    acquire(&wait_lock);
    8000208c:	0004f517          	auipc	a0,0x4f
    80002090:	0cc50513          	addi	a0,a0,204 # 80051158 <wait_lock>
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	cd8080e7          	jalr	-808(ra) # 80000d6c <acquire>
        if (localCount == count)
    8000209c:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    800020a0:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    800020a2:	00055c17          	auipc	s8,0x55
    800020a6:	acec0c13          	addi	s8,s8,-1330 # 80056b70 <tickslock>
    800020aa:	a851                	j	8000213e <ps+0x12e>
            loc_result[localCount].state = UNUSED;
    800020ac:	00399793          	slli	a5,s3,0x3
    800020b0:	97ce                	add	a5,a5,s3
    800020b2:	078a                	slli	a5,a5,0x2
    800020b4:	97d6                	add	a5,a5,s5
    800020b6:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    800020ba:	8526                	mv	a0,s1
    800020bc:	fffff097          	auipc	ra,0xfffff
    800020c0:	d64080e7          	jalr	-668(ra) # 80000e20 <release>
    release(&wait_lock);
    800020c4:	0004f517          	auipc	a0,0x4f
    800020c8:	09450513          	addi	a0,a0,148 # 80051158 <wait_lock>
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	d54080e7          	jalr	-684(ra) # 80000e20 <release>
    if (localCount < count)
    800020d4:	0179f963          	bgeu	s3,s7,800020e6 <ps+0xd6>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    800020d8:	00399793          	slli	a5,s3,0x3
    800020dc:	97ce                	add	a5,a5,s3
    800020de:	078a                	slli	a5,a5,0x2
    800020e0:	97d6                	add	a5,a5,s5
    800020e2:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    800020e6:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    800020e8:	00000097          	auipc	ra,0x0
    800020ec:	b72080e7          	jalr	-1166(ra) # 80001c5a <myproc>
    800020f0:	86d2                	mv	a3,s4
    800020f2:	8656                	mv	a2,s5
    800020f4:	85da                	mv	a1,s6
    800020f6:	6928                	ld	a0,80(a0)
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	724080e7          	jalr	1828(ra) # 8000181c <copyout>
}
    80002100:	854a                	mv	a0,s2
    80002102:	fb040113          	addi	sp,s0,-80
    80002106:	60a6                	ld	ra,72(sp)
    80002108:	6406                	ld	s0,64(sp)
    8000210a:	74e2                	ld	s1,56(sp)
    8000210c:	7942                	ld	s2,48(sp)
    8000210e:	79a2                	ld	s3,40(sp)
    80002110:	7a02                	ld	s4,32(sp)
    80002112:	6ae2                	ld	s5,24(sp)
    80002114:	6b42                	ld	s6,16(sp)
    80002116:	6ba2                	ld	s7,8(sp)
    80002118:	6c02                	ld	s8,0(sp)
    8000211a:	6161                	addi	sp,sp,80
    8000211c:	8082                	ret
        release(&p->lock);
    8000211e:	8526                	mv	a0,s1
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	d00080e7          	jalr	-768(ra) # 80000e20 <release>
        localCount++;
    80002128:	2985                	addiw	s3,s3,1
    8000212a:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    8000212e:	16848493          	addi	s1,s1,360
    80002132:	f984f9e3          	bgeu	s1,s8,800020c4 <ps+0xb4>
        if (localCount == count)
    80002136:	02490913          	addi	s2,s2,36
    8000213a:	053b8d63          	beq	s7,s3,80002194 <ps+0x184>
        acquire(&p->lock);
    8000213e:	8526                	mv	a0,s1
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	c2c080e7          	jalr	-980(ra) # 80000d6c <acquire>
        if (p->state == UNUSED)
    80002148:	4c9c                	lw	a5,24(s1)
    8000214a:	d3ad                	beqz	a5,800020ac <ps+0x9c>
        loc_result[localCount].state = p->state;
    8000214c:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    80002150:	549c                	lw	a5,40(s1)
    80002152:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    80002156:	54dc                	lw	a5,44(s1)
    80002158:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    8000215c:	589c                	lw	a5,48(s1)
    8000215e:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    80002162:	4641                	li	a2,16
    80002164:	85ca                	mv	a1,s2
    80002166:	15848513          	addi	a0,s1,344
    8000216a:	00000097          	auipc	ra,0x0
    8000216e:	a96080e7          	jalr	-1386(ra) # 80001c00 <copy_array>
        if (p->parent != 0) // init
    80002172:	7c88                	ld	a0,56(s1)
    80002174:	d54d                	beqz	a0,8000211e <ps+0x10e>
            acquire(&p->parent->lock);
    80002176:	fffff097          	auipc	ra,0xfffff
    8000217a:	bf6080e7          	jalr	-1034(ra) # 80000d6c <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    8000217e:	7c88                	ld	a0,56(s1)
    80002180:	591c                	lw	a5,48(a0)
    80002182:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	c9a080e7          	jalr	-870(ra) # 80000e20 <release>
    8000218e:	bf41                	j	8000211e <ps+0x10e>
        return result;
    80002190:	4901                	li	s2,0
    80002192:	b7bd                	j	80002100 <ps+0xf0>
    release(&wait_lock);
    80002194:	0004f517          	auipc	a0,0x4f
    80002198:	fc450513          	addi	a0,a0,-60 # 80051158 <wait_lock>
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	c84080e7          	jalr	-892(ra) # 80000e20 <release>
    if (localCount < count)
    800021a4:	b789                	j	800020e6 <ps+0xd6>

00000000800021a6 <fork>:
{
    800021a6:	7139                	addi	sp,sp,-64
    800021a8:	fc06                	sd	ra,56(sp)
    800021aa:	f822                	sd	s0,48(sp)
    800021ac:	f426                	sd	s1,40(sp)
    800021ae:	f04a                	sd	s2,32(sp)
    800021b0:	ec4e                	sd	s3,24(sp)
    800021b2:	e852                	sd	s4,16(sp)
    800021b4:	e456                	sd	s5,8(sp)
    800021b6:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    800021b8:	00000097          	auipc	ra,0x0
    800021bc:	aa2080e7          	jalr	-1374(ra) # 80001c5a <myproc>
    800021c0:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    800021c2:	00000097          	auipc	ra,0x0
    800021c6:	ca2080e7          	jalr	-862(ra) # 80001e64 <allocproc>
    800021ca:	12050563          	beqz	a0,800022f4 <fork+0x14e>
    800021ce:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    800021d0:	048ab603          	ld	a2,72(s5)
    800021d4:	692c                	ld	a1,80(a0)
    800021d6:	050ab503          	ld	a0,80(s5)
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	524080e7          	jalr	1316(ra) # 800016fe <uvmcopy>
    800021e2:	04054863          	bltz	a0,80002232 <fork+0x8c>
    np->sz = p->sz;
    800021e6:	048ab783          	ld	a5,72(s5)
    800021ea:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    800021ee:	058ab683          	ld	a3,88(s5)
    800021f2:	87b6                	mv	a5,a3
    800021f4:	058a3703          	ld	a4,88(s4)
    800021f8:	12068693          	addi	a3,a3,288
    800021fc:	0007b803          	ld	a6,0(a5)
    80002200:	6788                	ld	a0,8(a5)
    80002202:	6b8c                	ld	a1,16(a5)
    80002204:	6f90                	ld	a2,24(a5)
    80002206:	01073023          	sd	a6,0(a4)
    8000220a:	e708                	sd	a0,8(a4)
    8000220c:	eb0c                	sd	a1,16(a4)
    8000220e:	ef10                	sd	a2,24(a4)
    80002210:	02078793          	addi	a5,a5,32
    80002214:	02070713          	addi	a4,a4,32
    80002218:	fed792e3          	bne	a5,a3,800021fc <fork+0x56>
    np->trapframe->a0 = 0;
    8000221c:	058a3783          	ld	a5,88(s4)
    80002220:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    80002224:	0d0a8493          	addi	s1,s5,208
    80002228:	0d0a0913          	addi	s2,s4,208
    8000222c:	150a8993          	addi	s3,s5,336
    80002230:	a00d                	j	80002252 <fork+0xac>
        freeproc(np);
    80002232:	8552                	mv	a0,s4
    80002234:	00000097          	auipc	ra,0x0
    80002238:	bd8080e7          	jalr	-1064(ra) # 80001e0c <freeproc>
        release(&np->lock);
    8000223c:	8552                	mv	a0,s4
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	be2080e7          	jalr	-1054(ra) # 80000e20 <release>
        return -1;
    80002246:	54fd                	li	s1,-1
    80002248:	a861                	j	800022e0 <fork+0x13a>
    for (i = 0; i < NOFILE; i++)
    8000224a:	04a1                	addi	s1,s1,8
    8000224c:	0921                	addi	s2,s2,8
    8000224e:	01348b63          	beq	s1,s3,80002264 <fork+0xbe>
        if (p->ofile[i])
    80002252:	6088                	ld	a0,0(s1)
    80002254:	d97d                	beqz	a0,8000224a <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    80002256:	00003097          	auipc	ra,0x3
    8000225a:	8f8080e7          	jalr	-1800(ra) # 80004b4e <filedup>
    8000225e:	00a93023          	sd	a0,0(s2)
    80002262:	b7e5                	j	8000224a <fork+0xa4>
    np->cwd = idup(p->cwd);
    80002264:	150ab503          	ld	a0,336(s5)
    80002268:	00002097          	auipc	ra,0x2
    8000226c:	a66080e7          	jalr	-1434(ra) # 80003cce <idup>
    80002270:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80002274:	4641                	li	a2,16
    80002276:	158a8593          	addi	a1,s5,344
    8000227a:	158a0513          	addi	a0,s4,344
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	d34080e7          	jalr	-716(ra) # 80000fb2 <safestrcpy>
    pid = np->pid;
    80002286:	030a2483          	lw	s1,48(s4)
    release(&np->lock);
    8000228a:	8552                	mv	a0,s4
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	b94080e7          	jalr	-1132(ra) # 80000e20 <release>
    acquire(&wait_lock);
    80002294:	0004f917          	auipc	s2,0x4f
    80002298:	ec490913          	addi	s2,s2,-316 # 80051158 <wait_lock>
    8000229c:	854a                	mv	a0,s2
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	ace080e7          	jalr	-1330(ra) # 80000d6c <acquire>
    np->parent = p;
    800022a6:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    800022aa:	854a                	mv	a0,s2
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	b74080e7          	jalr	-1164(ra) # 80000e20 <release>
    acquire(&np->lock);
    800022b4:	8552                	mv	a0,s4
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	ab6080e7          	jalr	-1354(ra) # 80000d6c <acquire>
    np->state = RUNNABLE;
    800022be:	478d                	li	a5,3
    800022c0:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    800022c4:	8552                	mv	a0,s4
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	b5a080e7          	jalr	-1190(ra) # 80000e20 <release>
    printf("forked %d\n", pid);
    800022ce:	85a6                	mv	a1,s1
    800022d0:	00006517          	auipc	a0,0x6
    800022d4:	fb050513          	addi	a0,a0,-80 # 80008280 <digits+0x230>
    800022d8:	ffffe097          	auipc	ra,0xffffe
    800022dc:	2c4080e7          	jalr	708(ra) # 8000059c <printf>
}
    800022e0:	8526                	mv	a0,s1
    800022e2:	70e2                	ld	ra,56(sp)
    800022e4:	7442                	ld	s0,48(sp)
    800022e6:	74a2                	ld	s1,40(sp)
    800022e8:	7902                	ld	s2,32(sp)
    800022ea:	69e2                	ld	s3,24(sp)
    800022ec:	6a42                	ld	s4,16(sp)
    800022ee:	6aa2                	ld	s5,8(sp)
    800022f0:	6121                	addi	sp,sp,64
    800022f2:	8082                	ret
        return -1;
    800022f4:	54fd                	li	s1,-1
    800022f6:	b7ed                	j	800022e0 <fork+0x13a>

00000000800022f8 <scheduler>:
{
    800022f8:	1101                	addi	sp,sp,-32
    800022fa:	ec06                	sd	ra,24(sp)
    800022fc:	e822                	sd	s0,16(sp)
    800022fe:	e426                	sd	s1,8(sp)
    80002300:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002302:	00006497          	auipc	s1,0x6
    80002306:	6f648493          	addi	s1,s1,1782 # 800089f8 <sched_pointer>
    8000230a:	609c                	ld	a5,0(s1)
    8000230c:	9782                	jalr	a5
    while (1)
    8000230e:	bff5                	j	8000230a <scheduler+0x12>

0000000080002310 <sched>:
{
    80002310:	7179                	addi	sp,sp,-48
    80002312:	f406                	sd	ra,40(sp)
    80002314:	f022                	sd	s0,32(sp)
    80002316:	ec26                	sd	s1,24(sp)
    80002318:	e84a                	sd	s2,16(sp)
    8000231a:	e44e                	sd	s3,8(sp)
    8000231c:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    8000231e:	00000097          	auipc	ra,0x0
    80002322:	93c080e7          	jalr	-1732(ra) # 80001c5a <myproc>
    80002326:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	9ca080e7          	jalr	-1590(ra) # 80000cf2 <holding>
    80002330:	c53d                	beqz	a0,8000239e <sched+0x8e>
    80002332:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    80002334:	2781                	sext.w	a5,a5
    80002336:	079e                	slli	a5,a5,0x7
    80002338:	0004f717          	auipc	a4,0x4f
    8000233c:	a0870713          	addi	a4,a4,-1528 # 80050d40 <cpus>
    80002340:	97ba                	add	a5,a5,a4
    80002342:	5fb8                	lw	a4,120(a5)
    80002344:	4785                	li	a5,1
    80002346:	06f71463          	bne	a4,a5,800023ae <sched+0x9e>
    if (p->state == RUNNING)
    8000234a:	4c98                	lw	a4,24(s1)
    8000234c:	4791                	li	a5,4
    8000234e:	06f70863          	beq	a4,a5,800023be <sched+0xae>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002352:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002356:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002358:	ebbd                	bnez	a5,800023ce <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000235a:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    8000235c:	0004f917          	auipc	s2,0x4f
    80002360:	9e490913          	addi	s2,s2,-1564 # 80050d40 <cpus>
    80002364:	2781                	sext.w	a5,a5
    80002366:	079e                	slli	a5,a5,0x7
    80002368:	97ca                	add	a5,a5,s2
    8000236a:	07c7a983          	lw	s3,124(a5)
    8000236e:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    80002370:	2581                	sext.w	a1,a1
    80002372:	059e                	slli	a1,a1,0x7
    80002374:	05a1                	addi	a1,a1,8
    80002376:	95ca                	add	a1,a1,s2
    80002378:	06048513          	addi	a0,s1,96
    8000237c:	00000097          	auipc	ra,0x0
    80002380:	718080e7          	jalr	1816(ra) # 80002a94 <swtch>
    80002384:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    80002386:	2781                	sext.w	a5,a5
    80002388:	079e                	slli	a5,a5,0x7
    8000238a:	993e                	add	s2,s2,a5
    8000238c:	07392e23          	sw	s3,124(s2)
}
    80002390:	70a2                	ld	ra,40(sp)
    80002392:	7402                	ld	s0,32(sp)
    80002394:	64e2                	ld	s1,24(sp)
    80002396:	6942                	ld	s2,16(sp)
    80002398:	69a2                	ld	s3,8(sp)
    8000239a:	6145                	addi	sp,sp,48
    8000239c:	8082                	ret
        panic("sched p->lock");
    8000239e:	00006517          	auipc	a0,0x6
    800023a2:	ef250513          	addi	a0,a0,-270 # 80008290 <digits+0x240>
    800023a6:	ffffe097          	auipc	ra,0xffffe
    800023aa:	19a080e7          	jalr	410(ra) # 80000540 <panic>
        panic("sched locks");
    800023ae:	00006517          	auipc	a0,0x6
    800023b2:	ef250513          	addi	a0,a0,-270 # 800082a0 <digits+0x250>
    800023b6:	ffffe097          	auipc	ra,0xffffe
    800023ba:	18a080e7          	jalr	394(ra) # 80000540 <panic>
        panic("sched running");
    800023be:	00006517          	auipc	a0,0x6
    800023c2:	ef250513          	addi	a0,a0,-270 # 800082b0 <digits+0x260>
    800023c6:	ffffe097          	auipc	ra,0xffffe
    800023ca:	17a080e7          	jalr	378(ra) # 80000540 <panic>
        panic("sched interruptible");
    800023ce:	00006517          	auipc	a0,0x6
    800023d2:	ef250513          	addi	a0,a0,-270 # 800082c0 <digits+0x270>
    800023d6:	ffffe097          	auipc	ra,0xffffe
    800023da:	16a080e7          	jalr	362(ra) # 80000540 <panic>

00000000800023de <yield>:
{
    800023de:	1101                	addi	sp,sp,-32
    800023e0:	ec06                	sd	ra,24(sp)
    800023e2:	e822                	sd	s0,16(sp)
    800023e4:	e426                	sd	s1,8(sp)
    800023e6:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    800023e8:	00000097          	auipc	ra,0x0
    800023ec:	872080e7          	jalr	-1934(ra) # 80001c5a <myproc>
    800023f0:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800023f2:	fffff097          	auipc	ra,0xfffff
    800023f6:	97a080e7          	jalr	-1670(ra) # 80000d6c <acquire>
    p->state = RUNNABLE;
    800023fa:	478d                	li	a5,3
    800023fc:	cc9c                	sw	a5,24(s1)
    sched();
    800023fe:	00000097          	auipc	ra,0x0
    80002402:	f12080e7          	jalr	-238(ra) # 80002310 <sched>
    release(&p->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	a18080e7          	jalr	-1512(ra) # 80000e20 <release>
}
    80002410:	60e2                	ld	ra,24(sp)
    80002412:	6442                	ld	s0,16(sp)
    80002414:	64a2                	ld	s1,8(sp)
    80002416:	6105                	addi	sp,sp,32
    80002418:	8082                	ret

000000008000241a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000241a:	7179                	addi	sp,sp,-48
    8000241c:	f406                	sd	ra,40(sp)
    8000241e:	f022                	sd	s0,32(sp)
    80002420:	ec26                	sd	s1,24(sp)
    80002422:	e84a                	sd	s2,16(sp)
    80002424:	e44e                	sd	s3,8(sp)
    80002426:	1800                	addi	s0,sp,48
    80002428:	89aa                	mv	s3,a0
    8000242a:	892e                	mv	s2,a1
    struct proc *p = myproc();
    8000242c:	00000097          	auipc	ra,0x0
    80002430:	82e080e7          	jalr	-2002(ra) # 80001c5a <myproc>
    80002434:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	936080e7          	jalr	-1738(ra) # 80000d6c <acquire>
    release(lk);
    8000243e:	854a                	mv	a0,s2
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	9e0080e7          	jalr	-1568(ra) # 80000e20 <release>

    // Go to sleep.
    p->chan = chan;
    80002448:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    8000244c:	4789                	li	a5,2
    8000244e:	cc9c                	sw	a5,24(s1)

    sched();
    80002450:	00000097          	auipc	ra,0x0
    80002454:	ec0080e7          	jalr	-320(ra) # 80002310 <sched>

    // Tidy up.
    p->chan = 0;
    80002458:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    8000245c:	8526                	mv	a0,s1
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	9c2080e7          	jalr	-1598(ra) # 80000e20 <release>
    acquire(lk);
    80002466:	854a                	mv	a0,s2
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	904080e7          	jalr	-1788(ra) # 80000d6c <acquire>
}
    80002470:	70a2                	ld	ra,40(sp)
    80002472:	7402                	ld	s0,32(sp)
    80002474:	64e2                	ld	s1,24(sp)
    80002476:	6942                	ld	s2,16(sp)
    80002478:	69a2                	ld	s3,8(sp)
    8000247a:	6145                	addi	sp,sp,48
    8000247c:	8082                	ret

000000008000247e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000247e:	7139                	addi	sp,sp,-64
    80002480:	fc06                	sd	ra,56(sp)
    80002482:	f822                	sd	s0,48(sp)
    80002484:	f426                	sd	s1,40(sp)
    80002486:	f04a                	sd	s2,32(sp)
    80002488:	ec4e                	sd	s3,24(sp)
    8000248a:	e852                	sd	s4,16(sp)
    8000248c:	e456                	sd	s5,8(sp)
    8000248e:	0080                	addi	s0,sp,64
    80002490:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002492:	0004f497          	auipc	s1,0x4f
    80002496:	cde48493          	addi	s1,s1,-802 # 80051170 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    8000249a:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    8000249c:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    8000249e:	00054917          	auipc	s2,0x54
    800024a2:	6d290913          	addi	s2,s2,1746 # 80056b70 <tickslock>
    800024a6:	a811                	j	800024ba <wakeup+0x3c>
            }
            release(&p->lock);
    800024a8:	8526                	mv	a0,s1
    800024aa:	fffff097          	auipc	ra,0xfffff
    800024ae:	976080e7          	jalr	-1674(ra) # 80000e20 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800024b2:	16848493          	addi	s1,s1,360
    800024b6:	03248663          	beq	s1,s2,800024e2 <wakeup+0x64>
        if (p != myproc())
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	7a0080e7          	jalr	1952(ra) # 80001c5a <myproc>
    800024c2:	fea488e3          	beq	s1,a0,800024b2 <wakeup+0x34>
            acquire(&p->lock);
    800024c6:	8526                	mv	a0,s1
    800024c8:	fffff097          	auipc	ra,0xfffff
    800024cc:	8a4080e7          	jalr	-1884(ra) # 80000d6c <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    800024d0:	4c9c                	lw	a5,24(s1)
    800024d2:	fd379be3          	bne	a5,s3,800024a8 <wakeup+0x2a>
    800024d6:	709c                	ld	a5,32(s1)
    800024d8:	fd4798e3          	bne	a5,s4,800024a8 <wakeup+0x2a>
                p->state = RUNNABLE;
    800024dc:	0154ac23          	sw	s5,24(s1)
    800024e0:	b7e1                	j	800024a8 <wakeup+0x2a>
        }
    }
}
    800024e2:	70e2                	ld	ra,56(sp)
    800024e4:	7442                	ld	s0,48(sp)
    800024e6:	74a2                	ld	s1,40(sp)
    800024e8:	7902                	ld	s2,32(sp)
    800024ea:	69e2                	ld	s3,24(sp)
    800024ec:	6a42                	ld	s4,16(sp)
    800024ee:	6aa2                	ld	s5,8(sp)
    800024f0:	6121                	addi	sp,sp,64
    800024f2:	8082                	ret

00000000800024f4 <reparent>:
{
    800024f4:	7179                	addi	sp,sp,-48
    800024f6:	f406                	sd	ra,40(sp)
    800024f8:	f022                	sd	s0,32(sp)
    800024fa:	ec26                	sd	s1,24(sp)
    800024fc:	e84a                	sd	s2,16(sp)
    800024fe:	e44e                	sd	s3,8(sp)
    80002500:	e052                	sd	s4,0(sp)
    80002502:	1800                	addi	s0,sp,48
    80002504:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002506:	0004f497          	auipc	s1,0x4f
    8000250a:	c6a48493          	addi	s1,s1,-918 # 80051170 <proc>
            pp->parent = initproc;
    8000250e:	00006a17          	auipc	s4,0x6
    80002512:	5baa0a13          	addi	s4,s4,1466 # 80008ac8 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002516:	00054997          	auipc	s3,0x54
    8000251a:	65a98993          	addi	s3,s3,1626 # 80056b70 <tickslock>
    8000251e:	a029                	j	80002528 <reparent+0x34>
    80002520:	16848493          	addi	s1,s1,360
    80002524:	01348d63          	beq	s1,s3,8000253e <reparent+0x4a>
        if (pp->parent == p)
    80002528:	7c9c                	ld	a5,56(s1)
    8000252a:	ff279be3          	bne	a5,s2,80002520 <reparent+0x2c>
            pp->parent = initproc;
    8000252e:	000a3503          	ld	a0,0(s4)
    80002532:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    80002534:	00000097          	auipc	ra,0x0
    80002538:	f4a080e7          	jalr	-182(ra) # 8000247e <wakeup>
    8000253c:	b7d5                	j	80002520 <reparent+0x2c>
}
    8000253e:	70a2                	ld	ra,40(sp)
    80002540:	7402                	ld	s0,32(sp)
    80002542:	64e2                	ld	s1,24(sp)
    80002544:	6942                	ld	s2,16(sp)
    80002546:	69a2                	ld	s3,8(sp)
    80002548:	6a02                	ld	s4,0(sp)
    8000254a:	6145                	addi	sp,sp,48
    8000254c:	8082                	ret

000000008000254e <exit>:
{
    8000254e:	7179                	addi	sp,sp,-48
    80002550:	f406                	sd	ra,40(sp)
    80002552:	f022                	sd	s0,32(sp)
    80002554:	ec26                	sd	s1,24(sp)
    80002556:	e84a                	sd	s2,16(sp)
    80002558:	e44e                	sd	s3,8(sp)
    8000255a:	e052                	sd	s4,0(sp)
    8000255c:	1800                	addi	s0,sp,48
    8000255e:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    80002560:	fffff097          	auipc	ra,0xfffff
    80002564:	6fa080e7          	jalr	1786(ra) # 80001c5a <myproc>
    80002568:	89aa                	mv	s3,a0
    if (p == initproc)
    8000256a:	00006797          	auipc	a5,0x6
    8000256e:	55e7b783          	ld	a5,1374(a5) # 80008ac8 <initproc>
    80002572:	0d050493          	addi	s1,a0,208
    80002576:	15050913          	addi	s2,a0,336
    8000257a:	02a79363          	bne	a5,a0,800025a0 <exit+0x52>
        panic("init exiting");
    8000257e:	00006517          	auipc	a0,0x6
    80002582:	d5a50513          	addi	a0,a0,-678 # 800082d8 <digits+0x288>
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	fba080e7          	jalr	-70(ra) # 80000540 <panic>
            fileclose(f);
    8000258e:	00002097          	auipc	ra,0x2
    80002592:	612080e7          	jalr	1554(ra) # 80004ba0 <fileclose>
            p->ofile[fd] = 0;
    80002596:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    8000259a:	04a1                	addi	s1,s1,8
    8000259c:	01248563          	beq	s1,s2,800025a6 <exit+0x58>
        if (p->ofile[fd])
    800025a0:	6088                	ld	a0,0(s1)
    800025a2:	f575                	bnez	a0,8000258e <exit+0x40>
    800025a4:	bfdd                	j	8000259a <exit+0x4c>
    begin_op();
    800025a6:	00002097          	auipc	ra,0x2
    800025aa:	132080e7          	jalr	306(ra) # 800046d8 <begin_op>
    iput(p->cwd);
    800025ae:	1509b503          	ld	a0,336(s3)
    800025b2:	00002097          	auipc	ra,0x2
    800025b6:	914080e7          	jalr	-1772(ra) # 80003ec6 <iput>
    end_op();
    800025ba:	00002097          	auipc	ra,0x2
    800025be:	19c080e7          	jalr	412(ra) # 80004756 <end_op>
    p->cwd = 0;
    800025c2:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    800025c6:	0004f497          	auipc	s1,0x4f
    800025ca:	b9248493          	addi	s1,s1,-1134 # 80051158 <wait_lock>
    800025ce:	8526                	mv	a0,s1
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	79c080e7          	jalr	1948(ra) # 80000d6c <acquire>
    reparent(p);
    800025d8:	854e                	mv	a0,s3
    800025da:	00000097          	auipc	ra,0x0
    800025de:	f1a080e7          	jalr	-230(ra) # 800024f4 <reparent>
    wakeup(p->parent);
    800025e2:	0389b503          	ld	a0,56(s3)
    800025e6:	00000097          	auipc	ra,0x0
    800025ea:	e98080e7          	jalr	-360(ra) # 8000247e <wakeup>
    acquire(&p->lock);
    800025ee:	854e                	mv	a0,s3
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	77c080e7          	jalr	1916(ra) # 80000d6c <acquire>
    p->xstate = status;
    800025f8:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    800025fc:	4795                	li	a5,5
    800025fe:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002602:	8526                	mv	a0,s1
    80002604:	fffff097          	auipc	ra,0xfffff
    80002608:	81c080e7          	jalr	-2020(ra) # 80000e20 <release>
    sched();
    8000260c:	00000097          	auipc	ra,0x0
    80002610:	d04080e7          	jalr	-764(ra) # 80002310 <sched>
    panic("zombie exit");
    80002614:	00006517          	auipc	a0,0x6
    80002618:	cd450513          	addi	a0,a0,-812 # 800082e8 <digits+0x298>
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	f24080e7          	jalr	-220(ra) # 80000540 <panic>

0000000080002624 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002624:	7179                	addi	sp,sp,-48
    80002626:	f406                	sd	ra,40(sp)
    80002628:	f022                	sd	s0,32(sp)
    8000262a:	ec26                	sd	s1,24(sp)
    8000262c:	e84a                	sd	s2,16(sp)
    8000262e:	e44e                	sd	s3,8(sp)
    80002630:	1800                	addi	s0,sp,48
    80002632:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002634:	0004f497          	auipc	s1,0x4f
    80002638:	b3c48493          	addi	s1,s1,-1220 # 80051170 <proc>
    8000263c:	00054997          	auipc	s3,0x54
    80002640:	53498993          	addi	s3,s3,1332 # 80056b70 <tickslock>
    {
        acquire(&p->lock);
    80002644:	8526                	mv	a0,s1
    80002646:	ffffe097          	auipc	ra,0xffffe
    8000264a:	726080e7          	jalr	1830(ra) # 80000d6c <acquire>
        if (p->pid == pid)
    8000264e:	589c                	lw	a5,48(s1)
    80002650:	01278d63          	beq	a5,s2,8000266a <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002654:	8526                	mv	a0,s1
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	7ca080e7          	jalr	1994(ra) # 80000e20 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000265e:	16848493          	addi	s1,s1,360
    80002662:	ff3491e3          	bne	s1,s3,80002644 <kill+0x20>
    }
    return -1;
    80002666:	557d                	li	a0,-1
    80002668:	a829                	j	80002682 <kill+0x5e>
            p->killed = 1;
    8000266a:	4785                	li	a5,1
    8000266c:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    8000266e:	4c98                	lw	a4,24(s1)
    80002670:	4789                	li	a5,2
    80002672:	00f70f63          	beq	a4,a5,80002690 <kill+0x6c>
            release(&p->lock);
    80002676:	8526                	mv	a0,s1
    80002678:	ffffe097          	auipc	ra,0xffffe
    8000267c:	7a8080e7          	jalr	1960(ra) # 80000e20 <release>
            return 0;
    80002680:	4501                	li	a0,0
}
    80002682:	70a2                	ld	ra,40(sp)
    80002684:	7402                	ld	s0,32(sp)
    80002686:	64e2                	ld	s1,24(sp)
    80002688:	6942                	ld	s2,16(sp)
    8000268a:	69a2                	ld	s3,8(sp)
    8000268c:	6145                	addi	sp,sp,48
    8000268e:	8082                	ret
                p->state = RUNNABLE;
    80002690:	478d                	li	a5,3
    80002692:	cc9c                	sw	a5,24(s1)
    80002694:	b7cd                	j	80002676 <kill+0x52>

0000000080002696 <setkilled>:

void setkilled(struct proc *p)
{
    80002696:	1101                	addi	sp,sp,-32
    80002698:	ec06                	sd	ra,24(sp)
    8000269a:	e822                	sd	s0,16(sp)
    8000269c:	e426                	sd	s1,8(sp)
    8000269e:	1000                	addi	s0,sp,32
    800026a0:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	6ca080e7          	jalr	1738(ra) # 80000d6c <acquire>
    p->killed = 1;
    800026aa:	4785                	li	a5,1
    800026ac:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    800026ae:	8526                	mv	a0,s1
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	770080e7          	jalr	1904(ra) # 80000e20 <release>
}
    800026b8:	60e2                	ld	ra,24(sp)
    800026ba:	6442                	ld	s0,16(sp)
    800026bc:	64a2                	ld	s1,8(sp)
    800026be:	6105                	addi	sp,sp,32
    800026c0:	8082                	ret

00000000800026c2 <killed>:

int killed(struct proc *p)
{
    800026c2:	1101                	addi	sp,sp,-32
    800026c4:	ec06                	sd	ra,24(sp)
    800026c6:	e822                	sd	s0,16(sp)
    800026c8:	e426                	sd	s1,8(sp)
    800026ca:	e04a                	sd	s2,0(sp)
    800026cc:	1000                	addi	s0,sp,32
    800026ce:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	69c080e7          	jalr	1692(ra) # 80000d6c <acquire>
    k = p->killed;
    800026d8:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    800026dc:	8526                	mv	a0,s1
    800026de:	ffffe097          	auipc	ra,0xffffe
    800026e2:	742080e7          	jalr	1858(ra) # 80000e20 <release>
    return k;
}
    800026e6:	854a                	mv	a0,s2
    800026e8:	60e2                	ld	ra,24(sp)
    800026ea:	6442                	ld	s0,16(sp)
    800026ec:	64a2                	ld	s1,8(sp)
    800026ee:	6902                	ld	s2,0(sp)
    800026f0:	6105                	addi	sp,sp,32
    800026f2:	8082                	ret

00000000800026f4 <wait>:
{
    800026f4:	715d                	addi	sp,sp,-80
    800026f6:	e486                	sd	ra,72(sp)
    800026f8:	e0a2                	sd	s0,64(sp)
    800026fa:	fc26                	sd	s1,56(sp)
    800026fc:	f84a                	sd	s2,48(sp)
    800026fe:	f44e                	sd	s3,40(sp)
    80002700:	f052                	sd	s4,32(sp)
    80002702:	ec56                	sd	s5,24(sp)
    80002704:	e85a                	sd	s6,16(sp)
    80002706:	e45e                	sd	s7,8(sp)
    80002708:	e062                	sd	s8,0(sp)
    8000270a:	0880                	addi	s0,sp,80
    8000270c:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    8000270e:	fffff097          	auipc	ra,0xfffff
    80002712:	54c080e7          	jalr	1356(ra) # 80001c5a <myproc>
    80002716:	892a                	mv	s2,a0
    acquire(&wait_lock);
    80002718:	0004f517          	auipc	a0,0x4f
    8000271c:	a4050513          	addi	a0,a0,-1472 # 80051158 <wait_lock>
    80002720:	ffffe097          	auipc	ra,0xffffe
    80002724:	64c080e7          	jalr	1612(ra) # 80000d6c <acquire>
        havekids = 0;
    80002728:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    8000272a:	4a15                	li	s4,5
                havekids = 1;
    8000272c:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000272e:	00054997          	auipc	s3,0x54
    80002732:	44298993          	addi	s3,s3,1090 # 80056b70 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002736:	0004fc17          	auipc	s8,0x4f
    8000273a:	a22c0c13          	addi	s8,s8,-1502 # 80051158 <wait_lock>
        havekids = 0;
    8000273e:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002740:	0004f497          	auipc	s1,0x4f
    80002744:	a3048493          	addi	s1,s1,-1488 # 80051170 <proc>
    80002748:	a0bd                	j	800027b6 <wait+0xc2>
                    pid = pp->pid;
    8000274a:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000274e:	000b0e63          	beqz	s6,8000276a <wait+0x76>
    80002752:	4691                	li	a3,4
    80002754:	02c48613          	addi	a2,s1,44
    80002758:	85da                	mv	a1,s6
    8000275a:	05093503          	ld	a0,80(s2)
    8000275e:	fffff097          	auipc	ra,0xfffff
    80002762:	0be080e7          	jalr	190(ra) # 8000181c <copyout>
    80002766:	02054563          	bltz	a0,80002790 <wait+0x9c>
                    freeproc(pp);
    8000276a:	8526                	mv	a0,s1
    8000276c:	fffff097          	auipc	ra,0xfffff
    80002770:	6a0080e7          	jalr	1696(ra) # 80001e0c <freeproc>
                    release(&pp->lock);
    80002774:	8526                	mv	a0,s1
    80002776:	ffffe097          	auipc	ra,0xffffe
    8000277a:	6aa080e7          	jalr	1706(ra) # 80000e20 <release>
                    release(&wait_lock);
    8000277e:	0004f517          	auipc	a0,0x4f
    80002782:	9da50513          	addi	a0,a0,-1574 # 80051158 <wait_lock>
    80002786:	ffffe097          	auipc	ra,0xffffe
    8000278a:	69a080e7          	jalr	1690(ra) # 80000e20 <release>
                    return pid;
    8000278e:	a0b5                	j	800027fa <wait+0x106>
                        release(&pp->lock);
    80002790:	8526                	mv	a0,s1
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	68e080e7          	jalr	1678(ra) # 80000e20 <release>
                        release(&wait_lock);
    8000279a:	0004f517          	auipc	a0,0x4f
    8000279e:	9be50513          	addi	a0,a0,-1602 # 80051158 <wait_lock>
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	67e080e7          	jalr	1662(ra) # 80000e20 <release>
                        return -1;
    800027aa:	59fd                	li	s3,-1
    800027ac:	a0b9                	j	800027fa <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800027ae:	16848493          	addi	s1,s1,360
    800027b2:	03348463          	beq	s1,s3,800027da <wait+0xe6>
            if (pp->parent == p)
    800027b6:	7c9c                	ld	a5,56(s1)
    800027b8:	ff279be3          	bne	a5,s2,800027ae <wait+0xba>
                acquire(&pp->lock);
    800027bc:	8526                	mv	a0,s1
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	5ae080e7          	jalr	1454(ra) # 80000d6c <acquire>
                if (pp->state == ZOMBIE)
    800027c6:	4c9c                	lw	a5,24(s1)
    800027c8:	f94781e3          	beq	a5,s4,8000274a <wait+0x56>
                release(&pp->lock);
    800027cc:	8526                	mv	a0,s1
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	652080e7          	jalr	1618(ra) # 80000e20 <release>
                havekids = 1;
    800027d6:	8756                	mv	a4,s5
    800027d8:	bfd9                	j	800027ae <wait+0xba>
        if (!havekids || killed(p))
    800027da:	c719                	beqz	a4,800027e8 <wait+0xf4>
    800027dc:	854a                	mv	a0,s2
    800027de:	00000097          	auipc	ra,0x0
    800027e2:	ee4080e7          	jalr	-284(ra) # 800026c2 <killed>
    800027e6:	c51d                	beqz	a0,80002814 <wait+0x120>
            release(&wait_lock);
    800027e8:	0004f517          	auipc	a0,0x4f
    800027ec:	97050513          	addi	a0,a0,-1680 # 80051158 <wait_lock>
    800027f0:	ffffe097          	auipc	ra,0xffffe
    800027f4:	630080e7          	jalr	1584(ra) # 80000e20 <release>
            return -1;
    800027f8:	59fd                	li	s3,-1
}
    800027fa:	854e                	mv	a0,s3
    800027fc:	60a6                	ld	ra,72(sp)
    800027fe:	6406                	ld	s0,64(sp)
    80002800:	74e2                	ld	s1,56(sp)
    80002802:	7942                	ld	s2,48(sp)
    80002804:	79a2                	ld	s3,40(sp)
    80002806:	7a02                	ld	s4,32(sp)
    80002808:	6ae2                	ld	s5,24(sp)
    8000280a:	6b42                	ld	s6,16(sp)
    8000280c:	6ba2                	ld	s7,8(sp)
    8000280e:	6c02                	ld	s8,0(sp)
    80002810:	6161                	addi	sp,sp,80
    80002812:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002814:	85e2                	mv	a1,s8
    80002816:	854a                	mv	a0,s2
    80002818:	00000097          	auipc	ra,0x0
    8000281c:	c02080e7          	jalr	-1022(ra) # 8000241a <sleep>
        havekids = 0;
    80002820:	bf39                	j	8000273e <wait+0x4a>

0000000080002822 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002822:	7179                	addi	sp,sp,-48
    80002824:	f406                	sd	ra,40(sp)
    80002826:	f022                	sd	s0,32(sp)
    80002828:	ec26                	sd	s1,24(sp)
    8000282a:	e84a                	sd	s2,16(sp)
    8000282c:	e44e                	sd	s3,8(sp)
    8000282e:	e052                	sd	s4,0(sp)
    80002830:	1800                	addi	s0,sp,48
    80002832:	84aa                	mv	s1,a0
    80002834:	892e                	mv	s2,a1
    80002836:	89b2                	mv	s3,a2
    80002838:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    8000283a:	fffff097          	auipc	ra,0xfffff
    8000283e:	420080e7          	jalr	1056(ra) # 80001c5a <myproc>
    if (user_dst)
    80002842:	c08d                	beqz	s1,80002864 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002844:	86d2                	mv	a3,s4
    80002846:	864e                	mv	a2,s3
    80002848:	85ca                	mv	a1,s2
    8000284a:	6928                	ld	a0,80(a0)
    8000284c:	fffff097          	auipc	ra,0xfffff
    80002850:	fd0080e7          	jalr	-48(ra) # 8000181c <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002854:	70a2                	ld	ra,40(sp)
    80002856:	7402                	ld	s0,32(sp)
    80002858:	64e2                	ld	s1,24(sp)
    8000285a:	6942                	ld	s2,16(sp)
    8000285c:	69a2                	ld	s3,8(sp)
    8000285e:	6a02                	ld	s4,0(sp)
    80002860:	6145                	addi	sp,sp,48
    80002862:	8082                	ret
        memmove((char *)dst, src, len);
    80002864:	000a061b          	sext.w	a2,s4
    80002868:	85ce                	mv	a1,s3
    8000286a:	854a                	mv	a0,s2
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	658080e7          	jalr	1624(ra) # 80000ec4 <memmove>
        return 0;
    80002874:	8526                	mv	a0,s1
    80002876:	bff9                	j	80002854 <either_copyout+0x32>

0000000080002878 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002878:	7179                	addi	sp,sp,-48
    8000287a:	f406                	sd	ra,40(sp)
    8000287c:	f022                	sd	s0,32(sp)
    8000287e:	ec26                	sd	s1,24(sp)
    80002880:	e84a                	sd	s2,16(sp)
    80002882:	e44e                	sd	s3,8(sp)
    80002884:	e052                	sd	s4,0(sp)
    80002886:	1800                	addi	s0,sp,48
    80002888:	892a                	mv	s2,a0
    8000288a:	84ae                	mv	s1,a1
    8000288c:	89b2                	mv	s3,a2
    8000288e:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002890:	fffff097          	auipc	ra,0xfffff
    80002894:	3ca080e7          	jalr	970(ra) # 80001c5a <myproc>
    if (user_src)
    80002898:	c08d                	beqz	s1,800028ba <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    8000289a:	86d2                	mv	a3,s4
    8000289c:	864e                	mv	a2,s3
    8000289e:	85ca                	mv	a1,s2
    800028a0:	6928                	ld	a0,80(a0)
    800028a2:	fffff097          	auipc	ra,0xfffff
    800028a6:	006080e7          	jalr	6(ra) # 800018a8 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    800028aa:	70a2                	ld	ra,40(sp)
    800028ac:	7402                	ld	s0,32(sp)
    800028ae:	64e2                	ld	s1,24(sp)
    800028b0:	6942                	ld	s2,16(sp)
    800028b2:	69a2                	ld	s3,8(sp)
    800028b4:	6a02                	ld	s4,0(sp)
    800028b6:	6145                	addi	sp,sp,48
    800028b8:	8082                	ret
        memmove(dst, (char *)src, len);
    800028ba:	000a061b          	sext.w	a2,s4
    800028be:	85ce                	mv	a1,s3
    800028c0:	854a                	mv	a0,s2
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	602080e7          	jalr	1538(ra) # 80000ec4 <memmove>
        return 0;
    800028ca:	8526                	mv	a0,s1
    800028cc:	bff9                	j	800028aa <either_copyin+0x32>

00000000800028ce <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800028ce:	715d                	addi	sp,sp,-80
    800028d0:	e486                	sd	ra,72(sp)
    800028d2:	e0a2                	sd	s0,64(sp)
    800028d4:	fc26                	sd	s1,56(sp)
    800028d6:	f84a                	sd	s2,48(sp)
    800028d8:	f44e                	sd	s3,40(sp)
    800028da:	f052                	sd	s4,32(sp)
    800028dc:	ec56                	sd	s5,24(sp)
    800028de:	e85a                	sd	s6,16(sp)
    800028e0:	e45e                	sd	s7,8(sp)
    800028e2:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    800028e4:	00006517          	auipc	a0,0x6
    800028e8:	bdc50513          	addi	a0,a0,-1060 # 800084c0 <states.0+0xb0>
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	cb0080e7          	jalr	-848(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800028f4:	0004f497          	auipc	s1,0x4f
    800028f8:	9d448493          	addi	s1,s1,-1580 # 800512c8 <proc+0x158>
    800028fc:	00054917          	auipc	s2,0x54
    80002900:	3cc90913          	addi	s2,s2,972 # 80056cc8 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002904:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002906:	00006997          	auipc	s3,0x6
    8000290a:	9f298993          	addi	s3,s3,-1550 # 800082f8 <digits+0x2a8>
        printf("%d <%s %s", p->pid, state, p->name);
    8000290e:	00006a97          	auipc	s5,0x6
    80002912:	9f2a8a93          	addi	s5,s5,-1550 # 80008300 <digits+0x2b0>
        printf("\n");
    80002916:	00006a17          	auipc	s4,0x6
    8000291a:	baaa0a13          	addi	s4,s4,-1110 # 800084c0 <states.0+0xb0>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000291e:	00006b97          	auipc	s7,0x6
    80002922:	af2b8b93          	addi	s7,s7,-1294 # 80008410 <states.0>
    80002926:	a00d                	j	80002948 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002928:	ed86a583          	lw	a1,-296(a3)
    8000292c:	8556                	mv	a0,s5
    8000292e:	ffffe097          	auipc	ra,0xffffe
    80002932:	c6e080e7          	jalr	-914(ra) # 8000059c <printf>
        printf("\n");
    80002936:	8552                	mv	a0,s4
    80002938:	ffffe097          	auipc	ra,0xffffe
    8000293c:	c64080e7          	jalr	-924(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002940:	16848493          	addi	s1,s1,360
    80002944:	03248263          	beq	s1,s2,80002968 <procdump+0x9a>
        if (p->state == UNUSED)
    80002948:	86a6                	mv	a3,s1
    8000294a:	ec04a783          	lw	a5,-320(s1)
    8000294e:	dbed                	beqz	a5,80002940 <procdump+0x72>
            state = "???";
    80002950:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002952:	fcfb6be3          	bltu	s6,a5,80002928 <procdump+0x5a>
    80002956:	02079713          	slli	a4,a5,0x20
    8000295a:	01d75793          	srli	a5,a4,0x1d
    8000295e:	97de                	add	a5,a5,s7
    80002960:	6390                	ld	a2,0(a5)
    80002962:	f279                	bnez	a2,80002928 <procdump+0x5a>
            state = "???";
    80002964:	864e                	mv	a2,s3
    80002966:	b7c9                	j	80002928 <procdump+0x5a>
    }
}
    80002968:	60a6                	ld	ra,72(sp)
    8000296a:	6406                	ld	s0,64(sp)
    8000296c:	74e2                	ld	s1,56(sp)
    8000296e:	7942                	ld	s2,48(sp)
    80002970:	79a2                	ld	s3,40(sp)
    80002972:	7a02                	ld	s4,32(sp)
    80002974:	6ae2                	ld	s5,24(sp)
    80002976:	6b42                	ld	s6,16(sp)
    80002978:	6ba2                	ld	s7,8(sp)
    8000297a:	6161                	addi	sp,sp,80
    8000297c:	8082                	ret

000000008000297e <schedls>:

void schedls()
{
    8000297e:	1141                	addi	sp,sp,-16
    80002980:	e406                	sd	ra,8(sp)
    80002982:	e022                	sd	s0,0(sp)
    80002984:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002986:	00006517          	auipc	a0,0x6
    8000298a:	98a50513          	addi	a0,a0,-1654 # 80008310 <digits+0x2c0>
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	c0e080e7          	jalr	-1010(ra) # 8000059c <printf>
    printf("====================================\n");
    80002996:	00006517          	auipc	a0,0x6
    8000299a:	9a250513          	addi	a0,a0,-1630 # 80008338 <digits+0x2e8>
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	bfe080e7          	jalr	-1026(ra) # 8000059c <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    800029a6:	00006717          	auipc	a4,0x6
    800029aa:	0b273703          	ld	a4,178(a4) # 80008a58 <available_schedulers+0x10>
    800029ae:	00006797          	auipc	a5,0x6
    800029b2:	04a7b783          	ld	a5,74(a5) # 800089f8 <sched_pointer>
    800029b6:	04f70663          	beq	a4,a5,80002a02 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    800029ba:	00006517          	auipc	a0,0x6
    800029be:	9ae50513          	addi	a0,a0,-1618 # 80008368 <digits+0x318>
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	bda080e7          	jalr	-1062(ra) # 8000059c <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    800029ca:	00006617          	auipc	a2,0x6
    800029ce:	09662603          	lw	a2,150(a2) # 80008a60 <available_schedulers+0x18>
    800029d2:	00006597          	auipc	a1,0x6
    800029d6:	07658593          	addi	a1,a1,118 # 80008a48 <available_schedulers>
    800029da:	00006517          	auipc	a0,0x6
    800029de:	99650513          	addi	a0,a0,-1642 # 80008370 <digits+0x320>
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	bba080e7          	jalr	-1094(ra) # 8000059c <printf>
    }
    printf("\n*: current scheduler\n\n");
    800029ea:	00006517          	auipc	a0,0x6
    800029ee:	98e50513          	addi	a0,a0,-1650 # 80008378 <digits+0x328>
    800029f2:	ffffe097          	auipc	ra,0xffffe
    800029f6:	baa080e7          	jalr	-1110(ra) # 8000059c <printf>
}
    800029fa:	60a2                	ld	ra,8(sp)
    800029fc:	6402                	ld	s0,0(sp)
    800029fe:	0141                	addi	sp,sp,16
    80002a00:	8082                	ret
            printf("[*]\t");
    80002a02:	00006517          	auipc	a0,0x6
    80002a06:	95e50513          	addi	a0,a0,-1698 # 80008360 <digits+0x310>
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	b92080e7          	jalr	-1134(ra) # 8000059c <printf>
    80002a12:	bf65                	j	800029ca <schedls+0x4c>

0000000080002a14 <schedset>:

void schedset(int id)
{
    80002a14:	1141                	addi	sp,sp,-16
    80002a16:	e406                	sd	ra,8(sp)
    80002a18:	e022                	sd	s0,0(sp)
    80002a1a:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002a1c:	e90d                	bnez	a0,80002a4e <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002a1e:	00006797          	auipc	a5,0x6
    80002a22:	03a7b783          	ld	a5,58(a5) # 80008a58 <available_schedulers+0x10>
    80002a26:	00006717          	auipc	a4,0x6
    80002a2a:	fcf73923          	sd	a5,-46(a4) # 800089f8 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002a2e:	00006597          	auipc	a1,0x6
    80002a32:	01a58593          	addi	a1,a1,26 # 80008a48 <available_schedulers>
    80002a36:	00006517          	auipc	a0,0x6
    80002a3a:	98250513          	addi	a0,a0,-1662 # 800083b8 <digits+0x368>
    80002a3e:	ffffe097          	auipc	ra,0xffffe
    80002a42:	b5e080e7          	jalr	-1186(ra) # 8000059c <printf>
}
    80002a46:	60a2                	ld	ra,8(sp)
    80002a48:	6402                	ld	s0,0(sp)
    80002a4a:	0141                	addi	sp,sp,16
    80002a4c:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002a4e:	00006517          	auipc	a0,0x6
    80002a52:	94250513          	addi	a0,a0,-1726 # 80008390 <digits+0x340>
    80002a56:	ffffe097          	auipc	ra,0xffffe
    80002a5a:	b46080e7          	jalr	-1210(ra) # 8000059c <printf>
        return;
    80002a5e:	b7e5                	j	80002a46 <schedset+0x32>

0000000080002a60 <getProc>:



struct proc* getProc(int pid) {
    80002a60:	1141                	addi	sp,sp,-16
    80002a62:	e422                	sd	s0,8(sp)
    80002a64:	0800                	addi	s0,sp,16
    80002a66:	872a                	mv	a4,a0
    struct proc* p;
    for (p = proc; p < &proc[NPROC]; p++) {
    80002a68:	0004e517          	auipc	a0,0x4e
    80002a6c:	70850513          	addi	a0,a0,1800 # 80051170 <proc>
    80002a70:	00054697          	auipc	a3,0x54
    80002a74:	10068693          	addi	a3,a3,256 # 80056b70 <tickslock>

        if (p->pid == pid) {
    80002a78:	591c                	lw	a5,48(a0)
    80002a7a:	00e78a63          	beq	a5,a4,80002a8e <getProc+0x2e>
    for (p = proc; p < &proc[NPROC]; p++) {
    80002a7e:	16850513          	addi	a0,a0,360
    80002a82:	fed51be3          	bne	a0,a3,80002a78 <getProc+0x18>
            return p;
        }
    }
    p->pid = 0;
    80002a86:	00054797          	auipc	a5,0x54
    80002a8a:	1007ad23          	sw	zero,282(a5) # 80056ba0 <bcache+0x18>
    return p;
    80002a8e:	6422                	ld	s0,8(sp)
    80002a90:	0141                	addi	sp,sp,16
    80002a92:	8082                	ret

0000000080002a94 <swtch>:
    80002a94:	00153023          	sd	ra,0(a0)
    80002a98:	00253423          	sd	sp,8(a0)
    80002a9c:	e900                	sd	s0,16(a0)
    80002a9e:	ed04                	sd	s1,24(a0)
    80002aa0:	03253023          	sd	s2,32(a0)
    80002aa4:	03353423          	sd	s3,40(a0)
    80002aa8:	03453823          	sd	s4,48(a0)
    80002aac:	03553c23          	sd	s5,56(a0)
    80002ab0:	05653023          	sd	s6,64(a0)
    80002ab4:	05753423          	sd	s7,72(a0)
    80002ab8:	05853823          	sd	s8,80(a0)
    80002abc:	05953c23          	sd	s9,88(a0)
    80002ac0:	07a53023          	sd	s10,96(a0)
    80002ac4:	07b53423          	sd	s11,104(a0)
    80002ac8:	0005b083          	ld	ra,0(a1)
    80002acc:	0085b103          	ld	sp,8(a1)
    80002ad0:	6980                	ld	s0,16(a1)
    80002ad2:	6d84                	ld	s1,24(a1)
    80002ad4:	0205b903          	ld	s2,32(a1)
    80002ad8:	0285b983          	ld	s3,40(a1)
    80002adc:	0305ba03          	ld	s4,48(a1)
    80002ae0:	0385ba83          	ld	s5,56(a1)
    80002ae4:	0405bb03          	ld	s6,64(a1)
    80002ae8:	0485bb83          	ld	s7,72(a1)
    80002aec:	0505bc03          	ld	s8,80(a1)
    80002af0:	0585bc83          	ld	s9,88(a1)
    80002af4:	0605bd03          	ld	s10,96(a1)
    80002af8:	0685bd83          	ld	s11,104(a1)
    80002afc:	8082                	ret

0000000080002afe <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002afe:	1141                	addi	sp,sp,-16
    80002b00:	e406                	sd	ra,8(sp)
    80002b02:	e022                	sd	s0,0(sp)
    80002b04:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b06:	00006597          	auipc	a1,0x6
    80002b0a:	93a58593          	addi	a1,a1,-1734 # 80008440 <states.0+0x30>
    80002b0e:	00054517          	auipc	a0,0x54
    80002b12:	06250513          	addi	a0,a0,98 # 80056b70 <tickslock>
    80002b16:	ffffe097          	auipc	ra,0xffffe
    80002b1a:	1c6080e7          	jalr	454(ra) # 80000cdc <initlock>
}
    80002b1e:	60a2                	ld	ra,8(sp)
    80002b20:	6402                	ld	s0,0(sp)
    80002b22:	0141                	addi	sp,sp,16
    80002b24:	8082                	ret

0000000080002b26 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b26:	1141                	addi	sp,sp,-16
    80002b28:	e422                	sd	s0,8(sp)
    80002b2a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b2c:	00003797          	auipc	a5,0x3
    80002b30:	6c478793          	addi	a5,a5,1732 # 800061f0 <kernelvec>
    80002b34:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b38:	6422                	ld	s0,8(sp)
    80002b3a:	0141                	addi	sp,sp,16
    80002b3c:	8082                	ret

0000000080002b3e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b3e:	1141                	addi	sp,sp,-16
    80002b40:	e406                	sd	ra,8(sp)
    80002b42:	e022                	sd	s0,0(sp)
    80002b44:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b46:	fffff097          	auipc	ra,0xfffff
    80002b4a:	114080e7          	jalr	276(ra) # 80001c5a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b4e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b52:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b54:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b58:	00004697          	auipc	a3,0x4
    80002b5c:	4a868693          	addi	a3,a3,1192 # 80007000 <_trampoline>
    80002b60:	00004717          	auipc	a4,0x4
    80002b64:	4a070713          	addi	a4,a4,1184 # 80007000 <_trampoline>
    80002b68:	8f15                	sub	a4,a4,a3
    80002b6a:	040007b7          	lui	a5,0x4000
    80002b6e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002b70:	07b2                	slli	a5,a5,0xc
    80002b72:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b74:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b78:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b7a:	18002673          	csrr	a2,satp
    80002b7e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b80:	6d30                	ld	a2,88(a0)
    80002b82:	6138                	ld	a4,64(a0)
    80002b84:	6585                	lui	a1,0x1
    80002b86:	972e                	add	a4,a4,a1
    80002b88:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b8a:	6d38                	ld	a4,88(a0)
    80002b8c:	00000617          	auipc	a2,0x0
    80002b90:	13060613          	addi	a2,a2,304 # 80002cbc <usertrap>
    80002b94:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b96:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b98:	8612                	mv	a2,tp
    80002b9a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002ba0:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002ba4:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ba8:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002bac:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bae:	6f18                	ld	a4,24(a4)
    80002bb0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bb4:	6928                	ld	a0,80(a0)
    80002bb6:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002bb8:	00004717          	auipc	a4,0x4
    80002bbc:	4e470713          	addi	a4,a4,1252 # 8000709c <userret>
    80002bc0:	8f15                	sub	a4,a4,a3
    80002bc2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002bc4:	577d                	li	a4,-1
    80002bc6:	177e                	slli	a4,a4,0x3f
    80002bc8:	8d59                	or	a0,a0,a4
    80002bca:	9782                	jalr	a5
}
    80002bcc:	60a2                	ld	ra,8(sp)
    80002bce:	6402                	ld	s0,0(sp)
    80002bd0:	0141                	addi	sp,sp,16
    80002bd2:	8082                	ret

0000000080002bd4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002bd4:	1101                	addi	sp,sp,-32
    80002bd6:	ec06                	sd	ra,24(sp)
    80002bd8:	e822                	sd	s0,16(sp)
    80002bda:	e426                	sd	s1,8(sp)
    80002bdc:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002bde:	00054497          	auipc	s1,0x54
    80002be2:	f9248493          	addi	s1,s1,-110 # 80056b70 <tickslock>
    80002be6:	8526                	mv	a0,s1
    80002be8:	ffffe097          	auipc	ra,0xffffe
    80002bec:	184080e7          	jalr	388(ra) # 80000d6c <acquire>
  ticks++;
    80002bf0:	00006517          	auipc	a0,0x6
    80002bf4:	ee050513          	addi	a0,a0,-288 # 80008ad0 <ticks>
    80002bf8:	411c                	lw	a5,0(a0)
    80002bfa:	2785                	addiw	a5,a5,1
    80002bfc:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002bfe:	00000097          	auipc	ra,0x0
    80002c02:	880080e7          	jalr	-1920(ra) # 8000247e <wakeup>
  release(&tickslock);
    80002c06:	8526                	mv	a0,s1
    80002c08:	ffffe097          	auipc	ra,0xffffe
    80002c0c:	218080e7          	jalr	536(ra) # 80000e20 <release>
}
    80002c10:	60e2                	ld	ra,24(sp)
    80002c12:	6442                	ld	s0,16(sp)
    80002c14:	64a2                	ld	s1,8(sp)
    80002c16:	6105                	addi	sp,sp,32
    80002c18:	8082                	ret

0000000080002c1a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c1a:	1101                	addi	sp,sp,-32
    80002c1c:	ec06                	sd	ra,24(sp)
    80002c1e:	e822                	sd	s0,16(sp)
    80002c20:	e426                	sd	s1,8(sp)
    80002c22:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c24:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c28:	00074d63          	bltz	a4,80002c42 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c2c:	57fd                	li	a5,-1
    80002c2e:	17fe                	slli	a5,a5,0x3f
    80002c30:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c32:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c34:	06f70363          	beq	a4,a5,80002c9a <devintr+0x80>
  }
}
    80002c38:	60e2                	ld	ra,24(sp)
    80002c3a:	6442                	ld	s0,16(sp)
    80002c3c:	64a2                	ld	s1,8(sp)
    80002c3e:	6105                	addi	sp,sp,32
    80002c40:	8082                	ret
     (scause & 0xff) == 9){
    80002c42:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002c46:	46a5                	li	a3,9
    80002c48:	fed792e3          	bne	a5,a3,80002c2c <devintr+0x12>
    int irq = plic_claim();
    80002c4c:	00003097          	auipc	ra,0x3
    80002c50:	6ac080e7          	jalr	1708(ra) # 800062f8 <plic_claim>
    80002c54:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c56:	47a9                	li	a5,10
    80002c58:	02f50763          	beq	a0,a5,80002c86 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c5c:	4785                	li	a5,1
    80002c5e:	02f50963          	beq	a0,a5,80002c90 <devintr+0x76>
    return 1;
    80002c62:	4505                	li	a0,1
    } else if(irq){
    80002c64:	d8f1                	beqz	s1,80002c38 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c66:	85a6                	mv	a1,s1
    80002c68:	00005517          	auipc	a0,0x5
    80002c6c:	7e050513          	addi	a0,a0,2016 # 80008448 <states.0+0x38>
    80002c70:	ffffe097          	auipc	ra,0xffffe
    80002c74:	92c080e7          	jalr	-1748(ra) # 8000059c <printf>
      plic_complete(irq);
    80002c78:	8526                	mv	a0,s1
    80002c7a:	00003097          	auipc	ra,0x3
    80002c7e:	6a2080e7          	jalr	1698(ra) # 8000631c <plic_complete>
    return 1;
    80002c82:	4505                	li	a0,1
    80002c84:	bf55                	j	80002c38 <devintr+0x1e>
      uartintr();
    80002c86:	ffffe097          	auipc	ra,0xffffe
    80002c8a:	d24080e7          	jalr	-732(ra) # 800009aa <uartintr>
    80002c8e:	b7ed                	j	80002c78 <devintr+0x5e>
      virtio_disk_intr();
    80002c90:	00004097          	auipc	ra,0x4
    80002c94:	b54080e7          	jalr	-1196(ra) # 800067e4 <virtio_disk_intr>
    80002c98:	b7c5                	j	80002c78 <devintr+0x5e>
    if(cpuid() == 0){
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	f94080e7          	jalr	-108(ra) # 80001c2e <cpuid>
    80002ca2:	c901                	beqz	a0,80002cb2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ca4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ca8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002caa:	14479073          	csrw	sip,a5
    return 2;
    80002cae:	4509                	li	a0,2
    80002cb0:	b761                	j	80002c38 <devintr+0x1e>
      clockintr();
    80002cb2:	00000097          	auipc	ra,0x0
    80002cb6:	f22080e7          	jalr	-222(ra) # 80002bd4 <clockintr>
    80002cba:	b7ed                	j	80002ca4 <devintr+0x8a>

0000000080002cbc <usertrap>:
{
    80002cbc:	7139                	addi	sp,sp,-64
    80002cbe:	fc06                	sd	ra,56(sp)
    80002cc0:	f822                	sd	s0,48(sp)
    80002cc2:	f426                	sd	s1,40(sp)
    80002cc4:	f04a                	sd	s2,32(sp)
    80002cc6:	ec4e                	sd	s3,24(sp)
    80002cc8:	e852                	sd	s4,16(sp)
    80002cca:	e456                	sd	s5,8(sp)
    80002ccc:	0080                	addi	s0,sp,64
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cce:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002cd2:	1007f793          	andi	a5,a5,256
    80002cd6:	efb5                	bnez	a5,80002d52 <usertrap+0x96>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cd8:	00003797          	auipc	a5,0x3
    80002cdc:	51878793          	addi	a5,a5,1304 # 800061f0 <kernelvec>
    80002ce0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	f76080e7          	jalr	-138(ra) # 80001c5a <myproc>
    80002cec:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cee:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cf0:	14102773          	csrr	a4,sepc
    80002cf4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cf6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cfa:	47a1                	li	a5,8
    80002cfc:	06f70363          	beq	a4,a5,80002d62 <usertrap+0xa6>
  } else if((which_dev = devintr()) != 0){
    80002d00:	00000097          	auipc	ra,0x0
    80002d04:	f1a080e7          	jalr	-230(ra) # 80002c1a <devintr>
    80002d08:	892a                	mv	s2,a0
    80002d0a:	14051e63          	bnez	a0,80002e66 <usertrap+0x1aa>
    80002d0e:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15) {
    80002d12:	47bd                	li	a5,15
    80002d14:	0af70363          	beq	a4,a5,80002dba <usertrap+0xfe>
    80002d18:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d1c:	5890                	lw	a2,48(s1)
    80002d1e:	00005517          	auipc	a0,0x5
    80002d22:	7aa50513          	addi	a0,a0,1962 # 800084c8 <states.0+0xb8>
    80002d26:	ffffe097          	auipc	ra,0xffffe
    80002d2a:	876080e7          	jalr	-1930(ra) # 8000059c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d2e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d32:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d36:	00005517          	auipc	a0,0x5
    80002d3a:	7c250513          	addi	a0,a0,1986 # 800084f8 <states.0+0xe8>
    80002d3e:	ffffe097          	auipc	ra,0xffffe
    80002d42:	85e080e7          	jalr	-1954(ra) # 8000059c <printf>
    setkilled(p);
    80002d46:	8526                	mv	a0,s1
    80002d48:	00000097          	auipc	ra,0x0
    80002d4c:	94e080e7          	jalr	-1714(ra) # 80002696 <setkilled>
    80002d50:	a825                	j	80002d88 <usertrap+0xcc>
    panic("usertrap: not from user mode");
    80002d52:	00005517          	auipc	a0,0x5
    80002d56:	71650513          	addi	a0,a0,1814 # 80008468 <states.0+0x58>
    80002d5a:	ffffd097          	auipc	ra,0xffffd
    80002d5e:	7e6080e7          	jalr	2022(ra) # 80000540 <panic>
    if(killed(p))
    80002d62:	00000097          	auipc	ra,0x0
    80002d66:	960080e7          	jalr	-1696(ra) # 800026c2 <killed>
    80002d6a:	e131                	bnez	a0,80002dae <usertrap+0xf2>
    p->trapframe->epc += 4;
    80002d6c:	6cb8                	ld	a4,88(s1)
    80002d6e:	6f1c                	ld	a5,24(a4)
    80002d70:	0791                	addi	a5,a5,4
    80002d72:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d74:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d78:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d7c:	10079073          	csrw	sstatus,a5
    syscall();
    80002d80:	00000097          	auipc	ra,0x0
    80002d84:	35a080e7          	jalr	858(ra) # 800030da <syscall>
  if(killed(p))
    80002d88:	8526                	mv	a0,s1
    80002d8a:	00000097          	auipc	ra,0x0
    80002d8e:	938080e7          	jalr	-1736(ra) # 800026c2 <killed>
    80002d92:	e16d                	bnez	a0,80002e74 <usertrap+0x1b8>
  usertrapret();
    80002d94:	00000097          	auipc	ra,0x0
    80002d98:	daa080e7          	jalr	-598(ra) # 80002b3e <usertrapret>
}
    80002d9c:	70e2                	ld	ra,56(sp)
    80002d9e:	7442                	ld	s0,48(sp)
    80002da0:	74a2                	ld	s1,40(sp)
    80002da2:	7902                	ld	s2,32(sp)
    80002da4:	69e2                	ld	s3,24(sp)
    80002da6:	6a42                	ld	s4,16(sp)
    80002da8:	6aa2                	ld	s5,8(sp)
    80002daa:	6121                	addi	sp,sp,64
    80002dac:	8082                	ret
      exit(-1);
    80002dae:	557d                	li	a0,-1
    80002db0:	fffff097          	auipc	ra,0xfffff
    80002db4:	79e080e7          	jalr	1950(ra) # 8000254e <exit>
    80002db8:	bf55                	j	80002d6c <usertrap+0xb0>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dba:	143029f3          	csrr	s3,stval
  uint64 start_va = PGROUNDDOWN(r_stval());
    80002dbe:	77fd                	lui	a5,0xfffff
    80002dc0:	00f9f9b3          	and	s3,s3,a5
  pte = walk(p->pagetable, start_va, 0);
    80002dc4:	4601                	li	a2,0
    80002dc6:	85ce                	mv	a1,s3
    80002dc8:	68a8                	ld	a0,80(s1)
    80002dca:	ffffe097          	auipc	ra,0xffffe
    80002dce:	382080e7          	jalr	898(ra) # 8000114c <walk>
    80002dd2:	892a                	mv	s2,a0
  if (pte == 0) {
    80002dd4:	cd35                	beqz	a0,80002e50 <usertrap+0x194>
  if ((*pte & PTE_V) && (*pte & PTE_U) && (*pte & PTE_R) && (*pte & PTE_RSW)) {
    80002dd6:	00093a03          	ld	s4,0(s2)
    80002dda:	033a7713          	andi	a4,s4,51
    80002dde:	03300793          	li	a5,51
    80002de2:	faf713e3          	bne	a4,a5,80002d88 <usertrap+0xcc>
    char *mem = kalloc();
    80002de6:	ffffe097          	auipc	ra,0xffffe
    80002dea:	dd8080e7          	jalr	-552(ra) # 80000bbe <kalloc>
    80002dee:	8aaa                	mv	s5,a0
    char *pa = (char *)PTE2PA(*pte);
    80002df0:	00093903          	ld	s2,0(s2)
    80002df4:	00a95913          	srli	s2,s2,0xa
    80002df8:	0932                	slli	s2,s2,0xc
    memmove(mem, pa, PGSIZE);
    80002dfa:	6605                	lui	a2,0x1
    80002dfc:	85ca                	mv	a1,s2
    80002dfe:	ffffe097          	auipc	ra,0xffffe
    80002e02:	0c6080e7          	jalr	198(ra) # 80000ec4 <memmove>
    uvmunmap(p->pagetable, start_va, 1, 0);
    80002e06:	4681                	li	a3,0
    80002e08:	4605                	li	a2,1
    80002e0a:	85ce                	mv	a1,s3
    80002e0c:	68a8                	ld	a0,80(s1)
    80002e0e:	ffffe097          	auipc	ra,0xffffe
    80002e12:	5ec080e7          	jalr	1516(ra) # 800013fa <uvmunmap>
    dec_ref((void*)pa);
    80002e16:	854a                	mv	a0,s2
    80002e18:	ffffe097          	auipc	ra,0xffffe
    80002e1c:	e5c080e7          	jalr	-420(ra) # 80000c74 <dec_ref>
    flags &= (~PTE_RSW);
    80002e20:	3dfa7713          	andi	a4,s4,991
    if (mappages(p->pagetable, start_va, PGSIZE, (uint64)mem, flags) != 0) {
    80002e24:	00476713          	ori	a4,a4,4
    80002e28:	86d6                	mv	a3,s5
    80002e2a:	6605                	lui	a2,0x1
    80002e2c:	85ce                	mv	a1,s3
    80002e2e:	68a8                	ld	a0,80(s1)
    80002e30:	ffffe097          	auipc	ra,0xffffe
    80002e34:	404080e7          	jalr	1028(ra) # 80001234 <mappages>
    80002e38:	d921                	beqz	a0,80002d88 <usertrap+0xcc>
      p->killed = 1;
    80002e3a:	4785                	li	a5,1
    80002e3c:	d49c                	sw	a5,40(s1)
      printf("sometthing is wrong in mappages in trap.\n");
    80002e3e:	00005517          	auipc	a0,0x5
    80002e42:	65a50513          	addi	a0,a0,1626 # 80008498 <states.0+0x88>
    80002e46:	ffffd097          	auipc	ra,0xffffd
    80002e4a:	756080e7          	jalr	1878(ra) # 8000059c <printf>
    80002e4e:	bf2d                	j	80002d88 <usertrap+0xcc>
    printf("page not found\n");
    80002e50:	00005517          	auipc	a0,0x5
    80002e54:	63850513          	addi	a0,a0,1592 # 80008488 <states.0+0x78>
    80002e58:	ffffd097          	auipc	ra,0xffffd
    80002e5c:	744080e7          	jalr	1860(ra) # 8000059c <printf>
    p->killed = 1;
    80002e60:	4785                	li	a5,1
    80002e62:	d49c                	sw	a5,40(s1)
    80002e64:	bf8d                	j	80002dd6 <usertrap+0x11a>
  if(killed(p))
    80002e66:	8526                	mv	a0,s1
    80002e68:	00000097          	auipc	ra,0x0
    80002e6c:	85a080e7          	jalr	-1958(ra) # 800026c2 <killed>
    80002e70:	c901                	beqz	a0,80002e80 <usertrap+0x1c4>
    80002e72:	a011                	j	80002e76 <usertrap+0x1ba>
    80002e74:	4901                	li	s2,0
    exit(-1);
    80002e76:	557d                	li	a0,-1
    80002e78:	fffff097          	auipc	ra,0xfffff
    80002e7c:	6d6080e7          	jalr	1750(ra) # 8000254e <exit>
  if(which_dev == 2)
    80002e80:	4789                	li	a5,2
    80002e82:	f0f919e3          	bne	s2,a5,80002d94 <usertrap+0xd8>
    yield();
    80002e86:	fffff097          	auipc	ra,0xfffff
    80002e8a:	558080e7          	jalr	1368(ra) # 800023de <yield>
    80002e8e:	b719                	j	80002d94 <usertrap+0xd8>

0000000080002e90 <kerneltrap>:
{
    80002e90:	7179                	addi	sp,sp,-48
    80002e92:	f406                	sd	ra,40(sp)
    80002e94:	f022                	sd	s0,32(sp)
    80002e96:	ec26                	sd	s1,24(sp)
    80002e98:	e84a                	sd	s2,16(sp)
    80002e9a:	e44e                	sd	s3,8(sp)
    80002e9c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e9e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ea2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ea6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002eaa:	1004f793          	andi	a5,s1,256
    80002eae:	cb85                	beqz	a5,80002ede <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002eb0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002eb4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002eb6:	ef85                	bnez	a5,80002eee <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	d62080e7          	jalr	-670(ra) # 80002c1a <devintr>
    80002ec0:	cd1d                	beqz	a0,80002efe <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ec2:	4789                	li	a5,2
    80002ec4:	06f50a63          	beq	a0,a5,80002f38 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ec8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ecc:	10049073          	csrw	sstatus,s1
}
    80002ed0:	70a2                	ld	ra,40(sp)
    80002ed2:	7402                	ld	s0,32(sp)
    80002ed4:	64e2                	ld	s1,24(sp)
    80002ed6:	6942                	ld	s2,16(sp)
    80002ed8:	69a2                	ld	s3,8(sp)
    80002eda:	6145                	addi	sp,sp,48
    80002edc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ede:	00005517          	auipc	a0,0x5
    80002ee2:	63a50513          	addi	a0,a0,1594 # 80008518 <states.0+0x108>
    80002ee6:	ffffd097          	auipc	ra,0xffffd
    80002eea:	65a080e7          	jalr	1626(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002eee:	00005517          	auipc	a0,0x5
    80002ef2:	65250513          	addi	a0,a0,1618 # 80008540 <states.0+0x130>
    80002ef6:	ffffd097          	auipc	ra,0xffffd
    80002efa:	64a080e7          	jalr	1610(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002efe:	85ce                	mv	a1,s3
    80002f00:	00005517          	auipc	a0,0x5
    80002f04:	66050513          	addi	a0,a0,1632 # 80008560 <states.0+0x150>
    80002f08:	ffffd097          	auipc	ra,0xffffd
    80002f0c:	694080e7          	jalr	1684(ra) # 8000059c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f10:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f14:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f18:	00005517          	auipc	a0,0x5
    80002f1c:	65850513          	addi	a0,a0,1624 # 80008570 <states.0+0x160>
    80002f20:	ffffd097          	auipc	ra,0xffffd
    80002f24:	67c080e7          	jalr	1660(ra) # 8000059c <printf>
    panic("kerneltrap");
    80002f28:	00005517          	auipc	a0,0x5
    80002f2c:	66050513          	addi	a0,a0,1632 # 80008588 <states.0+0x178>
    80002f30:	ffffd097          	auipc	ra,0xffffd
    80002f34:	610080e7          	jalr	1552(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f38:	fffff097          	auipc	ra,0xfffff
    80002f3c:	d22080e7          	jalr	-734(ra) # 80001c5a <myproc>
    80002f40:	d541                	beqz	a0,80002ec8 <kerneltrap+0x38>
    80002f42:	fffff097          	auipc	ra,0xfffff
    80002f46:	d18080e7          	jalr	-744(ra) # 80001c5a <myproc>
    80002f4a:	4d18                	lw	a4,24(a0)
    80002f4c:	4791                	li	a5,4
    80002f4e:	f6f71de3          	bne	a4,a5,80002ec8 <kerneltrap+0x38>
    yield();
    80002f52:	fffff097          	auipc	ra,0xfffff
    80002f56:	48c080e7          	jalr	1164(ra) # 800023de <yield>
    80002f5a:	b7bd                	j	80002ec8 <kerneltrap+0x38>

0000000080002f5c <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f5c:	1101                	addi	sp,sp,-32
    80002f5e:	ec06                	sd	ra,24(sp)
    80002f60:	e822                	sd	s0,16(sp)
    80002f62:	e426                	sd	s1,8(sp)
    80002f64:	1000                	addi	s0,sp,32
    80002f66:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002f68:	fffff097          	auipc	ra,0xfffff
    80002f6c:	cf2080e7          	jalr	-782(ra) # 80001c5a <myproc>
    switch (n)
    80002f70:	4795                	li	a5,5
    80002f72:	0497e163          	bltu	a5,s1,80002fb4 <argraw+0x58>
    80002f76:	048a                	slli	s1,s1,0x2
    80002f78:	00005717          	auipc	a4,0x5
    80002f7c:	64870713          	addi	a4,a4,1608 # 800085c0 <states.0+0x1b0>
    80002f80:	94ba                	add	s1,s1,a4
    80002f82:	409c                	lw	a5,0(s1)
    80002f84:	97ba                	add	a5,a5,a4
    80002f86:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002f88:	6d3c                	ld	a5,88(a0)
    80002f8a:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002f8c:	60e2                	ld	ra,24(sp)
    80002f8e:	6442                	ld	s0,16(sp)
    80002f90:	64a2                	ld	s1,8(sp)
    80002f92:	6105                	addi	sp,sp,32
    80002f94:	8082                	ret
        return p->trapframe->a1;
    80002f96:	6d3c                	ld	a5,88(a0)
    80002f98:	7fa8                	ld	a0,120(a5)
    80002f9a:	bfcd                	j	80002f8c <argraw+0x30>
        return p->trapframe->a2;
    80002f9c:	6d3c                	ld	a5,88(a0)
    80002f9e:	63c8                	ld	a0,128(a5)
    80002fa0:	b7f5                	j	80002f8c <argraw+0x30>
        return p->trapframe->a3;
    80002fa2:	6d3c                	ld	a5,88(a0)
    80002fa4:	67c8                	ld	a0,136(a5)
    80002fa6:	b7dd                	j	80002f8c <argraw+0x30>
        return p->trapframe->a4;
    80002fa8:	6d3c                	ld	a5,88(a0)
    80002faa:	6bc8                	ld	a0,144(a5)
    80002fac:	b7c5                	j	80002f8c <argraw+0x30>
        return p->trapframe->a5;
    80002fae:	6d3c                	ld	a5,88(a0)
    80002fb0:	6fc8                	ld	a0,152(a5)
    80002fb2:	bfe9                	j	80002f8c <argraw+0x30>
    panic("argraw");
    80002fb4:	00005517          	auipc	a0,0x5
    80002fb8:	5e450513          	addi	a0,a0,1508 # 80008598 <states.0+0x188>
    80002fbc:	ffffd097          	auipc	ra,0xffffd
    80002fc0:	584080e7          	jalr	1412(ra) # 80000540 <panic>

0000000080002fc4 <fetchaddr>:
{
    80002fc4:	1101                	addi	sp,sp,-32
    80002fc6:	ec06                	sd	ra,24(sp)
    80002fc8:	e822                	sd	s0,16(sp)
    80002fca:	e426                	sd	s1,8(sp)
    80002fcc:	e04a                	sd	s2,0(sp)
    80002fce:	1000                	addi	s0,sp,32
    80002fd0:	84aa                	mv	s1,a0
    80002fd2:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002fd4:	fffff097          	auipc	ra,0xfffff
    80002fd8:	c86080e7          	jalr	-890(ra) # 80001c5a <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002fdc:	653c                	ld	a5,72(a0)
    80002fde:	02f4f863          	bgeu	s1,a5,8000300e <fetchaddr+0x4a>
    80002fe2:	00848713          	addi	a4,s1,8
    80002fe6:	02e7e663          	bltu	a5,a4,80003012 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002fea:	46a1                	li	a3,8
    80002fec:	8626                	mv	a2,s1
    80002fee:	85ca                	mv	a1,s2
    80002ff0:	6928                	ld	a0,80(a0)
    80002ff2:	fffff097          	auipc	ra,0xfffff
    80002ff6:	8b6080e7          	jalr	-1866(ra) # 800018a8 <copyin>
    80002ffa:	00a03533          	snez	a0,a0
    80002ffe:	40a00533          	neg	a0,a0
}
    80003002:	60e2                	ld	ra,24(sp)
    80003004:	6442                	ld	s0,16(sp)
    80003006:	64a2                	ld	s1,8(sp)
    80003008:	6902                	ld	s2,0(sp)
    8000300a:	6105                	addi	sp,sp,32
    8000300c:	8082                	ret
        return -1;
    8000300e:	557d                	li	a0,-1
    80003010:	bfcd                	j	80003002 <fetchaddr+0x3e>
    80003012:	557d                	li	a0,-1
    80003014:	b7fd                	j	80003002 <fetchaddr+0x3e>

0000000080003016 <fetchstr>:
{
    80003016:	7179                	addi	sp,sp,-48
    80003018:	f406                	sd	ra,40(sp)
    8000301a:	f022                	sd	s0,32(sp)
    8000301c:	ec26                	sd	s1,24(sp)
    8000301e:	e84a                	sd	s2,16(sp)
    80003020:	e44e                	sd	s3,8(sp)
    80003022:	1800                	addi	s0,sp,48
    80003024:	892a                	mv	s2,a0
    80003026:	84ae                	mv	s1,a1
    80003028:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    8000302a:	fffff097          	auipc	ra,0xfffff
    8000302e:	c30080e7          	jalr	-976(ra) # 80001c5a <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80003032:	86ce                	mv	a3,s3
    80003034:	864a                	mv	a2,s2
    80003036:	85a6                	mv	a1,s1
    80003038:	6928                	ld	a0,80(a0)
    8000303a:	fffff097          	auipc	ra,0xfffff
    8000303e:	8fc080e7          	jalr	-1796(ra) # 80001936 <copyinstr>
    80003042:	00054e63          	bltz	a0,8000305e <fetchstr+0x48>
    return strlen(buf);
    80003046:	8526                	mv	a0,s1
    80003048:	ffffe097          	auipc	ra,0xffffe
    8000304c:	f9c080e7          	jalr	-100(ra) # 80000fe4 <strlen>
}
    80003050:	70a2                	ld	ra,40(sp)
    80003052:	7402                	ld	s0,32(sp)
    80003054:	64e2                	ld	s1,24(sp)
    80003056:	6942                	ld	s2,16(sp)
    80003058:	69a2                	ld	s3,8(sp)
    8000305a:	6145                	addi	sp,sp,48
    8000305c:	8082                	ret
        return -1;
    8000305e:	557d                	li	a0,-1
    80003060:	bfc5                	j	80003050 <fetchstr+0x3a>

0000000080003062 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003062:	1101                	addi	sp,sp,-32
    80003064:	ec06                	sd	ra,24(sp)
    80003066:	e822                	sd	s0,16(sp)
    80003068:	e426                	sd	s1,8(sp)
    8000306a:	1000                	addi	s0,sp,32
    8000306c:	84ae                	mv	s1,a1
    *ip = argraw(n);
    8000306e:	00000097          	auipc	ra,0x0
    80003072:	eee080e7          	jalr	-274(ra) # 80002f5c <argraw>
    80003076:	c088                	sw	a0,0(s1)
}
    80003078:	60e2                	ld	ra,24(sp)
    8000307a:	6442                	ld	s0,16(sp)
    8000307c:	64a2                	ld	s1,8(sp)
    8000307e:	6105                	addi	sp,sp,32
    80003080:	8082                	ret

0000000080003082 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003082:	1101                	addi	sp,sp,-32
    80003084:	ec06                	sd	ra,24(sp)
    80003086:	e822                	sd	s0,16(sp)
    80003088:	e426                	sd	s1,8(sp)
    8000308a:	1000                	addi	s0,sp,32
    8000308c:	84ae                	mv	s1,a1
    *ip = argraw(n);
    8000308e:	00000097          	auipc	ra,0x0
    80003092:	ece080e7          	jalr	-306(ra) # 80002f5c <argraw>
    80003096:	e088                	sd	a0,0(s1)
}
    80003098:	60e2                	ld	ra,24(sp)
    8000309a:	6442                	ld	s0,16(sp)
    8000309c:	64a2                	ld	s1,8(sp)
    8000309e:	6105                	addi	sp,sp,32
    800030a0:	8082                	ret

00000000800030a2 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    800030a2:	7179                	addi	sp,sp,-48
    800030a4:	f406                	sd	ra,40(sp)
    800030a6:	f022                	sd	s0,32(sp)
    800030a8:	ec26                	sd	s1,24(sp)
    800030aa:	e84a                	sd	s2,16(sp)
    800030ac:	1800                	addi	s0,sp,48
    800030ae:	84ae                	mv	s1,a1
    800030b0:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    800030b2:	fd840593          	addi	a1,s0,-40
    800030b6:	00000097          	auipc	ra,0x0
    800030ba:	fcc080e7          	jalr	-52(ra) # 80003082 <argaddr>
    return fetchstr(addr, buf, max);
    800030be:	864a                	mv	a2,s2
    800030c0:	85a6                	mv	a1,s1
    800030c2:	fd843503          	ld	a0,-40(s0)
    800030c6:	00000097          	auipc	ra,0x0
    800030ca:	f50080e7          	jalr	-176(ra) # 80003016 <fetchstr>
}
    800030ce:	70a2                	ld	ra,40(sp)
    800030d0:	7402                	ld	s0,32(sp)
    800030d2:	64e2                	ld	s1,24(sp)
    800030d4:	6942                	ld	s2,16(sp)
    800030d6:	6145                	addi	sp,sp,48
    800030d8:	8082                	ret

00000000800030da <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    800030da:	1101                	addi	sp,sp,-32
    800030dc:	ec06                	sd	ra,24(sp)
    800030de:	e822                	sd	s0,16(sp)
    800030e0:	e426                	sd	s1,8(sp)
    800030e2:	e04a                	sd	s2,0(sp)
    800030e4:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    800030e6:	fffff097          	auipc	ra,0xfffff
    800030ea:	b74080e7          	jalr	-1164(ra) # 80001c5a <myproc>
    800030ee:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    800030f0:	05853903          	ld	s2,88(a0)
    800030f4:	0a893783          	ld	a5,168(s2)
    800030f8:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800030fc:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0xffffffff7ff9d0af>
    800030fe:	4765                	li	a4,25
    80003100:	00f76f63          	bltu	a4,a5,8000311e <syscall+0x44>
    80003104:	00369713          	slli	a4,a3,0x3
    80003108:	00005797          	auipc	a5,0x5
    8000310c:	4d078793          	addi	a5,a5,1232 # 800085d8 <syscalls>
    80003110:	97ba                	add	a5,a5,a4
    80003112:	639c                	ld	a5,0(a5)
    80003114:	c789                	beqz	a5,8000311e <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80003116:	9782                	jalr	a5
    80003118:	06a93823          	sd	a0,112(s2)
    8000311c:	a839                	j	8000313a <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    8000311e:	15848613          	addi	a2,s1,344
    80003122:	588c                	lw	a1,48(s1)
    80003124:	00005517          	auipc	a0,0x5
    80003128:	47c50513          	addi	a0,a0,1148 # 800085a0 <states.0+0x190>
    8000312c:	ffffd097          	auipc	ra,0xffffd
    80003130:	470080e7          	jalr	1136(ra) # 8000059c <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80003134:	6cbc                	ld	a5,88(s1)
    80003136:	577d                	li	a4,-1
    80003138:	fbb8                	sd	a4,112(a5)
    }
}
    8000313a:	60e2                	ld	ra,24(sp)
    8000313c:	6442                	ld	s0,16(sp)
    8000313e:	64a2                	ld	s1,8(sp)
    80003140:	6902                	ld	s2,0(sp)
    80003142:	6105                	addi	sp,sp,32
    80003144:	8082                	ret

0000000080003146 <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    80003146:	1101                	addi	sp,sp,-32
    80003148:	ec06                	sd	ra,24(sp)
    8000314a:	e822                	sd	s0,16(sp)
    8000314c:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    8000314e:	fec40593          	addi	a1,s0,-20
    80003152:	4501                	li	a0,0
    80003154:	00000097          	auipc	ra,0x0
    80003158:	f0e080e7          	jalr	-242(ra) # 80003062 <argint>
    exit(n);
    8000315c:	fec42503          	lw	a0,-20(s0)
    80003160:	fffff097          	auipc	ra,0xfffff
    80003164:	3ee080e7          	jalr	1006(ra) # 8000254e <exit>
    return 0; // not reached
}
    80003168:	4501                	li	a0,0
    8000316a:	60e2                	ld	ra,24(sp)
    8000316c:	6442                	ld	s0,16(sp)
    8000316e:	6105                	addi	sp,sp,32
    80003170:	8082                	ret

0000000080003172 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003172:	1141                	addi	sp,sp,-16
    80003174:	e406                	sd	ra,8(sp)
    80003176:	e022                	sd	s0,0(sp)
    80003178:	0800                	addi	s0,sp,16
    return myproc()->pid;
    8000317a:	fffff097          	auipc	ra,0xfffff
    8000317e:	ae0080e7          	jalr	-1312(ra) # 80001c5a <myproc>
}
    80003182:	5908                	lw	a0,48(a0)
    80003184:	60a2                	ld	ra,8(sp)
    80003186:	6402                	ld	s0,0(sp)
    80003188:	0141                	addi	sp,sp,16
    8000318a:	8082                	ret

000000008000318c <sys_fork>:

uint64
sys_fork(void)
{
    8000318c:	1141                	addi	sp,sp,-16
    8000318e:	e406                	sd	ra,8(sp)
    80003190:	e022                	sd	s0,0(sp)
    80003192:	0800                	addi	s0,sp,16
    return fork();
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	012080e7          	jalr	18(ra) # 800021a6 <fork>
}
    8000319c:	60a2                	ld	ra,8(sp)
    8000319e:	6402                	ld	s0,0(sp)
    800031a0:	0141                	addi	sp,sp,16
    800031a2:	8082                	ret

00000000800031a4 <sys_wait>:

uint64
sys_wait(void)
{
    800031a4:	1101                	addi	sp,sp,-32
    800031a6:	ec06                	sd	ra,24(sp)
    800031a8:	e822                	sd	s0,16(sp)
    800031aa:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    800031ac:	fe840593          	addi	a1,s0,-24
    800031b0:	4501                	li	a0,0
    800031b2:	00000097          	auipc	ra,0x0
    800031b6:	ed0080e7          	jalr	-304(ra) # 80003082 <argaddr>
    return wait(p);
    800031ba:	fe843503          	ld	a0,-24(s0)
    800031be:	fffff097          	auipc	ra,0xfffff
    800031c2:	536080e7          	jalr	1334(ra) # 800026f4 <wait>
}
    800031c6:	60e2                	ld	ra,24(sp)
    800031c8:	6442                	ld	s0,16(sp)
    800031ca:	6105                	addi	sp,sp,32
    800031cc:	8082                	ret

00000000800031ce <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800031ce:	7179                	addi	sp,sp,-48
    800031d0:	f406                	sd	ra,40(sp)
    800031d2:	f022                	sd	s0,32(sp)
    800031d4:	ec26                	sd	s1,24(sp)
    800031d6:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    800031d8:	fdc40593          	addi	a1,s0,-36
    800031dc:	4501                	li	a0,0
    800031de:	00000097          	auipc	ra,0x0
    800031e2:	e84080e7          	jalr	-380(ra) # 80003062 <argint>
    addr = myproc()->sz;
    800031e6:	fffff097          	auipc	ra,0xfffff
    800031ea:	a74080e7          	jalr	-1420(ra) # 80001c5a <myproc>
    800031ee:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    800031f0:	fdc42503          	lw	a0,-36(s0)
    800031f4:	fffff097          	auipc	ra,0xfffff
    800031f8:	dc0080e7          	jalr	-576(ra) # 80001fb4 <growproc>
    800031fc:	00054863          	bltz	a0,8000320c <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    80003200:	8526                	mv	a0,s1
    80003202:	70a2                	ld	ra,40(sp)
    80003204:	7402                	ld	s0,32(sp)
    80003206:	64e2                	ld	s1,24(sp)
    80003208:	6145                	addi	sp,sp,48
    8000320a:	8082                	ret
        return -1;
    8000320c:	54fd                	li	s1,-1
    8000320e:	bfcd                	j	80003200 <sys_sbrk+0x32>

0000000080003210 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003210:	7139                	addi	sp,sp,-64
    80003212:	fc06                	sd	ra,56(sp)
    80003214:	f822                	sd	s0,48(sp)
    80003216:	f426                	sd	s1,40(sp)
    80003218:	f04a                	sd	s2,32(sp)
    8000321a:	ec4e                	sd	s3,24(sp)
    8000321c:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    8000321e:	fcc40593          	addi	a1,s0,-52
    80003222:	4501                	li	a0,0
    80003224:	00000097          	auipc	ra,0x0
    80003228:	e3e080e7          	jalr	-450(ra) # 80003062 <argint>
    acquire(&tickslock);
    8000322c:	00054517          	auipc	a0,0x54
    80003230:	94450513          	addi	a0,a0,-1724 # 80056b70 <tickslock>
    80003234:	ffffe097          	auipc	ra,0xffffe
    80003238:	b38080e7          	jalr	-1224(ra) # 80000d6c <acquire>
    ticks0 = ticks;
    8000323c:	00006917          	auipc	s2,0x6
    80003240:	89492903          	lw	s2,-1900(s2) # 80008ad0 <ticks>
    while (ticks - ticks0 < n)
    80003244:	fcc42783          	lw	a5,-52(s0)
    80003248:	cf9d                	beqz	a5,80003286 <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    8000324a:	00054997          	auipc	s3,0x54
    8000324e:	92698993          	addi	s3,s3,-1754 # 80056b70 <tickslock>
    80003252:	00006497          	auipc	s1,0x6
    80003256:	87e48493          	addi	s1,s1,-1922 # 80008ad0 <ticks>
        if (killed(myproc()))
    8000325a:	fffff097          	auipc	ra,0xfffff
    8000325e:	a00080e7          	jalr	-1536(ra) # 80001c5a <myproc>
    80003262:	fffff097          	auipc	ra,0xfffff
    80003266:	460080e7          	jalr	1120(ra) # 800026c2 <killed>
    8000326a:	ed15                	bnez	a0,800032a6 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    8000326c:	85ce                	mv	a1,s3
    8000326e:	8526                	mv	a0,s1
    80003270:	fffff097          	auipc	ra,0xfffff
    80003274:	1aa080e7          	jalr	426(ra) # 8000241a <sleep>
    while (ticks - ticks0 < n)
    80003278:	409c                	lw	a5,0(s1)
    8000327a:	412787bb          	subw	a5,a5,s2
    8000327e:	fcc42703          	lw	a4,-52(s0)
    80003282:	fce7ece3          	bltu	a5,a4,8000325a <sys_sleep+0x4a>
    }
    release(&tickslock);
    80003286:	00054517          	auipc	a0,0x54
    8000328a:	8ea50513          	addi	a0,a0,-1814 # 80056b70 <tickslock>
    8000328e:	ffffe097          	auipc	ra,0xffffe
    80003292:	b92080e7          	jalr	-1134(ra) # 80000e20 <release>
    return 0;
    80003296:	4501                	li	a0,0
}
    80003298:	70e2                	ld	ra,56(sp)
    8000329a:	7442                	ld	s0,48(sp)
    8000329c:	74a2                	ld	s1,40(sp)
    8000329e:	7902                	ld	s2,32(sp)
    800032a0:	69e2                	ld	s3,24(sp)
    800032a2:	6121                	addi	sp,sp,64
    800032a4:	8082                	ret
            release(&tickslock);
    800032a6:	00054517          	auipc	a0,0x54
    800032aa:	8ca50513          	addi	a0,a0,-1846 # 80056b70 <tickslock>
    800032ae:	ffffe097          	auipc	ra,0xffffe
    800032b2:	b72080e7          	jalr	-1166(ra) # 80000e20 <release>
            return -1;
    800032b6:	557d                	li	a0,-1
    800032b8:	b7c5                	j	80003298 <sys_sleep+0x88>

00000000800032ba <sys_kill>:

uint64
sys_kill(void)
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    800032c2:	fec40593          	addi	a1,s0,-20
    800032c6:	4501                	li	a0,0
    800032c8:	00000097          	auipc	ra,0x0
    800032cc:	d9a080e7          	jalr	-614(ra) # 80003062 <argint>
    return kill(pid);
    800032d0:	fec42503          	lw	a0,-20(s0)
    800032d4:	fffff097          	auipc	ra,0xfffff
    800032d8:	350080e7          	jalr	848(ra) # 80002624 <kill>
}
    800032dc:	60e2                	ld	ra,24(sp)
    800032de:	6442                	ld	s0,16(sp)
    800032e0:	6105                	addi	sp,sp,32
    800032e2:	8082                	ret

00000000800032e4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800032e4:	1101                	addi	sp,sp,-32
    800032e6:	ec06                	sd	ra,24(sp)
    800032e8:	e822                	sd	s0,16(sp)
    800032ea:	e426                	sd	s1,8(sp)
    800032ec:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    800032ee:	00054517          	auipc	a0,0x54
    800032f2:	88250513          	addi	a0,a0,-1918 # 80056b70 <tickslock>
    800032f6:	ffffe097          	auipc	ra,0xffffe
    800032fa:	a76080e7          	jalr	-1418(ra) # 80000d6c <acquire>
    xticks = ticks;
    800032fe:	00005497          	auipc	s1,0x5
    80003302:	7d24a483          	lw	s1,2002(s1) # 80008ad0 <ticks>
    release(&tickslock);
    80003306:	00054517          	auipc	a0,0x54
    8000330a:	86a50513          	addi	a0,a0,-1942 # 80056b70 <tickslock>
    8000330e:	ffffe097          	auipc	ra,0xffffe
    80003312:	b12080e7          	jalr	-1262(ra) # 80000e20 <release>
    return xticks;
}
    80003316:	02049513          	slli	a0,s1,0x20
    8000331a:	9101                	srli	a0,a0,0x20
    8000331c:	60e2                	ld	ra,24(sp)
    8000331e:	6442                	ld	s0,16(sp)
    80003320:	64a2                	ld	s1,8(sp)
    80003322:	6105                	addi	sp,sp,32
    80003324:	8082                	ret

0000000080003326 <sys_ps>:

void *
sys_ps(void)
{
    80003326:	1101                	addi	sp,sp,-32
    80003328:	ec06                	sd	ra,24(sp)
    8000332a:	e822                	sd	s0,16(sp)
    8000332c:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    8000332e:	fe042623          	sw	zero,-20(s0)
    80003332:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    80003336:	fec40593          	addi	a1,s0,-20
    8000333a:	4501                	li	a0,0
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	d26080e7          	jalr	-730(ra) # 80003062 <argint>
    argint(1, &count);
    80003344:	fe840593          	addi	a1,s0,-24
    80003348:	4505                	li	a0,1
    8000334a:	00000097          	auipc	ra,0x0
    8000334e:	d18080e7          	jalr	-744(ra) # 80003062 <argint>
    return ps((uint8)start, (uint8)count);
    80003352:	fe844583          	lbu	a1,-24(s0)
    80003356:	fec44503          	lbu	a0,-20(s0)
    8000335a:	fffff097          	auipc	ra,0xfffff
    8000335e:	cb6080e7          	jalr	-842(ra) # 80002010 <ps>
}
    80003362:	60e2                	ld	ra,24(sp)
    80003364:	6442                	ld	s0,16(sp)
    80003366:	6105                	addi	sp,sp,32
    80003368:	8082                	ret

000000008000336a <sys_schedls>:

uint64 sys_schedls(void)
{
    8000336a:	1141                	addi	sp,sp,-16
    8000336c:	e406                	sd	ra,8(sp)
    8000336e:	e022                	sd	s0,0(sp)
    80003370:	0800                	addi	s0,sp,16
    schedls();
    80003372:	fffff097          	auipc	ra,0xfffff
    80003376:	60c080e7          	jalr	1548(ra) # 8000297e <schedls>
    return 0;
}
    8000337a:	4501                	li	a0,0
    8000337c:	60a2                	ld	ra,8(sp)
    8000337e:	6402                	ld	s0,0(sp)
    80003380:	0141                	addi	sp,sp,16
    80003382:	8082                	ret

0000000080003384 <sys_schedset>:

uint64 sys_schedset(void)
{
    80003384:	1101                	addi	sp,sp,-32
    80003386:	ec06                	sd	ra,24(sp)
    80003388:	e822                	sd	s0,16(sp)
    8000338a:	1000                	addi	s0,sp,32
    int id = 0;
    8000338c:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    80003390:	fec40593          	addi	a1,s0,-20
    80003394:	4501                	li	a0,0
    80003396:	00000097          	auipc	ra,0x0
    8000339a:	ccc080e7          	jalr	-820(ra) # 80003062 <argint>
    schedset(id - 1);
    8000339e:	fec42503          	lw	a0,-20(s0)
    800033a2:	357d                	addiw	a0,a0,-1
    800033a4:	fffff097          	auipc	ra,0xfffff
    800033a8:	670080e7          	jalr	1648(ra) # 80002a14 <schedset>
    return 0;
}
    800033ac:	4501                	li	a0,0
    800033ae:	60e2                	ld	ra,24(sp)
    800033b0:	6442                	ld	s0,16(sp)
    800033b2:	6105                	addi	sp,sp,32
    800033b4:	8082                	ret

00000000800033b6 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    800033b6:	7179                	addi	sp,sp,-48
    800033b8:	f406                	sd	ra,40(sp)
    800033ba:	f022                	sd	s0,32(sp)
    800033bc:	ec26                	sd	s1,24(sp)
    800033be:	e84a                	sd	s2,16(sp)
    800033c0:	1800                	addi	s0,sp,48
    int va = 0, pid = 0;
    800033c2:	fc042e23          	sw	zero,-36(s0)
    800033c6:	fc042c23          	sw	zero,-40(s0)
    argint(0, &va);
    800033ca:	fdc40593          	addi	a1,s0,-36
    800033ce:	4501                	li	a0,0
    800033d0:	00000097          	auipc	ra,0x0
    800033d4:	c92080e7          	jalr	-878(ra) # 80003062 <argint>
    argint(1, &pid);
    800033d8:	fd840593          	addi	a1,s0,-40
    800033dc:	4505                	li	a0,1
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	c84080e7          	jalr	-892(ra) # 80003062 <argint>
    pagetable_t pagetable;
    struct proc *proc;
    if(pid == 0){
    800033e6:	fd842503          	lw	a0,-40(s0)
    800033ea:	ed19                	bnez	a0,80003408 <sys_va2pa+0x52>
        proc = myproc();
    800033ec:	fffff097          	auipc	ra,0xfffff
    800033f0:	86e080e7          	jalr	-1938(ra) # 80001c5a <myproc>
    800033f4:	84aa                	mv	s1,a0
    }else {
        proc = getProc(pid);
    }

    if(proc->pid == 0){
    800033f6:	589c                	lw	a5,48(s1)
        return 0;
    800033f8:	4501                	li	a0,0
    if(proc->pid == 0){
    800033fa:	ef89                	bnez	a5,80003414 <sys_va2pa+0x5e>
    pagetable = proc->pagetable;
    release(&proc->lock);
    // uint64 pa =PTE2PA((pte_t) walk(pagetable, va,0));
    // pa = pa+(va & 0xFFF);
    return walkaddr(pagetable, va);
}
    800033fc:	70a2                	ld	ra,40(sp)
    800033fe:	7402                	ld	s0,32(sp)
    80003400:	64e2                	ld	s1,24(sp)
    80003402:	6942                	ld	s2,16(sp)
    80003404:	6145                	addi	sp,sp,48
    80003406:	8082                	ret
        proc = getProc(pid);
    80003408:	fffff097          	auipc	ra,0xfffff
    8000340c:	658080e7          	jalr	1624(ra) # 80002a60 <getProc>
    80003410:	84aa                	mv	s1,a0
    80003412:	b7d5                	j	800033f6 <sys_va2pa+0x40>
    acquire(&proc->lock);
    80003414:	8526                	mv	a0,s1
    80003416:	ffffe097          	auipc	ra,0xffffe
    8000341a:	956080e7          	jalr	-1706(ra) # 80000d6c <acquire>
    pagetable = proc->pagetable;
    8000341e:	0504b903          	ld	s2,80(s1)
    release(&proc->lock);
    80003422:	8526                	mv	a0,s1
    80003424:	ffffe097          	auipc	ra,0xffffe
    80003428:	9fc080e7          	jalr	-1540(ra) # 80000e20 <release>
    return walkaddr(pagetable, va);
    8000342c:	fdc42583          	lw	a1,-36(s0)
    80003430:	854a                	mv	a0,s2
    80003432:	ffffe097          	auipc	ra,0xffffe
    80003436:	dc0080e7          	jalr	-576(ra) # 800011f2 <walkaddr>
    8000343a:	b7c9                	j	800033fc <sys_va2pa+0x46>

000000008000343c <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    8000343c:	1141                	addi	sp,sp,-16
    8000343e:	e406                	sd	ra,8(sp)
    80003440:	e022                	sd	s0,0(sp)
    80003442:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    80003444:	00005597          	auipc	a1,0x5
    80003448:	6645b583          	ld	a1,1636(a1) # 80008aa8 <FREE_PAGES>
    8000344c:	00005517          	auipc	a0,0x5
    80003450:	16c50513          	addi	a0,a0,364 # 800085b8 <states.0+0x1a8>
    80003454:	ffffd097          	auipc	ra,0xffffd
    80003458:	148080e7          	jalr	328(ra) # 8000059c <printf>
    return 0;
    8000345c:	4501                	li	a0,0
    8000345e:	60a2                	ld	ra,8(sp)
    80003460:	6402                	ld	s0,0(sp)
    80003462:	0141                	addi	sp,sp,16
    80003464:	8082                	ret

0000000080003466 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003466:	7179                	addi	sp,sp,-48
    80003468:	f406                	sd	ra,40(sp)
    8000346a:	f022                	sd	s0,32(sp)
    8000346c:	ec26                	sd	s1,24(sp)
    8000346e:	e84a                	sd	s2,16(sp)
    80003470:	e44e                	sd	s3,8(sp)
    80003472:	e052                	sd	s4,0(sp)
    80003474:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003476:	00005597          	auipc	a1,0x5
    8000347a:	23a58593          	addi	a1,a1,570 # 800086b0 <syscalls+0xd8>
    8000347e:	00053517          	auipc	a0,0x53
    80003482:	70a50513          	addi	a0,a0,1802 # 80056b88 <bcache>
    80003486:	ffffe097          	auipc	ra,0xffffe
    8000348a:	856080e7          	jalr	-1962(ra) # 80000cdc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000348e:	0005b797          	auipc	a5,0x5b
    80003492:	6fa78793          	addi	a5,a5,1786 # 8005eb88 <bcache+0x8000>
    80003496:	0005c717          	auipc	a4,0x5c
    8000349a:	95a70713          	addi	a4,a4,-1702 # 8005edf0 <bcache+0x8268>
    8000349e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034a2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034a6:	00053497          	auipc	s1,0x53
    800034aa:	6fa48493          	addi	s1,s1,1786 # 80056ba0 <bcache+0x18>
    b->next = bcache.head.next;
    800034ae:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800034b0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800034b2:	00005a17          	auipc	s4,0x5
    800034b6:	206a0a13          	addi	s4,s4,518 # 800086b8 <syscalls+0xe0>
    b->next = bcache.head.next;
    800034ba:	2b893783          	ld	a5,696(s2)
    800034be:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800034c0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800034c4:	85d2                	mv	a1,s4
    800034c6:	01048513          	addi	a0,s1,16
    800034ca:	00001097          	auipc	ra,0x1
    800034ce:	4c8080e7          	jalr	1224(ra) # 80004992 <initsleeplock>
    bcache.head.next->prev = b;
    800034d2:	2b893783          	ld	a5,696(s2)
    800034d6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034d8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034dc:	45848493          	addi	s1,s1,1112
    800034e0:	fd349de3          	bne	s1,s3,800034ba <binit+0x54>
  }
}
    800034e4:	70a2                	ld	ra,40(sp)
    800034e6:	7402                	ld	s0,32(sp)
    800034e8:	64e2                	ld	s1,24(sp)
    800034ea:	6942                	ld	s2,16(sp)
    800034ec:	69a2                	ld	s3,8(sp)
    800034ee:	6a02                	ld	s4,0(sp)
    800034f0:	6145                	addi	sp,sp,48
    800034f2:	8082                	ret

00000000800034f4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034f4:	7179                	addi	sp,sp,-48
    800034f6:	f406                	sd	ra,40(sp)
    800034f8:	f022                	sd	s0,32(sp)
    800034fa:	ec26                	sd	s1,24(sp)
    800034fc:	e84a                	sd	s2,16(sp)
    800034fe:	e44e                	sd	s3,8(sp)
    80003500:	1800                	addi	s0,sp,48
    80003502:	892a                	mv	s2,a0
    80003504:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003506:	00053517          	auipc	a0,0x53
    8000350a:	68250513          	addi	a0,a0,1666 # 80056b88 <bcache>
    8000350e:	ffffe097          	auipc	ra,0xffffe
    80003512:	85e080e7          	jalr	-1954(ra) # 80000d6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003516:	0005c497          	auipc	s1,0x5c
    8000351a:	92a4b483          	ld	s1,-1750(s1) # 8005ee40 <bcache+0x82b8>
    8000351e:	0005c797          	auipc	a5,0x5c
    80003522:	8d278793          	addi	a5,a5,-1838 # 8005edf0 <bcache+0x8268>
    80003526:	02f48f63          	beq	s1,a5,80003564 <bread+0x70>
    8000352a:	873e                	mv	a4,a5
    8000352c:	a021                	j	80003534 <bread+0x40>
    8000352e:	68a4                	ld	s1,80(s1)
    80003530:	02e48a63          	beq	s1,a4,80003564 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003534:	449c                	lw	a5,8(s1)
    80003536:	ff279ce3          	bne	a5,s2,8000352e <bread+0x3a>
    8000353a:	44dc                	lw	a5,12(s1)
    8000353c:	ff3799e3          	bne	a5,s3,8000352e <bread+0x3a>
      b->refcnt++;
    80003540:	40bc                	lw	a5,64(s1)
    80003542:	2785                	addiw	a5,a5,1
    80003544:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003546:	00053517          	auipc	a0,0x53
    8000354a:	64250513          	addi	a0,a0,1602 # 80056b88 <bcache>
    8000354e:	ffffe097          	auipc	ra,0xffffe
    80003552:	8d2080e7          	jalr	-1838(ra) # 80000e20 <release>
      acquiresleep(&b->lock);
    80003556:	01048513          	addi	a0,s1,16
    8000355a:	00001097          	auipc	ra,0x1
    8000355e:	472080e7          	jalr	1138(ra) # 800049cc <acquiresleep>
      return b;
    80003562:	a8b9                	j	800035c0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003564:	0005c497          	auipc	s1,0x5c
    80003568:	8d44b483          	ld	s1,-1836(s1) # 8005ee38 <bcache+0x82b0>
    8000356c:	0005c797          	auipc	a5,0x5c
    80003570:	88478793          	addi	a5,a5,-1916 # 8005edf0 <bcache+0x8268>
    80003574:	00f48863          	beq	s1,a5,80003584 <bread+0x90>
    80003578:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000357a:	40bc                	lw	a5,64(s1)
    8000357c:	cf81                	beqz	a5,80003594 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000357e:	64a4                	ld	s1,72(s1)
    80003580:	fee49de3          	bne	s1,a4,8000357a <bread+0x86>
  panic("bget: no buffers");
    80003584:	00005517          	auipc	a0,0x5
    80003588:	13c50513          	addi	a0,a0,316 # 800086c0 <syscalls+0xe8>
    8000358c:	ffffd097          	auipc	ra,0xffffd
    80003590:	fb4080e7          	jalr	-76(ra) # 80000540 <panic>
      b->dev = dev;
    80003594:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003598:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000359c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035a0:	4785                	li	a5,1
    800035a2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035a4:	00053517          	auipc	a0,0x53
    800035a8:	5e450513          	addi	a0,a0,1508 # 80056b88 <bcache>
    800035ac:	ffffe097          	auipc	ra,0xffffe
    800035b0:	874080e7          	jalr	-1932(ra) # 80000e20 <release>
      acquiresleep(&b->lock);
    800035b4:	01048513          	addi	a0,s1,16
    800035b8:	00001097          	auipc	ra,0x1
    800035bc:	414080e7          	jalr	1044(ra) # 800049cc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800035c0:	409c                	lw	a5,0(s1)
    800035c2:	cb89                	beqz	a5,800035d4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035c4:	8526                	mv	a0,s1
    800035c6:	70a2                	ld	ra,40(sp)
    800035c8:	7402                	ld	s0,32(sp)
    800035ca:	64e2                	ld	s1,24(sp)
    800035cc:	6942                	ld	s2,16(sp)
    800035ce:	69a2                	ld	s3,8(sp)
    800035d0:	6145                	addi	sp,sp,48
    800035d2:	8082                	ret
    virtio_disk_rw(b, 0);
    800035d4:	4581                	li	a1,0
    800035d6:	8526                	mv	a0,s1
    800035d8:	00003097          	auipc	ra,0x3
    800035dc:	fda080e7          	jalr	-38(ra) # 800065b2 <virtio_disk_rw>
    b->valid = 1;
    800035e0:	4785                	li	a5,1
    800035e2:	c09c                	sw	a5,0(s1)
  return b;
    800035e4:	b7c5                	j	800035c4 <bread+0xd0>

00000000800035e6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035e6:	1101                	addi	sp,sp,-32
    800035e8:	ec06                	sd	ra,24(sp)
    800035ea:	e822                	sd	s0,16(sp)
    800035ec:	e426                	sd	s1,8(sp)
    800035ee:	1000                	addi	s0,sp,32
    800035f0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035f2:	0541                	addi	a0,a0,16
    800035f4:	00001097          	auipc	ra,0x1
    800035f8:	472080e7          	jalr	1138(ra) # 80004a66 <holdingsleep>
    800035fc:	cd01                	beqz	a0,80003614 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035fe:	4585                	li	a1,1
    80003600:	8526                	mv	a0,s1
    80003602:	00003097          	auipc	ra,0x3
    80003606:	fb0080e7          	jalr	-80(ra) # 800065b2 <virtio_disk_rw>
}
    8000360a:	60e2                	ld	ra,24(sp)
    8000360c:	6442                	ld	s0,16(sp)
    8000360e:	64a2                	ld	s1,8(sp)
    80003610:	6105                	addi	sp,sp,32
    80003612:	8082                	ret
    panic("bwrite");
    80003614:	00005517          	auipc	a0,0x5
    80003618:	0c450513          	addi	a0,a0,196 # 800086d8 <syscalls+0x100>
    8000361c:	ffffd097          	auipc	ra,0xffffd
    80003620:	f24080e7          	jalr	-220(ra) # 80000540 <panic>

0000000080003624 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003624:	1101                	addi	sp,sp,-32
    80003626:	ec06                	sd	ra,24(sp)
    80003628:	e822                	sd	s0,16(sp)
    8000362a:	e426                	sd	s1,8(sp)
    8000362c:	e04a                	sd	s2,0(sp)
    8000362e:	1000                	addi	s0,sp,32
    80003630:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003632:	01050913          	addi	s2,a0,16
    80003636:	854a                	mv	a0,s2
    80003638:	00001097          	auipc	ra,0x1
    8000363c:	42e080e7          	jalr	1070(ra) # 80004a66 <holdingsleep>
    80003640:	c92d                	beqz	a0,800036b2 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003642:	854a                	mv	a0,s2
    80003644:	00001097          	auipc	ra,0x1
    80003648:	3de080e7          	jalr	990(ra) # 80004a22 <releasesleep>

  acquire(&bcache.lock);
    8000364c:	00053517          	auipc	a0,0x53
    80003650:	53c50513          	addi	a0,a0,1340 # 80056b88 <bcache>
    80003654:	ffffd097          	auipc	ra,0xffffd
    80003658:	718080e7          	jalr	1816(ra) # 80000d6c <acquire>
  b->refcnt--;
    8000365c:	40bc                	lw	a5,64(s1)
    8000365e:	37fd                	addiw	a5,a5,-1
    80003660:	0007871b          	sext.w	a4,a5
    80003664:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003666:	eb05                	bnez	a4,80003696 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003668:	68bc                	ld	a5,80(s1)
    8000366a:	64b8                	ld	a4,72(s1)
    8000366c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000366e:	64bc                	ld	a5,72(s1)
    80003670:	68b8                	ld	a4,80(s1)
    80003672:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003674:	0005b797          	auipc	a5,0x5b
    80003678:	51478793          	addi	a5,a5,1300 # 8005eb88 <bcache+0x8000>
    8000367c:	2b87b703          	ld	a4,696(a5)
    80003680:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003682:	0005b717          	auipc	a4,0x5b
    80003686:	76e70713          	addi	a4,a4,1902 # 8005edf0 <bcache+0x8268>
    8000368a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000368c:	2b87b703          	ld	a4,696(a5)
    80003690:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003692:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003696:	00053517          	auipc	a0,0x53
    8000369a:	4f250513          	addi	a0,a0,1266 # 80056b88 <bcache>
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	782080e7          	jalr	1922(ra) # 80000e20 <release>
}
    800036a6:	60e2                	ld	ra,24(sp)
    800036a8:	6442                	ld	s0,16(sp)
    800036aa:	64a2                	ld	s1,8(sp)
    800036ac:	6902                	ld	s2,0(sp)
    800036ae:	6105                	addi	sp,sp,32
    800036b0:	8082                	ret
    panic("brelse");
    800036b2:	00005517          	auipc	a0,0x5
    800036b6:	02e50513          	addi	a0,a0,46 # 800086e0 <syscalls+0x108>
    800036ba:	ffffd097          	auipc	ra,0xffffd
    800036be:	e86080e7          	jalr	-378(ra) # 80000540 <panic>

00000000800036c2 <bpin>:

void
bpin(struct buf *b) {
    800036c2:	1101                	addi	sp,sp,-32
    800036c4:	ec06                	sd	ra,24(sp)
    800036c6:	e822                	sd	s0,16(sp)
    800036c8:	e426                	sd	s1,8(sp)
    800036ca:	1000                	addi	s0,sp,32
    800036cc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036ce:	00053517          	auipc	a0,0x53
    800036d2:	4ba50513          	addi	a0,a0,1210 # 80056b88 <bcache>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	696080e7          	jalr	1686(ra) # 80000d6c <acquire>
  b->refcnt++;
    800036de:	40bc                	lw	a5,64(s1)
    800036e0:	2785                	addiw	a5,a5,1
    800036e2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036e4:	00053517          	auipc	a0,0x53
    800036e8:	4a450513          	addi	a0,a0,1188 # 80056b88 <bcache>
    800036ec:	ffffd097          	auipc	ra,0xffffd
    800036f0:	734080e7          	jalr	1844(ra) # 80000e20 <release>
}
    800036f4:	60e2                	ld	ra,24(sp)
    800036f6:	6442                	ld	s0,16(sp)
    800036f8:	64a2                	ld	s1,8(sp)
    800036fa:	6105                	addi	sp,sp,32
    800036fc:	8082                	ret

00000000800036fe <bunpin>:

void
bunpin(struct buf *b) {
    800036fe:	1101                	addi	sp,sp,-32
    80003700:	ec06                	sd	ra,24(sp)
    80003702:	e822                	sd	s0,16(sp)
    80003704:	e426                	sd	s1,8(sp)
    80003706:	1000                	addi	s0,sp,32
    80003708:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000370a:	00053517          	auipc	a0,0x53
    8000370e:	47e50513          	addi	a0,a0,1150 # 80056b88 <bcache>
    80003712:	ffffd097          	auipc	ra,0xffffd
    80003716:	65a080e7          	jalr	1626(ra) # 80000d6c <acquire>
  b->refcnt--;
    8000371a:	40bc                	lw	a5,64(s1)
    8000371c:	37fd                	addiw	a5,a5,-1
    8000371e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003720:	00053517          	auipc	a0,0x53
    80003724:	46850513          	addi	a0,a0,1128 # 80056b88 <bcache>
    80003728:	ffffd097          	auipc	ra,0xffffd
    8000372c:	6f8080e7          	jalr	1784(ra) # 80000e20 <release>
}
    80003730:	60e2                	ld	ra,24(sp)
    80003732:	6442                	ld	s0,16(sp)
    80003734:	64a2                	ld	s1,8(sp)
    80003736:	6105                	addi	sp,sp,32
    80003738:	8082                	ret

000000008000373a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000373a:	1101                	addi	sp,sp,-32
    8000373c:	ec06                	sd	ra,24(sp)
    8000373e:	e822                	sd	s0,16(sp)
    80003740:	e426                	sd	s1,8(sp)
    80003742:	e04a                	sd	s2,0(sp)
    80003744:	1000                	addi	s0,sp,32
    80003746:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003748:	00d5d59b          	srliw	a1,a1,0xd
    8000374c:	0005c797          	auipc	a5,0x5c
    80003750:	b187a783          	lw	a5,-1256(a5) # 8005f264 <sb+0x1c>
    80003754:	9dbd                	addw	a1,a1,a5
    80003756:	00000097          	auipc	ra,0x0
    8000375a:	d9e080e7          	jalr	-610(ra) # 800034f4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000375e:	0074f713          	andi	a4,s1,7
    80003762:	4785                	li	a5,1
    80003764:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003768:	14ce                	slli	s1,s1,0x33
    8000376a:	90d9                	srli	s1,s1,0x36
    8000376c:	00950733          	add	a4,a0,s1
    80003770:	05874703          	lbu	a4,88(a4)
    80003774:	00e7f6b3          	and	a3,a5,a4
    80003778:	c69d                	beqz	a3,800037a6 <bfree+0x6c>
    8000377a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000377c:	94aa                	add	s1,s1,a0
    8000377e:	fff7c793          	not	a5,a5
    80003782:	8f7d                	and	a4,a4,a5
    80003784:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003788:	00001097          	auipc	ra,0x1
    8000378c:	126080e7          	jalr	294(ra) # 800048ae <log_write>
  brelse(bp);
    80003790:	854a                	mv	a0,s2
    80003792:	00000097          	auipc	ra,0x0
    80003796:	e92080e7          	jalr	-366(ra) # 80003624 <brelse>
}
    8000379a:	60e2                	ld	ra,24(sp)
    8000379c:	6442                	ld	s0,16(sp)
    8000379e:	64a2                	ld	s1,8(sp)
    800037a0:	6902                	ld	s2,0(sp)
    800037a2:	6105                	addi	sp,sp,32
    800037a4:	8082                	ret
    panic("freeing free block");
    800037a6:	00005517          	auipc	a0,0x5
    800037aa:	f4250513          	addi	a0,a0,-190 # 800086e8 <syscalls+0x110>
    800037ae:	ffffd097          	auipc	ra,0xffffd
    800037b2:	d92080e7          	jalr	-622(ra) # 80000540 <panic>

00000000800037b6 <balloc>:
{
    800037b6:	711d                	addi	sp,sp,-96
    800037b8:	ec86                	sd	ra,88(sp)
    800037ba:	e8a2                	sd	s0,80(sp)
    800037bc:	e4a6                	sd	s1,72(sp)
    800037be:	e0ca                	sd	s2,64(sp)
    800037c0:	fc4e                	sd	s3,56(sp)
    800037c2:	f852                	sd	s4,48(sp)
    800037c4:	f456                	sd	s5,40(sp)
    800037c6:	f05a                	sd	s6,32(sp)
    800037c8:	ec5e                	sd	s7,24(sp)
    800037ca:	e862                	sd	s8,16(sp)
    800037cc:	e466                	sd	s9,8(sp)
    800037ce:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800037d0:	0005c797          	auipc	a5,0x5c
    800037d4:	a7c7a783          	lw	a5,-1412(a5) # 8005f24c <sb+0x4>
    800037d8:	cff5                	beqz	a5,800038d4 <balloc+0x11e>
    800037da:	8baa                	mv	s7,a0
    800037dc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037de:	0005cb17          	auipc	s6,0x5c
    800037e2:	a6ab0b13          	addi	s6,s6,-1430 # 8005f248 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037e6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800037e8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037ea:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037ec:	6c89                	lui	s9,0x2
    800037ee:	a061                	j	80003876 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800037f0:	97ca                	add	a5,a5,s2
    800037f2:	8e55                	or	a2,a2,a3
    800037f4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800037f8:	854a                	mv	a0,s2
    800037fa:	00001097          	auipc	ra,0x1
    800037fe:	0b4080e7          	jalr	180(ra) # 800048ae <log_write>
        brelse(bp);
    80003802:	854a                	mv	a0,s2
    80003804:	00000097          	auipc	ra,0x0
    80003808:	e20080e7          	jalr	-480(ra) # 80003624 <brelse>
  bp = bread(dev, bno);
    8000380c:	85a6                	mv	a1,s1
    8000380e:	855e                	mv	a0,s7
    80003810:	00000097          	auipc	ra,0x0
    80003814:	ce4080e7          	jalr	-796(ra) # 800034f4 <bread>
    80003818:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000381a:	40000613          	li	a2,1024
    8000381e:	4581                	li	a1,0
    80003820:	05850513          	addi	a0,a0,88
    80003824:	ffffd097          	auipc	ra,0xffffd
    80003828:	644080e7          	jalr	1604(ra) # 80000e68 <memset>
  log_write(bp);
    8000382c:	854a                	mv	a0,s2
    8000382e:	00001097          	auipc	ra,0x1
    80003832:	080080e7          	jalr	128(ra) # 800048ae <log_write>
  brelse(bp);
    80003836:	854a                	mv	a0,s2
    80003838:	00000097          	auipc	ra,0x0
    8000383c:	dec080e7          	jalr	-532(ra) # 80003624 <brelse>
}
    80003840:	8526                	mv	a0,s1
    80003842:	60e6                	ld	ra,88(sp)
    80003844:	6446                	ld	s0,80(sp)
    80003846:	64a6                	ld	s1,72(sp)
    80003848:	6906                	ld	s2,64(sp)
    8000384a:	79e2                	ld	s3,56(sp)
    8000384c:	7a42                	ld	s4,48(sp)
    8000384e:	7aa2                	ld	s5,40(sp)
    80003850:	7b02                	ld	s6,32(sp)
    80003852:	6be2                	ld	s7,24(sp)
    80003854:	6c42                	ld	s8,16(sp)
    80003856:	6ca2                	ld	s9,8(sp)
    80003858:	6125                	addi	sp,sp,96
    8000385a:	8082                	ret
    brelse(bp);
    8000385c:	854a                	mv	a0,s2
    8000385e:	00000097          	auipc	ra,0x0
    80003862:	dc6080e7          	jalr	-570(ra) # 80003624 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003866:	015c87bb          	addw	a5,s9,s5
    8000386a:	00078a9b          	sext.w	s5,a5
    8000386e:	004b2703          	lw	a4,4(s6)
    80003872:	06eaf163          	bgeu	s5,a4,800038d4 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003876:	41fad79b          	sraiw	a5,s5,0x1f
    8000387a:	0137d79b          	srliw	a5,a5,0x13
    8000387e:	015787bb          	addw	a5,a5,s5
    80003882:	40d7d79b          	sraiw	a5,a5,0xd
    80003886:	01cb2583          	lw	a1,28(s6)
    8000388a:	9dbd                	addw	a1,a1,a5
    8000388c:	855e                	mv	a0,s7
    8000388e:	00000097          	auipc	ra,0x0
    80003892:	c66080e7          	jalr	-922(ra) # 800034f4 <bread>
    80003896:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003898:	004b2503          	lw	a0,4(s6)
    8000389c:	000a849b          	sext.w	s1,s5
    800038a0:	8762                	mv	a4,s8
    800038a2:	faa4fde3          	bgeu	s1,a0,8000385c <balloc+0xa6>
      m = 1 << (bi % 8);
    800038a6:	00777693          	andi	a3,a4,7
    800038aa:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800038ae:	41f7579b          	sraiw	a5,a4,0x1f
    800038b2:	01d7d79b          	srliw	a5,a5,0x1d
    800038b6:	9fb9                	addw	a5,a5,a4
    800038b8:	4037d79b          	sraiw	a5,a5,0x3
    800038bc:	00f90633          	add	a2,s2,a5
    800038c0:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800038c4:	00c6f5b3          	and	a1,a3,a2
    800038c8:	d585                	beqz	a1,800037f0 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038ca:	2705                	addiw	a4,a4,1
    800038cc:	2485                	addiw	s1,s1,1
    800038ce:	fd471ae3          	bne	a4,s4,800038a2 <balloc+0xec>
    800038d2:	b769                	j	8000385c <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800038d4:	00005517          	auipc	a0,0x5
    800038d8:	e2c50513          	addi	a0,a0,-468 # 80008700 <syscalls+0x128>
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	cc0080e7          	jalr	-832(ra) # 8000059c <printf>
  return 0;
    800038e4:	4481                	li	s1,0
    800038e6:	bfa9                	j	80003840 <balloc+0x8a>

00000000800038e8 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800038e8:	7179                	addi	sp,sp,-48
    800038ea:	f406                	sd	ra,40(sp)
    800038ec:	f022                	sd	s0,32(sp)
    800038ee:	ec26                	sd	s1,24(sp)
    800038f0:	e84a                	sd	s2,16(sp)
    800038f2:	e44e                	sd	s3,8(sp)
    800038f4:	e052                	sd	s4,0(sp)
    800038f6:	1800                	addi	s0,sp,48
    800038f8:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038fa:	47ad                	li	a5,11
    800038fc:	02b7e863          	bltu	a5,a1,8000392c <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003900:	02059793          	slli	a5,a1,0x20
    80003904:	01e7d593          	srli	a1,a5,0x1e
    80003908:	00b504b3          	add	s1,a0,a1
    8000390c:	0504a903          	lw	s2,80(s1)
    80003910:	06091e63          	bnez	s2,8000398c <bmap+0xa4>
      addr = balloc(ip->dev);
    80003914:	4108                	lw	a0,0(a0)
    80003916:	00000097          	auipc	ra,0x0
    8000391a:	ea0080e7          	jalr	-352(ra) # 800037b6 <balloc>
    8000391e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003922:	06090563          	beqz	s2,8000398c <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003926:	0524a823          	sw	s2,80(s1)
    8000392a:	a08d                	j	8000398c <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000392c:	ff45849b          	addiw	s1,a1,-12
    80003930:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003934:	0ff00793          	li	a5,255
    80003938:	08e7e563          	bltu	a5,a4,800039c2 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000393c:	08052903          	lw	s2,128(a0)
    80003940:	00091d63          	bnez	s2,8000395a <bmap+0x72>
      addr = balloc(ip->dev);
    80003944:	4108                	lw	a0,0(a0)
    80003946:	00000097          	auipc	ra,0x0
    8000394a:	e70080e7          	jalr	-400(ra) # 800037b6 <balloc>
    8000394e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003952:	02090d63          	beqz	s2,8000398c <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003956:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000395a:	85ca                	mv	a1,s2
    8000395c:	0009a503          	lw	a0,0(s3)
    80003960:	00000097          	auipc	ra,0x0
    80003964:	b94080e7          	jalr	-1132(ra) # 800034f4 <bread>
    80003968:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000396a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000396e:	02049713          	slli	a4,s1,0x20
    80003972:	01e75593          	srli	a1,a4,0x1e
    80003976:	00b784b3          	add	s1,a5,a1
    8000397a:	0004a903          	lw	s2,0(s1)
    8000397e:	02090063          	beqz	s2,8000399e <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003982:	8552                	mv	a0,s4
    80003984:	00000097          	auipc	ra,0x0
    80003988:	ca0080e7          	jalr	-864(ra) # 80003624 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000398c:	854a                	mv	a0,s2
    8000398e:	70a2                	ld	ra,40(sp)
    80003990:	7402                	ld	s0,32(sp)
    80003992:	64e2                	ld	s1,24(sp)
    80003994:	6942                	ld	s2,16(sp)
    80003996:	69a2                	ld	s3,8(sp)
    80003998:	6a02                	ld	s4,0(sp)
    8000399a:	6145                	addi	sp,sp,48
    8000399c:	8082                	ret
      addr = balloc(ip->dev);
    8000399e:	0009a503          	lw	a0,0(s3)
    800039a2:	00000097          	auipc	ra,0x0
    800039a6:	e14080e7          	jalr	-492(ra) # 800037b6 <balloc>
    800039aa:	0005091b          	sext.w	s2,a0
      if(addr){
    800039ae:	fc090ae3          	beqz	s2,80003982 <bmap+0x9a>
        a[bn] = addr;
    800039b2:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800039b6:	8552                	mv	a0,s4
    800039b8:	00001097          	auipc	ra,0x1
    800039bc:	ef6080e7          	jalr	-266(ra) # 800048ae <log_write>
    800039c0:	b7c9                	j	80003982 <bmap+0x9a>
  panic("bmap: out of range");
    800039c2:	00005517          	auipc	a0,0x5
    800039c6:	d5650513          	addi	a0,a0,-682 # 80008718 <syscalls+0x140>
    800039ca:	ffffd097          	auipc	ra,0xffffd
    800039ce:	b76080e7          	jalr	-1162(ra) # 80000540 <panic>

00000000800039d2 <iget>:
{
    800039d2:	7179                	addi	sp,sp,-48
    800039d4:	f406                	sd	ra,40(sp)
    800039d6:	f022                	sd	s0,32(sp)
    800039d8:	ec26                	sd	s1,24(sp)
    800039da:	e84a                	sd	s2,16(sp)
    800039dc:	e44e                	sd	s3,8(sp)
    800039de:	e052                	sd	s4,0(sp)
    800039e0:	1800                	addi	s0,sp,48
    800039e2:	89aa                	mv	s3,a0
    800039e4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800039e6:	0005c517          	auipc	a0,0x5c
    800039ea:	88250513          	addi	a0,a0,-1918 # 8005f268 <itable>
    800039ee:	ffffd097          	auipc	ra,0xffffd
    800039f2:	37e080e7          	jalr	894(ra) # 80000d6c <acquire>
  empty = 0;
    800039f6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039f8:	0005c497          	auipc	s1,0x5c
    800039fc:	88848493          	addi	s1,s1,-1912 # 8005f280 <itable+0x18>
    80003a00:	0005d697          	auipc	a3,0x5d
    80003a04:	31068693          	addi	a3,a3,784 # 80060d10 <log>
    80003a08:	a039                	j	80003a16 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a0a:	02090b63          	beqz	s2,80003a40 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a0e:	08848493          	addi	s1,s1,136
    80003a12:	02d48a63          	beq	s1,a3,80003a46 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a16:	449c                	lw	a5,8(s1)
    80003a18:	fef059e3          	blez	a5,80003a0a <iget+0x38>
    80003a1c:	4098                	lw	a4,0(s1)
    80003a1e:	ff3716e3          	bne	a4,s3,80003a0a <iget+0x38>
    80003a22:	40d8                	lw	a4,4(s1)
    80003a24:	ff4713e3          	bne	a4,s4,80003a0a <iget+0x38>
      ip->ref++;
    80003a28:	2785                	addiw	a5,a5,1
    80003a2a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a2c:	0005c517          	auipc	a0,0x5c
    80003a30:	83c50513          	addi	a0,a0,-1988 # 8005f268 <itable>
    80003a34:	ffffd097          	auipc	ra,0xffffd
    80003a38:	3ec080e7          	jalr	1004(ra) # 80000e20 <release>
      return ip;
    80003a3c:	8926                	mv	s2,s1
    80003a3e:	a03d                	j	80003a6c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a40:	f7f9                	bnez	a5,80003a0e <iget+0x3c>
    80003a42:	8926                	mv	s2,s1
    80003a44:	b7e9                	j	80003a0e <iget+0x3c>
  if(empty == 0)
    80003a46:	02090c63          	beqz	s2,80003a7e <iget+0xac>
  ip->dev = dev;
    80003a4a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a4e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a52:	4785                	li	a5,1
    80003a54:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a58:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a5c:	0005c517          	auipc	a0,0x5c
    80003a60:	80c50513          	addi	a0,a0,-2036 # 8005f268 <itable>
    80003a64:	ffffd097          	auipc	ra,0xffffd
    80003a68:	3bc080e7          	jalr	956(ra) # 80000e20 <release>
}
    80003a6c:	854a                	mv	a0,s2
    80003a6e:	70a2                	ld	ra,40(sp)
    80003a70:	7402                	ld	s0,32(sp)
    80003a72:	64e2                	ld	s1,24(sp)
    80003a74:	6942                	ld	s2,16(sp)
    80003a76:	69a2                	ld	s3,8(sp)
    80003a78:	6a02                	ld	s4,0(sp)
    80003a7a:	6145                	addi	sp,sp,48
    80003a7c:	8082                	ret
    panic("iget: no inodes");
    80003a7e:	00005517          	auipc	a0,0x5
    80003a82:	cb250513          	addi	a0,a0,-846 # 80008730 <syscalls+0x158>
    80003a86:	ffffd097          	auipc	ra,0xffffd
    80003a8a:	aba080e7          	jalr	-1350(ra) # 80000540 <panic>

0000000080003a8e <fsinit>:
fsinit(int dev) {
    80003a8e:	7179                	addi	sp,sp,-48
    80003a90:	f406                	sd	ra,40(sp)
    80003a92:	f022                	sd	s0,32(sp)
    80003a94:	ec26                	sd	s1,24(sp)
    80003a96:	e84a                	sd	s2,16(sp)
    80003a98:	e44e                	sd	s3,8(sp)
    80003a9a:	1800                	addi	s0,sp,48
    80003a9c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a9e:	4585                	li	a1,1
    80003aa0:	00000097          	auipc	ra,0x0
    80003aa4:	a54080e7          	jalr	-1452(ra) # 800034f4 <bread>
    80003aa8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003aaa:	0005b997          	auipc	s3,0x5b
    80003aae:	79e98993          	addi	s3,s3,1950 # 8005f248 <sb>
    80003ab2:	02000613          	li	a2,32
    80003ab6:	05850593          	addi	a1,a0,88
    80003aba:	854e                	mv	a0,s3
    80003abc:	ffffd097          	auipc	ra,0xffffd
    80003ac0:	408080e7          	jalr	1032(ra) # 80000ec4 <memmove>
  brelse(bp);
    80003ac4:	8526                	mv	a0,s1
    80003ac6:	00000097          	auipc	ra,0x0
    80003aca:	b5e080e7          	jalr	-1186(ra) # 80003624 <brelse>
  if(sb.magic != FSMAGIC)
    80003ace:	0009a703          	lw	a4,0(s3)
    80003ad2:	102037b7          	lui	a5,0x10203
    80003ad6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ada:	02f71263          	bne	a4,a5,80003afe <fsinit+0x70>
  initlog(dev, &sb);
    80003ade:	0005b597          	auipc	a1,0x5b
    80003ae2:	76a58593          	addi	a1,a1,1898 # 8005f248 <sb>
    80003ae6:	854a                	mv	a0,s2
    80003ae8:	00001097          	auipc	ra,0x1
    80003aec:	b4a080e7          	jalr	-1206(ra) # 80004632 <initlog>
}
    80003af0:	70a2                	ld	ra,40(sp)
    80003af2:	7402                	ld	s0,32(sp)
    80003af4:	64e2                	ld	s1,24(sp)
    80003af6:	6942                	ld	s2,16(sp)
    80003af8:	69a2                	ld	s3,8(sp)
    80003afa:	6145                	addi	sp,sp,48
    80003afc:	8082                	ret
    panic("invalid file system");
    80003afe:	00005517          	auipc	a0,0x5
    80003b02:	c4250513          	addi	a0,a0,-958 # 80008740 <syscalls+0x168>
    80003b06:	ffffd097          	auipc	ra,0xffffd
    80003b0a:	a3a080e7          	jalr	-1478(ra) # 80000540 <panic>

0000000080003b0e <iinit>:
{
    80003b0e:	7179                	addi	sp,sp,-48
    80003b10:	f406                	sd	ra,40(sp)
    80003b12:	f022                	sd	s0,32(sp)
    80003b14:	ec26                	sd	s1,24(sp)
    80003b16:	e84a                	sd	s2,16(sp)
    80003b18:	e44e                	sd	s3,8(sp)
    80003b1a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b1c:	00005597          	auipc	a1,0x5
    80003b20:	c3c58593          	addi	a1,a1,-964 # 80008758 <syscalls+0x180>
    80003b24:	0005b517          	auipc	a0,0x5b
    80003b28:	74450513          	addi	a0,a0,1860 # 8005f268 <itable>
    80003b2c:	ffffd097          	auipc	ra,0xffffd
    80003b30:	1b0080e7          	jalr	432(ra) # 80000cdc <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b34:	0005b497          	auipc	s1,0x5b
    80003b38:	75c48493          	addi	s1,s1,1884 # 8005f290 <itable+0x28>
    80003b3c:	0005d997          	auipc	s3,0x5d
    80003b40:	1e498993          	addi	s3,s3,484 # 80060d20 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b44:	00005917          	auipc	s2,0x5
    80003b48:	c1c90913          	addi	s2,s2,-996 # 80008760 <syscalls+0x188>
    80003b4c:	85ca                	mv	a1,s2
    80003b4e:	8526                	mv	a0,s1
    80003b50:	00001097          	auipc	ra,0x1
    80003b54:	e42080e7          	jalr	-446(ra) # 80004992 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b58:	08848493          	addi	s1,s1,136
    80003b5c:	ff3498e3          	bne	s1,s3,80003b4c <iinit+0x3e>
}
    80003b60:	70a2                	ld	ra,40(sp)
    80003b62:	7402                	ld	s0,32(sp)
    80003b64:	64e2                	ld	s1,24(sp)
    80003b66:	6942                	ld	s2,16(sp)
    80003b68:	69a2                	ld	s3,8(sp)
    80003b6a:	6145                	addi	sp,sp,48
    80003b6c:	8082                	ret

0000000080003b6e <ialloc>:
{
    80003b6e:	715d                	addi	sp,sp,-80
    80003b70:	e486                	sd	ra,72(sp)
    80003b72:	e0a2                	sd	s0,64(sp)
    80003b74:	fc26                	sd	s1,56(sp)
    80003b76:	f84a                	sd	s2,48(sp)
    80003b78:	f44e                	sd	s3,40(sp)
    80003b7a:	f052                	sd	s4,32(sp)
    80003b7c:	ec56                	sd	s5,24(sp)
    80003b7e:	e85a                	sd	s6,16(sp)
    80003b80:	e45e                	sd	s7,8(sp)
    80003b82:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b84:	0005b717          	auipc	a4,0x5b
    80003b88:	6d072703          	lw	a4,1744(a4) # 8005f254 <sb+0xc>
    80003b8c:	4785                	li	a5,1
    80003b8e:	04e7fa63          	bgeu	a5,a4,80003be2 <ialloc+0x74>
    80003b92:	8aaa                	mv	s5,a0
    80003b94:	8bae                	mv	s7,a1
    80003b96:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b98:	0005ba17          	auipc	s4,0x5b
    80003b9c:	6b0a0a13          	addi	s4,s4,1712 # 8005f248 <sb>
    80003ba0:	00048b1b          	sext.w	s6,s1
    80003ba4:	0044d593          	srli	a1,s1,0x4
    80003ba8:	018a2783          	lw	a5,24(s4)
    80003bac:	9dbd                	addw	a1,a1,a5
    80003bae:	8556                	mv	a0,s5
    80003bb0:	00000097          	auipc	ra,0x0
    80003bb4:	944080e7          	jalr	-1724(ra) # 800034f4 <bread>
    80003bb8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003bba:	05850993          	addi	s3,a0,88
    80003bbe:	00f4f793          	andi	a5,s1,15
    80003bc2:	079a                	slli	a5,a5,0x6
    80003bc4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003bc6:	00099783          	lh	a5,0(s3)
    80003bca:	c3a1                	beqz	a5,80003c0a <ialloc+0x9c>
    brelse(bp);
    80003bcc:	00000097          	auipc	ra,0x0
    80003bd0:	a58080e7          	jalr	-1448(ra) # 80003624 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003bd4:	0485                	addi	s1,s1,1
    80003bd6:	00ca2703          	lw	a4,12(s4)
    80003bda:	0004879b          	sext.w	a5,s1
    80003bde:	fce7e1e3          	bltu	a5,a4,80003ba0 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003be2:	00005517          	auipc	a0,0x5
    80003be6:	b8650513          	addi	a0,a0,-1146 # 80008768 <syscalls+0x190>
    80003bea:	ffffd097          	auipc	ra,0xffffd
    80003bee:	9b2080e7          	jalr	-1614(ra) # 8000059c <printf>
  return 0;
    80003bf2:	4501                	li	a0,0
}
    80003bf4:	60a6                	ld	ra,72(sp)
    80003bf6:	6406                	ld	s0,64(sp)
    80003bf8:	74e2                	ld	s1,56(sp)
    80003bfa:	7942                	ld	s2,48(sp)
    80003bfc:	79a2                	ld	s3,40(sp)
    80003bfe:	7a02                	ld	s4,32(sp)
    80003c00:	6ae2                	ld	s5,24(sp)
    80003c02:	6b42                	ld	s6,16(sp)
    80003c04:	6ba2                	ld	s7,8(sp)
    80003c06:	6161                	addi	sp,sp,80
    80003c08:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003c0a:	04000613          	li	a2,64
    80003c0e:	4581                	li	a1,0
    80003c10:	854e                	mv	a0,s3
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	256080e7          	jalr	598(ra) # 80000e68 <memset>
      dip->type = type;
    80003c1a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c1e:	854a                	mv	a0,s2
    80003c20:	00001097          	auipc	ra,0x1
    80003c24:	c8e080e7          	jalr	-882(ra) # 800048ae <log_write>
      brelse(bp);
    80003c28:	854a                	mv	a0,s2
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	9fa080e7          	jalr	-1542(ra) # 80003624 <brelse>
      return iget(dev, inum);
    80003c32:	85da                	mv	a1,s6
    80003c34:	8556                	mv	a0,s5
    80003c36:	00000097          	auipc	ra,0x0
    80003c3a:	d9c080e7          	jalr	-612(ra) # 800039d2 <iget>
    80003c3e:	bf5d                	j	80003bf4 <ialloc+0x86>

0000000080003c40 <iupdate>:
{
    80003c40:	1101                	addi	sp,sp,-32
    80003c42:	ec06                	sd	ra,24(sp)
    80003c44:	e822                	sd	s0,16(sp)
    80003c46:	e426                	sd	s1,8(sp)
    80003c48:	e04a                	sd	s2,0(sp)
    80003c4a:	1000                	addi	s0,sp,32
    80003c4c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c4e:	415c                	lw	a5,4(a0)
    80003c50:	0047d79b          	srliw	a5,a5,0x4
    80003c54:	0005b597          	auipc	a1,0x5b
    80003c58:	60c5a583          	lw	a1,1548(a1) # 8005f260 <sb+0x18>
    80003c5c:	9dbd                	addw	a1,a1,a5
    80003c5e:	4108                	lw	a0,0(a0)
    80003c60:	00000097          	auipc	ra,0x0
    80003c64:	894080e7          	jalr	-1900(ra) # 800034f4 <bread>
    80003c68:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c6a:	05850793          	addi	a5,a0,88
    80003c6e:	40d8                	lw	a4,4(s1)
    80003c70:	8b3d                	andi	a4,a4,15
    80003c72:	071a                	slli	a4,a4,0x6
    80003c74:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003c76:	04449703          	lh	a4,68(s1)
    80003c7a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003c7e:	04649703          	lh	a4,70(s1)
    80003c82:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003c86:	04849703          	lh	a4,72(s1)
    80003c8a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003c8e:	04a49703          	lh	a4,74(s1)
    80003c92:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003c96:	44f8                	lw	a4,76(s1)
    80003c98:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c9a:	03400613          	li	a2,52
    80003c9e:	05048593          	addi	a1,s1,80
    80003ca2:	00c78513          	addi	a0,a5,12
    80003ca6:	ffffd097          	auipc	ra,0xffffd
    80003caa:	21e080e7          	jalr	542(ra) # 80000ec4 <memmove>
  log_write(bp);
    80003cae:	854a                	mv	a0,s2
    80003cb0:	00001097          	auipc	ra,0x1
    80003cb4:	bfe080e7          	jalr	-1026(ra) # 800048ae <log_write>
  brelse(bp);
    80003cb8:	854a                	mv	a0,s2
    80003cba:	00000097          	auipc	ra,0x0
    80003cbe:	96a080e7          	jalr	-1686(ra) # 80003624 <brelse>
}
    80003cc2:	60e2                	ld	ra,24(sp)
    80003cc4:	6442                	ld	s0,16(sp)
    80003cc6:	64a2                	ld	s1,8(sp)
    80003cc8:	6902                	ld	s2,0(sp)
    80003cca:	6105                	addi	sp,sp,32
    80003ccc:	8082                	ret

0000000080003cce <idup>:
{
    80003cce:	1101                	addi	sp,sp,-32
    80003cd0:	ec06                	sd	ra,24(sp)
    80003cd2:	e822                	sd	s0,16(sp)
    80003cd4:	e426                	sd	s1,8(sp)
    80003cd6:	1000                	addi	s0,sp,32
    80003cd8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cda:	0005b517          	auipc	a0,0x5b
    80003cde:	58e50513          	addi	a0,a0,1422 # 8005f268 <itable>
    80003ce2:	ffffd097          	auipc	ra,0xffffd
    80003ce6:	08a080e7          	jalr	138(ra) # 80000d6c <acquire>
  ip->ref++;
    80003cea:	449c                	lw	a5,8(s1)
    80003cec:	2785                	addiw	a5,a5,1
    80003cee:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cf0:	0005b517          	auipc	a0,0x5b
    80003cf4:	57850513          	addi	a0,a0,1400 # 8005f268 <itable>
    80003cf8:	ffffd097          	auipc	ra,0xffffd
    80003cfc:	128080e7          	jalr	296(ra) # 80000e20 <release>
}
    80003d00:	8526                	mv	a0,s1
    80003d02:	60e2                	ld	ra,24(sp)
    80003d04:	6442                	ld	s0,16(sp)
    80003d06:	64a2                	ld	s1,8(sp)
    80003d08:	6105                	addi	sp,sp,32
    80003d0a:	8082                	ret

0000000080003d0c <ilock>:
{
    80003d0c:	1101                	addi	sp,sp,-32
    80003d0e:	ec06                	sd	ra,24(sp)
    80003d10:	e822                	sd	s0,16(sp)
    80003d12:	e426                	sd	s1,8(sp)
    80003d14:	e04a                	sd	s2,0(sp)
    80003d16:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d18:	c115                	beqz	a0,80003d3c <ilock+0x30>
    80003d1a:	84aa                	mv	s1,a0
    80003d1c:	451c                	lw	a5,8(a0)
    80003d1e:	00f05f63          	blez	a5,80003d3c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d22:	0541                	addi	a0,a0,16
    80003d24:	00001097          	auipc	ra,0x1
    80003d28:	ca8080e7          	jalr	-856(ra) # 800049cc <acquiresleep>
  if(ip->valid == 0){
    80003d2c:	40bc                	lw	a5,64(s1)
    80003d2e:	cf99                	beqz	a5,80003d4c <ilock+0x40>
}
    80003d30:	60e2                	ld	ra,24(sp)
    80003d32:	6442                	ld	s0,16(sp)
    80003d34:	64a2                	ld	s1,8(sp)
    80003d36:	6902                	ld	s2,0(sp)
    80003d38:	6105                	addi	sp,sp,32
    80003d3a:	8082                	ret
    panic("ilock");
    80003d3c:	00005517          	auipc	a0,0x5
    80003d40:	a4450513          	addi	a0,a0,-1468 # 80008780 <syscalls+0x1a8>
    80003d44:	ffffc097          	auipc	ra,0xffffc
    80003d48:	7fc080e7          	jalr	2044(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d4c:	40dc                	lw	a5,4(s1)
    80003d4e:	0047d79b          	srliw	a5,a5,0x4
    80003d52:	0005b597          	auipc	a1,0x5b
    80003d56:	50e5a583          	lw	a1,1294(a1) # 8005f260 <sb+0x18>
    80003d5a:	9dbd                	addw	a1,a1,a5
    80003d5c:	4088                	lw	a0,0(s1)
    80003d5e:	fffff097          	auipc	ra,0xfffff
    80003d62:	796080e7          	jalr	1942(ra) # 800034f4 <bread>
    80003d66:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d68:	05850593          	addi	a1,a0,88
    80003d6c:	40dc                	lw	a5,4(s1)
    80003d6e:	8bbd                	andi	a5,a5,15
    80003d70:	079a                	slli	a5,a5,0x6
    80003d72:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d74:	00059783          	lh	a5,0(a1)
    80003d78:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d7c:	00259783          	lh	a5,2(a1)
    80003d80:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d84:	00459783          	lh	a5,4(a1)
    80003d88:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d8c:	00659783          	lh	a5,6(a1)
    80003d90:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d94:	459c                	lw	a5,8(a1)
    80003d96:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d98:	03400613          	li	a2,52
    80003d9c:	05b1                	addi	a1,a1,12
    80003d9e:	05048513          	addi	a0,s1,80
    80003da2:	ffffd097          	auipc	ra,0xffffd
    80003da6:	122080e7          	jalr	290(ra) # 80000ec4 <memmove>
    brelse(bp);
    80003daa:	854a                	mv	a0,s2
    80003dac:	00000097          	auipc	ra,0x0
    80003db0:	878080e7          	jalr	-1928(ra) # 80003624 <brelse>
    ip->valid = 1;
    80003db4:	4785                	li	a5,1
    80003db6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003db8:	04449783          	lh	a5,68(s1)
    80003dbc:	fbb5                	bnez	a5,80003d30 <ilock+0x24>
      panic("ilock: no type");
    80003dbe:	00005517          	auipc	a0,0x5
    80003dc2:	9ca50513          	addi	a0,a0,-1590 # 80008788 <syscalls+0x1b0>
    80003dc6:	ffffc097          	auipc	ra,0xffffc
    80003dca:	77a080e7          	jalr	1914(ra) # 80000540 <panic>

0000000080003dce <iunlock>:
{
    80003dce:	1101                	addi	sp,sp,-32
    80003dd0:	ec06                	sd	ra,24(sp)
    80003dd2:	e822                	sd	s0,16(sp)
    80003dd4:	e426                	sd	s1,8(sp)
    80003dd6:	e04a                	sd	s2,0(sp)
    80003dd8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003dda:	c905                	beqz	a0,80003e0a <iunlock+0x3c>
    80003ddc:	84aa                	mv	s1,a0
    80003dde:	01050913          	addi	s2,a0,16
    80003de2:	854a                	mv	a0,s2
    80003de4:	00001097          	auipc	ra,0x1
    80003de8:	c82080e7          	jalr	-894(ra) # 80004a66 <holdingsleep>
    80003dec:	cd19                	beqz	a0,80003e0a <iunlock+0x3c>
    80003dee:	449c                	lw	a5,8(s1)
    80003df0:	00f05d63          	blez	a5,80003e0a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003df4:	854a                	mv	a0,s2
    80003df6:	00001097          	auipc	ra,0x1
    80003dfa:	c2c080e7          	jalr	-980(ra) # 80004a22 <releasesleep>
}
    80003dfe:	60e2                	ld	ra,24(sp)
    80003e00:	6442                	ld	s0,16(sp)
    80003e02:	64a2                	ld	s1,8(sp)
    80003e04:	6902                	ld	s2,0(sp)
    80003e06:	6105                	addi	sp,sp,32
    80003e08:	8082                	ret
    panic("iunlock");
    80003e0a:	00005517          	auipc	a0,0x5
    80003e0e:	98e50513          	addi	a0,a0,-1650 # 80008798 <syscalls+0x1c0>
    80003e12:	ffffc097          	auipc	ra,0xffffc
    80003e16:	72e080e7          	jalr	1838(ra) # 80000540 <panic>

0000000080003e1a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e1a:	7179                	addi	sp,sp,-48
    80003e1c:	f406                	sd	ra,40(sp)
    80003e1e:	f022                	sd	s0,32(sp)
    80003e20:	ec26                	sd	s1,24(sp)
    80003e22:	e84a                	sd	s2,16(sp)
    80003e24:	e44e                	sd	s3,8(sp)
    80003e26:	e052                	sd	s4,0(sp)
    80003e28:	1800                	addi	s0,sp,48
    80003e2a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e2c:	05050493          	addi	s1,a0,80
    80003e30:	08050913          	addi	s2,a0,128
    80003e34:	a021                	j	80003e3c <itrunc+0x22>
    80003e36:	0491                	addi	s1,s1,4
    80003e38:	01248d63          	beq	s1,s2,80003e52 <itrunc+0x38>
    if(ip->addrs[i]){
    80003e3c:	408c                	lw	a1,0(s1)
    80003e3e:	dde5                	beqz	a1,80003e36 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e40:	0009a503          	lw	a0,0(s3)
    80003e44:	00000097          	auipc	ra,0x0
    80003e48:	8f6080e7          	jalr	-1802(ra) # 8000373a <bfree>
      ip->addrs[i] = 0;
    80003e4c:	0004a023          	sw	zero,0(s1)
    80003e50:	b7dd                	j	80003e36 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e52:	0809a583          	lw	a1,128(s3)
    80003e56:	e185                	bnez	a1,80003e76 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e58:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e5c:	854e                	mv	a0,s3
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	de2080e7          	jalr	-542(ra) # 80003c40 <iupdate>
}
    80003e66:	70a2                	ld	ra,40(sp)
    80003e68:	7402                	ld	s0,32(sp)
    80003e6a:	64e2                	ld	s1,24(sp)
    80003e6c:	6942                	ld	s2,16(sp)
    80003e6e:	69a2                	ld	s3,8(sp)
    80003e70:	6a02                	ld	s4,0(sp)
    80003e72:	6145                	addi	sp,sp,48
    80003e74:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e76:	0009a503          	lw	a0,0(s3)
    80003e7a:	fffff097          	auipc	ra,0xfffff
    80003e7e:	67a080e7          	jalr	1658(ra) # 800034f4 <bread>
    80003e82:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e84:	05850493          	addi	s1,a0,88
    80003e88:	45850913          	addi	s2,a0,1112
    80003e8c:	a021                	j	80003e94 <itrunc+0x7a>
    80003e8e:	0491                	addi	s1,s1,4
    80003e90:	01248b63          	beq	s1,s2,80003ea6 <itrunc+0x8c>
      if(a[j])
    80003e94:	408c                	lw	a1,0(s1)
    80003e96:	dde5                	beqz	a1,80003e8e <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003e98:	0009a503          	lw	a0,0(s3)
    80003e9c:	00000097          	auipc	ra,0x0
    80003ea0:	89e080e7          	jalr	-1890(ra) # 8000373a <bfree>
    80003ea4:	b7ed                	j	80003e8e <itrunc+0x74>
    brelse(bp);
    80003ea6:	8552                	mv	a0,s4
    80003ea8:	fffff097          	auipc	ra,0xfffff
    80003eac:	77c080e7          	jalr	1916(ra) # 80003624 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003eb0:	0809a583          	lw	a1,128(s3)
    80003eb4:	0009a503          	lw	a0,0(s3)
    80003eb8:	00000097          	auipc	ra,0x0
    80003ebc:	882080e7          	jalr	-1918(ra) # 8000373a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ec0:	0809a023          	sw	zero,128(s3)
    80003ec4:	bf51                	j	80003e58 <itrunc+0x3e>

0000000080003ec6 <iput>:
{
    80003ec6:	1101                	addi	sp,sp,-32
    80003ec8:	ec06                	sd	ra,24(sp)
    80003eca:	e822                	sd	s0,16(sp)
    80003ecc:	e426                	sd	s1,8(sp)
    80003ece:	e04a                	sd	s2,0(sp)
    80003ed0:	1000                	addi	s0,sp,32
    80003ed2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ed4:	0005b517          	auipc	a0,0x5b
    80003ed8:	39450513          	addi	a0,a0,916 # 8005f268 <itable>
    80003edc:	ffffd097          	auipc	ra,0xffffd
    80003ee0:	e90080e7          	jalr	-368(ra) # 80000d6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ee4:	4498                	lw	a4,8(s1)
    80003ee6:	4785                	li	a5,1
    80003ee8:	02f70363          	beq	a4,a5,80003f0e <iput+0x48>
  ip->ref--;
    80003eec:	449c                	lw	a5,8(s1)
    80003eee:	37fd                	addiw	a5,a5,-1
    80003ef0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ef2:	0005b517          	auipc	a0,0x5b
    80003ef6:	37650513          	addi	a0,a0,886 # 8005f268 <itable>
    80003efa:	ffffd097          	auipc	ra,0xffffd
    80003efe:	f26080e7          	jalr	-218(ra) # 80000e20 <release>
}
    80003f02:	60e2                	ld	ra,24(sp)
    80003f04:	6442                	ld	s0,16(sp)
    80003f06:	64a2                	ld	s1,8(sp)
    80003f08:	6902                	ld	s2,0(sp)
    80003f0a:	6105                	addi	sp,sp,32
    80003f0c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f0e:	40bc                	lw	a5,64(s1)
    80003f10:	dff1                	beqz	a5,80003eec <iput+0x26>
    80003f12:	04a49783          	lh	a5,74(s1)
    80003f16:	fbf9                	bnez	a5,80003eec <iput+0x26>
    acquiresleep(&ip->lock);
    80003f18:	01048913          	addi	s2,s1,16
    80003f1c:	854a                	mv	a0,s2
    80003f1e:	00001097          	auipc	ra,0x1
    80003f22:	aae080e7          	jalr	-1362(ra) # 800049cc <acquiresleep>
    release(&itable.lock);
    80003f26:	0005b517          	auipc	a0,0x5b
    80003f2a:	34250513          	addi	a0,a0,834 # 8005f268 <itable>
    80003f2e:	ffffd097          	auipc	ra,0xffffd
    80003f32:	ef2080e7          	jalr	-270(ra) # 80000e20 <release>
    itrunc(ip);
    80003f36:	8526                	mv	a0,s1
    80003f38:	00000097          	auipc	ra,0x0
    80003f3c:	ee2080e7          	jalr	-286(ra) # 80003e1a <itrunc>
    ip->type = 0;
    80003f40:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f44:	8526                	mv	a0,s1
    80003f46:	00000097          	auipc	ra,0x0
    80003f4a:	cfa080e7          	jalr	-774(ra) # 80003c40 <iupdate>
    ip->valid = 0;
    80003f4e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f52:	854a                	mv	a0,s2
    80003f54:	00001097          	auipc	ra,0x1
    80003f58:	ace080e7          	jalr	-1330(ra) # 80004a22 <releasesleep>
    acquire(&itable.lock);
    80003f5c:	0005b517          	auipc	a0,0x5b
    80003f60:	30c50513          	addi	a0,a0,780 # 8005f268 <itable>
    80003f64:	ffffd097          	auipc	ra,0xffffd
    80003f68:	e08080e7          	jalr	-504(ra) # 80000d6c <acquire>
    80003f6c:	b741                	j	80003eec <iput+0x26>

0000000080003f6e <iunlockput>:
{
    80003f6e:	1101                	addi	sp,sp,-32
    80003f70:	ec06                	sd	ra,24(sp)
    80003f72:	e822                	sd	s0,16(sp)
    80003f74:	e426                	sd	s1,8(sp)
    80003f76:	1000                	addi	s0,sp,32
    80003f78:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	e54080e7          	jalr	-428(ra) # 80003dce <iunlock>
  iput(ip);
    80003f82:	8526                	mv	a0,s1
    80003f84:	00000097          	auipc	ra,0x0
    80003f88:	f42080e7          	jalr	-190(ra) # 80003ec6 <iput>
}
    80003f8c:	60e2                	ld	ra,24(sp)
    80003f8e:	6442                	ld	s0,16(sp)
    80003f90:	64a2                	ld	s1,8(sp)
    80003f92:	6105                	addi	sp,sp,32
    80003f94:	8082                	ret

0000000080003f96 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f96:	1141                	addi	sp,sp,-16
    80003f98:	e422                	sd	s0,8(sp)
    80003f9a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f9c:	411c                	lw	a5,0(a0)
    80003f9e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003fa0:	415c                	lw	a5,4(a0)
    80003fa2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003fa4:	04451783          	lh	a5,68(a0)
    80003fa8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003fac:	04a51783          	lh	a5,74(a0)
    80003fb0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003fb4:	04c56783          	lwu	a5,76(a0)
    80003fb8:	e99c                	sd	a5,16(a1)
}
    80003fba:	6422                	ld	s0,8(sp)
    80003fbc:	0141                	addi	sp,sp,16
    80003fbe:	8082                	ret

0000000080003fc0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fc0:	457c                	lw	a5,76(a0)
    80003fc2:	0ed7e963          	bltu	a5,a3,800040b4 <readi+0xf4>
{
    80003fc6:	7159                	addi	sp,sp,-112
    80003fc8:	f486                	sd	ra,104(sp)
    80003fca:	f0a2                	sd	s0,96(sp)
    80003fcc:	eca6                	sd	s1,88(sp)
    80003fce:	e8ca                	sd	s2,80(sp)
    80003fd0:	e4ce                	sd	s3,72(sp)
    80003fd2:	e0d2                	sd	s4,64(sp)
    80003fd4:	fc56                	sd	s5,56(sp)
    80003fd6:	f85a                	sd	s6,48(sp)
    80003fd8:	f45e                	sd	s7,40(sp)
    80003fda:	f062                	sd	s8,32(sp)
    80003fdc:	ec66                	sd	s9,24(sp)
    80003fde:	e86a                	sd	s10,16(sp)
    80003fe0:	e46e                	sd	s11,8(sp)
    80003fe2:	1880                	addi	s0,sp,112
    80003fe4:	8b2a                	mv	s6,a0
    80003fe6:	8bae                	mv	s7,a1
    80003fe8:	8a32                	mv	s4,a2
    80003fea:	84b6                	mv	s1,a3
    80003fec:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003fee:	9f35                	addw	a4,a4,a3
    return 0;
    80003ff0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ff2:	0ad76063          	bltu	a4,a3,80004092 <readi+0xd2>
  if(off + n > ip->size)
    80003ff6:	00e7f463          	bgeu	a5,a4,80003ffe <readi+0x3e>
    n = ip->size - off;
    80003ffa:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ffe:	0a0a8963          	beqz	s5,800040b0 <readi+0xf0>
    80004002:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004004:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004008:	5c7d                	li	s8,-1
    8000400a:	a82d                	j	80004044 <readi+0x84>
    8000400c:	020d1d93          	slli	s11,s10,0x20
    80004010:	020ddd93          	srli	s11,s11,0x20
    80004014:	05890613          	addi	a2,s2,88
    80004018:	86ee                	mv	a3,s11
    8000401a:	963a                	add	a2,a2,a4
    8000401c:	85d2                	mv	a1,s4
    8000401e:	855e                	mv	a0,s7
    80004020:	fffff097          	auipc	ra,0xfffff
    80004024:	802080e7          	jalr	-2046(ra) # 80002822 <either_copyout>
    80004028:	05850d63          	beq	a0,s8,80004082 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000402c:	854a                	mv	a0,s2
    8000402e:	fffff097          	auipc	ra,0xfffff
    80004032:	5f6080e7          	jalr	1526(ra) # 80003624 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004036:	013d09bb          	addw	s3,s10,s3
    8000403a:	009d04bb          	addw	s1,s10,s1
    8000403e:	9a6e                	add	s4,s4,s11
    80004040:	0559f763          	bgeu	s3,s5,8000408e <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80004044:	00a4d59b          	srliw	a1,s1,0xa
    80004048:	855a                	mv	a0,s6
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	89e080e7          	jalr	-1890(ra) # 800038e8 <bmap>
    80004052:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004056:	cd85                	beqz	a1,8000408e <readi+0xce>
    bp = bread(ip->dev, addr);
    80004058:	000b2503          	lw	a0,0(s6)
    8000405c:	fffff097          	auipc	ra,0xfffff
    80004060:	498080e7          	jalr	1176(ra) # 800034f4 <bread>
    80004064:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004066:	3ff4f713          	andi	a4,s1,1023
    8000406a:	40ec87bb          	subw	a5,s9,a4
    8000406e:	413a86bb          	subw	a3,s5,s3
    80004072:	8d3e                	mv	s10,a5
    80004074:	2781                	sext.w	a5,a5
    80004076:	0006861b          	sext.w	a2,a3
    8000407a:	f8f679e3          	bgeu	a2,a5,8000400c <readi+0x4c>
    8000407e:	8d36                	mv	s10,a3
    80004080:	b771                	j	8000400c <readi+0x4c>
      brelse(bp);
    80004082:	854a                	mv	a0,s2
    80004084:	fffff097          	auipc	ra,0xfffff
    80004088:	5a0080e7          	jalr	1440(ra) # 80003624 <brelse>
      tot = -1;
    8000408c:	59fd                	li	s3,-1
  }
  return tot;
    8000408e:	0009851b          	sext.w	a0,s3
}
    80004092:	70a6                	ld	ra,104(sp)
    80004094:	7406                	ld	s0,96(sp)
    80004096:	64e6                	ld	s1,88(sp)
    80004098:	6946                	ld	s2,80(sp)
    8000409a:	69a6                	ld	s3,72(sp)
    8000409c:	6a06                	ld	s4,64(sp)
    8000409e:	7ae2                	ld	s5,56(sp)
    800040a0:	7b42                	ld	s6,48(sp)
    800040a2:	7ba2                	ld	s7,40(sp)
    800040a4:	7c02                	ld	s8,32(sp)
    800040a6:	6ce2                	ld	s9,24(sp)
    800040a8:	6d42                	ld	s10,16(sp)
    800040aa:	6da2                	ld	s11,8(sp)
    800040ac:	6165                	addi	sp,sp,112
    800040ae:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040b0:	89d6                	mv	s3,s5
    800040b2:	bff1                	j	8000408e <readi+0xce>
    return 0;
    800040b4:	4501                	li	a0,0
}
    800040b6:	8082                	ret

00000000800040b8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040b8:	457c                	lw	a5,76(a0)
    800040ba:	10d7e863          	bltu	a5,a3,800041ca <writei+0x112>
{
    800040be:	7159                	addi	sp,sp,-112
    800040c0:	f486                	sd	ra,104(sp)
    800040c2:	f0a2                	sd	s0,96(sp)
    800040c4:	eca6                	sd	s1,88(sp)
    800040c6:	e8ca                	sd	s2,80(sp)
    800040c8:	e4ce                	sd	s3,72(sp)
    800040ca:	e0d2                	sd	s4,64(sp)
    800040cc:	fc56                	sd	s5,56(sp)
    800040ce:	f85a                	sd	s6,48(sp)
    800040d0:	f45e                	sd	s7,40(sp)
    800040d2:	f062                	sd	s8,32(sp)
    800040d4:	ec66                	sd	s9,24(sp)
    800040d6:	e86a                	sd	s10,16(sp)
    800040d8:	e46e                	sd	s11,8(sp)
    800040da:	1880                	addi	s0,sp,112
    800040dc:	8aaa                	mv	s5,a0
    800040de:	8bae                	mv	s7,a1
    800040e0:	8a32                	mv	s4,a2
    800040e2:	8936                	mv	s2,a3
    800040e4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800040e6:	00e687bb          	addw	a5,a3,a4
    800040ea:	0ed7e263          	bltu	a5,a3,800041ce <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040ee:	00043737          	lui	a4,0x43
    800040f2:	0ef76063          	bltu	a4,a5,800041d2 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040f6:	0c0b0863          	beqz	s6,800041c6 <writei+0x10e>
    800040fa:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040fc:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004100:	5c7d                	li	s8,-1
    80004102:	a091                	j	80004146 <writei+0x8e>
    80004104:	020d1d93          	slli	s11,s10,0x20
    80004108:	020ddd93          	srli	s11,s11,0x20
    8000410c:	05848513          	addi	a0,s1,88
    80004110:	86ee                	mv	a3,s11
    80004112:	8652                	mv	a2,s4
    80004114:	85de                	mv	a1,s7
    80004116:	953a                	add	a0,a0,a4
    80004118:	ffffe097          	auipc	ra,0xffffe
    8000411c:	760080e7          	jalr	1888(ra) # 80002878 <either_copyin>
    80004120:	07850263          	beq	a0,s8,80004184 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004124:	8526                	mv	a0,s1
    80004126:	00000097          	auipc	ra,0x0
    8000412a:	788080e7          	jalr	1928(ra) # 800048ae <log_write>
    brelse(bp);
    8000412e:	8526                	mv	a0,s1
    80004130:	fffff097          	auipc	ra,0xfffff
    80004134:	4f4080e7          	jalr	1268(ra) # 80003624 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004138:	013d09bb          	addw	s3,s10,s3
    8000413c:	012d093b          	addw	s2,s10,s2
    80004140:	9a6e                	add	s4,s4,s11
    80004142:	0569f663          	bgeu	s3,s6,8000418e <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004146:	00a9559b          	srliw	a1,s2,0xa
    8000414a:	8556                	mv	a0,s5
    8000414c:	fffff097          	auipc	ra,0xfffff
    80004150:	79c080e7          	jalr	1948(ra) # 800038e8 <bmap>
    80004154:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004158:	c99d                	beqz	a1,8000418e <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000415a:	000aa503          	lw	a0,0(s5)
    8000415e:	fffff097          	auipc	ra,0xfffff
    80004162:	396080e7          	jalr	918(ra) # 800034f4 <bread>
    80004166:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004168:	3ff97713          	andi	a4,s2,1023
    8000416c:	40ec87bb          	subw	a5,s9,a4
    80004170:	413b06bb          	subw	a3,s6,s3
    80004174:	8d3e                	mv	s10,a5
    80004176:	2781                	sext.w	a5,a5
    80004178:	0006861b          	sext.w	a2,a3
    8000417c:	f8f674e3          	bgeu	a2,a5,80004104 <writei+0x4c>
    80004180:	8d36                	mv	s10,a3
    80004182:	b749                	j	80004104 <writei+0x4c>
      brelse(bp);
    80004184:	8526                	mv	a0,s1
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	49e080e7          	jalr	1182(ra) # 80003624 <brelse>
  }

  if(off > ip->size)
    8000418e:	04caa783          	lw	a5,76(s5)
    80004192:	0127f463          	bgeu	a5,s2,8000419a <writei+0xe2>
    ip->size = off;
    80004196:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000419a:	8556                	mv	a0,s5
    8000419c:	00000097          	auipc	ra,0x0
    800041a0:	aa4080e7          	jalr	-1372(ra) # 80003c40 <iupdate>

  return tot;
    800041a4:	0009851b          	sext.w	a0,s3
}
    800041a8:	70a6                	ld	ra,104(sp)
    800041aa:	7406                	ld	s0,96(sp)
    800041ac:	64e6                	ld	s1,88(sp)
    800041ae:	6946                	ld	s2,80(sp)
    800041b0:	69a6                	ld	s3,72(sp)
    800041b2:	6a06                	ld	s4,64(sp)
    800041b4:	7ae2                	ld	s5,56(sp)
    800041b6:	7b42                	ld	s6,48(sp)
    800041b8:	7ba2                	ld	s7,40(sp)
    800041ba:	7c02                	ld	s8,32(sp)
    800041bc:	6ce2                	ld	s9,24(sp)
    800041be:	6d42                	ld	s10,16(sp)
    800041c0:	6da2                	ld	s11,8(sp)
    800041c2:	6165                	addi	sp,sp,112
    800041c4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041c6:	89da                	mv	s3,s6
    800041c8:	bfc9                	j	8000419a <writei+0xe2>
    return -1;
    800041ca:	557d                	li	a0,-1
}
    800041cc:	8082                	ret
    return -1;
    800041ce:	557d                	li	a0,-1
    800041d0:	bfe1                	j	800041a8 <writei+0xf0>
    return -1;
    800041d2:	557d                	li	a0,-1
    800041d4:	bfd1                	j	800041a8 <writei+0xf0>

00000000800041d6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800041d6:	1141                	addi	sp,sp,-16
    800041d8:	e406                	sd	ra,8(sp)
    800041da:	e022                	sd	s0,0(sp)
    800041dc:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041de:	4639                	li	a2,14
    800041e0:	ffffd097          	auipc	ra,0xffffd
    800041e4:	d58080e7          	jalr	-680(ra) # 80000f38 <strncmp>
}
    800041e8:	60a2                	ld	ra,8(sp)
    800041ea:	6402                	ld	s0,0(sp)
    800041ec:	0141                	addi	sp,sp,16
    800041ee:	8082                	ret

00000000800041f0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041f0:	7139                	addi	sp,sp,-64
    800041f2:	fc06                	sd	ra,56(sp)
    800041f4:	f822                	sd	s0,48(sp)
    800041f6:	f426                	sd	s1,40(sp)
    800041f8:	f04a                	sd	s2,32(sp)
    800041fa:	ec4e                	sd	s3,24(sp)
    800041fc:	e852                	sd	s4,16(sp)
    800041fe:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004200:	04451703          	lh	a4,68(a0)
    80004204:	4785                	li	a5,1
    80004206:	00f71a63          	bne	a4,a5,8000421a <dirlookup+0x2a>
    8000420a:	892a                	mv	s2,a0
    8000420c:	89ae                	mv	s3,a1
    8000420e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004210:	457c                	lw	a5,76(a0)
    80004212:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004214:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004216:	e79d                	bnez	a5,80004244 <dirlookup+0x54>
    80004218:	a8a5                	j	80004290 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000421a:	00004517          	auipc	a0,0x4
    8000421e:	58650513          	addi	a0,a0,1414 # 800087a0 <syscalls+0x1c8>
    80004222:	ffffc097          	auipc	ra,0xffffc
    80004226:	31e080e7          	jalr	798(ra) # 80000540 <panic>
      panic("dirlookup read");
    8000422a:	00004517          	auipc	a0,0x4
    8000422e:	58e50513          	addi	a0,a0,1422 # 800087b8 <syscalls+0x1e0>
    80004232:	ffffc097          	auipc	ra,0xffffc
    80004236:	30e080e7          	jalr	782(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000423a:	24c1                	addiw	s1,s1,16
    8000423c:	04c92783          	lw	a5,76(s2)
    80004240:	04f4f763          	bgeu	s1,a5,8000428e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004244:	4741                	li	a4,16
    80004246:	86a6                	mv	a3,s1
    80004248:	fc040613          	addi	a2,s0,-64
    8000424c:	4581                	li	a1,0
    8000424e:	854a                	mv	a0,s2
    80004250:	00000097          	auipc	ra,0x0
    80004254:	d70080e7          	jalr	-656(ra) # 80003fc0 <readi>
    80004258:	47c1                	li	a5,16
    8000425a:	fcf518e3          	bne	a0,a5,8000422a <dirlookup+0x3a>
    if(de.inum == 0)
    8000425e:	fc045783          	lhu	a5,-64(s0)
    80004262:	dfe1                	beqz	a5,8000423a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004264:	fc240593          	addi	a1,s0,-62
    80004268:	854e                	mv	a0,s3
    8000426a:	00000097          	auipc	ra,0x0
    8000426e:	f6c080e7          	jalr	-148(ra) # 800041d6 <namecmp>
    80004272:	f561                	bnez	a0,8000423a <dirlookup+0x4a>
      if(poff)
    80004274:	000a0463          	beqz	s4,8000427c <dirlookup+0x8c>
        *poff = off;
    80004278:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000427c:	fc045583          	lhu	a1,-64(s0)
    80004280:	00092503          	lw	a0,0(s2)
    80004284:	fffff097          	auipc	ra,0xfffff
    80004288:	74e080e7          	jalr	1870(ra) # 800039d2 <iget>
    8000428c:	a011                	j	80004290 <dirlookup+0xa0>
  return 0;
    8000428e:	4501                	li	a0,0
}
    80004290:	70e2                	ld	ra,56(sp)
    80004292:	7442                	ld	s0,48(sp)
    80004294:	74a2                	ld	s1,40(sp)
    80004296:	7902                	ld	s2,32(sp)
    80004298:	69e2                	ld	s3,24(sp)
    8000429a:	6a42                	ld	s4,16(sp)
    8000429c:	6121                	addi	sp,sp,64
    8000429e:	8082                	ret

00000000800042a0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800042a0:	711d                	addi	sp,sp,-96
    800042a2:	ec86                	sd	ra,88(sp)
    800042a4:	e8a2                	sd	s0,80(sp)
    800042a6:	e4a6                	sd	s1,72(sp)
    800042a8:	e0ca                	sd	s2,64(sp)
    800042aa:	fc4e                	sd	s3,56(sp)
    800042ac:	f852                	sd	s4,48(sp)
    800042ae:	f456                	sd	s5,40(sp)
    800042b0:	f05a                	sd	s6,32(sp)
    800042b2:	ec5e                	sd	s7,24(sp)
    800042b4:	e862                	sd	s8,16(sp)
    800042b6:	e466                	sd	s9,8(sp)
    800042b8:	e06a                	sd	s10,0(sp)
    800042ba:	1080                	addi	s0,sp,96
    800042bc:	84aa                	mv	s1,a0
    800042be:	8b2e                	mv	s6,a1
    800042c0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800042c2:	00054703          	lbu	a4,0(a0)
    800042c6:	02f00793          	li	a5,47
    800042ca:	02f70363          	beq	a4,a5,800042f0 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800042ce:	ffffe097          	auipc	ra,0xffffe
    800042d2:	98c080e7          	jalr	-1652(ra) # 80001c5a <myproc>
    800042d6:	15053503          	ld	a0,336(a0)
    800042da:	00000097          	auipc	ra,0x0
    800042de:	9f4080e7          	jalr	-1548(ra) # 80003cce <idup>
    800042e2:	8a2a                	mv	s4,a0
  while(*path == '/')
    800042e4:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800042e8:	4cb5                	li	s9,13
  len = path - s;
    800042ea:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800042ec:	4c05                	li	s8,1
    800042ee:	a87d                	j	800043ac <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800042f0:	4585                	li	a1,1
    800042f2:	4505                	li	a0,1
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	6de080e7          	jalr	1758(ra) # 800039d2 <iget>
    800042fc:	8a2a                	mv	s4,a0
    800042fe:	b7dd                	j	800042e4 <namex+0x44>
      iunlockput(ip);
    80004300:	8552                	mv	a0,s4
    80004302:	00000097          	auipc	ra,0x0
    80004306:	c6c080e7          	jalr	-916(ra) # 80003f6e <iunlockput>
      return 0;
    8000430a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000430c:	8552                	mv	a0,s4
    8000430e:	60e6                	ld	ra,88(sp)
    80004310:	6446                	ld	s0,80(sp)
    80004312:	64a6                	ld	s1,72(sp)
    80004314:	6906                	ld	s2,64(sp)
    80004316:	79e2                	ld	s3,56(sp)
    80004318:	7a42                	ld	s4,48(sp)
    8000431a:	7aa2                	ld	s5,40(sp)
    8000431c:	7b02                	ld	s6,32(sp)
    8000431e:	6be2                	ld	s7,24(sp)
    80004320:	6c42                	ld	s8,16(sp)
    80004322:	6ca2                	ld	s9,8(sp)
    80004324:	6d02                	ld	s10,0(sp)
    80004326:	6125                	addi	sp,sp,96
    80004328:	8082                	ret
      iunlock(ip);
    8000432a:	8552                	mv	a0,s4
    8000432c:	00000097          	auipc	ra,0x0
    80004330:	aa2080e7          	jalr	-1374(ra) # 80003dce <iunlock>
      return ip;
    80004334:	bfe1                	j	8000430c <namex+0x6c>
      iunlockput(ip);
    80004336:	8552                	mv	a0,s4
    80004338:	00000097          	auipc	ra,0x0
    8000433c:	c36080e7          	jalr	-970(ra) # 80003f6e <iunlockput>
      return 0;
    80004340:	8a4e                	mv	s4,s3
    80004342:	b7e9                	j	8000430c <namex+0x6c>
  len = path - s;
    80004344:	40998633          	sub	a2,s3,s1
    80004348:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    8000434c:	09acd863          	bge	s9,s10,800043dc <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004350:	4639                	li	a2,14
    80004352:	85a6                	mv	a1,s1
    80004354:	8556                	mv	a0,s5
    80004356:	ffffd097          	auipc	ra,0xffffd
    8000435a:	b6e080e7          	jalr	-1170(ra) # 80000ec4 <memmove>
    8000435e:	84ce                	mv	s1,s3
  while(*path == '/')
    80004360:	0004c783          	lbu	a5,0(s1)
    80004364:	01279763          	bne	a5,s2,80004372 <namex+0xd2>
    path++;
    80004368:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000436a:	0004c783          	lbu	a5,0(s1)
    8000436e:	ff278de3          	beq	a5,s2,80004368 <namex+0xc8>
    ilock(ip);
    80004372:	8552                	mv	a0,s4
    80004374:	00000097          	auipc	ra,0x0
    80004378:	998080e7          	jalr	-1640(ra) # 80003d0c <ilock>
    if(ip->type != T_DIR){
    8000437c:	044a1783          	lh	a5,68(s4)
    80004380:	f98790e3          	bne	a5,s8,80004300 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004384:	000b0563          	beqz	s6,8000438e <namex+0xee>
    80004388:	0004c783          	lbu	a5,0(s1)
    8000438c:	dfd9                	beqz	a5,8000432a <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000438e:	865e                	mv	a2,s7
    80004390:	85d6                	mv	a1,s5
    80004392:	8552                	mv	a0,s4
    80004394:	00000097          	auipc	ra,0x0
    80004398:	e5c080e7          	jalr	-420(ra) # 800041f0 <dirlookup>
    8000439c:	89aa                	mv	s3,a0
    8000439e:	dd41                	beqz	a0,80004336 <namex+0x96>
    iunlockput(ip);
    800043a0:	8552                	mv	a0,s4
    800043a2:	00000097          	auipc	ra,0x0
    800043a6:	bcc080e7          	jalr	-1076(ra) # 80003f6e <iunlockput>
    ip = next;
    800043aa:	8a4e                	mv	s4,s3
  while(*path == '/')
    800043ac:	0004c783          	lbu	a5,0(s1)
    800043b0:	01279763          	bne	a5,s2,800043be <namex+0x11e>
    path++;
    800043b4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043b6:	0004c783          	lbu	a5,0(s1)
    800043ba:	ff278de3          	beq	a5,s2,800043b4 <namex+0x114>
  if(*path == 0)
    800043be:	cb9d                	beqz	a5,800043f4 <namex+0x154>
  while(*path != '/' && *path != 0)
    800043c0:	0004c783          	lbu	a5,0(s1)
    800043c4:	89a6                	mv	s3,s1
  len = path - s;
    800043c6:	8d5e                	mv	s10,s7
    800043c8:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800043ca:	01278963          	beq	a5,s2,800043dc <namex+0x13c>
    800043ce:	dbbd                	beqz	a5,80004344 <namex+0xa4>
    path++;
    800043d0:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800043d2:	0009c783          	lbu	a5,0(s3)
    800043d6:	ff279ce3          	bne	a5,s2,800043ce <namex+0x12e>
    800043da:	b7ad                	j	80004344 <namex+0xa4>
    memmove(name, s, len);
    800043dc:	2601                	sext.w	a2,a2
    800043de:	85a6                	mv	a1,s1
    800043e0:	8556                	mv	a0,s5
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	ae2080e7          	jalr	-1310(ra) # 80000ec4 <memmove>
    name[len] = 0;
    800043ea:	9d56                	add	s10,s10,s5
    800043ec:	000d0023          	sb	zero,0(s10)
    800043f0:	84ce                	mv	s1,s3
    800043f2:	b7bd                	j	80004360 <namex+0xc0>
  if(nameiparent){
    800043f4:	f00b0ce3          	beqz	s6,8000430c <namex+0x6c>
    iput(ip);
    800043f8:	8552                	mv	a0,s4
    800043fa:	00000097          	auipc	ra,0x0
    800043fe:	acc080e7          	jalr	-1332(ra) # 80003ec6 <iput>
    return 0;
    80004402:	4a01                	li	s4,0
    80004404:	b721                	j	8000430c <namex+0x6c>

0000000080004406 <dirlink>:
{
    80004406:	7139                	addi	sp,sp,-64
    80004408:	fc06                	sd	ra,56(sp)
    8000440a:	f822                	sd	s0,48(sp)
    8000440c:	f426                	sd	s1,40(sp)
    8000440e:	f04a                	sd	s2,32(sp)
    80004410:	ec4e                	sd	s3,24(sp)
    80004412:	e852                	sd	s4,16(sp)
    80004414:	0080                	addi	s0,sp,64
    80004416:	892a                	mv	s2,a0
    80004418:	8a2e                	mv	s4,a1
    8000441a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000441c:	4601                	li	a2,0
    8000441e:	00000097          	auipc	ra,0x0
    80004422:	dd2080e7          	jalr	-558(ra) # 800041f0 <dirlookup>
    80004426:	e93d                	bnez	a0,8000449c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004428:	04c92483          	lw	s1,76(s2)
    8000442c:	c49d                	beqz	s1,8000445a <dirlink+0x54>
    8000442e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004430:	4741                	li	a4,16
    80004432:	86a6                	mv	a3,s1
    80004434:	fc040613          	addi	a2,s0,-64
    80004438:	4581                	li	a1,0
    8000443a:	854a                	mv	a0,s2
    8000443c:	00000097          	auipc	ra,0x0
    80004440:	b84080e7          	jalr	-1148(ra) # 80003fc0 <readi>
    80004444:	47c1                	li	a5,16
    80004446:	06f51163          	bne	a0,a5,800044a8 <dirlink+0xa2>
    if(de.inum == 0)
    8000444a:	fc045783          	lhu	a5,-64(s0)
    8000444e:	c791                	beqz	a5,8000445a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004450:	24c1                	addiw	s1,s1,16
    80004452:	04c92783          	lw	a5,76(s2)
    80004456:	fcf4ede3          	bltu	s1,a5,80004430 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000445a:	4639                	li	a2,14
    8000445c:	85d2                	mv	a1,s4
    8000445e:	fc240513          	addi	a0,s0,-62
    80004462:	ffffd097          	auipc	ra,0xffffd
    80004466:	b12080e7          	jalr	-1262(ra) # 80000f74 <strncpy>
  de.inum = inum;
    8000446a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000446e:	4741                	li	a4,16
    80004470:	86a6                	mv	a3,s1
    80004472:	fc040613          	addi	a2,s0,-64
    80004476:	4581                	li	a1,0
    80004478:	854a                	mv	a0,s2
    8000447a:	00000097          	auipc	ra,0x0
    8000447e:	c3e080e7          	jalr	-962(ra) # 800040b8 <writei>
    80004482:	1541                	addi	a0,a0,-16
    80004484:	00a03533          	snez	a0,a0
    80004488:	40a00533          	neg	a0,a0
}
    8000448c:	70e2                	ld	ra,56(sp)
    8000448e:	7442                	ld	s0,48(sp)
    80004490:	74a2                	ld	s1,40(sp)
    80004492:	7902                	ld	s2,32(sp)
    80004494:	69e2                	ld	s3,24(sp)
    80004496:	6a42                	ld	s4,16(sp)
    80004498:	6121                	addi	sp,sp,64
    8000449a:	8082                	ret
    iput(ip);
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	a2a080e7          	jalr	-1494(ra) # 80003ec6 <iput>
    return -1;
    800044a4:	557d                	li	a0,-1
    800044a6:	b7dd                	j	8000448c <dirlink+0x86>
      panic("dirlink read");
    800044a8:	00004517          	auipc	a0,0x4
    800044ac:	32050513          	addi	a0,a0,800 # 800087c8 <syscalls+0x1f0>
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	090080e7          	jalr	144(ra) # 80000540 <panic>

00000000800044b8 <namei>:

struct inode*
namei(char *path)
{
    800044b8:	1101                	addi	sp,sp,-32
    800044ba:	ec06                	sd	ra,24(sp)
    800044bc:	e822                	sd	s0,16(sp)
    800044be:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800044c0:	fe040613          	addi	a2,s0,-32
    800044c4:	4581                	li	a1,0
    800044c6:	00000097          	auipc	ra,0x0
    800044ca:	dda080e7          	jalr	-550(ra) # 800042a0 <namex>
}
    800044ce:	60e2                	ld	ra,24(sp)
    800044d0:	6442                	ld	s0,16(sp)
    800044d2:	6105                	addi	sp,sp,32
    800044d4:	8082                	ret

00000000800044d6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044d6:	1141                	addi	sp,sp,-16
    800044d8:	e406                	sd	ra,8(sp)
    800044da:	e022                	sd	s0,0(sp)
    800044dc:	0800                	addi	s0,sp,16
    800044de:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044e0:	4585                	li	a1,1
    800044e2:	00000097          	auipc	ra,0x0
    800044e6:	dbe080e7          	jalr	-578(ra) # 800042a0 <namex>
}
    800044ea:	60a2                	ld	ra,8(sp)
    800044ec:	6402                	ld	s0,0(sp)
    800044ee:	0141                	addi	sp,sp,16
    800044f0:	8082                	ret

00000000800044f2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044f2:	1101                	addi	sp,sp,-32
    800044f4:	ec06                	sd	ra,24(sp)
    800044f6:	e822                	sd	s0,16(sp)
    800044f8:	e426                	sd	s1,8(sp)
    800044fa:	e04a                	sd	s2,0(sp)
    800044fc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044fe:	0005d917          	auipc	s2,0x5d
    80004502:	81290913          	addi	s2,s2,-2030 # 80060d10 <log>
    80004506:	01892583          	lw	a1,24(s2)
    8000450a:	02892503          	lw	a0,40(s2)
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	fe6080e7          	jalr	-26(ra) # 800034f4 <bread>
    80004516:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004518:	02c92683          	lw	a3,44(s2)
    8000451c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000451e:	02d05863          	blez	a3,8000454e <write_head+0x5c>
    80004522:	0005d797          	auipc	a5,0x5d
    80004526:	81e78793          	addi	a5,a5,-2018 # 80060d40 <log+0x30>
    8000452a:	05c50713          	addi	a4,a0,92
    8000452e:	36fd                	addiw	a3,a3,-1
    80004530:	02069613          	slli	a2,a3,0x20
    80004534:	01e65693          	srli	a3,a2,0x1e
    80004538:	0005d617          	auipc	a2,0x5d
    8000453c:	80c60613          	addi	a2,a2,-2036 # 80060d44 <log+0x34>
    80004540:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004542:	4390                	lw	a2,0(a5)
    80004544:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004546:	0791                	addi	a5,a5,4
    80004548:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000454a:	fed79ce3          	bne	a5,a3,80004542 <write_head+0x50>
  }
  bwrite(buf);
    8000454e:	8526                	mv	a0,s1
    80004550:	fffff097          	auipc	ra,0xfffff
    80004554:	096080e7          	jalr	150(ra) # 800035e6 <bwrite>
  brelse(buf);
    80004558:	8526                	mv	a0,s1
    8000455a:	fffff097          	auipc	ra,0xfffff
    8000455e:	0ca080e7          	jalr	202(ra) # 80003624 <brelse>
}
    80004562:	60e2                	ld	ra,24(sp)
    80004564:	6442                	ld	s0,16(sp)
    80004566:	64a2                	ld	s1,8(sp)
    80004568:	6902                	ld	s2,0(sp)
    8000456a:	6105                	addi	sp,sp,32
    8000456c:	8082                	ret

000000008000456e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000456e:	0005c797          	auipc	a5,0x5c
    80004572:	7ce7a783          	lw	a5,1998(a5) # 80060d3c <log+0x2c>
    80004576:	0af05d63          	blez	a5,80004630 <install_trans+0xc2>
{
    8000457a:	7139                	addi	sp,sp,-64
    8000457c:	fc06                	sd	ra,56(sp)
    8000457e:	f822                	sd	s0,48(sp)
    80004580:	f426                	sd	s1,40(sp)
    80004582:	f04a                	sd	s2,32(sp)
    80004584:	ec4e                	sd	s3,24(sp)
    80004586:	e852                	sd	s4,16(sp)
    80004588:	e456                	sd	s5,8(sp)
    8000458a:	e05a                	sd	s6,0(sp)
    8000458c:	0080                	addi	s0,sp,64
    8000458e:	8b2a                	mv	s6,a0
    80004590:	0005ca97          	auipc	s5,0x5c
    80004594:	7b0a8a93          	addi	s5,s5,1968 # 80060d40 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004598:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000459a:	0005c997          	auipc	s3,0x5c
    8000459e:	77698993          	addi	s3,s3,1910 # 80060d10 <log>
    800045a2:	a00d                	j	800045c4 <install_trans+0x56>
    brelse(lbuf);
    800045a4:	854a                	mv	a0,s2
    800045a6:	fffff097          	auipc	ra,0xfffff
    800045aa:	07e080e7          	jalr	126(ra) # 80003624 <brelse>
    brelse(dbuf);
    800045ae:	8526                	mv	a0,s1
    800045b0:	fffff097          	auipc	ra,0xfffff
    800045b4:	074080e7          	jalr	116(ra) # 80003624 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045b8:	2a05                	addiw	s4,s4,1
    800045ba:	0a91                	addi	s5,s5,4
    800045bc:	02c9a783          	lw	a5,44(s3)
    800045c0:	04fa5e63          	bge	s4,a5,8000461c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045c4:	0189a583          	lw	a1,24(s3)
    800045c8:	014585bb          	addw	a1,a1,s4
    800045cc:	2585                	addiw	a1,a1,1
    800045ce:	0289a503          	lw	a0,40(s3)
    800045d2:	fffff097          	auipc	ra,0xfffff
    800045d6:	f22080e7          	jalr	-222(ra) # 800034f4 <bread>
    800045da:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045dc:	000aa583          	lw	a1,0(s5)
    800045e0:	0289a503          	lw	a0,40(s3)
    800045e4:	fffff097          	auipc	ra,0xfffff
    800045e8:	f10080e7          	jalr	-240(ra) # 800034f4 <bread>
    800045ec:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045ee:	40000613          	li	a2,1024
    800045f2:	05890593          	addi	a1,s2,88
    800045f6:	05850513          	addi	a0,a0,88
    800045fa:	ffffd097          	auipc	ra,0xffffd
    800045fe:	8ca080e7          	jalr	-1846(ra) # 80000ec4 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004602:	8526                	mv	a0,s1
    80004604:	fffff097          	auipc	ra,0xfffff
    80004608:	fe2080e7          	jalr	-30(ra) # 800035e6 <bwrite>
    if(recovering == 0)
    8000460c:	f80b1ce3          	bnez	s6,800045a4 <install_trans+0x36>
      bunpin(dbuf);
    80004610:	8526                	mv	a0,s1
    80004612:	fffff097          	auipc	ra,0xfffff
    80004616:	0ec080e7          	jalr	236(ra) # 800036fe <bunpin>
    8000461a:	b769                	j	800045a4 <install_trans+0x36>
}
    8000461c:	70e2                	ld	ra,56(sp)
    8000461e:	7442                	ld	s0,48(sp)
    80004620:	74a2                	ld	s1,40(sp)
    80004622:	7902                	ld	s2,32(sp)
    80004624:	69e2                	ld	s3,24(sp)
    80004626:	6a42                	ld	s4,16(sp)
    80004628:	6aa2                	ld	s5,8(sp)
    8000462a:	6b02                	ld	s6,0(sp)
    8000462c:	6121                	addi	sp,sp,64
    8000462e:	8082                	ret
    80004630:	8082                	ret

0000000080004632 <initlog>:
{
    80004632:	7179                	addi	sp,sp,-48
    80004634:	f406                	sd	ra,40(sp)
    80004636:	f022                	sd	s0,32(sp)
    80004638:	ec26                	sd	s1,24(sp)
    8000463a:	e84a                	sd	s2,16(sp)
    8000463c:	e44e                	sd	s3,8(sp)
    8000463e:	1800                	addi	s0,sp,48
    80004640:	892a                	mv	s2,a0
    80004642:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004644:	0005c497          	auipc	s1,0x5c
    80004648:	6cc48493          	addi	s1,s1,1740 # 80060d10 <log>
    8000464c:	00004597          	auipc	a1,0x4
    80004650:	18c58593          	addi	a1,a1,396 # 800087d8 <syscalls+0x200>
    80004654:	8526                	mv	a0,s1
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	686080e7          	jalr	1670(ra) # 80000cdc <initlock>
  log.start = sb->logstart;
    8000465e:	0149a583          	lw	a1,20(s3)
    80004662:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004664:	0109a783          	lw	a5,16(s3)
    80004668:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000466a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000466e:	854a                	mv	a0,s2
    80004670:	fffff097          	auipc	ra,0xfffff
    80004674:	e84080e7          	jalr	-380(ra) # 800034f4 <bread>
  log.lh.n = lh->n;
    80004678:	4d34                	lw	a3,88(a0)
    8000467a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000467c:	02d05663          	blez	a3,800046a8 <initlog+0x76>
    80004680:	05c50793          	addi	a5,a0,92
    80004684:	0005c717          	auipc	a4,0x5c
    80004688:	6bc70713          	addi	a4,a4,1724 # 80060d40 <log+0x30>
    8000468c:	36fd                	addiw	a3,a3,-1
    8000468e:	02069613          	slli	a2,a3,0x20
    80004692:	01e65693          	srli	a3,a2,0x1e
    80004696:	06050613          	addi	a2,a0,96
    8000469a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000469c:	4390                	lw	a2,0(a5)
    8000469e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046a0:	0791                	addi	a5,a5,4
    800046a2:	0711                	addi	a4,a4,4
    800046a4:	fed79ce3          	bne	a5,a3,8000469c <initlog+0x6a>
  brelse(buf);
    800046a8:	fffff097          	auipc	ra,0xfffff
    800046ac:	f7c080e7          	jalr	-132(ra) # 80003624 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800046b0:	4505                	li	a0,1
    800046b2:	00000097          	auipc	ra,0x0
    800046b6:	ebc080e7          	jalr	-324(ra) # 8000456e <install_trans>
  log.lh.n = 0;
    800046ba:	0005c797          	auipc	a5,0x5c
    800046be:	6807a123          	sw	zero,1666(a5) # 80060d3c <log+0x2c>
  write_head(); // clear the log
    800046c2:	00000097          	auipc	ra,0x0
    800046c6:	e30080e7          	jalr	-464(ra) # 800044f2 <write_head>
}
    800046ca:	70a2                	ld	ra,40(sp)
    800046cc:	7402                	ld	s0,32(sp)
    800046ce:	64e2                	ld	s1,24(sp)
    800046d0:	6942                	ld	s2,16(sp)
    800046d2:	69a2                	ld	s3,8(sp)
    800046d4:	6145                	addi	sp,sp,48
    800046d6:	8082                	ret

00000000800046d8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800046d8:	1101                	addi	sp,sp,-32
    800046da:	ec06                	sd	ra,24(sp)
    800046dc:	e822                	sd	s0,16(sp)
    800046de:	e426                	sd	s1,8(sp)
    800046e0:	e04a                	sd	s2,0(sp)
    800046e2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800046e4:	0005c517          	auipc	a0,0x5c
    800046e8:	62c50513          	addi	a0,a0,1580 # 80060d10 <log>
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	680080e7          	jalr	1664(ra) # 80000d6c <acquire>
  while(1){
    if(log.committing){
    800046f4:	0005c497          	auipc	s1,0x5c
    800046f8:	61c48493          	addi	s1,s1,1564 # 80060d10 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046fc:	4979                	li	s2,30
    800046fe:	a039                	j	8000470c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004700:	85a6                	mv	a1,s1
    80004702:	8526                	mv	a0,s1
    80004704:	ffffe097          	auipc	ra,0xffffe
    80004708:	d16080e7          	jalr	-746(ra) # 8000241a <sleep>
    if(log.committing){
    8000470c:	50dc                	lw	a5,36(s1)
    8000470e:	fbed                	bnez	a5,80004700 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004710:	5098                	lw	a4,32(s1)
    80004712:	2705                	addiw	a4,a4,1
    80004714:	0007069b          	sext.w	a3,a4
    80004718:	0027179b          	slliw	a5,a4,0x2
    8000471c:	9fb9                	addw	a5,a5,a4
    8000471e:	0017979b          	slliw	a5,a5,0x1
    80004722:	54d8                	lw	a4,44(s1)
    80004724:	9fb9                	addw	a5,a5,a4
    80004726:	00f95963          	bge	s2,a5,80004738 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000472a:	85a6                	mv	a1,s1
    8000472c:	8526                	mv	a0,s1
    8000472e:	ffffe097          	auipc	ra,0xffffe
    80004732:	cec080e7          	jalr	-788(ra) # 8000241a <sleep>
    80004736:	bfd9                	j	8000470c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004738:	0005c517          	auipc	a0,0x5c
    8000473c:	5d850513          	addi	a0,a0,1496 # 80060d10 <log>
    80004740:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004742:	ffffc097          	auipc	ra,0xffffc
    80004746:	6de080e7          	jalr	1758(ra) # 80000e20 <release>
      break;
    }
  }
}
    8000474a:	60e2                	ld	ra,24(sp)
    8000474c:	6442                	ld	s0,16(sp)
    8000474e:	64a2                	ld	s1,8(sp)
    80004750:	6902                	ld	s2,0(sp)
    80004752:	6105                	addi	sp,sp,32
    80004754:	8082                	ret

0000000080004756 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004756:	7139                	addi	sp,sp,-64
    80004758:	fc06                	sd	ra,56(sp)
    8000475a:	f822                	sd	s0,48(sp)
    8000475c:	f426                	sd	s1,40(sp)
    8000475e:	f04a                	sd	s2,32(sp)
    80004760:	ec4e                	sd	s3,24(sp)
    80004762:	e852                	sd	s4,16(sp)
    80004764:	e456                	sd	s5,8(sp)
    80004766:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004768:	0005c497          	auipc	s1,0x5c
    8000476c:	5a848493          	addi	s1,s1,1448 # 80060d10 <log>
    80004770:	8526                	mv	a0,s1
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	5fa080e7          	jalr	1530(ra) # 80000d6c <acquire>
  log.outstanding -= 1;
    8000477a:	509c                	lw	a5,32(s1)
    8000477c:	37fd                	addiw	a5,a5,-1
    8000477e:	0007891b          	sext.w	s2,a5
    80004782:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004784:	50dc                	lw	a5,36(s1)
    80004786:	e7b9                	bnez	a5,800047d4 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004788:	04091e63          	bnez	s2,800047e4 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000478c:	0005c497          	auipc	s1,0x5c
    80004790:	58448493          	addi	s1,s1,1412 # 80060d10 <log>
    80004794:	4785                	li	a5,1
    80004796:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004798:	8526                	mv	a0,s1
    8000479a:	ffffc097          	auipc	ra,0xffffc
    8000479e:	686080e7          	jalr	1670(ra) # 80000e20 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800047a2:	54dc                	lw	a5,44(s1)
    800047a4:	06f04763          	bgtz	a5,80004812 <end_op+0xbc>
    acquire(&log.lock);
    800047a8:	0005c497          	auipc	s1,0x5c
    800047ac:	56848493          	addi	s1,s1,1384 # 80060d10 <log>
    800047b0:	8526                	mv	a0,s1
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	5ba080e7          	jalr	1466(ra) # 80000d6c <acquire>
    log.committing = 0;
    800047ba:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800047be:	8526                	mv	a0,s1
    800047c0:	ffffe097          	auipc	ra,0xffffe
    800047c4:	cbe080e7          	jalr	-834(ra) # 8000247e <wakeup>
    release(&log.lock);
    800047c8:	8526                	mv	a0,s1
    800047ca:	ffffc097          	auipc	ra,0xffffc
    800047ce:	656080e7          	jalr	1622(ra) # 80000e20 <release>
}
    800047d2:	a03d                	j	80004800 <end_op+0xaa>
    panic("log.committing");
    800047d4:	00004517          	auipc	a0,0x4
    800047d8:	00c50513          	addi	a0,a0,12 # 800087e0 <syscalls+0x208>
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	d64080e7          	jalr	-668(ra) # 80000540 <panic>
    wakeup(&log);
    800047e4:	0005c497          	auipc	s1,0x5c
    800047e8:	52c48493          	addi	s1,s1,1324 # 80060d10 <log>
    800047ec:	8526                	mv	a0,s1
    800047ee:	ffffe097          	auipc	ra,0xffffe
    800047f2:	c90080e7          	jalr	-880(ra) # 8000247e <wakeup>
  release(&log.lock);
    800047f6:	8526                	mv	a0,s1
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	628080e7          	jalr	1576(ra) # 80000e20 <release>
}
    80004800:	70e2                	ld	ra,56(sp)
    80004802:	7442                	ld	s0,48(sp)
    80004804:	74a2                	ld	s1,40(sp)
    80004806:	7902                	ld	s2,32(sp)
    80004808:	69e2                	ld	s3,24(sp)
    8000480a:	6a42                	ld	s4,16(sp)
    8000480c:	6aa2                	ld	s5,8(sp)
    8000480e:	6121                	addi	sp,sp,64
    80004810:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004812:	0005ca97          	auipc	s5,0x5c
    80004816:	52ea8a93          	addi	s5,s5,1326 # 80060d40 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000481a:	0005ca17          	auipc	s4,0x5c
    8000481e:	4f6a0a13          	addi	s4,s4,1270 # 80060d10 <log>
    80004822:	018a2583          	lw	a1,24(s4)
    80004826:	012585bb          	addw	a1,a1,s2
    8000482a:	2585                	addiw	a1,a1,1
    8000482c:	028a2503          	lw	a0,40(s4)
    80004830:	fffff097          	auipc	ra,0xfffff
    80004834:	cc4080e7          	jalr	-828(ra) # 800034f4 <bread>
    80004838:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000483a:	000aa583          	lw	a1,0(s5)
    8000483e:	028a2503          	lw	a0,40(s4)
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	cb2080e7          	jalr	-846(ra) # 800034f4 <bread>
    8000484a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000484c:	40000613          	li	a2,1024
    80004850:	05850593          	addi	a1,a0,88
    80004854:	05848513          	addi	a0,s1,88
    80004858:	ffffc097          	auipc	ra,0xffffc
    8000485c:	66c080e7          	jalr	1644(ra) # 80000ec4 <memmove>
    bwrite(to);  // write the log
    80004860:	8526                	mv	a0,s1
    80004862:	fffff097          	auipc	ra,0xfffff
    80004866:	d84080e7          	jalr	-636(ra) # 800035e6 <bwrite>
    brelse(from);
    8000486a:	854e                	mv	a0,s3
    8000486c:	fffff097          	auipc	ra,0xfffff
    80004870:	db8080e7          	jalr	-584(ra) # 80003624 <brelse>
    brelse(to);
    80004874:	8526                	mv	a0,s1
    80004876:	fffff097          	auipc	ra,0xfffff
    8000487a:	dae080e7          	jalr	-594(ra) # 80003624 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000487e:	2905                	addiw	s2,s2,1
    80004880:	0a91                	addi	s5,s5,4
    80004882:	02ca2783          	lw	a5,44(s4)
    80004886:	f8f94ee3          	blt	s2,a5,80004822 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000488a:	00000097          	auipc	ra,0x0
    8000488e:	c68080e7          	jalr	-920(ra) # 800044f2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004892:	4501                	li	a0,0
    80004894:	00000097          	auipc	ra,0x0
    80004898:	cda080e7          	jalr	-806(ra) # 8000456e <install_trans>
    log.lh.n = 0;
    8000489c:	0005c797          	auipc	a5,0x5c
    800048a0:	4a07a023          	sw	zero,1184(a5) # 80060d3c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800048a4:	00000097          	auipc	ra,0x0
    800048a8:	c4e080e7          	jalr	-946(ra) # 800044f2 <write_head>
    800048ac:	bdf5                	j	800047a8 <end_op+0x52>

00000000800048ae <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800048ae:	1101                	addi	sp,sp,-32
    800048b0:	ec06                	sd	ra,24(sp)
    800048b2:	e822                	sd	s0,16(sp)
    800048b4:	e426                	sd	s1,8(sp)
    800048b6:	e04a                	sd	s2,0(sp)
    800048b8:	1000                	addi	s0,sp,32
    800048ba:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800048bc:	0005c917          	auipc	s2,0x5c
    800048c0:	45490913          	addi	s2,s2,1108 # 80060d10 <log>
    800048c4:	854a                	mv	a0,s2
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	4a6080e7          	jalr	1190(ra) # 80000d6c <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800048ce:	02c92603          	lw	a2,44(s2)
    800048d2:	47f5                	li	a5,29
    800048d4:	06c7c563          	blt	a5,a2,8000493e <log_write+0x90>
    800048d8:	0005c797          	auipc	a5,0x5c
    800048dc:	4547a783          	lw	a5,1108(a5) # 80060d2c <log+0x1c>
    800048e0:	37fd                	addiw	a5,a5,-1
    800048e2:	04f65e63          	bge	a2,a5,8000493e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800048e6:	0005c797          	auipc	a5,0x5c
    800048ea:	44a7a783          	lw	a5,1098(a5) # 80060d30 <log+0x20>
    800048ee:	06f05063          	blez	a5,8000494e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048f2:	4781                	li	a5,0
    800048f4:	06c05563          	blez	a2,8000495e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048f8:	44cc                	lw	a1,12(s1)
    800048fa:	0005c717          	auipc	a4,0x5c
    800048fe:	44670713          	addi	a4,a4,1094 # 80060d40 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004902:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004904:	4314                	lw	a3,0(a4)
    80004906:	04b68c63          	beq	a3,a1,8000495e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000490a:	2785                	addiw	a5,a5,1
    8000490c:	0711                	addi	a4,a4,4
    8000490e:	fef61be3          	bne	a2,a5,80004904 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004912:	0621                	addi	a2,a2,8
    80004914:	060a                	slli	a2,a2,0x2
    80004916:	0005c797          	auipc	a5,0x5c
    8000491a:	3fa78793          	addi	a5,a5,1018 # 80060d10 <log>
    8000491e:	97b2                	add	a5,a5,a2
    80004920:	44d8                	lw	a4,12(s1)
    80004922:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004924:	8526                	mv	a0,s1
    80004926:	fffff097          	auipc	ra,0xfffff
    8000492a:	d9c080e7          	jalr	-612(ra) # 800036c2 <bpin>
    log.lh.n++;
    8000492e:	0005c717          	auipc	a4,0x5c
    80004932:	3e270713          	addi	a4,a4,994 # 80060d10 <log>
    80004936:	575c                	lw	a5,44(a4)
    80004938:	2785                	addiw	a5,a5,1
    8000493a:	d75c                	sw	a5,44(a4)
    8000493c:	a82d                	j	80004976 <log_write+0xc8>
    panic("too big a transaction");
    8000493e:	00004517          	auipc	a0,0x4
    80004942:	eb250513          	addi	a0,a0,-334 # 800087f0 <syscalls+0x218>
    80004946:	ffffc097          	auipc	ra,0xffffc
    8000494a:	bfa080e7          	jalr	-1030(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    8000494e:	00004517          	auipc	a0,0x4
    80004952:	eba50513          	addi	a0,a0,-326 # 80008808 <syscalls+0x230>
    80004956:	ffffc097          	auipc	ra,0xffffc
    8000495a:	bea080e7          	jalr	-1046(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    8000495e:	00878693          	addi	a3,a5,8
    80004962:	068a                	slli	a3,a3,0x2
    80004964:	0005c717          	auipc	a4,0x5c
    80004968:	3ac70713          	addi	a4,a4,940 # 80060d10 <log>
    8000496c:	9736                	add	a4,a4,a3
    8000496e:	44d4                	lw	a3,12(s1)
    80004970:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004972:	faf609e3          	beq	a2,a5,80004924 <log_write+0x76>
  }
  release(&log.lock);
    80004976:	0005c517          	auipc	a0,0x5c
    8000497a:	39a50513          	addi	a0,a0,922 # 80060d10 <log>
    8000497e:	ffffc097          	auipc	ra,0xffffc
    80004982:	4a2080e7          	jalr	1186(ra) # 80000e20 <release>
}
    80004986:	60e2                	ld	ra,24(sp)
    80004988:	6442                	ld	s0,16(sp)
    8000498a:	64a2                	ld	s1,8(sp)
    8000498c:	6902                	ld	s2,0(sp)
    8000498e:	6105                	addi	sp,sp,32
    80004990:	8082                	ret

0000000080004992 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004992:	1101                	addi	sp,sp,-32
    80004994:	ec06                	sd	ra,24(sp)
    80004996:	e822                	sd	s0,16(sp)
    80004998:	e426                	sd	s1,8(sp)
    8000499a:	e04a                	sd	s2,0(sp)
    8000499c:	1000                	addi	s0,sp,32
    8000499e:	84aa                	mv	s1,a0
    800049a0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800049a2:	00004597          	auipc	a1,0x4
    800049a6:	e8658593          	addi	a1,a1,-378 # 80008828 <syscalls+0x250>
    800049aa:	0521                	addi	a0,a0,8
    800049ac:	ffffc097          	auipc	ra,0xffffc
    800049b0:	330080e7          	jalr	816(ra) # 80000cdc <initlock>
  lk->name = name;
    800049b4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800049b8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049bc:	0204a423          	sw	zero,40(s1)
}
    800049c0:	60e2                	ld	ra,24(sp)
    800049c2:	6442                	ld	s0,16(sp)
    800049c4:	64a2                	ld	s1,8(sp)
    800049c6:	6902                	ld	s2,0(sp)
    800049c8:	6105                	addi	sp,sp,32
    800049ca:	8082                	ret

00000000800049cc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049cc:	1101                	addi	sp,sp,-32
    800049ce:	ec06                	sd	ra,24(sp)
    800049d0:	e822                	sd	s0,16(sp)
    800049d2:	e426                	sd	s1,8(sp)
    800049d4:	e04a                	sd	s2,0(sp)
    800049d6:	1000                	addi	s0,sp,32
    800049d8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049da:	00850913          	addi	s2,a0,8
    800049de:	854a                	mv	a0,s2
    800049e0:	ffffc097          	auipc	ra,0xffffc
    800049e4:	38c080e7          	jalr	908(ra) # 80000d6c <acquire>
  while (lk->locked) {
    800049e8:	409c                	lw	a5,0(s1)
    800049ea:	cb89                	beqz	a5,800049fc <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049ec:	85ca                	mv	a1,s2
    800049ee:	8526                	mv	a0,s1
    800049f0:	ffffe097          	auipc	ra,0xffffe
    800049f4:	a2a080e7          	jalr	-1494(ra) # 8000241a <sleep>
  while (lk->locked) {
    800049f8:	409c                	lw	a5,0(s1)
    800049fa:	fbed                	bnez	a5,800049ec <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049fc:	4785                	li	a5,1
    800049fe:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a00:	ffffd097          	auipc	ra,0xffffd
    80004a04:	25a080e7          	jalr	602(ra) # 80001c5a <myproc>
    80004a08:	591c                	lw	a5,48(a0)
    80004a0a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a0c:	854a                	mv	a0,s2
    80004a0e:	ffffc097          	auipc	ra,0xffffc
    80004a12:	412080e7          	jalr	1042(ra) # 80000e20 <release>
}
    80004a16:	60e2                	ld	ra,24(sp)
    80004a18:	6442                	ld	s0,16(sp)
    80004a1a:	64a2                	ld	s1,8(sp)
    80004a1c:	6902                	ld	s2,0(sp)
    80004a1e:	6105                	addi	sp,sp,32
    80004a20:	8082                	ret

0000000080004a22 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a22:	1101                	addi	sp,sp,-32
    80004a24:	ec06                	sd	ra,24(sp)
    80004a26:	e822                	sd	s0,16(sp)
    80004a28:	e426                	sd	s1,8(sp)
    80004a2a:	e04a                	sd	s2,0(sp)
    80004a2c:	1000                	addi	s0,sp,32
    80004a2e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a30:	00850913          	addi	s2,a0,8
    80004a34:	854a                	mv	a0,s2
    80004a36:	ffffc097          	auipc	ra,0xffffc
    80004a3a:	336080e7          	jalr	822(ra) # 80000d6c <acquire>
  lk->locked = 0;
    80004a3e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a42:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a46:	8526                	mv	a0,s1
    80004a48:	ffffe097          	auipc	ra,0xffffe
    80004a4c:	a36080e7          	jalr	-1482(ra) # 8000247e <wakeup>
  release(&lk->lk);
    80004a50:	854a                	mv	a0,s2
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	3ce080e7          	jalr	974(ra) # 80000e20 <release>
}
    80004a5a:	60e2                	ld	ra,24(sp)
    80004a5c:	6442                	ld	s0,16(sp)
    80004a5e:	64a2                	ld	s1,8(sp)
    80004a60:	6902                	ld	s2,0(sp)
    80004a62:	6105                	addi	sp,sp,32
    80004a64:	8082                	ret

0000000080004a66 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a66:	7179                	addi	sp,sp,-48
    80004a68:	f406                	sd	ra,40(sp)
    80004a6a:	f022                	sd	s0,32(sp)
    80004a6c:	ec26                	sd	s1,24(sp)
    80004a6e:	e84a                	sd	s2,16(sp)
    80004a70:	e44e                	sd	s3,8(sp)
    80004a72:	1800                	addi	s0,sp,48
    80004a74:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a76:	00850913          	addi	s2,a0,8
    80004a7a:	854a                	mv	a0,s2
    80004a7c:	ffffc097          	auipc	ra,0xffffc
    80004a80:	2f0080e7          	jalr	752(ra) # 80000d6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a84:	409c                	lw	a5,0(s1)
    80004a86:	ef99                	bnez	a5,80004aa4 <holdingsleep+0x3e>
    80004a88:	4481                	li	s1,0
  release(&lk->lk);
    80004a8a:	854a                	mv	a0,s2
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	394080e7          	jalr	916(ra) # 80000e20 <release>
  return r;
}
    80004a94:	8526                	mv	a0,s1
    80004a96:	70a2                	ld	ra,40(sp)
    80004a98:	7402                	ld	s0,32(sp)
    80004a9a:	64e2                	ld	s1,24(sp)
    80004a9c:	6942                	ld	s2,16(sp)
    80004a9e:	69a2                	ld	s3,8(sp)
    80004aa0:	6145                	addi	sp,sp,48
    80004aa2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004aa4:	0284a983          	lw	s3,40(s1)
    80004aa8:	ffffd097          	auipc	ra,0xffffd
    80004aac:	1b2080e7          	jalr	434(ra) # 80001c5a <myproc>
    80004ab0:	5904                	lw	s1,48(a0)
    80004ab2:	413484b3          	sub	s1,s1,s3
    80004ab6:	0014b493          	seqz	s1,s1
    80004aba:	bfc1                	j	80004a8a <holdingsleep+0x24>

0000000080004abc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004abc:	1141                	addi	sp,sp,-16
    80004abe:	e406                	sd	ra,8(sp)
    80004ac0:	e022                	sd	s0,0(sp)
    80004ac2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ac4:	00004597          	auipc	a1,0x4
    80004ac8:	d7458593          	addi	a1,a1,-652 # 80008838 <syscalls+0x260>
    80004acc:	0005c517          	auipc	a0,0x5c
    80004ad0:	38c50513          	addi	a0,a0,908 # 80060e58 <ftable>
    80004ad4:	ffffc097          	auipc	ra,0xffffc
    80004ad8:	208080e7          	jalr	520(ra) # 80000cdc <initlock>
}
    80004adc:	60a2                	ld	ra,8(sp)
    80004ade:	6402                	ld	s0,0(sp)
    80004ae0:	0141                	addi	sp,sp,16
    80004ae2:	8082                	ret

0000000080004ae4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004ae4:	1101                	addi	sp,sp,-32
    80004ae6:	ec06                	sd	ra,24(sp)
    80004ae8:	e822                	sd	s0,16(sp)
    80004aea:	e426                	sd	s1,8(sp)
    80004aec:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004aee:	0005c517          	auipc	a0,0x5c
    80004af2:	36a50513          	addi	a0,a0,874 # 80060e58 <ftable>
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	276080e7          	jalr	630(ra) # 80000d6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004afe:	0005c497          	auipc	s1,0x5c
    80004b02:	37248493          	addi	s1,s1,882 # 80060e70 <ftable+0x18>
    80004b06:	0005d717          	auipc	a4,0x5d
    80004b0a:	30a70713          	addi	a4,a4,778 # 80061e10 <disk>
    if(f->ref == 0){
    80004b0e:	40dc                	lw	a5,4(s1)
    80004b10:	cf99                	beqz	a5,80004b2e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b12:	02848493          	addi	s1,s1,40
    80004b16:	fee49ce3          	bne	s1,a4,80004b0e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b1a:	0005c517          	auipc	a0,0x5c
    80004b1e:	33e50513          	addi	a0,a0,830 # 80060e58 <ftable>
    80004b22:	ffffc097          	auipc	ra,0xffffc
    80004b26:	2fe080e7          	jalr	766(ra) # 80000e20 <release>
  return 0;
    80004b2a:	4481                	li	s1,0
    80004b2c:	a819                	j	80004b42 <filealloc+0x5e>
      f->ref = 1;
    80004b2e:	4785                	li	a5,1
    80004b30:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b32:	0005c517          	auipc	a0,0x5c
    80004b36:	32650513          	addi	a0,a0,806 # 80060e58 <ftable>
    80004b3a:	ffffc097          	auipc	ra,0xffffc
    80004b3e:	2e6080e7          	jalr	742(ra) # 80000e20 <release>
}
    80004b42:	8526                	mv	a0,s1
    80004b44:	60e2                	ld	ra,24(sp)
    80004b46:	6442                	ld	s0,16(sp)
    80004b48:	64a2                	ld	s1,8(sp)
    80004b4a:	6105                	addi	sp,sp,32
    80004b4c:	8082                	ret

0000000080004b4e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b4e:	1101                	addi	sp,sp,-32
    80004b50:	ec06                	sd	ra,24(sp)
    80004b52:	e822                	sd	s0,16(sp)
    80004b54:	e426                	sd	s1,8(sp)
    80004b56:	1000                	addi	s0,sp,32
    80004b58:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b5a:	0005c517          	auipc	a0,0x5c
    80004b5e:	2fe50513          	addi	a0,a0,766 # 80060e58 <ftable>
    80004b62:	ffffc097          	auipc	ra,0xffffc
    80004b66:	20a080e7          	jalr	522(ra) # 80000d6c <acquire>
  if(f->ref < 1)
    80004b6a:	40dc                	lw	a5,4(s1)
    80004b6c:	02f05263          	blez	a5,80004b90 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b70:	2785                	addiw	a5,a5,1
    80004b72:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b74:	0005c517          	auipc	a0,0x5c
    80004b78:	2e450513          	addi	a0,a0,740 # 80060e58 <ftable>
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	2a4080e7          	jalr	676(ra) # 80000e20 <release>
  return f;
}
    80004b84:	8526                	mv	a0,s1
    80004b86:	60e2                	ld	ra,24(sp)
    80004b88:	6442                	ld	s0,16(sp)
    80004b8a:	64a2                	ld	s1,8(sp)
    80004b8c:	6105                	addi	sp,sp,32
    80004b8e:	8082                	ret
    panic("filedup");
    80004b90:	00004517          	auipc	a0,0x4
    80004b94:	cb050513          	addi	a0,a0,-848 # 80008840 <syscalls+0x268>
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	9a8080e7          	jalr	-1624(ra) # 80000540 <panic>

0000000080004ba0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ba0:	7139                	addi	sp,sp,-64
    80004ba2:	fc06                	sd	ra,56(sp)
    80004ba4:	f822                	sd	s0,48(sp)
    80004ba6:	f426                	sd	s1,40(sp)
    80004ba8:	f04a                	sd	s2,32(sp)
    80004baa:	ec4e                	sd	s3,24(sp)
    80004bac:	e852                	sd	s4,16(sp)
    80004bae:	e456                	sd	s5,8(sp)
    80004bb0:	0080                	addi	s0,sp,64
    80004bb2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004bb4:	0005c517          	auipc	a0,0x5c
    80004bb8:	2a450513          	addi	a0,a0,676 # 80060e58 <ftable>
    80004bbc:	ffffc097          	auipc	ra,0xffffc
    80004bc0:	1b0080e7          	jalr	432(ra) # 80000d6c <acquire>
  if(f->ref < 1)
    80004bc4:	40dc                	lw	a5,4(s1)
    80004bc6:	06f05163          	blez	a5,80004c28 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004bca:	37fd                	addiw	a5,a5,-1
    80004bcc:	0007871b          	sext.w	a4,a5
    80004bd0:	c0dc                	sw	a5,4(s1)
    80004bd2:	06e04363          	bgtz	a4,80004c38 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004bd6:	0004a903          	lw	s2,0(s1)
    80004bda:	0094ca83          	lbu	s5,9(s1)
    80004bde:	0104ba03          	ld	s4,16(s1)
    80004be2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004be6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004bea:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004bee:	0005c517          	auipc	a0,0x5c
    80004bf2:	26a50513          	addi	a0,a0,618 # 80060e58 <ftable>
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	22a080e7          	jalr	554(ra) # 80000e20 <release>

  if(ff.type == FD_PIPE){
    80004bfe:	4785                	li	a5,1
    80004c00:	04f90d63          	beq	s2,a5,80004c5a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004c04:	3979                	addiw	s2,s2,-2
    80004c06:	4785                	li	a5,1
    80004c08:	0527e063          	bltu	a5,s2,80004c48 <fileclose+0xa8>
    begin_op();
    80004c0c:	00000097          	auipc	ra,0x0
    80004c10:	acc080e7          	jalr	-1332(ra) # 800046d8 <begin_op>
    iput(ff.ip);
    80004c14:	854e                	mv	a0,s3
    80004c16:	fffff097          	auipc	ra,0xfffff
    80004c1a:	2b0080e7          	jalr	688(ra) # 80003ec6 <iput>
    end_op();
    80004c1e:	00000097          	auipc	ra,0x0
    80004c22:	b38080e7          	jalr	-1224(ra) # 80004756 <end_op>
    80004c26:	a00d                	j	80004c48 <fileclose+0xa8>
    panic("fileclose");
    80004c28:	00004517          	auipc	a0,0x4
    80004c2c:	c2050513          	addi	a0,a0,-992 # 80008848 <syscalls+0x270>
    80004c30:	ffffc097          	auipc	ra,0xffffc
    80004c34:	910080e7          	jalr	-1776(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004c38:	0005c517          	auipc	a0,0x5c
    80004c3c:	22050513          	addi	a0,a0,544 # 80060e58 <ftable>
    80004c40:	ffffc097          	auipc	ra,0xffffc
    80004c44:	1e0080e7          	jalr	480(ra) # 80000e20 <release>
  }
}
    80004c48:	70e2                	ld	ra,56(sp)
    80004c4a:	7442                	ld	s0,48(sp)
    80004c4c:	74a2                	ld	s1,40(sp)
    80004c4e:	7902                	ld	s2,32(sp)
    80004c50:	69e2                	ld	s3,24(sp)
    80004c52:	6a42                	ld	s4,16(sp)
    80004c54:	6aa2                	ld	s5,8(sp)
    80004c56:	6121                	addi	sp,sp,64
    80004c58:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c5a:	85d6                	mv	a1,s5
    80004c5c:	8552                	mv	a0,s4
    80004c5e:	00000097          	auipc	ra,0x0
    80004c62:	34c080e7          	jalr	844(ra) # 80004faa <pipeclose>
    80004c66:	b7cd                	j	80004c48 <fileclose+0xa8>

0000000080004c68 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c68:	715d                	addi	sp,sp,-80
    80004c6a:	e486                	sd	ra,72(sp)
    80004c6c:	e0a2                	sd	s0,64(sp)
    80004c6e:	fc26                	sd	s1,56(sp)
    80004c70:	f84a                	sd	s2,48(sp)
    80004c72:	f44e                	sd	s3,40(sp)
    80004c74:	0880                	addi	s0,sp,80
    80004c76:	84aa                	mv	s1,a0
    80004c78:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c7a:	ffffd097          	auipc	ra,0xffffd
    80004c7e:	fe0080e7          	jalr	-32(ra) # 80001c5a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c82:	409c                	lw	a5,0(s1)
    80004c84:	37f9                	addiw	a5,a5,-2
    80004c86:	4705                	li	a4,1
    80004c88:	04f76763          	bltu	a4,a5,80004cd6 <filestat+0x6e>
    80004c8c:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c8e:	6c88                	ld	a0,24(s1)
    80004c90:	fffff097          	auipc	ra,0xfffff
    80004c94:	07c080e7          	jalr	124(ra) # 80003d0c <ilock>
    stati(f->ip, &st);
    80004c98:	fb840593          	addi	a1,s0,-72
    80004c9c:	6c88                	ld	a0,24(s1)
    80004c9e:	fffff097          	auipc	ra,0xfffff
    80004ca2:	2f8080e7          	jalr	760(ra) # 80003f96 <stati>
    iunlock(f->ip);
    80004ca6:	6c88                	ld	a0,24(s1)
    80004ca8:	fffff097          	auipc	ra,0xfffff
    80004cac:	126080e7          	jalr	294(ra) # 80003dce <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004cb0:	46e1                	li	a3,24
    80004cb2:	fb840613          	addi	a2,s0,-72
    80004cb6:	85ce                	mv	a1,s3
    80004cb8:	05093503          	ld	a0,80(s2)
    80004cbc:	ffffd097          	auipc	ra,0xffffd
    80004cc0:	b60080e7          	jalr	-1184(ra) # 8000181c <copyout>
    80004cc4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004cc8:	60a6                	ld	ra,72(sp)
    80004cca:	6406                	ld	s0,64(sp)
    80004ccc:	74e2                	ld	s1,56(sp)
    80004cce:	7942                	ld	s2,48(sp)
    80004cd0:	79a2                	ld	s3,40(sp)
    80004cd2:	6161                	addi	sp,sp,80
    80004cd4:	8082                	ret
  return -1;
    80004cd6:	557d                	li	a0,-1
    80004cd8:	bfc5                	j	80004cc8 <filestat+0x60>

0000000080004cda <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004cda:	7179                	addi	sp,sp,-48
    80004cdc:	f406                	sd	ra,40(sp)
    80004cde:	f022                	sd	s0,32(sp)
    80004ce0:	ec26                	sd	s1,24(sp)
    80004ce2:	e84a                	sd	s2,16(sp)
    80004ce4:	e44e                	sd	s3,8(sp)
    80004ce6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004ce8:	00854783          	lbu	a5,8(a0)
    80004cec:	c3d5                	beqz	a5,80004d90 <fileread+0xb6>
    80004cee:	84aa                	mv	s1,a0
    80004cf0:	89ae                	mv	s3,a1
    80004cf2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cf4:	411c                	lw	a5,0(a0)
    80004cf6:	4705                	li	a4,1
    80004cf8:	04e78963          	beq	a5,a4,80004d4a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cfc:	470d                	li	a4,3
    80004cfe:	04e78d63          	beq	a5,a4,80004d58 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d02:	4709                	li	a4,2
    80004d04:	06e79e63          	bne	a5,a4,80004d80 <fileread+0xa6>
    ilock(f->ip);
    80004d08:	6d08                	ld	a0,24(a0)
    80004d0a:	fffff097          	auipc	ra,0xfffff
    80004d0e:	002080e7          	jalr	2(ra) # 80003d0c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d12:	874a                	mv	a4,s2
    80004d14:	5094                	lw	a3,32(s1)
    80004d16:	864e                	mv	a2,s3
    80004d18:	4585                	li	a1,1
    80004d1a:	6c88                	ld	a0,24(s1)
    80004d1c:	fffff097          	auipc	ra,0xfffff
    80004d20:	2a4080e7          	jalr	676(ra) # 80003fc0 <readi>
    80004d24:	892a                	mv	s2,a0
    80004d26:	00a05563          	blez	a0,80004d30 <fileread+0x56>
      f->off += r;
    80004d2a:	509c                	lw	a5,32(s1)
    80004d2c:	9fa9                	addw	a5,a5,a0
    80004d2e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d30:	6c88                	ld	a0,24(s1)
    80004d32:	fffff097          	auipc	ra,0xfffff
    80004d36:	09c080e7          	jalr	156(ra) # 80003dce <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d3a:	854a                	mv	a0,s2
    80004d3c:	70a2                	ld	ra,40(sp)
    80004d3e:	7402                	ld	s0,32(sp)
    80004d40:	64e2                	ld	s1,24(sp)
    80004d42:	6942                	ld	s2,16(sp)
    80004d44:	69a2                	ld	s3,8(sp)
    80004d46:	6145                	addi	sp,sp,48
    80004d48:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d4a:	6908                	ld	a0,16(a0)
    80004d4c:	00000097          	auipc	ra,0x0
    80004d50:	3c6080e7          	jalr	966(ra) # 80005112 <piperead>
    80004d54:	892a                	mv	s2,a0
    80004d56:	b7d5                	j	80004d3a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d58:	02451783          	lh	a5,36(a0)
    80004d5c:	03079693          	slli	a3,a5,0x30
    80004d60:	92c1                	srli	a3,a3,0x30
    80004d62:	4725                	li	a4,9
    80004d64:	02d76863          	bltu	a4,a3,80004d94 <fileread+0xba>
    80004d68:	0792                	slli	a5,a5,0x4
    80004d6a:	0005c717          	auipc	a4,0x5c
    80004d6e:	04e70713          	addi	a4,a4,78 # 80060db8 <devsw>
    80004d72:	97ba                	add	a5,a5,a4
    80004d74:	639c                	ld	a5,0(a5)
    80004d76:	c38d                	beqz	a5,80004d98 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d78:	4505                	li	a0,1
    80004d7a:	9782                	jalr	a5
    80004d7c:	892a                	mv	s2,a0
    80004d7e:	bf75                	j	80004d3a <fileread+0x60>
    panic("fileread");
    80004d80:	00004517          	auipc	a0,0x4
    80004d84:	ad850513          	addi	a0,a0,-1320 # 80008858 <syscalls+0x280>
    80004d88:	ffffb097          	auipc	ra,0xffffb
    80004d8c:	7b8080e7          	jalr	1976(ra) # 80000540 <panic>
    return -1;
    80004d90:	597d                	li	s2,-1
    80004d92:	b765                	j	80004d3a <fileread+0x60>
      return -1;
    80004d94:	597d                	li	s2,-1
    80004d96:	b755                	j	80004d3a <fileread+0x60>
    80004d98:	597d                	li	s2,-1
    80004d9a:	b745                	j	80004d3a <fileread+0x60>

0000000080004d9c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d9c:	715d                	addi	sp,sp,-80
    80004d9e:	e486                	sd	ra,72(sp)
    80004da0:	e0a2                	sd	s0,64(sp)
    80004da2:	fc26                	sd	s1,56(sp)
    80004da4:	f84a                	sd	s2,48(sp)
    80004da6:	f44e                	sd	s3,40(sp)
    80004da8:	f052                	sd	s4,32(sp)
    80004daa:	ec56                	sd	s5,24(sp)
    80004dac:	e85a                	sd	s6,16(sp)
    80004dae:	e45e                	sd	s7,8(sp)
    80004db0:	e062                	sd	s8,0(sp)
    80004db2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004db4:	00954783          	lbu	a5,9(a0)
    80004db8:	10078663          	beqz	a5,80004ec4 <filewrite+0x128>
    80004dbc:	892a                	mv	s2,a0
    80004dbe:	8b2e                	mv	s6,a1
    80004dc0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dc2:	411c                	lw	a5,0(a0)
    80004dc4:	4705                	li	a4,1
    80004dc6:	02e78263          	beq	a5,a4,80004dea <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dca:	470d                	li	a4,3
    80004dcc:	02e78663          	beq	a5,a4,80004df8 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dd0:	4709                	li	a4,2
    80004dd2:	0ee79163          	bne	a5,a4,80004eb4 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004dd6:	0ac05d63          	blez	a2,80004e90 <filewrite+0xf4>
    int i = 0;
    80004dda:	4981                	li	s3,0
    80004ddc:	6b85                	lui	s7,0x1
    80004dde:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004de2:	6c05                	lui	s8,0x1
    80004de4:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004de8:	a861                	j	80004e80 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004dea:	6908                	ld	a0,16(a0)
    80004dec:	00000097          	auipc	ra,0x0
    80004df0:	22e080e7          	jalr	558(ra) # 8000501a <pipewrite>
    80004df4:	8a2a                	mv	s4,a0
    80004df6:	a045                	j	80004e96 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004df8:	02451783          	lh	a5,36(a0)
    80004dfc:	03079693          	slli	a3,a5,0x30
    80004e00:	92c1                	srli	a3,a3,0x30
    80004e02:	4725                	li	a4,9
    80004e04:	0cd76263          	bltu	a4,a3,80004ec8 <filewrite+0x12c>
    80004e08:	0792                	slli	a5,a5,0x4
    80004e0a:	0005c717          	auipc	a4,0x5c
    80004e0e:	fae70713          	addi	a4,a4,-82 # 80060db8 <devsw>
    80004e12:	97ba                	add	a5,a5,a4
    80004e14:	679c                	ld	a5,8(a5)
    80004e16:	cbdd                	beqz	a5,80004ecc <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e18:	4505                	li	a0,1
    80004e1a:	9782                	jalr	a5
    80004e1c:	8a2a                	mv	s4,a0
    80004e1e:	a8a5                	j	80004e96 <filewrite+0xfa>
    80004e20:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e24:	00000097          	auipc	ra,0x0
    80004e28:	8b4080e7          	jalr	-1868(ra) # 800046d8 <begin_op>
      ilock(f->ip);
    80004e2c:	01893503          	ld	a0,24(s2)
    80004e30:	fffff097          	auipc	ra,0xfffff
    80004e34:	edc080e7          	jalr	-292(ra) # 80003d0c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e38:	8756                	mv	a4,s5
    80004e3a:	02092683          	lw	a3,32(s2)
    80004e3e:	01698633          	add	a2,s3,s6
    80004e42:	4585                	li	a1,1
    80004e44:	01893503          	ld	a0,24(s2)
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	270080e7          	jalr	624(ra) # 800040b8 <writei>
    80004e50:	84aa                	mv	s1,a0
    80004e52:	00a05763          	blez	a0,80004e60 <filewrite+0xc4>
        f->off += r;
    80004e56:	02092783          	lw	a5,32(s2)
    80004e5a:	9fa9                	addw	a5,a5,a0
    80004e5c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e60:	01893503          	ld	a0,24(s2)
    80004e64:	fffff097          	auipc	ra,0xfffff
    80004e68:	f6a080e7          	jalr	-150(ra) # 80003dce <iunlock>
      end_op();
    80004e6c:	00000097          	auipc	ra,0x0
    80004e70:	8ea080e7          	jalr	-1814(ra) # 80004756 <end_op>

      if(r != n1){
    80004e74:	009a9f63          	bne	s5,s1,80004e92 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e78:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e7c:	0149db63          	bge	s3,s4,80004e92 <filewrite+0xf6>
      int n1 = n - i;
    80004e80:	413a04bb          	subw	s1,s4,s3
    80004e84:	0004879b          	sext.w	a5,s1
    80004e88:	f8fbdce3          	bge	s7,a5,80004e20 <filewrite+0x84>
    80004e8c:	84e2                	mv	s1,s8
    80004e8e:	bf49                	j	80004e20 <filewrite+0x84>
    int i = 0;
    80004e90:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e92:	013a1f63          	bne	s4,s3,80004eb0 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e96:	8552                	mv	a0,s4
    80004e98:	60a6                	ld	ra,72(sp)
    80004e9a:	6406                	ld	s0,64(sp)
    80004e9c:	74e2                	ld	s1,56(sp)
    80004e9e:	7942                	ld	s2,48(sp)
    80004ea0:	79a2                	ld	s3,40(sp)
    80004ea2:	7a02                	ld	s4,32(sp)
    80004ea4:	6ae2                	ld	s5,24(sp)
    80004ea6:	6b42                	ld	s6,16(sp)
    80004ea8:	6ba2                	ld	s7,8(sp)
    80004eaa:	6c02                	ld	s8,0(sp)
    80004eac:	6161                	addi	sp,sp,80
    80004eae:	8082                	ret
    ret = (i == n ? n : -1);
    80004eb0:	5a7d                	li	s4,-1
    80004eb2:	b7d5                	j	80004e96 <filewrite+0xfa>
    panic("filewrite");
    80004eb4:	00004517          	auipc	a0,0x4
    80004eb8:	9b450513          	addi	a0,a0,-1612 # 80008868 <syscalls+0x290>
    80004ebc:	ffffb097          	auipc	ra,0xffffb
    80004ec0:	684080e7          	jalr	1668(ra) # 80000540 <panic>
    return -1;
    80004ec4:	5a7d                	li	s4,-1
    80004ec6:	bfc1                	j	80004e96 <filewrite+0xfa>
      return -1;
    80004ec8:	5a7d                	li	s4,-1
    80004eca:	b7f1                	j	80004e96 <filewrite+0xfa>
    80004ecc:	5a7d                	li	s4,-1
    80004ece:	b7e1                	j	80004e96 <filewrite+0xfa>

0000000080004ed0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ed0:	7179                	addi	sp,sp,-48
    80004ed2:	f406                	sd	ra,40(sp)
    80004ed4:	f022                	sd	s0,32(sp)
    80004ed6:	ec26                	sd	s1,24(sp)
    80004ed8:	e84a                	sd	s2,16(sp)
    80004eda:	e44e                	sd	s3,8(sp)
    80004edc:	e052                	sd	s4,0(sp)
    80004ede:	1800                	addi	s0,sp,48
    80004ee0:	84aa                	mv	s1,a0
    80004ee2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ee4:	0005b023          	sd	zero,0(a1)
    80004ee8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004eec:	00000097          	auipc	ra,0x0
    80004ef0:	bf8080e7          	jalr	-1032(ra) # 80004ae4 <filealloc>
    80004ef4:	e088                	sd	a0,0(s1)
    80004ef6:	c551                	beqz	a0,80004f82 <pipealloc+0xb2>
    80004ef8:	00000097          	auipc	ra,0x0
    80004efc:	bec080e7          	jalr	-1044(ra) # 80004ae4 <filealloc>
    80004f00:	00aa3023          	sd	a0,0(s4)
    80004f04:	c92d                	beqz	a0,80004f76 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f06:	ffffc097          	auipc	ra,0xffffc
    80004f0a:	cb8080e7          	jalr	-840(ra) # 80000bbe <kalloc>
    80004f0e:	892a                	mv	s2,a0
    80004f10:	c125                	beqz	a0,80004f70 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f12:	4985                	li	s3,1
    80004f14:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f18:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f1c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f20:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f24:	00004597          	auipc	a1,0x4
    80004f28:	95458593          	addi	a1,a1,-1708 # 80008878 <syscalls+0x2a0>
    80004f2c:	ffffc097          	auipc	ra,0xffffc
    80004f30:	db0080e7          	jalr	-592(ra) # 80000cdc <initlock>
  (*f0)->type = FD_PIPE;
    80004f34:	609c                	ld	a5,0(s1)
    80004f36:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f3a:	609c                	ld	a5,0(s1)
    80004f3c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f40:	609c                	ld	a5,0(s1)
    80004f42:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f46:	609c                	ld	a5,0(s1)
    80004f48:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f4c:	000a3783          	ld	a5,0(s4)
    80004f50:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f54:	000a3783          	ld	a5,0(s4)
    80004f58:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f5c:	000a3783          	ld	a5,0(s4)
    80004f60:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f64:	000a3783          	ld	a5,0(s4)
    80004f68:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f6c:	4501                	li	a0,0
    80004f6e:	a025                	j	80004f96 <pipealloc+0xc6>

 bad:
  if(pi)
    dec_ref((char*)pi);
  if(*f0)
    80004f70:	6088                	ld	a0,0(s1)
    80004f72:	e501                	bnez	a0,80004f7a <pipealloc+0xaa>
    80004f74:	a039                	j	80004f82 <pipealloc+0xb2>
    80004f76:	6088                	ld	a0,0(s1)
    80004f78:	c51d                	beqz	a0,80004fa6 <pipealloc+0xd6>
    fileclose(*f0);
    80004f7a:	00000097          	auipc	ra,0x0
    80004f7e:	c26080e7          	jalr	-986(ra) # 80004ba0 <fileclose>
  if(*f1)
    80004f82:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f86:	557d                	li	a0,-1
  if(*f1)
    80004f88:	c799                	beqz	a5,80004f96 <pipealloc+0xc6>
    fileclose(*f1);
    80004f8a:	853e                	mv	a0,a5
    80004f8c:	00000097          	auipc	ra,0x0
    80004f90:	c14080e7          	jalr	-1004(ra) # 80004ba0 <fileclose>
  return -1;
    80004f94:	557d                	li	a0,-1
}
    80004f96:	70a2                	ld	ra,40(sp)
    80004f98:	7402                	ld	s0,32(sp)
    80004f9a:	64e2                	ld	s1,24(sp)
    80004f9c:	6942                	ld	s2,16(sp)
    80004f9e:	69a2                	ld	s3,8(sp)
    80004fa0:	6a02                	ld	s4,0(sp)
    80004fa2:	6145                	addi	sp,sp,48
    80004fa4:	8082                	ret
  return -1;
    80004fa6:	557d                	li	a0,-1
    80004fa8:	b7fd                	j	80004f96 <pipealloc+0xc6>

0000000080004faa <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004faa:	1101                	addi	sp,sp,-32
    80004fac:	ec06                	sd	ra,24(sp)
    80004fae:	e822                	sd	s0,16(sp)
    80004fb0:	e426                	sd	s1,8(sp)
    80004fb2:	e04a                	sd	s2,0(sp)
    80004fb4:	1000                	addi	s0,sp,32
    80004fb6:	84aa                	mv	s1,a0
    80004fb8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004fba:	ffffc097          	auipc	ra,0xffffc
    80004fbe:	db2080e7          	jalr	-590(ra) # 80000d6c <acquire>
  if(writable){
    80004fc2:	02090d63          	beqz	s2,80004ffc <pipeclose+0x52>
    pi->writeopen = 0;
    80004fc6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fca:	21848513          	addi	a0,s1,536
    80004fce:	ffffd097          	auipc	ra,0xffffd
    80004fd2:	4b0080e7          	jalr	1200(ra) # 8000247e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004fd6:	2204b783          	ld	a5,544(s1)
    80004fda:	eb95                	bnez	a5,8000500e <pipeclose+0x64>
    release(&pi->lock);
    80004fdc:	8526                	mv	a0,s1
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	e42080e7          	jalr	-446(ra) # 80000e20 <release>
    dec_ref((char*)pi);
    80004fe6:	8526                	mv	a0,s1
    80004fe8:	ffffc097          	auipc	ra,0xffffc
    80004fec:	c8c080e7          	jalr	-884(ra) # 80000c74 <dec_ref>
  } else
    release(&pi->lock);
}
    80004ff0:	60e2                	ld	ra,24(sp)
    80004ff2:	6442                	ld	s0,16(sp)
    80004ff4:	64a2                	ld	s1,8(sp)
    80004ff6:	6902                	ld	s2,0(sp)
    80004ff8:	6105                	addi	sp,sp,32
    80004ffa:	8082                	ret
    pi->readopen = 0;
    80004ffc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005000:	21c48513          	addi	a0,s1,540
    80005004:	ffffd097          	auipc	ra,0xffffd
    80005008:	47a080e7          	jalr	1146(ra) # 8000247e <wakeup>
    8000500c:	b7e9                	j	80004fd6 <pipeclose+0x2c>
    release(&pi->lock);
    8000500e:	8526                	mv	a0,s1
    80005010:	ffffc097          	auipc	ra,0xffffc
    80005014:	e10080e7          	jalr	-496(ra) # 80000e20 <release>
}
    80005018:	bfe1                	j	80004ff0 <pipeclose+0x46>

000000008000501a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000501a:	711d                	addi	sp,sp,-96
    8000501c:	ec86                	sd	ra,88(sp)
    8000501e:	e8a2                	sd	s0,80(sp)
    80005020:	e4a6                	sd	s1,72(sp)
    80005022:	e0ca                	sd	s2,64(sp)
    80005024:	fc4e                	sd	s3,56(sp)
    80005026:	f852                	sd	s4,48(sp)
    80005028:	f456                	sd	s5,40(sp)
    8000502a:	f05a                	sd	s6,32(sp)
    8000502c:	ec5e                	sd	s7,24(sp)
    8000502e:	e862                	sd	s8,16(sp)
    80005030:	1080                	addi	s0,sp,96
    80005032:	84aa                	mv	s1,a0
    80005034:	8aae                	mv	s5,a1
    80005036:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005038:	ffffd097          	auipc	ra,0xffffd
    8000503c:	c22080e7          	jalr	-990(ra) # 80001c5a <myproc>
    80005040:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005042:	8526                	mv	a0,s1
    80005044:	ffffc097          	auipc	ra,0xffffc
    80005048:	d28080e7          	jalr	-728(ra) # 80000d6c <acquire>
  while(i < n){
    8000504c:	0b405663          	blez	s4,800050f8 <pipewrite+0xde>
  int i = 0;
    80005050:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005052:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005054:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005058:	21c48b93          	addi	s7,s1,540
    8000505c:	a089                	j	8000509e <pipewrite+0x84>
      release(&pi->lock);
    8000505e:	8526                	mv	a0,s1
    80005060:	ffffc097          	auipc	ra,0xffffc
    80005064:	dc0080e7          	jalr	-576(ra) # 80000e20 <release>
      return -1;
    80005068:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000506a:	854a                	mv	a0,s2
    8000506c:	60e6                	ld	ra,88(sp)
    8000506e:	6446                	ld	s0,80(sp)
    80005070:	64a6                	ld	s1,72(sp)
    80005072:	6906                	ld	s2,64(sp)
    80005074:	79e2                	ld	s3,56(sp)
    80005076:	7a42                	ld	s4,48(sp)
    80005078:	7aa2                	ld	s5,40(sp)
    8000507a:	7b02                	ld	s6,32(sp)
    8000507c:	6be2                	ld	s7,24(sp)
    8000507e:	6c42                	ld	s8,16(sp)
    80005080:	6125                	addi	sp,sp,96
    80005082:	8082                	ret
      wakeup(&pi->nread);
    80005084:	8562                	mv	a0,s8
    80005086:	ffffd097          	auipc	ra,0xffffd
    8000508a:	3f8080e7          	jalr	1016(ra) # 8000247e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000508e:	85a6                	mv	a1,s1
    80005090:	855e                	mv	a0,s7
    80005092:	ffffd097          	auipc	ra,0xffffd
    80005096:	388080e7          	jalr	904(ra) # 8000241a <sleep>
  while(i < n){
    8000509a:	07495063          	bge	s2,s4,800050fa <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    8000509e:	2204a783          	lw	a5,544(s1)
    800050a2:	dfd5                	beqz	a5,8000505e <pipewrite+0x44>
    800050a4:	854e                	mv	a0,s3
    800050a6:	ffffd097          	auipc	ra,0xffffd
    800050aa:	61c080e7          	jalr	1564(ra) # 800026c2 <killed>
    800050ae:	f945                	bnez	a0,8000505e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050b0:	2184a783          	lw	a5,536(s1)
    800050b4:	21c4a703          	lw	a4,540(s1)
    800050b8:	2007879b          	addiw	a5,a5,512
    800050bc:	fcf704e3          	beq	a4,a5,80005084 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050c0:	4685                	li	a3,1
    800050c2:	01590633          	add	a2,s2,s5
    800050c6:	faf40593          	addi	a1,s0,-81
    800050ca:	0509b503          	ld	a0,80(s3)
    800050ce:	ffffc097          	auipc	ra,0xffffc
    800050d2:	7da080e7          	jalr	2010(ra) # 800018a8 <copyin>
    800050d6:	03650263          	beq	a0,s6,800050fa <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800050da:	21c4a783          	lw	a5,540(s1)
    800050de:	0017871b          	addiw	a4,a5,1
    800050e2:	20e4ae23          	sw	a4,540(s1)
    800050e6:	1ff7f793          	andi	a5,a5,511
    800050ea:	97a6                	add	a5,a5,s1
    800050ec:	faf44703          	lbu	a4,-81(s0)
    800050f0:	00e78c23          	sb	a4,24(a5)
      i++;
    800050f4:	2905                	addiw	s2,s2,1
    800050f6:	b755                	j	8000509a <pipewrite+0x80>
  int i = 0;
    800050f8:	4901                	li	s2,0
  wakeup(&pi->nread);
    800050fa:	21848513          	addi	a0,s1,536
    800050fe:	ffffd097          	auipc	ra,0xffffd
    80005102:	380080e7          	jalr	896(ra) # 8000247e <wakeup>
  release(&pi->lock);
    80005106:	8526                	mv	a0,s1
    80005108:	ffffc097          	auipc	ra,0xffffc
    8000510c:	d18080e7          	jalr	-744(ra) # 80000e20 <release>
  return i;
    80005110:	bfa9                	j	8000506a <pipewrite+0x50>

0000000080005112 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005112:	715d                	addi	sp,sp,-80
    80005114:	e486                	sd	ra,72(sp)
    80005116:	e0a2                	sd	s0,64(sp)
    80005118:	fc26                	sd	s1,56(sp)
    8000511a:	f84a                	sd	s2,48(sp)
    8000511c:	f44e                	sd	s3,40(sp)
    8000511e:	f052                	sd	s4,32(sp)
    80005120:	ec56                	sd	s5,24(sp)
    80005122:	e85a                	sd	s6,16(sp)
    80005124:	0880                	addi	s0,sp,80
    80005126:	84aa                	mv	s1,a0
    80005128:	892e                	mv	s2,a1
    8000512a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000512c:	ffffd097          	auipc	ra,0xffffd
    80005130:	b2e080e7          	jalr	-1234(ra) # 80001c5a <myproc>
    80005134:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005136:	8526                	mv	a0,s1
    80005138:	ffffc097          	auipc	ra,0xffffc
    8000513c:	c34080e7          	jalr	-972(ra) # 80000d6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005140:	2184a703          	lw	a4,536(s1)
    80005144:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005148:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000514c:	02f71763          	bne	a4,a5,8000517a <piperead+0x68>
    80005150:	2244a783          	lw	a5,548(s1)
    80005154:	c39d                	beqz	a5,8000517a <piperead+0x68>
    if(killed(pr)){
    80005156:	8552                	mv	a0,s4
    80005158:	ffffd097          	auipc	ra,0xffffd
    8000515c:	56a080e7          	jalr	1386(ra) # 800026c2 <killed>
    80005160:	e949                	bnez	a0,800051f2 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005162:	85a6                	mv	a1,s1
    80005164:	854e                	mv	a0,s3
    80005166:	ffffd097          	auipc	ra,0xffffd
    8000516a:	2b4080e7          	jalr	692(ra) # 8000241a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000516e:	2184a703          	lw	a4,536(s1)
    80005172:	21c4a783          	lw	a5,540(s1)
    80005176:	fcf70de3          	beq	a4,a5,80005150 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000517a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000517c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000517e:	05505463          	blez	s5,800051c6 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005182:	2184a783          	lw	a5,536(s1)
    80005186:	21c4a703          	lw	a4,540(s1)
    8000518a:	02f70e63          	beq	a4,a5,800051c6 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000518e:	0017871b          	addiw	a4,a5,1
    80005192:	20e4ac23          	sw	a4,536(s1)
    80005196:	1ff7f793          	andi	a5,a5,511
    8000519a:	97a6                	add	a5,a5,s1
    8000519c:	0187c783          	lbu	a5,24(a5)
    800051a0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051a4:	4685                	li	a3,1
    800051a6:	fbf40613          	addi	a2,s0,-65
    800051aa:	85ca                	mv	a1,s2
    800051ac:	050a3503          	ld	a0,80(s4)
    800051b0:	ffffc097          	auipc	ra,0xffffc
    800051b4:	66c080e7          	jalr	1644(ra) # 8000181c <copyout>
    800051b8:	01650763          	beq	a0,s6,800051c6 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051bc:	2985                	addiw	s3,s3,1
    800051be:	0905                	addi	s2,s2,1
    800051c0:	fd3a91e3          	bne	s5,s3,80005182 <piperead+0x70>
    800051c4:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051c6:	21c48513          	addi	a0,s1,540
    800051ca:	ffffd097          	auipc	ra,0xffffd
    800051ce:	2b4080e7          	jalr	692(ra) # 8000247e <wakeup>
  release(&pi->lock);
    800051d2:	8526                	mv	a0,s1
    800051d4:	ffffc097          	auipc	ra,0xffffc
    800051d8:	c4c080e7          	jalr	-948(ra) # 80000e20 <release>
  return i;
}
    800051dc:	854e                	mv	a0,s3
    800051de:	60a6                	ld	ra,72(sp)
    800051e0:	6406                	ld	s0,64(sp)
    800051e2:	74e2                	ld	s1,56(sp)
    800051e4:	7942                	ld	s2,48(sp)
    800051e6:	79a2                	ld	s3,40(sp)
    800051e8:	7a02                	ld	s4,32(sp)
    800051ea:	6ae2                	ld	s5,24(sp)
    800051ec:	6b42                	ld	s6,16(sp)
    800051ee:	6161                	addi	sp,sp,80
    800051f0:	8082                	ret
      release(&pi->lock);
    800051f2:	8526                	mv	a0,s1
    800051f4:	ffffc097          	auipc	ra,0xffffc
    800051f8:	c2c080e7          	jalr	-980(ra) # 80000e20 <release>
      return -1;
    800051fc:	59fd                	li	s3,-1
    800051fe:	bff9                	j	800051dc <piperead+0xca>

0000000080005200 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005200:	1141                	addi	sp,sp,-16
    80005202:	e422                	sd	s0,8(sp)
    80005204:	0800                	addi	s0,sp,16
    80005206:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005208:	8905                	andi	a0,a0,1
    8000520a:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000520c:	8b89                	andi	a5,a5,2
    8000520e:	c399                	beqz	a5,80005214 <flags2perm+0x14>
      perm |= PTE_W;
    80005210:	00456513          	ori	a0,a0,4
    return perm;
}
    80005214:	6422                	ld	s0,8(sp)
    80005216:	0141                	addi	sp,sp,16
    80005218:	8082                	ret

000000008000521a <exec>:

int
exec(char *path, char **argv)
{
    8000521a:	de010113          	addi	sp,sp,-544
    8000521e:	20113c23          	sd	ra,536(sp)
    80005222:	20813823          	sd	s0,528(sp)
    80005226:	20913423          	sd	s1,520(sp)
    8000522a:	21213023          	sd	s2,512(sp)
    8000522e:	ffce                	sd	s3,504(sp)
    80005230:	fbd2                	sd	s4,496(sp)
    80005232:	f7d6                	sd	s5,488(sp)
    80005234:	f3da                	sd	s6,480(sp)
    80005236:	efde                	sd	s7,472(sp)
    80005238:	ebe2                	sd	s8,464(sp)
    8000523a:	e7e6                	sd	s9,456(sp)
    8000523c:	e3ea                	sd	s10,448(sp)
    8000523e:	ff6e                	sd	s11,440(sp)
    80005240:	1400                	addi	s0,sp,544
    80005242:	892a                	mv	s2,a0
    80005244:	dea43423          	sd	a0,-536(s0)
    80005248:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000524c:	ffffd097          	auipc	ra,0xffffd
    80005250:	a0e080e7          	jalr	-1522(ra) # 80001c5a <myproc>
    80005254:	84aa                	mv	s1,a0

  begin_op();
    80005256:	fffff097          	auipc	ra,0xfffff
    8000525a:	482080e7          	jalr	1154(ra) # 800046d8 <begin_op>

  if((ip = namei(path)) == 0){
    8000525e:	854a                	mv	a0,s2
    80005260:	fffff097          	auipc	ra,0xfffff
    80005264:	258080e7          	jalr	600(ra) # 800044b8 <namei>
    80005268:	c93d                	beqz	a0,800052de <exec+0xc4>
    8000526a:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000526c:	fffff097          	auipc	ra,0xfffff
    80005270:	aa0080e7          	jalr	-1376(ra) # 80003d0c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005274:	04000713          	li	a4,64
    80005278:	4681                	li	a3,0
    8000527a:	e5040613          	addi	a2,s0,-432
    8000527e:	4581                	li	a1,0
    80005280:	8556                	mv	a0,s5
    80005282:	fffff097          	auipc	ra,0xfffff
    80005286:	d3e080e7          	jalr	-706(ra) # 80003fc0 <readi>
    8000528a:	04000793          	li	a5,64
    8000528e:	00f51a63          	bne	a0,a5,800052a2 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005292:	e5042703          	lw	a4,-432(s0)
    80005296:	464c47b7          	lui	a5,0x464c4
    8000529a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000529e:	04f70663          	beq	a4,a5,800052ea <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800052a2:	8556                	mv	a0,s5
    800052a4:	fffff097          	auipc	ra,0xfffff
    800052a8:	cca080e7          	jalr	-822(ra) # 80003f6e <iunlockput>
    end_op();
    800052ac:	fffff097          	auipc	ra,0xfffff
    800052b0:	4aa080e7          	jalr	1194(ra) # 80004756 <end_op>
  }
  return -1;
    800052b4:	557d                	li	a0,-1
}
    800052b6:	21813083          	ld	ra,536(sp)
    800052ba:	21013403          	ld	s0,528(sp)
    800052be:	20813483          	ld	s1,520(sp)
    800052c2:	20013903          	ld	s2,512(sp)
    800052c6:	79fe                	ld	s3,504(sp)
    800052c8:	7a5e                	ld	s4,496(sp)
    800052ca:	7abe                	ld	s5,488(sp)
    800052cc:	7b1e                	ld	s6,480(sp)
    800052ce:	6bfe                	ld	s7,472(sp)
    800052d0:	6c5e                	ld	s8,464(sp)
    800052d2:	6cbe                	ld	s9,456(sp)
    800052d4:	6d1e                	ld	s10,448(sp)
    800052d6:	7dfa                	ld	s11,440(sp)
    800052d8:	22010113          	addi	sp,sp,544
    800052dc:	8082                	ret
    end_op();
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	478080e7          	jalr	1144(ra) # 80004756 <end_op>
    return -1;
    800052e6:	557d                	li	a0,-1
    800052e8:	b7f9                	j	800052b6 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800052ea:	8526                	mv	a0,s1
    800052ec:	ffffd097          	auipc	ra,0xffffd
    800052f0:	a32080e7          	jalr	-1486(ra) # 80001d1e <proc_pagetable>
    800052f4:	8b2a                	mv	s6,a0
    800052f6:	d555                	beqz	a0,800052a2 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052f8:	e7042783          	lw	a5,-400(s0)
    800052fc:	e8845703          	lhu	a4,-376(s0)
    80005300:	c735                	beqz	a4,8000536c <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005302:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005304:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005308:	6a05                	lui	s4,0x1
    8000530a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000530e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005312:	6d85                	lui	s11,0x1
    80005314:	7d7d                	lui	s10,0xfffff
    80005316:	ac3d                	j	80005554 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005318:	00003517          	auipc	a0,0x3
    8000531c:	56850513          	addi	a0,a0,1384 # 80008880 <syscalls+0x2a8>
    80005320:	ffffb097          	auipc	ra,0xffffb
    80005324:	220080e7          	jalr	544(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005328:	874a                	mv	a4,s2
    8000532a:	009c86bb          	addw	a3,s9,s1
    8000532e:	4581                	li	a1,0
    80005330:	8556                	mv	a0,s5
    80005332:	fffff097          	auipc	ra,0xfffff
    80005336:	c8e080e7          	jalr	-882(ra) # 80003fc0 <readi>
    8000533a:	2501                	sext.w	a0,a0
    8000533c:	1aa91963          	bne	s2,a0,800054ee <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005340:	009d84bb          	addw	s1,s11,s1
    80005344:	013d09bb          	addw	s3,s10,s3
    80005348:	1f74f663          	bgeu	s1,s7,80005534 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    8000534c:	02049593          	slli	a1,s1,0x20
    80005350:	9181                	srli	a1,a1,0x20
    80005352:	95e2                	add	a1,a1,s8
    80005354:	855a                	mv	a0,s6
    80005356:	ffffc097          	auipc	ra,0xffffc
    8000535a:	e9c080e7          	jalr	-356(ra) # 800011f2 <walkaddr>
    8000535e:	862a                	mv	a2,a0
    if(pa == 0)
    80005360:	dd45                	beqz	a0,80005318 <exec+0xfe>
      n = PGSIZE;
    80005362:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005364:	fd49f2e3          	bgeu	s3,s4,80005328 <exec+0x10e>
      n = sz - i;
    80005368:	894e                	mv	s2,s3
    8000536a:	bf7d                	j	80005328 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000536c:	4901                	li	s2,0
  iunlockput(ip);
    8000536e:	8556                	mv	a0,s5
    80005370:	fffff097          	auipc	ra,0xfffff
    80005374:	bfe080e7          	jalr	-1026(ra) # 80003f6e <iunlockput>
  end_op();
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	3de080e7          	jalr	990(ra) # 80004756 <end_op>
  p = myproc();
    80005380:	ffffd097          	auipc	ra,0xffffd
    80005384:	8da080e7          	jalr	-1830(ra) # 80001c5a <myproc>
    80005388:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000538a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000538e:	6785                	lui	a5,0x1
    80005390:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005392:	97ca                	add	a5,a5,s2
    80005394:	777d                	lui	a4,0xfffff
    80005396:	8ff9                	and	a5,a5,a4
    80005398:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000539c:	4691                	li	a3,4
    8000539e:	6609                	lui	a2,0x2
    800053a0:	963e                	add	a2,a2,a5
    800053a2:	85be                	mv	a1,a5
    800053a4:	855a                	mv	a0,s6
    800053a6:	ffffc097          	auipc	ra,0xffffc
    800053aa:	200080e7          	jalr	512(ra) # 800015a6 <uvmalloc>
    800053ae:	8c2a                	mv	s8,a0
  ip = 0;
    800053b0:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800053b2:	12050e63          	beqz	a0,800054ee <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    800053b6:	75f9                	lui	a1,0xffffe
    800053b8:	95aa                	add	a1,a1,a0
    800053ba:	855a                	mv	a0,s6
    800053bc:	ffffc097          	auipc	ra,0xffffc
    800053c0:	42e080e7          	jalr	1070(ra) # 800017ea <uvmclear>
  stackbase = sp - PGSIZE;
    800053c4:	7afd                	lui	s5,0xfffff
    800053c6:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800053c8:	df043783          	ld	a5,-528(s0)
    800053cc:	6388                	ld	a0,0(a5)
    800053ce:	c925                	beqz	a0,8000543e <exec+0x224>
    800053d0:	e9040993          	addi	s3,s0,-368
    800053d4:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800053d8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800053da:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053dc:	ffffc097          	auipc	ra,0xffffc
    800053e0:	c08080e7          	jalr	-1016(ra) # 80000fe4 <strlen>
    800053e4:	0015079b          	addiw	a5,a0,1
    800053e8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053ec:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800053f0:	13596663          	bltu	s2,s5,8000551c <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053f4:	df043d83          	ld	s11,-528(s0)
    800053f8:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800053fc:	8552                	mv	a0,s4
    800053fe:	ffffc097          	auipc	ra,0xffffc
    80005402:	be6080e7          	jalr	-1050(ra) # 80000fe4 <strlen>
    80005406:	0015069b          	addiw	a3,a0,1
    8000540a:	8652                	mv	a2,s4
    8000540c:	85ca                	mv	a1,s2
    8000540e:	855a                	mv	a0,s6
    80005410:	ffffc097          	auipc	ra,0xffffc
    80005414:	40c080e7          	jalr	1036(ra) # 8000181c <copyout>
    80005418:	10054663          	bltz	a0,80005524 <exec+0x30a>
    ustack[argc] = sp;
    8000541c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005420:	0485                	addi	s1,s1,1
    80005422:	008d8793          	addi	a5,s11,8
    80005426:	def43823          	sd	a5,-528(s0)
    8000542a:	008db503          	ld	a0,8(s11)
    8000542e:	c911                	beqz	a0,80005442 <exec+0x228>
    if(argc >= MAXARG)
    80005430:	09a1                	addi	s3,s3,8
    80005432:	fb3c95e3          	bne	s9,s3,800053dc <exec+0x1c2>
  sz = sz1;
    80005436:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000543a:	4a81                	li	s5,0
    8000543c:	a84d                	j	800054ee <exec+0x2d4>
  sp = sz;
    8000543e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005440:	4481                	li	s1,0
  ustack[argc] = 0;
    80005442:	00349793          	slli	a5,s1,0x3
    80005446:	f9078793          	addi	a5,a5,-112
    8000544a:	97a2                	add	a5,a5,s0
    8000544c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005450:	00148693          	addi	a3,s1,1
    80005454:	068e                	slli	a3,a3,0x3
    80005456:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000545a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000545e:	01597663          	bgeu	s2,s5,8000546a <exec+0x250>
  sz = sz1;
    80005462:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005466:	4a81                	li	s5,0
    80005468:	a059                	j	800054ee <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000546a:	e9040613          	addi	a2,s0,-368
    8000546e:	85ca                	mv	a1,s2
    80005470:	855a                	mv	a0,s6
    80005472:	ffffc097          	auipc	ra,0xffffc
    80005476:	3aa080e7          	jalr	938(ra) # 8000181c <copyout>
    8000547a:	0a054963          	bltz	a0,8000552c <exec+0x312>
  p->trapframe->a1 = sp;
    8000547e:	058bb783          	ld	a5,88(s7)
    80005482:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005486:	de843783          	ld	a5,-536(s0)
    8000548a:	0007c703          	lbu	a4,0(a5)
    8000548e:	cf11                	beqz	a4,800054aa <exec+0x290>
    80005490:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005492:	02f00693          	li	a3,47
    80005496:	a039                	j	800054a4 <exec+0x28a>
      last = s+1;
    80005498:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000549c:	0785                	addi	a5,a5,1
    8000549e:	fff7c703          	lbu	a4,-1(a5)
    800054a2:	c701                	beqz	a4,800054aa <exec+0x290>
    if(*s == '/')
    800054a4:	fed71ce3          	bne	a4,a3,8000549c <exec+0x282>
    800054a8:	bfc5                	j	80005498 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800054aa:	4641                	li	a2,16
    800054ac:	de843583          	ld	a1,-536(s0)
    800054b0:	158b8513          	addi	a0,s7,344
    800054b4:	ffffc097          	auipc	ra,0xffffc
    800054b8:	afe080e7          	jalr	-1282(ra) # 80000fb2 <safestrcpy>
  oldpagetable = p->pagetable;
    800054bc:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800054c0:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800054c4:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800054c8:	058bb783          	ld	a5,88(s7)
    800054cc:	e6843703          	ld	a4,-408(s0)
    800054d0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800054d2:	058bb783          	ld	a5,88(s7)
    800054d6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800054da:	85ea                	mv	a1,s10
    800054dc:	ffffd097          	auipc	ra,0xffffd
    800054e0:	8de080e7          	jalr	-1826(ra) # 80001dba <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054e4:	0004851b          	sext.w	a0,s1
    800054e8:	b3f9                	j	800052b6 <exec+0x9c>
    800054ea:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800054ee:	df843583          	ld	a1,-520(s0)
    800054f2:	855a                	mv	a0,s6
    800054f4:	ffffd097          	auipc	ra,0xffffd
    800054f8:	8c6080e7          	jalr	-1850(ra) # 80001dba <proc_freepagetable>
  if(ip){
    800054fc:	da0a93e3          	bnez	s5,800052a2 <exec+0x88>
  return -1;
    80005500:	557d                	li	a0,-1
    80005502:	bb55                	j	800052b6 <exec+0x9c>
    80005504:	df243c23          	sd	s2,-520(s0)
    80005508:	b7dd                	j	800054ee <exec+0x2d4>
    8000550a:	df243c23          	sd	s2,-520(s0)
    8000550e:	b7c5                	j	800054ee <exec+0x2d4>
    80005510:	df243c23          	sd	s2,-520(s0)
    80005514:	bfe9                	j	800054ee <exec+0x2d4>
    80005516:	df243c23          	sd	s2,-520(s0)
    8000551a:	bfd1                	j	800054ee <exec+0x2d4>
  sz = sz1;
    8000551c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005520:	4a81                	li	s5,0
    80005522:	b7f1                	j	800054ee <exec+0x2d4>
  sz = sz1;
    80005524:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005528:	4a81                	li	s5,0
    8000552a:	b7d1                	j	800054ee <exec+0x2d4>
  sz = sz1;
    8000552c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005530:	4a81                	li	s5,0
    80005532:	bf75                	j	800054ee <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005534:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005538:	e0843783          	ld	a5,-504(s0)
    8000553c:	0017869b          	addiw	a3,a5,1
    80005540:	e0d43423          	sd	a3,-504(s0)
    80005544:	e0043783          	ld	a5,-512(s0)
    80005548:	0387879b          	addiw	a5,a5,56
    8000554c:	e8845703          	lhu	a4,-376(s0)
    80005550:	e0e6dfe3          	bge	a3,a4,8000536e <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005554:	2781                	sext.w	a5,a5
    80005556:	e0f43023          	sd	a5,-512(s0)
    8000555a:	03800713          	li	a4,56
    8000555e:	86be                	mv	a3,a5
    80005560:	e1840613          	addi	a2,s0,-488
    80005564:	4581                	li	a1,0
    80005566:	8556                	mv	a0,s5
    80005568:	fffff097          	auipc	ra,0xfffff
    8000556c:	a58080e7          	jalr	-1448(ra) # 80003fc0 <readi>
    80005570:	03800793          	li	a5,56
    80005574:	f6f51be3          	bne	a0,a5,800054ea <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80005578:	e1842783          	lw	a5,-488(s0)
    8000557c:	4705                	li	a4,1
    8000557e:	fae79de3          	bne	a5,a4,80005538 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005582:	e4043483          	ld	s1,-448(s0)
    80005586:	e3843783          	ld	a5,-456(s0)
    8000558a:	f6f4ede3          	bltu	s1,a5,80005504 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000558e:	e2843783          	ld	a5,-472(s0)
    80005592:	94be                	add	s1,s1,a5
    80005594:	f6f4ebe3          	bltu	s1,a5,8000550a <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80005598:	de043703          	ld	a4,-544(s0)
    8000559c:	8ff9                	and	a5,a5,a4
    8000559e:	fbad                	bnez	a5,80005510 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055a0:	e1c42503          	lw	a0,-484(s0)
    800055a4:	00000097          	auipc	ra,0x0
    800055a8:	c5c080e7          	jalr	-932(ra) # 80005200 <flags2perm>
    800055ac:	86aa                	mv	a3,a0
    800055ae:	8626                	mv	a2,s1
    800055b0:	85ca                	mv	a1,s2
    800055b2:	855a                	mv	a0,s6
    800055b4:	ffffc097          	auipc	ra,0xffffc
    800055b8:	ff2080e7          	jalr	-14(ra) # 800015a6 <uvmalloc>
    800055bc:	dea43c23          	sd	a0,-520(s0)
    800055c0:	d939                	beqz	a0,80005516 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800055c2:	e2843c03          	ld	s8,-472(s0)
    800055c6:	e2042c83          	lw	s9,-480(s0)
    800055ca:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800055ce:	f60b83e3          	beqz	s7,80005534 <exec+0x31a>
    800055d2:	89de                	mv	s3,s7
    800055d4:	4481                	li	s1,0
    800055d6:	bb9d                	j	8000534c <exec+0x132>

00000000800055d8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055d8:	7179                	addi	sp,sp,-48
    800055da:	f406                	sd	ra,40(sp)
    800055dc:	f022                	sd	s0,32(sp)
    800055de:	ec26                	sd	s1,24(sp)
    800055e0:	e84a                	sd	s2,16(sp)
    800055e2:	1800                	addi	s0,sp,48
    800055e4:	892e                	mv	s2,a1
    800055e6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800055e8:	fdc40593          	addi	a1,s0,-36
    800055ec:	ffffe097          	auipc	ra,0xffffe
    800055f0:	a76080e7          	jalr	-1418(ra) # 80003062 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055f4:	fdc42703          	lw	a4,-36(s0)
    800055f8:	47bd                	li	a5,15
    800055fa:	02e7eb63          	bltu	a5,a4,80005630 <argfd+0x58>
    800055fe:	ffffc097          	auipc	ra,0xffffc
    80005602:	65c080e7          	jalr	1628(ra) # 80001c5a <myproc>
    80005606:	fdc42703          	lw	a4,-36(s0)
    8000560a:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ff9d0ca>
    8000560e:	078e                	slli	a5,a5,0x3
    80005610:	953e                	add	a0,a0,a5
    80005612:	611c                	ld	a5,0(a0)
    80005614:	c385                	beqz	a5,80005634 <argfd+0x5c>
    return -1;
  if(pfd)
    80005616:	00090463          	beqz	s2,8000561e <argfd+0x46>
    *pfd = fd;
    8000561a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000561e:	4501                	li	a0,0
  if(pf)
    80005620:	c091                	beqz	s1,80005624 <argfd+0x4c>
    *pf = f;
    80005622:	e09c                	sd	a5,0(s1)
}
    80005624:	70a2                	ld	ra,40(sp)
    80005626:	7402                	ld	s0,32(sp)
    80005628:	64e2                	ld	s1,24(sp)
    8000562a:	6942                	ld	s2,16(sp)
    8000562c:	6145                	addi	sp,sp,48
    8000562e:	8082                	ret
    return -1;
    80005630:	557d                	li	a0,-1
    80005632:	bfcd                	j	80005624 <argfd+0x4c>
    80005634:	557d                	li	a0,-1
    80005636:	b7fd                	j	80005624 <argfd+0x4c>

0000000080005638 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005638:	1101                	addi	sp,sp,-32
    8000563a:	ec06                	sd	ra,24(sp)
    8000563c:	e822                	sd	s0,16(sp)
    8000563e:	e426                	sd	s1,8(sp)
    80005640:	1000                	addi	s0,sp,32
    80005642:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005644:	ffffc097          	auipc	ra,0xffffc
    80005648:	616080e7          	jalr	1558(ra) # 80001c5a <myproc>
    8000564c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000564e:	0d050793          	addi	a5,a0,208
    80005652:	4501                	li	a0,0
    80005654:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005656:	6398                	ld	a4,0(a5)
    80005658:	cb19                	beqz	a4,8000566e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000565a:	2505                	addiw	a0,a0,1
    8000565c:	07a1                	addi	a5,a5,8
    8000565e:	fed51ce3          	bne	a0,a3,80005656 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005662:	557d                	li	a0,-1
}
    80005664:	60e2                	ld	ra,24(sp)
    80005666:	6442                	ld	s0,16(sp)
    80005668:	64a2                	ld	s1,8(sp)
    8000566a:	6105                	addi	sp,sp,32
    8000566c:	8082                	ret
      p->ofile[fd] = f;
    8000566e:	01a50793          	addi	a5,a0,26
    80005672:	078e                	slli	a5,a5,0x3
    80005674:	963e                	add	a2,a2,a5
    80005676:	e204                	sd	s1,0(a2)
      return fd;
    80005678:	b7f5                	j	80005664 <fdalloc+0x2c>

000000008000567a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000567a:	715d                	addi	sp,sp,-80
    8000567c:	e486                	sd	ra,72(sp)
    8000567e:	e0a2                	sd	s0,64(sp)
    80005680:	fc26                	sd	s1,56(sp)
    80005682:	f84a                	sd	s2,48(sp)
    80005684:	f44e                	sd	s3,40(sp)
    80005686:	f052                	sd	s4,32(sp)
    80005688:	ec56                	sd	s5,24(sp)
    8000568a:	e85a                	sd	s6,16(sp)
    8000568c:	0880                	addi	s0,sp,80
    8000568e:	8b2e                	mv	s6,a1
    80005690:	89b2                	mv	s3,a2
    80005692:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005694:	fb040593          	addi	a1,s0,-80
    80005698:	fffff097          	auipc	ra,0xfffff
    8000569c:	e3e080e7          	jalr	-450(ra) # 800044d6 <nameiparent>
    800056a0:	84aa                	mv	s1,a0
    800056a2:	14050f63          	beqz	a0,80005800 <create+0x186>
    return 0;

  ilock(dp);
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	666080e7          	jalr	1638(ra) # 80003d0c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056ae:	4601                	li	a2,0
    800056b0:	fb040593          	addi	a1,s0,-80
    800056b4:	8526                	mv	a0,s1
    800056b6:	fffff097          	auipc	ra,0xfffff
    800056ba:	b3a080e7          	jalr	-1222(ra) # 800041f0 <dirlookup>
    800056be:	8aaa                	mv	s5,a0
    800056c0:	c931                	beqz	a0,80005714 <create+0x9a>
    iunlockput(dp);
    800056c2:	8526                	mv	a0,s1
    800056c4:	fffff097          	auipc	ra,0xfffff
    800056c8:	8aa080e7          	jalr	-1878(ra) # 80003f6e <iunlockput>
    ilock(ip);
    800056cc:	8556                	mv	a0,s5
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	63e080e7          	jalr	1598(ra) # 80003d0c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056d6:	000b059b          	sext.w	a1,s6
    800056da:	4789                	li	a5,2
    800056dc:	02f59563          	bne	a1,a5,80005706 <create+0x8c>
    800056e0:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ff9d0f4>
    800056e4:	37f9                	addiw	a5,a5,-2
    800056e6:	17c2                	slli	a5,a5,0x30
    800056e8:	93c1                	srli	a5,a5,0x30
    800056ea:	4705                	li	a4,1
    800056ec:	00f76d63          	bltu	a4,a5,80005706 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800056f0:	8556                	mv	a0,s5
    800056f2:	60a6                	ld	ra,72(sp)
    800056f4:	6406                	ld	s0,64(sp)
    800056f6:	74e2                	ld	s1,56(sp)
    800056f8:	7942                	ld	s2,48(sp)
    800056fa:	79a2                	ld	s3,40(sp)
    800056fc:	7a02                	ld	s4,32(sp)
    800056fe:	6ae2                	ld	s5,24(sp)
    80005700:	6b42                	ld	s6,16(sp)
    80005702:	6161                	addi	sp,sp,80
    80005704:	8082                	ret
    iunlockput(ip);
    80005706:	8556                	mv	a0,s5
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	866080e7          	jalr	-1946(ra) # 80003f6e <iunlockput>
    return 0;
    80005710:	4a81                	li	s5,0
    80005712:	bff9                	j	800056f0 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005714:	85da                	mv	a1,s6
    80005716:	4088                	lw	a0,0(s1)
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	456080e7          	jalr	1110(ra) # 80003b6e <ialloc>
    80005720:	8a2a                	mv	s4,a0
    80005722:	c539                	beqz	a0,80005770 <create+0xf6>
  ilock(ip);
    80005724:	ffffe097          	auipc	ra,0xffffe
    80005728:	5e8080e7          	jalr	1512(ra) # 80003d0c <ilock>
  ip->major = major;
    8000572c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005730:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005734:	4905                	li	s2,1
    80005736:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000573a:	8552                	mv	a0,s4
    8000573c:	ffffe097          	auipc	ra,0xffffe
    80005740:	504080e7          	jalr	1284(ra) # 80003c40 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005744:	000b059b          	sext.w	a1,s6
    80005748:	03258b63          	beq	a1,s2,8000577e <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000574c:	004a2603          	lw	a2,4(s4)
    80005750:	fb040593          	addi	a1,s0,-80
    80005754:	8526                	mv	a0,s1
    80005756:	fffff097          	auipc	ra,0xfffff
    8000575a:	cb0080e7          	jalr	-848(ra) # 80004406 <dirlink>
    8000575e:	06054f63          	bltz	a0,800057dc <create+0x162>
  iunlockput(dp);
    80005762:	8526                	mv	a0,s1
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	80a080e7          	jalr	-2038(ra) # 80003f6e <iunlockput>
  return ip;
    8000576c:	8ad2                	mv	s5,s4
    8000576e:	b749                	j	800056f0 <create+0x76>
    iunlockput(dp);
    80005770:	8526                	mv	a0,s1
    80005772:	ffffe097          	auipc	ra,0xffffe
    80005776:	7fc080e7          	jalr	2044(ra) # 80003f6e <iunlockput>
    return 0;
    8000577a:	8ad2                	mv	s5,s4
    8000577c:	bf95                	j	800056f0 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000577e:	004a2603          	lw	a2,4(s4)
    80005782:	00003597          	auipc	a1,0x3
    80005786:	11e58593          	addi	a1,a1,286 # 800088a0 <syscalls+0x2c8>
    8000578a:	8552                	mv	a0,s4
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	c7a080e7          	jalr	-902(ra) # 80004406 <dirlink>
    80005794:	04054463          	bltz	a0,800057dc <create+0x162>
    80005798:	40d0                	lw	a2,4(s1)
    8000579a:	00003597          	auipc	a1,0x3
    8000579e:	10e58593          	addi	a1,a1,270 # 800088a8 <syscalls+0x2d0>
    800057a2:	8552                	mv	a0,s4
    800057a4:	fffff097          	auipc	ra,0xfffff
    800057a8:	c62080e7          	jalr	-926(ra) # 80004406 <dirlink>
    800057ac:	02054863          	bltz	a0,800057dc <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800057b0:	004a2603          	lw	a2,4(s4)
    800057b4:	fb040593          	addi	a1,s0,-80
    800057b8:	8526                	mv	a0,s1
    800057ba:	fffff097          	auipc	ra,0xfffff
    800057be:	c4c080e7          	jalr	-948(ra) # 80004406 <dirlink>
    800057c2:	00054d63          	bltz	a0,800057dc <create+0x162>
    dp->nlink++;  // for ".."
    800057c6:	04a4d783          	lhu	a5,74(s1)
    800057ca:	2785                	addiw	a5,a5,1
    800057cc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057d0:	8526                	mv	a0,s1
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	46e080e7          	jalr	1134(ra) # 80003c40 <iupdate>
    800057da:	b761                	j	80005762 <create+0xe8>
  ip->nlink = 0;
    800057dc:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800057e0:	8552                	mv	a0,s4
    800057e2:	ffffe097          	auipc	ra,0xffffe
    800057e6:	45e080e7          	jalr	1118(ra) # 80003c40 <iupdate>
  iunlockput(ip);
    800057ea:	8552                	mv	a0,s4
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	782080e7          	jalr	1922(ra) # 80003f6e <iunlockput>
  iunlockput(dp);
    800057f4:	8526                	mv	a0,s1
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	778080e7          	jalr	1912(ra) # 80003f6e <iunlockput>
  return 0;
    800057fe:	bdcd                	j	800056f0 <create+0x76>
    return 0;
    80005800:	8aaa                	mv	s5,a0
    80005802:	b5fd                	j	800056f0 <create+0x76>

0000000080005804 <sys_dup>:
{
    80005804:	7179                	addi	sp,sp,-48
    80005806:	f406                	sd	ra,40(sp)
    80005808:	f022                	sd	s0,32(sp)
    8000580a:	ec26                	sd	s1,24(sp)
    8000580c:	e84a                	sd	s2,16(sp)
    8000580e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005810:	fd840613          	addi	a2,s0,-40
    80005814:	4581                	li	a1,0
    80005816:	4501                	li	a0,0
    80005818:	00000097          	auipc	ra,0x0
    8000581c:	dc0080e7          	jalr	-576(ra) # 800055d8 <argfd>
    return -1;
    80005820:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005822:	02054363          	bltz	a0,80005848 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005826:	fd843903          	ld	s2,-40(s0)
    8000582a:	854a                	mv	a0,s2
    8000582c:	00000097          	auipc	ra,0x0
    80005830:	e0c080e7          	jalr	-500(ra) # 80005638 <fdalloc>
    80005834:	84aa                	mv	s1,a0
    return -1;
    80005836:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005838:	00054863          	bltz	a0,80005848 <sys_dup+0x44>
  filedup(f);
    8000583c:	854a                	mv	a0,s2
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	310080e7          	jalr	784(ra) # 80004b4e <filedup>
  return fd;
    80005846:	87a6                	mv	a5,s1
}
    80005848:	853e                	mv	a0,a5
    8000584a:	70a2                	ld	ra,40(sp)
    8000584c:	7402                	ld	s0,32(sp)
    8000584e:	64e2                	ld	s1,24(sp)
    80005850:	6942                	ld	s2,16(sp)
    80005852:	6145                	addi	sp,sp,48
    80005854:	8082                	ret

0000000080005856 <sys_read>:
{
    80005856:	7179                	addi	sp,sp,-48
    80005858:	f406                	sd	ra,40(sp)
    8000585a:	f022                	sd	s0,32(sp)
    8000585c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000585e:	fd840593          	addi	a1,s0,-40
    80005862:	4505                	li	a0,1
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	81e080e7          	jalr	-2018(ra) # 80003082 <argaddr>
  argint(2, &n);
    8000586c:	fe440593          	addi	a1,s0,-28
    80005870:	4509                	li	a0,2
    80005872:	ffffd097          	auipc	ra,0xffffd
    80005876:	7f0080e7          	jalr	2032(ra) # 80003062 <argint>
  if(argfd(0, 0, &f) < 0)
    8000587a:	fe840613          	addi	a2,s0,-24
    8000587e:	4581                	li	a1,0
    80005880:	4501                	li	a0,0
    80005882:	00000097          	auipc	ra,0x0
    80005886:	d56080e7          	jalr	-682(ra) # 800055d8 <argfd>
    8000588a:	87aa                	mv	a5,a0
    return -1;
    8000588c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000588e:	0007cc63          	bltz	a5,800058a6 <sys_read+0x50>
  return fileread(f, p, n);
    80005892:	fe442603          	lw	a2,-28(s0)
    80005896:	fd843583          	ld	a1,-40(s0)
    8000589a:	fe843503          	ld	a0,-24(s0)
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	43c080e7          	jalr	1084(ra) # 80004cda <fileread>
}
    800058a6:	70a2                	ld	ra,40(sp)
    800058a8:	7402                	ld	s0,32(sp)
    800058aa:	6145                	addi	sp,sp,48
    800058ac:	8082                	ret

00000000800058ae <sys_write>:
{
    800058ae:	7179                	addi	sp,sp,-48
    800058b0:	f406                	sd	ra,40(sp)
    800058b2:	f022                	sd	s0,32(sp)
    800058b4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800058b6:	fd840593          	addi	a1,s0,-40
    800058ba:	4505                	li	a0,1
    800058bc:	ffffd097          	auipc	ra,0xffffd
    800058c0:	7c6080e7          	jalr	1990(ra) # 80003082 <argaddr>
  argint(2, &n);
    800058c4:	fe440593          	addi	a1,s0,-28
    800058c8:	4509                	li	a0,2
    800058ca:	ffffd097          	auipc	ra,0xffffd
    800058ce:	798080e7          	jalr	1944(ra) # 80003062 <argint>
  if(argfd(0, 0, &f) < 0)
    800058d2:	fe840613          	addi	a2,s0,-24
    800058d6:	4581                	li	a1,0
    800058d8:	4501                	li	a0,0
    800058da:	00000097          	auipc	ra,0x0
    800058de:	cfe080e7          	jalr	-770(ra) # 800055d8 <argfd>
    800058e2:	87aa                	mv	a5,a0
    return -1;
    800058e4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058e6:	0007cc63          	bltz	a5,800058fe <sys_write+0x50>
  return filewrite(f, p, n);
    800058ea:	fe442603          	lw	a2,-28(s0)
    800058ee:	fd843583          	ld	a1,-40(s0)
    800058f2:	fe843503          	ld	a0,-24(s0)
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	4a6080e7          	jalr	1190(ra) # 80004d9c <filewrite>
}
    800058fe:	70a2                	ld	ra,40(sp)
    80005900:	7402                	ld	s0,32(sp)
    80005902:	6145                	addi	sp,sp,48
    80005904:	8082                	ret

0000000080005906 <sys_close>:
{
    80005906:	1101                	addi	sp,sp,-32
    80005908:	ec06                	sd	ra,24(sp)
    8000590a:	e822                	sd	s0,16(sp)
    8000590c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000590e:	fe040613          	addi	a2,s0,-32
    80005912:	fec40593          	addi	a1,s0,-20
    80005916:	4501                	li	a0,0
    80005918:	00000097          	auipc	ra,0x0
    8000591c:	cc0080e7          	jalr	-832(ra) # 800055d8 <argfd>
    return -1;
    80005920:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005922:	02054463          	bltz	a0,8000594a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005926:	ffffc097          	auipc	ra,0xffffc
    8000592a:	334080e7          	jalr	820(ra) # 80001c5a <myproc>
    8000592e:	fec42783          	lw	a5,-20(s0)
    80005932:	07e9                	addi	a5,a5,26
    80005934:	078e                	slli	a5,a5,0x3
    80005936:	953e                	add	a0,a0,a5
    80005938:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000593c:	fe043503          	ld	a0,-32(s0)
    80005940:	fffff097          	auipc	ra,0xfffff
    80005944:	260080e7          	jalr	608(ra) # 80004ba0 <fileclose>
  return 0;
    80005948:	4781                	li	a5,0
}
    8000594a:	853e                	mv	a0,a5
    8000594c:	60e2                	ld	ra,24(sp)
    8000594e:	6442                	ld	s0,16(sp)
    80005950:	6105                	addi	sp,sp,32
    80005952:	8082                	ret

0000000080005954 <sys_fstat>:
{
    80005954:	1101                	addi	sp,sp,-32
    80005956:	ec06                	sd	ra,24(sp)
    80005958:	e822                	sd	s0,16(sp)
    8000595a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000595c:	fe040593          	addi	a1,s0,-32
    80005960:	4505                	li	a0,1
    80005962:	ffffd097          	auipc	ra,0xffffd
    80005966:	720080e7          	jalr	1824(ra) # 80003082 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000596a:	fe840613          	addi	a2,s0,-24
    8000596e:	4581                	li	a1,0
    80005970:	4501                	li	a0,0
    80005972:	00000097          	auipc	ra,0x0
    80005976:	c66080e7          	jalr	-922(ra) # 800055d8 <argfd>
    8000597a:	87aa                	mv	a5,a0
    return -1;
    8000597c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000597e:	0007ca63          	bltz	a5,80005992 <sys_fstat+0x3e>
  return filestat(f, st);
    80005982:	fe043583          	ld	a1,-32(s0)
    80005986:	fe843503          	ld	a0,-24(s0)
    8000598a:	fffff097          	auipc	ra,0xfffff
    8000598e:	2de080e7          	jalr	734(ra) # 80004c68 <filestat>
}
    80005992:	60e2                	ld	ra,24(sp)
    80005994:	6442                	ld	s0,16(sp)
    80005996:	6105                	addi	sp,sp,32
    80005998:	8082                	ret

000000008000599a <sys_link>:
{
    8000599a:	7169                	addi	sp,sp,-304
    8000599c:	f606                	sd	ra,296(sp)
    8000599e:	f222                	sd	s0,288(sp)
    800059a0:	ee26                	sd	s1,280(sp)
    800059a2:	ea4a                	sd	s2,272(sp)
    800059a4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059a6:	08000613          	li	a2,128
    800059aa:	ed040593          	addi	a1,s0,-304
    800059ae:	4501                	li	a0,0
    800059b0:	ffffd097          	auipc	ra,0xffffd
    800059b4:	6f2080e7          	jalr	1778(ra) # 800030a2 <argstr>
    return -1;
    800059b8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059ba:	10054e63          	bltz	a0,80005ad6 <sys_link+0x13c>
    800059be:	08000613          	li	a2,128
    800059c2:	f5040593          	addi	a1,s0,-176
    800059c6:	4505                	li	a0,1
    800059c8:	ffffd097          	auipc	ra,0xffffd
    800059cc:	6da080e7          	jalr	1754(ra) # 800030a2 <argstr>
    return -1;
    800059d0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059d2:	10054263          	bltz	a0,80005ad6 <sys_link+0x13c>
  begin_op();
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	d02080e7          	jalr	-766(ra) # 800046d8 <begin_op>
  if((ip = namei(old)) == 0){
    800059de:	ed040513          	addi	a0,s0,-304
    800059e2:	fffff097          	auipc	ra,0xfffff
    800059e6:	ad6080e7          	jalr	-1322(ra) # 800044b8 <namei>
    800059ea:	84aa                	mv	s1,a0
    800059ec:	c551                	beqz	a0,80005a78 <sys_link+0xde>
  ilock(ip);
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	31e080e7          	jalr	798(ra) # 80003d0c <ilock>
  if(ip->type == T_DIR){
    800059f6:	04449703          	lh	a4,68(s1)
    800059fa:	4785                	li	a5,1
    800059fc:	08f70463          	beq	a4,a5,80005a84 <sys_link+0xea>
  ip->nlink++;
    80005a00:	04a4d783          	lhu	a5,74(s1)
    80005a04:	2785                	addiw	a5,a5,1
    80005a06:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a0a:	8526                	mv	a0,s1
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	234080e7          	jalr	564(ra) # 80003c40 <iupdate>
  iunlock(ip);
    80005a14:	8526                	mv	a0,s1
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	3b8080e7          	jalr	952(ra) # 80003dce <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a1e:	fd040593          	addi	a1,s0,-48
    80005a22:	f5040513          	addi	a0,s0,-176
    80005a26:	fffff097          	auipc	ra,0xfffff
    80005a2a:	ab0080e7          	jalr	-1360(ra) # 800044d6 <nameiparent>
    80005a2e:	892a                	mv	s2,a0
    80005a30:	c935                	beqz	a0,80005aa4 <sys_link+0x10a>
  ilock(dp);
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	2da080e7          	jalr	730(ra) # 80003d0c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a3a:	00092703          	lw	a4,0(s2)
    80005a3e:	409c                	lw	a5,0(s1)
    80005a40:	04f71d63          	bne	a4,a5,80005a9a <sys_link+0x100>
    80005a44:	40d0                	lw	a2,4(s1)
    80005a46:	fd040593          	addi	a1,s0,-48
    80005a4a:	854a                	mv	a0,s2
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	9ba080e7          	jalr	-1606(ra) # 80004406 <dirlink>
    80005a54:	04054363          	bltz	a0,80005a9a <sys_link+0x100>
  iunlockput(dp);
    80005a58:	854a                	mv	a0,s2
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	514080e7          	jalr	1300(ra) # 80003f6e <iunlockput>
  iput(ip);
    80005a62:	8526                	mv	a0,s1
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	462080e7          	jalr	1122(ra) # 80003ec6 <iput>
  end_op();
    80005a6c:	fffff097          	auipc	ra,0xfffff
    80005a70:	cea080e7          	jalr	-790(ra) # 80004756 <end_op>
  return 0;
    80005a74:	4781                	li	a5,0
    80005a76:	a085                	j	80005ad6 <sys_link+0x13c>
    end_op();
    80005a78:	fffff097          	auipc	ra,0xfffff
    80005a7c:	cde080e7          	jalr	-802(ra) # 80004756 <end_op>
    return -1;
    80005a80:	57fd                	li	a5,-1
    80005a82:	a891                	j	80005ad6 <sys_link+0x13c>
    iunlockput(ip);
    80005a84:	8526                	mv	a0,s1
    80005a86:	ffffe097          	auipc	ra,0xffffe
    80005a8a:	4e8080e7          	jalr	1256(ra) # 80003f6e <iunlockput>
    end_op();
    80005a8e:	fffff097          	auipc	ra,0xfffff
    80005a92:	cc8080e7          	jalr	-824(ra) # 80004756 <end_op>
    return -1;
    80005a96:	57fd                	li	a5,-1
    80005a98:	a83d                	j	80005ad6 <sys_link+0x13c>
    iunlockput(dp);
    80005a9a:	854a                	mv	a0,s2
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	4d2080e7          	jalr	1234(ra) # 80003f6e <iunlockput>
  ilock(ip);
    80005aa4:	8526                	mv	a0,s1
    80005aa6:	ffffe097          	auipc	ra,0xffffe
    80005aaa:	266080e7          	jalr	614(ra) # 80003d0c <ilock>
  ip->nlink--;
    80005aae:	04a4d783          	lhu	a5,74(s1)
    80005ab2:	37fd                	addiw	a5,a5,-1
    80005ab4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ab8:	8526                	mv	a0,s1
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	186080e7          	jalr	390(ra) # 80003c40 <iupdate>
  iunlockput(ip);
    80005ac2:	8526                	mv	a0,s1
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	4aa080e7          	jalr	1194(ra) # 80003f6e <iunlockput>
  end_op();
    80005acc:	fffff097          	auipc	ra,0xfffff
    80005ad0:	c8a080e7          	jalr	-886(ra) # 80004756 <end_op>
  return -1;
    80005ad4:	57fd                	li	a5,-1
}
    80005ad6:	853e                	mv	a0,a5
    80005ad8:	70b2                	ld	ra,296(sp)
    80005ada:	7412                	ld	s0,288(sp)
    80005adc:	64f2                	ld	s1,280(sp)
    80005ade:	6952                	ld	s2,272(sp)
    80005ae0:	6155                	addi	sp,sp,304
    80005ae2:	8082                	ret

0000000080005ae4 <sys_unlink>:
{
    80005ae4:	7151                	addi	sp,sp,-240
    80005ae6:	f586                	sd	ra,232(sp)
    80005ae8:	f1a2                	sd	s0,224(sp)
    80005aea:	eda6                	sd	s1,216(sp)
    80005aec:	e9ca                	sd	s2,208(sp)
    80005aee:	e5ce                	sd	s3,200(sp)
    80005af0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005af2:	08000613          	li	a2,128
    80005af6:	f3040593          	addi	a1,s0,-208
    80005afa:	4501                	li	a0,0
    80005afc:	ffffd097          	auipc	ra,0xffffd
    80005b00:	5a6080e7          	jalr	1446(ra) # 800030a2 <argstr>
    80005b04:	18054163          	bltz	a0,80005c86 <sys_unlink+0x1a2>
  begin_op();
    80005b08:	fffff097          	auipc	ra,0xfffff
    80005b0c:	bd0080e7          	jalr	-1072(ra) # 800046d8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b10:	fb040593          	addi	a1,s0,-80
    80005b14:	f3040513          	addi	a0,s0,-208
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	9be080e7          	jalr	-1602(ra) # 800044d6 <nameiparent>
    80005b20:	84aa                	mv	s1,a0
    80005b22:	c979                	beqz	a0,80005bf8 <sys_unlink+0x114>
  ilock(dp);
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	1e8080e7          	jalr	488(ra) # 80003d0c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b2c:	00003597          	auipc	a1,0x3
    80005b30:	d7458593          	addi	a1,a1,-652 # 800088a0 <syscalls+0x2c8>
    80005b34:	fb040513          	addi	a0,s0,-80
    80005b38:	ffffe097          	auipc	ra,0xffffe
    80005b3c:	69e080e7          	jalr	1694(ra) # 800041d6 <namecmp>
    80005b40:	14050a63          	beqz	a0,80005c94 <sys_unlink+0x1b0>
    80005b44:	00003597          	auipc	a1,0x3
    80005b48:	d6458593          	addi	a1,a1,-668 # 800088a8 <syscalls+0x2d0>
    80005b4c:	fb040513          	addi	a0,s0,-80
    80005b50:	ffffe097          	auipc	ra,0xffffe
    80005b54:	686080e7          	jalr	1670(ra) # 800041d6 <namecmp>
    80005b58:	12050e63          	beqz	a0,80005c94 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b5c:	f2c40613          	addi	a2,s0,-212
    80005b60:	fb040593          	addi	a1,s0,-80
    80005b64:	8526                	mv	a0,s1
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	68a080e7          	jalr	1674(ra) # 800041f0 <dirlookup>
    80005b6e:	892a                	mv	s2,a0
    80005b70:	12050263          	beqz	a0,80005c94 <sys_unlink+0x1b0>
  ilock(ip);
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	198080e7          	jalr	408(ra) # 80003d0c <ilock>
  if(ip->nlink < 1)
    80005b7c:	04a91783          	lh	a5,74(s2)
    80005b80:	08f05263          	blez	a5,80005c04 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b84:	04491703          	lh	a4,68(s2)
    80005b88:	4785                	li	a5,1
    80005b8a:	08f70563          	beq	a4,a5,80005c14 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b8e:	4641                	li	a2,16
    80005b90:	4581                	li	a1,0
    80005b92:	fc040513          	addi	a0,s0,-64
    80005b96:	ffffb097          	auipc	ra,0xffffb
    80005b9a:	2d2080e7          	jalr	722(ra) # 80000e68 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b9e:	4741                	li	a4,16
    80005ba0:	f2c42683          	lw	a3,-212(s0)
    80005ba4:	fc040613          	addi	a2,s0,-64
    80005ba8:	4581                	li	a1,0
    80005baa:	8526                	mv	a0,s1
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	50c080e7          	jalr	1292(ra) # 800040b8 <writei>
    80005bb4:	47c1                	li	a5,16
    80005bb6:	0af51563          	bne	a0,a5,80005c60 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005bba:	04491703          	lh	a4,68(s2)
    80005bbe:	4785                	li	a5,1
    80005bc0:	0af70863          	beq	a4,a5,80005c70 <sys_unlink+0x18c>
  iunlockput(dp);
    80005bc4:	8526                	mv	a0,s1
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	3a8080e7          	jalr	936(ra) # 80003f6e <iunlockput>
  ip->nlink--;
    80005bce:	04a95783          	lhu	a5,74(s2)
    80005bd2:	37fd                	addiw	a5,a5,-1
    80005bd4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005bd8:	854a                	mv	a0,s2
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	066080e7          	jalr	102(ra) # 80003c40 <iupdate>
  iunlockput(ip);
    80005be2:	854a                	mv	a0,s2
    80005be4:	ffffe097          	auipc	ra,0xffffe
    80005be8:	38a080e7          	jalr	906(ra) # 80003f6e <iunlockput>
  end_op();
    80005bec:	fffff097          	auipc	ra,0xfffff
    80005bf0:	b6a080e7          	jalr	-1174(ra) # 80004756 <end_op>
  return 0;
    80005bf4:	4501                	li	a0,0
    80005bf6:	a84d                	j	80005ca8 <sys_unlink+0x1c4>
    end_op();
    80005bf8:	fffff097          	auipc	ra,0xfffff
    80005bfc:	b5e080e7          	jalr	-1186(ra) # 80004756 <end_op>
    return -1;
    80005c00:	557d                	li	a0,-1
    80005c02:	a05d                	j	80005ca8 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005c04:	00003517          	auipc	a0,0x3
    80005c08:	cac50513          	addi	a0,a0,-852 # 800088b0 <syscalls+0x2d8>
    80005c0c:	ffffb097          	auipc	ra,0xffffb
    80005c10:	934080e7          	jalr	-1740(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c14:	04c92703          	lw	a4,76(s2)
    80005c18:	02000793          	li	a5,32
    80005c1c:	f6e7f9e3          	bgeu	a5,a4,80005b8e <sys_unlink+0xaa>
    80005c20:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c24:	4741                	li	a4,16
    80005c26:	86ce                	mv	a3,s3
    80005c28:	f1840613          	addi	a2,s0,-232
    80005c2c:	4581                	li	a1,0
    80005c2e:	854a                	mv	a0,s2
    80005c30:	ffffe097          	auipc	ra,0xffffe
    80005c34:	390080e7          	jalr	912(ra) # 80003fc0 <readi>
    80005c38:	47c1                	li	a5,16
    80005c3a:	00f51b63          	bne	a0,a5,80005c50 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005c3e:	f1845783          	lhu	a5,-232(s0)
    80005c42:	e7a1                	bnez	a5,80005c8a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c44:	29c1                	addiw	s3,s3,16
    80005c46:	04c92783          	lw	a5,76(s2)
    80005c4a:	fcf9ede3          	bltu	s3,a5,80005c24 <sys_unlink+0x140>
    80005c4e:	b781                	j	80005b8e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c50:	00003517          	auipc	a0,0x3
    80005c54:	c7850513          	addi	a0,a0,-904 # 800088c8 <syscalls+0x2f0>
    80005c58:	ffffb097          	auipc	ra,0xffffb
    80005c5c:	8e8080e7          	jalr	-1816(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005c60:	00003517          	auipc	a0,0x3
    80005c64:	c8050513          	addi	a0,a0,-896 # 800088e0 <syscalls+0x308>
    80005c68:	ffffb097          	auipc	ra,0xffffb
    80005c6c:	8d8080e7          	jalr	-1832(ra) # 80000540 <panic>
    dp->nlink--;
    80005c70:	04a4d783          	lhu	a5,74(s1)
    80005c74:	37fd                	addiw	a5,a5,-1
    80005c76:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c7a:	8526                	mv	a0,s1
    80005c7c:	ffffe097          	auipc	ra,0xffffe
    80005c80:	fc4080e7          	jalr	-60(ra) # 80003c40 <iupdate>
    80005c84:	b781                	j	80005bc4 <sys_unlink+0xe0>
    return -1;
    80005c86:	557d                	li	a0,-1
    80005c88:	a005                	j	80005ca8 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c8a:	854a                	mv	a0,s2
    80005c8c:	ffffe097          	auipc	ra,0xffffe
    80005c90:	2e2080e7          	jalr	738(ra) # 80003f6e <iunlockput>
  iunlockput(dp);
    80005c94:	8526                	mv	a0,s1
    80005c96:	ffffe097          	auipc	ra,0xffffe
    80005c9a:	2d8080e7          	jalr	728(ra) # 80003f6e <iunlockput>
  end_op();
    80005c9e:	fffff097          	auipc	ra,0xfffff
    80005ca2:	ab8080e7          	jalr	-1352(ra) # 80004756 <end_op>
  return -1;
    80005ca6:	557d                	li	a0,-1
}
    80005ca8:	70ae                	ld	ra,232(sp)
    80005caa:	740e                	ld	s0,224(sp)
    80005cac:	64ee                	ld	s1,216(sp)
    80005cae:	694e                	ld	s2,208(sp)
    80005cb0:	69ae                	ld	s3,200(sp)
    80005cb2:	616d                	addi	sp,sp,240
    80005cb4:	8082                	ret

0000000080005cb6 <sys_open>:

uint64
sys_open(void)
{
    80005cb6:	7131                	addi	sp,sp,-192
    80005cb8:	fd06                	sd	ra,184(sp)
    80005cba:	f922                	sd	s0,176(sp)
    80005cbc:	f526                	sd	s1,168(sp)
    80005cbe:	f14a                	sd	s2,160(sp)
    80005cc0:	ed4e                	sd	s3,152(sp)
    80005cc2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005cc4:	f4c40593          	addi	a1,s0,-180
    80005cc8:	4505                	li	a0,1
    80005cca:	ffffd097          	auipc	ra,0xffffd
    80005cce:	398080e7          	jalr	920(ra) # 80003062 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005cd2:	08000613          	li	a2,128
    80005cd6:	f5040593          	addi	a1,s0,-176
    80005cda:	4501                	li	a0,0
    80005cdc:	ffffd097          	auipc	ra,0xffffd
    80005ce0:	3c6080e7          	jalr	966(ra) # 800030a2 <argstr>
    80005ce4:	87aa                	mv	a5,a0
    return -1;
    80005ce6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ce8:	0a07c963          	bltz	a5,80005d9a <sys_open+0xe4>

  begin_op();
    80005cec:	fffff097          	auipc	ra,0xfffff
    80005cf0:	9ec080e7          	jalr	-1556(ra) # 800046d8 <begin_op>

  if(omode & O_CREATE){
    80005cf4:	f4c42783          	lw	a5,-180(s0)
    80005cf8:	2007f793          	andi	a5,a5,512
    80005cfc:	cfc5                	beqz	a5,80005db4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005cfe:	4681                	li	a3,0
    80005d00:	4601                	li	a2,0
    80005d02:	4589                	li	a1,2
    80005d04:	f5040513          	addi	a0,s0,-176
    80005d08:	00000097          	auipc	ra,0x0
    80005d0c:	972080e7          	jalr	-1678(ra) # 8000567a <create>
    80005d10:	84aa                	mv	s1,a0
    if(ip == 0){
    80005d12:	c959                	beqz	a0,80005da8 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d14:	04449703          	lh	a4,68(s1)
    80005d18:	478d                	li	a5,3
    80005d1a:	00f71763          	bne	a4,a5,80005d28 <sys_open+0x72>
    80005d1e:	0464d703          	lhu	a4,70(s1)
    80005d22:	47a5                	li	a5,9
    80005d24:	0ce7ed63          	bltu	a5,a4,80005dfe <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d28:	fffff097          	auipc	ra,0xfffff
    80005d2c:	dbc080e7          	jalr	-580(ra) # 80004ae4 <filealloc>
    80005d30:	89aa                	mv	s3,a0
    80005d32:	10050363          	beqz	a0,80005e38 <sys_open+0x182>
    80005d36:	00000097          	auipc	ra,0x0
    80005d3a:	902080e7          	jalr	-1790(ra) # 80005638 <fdalloc>
    80005d3e:	892a                	mv	s2,a0
    80005d40:	0e054763          	bltz	a0,80005e2e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d44:	04449703          	lh	a4,68(s1)
    80005d48:	478d                	li	a5,3
    80005d4a:	0cf70563          	beq	a4,a5,80005e14 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d4e:	4789                	li	a5,2
    80005d50:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d54:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d58:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d5c:	f4c42783          	lw	a5,-180(s0)
    80005d60:	0017c713          	xori	a4,a5,1
    80005d64:	8b05                	andi	a4,a4,1
    80005d66:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d6a:	0037f713          	andi	a4,a5,3
    80005d6e:	00e03733          	snez	a4,a4
    80005d72:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d76:	4007f793          	andi	a5,a5,1024
    80005d7a:	c791                	beqz	a5,80005d86 <sys_open+0xd0>
    80005d7c:	04449703          	lh	a4,68(s1)
    80005d80:	4789                	li	a5,2
    80005d82:	0af70063          	beq	a4,a5,80005e22 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d86:	8526                	mv	a0,s1
    80005d88:	ffffe097          	auipc	ra,0xffffe
    80005d8c:	046080e7          	jalr	70(ra) # 80003dce <iunlock>
  end_op();
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	9c6080e7          	jalr	-1594(ra) # 80004756 <end_op>

  return fd;
    80005d98:	854a                	mv	a0,s2
}
    80005d9a:	70ea                	ld	ra,184(sp)
    80005d9c:	744a                	ld	s0,176(sp)
    80005d9e:	74aa                	ld	s1,168(sp)
    80005da0:	790a                	ld	s2,160(sp)
    80005da2:	69ea                	ld	s3,152(sp)
    80005da4:	6129                	addi	sp,sp,192
    80005da6:	8082                	ret
      end_op();
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	9ae080e7          	jalr	-1618(ra) # 80004756 <end_op>
      return -1;
    80005db0:	557d                	li	a0,-1
    80005db2:	b7e5                	j	80005d9a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005db4:	f5040513          	addi	a0,s0,-176
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	700080e7          	jalr	1792(ra) # 800044b8 <namei>
    80005dc0:	84aa                	mv	s1,a0
    80005dc2:	c905                	beqz	a0,80005df2 <sys_open+0x13c>
    ilock(ip);
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	f48080e7          	jalr	-184(ra) # 80003d0c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005dcc:	04449703          	lh	a4,68(s1)
    80005dd0:	4785                	li	a5,1
    80005dd2:	f4f711e3          	bne	a4,a5,80005d14 <sys_open+0x5e>
    80005dd6:	f4c42783          	lw	a5,-180(s0)
    80005dda:	d7b9                	beqz	a5,80005d28 <sys_open+0x72>
      iunlockput(ip);
    80005ddc:	8526                	mv	a0,s1
    80005dde:	ffffe097          	auipc	ra,0xffffe
    80005de2:	190080e7          	jalr	400(ra) # 80003f6e <iunlockput>
      end_op();
    80005de6:	fffff097          	auipc	ra,0xfffff
    80005dea:	970080e7          	jalr	-1680(ra) # 80004756 <end_op>
      return -1;
    80005dee:	557d                	li	a0,-1
    80005df0:	b76d                	j	80005d9a <sys_open+0xe4>
      end_op();
    80005df2:	fffff097          	auipc	ra,0xfffff
    80005df6:	964080e7          	jalr	-1692(ra) # 80004756 <end_op>
      return -1;
    80005dfa:	557d                	li	a0,-1
    80005dfc:	bf79                	j	80005d9a <sys_open+0xe4>
    iunlockput(ip);
    80005dfe:	8526                	mv	a0,s1
    80005e00:	ffffe097          	auipc	ra,0xffffe
    80005e04:	16e080e7          	jalr	366(ra) # 80003f6e <iunlockput>
    end_op();
    80005e08:	fffff097          	auipc	ra,0xfffff
    80005e0c:	94e080e7          	jalr	-1714(ra) # 80004756 <end_op>
    return -1;
    80005e10:	557d                	li	a0,-1
    80005e12:	b761                	j	80005d9a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005e14:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005e18:	04649783          	lh	a5,70(s1)
    80005e1c:	02f99223          	sh	a5,36(s3)
    80005e20:	bf25                	j	80005d58 <sys_open+0xa2>
    itrunc(ip);
    80005e22:	8526                	mv	a0,s1
    80005e24:	ffffe097          	auipc	ra,0xffffe
    80005e28:	ff6080e7          	jalr	-10(ra) # 80003e1a <itrunc>
    80005e2c:	bfa9                	j	80005d86 <sys_open+0xd0>
      fileclose(f);
    80005e2e:	854e                	mv	a0,s3
    80005e30:	fffff097          	auipc	ra,0xfffff
    80005e34:	d70080e7          	jalr	-656(ra) # 80004ba0 <fileclose>
    iunlockput(ip);
    80005e38:	8526                	mv	a0,s1
    80005e3a:	ffffe097          	auipc	ra,0xffffe
    80005e3e:	134080e7          	jalr	308(ra) # 80003f6e <iunlockput>
    end_op();
    80005e42:	fffff097          	auipc	ra,0xfffff
    80005e46:	914080e7          	jalr	-1772(ra) # 80004756 <end_op>
    return -1;
    80005e4a:	557d                	li	a0,-1
    80005e4c:	b7b9                	j	80005d9a <sys_open+0xe4>

0000000080005e4e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e4e:	7175                	addi	sp,sp,-144
    80005e50:	e506                	sd	ra,136(sp)
    80005e52:	e122                	sd	s0,128(sp)
    80005e54:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e56:	fffff097          	auipc	ra,0xfffff
    80005e5a:	882080e7          	jalr	-1918(ra) # 800046d8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e5e:	08000613          	li	a2,128
    80005e62:	f7040593          	addi	a1,s0,-144
    80005e66:	4501                	li	a0,0
    80005e68:	ffffd097          	auipc	ra,0xffffd
    80005e6c:	23a080e7          	jalr	570(ra) # 800030a2 <argstr>
    80005e70:	02054963          	bltz	a0,80005ea2 <sys_mkdir+0x54>
    80005e74:	4681                	li	a3,0
    80005e76:	4601                	li	a2,0
    80005e78:	4585                	li	a1,1
    80005e7a:	f7040513          	addi	a0,s0,-144
    80005e7e:	fffff097          	auipc	ra,0xfffff
    80005e82:	7fc080e7          	jalr	2044(ra) # 8000567a <create>
    80005e86:	cd11                	beqz	a0,80005ea2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e88:	ffffe097          	auipc	ra,0xffffe
    80005e8c:	0e6080e7          	jalr	230(ra) # 80003f6e <iunlockput>
  end_op();
    80005e90:	fffff097          	auipc	ra,0xfffff
    80005e94:	8c6080e7          	jalr	-1850(ra) # 80004756 <end_op>
  return 0;
    80005e98:	4501                	li	a0,0
}
    80005e9a:	60aa                	ld	ra,136(sp)
    80005e9c:	640a                	ld	s0,128(sp)
    80005e9e:	6149                	addi	sp,sp,144
    80005ea0:	8082                	ret
    end_op();
    80005ea2:	fffff097          	auipc	ra,0xfffff
    80005ea6:	8b4080e7          	jalr	-1868(ra) # 80004756 <end_op>
    return -1;
    80005eaa:	557d                	li	a0,-1
    80005eac:	b7fd                	j	80005e9a <sys_mkdir+0x4c>

0000000080005eae <sys_mknod>:

uint64
sys_mknod(void)
{
    80005eae:	7135                	addi	sp,sp,-160
    80005eb0:	ed06                	sd	ra,152(sp)
    80005eb2:	e922                	sd	s0,144(sp)
    80005eb4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005eb6:	fffff097          	auipc	ra,0xfffff
    80005eba:	822080e7          	jalr	-2014(ra) # 800046d8 <begin_op>
  argint(1, &major);
    80005ebe:	f6c40593          	addi	a1,s0,-148
    80005ec2:	4505                	li	a0,1
    80005ec4:	ffffd097          	auipc	ra,0xffffd
    80005ec8:	19e080e7          	jalr	414(ra) # 80003062 <argint>
  argint(2, &minor);
    80005ecc:	f6840593          	addi	a1,s0,-152
    80005ed0:	4509                	li	a0,2
    80005ed2:	ffffd097          	auipc	ra,0xffffd
    80005ed6:	190080e7          	jalr	400(ra) # 80003062 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005eda:	08000613          	li	a2,128
    80005ede:	f7040593          	addi	a1,s0,-144
    80005ee2:	4501                	li	a0,0
    80005ee4:	ffffd097          	auipc	ra,0xffffd
    80005ee8:	1be080e7          	jalr	446(ra) # 800030a2 <argstr>
    80005eec:	02054b63          	bltz	a0,80005f22 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ef0:	f6841683          	lh	a3,-152(s0)
    80005ef4:	f6c41603          	lh	a2,-148(s0)
    80005ef8:	458d                	li	a1,3
    80005efa:	f7040513          	addi	a0,s0,-144
    80005efe:	fffff097          	auipc	ra,0xfffff
    80005f02:	77c080e7          	jalr	1916(ra) # 8000567a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f06:	cd11                	beqz	a0,80005f22 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f08:	ffffe097          	auipc	ra,0xffffe
    80005f0c:	066080e7          	jalr	102(ra) # 80003f6e <iunlockput>
  end_op();
    80005f10:	fffff097          	auipc	ra,0xfffff
    80005f14:	846080e7          	jalr	-1978(ra) # 80004756 <end_op>
  return 0;
    80005f18:	4501                	li	a0,0
}
    80005f1a:	60ea                	ld	ra,152(sp)
    80005f1c:	644a                	ld	s0,144(sp)
    80005f1e:	610d                	addi	sp,sp,160
    80005f20:	8082                	ret
    end_op();
    80005f22:	fffff097          	auipc	ra,0xfffff
    80005f26:	834080e7          	jalr	-1996(ra) # 80004756 <end_op>
    return -1;
    80005f2a:	557d                	li	a0,-1
    80005f2c:	b7fd                	j	80005f1a <sys_mknod+0x6c>

0000000080005f2e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f2e:	7135                	addi	sp,sp,-160
    80005f30:	ed06                	sd	ra,152(sp)
    80005f32:	e922                	sd	s0,144(sp)
    80005f34:	e526                	sd	s1,136(sp)
    80005f36:	e14a                	sd	s2,128(sp)
    80005f38:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f3a:	ffffc097          	auipc	ra,0xffffc
    80005f3e:	d20080e7          	jalr	-736(ra) # 80001c5a <myproc>
    80005f42:	892a                	mv	s2,a0
  
  begin_op();
    80005f44:	ffffe097          	auipc	ra,0xffffe
    80005f48:	794080e7          	jalr	1940(ra) # 800046d8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f4c:	08000613          	li	a2,128
    80005f50:	f6040593          	addi	a1,s0,-160
    80005f54:	4501                	li	a0,0
    80005f56:	ffffd097          	auipc	ra,0xffffd
    80005f5a:	14c080e7          	jalr	332(ra) # 800030a2 <argstr>
    80005f5e:	04054b63          	bltz	a0,80005fb4 <sys_chdir+0x86>
    80005f62:	f6040513          	addi	a0,s0,-160
    80005f66:	ffffe097          	auipc	ra,0xffffe
    80005f6a:	552080e7          	jalr	1362(ra) # 800044b8 <namei>
    80005f6e:	84aa                	mv	s1,a0
    80005f70:	c131                	beqz	a0,80005fb4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f72:	ffffe097          	auipc	ra,0xffffe
    80005f76:	d9a080e7          	jalr	-614(ra) # 80003d0c <ilock>
  if(ip->type != T_DIR){
    80005f7a:	04449703          	lh	a4,68(s1)
    80005f7e:	4785                	li	a5,1
    80005f80:	04f71063          	bne	a4,a5,80005fc0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f84:	8526                	mv	a0,s1
    80005f86:	ffffe097          	auipc	ra,0xffffe
    80005f8a:	e48080e7          	jalr	-440(ra) # 80003dce <iunlock>
  iput(p->cwd);
    80005f8e:	15093503          	ld	a0,336(s2)
    80005f92:	ffffe097          	auipc	ra,0xffffe
    80005f96:	f34080e7          	jalr	-204(ra) # 80003ec6 <iput>
  end_op();
    80005f9a:	ffffe097          	auipc	ra,0xffffe
    80005f9e:	7bc080e7          	jalr	1980(ra) # 80004756 <end_op>
  p->cwd = ip;
    80005fa2:	14993823          	sd	s1,336(s2)
  return 0;
    80005fa6:	4501                	li	a0,0
}
    80005fa8:	60ea                	ld	ra,152(sp)
    80005faa:	644a                	ld	s0,144(sp)
    80005fac:	64aa                	ld	s1,136(sp)
    80005fae:	690a                	ld	s2,128(sp)
    80005fb0:	610d                	addi	sp,sp,160
    80005fb2:	8082                	ret
    end_op();
    80005fb4:	ffffe097          	auipc	ra,0xffffe
    80005fb8:	7a2080e7          	jalr	1954(ra) # 80004756 <end_op>
    return -1;
    80005fbc:	557d                	li	a0,-1
    80005fbe:	b7ed                	j	80005fa8 <sys_chdir+0x7a>
    iunlockput(ip);
    80005fc0:	8526                	mv	a0,s1
    80005fc2:	ffffe097          	auipc	ra,0xffffe
    80005fc6:	fac080e7          	jalr	-84(ra) # 80003f6e <iunlockput>
    end_op();
    80005fca:	ffffe097          	auipc	ra,0xffffe
    80005fce:	78c080e7          	jalr	1932(ra) # 80004756 <end_op>
    return -1;
    80005fd2:	557d                	li	a0,-1
    80005fd4:	bfd1                	j	80005fa8 <sys_chdir+0x7a>

0000000080005fd6 <sys_exec>:

uint64
sys_exec(void)
{
    80005fd6:	7145                	addi	sp,sp,-464
    80005fd8:	e786                	sd	ra,456(sp)
    80005fda:	e3a2                	sd	s0,448(sp)
    80005fdc:	ff26                	sd	s1,440(sp)
    80005fde:	fb4a                	sd	s2,432(sp)
    80005fe0:	f74e                	sd	s3,424(sp)
    80005fe2:	f352                	sd	s4,416(sp)
    80005fe4:	ef56                	sd	s5,408(sp)
    80005fe6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005fe8:	e3840593          	addi	a1,s0,-456
    80005fec:	4505                	li	a0,1
    80005fee:	ffffd097          	auipc	ra,0xffffd
    80005ff2:	094080e7          	jalr	148(ra) # 80003082 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ff6:	08000613          	li	a2,128
    80005ffa:	f4040593          	addi	a1,s0,-192
    80005ffe:	4501                	li	a0,0
    80006000:	ffffd097          	auipc	ra,0xffffd
    80006004:	0a2080e7          	jalr	162(ra) # 800030a2 <argstr>
    80006008:	87aa                	mv	a5,a0
    return -1;
    8000600a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000600c:	0c07c363          	bltz	a5,800060d2 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80006010:	10000613          	li	a2,256
    80006014:	4581                	li	a1,0
    80006016:	e4040513          	addi	a0,s0,-448
    8000601a:	ffffb097          	auipc	ra,0xffffb
    8000601e:	e4e080e7          	jalr	-434(ra) # 80000e68 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006022:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006026:	89a6                	mv	s3,s1
    80006028:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000602a:	02000a13          	li	s4,32
    8000602e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006032:	00391513          	slli	a0,s2,0x3
    80006036:	e3040593          	addi	a1,s0,-464
    8000603a:	e3843783          	ld	a5,-456(s0)
    8000603e:	953e                	add	a0,a0,a5
    80006040:	ffffd097          	auipc	ra,0xffffd
    80006044:	f84080e7          	jalr	-124(ra) # 80002fc4 <fetchaddr>
    80006048:	02054a63          	bltz	a0,8000607c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    8000604c:	e3043783          	ld	a5,-464(s0)
    80006050:	c3b9                	beqz	a5,80006096 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006052:	ffffb097          	auipc	ra,0xffffb
    80006056:	b6c080e7          	jalr	-1172(ra) # 80000bbe <kalloc>
    8000605a:	85aa                	mv	a1,a0
    8000605c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006060:	cd11                	beqz	a0,8000607c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006062:	6605                	lui	a2,0x1
    80006064:	e3043503          	ld	a0,-464(s0)
    80006068:	ffffd097          	auipc	ra,0xffffd
    8000606c:	fae080e7          	jalr	-82(ra) # 80003016 <fetchstr>
    80006070:	00054663          	bltz	a0,8000607c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006074:	0905                	addi	s2,s2,1
    80006076:	09a1                	addi	s3,s3,8
    80006078:	fb491be3          	bne	s2,s4,8000602e <sys_exec+0x58>
    dec_ref(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000607c:	f4040913          	addi	s2,s0,-192
    80006080:	6088                	ld	a0,0(s1)
    80006082:	c539                	beqz	a0,800060d0 <sys_exec+0xfa>
    dec_ref(argv[i]);
    80006084:	ffffb097          	auipc	ra,0xffffb
    80006088:	bf0080e7          	jalr	-1040(ra) # 80000c74 <dec_ref>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000608c:	04a1                	addi	s1,s1,8
    8000608e:	ff2499e3          	bne	s1,s2,80006080 <sys_exec+0xaa>
  return -1;
    80006092:	557d                	li	a0,-1
    80006094:	a83d                	j	800060d2 <sys_exec+0xfc>
      argv[i] = 0;
    80006096:	0a8e                	slli	s5,s5,0x3
    80006098:	fc0a8793          	addi	a5,s5,-64
    8000609c:	00878ab3          	add	s5,a5,s0
    800060a0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800060a4:	e4040593          	addi	a1,s0,-448
    800060a8:	f4040513          	addi	a0,s0,-192
    800060ac:	fffff097          	auipc	ra,0xfffff
    800060b0:	16e080e7          	jalr	366(ra) # 8000521a <exec>
    800060b4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060b6:	f4040993          	addi	s3,s0,-192
    800060ba:	6088                	ld	a0,0(s1)
    800060bc:	c901                	beqz	a0,800060cc <sys_exec+0xf6>
    dec_ref(argv[i]);
    800060be:	ffffb097          	auipc	ra,0xffffb
    800060c2:	bb6080e7          	jalr	-1098(ra) # 80000c74 <dec_ref>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060c6:	04a1                	addi	s1,s1,8
    800060c8:	ff3499e3          	bne	s1,s3,800060ba <sys_exec+0xe4>
  return ret;
    800060cc:	854a                	mv	a0,s2
    800060ce:	a011                	j	800060d2 <sys_exec+0xfc>
  return -1;
    800060d0:	557d                	li	a0,-1
}
    800060d2:	60be                	ld	ra,456(sp)
    800060d4:	641e                	ld	s0,448(sp)
    800060d6:	74fa                	ld	s1,440(sp)
    800060d8:	795a                	ld	s2,432(sp)
    800060da:	79ba                	ld	s3,424(sp)
    800060dc:	7a1a                	ld	s4,416(sp)
    800060de:	6afa                	ld	s5,408(sp)
    800060e0:	6179                	addi	sp,sp,464
    800060e2:	8082                	ret

00000000800060e4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800060e4:	7139                	addi	sp,sp,-64
    800060e6:	fc06                	sd	ra,56(sp)
    800060e8:	f822                	sd	s0,48(sp)
    800060ea:	f426                	sd	s1,40(sp)
    800060ec:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800060ee:	ffffc097          	auipc	ra,0xffffc
    800060f2:	b6c080e7          	jalr	-1172(ra) # 80001c5a <myproc>
    800060f6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800060f8:	fd840593          	addi	a1,s0,-40
    800060fc:	4501                	li	a0,0
    800060fe:	ffffd097          	auipc	ra,0xffffd
    80006102:	f84080e7          	jalr	-124(ra) # 80003082 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006106:	fc840593          	addi	a1,s0,-56
    8000610a:	fd040513          	addi	a0,s0,-48
    8000610e:	fffff097          	auipc	ra,0xfffff
    80006112:	dc2080e7          	jalr	-574(ra) # 80004ed0 <pipealloc>
    return -1;
    80006116:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006118:	0c054463          	bltz	a0,800061e0 <sys_pipe+0xfc>
  fd0 = -1;
    8000611c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006120:	fd043503          	ld	a0,-48(s0)
    80006124:	fffff097          	auipc	ra,0xfffff
    80006128:	514080e7          	jalr	1300(ra) # 80005638 <fdalloc>
    8000612c:	fca42223          	sw	a0,-60(s0)
    80006130:	08054b63          	bltz	a0,800061c6 <sys_pipe+0xe2>
    80006134:	fc843503          	ld	a0,-56(s0)
    80006138:	fffff097          	auipc	ra,0xfffff
    8000613c:	500080e7          	jalr	1280(ra) # 80005638 <fdalloc>
    80006140:	fca42023          	sw	a0,-64(s0)
    80006144:	06054863          	bltz	a0,800061b4 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006148:	4691                	li	a3,4
    8000614a:	fc440613          	addi	a2,s0,-60
    8000614e:	fd843583          	ld	a1,-40(s0)
    80006152:	68a8                	ld	a0,80(s1)
    80006154:	ffffb097          	auipc	ra,0xffffb
    80006158:	6c8080e7          	jalr	1736(ra) # 8000181c <copyout>
    8000615c:	02054063          	bltz	a0,8000617c <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006160:	4691                	li	a3,4
    80006162:	fc040613          	addi	a2,s0,-64
    80006166:	fd843583          	ld	a1,-40(s0)
    8000616a:	0591                	addi	a1,a1,4
    8000616c:	68a8                	ld	a0,80(s1)
    8000616e:	ffffb097          	auipc	ra,0xffffb
    80006172:	6ae080e7          	jalr	1710(ra) # 8000181c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006176:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006178:	06055463          	bgez	a0,800061e0 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000617c:	fc442783          	lw	a5,-60(s0)
    80006180:	07e9                	addi	a5,a5,26
    80006182:	078e                	slli	a5,a5,0x3
    80006184:	97a6                	add	a5,a5,s1
    80006186:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000618a:	fc042783          	lw	a5,-64(s0)
    8000618e:	07e9                	addi	a5,a5,26
    80006190:	078e                	slli	a5,a5,0x3
    80006192:	94be                	add	s1,s1,a5
    80006194:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006198:	fd043503          	ld	a0,-48(s0)
    8000619c:	fffff097          	auipc	ra,0xfffff
    800061a0:	a04080e7          	jalr	-1532(ra) # 80004ba0 <fileclose>
    fileclose(wf);
    800061a4:	fc843503          	ld	a0,-56(s0)
    800061a8:	fffff097          	auipc	ra,0xfffff
    800061ac:	9f8080e7          	jalr	-1544(ra) # 80004ba0 <fileclose>
    return -1;
    800061b0:	57fd                	li	a5,-1
    800061b2:	a03d                	j	800061e0 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800061b4:	fc442783          	lw	a5,-60(s0)
    800061b8:	0007c763          	bltz	a5,800061c6 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800061bc:	07e9                	addi	a5,a5,26
    800061be:	078e                	slli	a5,a5,0x3
    800061c0:	97a6                	add	a5,a5,s1
    800061c2:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800061c6:	fd043503          	ld	a0,-48(s0)
    800061ca:	fffff097          	auipc	ra,0xfffff
    800061ce:	9d6080e7          	jalr	-1578(ra) # 80004ba0 <fileclose>
    fileclose(wf);
    800061d2:	fc843503          	ld	a0,-56(s0)
    800061d6:	fffff097          	auipc	ra,0xfffff
    800061da:	9ca080e7          	jalr	-1590(ra) # 80004ba0 <fileclose>
    return -1;
    800061de:	57fd                	li	a5,-1
}
    800061e0:	853e                	mv	a0,a5
    800061e2:	70e2                	ld	ra,56(sp)
    800061e4:	7442                	ld	s0,48(sp)
    800061e6:	74a2                	ld	s1,40(sp)
    800061e8:	6121                	addi	sp,sp,64
    800061ea:	8082                	ret
    800061ec:	0000                	unimp
	...

00000000800061f0 <kernelvec>:
    800061f0:	7111                	addi	sp,sp,-256
    800061f2:	e006                	sd	ra,0(sp)
    800061f4:	e40a                	sd	sp,8(sp)
    800061f6:	e80e                	sd	gp,16(sp)
    800061f8:	ec12                	sd	tp,24(sp)
    800061fa:	f016                	sd	t0,32(sp)
    800061fc:	f41a                	sd	t1,40(sp)
    800061fe:	f81e                	sd	t2,48(sp)
    80006200:	fc22                	sd	s0,56(sp)
    80006202:	e0a6                	sd	s1,64(sp)
    80006204:	e4aa                	sd	a0,72(sp)
    80006206:	e8ae                	sd	a1,80(sp)
    80006208:	ecb2                	sd	a2,88(sp)
    8000620a:	f0b6                	sd	a3,96(sp)
    8000620c:	f4ba                	sd	a4,104(sp)
    8000620e:	f8be                	sd	a5,112(sp)
    80006210:	fcc2                	sd	a6,120(sp)
    80006212:	e146                	sd	a7,128(sp)
    80006214:	e54a                	sd	s2,136(sp)
    80006216:	e94e                	sd	s3,144(sp)
    80006218:	ed52                	sd	s4,152(sp)
    8000621a:	f156                	sd	s5,160(sp)
    8000621c:	f55a                	sd	s6,168(sp)
    8000621e:	f95e                	sd	s7,176(sp)
    80006220:	fd62                	sd	s8,184(sp)
    80006222:	e1e6                	sd	s9,192(sp)
    80006224:	e5ea                	sd	s10,200(sp)
    80006226:	e9ee                	sd	s11,208(sp)
    80006228:	edf2                	sd	t3,216(sp)
    8000622a:	f1f6                	sd	t4,224(sp)
    8000622c:	f5fa                	sd	t5,232(sp)
    8000622e:	f9fe                	sd	t6,240(sp)
    80006230:	c61fc0ef          	jal	ra,80002e90 <kerneltrap>
    80006234:	6082                	ld	ra,0(sp)
    80006236:	6122                	ld	sp,8(sp)
    80006238:	61c2                	ld	gp,16(sp)
    8000623a:	7282                	ld	t0,32(sp)
    8000623c:	7322                	ld	t1,40(sp)
    8000623e:	73c2                	ld	t2,48(sp)
    80006240:	7462                	ld	s0,56(sp)
    80006242:	6486                	ld	s1,64(sp)
    80006244:	6526                	ld	a0,72(sp)
    80006246:	65c6                	ld	a1,80(sp)
    80006248:	6666                	ld	a2,88(sp)
    8000624a:	7686                	ld	a3,96(sp)
    8000624c:	7726                	ld	a4,104(sp)
    8000624e:	77c6                	ld	a5,112(sp)
    80006250:	7866                	ld	a6,120(sp)
    80006252:	688a                	ld	a7,128(sp)
    80006254:	692a                	ld	s2,136(sp)
    80006256:	69ca                	ld	s3,144(sp)
    80006258:	6a6a                	ld	s4,152(sp)
    8000625a:	7a8a                	ld	s5,160(sp)
    8000625c:	7b2a                	ld	s6,168(sp)
    8000625e:	7bca                	ld	s7,176(sp)
    80006260:	7c6a                	ld	s8,184(sp)
    80006262:	6c8e                	ld	s9,192(sp)
    80006264:	6d2e                	ld	s10,200(sp)
    80006266:	6dce                	ld	s11,208(sp)
    80006268:	6e6e                	ld	t3,216(sp)
    8000626a:	7e8e                	ld	t4,224(sp)
    8000626c:	7f2e                	ld	t5,232(sp)
    8000626e:	7fce                	ld	t6,240(sp)
    80006270:	6111                	addi	sp,sp,256
    80006272:	10200073          	sret
    80006276:	00000013          	nop
    8000627a:	00000013          	nop
    8000627e:	0001                	nop

0000000080006280 <timervec>:
    80006280:	34051573          	csrrw	a0,mscratch,a0
    80006284:	e10c                	sd	a1,0(a0)
    80006286:	e510                	sd	a2,8(a0)
    80006288:	e914                	sd	a3,16(a0)
    8000628a:	6d0c                	ld	a1,24(a0)
    8000628c:	7110                	ld	a2,32(a0)
    8000628e:	6194                	ld	a3,0(a1)
    80006290:	96b2                	add	a3,a3,a2
    80006292:	e194                	sd	a3,0(a1)
    80006294:	4589                	li	a1,2
    80006296:	14459073          	csrw	sip,a1
    8000629a:	6914                	ld	a3,16(a0)
    8000629c:	6510                	ld	a2,8(a0)
    8000629e:	610c                	ld	a1,0(a0)
    800062a0:	34051573          	csrrw	a0,mscratch,a0
    800062a4:	30200073          	mret
	...

00000000800062aa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800062aa:	1141                	addi	sp,sp,-16
    800062ac:	e422                	sd	s0,8(sp)
    800062ae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800062b0:	0c0007b7          	lui	a5,0xc000
    800062b4:	4705                	li	a4,1
    800062b6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800062b8:	c3d8                	sw	a4,4(a5)
}
    800062ba:	6422                	ld	s0,8(sp)
    800062bc:	0141                	addi	sp,sp,16
    800062be:	8082                	ret

00000000800062c0 <plicinithart>:

void
plicinithart(void)
{
    800062c0:	1141                	addi	sp,sp,-16
    800062c2:	e406                	sd	ra,8(sp)
    800062c4:	e022                	sd	s0,0(sp)
    800062c6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062c8:	ffffc097          	auipc	ra,0xffffc
    800062cc:	966080e7          	jalr	-1690(ra) # 80001c2e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062d0:	0085171b          	slliw	a4,a0,0x8
    800062d4:	0c0027b7          	lui	a5,0xc002
    800062d8:	97ba                	add	a5,a5,a4
    800062da:	40200713          	li	a4,1026
    800062de:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062e2:	00d5151b          	slliw	a0,a0,0xd
    800062e6:	0c2017b7          	lui	a5,0xc201
    800062ea:	97aa                	add	a5,a5,a0
    800062ec:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800062f0:	60a2                	ld	ra,8(sp)
    800062f2:	6402                	ld	s0,0(sp)
    800062f4:	0141                	addi	sp,sp,16
    800062f6:	8082                	ret

00000000800062f8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062f8:	1141                	addi	sp,sp,-16
    800062fa:	e406                	sd	ra,8(sp)
    800062fc:	e022                	sd	s0,0(sp)
    800062fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006300:	ffffc097          	auipc	ra,0xffffc
    80006304:	92e080e7          	jalr	-1746(ra) # 80001c2e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006308:	00d5151b          	slliw	a0,a0,0xd
    8000630c:	0c2017b7          	lui	a5,0xc201
    80006310:	97aa                	add	a5,a5,a0
  return irq;
}
    80006312:	43c8                	lw	a0,4(a5)
    80006314:	60a2                	ld	ra,8(sp)
    80006316:	6402                	ld	s0,0(sp)
    80006318:	0141                	addi	sp,sp,16
    8000631a:	8082                	ret

000000008000631c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000631c:	1101                	addi	sp,sp,-32
    8000631e:	ec06                	sd	ra,24(sp)
    80006320:	e822                	sd	s0,16(sp)
    80006322:	e426                	sd	s1,8(sp)
    80006324:	1000                	addi	s0,sp,32
    80006326:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006328:	ffffc097          	auipc	ra,0xffffc
    8000632c:	906080e7          	jalr	-1786(ra) # 80001c2e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006330:	00d5151b          	slliw	a0,a0,0xd
    80006334:	0c2017b7          	lui	a5,0xc201
    80006338:	97aa                	add	a5,a5,a0
    8000633a:	c3c4                	sw	s1,4(a5)
}
    8000633c:	60e2                	ld	ra,24(sp)
    8000633e:	6442                	ld	s0,16(sp)
    80006340:	64a2                	ld	s1,8(sp)
    80006342:	6105                	addi	sp,sp,32
    80006344:	8082                	ret

0000000080006346 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006346:	1141                	addi	sp,sp,-16
    80006348:	e406                	sd	ra,8(sp)
    8000634a:	e022                	sd	s0,0(sp)
    8000634c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000634e:	479d                	li	a5,7
    80006350:	04a7cc63          	blt	a5,a0,800063a8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006354:	0005c797          	auipc	a5,0x5c
    80006358:	abc78793          	addi	a5,a5,-1348 # 80061e10 <disk>
    8000635c:	97aa                	add	a5,a5,a0
    8000635e:	0187c783          	lbu	a5,24(a5)
    80006362:	ebb9                	bnez	a5,800063b8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006364:	00451693          	slli	a3,a0,0x4
    80006368:	0005c797          	auipc	a5,0x5c
    8000636c:	aa878793          	addi	a5,a5,-1368 # 80061e10 <disk>
    80006370:	6398                	ld	a4,0(a5)
    80006372:	9736                	add	a4,a4,a3
    80006374:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006378:	6398                	ld	a4,0(a5)
    8000637a:	9736                	add	a4,a4,a3
    8000637c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006380:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006384:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006388:	97aa                	add	a5,a5,a0
    8000638a:	4705                	li	a4,1
    8000638c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006390:	0005c517          	auipc	a0,0x5c
    80006394:	a9850513          	addi	a0,a0,-1384 # 80061e28 <disk+0x18>
    80006398:	ffffc097          	auipc	ra,0xffffc
    8000639c:	0e6080e7          	jalr	230(ra) # 8000247e <wakeup>
}
    800063a0:	60a2                	ld	ra,8(sp)
    800063a2:	6402                	ld	s0,0(sp)
    800063a4:	0141                	addi	sp,sp,16
    800063a6:	8082                	ret
    panic("free_desc 1");
    800063a8:	00002517          	auipc	a0,0x2
    800063ac:	54850513          	addi	a0,a0,1352 # 800088f0 <syscalls+0x318>
    800063b0:	ffffa097          	auipc	ra,0xffffa
    800063b4:	190080e7          	jalr	400(ra) # 80000540 <panic>
    panic("free_desc 2");
    800063b8:	00002517          	auipc	a0,0x2
    800063bc:	54850513          	addi	a0,a0,1352 # 80008900 <syscalls+0x328>
    800063c0:	ffffa097          	auipc	ra,0xffffa
    800063c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800063c8 <virtio_disk_init>:
{
    800063c8:	1101                	addi	sp,sp,-32
    800063ca:	ec06                	sd	ra,24(sp)
    800063cc:	e822                	sd	s0,16(sp)
    800063ce:	e426                	sd	s1,8(sp)
    800063d0:	e04a                	sd	s2,0(sp)
    800063d2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800063d4:	00002597          	auipc	a1,0x2
    800063d8:	53c58593          	addi	a1,a1,1340 # 80008910 <syscalls+0x338>
    800063dc:	0005c517          	auipc	a0,0x5c
    800063e0:	b5c50513          	addi	a0,a0,-1188 # 80061f38 <disk+0x128>
    800063e4:	ffffb097          	auipc	ra,0xffffb
    800063e8:	8f8080e7          	jalr	-1800(ra) # 80000cdc <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063ec:	100017b7          	lui	a5,0x10001
    800063f0:	4398                	lw	a4,0(a5)
    800063f2:	2701                	sext.w	a4,a4
    800063f4:	747277b7          	lui	a5,0x74727
    800063f8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063fc:	14f71b63          	bne	a4,a5,80006552 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006400:	100017b7          	lui	a5,0x10001
    80006404:	43dc                	lw	a5,4(a5)
    80006406:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006408:	4709                	li	a4,2
    8000640a:	14e79463          	bne	a5,a4,80006552 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000640e:	100017b7          	lui	a5,0x10001
    80006412:	479c                	lw	a5,8(a5)
    80006414:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006416:	12e79e63          	bne	a5,a4,80006552 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000641a:	100017b7          	lui	a5,0x10001
    8000641e:	47d8                	lw	a4,12(a5)
    80006420:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006422:	554d47b7          	lui	a5,0x554d4
    80006426:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000642a:	12f71463          	bne	a4,a5,80006552 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000642e:	100017b7          	lui	a5,0x10001
    80006432:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006436:	4705                	li	a4,1
    80006438:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000643a:	470d                	li	a4,3
    8000643c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000643e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006440:	c7ffe6b7          	lui	a3,0xc7ffe
    80006444:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47f9c80f>
    80006448:	8f75                	and	a4,a4,a3
    8000644a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000644c:	472d                	li	a4,11
    8000644e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006450:	5bbc                	lw	a5,112(a5)
    80006452:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006456:	8ba1                	andi	a5,a5,8
    80006458:	10078563          	beqz	a5,80006562 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000645c:	100017b7          	lui	a5,0x10001
    80006460:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006464:	43fc                	lw	a5,68(a5)
    80006466:	2781                	sext.w	a5,a5
    80006468:	10079563          	bnez	a5,80006572 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000646c:	100017b7          	lui	a5,0x10001
    80006470:	5bdc                	lw	a5,52(a5)
    80006472:	2781                	sext.w	a5,a5
  if(max == 0)
    80006474:	10078763          	beqz	a5,80006582 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006478:	471d                	li	a4,7
    8000647a:	10f77c63          	bgeu	a4,a5,80006592 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000647e:	ffffa097          	auipc	ra,0xffffa
    80006482:	740080e7          	jalr	1856(ra) # 80000bbe <kalloc>
    80006486:	0005c497          	auipc	s1,0x5c
    8000648a:	98a48493          	addi	s1,s1,-1654 # 80061e10 <disk>
    8000648e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006490:	ffffa097          	auipc	ra,0xffffa
    80006494:	72e080e7          	jalr	1838(ra) # 80000bbe <kalloc>
    80006498:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000649a:	ffffa097          	auipc	ra,0xffffa
    8000649e:	724080e7          	jalr	1828(ra) # 80000bbe <kalloc>
    800064a2:	87aa                	mv	a5,a0
    800064a4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800064a6:	6088                	ld	a0,0(s1)
    800064a8:	cd6d                	beqz	a0,800065a2 <virtio_disk_init+0x1da>
    800064aa:	0005c717          	auipc	a4,0x5c
    800064ae:	96e73703          	ld	a4,-1682(a4) # 80061e18 <disk+0x8>
    800064b2:	cb65                	beqz	a4,800065a2 <virtio_disk_init+0x1da>
    800064b4:	c7fd                	beqz	a5,800065a2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800064b6:	6605                	lui	a2,0x1
    800064b8:	4581                	li	a1,0
    800064ba:	ffffb097          	auipc	ra,0xffffb
    800064be:	9ae080e7          	jalr	-1618(ra) # 80000e68 <memset>
  memset(disk.avail, 0, PGSIZE);
    800064c2:	0005c497          	auipc	s1,0x5c
    800064c6:	94e48493          	addi	s1,s1,-1714 # 80061e10 <disk>
    800064ca:	6605                	lui	a2,0x1
    800064cc:	4581                	li	a1,0
    800064ce:	6488                	ld	a0,8(s1)
    800064d0:	ffffb097          	auipc	ra,0xffffb
    800064d4:	998080e7          	jalr	-1640(ra) # 80000e68 <memset>
  memset(disk.used, 0, PGSIZE);
    800064d8:	6605                	lui	a2,0x1
    800064da:	4581                	li	a1,0
    800064dc:	6888                	ld	a0,16(s1)
    800064de:	ffffb097          	auipc	ra,0xffffb
    800064e2:	98a080e7          	jalr	-1654(ra) # 80000e68 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800064e6:	100017b7          	lui	a5,0x10001
    800064ea:	4721                	li	a4,8
    800064ec:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800064ee:	4098                	lw	a4,0(s1)
    800064f0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800064f4:	40d8                	lw	a4,4(s1)
    800064f6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800064fa:	6498                	ld	a4,8(s1)
    800064fc:	0007069b          	sext.w	a3,a4
    80006500:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006504:	9701                	srai	a4,a4,0x20
    80006506:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000650a:	6898                	ld	a4,16(s1)
    8000650c:	0007069b          	sext.w	a3,a4
    80006510:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006514:	9701                	srai	a4,a4,0x20
    80006516:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000651a:	4705                	li	a4,1
    8000651c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000651e:	00e48c23          	sb	a4,24(s1)
    80006522:	00e48ca3          	sb	a4,25(s1)
    80006526:	00e48d23          	sb	a4,26(s1)
    8000652a:	00e48da3          	sb	a4,27(s1)
    8000652e:	00e48e23          	sb	a4,28(s1)
    80006532:	00e48ea3          	sb	a4,29(s1)
    80006536:	00e48f23          	sb	a4,30(s1)
    8000653a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000653e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006542:	0727a823          	sw	s2,112(a5)
}
    80006546:	60e2                	ld	ra,24(sp)
    80006548:	6442                	ld	s0,16(sp)
    8000654a:	64a2                	ld	s1,8(sp)
    8000654c:	6902                	ld	s2,0(sp)
    8000654e:	6105                	addi	sp,sp,32
    80006550:	8082                	ret
    panic("could not find virtio disk");
    80006552:	00002517          	auipc	a0,0x2
    80006556:	3ce50513          	addi	a0,a0,974 # 80008920 <syscalls+0x348>
    8000655a:	ffffa097          	auipc	ra,0xffffa
    8000655e:	fe6080e7          	jalr	-26(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006562:	00002517          	auipc	a0,0x2
    80006566:	3de50513          	addi	a0,a0,990 # 80008940 <syscalls+0x368>
    8000656a:	ffffa097          	auipc	ra,0xffffa
    8000656e:	fd6080e7          	jalr	-42(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006572:	00002517          	auipc	a0,0x2
    80006576:	3ee50513          	addi	a0,a0,1006 # 80008960 <syscalls+0x388>
    8000657a:	ffffa097          	auipc	ra,0xffffa
    8000657e:	fc6080e7          	jalr	-58(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006582:	00002517          	auipc	a0,0x2
    80006586:	3fe50513          	addi	a0,a0,1022 # 80008980 <syscalls+0x3a8>
    8000658a:	ffffa097          	auipc	ra,0xffffa
    8000658e:	fb6080e7          	jalr	-74(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006592:	00002517          	auipc	a0,0x2
    80006596:	40e50513          	addi	a0,a0,1038 # 800089a0 <syscalls+0x3c8>
    8000659a:	ffffa097          	auipc	ra,0xffffa
    8000659e:	fa6080e7          	jalr	-90(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    800065a2:	00002517          	auipc	a0,0x2
    800065a6:	41e50513          	addi	a0,a0,1054 # 800089c0 <syscalls+0x3e8>
    800065aa:	ffffa097          	auipc	ra,0xffffa
    800065ae:	f96080e7          	jalr	-106(ra) # 80000540 <panic>

00000000800065b2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800065b2:	7119                	addi	sp,sp,-128
    800065b4:	fc86                	sd	ra,120(sp)
    800065b6:	f8a2                	sd	s0,112(sp)
    800065b8:	f4a6                	sd	s1,104(sp)
    800065ba:	f0ca                	sd	s2,96(sp)
    800065bc:	ecce                	sd	s3,88(sp)
    800065be:	e8d2                	sd	s4,80(sp)
    800065c0:	e4d6                	sd	s5,72(sp)
    800065c2:	e0da                	sd	s6,64(sp)
    800065c4:	fc5e                	sd	s7,56(sp)
    800065c6:	f862                	sd	s8,48(sp)
    800065c8:	f466                	sd	s9,40(sp)
    800065ca:	f06a                	sd	s10,32(sp)
    800065cc:	ec6e                	sd	s11,24(sp)
    800065ce:	0100                	addi	s0,sp,128
    800065d0:	8aaa                	mv	s5,a0
    800065d2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800065d4:	00c52d03          	lw	s10,12(a0)
    800065d8:	001d1d1b          	slliw	s10,s10,0x1
    800065dc:	1d02                	slli	s10,s10,0x20
    800065de:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800065e2:	0005c517          	auipc	a0,0x5c
    800065e6:	95650513          	addi	a0,a0,-1706 # 80061f38 <disk+0x128>
    800065ea:	ffffa097          	auipc	ra,0xffffa
    800065ee:	782080e7          	jalr	1922(ra) # 80000d6c <acquire>
  for(int i = 0; i < 3; i++){
    800065f2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800065f4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800065f6:	0005cb97          	auipc	s7,0x5c
    800065fa:	81ab8b93          	addi	s7,s7,-2022 # 80061e10 <disk>
  for(int i = 0; i < 3; i++){
    800065fe:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006600:	0005cc97          	auipc	s9,0x5c
    80006604:	938c8c93          	addi	s9,s9,-1736 # 80061f38 <disk+0x128>
    80006608:	a08d                	j	8000666a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000660a:	00fb8733          	add	a4,s7,a5
    8000660e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006612:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006614:	0207c563          	bltz	a5,8000663e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006618:	2905                	addiw	s2,s2,1
    8000661a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000661c:	05690c63          	beq	s2,s6,80006674 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006620:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006622:	0005b717          	auipc	a4,0x5b
    80006626:	7ee70713          	addi	a4,a4,2030 # 80061e10 <disk>
    8000662a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000662c:	01874683          	lbu	a3,24(a4)
    80006630:	fee9                	bnez	a3,8000660a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006632:	2785                	addiw	a5,a5,1
    80006634:	0705                	addi	a4,a4,1
    80006636:	fe979be3          	bne	a5,s1,8000662c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000663a:	57fd                	li	a5,-1
    8000663c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000663e:	01205d63          	blez	s2,80006658 <virtio_disk_rw+0xa6>
    80006642:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006644:	000a2503          	lw	a0,0(s4)
    80006648:	00000097          	auipc	ra,0x0
    8000664c:	cfe080e7          	jalr	-770(ra) # 80006346 <free_desc>
      for(int j = 0; j < i; j++)
    80006650:	2d85                	addiw	s11,s11,1
    80006652:	0a11                	addi	s4,s4,4
    80006654:	ff2d98e3          	bne	s11,s2,80006644 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006658:	85e6                	mv	a1,s9
    8000665a:	0005b517          	auipc	a0,0x5b
    8000665e:	7ce50513          	addi	a0,a0,1998 # 80061e28 <disk+0x18>
    80006662:	ffffc097          	auipc	ra,0xffffc
    80006666:	db8080e7          	jalr	-584(ra) # 8000241a <sleep>
  for(int i = 0; i < 3; i++){
    8000666a:	f8040a13          	addi	s4,s0,-128
{
    8000666e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006670:	894e                	mv	s2,s3
    80006672:	b77d                	j	80006620 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006674:	f8042503          	lw	a0,-128(s0)
    80006678:	00a50713          	addi	a4,a0,10
    8000667c:	0712                	slli	a4,a4,0x4

  if(write)
    8000667e:	0005b797          	auipc	a5,0x5b
    80006682:	79278793          	addi	a5,a5,1938 # 80061e10 <disk>
    80006686:	00e786b3          	add	a3,a5,a4
    8000668a:	01803633          	snez	a2,s8
    8000668e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006690:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006694:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006698:	f6070613          	addi	a2,a4,-160
    8000669c:	6394                	ld	a3,0(a5)
    8000669e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066a0:	00870593          	addi	a1,a4,8
    800066a4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066a6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066a8:	0007b803          	ld	a6,0(a5)
    800066ac:	9642                	add	a2,a2,a6
    800066ae:	46c1                	li	a3,16
    800066b0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066b2:	4585                	li	a1,1
    800066b4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800066b8:	f8442683          	lw	a3,-124(s0)
    800066bc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800066c0:	0692                	slli	a3,a3,0x4
    800066c2:	9836                	add	a6,a6,a3
    800066c4:	058a8613          	addi	a2,s5,88
    800066c8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800066cc:	0007b803          	ld	a6,0(a5)
    800066d0:	96c2                	add	a3,a3,a6
    800066d2:	40000613          	li	a2,1024
    800066d6:	c690                	sw	a2,8(a3)
  if(write)
    800066d8:	001c3613          	seqz	a2,s8
    800066dc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800066e0:	00166613          	ori	a2,a2,1
    800066e4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800066e8:	f8842603          	lw	a2,-120(s0)
    800066ec:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066f0:	00250693          	addi	a3,a0,2
    800066f4:	0692                	slli	a3,a3,0x4
    800066f6:	96be                	add	a3,a3,a5
    800066f8:	58fd                	li	a7,-1
    800066fa:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066fe:	0612                	slli	a2,a2,0x4
    80006700:	9832                	add	a6,a6,a2
    80006702:	f9070713          	addi	a4,a4,-112
    80006706:	973e                	add	a4,a4,a5
    80006708:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000670c:	6398                	ld	a4,0(a5)
    8000670e:	9732                	add	a4,a4,a2
    80006710:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006712:	4609                	li	a2,2
    80006714:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006718:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000671c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006720:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006724:	6794                	ld	a3,8(a5)
    80006726:	0026d703          	lhu	a4,2(a3)
    8000672a:	8b1d                	andi	a4,a4,7
    8000672c:	0706                	slli	a4,a4,0x1
    8000672e:	96ba                	add	a3,a3,a4
    80006730:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006734:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006738:	6798                	ld	a4,8(a5)
    8000673a:	00275783          	lhu	a5,2(a4)
    8000673e:	2785                	addiw	a5,a5,1
    80006740:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006744:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006748:	100017b7          	lui	a5,0x10001
    8000674c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006750:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006754:	0005b917          	auipc	s2,0x5b
    80006758:	7e490913          	addi	s2,s2,2020 # 80061f38 <disk+0x128>
  while(b->disk == 1) {
    8000675c:	4485                	li	s1,1
    8000675e:	00b79c63          	bne	a5,a1,80006776 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006762:	85ca                	mv	a1,s2
    80006764:	8556                	mv	a0,s5
    80006766:	ffffc097          	auipc	ra,0xffffc
    8000676a:	cb4080e7          	jalr	-844(ra) # 8000241a <sleep>
  while(b->disk == 1) {
    8000676e:	004aa783          	lw	a5,4(s5)
    80006772:	fe9788e3          	beq	a5,s1,80006762 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006776:	f8042903          	lw	s2,-128(s0)
    8000677a:	00290713          	addi	a4,s2,2
    8000677e:	0712                	slli	a4,a4,0x4
    80006780:	0005b797          	auipc	a5,0x5b
    80006784:	69078793          	addi	a5,a5,1680 # 80061e10 <disk>
    80006788:	97ba                	add	a5,a5,a4
    8000678a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000678e:	0005b997          	auipc	s3,0x5b
    80006792:	68298993          	addi	s3,s3,1666 # 80061e10 <disk>
    80006796:	00491713          	slli	a4,s2,0x4
    8000679a:	0009b783          	ld	a5,0(s3)
    8000679e:	97ba                	add	a5,a5,a4
    800067a0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800067a4:	854a                	mv	a0,s2
    800067a6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800067aa:	00000097          	auipc	ra,0x0
    800067ae:	b9c080e7          	jalr	-1124(ra) # 80006346 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800067b2:	8885                	andi	s1,s1,1
    800067b4:	f0ed                	bnez	s1,80006796 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800067b6:	0005b517          	auipc	a0,0x5b
    800067ba:	78250513          	addi	a0,a0,1922 # 80061f38 <disk+0x128>
    800067be:	ffffa097          	auipc	ra,0xffffa
    800067c2:	662080e7          	jalr	1634(ra) # 80000e20 <release>
}
    800067c6:	70e6                	ld	ra,120(sp)
    800067c8:	7446                	ld	s0,112(sp)
    800067ca:	74a6                	ld	s1,104(sp)
    800067cc:	7906                	ld	s2,96(sp)
    800067ce:	69e6                	ld	s3,88(sp)
    800067d0:	6a46                	ld	s4,80(sp)
    800067d2:	6aa6                	ld	s5,72(sp)
    800067d4:	6b06                	ld	s6,64(sp)
    800067d6:	7be2                	ld	s7,56(sp)
    800067d8:	7c42                	ld	s8,48(sp)
    800067da:	7ca2                	ld	s9,40(sp)
    800067dc:	7d02                	ld	s10,32(sp)
    800067de:	6de2                	ld	s11,24(sp)
    800067e0:	6109                	addi	sp,sp,128
    800067e2:	8082                	ret

00000000800067e4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067e4:	1101                	addi	sp,sp,-32
    800067e6:	ec06                	sd	ra,24(sp)
    800067e8:	e822                	sd	s0,16(sp)
    800067ea:	e426                	sd	s1,8(sp)
    800067ec:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067ee:	0005b497          	auipc	s1,0x5b
    800067f2:	62248493          	addi	s1,s1,1570 # 80061e10 <disk>
    800067f6:	0005b517          	auipc	a0,0x5b
    800067fa:	74250513          	addi	a0,a0,1858 # 80061f38 <disk+0x128>
    800067fe:	ffffa097          	auipc	ra,0xffffa
    80006802:	56e080e7          	jalr	1390(ra) # 80000d6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006806:	10001737          	lui	a4,0x10001
    8000680a:	533c                	lw	a5,96(a4)
    8000680c:	8b8d                	andi	a5,a5,3
    8000680e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006810:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006814:	689c                	ld	a5,16(s1)
    80006816:	0204d703          	lhu	a4,32(s1)
    8000681a:	0027d783          	lhu	a5,2(a5)
    8000681e:	04f70863          	beq	a4,a5,8000686e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006822:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006826:	6898                	ld	a4,16(s1)
    80006828:	0204d783          	lhu	a5,32(s1)
    8000682c:	8b9d                	andi	a5,a5,7
    8000682e:	078e                	slli	a5,a5,0x3
    80006830:	97ba                	add	a5,a5,a4
    80006832:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006834:	00278713          	addi	a4,a5,2
    80006838:	0712                	slli	a4,a4,0x4
    8000683a:	9726                	add	a4,a4,s1
    8000683c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006840:	e721                	bnez	a4,80006888 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006842:	0789                	addi	a5,a5,2
    80006844:	0792                	slli	a5,a5,0x4
    80006846:	97a6                	add	a5,a5,s1
    80006848:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000684a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000684e:	ffffc097          	auipc	ra,0xffffc
    80006852:	c30080e7          	jalr	-976(ra) # 8000247e <wakeup>

    disk.used_idx += 1;
    80006856:	0204d783          	lhu	a5,32(s1)
    8000685a:	2785                	addiw	a5,a5,1
    8000685c:	17c2                	slli	a5,a5,0x30
    8000685e:	93c1                	srli	a5,a5,0x30
    80006860:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006864:	6898                	ld	a4,16(s1)
    80006866:	00275703          	lhu	a4,2(a4)
    8000686a:	faf71ce3          	bne	a4,a5,80006822 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000686e:	0005b517          	auipc	a0,0x5b
    80006872:	6ca50513          	addi	a0,a0,1738 # 80061f38 <disk+0x128>
    80006876:	ffffa097          	auipc	ra,0xffffa
    8000687a:	5aa080e7          	jalr	1450(ra) # 80000e20 <release>
}
    8000687e:	60e2                	ld	ra,24(sp)
    80006880:	6442                	ld	s0,16(sp)
    80006882:	64a2                	ld	s1,8(sp)
    80006884:	6105                	addi	sp,sp,32
    80006886:	8082                	ret
      panic("virtio_disk_intr status");
    80006888:	00002517          	auipc	a0,0x2
    8000688c:	15050513          	addi	a0,a0,336 # 800089d8 <syscalls+0x400>
    80006890:	ffffa097          	auipc	ra,0xffffa
    80006894:	cb0080e7          	jalr	-848(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...

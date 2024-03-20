
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <testcase5>:

int global_array[16777216] = {0};
int global_var = 0;

void testcase5()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
    int pid[3];

    printf("\n----- Test case 5 -----\n");
   c:	00001517          	auipc	a0,0x1
  10:	e5450513          	addi	a0,a0,-428 # e60 <malloc+0xf4>
  14:	00001097          	auipc	ra,0x1
  18:	ca0080e7          	jalr	-864(ra) # cb4 <printf>
    printf("[prnt] v1 --> ");
  1c:	00001517          	auipc	a0,0x1
  20:	e6450513          	addi	a0,a0,-412 # e80 <malloc+0x114>
  24:	00001097          	auipc	ra,0x1
  28:	c90080e7          	jalr	-880(ra) # cb4 <printf>
    print_free_frame_cnt();
  2c:	00001097          	auipc	ra,0x1
  30:	9a6080e7          	jalr	-1626(ra) # 9d2 <pfreepages>

    for (int i = 0; i < 3; ++i)
  34:	fd040493          	addi	s1,s0,-48
  38:	fdc40913          	addi	s2,s0,-36
    {
        if ((pid[i] = fork()) == 0)
  3c:	00001097          	auipc	ra,0x1
  40:	8ce080e7          	jalr	-1842(ra) # 90a <fork>
  44:	c088                	sw	a0,0(s1)
  46:	c121                	beqz	a0,86 <testcase5+0x86>
  48:	448d                	li	s1,3
    }


    for (int i = 0; i < 3; ++i)
    {
        int _pid = wait(0);
  4a:	4501                	li	a0,0
  4c:	00001097          	auipc	ra,0x1
  50:	8ce080e7          	jalr	-1842(ra) # 91a <wait>
        for (int j = 0; j < 3; ++j)
        {
            if (pid[j] == _pid)
  54:	fd042783          	lw	a5,-48(s0)
  58:	02a78c63          	beq	a5,a0,90 <testcase5+0x90>
  5c:	fd442783          	lw	a5,-44(s0)
  60:	02a78863          	beq	a5,a0,90 <testcase5+0x90>
  64:	fd842783          	lw	a5,-40(s0)
  68:	02a78463          	beq	a5,a0,90 <testcase5+0x90>
            {
                break;
            }
            if (j == 2)
            {
                printf("wait() error!");
  6c:	00001517          	auipc	a0,0x1
  70:	e2450513          	addi	a0,a0,-476 # e90 <malloc+0x124>
  74:	00001097          	auipc	ra,0x1
  78:	c40080e7          	jalr	-960(ra) # cb4 <printf>
                exit(1);
  7c:	4505                	li	a0,1
  7e:	00001097          	auipc	ra,0x1
  82:	894080e7          	jalr	-1900(ra) # 912 <exit>
    for (int i = 0; i < 3; ++i)
  86:	0491                	addi	s1,s1,4
  88:	fa991ae3          	bne	s2,s1,3c <testcase5+0x3c>
  8c:	448d                	li	s1,3
  8e:	bf75                	j	4a <testcase5+0x4a>
    for (int i = 0; i < 3; ++i)
  90:	34fd                	addiw	s1,s1,-1
  92:	fcc5                	bnez	s1,4a <testcase5+0x4a>
            }
        }
    }

    printf("[prnt] v7 --> ");
  94:	00001517          	auipc	a0,0x1
  98:	e0c50513          	addi	a0,a0,-500 # ea0 <malloc+0x134>
  9c:	00001097          	auipc	ra,0x1
  a0:	c18080e7          	jalr	-1000(ra) # cb4 <printf>
    print_free_frame_cnt();
  a4:	00001097          	auipc	ra,0x1
  a8:	92e080e7          	jalr	-1746(ra) # 9d2 <pfreepages>
}
  ac:	70a2                	ld	ra,40(sp)
  ae:	7402                	ld	s0,32(sp)
  b0:	64e2                	ld	s1,24(sp)
  b2:	6942                	ld	s2,16(sp)
  b4:	6145                	addi	sp,sp,48
  b6:	8082                	ret

00000000000000b8 <testcase4>:

void testcase4()
{
  b8:	1101                	addi	sp,sp,-32
  ba:	ec06                	sd	ra,24(sp)
  bc:	e822                	sd	s0,16(sp)
  be:	e426                	sd	s1,8(sp)
  c0:	e04a                	sd	s2,0(sp)
  c2:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 4 -----\n");
  c4:	00001517          	auipc	a0,0x1
  c8:	dec50513          	addi	a0,a0,-532 # eb0 <malloc+0x144>
  cc:	00001097          	auipc	ra,0x1
  d0:	be8080e7          	jalr	-1048(ra) # cb4 <printf>
    printf("[prnt] v1 --> ");
  d4:	00001517          	auipc	a0,0x1
  d8:	dac50513          	addi	a0,a0,-596 # e80 <malloc+0x114>
  dc:	00001097          	auipc	ra,0x1
  e0:	bd8080e7          	jalr	-1064(ra) # cb4 <printf>
    print_free_frame_cnt();
  e4:	00001097          	auipc	ra,0x1
  e8:	8ee080e7          	jalr	-1810(ra) # 9d2 <pfreepages>

    if ((pid = fork()) == 0)
  ec:	00001097          	auipc	ra,0x1
  f0:	81e080e7          	jalr	-2018(ra) # 90a <fork>
  f4:	c971                	beqz	a0,1c8 <testcase4+0x110>
  f6:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
  f8:	00001517          	auipc	a0,0x1
  fc:	ef850513          	addi	a0,a0,-264 # ff0 <malloc+0x284>
 100:	00001097          	auipc	ra,0x1
 104:	bb4080e7          	jalr	-1100(ra) # cb4 <printf>
        print_free_frame_cnt();
 108:	00001097          	auipc	ra,0x1
 10c:	8ca080e7          	jalr	-1846(ra) # 9d2 <pfreepages>

        global_array[0] = 111;
 110:	00002917          	auipc	s2,0x2
 114:	f0090913          	addi	s2,s2,-256 # 2010 <global_array>
 118:	06f00793          	li	a5,111
 11c:	00f92023          	sw	a5,0(s2)
        printf("[prnt] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 120:	06f00593          	li	a1,111
 124:	00001517          	auipc	a0,0x1
 128:	edc50513          	addi	a0,a0,-292 # 1000 <malloc+0x294>
 12c:	00001097          	auipc	ra,0x1
 130:	b88080e7          	jalr	-1144(ra) # cb4 <printf>

        printf("[prnt] v3 --> ");
 134:	00001517          	auipc	a0,0x1
 138:	f1450513          	addi	a0,a0,-236 # 1048 <malloc+0x2dc>
 13c:	00001097          	auipc	ra,0x1
 140:	b78080e7          	jalr	-1160(ra) # cb4 <printf>
        print_free_frame_cnt();
 144:	00001097          	auipc	ra,0x1
 148:	88e080e7          	jalr	-1906(ra) # 9d2 <pfreepages>
        printf("asking parent %d\n", pid);
 14c:	85a6                	mv	a1,s1
 14e:	00001517          	auipc	a0,0x1
 152:	f0a50513          	addi	a0,a0,-246 # 1058 <malloc+0x2ec>
 156:	00001097          	auipc	ra,0x1
 15a:	b5e080e7          	jalr	-1186(ra) # cb4 <printf>
        printf("[prnt] pa3 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 15e:	4581                	li	a1,0
 160:	0009051b          	sext.w	a0,s2
 164:	00001097          	auipc	ra,0x1
 168:	866080e7          	jalr	-1946(ra) # 9ca <va2pa>
 16c:	85aa                	mv	a1,a0
 16e:	00001517          	auipc	a0,0x1
 172:	f0250513          	addi	a0,a0,-254 # 1070 <malloc+0x304>
 176:	00001097          	auipc	ra,0x1
 17a:	b3e080e7          	jalr	-1218(ra) # cb4 <printf>
    }

    if (wait(0) != pid)
 17e:	4501                	li	a0,0
 180:	00000097          	auipc	ra,0x0
 184:	79a080e7          	jalr	1946(ra) # 91a <wait>
 188:	14951b63          	bne	a0,s1,2de <testcase4+0x226>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] global_array[0] --> %d\n", global_array[0]);
 18c:	00002597          	auipc	a1,0x2
 190:	e845a583          	lw	a1,-380(a1) # 2010 <global_array>
 194:	00001517          	auipc	a0,0x1
 198:	ef450513          	addi	a0,a0,-268 # 1088 <malloc+0x31c>
 19c:	00001097          	auipc	ra,0x1
 1a0:	b18080e7          	jalr	-1256(ra) # cb4 <printf>

    printf("[prnt] v7 --> ");
 1a4:	00001517          	auipc	a0,0x1
 1a8:	cfc50513          	addi	a0,a0,-772 # ea0 <malloc+0x134>
 1ac:	00001097          	auipc	ra,0x1
 1b0:	b08080e7          	jalr	-1272(ra) # cb4 <printf>
    print_free_frame_cnt();
 1b4:	00001097          	auipc	ra,0x1
 1b8:	81e080e7          	jalr	-2018(ra) # 9d2 <pfreepages>
}
 1bc:	60e2                	ld	ra,24(sp)
 1be:	6442                	ld	s0,16(sp)
 1c0:	64a2                	ld	s1,8(sp)
 1c2:	6902                	ld	s2,0(sp)
 1c4:	6105                	addi	sp,sp,32
 1c6:	8082                	ret
        sleep(50);
 1c8:	03200513          	li	a0,50
 1cc:	00000097          	auipc	ra,0x0
 1d0:	7d6080e7          	jalr	2006(ra) # 9a2 <sleep>
        printf("asking %d\n", pid);
 1d4:	4581                	li	a1,0
 1d6:	00001517          	auipc	a0,0x1
 1da:	cfa50513          	addi	a0,a0,-774 # ed0 <malloc+0x164>
 1de:	00001097          	auipc	ra,0x1
 1e2:	ad6080e7          	jalr	-1322(ra) # cb4 <printf>
        printf("[chld] pa1 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 1e6:	00002497          	auipc	s1,0x2
 1ea:	e2a48493          	addi	s1,s1,-470 # 2010 <global_array>
 1ee:	0004891b          	sext.w	s2,s1
 1f2:	4581                	li	a1,0
 1f4:	854a                	mv	a0,s2
 1f6:	00000097          	auipc	ra,0x0
 1fa:	7d4080e7          	jalr	2004(ra) # 9ca <va2pa>
 1fe:	85aa                	mv	a1,a0
 200:	00001517          	auipc	a0,0x1
 204:	ce050513          	addi	a0,a0,-800 # ee0 <malloc+0x174>
 208:	00001097          	auipc	ra,0x1
 20c:	aac080e7          	jalr	-1364(ra) # cb4 <printf>
        printf("[chld] v4 --> ");
 210:	00001517          	auipc	a0,0x1
 214:	ce850513          	addi	a0,a0,-792 # ef8 <malloc+0x18c>
 218:	00001097          	auipc	ra,0x1
 21c:	a9c080e7          	jalr	-1380(ra) # cb4 <printf>
        print_free_frame_cnt();
 220:	00000097          	auipc	ra,0x0
 224:	7b2080e7          	jalr	1970(ra) # 9d2 <pfreepages>
        global_array[0] = 222;
 228:	0de00793          	li	a5,222
 22c:	c09c                	sw	a5,0(s1)
        printf("[chld] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 22e:	0de00593          	li	a1,222
 232:	00001517          	auipc	a0,0x1
 236:	cd650513          	addi	a0,a0,-810 # f08 <malloc+0x19c>
 23a:	00001097          	auipc	ra,0x1
 23e:	a7a080e7          	jalr	-1414(ra) # cb4 <printf>
        printf("asking %d\n", pid);
 242:	4581                	li	a1,0
 244:	00001517          	auipc	a0,0x1
 248:	c8c50513          	addi	a0,a0,-884 # ed0 <malloc+0x164>
 24c:	00001097          	auipc	ra,0x1
 250:	a68080e7          	jalr	-1432(ra) # cb4 <printf>
        printf("[chld] pa2 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 254:	4581                	li	a1,0
 256:	854a                	mv	a0,s2
 258:	00000097          	auipc	ra,0x0
 25c:	772080e7          	jalr	1906(ra) # 9ca <va2pa>
 260:	85aa                	mv	a1,a0
 262:	00001517          	auipc	a0,0x1
 266:	cee50513          	addi	a0,a0,-786 # f50 <malloc+0x1e4>
 26a:	00001097          	auipc	ra,0x1
 26e:	a4a080e7          	jalr	-1462(ra) # cb4 <printf>
        printf("[chld] v5 --> ");
 272:	00001517          	auipc	a0,0x1
 276:	cf650513          	addi	a0,a0,-778 # f68 <malloc+0x1fc>
 27a:	00001097          	auipc	ra,0x1
 27e:	a3a080e7          	jalr	-1478(ra) # cb4 <printf>
        print_free_frame_cnt();
 282:	00000097          	auipc	ra,0x0
 286:	750080e7          	jalr	1872(ra) # 9d2 <pfreepages>
        global_array[2047] = 333;
 28a:	14d00793          	li	a5,333
 28e:	00004717          	auipc	a4,0x4
 292:	d6f72f23          	sw	a5,-642(a4) # 400c <global_array+0x1ffc>
        printf("[chld] modified two elements in the 2nd page, global_array[2047]=%d\n", global_array[2047]);
 296:	14d00593          	li	a1,333
 29a:	00001517          	auipc	a0,0x1
 29e:	cde50513          	addi	a0,a0,-802 # f78 <malloc+0x20c>
 2a2:	00001097          	auipc	ra,0x1
 2a6:	a12080e7          	jalr	-1518(ra) # cb4 <printf>
        printf("[chld] v6 --> ");
 2aa:	00001517          	auipc	a0,0x1
 2ae:	d1650513          	addi	a0,a0,-746 # fc0 <malloc+0x254>
 2b2:	00001097          	auipc	ra,0x1
 2b6:	a02080e7          	jalr	-1534(ra) # cb4 <printf>
        print_free_frame_cnt();
 2ba:	00000097          	auipc	ra,0x0
 2be:	718080e7          	jalr	1816(ra) # 9d2 <pfreepages>
        printf("[chld] global_array[0] --> %d\n", global_array[0]);
 2c2:	408c                	lw	a1,0(s1)
 2c4:	00001517          	auipc	a0,0x1
 2c8:	d0c50513          	addi	a0,a0,-756 # fd0 <malloc+0x264>
 2cc:	00001097          	auipc	ra,0x1
 2d0:	9e8080e7          	jalr	-1560(ra) # cb4 <printf>
        exit(0);
 2d4:	4501                	li	a0,0
 2d6:	00000097          	auipc	ra,0x0
 2da:	63c080e7          	jalr	1596(ra) # 912 <exit>
        printf("wait() error!");
 2de:	00001517          	auipc	a0,0x1
 2e2:	bb250513          	addi	a0,a0,-1102 # e90 <malloc+0x124>
 2e6:	00001097          	auipc	ra,0x1
 2ea:	9ce080e7          	jalr	-1586(ra) # cb4 <printf>
        exit(1);
 2ee:	4505                	li	a0,1
 2f0:	00000097          	auipc	ra,0x0
 2f4:	622080e7          	jalr	1570(ra) # 912 <exit>

00000000000002f8 <testcase3>:

void testcase3()
{
 2f8:	1101                	addi	sp,sp,-32
 2fa:	ec06                	sd	ra,24(sp)
 2fc:	e822                	sd	s0,16(sp)
 2fe:	e426                	sd	s1,8(sp)
 300:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 3 -----\n");
 302:	00001517          	auipc	a0,0x1
 306:	da650513          	addi	a0,a0,-602 # 10a8 <malloc+0x33c>
 30a:	00001097          	auipc	ra,0x1
 30e:	9aa080e7          	jalr	-1622(ra) # cb4 <printf>
    printf("[prnt] v1 --> ");
 312:	00001517          	auipc	a0,0x1
 316:	b6e50513          	addi	a0,a0,-1170 # e80 <malloc+0x114>
 31a:	00001097          	auipc	ra,0x1
 31e:	99a080e7          	jalr	-1638(ra) # cb4 <printf>
    print_free_frame_cnt();
 322:	00000097          	auipc	ra,0x0
 326:	6b0080e7          	jalr	1712(ra) # 9d2 <pfreepages>

    if ((pid = fork()) == 0)
 32a:	00000097          	auipc	ra,0x0
 32e:	5e0080e7          	jalr	1504(ra) # 90a <fork>
 332:	cd35                	beqz	a0,3ae <testcase3+0xb6>
 334:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 336:	00001517          	auipc	a0,0x1
 33a:	cba50513          	addi	a0,a0,-838 # ff0 <malloc+0x284>
 33e:	00001097          	auipc	ra,0x1
 342:	976080e7          	jalr	-1674(ra) # cb4 <printf>
        print_free_frame_cnt();
 346:	00000097          	auipc	ra,0x0
 34a:	68c080e7          	jalr	1676(ra) # 9d2 <pfreepages>

        printf("[prnt] read global_var, global_var=%d\n", global_var);
 34e:	00002597          	auipc	a1,0x2
 352:	cb25a583          	lw	a1,-846(a1) # 2000 <global_var>
 356:	00001517          	auipc	a0,0x1
 35a:	da250513          	addi	a0,a0,-606 # 10f8 <malloc+0x38c>
 35e:	00001097          	auipc	ra,0x1
 362:	956080e7          	jalr	-1706(ra) # cb4 <printf>

        printf("[prnt] v3 --> ");
 366:	00001517          	auipc	a0,0x1
 36a:	ce250513          	addi	a0,a0,-798 # 1048 <malloc+0x2dc>
 36e:	00001097          	auipc	ra,0x1
 372:	946080e7          	jalr	-1722(ra) # cb4 <printf>
        print_free_frame_cnt();
 376:	00000097          	auipc	ra,0x0
 37a:	65c080e7          	jalr	1628(ra) # 9d2 <pfreepages>
    }

    if (wait(0) != pid)
 37e:	4501                	li	a0,0
 380:	00000097          	auipc	ra,0x0
 384:	59a080e7          	jalr	1434(ra) # 91a <wait>
 388:	08951563          	bne	a0,s1,412 <testcase3+0x11a>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v6 --> ");
 38c:	00001517          	auipc	a0,0x1
 390:	d9450513          	addi	a0,a0,-620 # 1120 <malloc+0x3b4>
 394:	00001097          	auipc	ra,0x1
 398:	920080e7          	jalr	-1760(ra) # cb4 <printf>
    print_free_frame_cnt();
 39c:	00000097          	auipc	ra,0x0
 3a0:	636080e7          	jalr	1590(ra) # 9d2 <pfreepages>
}
 3a4:	60e2                	ld	ra,24(sp)
 3a6:	6442                	ld	s0,16(sp)
 3a8:	64a2                	ld	s1,8(sp)
 3aa:	6105                	addi	sp,sp,32
 3ac:	8082                	ret
        sleep(10);
 3ae:	4529                	li	a0,10
 3b0:	00000097          	auipc	ra,0x0
 3b4:	5f2080e7          	jalr	1522(ra) # 9a2 <sleep>
        printf("[chld] v4 --> ");
 3b8:	00001517          	auipc	a0,0x1
 3bc:	b4050513          	addi	a0,a0,-1216 # ef8 <malloc+0x18c>
 3c0:	00001097          	auipc	ra,0x1
 3c4:	8f4080e7          	jalr	-1804(ra) # cb4 <printf>
        print_free_frame_cnt();
 3c8:	00000097          	auipc	ra,0x0
 3cc:	60a080e7          	jalr	1546(ra) # 9d2 <pfreepages>
        global_var = 100;
 3d0:	06400793          	li	a5,100
 3d4:	00002717          	auipc	a4,0x2
 3d8:	c2f72623          	sw	a5,-980(a4) # 2000 <global_var>
        printf("[chld] modified global_var, global_var=%d\n", global_var);
 3dc:	06400593          	li	a1,100
 3e0:	00001517          	auipc	a0,0x1
 3e4:	ce850513          	addi	a0,a0,-792 # 10c8 <malloc+0x35c>
 3e8:	00001097          	auipc	ra,0x1
 3ec:	8cc080e7          	jalr	-1844(ra) # cb4 <printf>
        printf("[chld] v5 --> ");
 3f0:	00001517          	auipc	a0,0x1
 3f4:	b7850513          	addi	a0,a0,-1160 # f68 <malloc+0x1fc>
 3f8:	00001097          	auipc	ra,0x1
 3fc:	8bc080e7          	jalr	-1860(ra) # cb4 <printf>
        print_free_frame_cnt();
 400:	00000097          	auipc	ra,0x0
 404:	5d2080e7          	jalr	1490(ra) # 9d2 <pfreepages>
        exit(0);
 408:	4501                	li	a0,0
 40a:	00000097          	auipc	ra,0x0
 40e:	508080e7          	jalr	1288(ra) # 912 <exit>
        printf("wait() error!");
 412:	00001517          	auipc	a0,0x1
 416:	a7e50513          	addi	a0,a0,-1410 # e90 <malloc+0x124>
 41a:	00001097          	auipc	ra,0x1
 41e:	89a080e7          	jalr	-1894(ra) # cb4 <printf>
        exit(1);
 422:	4505                	li	a0,1
 424:	00000097          	auipc	ra,0x0
 428:	4ee080e7          	jalr	1262(ra) # 912 <exit>

000000000000042c <testcase2>:

void testcase2()
{
 42c:	1101                	addi	sp,sp,-32
 42e:	ec06                	sd	ra,24(sp)
 430:	e822                	sd	s0,16(sp)
 432:	e426                	sd	s1,8(sp)
 434:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 2 -----\n");
 436:	00001517          	auipc	a0,0x1
 43a:	cfa50513          	addi	a0,a0,-774 # 1130 <malloc+0x3c4>
 43e:	00001097          	auipc	ra,0x1
 442:	876080e7          	jalr	-1930(ra) # cb4 <printf>
    printf("[prnt] v1 --> ");
 446:	00001517          	auipc	a0,0x1
 44a:	a3a50513          	addi	a0,a0,-1478 # e80 <malloc+0x114>
 44e:	00001097          	auipc	ra,0x1
 452:	866080e7          	jalr	-1946(ra) # cb4 <printf>
    print_free_frame_cnt();
 456:	00000097          	auipc	ra,0x0
 45a:	57c080e7          	jalr	1404(ra) # 9d2 <pfreepages>

    if ((pid = fork()) == 0)
 45e:	00000097          	auipc	ra,0x0
 462:	4ac080e7          	jalr	1196(ra) # 90a <fork>
 466:	c531                	beqz	a0,4b2 <testcase2+0x86>
 468:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 46a:	00001517          	auipc	a0,0x1
 46e:	b8650513          	addi	a0,a0,-1146 # ff0 <malloc+0x284>
 472:	00001097          	auipc	ra,0x1
 476:	842080e7          	jalr	-1982(ra) # cb4 <printf>
        print_free_frame_cnt();
 47a:	00000097          	auipc	ra,0x0
 47e:	558080e7          	jalr	1368(ra) # 9d2 <pfreepages>
    }

    if (wait(0) != pid)
 482:	4501                	li	a0,0
 484:	00000097          	auipc	ra,0x0
 488:	496080e7          	jalr	1174(ra) # 91a <wait>
 48c:	08951163          	bne	a0,s1,50e <testcase2+0xe2>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v5 --> ");
 490:	00001517          	auipc	a0,0x1
 494:	cf850513          	addi	a0,a0,-776 # 1188 <malloc+0x41c>
 498:	00001097          	auipc	ra,0x1
 49c:	81c080e7          	jalr	-2020(ra) # cb4 <printf>
    print_free_frame_cnt();
 4a0:	00000097          	auipc	ra,0x0
 4a4:	532080e7          	jalr	1330(ra) # 9d2 <pfreepages>
}
 4a8:	60e2                	ld	ra,24(sp)
 4aa:	6442                	ld	s0,16(sp)
 4ac:	64a2                	ld	s1,8(sp)
 4ae:	6105                	addi	sp,sp,32
 4b0:	8082                	ret
        sleep(10);
 4b2:	4529                	li	a0,10
 4b4:	00000097          	auipc	ra,0x0
 4b8:	4ee080e7          	jalr	1262(ra) # 9a2 <sleep>
        printf("[chld] v3 --> ");
 4bc:	00001517          	auipc	a0,0x1
 4c0:	c9450513          	addi	a0,a0,-876 # 1150 <malloc+0x3e4>
 4c4:	00000097          	auipc	ra,0x0
 4c8:	7f0080e7          	jalr	2032(ra) # cb4 <printf>
        print_free_frame_cnt();
 4cc:	00000097          	auipc	ra,0x0
 4d0:	506080e7          	jalr	1286(ra) # 9d2 <pfreepages>
        printf("[chld] read global_var, global_var=%d\n", global_var);
 4d4:	00002597          	auipc	a1,0x2
 4d8:	b2c5a583          	lw	a1,-1236(a1) # 2000 <global_var>
 4dc:	00001517          	auipc	a0,0x1
 4e0:	c8450513          	addi	a0,a0,-892 # 1160 <malloc+0x3f4>
 4e4:	00000097          	auipc	ra,0x0
 4e8:	7d0080e7          	jalr	2000(ra) # cb4 <printf>
        printf("[chld] v4 --> ");
 4ec:	00001517          	auipc	a0,0x1
 4f0:	a0c50513          	addi	a0,a0,-1524 # ef8 <malloc+0x18c>
 4f4:	00000097          	auipc	ra,0x0
 4f8:	7c0080e7          	jalr	1984(ra) # cb4 <printf>
        print_free_frame_cnt();
 4fc:	00000097          	auipc	ra,0x0
 500:	4d6080e7          	jalr	1238(ra) # 9d2 <pfreepages>
        exit(0);
 504:	4501                	li	a0,0
 506:	00000097          	auipc	ra,0x0
 50a:	40c080e7          	jalr	1036(ra) # 912 <exit>
        printf("wait() error!");
 50e:	00001517          	auipc	a0,0x1
 512:	98250513          	addi	a0,a0,-1662 # e90 <malloc+0x124>
 516:	00000097          	auipc	ra,0x0
 51a:	79e080e7          	jalr	1950(ra) # cb4 <printf>
        exit(1);
 51e:	4505                	li	a0,1
 520:	00000097          	auipc	ra,0x0
 524:	3f2080e7          	jalr	1010(ra) # 912 <exit>

0000000000000528 <testcase1>:

void testcase1()
{
 528:	1101                	addi	sp,sp,-32
 52a:	ec06                	sd	ra,24(sp)
 52c:	e822                	sd	s0,16(sp)
 52e:	e426                	sd	s1,8(sp)
 530:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 1 -----\n");
 532:	00001517          	auipc	a0,0x1
 536:	c6650513          	addi	a0,a0,-922 # 1198 <malloc+0x42c>
 53a:	00000097          	auipc	ra,0x0
 53e:	77a080e7          	jalr	1914(ra) # cb4 <printf>
    printf("[prnt] v1 --> ");
 542:	00001517          	auipc	a0,0x1
 546:	93e50513          	addi	a0,a0,-1730 # e80 <malloc+0x114>
 54a:	00000097          	auipc	ra,0x0
 54e:	76a080e7          	jalr	1898(ra) # cb4 <printf>
    print_free_frame_cnt();
 552:	00000097          	auipc	ra,0x0
 556:	480080e7          	jalr	1152(ra) # 9d2 <pfreepages>

    if ((pid = fork()) == 0)
 55a:	00000097          	auipc	ra,0x0
 55e:	3b0080e7          	jalr	944(ra) # 90a <fork>
 562:	c531                	beqz	a0,5ae <testcase1+0x86>
 564:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v3 --> ");
 566:	00001517          	auipc	a0,0x1
 56a:	ae250513          	addi	a0,a0,-1310 # 1048 <malloc+0x2dc>
 56e:	00000097          	auipc	ra,0x0
 572:	746080e7          	jalr	1862(ra) # cb4 <printf>
        print_free_frame_cnt();
 576:	00000097          	auipc	ra,0x0
 57a:	45c080e7          	jalr	1116(ra) # 9d2 <pfreepages>
    }

    if (wait(0) != pid)
 57e:	4501                	li	a0,0
 580:	00000097          	auipc	ra,0x0
 584:	39a080e7          	jalr	922(ra) # 91a <wait>
 588:	04951963          	bne	a0,s1,5da <testcase1+0xb2>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v4 --> ");
 58c:	00001517          	auipc	a0,0x1
 590:	c3c50513          	addi	a0,a0,-964 # 11c8 <malloc+0x45c>
 594:	00000097          	auipc	ra,0x0
 598:	720080e7          	jalr	1824(ra) # cb4 <printf>
    print_free_frame_cnt();
 59c:	00000097          	auipc	ra,0x0
 5a0:	436080e7          	jalr	1078(ra) # 9d2 <pfreepages>
}
 5a4:	60e2                	ld	ra,24(sp)
 5a6:	6442                	ld	s0,16(sp)
 5a8:	64a2                	ld	s1,8(sp)
 5aa:	6105                	addi	sp,sp,32
 5ac:	8082                	ret
        sleep(10);
 5ae:	4529                	li	a0,10
 5b0:	00000097          	auipc	ra,0x0
 5b4:	3f2080e7          	jalr	1010(ra) # 9a2 <sleep>
        printf("[chld] v2 --> ");
 5b8:	00001517          	auipc	a0,0x1
 5bc:	c0050513          	addi	a0,a0,-1024 # 11b8 <malloc+0x44c>
 5c0:	00000097          	auipc	ra,0x0
 5c4:	6f4080e7          	jalr	1780(ra) # cb4 <printf>
        print_free_frame_cnt();
 5c8:	00000097          	auipc	ra,0x0
 5cc:	40a080e7          	jalr	1034(ra) # 9d2 <pfreepages>
        exit(0);
 5d0:	4501                	li	a0,0
 5d2:	00000097          	auipc	ra,0x0
 5d6:	340080e7          	jalr	832(ra) # 912 <exit>
        printf("wait() error!");
 5da:	00001517          	auipc	a0,0x1
 5de:	8b650513          	addi	a0,a0,-1866 # e90 <malloc+0x124>
 5e2:	00000097          	auipc	ra,0x0
 5e6:	6d2080e7          	jalr	1746(ra) # cb4 <printf>
        exit(1);
 5ea:	4505                	li	a0,1
 5ec:	00000097          	auipc	ra,0x0
 5f0:	326080e7          	jalr	806(ra) # 912 <exit>

00000000000005f4 <main>:

int main(int argc, char *argv[])
{
 5f4:	1101                	addi	sp,sp,-32
 5f6:	ec06                	sd	ra,24(sp)
 5f8:	e822                	sd	s0,16(sp)
 5fa:	e426                	sd	s1,8(sp)
 5fc:	1000                	addi	s0,sp,32
 5fe:	84ae                	mv	s1,a1
    if (argc < 2)
 600:	4785                	li	a5,1
 602:	02a7d863          	bge	a5,a0,632 <main+0x3e>
    {
        printf("Usage: cowtest test_id");
    }
    switch (atoi(argv[1]))
 606:	6488                	ld	a0,8(s1)
 608:	00000097          	auipc	ra,0x0
 60c:	210080e7          	jalr	528(ra) # 818 <atoi>
 610:	478d                	li	a5,3
 612:	04f50c63          	beq	a0,a5,66a <main+0x76>
 616:	02a7c763          	blt	a5,a0,644 <main+0x50>
 61a:	4785                	li	a5,1
 61c:	02f50d63          	beq	a0,a5,656 <main+0x62>
 620:	4789                	li	a5,2
 622:	04f51a63          	bne	a0,a5,676 <main+0x82>
    case 1:
        testcase1();
        break;

    case 2:
        testcase2();
 626:	00000097          	auipc	ra,0x0
 62a:	e06080e7          	jalr	-506(ra) # 42c <testcase2>

    default:
        printf("Error: No test with index %s", argv[1]);
        return 1;
    }
    return 0;
 62e:	4501                	li	a0,0
        break;
 630:	a805                	j	660 <main+0x6c>
        printf("Usage: cowtest test_id");
 632:	00001517          	auipc	a0,0x1
 636:	ba650513          	addi	a0,a0,-1114 # 11d8 <malloc+0x46c>
 63a:	00000097          	auipc	ra,0x0
 63e:	67a080e7          	jalr	1658(ra) # cb4 <printf>
 642:	b7d1                	j	606 <main+0x12>
    switch (atoi(argv[1]))
 644:	4791                	li	a5,4
 646:	02f51863          	bne	a0,a5,676 <main+0x82>
        testcase4();
 64a:	00000097          	auipc	ra,0x0
 64e:	a6e080e7          	jalr	-1426(ra) # b8 <testcase4>
    return 0;
 652:	4501                	li	a0,0
        break;
 654:	a031                	j	660 <main+0x6c>
        testcase1();
 656:	00000097          	auipc	ra,0x0
 65a:	ed2080e7          	jalr	-302(ra) # 528 <testcase1>
    return 0;
 65e:	4501                	li	a0,0
 660:	60e2                	ld	ra,24(sp)
 662:	6442                	ld	s0,16(sp)
 664:	64a2                	ld	s1,8(sp)
 666:	6105                	addi	sp,sp,32
 668:	8082                	ret
        testcase3();
 66a:	00000097          	auipc	ra,0x0
 66e:	c8e080e7          	jalr	-882(ra) # 2f8 <testcase3>
    return 0;
 672:	4501                	li	a0,0
        break;
 674:	b7f5                	j	660 <main+0x6c>
        printf("Error: No test with index %s", argv[1]);
 676:	648c                	ld	a1,8(s1)
 678:	00001517          	auipc	a0,0x1
 67c:	b7850513          	addi	a0,a0,-1160 # 11f0 <malloc+0x484>
 680:	00000097          	auipc	ra,0x0
 684:	634080e7          	jalr	1588(ra) # cb4 <printf>
        return 1;
 688:	4505                	li	a0,1
 68a:	bfd9                	j	660 <main+0x6c>

000000000000068c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 68c:	1141                	addi	sp,sp,-16
 68e:	e406                	sd	ra,8(sp)
 690:	e022                	sd	s0,0(sp)
 692:	0800                	addi	s0,sp,16
  extern int main();
  main();
 694:	00000097          	auipc	ra,0x0
 698:	f60080e7          	jalr	-160(ra) # 5f4 <main>
  exit(0);
 69c:	4501                	li	a0,0
 69e:	00000097          	auipc	ra,0x0
 6a2:	274080e7          	jalr	628(ra) # 912 <exit>

00000000000006a6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 6a6:	1141                	addi	sp,sp,-16
 6a8:	e422                	sd	s0,8(sp)
 6aa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 6ac:	87aa                	mv	a5,a0
 6ae:	0585                	addi	a1,a1,1
 6b0:	0785                	addi	a5,a5,1
 6b2:	fff5c703          	lbu	a4,-1(a1)
 6b6:	fee78fa3          	sb	a4,-1(a5)
 6ba:	fb75                	bnez	a4,6ae <strcpy+0x8>
    ;
  return os;
}
 6bc:	6422                	ld	s0,8(sp)
 6be:	0141                	addi	sp,sp,16
 6c0:	8082                	ret

00000000000006c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6c2:	1141                	addi	sp,sp,-16
 6c4:	e422                	sd	s0,8(sp)
 6c6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 6c8:	00054783          	lbu	a5,0(a0)
 6cc:	cb91                	beqz	a5,6e0 <strcmp+0x1e>
 6ce:	0005c703          	lbu	a4,0(a1)
 6d2:	00f71763          	bne	a4,a5,6e0 <strcmp+0x1e>
    p++, q++;
 6d6:	0505                	addi	a0,a0,1
 6d8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 6da:	00054783          	lbu	a5,0(a0)
 6de:	fbe5                	bnez	a5,6ce <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 6e0:	0005c503          	lbu	a0,0(a1)
}
 6e4:	40a7853b          	subw	a0,a5,a0
 6e8:	6422                	ld	s0,8(sp)
 6ea:	0141                	addi	sp,sp,16
 6ec:	8082                	ret

00000000000006ee <strlen>:

uint
strlen(const char *s)
{
 6ee:	1141                	addi	sp,sp,-16
 6f0:	e422                	sd	s0,8(sp)
 6f2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 6f4:	00054783          	lbu	a5,0(a0)
 6f8:	cf91                	beqz	a5,714 <strlen+0x26>
 6fa:	0505                	addi	a0,a0,1
 6fc:	87aa                	mv	a5,a0
 6fe:	4685                	li	a3,1
 700:	9e89                	subw	a3,a3,a0
 702:	00f6853b          	addw	a0,a3,a5
 706:	0785                	addi	a5,a5,1
 708:	fff7c703          	lbu	a4,-1(a5)
 70c:	fb7d                	bnez	a4,702 <strlen+0x14>
    ;
  return n;
}
 70e:	6422                	ld	s0,8(sp)
 710:	0141                	addi	sp,sp,16
 712:	8082                	ret
  for(n = 0; s[n]; n++)
 714:	4501                	li	a0,0
 716:	bfe5                	j	70e <strlen+0x20>

0000000000000718 <memset>:

void*
memset(void *dst, int c, uint n)
{
 718:	1141                	addi	sp,sp,-16
 71a:	e422                	sd	s0,8(sp)
 71c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 71e:	ca19                	beqz	a2,734 <memset+0x1c>
 720:	87aa                	mv	a5,a0
 722:	1602                	slli	a2,a2,0x20
 724:	9201                	srli	a2,a2,0x20
 726:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 72a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 72e:	0785                	addi	a5,a5,1
 730:	fee79de3          	bne	a5,a4,72a <memset+0x12>
  }
  return dst;
}
 734:	6422                	ld	s0,8(sp)
 736:	0141                	addi	sp,sp,16
 738:	8082                	ret

000000000000073a <strchr>:

char*
strchr(const char *s, char c)
{
 73a:	1141                	addi	sp,sp,-16
 73c:	e422                	sd	s0,8(sp)
 73e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 740:	00054783          	lbu	a5,0(a0)
 744:	cb99                	beqz	a5,75a <strchr+0x20>
    if(*s == c)
 746:	00f58763          	beq	a1,a5,754 <strchr+0x1a>
  for(; *s; s++)
 74a:	0505                	addi	a0,a0,1
 74c:	00054783          	lbu	a5,0(a0)
 750:	fbfd                	bnez	a5,746 <strchr+0xc>
      return (char*)s;
  return 0;
 752:	4501                	li	a0,0
}
 754:	6422                	ld	s0,8(sp)
 756:	0141                	addi	sp,sp,16
 758:	8082                	ret
  return 0;
 75a:	4501                	li	a0,0
 75c:	bfe5                	j	754 <strchr+0x1a>

000000000000075e <gets>:

char*
gets(char *buf, int max)
{
 75e:	711d                	addi	sp,sp,-96
 760:	ec86                	sd	ra,88(sp)
 762:	e8a2                	sd	s0,80(sp)
 764:	e4a6                	sd	s1,72(sp)
 766:	e0ca                	sd	s2,64(sp)
 768:	fc4e                	sd	s3,56(sp)
 76a:	f852                	sd	s4,48(sp)
 76c:	f456                	sd	s5,40(sp)
 76e:	f05a                	sd	s6,32(sp)
 770:	ec5e                	sd	s7,24(sp)
 772:	1080                	addi	s0,sp,96
 774:	8baa                	mv	s7,a0
 776:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 778:	892a                	mv	s2,a0
 77a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 77c:	4aa9                	li	s5,10
 77e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 780:	89a6                	mv	s3,s1
 782:	2485                	addiw	s1,s1,1
 784:	0344d863          	bge	s1,s4,7b4 <gets+0x56>
    cc = read(0, &c, 1);
 788:	4605                	li	a2,1
 78a:	faf40593          	addi	a1,s0,-81
 78e:	4501                	li	a0,0
 790:	00000097          	auipc	ra,0x0
 794:	19a080e7          	jalr	410(ra) # 92a <read>
    if(cc < 1)
 798:	00a05e63          	blez	a0,7b4 <gets+0x56>
    buf[i++] = c;
 79c:	faf44783          	lbu	a5,-81(s0)
 7a0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 7a4:	01578763          	beq	a5,s5,7b2 <gets+0x54>
 7a8:	0905                	addi	s2,s2,1
 7aa:	fd679be3          	bne	a5,s6,780 <gets+0x22>
  for(i=0; i+1 < max; ){
 7ae:	89a6                	mv	s3,s1
 7b0:	a011                	j	7b4 <gets+0x56>
 7b2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 7b4:	99de                	add	s3,s3,s7
 7b6:	00098023          	sb	zero,0(s3)
  return buf;
}
 7ba:	855e                	mv	a0,s7
 7bc:	60e6                	ld	ra,88(sp)
 7be:	6446                	ld	s0,80(sp)
 7c0:	64a6                	ld	s1,72(sp)
 7c2:	6906                	ld	s2,64(sp)
 7c4:	79e2                	ld	s3,56(sp)
 7c6:	7a42                	ld	s4,48(sp)
 7c8:	7aa2                	ld	s5,40(sp)
 7ca:	7b02                	ld	s6,32(sp)
 7cc:	6be2                	ld	s7,24(sp)
 7ce:	6125                	addi	sp,sp,96
 7d0:	8082                	ret

00000000000007d2 <stat>:

int
stat(const char *n, struct stat *st)
{
 7d2:	1101                	addi	sp,sp,-32
 7d4:	ec06                	sd	ra,24(sp)
 7d6:	e822                	sd	s0,16(sp)
 7d8:	e426                	sd	s1,8(sp)
 7da:	e04a                	sd	s2,0(sp)
 7dc:	1000                	addi	s0,sp,32
 7de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7e0:	4581                	li	a1,0
 7e2:	00000097          	auipc	ra,0x0
 7e6:	170080e7          	jalr	368(ra) # 952 <open>
  if(fd < 0)
 7ea:	02054563          	bltz	a0,814 <stat+0x42>
 7ee:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 7f0:	85ca                	mv	a1,s2
 7f2:	00000097          	auipc	ra,0x0
 7f6:	178080e7          	jalr	376(ra) # 96a <fstat>
 7fa:	892a                	mv	s2,a0
  close(fd);
 7fc:	8526                	mv	a0,s1
 7fe:	00000097          	auipc	ra,0x0
 802:	13c080e7          	jalr	316(ra) # 93a <close>
  return r;
}
 806:	854a                	mv	a0,s2
 808:	60e2                	ld	ra,24(sp)
 80a:	6442                	ld	s0,16(sp)
 80c:	64a2                	ld	s1,8(sp)
 80e:	6902                	ld	s2,0(sp)
 810:	6105                	addi	sp,sp,32
 812:	8082                	ret
    return -1;
 814:	597d                	li	s2,-1
 816:	bfc5                	j	806 <stat+0x34>

0000000000000818 <atoi>:

int
atoi(const char *s)
{
 818:	1141                	addi	sp,sp,-16
 81a:	e422                	sd	s0,8(sp)
 81c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 81e:	00054683          	lbu	a3,0(a0)
 822:	fd06879b          	addiw	a5,a3,-48
 826:	0ff7f793          	zext.b	a5,a5
 82a:	4625                	li	a2,9
 82c:	02f66863          	bltu	a2,a5,85c <atoi+0x44>
 830:	872a                	mv	a4,a0
  n = 0;
 832:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 834:	0705                	addi	a4,a4,1
 836:	0025179b          	slliw	a5,a0,0x2
 83a:	9fa9                	addw	a5,a5,a0
 83c:	0017979b          	slliw	a5,a5,0x1
 840:	9fb5                	addw	a5,a5,a3
 842:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 846:	00074683          	lbu	a3,0(a4)
 84a:	fd06879b          	addiw	a5,a3,-48
 84e:	0ff7f793          	zext.b	a5,a5
 852:	fef671e3          	bgeu	a2,a5,834 <atoi+0x1c>
  return n;
}
 856:	6422                	ld	s0,8(sp)
 858:	0141                	addi	sp,sp,16
 85a:	8082                	ret
  n = 0;
 85c:	4501                	li	a0,0
 85e:	bfe5                	j	856 <atoi+0x3e>

0000000000000860 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 860:	1141                	addi	sp,sp,-16
 862:	e422                	sd	s0,8(sp)
 864:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 866:	02b57463          	bgeu	a0,a1,88e <memmove+0x2e>
    while(n-- > 0)
 86a:	00c05f63          	blez	a2,888 <memmove+0x28>
 86e:	1602                	slli	a2,a2,0x20
 870:	9201                	srli	a2,a2,0x20
 872:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 876:	872a                	mv	a4,a0
      *dst++ = *src++;
 878:	0585                	addi	a1,a1,1
 87a:	0705                	addi	a4,a4,1
 87c:	fff5c683          	lbu	a3,-1(a1)
 880:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 884:	fee79ae3          	bne	a5,a4,878 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 888:	6422                	ld	s0,8(sp)
 88a:	0141                	addi	sp,sp,16
 88c:	8082                	ret
    dst += n;
 88e:	00c50733          	add	a4,a0,a2
    src += n;
 892:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 894:	fec05ae3          	blez	a2,888 <memmove+0x28>
 898:	fff6079b          	addiw	a5,a2,-1
 89c:	1782                	slli	a5,a5,0x20
 89e:	9381                	srli	a5,a5,0x20
 8a0:	fff7c793          	not	a5,a5
 8a4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 8a6:	15fd                	addi	a1,a1,-1
 8a8:	177d                	addi	a4,a4,-1
 8aa:	0005c683          	lbu	a3,0(a1)
 8ae:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 8b2:	fee79ae3          	bne	a5,a4,8a6 <memmove+0x46>
 8b6:	bfc9                	j	888 <memmove+0x28>

00000000000008b8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 8b8:	1141                	addi	sp,sp,-16
 8ba:	e422                	sd	s0,8(sp)
 8bc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 8be:	ca05                	beqz	a2,8ee <memcmp+0x36>
 8c0:	fff6069b          	addiw	a3,a2,-1
 8c4:	1682                	slli	a3,a3,0x20
 8c6:	9281                	srli	a3,a3,0x20
 8c8:	0685                	addi	a3,a3,1
 8ca:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 8cc:	00054783          	lbu	a5,0(a0)
 8d0:	0005c703          	lbu	a4,0(a1)
 8d4:	00e79863          	bne	a5,a4,8e4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 8d8:	0505                	addi	a0,a0,1
    p2++;
 8da:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 8dc:	fed518e3          	bne	a0,a3,8cc <memcmp+0x14>
  }
  return 0;
 8e0:	4501                	li	a0,0
 8e2:	a019                	j	8e8 <memcmp+0x30>
      return *p1 - *p2;
 8e4:	40e7853b          	subw	a0,a5,a4
}
 8e8:	6422                	ld	s0,8(sp)
 8ea:	0141                	addi	sp,sp,16
 8ec:	8082                	ret
  return 0;
 8ee:	4501                	li	a0,0
 8f0:	bfe5                	j	8e8 <memcmp+0x30>

00000000000008f2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 8f2:	1141                	addi	sp,sp,-16
 8f4:	e406                	sd	ra,8(sp)
 8f6:	e022                	sd	s0,0(sp)
 8f8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 8fa:	00000097          	auipc	ra,0x0
 8fe:	f66080e7          	jalr	-154(ra) # 860 <memmove>
}
 902:	60a2                	ld	ra,8(sp)
 904:	6402                	ld	s0,0(sp)
 906:	0141                	addi	sp,sp,16
 908:	8082                	ret

000000000000090a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 90a:	4885                	li	a7,1
 ecall
 90c:	00000073          	ecall
 ret
 910:	8082                	ret

0000000000000912 <exit>:
.global exit
exit:
 li a7, SYS_exit
 912:	4889                	li	a7,2
 ecall
 914:	00000073          	ecall
 ret
 918:	8082                	ret

000000000000091a <wait>:
.global wait
wait:
 li a7, SYS_wait
 91a:	488d                	li	a7,3
 ecall
 91c:	00000073          	ecall
 ret
 920:	8082                	ret

0000000000000922 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 922:	4891                	li	a7,4
 ecall
 924:	00000073          	ecall
 ret
 928:	8082                	ret

000000000000092a <read>:
.global read
read:
 li a7, SYS_read
 92a:	4895                	li	a7,5
 ecall
 92c:	00000073          	ecall
 ret
 930:	8082                	ret

0000000000000932 <write>:
.global write
write:
 li a7, SYS_write
 932:	48c1                	li	a7,16
 ecall
 934:	00000073          	ecall
 ret
 938:	8082                	ret

000000000000093a <close>:
.global close
close:
 li a7, SYS_close
 93a:	48d5                	li	a7,21
 ecall
 93c:	00000073          	ecall
 ret
 940:	8082                	ret

0000000000000942 <kill>:
.global kill
kill:
 li a7, SYS_kill
 942:	4899                	li	a7,6
 ecall
 944:	00000073          	ecall
 ret
 948:	8082                	ret

000000000000094a <exec>:
.global exec
exec:
 li a7, SYS_exec
 94a:	489d                	li	a7,7
 ecall
 94c:	00000073          	ecall
 ret
 950:	8082                	ret

0000000000000952 <open>:
.global open
open:
 li a7, SYS_open
 952:	48bd                	li	a7,15
 ecall
 954:	00000073          	ecall
 ret
 958:	8082                	ret

000000000000095a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 95a:	48c5                	li	a7,17
 ecall
 95c:	00000073          	ecall
 ret
 960:	8082                	ret

0000000000000962 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 962:	48c9                	li	a7,18
 ecall
 964:	00000073          	ecall
 ret
 968:	8082                	ret

000000000000096a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 96a:	48a1                	li	a7,8
 ecall
 96c:	00000073          	ecall
 ret
 970:	8082                	ret

0000000000000972 <link>:
.global link
link:
 li a7, SYS_link
 972:	48cd                	li	a7,19
 ecall
 974:	00000073          	ecall
 ret
 978:	8082                	ret

000000000000097a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 97a:	48d1                	li	a7,20
 ecall
 97c:	00000073          	ecall
 ret
 980:	8082                	ret

0000000000000982 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 982:	48a5                	li	a7,9
 ecall
 984:	00000073          	ecall
 ret
 988:	8082                	ret

000000000000098a <dup>:
.global dup
dup:
 li a7, SYS_dup
 98a:	48a9                	li	a7,10
 ecall
 98c:	00000073          	ecall
 ret
 990:	8082                	ret

0000000000000992 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 992:	48ad                	li	a7,11
 ecall
 994:	00000073          	ecall
 ret
 998:	8082                	ret

000000000000099a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 99a:	48b1                	li	a7,12
 ecall
 99c:	00000073          	ecall
 ret
 9a0:	8082                	ret

00000000000009a2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 9a2:	48b5                	li	a7,13
 ecall
 9a4:	00000073          	ecall
 ret
 9a8:	8082                	ret

00000000000009aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 9aa:	48b9                	li	a7,14
 ecall
 9ac:	00000073          	ecall
 ret
 9b0:	8082                	ret

00000000000009b2 <ps>:
.global ps
ps:
 li a7, SYS_ps
 9b2:	48d9                	li	a7,22
 ecall
 9b4:	00000073          	ecall
 ret
 9b8:	8082                	ret

00000000000009ba <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 9ba:	48dd                	li	a7,23
 ecall
 9bc:	00000073          	ecall
 ret
 9c0:	8082                	ret

00000000000009c2 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 9c2:	48e1                	li	a7,24
 ecall
 9c4:	00000073          	ecall
 ret
 9c8:	8082                	ret

00000000000009ca <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 9ca:	48e9                	li	a7,26
 ecall
 9cc:	00000073          	ecall
 ret
 9d0:	8082                	ret

00000000000009d2 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 9d2:	48e5                	li	a7,25
 ecall
 9d4:	00000073          	ecall
 ret
 9d8:	8082                	ret

00000000000009da <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9da:	1101                	addi	sp,sp,-32
 9dc:	ec06                	sd	ra,24(sp)
 9de:	e822                	sd	s0,16(sp)
 9e0:	1000                	addi	s0,sp,32
 9e2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9e6:	4605                	li	a2,1
 9e8:	fef40593          	addi	a1,s0,-17
 9ec:	00000097          	auipc	ra,0x0
 9f0:	f46080e7          	jalr	-186(ra) # 932 <write>
}
 9f4:	60e2                	ld	ra,24(sp)
 9f6:	6442                	ld	s0,16(sp)
 9f8:	6105                	addi	sp,sp,32
 9fa:	8082                	ret

00000000000009fc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9fc:	7139                	addi	sp,sp,-64
 9fe:	fc06                	sd	ra,56(sp)
 a00:	f822                	sd	s0,48(sp)
 a02:	f426                	sd	s1,40(sp)
 a04:	f04a                	sd	s2,32(sp)
 a06:	ec4e                	sd	s3,24(sp)
 a08:	0080                	addi	s0,sp,64
 a0a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 a0c:	c299                	beqz	a3,a12 <printint+0x16>
 a0e:	0805c963          	bltz	a1,aa0 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 a12:	2581                	sext.w	a1,a1
  neg = 0;
 a14:	4881                	li	a7,0
 a16:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 a1a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 a1c:	2601                	sext.w	a2,a2
 a1e:	00001517          	auipc	a0,0x1
 a22:	85250513          	addi	a0,a0,-1966 # 1270 <digits>
 a26:	883a                	mv	a6,a4
 a28:	2705                	addiw	a4,a4,1
 a2a:	02c5f7bb          	remuw	a5,a1,a2
 a2e:	1782                	slli	a5,a5,0x20
 a30:	9381                	srli	a5,a5,0x20
 a32:	97aa                	add	a5,a5,a0
 a34:	0007c783          	lbu	a5,0(a5)
 a38:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a3c:	0005879b          	sext.w	a5,a1
 a40:	02c5d5bb          	divuw	a1,a1,a2
 a44:	0685                	addi	a3,a3,1
 a46:	fec7f0e3          	bgeu	a5,a2,a26 <printint+0x2a>
  if(neg)
 a4a:	00088c63          	beqz	a7,a62 <printint+0x66>
    buf[i++] = '-';
 a4e:	fd070793          	addi	a5,a4,-48
 a52:	00878733          	add	a4,a5,s0
 a56:	02d00793          	li	a5,45
 a5a:	fef70823          	sb	a5,-16(a4)
 a5e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a62:	02e05863          	blez	a4,a92 <printint+0x96>
 a66:	fc040793          	addi	a5,s0,-64
 a6a:	00e78933          	add	s2,a5,a4
 a6e:	fff78993          	addi	s3,a5,-1
 a72:	99ba                	add	s3,s3,a4
 a74:	377d                	addiw	a4,a4,-1
 a76:	1702                	slli	a4,a4,0x20
 a78:	9301                	srli	a4,a4,0x20
 a7a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a7e:	fff94583          	lbu	a1,-1(s2)
 a82:	8526                	mv	a0,s1
 a84:	00000097          	auipc	ra,0x0
 a88:	f56080e7          	jalr	-170(ra) # 9da <putc>
  while(--i >= 0)
 a8c:	197d                	addi	s2,s2,-1
 a8e:	ff3918e3          	bne	s2,s3,a7e <printint+0x82>
}
 a92:	70e2                	ld	ra,56(sp)
 a94:	7442                	ld	s0,48(sp)
 a96:	74a2                	ld	s1,40(sp)
 a98:	7902                	ld	s2,32(sp)
 a9a:	69e2                	ld	s3,24(sp)
 a9c:	6121                	addi	sp,sp,64
 a9e:	8082                	ret
    x = -xx;
 aa0:	40b005bb          	negw	a1,a1
    neg = 1;
 aa4:	4885                	li	a7,1
    x = -xx;
 aa6:	bf85                	j	a16 <printint+0x1a>

0000000000000aa8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 aa8:	7119                	addi	sp,sp,-128
 aaa:	fc86                	sd	ra,120(sp)
 aac:	f8a2                	sd	s0,112(sp)
 aae:	f4a6                	sd	s1,104(sp)
 ab0:	f0ca                	sd	s2,96(sp)
 ab2:	ecce                	sd	s3,88(sp)
 ab4:	e8d2                	sd	s4,80(sp)
 ab6:	e4d6                	sd	s5,72(sp)
 ab8:	e0da                	sd	s6,64(sp)
 aba:	fc5e                	sd	s7,56(sp)
 abc:	f862                	sd	s8,48(sp)
 abe:	f466                	sd	s9,40(sp)
 ac0:	f06a                	sd	s10,32(sp)
 ac2:	ec6e                	sd	s11,24(sp)
 ac4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 ac6:	0005c903          	lbu	s2,0(a1)
 aca:	18090f63          	beqz	s2,c68 <vprintf+0x1c0>
 ace:	8aaa                	mv	s5,a0
 ad0:	8b32                	mv	s6,a2
 ad2:	00158493          	addi	s1,a1,1
  state = 0;
 ad6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 ad8:	02500a13          	li	s4,37
 adc:	4c55                	li	s8,21
 ade:	00000c97          	auipc	s9,0x0
 ae2:	73ac8c93          	addi	s9,s9,1850 # 1218 <malloc+0x4ac>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 ae6:	02800d93          	li	s11,40
  putc(fd, 'x');
 aea:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 aec:	00000b97          	auipc	s7,0x0
 af0:	784b8b93          	addi	s7,s7,1924 # 1270 <digits>
 af4:	a839                	j	b12 <vprintf+0x6a>
        putc(fd, c);
 af6:	85ca                	mv	a1,s2
 af8:	8556                	mv	a0,s5
 afa:	00000097          	auipc	ra,0x0
 afe:	ee0080e7          	jalr	-288(ra) # 9da <putc>
 b02:	a019                	j	b08 <vprintf+0x60>
    } else if(state == '%'){
 b04:	01498d63          	beq	s3,s4,b1e <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 b08:	0485                	addi	s1,s1,1
 b0a:	fff4c903          	lbu	s2,-1(s1)
 b0e:	14090d63          	beqz	s2,c68 <vprintf+0x1c0>
    if(state == 0){
 b12:	fe0999e3          	bnez	s3,b04 <vprintf+0x5c>
      if(c == '%'){
 b16:	ff4910e3          	bne	s2,s4,af6 <vprintf+0x4e>
        state = '%';
 b1a:	89d2                	mv	s3,s4
 b1c:	b7f5                	j	b08 <vprintf+0x60>
      if(c == 'd'){
 b1e:	11490c63          	beq	s2,s4,c36 <vprintf+0x18e>
 b22:	f9d9079b          	addiw	a5,s2,-99
 b26:	0ff7f793          	zext.b	a5,a5
 b2a:	10fc6e63          	bltu	s8,a5,c46 <vprintf+0x19e>
 b2e:	f9d9079b          	addiw	a5,s2,-99
 b32:	0ff7f713          	zext.b	a4,a5
 b36:	10ec6863          	bltu	s8,a4,c46 <vprintf+0x19e>
 b3a:	00271793          	slli	a5,a4,0x2
 b3e:	97e6                	add	a5,a5,s9
 b40:	439c                	lw	a5,0(a5)
 b42:	97e6                	add	a5,a5,s9
 b44:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 b46:	008b0913          	addi	s2,s6,8
 b4a:	4685                	li	a3,1
 b4c:	4629                	li	a2,10
 b4e:	000b2583          	lw	a1,0(s6)
 b52:	8556                	mv	a0,s5
 b54:	00000097          	auipc	ra,0x0
 b58:	ea8080e7          	jalr	-344(ra) # 9fc <printint>
 b5c:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 b5e:	4981                	li	s3,0
 b60:	b765                	j	b08 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b62:	008b0913          	addi	s2,s6,8
 b66:	4681                	li	a3,0
 b68:	4629                	li	a2,10
 b6a:	000b2583          	lw	a1,0(s6)
 b6e:	8556                	mv	a0,s5
 b70:	00000097          	auipc	ra,0x0
 b74:	e8c080e7          	jalr	-372(ra) # 9fc <printint>
 b78:	8b4a                	mv	s6,s2
      state = 0;
 b7a:	4981                	li	s3,0
 b7c:	b771                	j	b08 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 b7e:	008b0913          	addi	s2,s6,8
 b82:	4681                	li	a3,0
 b84:	866a                	mv	a2,s10
 b86:	000b2583          	lw	a1,0(s6)
 b8a:	8556                	mv	a0,s5
 b8c:	00000097          	auipc	ra,0x0
 b90:	e70080e7          	jalr	-400(ra) # 9fc <printint>
 b94:	8b4a                	mv	s6,s2
      state = 0;
 b96:	4981                	li	s3,0
 b98:	bf85                	j	b08 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 b9a:	008b0793          	addi	a5,s6,8
 b9e:	f8f43423          	sd	a5,-120(s0)
 ba2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 ba6:	03000593          	li	a1,48
 baa:	8556                	mv	a0,s5
 bac:	00000097          	auipc	ra,0x0
 bb0:	e2e080e7          	jalr	-466(ra) # 9da <putc>
  putc(fd, 'x');
 bb4:	07800593          	li	a1,120
 bb8:	8556                	mv	a0,s5
 bba:	00000097          	auipc	ra,0x0
 bbe:	e20080e7          	jalr	-480(ra) # 9da <putc>
 bc2:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bc4:	03c9d793          	srli	a5,s3,0x3c
 bc8:	97de                	add	a5,a5,s7
 bca:	0007c583          	lbu	a1,0(a5)
 bce:	8556                	mv	a0,s5
 bd0:	00000097          	auipc	ra,0x0
 bd4:	e0a080e7          	jalr	-502(ra) # 9da <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bd8:	0992                	slli	s3,s3,0x4
 bda:	397d                	addiw	s2,s2,-1
 bdc:	fe0914e3          	bnez	s2,bc4 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 be0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 be4:	4981                	li	s3,0
 be6:	b70d                	j	b08 <vprintf+0x60>
        s = va_arg(ap, char*);
 be8:	008b0913          	addi	s2,s6,8
 bec:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 bf0:	02098163          	beqz	s3,c12 <vprintf+0x16a>
        while(*s != 0){
 bf4:	0009c583          	lbu	a1,0(s3)
 bf8:	c5ad                	beqz	a1,c62 <vprintf+0x1ba>
          putc(fd, *s);
 bfa:	8556                	mv	a0,s5
 bfc:	00000097          	auipc	ra,0x0
 c00:	dde080e7          	jalr	-546(ra) # 9da <putc>
          s++;
 c04:	0985                	addi	s3,s3,1
        while(*s != 0){
 c06:	0009c583          	lbu	a1,0(s3)
 c0a:	f9e5                	bnez	a1,bfa <vprintf+0x152>
        s = va_arg(ap, char*);
 c0c:	8b4a                	mv	s6,s2
      state = 0;
 c0e:	4981                	li	s3,0
 c10:	bde5                	j	b08 <vprintf+0x60>
          s = "(null)";
 c12:	00000997          	auipc	s3,0x0
 c16:	5fe98993          	addi	s3,s3,1534 # 1210 <malloc+0x4a4>
        while(*s != 0){
 c1a:	85ee                	mv	a1,s11
 c1c:	bff9                	j	bfa <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 c1e:	008b0913          	addi	s2,s6,8
 c22:	000b4583          	lbu	a1,0(s6)
 c26:	8556                	mv	a0,s5
 c28:	00000097          	auipc	ra,0x0
 c2c:	db2080e7          	jalr	-590(ra) # 9da <putc>
 c30:	8b4a                	mv	s6,s2
      state = 0;
 c32:	4981                	li	s3,0
 c34:	bdd1                	j	b08 <vprintf+0x60>
        putc(fd, c);
 c36:	85d2                	mv	a1,s4
 c38:	8556                	mv	a0,s5
 c3a:	00000097          	auipc	ra,0x0
 c3e:	da0080e7          	jalr	-608(ra) # 9da <putc>
      state = 0;
 c42:	4981                	li	s3,0
 c44:	b5d1                	j	b08 <vprintf+0x60>
        putc(fd, '%');
 c46:	85d2                	mv	a1,s4
 c48:	8556                	mv	a0,s5
 c4a:	00000097          	auipc	ra,0x0
 c4e:	d90080e7          	jalr	-624(ra) # 9da <putc>
        putc(fd, c);
 c52:	85ca                	mv	a1,s2
 c54:	8556                	mv	a0,s5
 c56:	00000097          	auipc	ra,0x0
 c5a:	d84080e7          	jalr	-636(ra) # 9da <putc>
      state = 0;
 c5e:	4981                	li	s3,0
 c60:	b565                	j	b08 <vprintf+0x60>
        s = va_arg(ap, char*);
 c62:	8b4a                	mv	s6,s2
      state = 0;
 c64:	4981                	li	s3,0
 c66:	b54d                	j	b08 <vprintf+0x60>
    }
  }
}
 c68:	70e6                	ld	ra,120(sp)
 c6a:	7446                	ld	s0,112(sp)
 c6c:	74a6                	ld	s1,104(sp)
 c6e:	7906                	ld	s2,96(sp)
 c70:	69e6                	ld	s3,88(sp)
 c72:	6a46                	ld	s4,80(sp)
 c74:	6aa6                	ld	s5,72(sp)
 c76:	6b06                	ld	s6,64(sp)
 c78:	7be2                	ld	s7,56(sp)
 c7a:	7c42                	ld	s8,48(sp)
 c7c:	7ca2                	ld	s9,40(sp)
 c7e:	7d02                	ld	s10,32(sp)
 c80:	6de2                	ld	s11,24(sp)
 c82:	6109                	addi	sp,sp,128
 c84:	8082                	ret

0000000000000c86 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c86:	715d                	addi	sp,sp,-80
 c88:	ec06                	sd	ra,24(sp)
 c8a:	e822                	sd	s0,16(sp)
 c8c:	1000                	addi	s0,sp,32
 c8e:	e010                	sd	a2,0(s0)
 c90:	e414                	sd	a3,8(s0)
 c92:	e818                	sd	a4,16(s0)
 c94:	ec1c                	sd	a5,24(s0)
 c96:	03043023          	sd	a6,32(s0)
 c9a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c9e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ca2:	8622                	mv	a2,s0
 ca4:	00000097          	auipc	ra,0x0
 ca8:	e04080e7          	jalr	-508(ra) # aa8 <vprintf>
}
 cac:	60e2                	ld	ra,24(sp)
 cae:	6442                	ld	s0,16(sp)
 cb0:	6161                	addi	sp,sp,80
 cb2:	8082                	ret

0000000000000cb4 <printf>:

void
printf(const char *fmt, ...)
{
 cb4:	711d                	addi	sp,sp,-96
 cb6:	ec06                	sd	ra,24(sp)
 cb8:	e822                	sd	s0,16(sp)
 cba:	1000                	addi	s0,sp,32
 cbc:	e40c                	sd	a1,8(s0)
 cbe:	e810                	sd	a2,16(s0)
 cc0:	ec14                	sd	a3,24(s0)
 cc2:	f018                	sd	a4,32(s0)
 cc4:	f41c                	sd	a5,40(s0)
 cc6:	03043823          	sd	a6,48(s0)
 cca:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 cce:	00840613          	addi	a2,s0,8
 cd2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cd6:	85aa                	mv	a1,a0
 cd8:	4505                	li	a0,1
 cda:	00000097          	auipc	ra,0x0
 cde:	dce080e7          	jalr	-562(ra) # aa8 <vprintf>
}
 ce2:	60e2                	ld	ra,24(sp)
 ce4:	6442                	ld	s0,16(sp)
 ce6:	6125                	addi	sp,sp,96
 ce8:	8082                	ret

0000000000000cea <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cea:	1141                	addi	sp,sp,-16
 cec:	e422                	sd	s0,8(sp)
 cee:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cf0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cf4:	00001797          	auipc	a5,0x1
 cf8:	3147b783          	ld	a5,788(a5) # 2008 <freep>
 cfc:	a02d                	j	d26 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cfe:	4618                	lw	a4,8(a2)
 d00:	9f2d                	addw	a4,a4,a1
 d02:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 d06:	6398                	ld	a4,0(a5)
 d08:	6310                	ld	a2,0(a4)
 d0a:	a83d                	j	d48 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 d0c:	ff852703          	lw	a4,-8(a0)
 d10:	9f31                	addw	a4,a4,a2
 d12:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 d14:	ff053683          	ld	a3,-16(a0)
 d18:	a091                	j	d5c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d1a:	6398                	ld	a4,0(a5)
 d1c:	00e7e463          	bltu	a5,a4,d24 <free+0x3a>
 d20:	00e6ea63          	bltu	a3,a4,d34 <free+0x4a>
{
 d24:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d26:	fed7fae3          	bgeu	a5,a3,d1a <free+0x30>
 d2a:	6398                	ld	a4,0(a5)
 d2c:	00e6e463          	bltu	a3,a4,d34 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d30:	fee7eae3          	bltu	a5,a4,d24 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 d34:	ff852583          	lw	a1,-8(a0)
 d38:	6390                	ld	a2,0(a5)
 d3a:	02059813          	slli	a6,a1,0x20
 d3e:	01c85713          	srli	a4,a6,0x1c
 d42:	9736                	add	a4,a4,a3
 d44:	fae60de3          	beq	a2,a4,cfe <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 d48:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d4c:	4790                	lw	a2,8(a5)
 d4e:	02061593          	slli	a1,a2,0x20
 d52:	01c5d713          	srli	a4,a1,0x1c
 d56:	973e                	add	a4,a4,a5
 d58:	fae68ae3          	beq	a3,a4,d0c <free+0x22>
    p->s.ptr = bp->s.ptr;
 d5c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 d5e:	00001717          	auipc	a4,0x1
 d62:	2af73523          	sd	a5,682(a4) # 2008 <freep>
}
 d66:	6422                	ld	s0,8(sp)
 d68:	0141                	addi	sp,sp,16
 d6a:	8082                	ret

0000000000000d6c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d6c:	7139                	addi	sp,sp,-64
 d6e:	fc06                	sd	ra,56(sp)
 d70:	f822                	sd	s0,48(sp)
 d72:	f426                	sd	s1,40(sp)
 d74:	f04a                	sd	s2,32(sp)
 d76:	ec4e                	sd	s3,24(sp)
 d78:	e852                	sd	s4,16(sp)
 d7a:	e456                	sd	s5,8(sp)
 d7c:	e05a                	sd	s6,0(sp)
 d7e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d80:	02051493          	slli	s1,a0,0x20
 d84:	9081                	srli	s1,s1,0x20
 d86:	04bd                	addi	s1,s1,15
 d88:	8091                	srli	s1,s1,0x4
 d8a:	0014899b          	addiw	s3,s1,1
 d8e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d90:	00001517          	auipc	a0,0x1
 d94:	27853503          	ld	a0,632(a0) # 2008 <freep>
 d98:	c515                	beqz	a0,dc4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d9a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d9c:	4798                	lw	a4,8(a5)
 d9e:	02977f63          	bgeu	a4,s1,ddc <malloc+0x70>
 da2:	8a4e                	mv	s4,s3
 da4:	0009871b          	sext.w	a4,s3
 da8:	6685                	lui	a3,0x1
 daa:	00d77363          	bgeu	a4,a3,db0 <malloc+0x44>
 dae:	6a05                	lui	s4,0x1
 db0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 db4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 db8:	00001917          	auipc	s2,0x1
 dbc:	25090913          	addi	s2,s2,592 # 2008 <freep>
  if(p == (char*)-1)
 dc0:	5afd                	li	s5,-1
 dc2:	a895                	j	e36 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 dc4:	04001797          	auipc	a5,0x4001
 dc8:	24c78793          	addi	a5,a5,588 # 4002010 <base>
 dcc:	00001717          	auipc	a4,0x1
 dd0:	22f73e23          	sd	a5,572(a4) # 2008 <freep>
 dd4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 dd6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 dda:	b7e1                	j	da2 <malloc+0x36>
      if(p->s.size == nunits)
 ddc:	02e48c63          	beq	s1,a4,e14 <malloc+0xa8>
        p->s.size -= nunits;
 de0:	4137073b          	subw	a4,a4,s3
 de4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 de6:	02071693          	slli	a3,a4,0x20
 dea:	01c6d713          	srli	a4,a3,0x1c
 dee:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 df0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 df4:	00001717          	auipc	a4,0x1
 df8:	20a73a23          	sd	a0,532(a4) # 2008 <freep>
      return (void*)(p + 1);
 dfc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 e00:	70e2                	ld	ra,56(sp)
 e02:	7442                	ld	s0,48(sp)
 e04:	74a2                	ld	s1,40(sp)
 e06:	7902                	ld	s2,32(sp)
 e08:	69e2                	ld	s3,24(sp)
 e0a:	6a42                	ld	s4,16(sp)
 e0c:	6aa2                	ld	s5,8(sp)
 e0e:	6b02                	ld	s6,0(sp)
 e10:	6121                	addi	sp,sp,64
 e12:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 e14:	6398                	ld	a4,0(a5)
 e16:	e118                	sd	a4,0(a0)
 e18:	bff1                	j	df4 <malloc+0x88>
  hp->s.size = nu;
 e1a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 e1e:	0541                	addi	a0,a0,16
 e20:	00000097          	auipc	ra,0x0
 e24:	eca080e7          	jalr	-310(ra) # cea <free>
  return freep;
 e28:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 e2c:	d971                	beqz	a0,e00 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e2e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e30:	4798                	lw	a4,8(a5)
 e32:	fa9775e3          	bgeu	a4,s1,ddc <malloc+0x70>
    if(p == freep)
 e36:	00093703          	ld	a4,0(s2)
 e3a:	853e                	mv	a0,a5
 e3c:	fef719e3          	bne	a4,a5,e2e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 e40:	8552                	mv	a0,s4
 e42:	00000097          	auipc	ra,0x0
 e46:	b58080e7          	jalr	-1192(ra) # 99a <sbrk>
  if(p == (char*)-1)
 e4a:	fd5518e3          	bne	a0,s5,e1a <malloc+0xae>
        return 0;
 e4e:	4501                	li	a0,0
 e50:	bf45                	j	e00 <malloc+0x94>

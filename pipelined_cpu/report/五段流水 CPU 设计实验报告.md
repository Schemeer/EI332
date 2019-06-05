# 五段流水 CPU 设计实验报告

姓名：况羿

学号：517030910343

## 实验目的

1. 理解计算机指令流水线的协调工作原理，初步掌握流水线的设计和实现原理。
2. 深刻理解流水线寄存器在流水线实现中所起的重要作用。
3. 理解和掌握流水段的划分、设计原理及其实现方法原理。
4. 掌握运算器、寄存器堆、存储器、控制器在流水工作方式下，有别于实验一 的设计和实现方法。
5. 掌握流水方式下，通过 I/O 端口与外部设备进行信息交互的方法。

## 实验内容

1. 采用Verilog在quartusⅡ中实现基本的具有20条MIPS 指令的5段流水CPU 设计。
2. 利用实验提供的标准测试程序代码，完成仿真测试。
3. 采用 I/O 统一编址方式，即将输入输出的 I/O 地址空间，作为数据存取空间 的一部分，实现 CPU 与外部设备的输入输出端口设计。实验中可采用高端 地址。
4. 利用设计的 I/O 端口，通过 lw 指令，输入 DE2 实验板上的按键等输入设备 信息。即将外部设备状态，读到 CPU 内部寄存器。
5. 利用设计的 I/O 端口，通过 sw 指令，输出对 DE2 实验板上的 LED 灯等输出 设备的控制信号（或数据信息）。即将对外部设备的控制数据，从 CPU 内部 的寄存器，写入到外部设备的相应控制寄存器（或可直接连接至外部设备的 控制输入信号）。
6. 利用自己编写的程序代码，在自己设计的 CPU 上，实现对板载输入开关或 按键的状态输入，并将判别或处理结果，利用板载 LED 灯或 7 段 LED 数码 管显示出来。
7. 例如，将一路 4bit 二进制输入与另一路 4bit 二进制输入相加，利用两组分别 2 个 LED 数码管以 10 进制形式显示“被加数”和“加数”，另外一组 LED 数码管以 10 进制形式显示“和”等。（具体任务形式不做严格规定，同学可 自由创意）。
8. 在实现 MIPS 基本 20 条指令的基础上，掌握新指令的扩展方法。
9. 在实验报告中，汇报自己的设计思想和方法；并以汇编语言的形式，提供以 上两种指令集（MIPS 和 Y86）应用功能的程序设计代码，并提供程序主要
   流程图。

## 实验器材

- Intel/Altera-DE1-SOC 实验板套件 1 套 
- 万用表 1 台
-  示波器 1 台 

## 设计思想和方法

五段流水线CPU总体结构框架如下图

![pipelined_computer](D:\ComputerOrganization\Experiment3\pipelined_cpu.png)

可以看见从模块上看单周期CPU中很多模块是可以继续使用的，如寄存器堆，ALU，CU，指令存储器，数据存储器，多选器等。因此是可以考虑利用上次的顶层代码所规划出的结构，添加转发等机制从而实现五段流水线。当然也可以从五段流水线的五段以及每段之间的寄存器堆来划分结构，从而将整个五段流水线分为PCreg、IF、FDreg、ID、DEreg、EXE、EMreg、MEM、MWreg、WB这几个大模块，再在几个大模块之中嵌套CU、ALU、多选器等小模块或相应赋值操作实现对应功能。两种设计结构方法都可以实现，选择前一种好处在于是在上次的框架下面新增功能，整体框架已经搭好了，工作量略少；后一种的好处在于结构更加清晰明了。出与对练习和巩固流水线结构的角度考虑，我选择了后一种结构方式，顶层代码如下：

```verilog
module	pipelined_computer (	resetn, clock, mem_clock, pc, inst, ealu, malu, walu, in_port0, in_port1, hex0, hex1, hex2, hex3, hex4, hex5, out_port0, out_port1, out_port2, out_port3, out_port4, out_port5); 
//定义顶层模块 pipelined_computer，作为工程文件的顶层入口，如图 1-1 建立工程时指定。 
	input					resetn, clock, mem_clock;  
	input 	[3:0] 	in_port0, in_port1;
	//定义整个计算机 module 和外界交互的输入信号，包括复位信号 resetn、时钟信号 clock、 
	//以及一个和 clock 同频率但反相的 mem_clock 信号。mem_clock 用于指令同步 ROM 和数据同步 RAM 使用，其波形需要有别于实验一。 
	//这些信号可以用作仿真验证时的输出观察信号。 
	output	[31:0]	pc, inst, ealu, malu, walu; 
	//模块用于仿真输出的观察信号。缺省为 wire 型。 
	output	[6:0] 	hex0,hex1,hex2,hex3,hex4,hex5;

	output 		[31:0] 	out_port0, out_port1, out_port2, out_port3, out_port4, out_port5;
	wire		[31:0]	bpc, jpc, npc, pc4, ins, inst;     
	//模块间互联传递数据或控制信息的信号线,均为 32 位宽信号。IF 取指令阶段。
	wire		[31:0]	dpc4, da, db, dimm, dsa; 
	//模块间互联传递数据或控制信息的信号线,均为 32 位宽信号。ID 指令译码阶段。 
	wire		[31:0]	epc4, ea, eb, eimm, esa;  
	//模块间互联传递数据或控制信息的信号线,均为 32 位宽信号。EXE 指令运算阶段。 
	wire		[31:0]	mb, mmo; 
	//模块间互联传递数据或控制信息的信号线,均为 32 位宽信号。MEM 访问数据阶段。 
	wire		[31:0]	wmo, wdi; 
	//模块间互联传递数据或控制信息的信号线,均为 32 位宽信号。WB 回写寄存器阶段。 
	
	wire		[4:0]		drn, ern0, ern, mrn, wrn; 
	//模块间互联，通过流水线寄存器传递结果寄存器号的信号线，寄存器号（32 个）为 5bit。 
	wire		[3:0]		daluc, ealuc; 
	//ID 阶段向 EXE 阶段通过流水线寄存器传递的 aluc 控制信号，4bit。 
	wire   	[1:0]		pcsource; 
	//CU 模块向 IF阶段模块传递的 PC 选择信号，2bit。 
	wire          		wpcir; 
	// CU 模块发出的控制流水线停顿的控制信号，使 PC 和 IF/ID 流水线寄存器保持不变。 
	wire					dwreg, dm2reg, dwmem, daluimm, dshift, djal;  
	// id stage 
	// ID 阶段产生，需往后续流水级传播的信号。 
	wire					ewreg, em2reg, ewmem, ealuimm, eshift, ejal;  
	// exe stage 
	//来自于 ID/EXE 流水线寄存器，EXE 阶段使用，或需要往后续流水级传播的信号。 
	wire					mwreg, mm2reg, mwmem; 
	// mem stage 
	//来自于 EXE/MEM 流水线寄存器，MEM 阶段使用，或需要往后续流水级传播的信号。       
	wire					wwreg, wm2reg;          
	// wb stage 
	//来自于 MEM/WB 流水线寄存器，WB 阶段使用的信号。 

	
	pipepc				prog_cnt (	npc, wpcir, clock, resetn, pc ); 
	//程序计数器模块，是最前面一级 IF流水段的输入。       
	pipeif				if_stage	(	pcsource, pc, bpc, da, jpc, npc, pc4, ins, mem_clock );  
	//  IF stage 
	//IF取指令模块，注意其中包含的指令同步 ROM 存储器的同步信号， 
	//即输入给该模块的 mem_clock 信号，模块内定义为 rom_clk。
	// 注意 mem_clock。 
	//实验中可采用系统 clock 的反相信号作为 mem_clock（亦即 rom_clock）, 
	//即留给信号半个节拍的传输时间。 
	pipefdreg				inst_reg	(	pc4, ins, wpcir, clock, resetn, dpc4, inst );        
	// IF/ID 流水线寄存器 
	//IF/ID 流水线寄存器模块，起承接 IF阶段和 ID 阶段的流水任务。 
	//在 clock 上升沿时，将 IF 阶段需传递给 ID 阶段的信息，锁存在 IF/ID 流水线寄存器 
	//中，并呈现在 ID 阶段。       
	pipeid				id_stage	(	mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst,
											wrn, wdi, ealu, malu, mmo, wwreg, clock, resetn,
											bpc, jpc, pcsource, wpcir, dwreg, dm2reg, dwmem, daluc,
											daluimm, da, db, dimm, drn, dshift, djal, dsa );
	//  ID stage 
	//ID 指令译码模块。注意其中包含控制器 CU、寄存器堆、及多个多路器等。 
	//其中的寄存器堆，会在系统 clock 的下沿进行寄存器写入，也就是给信号从 WB 阶段 
	//传输过来留有半个 clock 的延迟时间，亦即确保信号稳定。 
	//该阶段 CU 产生的、要传播到流水线后级的信号较多。       
	pipedereg			de_reg	(	dwreg, dm2reg, dwmem,daluc, daluimm, da, db, dimm, drn, dshift,
											djal, dpc4, dsa, clock, resetn, ewreg, em2reg, ewmem, ealuc, ealuimm,
											ea,eb, eimm, ern0, eshift, ejal, epc4, esa );          
	// ID/EXE 流水线寄存器 
	//ID/EXE 流水线寄存器模块，起承接 ID 阶段和 EXE 阶段的流水任务。 
	//在 clock 上升沿时，将 ID 阶段需传递给 EXE 阶段的信息，锁存在 ID/EXE 流水线 
	//寄存器中，并呈现在 EXE 阶段。                               
	pipeexe				exe_stage(	ealuc, ealuimm, ea, eb, eimm, esa, eshift, ern0, epc4, ejal, ern, ealu );  
	// EXE stage 
	//EXE 运算模块。其中包含 ALU 及多个多路器等。                                                 
	pipeemreg			em_reg	(	ewreg, em2reg, ewmem, ealu, eb, ern, clock, resetn,
											mwreg, mm2reg, mwmem, malu, mb, mrn); 
	// EXE/MEM流水线寄存器 
	//EXE/MEM流水线寄存器模块，起承接 EXE 阶段和 MEM 阶段的流水任务。 
	//在 clock 上升沿时，将 EXE 阶段需传递给 MEM 阶段的信息，锁存在 EXE/MEM 
	//流水线寄存器中，并呈现在 MEM 阶段。       
	pipemem				mem_stage(	mwmem, malu, mb, clock, resetn, mem_clock, mmo, in_port0, in_port1, out_port0, out_port1, out_port2, out_port3, out_port4, out_port5 );        
	//  MEM stage 
	//MEM 数据存取模块。其中包含对数据同步 RAM 的读写访问。
	// 注意 mem_clock。 
	//输入给该同步 RAM 的 mem_clock 信号，模块内定义为 ram_clk。 
	//实验中可采用系统 clock 的反相信号作为 mem_clock 信号（亦即 ram_clk）, 
	//即留给信号半个节拍的传输时间，然后在 mem_clock 上沿时，读输出、或写输入。 

	pipemwreg			mw_reg	(	mwreg, mm2reg, mmo, malu, mrn, clock, resetn,
											wwreg, wm2reg, wmo, walu, wrn);     
	//  MEM/WB 流水线寄存器 
	//MEM/WB 流水线寄存器模块，起承接 MEM 阶段和 WB 阶段的流水任务。 
	//在 clock 上升沿时，将 MEM 阶段需传递给 WB 阶段的信息，锁存在 MEM/WB 
	//流水线寄存器中，并呈现在 WB 阶段。       
	mux2x32				wb_stage	(	walu, wmo, wm2reg, wdi );          
	//  WB stage 
	//WB 写回阶段模块。事实上，从设计原理图上可以看出，该阶段的逻辑功能部件只 
	//包含一个多路器，所以可以仅用一个多路器的实例即可实现该部分。 
	//当然，如果专门写一个完整的模块也是很好的。 
	
   sevenseg sevenseg5(out_port5[3:0],hex5);
   sevenseg sevenseg4(out_port4[3:0],hex4);
   sevenseg sevenseg3(out_port3[3:0],hex3);
   sevenseg sevenseg2(out_port2[3:0],hex2);
   sevenseg sevenseg1(out_port1[3:0],hex1);
   sevenseg sevenseg0(out_port0[3:0],hex0);
endmodule 
```

在完成整个顶层模块的设计构建以后，接下来便是根据图逐步描述各个模块，实现相应的功能。由于模块较多，在此就不一一展示代码，因此仅挑出比较困难的，代码量也比较大的ID阶段进行展示。值得注意的是，与上图中有些不一样的是，ID阶段的中有些输入输出信号，实际上在该阶段并没有使用或者修改，我并又没将信号列入输入输出端口，例如dwreg。有些信号上图中并没有，比如I形指令中的sa（实际上是该图将sa与imm线合并了，我在实现时没有意识到这一点），我单独将其拿出来作为一个输出端口，输出到DEreg，从而作为ALU的a输入的备选，这是与图中直接使用imm作为备选所不同的。代码如下：

```verilog
module pipeid (	mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst,
						wrn, wdi, ealu, malu, mmo, wwreg, clock, resetn,
						bpc, jpc, pcsource, wpcir, dwreg, dm2reg, dwmem, daluc,
						daluimm, da, db, dimm, drn, dshift, djal, dsa );
	
	
	input [31:0]	dpc4, inst, wdi, ealu, malu, mmo;
	input [4:0]		mrn, ern, wrn;
	input 			mwreg, ewreg, em2reg, mm2reg, wwreg, clock, resetn;
	
	output [31:0]	bpc, jpc, da, db, dimm, dsa;
	output [4:0]	drn;
	output [3:0]	daluc;
	output [1:0]	pcsource;
	output			wpcir, dwreg, dm2reg, dwmem, daluimm, dshift,djal;
	
	wire dregrt, sext;
	wire [1:0]	fwda, fwdb;
	
	wire z = ~|(da^db); //a==b?1:0
	
	wire	[5:0] 	op =		inst[31:26];
	wire	[4:0] 	rs =		inst[25:21];
	wire	[4:0] 	rt =		inst[20:16];
	wire	[4:0] 	rd =		inst[15:11];
	
	wire	[5:0]		func =	inst[5:0];
	
	wire	[31:0]	qa, qb;

	wire	[3:0]		daluc_tmp;
	wire	dwmem_tmp, dwreg_tmp, dm2reg_tmp, dshift_tmp, daluimm_tmp, djal_tmp;
	assign dsa =  { 27'b0, inst[10:6] };
	
	pipecu	pcu(	op, func, z, dwmem_tmp, dwreg_tmp, dregrt, dm2reg_tmp, daluc_tmp, dshift_tmp,
						daluimm_tmp, pcsource, djal_tmp, sext);
	
	regfile rf(rs, rt, wdi, wrn, wwreg, clock, resetn, qa, qb);
	
	assign	wpcir = ~(em2reg & ((ern == rs)|(ern == rt)) & ~dwmem_tmp);
	assign	dwreg = wpcir?dwreg_tmp:1'b0;
	assign	dm2reg = wpcir?dm2reg_tmp:1'b0;
	assign	dwmem = wpcir?dwmem_tmp:1'b0;
	assign	daluimm = wpcir?daluimm_tmp:1'b0;
	assign	dshift = wpcir?dshift_tmp:1'b0;
	assign	djal = wpcir?djal_tmp:1'b0;
	assign	daluc = wpcir?daluc_tmp:4'b0;
	assign	drn = dregrt?rt:rd;
	assign	jpc = {dpc4[31:28],inst[25:0],2'b0};
	
	wire		e = sext&inst[15];
	wire	[15:0] 	imm = {16{e}};
	wire	[31:0] 	offset = {imm[13:0], inst[15:0], 2'b0};
	
	assign dimm = {imm, inst[15:0]};
	assign bpc = dpc4 + offset;
	
	assign fwda[0] = (ewreg & ~em2reg & ern == rs & ern != 0) | (mm2reg & mrn == rs & mrn != 0);
	assign fwda[1] = (mwreg & ~mm2reg & mrn == rs & ern != rs & mrn != 0) | (mm2reg & mrn == rs & mrn != 0); 
	assign fwdb[0] = (ewreg & ~em2reg & ern == rt & ern != 0) | ( mm2reg & mrn == rt & mrn != 0);
	assign fwdb[1] = (mwreg & ~mm2reg & mrn == rt & ern != rt & mrn != 0) | (mm2reg & mrn == rt & mrn != 0); 
	
	
	mux4x32 forwarding_da(qa,ealu,malu,mmo,fwda,da);
	mux4x32 forwarding_db(qb,ealu,malu,mmo,fwdb,db);
	
endmodule
```

完成整个设计实现过程以后，我利用sc_computer阶段老师提供的全覆盖指令完成了仿真过程，并用以下指令实现了IO交互检测（在IO的设计方式上除了将输入从五位变成了四位以外，其余我均与单周期CPU保持了一致），如下：

```mif
DEPTH = 32;           % Memory depth and width are required %
WIDTH = 32;           % Enter a decimal number %
ADDRESS_RADIX = HEX;  % Address and value radixes are optional %
DATA_RADIX = HEX;     % Enter BIN, DEC, HEX, or OCT; unless %
                      % otherwise specified, radixes = HEX %
CONTENT
BEGIN
[0..1F] : 00000000;   % Range--Every address from 0 to 1F = 00000000 %

 0 : 20010080;        % (00)       addi  $1, $0, 128  #  %
 1 : 20020084;        % (04)       addi  $2, $0, 132  #  %
 2 : 20030088;        % (08)       addi  $3, $0, 136  #  %
 3 : 2004008c;        % (0c)       addi   $4, $0, 140 #  %
 4 : 20050090;        % (10)       addi   $5, $0, 144 #  %
 5 : 20060094;        % (14)       addi   $6, $0, 148 #  %
 6 : 200700c0;        % (18)       addi   $7, $0, 192 #  %
 7 : 200800c4;        % (1c)       addi   $8, $0, 196 #  %
 8 : 8ce90000;        % (20) loop: lw   $9, 0($7)     #  %
 9 : 8d0a0000;        % (24)       lw  $10, 0($8)     #  %
 A : 21290000;        % (28)       addi  $9, $9,   0  #  %
 B : 214a0000;        % (2c)       addi  $10, $10, 0  #  %
 C : 012a5820;        % (30)       add  $11, $9, $10  #  %
 D : 012a6022;        % (34)       sub  $12, $9, $10  #  %
 E : 012a6824;        % (38)       and  $13, $9, $10  #  %
 F : 012a7025;        % (3c)       or  $14, $9, $10   #  %
10 : 00097842;        % (40)       srl  $15, $9, 1    #  %
11 : 000a8040;        % (44)       sll  $16, $10,1    #  %
12 : ac2b0000;        % (48)       sw  $11, 0($1)     #  %
13 : ac4c0000;        % (4c)       sw  $12, 0($2)     #  %
14 : ac6d0000;        % (50)       sw  $13, 0($3)     #  %
15 : ac8e0000;        % (54)       sw  $14, 0($4)     #  %
16 : acaf0000;        % (58)       sw  $15, 0($5)     #  %
17 : acd00000;        % (5c)       sw  $16, 0($6)     #  %
18 : 08000008;        % (60)       j  loop            #  %
END ;
```

## 实验总结

经过本次实验，我对于流水线的整体结构以及冒险处理方式有了更深层次的了解。将理论课程的知识应用于实践，在实践过程中补全了理论学习过程中的漏洞，获益匪浅。
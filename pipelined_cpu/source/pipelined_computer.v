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
											wrn, wdi, ealu, malu, mmo, wwreg, clock, mem_clock, resetn,
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
	pipemem				mem_stage(	mwmem, wm2reg, wrn, mrn, malu, mb, wmo, clock, resetn, mem_clock, mmo, in_port0, in_port1, out_port0, out_port1, out_port2, out_port3, out_port4, out_port5 );        
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
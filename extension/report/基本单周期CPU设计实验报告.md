# 基本单周期CPU设计实验报告

姓名：况羿

学号：517030910343

## 实验目的

1. 理解计算机 5 大组成部分的协调工作原理，理解存储程序自动执行的原理。

1. 掌握运算器、存储器、控制器的设计和实现原理。重点掌握控制器设计原理 和实现方法。
2. 掌握 I/O 端口的设计方法，理解 I/O 地址空间的设计方法。
3. 会通过设计 I/O 端口与外部设备进行信息交互

## 实验内容

1. 采用 Verilog HDL 在 quartusⅡ中实现基本的具有 20 条 MIPS 指令的单周期 CPU 设计。
2. 利用实验提供的标准测试程序代码，完成仿真测试。
3. 采用 I/O 统一编址方式，即将输入输出的 I/O 地址空间，作为数据存取空间 的一部分，实现 CPU 与外部设备的输入输出端口设计。实验中可采用高端 地址。
4. 利用设计的 I/O 端口，通过 lw 指令，输入 DE2 实验板上的按键等输入设备 信息。即将外部设备状态，读到 CPU 内部寄存器。
5. 利用设计的 I/O 端口，通过 sw 指令，输出对 DE2 实验板上的 LED 灯等输出 设备的控制信号（或数据信息）。即将对外部设备的控制数据，从 CPU 内部 的寄存器，写入到外部设备的相应控制寄存器（或可直接连接至外部设备的 控制输入信号）。
6. 利用自己编写的程序代码，在自己设计的 CPU 上，实现对板载输入开关或 按键的状态输入，并将判别或处理结果，利用板载 LED 灯或 7 段 LED 数码 管显示出来。
7. 例如，将一路 4bit 二进制输入与另一路 4bit 二进制输入相加，利用两组分别 2 个 LED 数码管以 10 进制形式显示“被加数”和“加数”，另外一组 LED 数码管以 10 进制形式显示“和”等。（具体任务形式不做严格规定，同学可 自由创意）。
8. 在实现 MIPS 基本 20 条指令的基础上，掌握新指令的扩展方法。
9. 在实验报告中，汇报自己的设计思想和方法；并以汇编语言的形式，提供以 上指令集全覆盖的测试应用功能的程序设计代码，并提供程序主要流程图。

## 实验器材

- DE1-SOC 实验板 1 套 
- 示波器 1 台 
- 数字万用表 1 台 

## 设计思想与方法

### 1. 设计框架

单周期CPU的整体框架结构可参考下图

![single_computer](D:\ComputerOrganization\Experiment2\single_cpu.png)

从中我们可以看出要设计单周期CPU，我们需要上图中各个模块的输入输出端口确定，在模块内部将相应模块所需实现的功能描述清楚。而本次实验老师已经给出了大部分模块的代码，因此我们仅需完成部分模块的设计，在这些模块则是较为重要的CU以及ALU。

#### 1. CU设计

CU负责分析op、z以及func信号从而产生相应的控制信号使寄存器、ALU以及存储器执行相应的操作，而想要实现根据各种输入信号产生相应信号的过程，则需要我们设计各种指令的信号，建立真值表，根据真值表的相应信息来完成控制信号的产生。我设计的真值表如下：

![truthtable](D:\ComputerOrganization\Experiment2\truthtable.png)

在该真值表的指引下我们就可以完成CU的设计，相应代码如下：

```verilog
module sc_cu (op, func, z, wmem, wreg, regrt, m2reg, aluc, shift,
              aluimm, pcsource, jal, sext);
   input  [5:0] op,func;
   input        z;
   output       wreg,regrt,jal,m2reg,shift,aluimm,sext,wmem;
   output [3:0] aluc;
   output [1:0] pcsource;
   wire r_type = ~|op;
   wire i_add = r_type & func[5] & ~func[4] & ~func[3] &
                ~func[2] & ~func[1] & ~func[0];          //100000
   wire i_sub = r_type & func[5] & ~func[4] & ~func[3] &
                ~func[2] &  func[1] & ~func[0];          //100010
      
   //  please complete the deleted code.
   
   wire i_and =  r_type & func[5] & ~func[4] & ~func[3] &
                func[2] & ~func[1] & ~func[0];          //100100
   wire i_or  =  r_type & func[5] & ~func[4] & ~func[3] &
                func[2] & ~func[1] & func[0];          //100101

   wire i_xor =  r_type & func[5] & ~func[4] & ~func[3] &
                func[2] & func[1] & ~func[0];          //100110
   wire i_sll =  r_type & ~func[5] & ~func[4] & ~func[3] &
                ~func[2] & ~func[1] & ~func[0];          //000000
   wire i_srl =  r_type & ~func[5] & ~func[4] & ~func[3] &
                ~func[2] & func[1] & ~func[0];          //000010
   wire i_sra =  r_type & ~func[5] & ~func[4] & ~func[3] &
                ~func[2] & func[1] & func[0];          //000011
   wire i_jr  =  r_type & ~func[5] & ~func[4] & func[3] &
                ~func[2] & ~func[1] & ~func[0];          //001000
                
   wire i_addi = ~op[5] & ~op[4] &  op[3] & ~op[2] & ~op[1] & ~op[0]; //001000
   wire i_andi = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] & ~op[0]; //001100
   // complete by yourself.
   wire i_ori  = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] & op[0]; //001101     
   wire i_xori = ~op[5] & ~op[4] &  op[3] &  op[2] & op[1] & ~op[0]; //001110
   wire i_lw   = op[5] & ~op[4] &  ~op[3] &  ~op[2] & op[1] & op[0]; //100011
   wire i_sw   = op[5] & ~op[4] &  op[3] &  ~op[2] & op[1] & op[0]; //101011
   wire i_beq  = ~op[5] & ~op[4] &  ~op[3] &  op[2] & ~op[1] & ~op[0]; //000100
   wire i_bne  = ~op[5] & ~op[4] &  ~op[3] &  op[2] & ~op[1] & op[0]; //000101
   wire i_lui  = ~op[5] & ~op[4] &  op[3] &  op[2] & op[1] & op[0]; //001111
   wire i_j    = ~op[5] & ~op[4] &  ~op[3] &  ~op[2] & op[1] & ~op[0]; //000010
   wire i_jal  = ~op[5] & ~op[4] &  ~op[3] &  ~op[2] & op[1] & op[0]; //000011
   
  
   assign pcsource[1] = i_jr | i_j | i_jal;
   assign pcsource[0] = ( i_beq & z ) | (i_bne & ~z) | i_j | i_jal ;
   
   assign wreg = i_add | i_sub | i_and | i_or   | i_xor  |
                 i_sll | i_srl | i_sra | i_addi | i_andi |
                 i_ori | i_xori | i_lw | i_lui  | i_jal;
   // complete by yourself.
   assign aluc[3] = i_sra;
   assign aluc[2] = i_sub | i_or | i_sra | i_srl | i_ori;
   assign aluc[1] = i_xor | i_sll | i_sra | i_srl | i_xori;
   assign aluc[0] = i_and | i_or | i_sll | i_sra | i_srl | i_andi | i_ori;
   assign shift   = i_sll | i_srl | i_sra ;
	// complete by yourself.
   assign aluimm  = i_addi | i_andi | i_ori | i_xori | i_lw | i_sw | i_lui;
   assign sext    = i_addi | i_lw | i_sw | i_beq | i_bne;
   assign wmem    = i_sw;
   assign m2reg   = i_lw;
   assign regrt   = i_addi | i_andi | i_ori | i_xori | i_lw | i_sw;
   assign jal     = i_jal;

endmodule
```

#### 2. ALU设计

ALU则应根据CU给出的aluc控制信号决定对输入的数据执行什么操作，代码设计相对简单，具体如下：

```veri
module alu (a,b,aluc,s,z);
   input [31:0] a,b;
   input [3:0] aluc;
   output [31:0] s;
   output        z;
   reg [31:0] s;
   reg        z;
   always @ (a or b or aluc) 
      begin                                   // event
         casex (aluc)
             4'bx000: s = a + b;              //x000 ADD
             4'bx100: s = a - b;              //x100 SUB
             4'bx001: s = a & b;              //x001 AND
             4'bx101: s = a | b;              //x101 OR
             4'bx010: s = a ^ b;              //x010 XOR
             4'bx110: s = b << 16;              //x110 LUI: imm << 16bit             
             4'b0011: s = b << a;              //0011 SLL: rd <- (rt << sa)
             4'b0111: s = b >> a;              //0111 SRL: rd <- (rt >> sa) (logical)
             4'b1111: s = $signed(b) >>> a;   //1111 SRA: rd <- (rt >> sa) (arithmetic)
             default: s = 0;
         endcase
         if (s == 0 )  z = 1;
            else z = 0;
      end
endmodule 
```

#### 3. 顶层代码

其于各组件较为简单，并且老师给出的代码中也均较为完整，在此就不展示了。在完成了各模块的设计之后，建立顶层文件，将各个模块连接起来，代码如下：

```verilog
module  sc_computer ( resetn, clock, mem_clk, pc, inst, aluout, memout,
						in_port0,in_port1,hex0,hex1,hex2,hex3,hex4,hex5,leds); 

	input	  [4:0]  in_port0,in_port1;
	input  resetn,clock,mem_clk;  


	output  [31:0]  pc, inst, aluout, memout;  
	output [6:0] hex0,hex1,hex2,hex3,hex4,hex5;
	output [9:0] leds;
	
			
	wire   [31:0]   data;   
	wire   [31:0]	 out_port0,out_port1,out_port2,out_port3,out_port4,out_port5;
	wire          wmem;  
	wire			  imem_clk,dmem_clk; 
	sc_cpu  cpu (clock,resetn,inst,memout,pc,wmem,aluout,data);   


	sc_instmem  imem (pc,inst,clock,mem_clk,imem_clk);       

	sc_datamem  dmem (aluout,data,memout,wmem,clock,mem_clk,dmem_clk,resetn,
							out_port0,out_port1,out_port2,out_port3,out_port4,out_port5,in_port0,in_port1); 				
	sevenseg sevenseg5(out_port5[3:0],hex5);
   sevenseg sevenseg4(out_port4[3:0],hex4);
   sevenseg sevenseg3(out_port3[3:0],hex3);
	sevenseg sevenseg2(out_port2[3:0],hex2);
   sevenseg sevenseg1(out_port1[3:0],hex1);
   sevenseg sevenseg0(out_port0[3:0],hex0);
	
	assign leds = {in_port1,in_port0};
	//有需要可扩展
endmodule
module sevenseg ( data, ledsegments);
input [3:0] data;
output ledsegments;
reg [6:0] ledsegments;
always @ (*)
case(data)
// gfe_dcba // 7 段 LED 数码管的位段编号
// 654_3210 // DE2 板上的信号位编号
4'h0: ledsegments = 7'b100_0000; // DE2C 板上的数码管为共阳极接法。
4'h1: ledsegments = 7'b111_1001;
4'h2: ledsegments = 7'b010_0100;
4'h3: ledsegments = 7'b011_0000;
4'h4: ledsegments = 7'b001_1001;
4'h5: ledsegments = 7'b001_0010;
4'h6: ledsegments = 7'b000_0010;
4'h7: ledsegments = 7'b111_1000;
4'h8: ledsegments = 7'b000_0000;
4'h9: ledsegments = 7'b001_0000;
default: ledsegments = 7'b111_1111; // 其它值时全灭。
endcase
endmodule
```

### 2. IO扩展

在完成了CPU基本设计之后并根据老师给出的指令以及数据仿真完成之后，便需要设计IO，与外部设备进行交互，而输入输出端口则是以上代码中的in_port以及out_port。

#### 1. 编址方式

要实现扩展IO，首先要对IO设备以及存储器设别地址进行设置，或是专门给IO分一块地址值，或是采用统一编址，根据实验要求，我们需要采用统一编址的方式设计IO。根据实验指导书，我决定采用其建议方式，通过地址的第七位判断是与内部存储器交互还是同外部设备交互，如果地址第七位是1，则与外部设备交互，如果为0则与内部存储器交互。

#### 2. sc_datamem修改

在决定了编址方式以后，我们需要修改代码来实现对外部设备的读数和写入，这一点我们可以通过修改sc_datamem实现，在sc_datamem中，判定地址第七位是0还是1，从未决定是对内部存储器还是外部设备交互，同时结合we信号决定执行写操作还是执行读操作。同时应新加入两个模块，分别对应外部 输入设备和外部输出设备，代码如下：

```verilog
module sc_datamem (addr,datain,dataout,we,clock,mem_clk,dmem_clk,clrn,
						 out_port0,out_port1,out_port2,out_port3,out_port4,out_port5,in_port0,in_port1);
 
   input  [31:0]  addr;
   input  [31:0]  datain;
	input	 [4:0]	in_port0,in_port1;
	input          we, clock,mem_clk,clrn;
	
   output [31:0]  dataout;
   output [31:0]	out_port0,out_port1,out_port2,out_port3,out_port4,out_port5;
	output         dmem_clk;

	wire [31:0]	mem_dataout;
	wire [31:0]	io_read_data;
   wire           dmem_clk;    
   wire           write_enable; 
   wire				write_datamem_enable;
	wire				write_io_output_reg_enable;

	assign         write_enable = we & (~clock); 
   assign         dmem_clk = mem_clk & ( ~ clock) ; 
   assign			write_datamem_enable = write_enable & (~addr[7]);
	assign			write_io_output_reg_enable = write_enable & addr[7];
	
	mux2x32				mem_io_output_mux(mem_dataout,io_read_data,addr[7],dataout);	
   lpm_ram_dq_dram	dram(addr[6:2],dmem_clk,datain,write_datamem_enable,mem_dataout);
	io_output_reg		io_output_regx2(addr,datain,write_io_output_reg_enable,dmem_clk,clrn,out_port0,out_port1,out_port2,out_port3,out_port4,out_port5);
	io_input_reg		io_input_regx2(addr,dmem_clk,io_read_data,in_port0,in_port1);

endmodule 
```

```verilog
module io_input_reg(addr,io_clk,io_read_data,in_port0,in_port1);
	
	input		[31:0]	addr;
	input		[4:0]	in_port0,in_port1;
	input					io_clk;
	
	output	[31:0]	io_read_data;

	reg		[31:0]	in_reg0,in_reg1;
	
	io_input_mux		io_input_mux2x32(in_reg0,in_reg1,addr[7:2],io_read_data);
	
	always @(posedge io_clk)
		begin
			in_reg0 <= {27'b0,in_port0};
			in_reg1 <= {27'b0,in_port1};
		end

endmodule

module	io_input_mux(a0,a1,sel_addr,y);
	input		[31:0]	a0,a1;
	input		[5:0]		sel_addr;
	output	[31:0]	y;
	
	reg		[31:0]	y;
	
	always @ *
		case(sel_addr)
			6'b110000: y = a0;
			6'b110001: y = a1;
		endcase
endmodule
```

```verilog
module io_output_reg(addr,datain,write_io_enable,io_clk,clrn,out_port0,out_port1,out_port2,out_port3,out_port4,out_port5);
	
	input		[31:0]	addr,datain;
	input				write_io_enable,io_clk;
	input				clrn;
	
	output	[31:0]	out_port0,out_port1,out_port2,out_port3,out_port4,out_port5;
	
	reg		[31:0]	out_port0,out_port1,out_port2,out_port3,out_port4,out_port5;
	
	always @(posedge io_clk or negedge clrn)
		begin
			if(clrn == 0)
				begin
					out_port0 <= 0;
					out_port1 <= 0;
					out_port2 <= 0;
					out_port3 <= 0;
					out_port4 <= 0;
					out_port5 <= 0;
				end
			else
				begin
					if(write_io_enable == 1)
						case(addr[7:2])
							6'b100000: out_port0 <= datain;
							6'b100001: out_port1 <= datain;
							6'b100010: out_port2 <= datain;
							6'b100011: out_port3 <= datain;
							6'b100100: out_port4 <= datain;
							6'b100101: out_port5 <= datain;
						endcase
				end			
		end

endmodule
```

至此IO扩展部分设计完成，在我设计的如下指令的IO测试下，结果显示良好。

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
 8 : 20090000;        % (20) loop: addi   $9, $0, 0   #  %
 9 : 200a0000;        % (24)       addi   $10, $0, 0  #  %
 A : 8ce90000;        % (28)       lw   $9, 0($7)     #  %
 B : 8d0a0000;        % (2c)       lw  $10, 0($8)     #  %
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

经过本次实验我对单周期CPU的结构有了更深的了解，在实践的基础上对理论的认识更加深刻，同时能够较为熟练的使用verilog语言和quartusII以及modelsim进行设计与验证。
module  sc_computer ( resetn, clock, mem_clk, pc, inst, aluout, memout,
						in_port0,hex5); 

	input	  [7:0]  in_port0;
	input  resetn,clock,mem_clk;  


	output  [31:0]  pc, inst, aluout, memout;  
	output [6:0] hex5;
	
			
	wire   [31:0]   data;   
	wire   [31:0]	 out_port;
	wire          wmem;  
	wire			  imem_clk,dmem_clk; 
	sc_cpu  cpu (clock,resetn,inst,memout,pc,wmem,aluout,data);   


	sc_instmem  imem (pc,inst,clock,mem_clk,imem_clk);       

	sc_datamem  dmem (aluout,data,memout,wmem,clock,mem_clk,dmem_clk,resetn,
							out_port,in_port0); 				
	sevenseg sevenseg5(out_port[3:0],hex5);
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

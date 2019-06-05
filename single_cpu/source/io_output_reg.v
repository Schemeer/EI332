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
module io_output_reg(addr,datain,write_io_enable,io_clk,clrn,out_port);
	
	input		[31:0]	addr,datain;
	input				write_io_enable,io_clk;
	input				clrn;
	
	output	[31:0]	out_port;
	
	reg		[31:0]	out_port;
	
	always @(posedge io_clk or negedge clrn)
		begin
			if(clrn == 0)
				begin
					out_port <= 0;
				end
			else
				begin
					if(write_io_enable == 1)
						case(addr[7:2])
							6'b100000: out_port <= datain;
						endcase
				end			
		end

endmodule
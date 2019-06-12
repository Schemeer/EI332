module fiftyMto100ms(clk,CLOCK);
	input clk;
	output CLOCK;
	reg [31:0]	count;
	reg			CLOCK;
	
	initial
		begin
			count = 0;
			CLOCK = 1;
		end
	
	always @ (posedge clk)
		begin
			if(count == 5000000)
				begin
					count = 0;
					CLOCK = ~CLOCK;
				end
			count = count + 1;
		end
endmodule

module half_frequency
(clk,CLOCK);
	input clk;
	output CLOCK;
	reg			count;
	reg			CLOCK;
	
	initial
		begin
			count = 0;
			CLOCK = 1;
		end
	
	always @ (posedge clk)
		begin
			if(count)
				begin
					count = 0;
					CLOCK = ~CLOCK;
				end
			count = 1;
		end
endmodule
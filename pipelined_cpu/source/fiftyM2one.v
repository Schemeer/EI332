module fiftyM2one(CLOCK_50, clk);
	input CLOCK_50;
	output reg clk;
	reg [31:0] counter;
	
	initial
	begin
		counter <= 0;
		clk <= 1;
	end
	
	always @ (posedge CLOCK_50)
	begin
		if(counter == 50000000)
		begin
			counter <= 0;
			clk <= ~clk;
		end
		counter <= counter + 1;
	end
endmodule
module inverse(clk,memclk);
	input clk;
	output memclk;
	assign memclk = ~clk;
endmodule

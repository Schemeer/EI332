module pipemwreg (	mwreg, mm2reg, mmo, malu, mrn, clock, resetn,
											wwreg, wm2reg, wmo, walu, wrn);

	input [31:0]		malu, mmo;
	input	[4:0]			mrn;
	input 				mwreg, mm2reg, clock, resetn;
	
	output reg[31:0]		wmo, walu;
	output reg[4:0]		wrn;
	output reg				wwreg, wm2reg;
	
	always @ (posedge clock)
	begin
		if(~resetn)
		begin
			wwreg <= 0;
			wm2reg <= 0;
			wmo <= 0;
			walu <= 0;
			wrn <= 0;
		end
		else
		begin
			wwreg <= mwreg;
			wm2reg <= mm2reg;
			wmo <= mmo;
			walu <= malu;
			wrn <= mrn;
		end
	end
endmodule
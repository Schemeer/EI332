module pipeexe (	ealuc, ealuimm, ea, eb, eimm, esa, eshift, ern0, epc4, ejal, ern, ealu );  

	input	[31:0]	ea, eb, eimm, epc4, esa;
	input	[4:0]		ern0;
	input	[3:0]		ealuc;
	input				ealuimm, eshift, ejal;
	
	output[31:0]	ealu;
	output[4:0]		ern;
	
	wire [31:0] alua,alub,aluout,epc8;
	
	assign epc8 = epc4 + 32'h4;
	
	mux2x32 alu_b(eb,eimm,ealuimm,alub);
	mux2x32 alu_a(ea,esa,eshift,alua);
	alu agorithm_logic_unit(alua,alub,ealuc,aluout);
	mux2x32 call_sub(aluout,epc4,ejal,ealu);
	assign ern = ern0 | {5{ejal}};
endmodule
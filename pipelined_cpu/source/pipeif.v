module pipeif (	pcsource, pc, bpc, da, jpc, npc, pc4, ins, mem_clock );  
	input [1:0]		pcsource;
	input [31:0]	pc, bpc, da, jpc;
	input 			mem_clock;
	output [31:0]	pc4, ins, npc;
	
	wire [31:0]		fetched_ins;
	irom irom_inst(pc[7:2], mem_clock, fetched_ins);
	assign ins = pcsource[0]? 32'h0:fetched_ins;
	assign pc4 = pc + 32'h4;
	mux4x32	newpc(pc4, bpc, da, jpc, pcsource, npc);
endmodule
module pipeid (	mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst,
						wrn, wdi, ealu, malu, mmo, wwreg, clock, resetn,
						bpc, jpc, pcsource, wpcir, dwreg, dm2reg, dwmem, daluc,
						daluimm, da, db, dimm, drn, dshift, djal, dsa );
	
	
	input [31:0]	dpc4, inst, wdi, ealu, malu, mmo;
	input [4:0]		mrn, ern, wrn;
	input 			mwreg, ewreg, em2reg, mm2reg, wwreg, clock, resetn;
	
	output [31:0]	bpc, jpc, da, db, dimm, dsa;
	output [4:0]	drn;
	output [3:0]	daluc;
	output [1:0]	pcsource;
	output			wpcir, dwreg, dm2reg, dwmem, daluimm, dshift,djal;
	
	wire dregrt, sext;
	wire [1:0]	fwda, fwdb;
	
	wire z = ~|(da^db); //a==b?1:0
	
	wire	[5:0] 	op =		inst[31:26];
	wire	[4:0] 	rs =		inst[25:21];
	wire	[4:0] 	rt =		inst[20:16];
	wire	[4:0] 	rd =		inst[15:11];
	
	wire	[5:0]		func =	inst[5:0];
	
	wire	[31:0]	qa, qb;

	wire	[3:0]		daluc_tmp;
	wire	dwmem_tmp, dwreg_tmp, dm2reg_tmp, dshift_tmp, daluimm_tmp, djal_tmp;
	assign dsa =  { 27'b0, inst[10:6] };
	
	pipecu	pcu(	op, func, z, dwmem_tmp, dwreg_tmp, dregrt, dm2reg_tmp, daluc_tmp, dshift_tmp,
						daluimm_tmp, pcsource, djal_tmp, sext);
	
	regfile rf(rs, rt, wdi, wrn, wwreg, clock, resetn, qa, qb);
	
	assign	wpcir = ~(em2reg & ((ern == rs)|(ern == rt)) & ~dwmem_tmp);
	assign	dwreg = wpcir?dwreg_tmp:1'b0;
	assign	dm2reg = wpcir?dm2reg_tmp:1'b0;
	assign	dwmem = wpcir?dwmem_tmp:1'b0;
	assign	daluimm = wpcir?daluimm_tmp:1'b0;
	assign	dshift = wpcir?dshift_tmp:1'b0;
	assign	djal = wpcir?djal_tmp:1'b0;
	assign	daluc = wpcir?daluc_tmp:4'b0;
	assign	drn = dregrt?rt:rd;
	assign	jpc = {dpc4[31:28],inst[25:0],2'b0};
	
	wire		e = sext&inst[15];
	wire	[15:0] 	imm = {16{e}};
	wire	[31:0] 	offset = {imm[13:0], inst[15:0], 2'b0};
	
	assign dimm = {imm, inst[15:0]};
	assign bpc = dpc4 + offset;
	
	assign fwda[0] = (ewreg & ~em2reg & ern == rs & ern != 0) | (mm2reg & mrn == rs & mrn != 0);
	assign fwda[1] = (mwreg & ~mm2reg & mrn == rs & ern != rs & mrn != 0) | (mm2reg & mrn == rs & mrn != 0); 
	assign fwdb[0] = (ewreg & ~em2reg & ern == rt & ern != 0) | ( mm2reg & mrn == rt & mrn != 0);
	assign fwdb[1] = (mwreg & ~mm2reg & mrn == rt & ern != rt & mrn != 0) | (mm2reg & mrn == rt & mrn != 0); 
	
	
	mux4x32 forwarding_da(qa,ealu,malu,mmo,fwda,da);
	mux4x32 forwarding_db(qb,ealu,malu,mmo,fwdb,db);
	
endmodule
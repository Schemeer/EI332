module pipemem (	mwmem, malu, mb, clock, clrn, mem_clock, mmo, in_port0, in_port1, out_port0, out_port1, out_port2, out_port3, out_port4, out_port5);   

	input [31:0]	malu, mb;
	input [3:0]		in_port0, in_port1;
	input 			mwmem, clock, clrn, mem_clock;
	
	output[31:0]	mmo, out_port0, out_port1, out_port2, out_port3, out_port4, out_port5;
	
	wire 				write_datamem_enable, write_io_output_reg_enable;
	wire [31:0]		mem_dataout, io_read_data;
	
	assign write_datamem_enable = mwmem & ~malu[7];
	assign write_io_output_reg_enable = mwmem & malu[7];
	
	mux2x32				mem_io_output_mux(mem_dataout, io_read_data, malu[7], mmo);	
   dram					dram_inst(malu[6:2],	mem_clock, mb, write_datamem_enable, mem_dataout);
	io_output_reg		io_output_regx2(malu, mb, write_io_output_reg_enable, mem_clock, clrn, out_port0, out_port1, out_port2, out_port3, out_port4, out_port5);
	io_input_reg		io_input_regx2(malu, mem_clock, io_read_data, in_port0, in_port1);
	
endmodule
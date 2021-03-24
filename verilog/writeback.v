module writeback(
	output [15:0] Writeback_data,
	input  [15:0] Memory_read_data,		
	input  [15:0] PC_Inc,		
	input  [15:0] ALU_Out,	
	input MemToReg_cntrl,
	input PcToReg_cntrl
);	
	assign Writeback_data = PcToReg_cntrl ? PC_Inc :
		MemToReg_cntrl ? Memory_read_data : ALU_Out;
endmodule

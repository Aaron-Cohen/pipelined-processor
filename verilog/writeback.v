module writeback(
	output wire [15:0] Writeback_data,
	input  wire [15:0] Memory_read_data,		
	input  wire [15:0] PC_Inc,		
	input  wire [15:0] ALU_Out,	
	input  wire MemToReg_cntrl,
	input  wire PcToReg_cntrl
);	
	assign Writeback_data = PcToReg_cntrl ? PC_Inc :
		MemToReg_cntrl ? Memory_read_data : ALU_Out;
endmodule

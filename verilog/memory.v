module memory(
	output [15:0] Memory_read_data,
	input  [15:0] ALU_Out,
	input  [15:0] Read2data,
	input MemWrite_cntrl,
	input MemRead_cntrl,
	input Halt_cntrl,
       	input clk,
	input rst	
);
	memory2c Data_Memory(.data_out(Memory_read_data), .data_in(Read2data), .createdump(Halt_cntrl),
		.addr(ALU_Out), .enable(MemRead_cntrl | MemWrite_cntrl), .wr(MemWrite_cntrl), .clk(clk), .rst(rst));

endmodule

`default_nettype none
module decode(
	output wire [15:0] Read1data,
	output wire[15:0] Read2data,
	output wire err,
	output wire Jump_cntrl,
	output wire Branch_cntrl,
	output wire MemRead_cntrl,
	output wire MemToReg_cntrl,
	output wire MemWrite_cntrl,
	output wire PcToReg_cntrl,
	output wire RegToPc_cntrl,
	output wire RegWrite_cntrl,
	output wire ALU_InvA_cntrl,
	output wire ALU_InvB_cntrl,
	output wire ALU_Cin_cntrl,
	output wire SIIC_cntrl,
	output wire Halt_cntrl,
	output wire [3:0] ALUOp_cntrl,
	output wire [1:0] ALUSrc_cntrl,
	output wire [2:0]  Write_reg_sel_out,
	input  wire [15:0] Instruction,
	input  wire [15:0] Writeback_data,
	input  wire [2:0]  Write_reg_sel_in,
	input  wire [8:0]  Forwarding_vector,
	input  wire [47:0] Forwarding_data,
	input  wire	   RegWrite_cntrl_in,
	input  wire	   Valid_PC,
	input  wire clk,
	input  wire rst
);

wire control_err, register_err;
assign err = control_err | register_err;

// control module
wire [1:0] regDst_cntrl;
control control(
	// Inputs
	.Valid_PC(Valid_PC),
	.Opcode(Instruction[15:11]),
	.Mode(Instruction[1 : 0]),
	// Outputs
	.ALUOp(ALUOp_cntrl),
	.ALUSrc(ALUSrc_cntrl),
	.RegDst(regDst_cntrl),
	.Jump(Jump_cntrl),
	.Branch(Branch_cntrl),
	.MemRead(MemRead_cntrl),
	.MemToReg(MemToReg_cntrl),
	.MemWrite(MemWrite_cntrl),
	.RegWrite(RegWrite_cntrl),
	.PcToReg(PcToReg_cntrl),
	.RegToPc(RegToPc_cntrl),
	.ALU_InvA(ALU_InvA_cntrl),
	.ALU_InvB(ALU_InvB_cntrl),
	.ALU_Cin(ALU_Cin_cntrl),
	.SIIC(SIIC_cntrl),
	.Halt(Halt_cntrl),
	.err(control_err)
);
// TODO - maybe add detection for branches here, like page 351 of textbook
// although currently this is done in execute phase

// Mux the write register input
assign Write_reg_sel_out = PcToReg_cntrl ? 3'h7 :
	regDst_cntrl[1] ? Instruction[10:8] :
        regDst_cntrl[0]	? Instruction[4:2]  : Instruction[7:5];

// EPC feeds back its output when exception is not asserted, only updated when
// exception. Writeback data will be the PC+2 from PcToReg being asserted.
wire[15:0] EPC;
dff EPC_reg [15:0]( .q(EPC), .d(SIIC_cntrl ? Writeback_data : EPC), .rst(rst), .clk(clk));

// Only use the value from the registers when the current register being read
// from is not being written to later down the pipeline. If so, grab
// the earliest one in (i.e. execute, then memory, then writeback)
wire [15:0] read1data, read2data;

assign Read1data = 	
			SIIC_cntrl ? EPC : 
			Instruction[10:8] == Forwarding_vector[2:0] ?	Forwarding_data[15:0]  :
			Instruction[10:8] == Forwarding_vector[5:3] ?	Forwarding_data[31:16] :
			Instruction[10:8] == Forwarding_vector[8:6] ? 	Forwarding_data[47:32] :
									read1data;

assign Read2data =	
			Instruction[7:5] == Forwarding_vector[2:0] ?	Forwarding_data[15:0]  :
			Instruction[7:5] == Forwarding_vector[5:3] ?	Forwarding_data[31:16] :
			Instruction[7:5] == Forwarding_vector[8:6] ? 	Forwarding_data[47:32] :
									read2data;

// Register center with bypass to read/write same data concurrently
rf registers(.read1data(read1data), .read2data(read2data), .err(register_err),
	.clk(clk), .rst(rst), .read1regsel(Instruction[10:8]), .read2regsel(Instruction[7:5]),
	.writeregsel(Write_reg_sel_in), .writedata(Writeback_data), .write(RegWrite_cntrl_in));

endmodule
`default_nettype wire

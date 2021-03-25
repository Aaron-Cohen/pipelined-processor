module decode(
	output [15:0] Read1data,
	output [15:0] Read2data,
	output err,
	output Jump_cntrl,
	output Branch_cntrl,
	output MemRead_cntrl,
	output MemToReg_cntrl,
	output MemWrite_cntrl,
	output PcToReg_cntrl,
	output RegToPc_cntrl,
	output ALU_InvA_cntrl,
	output ALU_InvB_cntrl,
	output ALU_Cin_cntrl,
	output SIIC_cntrl,
	output Halt_cntrl,
	output [3:0] ALUOp_cntrl,
	output [1:0] ALUSrc_cntrl,
	input  [15:0] Instruction,
	input  [15:0] Writeback_data,
	input  clk,
	input  rst
);

// TODO - in pipelined version, RegWrite_cntrl will have to be outputted from
// decode as it will be the signal from writeback stage that controls it for
// decode stage`
wire control_err, register_err, RegWrite_cntrl;
assign err = control_err | register_err;

// control module
wire [1:0] regDst_cntrl;
control control(
	// Inputs
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
wire [2:0] write_reg_sel;
assign write_reg_sel = PcToReg_cntrl ? 3'h7 :
	regDst_cntrl[1] ? Instruction[10:8] :
        regDst_cntrl[0]	? Instruction[4:2]  : Instruction[7:5];

// EPC feeds back its output when exception is not asserted, only updated when
// exception. Writeback data will be the PC+2 from PcToReg being asserted.
wire[15:0] EPC;
dff EPC_reg [15:0]( .q(EPC), .d(SIIC_cntrl ? Writeback_data : EPC), .rst(rst), .clk(clk));

wire [15:0] r1data;
assign Read1data = SIIC_cntrl ? EPC : r1data;

// Register center with bypass to read/write same data concurrently
rf registers(.read1data(r1data), .read2data(Read2data), .err(register_err),
	.clk(clk), .rst(rst), .read1regsel(Instruction[10:8]), .read2regsel(Instruction[7:5]),
	.writeregsel(write_reg_sel), .writedata(Writeback_data), .write(RegWrite_cntrl));

endmodule

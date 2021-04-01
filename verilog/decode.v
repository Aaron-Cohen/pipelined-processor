`default_nettype none
module decode(
	output wire [15:0] Read1data,
	output wire[15:0] Read2data,
	output wire err,
	output wire Load_warning_a,
	output wire Load_warning_b,
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
	output wire ValidFwd_cntrl,
	output wire [3:0] ALUOp_cntrl,
	output wire [1:0] ALUSrc_cntrl,
	output wire [2:0]  Write_reg_sel_out,
	input  wire [15:0] Instruction,
	input  wire [15:0] Writeback_data,
	input  wire [2:0]  Write_reg_sel_in,
	input  wire [11:0]  Forwarding_vector,
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
	.ValidFwd(ValidFwd_cntrl),
	.err(control_err)
);
// TODO - maybe add detection for branches here, like page 351 of textbook
// although currently this is done in execute phase

/*
* Forwarding has an issue with a load that is immediately
* followed by a read on that register. When that read occurs,
* the load is still in execute so no forwarding can occur from 
* memory.
*
* load_warning tells execute in next clk cycle, when this instruction
* is there, to overwrite whatever Read1data value is with the memory value
*
* Only consider input b in the case where its R format, without immediate 
* 
* This has a special forwarding path from memory 
*/
wire load_warning, load_warning_ff;
assign load_warning = Instruction[15:11] == 5'b10001;
dff load_warn_ff(.clk(clk), .rst(rst), .d(load_warning), .q(load_warning_ff));
assign Load_warning_a = load_warning_ff & (Instruction[10:8] == Forwarding_vector[2:0]);
assign Load_warning_b = load_warning_ff & (Instruction[7:5]  == Forwarding_vector[2:0]) & (ALUSrc_cntrl == 1'b0); 

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
			Forwarding_vector[3 ] & (Instruction[10:8] == Forwarding_vector[2:0]) ? Forwarding_data[15:0]  :
			Forwarding_vector[7 ] & (Instruction[10:8] == Forwarding_vector[6:4]) ? Forwarding_data[31:16] :
			Forwarding_vector[11] & (Instruction[10:8] == Forwarding_vector[10:8]) ? Forwarding_data[47:32] :
												read1data;

assign Read2data =	
			Forwarding_vector[3 ] & (Instruction[7:5] == Forwarding_vector[2:0]) ? Forwarding_data[15:0]  :
			Forwarding_vector[7 ] & (Instruction[7:5] == Forwarding_vector[6:4]) ? Forwarding_data[31:16] :
			Forwarding_vector[11] & (Instruction[7:5] == Forwarding_vector[10:8]) ? Forwarding_data[47:32] :
												read2data;
// Register center with bypass to read/write same data concurrently
rf_bypass registers(.read1data(read1data), .read2data(read2data), .err(register_err),
	.clk(clk), .rst(rst), .read1regsel(Instruction[10:8]), .read2regsel(Instruction[7:5]),
	.writeregsel(Write_reg_sel_in), .writedata(Writeback_data), .write(RegWrite_cntrl_in));

endmodule
`default_nettype wire

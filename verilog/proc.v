`default_nettype none
/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input wire clk;
   input wire rst;

   output wire err;

   // None of the above lines can be modified
// TODO - must remove wire from module declaration and the compiler directive
// TODO - at top for default net type. The above shouldn't be modified
wire [3:0] ALUOp_cntrl;
wire [1:0] ALUSrc_cntrl;
wire Jump_cntrl, Branch_cntrl, MemRead_cntrl, MemToReg_cntrl,
	MemWrite_cntrl, PcToReg_cntrl, RegToPc_cntrl,
	ALU_InvA_cntrl, ALU_InvB_cntrl, ALU_Cin_cntrl, Halt_cntrl,
	SIIC_cntrl, PCSrc_cntrl, Valid_PC;

wire Halt_cntrl_p2, Halt_cntrl_p3, Halt_cntrl_p4, Valid_PC_p1;
wire [15:0] Instruction, PC_Inc, PC_Next, ALU_Out;
wire [15:0] Instruction_p1, PC_Inc_p1;
wire [15:0] Read2data_p3, ALU_Out_p3, PC_Inc_p3;
wire MemRead_cntrl_p3, MemToReg_cntrl_p3, MemWrite_cntrl_p3, RegToPc_cntrl_p3, PcToReg_cntrl_p3;
wire [11:0]  Forwarding_vector;
wire [47:0] Forwarding_data;

wire [15:0] Read1data, Read2data, Writeback_data;
wire [2:0] Write_reg_sel, Write_reg_sel_p2, Write_reg_sel_p3, Write_reg_sel_p4; 
wire	   RegWrite_cntrl, RegWrite_cntrl_p2, RegWrite_cntrl_p3, RegWrite_cntrl_p4;
wire [3:0] ALUOp_cntrl_p2;
wire [1:0] ALUSrc_cntrl_p2;
wire [15:0] Read1data_p2, Read2data_p2, Writeback_data_p2, Instruction_p2, PC_Inc_p2;
wire Jump_cntrl_p2, Branch_cntrl_p2, MemRead_cntrl_p2, MemToReg_cntrl_p2,
	MemWrite_cntrl_p2, PcToReg_cntrl_p2, RegToPc_cntrl_p2,
	ALU_InvA_cntrl_p2, ALU_InvB_cntrl_p2, ALU_Cin_cntrl_p2,
	SIIC_cntrl_p2;
wire [15:0] Memory_read_data;
wire [15:0] Memory_read_data_p4, PC_Inc_p4, ALU_Out_p4;
wire MemToReg_cntrl_p4, PcToReg_cntrl_p4;
fetch fetch(
	// Outputs
	.Instruction(Instruction),
	.PC_Inc(PC_Inc),
	.Valid_PC(Valid_PC),
	// Inputs
	.PC_Next(PC_Next),
	.ALU_Out(ALU_Out),
	.RegToPc_cntrl(RegToPc_cntrl),
	.PCSrc_cntrl(PCSrc_cntrl),
	.Halt_cntrl(Halt_cntrl_p4),
	.SIIC_cntrl(SIIC_cntrl),
	.clk(clk),
	.rst(rst)
);

dff pipe_fetch[32:0](.clk(clk), .rst(rst | PCSrc_cntrl), .d({Instruction, PC_Inc, Valid_PC}), .q({Instruction_p1, PC_Inc_p1, Valid_PC_p1}));

/*
 * Examine what registers are being written to for each stage
 * so the decode stage can snag a value if it needs to
 * dirty bit to determine if forwarding data is valid
 * 3  | [2:0] => Execute
 * 7  | [6:4] => Memory
 * 11 |[10:8] => Writeback
 */
decode decode(
	// Decode Outputs
	.Read1data(Read1data),
	.Read2data(Read2data),
	.err(err),
	// Control Outputs
	.Jump_cntrl(Jump_cntrl),
	.Branch_cntrl(Branch_cntrl),
	.MemRead_cntrl(MemRead_cntrl),
	.MemToReg_cntrl(MemToReg_cntrl),
	.MemWrite_cntrl(MemWrite_cntrl),
	.PcToReg_cntrl(PcToReg_cntrl),
	.RegToPc_cntrl(RegToPc_cntrl),
	.RegWrite_cntrl(RegWrite_cntrl),
	.ALU_InvA_cntrl(ALU_InvA_cntrl),
	.ALU_InvB_cntrl(ALU_InvB_cntrl),
	.ALU_Cin_cntrl(ALU_Cin_cntrl),
	.ALUOp_cntrl(ALUOp_cntrl),
	.ALUSrc_cntrl(ALUSrc_cntrl),
	.Halt_cntrl(Halt_cntrl),
	.SIIC_cntrl(SIIC_cntrl),
	.Write_reg_sel_out(Write_reg_sel),
	// Inputs
	.Instruction(Instruction_p1),
	.Valid_PC(Valid_PC_p1),
	.Forwarding_vector(Forwarding_vector),
	.Forwarding_data(Forwarding_data),
	.Writeback_data(Writeback_data),
	.Write_reg_sel_in(Write_reg_sel_p4),
	.RegWrite_cntrl_in(RegWrite_cntrl_p4),
	.clk(clk),
	.rst(rst)
);


dff pipe_decode_p2[85:0](.clk(clk), .rst(rst | PCSrc_cntrl),
	.d({Read1data, Read2data, Jump_cntrl, Branch_cntrl, MemRead_cntrl, MemWrite_cntrl, PcToReg_cntrl,
		RegToPc_cntrl, ALU_InvA_cntrl, ALU_InvB_cntrl, ALU_Cin_cntrl, ALUOp_cntrl, ALUSrc_cntrl,
		SIIC_cntrl, Instruction_p1, PC_Inc_p1, RegWrite_cntrl, Write_reg_sel, MemToReg_cntrl, Halt_cntrl}),
	.q({Read1data_p2, Read2data_p2, Jump_cntrl_p2, Branch_cntrl_p2, MemRead_cntrl_p2, MemWrite_cntrl_p2, PcToReg_cntrl_p2,
		RegToPc_cntrl_p2, ALU_InvA_cntrl_p2, ALU_InvB_cntrl_p2, ALU_Cin_cntrl_p2, ALUOp_cntrl_p2, ALUSrc_cntrl_p2,
		SIIC_cntrl_p2, Instruction_p2, PC_Inc_p2, RegWrite_cntrl_p2, Write_reg_sel_p2, MemToReg_cntrl_p2, Halt_cntrl_p2}));

execute execute(
	// Outputs
	.PC_Next(PC_Next),
	.ALU_Out(ALU_Out),
	.PCSrc_cntrl(PCSrc_cntrl),
	// Inputs
	.PC_Inc(PC_Inc_p2),
	.Read1data(Read1data_p2),
	.Read2data(Read2data_p2),
	.Instruction(Instruction_p2),
	.ALUSrc_cntrl(ALUSrc_cntrl_p2),
	.Branch_cntrl(Branch_cntrl_p2),
	.Jump_cntrl(Jump_cntrl_p2),
	.ALUOp_cntrl(ALUOp_cntrl_p2),
	.ALU_InvA(ALU_InvA_cntrl_p2),
	.ALU_InvB(ALU_InvB_cntrl_p2),
	.ALU_Cin(ALU_Cin_cntrl_p2)
);


dff pipe_execute_p3[56:0](.clk(clk), .rst(rst),
	.d({ALU_Out,    MemWrite_cntrl_p2, MemRead_cntrl_p2, Read2data_p2, MemToReg_cntrl_p2, PcToReg_cntrl_p2, PC_Inc_p2, Write_reg_sel_p2, RegWrite_cntrl_p2, Halt_cntrl_p2}),
	.q({ALU_Out_p3, MemWrite_cntrl_p3, MemRead_cntrl_p3, Read2data_p3, MemToReg_cntrl_p3, PcToReg_cntrl_p3, PC_Inc_p3, Write_reg_sel_p3, RegWrite_cntrl_p3, Halt_cntrl_p3}));

memory memory(
	// Outputs
	.Memory_read_data(Memory_read_data),
	// Inputs
	.ALU_Out(ALU_Out_p3),
	.MemWrite_cntrl(MemWrite_cntrl_p3),
	.MemRead_cntrl(MemRead_cntrl_p3),
	.Halt_cntrl(Halt_cntrl_p4),
	.Read2data(Read2data_p3),
	.clk(clk),
	.rst(rst)
);

dff pipe_memory_p4[54:0](.clk(clk), .rst(rst), 
	.d({Memory_read_data,    PC_Inc_p3, ALU_Out_p3, MemToReg_cntrl_p3, PcToReg_cntrl_p3, Write_reg_sel_p3, RegWrite_cntrl_p3, Halt_cntrl_p3}),
	.q({Memory_read_data_p4, PC_Inc_p4, ALU_Out_p4, MemToReg_cntrl_p4, PcToReg_cntrl_p4, Write_reg_sel_p4, RegWrite_cntrl_p4, Halt_cntrl_p4})
);

// TODO - Something with reg write/reg dst being passed along and controlled from
// this stage perhaps? Same with writeback_data
writeback writeback(
	// Outputs
	.Writeback_data(Writeback_data),
	// Inputs
	.Memory_read_data(Memory_read_data_p4),		
	.PC_Inc(PC_Inc_p4),		
	.ALU_Out(ALU_Out_p4),	
	.MemToReg_cntrl(MemToReg_cntrl_p4),
	.PcToReg_cntrl(PcToReg_cntrl_p4)
);	

assign Forwarding_data   = {Writeback_data, ALU_Out_p3, ALU_Out};
assign Forwarding_vector = {~MemToReg_cntrl_p4, Write_reg_sel_p4, ~MemToReg_cntrl_p3, Write_reg_sel_p3, ~MemToReg_cntrl_p2, Write_reg_sel_p2};

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here */
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:

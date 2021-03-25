/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified
wire [3:0] ALUOp_cntrl;
wire [1:0] ALUSrc_cntrl;
wire Jump_cntrl, Branch_cntrl, MemRead_cntrl, MemToReg_cntrl,
	MemWrite_cntrl, RegWrite_cntrl, PcToReg_cntrl, RegToPc_cntrl,
	ALU_InvA_cntrl, ALU_InvB_cntrl, ALU_Cin_cntrl, Halt_cntrl,
	SIIC_cntrl;

wire [15:0] Instruction, PC_Inc, PC_Next, ALU_Out;
fetch fetch(
	// Outputs
	.Instruction(Instruction),
	.PC_Inc(PC_Inc),
	// Inputs
	.PC_Next(PC_Next),
	.ALU_Out(ALU_Out),
	.RegToPc_cntrl(RegToPc_cntrl),
	.SIIC_cntrl(SIIC_cntrl),
	.Halt_cntrl(Halt_cntrl),
	.clk(clk),
	.rst(rst)
);


wire [15:0] Read1data, Read2data, Writeback_data;
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
	.ALU_InvA_cntrl(ALU_InvA_cntrl),
	.ALU_InvB_cntrl(ALU_InvB_cntrl),
	.ALU_Cin_cntrl(ALU_Cin_cntrl),
	.Halt_cntrl(Halt_cntrl),
	.ALUOp_cntrl(ALUOp_cntrl),
	.ALUSrc_cntrl(ALUSrc_cntrl),
	// Inputs
	.Instruction(Instruction),
	.Writeback_data(Writeback_data),
	.SIIC_cntrl(SIIC_cntrl),
	.clk(clk),
	.rst(rst)
);

execute execute(
	// Outputs
	.PC_Next(PC_Next),
	.ALU_Out(ALU_Out),
	// Inputs
	.Read1data(Read1data),
	.Read2data(Read2data),
	.Instruction(Instruction),
	.PC_Inc(PC_Inc),
	.ALUSrc_cntrl(ALUSrc_cntrl),
	.Branch_cntrl(Branch_cntrl),
	.Jump_cntrl(Jump_cntrl),
	.ALUOp_cntrl(ALUOp_cntrl),
	.ALU_InvA(ALU_InvA_cntrl),
	.ALU_InvB(ALU_InvB_cntrl),
	.ALU_Cin(ALU_Cin_cntrl)
);


wire [15:0] Memory_read_data;
memory memory(
	// Outputs
	.Memory_read_data(Memory_read_data),
	// Inputs
	.ALU_Out(ALU_Out),
	.MemWrite_cntrl(MemWrite_cntrl),
	.MemRead_cntrl(MemRead_cntrl),
	.Halt_cntrl(Halt_cntrl),
	.Read2data(Read2data),
	.clk(clk),
	.rst(rst)
);


writeback writeback(
	// Outputs
	.Writeback_data(Writeback_data),
	// Inputs
	.Memory_read_data(Memory_read_data),		
	.PC_Inc(PC_Inc),		
	.ALU_Out(ALU_Out),	
	.MemToReg_cntrl(MemToReg_cntrl),
	.PcToReg_cntrl(PcToReg_cntrl)
);	


   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here */
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:

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
wire [11:0]  Forwarding_vector;
wire [47:0] Forwarding_data;

/*/////////////////////////////////////////////
// Pipelined signals table                  //
//                                         //
// This shows up beautifully in vim.      //
// Hopefully it shows up similarly       //
// in your text editor			//
/////////////////////////////////////////

 		Fetch		Decode			Execute			Memory			Writeback	*/
wire							PCSrc_cntrl;
wire				Load_warning_a,		Load_warning_a_p2;
wire				Load_warning_b,		Load_warning_b_p2;
wire 		Valid_PC,	Valid_PC_p1;
wire				Halt_cntrl,		Halt_cntrl_p2,		Halt_cntrl_p3,		Halt_cntrl_p4;
wire				SIIC_cntrl,		SIIC_cntrl_p2;
wire				Jump_cntrl,		Jump_cntrl_p2;
wire				Branch_cntrl,		Branch_cntrl_p2;
wire				ALU_Cin_cntrl,		ALU_Cin_cntrl_p2;
wire				ALU_InvA_cntrl,		ALU_InvA_cntrl_p2;
wire				ALU_InvB_cntrl,		ALU_InvB_cntrl_p2;
wire				MemRead_cntrl,		MemRead_cntrl_p2,	MemRead_cntrl_p3;
wire				MemWrite_cntrl,		MemWrite_cntrl_p2,	MemWrite_cntrl_p3;
wire				RegToPc_cntrl,		RegToPc_cntrl_p2,	RegToPc_cntrl_p3,	RegToPc_cntrl_p4; // TODO - remove pipelined p3/p4
wire				PcToReg_cntrl,		PcToReg_cntrl_p2,	PcToReg_cntrl_p3,	PcToReg_cntrl_p4;
wire				RegWrite_cntrl,		RegWrite_cntrl_p2,	RegWrite_cntrl_p3,	RegWrite_cntrl_p4;
wire				MemToReg_cntrl,		MemToReg_cntrl_p2,	MemToReg_cntrl_p3, 	MemToReg_cntrl_p4;
wire				ValidFwd_cntrl,		ValidFwd_cntrl_p2,	ValidFwd_cntrl_p3,	ValidFwd_cntrl_p4;
wire [1:0] 			ALUSrc_cntrl,		ALUSrc_cntrl_p2;
wire [2:0]			Write_reg_sel,		Write_reg_sel_p2,	Write_reg_sel_p3,	Write_reg_sel_p4; 
wire [3:0]			ALUOp_cntrl, 		ALUOp_cntrl_p2;
wire [15:0]						PC_Next;
wire [15:0]			Read1data,		Read1data_p2;
wire [15:0]			Read2data, 		Read2data_p2,		Read2data_p3;
wire [15:0]												Writeback_data;
wire [15:0] 	Instruction,	Instruction_p1, 	Instruction_p2;
wire [15:0]									Memory_read_data,	Memory_read_data_p4;
wire [15:0]						ALU_Out,		ALU_Out_p3,		ALU_Out_p4;
wire [15:0] 	PC_Inc,		PC_Inc_p1,		PC_Inc_p2,		PC_Inc_p3, 		PC_Inc_p4;


fetch fetch(
	// Outputs
	.Instruction(Instruction),
	.PC_Inc(PC_Inc),
	.Valid_PC(Valid_PC),
	// Inputs
	.PC_Next(PC_Next),
	.ALU_Out(ALU_Out),
	.RegToPc_cntrl(RegToPc_cntrl_p2),
	.PCSrc_cntrl(PCSrc_cntrl),
	.Halt_cntrl(Halt_cntrl_p4),
	.SIIC_cntrl(SIIC_cntrl),
	.clk(clk),
	.rst(rst)
);

dff pipe_fetch[32:0](.clk(clk), .rst(rst | PCSrc_cntrl),
	.d({Instruction,	PC_Inc,		Valid_PC}),
	.q({Instruction_p1,	PC_Inc_p1,	Valid_PC_p1})
);

decode decode(
	// Decode Outputs
	.Read1data(Read1data),
	.Read2data(Read2data),
	.err(err),
	.Load_warning_a(Load_warning_a),
	.Load_warning_b(Load_warning_b),
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
	.ValidFwd_cntrl(ValidFwd_cntrl),
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


dff pipe_decode_p2[88:0](.clk(clk), .rst(rst | PCSrc_cntrl),
	.d({	
		Read1data,
		Read2data,
		Jump_cntrl,
		Branch_cntrl,
		MemRead_cntrl,
		MemWrite_cntrl,
		PcToReg_cntrl,
		RegToPc_cntrl,
		ALU_InvA_cntrl,
		ALU_InvB_cntrl,
		ALU_Cin_cntrl,
		ALUOp_cntrl,
		ALUSrc_cntrl,
		SIIC_cntrl,
		Instruction_p1,
		PC_Inc_p1,
		RegWrite_cntrl,
		Write_reg_sel,
		MemToReg_cntrl,
		Halt_cntrl,
		ValidFwd_cntrl,
		Load_warning_a,
		Load_warning_b
	}),
	.q({
		Read1data_p2,
		Read2data_p2,
		Jump_cntrl_p2,
		Branch_cntrl_p2,
		MemRead_cntrl_p2,
		MemWrite_cntrl_p2,
		PcToReg_cntrl_p2,
		RegToPc_cntrl_p2,
		ALU_InvA_cntrl_p2,
		ALU_InvB_cntrl_p2,
		ALU_Cin_cntrl_p2,
		ALUOp_cntrl_p2,
		ALUSrc_cntrl_p2,
		SIIC_cntrl_p2,
		Instruction_p2,
		PC_Inc_p2,
		RegWrite_cntrl_p2,
		Write_reg_sel_p2,
		MemToReg_cntrl_p2,
		Halt_cntrl_p2,
		ValidFwd_cntrl_p2,
		Load_warning_a_p2,
		Load_warning_b_p2
	})
);

execute execute(
	// Outputs
	.PC_Next(PC_Next),
	.ALU_Out(ALU_Out),
	.PCSrc_cntrl(PCSrc_cntrl),
	// Inputs
	.PC_Inc(PC_Inc_p2),
	.Read1data(Read1data_p2),
	.Read2data(Read2data_p2),
	.Load_warning_a(Load_warning_a_p2),
	.Load_warning_b(Load_warning_b_p2),
	.Memory_read_data(Memory_read_data),
	.Instruction(Instruction_p2),
	.ALUSrc_cntrl(ALUSrc_cntrl_p2),
	.Branch_cntrl(Branch_cntrl_p2),
	.Jump_cntrl(Jump_cntrl_p2),
	.ALUOp_cntrl(ALUOp_cntrl_p2),
	.ALU_InvA(ALU_InvA_cntrl_p2),
	.ALU_InvB(ALU_InvB_cntrl_p2),
	.ALU_Cin(ALU_Cin_cntrl_p2)
);


dff pipe_execute_p3[58:0](.clk(clk), .rst(rst),
	.d({
		ALU_Out,   
		MemWrite_cntrl_p2, MemRead_cntrl_p2, Read2data_p2, MemToReg_cntrl_p2, PcToReg_cntrl_p2, RegToPc_cntrl_p2, PC_Inc_p2, Write_reg_sel_p2, RegWrite_cntrl_p2, Halt_cntrl_p2, ValidFwd_cntrl_p2}),
	.q({ALU_Out_p3, MemWrite_cntrl_p3, MemRead_cntrl_p3, Read2data_p3, MemToReg_cntrl_p3, PcToReg_cntrl_p3, RegToPc_cntrl_p3, PC_Inc_p3, Write_reg_sel_p3, RegWrite_cntrl_p3, Halt_cntrl_p3, ValidFwd_cntrl_p3}));

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

dff pipe_memory_p4[56:0](.clk(clk), .rst(rst), 
	.d({Memory_read_data,    PC_Inc_p3, ALU_Out_p3, MemToReg_cntrl_p3, PcToReg_cntrl_p3, RegToPc_cntrl_p3, Write_reg_sel_p3, RegWrite_cntrl_p3, Halt_cntrl_p3, ValidFwd_cntrl_p3}),
	.q({Memory_read_data_p4, PC_Inc_p4, ALU_Out_p4, MemToReg_cntrl_p4, PcToReg_cntrl_p4, RegToPc_cntrl_p4, Write_reg_sel_p4, RegWrite_cntrl_p4, Halt_cntrl_p4, ValidFwd_cntrl_p4})
);

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

/*
 * Examine what registers are being written to for each stage
 * so the decode stage can snag a value if it needs to
 * 
 * Uses a dirty bit to determine if forwarding data is valid
 * 3  => [2:0] 	=> Execute
 * 7  => [6:4] 	=> Memory
 * 11 => [10:8]	=> Writeback
 */

assign Forwarding_data   = {Writeback_data, MemToReg_cntrl_p3 ? Memory_read_data : ALU_Out_p3, ALU_Out};
assign Forwarding_vector = {
	ValidFwd_cntrl_p4, Write_reg_sel_p4,
	ValidFwd_cntrl_p3, Write_reg_sel_p3,
	ValidFwd_cntrl_p2, Write_reg_sel_p2
	};

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:

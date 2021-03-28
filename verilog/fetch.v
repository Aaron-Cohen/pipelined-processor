// Aaron Cohen 3/12/2021
module fetch(
	output [15:0] Instruction,
	output [15:0] PC_Inc,
	output	      Valid_PC,
	input  [15:0] PC_Next,
	input  [15:0] ALU_Out,
	input RegToPc_cntrl,
	input PCSrc_cntrl,
	input SIIC_cntrl,
	input Halt_cntrl,
	input clk,
	input rst
);

// Requires:
// A register to store the PC, with muxed input
// An adder to computer PC + 4
// Instruction memory module

// Mux to select which PC value to use:
wire [15:0] pc_mux;

/* RegToPc => Reg contents from ALU_Out become PC
 * SIIC    => Set PC to hardcoded 2
 * PCSrc   => Use the jump/branch PC
 * else    => Set PC to PC+2
 */
assign pc_mux =	RegToPc_cntrl 	? ALU_Out	:
		SIIC_cntrl 	? 16'h0002	:
		PCSrc_cntrl 	? PC_Next	:
				  PC_Inc;


wire [15:0] pc;
dff pc_reg[15:0](.q(pc), .d(pc_mux), .clk(clk), .rst(rst));

cla16 pc_addr_adder(.A(pc), .B(16'h0002), .Cin(1'b0), .Cout(), .S(PC_Inc));

memory2c Instruction_Memory(.data_out(Instruction), .data_in(16'hXXXX), .addr(pc), .enable(~Halt_cntrl), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));

// Used so initial reset of does not halt. Instead only halts if the PC !=
// 0 (i.e. Valid_PC is high)
assign Valid_PC = |pc;

endmodule

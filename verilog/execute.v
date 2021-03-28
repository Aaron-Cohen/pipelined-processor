module execute(
	output [15:0] PC_Next,
	output [15:0] ALU_Out,
	output	      PCSrc_cntrl,
	input  [15:0] PC_Inc,
	input  [15:0] Read1data,
	input  [15:0] Read2data,
	input  [15:0] Instruction,
	input  [1:0]  ALUSrc_cntrl,
	input  [3:0]  ALUOp_cntrl,
	input	      Branch_cntrl,
	input	      Jump_cntrl,
	input	      ALU_InvB,
	input	      ALU_InvA,
	input	      ALU_Cin
);

	wire branch; reg branch_cond;
	wire [15:0] imm_sign_ext;
	wire [15:0] pc_offset;
	wire [15:0] imm_zero_ext;
	wire [15:0] i2_sign_ext;
	wire [15:0] d_sign_ext;
	wire [15:0] addr_offset;

	// Different quantities pulled from instruction, to be chosen between
	// with muxes
	assign imm_sign_ext = {{11{Instruction[4]}}, Instruction[4:0]};
	assign imm_zero_ext = {11'h000, Instruction[4:0]};
	assign i2_sign_ext  = {{8{Instruction[7]}}, Instruction[7:0]};
	assign d_sign_ext   = {{5{Instruction[10]}}, Instruction[10:0]};
	
	assign addr_offset = branch ? i2_sign_ext : d_sign_ext;
	cla16 pc_addr_adder(.A(PC_Inc), .B(addr_offset), .Cin(1'b0), .Cout(), .S(PC_Next));

	assign PCSrc_cntrl = (branch | Jump_cntrl);

	// to branch or not to branch, that is the question
	// 
	// for branches, ALU does a subtraction. Observing
	// MSB of output gives us insight for bgtz/bltz,
	// as does the presence of a high bit for equality
	assign branch = Branch_cntrl & branch_cond;
	always @(*)
		case(Instruction[15:11])
			5'b01111 : begin // BGTZ
					branch_cond = ~ALU_Out[15];
			end
			5'b01110: begin // BLTZ
					branch_cond = ALU_Out[15];
			end
			5'b01100 : begin // BEQZ
					branch_cond = ~|ALU_Out;
			end
			5'b01101 : begin // BNEZ
					branch_cond = |ALU_Out;
			end
			default : begin
					branch_cond = 1'b0;
			end
		endcase

	wire [15:0] alu_input_mux;
	// Zero extended is used for XORI and ANDNI
	assign alu_input_mux =  (ALUSrc_cntrl == 2'b00) ? Read2data :
	       			(ALUSrc_cntrl == 2'b01) ? (Instruction[15:12] == 4'b0101 ? imm_zero_ext : imm_sign_ext) :
							  i2_sign_ext ;

	alu alu(.Out(ALU_Out), .A(Read1data), .B(alu_input_mux), .Cin(ALU_Cin),
		.Op(ALUOp_cntrl), .invA(ALU_InvA), .invB(ALU_InvB));
	
endmodule

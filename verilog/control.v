module control(
	input		 Valid_PC,
	input      [4:0] Opcode,
	input      [1:0] Mode,
	output reg [3:0] ALUOp,
	output reg [1:0] ALUSrc,
	output reg [1:0] RegDst,
	output reg Jump,
	output reg Branch,
	output reg MemRead,
	output reg MemWrite,
	output reg RegWrite,
	output reg PcToReg,
	output reg RegToPc,
	output reg ALU_InvA,
	output reg ALU_InvB,
	output reg ALU_Cin,
	output reg Halt,
	output reg SIIC,
	output reg err,
	output reg MemToReg,
	output reg ValidFwd
);

reg [3:0] shared_opcode1;
reg alu_inva, alu_invb;
always @(*) begin
	alu_invb = 1'b0;
	alu_inva = 1'b0;
	case(Mode) 
		2'b10 : begin // XOR
			shared_opcode1 = 4'b0110;
		end
		2'b11 : begin // ANDN
			shared_opcode1 = 4'b0111;
			alu_invb = 1'b1;
		end
		2'b00 : begin // ADD
			shared_opcode1 = 4'b0100;
		end
		default : begin // SUB
			alu_inva = 1'b1;
			shared_opcode1 = 4'b0100;
		end
	endcase
end

/* ALU Guide:
0000	rll	rotate left
0001	sll	shift left
0010	sra	rotate right
0011	srl	shift right logical
0100	ADD	A+B
0101	OR	A OR B
0110	XOR	A XOR B
0111	AND	A AND B
1000	BTR	BTR A
1001	SEQ	A == B
1010	SLT	A < B
1011	SLE	A <= B
1100	SCO	Carry out from adder
1101	LBI	B
1110	LBI	A<<8 | B
*/
// Set controls based on opcodes
// TODO - this next assign statement might not hold once bipelining is added
//assign MemToReg = MemRead; // If we are electing to read memory, we can assume we want to use it.
always @(*) begin
	Halt 	 = 1'b0;
	err 	 = 1'b0;
	SIIC     = 1'b0;

	// ALU Control signals
	ALU_Cin  = 1'b0;
	ALU_InvB = 1'b0;
	ALU_InvA = 1'b0;

	// Default the value of the control signals which are directly mapped
	// to a specific type of instruction
	PcToReg  = 1'b0;	// JAL, JALR
	RegToPc  = 1'b0;	// JR,  JALR
	Jump     = 1'b0;	// J*
	Branch   = 1'b0;	// B*Z
	MemRead  = 1'b0;	// Loads and load like instructions
	MemToReg = 1'b0;
	MemWrite = 1'b0;	// Store and its variants
	RegWrite = 1'b0;	// R --> R operations
	ValidFwd = 1'b1;	// Most values can be forwarded
	case(Opcode)
		////////////////////////////
		// Strange Instructions  //
		// IDK what to do here  //
		/////////////////////////
		5'b00000 : begin // HALT
			Halt = Valid_PC;
			RegDst = 2'bX;
			ALUOp = 4'bXXXX;
			ALUSrc = 2'bXX;
			ValidFwd = 1'b0;
		end
		5'b00001 : begin // NOP
			// Doesn't do anything, and we don't care about these
			// values as all writes are disabled by default. Must
			// be assigned to prevent latch synthesis though
			RegDst = 2'bXX;
			ALUOp = 4'bXXXX;
			ALUSrc = 2'bXX;
			ValidFwd = 1'b0;
		end	

		///////////////////////////////////////////////////////////////
		// I format 1 Instructions 				    //
		// -----------------------				   //
		// It is characteristic that these instructions		  //
		// have RegDst = 0 to get the Dest Reg in I[7:5]	 //
		// have ALUSrc = 1 to use immediate in ALU		//
		/////////////////////////////////////////////////////////
	
		// RegWrite = 1 for R-->R operations
		5'b01000 : begin // ADDI
			RegDst = 2'b00;		// Select write register in bits I[7:5]
			ALUOp = 4'b0100;	// ALU A+B
			ALUSrc = 2'b01;		// Use immediate as other operand in ALU
			RegWrite = 1'b1;	// Contents saved to a register
		end
		5'b01001 : begin // SUBI
			RegDst = 2'b00;
			ALUOp = 4'b0100; // ALU A+B 
			ALU_InvA = 1;
			ALU_Cin = 1;
			ALUSrc = 2'b01;
			RegWrite = 1'b1;
		end
		5'b01010 : begin // XORI
			RegDst = 2'b00;
			ALUOp = 4'b0110;// ALU XOR
			ALUSrc = 2'b01;
			RegWrite = 1'b1;
		end
		5'b01011 : begin // ANDNI
			RegDst = 2'b00;
			ALUOp = 4'b0111;// ALU AND
			ALU_InvB = 1;
			ALUSrc = 2'b01;
			RegWrite = 1'b1;
		end	
		5'b10100 : begin // ROLI
			RegDst = 2'b00;
			ALUOp = 4'b0000;// ALU rotate left
			ALUSrc = 2'b01;
			RegWrite = 1'b1;
		end
		5'b10101 : begin // SLLI
			RegDst = 2'b00;
			ALUOp = 4'b0001;// ALU shift left
			ALUSrc = 2'b01;
			RegWrite = 1'b1;
		end
		5'b10110 : begin // RORI
			RegDst = 2'b00;
			ALUOp = 4'b0010; // ALU rotate right
			ALUSrc = 2'b01;
			RegWrite = 1'b1;
		end
		5'b10111 : begin // SRLI
			RegDst = 2'b00;
			ALUOp = 4'b0011; // ALU logical shift right
			ALUSrc = 2'b01;
			RegWrite = 1'b1;
		end
		
		// Memory operations
		5'b10000 : begin // ST
			RegDst = 2'bXX;	// Don't care about RegDst as RegWrite is not asserted
			ALUOp = 4'b0100;// ALU add
			ValidFwd = 1'b0;
			MemWrite = 1'b1;
			ALUSrc = 2'b01;
		end
		5'b10001 : begin // LD
			RegDst = 2'b00;
			MemRead = 1'b1;	
			MemToReg = 1'b1;
			ValidFwd = 1'b1;
			ALUOp = 4'b0100;// ALU add
			ALUSrc = 2'b01;	
			RegWrite = 1'b1;
		end

		// This is basically doing the same thing as a store, but with
		// a writeback to a register with the ALU result
		5'b10011 : begin // STU
			RegDst = 2'b10;	
			ALUOp = 4'b0100;// ALU add
			MemWrite = 1'b1;
			ALUSrc = 2'b01;	
			RegWrite = 1'b1;
		end
	
		//////////////////////////////////////////////////////
		// R format Instructions			   //	
		// -----------------------			  //
		// It is characteristic that these instructions  //
		// have RegDst = 1 to get dest from I[4:2]	//
		// have RegWrite = 1 as they are always R-->R  //
		// have ALUSrc = 0 (if non unary operation)   //	
		///////////////////////////////////////////////


		5'b11001 : begin // BTR -  // Bit reversal done by ALU 
			RegDst = 2'b01;	
			ALUOp = 4'b1000;// ALU BTR
			ALUSrc = 2'bXX;	// Other operand in ALU unimportant as BTR is a unary operation
			RegWrite = 1'b1;// Register to register
		end	
		5'b11011 : begin // ADD SUB XOR ANDN	// ALU Control differentiates by func I[1:0]
			RegDst = 2'b01;
			ALU_InvB = alu_invb; // Inverts for ANDN and SUB,
			ALU_InvA = alu_inva; // Inverts for ANDN and SUB,
			ALU_Cin = Mode;      // Cin does not affect ANDN
			ALUOp = shared_opcode1;
			ALUSrc = 2'b00;
			RegWrite = 1'b1;
		end
		5'b11010 : begin // ROL SLL ROR SRL
			RegDst = 2'b01;
			ALUOp = {2'b00, Mode};
			ALUSrc = 2'b00;
			RegWrite = 1'b1;
		end
		5'b11100 : begin // SEQ 
			RegDst = 2'b01;
			ALUOp = 4'b1001;// ALU SEQ 
			ALUSrc = 2'b00;
			ALU_InvB = 1'b1;
			ALU_Cin = 1'b1;
			RegWrite = 1'b1;
		end
		5'b11101 : begin // SLT 
			RegDst = 2'b01;
			ALUOp = 4'b1010;// ALU SLT 
			ALUSrc = 2'b00;
			ALU_InvB = 1'b1;
			ALU_Cin = 1'b1;
			RegWrite = 1'b1;
		end
		5'b11110 : begin // SLE
			RegDst = 2'b01;
			ALUOp = 4'b1011;// ALU SLE 
			ALUSrc = 2'b00;
			ALU_InvB = 1'b1;
			ALU_Cin = 1'b1;
			RegWrite = 1'b1;
		end	
		5'b11111 : begin // SCO
			RegDst = 2'b01;
			ALUOp = 4'b1100;// ALU SCO 
			ALUSrc = 2'b00;
			RegWrite = 1'b1;
		end

		//////////////////////////////
		// I format 2 Instructions //
		////////////////////////////

		// For breaks, disable writing to register, and don't care the write mux
		5'b01100 : begin // BEQZ
			RegDst = 2'b1X;	
			Branch = 1'b1;	
			ALUOp = 4'b1111; // ALU A
			ALUSrc = 2'b10;	
		end
		5'b01101 : begin // BNEZ
			RegDst = 2'b1X;	
			Branch = 1'b1;	
			ALUOp = 4'b1111; // ALU A
			ALUSrc = 2'b10;
		end
		5'b01110 : begin // BLTZ
			RegDst = 2'b1X;	
			Branch = 1'b1;	
			ALUOp = 4'b1111; // ALU A
			ALUSrc = 2'b10;	
		end	
		5'b01111 : begin // BGEZ
			RegDst = 2'b1X;	
			Branch = 1'b1;	
			ALUOp = 4'b1111; // ALU A
			ALUSrc = 2'b10;
		end


		5'b11000 : begin // LBI 
			RegDst = 2'b10;	
			ALUOp = 4'b1101;// ALU B
			ALUSrc = 2'b10;	// Set B = immediate
			RegWrite = 1'b1;
		end
		5'b10010 : begin // SLBI
			RegDst = 2'b10;	
			ALUOp = 4'b1110;// ALU Specific Operation 
			ALUSrc = 2'b10;	// Use immediate as other operand in ALU
			RegWrite = 1'b1;
		end

		////////////////////////////
		// J Format Instructions //
		//////////////////////////

		5'b00100 : begin // J
			RegDst = 2'bXX;	// Write register doesn't matter
			Jump = 1'b1;	
			ALUOp = 4'bXXXX;
			ALUSrc = 2'bXX;	// ALU result not used
			ValidFwd = 1'b0;
		end	
		5'b00101 : begin // JR
			RegDst = 2'bXX;
			Jump = 1'b1;	// This could be a dont care because RegToPC take priority,
					// but is 1 so PcSrc assert clears pipeline of instructions after
			ALUOp = 4'b0100;// ALU add
			ALUSrc = 2'b10;	// Use immediate as other operand in ALU
			RegWrite = 1'b0;// No reg being written to
			RegToPc = 1'b1;
			ValidFwd = 1'b0;
		end
		5'b00110 : begin // JAL
			RegDst = 2'bXX;	// Write register doesn't matter
			Jump = 1'b1;	// Unconditional jump
			ALUOp = 4'bXXXX;// ALU result unused
			ALUSrc = 2'bXX;	
			RegWrite = 1'b1;
			PcToReg = 1'b1;
			ValidFwd = 1'b0;
		end
		5'b00111 : begin // JALR 
			RegDst = 2'bXX;
			Jump = 1'b1;
			ALUOp = 4'b0100; // ALU Add
			ALUSrc = 2'b10;  
			RegWrite = 1'b1;
			PcToReg = 1'b1;
			RegToPc = 1'b1;
			ValidFwd = 1'b0;
		end

		/////////////////////////////////
		// Bonus strange instructions //
		///////////////////////////////
		
		5'b00010 : begin // siic
			RegDst = 2'bXX;
			Jump = 1'b1;
			ALUSrc = 2'b10;  
			PcToReg = 1'b1;
			ValidFwd = 1'b0;
			ALUOp = 4'bXXXX;
			SIIC = 1'b1;
			PcToReg = 1'b1;
		end	
		5'b00011 : begin // NOP / RTI
			ALUOp = 4'b1111; // ALU A
			ALUSrc = 4'bXXXX;
			RegDst = 2'bXX;
			RegToPc = 1'b1;
		end
		default : begin
			err = 1'b1;
			ALUOp = 4'bXXXX;
			ALUSrc = 4'bXXXX;
			RegDst = 2'bXX;
		end
	endcase
end
endmodule

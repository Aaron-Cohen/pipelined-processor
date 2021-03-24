module alu (
	input [15:0] A,
	input [15:0] B,
	input Cin,
	input [3:0] Op,
	input invA,
	input invB,
	output [15:0] Out
); 
// Don't use A or B directly in ALU - use AA/BB which are chosen
// based on invA/invB
wire [15:0] AA, BB;
assign AA = invA ? ~A : A;
assign BB = invB ? ~B : B;

// This is messy but I think will synthesize the cleanest, although
// may cause some nasty ratsnest wire crossings ;/
wire [15:0] AA_reversed;
assign AA_reversed = {AA[0], AA[1], AA[2], AA[3], AA[4], AA[5], AA[6], AA[7],
	AA[8], AA[9], AA[10], AA[11], AA[12], AA[13], AA[14], AA[15] };

// Barrel shifter's output is used for Opcodes 0XX
wire Cout;
wire [15:0] shifter_out, cla16_out;
shifter shifter (.In(AA), .Cnt(BB[3:0]), .Op(Op[1:0]), .Out(shifter_out));
cla16 cla16 (.A(AA), .B(BB), .Cin(Cin), .Cout(Cout), .S(cla16_out));


// If needed later, could reduce amount of cases by smashing 1110 and
// 0101 together as they are both OR's, just mux AA << 8 and AA as
// choice. Also could include 1100 in there as BB | 0 = BB
wire SEQ, SLT, SLE, SCO;
assign Out =
	(Op[3:2] == 2'b00  )  ? shifter_out 	:
	(Op      == 4'b0100)  ? cla16_out	:
	(Op      == 4'b0101)  ? AA | BB		:
	(Op      == 4'b0110)  ? AA ^ BB		:
	(Op      == 4'b0111)  ? AA & BB		:
	(Op      == 4'b1000)  ? AA_reversed	:
	(Op      == 4'b1001)  ? SEQ		:
	(Op      == 4'b1010)  ? SLT		:
	(Op      == 4'b1011)  ? SLE		:
	(Op      == 4'b1100)  ? SCO		:
	(Op      == 4'b1101)  ? BB		:
	(Op 	 == 4'b1110)  ? (AA<<8) | {8'h00, BB[7:0]} : // This replaces nonsense sign extension of B with 0's
       				AA;
wire Ofl;
assign Ofl = ((AA[15] == BB[15]) & (AA[15] != cla16_out[15]));
assign SCO = Cout;
assign SLE = SEQ | SLT;
assign SEQ = ~|cla16_out;
assign SLT = cla16_out[15] ^ Ofl;

endmodule

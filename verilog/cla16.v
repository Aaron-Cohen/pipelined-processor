// Aaron Cohen - 2/19/2021
module cla16(A, B, Cin, Cout, S);
        input [15:0] A, B;	// Addends
        input Cin;		// Carry in for LSB
	output [15:0] S;	// 16 bit sum
        output Cout;		// Carry out for operation

	// Propogate/Generate/Carry vectors
	// Note that carry is offset by 1 so Cin used
	// first, C[0] second, C[3] for Cout.
	wire [3:0] P, G, C;
	cla4 adders[3:0](.A(A), .B(B), .Cin({C[2:0], Cin}), .S(S), .PG(P), .GG(G));

   	assign C = G | ( P & {C, Cin} );
	assign Cout = C[3];

endmodule

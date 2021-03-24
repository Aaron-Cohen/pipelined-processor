// Aaron Cohen - 2/19/2021
module cla4(A, B, Cin, S, PG, GG);
        input [3:0] A, B;	// Addends
        input Cin;		// Cin for LSB
	output [3:0] S;		// 4 bit sum out
        output PG, GG;		// Overal propogate/generate signal
				// for this group of four bits

	// Note that there is no Cout as Cout is not used in the
	// CLA16 hierarchy as the next Cla4 will use the PG and GG
	// signals instead of a Cout for this block.

        wire [2:0] C; 	// If Cout later wanted, make this a 4 bit [3:0] signal
			// with P and G and do "assign Cout = C[3]"
			// That is not needed for this assignment, so it is
			// ommitted.
        wire [3:0] P, G;

	// adder pieces. These addersdo not generate Cout as it is not used.
	// Doing so saves 3 AND gates and 2 OR gates per adder.
	adder adders[3:0](.A(A), .B(B), .Cin({C, Cin}), .S(S));

        // Generate signals based of bitwise and's of known bits
	assign G = A & B;

        // Propogate signals based on or's of known bits
	assign P = A | B;

	// Carry out, Group Propogate/Generate
        assign C = G | ( P & {C, Cin} );
	assign PG = &P;
	assign GG = 	( G[3] ) | 		// Theres probably a beautiful
			( P[3] & G[2] ) |	// way to do this with a vector
			( &P[3:2] & G[1] ) |	// assign statement but I can't
		       	( &P[3:1] & G[0] );	// think how and this works.

endmodule

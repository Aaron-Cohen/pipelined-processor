// Aaron Cohen - 2/19/2021
module adder(A, B, Cin, S);
	input A, B;	// Addends
	input Cin;	// Carry-in bit (also added)
	output S;	// Sum

	assign S = A ^ B ^ Cin;
	// Note there is no carry out bit here. Because this is used in a carry
	// look ahead adder and not a ripple carry adder, this hardware can be
	// spared as it would not be used

endmodule

// Aaron Cohen - 2/26/2021
module reg16(clk, rst, w_en, d, q);
	localparam bitwidth = 15; // Remember that it is from this number to 0, so 15 really is 16 bits	
	input clk;
	input rst;
	input w_en;
	input [bitwidth:0] d;
	output [bitwidth:0] q;

	
	// Recirculating mux style enable
	wire [bitwidth:0] data_in;
	assign data_in = w_en ? d : q;

	dff registers[bitwidth:0](.q(q), .d(data_in), .clk(clk), .rst(rst));

endmodule

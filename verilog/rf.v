/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
// Aaron Cohen - 2/26/2021
module rf (
           // Outputs
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
           );

	input wire clk, rst;
	input wire [2:0] read1regsel;
	input wire [2:0] read2regsel;
	input wire [2:0] writeregsel;
	input wire [15:0] writedata;
	input wire   write;

	output wire [15:0] read1data;
	output wire [15:0] read2data;
	output wire        err;

	assign err = 1'b0;

	// Current progress - looks like we are reading from the right place
	// but write the data to the wrong location. 

	wire [7:0] w_en; // One hot encoding for each write select/enable
	assign w_en = 	(write 	     == 1'b0  ) ? 8'h00:
			(writeregsel == 3'b000) ? 8'h01:
			(writeregsel == 3'b001) ? 8'h02:
			(writeregsel == 3'b010) ? 8'h04:
			(writeregsel == 3'b011) ? 8'h08:
			(writeregsel == 3'b100) ? 8'h10:
			(writeregsel == 3'b101) ? 8'h20:
			(writeregsel == 3'b110) ? 8'h40:
		    				  8'h80;

	// Hold the outputs of all registers at all times, and later just
	// choose which show up on output lines
	wire [127:0] read_data;
	reg16 registers[7:0](.q(read_data), .d(writedata), .w_en(w_en), .clk(clk), .rst(rst));

	// All register data is in read_data; use selects to choose portion to
	// asserts on output data lines.
	assign read1data = 	(read1regsel == 3'b111) ? read_data[127:112] :
	       			(read1regsel == 3'b110) ? read_data[111:096] :	
	       			(read1regsel == 3'b101) ? read_data[95 : 80] :	
	       			(read1regsel == 3'b100) ? read_data[79 : 64] :	
	       			(read1regsel == 3'b011) ? read_data[63 : 48] :	
	       			(read1regsel == 3'b010) ? read_data[47 : 32] :	
	       			(read1regsel == 3'b001) ? read_data[31 : 16] :	
	       						  read_data[15 : 0 ] ;	

	assign read2data = 	(read2regsel == 3'b111) ? read_data[127:112] :
	       			(read2regsel == 3'b110) ? read_data[111:096] :	
	       			(read2regsel == 3'b101) ? read_data[95 : 80] :	
	       			(read2regsel == 3'b100) ? read_data[79 : 64] :	
	       			(read2regsel == 3'b011) ? read_data[63 : 48] :	
	       			(read2regsel == 3'b010) ? read_data[47 : 32] :	
	       			(read2regsel == 3'b001) ? read_data[31 : 16] :	
	       						  read_data[15 : 0 ] ;	
endmodule

/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
// Aaron Cohen - 2/27/2021
module rf_bypass (
           // Outputs
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
           );
   input clk, rst;
   input [2:0] read1regsel;
   input [2:0] read2regsel;
   input [2:0] writeregsel;
   input [15:0] writedata;
   input        write;

   output [15:0] read1data;
   output [15:0] read2data;
   output        err;

   wire [15:0] read1data_rf, read2data_rf;
   rf registers(.clk(clk), .rst(rst), .read1regsel(read1regsel), .read2regsel(read2regsel),
		.writeregsel(writeregsel), .writedata(writedata), .write(write),
	     	.read1data(read1data_rf), .read2data(read2data_rf), .err(err));

   // Mux out the data being inputted if writing, and reading from write select
   assign read1data = (write & (read1regsel == writeregsel)) ? writedata : read1data_rf;
   assign read2data = (write & (read2regsel == writeregsel)) ? writedata : read2data_rf;
   	

endmodule

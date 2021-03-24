// Aaron Cohen - 2/13/2021
module shifter (In, Cnt, Op, Out);
input [15:0] In;
input [3:0]  Cnt;
input [1:0]  Op;
output [15:0] Out;

// Left r_shift - lower bits either take on value of 0's or of grabbed upper
// bits depending on opcode.


// Code for shifting right - only logical never arithmetic
wire [15:0] r_shift0, r_shift1, r_shift2, r_shift4, r_shift8;
assign r_shift0 = In; 
assign r_shift1 = Cnt[0] ? {Op[0] ? 1'h0  : r_shift0[0:0], r_shift0[15:1]} : r_shift0; 
assign r_shift2 = Cnt[1] ? {Op[0] ? 2'h0  : r_shift1[1:0], r_shift1[15:2]} : r_shift1; 
assign r_shift4 = Cnt[2] ? {Op[0] ? 4'h0  : r_shift2[3:0], r_shift2[15:4]} : r_shift2; 
assign r_shift8 = Cnt[3] ? {Op[0] ? 8'h00 : r_shift4[7:0], r_shift4[15:8]} : r_shift4;

// Code for left shift/rotate
wire [15:0] l_shift0, l_shift1, l_shift2, l_shift4, l_shift8;
assign l_shift0 = In; // Each of the below mux's have a mux feeding into them to use rotated bits or zero
assign l_shift1 = Cnt[0] ? {l_shift0[14:0], Op[0] ? 1'h0  : l_shift0[15:15]} : l_shift0; 
assign l_shift2 = Cnt[1] ? {l_shift1[13:0], Op[0] ? 2'h0  : l_shift1[15:14]} : l_shift1; 
assign l_shift4 = Cnt[2] ? {l_shift2[11:0], Op[0] ? 4'h0  : l_shift2[15:12]} : l_shift2; 
assign l_shift8 = Cnt[3] ? {l_shift4[07:0], Op[0] ? 8'h00 : l_shift4[15:08]} : l_shift4; 

// Select proper output
assign Out = Op[1] ? r_shift8 : l_shift8;

endmodule


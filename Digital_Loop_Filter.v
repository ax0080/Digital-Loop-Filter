module Digital_Loop_Filter(
	clk,
	rstn,
	master_in,
	slave_out
);

parameter signed [12:0] b0 = 13'b0_1011_0110_0110;
parameter signed [12:0] b1 = 13'b0_1011_1101_0111;
parameter b2 = 13'b1_0101_0111_1010;
parameter b3 = 13'b1_0101_0000_1010;
parameter a0 = 21'b0_1001_0001_1101_1111_1100;
parameter a1 = 21'b1_0001_0000_0111_1001_0100;
parameter a2 = 21'b0_0110_0110_1100_1110_1100;
parameter a3 = 21'b1_1111_0110_1101_1001_1000;


input clk;
input rstn;
signed input master_in;
output slave_out;













endmodule
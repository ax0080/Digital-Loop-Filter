module Digital_Loop_Filter(
	clk,
	rstn,
	master_in,
	slave_out
);
parameter inout_width = 8;
parameter coeff_int_width = 2;
parameter coeff_decimal_width = 18;
parameter coeff_width = coeff_int_width + coeff_decimal_width;


parameter signed [coeff_width - 1 : 0] b0 = 20'b00_0000_0001_0100_0000_00;
parameter signed [coeff_width - 1 : 0] b1 = 20'b00_0000_0001_0100_1100_01;
parameter signed [coeff_width - 1 : 0] b2 = 20'b11_1111_1110_1101_1000_10;
parameter signed [coeff_width - 1 : 0] b3 = 20'b11_1111_1110_1100_1100_00;
  
parameter signed [coeff_width - 1 : 0] a1 = 20'b01_1010_0100_0101_1010_00;
parameter signed [coeff_width - 1 : 0] a2 = 20'b00_1011_0100_0110_1011_11;
parameter signed [coeff_width - 1 : 0] a3 = 20'b11_1110_1111_1111_0000_11;


input clk;
input rstn;
signed input wire [inout_width - 1 : 0] master_in;
signed output reg [inout_width - 1 : 0] slave_out;


//register
signed reg [inout_width - 1 : 0] in_delay1;
signed reg [inout_width - 1 : 0] in_delay2;
signed reg [inout_width - 1 : 0] in_delay3; 
			
signed reg [inout_width - 1 : 0] out_delay1;
signed reg [inout_width - 1 : 0] out_delay2;
signed reg [inout_width - 1 : 0] out_delay3;

//wire
signed wire [inout_width + coeff_width - 1 : 0] in1;  
signed wire [inout_width + coeff_width - 1 : 0] in2; 
signed wire [inout_width + coeff_width - 1 : 0] in3; 
			  
signed wire [inout_width + coeff_width - 1 : 0] out1;  
signed wire [inout_width + coeff_width - 1 : 0] out2; 
signed wire [inout_width + coeff_width - 1 : 0] out3;

signed wire [inout_width + coeff_width + 2 : 0] out_sum;
 

//numerator
assign in1 = b1 * in_delay1;
assign in2 = b2 * in_delay2;
assign in3 = b3 * in_delay3;


//denominator
assign out1 = a1 * out_delay1;
assign out2 = a2 * out_delay2;
assign out3 = a3 * out_delay3;

always @(posedge clk) begin
	if (!rstn) begin
		in_delay1 <= 7'b0;
		in_delay2 <= 7'b0;
		in_delay3 <= 7'b0;
		
		out_delay1 <= 7'b0;
		out_delay2 <= 7'b0;
		out_delay3 <= 7'b0;
	end
	else begin
		in_delay1 <= master_in;
		in_delay2 <= in_delay1;
		in_delay3 <= in_delay2;
		
		out_delay1 <= output_int;
		out_delay2 <= out_delay1;
		out_delay3 <= out_delay2;
    end
end

//output
assign out_sum = b0 + in1 + in2 + in3 - out1 - out2 - out3;
assign slave_out = out_sum[coeff_decimal_width + coeff_width - 1 : coeff_decimal_width];


endmodule
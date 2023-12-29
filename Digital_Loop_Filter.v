/* 
This is for AICLAB718 Novatek ADPLL Project
The Digital Loop Filter is a third order Digital Loop Filter
clk : clock signal for the Filter
rstn : set it 0 when we need reset
master_in : Input of Digital Loop Filter, in our case, it is connected to ADC output
slave_out : Output of Digital Loop Filter, in our case, it is connected to Digital Controlled Oscillator
lead : High means feedback lead, low means ref lead
*/ 
module Digital_Loop_Filter(
	clk,
	rstn,
	master_in,
	slave_out,
	lead
);
parameter inout_width = 8;
parameter coeff_int_width = 2;
parameter coeff_decimal_width = 18;
parameter coeff_width = coeff_int_width + coeff_decimal_width;


wire signed [coeff_width - 1 : 0] b0 = 20'b00_0000_0010_1000_0000_00; //0.0097690
wire signed [coeff_width - 1 : 0] b1 = 20'b00_0000_0010_1001_1000_11; //0.0101456
wire signed [coeff_width - 1 : 0] b2 = 20'b11_1111_1101_1011_0001_01; //-0.0090159
wire signed [coeff_width - 1 : 0] b3 = 20'b11_1111_1101_1001_1000_10; //-0.0093925
  
wire signed [coeff_width - 1 : 0] a1 = 20'b10_0101_1011_1010_0110_00; //-1.64201
wire signed [coeff_width - 1 : 0] a2 = 20'b00_1011_0100_0110_1011_11; //0.70477
wire signed [coeff_width - 1 : 0] a3 = 20'b11_1110_1111_1111_0000_11; //-0.06273


input clk;
input rstn;
input lead;
input wire [inout_width - 1 : 0] master_in;
output reg [inout_width - 1 : 0] slave_out;


//register
reg signed [inout_width : 0] in_temp;
reg signed [inout_width : 0] in_delay1;
reg signed [inout_width : 0] in_delay2;
reg signed [inout_width : 0] in_delay3; 
			
reg signed [inout_width : 0] out_delay1;
reg signed [inout_width : 0] out_delay2;
reg signed [inout_width : 0] out_delay3;


//wire
wire signed [inout_width + coeff_width : 0] in0;
wire signed [inout_width + coeff_width : 0] in1;  
wire signed [inout_width + coeff_width : 0] in2; 
wire signed [inout_width + coeff_width : 0] in3; 
			  
wire signed [inout_width + coeff_width : 0] out1;  
wire signed [inout_width + coeff_width : 0] out2; 
wire signed [inout_width + coeff_width : 0] out3;

wire signed [inout_width + coeff_width + 3 : 0] out_sum;
 
//change to signed
always @ (*) begin
	if(lead) in_temp = {1'b0, master_in};
	else begin 
    in_temp = {1'b1, ~master_in} + 1'b1;
  end
end

//numerator
assign in0 = b0 * in_temp; 
assign in1 = b1 * in_delay1;
assign in2 = b2 * in_delay2;
assign in3 = b3 * in_delay3;

//denominator
assign out1 = a1 * out_delay1;
assign out2 = a2 * out_delay2;
assign out3 = a3 * out_delay3;


always @ (posedge clk or negedge rstn) begin
  if (!rstn) begin
		in_delay1 <= 9'b0;
		in_delay2 <= 9'b0;
		in_delay3 <= 9'b0;
		
		out_delay1 <= 9'b0;
		out_delay2 <= 9'b0;
	  out_delay3 <= 9'b0;
	end
	else begin
		in_delay1 <= in_temp;
		in_delay2 <= in_delay1;
		in_delay3 <= in_delay2;
		
		out_delay1 <= out_sum[coeff_decimal_width + inout_width : coeff_decimal_width];
		out_delay2 <= out_delay1;
		out_delay3 <= out_delay2;
  end

end


//output
wire [inout_width - 1 : 0] out_temp;

assign out_sum = in0 + in1 + in2 + in3 - out1 - out2 - out3;
assign out_temp = {out_sum[coeff_decimal_width + inout_width - 1 : coeff_decimal_width]};
assign slave_out = {~out_temp[inout_width - 1], out_temp[inout_width - 1 : 0]};


endmodule

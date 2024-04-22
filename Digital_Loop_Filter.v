//*****************************************************************************************************************************
// This is for AICLAB718 Novatek ADPLL Project
// The Digital Loop Filter is a third order direct-form II Transposed Digital Loop Filter 					
// clk : clock signal for the Filter 									                                    
// rst_n : set it 0 when we need reset 																		
// master_in : Input of Digital Loop Filter, in our case, it is connected to ADC output                     
// slave_out : Output of Digital Loop Filter, in our case, it is connected to Digital Controlled Oscillator 
// mode : 2'b00 for Bandwidth = 1MHz
//		  2'b01 for Bandwidth = 0.75MHz
//		  2'b10 for Bandwidth = 1.25MHz
// 		  2'b11 for Bandwidth = FPGA
//*****************************************************************************************************************************

`timescale 100ps/1ps

module Digital_Loop_Filter(
	clk,
	rst_n,
	master_in,
	slave_out,
	mode
);

input clk;
input rst_n;
input wire [inout_width - 1 : 0] master_in;
output reg [inout_width - 1 : 0] slave_out;
input [1:0] mode;

parameter inout_width = 8;
parameter coeff_int_width = 2;
parameter coeff_decimal_width = 18;
parameter coeff_width = coeff_int_width + coeff_decimal_width;

//***** denominator *****
wire signed [coeff_width - 1 : 0] a1 = 20'b10_0101_1011_1010_0110_00; //-1.64201
wire signed [coeff_width - 1 : 0] a2 = 20'b00_1011_0100_0110_1011_11; //0.70477
wire signed [coeff_width - 1 : 0] a3 = 20'b11_1110_1111_1111_0000_11; //-0.06273

//***** numerator *****
// 1MHz 
wire signed [coeff_width - 1 : 0] b0 = 20'b00_0000_0010_1000_0000_00; //0.0097690
wire signed [coeff_width - 1 : 0] b1 = 20'b00_0000_0010_1001_1000_11; //0.0101456
wire signed [coeff_width - 1 : 0] b2 = 20'b11_1111_1101_1011_0001_01; //-0.0090159
wire signed [coeff_width - 1 : 0] b3 = 20'b11_1111_1101_1001_1000_10; //-0.0093925


// 0.75MHz
wire signed [coeff_width - 1 : 0] b0_075 = 20'b00_0000_0001_1110_0000_00; //0.00732422
wire signed [coeff_width - 1 : 0] b1_075 = 20'b00_0000_0001_1111_0010_10; //0.0076092
wire signed [coeff_width - 1 : 0] b2_075 = 20'b11_1111_1110_0100_0101_00; //-0.006761925 
wire signed [coeff_width - 1 : 0] b3_075 = 20'b11_1111_1110_1100_1011_11; //-0.00470475

// 1.25MHz
wire signed [coeff_width - 1 : 0] b0_125 = 20'b00_0000_0011_0010_0000_01 //0.01221125
wire signed [coeff_width - 1 : 0] b1_125 = 20'b00_0000_0011_0011_1111_00 //0.012680
wire signed [coeff_width - 1 : 0] b2_125 = 20'b11_1111_1101_0001_1101_10 //-0.011269875
wire signed [coeff_width - 1 : 0] b3_125 = 20'b11_1111_1101_1111_1110_01 //-0.00784125




reg signed [inout_width - 1 : 0] in_temp;
reg signed [inout_width + coeff_width + 2 : 0] out_sum;
reg signed [inout_width - 1 : 0] out_temp;

reg signed [inout_width + coeff_width - 1 : 0] in_b0;
reg signed [inout_width + coeff_width - 1 : 0] in_b1;  
reg signed [inout_width + coeff_width - 1 : 0] in_b2; 
reg signed [inout_width + coeff_width - 1 : 0] in_b3; 	
reg signed [inout_width + coeff_width - 1 : 0] out_a1;  
reg signed [inout_width + coeff_width - 1 : 0] out_a2; 
reg signed [inout_width + coeff_width - 1 : 0] out_a3;

reg signed [inout_width + coeff_width + 2 : 0] s1z;
reg signed [inout_width + coeff_width + 1 : 0] s2z;
reg signed [inout_width + coeff_width + 0 : 0] s3z;


always @(*) begin
	in_temp = {~master_in[inout_width - 1], master_in[inout_width - 2 : 0]};
end

always @(*) begin
	case(mode)	begin
		2'b00:	begin
			in_b0 = in_temp * b0;
			in_b1 = in_temp * b1;
			in_b2 = in_temp * b2;
			in_b3 = in_temp * b3;
		end
		2'b01:	begin
			in_b0 = in_temp * b0_075;
			in_b1 = in_temp * b1_075;
			in_b2 = in_temp * b2_075;
			in_b3 = in_temp * b3_075;
		end
		2'b10:	begin
			in_b0 = in_temp * b0_125;
			in_b1 = in_temp * b1_125;
			in_b2 = in_temp * b2_125;
			in_b3 = in_temp * b3_125;	
		end
		2'b11:	begin
			in_b0 = {(inout_width + coeff_width - 1 : 0){1'bz}};
			in_b1 = {(inout_width + coeff_width - 1 : 0){1'bz}};
			in_b2 = {(inout_width + coeff_width - 1 : 0){1'bz}};
			in_b3 = {(inout_width + coeff_width - 1 : 0){1'bz}};
		end
		default:begin
			in_b0 = {(inout_width + coeff_width - 1 : 0){1'bz}};
			in_b1 = {(inout_width + coeff_width - 1 : 0){1'bz}};
			in_b2 = {(inout_width + coeff_width - 1 : 0){1'bz}};
			in_b3 = {(inout_width + coeff_width - 1 : 0){1'bz}};
		end
	endcase
end

always @(*) begin
	out_a1 = out_temp * a1;
	out_a2 = out_temp * a2;
	out_a3 = out_temp * a3;
end

always @(*) begin
	out_sum = s1z * in_b0;
end

always @(*) begin
	out_temp = out_sum[coeff_decimal_width + inout_width : coeff_decimal_width];
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		s1z <= {(inout_width + coeff_decimal_width + 3){1'b0}};
		s2z <= {(inout_width + coeff_decimal_width + 2){1'b0}};
		s3z <= {(inout_width + coeff_decimal_width + 1){1'b0}};
	end
	else begin
		s1z <= in_b1 - out_a1 + s2z;
		s2z <= in_b2 - out_a2 + s3z;
		s3z <= in_b3 - out_a3;
	end
end

// output
always @(*) begin
	slave_out = {~out_temp[inout_width - 1], out_temp[inout_width - 2 : 0]};
end

endmodule

/*************************Digital Loop Filter*************************/
module DLF(
clk, resetn, s_axis_tdata, s_axis_tlast, s_axis_tvalid, s_axis_tready, m_axis_tdata, m_axis_tlast, m_axis_tvalid, m_axis_tready, bo, b1, b2, a1, a2);
parameter inout_width = 16,
parameter inout_decimal_width = 15,
parameter coefficient_width = 16,
parameter coefficient_decimal_width = 15,
parameter internal_width = 16,
parameter internal_decimal_width = 15

input aclk,
input resetn,

/* slave axis interface */
input [inout_width-1:0] s_axis_tdata,
input s_axis_tlast,
input s_axis_tvalid,
output s_axis_tready,

/* master axis interface */
output reg [inout_width-1:0] m_axis_tdata,
output reg m_axis_tlast,
output reg m_axis_tvalid,
input m_axis_tready,

/* coefficients */
input signed [pw_coefficient_width-1:0] b0,
input signed [pw_coefficient_width-1:0] b1,
input signed [pw_coefficient_width-1:0] b2,
input signed [pw_coefficient_width-1:0] a1,
input signed [pw_coefficient_width-1:0] a2

/* wire */
wire input_b0;
wire input_b1;
wire input_b2;
wire output_a1;
wire output_a2;
wire output_2int;
wire output_int;


/* register */
reg input_pipe1;
reg input_pipe2;
reg output_pipe1;
reg output_pipe2;


/* pipeline registers */
always @(posedge aclk) begin
  if (!resetn) begin
    input_pipe1 <= 0;
    input_pipe2 <= 0;
    output_pipe1 <= 0;
    output_pipe2 <= 0;
  end
  else
    if (s_axis_tvalid) begin
      input_pipe1 <= input_int;
      input_pipe2 <= input_pipe1;
      output_pipe1 <= output_int;
      output_pipe2 <= output_pipe1;
    end
end

/* combinational multiplications */
assign input_b0 = input_int * b0_int;
assign input_b1 = input_pipe1 * b1_int;
assign input_b2 = input_pipe2 * b2_int;
assign output_a1 = output_pipe1 * a1_int;
assign output_a2 = output_pipe2 * a2_int;

assign output_2int = input_b0 + input_b1 + input_b2 - output_a1 - output_a2;
assign output_int = output_2int >>> (internal_decimal_width);

assign m_axis_tdata = output_int >>> (internal_decimal_width-inout_decimal_width);

endmodule
`timescale 1ns/1ps

module tb_Digital_Loop_Filter;
  
reg clk;
reg rstn;
reg master_in;
wire slave_out;
wire lead;
  
Digital_Loop_Filter DLF
(
  .clk(clk),
  .rstn(rstn),
  .master_in(master_in),
  .slave_out(slave_out),
  .lead(lead)
);
  
initial begin
  $dumpfile("tb.vcd");
  $dumpvars(0);   
end
  
initial begin
  clk = 0;
  forever begin
  	#100 clk = ~clk;
  end
end

initial begin
  rstn = 0;
  lead = 0;
  
  #50
  rstn = 1'b1;
  lead = 1'b1;
  master_in = 8'b10100001;
  
  #100
  lead = 1'b1;
  master_in = 8'b11001111;
  
  #100
  lead = 1'b0;
  master_in = 8'b10111111;
  
  
endmodule
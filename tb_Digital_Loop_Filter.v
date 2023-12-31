
module tb_Digital_Loop_Filter;
  
reg clk;
reg rstn;
reg [7:0] master_in;
wire [7:0] slave_out;
reg lead;
  
Digital_Loop_Filter DLF
(
  .clk(clk),
  .rstn(rstn),
  .master_in(master_in),
  .slave_out(slave_out),
  .lead(lead)
);
  
  
initial begin
  clk = 0;
  forever begin
  	#100 clk = ~clk;
  end
end

//waveform
initial begin
  $fsdbDumpfile("tb_Digital_Loop_Filter.fsdb");
  $fsdbDumpvars;
end





initial begin
  rstn = 1'b0;
  lead = 1'b0;
  
  #50
  rstn = 1'b1;
  lead = 1'b1;
  master_in = 8'b10010110;

  #150
  $display("output = %d", slave_out);
  
  #50
  lead = 1'b0;
  master_in = 8'b01100000;

  #150
  $display("output = %d", slave_out);

  #50
  lead = 1'b1;
  master_in = 8'b00001111;

  #150
  $display("output = %d", slave_out);

  #50
  lead = 1'b0;
  master_in = 8'b10101011;

  #150
  $display("output = %d", slave_out);

  #2000

  $display("output = %d", slave_out);  

  $finish();
end
  
endmodule

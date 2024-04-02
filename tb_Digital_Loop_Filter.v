/*
`ifdef RTL
	`define CYCLE_TIME 250
`endif

`ifdef GATE
	`define CYCLE_TIME 250
`endif
*/
`ifdef RTL
	`include "../01_RTL/Digital_Loop_Filter.v"
`endif

`ifdef GATE
	`include "../02_SYN/netlist/Digital_Loop_Filter_syn.v"
	`include "/cad/CBDK/CBDK_TSMC90GUTM_Arm_v1.2/CIC/Verilog/tsmc090.v"
`endif

`include "PATTERN.v"
//`timescale 100ps/1ps

module tb_Digital_Loop_Filter;

wire clk;
wire rstn;
wire [7:0] master_in;
wire [7:0] slave_out;

Digital_Loop_Filter DLF
(
	.clk(clk),
	.rstn(rstn),
	.master_in(master_in),
	.slave_out(slave_out)
);

PATTERN PATTERN_DLF
(
	.clk(clk),
	.rstn(rstn),
	.master_in(master_in),
	.slave_out(slave_out)
);

initial begin
	`ifdef RTL
		$dumpfile("tb_Digital_Loop_Filter.vcd");
		$dumpvars;
	`endif
	`ifdef GATE
		$sdf_annotate("../02_SYN/netlist/Digital_Loop_Filter_syn.sdf", DLF);
		$dumpfile("tb_Digital_Loop_Filter_SYN.vcd");
		$dumpvars;
	`endif
end
  
endmodule
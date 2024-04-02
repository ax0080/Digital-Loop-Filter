`define CYCLE_TIME 250

module PATTERN(
    output reg clk,
    output reg rstn,
    output reg [7:0] master_in,
    input [7:0] slave_out
);

reg [7:0] golden;

integer PAT_NUM = 100;
integer i_pat, i, num;
integer seed = 123;

// coefficient
parameter b0 = 0.0097690;
parameter b1 = 0.0101456;
parameter b2 = -0.0090159;
parameter b3 = -0.0093925;
parameter a1 = -1.64201;
parameter a2 = 0.70477;
parameter a3 = -0.06273;

real y, y1, y2, y3;
real x, x1, x2, x3;


always #(`CYCLE_TIME/2) clk = ~clk;
initial clk = 0;

initial begin    
    reset_task;
    for (i_pat = 0; i_pat < PAT_NUM; i_pat = i_pat + 1) begin
        normal_task;
        normal_check;
    end
    convergence_task;
    overflow_task;
    
    PASS_task;
end

task reset_task;
begin
    rstn = 1'b1;
	master_in = 0;
    force clk = 0;
    #`CYCLE_TIME; rstn = 1'b0; 
    #(2 * `CYCLE_TIME); rstn = 1'b1;
    #`CYCLE_TIME; release clk;
	
	x = 0;
	x1 = 0;
	x2 = 0;
	x3 = 0;
	y = 0;
	y1 = 0;
	y2 = 0;
	y3 = 0;
end
endtask

task normal_task;
begin
	@ (posedge clk);
    master_in = $urandom(seed) % 256;
    x = master_in;  
end
endtask

task normal_check;
begin
    y = b0 * x + b1 * x1 + b2 * x2 + b3 * x3 - a1 * y1 - a2 * y2 - a3 * y3;
    y3 = y2;
    y2 = y1;
    y1 = y;
    x3 = x2;
    x2 = x1;
    x1 = x;
    golden = $rtoi(y);
    
    @ (negedge clk);
    if (golden !== slave_out) begin
        $display("actual output is %d", golden);
        $display("your output is %d", slave_out);
        $finish;
    end
end
endtask

task convergence_task;
begin
    @(posedge clk);
    reset_task;
    num = 0;
    
    $display("convergence_task start");
    for (i = 0; i < 100; i = i + 1) begin
        master_in = 1;
        @(negedge clk);
        $display("The %d times", num);
        $display("your output is %d", slave_out);
        num = num + 1;
    end
end
endtask

task overflow_task;
begin
    @(posedge clk);
    reset_task;
    num = 0;
    
    $display("overflow_task start");
    for (i = 0; i < 1000; i = i + 1) begin
        master_in = 255;
        @(negedge clk);
        $display("The %d times", num);
        $display("your output is %d", slave_out);
    end
end
endtask

task PASS_task;
begin
    $display("--------------------------------------------------------------------------------");
    $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
    $display("    ▄▀            ▀▄      ▄▄                                          ");
    $display("    █  ▀   ▀       ▀▄▄   █  █      Congratulations !                            ");
    $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  You have passed all patterns ! ");
    $display("    █ ▀▄▀▄▄▀                 █  ╭     ");
    $display("    ▀▄                       █       ");
    $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █        ");
    $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
    $display("--------------------------------------------------------------------------------");  
    repeat(2) @(negedge clk);
    $finish;
    
end
endtask

endmodule

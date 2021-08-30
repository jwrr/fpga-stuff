`timescale 1 ns /  100 ps
module tb;
  parameter DWID = 8;

  reg rst = 0;
  reg clk = 0;
  always #5 clk <= !clk;

  reg               i_enable = 0;
  reg    [DWID-1:0] i_period;
  reg    [DWID-1:0] i_hi_time;
  reg    [DWID-1:0] i_hi_more_precision;
  wire              o_q_tl;
  wire              o_q_bl;
  wire              o_q_tr;
  wire              o_q_br;

  hbridge #(DWID) u_hbridge (
    .clk                 (clk),
    .rst                 (rst),
    .i_pn                (1'b1),
    .i_enable            (i_enable),
    .i_period            (i_period),
    .i_hi_time           (i_hi_time),
    .i_hi_more_precision (i_hi_more_precision),
    .i_dead_time         (8'h1),
    .o_q_tl              (o_q_tl),
    .o_q_bl              (o_q_bl),
    .o_q_tr              (o_q_tr),
    .o_q_br              (o_q_br)
  );
  

  initial begin
    $display($time, " info: Start of Simulation");
    #1 rst = 1;
    i_period = 100;
    i_hi_time = 40;
    i_hi_more_precision = 171; // 171/256 ~= 0.667

    repeat(10) @(posedge clk); #1;
    rst = 0;

    $display($time, " info: enable pwm");
    repeat(10) @(posedge clk); #1;
    i_enable = 1;

    repeat(10000) @(posedge clk); #1;

    repeat(10) @(posedge clk); #1;
    $display($time, " info: End of Simulation");
    $finish;    
  end

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb);
  end

endmodule


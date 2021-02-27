`timescale 1 ns /  100 ps
module tb;
  parameter DWID      = 16;
  parameter DEPTH     = 256;

  reg clk = 0;
  always #5 clk <= !clk;

  reg              rst = 0;
  reg              push = 0;
  reg   [DWID-1:0] din = 0;
  wire             full;
  reg              pop = 0;
  wire  [DWID-1:0] dout;
  wire             empty;

  integer ii = 0;

  stack #(DEPTH,DWID) u_dut
  (
    .rst    (rst),
    .clk    (clk),
    .push   (push),
    .pop    (pop),
    .din    (din),
    .dout   (dout),
    .empty  (empty),
    .full   (full)
  );

  initial begin
    ii = 0;
    rst = 0;
    @(posedge clk); #1;
    rst = 1;
    $display($time, "info: Start of Simulation");
    repeat(10) @(posedge clk); #1;
    rst = 0;
    repeat(10) @(posedge clk); #1;
    
    
    // =================================================
    // FILL AND DRAIN STACK

    $display($time, "info: fill stack");
    for (ii = 0; ii < DEPTH; ii = ii + 1) begin
      push = 1;
      din = ii + 'ha;
      @(posedge clk); #1;
    end

    push <= 0;
    repeat(10) @(posedge clk);


    $display($time, "info: read stack");
    for (ii = 0; ii < DEPTH; ii = ii + 1) begin
      pop = 1;
      @(posedge clk); #1;
    end

    // =================================================
    // FILL ONLY, THEN FILL/DRAIN, THEN DRAIN

    
    $display($time, "info: fill stack");
    for (ii = 0; ii < 20; ii = ii + 1) begin
      push = 1;
      pop = 0;
      din = ii + 'hb;
      @(posedge clk); #1;
    end

    $display($time, "info: fill and drain stack");
    for (ii = 0; ii < 10; ii = ii + 1) begin
      push = 1;
      pop  = 1;
      din = ii + 'hb;
      @(posedge clk); #1;
    end

    push <= 0;
    repeat(10) @(posedge clk);
    
    $display($time, "info: read stack");
    for (ii = 0; ii < 12; ii = ii + 1) begin
      pop = 1;
      @(posedge clk); #1;
    end

    repeat(100) @(posedge clk);
    $display($time, "info: End of Simulation");
    $finish;
  end

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb);
  end

endmodule


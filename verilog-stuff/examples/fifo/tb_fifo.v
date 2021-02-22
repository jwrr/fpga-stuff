`timescale 1 ns /  100 ps
module tb;
  parameter DWID      = 16; // 16, 8, 4, 2
  parameter DEPTH     = 256;

  reg              clk = 0;
  always #5 clk <= !clk;

  integer ii = 0;

  reg                   rst = 0;
  wire                  wclk = clk;
  reg                   i_write_wclk = 0;
  reg        [DWID-1:0] i_din_wclk = 0;
  wire                  o_full_wclk;
  wire                  rclk = clk;
  reg                   i_read_rclk = 0;
  wire       [DWID-1:0] o_dout_rclk;
  wire                  o_empty_rclk;

  fifo #(DEPTH,DWID) u_dut
  (
    .rst            (rst),
    .wclk           (wclk),
    .i_write_wclk   (i_write_wclk),
    .i_din_wclk     (i_din_wclk),
    .o_full_wclk    (o_full_wclk),
    .rclk           (rclk),
    .i_read_rclk    (i_read_rclk),
    .o_dout_rclk    (o_dout_rclk),
    .o_empty_rclk   (o_empty_rclk)
  );

  initial begin
    ii = 0;
    rst = 0;
    @(posedge clk); #1;
    rst = 1;
    $display($time, "info: Start of Simulation");
    repeat(10) @(posedge clk); #1;
    rst = 0;
    repeat(10) @(posedge wclk); #1;
    $display($time, "info: fill fifo");
    for (ii = 0; ii < DEPTH; ii = ii + 1) begin
      i_write_wclk = 1;
      i_din_wclk = ii;
      @(posedge wclk); #1;
    end

    i_write_wclk <= 0;
    repeat(10) @(posedge wclk);


    $display($time, "info: read fifo");
    for (ii = 0; ii < DEPTH; ii = ii + 1) begin
      i_read_rclk = 1;
      @(posedge rclk); #1;
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


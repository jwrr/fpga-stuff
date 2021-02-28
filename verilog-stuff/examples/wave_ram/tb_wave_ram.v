`timescale 1 ns /  100 ps
module tb;

  parameter WAVE_RAM_DEPTH  = 256;
  parameter CMD_FIFO_DEPTH  = 256;
  parameter AWIDTH          =   8;
  parameter DWIDTH          =  16;
  parameter CWIDTH          =  24;


  reg clk = 0;
  always #5 clk = !clk;

  reg                   rst;            // asynchronous; sync'ed in module
  wire                  rclk    = clk;
  wire                  wclk    = clk;
  reg      [AWIDTH-1:0] waddr   = 0;    // set base addr (auto-increments each wdata_v)
  reg                   waddr_v = 0;
  reg      [DWIDTH-1:0] wdata   = 0;    // data written to wave memory
  reg                   wdata_v = 0;
  reg      [CWIDTH-1:0] wcmd    = 0;    // cmd including start_addr, length, clkrate
  reg                   wcmd_v  = 0;
  reg                   go      = 0;    // start reading commands
  wire     [DWIDTH-1:0] dout;
  wire                  dout_v;
  wire           [15:0] status;

wave_ram #(WAVE_RAM_DEPTH, CMD_FIFO_DEPTH, AWIDTH, DWIDTH, CWIDTH) u_dut
(
    .rst     (rst),
    .wclk    (wclk),
    .rclk    (rclk),
    .waddr   (waddr),
    .waddr_v (waddr_v),
    .wdata   (wdata),
    .wdata_v (wdata_v),
    .wcmd    (wcmd),
    .wcmd_v  (wcmd_v),
    .go      (go),
    .dout    (dout),
    .dout_v  (dout_v),
    .status  (status)
);


  integer ii, jj;
  initial begin
    ii = 0;
    rst = 0;
    @(posedge clk); #1;
    rst = 1;
    $display($time, "info: Start of Simulation");
    repeat(10) @(posedge clk); #1;
    rst = 0;
    repeat(10) @(posedge wclk); #1;


    $display($time, "info: fill wave_ram");
    for (jj=0; jj<16; jj=jj+1) begin
      waddr = 0;
      waddr_v = 0;
      @(posedge clk); #1;
      waddr = jj * 16;
      waddr_v = 1;
      @(posedge clk); #1;
      waddr = 0;
      waddr_v = 0;
      @(posedge clk); #1;

      for (ii = 0; ii < WAVE_RAM_DEPTH; ii = ii + 1) begin
        wdata_v = 1;
        wdata = ii;
        @(posedge wclk); #1;
      end
      wdata_v = 0;
      wdata = 0;
      @(posedge clk); #1;
    end
    wdata_v = 0;
    repeat(10) @(posedge wclk);


    $display($time, "info: fill cmd fifo");
    for (jj=0; jj<16; jj=jj+1) begin
      wcmd =  (((jj+1)*10) << 16) + (((jj+1)*10) << 8) + jj*16; // clkdiv, len, addr
      wcmd_v = 1;
      @(posedge clk); #1;
    end
    wcmd = 0;
    wcmd_v = 0;
    repeat(10) @(posedge wclk);


    $display($time, "info: go go go...");
    go = 1;
    repeat(10) @(posedge wclk);
    go = 0;
    repeat(40000) @(posedge wclk);

    repeat(100) @(posedge clk);
    $display($time, "info: End of Simulation");
    $finish;
  end

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb);
  end

endmodule


`timescale 1 ns /  100 ps
module tb;
  parameter DWID      = 16;
  parameter AWID      = 8; // $clog2(DEPTH);
  parameter DEPTH     = 2**AWID;

  reg              clk = 0;
  reg              i_we = 0;
  reg  [AWID-1:0]  i_waddr = 0;
  reg  [AWID-1:0]  i_raddr = 0;
  reg  [DWID-1:0]  i_dat  = 0;
  wire [DWID-1:0]  o_dat;
  integer ii;
  
  ram2p #(DEPTH,AWID,DWID) u_dut (
    .clka(clk),
    .i_wea(i_we),
    .i_addra(i_waddr),
    .i_data(i_dat),
    .o_data(),
    .clkb(clk),
    .i_web(1'b0),
    .i_addrb(i_raddr),
    .i_datb({DWID{1'b0}}),
    .o_datb(o_dat)
  );
  

  always #5 clk <= !clk;

  initial begin
    $display($time, "info: Start of Simulation");
    repeat(10) @(posedge clk);

    $display($time, "info: fill memory");

    for (ii = 0; ii < DEPTH; ii = ii + 1) begin
      i_waddr <= ii;
      i_we <= 1;
      i_dat <= i_waddr;
      @(posedge clk);
    end

    i_we <= 0;
    repeat(10) @(posedge clk);

    $display($time, "info: read memory");
    
    for (ii = 0; ii < DEPTH; ii = ii + 1) begin
      i_raddr <= ii;    
      @(posedge clk);
    end

    repeat(10) @(posedge clk);
    $display($time, "info: End of Simulation");
    $finish;    
  end

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb);
  end

endmodule


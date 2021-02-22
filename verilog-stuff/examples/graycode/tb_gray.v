`timescale 1 ns /  100 ps
module tb;
  parameter DWID = 8;

  reg  [DWID-1:0]  i_bin  = 0;
  wire [DWID-1:0]  gray;
  wire [DWID-1:0]  o_bin;
  integer ii;

  reg clk = 0;
  always #5 clk <= !clk;


  bin2gray #(DWID) u_bin2gray
  (
    .clk    (clk),
    .rst    (rst),
    .i_bin  (i_bin),
    .o_gray (gray)
  );
  
  gray2bin #(DWID) u_gray2bin
  (
    .clk    (clk),
    .rst    (rst),
    .i_gray (gray),
    .o_bin  (o_bin)
  );
  

  initial begin
    $display($time, "info: Start of Simulation");
    repeat(10) @(posedge clk); #1;

    $display($time, "info: fill memory");

    for (ii = 0; ii < 2**DWID; ii = ii + 1) begin
      i_bin =ii;
      @(posedge clk); #1;
    end

    repeat(10) @(posedge clk); #1;
    $display($time, "info: End of Simulation");
    $finish;    
  end

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb);
  end

endmodule


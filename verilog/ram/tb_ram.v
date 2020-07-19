`timescale 1 ns /  100 ps
module tb_top();
  parameter NUM_BITS  = 4096;
  parameter DWID      = 16; // 16, 8, 4, 2
  parameter DEPTH     = NUM_BITS / DWID;
  parameter AWID      = 8; // $clog2(DEPTH);

  reg              clk = 0;
  reg              i_we = 0;
  reg  [AWID-1:0]  i_addr = 0;
  reg  [DWID-1:0]  i_dat  = 0;
  wire [DWID-1:0]  o_dat;
  integer ii;
  
//   ram #(
//     AWID  = AWID,
//     DWID  = DWID
//   ) 
  ram #(AWID,DWID) u_dut (
    .clk(clk),
    .i_we(i_we),
    .i_addr(i_addr),
    .i_dat(i_dat),
    .o_dat(o_dat)
  );
  

  always #5 clk <= !clk;

  initial begin
    $display($time, "info: Start of Simulation");
    repeat(10) @(posedge clk);

    $display($time, "info: fill memory");

    for (ii = 0; ii < DEPTH; ii = ii + 1) begin
      i_addr <= ii;
      i_we <= 1;
      i_dat <= i_addr;
      @(posedge clk);
    end

    i_we <= 0;
    repeat(10) @(posedge clk);

    $display($time, "info: read memory");
    
    for (ii = 0; ii < DEPTH; ii = ii + 1) begin
      i_addr <= ii;    
      @(posedge clk);
    end

    repeat(10) @(posedge clk);
    $display($time, "info: End of Simulation");
    $finish;    
  end

endmodule


`timescale 1 ns /  100 ps
module tb();
  parameter DOUT_WIDTH  = 16;
  parameter DIN_WIDTH   = $clog2(DOUT_WIDTH);

  reg                       rst = 0;
  reg   [DIN_WIDTH-1:0]     din = 0;
  reg                       din_v = 0;
  wire  [DOUT_WIDTH-1:0]    dout;

  reg   [DOUT_WIDTH-1:0]    exp_dout;

  reg clk = 0;
  always #5 clk <= !clk;


  decoder #(DOUT_WIDTH) u_dut (
    .clk(clk),
    .rst(rst),
    .din(din),
    .din_v(din_v),
    .dout(dout)
  );


  integer test_count = 0;
  integer fail_count = 0;
  integer ii = 0;
  initial begin
    $display($time, " info: Start of Simulation");
    @(posedge clk);
    rst = 1;
    repeat(10) @(posedge clk);
    rst = 0;
    
    din = 0;
    din_v = 1;
    repeat(10) @(posedge clk);



    repeat(DOUT_WIDTH) begin
      
      exp_dout = 0;
      exp_dout[din] = 1;
      
      test_count = test_count + 1;
      if (dout == exp_dout) begin
        $display($time, " PASS: dout = %0b", dout);
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: dout = %0b expect = %0b", ii, dout, exp_dout);
      end

      @(posedge clk); #1;
      din = din + 1;
      din_v = 1;
      repeat (2) @(posedge clk); #1;
    end
    repeat (20) @(posedge clk); #1;
    if (fail_count == 0) begin
      $display($time, "TEST PASSED. All %0sd tests passed", test_count);
    end else begin
      $display($time, "TEST FAILED. %0d tests failed out of %0d.", fail_count, test_count);
    end
    $display($time, " info: End of Simulation");
    $finish;
  end

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb);
  end


endmodule


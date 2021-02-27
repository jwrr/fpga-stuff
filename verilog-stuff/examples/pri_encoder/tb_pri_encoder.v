`timescale 1 ns / 100 ps
module tb();
  parameter DWIDTH   = 8;

  reg                         rst = 0;
  reg   [DWIDTH-1:0]          din = 0;
  reg   [DWIDTH-1:0]          din_v = 0;
  reg                         enable = 0;
  wire  [$clog2(DWIDTH)-1:0]  dout;
  wire                        dout_v;
  reg   [DWIDTH-1:0]          exp_dout;

  reg clk = 0;
  always #5 clk <= !clk;


  pri_encoder #(DWIDTH) u_dut (
    .clk(clk),
    .rst(rst),
    .din(din),
    .din_v(din_v),
    .enable(enable),
    .dout(dout),
    .dout_v(dout_v)
  );
  

  integer test_count = 0;
  integer fail_count = 0;
  integer ii = 0;
  initial begin
    $display($time, " info: Start of Simulation");
    @(posedge clk);
    rst = 1;
    repeat(10) @(posedge clk); #1;
    rst = 0;
    enable = 1;
    din_v = ~0;
    din = 0;

    repeat(10) @(posedge clk); #1;

    exp_dout = 0;
    repeat(DWIDTH) begin
      test_count = test_count + 1;
      if (dout == exp_dout) begin
        $display($time, " PASS: dout = %2x", dout);
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: dout = %2x expect = %2x", dout, exp_dout);
      end
      if (din>0) begin
        exp_dout = exp_dout + 1;
      end
      din = (din==0) ? 1 : din << 1;
      repeat(10) @(posedge clk); #1;
    end

    repeat (20) @(posedge clk); #1;
    if (fail_count == 0) begin
      $display($time, "TEST PASSED. All %0d tests passed", test_count);
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


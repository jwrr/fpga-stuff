`timescale 1 ns /  100 ps
module tb();

  reg  rst = 0;
  reg  clk = 0;
  always #5 clk <= !clk;

  reg d = 0;
  wire q;
  wire exp_q;
  dualrank_cdc #(2) u_dut (
    .clk(clk),
    .rst(rst),
    .d(d),
    .q(q)
  );

  integer test_count = 0;
  integer fail_count = 0;
  integer ii = 0;
  initial begin
    $display($time, " info: Start of Simulation");
    @(posedge clk); #1
    rst = 0;
    @(posedge clk); #1
    rst = 1;
    repeat(10) @(posedge clk); #1;
    rst = 0;
    repeat(10) @(posedge clk); #1;

    repeat(10) begin
      repeat(10) @(posedge clk); #1;
      d = ~d; // deassert
      #1;
      test_count = test_count + 1;
      if (q==~d) begin
        $display($time, " PASS: q did not assert asynchronousely");
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: q asserted asynchronously");
      end
      @(posedge clk); # 1;

      test_count = test_count + 1;
      if (q==~d) begin
        $display($time, " PASS: q did not assert early");
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: q asserted early");
      end
      @(posedge clk); # 1;

      test_count = test_count + 1;
      if (q==d) begin
        $display($time, " PASS: q assert on-time");
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: q did not assert on-time");
      end
      @(posedge clk); # 1;

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


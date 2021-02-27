`timescale 1 ns /  100 ps
module tb();

  reg  rst = 0;
  reg  exp_rst;
  wire rst_out;
  reg  clk = 0;
  always #5 clk <= !clk;

  reset_cdc #(1,1,2) u_dut (
    .clk(clk),
    .rst_in(rst),
    .rst_out(rst_out)
  );

  integer test_count = 0;
  integer fail_count = 0;
  integer ii = 0;
  initial begin
    $display($time, " info: Start of Simulation");
    @(posedge clk);
    rst = 0;

    repeat(10) begin
      repeat(10) @(posedge clk); #1;
      rst = 1; // assert asynchronously
      #1;
      test_count = test_count + 1;
      if (rst_out==1) begin
        $display($time, " PASS: reset asserted asynchronousely");
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: reset did nto assert asynchronously");
      end

      repeat(10) @(posedge clk); #1;
      rst = 0; // deassert
      #1;
      test_count = test_count + 1;
      if (rst_out==1) begin
        $display($time, " PASS: reset did not de-asserted asynchronousely");
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: reset de-asserted asynchronously");
      end
      @(posedge clk); # 1;

      test_count = test_count + 1;
      if (rst_out==1) begin
        $display($time, " PASS: reset did not de-assert early");
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: reset de-asserted early");
      end
      @(posedge clk); # 1;

      test_count = test_count + 1;
      if (rst_out==0) begin
        $display($time, " PASS: reset de-assert on-time");
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: reset did not de-assert on-time");
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


`timescale 1 ns /  100 ps
module tb();
  parameter NUM_INPUTS  = 16;
  parameter DWIDTH      = 32;
  parameter DIVISOR     = 43;

  reg                 clk = 0;
  reg                 rst = 0;
  reg   [DWIDTH-1:0]  i_dividend = 0;
  reg                 i_dividend_v = 0;
  wire  [DWIDTH-1:0]  o_quotient;
  wire                o_quotient_v;

  always #5 clk <= !clk;

  divide_by_n #(DWIDTH, DIVISOR) u_dut
  (
    .clk(clk),
    .rst(rst),
    .i_dividend(i_dividend),
    .i_dividend_v(i_dividend_v),
    .o_quotient(o_quotient),
    .o_quotient_v(o_quotient_v)
  );

  integer ii;
  integer print_pass = 0;
  integer fail_count = 0;
  integer timeout_count = 0;
  integer expect_quotient = 0;
  integer expect_min = 0;
  integer expect_ii = 0;

  initial begin
    $display($time, " info: Start of Simulation");
    @(posedge clk); #1 
    rst = 1;
    i_dividend = 0;

    repeat(10) @(posedge clk); #1
    rst = 0;
    repeat(10) @(posedge clk); #1

    for (ii=0; ii<=1000000; ii=ii+1) begin
      i_dividend = ii;
      i_dividend_v = 1;
      expect_quotient = $floor((i_dividend / DIVISOR) + 0.5);
      @(posedge clk); #1
      i_dividend_v = 0;
      timeout_count = 0;
      while (!o_quotient_v) begin
        @(posedge clk); #1
        timeout_count = timeout_count + 1;
        if (timeout_count == 100) begin
          $display($time, " TIMEOUT: waiting for o_quotient_v");
          $finish;
        end
      end
      @(posedge clk); #1
      @(posedge clk); #1

      expect_min = (expect_quotient==0) ? expect_quotient : expect_quotient-1;
      if ((o_quotient >= expect_min) && (o_quotient <= expect_quotient+1)) begin
        if (print_pass) begin
          $display($time, " PASS: i_dividend = %d o_quotient = %d", i_dividend, o_quotient);
        end
      end else begin
        $display($time, " FAIL: i_dividend = %d o_quotient = %d expect = %d", i_dividend, o_quotient, expect_quotient);
        fail_count = fail_count + 1;
        if (fail_count > 10) $finish;
      end

      if (ii % 10000 == 0) begin
        $display($time, " info:  i_dividend = %d  fail_count = %d", i_dividend, fail_count);
      end
    end

    $display($time, " info: End of Simulation");
    $finish;
  end


  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb);
  end


endmodule


`timescale 1 ns /  100 ps
module tb();
  parameter NUMIN    = 16;
  parameter SWIDTH   = $clog2(NUMIN);
  parameter DWIDTH   = 14;

  reg                       rst = 0;
  reg   [SWIDTH-1:0]        sel = 0;
  reg   [NUMIN*DWIDTH-1:0]  din_vec;
  reg   [NUMIN-1:0]         din_vec_v = 0;
  wire  [DWIDTH-1:0]        dout;
  wire                      dout_v;
  reg   [DWIDTH-1:0]        exp_dout;

  reg clk = 0;
  always #5 clk <= !clk;


  mux #(NUMIN, DWIDTH) u_dut (
    .clk(clk),
    .rst(rst),
    .sel(sel),
    .din_vec(din_vec),
    .din_vec_v(din_vec_v),
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
    repeat(10) @(posedge clk);
    rst = 0;
    din_vec = 0;
    din_vec[sel*DWIDTH-1 +: 8] = sel;
    din_vec_v = 0;
    din_vec_v[sel] = 1;
    repeat(10) @(posedge clk);

    repeat(NUMIN) begin
      test_count = test_count + 1;
      if (din_vec[sel*DWIDTH +: DWIDTH] == dout) begin
        $display($time, " PASS: selected sel=%2d dout = %4x", sel, dout);
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: selected sel=%2d dout = %4x expect = %4x", sel, dout, din_vec[sel*DWIDTH +: DWIDTH]);
      end
      test_count = test_count + 1;
      if (din_vec_v[sel] == dout_v) begin
        $display($time, " PASS: selected sel=%2d dout_v = %1b", sel, dout_v);
      end else begin
        fail_count = fail_count + 1;
        $display($time, " FAIL: selected sel=%2d dout_v = %1b expect = %1b", sel, dout_v, din_vec_v[sel]);
      end

      @(posedge clk); #1;
      sel = sel + 1;
      din_vec = 0;
      din_vec[sel*DWIDTH-1 +: 8] = sel;
      din_vec_v = 0;
      din_vec_v[sel] = 1;
      repeat (2) @(posedge clk); #1;
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


`timescale 1 ns /  100 ps
module tb();
  parameter NUMOUT   = 16;
  parameter SWIDTH   = $clog2(NUMOUT);
  parameter DWIDTH   = 14;

  reg                       rst = 0;
  reg   [SWIDTH-1:0]        sel = 0;
  reg   [DWIDTH-1:0]        din = 0;
  reg                       din_v = 0;
  wire  [NUMOUT*DWIDTH-1:0] dout_vec;
  wire  [NUMOUT-1:0]        dout_vec_v;

  reg   [DWIDTH-1:0]        exp_dout;

  reg clk = 0;
  always #5 clk <= !clk;


  demux #(NUMOUT, DWIDTH) u_dut (
    .clk(clk),
    .rst(rst),
    .sel(sel),
    .din(din),
    .din_v(din_v),
    .dout_vec(dout_vec),
    .dout_vec_v(dout_vec_v)
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
    repeat(10) @(posedge clk);

    repeat(NUMOUT) begin
      for (ii=0; ii < NUMOUT; ii = ii + 1) begin
        test_count = test_count + 1;
        if (ii == sel) begin
          if (dout_vec[ii*DWIDTH +: DWIDTH] == din) begin
            $display($time, " PASS: dout_vec[%2d] = %4x", ii, din);
          end else begin
            fail_count = fail_count + 1;
            $display($time, " FAIL: dout_vec[%2d] = %4x expect = %4x", ii, dout_vec[ii*DWIDTH +: DWIDTH], din);
          end
        end else begin
          if (dout_vec[ii*DWIDTH +: DWIDTH] == 0) begin
            $display($time, " PASS: dout_vec[%2d] = %4x", ii, 0);
          end else begin
            fail_count = fail_count + 1;
            $display($time, " FAIL: dout_vec[%2d] = %4x expect = %4x", ii, dout_vec[ii*DWIDTH +: DWIDTH], 0);
          end
        end

        test_count = test_count + 1;
        if (ii == sel) begin
          if (dout_vec_v[ii] == din_v) begin
            $display($time, " PASS: dout_vec_v[%2d] = %1b", ii, din_v);
          end else begin
            fail_count = fail_count + 1;
            $display($time, " FAIL: dout_vec_v[%2d] = %1b expect = %1b", ii, dout_vec_v[ii], din_v);
          end
        end else begin
          if (dout_vec_v[ii] == 0) begin
            $display($time, " PASS: dout_vec_v[%2d] = 0", ii);
          end else begin
            fail_count = fail_count + 1;
            $display($time, " FAIL: dout_vec_v[%2d] = %1b expect = 0", ii, dout_vec_v[ii]);
          end
        end

      end
      
      @(posedge clk); #1;
      din = din + 1;
      din_v = 1;
      sel = sel + 1;
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


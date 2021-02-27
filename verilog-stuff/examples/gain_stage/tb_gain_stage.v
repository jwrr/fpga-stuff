`timescale 1 ns /  100 ps
module tb();
  parameter GAIN_WIDTH        = 16;
  parameter SHIFT_LEFT_SIZE   = 12;
  parameter DIN_WIDTH         = 16;
  parameter DOUT_WIDTH        = 16;

  reg                    rst  = 0;
  reg   [GAIN_WIDTH-1:0] gain = 'h800;
  reg   [DIN_WIDTH-1:0]  din  = 0;
  reg                    din_v = 0;
  wire  [DOUT_WIDTH-1:0] dout;
  wire                   dout_v;

  integer expect_dout;
  integer expect_dout_min;

  reg clk = 0;
  always #5 clk = !clk;

  gain_stage #(GAIN_WIDTH, SHIFT_LEFT_SIZE, DIN_WIDTH, DOUT_WIDTH) u_dut (
    .clk(clk),
    .rst(rst),
    .gain(gain),
    .din(din),
    .din_v(din_v),
    .dout(dout),
    .dout_v(dout_v)
  );

  integer print_pass = 1;
  integer fail_count = 0;
  integer timeout_count = 0;
  integer expect_div3 = 0;
  integer ii = 0;
  integer expect_ii = 0;
  initial begin
    $display($time, " info: Start of Simulation");
    @(posedge clk);
    rst = 1;
    din = 0;

    repeat(10) @(posedge clk);
    rst = 0;
    repeat(10) @(posedge clk);

    for (ii=0; ii<50000; ii=ii+100) begin
      din = ii;
      din_v = 1;
      gain = $urandom & 2**(GAIN_WIDTH-3)-1;
      expect_dout = din * gain / 2**SHIFT_LEFT_SIZE;
      if (expect_dout > 2**DOUT_WIDTH-1) expect_dout = 2**DOUT_WIDTH-1;
      
      @(posedge clk);
      din_v = 0;
      timeout_count = 0;
      while (!dout_v) begin
        @(posedge clk);
        timeout_count = timeout_count + 1;
        if (timeout_count == 100) begin
          $display($time, " TIMEOUT: waiting for din_v");
          $finish;
        end
      end
  
      expect_dout_min = expect_dout==0 ? 0 : expect_dout-1;
      if ((dout >= expect_dout_min) && (dout <= expect_dout+1)) begin
       if (print_pass) begin
          $display($time, " PASS: din = %d *  gain = %d = dout = %d", din, gain, dout);
       end
      end else begin
        $display($time, " FAIL: din = %d *  gain = %d = dout = %d, expected %d", din, gain, dout, expect_dout);
        fail_count = fail_count + 1;
      end
      
      if (ii % 10000 == 0) begin
        $display($time, " info: din = %d fail_count = %d", din, fail_count);
      end
    end

    $display($time, " info: fail_count = %d", fail_count);
    $display($time, " info: End of Simulation");
    $finish;    
  end


  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb);
  end


endmodule


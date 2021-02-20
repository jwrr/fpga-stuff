`timescale 1 ns /  100 ps
module tb();
  parameter NUM_INPUTS  = 16;
  parameter DWIDTH      = 32;

  reg                 clk = 0;
  reg                 rst = 0;
  reg   [DWIDTH-1:0]  n = 0;
  reg                 n_valid = 0;
  wire  [DWIDTH-1:0]  div3;
  wire                div3_valid;
  integer ii;

  
  divide_by_3 #(DWIDTH) u_dut (
    .clk(clk),
    .rst(rst),
    .i_n(n),
    .i_n_valid(n_valid),
    .o_div3(div3),
    .o_div3_valid(div3_valid)
  );
  

  always #5 clk <= !clk;
  integer print_pass = 0;
  integer fail_count = 0;
  integer timeout_count = 0;
  integer expect_div3 = 0;
  integer expect_ii = 0;
  initial begin
    $display($time, " info: Start of Simulation");
    @(posedge clk);
    rst = 1;
    n = 0;

    repeat(10) @(posedge clk);
    rst = 0;
    repeat(10) @(posedge clk);

    for (ii=0; ii<100; ii=ii+1) begin
      n = ii;
      n_valid = 1;
      expect_div3 = n / 3;
      @(posedge clk);
      n_valid = 0;
      timeout_count = 0;
      while (!div3_valid) begin
        @(posedge clk);
        timeout_count = timeout_count + 1;
        if (timeout_count == 100) begin
          $display($time, " TIMEOUT: waiting for div3_valid");
          $finish;
        end
      end
  
      if (div3 == expect_div3) begin
//        if (print_pass) begin
          $display($time, " PASS: n = %d div3 = %d", n, div3);
//        end
      end else begin
        $display($time, " FAIL: n = %d div3 = %d expect = %d", n, div3, expect_div3);
        fail_count = fail_count + 1;
      end
      
      if (ii % 10000 == 0) begin
        $display($time, " info: n = %d fail_count = %d", n, fail_count);
      end
    end

    $display($time, " Test Pipelining");
    expect_ii = 0;
    for (ii=0; ii<1000000; ii=ii+1) begin
      n = ii;
      n_valid = 1;
      @(posedge clk);

      if (div3_valid) begin
        expect_div3 = expect_ii / 3;
        if (div3 == expect_div3) begin
          if (print_pass) begin
            $display($time, " PASS: n = %d div3 = %d", expect_ii, div3);
          end
        end else begin
          $display($time, " FAIL: n = %d div3 = %d expect = %d", expect_ii, div3, expect_div3);
          fail_count = fail_count + 1;
        end
        expect_ii = expect_ii + 1;
      end
      
      if (ii % 100000 == 0) begin
        $display($time, " info: n = %d fail_count = %d", n, fail_count);
      end
    end

    $display($time, " Test Random");
    repeat(30) begin
      n = $urandom & 'hffffffff;
      expect_div3 = n / 3;
      repeat(10) @(posedge clk);
  
      if (div3 == expect_div3) begin
        $display($time, " PASS: n = %d div3 = %d", n, div3);
      end else begin
        $display($time, " FAIL: n = %d div3 = %d expect = %d", n, div3, expect_div3);
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


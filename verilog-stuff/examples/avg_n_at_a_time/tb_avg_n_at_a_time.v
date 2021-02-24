`timescale 1 ns /  100 ps
module tb();
  parameter NUM_INPUTS  = 16;
  parameter DWIDTH      = 16;

  reg                          rst = 0;
  reg  [DWIDTH-1:0]            i_dat_2darray[0:NUM_INPUTS-1];
  reg  [NUM_INPUTS*DWIDTH-1:0] i_dat_vector;
  reg                          i_dat_valid = 0;
  wire [DWIDTH-1:0]            o_avg;
  wire                         o_avg_valid;
  integer ii;
  integer val;
  integer expect_sum;
  integer expect_avg;

  reg clk = 0;
  always #5 clk = !clk;


  avg_n_at_a_time #(NUM_INPUTS, DWIDTH) u_dut (
    .clk(clk),
    .rst(rst),
    .i_dat_vector(i_dat_vector),
    .i_dat_valid(i_dat_valid),
    .o_avg(o_avg),
    .o_avg_valid(o_avg_valid)
  );


  // Convert 2D-Array into a Vector
  always @* begin
    for (ii=0; ii<NUM_INPUTS; ii=ii+1) begin
      i_dat_vector[DWIDTH*ii +: DWIDTH] = i_dat_2darray[ii];
    end
  end


  integer timeout_count = 0;
  initial begin
    $display($time, " info: Start of Simulation");
    @(posedge clk);
    rst = 1;
    for (ii=0; ii<NUM_INPUTS; ii=ii+1) begin
      i_dat_2darray[ii] = 0;
    end
    i_dat_valid = 0;

    repeat(10) @(posedge clk);
    rst = 0;
    repeat(10) @(posedge clk);

    repeat(40) begin
      expect_sum = 0;
      for (ii=0; ii<NUM_INPUTS; ii=ii+1) begin
        val = $urandom & (2**DWIDTH-1);
        i_dat_2darray[ii] = val;
        expect_sum = expect_sum + val;
      end
      expect_avg = $floor(expect_sum / NUM_INPUTS);
      i_dat_valid = 1;
      @(posedge clk);
      i_dat_valid = 0;
      timeout_count = 0;
      while (!o_avg_valid) begin
        @(posedge clk);
        timeout_count = timeout_count + 1;
        if (timeout_count == 100) begin
          $display($time, " TIMEOUT: waiting for o_avg_valid");
          $finish;
        end
      end

      if ((o_avg == expect_avg) || (o_avg == expect_avg+1)) begin
        $display($time, " PASS: o_avg = %x", o_avg);
      end else begin
        $display($time, " FAIL: o_avg = %x expect = %x", o_avg, expect_avg);
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


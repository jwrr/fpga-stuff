`timescale 1 ns /  100 ps
module tb();
  parameter NUM_INPUTS  = 16;
  parameter DWIDTH      = 14;

  reg                          rst = 0;
  reg  [DWIDTH-1:0]            i_dat_2darray[0:NUM_INPUTS-1];
  reg  [NUM_INPUTS*DWIDTH-1:0] i_dat_vector;
  reg                          i_dat_valid = 0;
  wire [DWIDTH-1:0]            o_sum;
  wire                         o_sum_valid;
  integer ii;
  integer val;
  integer expect_sum;

  reg clk = 0;
  always #5 clk <= !clk;


  adder_tree #(NUM_INPUTS, DWIDTH) u_dut (
    .clk(clk),
    .rst(rst),
    .i_dat_vector(i_dat_vector),
    .i_dat_valid(i_dat_valid),
    .o_sum(o_sum),
    .o_sum_valid(o_sum_valid)
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
        val = $urandom & 'h3ff;
        i_dat_2darray[ii] = val;
        expect_sum = expect_sum + val;
      end
      i_dat_valid <= 1;
      @(posedge clk);
      i_dat_valid <= 0;
      timeout_count = 0;
      while (!o_sum_valid) begin
        @(posedge clk);
        timeout_count = timeout_count + 1;
        if (timeout_count == 100) begin
          $display($time, " TIMEOUT: waiting for o_sum_valid");
          $finish;
        end
      end
  
      if (o_sum == expect_sum) begin
        $display($time, " PASS: o_sum = %x", o_sum);
      end else begin
        $display($time, " FAIL: o_sum = %x expect = %x", o_sum, expect_sum);
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


`timescale 1 ns /  100 ps
module tb();
  parameter NUM_INPUTS  = 16;
  parameter DWIDTH      = 14;

  reg                clk = 0;
  reg                rst = 0;
  reg  [DWIDTH-1:0]            i_dat_2darray[0:NUM_INPUTS-1];
  reg  [NUM_INPUTS*DWIDTH-1:0] i_dat_vector;
  wire [DWIDTH-1:0]            o_sum;
  integer ii;
  integer val;
  integer expect_sum;

  
  adder_tree #(NUM_INPUTS, DWIDTH) u_dut (
    .clk(clk),
    .rst(rst),
    .i_dat_vector(i_dat_vector),
    .o_sum(o_sum)
  );
  

  always #5 clk <= !clk;


  // Convert 2D-Array into a Vector
  always @* begin
    for (ii=0; ii<NUM_INPUTS; ii=ii+1) begin
      i_dat_vector[DWIDTH*ii +: DWIDTH] = i_dat_2darray[ii];
    end  
  end


  initial begin
    $display($time, " info: Start of Simulation");
    @(posedge clk);
    rst = 1;
    for (ii=0; ii<NUM_INPUTS; ii=ii+1) begin
      i_dat_2darray[ii] = 0;
    end

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
      repeat(10) @(posedge clk);
  
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


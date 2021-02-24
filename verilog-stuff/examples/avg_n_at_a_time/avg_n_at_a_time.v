//-----------------------------------------------------------------------------
// Block: avg_n_at_a_time
// Description:
// This block adds multiple inputs together and returns a sum.
// NUM_INPUTS defines the number of input values. It must be a power of 2.
// DWIDTH defines the number of bits per input and output.
//
//------------------------------------------------------------------------------

module avg_n_at_a_time #(
  parameter NUM_INPUTS  = 16,
  parameter DWIDTH      = 8
) (
  input                          clk,
  input                          rst,
  input  [NUM_INPUTS*DWIDTH-1:0] i_dat_vector,  // see tb_avg_n_at_a_time on bit packing
  input                          i_dat_valid,
  output [DWIDTH-1:0]            o_avg,
  output                         o_avg_valid
);

  localparam EXTRAWIDTH = $clog2(NUM_INPUTS);
  localparam SUMWIDTH = DWIDTH + EXTRAWIDTH;

  integer ii;
  reg [SUMWIDTH*NUM_INPUTS-1:0] dat_vector_repacked;
  always@* begin
    dat_vector_repacked = 0;
    for (ii=0; ii<NUM_INPUTS; ii=ii+1) begin
      dat_vector_repacked[ii*SUMWIDTH +: DWIDTH] = i_dat_vector[ii*DWIDTH +: DWIDTH];
    end
  end

  wire [SUMWIDTH-1:0] sum;
  wire                sum_valid;
  sum_n_at_a_time #(NUM_INPUTS, SUMWIDTH) u_sum_n_at_a_time
  (
    .clk(clk),
    .rst(rst),
    .i_dat_vector(dat_vector_repacked),
    .i_dat_valid(i_dat_valid),
    .o_sum(sum),
    .o_sum_valid(sum_valid)
  );

  wire [SUMWIDTH-1:0] avg;
  divide_by_n #(SUMWIDTH, NUM_INPUTS) u_divide_by_n
  (
    .clk(clk),
    .rst(rst),
    .i_dividend(sum),
    .i_dividend_v(sum_valid),
    .o_quotient(avg),
    .o_quotient_v(o_avg_valid)
  );

  assign o_avg = avg[DWIDTH-1:0];

endmodule



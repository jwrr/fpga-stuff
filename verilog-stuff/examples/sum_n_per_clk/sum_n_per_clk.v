//-----------------------------------------------------------------------------
// Block: sum_n_per_clk
// Description:
// This block adds multiple inputs together and returns a sum.
// NUM_INPUTS defines the number of input values. It must be a power of 2.
// DWIDTH defines the number of bits per input and output.
//
//------------------------------------------------------------------------------

module sum_n_per_clk #(
  parameter NUM_INPUTS  = 16,
  parameter DWIDTH      = 8
) (
  input                          clk,
  input                          rst,
  input  [NUM_INPUTS*DWIDTH-1:0] i_dat_vector,  // see tb_sum_n_per_clk on bit packing
  input                          i_dat_valid,
  output [DWIDTH-1:0]            o_sum,
  output                         o_sum_valid
);

  localparam NUM_STAGES = $clog2(NUM_INPUTS);
  integer i;

  reg [NUM_INPUTS*DWIDTH-1:0] stage[0:NUM_STAGES];
  reg [NUM_STAGES:0]          stage_valid;
  
  always@* begin
    stage[0] = i_dat_vector;
    stage_valid[0] = i_dat_valid;
  end
  
  genvar stage_number;
  generate
    for (stage_number=1; stage_number <= NUM_STAGES; stage_number = stage_number+1) begin
      always@(posedge clk, posedge rst) begin
        if (rst) begin
          stage[stage_number] <= 0;
          stage_valid[stage_number] <= 0;
        end else begin
          for (i=0; i<NUM_INPUTS/(2**stage_number); i=i+1) begin
            stage[stage_number][i*DWIDTH +: DWIDTH] <= stage[stage_number-1][i*DWIDTH +: DWIDTH] + stage[stage_number-1][(i+NUM_INPUTS/(2**stage_number))*DWIDTH +: DWIDTH];
            stage_valid[stage_number] <= stage_valid[stage_number-1];
          end
        end
      end
    end
  endgenerate

  assign o_sum = stage[NUM_STAGES][0 +: DWIDTH];
  assign o_sum_valid = stage_valid[NUM_STAGES];

endmodule



//-----------------------------------------------------------------------------
// Block: adder_tree
// Description:
// This block adds multiple inputs together and returns a sum.
// NUM_INPUTS defines the number of input values. It must be a power of 2.
// DWIDTH defines the number of bits per input and output.
//
//------------------------------------------------------------------------------

module adder_tree #(
  parameter NUM_INPUTS  = 16,
  parameter DWIDTH      = 8
) (
  input                          clk,
  input                          rst,
  input  [NUM_INPUTS*DWIDTH-1:0] i_dat_vector,  // see tb_adder_tree on bit packing
  output [DWIDTH-1:0]            o_sum
);

  localparam NUM_STAGES = $clog2(NUM_INPUTS);
  integer i;

  reg [NUM_INPUTS*DWIDTH-1:0] stage[0:NUM_STAGES];
  assign o_sum = stage[NUM_STAGES][0 +: DWIDTH];

  always@* stage[0] = i_dat_vector;
  genvar stage_number;
  generate
    for (stage_number=1; stage_number <= NUM_STAGES; stage_number = stage_number+1) begin
      always@(posedge clk, posedge rst) begin
        if (rst) begin
          stage[stage_number] <= 0;
        end else begin
          for (i=0; i<NUM_INPUTS/(2**stage_number); i=i+1) begin
            stage[stage_number][i*DWIDTH +: DWIDTH] <= stage[stage_number-1][i*DWIDTH +: DWIDTH] + stage[stage_number-1][(i+NUM_INPUTS/(2**stage_number))*DWIDTH +: DWIDTH];
          end
        end
      end
    end
  endgenerate
endmodule



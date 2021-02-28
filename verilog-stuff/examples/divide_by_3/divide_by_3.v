//-----------------------------------------------------------------------------
// Block: divide_by_3
// Description:
// This block divides by three by using the series:
//    n/3 = sum(n/2^(2i)) for i=1..infinite or
//    n/3 = n*sum(1/x) for x = 4,       16,    64, 256, 1k, 4k, 16k, 64k ...
//                          or n>>2 + n>>4 + n>>6 + n>>8 + n>>10 + n>>12 ...
// DWIDTH defines the number of bits per input and output.
//
//------------------------------------------------------------------------------

module divide_by_3 #(
  parameter DWIDTH      = 8
) (
  input               clk,
  input               rst,
  input  [DWIDTH-1:0] i_n,
  input               i_n_valid,
  output [DWIDTH-1:0] o_div3,
  output              o_div3_valid
);

  localparam NUM_TERMS     = DWIDTH/2;
  localparam PAD_WIDTH     = DWIDTH/2;
  localparam DWIDTH_PADDED = DWIDTH + PAD_WIDTH;
  localparam NUM_BITS      = NUM_TERMS * DWIDTH_PADDED;
  integer i;

  reg [DWIDTH_PADDED-1:0] n_padded;
  reg                     n_padded_valid;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      n_padded <= 0;
      n_padded_valid <= 0;
    end else begin
      n_padded <= (i_n+1) << PAD_WIDTH;
      n_padded_valid <= i_n_valid;
    end
  end
  
  reg  [NUM_BITS-1:0]      term_vector;
  always@* begin
    for (i=0; i<NUM_TERMS; i=i+1) begin
      term_vector[i*DWIDTH_PADDED +: DWIDTH_PADDED] = n_padded >> (2*(i+1));
    end
  end
  
  wire [DWIDTH_PADDED-1:0] div3_padded;
  wire                     div3_padded_valid;
  sum_n_per_clk #(NUM_TERMS, DWIDTH_PADDED) u_sum_n_per_clk (
    .clk(clk),
    .rst(rst),
    .i_dat_vector(term_vector),
    .i_dat_valid(n_padded_valid),
    .o_sum(div3_padded),
    .o_sum_valid(div3_padded_valid)
  );
  
  assign o_div3 = div3_padded >> PAD_WIDTH;
  assign o_div3_valid = div3_padded_valid;

endmodule



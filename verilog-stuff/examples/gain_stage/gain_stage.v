//-----------------------------------------------------------------------------
// Block: gain_stage
// Description:
// This block ...
//
//------------------------------------------------------------------------------

module gain_stage #(
  parameter GAIN_WIDTH        = 16,
  parameter SHIFT_LEFT_SIZE   = 14,
  parameter DIN_WIDTH         = 16,
  parameter DOUT_WIDTH        = 16
) (
  input                   clk,
  input                   rst,
  input  [GAIN_WIDTH-1:0] gain,
  input  [DIN_WIDTH-1:0]  din,
  input                   din_v,
  output [DOUT_WIDTH-1:0] dout,
  output                  dout_v
);

  localparam PROD_WIDTH = GAIN_WIDTH + DIN_WIDTH;
  localparam MAX_DOUT   = 2**DOUT_WIDTH - 1;
  
  reg [PROD_WIDTH-1:0] prod;
  reg                  prod_v;

  reg [PROD_WIDTH:0]   round;
  reg                  round_v;

  reg [DOUT_WIDTH-1:0] clamp;
  reg                  clamp_v;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      prod    <= 0;
      prod_v  <= 0;
      round   <= 0;
      round_v <= 0;
      clamp   <= 0;
      clamp_v <= 0;
    end else begin
      prod   <= din * gain;
      prod_v <= din_v;
      
      if (prod[SHIFT_LEFT_SIZE-1]) begin
        round <= prod[PROD_WIDTH-1:SHIFT_LEFT_SIZE] + 1;
      end else begin
        round <= prod[PROD_WIDTH-1:SHIFT_LEFT_SIZE];
      end
      round_v <= prod_v;
      
      if (round[PROD_WIDTH:DOUT_WIDTH] == 0) begin
        clamp <= round[DOUT_WIDTH-1:0];
      end else begin
        clamp <= MAX_DOUT;
      end
      clamp_v <= round_v;
    end
  end
  
  assign dout = clamp;
  assign dout_v = clamp_v;
  
endmodule



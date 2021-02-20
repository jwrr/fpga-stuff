//-----------------------------------------------------------------------------
// Block: divide_by_n
// Description:
// This block divides by n. The input value is multiply by 256K/n and then
// divided by 256K.
//
//------------------------------------------------------------------------------

module divide_by_n #(
  parameter DWIDTH  = 8,
  parameter DIVISOR = 43
) (
  input               clk,
  input               rst,
  input  [DWIDTH-1:0] i_dividend,
  input               i_dividend_v,
  output [DWIDTH-1:0] o_quotient,
  output              o_quotient_v
);

  localparam COEF_CONSTANT   = 256*1024/DIVISOR;
  localparam COEF_WIDTH      = 18;
  localparam PRODUCT_WIDTH   = DWIDTH + COEF_WIDTH;

  reg [PRODUCT_WIDTH-1:0] product;
  reg                     product_v;
  reg [COEF_WIDTH-1:0]    coef = COEF_CONSTANT;
  reg [DWIDTH-1:0]        o_quotient;
  reg                     o_quotient_v;
  wire                    roundup = product[COEF_WIDTH-1];
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      product <= 0;
      product_v <= 0;
      o_quotient = 0;
      o_quotient_v = 0;
    end else begin
      product <= i_dividend * coef;
      product_v <= i_dividend_v;
      if (roundup) begin
        o_quotient = (product >> COEF_WIDTH) + 1;
      end else begin
        o_quotient = product >> COEF_WIDTH;
      end
      o_quotient_v = product_v;
    end
  end

endmodule



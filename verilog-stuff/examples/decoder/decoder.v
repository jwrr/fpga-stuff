//-----------------------------------------------------------------------------
// Block: decoder
// Description:
//
//------------------------------------------------------------------------------

module decoder #(
  parameter DOUT_WIDTH  = 8
) (
  input                               clk,
  input                               rst,
  input      [$clog2(DOUT_WIDTH)-1:0] din,
  input                               din_v,
  output reg [DOUT_WIDTH-1:0]         dout
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      dout <= 0;
    end else begin
      dout <= 0;
      dout[din] <= din_v;
    end
  end

endmodule



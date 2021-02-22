//-----------------------------------------------------------------------------
// Block: bin2gray
// Description:
// This block ...
//
//------------------------------------------------------------------------------


module bin2gray #(
  parameter DWID   =  16
) (
  input                 clk,
  input                 rst,
  input      [DWID-1:0] i_bin,
  output reg [DWID-1:0] o_gray
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      o_gray <= 0;
    end else begin
      o_gray <= i_bin ^ (i_bin >> 1);
    end
  end

endmodule



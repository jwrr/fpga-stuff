//-----------------------------------------------------------------------------
// Block: pri_encoder
// Description:
//
//------------------------------------------------------------------------------

module pri_encoder #(
  parameter DWIDTH  = 16
) (
  input                           clk,
  input                           rst,
  input                           enable,
  input      [DWIDTH-1:0]         din,
  input      [DWIDTH-1:0]         din_v,
  output reg [$clog2(DWIDTH)-1:0] dout,
  output reg                      dout_v
);

  integer ii;
  
  wire [DWIDTH-1:0] din2 = din & din_v;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      dout <= 0;
      dout_v <= 0;
    end else begin
      dout_v <= enable && (din2 != 0);
      dout <= 0;
      if (enable) begin
        for (ii=0; ii<DWIDTH; ii=ii+1) begin
          if (din2[ii]) begin
            dout <= ii;
          end
        end
      end
    end
  end

endmodule



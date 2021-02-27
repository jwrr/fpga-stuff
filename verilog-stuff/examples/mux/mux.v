//-----------------------------------------------------------------------------
// Block: mux
// Description:
//
//------------------------------------------------------------------------------

module mux #(
  parameter NUMOUT  = 16,
  parameter DWIDTH  = 8
) (
  input                           clk,
  input                           rst,
  input      [NUMOUT*DWIDTH-1:0]  din_vec,  // see tb_mux on bit packing
  input      [NUMOUT-1:0]         din_vec_v,
  input      [$clog2(NUMOUT)-1:0] sel,
  output reg [DWIDTH-1:0]         dout,
  output reg                      dout_v
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      dout   <= 0;
      dout_v <= 0;
    end else begin
      dout <= din_vec[sel*DWIDTH +: DWIDTH];
      dout_v <= din_vec_v[sel];
    end
  end

endmodule



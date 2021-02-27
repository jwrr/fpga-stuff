//-----------------------------------------------------------------------------
// Block: demux
// Description:
//
//------------------------------------------------------------------------------

module demux #(
  parameter NUMOUT  = 16,
  parameter DWIDTH  = 8
) (
  input                           clk,
  input                           rst,
  input      [DWIDTH-1:0]         din,
  input                           din_v,
  input      [$clog2(NUMOUT)-1:0] sel,
  output reg [NUMOUT*DWIDTH-1:0]  dout_vec,  // see tb_demux on bit packing
  output reg [NUMOUT-1:0]         dout_vec_v
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      dout_vec <= 0;
      dout_vec_v <= 0;
    end else begin
      dout_vec <= 0;
      dout_vec[sel*DWIDTH +: DWIDTH] <= din;
      dout_vec_v <= 0;
      dout_vec_v[sel] <= din_v;
    end
  end

endmodule



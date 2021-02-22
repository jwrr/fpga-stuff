//-----------------------------------------------------------------------------
// Block: gray2bin
// Description:
// This block ...
//
//------------------------------------------------------------------------------


module gray2bin #(
  parameter DWID   =  16
) (
  input                 clk,
  input                 rst,
  input      [DWID-1:0] i_gray,
  output reg [DWID-1:0] o_bin
);

  reg [DWID-1:0] num;
  reg [DWID-1:0] mask;
  reg [DWID-1:0] bin;
  integer        i;
  
  always@* begin
    num  = i_gray;
    mask = num;
    for (i=0; i<DWID; i=i+1) begin
      mask = mask >> 1;
      num  = num ^ mask;
    end
  end
  
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      bin <= 0;
      o_bin <= 0;
    end else begin
      bin <= num;
      o_bin <= bin;
    end
  end // always
  
endmodule



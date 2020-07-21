//-----------------------------------------------------------------------------
// Block: ram
// Description:
// This block ...
//
//------------------------------------------------------------------------------


module ram #(
  parameter AWID  = 8,
  parameter DWID  = 16
) (
  input                 clk,
  input                 i_we,
  input      [AWID-1:0] i_addr,
  input      [DWID-1:0] i_dat,
  output reg [DWID-1:0] o_dat
);

  localparam DEPTH = 256; // 1'b1 << AWID;

  reg [DWID-1:0] mem_array[0:DEPTH-1];

  always @(posedge clk) begin
    if (i_we) begin
      mem_array[i_addr] <= i_dat;
    end
    o_dat <= mem_array[i_addr];
  end

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,ram);
  end


endmodule



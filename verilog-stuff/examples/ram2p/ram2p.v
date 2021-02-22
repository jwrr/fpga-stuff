//-----------------------------------------------------------------------------
// Block: ram
// Description:
// This block ...
//
//------------------------------------------------------------------------------


module ram2p #(
  parameter AWID  = 8,
  parameter DEPTH = 256,
  parameter DWID  = 16
) (
  input                 clka,
  input                 i_wea,
  input      [AWID-1:0] i_addra,
  input      [DWID-1:0] i_data,
  output reg [DWID-1:0] o_data,

  input                 clkb,
  input                 i_web,
  input      [AWID-1:0] i_addrb,
  input      [DWID-1:0] i_datb,
  output reg [DWID-1:0] o_datb
);

  reg [DWID-1:0] mem_array[0:DEPTH-1];

  always @(posedge clka) begin
    if (i_wea) begin
      mem_array[i_addra] <= i_data;
    end
    o_data <= mem_array[i_addra];
  end

  always @(posedge clkb) begin
    if (i_web) begin
      mem_array[i_addrb] <= i_datb;
    end
    o_datb <= mem_array[i_addrb];
  end

endmodule



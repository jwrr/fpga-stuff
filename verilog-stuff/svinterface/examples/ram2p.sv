//-----------------------------------------------------------------------------
// Block: ram
// Description:
// This block ...
//
//------------------------------------------------------------------------------

module ram2p #(
  parameter DEPTH = 256,
  parameter AWID  = 8,
  parameter DWID  = 16
) (
  ram_if.mem porta,
  ram_if.mem portb,
  ram_if.ctrl portc, portd, porte
);

  reg [DWID-1:0] mem_array[0:DEPTH-1];
  reg [DWID-1:0] porta.dout;
  reg [DWID-1:0] portb.dout;

  always @(posedge porta.clk) begin
    if (porta.we) begin
      mem_array[porta.addr] <= porta.din;
    end
    porta.dout <= mem_array[porta.addr];
  end

  always @(posedge portb.clk) begin
    if (portb.we) begin
      mem_array[portb.addr] <= portb.din;
    end
    portb.dout <= mem_array[portb.addr];
  end

endmodule



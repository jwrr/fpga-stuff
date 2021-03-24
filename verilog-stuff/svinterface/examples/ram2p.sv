//-----------------------------------------------------------------------------
// Block: ram
// Description:
// This block ...
//
//------------------------------------------------------------------------------

interface abc_if #(
  parameter DEPTH = 256,
  parameter AWID  = 8,
  parameter DWID  = 16
) (
 input bit clk
);
  logic we;
  logic [DWID-1:0] din, dout;
  logic [AWID-1:0]  addr;
  modport mem  (input  we, din, addr, output dout);
  modport ctrl (output we, din, addr, input  dout);
endinterface

module ram2p #(
  parameter DEPTH = 256,
  parameter AWID  = 8,
  parameter DWID  = 16
) (
  ram_if.mem porta,
  ram_if.mem portb
);

  reg [DWID-1:0] mem_array[0:DEPTH-1];
  reg [DWID-1:0] porta.dout;
  reg [DWID-1:0] portb.dout;
  wire read_enable;
  wire write_enable1, write_enable2;
  ram_if abc;
  bus_if def, ghi, lmn;
  
  

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

module ram5p #(
  parameter DEPTH = 256,
  parameter AWID  = 8,
  parameter DWID  = 16
) (
  ram_if.mem porta,
  bus_if.dest portb,
  ram_if.ctrl portc, portd, porte
);

  reg [DWID-1:0] mem_array[0:DEPTH-1];
  reg [DWID-1:0] porta_dout;
  reg [DWID-1:0] portb_dout;
  assign porta__dout = porta_dout;
  assign portb__dout = portb_dout;

  always @(posedge porta.clk) begin
    if (porta.we) begin
      mem_array[porta.addr] <= porta.din;
    end
    porta_dout <= mem_array[porta.addr];
  end

  always @(posedge portb.clk) begin
    if (portb.we) begin
      mem_array[portb.addr] <= portb.din;
    end
    portb_dout <= mem_array[portb.addr];
  end

endmodule



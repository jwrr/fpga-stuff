//-----------------------------------------------------------------------------
// Block: ram
// Description:
// This block ...
//
//------------------------------------------------------------------------------

interface ram_if #(
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


interface bus_if #(
  parameter DEPTH = 256,
  parameter AWID  = 8,
  parameter DWID  = 16
) (
 input bit clk
);
  logic we;
  logic [DWID-1:0] din, dout;
  logic [AWID-1:0]  addr;
  modport src  (input  we, din, addr, output dout);
  modport dest (output we, din, addr, input  dout);
endinterface


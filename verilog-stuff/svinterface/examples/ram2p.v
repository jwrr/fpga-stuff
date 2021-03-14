module ram2p #(
  parameter DEPTH = 256,
  parameter AWID  = 8,
  parameter DWID  = 16
) (
    input porta__clk, input  porta__we, input [DWID-1:0] porta__din, output [DWID-1:0] porta__dout, input [AWID-1:0] porta__addr, //   ram_if porta,
    input portb__clk, input  portb__we, input [DWID-1:0] portb__din, output [DWID-1:0] portb__dout, input [AWID-1:0] portb__addr //   ram_if portb
);

  reg [DWID-1:0] mem_array[0:DEPTH-1];
  reg [DWID-1:0] porta__dout;
  reg [DWID-1:0] portb__dout;

  always @(posedge porta__clk) begin
    if (porta__we) begin
      mem_array[porta__addr] <= porta__din;
    end
    porta__dout <= mem_array[porta__addr];
  end

  always @(posedge portb__clk) begin
    if (portb__we) begin
      mem_array[portb__addr] <= portb__din;
    end
    portb__dout <= mem_array[portb__addr];
  end

endmodule

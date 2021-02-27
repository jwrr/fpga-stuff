//-----------------------------------------------------------------------------
// Block: stack
// Description:
// This block ...
//
//------------------------------------------------------------------------------


module stack #(
  parameter DEPTH  = 256,
  parameter DWID   =  16
) (
  input             rst,
  input             clk,
  input             push,
  input             pop,
  input  [DWID-1:0] din,
  output [DWID-1:0] dout,
  output reg        dout_v,
  output            empty,
  output            full
);

  localparam AWID = $clog2(DEPTH);

  reg  [AWID:0]   waddr;
  reg  [AWID:0]   raddr;
  wire            full_ram   = waddr == DEPTH;
  wire            full       = full_ram && !pop;
  wire            empty_ram  = waddr == 0;
  reg             empty_ram2;
  wire            empty      = empty_ram && !push;
  wire            write_ram  = push && !full_ram && !pop;
  wire            read_ram   = pop && !empty_ram && !push;
  wire            pushpop    = push && pop;
  reg             push2;
  reg  [DWID-1:0] din2;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      push2  <= 0;
      din2   <= 0;
      dout_v <= 0;
      raddr  <= 0;
      waddr  <= 0;
      empty_ram2 <= 1;
    end else begin
      push2  <= push;
      din2   <= din;
      dout_v <= read_ram || pushpop;
      empty_ram2 <= empty_ram;
      if (write_ram) begin
        raddr <= waddr;
        waddr <= waddr + 1;
      end else if (read_ram) begin
        waddr <= raddr;
        raddr <= raddr - 1;
      end
    end
  end

  // ====================================

  wire [DWID-1:0] dout_ram;
  wire [DWID-1:0] dout_ram2 = empty_ram2 ? 0 : dout_ram;

  ram2p #(DEPTH,AWID,DWID) u_ram2p (
    .clka(clk),
    .i_wea(write_ram),
    .i_addra(waddr[AWID-1:0]),
    .i_data(din),
    .o_data(),
    .clkb(clk),
    .i_web(1'b0),
    .i_addrb(raddr[AWID-1:0]),
    .i_datb({DWID{1'b0}}),
    .o_datb(dout_ram)
  );

  assign dout = push2 ? din2 : dout_ram2;

endmodule



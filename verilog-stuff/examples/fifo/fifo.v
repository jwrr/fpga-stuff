//-----------------------------------------------------------------------------
// Block: fifo
// Description:
// This block ...
//
//------------------------------------------------------------------------------


module fifo #(
  parameter DEPTH  = 256,
  parameter DWID   =  16
) (
  input                 rst,

  input                 wclk,
  input                 i_write_wclk,
  input      [DWID-1:0] i_din_wclk,
  output                o_full_wclk,

  input                 rclk,
  input                 i_read_rclk,
  output     [DWID-1:0] o_dout_rclk,
  output reg            o_empty_rclk
);

  localparam AWID = $clog2(DEPTH);

  // ====================================
  // Sync Resets

  reg [1:0] rst_cdc_wclk;
  wire      rst_wclk = rst_cdc_wclk[1];
  always @(posedge wclk or posedge rst) begin
    if (rst) begin
      rst_cdc_wclk <= 3;
    end else begin
      rst_cdc_wclk <= (rst_cdc_wclk << 1);
    end
  end

  reg [1:0] rst_cdc_rclk;
  wire      rst_rclk = rst_cdc_rclk[1];
  always @(posedge rclk or posedge rst) begin
    if (rst) begin
      rst_cdc_rclk <= 3;
    end else begin
      rst_cdc_rclk <= (rst_cdc_rclk << 1);
    end
  end


  // ====================================
  // Address and Control Logic

  reg  [AWID-1:0] waddr_wclk;
  wire [AWID-1:0] raddr_wclk;
  wire [AWID-1:0] waddr_next_wclk = (waddr_wclk == DEPTH-1) ? 0 : waddr_wclk + 1;
  wire full_wclk  = waddr_next_wclk == raddr_wclk;
  assign o_full_wclk = full_wclk;
  wire write_wclk = i_write_wclk && !full_wclk;

  always @(posedge wclk or posedge rst_wclk) begin
    if (rst_wclk) begin
      waddr_wclk <= 0;
    end else begin
      if (write_wclk) begin
        waddr_wclk <= waddr_next_wclk;
      end
    end
  end

  // ---------------

  reg  [AWID-1:0] raddr_rclk;
  wire [AWID-1:0] waddr_rclk;
  wire empty_rclk = raddr_rclk == waddr_rclk;
  wire read_rclk  = i_read_rclk && !empty_rclk;

  always @(posedge rclk or posedge rst_rclk) begin
    if (rst_rclk) begin
      raddr_rclk <= 0;
      o_empty_rclk <= 1;
    end else begin
      if (read_rclk) begin
        raddr_rclk <= (raddr_rclk == DEPTH-1) ? 0 : raddr_rclk + 1;
      end
      o_empty_rclk = empty_rclk;
    end
  end


  // ====================================
  // Addresses cross clock domains for full/empty flags

  wire [AWID-1:0] waddr_gray;
  bin2gray #(AWID) u_bin2gray_waddr
  (
    .clk    (wclk),
    .rst    (rst_wclk),
    .i_bin  (waddr_wclk),
    .o_gray (waddr_gray)
  );

  gray2bin #(AWID) u_gray2bin_waddr
  (
    .clk    (rclk),
    .rst    (rst_rclk),
    .i_gray (waddr_gray),
    .o_bin  (waddr_rclk)
  );

  // ---------------

  wire [AWID-1:0] raddr_gray;
  bin2gray #(AWID) u_bin2gray_raddr
  (
    .clk    (rclk),
    .rst    (rst_rclk),
    .i_bin  (raddr_rclk),
    .o_gray (raddr_gray)
  );

  gray2bin #(AWID) u_gray2bin_raddr
  (
    .clk    (rclk),
    .rst    (rst_rclk),
    .i_gray (raddr_gray),
    .o_bin  (raddr_wclk)
  );


  // ====================================

  wire [DWID-1:0] dout_rclk;

  ram2p #(AWID,DWID) u_ram2p (
    .clka(wclk),
    .i_wea(write_wclk),
    .i_addra(waddr_wclk),
    .i_data(i_din_wclk),
    .o_data(),
    .clkb(rclk),
    .i_web(1'b0),
    .i_addrb(raddr_rclk),
    .i_datb({DWID{1'b0}}),
    .o_datb(dout_rclk)
  );

  assign o_dout_rclk = o_empty_rclk ? 0 : dout_rclk;

endmodule



//-----------------------------------------------------------------------------
// Block: wave_ram
// Description:
// This block ...
//
//------------------------------------------------------------------------------


module wave_ram #(
  parameter WAVE_RAM_DEPTH  = 256,
  parameter CMD_FIFO_DEPTH  = 256,
  parameter AWIDTH          =   8,
  parameter DWIDTH          =  16,
  parameter CWIDTH          =  24
) (
  input                 rst,     // asynchronous, sync'ed in module
  input                 rclk,
  input                 wclk,
  input    [AWIDTH-1:0] waddr,   // set base addr (auto-increments each wdata_v)
  input                 waddr_v,
  input    [DWIDTH-1:0] wdata,   // data written to wave memory
  input                 wdata_v,
  input    [CWIDTH-1:0] wcmd,    // cmd including start_addr, length, clkrate
  input                 wcmd_v,
  input                 go,      // start reading commands
  output   [DWIDTH-1:0] dout,
  output                dout_v,
  output reg     [15:0] status
);

  // ====================================
  // Sync Resets

  wire w_rst;
  wire r_rst;
  reset_cdc #(1,1,2) u_reset_wclk (.clk(wclk), .rst_in(rst), .rst_out(w_rst));
  reset_cdc #(1,1,2) u_reset_rclk (.clk(rclk), .rst_in(rst), .rst_out(r_rst));


  localparam IDLE=0, RD_WAVE=1;
  reg  [0:0]         r_state, r_state_next;
  reg  [AWIDTH-1:0]  waddr_cnt;
  reg  [AWIDTH-1:0]  waddr_addr;
  reg  [7:0]         clkdiv_val;
  reg  [7:0]         clkdiv_cnt;
  reg  [7:0]         wave_raddr;
  reg  [7:0]         wave_cnt;

  wire cmd_done      = r_state == RD_WAVE && wave_cnt==0 && clkdiv_cnt==0;
  wire wave_done     = cmd_done && r_empty;
  wire rd_first_cmd  = r_state == IDLE && r_state_next == RD_WAVE;
  wire rd_next_cmd   = cmd_done && !r_empty;
  wire rd_fifo_cmd   = rd_first_cmd || rd_next_cmd;

  // ====================================
  // ====================================
  // COMMAND FIFO

  wire w_full;

  wire [CWIDTH-1:0] fifo_cmd_word;
  wire r_empty;

  fifo #(CMD_FIFO_DEPTH, CWIDTH) u_fifo_cmd
  (
    .rst          (rst),
    .wclk         (wclk),
    .i_write_wclk (wcmd_v),
    .i_din_wclk   (wcmd),
    .o_full_wclk  (w_full),
    .rclk         (rclk),
    .i_read_rclk  (rd_fifo_cmd),
    .o_dout_rclk  (fifo_cmd_word),
    .o_empty_rclk (r_empty)
  );


  // ====================================
  // ====================================
  // RCLK DOMAIN

  always@* begin
    case (r_state)
      IDLE:    if (go && !r_empty) r_state_next <= RD_WAVE;
      RD_WAVE: if (wave_done) r_state_next <= IDLE;
      default  r_state_next <= IDLE;
    endcase
  end


  wire wave_clktick = (clkdiv_cnt==0);
  reg rdata_v;
  always @(posedge rclk or posedge r_rst) begin
    if (r_rst) begin
      r_state      <= IDLE;
      wave_raddr   <= 0;
      wave_cnt     <= 0;
      clkdiv_val   <= 0;
      clkdiv_cnt   <= 0;
      rdata_v      <= 0;
    end else begin
      r_state <= r_state_next;

      if (r_state == IDLE) begin
        clkdiv_cnt <= 0;
      end else begin
        clkdiv_cnt <= (clkdiv_cnt==0) ? clkdiv_val : clkdiv_cnt-1;
      end

      if (rd_fifo_cmd) begin
        wave_raddr   <= fifo_cmd_word[0  +: 8];
        wave_cnt     <= fifo_cmd_word[8  +: 8];
        clkdiv_val  <= fifo_cmd_word[16 +: 8];
      end else if (r_state == RD_WAVE) begin
        if (wave_clktick) begin
          wave_raddr <= wave_raddr + 1;
          wave_cnt  <= wave_cnt - 1;
        end
      end

      rdata_v <= r_state == RD_WAVE && !wave_done;

    end
  end


  // ====================================
  // ====================================
  // WCLK DOMAIN

  wire w_empty;
  dualrank_cdc u_dr_empty(.clk(wclk), .rst(w_rst), .d(r_empty), .q(w_empty));

  wire w_state;
  dualrank_cdc u_dr_state(.clk(wclk), .rst(w_rst), .d(r_state), .q(w_state));

  reg  [AWIDTH-1:0] waddr_reg;
  always @(posedge wclk or posedge w_rst) begin
    if (w_rst) begin
      waddr_reg <= 0;
    end else begin
      if (waddr_v) begin
        waddr_reg <= waddr;
      end else if (wdata_v) begin
        waddr_reg <= waddr_reg + 1;
      end

      status <= 0;
      status[0] = w_empty;
      status[1] = w_full;
      status[2] = w_state;

    end
  end


  // ====================================
  // ====================================
  // WAVE RAM
  wire [DWIDTH-1:0] rdata;

  ram2p #(WAVE_RAM_DEPTH, AWIDTH, DWIDTH) u_ram2p_wave (
    .clka(wclk),
    .i_wea(wdata_v),
    .i_addra(waddr_reg),
    .i_data(wdata),
    .o_data(),
    .clkb(rclk),
    .i_web(1'b0),
    .i_addrb(wave_raddr),
    .i_datb({DWIDTH{1'b0}}),
    .o_datb(rdata)
  );

  assign dout = rdata;
  assign dout_v = rdata_v;
endmodule


//-----------------------------------------------------------------------------
// Block: hbridge
// Description:
// This block implements a PWM-based H-Bridge controller using Locked Anti
// Phase drive.  This means the H-Bridge is always driving forwards or
// backwards and a 50% PWM duty cycle results in 0 current. 
// i_pn - H-Bridges are usually built from four N-channel FETs or from two
// P-channel FETs on the top and two N-channel FETs on the bottom.  P-Channel 
// FETs are on when the gate voltage is low. N-channel FETs are on when the 
// gate voltage is high. Whenthe H-Bridge has P-channel FETs on the top then
// set i_pn=1.
// i_enable - when i_enable=0 all the H-Bridge FETs are off.
// i_dead_time - i_dead_time temporarily turns all FETs off when switching.
// This is to prevent shoot-thru. Set this parameter to a small, but not too 
// small, value. A too small value can damage the H-Bridge, . If the H-Bridge 
// has built-in shoot-thru protection then this value can be set to 0.
//------------------------------------------------------------------------------


module hbridge #(
  parameter DWID = 32, PIPELEN=8) (
  input                 clk,
  input                 rst,
  input                 i_pn,    // 0 = nn h-bridge, 1 = pn h-bridge
  input                 i_enable,
  input      [DWID-1:0] i_period,
  input      [DWID-1:0] i_hi_time,
  input      [DWID-1:0] i_hi_more_precision,
  input      [DWID-1:0] i_dead_time,
  output                o_q_tl, // top lef (p-channel or n-channel)
  output                o_q_bl, // bot rig (n-channel)
  output                o_q_tr, // top rig (p-channel or n-channel)
  output                o_q_br  // bot rig (n-channel)
  );

  reg  [DWID-1:0]    cnt;
  wire               pwm;
  reg                pwm2;
  reg  [DWID-1:0]    dead_timer;
  
  reg                q_tl;
  reg                q_bl;
  reg                q_tr;
  reg                q_br;

  assign o_q_tl = i_pn ? !q_tl : q_tl;
  assign o_q_bl = q_bl;
  assign o_q_tr = i_pn ? !q_tr : q_tr;
  assign o_q_br = q_br;

  // shoot-thru protection
  // i_dead_time=0 indicates H-Bridge has built shoot-thru protection
  
  wire stable = (i_dead_time==0) || ((dead_timer==0) && (pwm2==pwm));
  
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      dead_timer <= 'b0;
      q_tl <= 1'b0;
      q_bl <= 1'b0;
      q_tr <= 1'b0;
      q_br <= 1'b0;
      pwm2 <= 1'b0;
      dead_timer <= 'h0;
    end else begin
      pwm2 <= pwm;
      if (i_enable) begin
        q_tl <= pwm && stable;
        q_br <= pwm && stable;
        q_bl <= !pwm && stable;
        q_tr <= !pwm && stable;
        if (pwm2 != pwm) begin
          dead_timer <= (i_dead_time==0) ? 'h0 : i_dead_time - 1;
        end else if (dead_timer != 0) begin
          dead_timer <= dead_timer - 1;
        end
      end else begin
        q_tl <= 1'b0;
        q_bl <= 1'b0;
        q_tr <= 1'b0;
        q_br <= 1'b0;
        dead_timer <= 'h0;
      end
    end
  end
  
  pwm #(DWID) u_pwm (
    .clk                 (clk),
    .rst                 (rst),
    .i_enable            (i_enable),
    .i_period            (i_period),
    .i_hi_time           (i_hi_time),
    .i_hi_more_precision (i_hi_more_precision),
    .o_pwm               (pwm)
  );

endmodule




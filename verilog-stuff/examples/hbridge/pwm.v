//-----------------------------------------------------------------------------
// Block: pwm
// Description:
// This block inplements pulse width modulation. Set i_period to the number
// of clocks of the waveform period. Set i_hi_time to the number of clocks
// the pulse is high. The pulse is always low when i_hi_time=0 and always high
// when i_hi_time > i_period.  Optional input i_hi_time_more_precision proves
// more precision and should be set to zero if not used.  When used the pwm
// high time will be either i_hi_time or i_hi_time+1, defined by the ratio
// i_hi_time_more_precision/2**DWID.
//------------------------------------------------------------------------------


module pwm #(
  parameter DWID = 10) (
  input                 clk,
  input                 rst,
  input                 i_enable,
  input      [DWID-1:0] i_period,
  input      [DWID-1:0] i_hi_time,
  input      [DWID-1:0] i_hi_more_precision, // 0.0 <= more_precision < 1.0
  output reg            o_pwm);

  reg  [DWID-1:0] cnt;
  reg  [DWID-1:0] duty_cnt;
  reg  [DWID  :0] more_precision_cnt;
  reg  [DWID-1:0] this_period;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      o_pwm <= 1'b0;
      cnt   <= 'h0;
      more_precision_cnt <= 'h0;
      this_period <= 'h0;
    end else begin
      this_period <= i_period + more_precision_cnt[DWID];
      if (i_enable) begin
        if (cnt >= this_period) begin
          more_precision_cnt <= {1'b0, more_precision_cnt[DWID-1:0]} + i_hi_more_precision;
        end
        cnt <= (cnt < this_period) ? cnt + 1 : 'h0;
        o_pwm <= (cnt < i_hi_time) ? 1'b1 : 1'b0;
      end else begin
        cnt <= 'h0;
        o_pwm <= 1'b0;
      end
    end
  end
endmodule




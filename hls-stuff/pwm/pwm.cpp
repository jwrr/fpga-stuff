#include "pwm.h"

void pwm(ap_uint<8> i_hi, bool &o_pulse, bool &o_enable_led)
{
#pragma HLS TOP name=pwm
#pragma HLS INTERFACE mode=ap_ctrl_none port=return
#pragma HLS INTERFACE mode=ap_none port=i_hi
#pragma HLS INTERFACE mode=ap_none port=o_pulse
	static int unit_cnt = 0;
	static ap_uint<8> pwm_cnt = 0;
	static bool pulse = 0;
	static bool enable = 0;

	o_pulse = pulse;
	pulse = (pwm_cnt < i_hi);

	o_enable_led = 1;

	bool unit_cnt_wrap = (unit_cnt >= PWM_UNIT_COUNT_MAX-1);
	if (enable && !unit_cnt_wrap) {
		unit_cnt++;
	} else {
		unit_cnt = 0;
	}

	bool pwm_incr = unit_cnt_wrap;
	if (pwm_incr) {
		bool pwm_wrap = (pwm_cnt >= PWM_COUNT_MAX-1);
		if (pwm_wrap) {
			pwm_cnt = 0;
		} else {
			pwm_cnt++;
		}
	} else if (!enable) {
		pwm_cnt = 0;
	}

	enable = (i_hi > 0);

}

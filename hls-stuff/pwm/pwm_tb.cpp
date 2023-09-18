#include "pwm.h"
#include "tb_lib.h"
// void pwm(bool i_enable, ap_uint<PWM_N> i_period, ap_uint<PWM_N> i_hi, bool *o_pulse)

int main()
{
	int  hi = 2;
	bool pulse;
	bool enable_led;

	int cycles_per_wave = PWM_COUNT_MAX * PWM_UNIT_COUNT_MAX;

	for (int wave=0; wave<10; wave++) {
		for (int i=0; i < cycles_per_wave; i++) {
			pwm(hi, pulse, enable_led);
			if (i % PWM_UNIT_COUNT_MAX == 0) {
				tb_printval(pulse);
			}
		}
		tb_endl();
	}
	int status = tb_end();
	return status;
}

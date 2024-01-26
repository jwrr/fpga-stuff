#pragma once
#include <ap_int.h>

#define PWM_UNIT_COUNT_MAX 3906250
// #define PWM_UNIT_COUNT_MAX 100000
#define PWM_COUNT_MAX 100

void pwm(ap_uint<8> i_hi, bool &o_pulse, bool &o_enable_led);

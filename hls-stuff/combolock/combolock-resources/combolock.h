#pragma once

#include <ap_int.h>

#define DEBOUNCE_TIME 64000
#define NUM_DIGITS 4
void combolock(bool i_keypress, ap_uint<4> i_digit, bool i_set_combo, ap_uint<8> &o_status, bool &o_locked);
int sevenseg(int val);

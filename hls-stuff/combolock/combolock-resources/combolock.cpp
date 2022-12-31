#include "combolock.h"
// #include "tb_lib.h"

void combolock(bool i_keypress, ap_uint<4> i_digit, bool i_set_combo, ap_uint<8> &o_status, bool &o_locked)
{
	static ap_uint<3> digit_cnt = 0;
	static unsigned int debounce_cnt = 0;
	static ap_uint<4*NUM_DIGITS> entered_combo = 0;
	static ap_uint<4*NUM_DIGITS> secret_combo = 0x1357;
	static bool locked = 1;
	bool set_combo = i_set_combo && !locked;
	ap_uint<8> status_7seg = sevenseg(digit_cnt);

	if (!i_set_combo) {
		locked = (entered_combo != secret_combo);
	}

	if (!i_keypress){
		debounce_cnt = DEBOUNCE_TIME+1;
	} else if (debounce_cnt > 0){
		if (debounce_cnt==1) {
			if (digit_cnt == 0) {
				entered_combo = i_digit;
			} else {
				entered_combo = (entered_combo << 4) | i_digit;
			}
			if (digit_cnt == NUM_DIGITS-1) {
				digit_cnt = 0;
				if (set_combo) {
					secret_combo = entered_combo;
				}
			} else {
				digit_cnt++;
			}
			// tb_msg("ENTERED_COMBO="+tb_hex(entered_combo)+" secret="+tb_hex(secret_combo)+" is_locked="+tb_dec(locked));
		}
		debounce_cnt--;
	}
	o_status = status_7seg;
	o_locked = locked;
}


int sevenseg(int val)
{
	int s7 = 0;
	switch (val) {
		case 0: s7 = 0b0000001; break;
		case 1: s7 = 0b1001111; break;
		case 2: s7 = 0b0010010; break;
		case 3: s7 = 0b0000110; break;
		case 4: s7 = 0b1001100; break;
		case 5: s7 = 0b0100100; break;
		case 6: s7 = 0b0100000; break;
		case 7: s7 = 0b0001111; break;
		case 8: s7 = 0b0000000; break;
		case 9: s7 = 0b0000100; break;
		default: s7 = 0b0000001;
	}
	return s7;
}

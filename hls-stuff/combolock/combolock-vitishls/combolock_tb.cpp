#include "combolock.h"
#include "tb_lib.h"

using namespace std;
#include <chrono>
using namespace std::chrono;

bool enter_combo(int i_combo, bool set_combo, std::string msg);
bool handle_button(bool keypress_from_button, ap_uint<4> digit_from_switches, bool set_combo, ap_uint<3> &status_exp, int i, bool &is_locked);


int main()
{
	auto start_time = high_resolution_clock::now();
	ap_uint<3> status_exp = 0;
	ap_uint<4> digit_from_switches;

	bool keypress_from_button = 0;
	bool set_combo = 0;
	tb_print_fail();
	bool pass = 1;

	pass &= enter_combo(0x7531, 0, "Test correct default combo opens lock");
	for (int i=0; i<5; i++){
		int combo = std::rand() & 0xFFFF;
		pass &= enter_combo(combo, 1, "Test setting combo");
		pass &= enter_combo(combo^0x1111, 0, "Test wrong combo does not open lock");
		pass &= enter_combo(combo, 0, "Test correct combo opens lock");
	}
	int err_code = tb_final();
	auto stop_time = high_resolution_clock::now();
	auto duration = duration_cast<milliseconds>(stop_time - start_time);
	auto duration_in_seconds = (double)duration.count() / 1000;
	cout << "Runtime: " << duration_in_seconds << " seconds" << endl;
	return err_code;
}


bool enter_combo(int i_combo, bool set_combo, std::string msg)
{
	tb_msg(msg + " with combo = " + tb_hex(i_combo, NUM_DIGITS));
	static int secret_combo = 0x7531;
	if (set_combo){
		secret_combo = i_combo;
	}
	bool keypress_from_button = 0;
	int digit_from_switches = 0;
	ap_uint<3> status_exp = 0;
	bool is_locked;
	bool pass = 1;
	int combo = i_combo;
	for(int i=0; i<8; i++){
		keypress_from_button = !keypress_from_button;
		digit_from_switches = combo & 0xF;
		if (i % 2) {
			combo >>= 4;
		}
		pass &= handle_button(keypress_from_button, digit_from_switches, set_combo, status_exp, i, is_locked);
	}
	bool is_locked_exp = (i_combo != secret_combo);
	msg = is_locked_exp ? "LOCKED because entered combo "+tb_hex(i_combo)+" != secret "+tb_hex(secret_combo) :
			              "OPENED because entered combo "+tb_hex(i_combo)+" == secret "+tb_hex(secret_combo);
	pass &= tb_cmp(is_locked, is_locked_exp, msg);
	return pass;
}


bool handle_button(bool keypress_from_button, ap_uint<4> digit_from_switches, bool set_combo, ap_uint<3> &status_exp, int i, bool &is_locked)
{
	ap_uint<8> status_7seg;
	bool pass = 1;
	bool check_locked = 0;
	std::string msg = "";
	msg = keypress_from_button ? " (pressing button)" : " (releasing button)";
//	tb_msg("Test case: " + tb_dec(digit_from_switches) + msg);
	bool keypress_bouncing = keypress_from_button;
	for(int clkcnt=0; clkcnt<DEBOUNCE_TIME+100; clkcnt++){
		keypress_bouncing = !keypress_bouncing;
		combolock(keypress_bouncing, digit_from_switches, set_combo, status_7seg, is_locked);
		pass &= tb_cmp(status_7seg, tb_7seg(status_exp), "bouncing d="+tb_dec(keypress_bouncing));
	}
	for(int clkcnt=0; clkcnt<DEBOUNCE_TIME+100; clkcnt++){
		combolock(keypress_from_button, digit_from_switches, set_combo, status_7seg, is_locked);
		bool keypress_stable =  (clkcnt == DEBOUNCE_TIME) && keypress_from_button;
//		if (check_locked) {
//			bool is_locked_exp = (i%8 != 6) && !set_combo;
//			pass &= tb_cmp(is_locked, is_locked_exp, "is_locked digit_from_switches="+tb_dec(digit_from_switches));
//			check_locked = 0;
//		}

		if (keypress_stable) {
			if (status_exp == NUM_DIGITS-1){
				status_exp = 0;
			} else {
				status_exp++;
			}
			check_locked = 1;
		}

		pass &= tb_cmp(status_7seg, tb_7seg(status_exp), "Status during handle_button");
	}
	pass &= tb_cmp(status_7seg, tb_7seg(status_exp), "Status 7-segment after handle_button");
	return pass;
} // handle_button

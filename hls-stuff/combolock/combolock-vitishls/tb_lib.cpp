#include <iostream>
using std::cout;
using std::endl;
using std::string;

int tb_cmp_cnt = 0;
int tb_err_cnt = 0;
int tb_err_max = 10;
int tb_print_lvl = 0;  // 0 = print_all, 1 = print_pass, 2 = print_fail, 3 = print_result, 4 = print_final, 5 = quiet


void tb_set_print_lvl(int lvl)
{
	tb_print_lvl = lvl;
}


void tb_print_fail()
{
	tb_print_lvl = 2;
}


void tb_print_all()
{
	tb_print_lvl = 0;
}


bool tb_cmp(int act, int exp, std::string msg = "")
{
	bool pass = exp == act;
	tb_cmp_cnt++;
	bool max_reached = (tb_err_cnt > tb_err_max);
	if (pass) {
		bool print_pass = (tb_print_lvl <= 1);
		if (print_pass && !max_reached) {
			cout << "pass: actual=" << act << " -- " << msg << endl;
		}
	} else {
		tb_err_cnt++;
		bool print_fail = (tb_print_lvl <= 2);
		if (print_fail && !max_reached) {
			cout << "FAIL: actual=" << act << " expect=" << exp << " -- " << msg << endl;
		}
	}
	return pass;
}

void tb_msg(std::string msg, int lvl = 3)
{
	bool print_msg = (tb_print_lvl <= lvl);
	if (print_msg){
		cout << "MSG:  " << msg << endl;
	}
}


bool tb_final()
{
	if (tb_err_cnt == 0){
		cout << "SUCCESS: Test PASSED. All " << tb_cmp_cnt << " tests passed." << endl;
	} else {
		cout << "ERROR: Test FAILED. " << tb_err_cnt << " of " << tb_cmp_cnt << " tests failed." << endl;

	}
	return tb_err_cnt;
}

void tb_dbg(std::string msg)
{
	if (tb_print_lvl == 0) {
		cout << "DEBUG: " << msg << endl;
	}
}

#include <iomanip>
std::string tb_hex(int i, int wid=1)
{
  std::stringstream stream;
  stream << "0x"
         << std::setfill ('0') << std::setw(wid)
         << std::hex << i;
  return stream.str();
}

std::string tb_dec(int i, int wid=1)
{
  std::stringstream stream;
  stream << std::setfill ('0') << std::setw(wid)
         << std::dec << i;
  return stream.str();
}

std::string tb_bin(int i, int wid=1)
{
	std::string str = "";
	while (i != 0) {
		std::string bit = (i % 2) ? "1" : "0";
		str = bit + str;
		i /= 2;
	}
	while (str.length() < wid) {
		str = "0" + str;
	}
	str = "0b" + str;
	return str;
}



int tb_7seg(int val)
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

int tb_decode_7seg(int s7)
{
	int val = 0;
	switch (s7) {
		case 0b0000001: val = 0; break;
		case 0b1001111: val = 1; break;
		case 0b0010010: val = 2; break;
		case 0b0000110: val = 3; break;
		case 0b1001100: val = 4; break;
		case 0b0100100: val = 5; break;
		case 0b0100000: val = 6; break;
		case 0b0001111: val = 7; break;
		case 0b0000000: val = 8; break;
		case 0b0000100: val = 9; break;
		default: val = 0b0000001;
	}
	return val;
}



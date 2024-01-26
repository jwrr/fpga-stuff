#pragma once

bool tb_cmp(int act, int exp, std::string msg = "");
void tb_msg(std::string msg, int lvl = 3);
void tb_endl();
bool tb_end();
void tb_dbg(std::string msg);
void tb_printval(int val, std::string sep="");
void tb_set_print_lvl(int lvl);
void tb_print_fail();
void tb_print_all();

std::string tb_hex(int i, int wid=1);
std::string tb_dec(int i, int wid=1);
std::string tb_bin(int i, int wid=1);
int tb_7seg(int val);
int tb_decode_7seg(int s7);



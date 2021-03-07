#!/usr/bin/env python3


# interface handshake_if(input bit clk);
#   logic request, ack;
#   bit [7:0] data;
#   logic [15:0] addr;
#   modport controller (output request, input ack);
#   modport peripheral (input request, output ack);
#   modport sniffer (input request, ack);
# endinterface

# g_dict["iface"]["name"]
# g_dict["iface"]["name"]["clk_name"] = "clk"
# g_dict["iface"]["name"]["clk_type"] = "logic/bit"
# g_dict["iface"]["name"]["sig"]["name"]["type"] = "logic/bit"
# g_dict["iface"]["name"]["sig"]["name"]["size"] = "[7:0]"
# g_dict["iface"]["name"]["sig"]["name"]["modport"]["modport_name"] = "direction"

import sys
import re
import mylittleparser as mlp

class InterfaceParser(mlp.MyLittleParser):

    g_dict = {}
    g_dict["iface"] = {}


    def parse_interface(self, filename):
        self.slurp_tokens(filename)
        if not self.find_token("interface"):
            sys.exit("'interface' not found")
        iface_name = self.get_name()
        iface_dict = self.g_dict["iface"][iface_name] = {}
        self.parse_clk(iface_dict)
        self.get_keyword(";")
        sig_list = iface_dict["sig"] = {}
        self.parse_signals(sig_list)
        self.parse_modport(sig_list)
        self.get_keyword("endinterface")


    def slurp_tokens(self, filename):
        lines = self.slurp(filename).splitlines()
        lines = self.remove_comments(lines)
        self.g_tokens = self.get_tokens(lines)


    def parse_clk(self, iface_dict):
        if self.get_optional_keyword("("):
            self.get_keyword("input")
            clk_type = self.get_choice("logic bit")
            clk_name = self.get_name()
            iface_dict["clk_name"] = clk_name
            iface_dict["clk_type"] = clk_type
            self.get_keyword(")")


    def parse_signals(self, sig_list):
        token = self.peek_next_token()
        while token in "logic bit".split():
            sig_type = self.get_choice("logic bit")
            sig_size = self.get_from_to("[", "]", sep="")
            sig_name = self.get_name()
            self.add_sig(sig_list, sig_name, sig_type, sig_size)
            token = self.peek_next_token()
            while token == ",":
                self.get_keyword(",")
                sig_name = self.get_name()
                self.add_sig(sig_list, sig_name, sig_type, sig_size)
                token = self.peek_next_token()
            self.get_keyword(";")
            token = self.peek_next_token()


    def add_sig(self, sig_list, sig_name, sig_type, sig_size):
        sig_list[sig_name] = {}
        sig_list[sig_name]["type"] = sig_type
        sig_list[sig_name]["size"] = sig_size
        sig_list[sig_name]["modport"] = {}


    def parse_modport(self, sig_list):
        token = self.peek_next_token()
        while token == "modport":
            self.get_keyword("modport")
            modport_name = self.get_name()
            self.get_keyword("(")
            token = self.get_choice("input output inout")
            while (token != ')') and (token != ""):
                if token in "input output inout".split():
                    modport_dir = token
                    token = self.get_name()
                    continue
                if self.valid_name(token):
                    sig_name = token
                    if sig_name in sig_list:
                        sig_list[sig_name]["modport"][modport_name] = modport_dir
                    else:
                        sys.exit(f"Error on line {self.g_line_i}: Modport signal '{sig_name}' not defined.")
                    token = self.get_choice(", )")
                    if token == ',':
                        token = self.get_next_token()
                    continue
                sys.exit(f"Error on line {self.g_line_i}: expected signame, input, output or inout, got '{token}'.")
            self.get_keyword(";")
            token = self.peek_next_token()


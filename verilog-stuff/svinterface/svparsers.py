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


## ============================================================================
## ============================================================================


class SVParser(mlp.MyLittleParser):

    def parse_parameters(self, parm_list):
        token = self.peek_next_token()
        if token != "#":
            return False
        self.get_keyword("#")
        self.get_keyword("(")
        while True:
            self.get_keyword("parameter")
            parm_name = self.get_name()
            self.get_keyword("=")
            parm_value = self.get_value()
            parm_list[parm_name] = parm_value
            token = self.get_choice(", )")
            if token == ")":
                break


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


    def get_init_value(self):
        token = self.peek_and_get("=");
        if token == "":
            return ""
        value = get_value ()
        return value


    def get_array_size(self):
        port_size = self.get_from_to("[", "]", sep="")


    def add_sig(self, sig_list, sig_name, sig_type, sig_size):
        if sig_name in sig_list.keys():
            self.err(f"Duplicate signal. Signal '{sig_name}' already defined.")
        sig_list[sig_name] = {}
        sig_list[sig_name]["type"] = sig_type
        sig_list[sig_name]["size"] = sig_size
        sig_list[sig_name]["modport"] = {}


## ============================================================================
## ============================================================================


class ModuleParser(SVParser):

    def __init__(self, sv_dict):
        self.sv_dict = sv_dict
        self.module_dict = sv_dict["module"] = {}
        self.lines = []


    def parse_module(self, filename):
        self.slurp_tokens(filename)
        if not self.find_token("module"):
            return
        lnum1 = self.g_line_i
        module_name = self.get_name()
        module_dict = self.module_dict[module_name] = {}
        sig_list  = module_dict["sig"] = {}
        port_list = module_dict["port"] = {}
        parm_list = module_dict["parm"] = {}

        if "iface" in self.sv_dict:
            iface_list = self.sv_dict["iface"]
        else:
            iface_list = self.sv_dict["iface"] = {}

        self.parse_parameters(parm_list)
        self.parse_ports(port_list, iface_list)
        self.get_keyword(";")

        token = self.peek_next_token()
        while token != "endmodule" and token != "":
            if token in "reg wire logic".split():
                self.parse_signal_declaration(sig_list)
#             elif token == "assign":
#                 self.parse_assign()
#             elif token == "always initial":
#                 self.parse_block()
#             elif token == "localparam":
#                 self.parse_localparam()
            else:
                token = self.get_unknown()
            token = self.peek_next_token()
        self.get_keyword("endmodule")
        lnum2 = self.g_line_i+1

        for l in self.lines[lnum1:lnum2]:
            print(l)


    def is_valid_port_type(self, token, iface_list):
        is_port_type = token in "input output inout".split()
        is_iface_name = token in iface_list
        is_valid = is_port_type or is_iface_name
        return is_valid


    def parse_ports(self, port_list, iface_list):
        token = self.peek_next_token()
        if token != "(":
            return False
        self.get_keyword("(");
        token = self.peek_next_token()
        while self.is_valid_port_type(token, iface_list):
            port_type = self.peek_and_get("input output inout")
            is_iface = port_type == ""
            if is_iface:
                iface_name = self.get_name()
                port_type = iface_name;
                port_size = ""
            else:
                port_type += " " + self.peek_and_get("reg wire logic", "wire")
                port_size = self.get_array_size()
            siglist_done = False
            while not siglist_done:
                port_name = self.get_name()
                self.add_sig(port_list, port_name, port_type, port_size)
                token = self.peek_next_token()
                sep = ""
                if token == ",":
                    sep = ","
                if is_iface:
                    iface_sigs = []
                    if "clk_name" in iface_list[iface_name]:
                        iface_clk = iface_list[iface_name]["clk_name"]
                        iface_sigs.append(f"input {port_name}__{iface_clk}")
                    for s in iface_list[iface_name]["sig"]:
                        io = iface_list[iface_name]["sig"][s]["modport"]["mem"]
                        size = iface_list[iface_name]["sig"][s]["size"]
                        iface_sigs.append(f"{io} {size} {port_name}__{s}")
                    iface_sig_str = ", ".join(iface_sigs)
                    self.lines[self.g_line_i] = f"  {iface_sig_str}{sep} // {self.lines[self.g_line_i]}"
                    self.lines[self.g_line_i] = "  " + self.lines[self.g_line_i]
                    from_str = f"{port_name}."
                    to_str = f"{port_name}__"
                    self.lines = [l.replace(from_str, to_str) for l in self.lines]

                if token == ",":
                    self.get_keyword(",")
                    token = self.peek_next_token()
                    if self.is_valid_port_type(token, iface_list):
                        siglist_done = True
                else:
                    siglist_done = True
        self.get_keyword(")")


    def parse_signal_declaration(self, sig_list):
        sig_type = self.peek_and_get("reg wire logic")
        if sig_type == "":
            return False
        while True:
            sig_packed_size = self.get_array_size()
            sig_name = self.get_name();
            sig_unpacked_size = self.get_array_size()
            sig_init_value = self.get_init_value()
            token = self.get_choice(", ;");
            if token == ";":
                break


## ============================================================================
## ============================================================================


class InterfaceParser(SVParser):

    def __init__(self, sv_dict):
        self.iface_dict = sv_dict["iface"] = {}
        self.lines = []
        self.filename = ""

    def parse_interface(self, filename):
        self.slurp_tokens(filename)
        if not self.find_token("interface"):
            return
        lnum1 = self.g_line_i
        iface_name = self.get_name()
        iface_dict = self.iface_dict[iface_name] = {}
        sig_list  = iface_dict["sig"] = {}
        parm_list = iface_dict["parm"] = {}
        self.parse_parameters(parm_list)
        self.parse_clk(iface_dict)
        self.get_keyword(";")
        self.parse_signals(sig_list)
        self.parse_modport(sig_list)
        self.get_keyword("endinterface")
        lnum2 = self.g_line_i
        self.lines = ["//" + l for l in self.lines[lnum1:lnum2]]

        
    def slurp_tokens(self, filename):
        self.filename = filename;
        self.lines = self.slurp(filename).splitlines()
        lines_no_comments = self.remove_comments(self.lines)
        self.lines_of_tokens = self.get_tokens(lines_no_comments)


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


    def parse_modport(self, sig_list):
        token = self.peek_next_token()
        while token == "modport":
            self.get_keyword("modport")
            modport_name = self.get_name()
            self.get_keyword("(")
            while True:
                modport_dir = self.get_choice("input output inout")
                while True:
                    sig_name = self.get_name()
                    if sig_name not in sig_list:
                        self.err(f"Modport signal '{sig_name}' not defined.")
                    sig_list[sig_name]["modport"][modport_name] = modport_dir
                    token = self.get_choice(", )")
                    if token == ")":
                        break
                    token = self.peek_next_token()
                    if token in "input output inout".split():
                        break
                if token == ")":
                    break
            self.get_keyword(";")
            token = self.peek_next_token()


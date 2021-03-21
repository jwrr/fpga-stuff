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

    # parameter_port_list ::=
    #   '#' '(' {parameter_keyword? parameter_identifier '=' constant}* ')' 
    def parse_parameter_port_list(self):
        parms = {} 
        if self.peek_token() != "#":
            return parms
        self.get_keyword("#")
        self.get_keyword("(")
        while True:
            self.get_optional_keyword("parameter")
            parm_name = self.get_name()
            self.get_keyword("=")
            parm_value = self.get_value()
            parms[parm_name] = parm_value
            token = self.get_choice(", )")
            if token == ")":
                break
        return parms


    def parse_signals(self, sig_list):
        token = self.peek_token()
        while token in "logic bit".split():
            sig_type = self.get_choice("logic bit")
            sig_size = self.get_from_to("[", "]", sep="")
            sig_name = self.get_name()
            self.add_sig(sig_list, sig_name, sig_type, sig_size)
            token = self.peek_token()
            while token == ",":
                self.get_keyword(",")
                sig_name = self.get_name()
                self.add_sig(sig_list, sig_name, sig_type, sig_size)
                token = self.peek_token()
            self.get_keyword(";")
            token = self.peek_token()


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

    # module_declaration ::=
    # module_ansi_header { non_port_module_item } endmodule
    def parse_module_declaration(self, filename):
        self.slurp_tokens(filename)
        if not self.find_token("module"):
            return
        lnum1 = self.g_line_i
        self.get_prev_token()
        all_modules = self.module_dict
        all_ifaces = self.sv_dict["iface"] if "iface" in self.sv_dict else {}
        this_module_dict = self.parse_module_header(all_modules, all_ifaces)
        sig_list = this_module_dict["sig"] = {}

        token = self.peek_token()
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
            token = self.peek_token()
        self.get_keyword("endmodule")
        lnum2 = self.g_line_i+1

        for l in self.lines[lnum1:lnum2]:
            print(l)


    def parse_module_header(self, all_modules, all_ifaces):
        return self.parse_module_ansi_header(all_modules, all_ifaces)


    # module_ansi_header ::= 
    # module_keyword module_identifier [ parameter_port_list ] [ list_of_port_declarations ] ;
    def parse_module_ansi_header(self, all_modules_dict, all_ifaces):
        self.get_keyword("module")
        module_name = self.get_name()
        all_modules_dict[module_name] = {}
        module_dict = all_modules_dict[module_name]
        port_list = module_dict["port"] = {}
        module_dict["parm"] = self.parse_parameter_port_list()
        module_dict["port"] = self.parse_list_of_port_declarations(all_ifaces)
        self.get_keyword(";")
        return module_dict


    # list_of_port_declarations
    # '(' port_type port_name { ',' port_type? portname}*  ')'
    # port_type ::= port_direction | interface_name
    def parse_list_of_port_declarations(self, if_list):
        if self.peek_token() != "(":
            return {}
        port_list = {}
        self.get_keyword("(");
        ptype = self.parse_port_type_and_name(port_list, if_list, "")
        while self.get_choice(", )") == ",":
            ptype = self.parse_port_type_and_name(port_list, if_list, ptype)


    def parse_port_type_and_name(self, port_list, if_list, def_port_type=""):
        if_names = " ".join(if_list.keys())
        if self.peek_choice("input output inout") != "":
            port_direction = self.get_choice("input output inout")
            port_type += " " + self.peek_and_get("reg wire logic", "wire")
            port_size = self.get_array_size()
            port_name = self.get_name("port name")
        else:
            port_type = self.peek_and_get_if(if_list, def_port_type)
            if port_type == "":
                self.err("Expecting port type or interface. Got '{self.peek_token()}'")
                
            if_name, if_modport = self.split_default(port_type, ".", 2, "")
            if if_modport == "":
                self.err(f"Modport required for interface '{port_type}'")
        
#             if_name_pieces = port_type.split(".")
#             if len(if_name_pieces) < 2:
#                 self.err(f"Modport required for interface '{port_type}'")
#             if_name, if_modport = if_name_pieces
            port_name = self.get_name("interface port name")
            port_size = ""
            if_sigs = []
            if "clk_name" in if_list[if_name]:
                if_clk = if_list[if_name]["clk_name"]
                if_sigs.append(f"input {port_name}__{if_clk}")
            for signame in if_list[if_name]["sig"]:
                sig = if_list[if_name]["sig"][signame]
                if if_modport not in  sig["modport"]:
                    print(sig["modport"])
                    self.err(f"Undefined modport '{if_modport}' in interface '{if_name}'")
                io = sig["modport"][if_modport]
                size = sig["size"]
                if_sigs.append(f"{io} {size} {port_name}__{signame}")
            if_sig_str = ", ".join(if_sigs)
            comma = self.peek_choice(",", "")
            if "__" in self.lines[self.g_line_i]:
                self.lines[self.g_line_i] = self.lines[self.g_line_i].replace("//", f"  {if_sig_str}{comma} //",1)
            else:
                self.lines[self.g_line_i] = f"  {if_sig_str}{comma} // {self.lines[self.g_line_i]}"
            from_str = f"{port_name}."
            to_str = f"{port_name}__"
            self.lines = [l.replace(from_str, to_str) for l in self.lines]
        self.add_sig(port_list, port_name, port_type, port_size)
        return port_type


    def split_default(self, instring, delim="", num_pieces=2, default_val=""):
        pieces = instring.split(delim)
        pieces_found = len(pieces)
        num_missing_pieces = num_pieces - pieces_found
        if num_missing_pieces > 0:
            for i in range(num_missing_pieces):
                pieces.append(default_val)
        return pieces


    def peek_and_get_if(self, if_list, def_port_type):
        if_name_modport = self.peek_token()
        if_name_pieces = if_name_modport.split(".")
        if if_name_pieces[0] in if_list.keys():
            if_name_modport = self.get_name("interface type")
        else:
            if_name_modport = def_port_type
        return if_name_modport


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
        if iface_name in self.iface_dict:
            self.err(f"Interface '{iface_name}' already defined")
        iface_dict = self.iface_dict[iface_name] = {}
        sig_list  = iface_dict["sig"] = {}
        iface_dict["parm"] = self.parse_parameter_port_list()
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
        token = self.peek_token()
        while token in "logic bit".split():
            sig_type = self.get_choice("logic bit")
            sig_size = self.get_from_to("[", "]", sep="")
            sig_name = self.get_name()
            self.add_sig(sig_list, sig_name, sig_type, sig_size)
            token = self.peek_token()
            while token == ",":
                self.get_keyword(",")
                sig_name = self.get_name()
                self.add_sig(sig_list, sig_name, sig_type, sig_size)
                token = self.peek_token()
            self.get_keyword(";")
            token = self.peek_token()


    def parse_modport(self, sig_list):
        token = self.peek_token()
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
                    token = self.peek_token()
                    if token in "input output inout".split():
                        break
                if token == ")":
                    break
            self.get_keyword(";")
            token = self.peek_token()


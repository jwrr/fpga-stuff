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
# g_dict["iface"]["name"]["sig"]["name"]["modport"]["modport_name"] = "dir"

import sys
import re
import mylittleparser as mlp


# ============================================================================
# ============================================================================


class SVParser(mlp.MyLittleParser):
    def __init__(self):
        self.sv_dict = {}
        self.module_dict = self.sv_dict["module"] = {}
        self.iface_dict = self.sv_dict["iface"] = {}
        self.lines = []
        self.filename = ""

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
            sig = {"name": sig_name, "type": sig_type, "size": sig_size}
            self.add_sig(sig_list, sig)
            token = self.peek_token()
            while token == ",":
                self.get_keyword(",")
                sig["name"] = self.get_name()
                self.add_sig(sig_list, sig)
                token = self.peek_token()
            self.get_keyword(";")
            token = self.peek_token()

    def get_optional_init_value(self):
        token = self.peek_and_get("=", "")
        if token == "":
            return ""
        value = get_value()
        return value

    def get_optional_array_size(self):
        port_size = self.get_from_to("[", "]", sep="")

    def add_sig(self, all_signals, new_signal):
        name = new_signal["name"]
        if name in all_signals.keys():
            self.err(f"Duplicate signal. Signal '{name}' already defined.")
        all_signals[name] = new_signal

    # ============================================================================
    # ============================================================================

    # module_declaration ::=
    # module_ansi_header { non_port_module_item } endmodule
    def parse_module_declaration(self):
        while self.find_token("module"):
            lnum1 = self.g_line_i
            self.get_prev_token()
            all_modules = self.module_dict
            all_ifaces = self.sv_dict["iface"]
            module_name = self.parse_module_header(all_modules, all_ifaces)
            self.parse_module_item(all_modules, all_ifaces, module_name)
            self.get_keyword("endmodule")

    def print_module(self, lnum1):
        lnum2 = self.g_line_i + 1
        for line in self.lines[lnum1:lnum2]:
            print(line)

    def parse_module_item(self, all_modules, all_ifaces, module_name):
        if module_name not in all_modules:
            self.err(f"module '{module_name}' not defined")
        all_sigs = all_modules[module_name]["sig"] = {}
        token = self.peek_token()
        while token != "endmodule" and token != "":
            if self.is_data_type(token, all_ifaces):
                self.parse_signal_declaration(all_sigs, all_ifaces)
            elif self.is_procedural_block(token):
                self.parse_procedural_block(all_sigs, all_ifaces)

            #             elif token == 'assign':
            #                 self.parse_assign()
            #             elif token == 'always initial':
            #                 self.parse_block()
            #             elif token == 'localparam':
            #                 self.parse_localparam()
            else:
                token = self.get_unknown()
            token = self.peek_token()

    def is_procedural_block(self, token):
        keywords = "always always_comb always_latch always_ff "
        keywords += "initial"
        return token in keywords.split()

    def parse_procedural_block(self, all_sigs, all_ifaces):
        block_type = self.get_token("procedureal block keyword")
        sensitivity_list = self.get_optional_sensitivity_list(all_sigs, all_ifaces)
        token = self.peek_and_get("begin")
        if token == "begin":
            begin_end_count = 1
            repeat = True
            while repeat:
                token = self.get_token("in procedural block")
                if token == "begin":
                    begin_end_count += 1
                elif token == "end":
                    begin_end_count -= 1
                repeat = begin_end_count != 0

    def get_optional_sensitivity_list(self, all_sigs, all_ifaces):
        sensivitity_list_str = self.get_from_to("@", ")", " ")
        return sensivitity_list_str

    def parse_module_header(self, all_modules, all_ifaces):
        return self.parse_module_ansi_header(all_modules, all_ifaces)

    # module_ansi_header ::=
    # module_keyword module_identifier \
    #     [ parameter_port_list ] [ list_of_port_declarations ] ;
    def parse_module_ansi_header(self, all_modules, all_ifaces):
        self.get_keyword("module")
        module_name = self.get_name()
        all_modules[module_name] = {}
        module_dict = all_modules[module_name]
        port_list = module_dict["port"] = {}
        module_dict["parm"] = self.parse_parameter_port_list()
        module_dict["port"] = self.parse_list_of_port_declarations(all_ifaces)
        self.get_keyword(";")
        return module_name

    # list_of_port_declarations
    # '(' port_type port_name { ',' port_type? portname}*  ')'
    # port_type ::= port_direction | interface_name
    def parse_list_of_port_declarations(self, if_list):
        if self.peek_token() != "(":
            return {}
        port_list = {}
        self.get_keyword("(")
        ptype = self.parse_port_type_and_name(port_list, if_list, "")
        while self.get_choice(", )") == ",":
            ptype = self.parse_port_type_and_name(port_list, if_list, ptype)

    def parse_port_type_and_name(self, port_list, if_list, def_port_type=""):
        if_names = " ".join(if_list.keys())
        if self.peek_choice("input output inout") != "":
            port_dict = self.get_io_port()
        else:
            port_type = self.peek_and_get_port_type(if_list, def_port_type)
            if port_type in "input output inout":
                port_dict = self.get_io_port(port_type)
            else:
                port_dict = self.get_if_port(if_list, port_type)
        self.add_sig(port_list, port_dict)
        return port_dict["type"]

    def get_io_port(self, port_dir=""):
        if port_dir == "":
            port_dir = self.get_choice("input output inout")
        port_type = f"{port_dir} {self.peek_and_get('reg wire logic', 'wire')}"
        port_size = self.get_optional_array_size()
        port_name = self.get_name("port name")
        return {port_name, port_type, port_size}

    def get_if_port(self, if_list, port_type=""):
        port_size = ""  # arrays of interfaces not supported yet
        if_name, if_modport_name = self.split_name_modport(port_type)
        port_name = self.get_name("interface port name")
        if_dict = if_list[if_name]
        self.expand_if_port(if_dict, if_modport_name, port_name)
        from_str = f"{port_name}."
        to_str = f"{port_name}__"
        self.lines = [line.replace(from_str, to_str) for line in self.lines]
        return {"name": port_name, "type": port_type, "size": port_size}

    def expand_if_port(self, if_dict, if_modport_name, port_name):
        if_sigs = []
        if "clk_name" in if_dict:
            if_clk = if_dict["clk_name"]
            if_sigs.append(f"input {port_name}__{if_clk}")
        for sig_name in if_dict["sig"]:
            if_sig = if_dict["sig"][sig_name]

            modport_defined = if_modport_name != ""
            modport_doesnt_exists = if_modport_name not in if_sig["modport"]
            invalid_modport = modport_defined and modport_doesnt_exists
            if invalid_modport:
                print(f"signal '{sig_name}'", if_sig["modport"])
                err_msg = f"Undefined modport '{if_modport_name}' "
                err_msg += f"for interface signal '{sig_name}'"
                self.err(err_msg)
            if if_modport_name == "":
                size = if_sig["size"]
                if_sigs.append(f"wire {size} {port_name}__{sig_name};")
            else:
                io = if_sig["modport"][if_modport_name]
                size = if_sig["size"]
                if_sigs.append(f"{io} {size} {port_name}__{sig_name}")
        self.update_line_for_if_port(if_sigs)

    def expand_if_data_declaration(self, if_dict, port_name):
        if_sigs = []
        if "clk_name" in if_dict:
            if_clk = if_dict["clk_name"]
            if_sigs.append(f"wire {port_name}__{if_clk};")
        for sig_name in if_dict["sig"]:
            if_sig = if_dict["sig"][sig_name]
            size = if_dict["sig"][sig_name].get("size", "")
            if_sigs.append(f"wire {size} {port_name}__{sig_name};")
        self.update_line_for_if_data_declaration(if_sigs)

    def update_line_for_if_port(self, if_sigs):
        if_sig_str = ", ".join(if_sigs)
        comma = self.peek_choice(",", "")
        lines = self.lines
        linenum = self.g_line_i
        if "__" in lines[linenum]:
            lines[linenum] = lines[linenum].replace(
                "//", f"  {if_sig_str}{comma} //", 1
            )
        else:
            lines[linenum] = f"  {if_sig_str}{comma} // {lines[linenum]}"

    def update_line_for_if_data_declaration(self, if_sigs):
        if_sig_str = " ".join(if_sigs)
        comma = self.peek_choice(",", "")
        lines = self.lines
        linenum = self.g_line_i
        if "__" in lines[linenum]:
            lines[linenum] = lines[linenum].replace(
                "//", f"  {if_sig_str} //", 1
            )
        else:
            lines[linenum] = f"  {if_sig_str} // {lines[linenum]}"

    def peek_and_get_port_type(self, if_list, def_port_type):
        port_type = self.peek_and_get_if(if_list, def_port_type)
        if port_type == "":
            err_msg = f"Expecting port type or interface. "
            err_msg += f"Got '{self.peek_token()}'"
            self.err(err_msg)
        return port_type

    def split_name_modport(self, port_type):
        if_name, if_modport_name = self.split_default(port_type, ".", 2, "")
        if if_modport_name == "":
            self.err(f"Modport required for interface '{port_type}'")
        return if_name, if_modport_name

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

    def parse_signal_declaration(self, sig_list, if_list={}):
        sig_type = self.peek_and_get("reg wire logic integer", "")
        is_builtin_type = sig_type != ""
        if not is_builtin_type:
            sig_type = self.get_name("interface name")
            if not self.is_interface(sig_type, if_list):
                self.err(f"Expected type or interface name. got '{token}'")
        is_interface = not is_builtin_type
        sig = {}
        sig['type'] = sig_type
        sig['packed_size'] = self.get_optional_array_size()
        repeat = True
        while repeat:
            sig['name'] = self.get_name("signal name")
            sig['unpacked_size'] = self.get_optional_array_size()
            sig['init_value'] = self.get_optional_init_value()
            self.add_sig(sig_list, sig)
            if is_interface:
                if_dict = if_list[sig_type]
                self.expand_if_data_declaration(if_dict, sig['name'])
            repeat = self.get_choice(", ;") == ","

    def is_data_type(self, token, all_ifaces):
        if token in "reg wire logic integer".split():
            return True
        return self.is_interface(token, all_ifaces)

    def is_interface(self, token, interface_list):
        return token in interface_list

    def parse_interface_declaration(self):
        while self.find_token("interface"):
            lnum1 = self.g_line_i
            iface_name = self.get_name()
            if iface_name in self.iface_dict:
                self.err(f"Interface '{iface_name}' already defined")
            iface_dict = self.iface_dict[iface_name] = {}
            sig_list = iface_dict["sig"] = {}
            iface_dict["parm"] = self.parse_parameter_port_list()
            self.parse_clk(iface_dict)
            self.get_keyword(";")
            self.parse_signals(sig_list)
            self.parse_modport(sig_list)
            self.get_keyword("endinterface")
            self.comment_out_interface(lnum1)

    def comment_out_interface(self, lnum1):
        lnum2 = self.g_line_i + 1
        for linenum in range(lnum1, lnum2):
            self.lines[linenum] = "// " + self.lines[linenum]

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
            sig = {"name": sig_name, "type": sig_type, "size": sig_size}
            self.add_sig(sig_list, sig)
            token = self.peek_token()
            while token == ",":
                self.get_keyword(",")
                sig_name = self.get_name()
                sig["name"] = sig_name
                self.add_sig(sig_list, sig)
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
                    if "modport" not in sig_list[sig_name]:
                        sig_list[sig_name]["modport"] = {}
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

    # ============================================================================
    # ============================================================================

    def to_verilog(self, filename):
        self.slurp_tokens(filename)
        self.parse_interface_declaration()
        self.reset_tokens()
        self.parse_module_declaration()
        self.print_file()

    def convert_all_to_verilog(self, filelist):
        for file in filelist:
            self.to_verilog(file)

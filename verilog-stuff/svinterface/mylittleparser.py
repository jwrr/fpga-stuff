#!/usr/bin/env python3


#   interface handshake_if(input bit clk);
#     logic request, ack;
#     bit [7:0] data;
#     logic [15:0] addr;
#     modport controller (output request, input ack);
#     modport peripheral (input request, output ack);
#     modport sniffer (input request, ack);
#     <= == >= ::
#   endinterface

import sys
import re


class MyLittleParser:

    dbg = False

    def __init__():
        self.dbg = False
        self.lines_of_tokens = []
        self.g_line_i = 0
        self.g_token_i = -1
        self.filename = ""

    def slurp(self, filename):
        self.lines_of_tokens = []
        self.g_line_i = 0
        self.g_token_i = -1
        self.filename = filename
        text = ""
        with open(filename, "r") as infile:
            text = infile.read()
        return text

    def remove_comments(self, lines):
        return [re.sub(r"//.*", "", line) for line in lines]

    def get_tokens(self, lines, special_tokens="== <= >= :: += ++ --"):
        tokens = []
        for line in lines:
            # add space around all special characters
            line = re.sub(r"([^\w\s'.])", r" \1 ", line)
            # remove the spaces just incorrectly added into special tokens
            for special in special_tokens.split():
                line = line.replace("  ".join(list(special)), special)
            tokens.append(line.split())
        return tokens

    def slurp_tokens(self, filename):
        self.filename = filename
        self.lines = self.slurp(filename).splitlines()
        lines_no_comments = self.remove_comments(self.lines)
        self.lines_of_tokens = self.get_tokens(lines_no_comments)

    def reset_tokens(self, token_idx=0):
        self.g_token_i = 0
        self.g_line_i = 0

    def print_file(self):
        for line in self.lines:
            print(line)

    def get_token(self):
        self.g_token_i += 1
        while (self.g_line_i < len(self.lines_of_tokens)) and (
            self.g_token_i >= len(self.lines_of_tokens[self.g_line_i])
        ):
            self.g_token_i = 0
            self.g_line_i += 1

        if self.g_line_i >= len(self.lines_of_tokens):
            return ""

        token = self.lines_of_tokens[self.g_line_i][self.g_token_i]
        return token

    def peek_token(self):
        save_line_i = self.g_line_i
        save_token_i = self.g_token_i
        token = self.get_token()
        self.g_line_i = save_line_i
        self.g_token_i = save_token_i
        return token

    def get_prev_token(self):
        if len(self.lines_of_tokens) == 0:
            return ""

        self.g_token_i -= 1
        while self.g_token_i < 0:
            self.g_line_i -= 1
            if self.g_line_i < 0:
                return ""
            if len(self.lines_of_tokens[self.g_line_i]) > 0:
                self.g_token_i = len(self.lines_of_tokens[self.g_line_i]) - 1
        token = self.lines_of_tokens[self.g_line_i][self.g_token_i]
        return token

    def find_token(self, needle):
        token = self.get_token()
        while (token != needle) and (token != ""):
            token = self.get_token()
        return token == needle

    def find_upto_token(self, needle):
        found = self.find_token(needle)
        if found:
            self.get_prev_token()
        return found

    def get_including_token(self, needle, sep=" "):
        token = self.get_token()
        tokens = token
        while (token != needle) and (token != ""):
            token = self.get_token()
            tokens += sep + token
        if token != needle:
            return ""
        return tokens

    def get_from_to(self, first, last, sep=" "):
        token = self.peek_token()
        if first != "" and token != first:
            return ""
        first_token = "" if first == "" else self.get_token()
        the_rest = self.get_including_token(last, sep)
        if the_rest == "":
            return ""
        tokens = first_token + sep + the_rest
        self.dbg_print(f"get_from_to: {tokens}")
        return tokens

    def err(self, msg=""):
        err_lines = ""
        lines = self.lines
        linenum = self.g_line_i
        if linenum > 0:
            err_lines += f"{linenum}: {lines[linenum-1]}"
        err_lines += f"\n{linenum+1}: {lines[linenum]}"
        if linenum + 1 < len(lines):
            err_lines += f"\n{linenum+2}: {lines[linenum+1]}\n"
        err_msg = f"Error in file {self.filename}, line {linenum+1} - {msg}"
        err_msg += f"\n{err_lines}"
        sys.exit(err_msg)

    def get_keyword(self, keyword):
        token = self.get_token()
        if token != keyword:
            self.err(f"Expected '{keyword}', got '{token}'.")
        self.dbg_print(f"get_keyword: {token}")
        return token

    def get_optional_keyword(self, keyword):
        token = self.peek_token()
        if token != keyword:
            return ""
        self.dbg_print(f"get_optional_keyword: {token}")
        return self.get_token()

    def valid_name(self, token):
        return bool(re.match(r"^[\w\.]*$", token))

    def get_name(self, msg=""):
        token = self.get_token()
        if not self.valid_name(token):
            msg = "identifer" if msg == "" else msg
            self.err(f"Expected {msg}, got '{token}'.")
        msg = "" if msg == "" else f" ({msg})"
        self.dbg_print(f"get_name{msg}: {token}")
        return token

    def get_value(self):
        token = self.get_token()
        self.dbg_print(f"get_value: {token}")
        return token

    def get_unknown(self):
        token = self.get_token()
        self.dbg_print(f"get_unknown: {token}")
        return token

    def get_choice(self, choices):
        token = self.get_token()
        for choice in choices.split():
            if token == choice:
                self.dbg_print(f"get_choice: {token}")
                return token
        self.err(f"Expected one of '{choices}', got '{token}'.")

    def peek_and_get(self, choices, default_selection=""):
        token = self.peek_token()
        if token in choices.split():
            token = self.get_token()
            self.dbg_print(f"peek_and_get: {token}")
            return token
        else:
            return default_selection

    def peek_choice(self, choices, default_selection=""):
        token = self.peek_token()
        if token in choices.split():
            return token
        else:
            return default_selection

    def dbg_print(self, msg):
        if self.dbg:
            print(msg)

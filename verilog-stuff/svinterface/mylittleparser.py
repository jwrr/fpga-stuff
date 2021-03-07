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

    g_tokens  = []
    g_line_i  = 0
    g_token_i = -1
    
    def slurp(self, filename):

        self.g_tokens  = []
        self.g_line_i  = 0
        self.g_token_i = -1

        text = ""
        with open(filename, "r") as infile:
            text = infile.read()
        return text
    
    def get_tokens(self, lines, special_tokens = "== <= >= :: += ++ --"):
        tokens = []
        for line in lines:
            # add space around all special characters
            line = re.sub(r"([^\w\s])", r" \1 ", line)
            # remove the spaces just incorrectly added into special tokens
            for special in special_tokens.split():
                line = line.replace("  ".join(list(special)), special)
            tokens.append(line.split())
        return tokens

    
    def remove_comments(self, lines):
        return [re.sub(r"//.*", "", line) for line in lines]
    
    
    def get_next_token(self):
        self.g_token_i += 1
        while (self.g_line_i < len(self.g_tokens)) and (self.g_token_i >= len(self.g_tokens[self.g_line_i])):
            self.g_token_i = 0
            self.g_line_i += 1
    
        if self.g_line_i >= len(self.g_tokens):
            return ""
    
        token = self.g_tokens[self.g_line_i][self.g_token_i]
        return token
    
    
    def peek_next_token(self):
        save_line_i = self.g_line_i
        save_token_i = self.g_token_i
        token = self.get_next_token();
        self.g_line_i = save_line_i
        self.g_token_i = save_token_i
        return token;
    
    
    def get_prev_token(self):
        if len(self.g_tokens) == 0:
            return ""
    
        self.g_token_i -= 1
        while (self.g_token_i < 0):
            self.g_line_i -= 1
            if (self.g_line_i < 0):
                return ""
            if len(self.g_tokens[self.g_line_i]) > 0:
                self.g_token_i = len(self.g_tokens[self.g_line_i])-1
        token = self.g_tokens[self.g_line_i][self.g_token_i]
        return token
    
    
    def find_token(self, needle):
      token = self.get_next_token()
      while (token != needle) and (token != ""):
        token = self.get_next_token()
      return token == needle
    
    
    def get_including_token(self, needle, sep=" "):
        token = self.get_next_token()
        tokens = token
        while (token != needle) and (token != ""):
            token = self.get_next_token()
            tokens += sep + token
        if token != needle:
            return ""
        return tokens
    
    
    def get_from_to(self, first, last, sep=" "):
        token = self.peek_next_token()
        if token != first:
            return ""
        first_token = self.get_next_token()
        the_rest = self.get_including_token("]", sep)
        if the_rest == "":
            return ""
        tokens = first_token + sep + the_rest
        return tokens
    
    
    def get_keyword(self, keyword):
        token = self.get_next_token()
        if token != keyword:
            sys.exit(f"Error on line {self.g_line_i}: expected '{keyword}', got '{token}'.")
    
    
    def get_optional_keyword(self, keyword):
        token = self.get_next_token()
        if token != keyword:
            self.get_prev_token()
            return False
        return True
    
    
    def valid_name(self, token):
        return bool(re.match(r"^[\w\.]*$", token))
    
    
    def get_name(self):
        token = self.get_next_token()
        if not self.valid_name(token):
            sys.exit(f"Error on line {self.g_line_i}: expected identifier, got '{token}'.")
        return token
    
    
    def get_choice(self, choices):
        token = self.get_next_token()
        for choice in choices.split():
            if token == choice:
                return token
        sys.exit(f"Error on line {self.g_line_i}: expected one of '{choices}', got '{token}'.")
    


#!/usr/bin/env python3

import sys
import svparsers as svp

filelist = sys.argv[1:]

sv_dict = {}

# Pass 1 - Make interface data structure
iface_parser = svp.InterfaceParser(sv_dict)
iface_parser.dbg = False
for file in filelist:
    iface_parser.parse_interface(file)
# print(iface_parser.iface_dict)

# Pass 2 - Convert interfaces
module_parser = svp.ModuleParser(sv_dict)
module_parser.dbg = False
for file in filelist:
  module_parser.parse_module_declaration(file)




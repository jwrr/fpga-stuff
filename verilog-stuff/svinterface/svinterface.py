#!/usr/bin/env python3

import sys
import svparsers as svp

sv_parser = svp.SVParser()
sv_parser.dbg = False
sv_parser.convert_all_to_verilog(sys.argv[1:])

#!/usr/bin/env python3

import sys
import svparsers as svp

ifp = svp.InterfaceParser()
filelist = sys.argv[1:]
for file in filelist:
    ifp.parse_interface(file)
print(ifp.g_dict)


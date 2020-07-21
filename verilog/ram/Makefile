# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

#MODULE = test_ram_directed
MODULE ?= test_ram_random
VERILOG_SOURCES = rtl/ram.v
TOPLEVEL = ram

# Shorten log line
export COCOTB_REDUCED_LOG_FMT = 1

# DEBUG, INFO, WARNING, ERROR, CRITICAL
export COCOTB_LOG_LEVEL = INFO
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

WAVES = $(TEST).vcd
WAVES_TOP ?= TOPLEVEL
WAVES_LVL ?= 0

include $(shell cocotb-config --makefiles)/Makefile.sim

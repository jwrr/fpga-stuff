# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

TOPLEVEL ?= ram
MODULE ?= test_$(TOPLEVEL)
VERILOG_SOURCES = rtl/ram.v

# DEBUG, INFO, WARNING, ERROR, CRITICAL
export COCOTB_LOG_LEVEL ?= INFO
export COCOTB_REDUCED_LOG_FMT ?= 1
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

include $(shell cocotb-config --makefiles)/Makefile.sim

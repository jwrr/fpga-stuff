# Makefile
BLOCK?=reg

### ICARUS TOPLEVEL_LANG = verilog
### ICARUS PWD=$(shell pwd)
### ICARUS VERILOG_SOURCES = $(PWD)/$(BLOCK).v
### ICARUS TOPLEVEL = $(BLOCK)
### ICARUS MODULE = test_$(BLOCK)
### ICARUS include $(shell cocotb-config --makefiles)/Makefile.sim

# DEBUG, INFO, WARNING, ERROR, CRITICAL
export COCOTB_LOG_LEVEL ?= INFO
export COCOTB_REDUCED_LOG_FMT ?= 1

SIM = ghdl
EXTRA_ARGS=--std=08
SIM_ARGS=--vcd=waves.vcd
#SIM_ARGS=--wave=waves.ghw
TOPLEVEL_LANG = vhdl
# export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)
VHDL_SOURCES = $(PWD)/$(BLOCK).vhd
TOPLEVEL := $(BLOCK)
MODULE   := test_$(BLOCK)
include $(shell cocotb-config --makefiles)/Makefile.sim


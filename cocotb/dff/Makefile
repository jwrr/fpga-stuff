# Makefile.ghdl

### ICARUS TOPLEVEL_LANG = verilog
### ICARUS PWD=$(shell pwd)
### ICARUS VERILOG_SOURCES = $(PWD)/dff.v
### ICARUS TOPLEVEL = dff
### ICARUS MODULE = test_dff
### ICARUS include $(shell cocotb-config --makefiles)/Makefile.sim

# SIM = ghdl
# SIM_ARGS=--vcd=waves.vcd
TOPLEVEL_LANG = vhdl
# export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)
VHDL_SOURCES = $(PWD)/dff.vhd
TOPLEVEL := dff
MODULE   := test_dff
include $(shell cocotb-config --makefiles)/Makefile.sim


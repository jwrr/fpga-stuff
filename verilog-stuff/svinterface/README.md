SVinterface.py
==============


What is it, what will it be?
-------------------------------

The goal is to convert systemverilog interfaces into verilog-2005 and be a
preprocessor for simulation and synthesis tools that support verilog, but do
not yet support systemverilog.


STATUS
------
Very preliminary work in progress.

Converts of ramp2p.sv -> ram2p.v

% python3 svinterface.py examples/ram2p.sv > examples/ram2p.v


NEXT STEPS
----------

* convert ram2p_tb.v
* convert ram2p_wrapper.v
* get parameters working




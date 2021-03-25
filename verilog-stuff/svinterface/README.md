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

Example
-------
$ python3 svinterface.py examples/ram2p_if.sv examples/ram2p.sv > x.v
$ iverilog x.v


NEXT STEPS
----------

* handle modports - done
* expand "abc_if x _;" to "wire x__we; wire [7:0] x__wdata; ..." - done
* expand interfaces in instantiations - next

* convert ram2p_tb.v
* convert ram2p_wrapper.v
* get parameters working

* All interface signals are interpretted as wires.
  * Convert reg [15:0] bus_if.data; -> reg [15:0] bus_if__data_r; assign bus_if__data = bus_if__data_r; 
  * The above shouldn't be supported.  Instead
    * reg [15:0] rdata; assign bus_if.rdata = rdata;
  * Or: convert all rhs to if__signame, convert assigns to if__signame
    convert lhs in always block to reg if__signame_r; assign if__signame = if_signame;   


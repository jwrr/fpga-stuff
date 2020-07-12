Test DFF with Cocodb
====================

The first few examples use a simple vhdl testbench.  For more advanced
testing two popular VHDL test frameworks are [OSSVM][osvvm] and [UVVM][uvvm].

But, for me, this is the year of Python.  So I'll use [Cocotb][cocotb].



Install python and pip 
----------------------

```
sudo apt update
sudo apt upgrade
sudo dpkg --configure -a
sudo apt upgrade
sudo install python3 python3-pip
sudo apt install python3-pip
sudo apt autoremove 
```

Install cocotb
--------------

```
pip install cocotb
```

Install Icarus Verilog
----------------------

```
sudo apt install iverilog
```

Run Cocotb + Icarus
-------------------

```
make SIM=icarus
```

Run Cocotb + GHDL Sim with Waves
--------------------------------

```
make SIM=ghdl SIM_ARGS=--vcd=ghdl_dff.vc
```

[osvvm]: https://github.com/OSVVM/OSVVM
[uvvm]: https://github.com/UVVM/UVVM
[cocotb]: https://cocotb.org


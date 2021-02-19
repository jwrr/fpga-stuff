VHDL tested with cocotb
=======================

Install cocotb, ghdl and gtkwave
--------------------------------

```
pip3 install cocotb
cocotb-config --version
sudo apt update
sudo apt install build-essential
sudo apt install ghdl
sudo apt install gtkwave
```

Run GHDL Simulation driven by cocotb Python testbench
-----------------------------------------------------

```
make BLOCK=srff
make BLOCK=reg
...
```

run all tests

```
source run_regress 
```

View VCD Waves
--------------

```
gtkwaves waves.vcd
```


Error: Missing VHDL 2008 Libraries
-----------------------------------

If you get the following error:

```
error: unit "numeric_std" not found in library "ieee"
```

then build ghdl from the source

```
sudo apt update
sudo apt install gnat-gps
git clone https://github.com/ghdl/ghdl
cd ghdl
./configure
make
sudo make install
```


Error: GTKWave missing library
-----------------------------

Error message: Gtk-Message: 11:29:36.021: Failed to load module "canberra-gtk-module"

```
sudo apt install libcanberra-gtk-module
```






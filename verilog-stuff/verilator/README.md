Verilator Examples
==================


 Install Verilator on Ubuntu 22.04
 ---------------------------------
 
 ````bash
 sudo apt-get update
 sudo apt-get upgrade
 sudo apt-get verilator
 ```
 
 Download Blinky From ZIPCPU
 ---------------------------

```bash
wget https://zipcpu.com/tutorial/ex-02-blinky.tgz
tar zxvf ex-02-blinky.tgz
cd ex-02-blinky
```

Compile and Run Verilator Simulation
------------------------------------

```bash
make
./blinky
```

View signal Waveforms
---------------------

```bash
gtkwave blinkytrace.vcd
```





 
 
 
 

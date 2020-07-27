# Embedded UVM

An open source UVM implementation in the D language. It is a line-by-line port 
of Systemverilog UVM. e-UVM was previously called VLang.

# Links

* [Embedded UVM Site](http://uvm.io/)
* [Forum](https://forum.uvm.io/)
* [Udemy Tutorial -  VSD - Embedded-UVMO pensource Verification and Emulation ](https://www.udemy.com/course/vsd-embedded-uvm/)
  * [Github Examples](https://github.com/uvm)
  * [Author's Github Page](https://github.com/puneet) 

## The Problems

* Performance
  * Chips continue becoming more complex
  * Processor frequency is not increasing
  * Single threaded verification is not keeping up
  * 
  
* Open Source Flow
  * More and more hardward is going open source
  * Proprietary tools are not compatible with cloud-based, distributed development
  * Currently SystemVerilog only has proprietary implementations
  
## The Solutions
  
* Multi-thread is needed
* Hardware Accelerators are needed
  * Intel Xeon has embedded Arria FPGA - It's happening now
* A complete open-source tool chain running on cloud-based CI


## Why not SystemVerilog UVM?

* SystemVerilog is single threaded. Slow simulation times.
  * Big-3 RTL simulators are becoming multi-threaded, SystemVerilog is becoming bottleneck
* Limited selection of pre-built tools
* UVM is an open standard but all SystemVerilog implementations are proprietary
 
## Why not System-C UVM?

* System-C UVM is an independant implementation, so there may be subtle differences with SystemVerilog UVM.
* System-C oes not have garbage collection, UVM relies heavily on garbage collection


## Why Embedded UVM? [See E-UVM FAQ](http://uvm.io/faq/)

* Good mult-thread support
* Large selection of 3rd party API.
* Object model with garbage collection is more compatible with UVM
* Good constraint solver
* Apache 2.0 open source license

## Why D?

* E-UVM inherits many of its properties from the D system programming language
* D has Java like support for concurrency
* ABI compatible with C++ can call C/C++ libraries
* Automatic Garbage Collection
* Meta programming makes for clean constraint-solver implementation


## Install

### Install D Compiler, Verilog simulator and Waveform viewer

The D compiler is not needed because it is downloaded with euvm

```
sudo apt update
sudo apt install verilog gtkwave # icarus verilog simulator
# sudo apt install ldc # LLVM-based D compiler
```

### Install E-UVM

```
wget http://download.uvm.io/euvm-1.0-beta9.tar.xz
tar xf euvm-1.0-beta9.tar.xz
export PATH=$PWD/euvm-1.0-beta9/bin:$PATH
cd euvm-1.0-beta9/
git clone https://github.com/uvm/avst_adder
cd cd avst_adder/testbench
make
make run
gtkwave avst_adder.vcd
```


## Testbench Architecture

* Functional Spec -> Testcases -> Factory -> Transactor (Sequencer) -> Drivers -> Collectors -> Monitors -> Ref Model -> Scoreboard -> Functional Coverage -> Coverage Goals
* Trasactor converts sequence into sequence items

# AXI4 Lite SHA3 Example




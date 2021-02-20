# Single Port RAM in Verilog.r

* Simulate with [Icarus Verilog](http://iverilog.icarus.com/)
* Test with Python / [cocotb](https://docs.cocotb.org/en/stable/).

## Details

* Create a simple Verilog memory model.  It's a single port RAM loosely based on the
[Lattice ICE40 Embedded Block RAM(EBR)]
(file:///C:/Users/Robin/AppData/Local/Temp/MemoryUsageGuideforiCE40Devices-2.pdf) 
Hopefully it should be inferred by [Yosys Open Source Synthesis tools]
(http://www.clifford.at/yosys/links.html).
* Make an old school verilog testbench to make sure it's alive. It just writes and then reads all locations.
* Make a randomized cocotb testbench. It writes/reads to random locations.  It then reads all locations.

## Simulated Verilog-only using Icarus

```
sudo apt update
sudo apt install iverilog
iverilog -o tb_ram.vvp ram.v tb_ram.v
vvp tb_ram.vvp
gtkwave test.vcd
```

## Simulate using cocotb+iverilog

```
make
gtkwave test.vcd
```


## Summary

* The RAM is simple to verify in with pure Verilog test.
* The cocotb testbench was easy to create and was much more thorough.  The cocotb
  approach will scale to more complex designs.


## Links I went to while creating this test

* [Does Icarus Verilog support SystemVerilog?](
https://iverilog.fandom.com/wiki/Iverilog_Flags)
  * Verilog 2005 is the default. SystemVerilog 2012 development is ongoing. 
    cocotb uses the -g2012 switch.
* [cocotb quickstart](https://docs.cocotb.org/en/stable/quickstart.html)
* [Python Dictionary](https://www.tutorialspoint.com/python/python_dictionary.htm)
  * dict{}, dict.update({newkey : newval}), val = expect_ram[key], 
* [Python is key defined in Dictionary](
https://www.geeksforgeeks.org/python-check-whether-given-key-already-exists-in-a-dictionary/)
  * if key in dict.keys(): 
* [Python Convert int to hex string](
https://stackoverflow.com/questions/2269827/how-to-convert-an-int-to-a-hex-string)
  * hexstr = hex(i)
* [Python assert stops test](
https://stackoverflow.com/questions/4732827/continuing-in-pythons-unittest-when-an-assertion-fails)
  * It is what it is. Use comparisons to keep test running
* [cocotb log errors](
https://docs.cocotb.org/en/latest/examples.html#sorter)
  * dut._log.error 
* [cocotb set log level](https://docs.cocotb.org/en/stable/building.html#envvar-COCOTB_LOG_LEVEL)
  * export COCOTB_LOG_LEVEL = DEBUG, INFO, WARNING, ERROR, CRITICAL
*  [cocotb format log line](https://docs.cocotb.org/en/stable/building.html#envvar-COCOTB_REDUCED_LOG_FMT)
   * export COCOTB_REDUCED_LOG_FMT = 1
* [Python default arguments](https://www.tutorialspoint.com/What-are-default-arguments-in-python)
  * def defaultArg(name, foo='Come here!'):
* [Icarus Verilog unable to bind wire reg memory](#)
  * This was caused by $dumpvars pointing to non-existing module in hierarchy
* [cocotb test exceptions and methods](
https://docs.cocotb.org/en/stable/library_reference.html#test-results)


## Videos

* [Cocotb: Python-powered hardware verification - Philipp Wagner](
https://www.youtube.com/watch?v=GUcKJ5zXgPA)
* [Another Introduction to Cocotb - Luke Darnell - ORConf 2018](
https://www.youtube.com/watch?v=T9NioUyaZNM)
  * [github](https://github.com/lukedarnell/cocotb)
  * [David Beazly Python Tutorials](https://www.dabeaz.com/tutorials.html)
* [Cocotb as a comprehensive verification platform - Marek Cieplucha - ORConf 2018](
https://www.youtube.com/watch?v=TDY1JqSyPos)
  * [CRV (constrained random verification) and MDV (metric-driven verification) methodologies](
https://github.com/mciepluc/cocotb-coverage)
* [News from cocotb land - Philipp Wagner - ORConf 2019](
https://www.youtube.com/watch?v=9kZrlsv0fF4)
  * What's new in 1.1 and 1.2
  * [cocotb-test](https://github.com/themperek/cocotb-test)
  * [USB 1.1 Test](https://antmicro.com/blog/2019/12/testing-usb-cores-with-python-and-cocotb/)
* [OSHUG 36 — Cocotb, Chris Higgs.](
https://www.youtube.com/watch?v=M2rAOF4EvVI)



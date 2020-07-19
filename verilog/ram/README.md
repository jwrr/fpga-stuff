# Single Port RAM in Verilog.

* Simulate with [Icarus Verilog](http://iverilog.icarus.com/)
* Test with Python / [cocotb](https://docs.cocotb.org/en/stable/).

## Details

* Create a simple Verilog memory model.  It's a single port RAM loosely based on the
[Latice ICE40 Embedded Block RAM(EBR)](file:///C:/Users/Robin/AppData/Local/Temp/MemoryUsageGuideforiCE40Devices-2.pdf) 
Hopely it should be inferred by [Yosys Open Source Synthesis tools](http://www.clifford.at/yosys/links.html).
* Make an old school verilog testbench to make sure it's alive. It just writes and then reads all locations.
* Make a randomized cocotb testbench. It writes/reads to random locations.  It then reads all locations.

## Summary

* The RAM is simple to verify in with pure Verilog test.
* With cocotb is was easy to create a much more complex test.  I can see this approach will scale to more complex designs.


## Links I went to while creating this test

* [Does Icarus Verilog support SystemVerilog?](https://iverilog.fandom.com/wiki/Iverilog_Flags?action=edit&section=4). Verilog 2005 is default. SystemVerilog 2012 developmengt is ongoing. cocotb uses the -g2012 switch.
* [cocotb quickstart](https://docs.cocotb.org/en/stable/quickstart.html)
* [Python Dictionary](https://www.tutorialspoint.com/python/python_dictionary.htm) - dict{}, dict.update({newkey : newval}), val = expect_ram[key], 
* [Python Key in Dictionary](https://www.geeksforgeeks.org/python-check-whether-given-key-already-exists-in-a-dictionary/) - if key in dict.keys(): 
* [Python Convert int to hex string](https://stackoverflow.com/questions/2269827/how-to-convert-an-int-to-a-hex-string) - hexstr = hex(i)
* [Python assert stops test](https://stackoverflow.com/questions/4732827/continuing-in-pythons-unittest-when-an-assertion-fails) - it is what it is. Use comparisons to keep test running
* [cocotb log errors](https://docs.cocotb.org/en/latest/examples.html#sorter) - dut._log.error 
* [cocotb set log level](https://docs.cocotb.org/en/stable/building.html#envvar-COCOTB_LOG_LEVEL) - export COCOTB_LOG_LEVEL = DEBUG, INFO, WARNING, ERROR, CRITICAL
* [cocotb format log line](https://docs.cocotb.org/en/stable/building.html#envvar-COCOTB_REDUCED_LOG_FMT) - export COCOTB_REDUCED_LOG_FMT = 1
* [Python default arguments](https://www.tutorialspoint.com/What-are-default-arguments-in-python) - def defaultArg(name, foo='Come here!'):
* [Icarus Verilog unable to bind wire reg memory](#) - This was caused by $dumpvars pointing to non-existing module in hierarchy






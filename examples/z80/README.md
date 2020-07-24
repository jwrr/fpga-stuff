# Z80 + COCOTB TESTBENCH

This example attempts to add a cocotb testbench to a working Z80 porcessor
design.

## Create submodules

```
mkdir z80
cd z80
git submodule add https://github.com/abnoname/iceZ0mb1e
git submodule add https://github.com/davidthings/tinyfpga_bx_usbserial
git submodule add https://github.com/Martoni/cocotbext-spi
git submodule add https://github.com/wallento/cocomod-fifointerface
git submodule add https://github.com/themperek/cocotb-test
git submodule add https://github.com/tpoikela/uvm-python
git submodule add https://github.com/mciepluc/cocotb-coverage
git submodule add https://github.com/mciepluc/apbi2c_cocotb_example
https://github.com/antmicro/usb-test-suite-cocotb-usb
git commit
git push
cd iceZ0mb1e/
```

## Run Existing Testbench



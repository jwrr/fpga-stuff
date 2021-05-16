# test_reg.py


import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles

# entity divider is 
# generic (
# DWIDTH : positive := 8;  -- dividend/divisor width
# QWIDTH : positive := 12  -- quotient width
# );
# port (
# clk       : in  std_logic;
# rst       : in  std_logic;
# dividend  : in  unsigned(DWIDTH-1 downto 0);
# divisor   : in  unsigned(DWIDTH-1 downto 0);
# dvalid    : in  std_logic;
# quotient  : out unsigned(QWIDTH-1 downto 0);
# qvalid    : out std_logic
# );

@cocotb.test()
async def test_divider_simple(dut):
    """ Test basic functionality of register"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 100MHz clock
    cocotb.fork(clock.start())  # Start the clock

    dividend = 0
    divisor  = 0
    dvalid   = 0
    quotient = 0
    qvalid   = 0
    dut.rst <= 1
    dut.dividend = dividend
    dut.divisor  = divisor
    dut.dvalid   = dvalid

    await ClockCycles(dut.clk, 10)
    dut.rst <= 0
    assert dut.qvalid.value == qvalid, "FAIL on qvalid: Not 0 after reset"
    assert dut.quotient.value == quotient, "FAIL on qvalid: Not 0 after reset"
    await ClockCycles(dut.clk, 10)
    dividend = 12
    for divisor in range(100):
        dut.dividend = dividend
        dut.divisor  = divisor+1
        dut.dvalid   = 1
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        if dut.qvalid.value == 1:
          print(f"q={dut.quotient.value} ", end='')


        
        

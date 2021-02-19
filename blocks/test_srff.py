# test_srff.py

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_srff_simple(dut):
    """ Test basic functionality of set/reset flop"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 100MHz clock
    cocotb.fork(clock.start())  # Start the clock

    s = 0
    r = 0
    q = 0
    dut.rst <= 1
    dut.s = s
    dut.r = r
    await ClockCycles(dut.clk, 10)
    assert dut.q.value == q, "FAIL on q: Not 0 after reset"
    dut.rst <= 0

    for i in range(100):
        s = random.randint(0, 1)
        r = random.randint(0, 1)
        dut.s = s
        dut.r = r
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        if s:
          q = 1
        elif r:
          q = 0
        assert dut.q.value == q, f"FAIL on q: actual = {dut.q.value}, expect = {q}"


        
        

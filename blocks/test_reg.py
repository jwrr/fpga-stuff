# test_reg.py


import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_reg_simple(dut):
    """ Test basic functionality of register"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 100MHz clock
    cocotb.fork(clock.start())  # Start the clock

    en  = 0
    clr = 0
    d   = 0
    q   = 0
    dut.rst <= 1
    dut.en = en
    dut.clr = clr
    dut.d = 0
    await ClockCycles(dut.clk, 10)
    assert dut.q.value == q, "FAIL on q: Not 0 after reset"
    dut.rst <= 0

    for i in range(100):
        clr = random.randint(0, 1)
        en  = random.randint(0, 1)
        d   = random.randint(0,128)
        dut.en = en
        dut.clr = clr
        dut.d = d
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        if clr:
          q = 0
        elif en:
          q = d
        assert dut.q.value == q, f"FAIL on q: actual = {dut.q.value}, expect = {q}"


        
        

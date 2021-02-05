# test_cnt.py


import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cnt_simple(dut):
    """ Test basic functionality of counter"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 100MHz clock
    cocotb.fork(clock.start())  # Start the clock

    en   = 0
    load = 0
    q    = 0
    wrap = 0
    dut.rst <= 1
    dut.en = en
    dut.load = load
    await ClockCycles(dut.clk, 10)
    assert dut.q.value == q, "FAIL on q: Not 0 after reset"
    dut.rst <= 0

    for i in range(1000):
        load = random.randint(0, 300) < 1 
        en  = random.randint(0, 1)
        dut.en = en
        dut.load = load
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        wrap = 0
        if load:
          q = 0
        elif en:
          q = (q + 1) % 256
          wrap = q == 0 

        assert dut.q.value == q, f"FAIL on q: actual = {dut.q.value}, expect = {q}"
        assert dut.wrap.value == wrap, f"Fail on wrap: actual = {dut.q.value}, expect = {wrap}"


        
        

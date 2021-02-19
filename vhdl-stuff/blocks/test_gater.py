# test_gater.py

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_gater_simple(dut):
    """ Test basic functionality of gater"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 100MHz clock
    cocotb.fork(clock.start())  # Start the clock

    arm   = 0
    start = 0
    stop  = 0
    d     = 0
    q     = 0
    dut.rst <= 1
    dut.arm <= arm
    dut.start <= start
    dut.stop  <= stop
    dut.d = d
    await ClockCycles(dut.clk, 10)
    assert dut.q.value == q, "FAIL on q: Not 0 after reset"
    dut.rst <= 0

    armed = 0
    enabled = 0
    for i in range(500):
        arm = i%150==0  ### else random.randint(0, 19) == 1
        arm_cnt = 0 if arm else arm_cnt + 1
        start = arm_cnt == 10 or arm_cnt == 100 ### range(2) else random.randint(0, 39)  == 2
        stop  = start # random.randint(0, 39)  == 3
        d   = random.randint(0,255)
        dut.arm   <= arm
        dut.start <= start
        dut.stop  <= stop
        dut.d     <= d
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        
        if not enabled and start:
          enabled = 1
        elif enabled and stop:
          enabled = 0

        if enabled:
          q = d
        else:
          q = 0
        assert dut.q.value == q, f"FAIL on q: actual = {dut.q.value}, expect = {q}"


        
        

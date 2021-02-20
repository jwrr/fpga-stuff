# test_ram.py


import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_ram_simple(dut):
    """ Test basic functionality of ramister"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 100MHz clock
    cocotb.fork(clock.start())  # Start the clock

    depth = 1024
    width = 8
    wen = 0
    d   = 0
    q   = 0
    dut.wen = wen
    dut.d = 0
    dut.wa = 0
    dut.ra = 0
    await ClockCycles(dut.clk, 10)

    ram = [0] * depth
    dut.wen <= 1
    dut.d   <= 0
    for i in range(depth):
        ram[i] = i*2 % 2**width
        dut.d  <= i*2 % 2**width
        dut.wa <= i
        await RisingEdge(dut.clk)

    dut.wen = 0
    for i in range(depth):
        dut.ra <= i
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        assert dut.q.value == ram[i], "FAIL on ram[{i}]: actual = {dut.q.value}, expect = {ram[i]}"


@cocotb.test()
async def test_ram_random(dut):
    """ Test basic functionality of ramister"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 100MHz clock
    cocotb.fork(clock.start())  # Start the clock

    depth = 1024
    width = 8
    wen = 0
    d   = 0
    q   = 0
    dut.wen = wen
    dut.d = 0
    dut.wa = 0
    dut.ra = 0
    await ClockCycles(dut.clk, 10)

    ram = [0] * depth
    dut.wen <= 1
    dut.d   <= 0
    for i in range(depth):
        dut.wa <= i
        await RisingEdge(dut.clk)

    for i in range(10000):
        wen = random.randint(0, 1)
        wa  = random.randint(0, 1023)
        ra  = random.randint(0, 1023)
        dut.wen = wen
        dut.wa  = wa
        dut.ra  = ra
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        assert dut.q.value == ram[ra], "FAIL on ram[{ra}]: actual = {dut.q.value}, expect = {ram[i]}"



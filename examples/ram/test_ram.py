# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge
from cocotb.triggers import RisingEdge
from dv_test import dv_test

force_fail = False # True / False

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

@cocotb.test()
async def test_ram_directed(dut):

    dv = dv_test(dut,"Fail",4)

    clk = Clock(dut.clk, 10, units="ns")  # Create a 10us period clock on port clk
    cocotb.fork(clk.start())  # Start the clock
    
    tick = FallingEdge(dut.clk)
    expect_ram = {}
    dv.info("before")
    for i in range(100): await tick
    dv.info("afer")
    await tick  # Synchronize with the clock
    for i in range(256):
        dut.i_we = 1
        dut.i_dat <= i
        i_addr = i
        dut.i_addr = i_addr
        expect_ram.update( {i : i} )
        await tick

    for i in range(256):
        dut.i_we = 0
        dut.i_addr = i

        if force_fail:
            if i >= 250:
                expect_ram[i] = 0
        await tick
        dv.eq(dut.o_dat, expect_ram.get(i), "ram[" + str(i) + "]")
    dv.done()

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

@cocotb.test()
async def test_ram_random(dut):

    dv = dv_test(dut,"Fail",4)

    clk = Clock(dut.clk, 10, units="ns")  # Create a 10us period clock on port clk
    cocotb.fork(clk.start())  # Start the clock
    tick = FallingEdge(dut.clk)

    expect_ram = {}
    await tick  # Synchronize with the clock
    for i in range(5000):
        i_we = random.randint(0, 1)
        dut.i_we = i_we

        i_dat = random.randint(0,2**16-1)
        dut.i_dat <= i_dat
        i_addr = random.randint(0,2**8-1)
        dut.i_addr = i_addr

        rdata_exp = expect_ram.get(i_addr)

        if i_we == 1:
            expect_ram.update( {i_addr : i_dat})

        await tick

        if i_we == 0:
            dv.eq(dut.o_dat, rdata_exp, "ram[" + str(i_addr) + "]")

    for i in range(256):
        dut.i_we = 0
        dut.i_addr = i

        if force_fail:
            if i >= 250:
                expect_ram[i] = 0

        await tick
        dv.eq(dut.o_dat, expect_ram.get(i), "ram[" + str(i) + "]")
    dv.done()

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------



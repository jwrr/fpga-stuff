# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge
from dv_test import dv_test


# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

force_fail = False # True / False


@cocotb.test()
async def test_ram_directed(dut):

    dv = dv_test(dut,"Fail",4)

    clock = Clock(dut.clk, 10, units="ns")  # Create a 10us period clock on port clk
    cocotb.fork(clock.start())  # Start the clock

    expect_ram = {}
    await FallingEdge(dut.clk)  # Synchronize with the clock
    for i in range(256):
        dut.i_we = 1
        dut.i_dat <= i
        i_addr = i
        dut.i_addr = i_addr
        expect_ram.update( {i : i})
        await FallingEdge(dut.clk)


    for i in range(256):
        dut.i_we = 0
        dut.i_addr = i

        if force_fail:
            if i >= 250:
                expect_ram[i] = 0

        await FallingEdge(dut.clk)
        dv.eq(dut.o_dat, expect_ram.get(i), "ram[" + str(i) + "]")
    dv.done()


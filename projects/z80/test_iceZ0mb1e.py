# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge
from cocotb.triggers import RisingEdge


# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

@cocotb.test()
async def test_icez0mb1e_gpio_loopback(dut):

    clk = Clock(dut.clk, 10, units="ns")  # Create a 10us period clock on port clk
    cocotb.fork(clk.start())  # Start the clock
    
    dut.uart_txd = 0
    dut.P1_in = 0x55
    dut.P2_in = 0xAA

    for i in range(10000):
        await FallingEdge(dut.clk)
        binstr = dut.P1_out.value.binstr
#         dut._log.info("P1_out = " + binstr)
        try:
            val = int(binstr,2)
        except ValueError:
            val = 0x42
        dut.P2_in <= val
        if (i+1) % 1000 == 0:
            dut._log.info(str(i+1))

    assert val == 0, "Error count from Z80 for GPIO Loopback Test"



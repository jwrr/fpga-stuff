# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge
from cocotb.triggers import RisingEdge
from cocotb.triggers import ClockCycles
from dv_test import dv_test


# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

@cocotb.test()
async def test_icez0mb1e_gpio_loopback(dut):
    dv = dv_test(dut)

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
            dv.info(str(i+1))

    assert val == 0, "Error count from Z80 for GPIO Loopback Test"

    dv.info("SPI SHOULD BE READING")
    
#     output spi_sclk,
#     output spi_cs,
#     output spi_mosi,
#     input  spi_miso,
    
    spi_str = ""
    prev_clk = dv.val(dut.spi_sclk);
    for i in range(10000):
        await FallingEdge(dut.clk)
        curr_clk = dv.val(dut.spi_sclk);
        re = curr_clk == 1 and prev_clk == 0
        fe = curr_clk == 0 and prev_clk == 1
        edge = re
        prev_clk = curr_clk
        if dv.lo(dut.spi_cs):
            if edge:
                dv.info( "CS=" + str(dv.val(dut.spi_cs)) + " sclk=" + str(dv.val(dut.spi_sclk)) + " mosi=" + str(dv.val(dut.spi_mosi)) )
                spi_str = spi_str + str(dv.val(dut.spi_mosi))  
        elif dv.hi(dut.spi_cs):
            if spi_str != "":
                dv.info("spi = " + spi_str)
            spi_str = "";
        
        if (i+1) % 1000 == 0:
            dv.info(str(i+1))
#   await ClockCycles(dut.clk,10000)



# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Edge
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


    for i in range(10):
      spi_val = await spi_slave(dut.spi_sclk, dut.spi_cs, dut.spi_mosi, dut.spi_miso, "{:08b}".format(0x80+i) )
      dv.info("spi_val = " + spi_val)

    for i in range(2000):
        await FallingEdge(dut.clk)

#   await ClockCycles(dut.clk,10000)



async def spi_slave(sclk, cs_n, mosi, miso, miso_str):
    msb_first = True
    loop_back = False
    size = len(miso_str)
    mosi_str = ""
    cnt = 0
    await FallingEdge(cs_n)
    if msb_first:
        miso_str = miso_str[::-1]
    miso <= int(mosi.value.binstr,2) if loop_back else int(miso_str[-1],2)
    while cnt < size:
        if cs_n.value.binstr != '0':
            break
        await Edge(sclk)
        if sclk.value.binstr == '1':
            cnt += 1
            mosi_str = mosi.value.binstr + mosi_str
        else:
            miso_str = miso_str[:-1]
            miso <= int(miso_str[-1],2)
#         if loop_back:
#             miso <= int(mosi.value.binstr,2)
    if msb_first:
       mosi_str = mosi_str[::-1]
    return mosi_str



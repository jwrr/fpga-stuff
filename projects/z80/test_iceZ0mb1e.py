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


# THIS WORKS. X IS CORRECTLY ASSIGNED to miso
#     dut._log.info("AAA before spi loop back")
#     val = dut.spi_mosi.value.binstr
#     dut._log.info("+++ mosi=" + val)
#     dut.spi_miso <= dut.spi_mosi.value
#     for i in range(20):
#         val = dut.spi_mosi.value.binstr
#         dut._log.info("AAA mosi=" + val)
#         dut.spi_miso <= dut.spi_mosi.value
#         await Edge(dut.spi_mosi)
#     dut._log.info("AAA after spi loop back")


# THIS WORKS. X IS CORRECTLY ASSIGNED to miso
    dut._log.info("BBB Before assignng X to P2_in")
# works    dut.P2_in <=  int(dut.P1_out.value) + 5

    dut._log.info(dut.P2_in.value)
    dut.P2_in <=  dut.P1_out.value
    dut._log.info(dut.P2_in.value)
    await FallingEdge(dut.clk)
    dut._log.info(dut.P2_in.value)

    dut._log.info("BBB1 After assignng X to P2_in")
    dut.P2_in <= dut.P1_out
    await FallingEdge(dut.clk)
    dut._log.info("BBB2 After assignng X to P2_in")
    dv.info("dut.P1_out.value =" + str(type(dut.P1_out.value) ) )
    dv.info("dut.P1_out =" + str(type(dut.P1_out) ) )
    dv.info("dut =" + str(type(dut)) )
    for i in range(1000):
        await FallingEdge(dut.clk)
###         dut.P2_in <= dut.P1_out
        if (i+1) % 1000 == 0:
            dv.info(str(i+1))

#     assert val == 0, "Error count from Z80 for GPIO Loopback Test"

    dut._log.info("DUT OUTPUT")
    dut._log.info(dut.P1_out.value)
    dut._log.info("BEFORE ASSIGMENT")
    dut._log.info(dut.P2_in.value)
###     dut.P2_in <=  dut.P1_out.value
    dut.P2_in <=  dut.P1_out
    dut._log.info("IMMEDIATELY AFTER ASSIGMENT")
    dut._log.info(dut.P2_in.value)
    await FallingEdge(dut.clk)
    dut._log.info("AFTER AWAIT ASSIGMENT")
    dut._log.info(dut.P2_in.value)

    dv.info("SPI SHOULD BE READING")


    ### =============================================================================================================
    ### SPI TEST
    
    ### TEST MODE 0
    spi_val = "10010111";
    dut.P2_in <= 0x70
    for i in range(10):
        spi_val = await spi_periph(dut, dut.spi_sclk, dut.spi_cs, dut.spi_mosi, dut.spi_miso, "{:08b}".format(int(spi_val)) )
        dv.info("0. spi_val = " + str(int(spi_val,2)) + " expect = " + str(int(dut.P1_out.value.binstr,2)))

    ### TEST MODE 1
    dut.P2_in <= 0x71
    for i in range(10):
        spi_val = await spi_periph(dut, dut.spi_sclk, dut.spi_cs, dut.spi_mosi, dut.spi_miso, "{:08b}".format(int(spi_val)), 1 )
        dv.info("1. spi_val = " + str(int(spi_val,2)) + " expect = " + str(int(dut.P1_out.value.binstr,2)))

    ### TEST MODE 2
    dut.P2_in <= 0x72
    for i in range(10):
        spi_val = await spi_periph(dut, dut.spi_sclk, dut.spi_cs, dut.spi_mosi, dut.spi_miso, "{:08b}".format(int(spi_val)), 2 )
        dv.info("2. spi_val = " + str(int(spi_val,2)) + " expect = " + str(int(dut.P1_out.value.binstr,2)))

    ### TEST MODE 3
    dut.P2_in <= 0x73
    for i in range(10):
        spi_val = await spi_periph(dut, dut.spi_sclk, dut.spi_cs, dut.spi_mosi, dut.spi_miso, "{:08b}".format(int(spi_val)), 3 )
        dv.info("3. spi_val = " + str(int(spi_val,2)) + " expect = " + str(int(dut.P1_out.value.binstr,2)))

    dv.info("After SPI TEST")
    await ClockCycles(dut.clk,1000)
 

    ### =============================================================================================================

#
#     for i in range(100):
#         await Edge(dut.spi_mosi)
#         val = dut.spi_mosi.value.binstr
#         dv.info("mosi=" + val)
#         dut.spi_miso <= dut.spi_mosi
#     dv.info("after spi loop back")
#     for i in range(2000):
#         await FallingEdge(dut.clk)




async def spi_periph(dut, sclk, cs_n, sdi, sdo, sdo_str, spi_mode = 0):
    msb_first = True
    loop_back = False
    size = 8 ### len(sdo_str)
    sdi_str = ""
    cnt = 0
    await FallingEdge(cs_n)
    if msb_first:
        sdo_str = sdo_str[::-1]
        
    # spi_mode cpol cpha
    #    0      0    0    drive on falling sample on rising;  sclk=0 when idle
    #    1      0    1    drive on rising  sample on falling; sclk=0 when idle
    #    2      1    1    drive on rising  sample on falling; sclk=1 when idle
    #    3      1    0    drive on falling sample on rising;  sclk=1 when idle
    capture_edge = '1' if spi_mode == 0 or spi_mode == 3 else '0'
        
    sdo <= int(sdi.value.binstr,2) if loop_back else int(sdo_str[-1],2)
    while cnt < size:
        if cs_n.value.binstr != '0':
            break
        await Edge(sclk)
        if sclk.value.binstr == capture_edge:
            cnt += 1
            sdi_str = sdi.value.binstr + sdi_str
###         else:
###             l = len(sdo_str)
###             if l > 0:
###                 sdo_str = sdo_str[:-1]
###                 sdo <= int(sdo_str[-1],2)
#         if loop_back:
#             sdo <= int(sdi.value.binstr,2)
    if msb_first:
       sdi_str = sdi_str[::-1]
    return sdi_str



# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge


def dv(dut, act, exp, description):
#     parent = act.parent
    val = act.value.integer
    if exp != val:
        dut._log.error("act = " + hex(val) + " exp = " + hex(exp) + " " + description)
    else:
        dut._log.info("act = " + hex(val) + " " + description)


@cocotb.test()
async def test_ram_random(dut):

    print("dut type =", type(dut) )

    clock = Clock(dut.clk, 10, units="us")  # Create a 10us period clock on port clk
    cocotb.fork(clock.start())  # Start the clock

    expect_ram = {}
    await FallingEdge(dut.clk)  # Synchronize with the clock
    for i in range(10000):
        i_we = random.randint(0, 1)
        dut.i_we = i_we

        i_dat = random.randint(0,2**16-1)
        dut.i_dat <= i_dat
        i_addr = random.randint(0,2**8-1)
        dut.i_addr = i_addr;

        if i_we == 1:
            expect_ram.update( {i_addr : i_dat})
            
        await FallingEdge(dut.clk)  
        
        
    
    for i in range(256):
        dut.i_we = 0
        dut.i_addr = i

        await FallingEdge(dut.clk)
        if i == 10:
            expect_ram[i] = 0
        dv(dut, dut.o_dat, expect_ram[i], "ram[" + str(i) + "]")
#         exp = expect_ram[i]
#         act = dut.o_dat.value.integer
#         if exp != act:
#           dut._log.error("ram[" + str(i)+ "] exp = " + hex(exp) + " act = " + hex(act) )
#         else:
#           dut._log.info("ram[" + str(i)+ "] exp = " + hex(exp) + " act = " + hex(act) )


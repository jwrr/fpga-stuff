# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge

# -----------------------------------------------------------------------------

def dv_new(dut):
  dv_state = {"err_cnt" : 0, "tot_cnt" : 0, "err_max" : 10, "dut" : dut}
  return dv_state

def dv(dv_state, act, exp, description):
    if exp == None:
        return dv_state
#     parent = act.parent
    dut = dv_state['dut']
    dv_state['tot_cnt'] += 1
    binstr = act.value.binstr
    try:
        val = int(binstr,2)
    except ValueError:
        dv_state['err_cnt'] += 1
        dut._log.error("FAIL: act = " + binstr  + " exp = " + hex(exp) + " " + description)
        return dv_state
    if exp != val:
        dv_state['err_cnt'] += 1
        dut._log.error("FAIL: act = " + hex(val)  + " exp = " + hex(exp) + " " + description)
        if dv_state['err_cnt'] >= dv_state['err_max'] :
            assert False, "TEST FAILED - Fail Count = " + str(dv_state['err_cnt'])
    else:
        dut._log.info("PASS: act = " + hex(val) + " " + description)

    return dv_state

def dv_done(dv_state):
    if dv_state['err_cnt'] > 0:
        assert False, "TEST FAILED - Fail Count = " + str(dv_state['err_cnt'])
    else:
        assert True, "TEST PASSED"


# -----------------------------------------------------------------------------


@cocotb.test()
async def test_ram_random(dut):

    dv_state = dv_new(dut)

    clock = Clock(dut.clk, 10, units="ns")  # Create a 10us period clock on port clk
    cocotb.fork(clock.start())  # Start the clock

    expect_ram = {}
    await FallingEdge(dut.clk)  # Synchronize with the clock
    for i in range(500):
        i_we = random.randint(0, 1)
        dut.i_we = i_we

        i_dat = random.randint(0,2**16-1)
        dut.i_dat <= i_dat
        i_addr = random.randint(0,2**8-1)
        dut.i_addr = i_addr;

        rdata_exp = expect_ram.get(i_addr)

        if i_we == 1:
            expect_ram.update( {i_addr : i_dat})

        await FallingEdge(dut.clk)

        if i_we == 0:
            dv(dv_state, dut.o_dat, rdata_exp , "ram[" + str(i_addr) + "]")

    dv_state = {"err_cnt" : 0, "tot_cnt" : 0, "err_max" : 10, "dut" : dut}
    for i in range(256):
        dut.i_we = 0
        dut.i_addr = i

#         if i >= 10:
#             expect_ram[i] = 0

        await FallingEdge(dut.clk)
        dv(dv_state, dut.o_dat, expect_ram.get(i), "ram[" + str(i) + "]")
    dv_done(dv_state)


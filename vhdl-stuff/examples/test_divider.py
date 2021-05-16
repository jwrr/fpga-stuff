# test_reg.py


import random
import math
import queue
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles

# entity divider is 
# generic (
# DWIDTH : positive := 8;  -- dividend/divisor width
# QWIDTH : positive := 12  -- quotient width
# );
# port (
# clk       : in  std_logic;
# rst       : in  std_logic;
# dividend  : in  unsigned(DWIDTH-1 downto 0);
# divisor   : in  unsigned(DWIDTH-1 downto 0);
# dvalid    : in  std_logic;
# quotient  : out unsigned(QWIDTH-1 downto 0);
# qvalid    : out std_logic
# );

@cocotb.test()
async def test_divider_simple(dut):
    """ Test basic functionality of register"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 100MHz clock
    cocotb.fork(clock.start())  # Start the clock

    dividend = 0
    divisor  = 0
    dvalid   = 0
    quotient = 0
    qvalid   = 0
    dut.rst <= 1
    dut.dividend = dividend
    dut.divisor  = divisor
    dut.dvalid   = dvalid

    await ClockCycles(dut.clk, 10)
    dut.rst <= 0
    assert dut.qvalid.value == qvalid, "FAIL on qvalid: Not 0 after reset"
    assert dut.quotient.value == quotient, "FAIL on qvalid: Not 0 after reset"
    await ClockCycles(dut.clk, 10)
    dividend = 12
    exp_q = queue.Queue()
    for i in range(100):
        divisor = i+1
        dut.dividend = dividend
        dut.divisor  = divisor
        dut.dvalid   = 1
        exp_quotient = math.floor(16*dividend / divisor) ## div generics set to return u8.4
        exp_q.put(exp_quotient)
         
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        if dut.qvalid.value == 1:
          exp_quotient = exp_q.get()
          act_quotient = dut.quotient.value.integer
          assert act_quotient == exp_quotient, f"FAIL on quotient. actual = {act_quotient} expect = {exp_quotient}"

@cocotb.test()
async def test_divider_random(dut):
    """ Test basic functionality of register"""

    ## vhdl generics configured to input u8.0 and output u8.4
    DWIDTH = 8  ## must match vhdl generic
    QWIDTH = 12 ## must match vhdl generic
    
    full_scale = 2**12 - 1
    fractional = 2**(QWIDTH-DWIDTH)

    clock = Clock(dut.clk, 10, units="ns")  # Create a 100MHz clock
    cocotb.fork(clock.start())  # Start the clock

    dividend = 0
    divisor  = 0
    dvalid   = 0
    quotient = 0
    qvalid   = 0
    dut.rst <= 1
    dut.dividend = dividend
    dut.divisor  = divisor
    dut.dvalid   = dvalid

    await ClockCycles(dut.clk, 10)
    dut.rst <= 0
    assert dut.qvalid.value == qvalid, "FAIL on qvalid: Not 0 after reset"
    assert dut.quotient.value == quotient, "FAIL on qvalid: Not 0 after reset"
    await ClockCycles(dut.clk, 10)
    dividend = 12
    
    qdivisor  = queue.Queue()
    qdividend = queue.Queue()
    qquotient = queue.Queue()
    for i in range(100000):
        if (i % 10000 == 0) and (i > 0):
          print(f"{i}")
        dividend = random.randrange(256)
        divisor = random.randrange(256)
        dut.dividend = dividend
        dut.divisor  = divisor
        dut.dvalid   = 1
        qdividend.put(dividend)
        qdivisor.put(divisor)
        if divisor == 0:
          exp_quotient = full_scale
        else:
          exp_quotient = math.floor(fractional*dividend / divisor)

        qquotient.put(exp_quotient)
         
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        if dut.qvalid.value == 1:
          exp_divisor  = qdivisor.get()
          exp_dividend = qdividend.get()
          exp_quotient = qquotient.get()
          act_quotient = dut.quotient.value.integer
          assert act_quotient == exp_quotient, f"FAIL on quotient. actual = {act_quotient} expect = {exp_quotient}. dividend ={exp_dividend} divisor = {exp_divisor}"


        
                

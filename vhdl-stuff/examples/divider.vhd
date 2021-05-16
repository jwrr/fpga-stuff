-- MIT LICENSE
-- Copyright 2016 jwrr.com
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in 
-- the Software without restriction, including without limitation the rights to 
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
-- of the Software, and to permit persons to whom the Software is furnished to do 
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all 
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
-- SOFTWARE.
-- 
-- --------------------------------------------------------------------------------
-- Block: divider
-- Description:
-- This block implements a pipelined divider, producing a quotient every clock
-- cycle, after the initial latency. 
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity divider is
  generic (
    DWIDTH : positive := 8;  -- dividend/divisor width
    QWIDTH : positive := 12  -- quotient width. Extra bits for fractional.
                             -- Must be larger than DWIDTH
  );
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    dividend  : in  unsigned(DWIDTH-1 downto 0);
    divisor   : in  unsigned(DWIDTH-1 downto 0);
    dvalid    : in  std_logic;
    quotient  : out unsigned(QWIDTH-1 downto 0);
    qvalid    : out std_logic
  );
end divider;

architecture rtl of divider is
  constant DEPTH  : positive := QWIDTH;
  constant FWIDTH : positive := QWIDTH - DWIDTH; -- Number of fractional bits
  constant TWIDTH : positive := DWIDTH + QWIDTH - 1; -- Total Width
  type dtype is array(0 to DEPTH) of unsigned(TWIDTH-1 downto 0);
  type qtype is array(0 to DEPTH) of unsigned(QWIDTH-1 downto 0);

  signal dividend_pipeline : dtype;
  signal divisor_pipeline  : dtype;
  signal quotient_pipeline : qtype;
  signal valid_pipeline    : std_logic_vector(DEPTH downto 0);

  signal quotient_whole : unsigned(QWIDTH-FWIDTH-1 downto 0);
  signal quotient_frac  : unsigned(FWIDTH-1 downto 0);

begin

  process (clk, rst)
  begin
    if rst then
      dividend_pipeline <= (others => (others => '0'));
      divisor_pipeline  <= (others => (others => '0'));
      quotient_pipeline <= (others => (others => '0'));
      valid_pipeline    <= (others => '0');
    elsif rising_edge(clk) then

      dividend_pipeline(0) <= resize(dividend, TWIDTH-FWIDTH) & to_unsigned(0, FWIDTH);
      divisor_pipeline(0)  <= divisor & to_unsigned(0, QWIDTH-1);
      valid_pipeline(0)    <= dvalid;
      
      for i in 1 to DEPTH loop
        valid_pipeline(i) <= valid_pipeline(i-1);
        divisor_pipeline(i) <= '0' & divisor_pipeline(i-1)(TWIDTH-1 downto 1);
        if dividend_pipeline(i-1) >= divisor_pipeline(i-1) then
          dividend_pipeline(i) <= dividend_pipeline(i-1) - divisor_pipeline(i-1);
          quotient_pipeline(i) <= quotient_pipeline(i-1)(QWIDTH-2 downto 0) & '1';
        else
          dividend_pipeline(i) <= dividend_pipeline(i-1);
          quotient_pipeline(i) <= quotient_pipeline(i-1)(QWIDTH-2 downto 0) & '0';
        end if;
      end loop;
    end if;
  end process;

  quotient    <= quotient_pipeline(DEPTH);
  qvalid      <= valid_pipeline(DEPTH);

  quotient_whole <= quotient(quotient'HIGH downto FWIDTH);
  quotient_frac  <= quotient(FWIDTH-1 downto 0);
                
end rtl;


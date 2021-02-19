--------------------------------------------------------------------------------
-- Block: dff
-- Description:
-- This block implement a d flip-flop
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;

entity dff is
port (
  q          : out std_logic;
  clk        : in  std_logic := '0';
  d          : in  std_logic := '0'
);
end dff;

architecture rtl of dff is
begin

  process (clk)
  begin
    if rising_edge(clk) then
      q <= d;
    end if;
  end process;

end rtl;



--------------------------------------------------------------------------------
-- Block: srff
-- Description:
-- This block implement a set-reset flip-flop
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity srff is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    s   : in  std_logic;
    r   : in  std_logic;
    q   : out std_logic
  );
end srff;

architecture rtl of srff is
begin

  process (clk, rst)
  begin
    if rst then
      q <= '0';
    elsif rising_edge(clk) then
      if s then
        q <= '1';
      elsif r then
        q <= '0';
      end if;
    end if;
  end process;

end rtl;



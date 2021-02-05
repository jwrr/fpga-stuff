--------------------------------------------------------------------------------
-- Block: reg
-- Description:
-- This block implements a register
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity reg is
  generic (
    WIDTH : integer := 8
  );
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    clr : in  std_logic := '0';
    en  : in  std_logic := '1';
    d   : in  std_logic_vector(WIDTH-1 downto 0);
    q   : out std_logic_vector(WIDTH-1 downto 0)
  );
end reg;

architecture rtl of reg is
begin

  process (clk, rst)
  begin
    if rst then
      q <= (others => '0');
    elsif rising_edge(clk) then
      if clr then
        q <= (others => '0');
      elsif en then
        q <= d;
      end if;
    end if;
  end process;

end rtl;



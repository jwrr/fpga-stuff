
--------------------------------------------------------------------------------
-- Block: counter-- Description:
-- This block implements an up down counter
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity counter is
generic (
  WIDTH   : integer := 16;
  WRAP_AT : integer := 0
);
port (
  clk        : in  std_logic;
  rst        : in  std_logic;
  i_clr      : in  std_logic;
  i_enable   : in  std_logic;
  o_cnt      : out std_logic_vector(WIDTH-1 downto 0)
);
end counter;

architecture rtl of counter is
  signal cnt : std_logic_vector(o_cnt'range);
begin

  o_cnt <= cnt;
  process (clk,rst)
  begin
    if rst = '1' then
      cnt <= (others => '0');
    elsif rising_edge(clk) then
      if i_clr = '1' then
        cnt <= (others => '0');
      elsif i_enable = '1' then
        if (WRAP_AT > 0) and ( unsigned(cnt) = WRAP_AT) then
          cnt <= (others => '0');
        else
          cnt <= std_logic_vector( unsigned(cnt) + 1 );
        end if;
      end if;
    end if;
  end process;

end rtl;



--------------------------------------------------------------------------------
-- Block: cnt
-- Description:
-- This block implements a counter
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity cnt is
  generic (
    WIDTH : integer := 8;
    UP    : boolean := true -- UP / DOWN
  );
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    load    : in  std_logic := '0';
    en      : in  std_logic := '1';
    startat : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    wrapat  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '1');
    q       : out std_logic_vector(WIDTH-1 downto 0);
    wrap    : out std_logic
  );
end cnt;

architecture rtl of cnt is
begin

  process (clk, rst)
  begin
    if rst then
      q <= (others => '0');
      wrap <= '0';
    elsif rising_edge(clk) then
      if load then
        q <= startat;
        wrap <= '0';
      elsif en then
        if q = wrapat then
          q <= startat;
          wrap <= '1';
        else
          if UP then
            q <= std_logic_vector(unsigned(q) + 1);
          else
            q <= std_logic_vector(unsigned(q) - 1);
          end if;
          wrap <= '0';
        end if;
      end if;
    end if;
  end process;

end rtl;



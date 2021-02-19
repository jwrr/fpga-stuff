--------------------------------------------------------------------------------
-- Block: cdc_gray2bin 
-- Description:
-- This block ...
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;

entity cdc_gray2bin is
generic (
  WIDTH : integer := 16
);
port (
  clk        : in  std_logic;
  rst        : in  std_logic;
  i_gray     : in  std_logic_vector(WIDTH-1 downto 0);
  o_bin      : out std_logic_vector(WIDTH-1 downto 0)
);
end cdc_gray2bin;

architecture rtl of cdc_gray2bin is
  signal bin1      : std_logic_vector(WIDTH-1 downto 0);
  signal bin2      : std_logic_vector(WIDTH-1 downto 0);
begin

  o_bin <= bin2;

  process (clk,rst)
    variable bin_var : std_logic;
  begin
    if rst = '1' then
      bin1 <= (others => '0');
      bin2 <= (others => '0');
    elsif rising_edge(clk) then
      for i in 0 to WIDTH-1 loop
        bin_var := '0';
        for j in i to WIDTH-1 loop
          bin_var := bin_var xor i_gray(j);
        end loop;
        bin1(i) <= bin_var;
      end loop;
      bin2 <= bin1;
    end if;
  end process;
  
end rtl;



--------------------------------------------------------------------------------
-- Block: cdc_bin2gray 
-- Description:
-- This block converts binary to gray.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;

entity cdc_bin2gray is
generic (
  WIDTH : integer := 16
)
port (
  clk        : in  std_logic;
  rst        : in  std_logic;
  i_enable   : in  std_logic;
  i_bin      : in  std_logic_vector(WIDTH-1 downto 0);
  o_gray     : out std_logic_vector(WIDTH-1 downto 0)
);
end cdc_bin2gray;

architecture rtl of cdc_bin2gray is
begin

  process (clk,rst)
  begin
    if rst = '1' then
      o_gray <= (others => '0');
    elsif rising_edge(clk) then
      for i in 0 to WIDTH-2 loop
        o_gray(i) <= i_bin(i) xor i_bin(i+1);
      end loop;
      o_gray(WIDTH-1) <= i_bin(WIDTH-1);
    end if;
  end process;
  
end rtl;



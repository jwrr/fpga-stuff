--------------------------------------------------------------------------------
-- Block: ram
-- Description:
-- This block implements a ram
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
library work;

entity ram is
  generic (
    DWIDTH : integer := 8;
    DEPTH  : integer := 1024;
    AWIDTH : integer := integer(ceil(log2(real(DEPTH))))
  );
  port (
    clk : in  std_logic;
    wen : in  std_logic := '0';
    wa  : in  std_logic_vector(AWIDTH-1 downto 0);
    ra  : in  std_logic_vector(AWIDTH-1 downto 0);
    d   : in  std_logic_vector(DWIDTH-1 downto 0);
    q   : out std_logic_vector(DWIDTH-1 downto 0)
  );
end ram;

architecture rtl of ram is
  type ram_array_type is array(0 to DEPTH-1) of std_logic_vector(DWIDTH-1 downto 0);
  signal ram_array : ram_array_type;
begin

  process (clk)
  begin
    if rising_edge(clk) then
      if wen then
        ram_array(to_integer(unsigned(wa))) <= d;
      end if;
      q <= ram_array(to_integer(unsigned(ra)));
    end if;
  end process;

end rtl;



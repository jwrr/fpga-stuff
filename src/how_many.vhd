--------------------------------------------------------------------------------
-- Block: how_many
-- Description:
-- This block counts how many bits are set in a vector.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;

entity how_many is
generic (
  I_SIZE : integer := 16;
  O_SIZE : integer := 4
);
port (
  i_vec    : in  std_logic_vector(I_SIZE-1 downto 0);
  o_cnt    : out std_logic_vector(O_SIZE-1 downto 0)
);
end how_many;

architecture rtl of how_many is

  function countbits(in_vec :std_logic_vector) return integer is
    variable cnt : integer := 0;
  begin
    for ii in in_vec'range loop
      if in_vec(ii) = '1' then
        cnt := cnt + 1;
      end if;
    end loop;
    return cnt;
  end function;

begin

o_cnt <= std_logic_vector( to_unsigned( countbits(i_vec), o_cnt'length ) );

end rtl;





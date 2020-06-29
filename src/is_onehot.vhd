--------------------------------------------------------------------------------
-- Block: is_onehot
-- Description:
-- This block checks if an input vector has one bit set.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;

entity is_onehot is
generic (
  WIDTH : integer := 16
);
port (
  i_data  : in  std_logic_vector(WIDTH-1 downto 0);
  o_hot   : out std_logic
);
end is_onehot;

architecture rtl of is_onehot is

  function is_allzeroes(in_vec : std_logic_vector) return std_logic is
    variable o_or : std_logic;
    variable all_zeroes :std_logic_vector(in_vec'range) := (others => '0');
  begin
    o_or := '1' when in_vec = all_zeroes else '0';
    return o_or;
  end function is_allzeroes;
  
  
  function one_or_more(in_vec :std_logic_vector) return std_logic is
  begin
    return not is_allzeroes(in_vec);
  end function one_or_more;


  function is_allones(in_vec : std_logic_vector) return std_logic is
    variable o_and : std_logic;
    variable all_ones : std_logic_vector(in_vec'range) := (others => '0');
  begin
    o_and := '1' when in_vec = all_ones else '0';
    return o_and;
  end function is_allones;
  
  function not_allones(in_vec : std_logic_vector) return std_logic is
  begin
    return not is_allones(in_vec);
  end function not_allones;


  function one_and_only_one(in_vec :std_logic_vector) return std_logic is
    variable mask_vec   : std_logic_vector(in_vec'range);
    variable hot_vec    : std_logic_vector(in_vec'range);
    variable all_zeroes : std_logic_vector(in_vec'range) := (others => '0'); 
  begin
    for ii in in_vec'range loop
      mask_vec := (others => '0');
      mask_vec(ii) := '1';
      hot_vec(ii) := '1' when (in_vec = mask_vec) else '0';
    end loop;
    return one_or_more(hot_vec);
  end function one_and_only_one;

begin
  o_hot <= one_and_only_one(i_data);
end rtl;






--------------------------------------------------------------------------------
-- Block: avg9
-- Description:
-- This block implements a big adder with 9 inputs.
-- There are several add stages to improve timing.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
library work;


entity avg9 is
  generic (
    DWIDTH  : integer := 16;
    NUM_INPUTS : integer := 9
);
  port (
    clk : std_logic;
    rst : std_logic;
    i_data_0  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_1  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_2  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_3  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_4  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_5  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_6  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_7  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_8  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_v  : in  std_logic;
    o_avg     : out std_logic_vector(DWIDTH-1 downto 0);
    o_avg_v   : out std_logic
  );
end entity avg9;

architecture rtl of avg9 is

  signal coef : unsigned(19 downto 0) := to_unsigned(integer(256*1024/NUM_INPUTS), 20);
  signal sum_0_0 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_1 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_2 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_3 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_4 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_5 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_6 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_7 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_8 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_9 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_10 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_11 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_12 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_13 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_14 : unsigned(DWIDTH-1 downto 0);
  signal sum_0_15 : unsigned(DWIDTH-1 downto 0);

  signal sum_1_0 : unsigned(DWIDTH+0 downto 0);
  signal sum_1_1 : unsigned(DWIDTH+0 downto 0);
  signal sum_1_2 : unsigned(DWIDTH+0 downto 0);
  signal sum_1_3 : unsigned(DWIDTH+0 downto 0);
  signal sum_1_4 : unsigned(DWIDTH+0 downto 0);
  signal sum_1_5 : unsigned(DWIDTH+0 downto 0);
  signal sum_1_6 : unsigned(DWIDTH+0 downto 0);
  signal sum_1_7 : unsigned(DWIDTH+0 downto 0);

  signal sum_2_0 : unsigned(DWIDTH+1 downto 0);
  signal sum_2_1 : unsigned(DWIDTH+1 downto 0);
  signal sum_2_2 : unsigned(DWIDTH+1 downto 0);
  signal sum_2_3 : unsigned(DWIDTH+1 downto 0);

  signal sum_3_0 : unsigned(DWIDTH+2 downto 0);
  signal sum_3_1 : unsigned(DWIDTH+2 downto 0);

  signal sum_4_0 : unsigned(DWIDTH+3 downto 0);
  signal prod    : unsigned(sum_4_0'length+coef'length-1 downto 0);
  
  signal data_v  : std_logic_vector(5 downto 0);

begin

  o_avg_v <= data_v(data_v'high);

  process(clk, rst)
  begin
    if rst then
      data_v <= (others => '0');
    elsif rising_edge(clk) then
      data_v <= data_v(data_v'high-1 downto 0) & i_data_v;
      sum_0_0 <= unsigned(i_data_0);
      sum_0_1 <= unsigned(i_data_1);
      sum_0_2 <= unsigned(i_data_2);
      sum_0_3 <= unsigned(i_data_3);
      sum_0_4 <= unsigned(i_data_4);
      sum_0_5 <= unsigned(i_data_5);
      sum_0_6 <= unsigned(i_data_6);
      sum_0_7 <= unsigned(i_data_7);
      sum_0_8 <= unsigned(i_data_8);
      sum_0_9 <= (others => '0');
      sum_0_10 <= (others => '0');
      sum_0_11 <= (others => '0');
      sum_0_12 <= (others => '0');
      sum_0_13 <= (others => '0');
      sum_0_14 <= (others => '0');
      sum_0_15 <= (others => '0');
      -- level: 1. Num Adders: 8
      sum_1_0 <= ('0' + sum_0_0) + ('0' & sum_0_1);
      sum_1_1 <= ('0' + sum_0_2) + ('0' & sum_0_3);
      sum_1_2 <= ('0' + sum_0_4) + ('0' & sum_0_5);
      sum_1_3 <= ('0' + sum_0_6) + ('0' & sum_0_7);
      sum_1_4 <= ('0' + sum_0_8) + ('0' & sum_0_9);
      sum_1_5 <= ('0' + sum_0_10) + ('0' & sum_0_11);
      sum_1_6 <= ('0' + sum_0_12) + ('0' & sum_0_13);
      sum_1_7 <= ('0' + sum_0_14) + ('0' & sum_0_15);

      -- level: 2. Num Adders: 4
      sum_2_0 <= ('0' + sum_1_0) + ('0' & sum_1_1);
      sum_2_1 <= ('0' + sum_1_2) + ('0' & sum_1_3);
      sum_2_2 <= ('0' + sum_1_4) + ('0' & sum_1_5);
      sum_2_3 <= ('0' + sum_1_6) + ('0' & sum_1_7);

      -- level: 3. Num Adders: 2
      sum_3_0 <= ('0' + sum_2_0) + ('0' & sum_2_1);
      sum_3_1 <= ('0' + sum_2_2) + ('0' & sum_2_3);

      -- level: 4. Num Adders: 1
      sum_4_0 <= ('0' + sum_3_0) + ('0' & sum_3_1);

      prod <= sum_4_0 * coef;

      o_avg <= std_logic_vector(prod(DWIDTH+18 downto 18));
    end if;
  end process;
end architecture rtl;

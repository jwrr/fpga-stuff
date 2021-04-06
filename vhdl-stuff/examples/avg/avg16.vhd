
--------------------------------------------------------------------------------
-- Block: bigadd_16
-- Description:
-- This block implements a big adder with 16 inputs.
-- There are several add stages to improve timing.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
library work;


entity bigadd_16 is
  generic (
    DWIDTH  : integer := 16
)
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
    i_data_9  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_10  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_11  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_12  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_13  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_14  : in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_15  : in  std_logic_vector(DWIDTH-1 downto 0);
    o_sum : out std_logic_vector(DWIDTH+3 downto 0)
  );
end entity big_add16;

architecture rtl of bigadd_16 is
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

begin
  process(clk, rst)
  begin
    if rst then
    elsif rising_edge(clk) then
      -- level: 1. Num Adders: 8
      sum_1_0 <= sum_0_0 + sum_0_1;
      sum_1_1 <= sum_0_2 + sum_0_3;
      sum_1_2 <= sum_0_4 + sum_0_5;
      sum_1_3 <= sum_0_6 + sum_0_7;
      sum_1_4 <= sum_0_8 + sum_0_9;
      sum_1_5 <= sum_0_10 + sum_0_11;
      sum_1_6 <= sum_0_12 + sum_0_13;
      sum_1_7 <= sum_0_14 + sum_0_15;

      -- level: 2. Num Adders: 4
      sum_2_0 <= sum_1_0 + sum_1_1;
      sum_2_1 <= sum_1_2 + sum_1_3;
      sum_2_2 <= sum_1_4 + sum_1_5;
      sum_2_3 <= sum_1_6 + sum_1_7;

      -- level: 3. Num Adders: 2
      sum_3_0 <= sum_2_0 + sum_2_1;
      sum_3_1 <= sum_2_2 + sum_2_3;

      -- level: 4. Num Adders: 1
      sum_4_0 <= sum_3_0 + sum_3_1;

    end if;
  end process;
end architecture rtl;

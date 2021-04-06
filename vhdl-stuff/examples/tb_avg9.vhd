
--------------------------------------------------------------------------------
-- Test : tb_avg9.vhd
-- Description:
-- This test verifies the avg9 block.
--
--------------------------------------------------------------------------------
-- library std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library work;
use work.tb_pkg.all;

entity tb is
end entity tb;

architecture sim of tb is

  constant NUM_INPUTS    : integer := 9;
  constant DWIDTH        : integer := 16;

  signal  clk : std_logic;
  signal  rst : std_logic;
  type data_type is array(0 to NUM_INPUTS-1) of std_logic_vector(DWIDTH-1 downto 0);
  signal  i_data_array : data_type := (others => (others => '0'));
  signal  i_data_0  : std_logic_vector(DWIDTH-1 downto 0) := (others => '0');
  signal  i_data_1  : std_logic_vector(DWIDTH-1 downto 0) := (others => '0');
  signal  i_data_2  : std_logic_vector(DWIDTH-1 downto 0) := (others => '0');
  signal  i_data_3  : std_logic_vector(DWIDTH-1 downto 0) := (others => '0');
  signal  i_data_4  : std_logic_vector(DWIDTH-1 downto 0) := (others => '0');
  signal  i_data_5  : std_logic_vector(DWIDTH-1 downto 0) := (others => '0');
  signal  i_data_6  : std_logic_vector(DWIDTH-1 downto 0) := (others => '0');
  signal  i_data_7  : std_logic_vector(DWIDTH-1 downto 0) := (others => '0');
  signal  i_data_8  : std_logic_vector(DWIDTH-1 downto 0) := (others => '0');
  signal  o_avg     : std_logic_vector(DWIDTH-1 downto 0);
  signal  i_data_v  : std_logic;
  signal  o_avg_v   : std_logic;

  signal test_done  : std_logic := '0';

begin

  u_avg9: entity work.avg9
  generic map (
    DWIDTH  => DWIDTH
  )
  port map (
    clk => clk, -- std_logic;
    rst => rst, --  std_logic;
    i_data_0  => i_data_array(0),    -- in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_1  => i_data_array(1),    -- in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_2  => i_data_array(2),    -- in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_3  => i_data_array(3),    -- in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_4  => i_data_array(4),    -- in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_5  => i_data_array(5),    -- in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_6  => i_data_array(6),    -- in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_7  => i_data_array(7),    -- in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_8  => i_data_array(8),    -- in  std_logic_vector(DWIDTH-1 downto 0);
    i_data_v  => i_data_v,
    o_avg_v   => o_avg_v,
    o_avg     => o_avg               -- out std_logic_vector(DWIDTH+3 downto 0)
  );


  -- generate clocks until test_done is asserted
  process
  begin
    clkgen(clk,test_done);
    wait;  -- Simulation stops stop after clock stops
  end process;

  main_test: process
  begin

    report("reset dut");
    pulse(rst, clk, 10);

    report("After reset");

    wait_re(clk,10);

    for i in 0 to NUM_INPUTS-1 loop
      i_data_array(i) <= std_logic_vector(to_unsigned(32000+1000*i, DWIDTH));
    end loop;
    wait_re(clk,10);

    for i in 0 to NUM_INPUTS-1 loop
      i_data_array(i) <= std_logic_vector(to_unsigned(32000+3000*i, DWIDTH));
    end loop;
    wait_re(clk,20);

    report("test done"); -- severity NOTE, WARNING, ERROR, FAILURE (NOTE is default)

    set(test_done);
    wait;
  end process main_test;

end architecture sim;




--------------------------------------------------------------------------------
-- Test : reg_tb.vhd
-- Description:
-- This test verifies the reg block.
--
--------------------------------------------------------------------------------
-- library std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library work;
-- use work.tb_pkg.all;

entity tb is
end entity tb;

architecture sim of tb is
  constant CLK_PERIOD : time := 10 ns;
  constant DWID       : integer := 16;

  constant CLEN : integer := 10;
  constant RLEN : integer := 9;
  constant DLEN : integer := 16;

  signal test_done   : std_logic := '0';

  signal clk         : std_logic := '0';
  signal rst         : std_logic := '0';

  signal i_clk       : std_logic := '0';
  signal i_rst       : std_logic := '0';
  signal i_fsync     : std_logic := '0';
  signal i_lsync     : std_logic := '0';
  signal i_dval      : std_logic := '0';
  signal i_data      : std_logic_vector(DLEN-1 downto 0):= (others => '0');
  signal i_roi0_r0   : std_logic_vector(RLEN-1 downto 0):= (others => '0');
  signal i_roi0_c0   : std_logic_vector(CLEN-1 downto 0):= (others => '0');
  signal i_roi0_r1   : std_logic_vector(RLEN-1 downto 0):= (others => '0');
  signal i_roi0_c1   : std_logic_vector(CLEN-1 downto 0):= (others => '0');
  signal i_roi1_r0   : std_logic_vector(RLEN-1 downto 0):= (others => '0');
  signal i_roi1_c0   : std_logic_vector(CLEN-1 downto 0):= (others => '0');
  signal i_roi1_r1   : std_logic_vector(RLEN-1 downto 0):= (others => '0');
  signal i_roi1_c1   : std_logic_vector(CLEN-1 downto 0):= (others => '0');
  signal o_in_roi0   : std_logic := '0';
  signal o_in_roi1   : std_logic := '0';
  signal o_fsync     : std_logic := '0';
  signal o_lsync     : std_logic := '0';
  signal o_dval      : std_logic := '0';
  signal o_data      : std_logic_vector(DLEN-1 downto 0):= (others => '0');

begin

  u_dut1: entity work.in_roi
  generic map (
    CLEN => CLEN,
    RLEN => RLEN,
    DLEN => DLEN
  )
  port map (
    i_clk     => clk,       --  in  std_logic;
    i_rst     => rst,       --  in  std_logic;
    i_fsync   => i_fsync,   --  in  std_logic;
    i_lsync   => i_lsync,   --  in  std_logic;
    i_dval    => i_dval,    --  in  std_logic;
    i_data    => i_data,    --  in  std_logic_vector(DLEN-1 downto 0);
    i_roi0_r0 => i_roi0_r0, --  std_logic_vector(RLEN-1 downto 0);
    i_roi0_c0 => i_roi0_c0, --  std_logic_vector(CLEN-1 downto 0);
    i_roi0_r1 => i_roi0_r1, --  std_logic_vector(RLEN-1 downto 0);
    i_roi0_c1 => i_roi0_c1, --  std_logic_vector(CLEN-1 downto 0);
    i_roi1_r0 => i_roi1_r0, --  std_logic_vector(RLEN-1 downto 0);
    i_roi1_c0 => i_roi1_c0, --  std_logic_vector(CLEN-1 downto 0);
    i_roi1_r1 => i_roi1_r1, --  std_logic_vector(RLEN-1 downto 0);
    i_roi1_c1 => i_roi1_c1, --  std_logic_vector(CLEN-1 downto 0);
    o_in_roi0 => o_in_roi0, --  std_logic;
    o_in_roi1 => o_in_roi1, --  std_logic;
    o_fsync   => o_fsync,   --  in  std_logic;
    o_lsync   => o_lsync,   --  in  std_logic;
    o_dval    => o_dval,    --  in  std_logic;
    o_data    => o_data     --  in  std_logic_vector(DLEN-1 downto 0);
  );
  

  -- generate clocks until test_done is asserted
  process
  begin
    wait for CLK_PERIOD;
    while test_done = '0'  loop
      clk <= not clk;
      wait for CLK_PERIOD / 2;
    end loop;
    wait;  -- Simulation stops stop after clock stops
  end process;
  

  main_test: process
  begin

    report("reset dut");
    rst <= '0';
    for i in 1 to 10 loop wait until rising_edge(clk); end loop; 
    rst <= '1';
    for i in 1 to 10 loop wait until rising_edge(clk); end loop; 
    report("After reset");
    rst <= '0';
    for i in 1 to 10 loop wait until rising_edge(clk); end loop; 

    report("Start of test");
    
    for i in 1 to 100 loop
      wait until rising_edge(clk);
    end loop;
    wait until rising_edge(clk);
    for i in 1 to 20 loop wait until rising_edge(clk); end loop; 

    for i in 1 to 10 loop
      wait until rising_edge(clk);
      for j in 1 to 9 loop wait until rising_edge(clk); end loop; 
    end loop;

    report("Test done"); -- severity NOTE, WARNING, ERROR, FAILURE (NOTE is default)
    for i in 1 to 10 loop wait until rising_edge(clk); end loop; 
    test_done <= '1';
    wait;
  end process main_test;

end architecture sim;



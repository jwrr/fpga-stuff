
--------------------------------------------------------------------------------
-- Test : tb_how_many.vhd
-- Description:
-- This test verifies the how_many block.
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
  constant I_SIZE   : integer := 16;
  constant O_SIZE   : integer := 4;
  signal   i_vec    : std_logic_vector(I_SIZE-1 downto 0);
  signal   o_cnt    : std_logic_vector(O_SIZE-1 downto 0);

  constant CLK_PERIOD : time := 10 ns;
  signal clk       : std_logic := '0';
  signal rst       : std_logic := '0';
  signal test_done : std_logic := '0';

begin

  u_how_many: entity work.how_many
  generic map (
    I_SIZE        => I_SIZE,
    O_SIZE        => O_SIZE 
  )
  port map (
    i_vec         => i_vec,           -- in  std_logic_vector(I_SIZE-1 downto 0);
    o_cnt         => o_cnt            -- out std_logic_vector(O_SIZE-1 downto 0)
  )
  ; -- end how_many;


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

    for ii in 0 to 255 loop
      i_vec <= std_logic_vector(to_unsigned(ii, i_vec'length));
      wait until rising_edge(clk);
      report("val = " & integer'image(ii) & " cnt = "  & to_hstring(o_cnt) );
    end loop;



    report("Test done"); -- severity NOTE, WARNING, ERROR, FAILURE (NOTE is default)
    for i in 1 to 10 loop wait until rising_edge(clk); end loop; 
    test_done <= '1';
    wait;
  end process main_test;

end architecture sim;



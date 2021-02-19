
--------------------------------------------------------------------------------
-- Test : is_onehot.vhd
-- Description:
-- This test verifies the is_onehot block.
--
--------------------------------------------------------------------------------
-- library std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library work;

entity tb is
end entity tb;

architecture sim of tb is
  constant CLK_PERIOD : time := 10 ns;
  constant WIDTH   : integer   := 8;
  signal clk       : std_logic := '0';
  signal rst       : std_logic := '0';
  signal test_done : std_logic := '0';
  
  signal i_data    : std_logic_vector(WIDTH-1 downto 0);
  signal o_hot     : std_logic;

begin

  u_is_onehot: entity work.is_onehot
  generic map (
    WIDTH         => WIDTH 
  )
  port map (
    i_data        => i_data,          -- in  std_logic_vector(WIDTH-1 downto 0);
    o_hot         => o_hot            -- out std_logic;
  )
  ; -- end is_onehot;


  -- create clocks until test_done is asserted
  process
  begin
    wait for CLK_PERIOD;
    while test_done = '0' loop
      clk <= not clk;
      wait for CLK_PERIOD / 2;
    end loop;    
    wait;  -- Simulation stops stop after clock stops
  end process;

  main_test: process
  begin

    report("reset dut");
    rst <= '0';
    i_data <= (others => '0');
    for i in 1 to 10 loop wait until rising_edge(clk); end loop; 
    rst <= '1';
    for i in 1 to 10 loop wait until rising_edge(clk); end loop; 
    rst <= '0';
    for i in 1 to 10 loop wait until rising_edge(clk); end loop; 
    
    for ii in 0 to 255 loop
      i_data <= std_logic_vector(to_unsigned(ii,i_data'length));
      wait until rising_edge(clk);
      if o_hot = '1' then
        report (integer'image(ii) & " is one hot");
      end if;
    end loop;
    
    for i in 1 to 10 loop wait until rising_edge(clk); end loop; 

    test_done <= '1';

    wait;
  end process main_test;

end architecture sim;



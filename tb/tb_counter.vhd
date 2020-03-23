
--------------------------------------------------------------------------------
-- Test :
-- Description:
-- This test ...
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
  constant CLK_PERIOD : time    := 10 ns;
  constant WIDTH      : integer := 16;
  constant WRAP_AT    : integer := 255;

  signal clk          : std_logic;
  signal rst          : std_logic := '0';
  signal test_done    : std_logic := '0';

  signal i_clr        : std_logic;
  signal i_enable     : std_logic;
  signal o_cnt        : std_logic_vector(WIDTH-1 downto 0);

begin

  u_counter: entity work.counter
  generic map (
    WIDTH         => WIDTH,
    WRAP_AT       => WRAP_AT
  )
  port map (
    clk           => clk,             -- in  std_logic;
    rst           => rst,             -- in  std_logic;
    i_clr         => i_clr,           -- in  std_logic;
    i_enable      => i_enable,        -- in  std_logic;
    o_cnt         => o_cnt            -- out std_logic_vector(WIDTH-1 downto 0)
  );
  -- end counter;

  -- generate clocks until test_done is asserted
  process
  begin
    clkgen(clk,test_done);
    wait;  -- Simulation stops stop after clock stops
  end process clk_gen;

  main_test: process
  begin

    report("reset dut");

    clr(i_clr);
    clr(i_enable);
    pulse(rst, clk, 10);

    report("Disable counter");

    wait_re(clk,10);

    report("Increment Counter");
    set(i_enable);
    wait_re(clk, 1000);
    
    report("Clear Counter");
    pulse(i_clr,clk,100);


    report("Increment Counter Again");
    set(i_enable);
    wait_re(clk, 1000);
    
    report("Disable Counter");
    clr(i_enable);
    wait_re(clk, 1000);

    report("test done"); -- severity NOTE, WARNING, ERROR, FAILURE (NOTE is default)

    set(test_done);
    wait;
  end process main_test;

end architecture sim;


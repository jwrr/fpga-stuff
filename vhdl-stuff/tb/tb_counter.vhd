
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
  constant WIDTH      : integer := 16;
  constant WRAP_AT    : integer := 255;

  constant CLK_PERIOD      : time := 10 ns;
  constant CLK_HALF_PERIOD : time := CLK_PERIOD / 2;
  signal   clk_en          : std_logic := '0';
  signal   clk             : std_logic := '0';

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



  clk_en <= not test_done;
  clkgen: process
  begin
    while true loop
      wait until clk_en;
      while clk_en loop
        clk <= not clk;
        wait for CLK_HALF_PERIOD;
      end loop;
    end loop;
    wait;
  end process clkgen;



  main_test: process
  begin

    report("reset dut");

    i_clr <= '0';
    i_enable <= '0';
    pulse(rst, clk, 10);

    report("Disable counter");

    for i in 1 to 10 loop wait until rising_edge(clk); end loop;

    report("Increment Counter");
    i_enable <= '1';


    for i in 1 to 1000 loop wait until rising_edge(clk); end loop;

    report("Clear Counter");
    i_clr   <= '1';
    for i in 1 to 100 loop wait until rising_edge(clk); end loop;
    i_clr <= '0';
    
    report("Increment Counter Again");
    i_enable <= '1';

    for i in 1 to 1000 loop wait until rising_edge(clk); end loop; 
    
    report("Disable Counter");
    i_enable <= '0';

    for i in 1 to 1000 loop wait until rising_edge(clk); end loop;

    report("test done"); -- severity NOTE, WARNING, ERROR, FAILURE (NOTE is default)
    test_done <= '1';
    wait;
  end process main_test;

end architecture sim;


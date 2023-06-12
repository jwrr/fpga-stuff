
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

  signal apb_resetn        : std_logic := '1';
  signal test_done         : std_logic := '0';

  constant PADDR_WIDTH : integer := 16;
  constant PDATA_WIDTH : integer := 32;
  signal apb_clk      : std_logic := '0';
  signal apb_paddr    : std_logic_vector(PADDR_WIDTH-1 downto 0) := (others => '0');
  signal apb_penable  : std_logic := '0';
  signal apb_pwdata   : std_logic_vector(PDATA_WIDTH-1 downto 0) := (others => '0');
  signal apb_pwrite   : std_logic;
  signal apb_psel     : std_logic;
  signal apb_prdata   : std_logic_vector(PDATA_WIDTH-1 downto 0);
  signal apb_pready   : std_logic;
  signal apb_pslverr  : std_logic;
  signal apb_presetn  : std_logic;
  signal interrupt    : std_logic;

begin

  u_timer: entity work.timer
  generic map (
    PADDR_WIDTH  => PADDR_WIDTH,
    PDATA_WIDTH  => PDATA_WIDTH
  )
  port map (
    i_apb_clk      =>  apb_clk,      -- in   std_logic;
    i_apb_presetn  =>  apb_presetn,  -- in   std_logic;
    i_apb_paddr    =>  apb_paddr,    -- in   std_logic_vector(PADDR_WIDTH-1 downto 0);
    i_apb_penable  =>  apb_penable,  -- in   std_logic;
    i_apb_pwdata   =>  apb_pwdata,   -- in   std_logic_vector(PDATA_WIDTH-1 downto 0);
    i_apb_pwrite   =>  apb_pwrite,   -- in   std_logic;
    i_apb_psel     =>  apb_psel,     -- in   std_logic;
    o_apb_pready   =>  apb_pready,   -- out  std_logic;
    o_apb_prdata   =>  apb_prdata,   -- out  std_logic_vector(PDATA_WIDTH-1 downto 0);
    o_apb_pslverr  =>  apb_pslverr,  -- out  std_logic;
    o_interrupt    =>  interrupt     -- out  std_logic
  );

  clk_en <= not test_done;
  clkgen: process
  begin
    while true loop
      wait until clk_en;
      while clk_en loop
        apb_clk <= not apb_clk;
        wait for CLK_HALF_PERIOD;
      end loop;
    end loop;
    wait;
  end process clkgen;



  main_test: process

    procedure wait_rex(
      signal   sig : in std_logic;
      constant cnt : in positive
    ) is
    begin
      for i in 1 to cnt loop
        wait until rising_edge(sig);
      end loop;
    end procedure wait_rex;

  begin

    report("reset dut");

    apb_resetn <= '0';
    for i in 1 to 10 loop wait until rising_edge(apb_clk); end loop;
    apb_resetn <= '1';

    report("Disable timer");

    for i in 1 to 10 loop wait until rising_edge(apb_clk); end loop;

    report("Increment timer");

    for i in 1 to 1000 loop wait until rising_edge(apb_clk); end loop;

    report("Clear timer");
    for i in 1 to 100 loop wait until rising_edge(apb_clk); end loop;

    report("Increment timer Again");

    for i in 1 to 1000 loop wait until rising_edge(apb_clk); end loop;

    report("Disable timer");

    for i in 1 to 1000 loop wait until rising_edge(apb_clk); end loop;

    report("test done"); -- severity NOTE, WARNING, ERROR, FAILURE (NOTE is default)
    test_done <= '1';
    wait;
  end process main_test;

end architecture sim;


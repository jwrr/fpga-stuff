
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
  constant DEPTH      : integer := 1024;
  constant AWIDTH     : integer := 10;
  constant DWIDTH     : integer := 16;
  constant LATENCY    : integer := 1;
  constant INITFILE   : string  := "";

  signal clk          : std_logic;
  signal rst          : std_logic := '0';
  signal test_done    : std_logic := '0';
  

  signal i_clk_write  : std_logic;
  signal i_rst_write  : std_logic;
  signal i_write      : std_logic;
  signal i_waddr      : std_logic_vector(AWIDTH-1 downto 0);
  signal i_wdata      : std_logic_vector(DWIDTH-1 downto 0);
  
  signal i_clk_read   : std_logic;
  signal i_rst_read   : std_logic;
  signal i_read       : std_logic;
  signal i_raddr      : std_logic_vector(AWIDTH-1 downto 0);
  signal o_rdata      : std_logic_vector(DWIDTH-1 downto 0);
  signal o_rdata_v    : std_logic;
  

begin

  u_dpram: entity work.dpram
  generic map (
    DEPTH         => DEPTH,
    AWIDTH        => AWIDTH,
    DWIDTH        => DWIDTH,
    LATENCY       => LATENCY,
    INITFILE      => INITFILE 
  )
  port map (
    i_clk_write   => i_clk_write,     -- in  std_logic;
    i_rst_write   => i_rst_write,     -- in  std_logic;
    i_write       => i_write,         -- in  std_logic;
    i_waddr       => i_waddr,         -- in  std_logic_vector( AWIDTH-1 downto 0);
    i_wdata       => i_wdata,         -- in  std_logic_vector( DWIDTH-1 downto 0);

    i_clk_read    => i_clk_read,      -- in  std_logic;
    i_rst_read    => i_rst_read,      -- in  std_logic;
    i_read        => i_read,          -- in  std_logic;
    i_raddr       => i_raddr,         -- in  std_logic_vector( AWIDTH-1 downto 0);
    o_rdata       => o_rdata,         -- out std_logic_vector( DWIDTH-1 downto 0);
    o_rdata_v     => o_rdata_v        -- out std_logic
  );


  -- generate clocks until test_done is asserted
  clk_gen: process
  begin
    while test_done = '0' loop
      wait for CLK_PERIOD / 2;
      clk <= '1';
      wait for CLK_PERIOD / 2;
      clk <= '0';
    end loop;
    wait;  -- Simulation stops stop after clock stops
  end process clk_gen;
  
  i_clk_write <= clk;
  i_clk_read  <= clk;
  i_rst_write <= rst;
  i_rst_read  <= rst;
  
  main_test: process
  begin

    report("reset dut");
    
    clr(i_write);
    clr(i_waddr);
    clr(i_wdata);

    clr(i_read);
    clr(i_raddr);
    pulse(rst, i_clk_write, 10);
    
    report("Enable dut");
    
    wait_re(i_clk_write,10);
  
    report("Fill with incrementing pattern");  
    for i in 0 to 1023 loop
      set(i_write);
      wait_re(i_clk_write);
      set(i_waddr, i);
      set (i_wdata, i);
    end loop;

    clr(i_write);
    clr(i_raddr);
    wait_re(i_clk_read);
    
    report("Read incrementing pattern");  
    for i in 0 to 1023 loop
      set (i_read);
      wait_re(i_clk_read);
      incr(i_raddr);
    end loop;
    
    report("test done"); -- severity NOTE, WARNING, ERROR, FAILURE (NOTE is default)
  
    set(test_done);
    wait;
  end process main_test;

end architecture sim;



--------------------------------------------------------------------------------
-- Test : tb_fifo.vhd
-- Description:
-- This test verifies the fifo block.
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


  constant DEPTH        : integer := 16;
  constant WIDTH        : integer := 16;
  constant SAME_CLK     : boolean := true;


  signal clk_write  : std_logic := '0'; -- in
  signal rst_write  : std_logic := '0'; -- in
  signal i_write    : std_logic := '0'; -- in
  signal i_wdata    : std_logic_vector(WIDTH-1 downto 0) := (others => '0'); -- in
  signal o_wff      : std_logic; -- out

  signal clk_read   : std_logic := '0'; -- in
  signal rst_read   : std_logic := '0'; -- in
  signal i_read     : std_logic := '0'; -- in
  signal o_rdata    : std_logic_vector(WIDTH-1 downto 0); -- out
  signal o_ref      : std_logic; -- out
  signal o_rlast    : std_logic; -- out

  signal clk       : std_logic := '0';
  signal rst       : std_logic := '0';
  signal test_done : std_logic := '0';

begin


  u_fifo: entity work.fifo
  generic map (
    DEPTH         => DEPTH,
    WIDTH         => WIDTH,
    SAME_CLK      => SAME_CLK
  )
  port map (
    clk_write     => clk_write,       -- in  std_logic;
    rst_write     => rst_write,       -- in  std_logic;
    i_write       => i_write,         -- in  std_logic;
    i_wdata       => i_wdata,         -- in  std_logic_vector(WIDTH-1 downto 0);
    o_wff         => o_wff,           -- out std_logic;

    clk_read      => clk_read,        -- in  std_logic;
    rst_read      => rst_read,        -- in  std_logic;
    i_read        => i_read,          -- in  std_logic;
    o_rdata       => o_rdata,         -- out std_logic_vector(WIDTH-1 downto 0);
    o_rlast       => o_rlast,         -- out std_logic;
    o_ref         => o_ref            -- out std_logic;
  )
  ; -- end fifo;


  -- generate clocks until test_done is asserted
  process
  begin
    clkgen(clk,test_done);
    wait;  -- Simulation stops stop after clock stops
  end process;

  clk_write <= clk;
  clk_read  <= clk;
  rst_write <= rst;
  rst_read  <= rst;

  main_test: process
  begin

    report("reset dut");
    pulse(rst, clk, 10);

    report("After reset");

    wait_re(clk,10);
    wait_re(clk_write);

    report("Fill FIFO");
    for i in 1 to 2000 loop
      if o_wff = '1' then
        exit;
      end if;
      incr(i_wdata);
      set(i_write);
      wait_re(clk_write);
    end loop;

    clr(i_write);
    wait_re(clk_write);

    wait_re(clk_read);
    report("Read FIFO");
    for i in 1 to 2000 loop
      if o_ref = '1' then
        exit;
      end if;
      set(i_read);
      wait_re(clk_read);
    end loop;

    clr(i_read);
    wait_re(clk,20);

    report("test done"); -- severity NOTE, WARNING, ERROR, FAILURE (NOTE is default)

    set(test_done);
    wait;
  end process main_test;

end architecture sim;



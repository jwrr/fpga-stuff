
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
use WORK.tb_pkg;
use WORK.vid_pack;

entity tb is
end entity tb;

architecture sim of tb is
  constant NN : integer := 5;
  constant FW : integer := 16;
  constant FH : integer := 16;
  constant PW : integer := 8;

  constant CLK_PERIOD      : time := 10 ns;
  constant CLK_HALF_PERIOD : time := CLK_PERIOD / 2;

  signal   clk_en          : std_logic := '0';
  signal   clk             : std_logic := '0';

  signal rst          : std_logic := '0';
  signal test_done    : std_logic := '0';

  signal i_clk     : std_logic;
  signal i_rst     : std_logic;
  signal i_frame_v : std_logic;
  signal i_line_v  : std_logic;
  signal i_pixel_v : std_logic;
  signal i_pixel   : std_logic_vector(PW-1 downto 0);
  signal o_frame_v : std_logic;
  signal o_line_v  : std_logic;
  signal o_pixels  : vid_pack.array_of_slv(0 to NN-1);
  
  signal i_video_port : WORK.vid_pack.video_port;
  signal o_video_port : WORK.vid_pack.video_port;

begin

  i_clk <= clk;
  i_rst <= rst;

  u_video_line_buffer: entity WORK.video_line_buffer
  generic map (
    NN => NN, -- integer := 5;   -- NxN Kernel
    FW => FW, -- integer := 256; -- Frame Width
    FH => FH, -- integer := 256; -- Frame Height
    PW => PW  -- integer := 8    -- Pixel Width
  )
  port map (
    i_clk     => clk,       -- in  std_logic;
    i_rst     => i_rst,     -- in  std_logic;
    i_frame_v => i_frame_v, -- in  std_logic;
    i_video_port => i_video_port,
    o_video_port => o_video_port,
    i_line_v  => i_line_v,  -- in  std_logic;
    i_pixel   => i_pixel,   -- in  unsigned(PW-1 downto 0);
    o_frame_v => o_frame_v, -- out std_logic;
    o_line_v  => o_line_v,  -- out std_logic;
    o_pixels  => o_pixels   -- out unsigned(PW-1 downto 0)
  );


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

    i_frame_v <= '0';
    i_line_v <= '0';
    i_pixel <= (others => '0');
    tb_pkg.pulse(rst, clk, 10);

    report("Disable counter");

    for i in 1 to 100 loop wait until rising_edge(clk); end loop;
    i_video_port <= vid_pack.video_port_reset;
    for i in 1 to 10 loop wait until rising_edge(clk); end loop;


    for pix_i in 1 to 20000 loop
      i_video_port <= vid_pack.video_port_incr(i_video_port);
      tb_pkg.tick(clk);
    end loop;

    for i in 1 to 1000 loop wait until rising_edge(clk); end loop;

    report("test done"); -- severity NOTE, WARNING, ERROR, FAILURE (NOTE is default)
    test_done <= '1';
    wait;
  end process main_test;

end architecture sim;


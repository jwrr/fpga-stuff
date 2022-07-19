
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
use WORK.test_pack;
use WORK.vid_pack;

entity tb is
end entity tb;

architecture sim of tb is

  constant CPP : natural := 4;
  constant FRAME_WIDTH  : natural := 40;
  constant FRAME_HEIGHT : natural := 40;
  constant KSIZE : integer := 5;
  constant FW : integer := 16;
  constant FH : integer := 16;
  constant PIXLEN : integer := 8;

  constant CLK_PERIOD      : time := 10 ns;
  constant CLK_HALF_PERIOD : time := CLK_PERIOD / 2;

  signal clk_en    : std_logic := '0';
  signal clk       : std_logic := '0';

  signal rst       : std_logic := '0';
  signal test_done : std_logic := '0';
  signal cnt       : integer := 0;

  signal i_clk     : std_logic;
  signal i_rst     : std_logic;
  signal i_frame_v : std_logic;
  signal i_line_v  : std_logic;
  signal i_pixel_v : std_logic;
  signal i_pixel   : std_logic_vector(PIXLEN-1 downto 0);
  signal o_frame_v : std_logic;
  signal o_line_v  : std_logic;
  signal o_pixels  : vid_pack.array_of_slv(0 to KSIZE-1);
  
  signal i_vp      : vid_pack.vport;
  signal o_vp      : vid_pack.vport;

  signal pass      : boolean := true;
  signal test_pass : boolean := true;


  impure function test_frame_sof(vp : vid_pack.vport; f, r, c : natural) return boolean is
    variable v_pass : boolean := false;
    variable v_repeat_first_test : boolean := false;
  begin
    v_repeat_first_test := (f=1 and r=1 and c<=2);
    if (r = 1 and c = 1) or v_repeat_first_test then
      v_pass := test_pack.test(i_vp.frame_sof = '1', "Frame SOF");
    else
      v_pass := test_pack.test(i_vp.frame_sof = '0', "Not Frame SOF");
    end if;
    return v_pass;
  end function test_frame_sof;


  impure function test_frame_sol(vp : vid_pack.vport; f, r, c : natural) return boolean is
    variable v_pass : boolean := false;
    variable v_repeat_first_test : boolean := false;
  begin
    v_repeat_first_test := (f=1 and r=1 and c<=2);
    if (c = 1) or v_repeat_first_test then
      v_pass := test_pack.test(i_vp.frame_sol = '1', "Frame SOL");
    else
      v_pass := test_pack.test(i_vp.frame_sol = '0', "Not Frame SOL");
    end if;
    return v_pass;
  end function test_frame_sol;

begin

  i_clk <= clk;
  i_rst <= rst;

  u_video_line_buffer: entity WORK.video_line_buffer
  generic map (
    KSIZE  => KSIZE, -- integer := 5;   -- NxN Kernel
    FW     => FW,    -- integer := 256; -- Frame Width
    FH     => FH,    -- integer := 256; -- Frame Height
    PIXLEN => PIXLEN -- integer := 8    -- Pixel Width
  )
  port map (
    i_clk => clk,    -- in  std_logic;
    i_rst => i_rst,  -- in  std_logic;
    i_vp  => i_vp,   -- in  vid_pack.vport;
    o_vp  => o_vp    -- out vid_pack.vport;
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
    variable v_col_size : integer := 0;
    variable v_first_pix : boolean := true;
    variable v_repeat_first_test : boolean := true;
  begin
    i_vp <= vid_pack.vport_reset;

--     report("reset dut");
    test_pack.msg("Reset DUT");

    i_frame_v <= '0';
    i_line_v <= '0';
    i_pixel <= (others => '0');
    test_pack.pulse(rst, clk, 10);

    for i in 1 to 100 loop wait until rising_edge(clk); end loop;
    i_vp <= vid_pack.vport_reset;
    for i in 1 to 10 loop wait until rising_edge(clk); end loop;
    i_vp <= vid_pack.vport_reset;
    for f in 1 to 20 loop
      for r in 1 to FRAME_HEIGHT loop
        v_col_size := FRAME_WIDTH+1 when v_first_pix else FRAME_WIDTH;
        for c in 1 to v_col_size loop

          test_pass <= test_frame_sof(i_vp, f, r, c) and
                       test_frame_sol(i_vp, f, r, c) and test_pass;

          for p in 1 to CPP loop
            cnt <= cnt + 1;
            i_vp <= vid_pack.vport_incr(i_vp);
            i_vp.pix <= to_unsigned((cnt/4) mod 256, i_vp.pix'length);
            test_pack.tick(clk);
          end loop;
          v_first_pix := false;
        end loop;
      end loop;
    end loop;

    for i in 1 to 1000 loop wait until rising_edge(clk); end loop;

    test_done <= '1';
    
--     report("test done"); -- severity NOTE, WARNING, ERROR, FAILURE (NOTE is default)
    test_pack.msg("Test Done");
    test_pass <= test_pack.test(test_pass, "FINAL TEST RESULT ***************", true);
    wait;
  end process main_test;

end architecture sim;


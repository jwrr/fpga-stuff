--------------------------------------------------------------------------------
-- Block: video_line_buffer
-- Description:
-- This block stores N lines of a video frame and output an NxN array for each
-- pixel.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.vid_pack;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity video_line_buffer is
generic (
  KSIZE   : integer := 5;   -- NxN Kernel. KSIZE IS ALWAYS ODD
  FW   : integer := 256; -- Frame Width
  FH   : integer := 256; -- Frame Height
  PWID : integer := 8    -- Pixel Width
);
port (
  i_clk        : in  std_logic;
  i_rst        : in  std_logic;
  i_vp         : in  vid_pack.vport;
  o_vp         : out vid_pack.vport
);
end entity video_line_buffer;

architecture rtl of video_line_buffer is
  constant BUF_DEPTH     : natural := FW;
  constant AWID          : natural := integer(ceil(log2(real(BUF_DEPTH))));
  signal KERNEL_OFFSET   : integer := (KSIZE+1) / 2;
  signal write_sel       : std_logic_vector(KSIZE-1 downto 0);
  signal write           : std_logic_vector(KSIZE-1 downto 0);

  signal read            : std_logic;
  signal rdata_array     : vid_pack.array_of_slv(0 to KSIZE-1); --  std_logic_vector(i_pixel'range);
  signal rdata_array_v   : std_logic;

  signal window_2darray  : vid_pack.array_of_unsigned(0 to KSIZE*KSIZE-1);
  type array_of_vports   is array(natural range <>) of vid_pack.vport; 
  signal vid_pipeline    : array_of_vports(0 to 10);

  signal waddr           : std_logic_vector(AWID-1 downto 0);
  signal raddr           : std_logic_vector(AWID-1 downto 0);
  signal wdata           : std_logic_vector(PWID-1 downto 0);

  signal enable_read     : std_logic;
  signal enable_read_ff  : std_logic;

  signal l1_vp           : vid_pack.vport;

begin

  waddr <= std_logic_vector(resize(i_vp.active_hcnt, waddr'length));
  wdata <= std_logic_vector(resize(i_vp.pix, wdata'length));
  raddr <= std_logic_vector(resize(l1_vp.active_hcnt, raddr'length));

  G_LINE_BUF: for ii in 0 to KSIZE-1 generate
    u_dpram: entity WORK.dpram
    generic map (
      DEPTH         => BUF_DEPTH,
      AWIDTH        => AWID,
      DWIDTH        => PWID
  --  LATENCY       => LATENCY,
  --  INITFILE      => INITFILE
    )
    port map (
      i_clk_write => i_clk,     -- in  std_logic;
      i_rst_write => i_rst,     -- in  std_logic;
      i_write     => write(ii), -- in  std_logic;
      i_waddr     => waddr,     -- in  std_logic_vector( AWIDTH-1 downto 0);
      i_wdata     => wdata,     -- in  std_logic_vector( DWIDTH-1 downto 0);

      i_clk_read  => i_clk,           -- in  std_logic;
      i_rst_read  => i_rst,           -- in  std_logic;
      i_read      => l1_vp.pix_v,     -- in  std_logic;
      i_raddr     => raddr,           -- in  std_logic_vector( AWIDTH-1 downto 0);
      o_rdata     => rdata_array(ii), -- out std_logic_vector( DWIDTH-1 downto 0);
      o_rdata_v   => rdata_array_v    -- out std_logic
    );
  end generate G_LINE_BUF;

  write <= write_sel when i_vp.pix_v else (others => '0');

  enable_read <= '1' when (enable_read_ff = '1') or
                          ((i_vp.frame_vcnt = KERNEL_OFFSET) and (i_vp.frame_eol = '1') and (i_vp.frame_eopix_v = '1'))
                  else '0';
  u_enable_read_ff: entity WORK.ff port map (i_clk, i_rst, enable_read, enable_read_ff);


  pipeline: process(i_clk, i_rst)
  begin
    if i_rst then
      for ii in 0 to vid_pipeline'high loop
        vid_pipeline(ii) <= vid_pack.vport_reset;
      end loop;
    elsif rising_edge(i_clk) then
      for ii in vid_pipeline'high downto 1 loop
        vid_pipeline(ii) <= vid_pipeline(ii-1);
      end loop;
      vid_pipeline(0) <= vid_pack.vport_incr(vid_pipeline(0));
      -- Stage 0: read buffer
      -- Stage 1: read delay
      -- Stage 2: read delay
      -- Stage 3: read valid shift window
      -- Stage 4: matmul (NxN multipliers)
      -- Stage 5: matsum;;
    end if;
  end process pipeline;
  

  process(i_clk, i_rst)
  begin
    if i_rst then
      write_sel(KSIZE-2 downto 0) <= (others => '0');
      write_sel(KSIZE-1) <= '1';
      l1_vp              <= vid_pack.vport_reset;
      o_vp    <= vid_pack.vport_reset;
    elsif rising_edge(i_clk) then

      if enable_read then
        l1_vp <= vid_pack.vport_incr(l1_vp);
      else
        l1_vp <= vid_pack.vport_reset;
      end if;

      if rdata_array_v then
        window_2darray <= vid_pack.shift_window(window_2darray, vid_pack.to_array_of_unsigned(rdata_array));
      end if;

      o_vp <= l1_vp;

      if i_vp.active_sol and i_vp.frame_pix_v then
        write_sel <= write_sel(KSIZE-2 downto 0) & write_sel(KSIZE-1);
      end if;

    end if;
  end process;


end architecture rtl;



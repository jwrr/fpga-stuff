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

entity video_line_buffer is
generic (
  KSIZE   : integer := 5;   -- NxN Kernel. KSIZE IS ALWAYS ODD
  FW   : integer := 256; -- Frame Width
  FH   : integer := 256; -- Frame Height
  PIXLEN : integer := 8    -- Pixel Width
);
port (
  i_clk        : in  std_logic;
  i_rst        : in  std_logic;
  i_vp         : in  vid_pack.vport;
  o_vp         : out vid_pack.vport
);
end entity video_line_buffer;

architecture rtl of video_line_buffer is
  constant ALEN          : integer := 4; -- cnt width
  constant KERNEL_OFFSET : integer := (KSIZE-1) / 2;
  signal write_sel    : std_logic_vector(KSIZE-1 downto 0);
  signal write        : std_logic_vector(KSIZE-1 downto 0);

  signal read         : std_logic;
  signal rdata        : vid_pack.array_of_slv(0 to KSIZE-1); --  std_logic_vector(i_pixel'range);
  signal rdata_v      : std_logic;
  
  signal waddr_tmp    : std_logic_vector(ALEN-1 downto 0);
  signal raddr_tmp    : std_logic_vector(ALEN-1 downto 0);
  signal wdata_tmp    : std_logic_vector(PIXLEN-1 downto 0);
  
  signal delay_read   : std_logic;
  
  signal l_vp         : vid_pack.vport;
  
begin

  waddr_tmp <= std_logic_vector(resize(i_vp.active_hcnt, waddr_tmp'length));
  wdata_tmp <= std_logic_vector(resize(i_vp.pix, wdata_tmp'length));
  raddr_tmp <= (others => '0'); -- std_logic_vector(resize(l_vp.active_hcnt, raddr_tmp'length));

  G_LINE_BUF: for ii in 0 to KSIZE-1 generate
    u_dpram: entity WORK.dpram
    generic map (
      DEPTH         => FW,
      AWIDTH        => ALEN,
      DWIDTH        => PIXLEN
  --  LATENCY       => LATENCY,
  --  INITFILE      => INITFILE
    )
    port map (
      i_clk_write => i_clk,     -- in  std_logic;
      i_rst_write => i_rst,     -- in  std_logic;
      i_write     => write(ii), -- in  std_logic;
      i_waddr     => waddr_tmp, -- in  std_logic_vector( AWIDTH-1 downto 0);
      i_wdata     => wdata_tmp, -- in  std_logic_vector( DWIDTH-1 downto 0);

      i_clk_read  => i_clk,     -- in  std_logic;
      i_rst_read  => i_rst,     -- in  std_logic;
      i_read      => '0',       -- in  std_logic;
      i_raddr     => raddr_tmp, -- in  std_logic_vector( AWIDTH-1 downto 0);
      o_rdata     => rdata(ii), -- out std_logic_vector( DWIDTH-1 downto 0);
      o_rdata_v   => rdata_v    -- out std_logic
    );
  end generate G_LINE_BUF;

  write <= write_sel when i_vp.pix_v else (others => '0');
  delay_read <= '1' when i_vp.active_vcnt <= (KSIZE / 2) else '0';

  process(i_clk, i_rst)
  begin
    if i_rst then
      write_sel(KSIZE-2 downto 0) <= (others => '0');
      write_sel(KSIZE-1) <= '1';
      l_vp    <= vid_pack.vport_reset;
      o_vp    <= vid_pack.vport_reset;
    elsif rising_edge(i_clk) then
      
      if delay_read then
        l_vp <= vid_pack.vport_reset;
      else
        l_vp <= vid_pack.vport_incr(o_vp);
      end if;
      o_vp <= i_vp;
      
      if i_vp.active_sol and i_vp.frame_pix_v then
        write_sel <= write_sel(KSIZE-2 downto 0) & write_sel(KSIZE-1);
      end if;

    end if;
  end process;


end architecture rtl;



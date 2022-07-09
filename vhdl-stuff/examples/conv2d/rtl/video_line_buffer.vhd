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
library work;
use work.video_line_buffer_package.all;

entity video_line_buffer is
generic (
  NN   : integer := 5;   -- NxN Kernel
  FW   : integer := 256; -- Frame Width
  FH   : integer := 256; -- Frame Height
  PW   : integer := 8    -- Pixel Width
);
port (
  i_clk     : in  std_logic;
  i_rst     : in  std_logic;
  i_frame_v : in  std_logic;
  i_line_v  : in  std_logic;
  i_pixel   : in  std_logic_vector(PW-1 downto 0);
  o_frame_v : out std_logic;
  o_line_v  : out std_logic;
  o_pixels  : out video_line_buffer_array(0 to NN-1)
);
end entity video_line_buffer;

architecture rtl of video_line_buffer is
  constant CW         : integer := 8; -- cnt width'
  constant READ_DELAY : integer := NN / 2;
  signal frame_v   : std_logic;
  signal line_v    : std_logic;
  signal sof       : std_logic;
  signal sol       : std_logic;
  signal pixel     : std_logic_vector(i_pixel'range);
  signal row_cnt   : unsigned(CW-1 downto 0);
  signal col_cnt   : unsigned(CW-1 downto 0);
  signal waddr     : std_logic_vector(col_cnt'range);
  signal wdata     : std_logic_vector(i_pixel'range);
  signal write_sel : std_logic_vector(NN-1 downto 0);
  signal write     : std_logic_vector(NN-1 downto 0);
  signal raddr     : std_logic_vector(col_cnt'range);
  signal read      : std_logic;
  signal rdata     : video_line_buffer_array(0 to NN-1); --  std_logic_vector(i_pixel'range);
  signal rdata_v   : std_logic;
begin


  G_LINE_BUF: for ii in 0 to NN-1 generate
    u_dpram: entity work.dpram
    generic map (
      DEPTH         => FW,
      AWIDTH        => waddr'length,
      DWIDTH        => wdata'length
  --  LATENCY       => LATENCY,
  --  INITFILE      => INITFILE
    )
    port map (
      i_clk_write => i_clk,     -- in  std_logic;
      i_rst_write => i_rst,     -- in  std_logic;
      i_write     => write(ii), -- in  std_logic;
      i_waddr     => waddr,     -- in  std_logic_vector( AWIDTH-1 downto 0);
      i_wdata     => wdata,     -- in  std_logic_vector( DWIDTH-1 downto 0);
  
      i_clk_read  => i_clk,     -- in  std_logic;
      i_rst_read  => i_rst,     -- in  std_logic;
      i_read      => read,      -- in  std_logic;
      i_raddr     => raddr,     -- in  std_logic_vector( AWIDTH-1 downto 0);
      o_rdata     => rdata(ii), -- out std_logic_vector( DWIDTH-1 downto 0);
      o_rdata_v   => rdata_v    -- out std_logic
    );
  end generate G_LINE_BUF;

  sof   <= i_frame_v and not frame_v;
  sol   <= i_line_v and not line_v;
  waddr <= std_logic_vector(col_cnt);
  wdata <= std_logic_vector(pixel);
  write <= write_sel when line_v else (others => '0');

  process(i_clk, i_rst)
  begin
    if i_rst then
      frame_v <= '0';
      line_v  <= '0';
      pixel   <= (others => '0');
      row_cnt <= (others => '0');
      col_cnt <= to_unsigned(0, col_cnt'length);
      write_sel(NN-2 downto 0) <= (others => '0');
      write_sel(NN-1) <= '1';
    elsif rising_edge(i_clk) then
      frame_v <= i_frame_v;
      line_v  <= i_line_v;
      pixel   <= i_pixel;

      if sof then
        row_cnt <= (others => '0');
      elsif sol then
        row_cnt <= row_cnt + 1;
      end if;

      if sol then
        col_cnt <= (others => '0');
      elsif line_v then
        col_cnt <= col_cnt + 1;
      end if;
      
      if col_cnt < READ_DELAY then
        read  <= '0';
        raddr <= (others => '0');
      else
        read <= '1';
        raddr <= std_logic_vector(col_cnt - READ_DELAY);
      end if;
      
      if sol then
        write_sel <= write_sel(NN-2 downto 0) & write_sel(NN-1);
      end if;
      
     o_pixels <= rdata;
      o_line_v <= rdata_v;
      o_frame_v <= rdata_v;

    end if;
  end process;


end architecture rtl;



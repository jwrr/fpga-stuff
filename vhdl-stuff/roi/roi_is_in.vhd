
-- --------------------------------------------------------------------------------
-- Block: roi_is_in
-- Description:
-- This block checks if the current pixel is in the region of interest. Two
-- ROIs are supported
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.roi_pkg.all;

entity roi_is_in is
generic (
  CLEN : integer := 9;
  RLEN : integer := 8;
  DLEN : integer := 16
);
port (
  fromx_roi_rec      : in  fromx_roi_record;
  i_clk              : in  std_logic;
  i_rst              : in  std_logic;
  i_fsync            : in  std_logic;
  i_lsync            : in  std_logic;
  i_dval             : in  std_logic;
  i_data0            : in  std_logic_vector(DLEN-1 downto 0);
  i_data1            : in  std_logic_vector(DLEN-1 downto 0);
  o_roi_center_is_in : out std_logic;
  o_roi_minmax_is_in : out std_logic;
  o_roi_select_is_in : out std_logic;
  o_fsync            : out std_logic;
  o_lsync            : out std_logic;
  o_dval             : out std_logic;
  o_data0            : out std_logic_vector(DLEN-1 downto 0);
  o_data1            : out std_logic_vector(DLEN-1 downto 0);
  o_roi_center_done  : out std_logic;
  o_roi_minmax_done  : out std_logic;
  o_roi_select_done  : out std_logic
);
end roi_is_in;

architecture rtl of roi_is_in is
  signal row  : unsigned(RLEN-1 downto 0);
  signal col  : unsigned(CLEN-1 downto 0);

  signal roi_center_r0 : unsigned(RLEN-1 downto 0);
  signal roi_center_c0 : unsigned(CLEN-1 downto 0);
  signal roi_center_r1 : unsigned(RLEN-1 downto 0);
  signal roi_center_c1 : unsigned(CLEN-1 downto 0);
  signal roi_minmax_r0 : unsigned(RLEN-1 downto 0);
  signal roi_minmax_c0 : unsigned(CLEN-1 downto 0);
  signal roi_minmax_r1 : unsigned(RLEN-1 downto 0);
  signal roi_minmax_c1 : unsigned(CLEN-1 downto 0);
  signal roi_select_r0 : unsigned(RLEN-1 downto 0);
  signal roi_select_c0 : unsigned(CLEN-1 downto 0);
  signal roi_select_r1 : unsigned(RLEN-1 downto 0);
  signal roi_select_c1 : unsigned(CLEN-1 downto 0);

  signal fsync   : std_logic;
  signal lsync   : std_logic;
  signal dval    : std_logic;
  signal data0   : std_logic_vector(DLEN-1 downto 0);
  signal data1   : std_logic_vector(DLEN-1 downto 0);
begin

  process (i_clk, i_rst)
  begin
    if i_rst then
      row                <= (others => '0');
      col                <= (others => '0');
      roi_center_r0      <= (others => '0');
      roi_center_c0      <= (others => '0');
      roi_center_r1      <= (others => '0');
      roi_center_c1      <= (others => '0');
      roi_minmax_r0      <= (others => '0');
      roi_minmax_c0      <= (others => '0');
      roi_minmax_r1      <= (others => '0');
      roi_minmax_c1      <= (others => '0');
      roi_select_r0      <= (others => '0');
      roi_select_c0      <= (others => '0');
      roi_select_r1      <= (others => '0');
      roi_select_c1      <= (others => '0');
      fsync              <= '0';
      lsync              <= '0';
      dval               <= '0';
      data0              <= (others => '0');
      data1              <= (others => '0');
      o_fsync            <= '0';
      o_lsync            <= '0';
      o_dval             <= '0';
      o_data0            <= (others => '0');
      o_data1            <= (others => '0');
      o_roi_center_is_in <= '0';
      o_roi_minmax_is_in <= '0';
      o_roi_select_is_in <= '0';
      o_roi_center_done  <= '0';
      o_roi_minmax_done  <= '0';
      o_roi_select_done  <= '0';
    elsif rising_edge(i_clk) then

      -- allow roi to update on frame boundary
      if i_fsync and i_dval then
        roi_center_r0 <= unsigned(fromx_roi_rec.roi_center_r0);
        roi_center_c0 <= unsigned(fromx_roi_rec.roi_center_c0);
        roi_center_r1 <= unsigned(fromx_roi_rec.roi_center_r1);
        roi_center_c1 <= unsigned(fromx_roi_rec.roi_center_c1);
        roi_minmax_r0 <= unsigned(fromx_roi_rec.roi_minmax_r0);
        roi_minmax_c0 <= unsigned(fromx_roi_rec.roi_minmax_c0);
        roi_minmax_r1 <= unsigned(fromx_roi_rec.roi_minmax_r1);
        roi_minmax_c1 <= unsigned(fromx_roi_rec.roi_minmax_c1);
        roi_select_r0 <= unsigned(fromx_roi_rec.roi_select_r0);
        roi_select_c0 <= unsigned(fromx_roi_rec.roi_select_c0);
        roi_select_r1 <= unsigned(fromx_roi_rec.roi_select_r1);
        roi_select_c1 <= unsigned(fromx_roi_rec.roi_select_c1);
      end if;

      -- increment row and column counters
      if i_fsync and i_dval then
        row <= (others => '0');
      elsif i_lsync and i_dval then
        row <= row + 1;
      end if;

      if i_lsync and i_dval then
        col <= (others => '0');
      elsif i_dval then
        col <= col + 1;
      end if;

      fsync  <= i_fsync;
      lsync  <= i_lsync;
      dval   <= i_dval;
      data0  <= i_data0;
      data1  <= i_data1;

      -- check if counters are in range

      -- ====================================================

      if (row >= roi_center_r0) and (row < roi_center_r1) and
         (col >= roi_center_c0) and (col < roi_center_c1)
      then
        o_roi_center_is_in <= '1';
      else
        o_roi_center_is_in <= '0';
      end if;

      if i_fsync then
        o_roi_center_done <= '0';
      elsif row = (roi_center_r1-1) and col = (roi_center_c1-1) then
        o_roi_center_done <= '1';
      end if; 

      -- ====================================================

      if (row >= roi_minmax_r0) and (row < roi_minmax_r1) and
         (col >= roi_minmax_c0) and (col < roi_minmax_c1)
      then
        o_roi_minmax_is_in <= '1';
      else
        o_roi_minmax_is_in <= '0';
      end if;
      
      if i_fsync then
        o_roi_minmax_done <= '0';
      elsif row = (roi_minmax_r1-1) and col = (roi_minmax_c1-1) then
        o_roi_minmax_done <= '1';
      end if; 

      -- ====================================================

      if (row >= roi_select_r0) and (row < roi_select_r1) and
         (col >= roi_select_c0) and (col < roi_select_c1)
      then
        o_roi_select_is_in <= '1';
      else
        o_roi_select_is_in <= '0';
      end if;
      
      if i_fsync then
        o_roi_select_done <= '0';
      elsif row = (roi_select_r1-1) and col = (roi_select_c1-1) then
        o_roi_select_done <= '1';
      end if; 

      -- ====================================================

      o_fsync <= fsync;
      o_lsync <= lsync;
      o_dval  <= dval;
      o_data0  <= data0;
      o_data1  <= data1;

    end if;
  end process;

end rtl;


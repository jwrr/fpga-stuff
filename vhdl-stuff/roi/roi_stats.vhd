--------------------------------------------------------------------------------
-- Block: roi_stats
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


entity roi_stats is
generic (
  CLEN : integer := 9;
  RLEN : integer := 8;
  DLEN : integer := 16;
  SLEN : integer := 32
);
port (
  fromx_roi_rec : in  fromx_roi_record;
  roi_tox_rec   : out roi_tox_record;
  i_clk         : in  std_logic;
  i_rst         : in  std_logic;
  i_fsync       : in  std_logic;
  i_lsync       : in  std_logic;
  i_dval        : in  std_logic;
  i_data0       : in  std_logic_vector(DLEN-1 downto 0);
  i_data1       : in  std_logic_vector(DLEN-1 downto 0);

  o_fsync       : out std_logic;
  o_lsync       : out std_logic;
  o_dval        : out std_logic;
  o_data0       : out std_logic_vector(DLEN-1 downto 0);
  o_data1       : out std_logic_vector(DLEN-1 downto 0)
);
end roi_stats;

architecture rtl of roi_stats is

  signal roi0_done   : std_logic;
  signal roi1_done   : std_logic;
  signal roi0_is_in  : std_logic;
  signal roi1_is_in  : std_logic;

begin

  u_roi_is_in: entity work.roi_is_in
  generic map (
    CLEN => CLEN,
    RLEN => RLEN,
    DLEN => DLEN
  )
  port map (
    fromx_roi_rec => fromx_roi_rec,
    i_clk         => i_clk,      --  in  std_logic;
    i_rst         => i_rst,      --  in  std_logic;
    i_fsync       => i_fsync,    --  in  std_logic;
    i_lsync       => i_lsync,    --  in  std_logic;
    i_dval        => i_dval,     --  in  std_logic;
    i_data0       => i_data0,    --  in  std_logic_vector(DLEN-1 downto 0);
    i_data1       => i_data1,    --  in  std_logic_vector(DLEN-1 downto 0);
    o_roi0_is_in  => roi0_is_in, --  out std_logic;
    o_roi1_is_in  => roi1_is_in, --  out std_logic;
    o_fsync       => o_fsync,    --  out std_logic;
    o_lsync       => o_lsync,    --  out std_logic;
    o_dval        => o_dval,     --  out std_logic;
    o_roi0_done   => roi0_done,  --  out std_logic;
    o_roi1_done   => roi1_done,  --  out std_logic;
    o_data0       => o_data0,    --  out std_logic_vector(DLEN-1 downto 0);
    o_data1       => o_data1     --  out std_logic_vector(DLEN-1 downto 0);
  );

  process (i_clk, i_rst)
  begin
    if i_rst then
      roi_tox_rec.roi0_max <= (others => '0');
      roi_tox_rec.roi0_min <= (others => '0');
      roi_tox_rec.roi0_sum <= (others => '0');
    elsif rising_edge(i_clk) then
      if i_fsync then
        roi_tox_rec.roi0_max <= (others => '0');
        roi_tox_rec.roi0_min <= (others => '1');
        roi_tox_rec.roi0_sum <= (others => '0');
      elsif roi0_is_in then
        if unsigned(o_data0) > unsigned(roi_tox_rec.roi0_max) then
          roi_tox_rec.roi0_max <= o_data0;
        end if;
        if unsigned(o_data0) < unsigned(roi_tox_rec.roi0_min) then
          roi_tox_rec.roi0_min <= o_data0;
        end if;
        roi_tox_rec.roi0_sum <= std_logic_vector(to_unsigned(to_integer(unsigned(roi_tox_rec.roi0_sum)) + to_integer(unsigned(o_data0)), roi_tox_rec.roi0_sum'length));
      end if;
    end if;
  end process;


  process (i_clk, i_rst)
  begin
    if i_rst then
      roi_tox_rec.roi1_max <= (others => '0');
      roi_tox_rec.roi1_min <= (others => '0');
      roi_tox_rec.roi1_sum <= (others => '0');
    elsif rising_edge(i_clk) then
      if i_fsync then
        roi_tox_rec.roi1_max <= (others => '0');
        roi_tox_rec.roi1_min <= (others => '1');
        roi_tox_rec.roi1_sum <= (others => '0');
      elsif roi1_is_in then
        if unsigned(o_data0) > unsigned(roi_tox_rec.roi1_max) then
          roi_tox_rec.roi1_max <= o_data0;
        end if;
        if unsigned(o_data0) < unsigned(roi_tox_rec.roi1_min) then
          roi_tox_rec.roi1_min <= o_data0;
        end if;
        roi_tox_rec.roi1_sum <= std_logic_vector(to_unsigned(to_integer(unsigned(roi_tox_rec.roi1_sum)) + to_integer(unsigned(o_data0)), roi_tox_rec.roi1_sum'length));
      end if;
    end if;
  end process;

end rtl;


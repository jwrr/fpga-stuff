--------------------------------------------------------------------------------
-- Block: roi_select
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

entity roi_select is
generic (
  CLEN : integer := 9;
  RLEN : integer := 8;
  DLEN : integer := 16;
  SLEN : integer := 32
);
port (
  fromx_roi_rec : in  fromx_roi_record;
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
end roi_select;

architecture rtl of roi_select is

  signal roi_center_done   : std_logic;
  signal roi_minmax_done   : std_logic;
  signal roi_select_done   : std_logic;
  signal roi_center_is_in  : std_logic;
  signal roi_minmax_is_in  : std_logic;
  signal roi_select_is_in  : std_logic;
  signal data0       : std_logic_vector(DLEN-1 downto 0);
  signal data1       : std_logic_vector(DLEN-1 downto 0);

begin

  u_roi_is_in: entity work.roi_is_in
  generic map (
    CLEN => CLEN,
    RLEN => RLEN,
    DLEN => DLEN
  )
  port map (
    fromx_roi_rec       => fromx_roi_rec,
    i_clk               => i_clk,            --  in  std_logic;
    i_rst               => i_rst,            --  in  std_logic;
    i_fsync             => i_fsync,          --  in  std_logic;
    i_lsync             => i_lsync,          --  in  std_logic;
    i_dval              => i_dval,           --  in  std_logic;
    i_data0             => i_data0,          --  in  std_logic_vector(DLEN-1 downto 0);
    i_data1             => i_data1,          --  in  std_logic_vector(DLEN-1 downto 0);
    o_roi_center_is_in  => roi_center_is_in, --  out std_logic;
    o_roi_minmax_is_in  => roi_minmax_is_in, --  out std_logic;
    o_roi_select_is_in  => roi_select_is_in, --  out std_logic;
    o_fsync             => o_fsync,          --  out std_logic;
    o_lsync             => o_lsync,          --  out std_logic;
    o_dval              => o_dval,           --  out std_logic;
    o_roi_center_done   => roi_center_done,  --  out std_logic;
    o_roi_minmax_done   => roi_minmax_done,  --  out std_logic;
    o_roi_select_done   => roi_select_done,  --  out std_logic;
    o_data0             => data0,            --  out std_logic_vector(DLEN-1 downto 0);
    o_data1             => data1             --  out std_logic_vector(DLEN-1 downto 0);
  );

  o_data0 <= data0 when roi_select_is_in = '1' else data1;
  o_data1 <= data1 when roi_select_is_in = '1' else data0;

end rtl;


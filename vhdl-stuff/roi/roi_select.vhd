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

entity roi_select is
generic (
  CLEN : integer := 9;
  RLEN : integer := 8;
  DLEN : integer := 16;
  SLEN : integer := 32
);
port (
  i_clk     : in  std_logic;
  i_rst     : in  std_logic;
  i_fsync   : in  std_logic;
  i_lsync   : in  std_logic;
  i_dval    : in  std_logic;
  i_data0   : in  std_logic_vector(DLEN-1 downto 0);
  i_data1   : in  std_logic_vector(DLEN-1 downto 0);
  i_roi0_r0 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi0_c0 : in  std_logic_vector(CLEN-1 downto 0);
  i_roi0_r1 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi0_c1 : in  std_logic_vector(CLEN-1 downto 0);
  i_roi1_r0 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi1_c0 : in  std_logic_vector(CLEN-1 downto 0);
  i_roi1_r1 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi1_c1 : in  std_logic_vector(CLEN-1 downto 0);

  o_fsync    : out std_logic;
  o_lsync    : out std_logic;
  o_dval     : out std_logic;
  o_data0    : out std_logic_vector(DLEN-1 downto 0);
  o_data1    : out std_logic_vector(DLEN-1 downto 0)
);
end roi_select;

architecture rtl of roi_select is

  signal roi0_done   : std_logic;
  signal roi1_done   : std_logic;
  signal roi0_is_in  : std_logic;
  signal roi1_is_in  : std_logic;
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
    i_clk          => i_clk,      --  in  std_logic;
    i_rst          => i_rst,      --  in  std_logic;
    i_fsync        => i_fsync,    --  in  std_logic;
    i_lsync        => i_lsync,    --  in  std_logic;
    i_dval         => i_dval,     --  in  std_logic;
    i_data0        => i_data0,    --  in  std_logic_vector(DLEN-1 downto 0);
    i_data1        => i_data1,    --  in  std_logic_vector(DLEN-1 downto 0);
    i_roi0_r0      => i_roi0_r0,  --  in  std_logic_vector(RLEN-1 downto 0);
    i_roi0_c0      => i_roi0_c0,  --  in  std_logic_vector(CLEN-1 downto 0);
    i_roi0_r1      => i_roi0_r1,  --  in  std_logic_vector(RLEN-1 downto 0);
    i_roi0_c1      => i_roi0_c1,  --  in  std_logic_vector(CLEN-1 downto 0);
    i_roi1_r0      => i_roi1_r0,  --  in  std_logic_vector(RLEN-1 downto 0);
    i_roi1_c0      => i_roi1_c0,  --  in  std_logic_vector(CLEN-1 downto 0);
    i_roi1_r1      => i_roi1_r1,  --  in  std_logic_vector(RLEN-1 downto 0);
    i_roi1_c1      => i_roi1_c1,  --  in  std_logic_vector(CLEN-1 downto 0);
    o_roi0_is_in   => roi0_is_in, --  out std_logic;
    o_roi1_is_in   => roi1_is_in, --  out std_logic;
    o_fsync        => o_fsync,    --  out std_logic;
    o_lsync        => o_lsync,    --  out std_logic;
    o_dval         => o_dval,     --  out std_logic;
    o_roi0_done    => roi0_done,  --  out std_logic;
    o_roi1_done    => roi1_done,  --  out std_logic;
    o_data0        => data0,      --  out std_logic_vector(DLEN-1 downto 0);
    o_data1        => data1       --  out std_logic_vector(DLEN-1 downto 0);
  );

  o_data0 <= data0 when roi0_is_in = '1' else data1;
  o_data1 <= data1 when roi0_is_in = '1' else data0;

end rtl;


--------------------------------------------------------------------------------
-- Name : roi_pkg
-- Description:
-- This package ...
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

package roi_pkg is

  constant CLEN : integer := 10; -- Num bits in Column counter
  constant RLEN : integer := 9;  -- Num bits in Row counter
  constant DLEN : integer := 16; -- Num bits in Data Bus
  constant SLEN : integer := 32; -- Num bits in Sum

  type fromx_roi_record is record
    roi_center_r0 : std_logic_vector(RLEN-1 downto 0);
    roi_center_c0 : std_logic_vector(CLEN-1 downto 0);
    roi_center_r1 : std_logic_vector(RLEN-1 downto 0);
    roi_center_c1 : std_logic_vector(CLEN-1 downto 0);
    roi_minmax_r0 : std_logic_vector(RLEN-1 downto 0);
    roi_minmax_c0 : std_logic_vector(CLEN-1 downto 0);
    roi_minmax_r1 : std_logic_vector(RLEN-1 downto 0);
    roi_minmax_c1 : std_logic_vector(CLEN-1 downto 0);
    roi_select_r0 : std_logic_vector(RLEN-1 downto 0);
    roi_select_c0 : std_logic_vector(CLEN-1 downto 0);
    roi_select_r1 : std_logic_vector(RLEN-1 downto 0);
    roi_select_c1 : std_logic_vector(CLEN-1 downto 0);
  end record;

  type roi_tox_record is record
    roi_center_max : std_logic_vector(DLEN-1 downto 0);
    roi_center_min : std_logic_vector(DLEN-1 downto 0);
    roi_center_sum : std_logic_vector(SLEN-1 downto 0);
    roi_minmax_max : std_logic_vector(DLEN-1 downto 0);
    roi_minmax_min : std_logic_vector(DLEN-1 downto 0);
    roi_minmax_sum : std_logic_vector(SLEN-1 downto 0);
    roi_select_max : std_logic_vector(DLEN-1 downto 0);
    roi_select_min : std_logic_vector(DLEN-1 downto 0);
    roi_select_sum : std_logic_vector(SLEN-1 downto 0);
  end record;
end package;


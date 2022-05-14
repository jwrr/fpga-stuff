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
    roi0_r0 : std_logic_vector(RLEN-1 downto 0);
    roi0_c0 : std_logic_vector(CLEN-1 downto 0);
    roi0_r1 : std_logic_vector(RLEN-1 downto 0);
    roi0_c1 : std_logic_vector(CLEN-1 downto 0);
    roi1_r0 : std_logic_vector(RLEN-1 downto 0);
    roi1_c0 : std_logic_vector(CLEN-1 downto 0);
    roi1_r1 : std_logic_vector(RLEN-1 downto 0);
    roi1_c1 : std_logic_vector(CLEN-1 downto 0);
  end record;

  type roi_tox_record is record
    roi0_max : std_logic_vector(DLEN-1 downto 0);
    roi0_min : std_logic_vector(DLEN-1 downto 0);
    roi0_sum : std_logic_vector(SLEN-1 downto 0);
    roi1_max : std_logic_vector(DLEN-1 downto 0);
    roi1_min : std_logic_vector(DLEN-1 downto 0);
    roi1_sum : std_logic_vector(SLEN-1 downto 0);
  end record;
end package;


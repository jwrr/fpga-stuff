--------------------------------------------------------------------------------
-- Description:
--   This package provides useful procedures and functions to simplify writing
--   tests.
--
--------------------------------------------------------------------------------
-- library std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library work;


package video_line_buffer_package is
  type video_line_buffer_array is array(integer range <>) of std_logic_vector(7 downto 0);
end package;

package body video_line_buffer_package is
end package body;

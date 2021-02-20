--------------------------------------------------------------------------------
-- Block: gater
-- Description:
-- This block allows data to pass when the start signal asserts, and drives
-- zeroes when the stop pulse asserts. a rising-edge on the arm input arms
-- gater to look for the next start pulse.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity gater is
  generic (
    WIDTH : integer := 8
  );
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    arm    : in  std_logic;  -- typically a pulse, rising-edge active
    start  : in  std_logic;  -- typically a pulse. data is valid when and after this is asserted
    stop   : in  std_logic;  -- typically a pulse. data is zero when and after this is asserted
    d      : in  std_logic_vector(WIDTH-1 downto 0);
    q      : out std_logic_vector(WIDTH-1 downto 0)
  );
end gater;

architecture rtl of gater is
  signal arm_cdc     : std_logic_vector(2 downto 0);
  signal armed       : std_logic;
  signal enabled     : std_logic;
  signal enabled_reg : std_logic;
  signal start2      : std_logic;
  signal start_edge  : std_logic;
  signal stop2       : std_logic;
  signal stop_edge   : std_logic;
begin

  start_edge <= start and not start2;
  stop_edge <= stop and not stop2;
  enabled <= armed when start_edge else enabled_reg;

  process (clk, rst)
  begin
    if rst then
      arm_cdc <= (others => '0');
      q <= (others => '0');
      armed <= '0';
      start2 <= '0';
      stop2 <= '0';
      enabled_reg <= '0';
    elsif rising_edge(clk) then
      start2 <= start;
      stop2 <= stop;
      arm_cdc <= arm_cdc(1 downto 0) & arm;
      if arm_cdc(2 downto 1) = "01" then
        armed <= '1';
      elsif start_edge and not enabled_reg then
        armed <= '0';
        enabled_reg <= armed;
      elsif stop_edge then
        enabled_reg <= '0';
      end if;
      
      if enabled then
        q <= d;
      else
        q <= (others => '0');
      end if;
      
    end if;
  end process;

end rtl;



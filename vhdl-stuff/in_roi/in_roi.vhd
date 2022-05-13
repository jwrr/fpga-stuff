--------------------------------------------------------------------------------
-- Block: in_roi
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

entity in_roi is
generic (
  CLEN : integer := 9;
  RLEN : integer := 8;
  DLEN : integer := 16
);
port (
  i_clk     : in  std_logic;
  i_rst     : in  std_logic;
  i_fsync   : in  std_logic;
  i_lsync   : in  std_logic;
  i_dval    : in  std_logic;
  i_data    : in  std_logic_vector(DLEN-1 downto 0);
  i_roi0_r0 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi0_c0 : in  std_logic_vector(CLEN-1 downto 0);
  i_roi0_r1 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi0_c1 : in  std_logic_vector(CLEN-1 downto 0);
  i_roi1_r0 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi1_c0 : in  std_logic_vector(CLEN-1 downto 0);
  i_roi1_r1 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi1_c1 : in  std_logic_vector(CLEN-1 downto 0);
  o_in_roi0 : out std_logic;
  o_in_roi1 : out std_logic;
  o_fsync   : out std_logic;
  o_lsync   : out std_logic;
  o_dval    : out std_logic;
  o_data    : out std_logic_vector(DLEN-1 downto 0)
);
end in_roi;

architecture rtl of in_roi is
  signal row  : unsigned(RLEN-1 downto 0);
  signal col  : unsigned(CLEN-1 downto 0);

  signal roi0_r0 : unsigned(RLEN-1 downto 0);
  signal roi0_c0 : unsigned(CLEN-1 downto 0);
  signal roi0_r1 : unsigned(RLEN-1 downto 0);
  signal roi0_c1 : unsigned(CLEN-1 downto 0);
  signal roi1_r0 : unsigned(RLEN-1 downto 0);
  signal roi1_c0 : unsigned(CLEN-1 downto 0);
  signal roi1_r1 : unsigned(RLEN-1 downto 0);
  signal roi1_c1 : unsigned(CLEN-1 downto 0);

  signal fsync   : std_logic;
  signal lsync   : std_logic;
  signal dval    : std_logic;
  signal data    : std_logic_vector(DLEN-1 downto 0);

  signal in_roi0 : std_logic;
  signal in_roi1 : std_logic;

begin

  process (i_clk, i_rst)
  begin
    if i_rst then
      row     <= (others => '0');
      col     <= (others => '0');
      roi0_r0 <= (others => '0');
      roi0_c0 <= (others => '0');
      roi0_r1 <= (others => '0');
      roi0_c1 <= (others => '0');
      roi1_r0 <= (others => '0');
      roi1_c0 <= (others => '0');
      roi1_r1 <= (others => '0');
      roi1_c1 <= (others => '0');
      o_fsync <= '0';
      o_lsync <= '0';
      o_dval  <= '0';
      o_in_roi0 <= '0';
      o_in_roi1 <= '0';
    elsif rising_edge(i_clk) then

      -- allow roi to update on frame boundary
      if i_fsync and i_dval then
        roi0_r0 <= unsigned(i_roi0_r0);
        roi0_c0 <= unsigned(i_roi0_c0);
        roi0_r1 <= unsigned(i_roi0_r1);
        roi0_c1 <= unsigned(i_roi0_c1);
        roi1_r0 <= unsigned(i_roi1_r0);
        roi1_c0 <= unsigned(i_roi1_c0);
        roi1_r1 <= unsigned(i_roi1_r1);
        roi1_c1 <= unsigned(i_roi1_c1);
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

      fsync <= i_fsync;
      lsync <= i_lsync;
      dval  <= i_dval;

      -- check if counters are in range

      if (row >= roi0_r0) and (row < roi0_r1) and
         (col >= roi0_c0) and (col < roi0_c1)
      then
        o_in_roi0 <= '1';
      else
        o_in_roi0 <= '0';
      end if;

      if (row >= roi1_r0) and (row < roi1_r1) and
         (col >= roi1_c0) and (col < roi1_c1)
      then
        o_in_roi1 <= '1';
      else
        o_in_roi1 <= '0';
      end if;

      o_fsync <= fsync;
      o_lsync <= lsync;
      o_dval  <= dval;

    end if;
  end process;

end rtl;


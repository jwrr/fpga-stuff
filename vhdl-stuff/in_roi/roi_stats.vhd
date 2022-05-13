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

entity roi_stats is
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
  i_data    : in  std_logic_vector(DLEN-1 downto 0);
  i_roi0_r0 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi0_c0 : in  std_logic_vector(CLEN-1 downto 0);
  i_roi0_r1 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi0_c1 : in  std_logic_vector(CLEN-1 downto 0);
  i_roi1_r0 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi1_c0 : in  std_logic_vector(CLEN-1 downto 0);
  i_roi1_r1 : in  std_logic_vector(RLEN-1 downto 0);
  i_roi1_c1 : in  std_logic_vector(CLEN-1 downto 0);

  o_roi0_max : out std_logic_vector(DLEN-1 downto 0);
  o_roi0_min : out std_logic_vector(DLEN-1 downto 0);
  o_roi0_sum : out std_logic_vector(SLEN-1 downto 0);
  o_roi1_max : out std_logic_vector(DLEN-1 downto 0);
  o_roi1_min : out std_logic_vector(DLEN-1 downto 0);
  o_roi1_sum : out std_logic_vector(SLEN-1 downto 0);

  o_fsync    : out std_logic;
  o_lsync    : out std_logic;
  o_dval     : out std_logic;
  o_data     : out std_logic_vector(DLEN-1 downto 0)
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
    i_clk          => i_clk,      --  in  std_logic;
    i_rst          => i_rst,      --  in  std_logic;
    i_fsync        => i_fsync,    --  in  std_logic;
    i_lsync        => i_lsync,    --  in  std_logic;
    i_dval         => i_dval,     --  in  std_logic;
    i_data         => i_data,     --  in  std_logic_vector(DLEN-1 downto 0);
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
    o_roi0_done    => open,       --  out std_logic;
    o_roi1_done    => open,       --  out std_logic;
    o_data         => o_data    --  out std_logic_vector(DLEN-1 downto 0);
  );


  process (i_clk, i_rst)
  begin
    if i_rst then
      o_roi0_max <= (others => '0');
      o_roi0_min <= (others => '0');
      o_roi0_sum <= (others => '0');
    elsif rising_edge(i_clk) then
      if i_fsync then
        o_roi0_max <= (others => '0');
        o_roi0_min <= (others => '1');
        o_roi0_sum <= (others => '0');
      elsif roi0_is_in then
        if unsigned(o_data) > unsigned(o_roi0_max) then
          o_roi0_max <= o_data;
        end if;
        if unsigned(o_data) < unsigned(o_roi0_min) then
          o_roi0_min <= o_data;
        end if;
        o_roi0_sum <= std_logic_vector(to_unsigned(to_integer(unsigned(o_roi0_sum)) + to_integer(unsigned(o_data)), o_roi0_sum'length));
      end if;
    end if;
  end process;


  process (i_clk, i_rst)
  begin
    if i_rst then
      o_roi1_max <= (others => '0');
      o_roi1_min <= (others => '0');
      o_roi1_sum <= (others => '0');
    elsif rising_edge(i_clk) then
      if i_fsync then
        o_roi1_max <= (others => '0');
        o_roi1_min <= (others => '1');
        o_roi1_sum <= (others => '0');
      elsif roi1_is_in then
        if unsigned(o_data) > unsigned(o_roi1_max) then
          o_roi1_max <= o_data;
        end if;
        if unsigned(o_data) < unsigned(o_roi1_min) then
          o_roi1_min <= o_data;
        end if;
        o_roi1_sum <= std_logic_vector(to_unsigned(to_integer(unsigned(o_roi1_sum)) + to_integer(unsigned(o_data)), o_roi1_sum'length));
      end if;
    end if;
  end process;

end rtl;


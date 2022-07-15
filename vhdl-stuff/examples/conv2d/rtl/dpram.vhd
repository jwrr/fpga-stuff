
--------------------------------------------------------------------------------
-- Block:
-- Description:
-- This block ...
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity dpram is
generic (
  DEPTH    : integer := 1024;
  AWIDTH   : integer := 10; -- integer(ceil(log2(real(DEPTH))));
  DWIDTH   : integer := 16;
  LATENCY  : integer := 1;
  INITFILE : string  := ""
);
port (
  i_clk_write  : in  std_logic;
  i_rst_write  : in  std_logic;
  i_write      : in  std_logic;
  i_waddr      : in  std_logic_vector( AWIDTH-1 downto 0);
  i_wdata      : in  std_logic_vector( DWIDTH-1 downto 0);

  i_clk_read   : in  std_logic;
  i_rst_read   : in  std_logic;
  i_read       : in  std_logic;
  i_raddr      : in  std_logic_vector( AWIDTH-1 downto 0);
  o_rdata      : out std_logic_vector( DWIDTH-1 downto 0);
  o_rdata_v    : out std_logic
);
end dpram;

architecture rtl of dpram is
  type ram_t is array(0 to DEPTH-1) of std_logic_vector( DWIDTH-1 downto 0);
  signal ram_array : ram_t;
begin

  process (i_clk_read, i_rst_read)
  begin
    if i_rst_read = '1' then
      o_rdata <= (others => '0');
      o_rdata_v <= '0';
    elsif rising_edge(i_clk_read) then
      o_rdata_v <= i_read;
      if i_read = '1' then
        o_rdata <= ram_array( to_integer(unsigned(i_raddr)) );
      end if;
    end if;
  end process;

  process (i_clk_write)
  begin
    if rising_edge(i_clk_write) then
      if i_write = '1' then
        ram_array( to_integer(unsigned(i_waddr)) ) <= i_wdata;
      end if;
    end if;
  end process;

end rtl;


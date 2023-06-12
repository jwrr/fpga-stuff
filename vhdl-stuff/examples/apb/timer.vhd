
--------------------------------------------------------------------------------
-- Block: timer
-- Description:
-- This block implements a timer. The timer starts on apb write and
-- stops when timer reaches 0. When it reaches zero it generates an interrupt pulse
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity timer is
generic (
  PADDR_WIDTH   : integer := 16;
  PDATA_WIDTH   : integer := 32
);
port (
  i_apb_clk      : in   std_logic;
  i_apb_presetn  : in   std_logic;
  i_apb_paddr    : in   std_logic_vector(PADDR_WIDTH-1 downto 0);
  i_apb_penable  : in   std_logic;
  i_apb_pwdata   : in   std_logic_vector(PDATA_WIDTH-1 downto 0);
  i_apb_pwrite   : in   std_logic;
  i_apb_psel     : in   std_logic;
  o_apb_pready   : out  std_logic;
  o_apb_prdata   : out  std_logic_vector(PDATA_WIDTH-1 downto 0);
  o_apb_pslverr  : out  std_logic;
  o_interrupt    : out  std_logic
);
end timer;

architecture rtl of timer is
  signal cnt       : unsigned(i_apb_pwdata'range);
  signal reg       : unsigned(i_apb_pwdata'range);
  signal interrupt : std_logic;
  signal decr      : std_logic;
  signal wrap      : std_logic;
begin

  decr <= '1' when cnt(PDATA_WIDTH-2 downto 0) /= 0 else '0';
  interrupt <= '1' when cnt(PDATA_WIDTH-2 downto 0) = 0 else '0';
  wrap <= '1' when cnt(PDATA_WIDTH-2 downto 0) = 0 and cnt(PDATA_WIDTH-1) = '1' else '0';

  o_apb_pready  <= '1';
  o_apb_pslverr <= '0';
  o_apb_prdata <= std_logic_vector(reg) when unsigned(i_apb_paddr(1 downto 0)) = 0 else
                  std_logic_vector(cnt); --  when unsigned(i_apb_paddr(1 downto 0)) = 4 else 
  
  process (i_apb_clk, i_apb_presetn)
  begin
    if i_apb_presetn = '0' then
      cnt <= (others => '0');
      reg <= (others => '0');
    elsif rising_edge(i_apb_clk) then
      
      if i_apb_pwrite then
        cnt <= unsigned(i_apb_pwdata);
        reg <= unsigned(i_apb_pwdata);
      elsif decr then
        cnt <= cnt - 1;
      elsif wrap then
        cnt <= reg;
      end if;
      
      o_interrupt <= interrupt;
          
    end if;
  end process;

end rtl;



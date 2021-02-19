--------------------------------------------------------------------------------
-- Block: fifo
-- Description:
-- This block implements a FIFO.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
library work;

entity fifo is
generic (
  DEPTH : integer := 16;
  WIDTH        : integer := 16;
  SAME_CLK     : boolean := false
);
port (
  clk_write  : in  std_logic;
  rst_write  : in  std_logic;
  i_write    : in  std_logic;
  i_wdata    : in  std_logic_vector(WIDTH-1 downto 0);
  o_wff      : out std_logic;

  clk_read   : in  std_logic;
  rst_read   : in  std_logic;
  i_read     : in  std_logic;
  o_rdata    : out std_logic_vector(WIDTH-1 downto 0);
  o_ref      : out std_logic;
  o_rlast    : out std_logic
);
end fifo;
    -- here i am.
architecture rtl of fifo is
  constant AWIDTH    : integer := integer(ceil(log2(real(DEPTH))));
  signal waddr       : std_logic_vector(AWIDTH-1 downto 0);
  signal waddr_next1 : std_logic_vector(AWIDTH-1 downto 0);
  signal waddr_next2 : std_logic_vector(AWIDTH-1 downto 0);
  signal wff1        : std_logic;
  signal wff2        : std_logic;
  signal write       : std_logic;
  signal raddr       : std_logic_vector(AWIDTH-1 downto 0);
  signal waddr_gray  : std_logic_vector(AWIDTH-1 downto 0);
  signal raddr_gray  : std_logic_vector(AWIDTH-1 downto 0);
  signal waddr_bin   : std_logic_vector(AWIDTH-1 downto 0);
  signal raddr_bin   : std_logic_vector(AWIDTH-1 downto 0);
  signal ef          : std_logic;
  signal read        : std_logic;
begin


  u_dpram: entity work.dpram
  generic map (
    DEPTH         => DEPTH,
    AWIDTH        => AWIDTH,
    DWIDTH        => WIDTH
  )
  port map (
    i_clk_write   => clk_write,       -- in  std_logic;
    i_rst_write   => rst_write,       -- in  std_logic;
    i_write       => i_write,         -- in  std_logic;
    i_waddr       => waddr,           -- in  std_logic_vector( AWIDTH-1 downto 0);
    i_wdata       => i_wdata,         -- in  std_logic_vector( DWIDTH-1 downto 0);

    i_clk_read    => clk_read,        -- in  std_logic;
    i_rst_read    => rst_read,        -- in  std_logic;
    i_read        => i_read,          -- in  std_logic;
    i_raddr       => raddr,           -- in  std_logic_vector( AWIDTH-1 downto 0);
    o_rdata       => o_rdata,         -- out std_logic_vector( DWIDTH-1 downto 0);
    o_rdata_v     => open             -- out std_logic
  );

  write <= i_write and not wff1;
  u_counter_waddr: entity work.counter
  generic map (
    WIDTH         => AWIDTH,
    WRAP_AT       => DEPTH-1
  )
  port map (
    clk           => clk_write,       -- in  std_logic;
    rst           => rst_write,       -- in  std_logic;
    i_clr         => '0',             -- in  std_logic;
    i_enable      => write,           -- in  std_logic;
    o_cnt         => waddr            -- out std_logic_vector(WIDTH-1 downto 0)
  );


  gen_waddr_bin: if SAME_CLK generate
  
    waddr_bin <= waddr;

  else generate
    -- different read and write clocks. use gray code for Clock Domain Crossing (CDC)
    u_cdc_bin2gray_waddr: entity work.cdc_bin2gray
    generic map (
      WIDTH         => AWIDTH
    )
    port map (
      clk           => clk_write,       -- in  std_logic;
      rst           => rst_write,       -- in  std_logic;
      i_bin         => waddr,           -- in  std_logic_vector(WIDTH-1 downto 0);
      o_gray        => waddr_gray       -- out std_logic_vector(WIDTH-1 downto 0)
    );

    u_cdc_gray2bin_waddr: entity work.cdc_gray2bin
    generic map (
      WIDTH         => AWIDTH
    )
    port map (
      clk           => clk_read,        -- in  std_logic;
      rst           => rst_read,        -- in  std_logic;
      i_gray        => waddr_gray,      -- in  std_logic_vector(WIDTH-1 downto 0);
      o_bin         => waddr_bin -- out std_logic_vector(WIDTH-1 downto 0)
    );
  
  end generate;


  read <= i_read and not ef;
  u_counter_raddr: entity work.counter
  generic map (
    WIDTH         => AWIDTH,
    WRAP_AT       => DEPTH-1
  )
  port map (
    clk           => clk_read,        -- in  std_logic;
    rst           => rst_read,        -- in  std_logic;
    i_clr         => '0',             -- in  std_logic;
    i_enable      => read,            -- in  std_logic;
    o_cnt         => raddr            -- out std_logic_vector(WIDTH-1 downto 0)
  );

  gen_raddr_bin: if SAME_CLK generate

    raddr_bin <= raddr;
    
  else generate
    u_cdc_bin2gray_raddr: entity work.cdc_bin2gray
    generic map (
      WIDTH         => AWIDTH
    )
    port map (
      clk           => clk_read,        -- in  std_logic;
      rst           => rst_read,        -- in  std_logic;
      i_bin         => raddr,           -- in  std_logic_vector(WIDTH-1 downto 0);
      o_gray        => raddr_gray       -- out std_logic_vector(WIDTH-1 downto 0)
    );
  
    u_cdc_gray2bin_raddr: entity work.cdc_gray2bin
    generic map (
      WIDTH         => AWIDTH
    )
    port map (
      clk           => clk_read,        -- in  std_logic;
      rst           => rst_read,        -- in  std_logic;
      i_gray        => raddr_gray,      -- in  std_logic_vector(WIDTH-1 downto 0);
      o_bin         => raddr_bin -- out std_logic_vector(WIDTH-1 downto 0)
    );

  end generate;
  
  ef <= '1' when raddr = waddr_bin else '0';
  o_rlast <= ef;

  process (clk_read, rst_read)
  begin
    if (rst_read = '1') then
      o_ref <= '1';
    elsif rising_edge(clk_read) then
      o_ref <= ef;
    end if;
  end process;

  waddr_next1 <= std_logic_vector( unsigned(waddr) + 1);
  waddr_next2 <= std_logic_vector( unsigned(waddr) + 2);
  wff1 <= '1' when waddr_next1 = raddr_bin else '0';
  wff2 <= '1' when waddr_next2 = raddr_bin else '0';
  o_wff <= wff1 or wff2;


end rtl;



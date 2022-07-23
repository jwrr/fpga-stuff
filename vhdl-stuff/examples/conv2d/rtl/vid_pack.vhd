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

use ieee.math_real.log2;
use ieee.math_real.ceil;


--  Clocks Per Pixel        :
--  Horizontal Sync:         120 Pixels, 1.11782 usec; (line 38)
--  Horizontal Back Porch:   240 Pixels, 2.23564 usec; (line 38)
--  Horizontal Active:       1280 Pixels, 11.9234 usec; (line 38)
--  Horizontal Front Porch:  40 Pixels, 372.606 nsec; (line 38)
--  Field Information:
--   Field Duration:           1.7892e+06 Pixels, 1065 Lines, 16.667 msec; (line 0)
--   Vertical Sync:            5040 Pixels, 3 Lines, 46.9484 usec; (line 0)
--   Vertical Sync Pulse:      5160 Pixels, 3.07143 Lines, 48.0662 usec; (line 0)
--   Vertical Back Porch:      58800 Pixels, 35 Lines, 547.731 usec; (line 3)
--   Vertical Active:          1.72e+06 Pixels, 1024 Lines, 16.025 msec; (line 38)
--   Vertical Front Porch:     5040 Pixels, 3 Lines, 46.9484 usec; (line 1062)


package vid_pack is

  constant BPP     : natural := 8;   -- Bits Per Pixel
  constant CPP     : natural := 4;   -- Clocks Per Pixel
  constant HSYNC   : natural := 1;   -- 1 pixel
  constant HBPORCH : natural := 9;  
  constant HACTIVE : natural := 20;
  constant HFPORCH : natural := 10;
  constant VSYNC   : natural := 1;   -- 1 line
  constant VBPORCH : natural := 9;
  constant VACTIVE : natural := 20;
  constant VFPORCH : natural := 10;

  constant FRAME_WIDTH   : natural := HSYNC + HBPORCH + HACTIVE + HFPORCH;
  constant FRAME_HEIGHT  : natural := VSYNC + VBPORCH + VACTIVE + VFPORCH;
  constant ACTIVE_HSTART : natural := HSYNC + HBPORCH;
  constant ACTIVE_HSTOP  : natural := ACTIVE_HSTART + HACTIVE - 1;
  constant ACTIVE_WIDTH  : natural := HACTIVE;
  constant ACTIVE_VSTART : natural := VSYNC + VBPORCH;
  constant ACTIVE_VSTOP  : natural := ACTIVE_VSTART + VACTIVE - 1;
  constant ACTIVE_HEIGHT : natural := VACTIVE;
  constant F_HCNT_LEN : natural := integer(ceil(log2(real(FRAME_WIDTH))));
  constant F_VCNT_LEN : natural := integer(ceil(log2(real(FRAME_HEIGHT))));
  constant A_HCNT_LEN : natural := integer(ceil(log2(real(HACTIVE))));
  constant A_VCNT_LEN : natural := integer(ceil(log2(real(VACTIVE))));
  constant KSIZE      : natural := 5;

  type array_of_slv is array(integer range <>) of std_logic_vector(BPP-1 downto 0);
  type array_of_unsigned is array(integer range <>) of unsigned(BPP-1 downto 0);

  type vport is record
    active_v       : std_logic;
    frame_v        : std_logic;
    line_v         : std_logic;
    line_early_v   : std_logic;
    pix_v          : std_logic;
    pix            : unsigned(BPP-1 downto 0);
    pix_cnt        : unsigned(3 downto 0);
    frame_hcnt_early : unsigned(F_HCNT_LEN-1 downto 0);
    frame_hcnt       : unsigned(F_HCNT_LEN-1 downto 0);
    frame_vcnt     : unsigned(F_VCNT_LEN-1 downto 0);
    frame_sof      : std_logic;
    frame_sol      : std_logic;
    frame_eof      : std_logic;
    frame_eol      : std_logic;
    frame_pix_v    : std_logic;
    frame_eopix_v  : std_logic;
    frame_early_eopix_v  : std_logic;
    active_hcnt    : unsigned(A_HCNT_LEN-1 downto 0);
    active_vcnt    : unsigned(A_VCNT_LEN-1 downto 0);
    is_active      : std_logic;
    active_sof     : std_logic;
    active_eof     : std_logic;
    active_sol     : std_logic;
    active_eol     : std_logic;
    inactive_sol   : std_logic;
    inactive_eol   : std_logic;
  end record vport;

  function to_array_of_unsigned(aslv : array_of_slv) return array_of_unsigned;
  function to_array_of_slv(au : array_of_unsigned) return array_of_slv;
  function sl(i_bool : boolean) return std_logic;

  function vport_reset return vport;
  function vport_incr(i_vp : vport) return vport;
  function vport_update(i_vp : vport; new_pix : unsigned(BPP-1 downto 0)) return vport;

--   function shift_window(i_win : array_of_unsigned(0 to KSIZE*KSIZE-1); col_array : array_of_unsigned(0 to KSIZE-1)) return array_of_unsigned;
  function shift_window(i_win : array_of_unsigned; col_array : array_of_unsigned) return array_of_unsigned;

end package;




package body vid_pack is

  function shift_window(i_win : array_of_unsigned; col_array : array_of_unsigned) return array_of_unsigned is
    variable o_win : array_of_unsigned(i_win'range);
  begin
    for ii in i_win'range loop
      if ii < col_array'length then
        o_win(ii) := col_array(ii);
      else
        o_win(ii) := i_win(ii-col_array'length);
      end if;
    end loop;
    return o_win;
  end function shift_window;



  function to_array_of_unsigned(aslv : array_of_slv) return array_of_unsigned is
    variable au : array_of_unsigned(aslv'range);
  begin
    for ii in 0 to aslv'high loop
      au(ii) := unsigned(aslv(ii));
    end loop;
    return au;
  end function to_array_of_unsigned;

  function to_array_of_slv(au : array_of_unsigned) return array_of_slv is
    variable aslv : array_of_slv(au'range);
  begin
    for ii in 0 to au'high loop
      aslv(ii) := std_logic_vector(au(ii));
    end loop;
    return aslv;
  end function to_array_of_slv;

  function sl(i_bool : boolean) return std_logic is
    variable o_sl : std_logic;
  begin
    o_sl := '1' when i_bool else '0';
    return o_sl;
  end function sl;

  function vport_reset return vport is
    variable o_frame : vport;
  begin
    o_frame.frame_v      := '0';
    o_frame.line_v       := '0';
    o_frame.line_early_v := '0';
    o_frame.active_v     := '0';
    o_frame.pix_v        := '0';
    o_frame.frame_pix_v  := '0';
    o_frame.frame_eopix_v  := '0';
    o_frame.frame_early_eopix_v  := '0';
    o_frame.pix          := (others => '0');
    o_frame.frame_hcnt_early        := (others => '0');   -- unsigned(F_HCNT_LEN-1 downto 0);
    o_frame.frame_hcnt              := (others => '0');   -- unsigned(F_HCNT_LEN-1 downto 0);
    o_frame.frame_vcnt   := (others => '0');   -- unsigned(F_VCNT_LEN-1 downto 0);
    o_frame.frame_sof    := '1';               -- std_logic;
    o_frame.frame_sol    := '1';               -- std_logic;
    o_frame.frame_eof    := '0';               -- std_logic;
    o_frame.frame_eol    := '0';               -- std_logic;
    o_frame.is_active    := '0';               -- std_logic;
    o_frame.active_hcnt  := (others => '0');   -- unsigned(A_HCNT_LEN-1 downto 0);
    o_frame.active_vcnt  := (others => '0');   -- unsigned(A_VCNT_LEN-1 downto 0);
    o_frame.active_sof   := '0';               -- std_logic;
    o_frame.active_eof   := '0';               -- std_logic;
    o_frame.active_sol   := '0';               -- std_logic;
    o_frame.active_eol   := '0';               -- std_logic;
    o_frame.inactive_sol := '1';               -- std_logic;
    o_frame.inactive_eol := '0';               -- std_logic;
    o_frame.pix_cnt      := (others => '0');   -- unsigned(CPP-1 downto 0);
    return o_frame;
  end function vport_reset;


  function vport_update(i_vp : vport; new_pix : unsigned(BPP-1 downto 0)) return vport is
    variable o_vp : vport;
  begin
    o_vp := i_vp;
    o_vp.pix := new_pix;
    return o_vp;
  end function vport_update;
  

  function vport_incr(i_vp : vport) return vport is
    variable o_vp        : vport;
    variable var_hactive : boolean;
    variable var_hactive_early : boolean;
    variable var_vactive : boolean;
    variable var_active  : boolean;
    variable var_active_early  : boolean;
    variable var_frame_pix_v : boolean;
    variable var_frame_eopix_v : boolean;
    variable var_frame_early_eopix_v : boolean;
    variable var_pix_v   : boolean;
  begin
    
    o_vp := i_vp;

    var_frame_pix_v   := i_vp.pix_cnt = 0;
    var_frame_eopix_v := i_vp.pix_cnt = CPP-1;
    var_frame_early_eopix_v := i_vp.pix_cnt = CPP-2;
    if (CPP = 1) then
      o_vp.pix_cnt := (others => '0');
    elsif i_vp.pix_cnt = CPP-1 then
      o_vp.pix_cnt := (others => '0');
    else
      o_vp.pix_cnt := i_vp.pix_cnt + 1;
    end if;

    o_vp.frame_pix_v := sl(var_frame_pix_v);
    o_vp.frame_eopix_v := sl(var_frame_eopix_v);
    o_vp.frame_early_eopix_v := sl(var_frame_early_eopix_v);
    o_vp.pix_v       := sl((i_vp.line_early_v = '1') and var_frame_pix_v);

    if not var_frame_pix_v then
      return o_vp;
    end if;    

    if i_vp.frame_hcnt_early = FRAME_WIDTH-1 then
      o_vp.frame_hcnt_early := (others => '0');
    else
      o_vp.frame_hcnt_early := i_vp.frame_hcnt_early + 1;
    end if;

    if i_vp.frame_hcnt_early = FRAME_WIDTH-1 then
      if i_vp.frame_vcnt = FRAME_HEIGHT-1  then
        o_vp.frame_vcnt := (others => '0');
      else
        o_vp.frame_vcnt := i_vp.frame_vcnt + 1;
      end if;
    end if;

    var_hactive := (i_vp.frame_hcnt_early >= ACTIVE_HSTART) and (i_vp.frame_hcnt_early <= ACTIVE_HSTOP);
    var_hactive_early := (i_vp.frame_hcnt_early >= ACTIVE_HSTART-1) and (i_vp.frame_hcnt_early <= ACTIVE_HSTOP-1);
    var_vactive := (i_vp.frame_vcnt >= ACTIVE_VSTART) and (i_vp.frame_vcnt <= ACTIVE_VSTOP);
    var_active  := var_hactive and var_vactive;
    var_active_early  := var_hactive_early and var_vactive;

    o_vp.is_active := sl(var_active);
    o_vp.frame_sof := sl((i_vp.frame_hcnt_early = 0) and (i_vp.frame_vcnt = 0));
    o_vp.frame_eof := sl((i_vp.frame_hcnt_early = FRAME_WIDTH-1) and (i_vp.frame_vcnt = FRAME_HEIGHT-1));
    o_vp.frame_sol := sl(i_vp.frame_hcnt_early = 0);
    o_vp.frame_eol := sl(i_vp.frame_hcnt_early = FRAME_WIDTH-1);
    o_vp.frame_hcnt   := i_vp.frame_hcnt_early;

    if i_vp.is_active then
      if i_vp.active_hcnt = ACTIVE_WIDTH-1 then
        o_vp.active_hcnt := (others => '0');
      else
        o_vp.active_hcnt := i_vp.active_hcnt + 1;
      end if;


      if i_vp.active_hcnt = ACTIVE_WIDTH-1 then
        if i_vp.active_vcnt = ACTIVE_HEIGHT-1  then
          o_vp.active_vcnt := (others => '0');
        else
          o_vp.active_vcnt := i_vp.active_vcnt + 1;
        end if;
      end if;
    else
      o_vp.active_hcnt := (others => '0');
    end if;

    o_vp.active_sof := sl((i_vp.frame_hcnt_early = ACTIVE_HSTART-1) and (i_vp.frame_vcnt = ACTIVE_VSTART));
    o_vp.active_eof := sl((i_vp.frame_hcnt_early = ACTIVE_HSTOP) and (i_vp.frame_vcnt = ACTIVE_VSTOP));
    
    -- sol and eol are one pixel before the actual first and last pixel of line
    o_vp.active_sol := sl(i_vp.frame_hcnt_early = ACTIVE_HSTART-1 and var_vactive);
    o_vp.active_eol := sl(i_vp.frame_hcnt_early = ACTIVE_HSTOP-1 and var_vactive);
    
    -- The inactive lines may be useful to maintain timing when a block delays image
    o_vp.inactive_sol := sl(i_vp.frame_hcnt_early = ACTIVE_HSTART-1 and not var_vactive);
    o_vp.inactive_eol := sl(i_vp.frame_hcnt_early = ACTIVE_HSTOP-1 and not var_vactive);

    o_vp.line_v  := sl(var_active);
    o_vp.line_early_v  := sl(var_active_early);
    o_vp.frame_v := sl(var_vactive);

    return o_vp;
  end function vport_incr;


end package body;

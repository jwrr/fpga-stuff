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

library work;



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


package conv2d_package is


  constant BPP     : natural := 8;   -- Bits Per Pixel
  constant CPP     : natural := 1;   -- Clocks Per Pixel
  constant HSYNC   : natural := 1;
  constant HBPORCH : natural := 10;
  constant HACTIVE : natural := 20;
  constant HFPORCH : natural := 10;
  constant VSYNC   : natural := 1;
  constant VBPORCH : natural := 10;
  constant VACTIVE : natural := 20;
  constant VFPORCH : natural := 10;
  
  constant FRAME_WIDTH   : natural := HSYNC + HBPORCH + HACTIVE + HFPORCH;  
  constant FRAME_HEIGHT  : natural := VSYNC + VBPORCH + VACTIVE + VFPORCH;
  constant ACTIVE_HSTART : natural := HSYNC + HBPORCH;
  constant ACTIVE_HSTOP  : natural := ACTIVE_HSTART + HACTIVE - 1;
  constant ACTIVE_VSTART : natural := VSYNC + VBPORCH;
  constant ACTIVE_VSTOP  : natural := ACTIVE_VSTART + VACTIVE - 1;
  constant F_HCNT_LEN : natural := integer(ceil(log2(real(FRAME_WIDTH))));
  constant F_VCNT_LEN : natural := integer(ceil(log2(real(FRAME_HEIGHT))));
  constant A_HCNT_LEN : natural := integer(ceil(log2(real(HACTIVE))));
  constant A_VCNT_LEN : natural := integer(ceil(log2(real(VACTIVE))));

  type array_of_slv is array(integer range <>) of std_logic_vector(BPP-1 downto 0);
  type array_of_unsigned is array(integer range <>) of unsigned(BPP-1 downto 0);

  type video_port is record
    active_v    : std_logic;
    frame_v     : std_logic;
    line_v      : std_logic;
    pix_v       : std_logic;
    pix         : unsigned(BPP-1 downto 0);
    frame_hcnt  : unsigned(F_HCNT_LEN-1 downto 0);
    frame_vcnt  : unsigned(F_VCNT_LEN-1 downto 0);
    is_active   : std_logic;
    active_hcnt : unsigned(A_HCNT_LEN-1 downto 0);
    active_vcnt : unsigned(A_VCNT_LEN-1 downto 0);
  end record video_port;

  function unsigned(aslv : array_of_slv) return array_of_unsigned;
  function std_logic_vector(au : array_of_unsigned) return array_of_slv;

  function video_port_reset return video_port;
  function video_port_incr(i_vp : video_port) return video_port;

  function video_port_is_active(i_vp : video_port) return boolean;
  function video_port_frame_is_sof(i_vp : video_port) return boolean;
  function video_port_frame_is_sol(i_vp : video_port) return boolean;
  function video_port_frame_is_eof(i_vp : video_port) return boolean;
  function video_port_frame_is_eol(i_vp : video_port) return boolean;

end package;

package body conv2d_package is

  function unsigned(aslv : array_of_slv) return array_of_unsigned is
    variable au : array_of_unsigned(aslv'range);
  begin
    return au;
  end function unsigned;
  
  function std_logic_vector(au : array_of_unsigned) return array_of_slv is
    variable aslv : array_of_slv(au'range);
  begin
    return aslv;
  end function std_logic_vector;


  function video_port_reset return video_port is
    variable o_frame : video_port;
  begin
    o_frame.frame_v     := '0';
    o_frame.line_v      := '0';
    o_frame.active_v    := '0';
    o_frame.pix_v       := '0';
    o_frame.pix         := (others => '0');
    o_frame.frame_hcnt  := (others => '0');   -- unsigned(F_HCNT_LEN-1 downto 0);
    o_frame.frame_vcnt  := (others => '0');   -- unsigned(F_VCNT_LEN-1 downto 0);
    o_frame.is_active   := '0';               -- std_logic;
    o_frame.active_hcnt := (others => '0');   -- unsigned(A_HCNT_LEN-1 downto 0);
    o_frame.active_vcnt := (others => '0');   -- unsigned(A_VCNT_LEN-1 downto 0);
    return o_frame;
  end function video_port_reset;


  function video_port_incr(i_vp : video_port) return video_port is
    variable o_vp : video_port; 
  begin
    o_vp := i_vp;
    if i_vp.frame_hcnt = FRAME_WIDTH-1 then
      o_vp.frame_hcnt := (others => '0');
    else
      o_vp.frame_hcnt := i_vp.frame_hcnt + 1;
    end if;
    
    if i_vp.active_hcnt = HACTIVE-1 then
      if i_vp.active_vcnt = VACTIVE-1  then
        o_vp.active_vcnt := (others => '0');
      else
        o_vp.active_vcnt := i_vp.active_vcnt + 1;
      end if;
    end if;
    o_vp.is_active := '1' when (o_vp.frame_hcnt >= ACTIVE_HSTART) and 
                                (o_vp.frame_hcnt <= ACTIVE_HSTOP) and
                                (o_vp.frame_vcnt >= ACTIVE_VSTART) and 
                                (o_vp.frame_vcnt <= ACTIVE_VSTOP) else '0';
    if o_vp.is_active then
      if i_vp.active_hcnt = HACTIVE-1 then
        o_vp.active_hcnt := (others => '0');
      else
        o_vp.active_hcnt := i_vp.active_hcnt + 1;
      end if;
      
      if i_vp.active_hcnt = HACTIVE-1 then
        if i_vp.active_vcnt = VACTIVE-1  then
          o_vp.active_vcnt := (others => '0');
        else
          o_vp.active_vcnt := i_vp.active_vcnt + 1;
        end if;
      end if;
    end if;
    return o_vp;
  end function video_port_incr;


  function video_port_is_active(i_vp : video_port) return boolean is
    variable is_active : boolean;
  begin
    is_active := (i_vp.frame_hcnt >= ACTIVE_HSTART) and 
                 (i_vp.frame_hcnt <= ACTIVE_HSTOP) and
                 (i_vp.frame_vcnt >= ACTIVE_VSTART) and 
                 (i_vp.frame_vcnt <= ACTIVE_VSTOP);
    return is_active;
  end function video_port_is_active;


  function video_port_frame_is_sof(i_vp : video_port) return boolean is
    variable sof : boolean;
  begin
    sof := (i_vp.frame_hcnt = 0) and
           (i_vp.frame_vcnt = 0);
    return sof;
  end function video_port_frame_is_sof;


  function video_port_frame_is_sol(i_vp : video_port) return boolean is
    variable sof : boolean;
  begin
    sof := (i_vp.frame_hcnt = 0);
    return sof;
  end function video_port_frame_is_sol;


  function video_port_frame_is_eof(i_vp : video_port) return boolean is
    variable eof : boolean;
  begin
    eof := (i_vp.frame_hcnt = FRAME_WIDTH) and
           (i_vp.frame_vcnt = FRAME_HEIGHT);
    return eof;
  end function video_port_frame_is_eof;


  function video_port_frame_is_eol(i_vp : video_port) return boolean is
    variable eof : boolean;
  begin
    eof := (i_vp.frame_hcnt = FRAME_WIDTH);
    return eof;
  end function video_port_frame_is_eol;






end package body;

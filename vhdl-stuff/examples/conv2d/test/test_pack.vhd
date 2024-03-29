--------------------------------------------------------------------------------
-- Description:
--   This package provides useful procedures and functions to simplify writing
--   tests.
--
--------------------------------------------------------------------------------
-- library std.textio.all;
use STD.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

package test_pack is
  pure function to_slv ( ii : natural; len : integer) return std_logic_vector;
  procedure set_sl ( signal sl : inout std_logic; constant val : natural := 1);
  procedure set_slv ( signal slv : inout std_logic_vector; constant val : natural := 1);
  procedure set ( signal slv : inout std_logic_vector; constant val : natural := 1);
  procedure set ( signal sl : inout std_logic; constant val : natural := 1);
  procedure set ( signal sl : inout std_logic; constant val : boolean);
  procedure incr ( signal slv : inout std_logic_vector; constant val : natural := 1);
  procedure decr ( signal slv : inout std_logic_vector; constant val : natural := 1);
  procedure clr ( signal slv : inout std_logic_vector);
  procedure clr ( signal sl : inout std_logic);
  procedure wait_re( signal sig : in std_logic; constant cnt : in positive);
  procedure wait_re( signal   sig : in std_logic);
  procedure pulse ( signal sig : inout std_logic; signal clk : in std_logic; constant cnt : positive := 1);
  procedure tick ( signal clk : in std_logic; constant cnt : positive := 1);
  procedure tick_falling ( signal clk : in std_logic; constant cnt : positive := 1);
  procedure clkgen (signal clk : out std_logic; signal done : in std_logic; constant period : time := 10 ns);

  impure function test(pass : boolean; str : string; print_all : boolean := false) return boolean;
  procedure msg (str : string);

end package;

package body test_pack is

  pure function to_slv ( ii : natural; len : integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(ii, len) );
  end function to_slv;


  procedure set_sl ( signal sl : inout std_logic; constant val : natural := 1) is
  begin
   sl <= '0' when val = 0 else '1';
  end procedure set_sl;
 

  procedure set_slv ( signal slv : inout std_logic_vector; constant val : natural := 1) is
  begin
    slv <= to_slv(val, slv'LENGTH);
  end procedure set_slv;
 

  procedure set ( signal slv : inout std_logic_vector; constant val : natural := 1) is
  begin
    set_slv( slv, val);
  end procedure set;
 

  procedure set ( signal sl : inout std_logic; constant val : natural := 1) is
  begin
    set_sl( sl, val);
  end procedure set;
 

  procedure clr ( signal slv : inout std_logic_vector) is
  begin
    set( slv, 0);
  end procedure clr;

 
  procedure clr ( signal sl : inout std_logic) is
  begin
    set( sl, 0);
  end procedure clr;
 

  procedure set ( signal sl : inout std_logic; constant val : boolean) is
    variable ii : natural;
  begin
    ii := 0;
    if val then
      ii := 1;
    end if;
    set_sl( sl, ii );
  end procedure set;


  procedure incr ( signal slv : inout std_logic_vector; constant val : natural := 1) is
  begin
    slv <= std_logic_vector(  unsigned(slv) + val );
  end procedure incr;
  
  procedure decr ( signal slv : inout std_logic_vector; constant val : natural := 1) is
  begin
    slv <= std_logic_vector(  unsigned(slv) - val );
  end procedure decr;
  
 

  procedure wait_re(
    signal   sig : in std_logic;
    constant cnt : in positive
  ) is
  begin
    for i in 1 to cnt loop
      wait until rising_edge(sig);
    end loop;
  end procedure wait_re;
 

  procedure wait_re(
    signal   sig : in std_logic
  ) is
  begin
    wait_re(sig, 1);
  end procedure wait_re;
 

  procedure pulse (
    signal   sig : inout std_logic;
    signal   clk : in    std_logic;
    constant cnt :       positive := 1
  ) is
  begin
    sig <= '0' when sig = '1' else '1';
    wait_re(clk, cnt);
    sig <= not sig;
  end procedure pulse;

  procedure tick (
    signal   clk : in    std_logic;
    constant cnt :       positive := 1
  ) is
  begin
    for ii in 1 to cnt loop
      wait_re(clk, cnt);
    end loop;
  end procedure tick;


  procedure tick_falling (
    signal   clk : in    std_logic;
    constant cnt :       positive := 1
  ) is
  begin
    for i in 1 to cnt loop
      wait until falling_edge(clk);
    end loop;
  end procedure tick_falling;


  procedure clkgen (
    signal   clk    : out   std_logic;
    signal   done   : in    std_logic;
    constant period : time := 10 ns
  ) is
    constant half_period : time := period / 2;
  begin
    while done = '0' loop
      clk <= '0';
      wait for half_period;
      clk <= '1';
      wait for half_period;
    end loop;
    wait;
  end procedure clkgen;
    
  impure function test(pass : boolean; str : string; print_all : boolean := false) return boolean is
    variable outline : line;
  begin
    if print_all or not pass then
      write(outline, now, right, 12);
      write(outline, string'(": "));
      if not pass then
        write(outline, string'("FAIL"));
      else
        write(outline, string'("PASS"));
      end if;
      write(outline, string'(" - "));
      write(outline, str);
      writeline(output, outline);
    end if;
    return pass;
  end function test;

  procedure msg (str : string) is
    variable outline : line;
  begin
    write(outline, now, right, 12);
    write(outline, string'(": "));
    write(outline, string'("    "));
    write(outline, string'(" - "));
    write(outline, str);
    writeline(output, outline);
  end procedure msg;

end package body;

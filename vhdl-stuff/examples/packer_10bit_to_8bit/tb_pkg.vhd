--------------------------------------------------------------------------------
-- Description:
--   This package provides useful procedures and functions to simply writing
--   tests.
--
--------------------------------------------------------------------------------
-- library std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all; -- log2, ceil
library work;


package tb_pkg is
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
  procedure clkgen (signal clk : out std_logic; signal done : in std_logic; constant period : time := 10 ns);

  impure function num_bits(i : natural) return natural;
  impure function to_string(i : natural) return string;
  impure function to_hstring(i : natural) return string;

  type test_t is protected
    procedure start;
    procedure done;
    procedure level(lvl : natural);
    procedure msg(lvl : natural; m : string);
    procedure dbg(m : string);
    procedure note(m : string);
    procedure warn(m : string);
    procedure error(m : string);
    procedure test(a : std_logic_vector; e : std_logic_vector; m : string);
    procedure test(a : std_logic; e : std_logic; m : string);
  end protected test_t;

  type packer_t is protected
    procedure reset;
    procedure push_10bits(i: natural);
    impure function pull_8bits return natural;
    impure function valid return boolean;
    impure function full return boolean;
  end protected packer_t;

end package;

package body tb_pkg is

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

  impure function num_bits(i : natural) return natural is
    variable n : natural := 1;
  begin
    if i = 0 then
      return 1;
    else
      n := natural(ceil(log2(real(i))));
      if n = 0 then
        n := 1;
      end if;
      return n;
    end if;
  end function num_bits;


  impure function to_hstring(i : natural) return string is
  begin
    return "0x" & to_hstring(to_unsigned(i, num_bits(i)));
  end function to_hstring; -- natural


  impure function to_string(i : natural) return string is
  begin
    return integer'image(i);
  end function to_string; -- natural


  type test_t is protected body
    variable test_count : natural := 0;
    variable fail_count : natural := 0;
    variable test_level : natural := 2; -- DBG=0, PASS=1, NOTE=2, FAIL=3, FINAL=4

    procedure start is
    begin
      test_count := 0;
      fail_count := 0;
      test_level := 2;
    end procedure start;
    
    procedure level(lvl : natural) is
    begin
      test_level := lvl;
    end procedure level;
    

    procedure done is
    begin
      if fail_count = 0 then
        report("TEST PASSED -- All " & to_string(test_count) & " tests passed.");
      else
        report("TEST FAILED -- " & to_string(fail_count) & " of " & to_string(test_count) & " failed.");
      end if;
    end procedure done;

    procedure msg(lvl : natural; m : string) is
    begin
      report(m);
    end procedure msg;

    procedure dbg(m : string) is
    begin
      msg(0, m);
    end procedure dbg;

    procedure note(m : string) is
    begin
      msg(1, m);
    end procedure note;

    procedure warn(m : string) is
    begin
      msg(1, m);
    end procedure warn;

    procedure error(m : string) is
    begin
      msg(2, m);
    end procedure error;

    procedure test(a : std_logic_vector; e : std_logic_vector; m : string) is
    begin
      test_count := test_count + 1;
      if a /= e then
        fail_count := fail_count + 1;
        report("FAIL: " & "Actual = 0x" & to_hstring(a) & " Expect = 0x" & to_hstring(e) & " -- " & m);
      elsif test_level <= 1 then
        report("pass: " & "Actual = 0x" & to_hstring(a) & " Expect = 0x" & to_hstring(e) & " -- " & m);
      end if;
    end procedure test;


    procedure test(a : std_logic; e : std_logic; m : string) is
      variable a_slv : std_logic_vector(0 downto 0);
      variable e_slv : std_logic_vector(0 downto 0);
    begin
      a_slv(0) := a;
      e_slv(0) := e;
      test(a_slv, e_slv, m);
    end procedure test;


  end protected body test_t;



  type packer_t is protected body

    variable pack_offset  : natural := 0;
    variable pack_val     : natural := 0;
    variable pack_numbits : natural := 0;

    procedure reset is
    begin
      pack_offset := 0;
      pack_val    := 0;
    end procedure reset;

    procedure push_10bits(i : natural) is
    begin
      report("Debug: in push1 - pack_numbits =" & to_string(pack_numbits) & " pack_val=" & to_hstring(pack_val) &  " i=" & to_hstring(i));
      if not full then
        pack_val    := pack_val + i*(2**pack_numbits);
        pack_numbits := pack_numbits + 10;
        report("Good Push");
      else
        report("Warning: Push ignored to full packer");
      end if;
      report("Debug: in push2 - pack_numbits =" & to_string(pack_numbits) & " pack_val=" & to_hstring(pack_val) &  " i=" & to_hstring(i));
    end procedure push_10bits;



    impure function pull_8bits return natural is
      variable o_val :natural := 3_141_592_65;
    begin
      report("Debug: in pull1 - pack_numbits =" & to_string(pack_numbits) & " pack_val=" & to_hstring(pack_val));
      if valid then
        o_val := pack_val mod 256;
        pack_val := pack_val / 256;
        pack_numbits := pack_numbits - 8;
      else
        report("Warning: Pull ignored from empty packer");
      end if;
      report("Debug: in pull2 - pack_numbits =" & to_string(pack_numbits) & " pack_val=" & to_hstring(pack_val) & " o=" & to_hstring(o_val));
      return o_val;
    end function pull_8bits;

    impure function valid return boolean is
    begin
      return pack_numbits >= 8;
    end function valid;

    impure function full return boolean is
      variable ff : boolean;
    begin
      ff := pack_numbits >= 22;
      report("full = " & boolean'image(ff) & " pack_numbits = " & to_string(pack_numbits));
      return pack_numbits >= 22;
    end function full;


  end protected body;


end package body;

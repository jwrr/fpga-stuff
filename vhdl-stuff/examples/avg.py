#!/usr/bin/env python3
num_inputs = 16


print(f"""
--------------------------------------------------------------------------------
-- Block: avg{num_inputs}
-- Description:
-- This block implements a big adder with {num_inputs} inputs.
-- There are several add stages to improve timing.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
library work;

""")

print(f"entity avg{num_inputs} is")
print("  generic (\n    DWIDTH  : integer := 16\n);\n  port (\n    clk : std_logic;\n    rst : std_logic;")
for i in range(num_inputs):
    print(f"    i_data_{i}  : in  std_logic_vector(DWIDTH-1 downto 0);")
level = 4
print(    f"    o_avg : out std_logic_vector(DWIDTH-1 downto 0)")
print(f"  );\nend entity avg{num_inputs};\n")


print(f"architecture rtl of avg{num_inputs} is")
nn = num_inputs
level = 0
while nn >= 1:
    for i in range(nn):
        if nn == num_inputs:
            print(f"  signal sum_{level}_{i} : unsigned(DWIDTH-1 downto 0);")
        else:
            print(f"  signal sum_{level}_{i} : unsigned(DWIDTH+{level-1} downto 0);")
    print()
    nn //= 2
    level += 1

print("begin\n  process(clk, rst)\n  begin\n    if rst then")
print("    elsif rising_edge(clk) then")

for i in range(num_inputs):
  print(f"      sum_0_{i} <= unsigned(i_data_{i});");

nn = num_inputs
level = 0
while nn > 1:
    nn //= 2
    level += 1
    print(f"      -- level: {level}. Num Adders: {nn}")
    for i in range(nn):
        print(f"      sum_{level}_{i} <= ('0' + sum_{level-1}_{2*i}) + ('0' & sum_{level-1}_{2*i+1});")
    print()
print(f"      o_avg <= std_logic_vector(sum_{level}_0(sum_{level}_0'high downto {level}));")

print("    end if;\n  end process;\nend architecture rtl;")




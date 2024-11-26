library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- A variable combinatorial left shifter 
entity left_shifter is
    generic(
        -- Number of bits of the input
        IN_BITS : natural := 35;
        -- Number of bits of the input
        SHAMT_BITS : natural := 6); -- 6 for float16, 7 bits for float32
    Port(
        -- Input of the shifter
        in_shift : std_logic_vector(IN_BITS-1 downto 0);
        -- Number of shift positions
        lshamt : std_logic_vector(SHAMT_BITS-1 downto 0);
        -- Output of the shifter
        out_shift : out std_logic_vector(IN_BITS-1 downto 0));
end left_shifter;

architecture Behavioral of left_shifter is
begin
    out_shift <= in_shift sll to_integer(unsigned(lshamt));
end Behavioral;
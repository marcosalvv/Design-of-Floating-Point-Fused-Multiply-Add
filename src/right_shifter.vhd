library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- A variable combinatorial right shifter 
entity right_shifter is
    generic(
        -- Number of bits of the input
        IN_BITS : natural := 3;
        -- Number of bits of the shift amount
        SHAMT_BITS : natural := 2);
    Port(
        -- Input of the shifter
        in_shift : std_logic_vector(IN_BITS-1 downto 0);
        -- Number of shift positions
        rshamt : std_logic_vector(SHAMT_BITS-1 downto 0);
        -- Output of the shifter
        out_shift : out std_logic_vector(IN_BITS-1 downto 0));
end right_shifter;

architecture Behavioral of right_shifter is
begin
    out_shift <= in_shift srl to_integer(unsigned(rshamt));
end Behavioral;

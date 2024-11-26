library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
-- TODO: WARNING STRANO NELLA SINTESI, CONTROLLARE

-- Component for the rounding to the nearest(even to tie)
entity round_zero is
    generic(
        -- Number of input bits (35 for 16float e 74 for 32float)
        IN_BITS : natural := 74;
        -- Number of output bits (11 for 16float e 24 for 32float)
        OUT_BITS : natural := 24);
    Port(
        in_round : in std_logic_vector(IN_BITS-1 downto 0);
        out_round : out std_logic_vector(OUT_BITS-1 downto 0);
        ovf_round : out std_logic);
end round_zero;

architecture Behavioral of round_zero is
begin
    out_round <= in_round(IN_BITS-1 downto IN_BITS-OUT_BITS);
   -- This output indicates that occured an overflow in rounding process, it's necessary for the exponent update
    ovf_round <= '0';                                 
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- A generic bit inverter with an enable
entity bit_inverter is
    generic(
        -- Input and output number of bits 
        N_BITS : natural := 11
    );
    Port(
        in_inv : in std_logic_vector(N_BITS-1 downto 0);
        -- Bit inverter enable
        en : in std_logic;
        out_inv : out std_logic_vector(N_BITS-1 downto 0));
end bit_inverter;

architecture Behavioral of bit_inverter is
begin

--    out_inv <= in_inv;
   out_inv <= in_inv xor en;
    
--    out_inv <= in_inv when en = '0' else
--               std_logic_vector(signed(not(in_inv))+1);
    
end Behavioral;

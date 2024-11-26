library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- A full adder with no c_out
entity full_adder_no_c_out is
    Port(
        a : in std_logic;
        b : in std_logic;
        c_in : in std_logic; 
        s : out std_logic
        );
end full_adder_no_c_out;

architecture Behavioral of full_adder_no_c_out is
begin
    s <= a xor b xor c_in;
end Behavioral;
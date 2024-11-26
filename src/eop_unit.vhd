library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity eop_unit is
    Port (
        s_x: in std_logic;
        s_y: in std_logic;
        s_w: in std_logic;
        eop: out std_logic
    );
end eop_unit;

architecture Behavioral of eop_unit is

begin
eop<=(s_x xor s_y) xor s_w;
end Behavioral;

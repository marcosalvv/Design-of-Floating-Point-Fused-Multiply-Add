library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sign_unit is
    Port(
        s_x: in std_logic;
        s_y: in std_logic;
        s_w: in std_logic;
        sign_sum: in std_logic;
        s_z: out std_logic);
end sign_unit;

architecture Behavioral of sign_unit is
    signal s_xy: std_logic;
    signal input_vec: std_logic_vector(2 downto 0);
begin
    s_xy <= s_x xor s_y;
    with sign_sum select
        s_z <= s_xy when '0',
               s_w when others;


--    input_vec <= s_xy & s_w & sign_sum;
--    --Lookup Table (Youssef)
--    with input_vec select
--        s_z <= '0' when "000",
--               '0' when "001",
--               '0' when "010",
--               '1' when "011",
--               '1' when "100",
--               '0' when "101",
--               '1' when others;
 end Behavioral;
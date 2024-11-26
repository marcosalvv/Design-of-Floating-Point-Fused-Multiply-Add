library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adder_1c_tb is
    generic(
    constant N_BITS: natural := 35
    );
end adder_1c_tb;

architecture Behavioral of adder_1c_tb is

component adder_1c is
    Port (
    in_a: in std_logic_vector((N_BITS)-1 downto 0);
    in_b: in std_logic_vector((N_BITS)-1 downto 0);
    out_add: out std_logic_vector((N_BITS)-1 downto 0);
    c_out: out std_logic
    );
end component;

signal in_a: std_logic_vector((N_BITS)-1 downto 0) := (others => '0');
signal in_b: std_logic_vector((N_BITS)-1 downto 0) := (others => '0');
signal out_add: std_logic_vector((N_BITS)-1 downto 0);
signal c_out: std_logic := '0';

begin
DUT: adder_1c PORT MAP(
    in_a=>in_a,
    in_b=>in_b,
    out_add=>out_add,
    c_out=>c_out
);
process
begin
    wait for 2 ns;
    in_a <= "00000000010000100001001000100000001";
    in_b <= "00000000010001000100010101000101000";
    wait for 5 ns;
    in_a <= "10001100010001000000000111001010101";
    in_b <= "00101010001000100010001000100010011";
    wait for 5 ns;
    in_a <= "10110001000100100100100011100100100";
    in_b <= "10000010001001000100100010010100111";
    wait for 5 ns;
    in_a <= "01111111111111111111111111111111110";
    in_b <= "10000000000000000000000000000000001";
    wait;
end process;

end Behavioral;

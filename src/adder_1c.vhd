library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder_1c is
    generic(
    -- Number of input bits, where N_BIT=3m+2
        N_BITS: natural := 35
    );
    Port (
        in_a: in std_logic_vector(N_BITS-1 downto 0);
        in_b: in std_logic_vector(N_BITS-1 downto 0);
        disable : in std_logic;
        out_add: out std_logic_vector(N_BITS-1 downto 0);
        sign_sum: out std_logic);
end adder_1c;

architecture Behavioral of adder_1c is
    signal sum: signed(N_BITS-1 downto 0);
    signal two_c_sum: signed(N_BITS-1 downto 0);
    signal en_compl2: std_logic;
begin
    -- CA2 Adder
    sum <= signed(in_a) + signed(in_b);    
    -- Two's complement
    two_c_sum <=(not sum)+1;
    -- Sign bit mux
    sign_sum <= sum(N_BITS-1);
    -- Complement 2 when the sign_sum is 1 and disable is 0
    en_compl2 <= sign_sum and (not disable);
    with en_compl2 select
        out_add <= std_logic_vector(sum) when '0',
                   std_logic_vector(two_c_sum) when others;           
end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity csa_3_2 is
    generic(
        N_BITS: natural := 22);
    Port(  
        in_x : in std_logic_vector(N_BITS-1 downto 0);
        in_y : in std_logic_vector(N_BITS-1 downto 0);
        in_w : in std_logic_vector(N_BITS-1 downto 0);
        out_sum : out std_logic_vector(N_BITS-1 downto 0);
        out_carry : out std_logic_vector(N_BITS-1 downto 0));
end csa_3_2;

architecture Behavioral of csa_3_2 is
    -- Full Adder
    component full_adder
        Port(
            a : in std_logic;
            b : in std_logic;
            c_in : in std_logic; 
            s : out std_logic;
            c_out : out std_logic
            );
    end component;

begin
    gen_fa: for i in 0 to N_BITS-1 generate
        FA: full_adder port map(
            a=>in_x(i), 
            b=>in_y(i), 
            c_in=>in_w(i), 
            s=>out_sum(i), 
            c_out=>out_carry(i) 
        );
    end generate;
end Behavioral;
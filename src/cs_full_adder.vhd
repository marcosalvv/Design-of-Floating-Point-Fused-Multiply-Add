library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- A full adder with 3 inputs
entity cs_full_adder is
    Port(
        a : in std_logic;
        b : in std_logic;
        s_in : in std_logic;
        c_in : in std_logic; 
        s_out : out std_logic;
        c_out : out std_logic);
end cs_full_adder;

architecture Behavioral of cs_full_adder is
     -- Full Adder
    component full_adder
        Port(
            a : in std_logic;
            b : in std_logic;
            c_in : in std_logic; 
            s : out std_logic;
            c_out : out std_logic);
        
    end component;
    
    signal w_and : std_logic;     
begin
    w_and <= a and b;
    FA: full_adder port map(
            a=>w_and, 
            b=>s_in, 
            c_in=>c_in, 
            s=>s_out, 
            c_out=>c_out);
end Behavioral;
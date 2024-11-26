library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ONLY FOR TESTING!
-- An unsigned array multiplier (it's the cs_array_multiplier with a carry ripple adder in the last row)
entity test_array_multiplier is
    generic(
        N_BITS: natural := 24
        );
    Port ( 
        in_x : in std_logic_vector(N_BITS-1 downto 0);   
        in_y : in std_logic_vector(N_BITS-1 downto 0);   
        out_mult : out std_logic_vector(2*N_BITS-1 downto 0));
end test_array_multiplier;

architecture Behavioral of test_array_multiplier is
    component cs_array_multiplier is
        generic(
        -- Number of bits of the input
        N_BITS : natural := 4);
        Port ( 
            in_x : in std_logic_vector(N_BITS-1 downto 0);
            in_y : in std_logic_vector(N_BITS-1 downto 0);
            out_sum : out std_logic_vector(2*N_BITS-2 downto 0);   
            out_carry : out std_logic_vector(N_BITS-1 downto 0));  
    end component;
        
    component full_adder is
        Port(
            a : in std_logic;
            b : in std_logic;
            c_in : in std_logic; 
            s : out std_logic;
            c_out : out std_logic
            );
    end component;
    
    component full_adder_no_c_out is
        Port(
            a : in std_logic;
            b : in std_logic;
            c_in : in std_logic; 
            s : out std_logic
            );
    end component;
    
    signal out_sum : std_logic_vector(2*N_BITS-2 downto 0);
    signal out_carry : std_logic_vector(N_BITS-1 downto 0);
    signal w_x: std_logic_vector(N_BITS-1 downto 0);
    signal w_y: std_logic_vector(2*N_BITS-1 downto 0);
    signal w_carry: std_logic_vector(N_BITS-1 downto 0);
begin
    cs_mult: cs_array_multiplier
            generic map(
                N_BITS=>N_BITS)
                
            port map(
                in_x=>in_x,
                in_y=>in_y,
                out_sum=>out_sum,                
                out_carry=>out_carry);
    out_mult(N_BITS-1 downto 0) <= out_sum(N_BITS-1 downto 0);
       
    w_x <= '0' & out_sum(2*N_BITS-2 downto N_BITS);
    
    
    carry_ripple_add: for i in 0 to N_BITS-2 generate
        full_add: full_adder
            port map (
                a=>w_x(i),
                b=>out_carry(i),
                c_in=>w_carry(i), 
                s=>out_mult(i+N_BITS),
                c_out=>w_carry(i+1));     
    end generate;
    w_carry(0) <= '0';
    
    last_full_add: full_adder_no_c_out
        port map (
                a=>w_x(N_BITS-1),
                b=>out_carry(N_BITS-1),
                c_in=>w_carry(N_BITS-1), 
                s=>out_mult(2*N_BITS-1));   
end Behavioral;
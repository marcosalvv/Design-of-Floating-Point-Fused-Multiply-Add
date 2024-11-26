library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Unit that updates the exponents of the inputs and it calculates the output exponent
entity exp_update is
    generic(
        EXP_BITS: natural := 8;      
        SIGNIF_BITS: natural := 23;
        BIAS: natural := 127;
        SHAMT_BITS: natural := 7;
        EXP_INTERN_BITS: natural := 10); -- float16 --> 8 | float32 --> 10
        
    port(
        e_x : in std_logic_vector(EXP_BITS-1 downto 0);
        e_y : in std_logic_vector(EXP_BITS-1 downto 0);
        e_w : in std_logic_vector(EXP_BITS-1 downto 0);
        signD : in std_logic;
        rshamt : in std_logic_vector(SHAMT_BITS-1 downto 0);    -- 16 bit -> 6 bits  32 bit -> 7 bits
        lshamt : in std_logic_vector(SHAMT_BITS-1 downto 0);    -- 16 bit -> 6 bits  32 bit -> 7 bits
        ovf_round : in std_logic;
        e_z : out std_logic_vector(EXP_BITS-1 downto 0);
        zero_xyw: in std_logic;
        exp_und : out std_logic;
        exp_ovf : out std_logic);
end exp_update;

architecture Behavioral of exp_update is
    --Signals
    signal sum0: integer;
    signal sum1: integer;
    signal mux_signD: signed(EXP_INTERN_BITS-1 downto 0);
    signal diff_lshamt: signed(EXP_INTERN_BITS-1 downto 0);
    signal mux_ovf_round: signed(EXP_INTERN_BITS-1 downto 0);
    signal mux_und: signed(EXP_INTERN_BITS-1 downto 0);
    signal mux_und_uns: unsigned(EXP_INTERN_BITS-1 downto 0);
    signal comp_ovf: std_logic;
    signal comp_und_temp: std_logic;
    signal comp_und: std_logic;
    signal mux_ovf: unsigned(EXP_INTERN_BITS-1 downto 0);   
begin
    -- Sum and subract for signD = 0
    sum0<=to_integer(unsigned(e_x))+to_integer(unsigned(e_y))+(SIGNIF_BITS+4-BIAS);
    -- Sum for signD = 1  
    sum1<= to_integer(unsigned(e_w)) + to_integer(unsigned(rshamt));                                     
    -- Mux with signD
    with signD select
        mux_signD <= to_signed(sum0,EXP_INTERN_BITS) when '0',
                     to_signed(sum1,EXP_INTERN_BITS) when others;
    -- Subtract lshamt
    diff_lshamt <= mux_signD - to_integer(unsigned(lshamt));
    -- Mux with ovf_round to consider the overflow of the rounding
    with ovf_round select
        mux_ovf_round <= diff_lshamt when '0',
                         diff_lshamt+1 when others; 
                                   
--    -- Sign bit of mux_ovf_round    
--    mux_ovf_round_sign <= mux_ovf_round(EXP_INTERN_BITS-1);
--    -- Mux for case e_z<0 (underflow case)
--    with mux_ovf_round_sign select
--        mux_und <= mux_ovf_round when '0',
--                    (others=>'0') when others;                    
--    -- Convert to unsigned, because mux_und is a positive number                
--    mux_und_uns <= unsigned(mux_und); 


    -- Comparator and mux for case e_z<=0 
    comp_und_temp <= '1' when mux_ovf_round <= to_signed(0, EXP_INTERN_BITS) else
                     '0';
    -- This or is necessary when there is the case num*0+0 and to put the fma output to zero
    comp_und <= comp_und_temp or zero_xyw;            
    with comp_und select
        mux_und <= mux_ovf_round when '0',
                   to_signed(0, EXP_INTERN_BITS) when others;
    -- Convert to unsigned, because mux_und is a positive number                
    mux_und_uns <= unsigned(mux_und);                                                   
    -- Comparator and mux for case e_z>e_z_max 
    comp_ovf <= '1' when mux_und>to_signed(2**EXP_BITS-2, EXP_INTERN_BITS) else
                '0';
    with comp_ovf select
        mux_ovf <= mux_und_uns when '0',
                   to_unsigned(2**EXP_BITS-1, EXP_INTERN_BITS) when others;
                                                 
    -- e_z output, it's truncated to EXP_BITS                
    e_z <= std_logic_vector(mux_ovf(EXP_BITS-1 downto 0));   
    -- Flags
    exp_und <= comp_und;
    exp_ovf <= comp_ovf;          
end Behavioral;
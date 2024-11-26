library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shift_distance is
    generic(
        EXP_BITS: natural := 8;
        SIGNIF_BITS : natural := 23;
        BIAS : natural := 127;       
        SHAMT_BITS: natural := 7;
        SHIFT_INTERN_BITS: natural := 10);  -- float16 --> 7 | float32 --> 10
    port(
        e_x : in std_logic_vector(EXP_BITS-1 downto 0);
        e_y : in std_logic_vector(EXP_BITS-1 downto 0);
        e_w : in std_logic_vector(EXP_BITS-1 downto 0);
        rshamt : out std_logic_vector(SHAMT_BITS-1 downto 0);
        signD : out std_logic;
        disable : out std_logic);
end shift_distance;

architecture Behavioral of shift_distance is
    signal D : integer;
    signal D_sig : signed(SHIFT_INTERN_BITS-1 downto 0);
    signal w_signD : std_logic;
    signal amt : signed(SHIFT_INTERN_BITS-1 downto 0);
    signal sign_amt : std_logic;
    signal mux_signD: unsigned(SHIFT_INTERN_BITS-1 downto 0);
    signal comp_ovf: std_logic;
    signal mux_ovf: unsigned(SHIFT_INTERN_BITS-1 downto 0);
begin
    -- Exponent distance
    D <= to_integer(unsigned(e_x)) + to_integer(unsigned(e_y)) - 
         to_integer(unsigned(e_w)) - BIAS;
    D_sig <= to_signed(D,SHIFT_INTERN_BITS);    
    -- Shift amount
    amt <= D_sig + (SIGNIF_BITS+4);
    sign_amt <= amt(SHIFT_INTERN_BITS-1);    
    -- Mux to change the output to m+2 when amt<0
    with sign_amt select ---------------------------------------------------- non so se deve essere selezionato dal sign di amt e quando = 1 si ha mux_signD = 0
        mux_signD <= unsigned(amt) when '0', --mux_signD is a positive number
                     (others => '0') when others;                                                  
    -- Comparator and mux for case rshamt>rshamt_max    
    comp_ovf <= '1' when mux_signD>to_unsigned(3*(SIGNIF_BITS+1)+2,SHIFT_INTERN_BITS) else
                '0';         
    with comp_ovf select
        mux_ovf <= mux_signD when '0',
                   to_unsigned(3*(SIGNIF_BITS+1)+2,SHIFT_INTERN_BITS) when others; -- <------ Non so se deve essere 3m+1 anzichè 3m+2
                   
    -- Outputs:
    -- Right shif amount of the right shifter               
    rshamt <= std_logic_vector(mux_ovf(SHAMT_BITS-1 downto 0)); 
    -- Sign of the exponent distance
    signD <= D_sig(SHIFT_INTERN_BITS-1);  
    -- The disable signal is useful to resolve a particular corner case,
    -- Because when there is a combination of inputs, which leads to having D<=-27, it causes an error in the FMA output.
    -- To solve this case, the inverter bit and the 2's complement of the adder must be disabled.                      
    disable <= '1' when mux_signD<=to_unsigned(0,SHIFT_INTERN_BITS) else
               '0';      
end Behavioral;



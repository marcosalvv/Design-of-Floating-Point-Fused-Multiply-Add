library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- VHDL 2008 ONLY

entity special_values is
    generic(
        EXP_BITS: natural := 8;
        SIGNIF_BITS : natural := 23);
    port(
        e_x: in std_logic_vector(EXP_BITS-1 downto 0);
        e_y: in std_logic_vector(EXP_BITS-1 downto 0);
        e_w: in std_logic_vector(EXP_BITS-1 downto 0);
        signif_x: in std_logic_vector(SIGNIF_BITS-1 downto 0);
        signif_y: in std_logic_vector(SIGNIF_BITS-1 downto 0);
        signif_w: in std_logic_vector(SIGNIF_BITS-1 downto 0);
        eop: in std_logic;
        zero_xyw: out std_logic;
        invalid: out std_logic);
end special_values;

architecture Behavioral of special_values is
    signal inf_nan_x : std_logic;
    signal inf_nan_y : std_logic;
    signal inf_nan_w : std_logic;
    signal inf_nan_xyw : std_logic;
    signal zero_signif_x : std_logic;
    signal zero_signif_y : std_logic;
    signal zero_signif_w : std_logic;    
    signal nan_x : std_logic;
    signal nan_y : std_logic;
    signal nan_w : std_logic;    
begin
    -- These signal detects if the input is infinity or NaN
    inf_nan_x <= and e_x;
    inf_nan_y <= and e_y;
    inf_nan_w <= and e_w;
    
    -- This signal detects if one or both of inputs x and y are infinity or NaN
    -- and the input w is infinity or NaN
    inf_nan_xyw <= (inf_nan_x or inf_nan_y) and inf_nan_w;
    -- These signals detect if the input has the significand part with all zeros
    zero_signif_x <= nor signif_x;
    zero_signif_y <= nor signif_y;
    zero_signif_w <= nor signif_w;  
    -- These signals detect if the input is NaN
    nan_x <= inf_nan_x and (not zero_signif_x);
    nan_y <= inf_nan_y and (not zero_signif_y);
    nan_w <= inf_nan_w and (not zero_signif_w);
    
    -- This signal detects if there is the case of inf-inf or one of the inputs is NaN
    invalid <= (inf_nan_xyw and eop) or nan_x or nan_y or nan_w;
    
    -- This signal detects if one or both of inputs x and y are zeros
    -- and the input w is zero
    zero_xyw <= (((nor e_x) and zero_signif_x) or ((nor e_y) and zero_signif_y)) and ((nor e_w) and zero_signif_w);   
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity shift_distance_tb is       
end shift_distance_tb;

architecture Behavioral of shift_distance_tb is
    constant EXP_BITS: natural := 8;
    constant BIAS : natural := 127;       -- bias (b16 -> 15, b32 -> 127)
    constant SIGNIF_BITS : natural := 23;       -- mantissa bits without sign (b16 -> 10, b32 -> 23)
    constant SHAMT_BITS: natural := 7;
    constant SHIFT_INTERN_BITS: natural := 10;  -- float16 --> 7 | float32 --> 10

    -- Inputs
    signal e_x : std_logic_vector(EXP_BITS-1 downto 0);
    signal e_y : std_logic_vector(EXP_BITS-1 downto 0);
    signal e_w : std_logic_vector(EXP_BITS-1 downto 0);
    signal rshamt : std_logic_vector(SHAMT_BITS-1 downto 0);
    signal signD : std_logic;
begin
    duv: entity work.shift_distance
        generic map (
            EXP_BITS => EXP_BITS,
            BIAS => BIAS,       -- bias b16 -> 15, b32 -> 127
            SIGNIF_BITS => SIGNIF_BITS,       -- mantissa bits without sign (b16 -> 10, b32 -> 23)
            SHAMT_BITS => SHAMT_BITS,
            SHIFT_INTERN_BITS => SHIFT_INTERN_BITS) -- float16 --> 7 | float32 --> 10
        port map(
            e_x=>e_x,
            e_y=>e_y,
            e_w=>e_w,
            rshamt=>rshamt,
            signD=>signD);
    --Stimuli float16
--    process
--    begin
--        --wait for 20 ns; 
--        e_x <= "00001";
--        e_y <= "00011";
--        e_w <= "00000";
--        wait for 100 ns;
--        e_x <= "00001";
--        e_y <= "00101";
--        e_w <= "10001";
--        wait for 100 ns;
--        e_x <= "01010";
--        e_y <= "01001";
--        e_w <= "10101";
--        wait for 100 ns;
--        e_x <= "11010";
--        e_y <= "01001";
--        e_w <= "00101";
--        wait for 100 ns;
--        e_x <= "11111";
--        e_y <= "11111";
--        e_w <= "00000";
--        wait for 100 ns;
--        e_x <= "00000";
--        e_y <= "00000";
--        e_w <= "11111";
--        wait;
--    end process;
    
    
    --Stimuli float32
    process
    begin
        --wait for 20 ns; 
        e_x <= "00000001";
        e_y <= "00000011";
        e_w <= "00000000";
        wait for 100 ns;
        e_x <= "00000001";
        e_y <= "00000101";
        e_w <= "00010001";
        wait for 100 ns;
        e_x <= "00001010";
        e_y <= "00001001";
        e_w <= "00010101";
        wait for 100 ns;
        e_x <= "00011010";
        e_y <= "00001001";
        e_w <= "00000101";
        wait for 100 ns;
        e_x <= "11011010";
        e_y <= "00101001";
        e_w <= "00000000";
        wait for 100 ns;
        e_x <= "11111111";
        e_y <= "11111111";
        e_w <= "00000000";
        wait for 100 ns;
        e_x <= "00000000";
        e_y <= "00000000";
        e_w <= "11111111";
        wait for 100 ns;
        e_x <= "01111111";
        e_y <= "00000011";
        e_w <= "00000000";
        wait;
    end process;

end Behavioral;

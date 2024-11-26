library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- DA CONTROLLARE
entity exp_update_tb is
end exp_update_tb;

architecture Behavioral of exp_update_tb is
    constant EXP_BITS: natural := 8;         
    constant SIGNIF_BITS: natural := 23;
    constant BIAS: natural := 127;
    constant SHAMT_BITS: natural := 7;
    constant EXP_INTERN_BITS: natural := 10;  -- float16 --> 8 | float32 --> 10 
    
    -- Signals for the port map
    signal e_x: std_logic_vector(EXP_BITS-1 downto 0);
    signal e_y: std_logic_vector(EXP_BITS-1 downto 0);
    signal e_w: std_logic_vector(EXP_BITS-1 downto 0);
    signal signD: std_logic := '1';
    signal rshamt: std_logic_vector(SHAMT_BITS-1 downto 0);
    signal lshamt: std_logic_vector(SHAMT_BITS-1 downto 0);
    signal ovf_round: std_logic := '0';
    signal e_z: std_Logic_vector(EXP_BITS-1 downto 0);
    signal flag_und : std_logic;
    signal flag_ovf : std_logic;

begin
    duv: entity work.exp_update
        generic map(
            EXP_BITS => EXP_BITS,         
            SIGNIF_BITS => SIGNIF_BITS,
            BIAS => BIAS,
            SHAMT_BITS => SHAMT_BITS,
            EXP_INTERN_BITS => EXP_INTERN_BITS)
        port map(
            e_x=>e_x,
            e_y=>e_y,
            e_w=>e_w,
            signD=>signD,
            rshamt=>rshamt,
            lshamt=>lshamt,
            ovf_round=>ovf_round,
            e_z=>e_z,
            flag_und => flag_und,
            flag_ovf => flag_ovf);
    


--    process
--    begin
--        e_x <= "00000";
--        e_y <= "00000";
--        e_w <= "00000";
--        signD <= '1';
--        rshamt <= "000000";
--        lshamt <= "000000";
--        ovf_round <= '0';
--        wait for 100 ns;
--        e_x <= "00001";
--        e_y <= "01010";
--        e_w <= "01000";
--        signD <= '0';
--        rshamt <= "000000";
--        lshamt <= "000000";
--        ovf_round <= '0';
--        wait for 100 ns;
--        e_x <= "00111";
--        e_y <= "00000";
--        e_w <= "01000";
--        signD <= '1';
--        rshamt <= "000101";
--        lshamt <= "000011";
--        ovf_round <= '0';
--        wait for 100 ns;
--        e_x <= "00111";
--        e_y <= "00000";
--        e_w <= "01000";
--        signD <= '1';
--        rshamt <= "000111";
--        lshamt <= "000011";
--        ovf_round <= '1';
--        wait for 100 ns;
--        e_x <= "11111";
--        e_y <= "11111";
--        e_w <= "00000";
--        signD <= '0';
--        rshamt <= "000000";
--        lshamt <= "000000";
--        wait for 100 ns;
--        e_x <= "00000";
--        e_y <= "00000";
--        e_w <= "11111";
--        signD <= '1';
--        rshamt <= "100011"; --35
--        lshamt <= "000000";
--        wait for 100 ns;
--        e_x <= "00000";
--        e_y <= "00000";
--        e_w <= "00000";
--        signD <= '0';
--        rshamt <= "000000";
--        lshamt <= "100010";
--        wait for 100 ns;            
--    end process;

process
    begin
        e_x <= "00000000";
        e_y <= "00000000";
        e_w <= "00000000";
        signD <= '1';
        rshamt <= "0000000";
        lshamt <= "0000000";
        ovf_round <= '0';
        wait for 100 ns;
        e_x <= "00000001";
        e_y <= "00001010";
        e_w <= "00001000";
        signD <= '0';
        rshamt <= "0000000";
        lshamt <= "0000000";
        ovf_round <= '0';
        wait for 100 ns;
        e_x <= "00000111";
        e_y <= "00000000";
        e_w <= "00001000";
        signD <= '1';
        rshamt <= "0000101";
        lshamt <= "0000011";
        ovf_round <= '0';
        wait for 100 ns;
        e_x <= "00000111";
        e_y <= "00000000";
        e_w <= "00001000";
        signD <= '1';
        rshamt <= "0000111";
        lshamt <= "0000011";
        ovf_round <= '1';
        wait for 100 ns;
        e_x <= "11111111";
        e_y <= "11111111";
        e_w <= "00000000";
        signD <= '0';
        rshamt <= "0000000";
        lshamt <= "0000000";
        wait for 100 ns;
        e_x <= "00000000";
        e_y <= "00000000";
        e_w <= "11111111";
        signD <= '1';
        rshamt <= "1001010"; --74
        lshamt <= "0000000";
        wait for 100 ns;      
    end process;
end Behavioral;

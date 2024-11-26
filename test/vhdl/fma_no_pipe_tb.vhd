library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Testbench for the array_multiplier
entity fma_no_pipe_tb is
end fma_no_pipe_tb;

architecture testbench of fma_no_pipe_tb is
    -- Number of bits of the inputs and outputs
    constant FLOAT_BITS : natural := 32;        -- float16 --> 16 | float32 --> 32
    -- Number of bits for the exponent part
    constant EXP_BITS: natural := 8;            -- float16 --> 5 | float32 --> 8
    -- Number of bits for the significand part (hidden bit excluded)
    constant SIGNIF_BITS: natural := 23;        -- float16 --> 10 | float32 --> 23
    -- Bias of the exponent
    constant BIAS: natural := 127;              -- float16 --> 15 | float32 --> 127
    -- Number of bits of internal block of exp_update to prevent an internal overflow
    constant EXP_INTERN_BITS: natural := 10;    -- float16 --> 8 | float32 --> 10
    -- Number of bits of internal block of shift_distance to prevent an internal overflow
    constant SHIFT_INTERN_BITS: natural := 10;  -- float16 --> 7 | float32 --> 10 
    -- Test parameters
    constant N_DATA_TEST : natural := 11;
    constant TEST_PERIOD : time := 50 ns; --test time interval
    constant MAX_DELAY : time := 10 ns; --maximum acceptable delay
    constant CLK_PERIOD : time := 100 ns; -- clock period
    constant END_TIME : time := 1000 ns; -- end time of the simulation
    
    -- Signals for the port map
    signal in_x : std_logic_vector(FLOAT_BITS-1 downto 0);
    signal in_y : std_logic_vector(FLOAT_BITS-1 downto 0);
    signal in_w : std_logic_vector(FLOAT_BITS-1 downto 0);
    signal clk : std_logic := '1'; 
    signal clr : std_logic := '1'; 
    signal out_z : std_logic_vector(FLOAT_BITS-1 downto 0);
    signal flag_und : std_logic;
    signal flag_ovf : std_logic;
    signal flag_invalid : std_logic;
    signal out_z_expected : std_logic_vector(FLOAT_BITS-1 downto 0);
    signal flag_und_expected : std_logic;
    signal flag_ovf_expected : std_logic;
begin
    --DUV instantiation:   
    duv: entity work.fma_no_pipe
        port map(
            in_x => in_x,
            in_y => in_y,
            in_w => in_w,
            clk => clk,
            clr => clr,
            out_z => out_z,
            flag_ovf => flag_ovf,
            flag_und => flag_und,
            flag_invalid => flag_invalid);
   
    -- Stimuli generation
    clk <= not clk after CLK_PERIOD/2;
    clr <= '0',
           '0' after CLK_PERIOD+MAX_DELAY;
    
    in_x <= "00000000000000000000000000000000", 
            "10000000000000000000000000000000" after CLK_PERIOD,
            "01000000001000000000000000000000" after 2*CLK_PERIOD,
            "01111111011111111111111111111111" after 3*CLK_PERIOD,
            "00000000100000000000000000000000" after 4*CLK_PERIOD, 
            "01111111100000000000000000000000" after 5*CLK_PERIOD,
            "11111111100000000000000000000000" after 6*CLK_PERIOD,
            "01111111100000000000000000000000" after 7*CLK_PERIOD,
            "11111111100000000000000000000000" after 8*CLK_PERIOD,
            "01111111100000000000000000000000" after 9*CLK_PERIOD,
            "01111111100000000000000000000000" after 10*CLK_PERIOD,            
            "01111111110000000000000000000001" after 11*CLK_PERIOD,
            "01111111110000000000000000000001" after 12*CLK_PERIOD;
            
                       
            

    
    in_y <= "00000000000000000000000000000000",
            "00000000000000000000000000000000" after CLK_PERIOD,
            "00000000000000000000000000000000" after 2*CLK_PERIOD,
            "01111111011111111111111111111111" after 3*CLK_PERIOD,
            "00000000100000000000000000000000" after 4*CLK_PERIOD, 
            "01000000001000000000000000000000" after 5*CLK_PERIOD,
            "01000000001000000000000000000000" after 6*CLK_PERIOD,
            "01111111100000000000000000000000" after 7*CLK_PERIOD,
            "11111111100000000000000000000000" after 8*CLK_PERIOD,
            "01000000001000000000000000000000" after 9*CLK_PERIOD,
            "11111111100000000000000000000000" after 10*CLK_PERIOD,
            "01000000001000000000000000000000" after 11*CLK_PERIOD,
            "01111111110000000000000000000001" after 12*CLK_PERIOD;
            
                      

    
    in_w <= "00000000000000000000000000000000",
            "10000000000000000000000000000000" after CLK_PERIOD,
            "00000000000000000000000000000000" after 2*CLK_PERIOD,
            "01111111011111111111111111111111" after 3*CLK_PERIOD,
            "00000000000000000000000000000000" after 4*CLK_PERIOD, 
            "01000000001000000000000000000000" after 5*CLK_PERIOD,
            "01000000001000000000000000000000" after 6*CLK_PERIOD,
            "01111111100000000000000000000000" after 7*CLK_PERIOD,
            "01111111100000000000000000000000" after 8*CLK_PERIOD,
            "11111111100000000000000000000000" after 9*CLK_PERIOD,
            "01111111100000000000000000000000" after 10*CLK_PERIOD,            
            "01000000001000000000000000000000" after 11*CLK_PERIOD,
            "01111111110000000000000000000001" after 12*CLK_PERIOD;
            
                  
            
            

    
    -- Template generator
    out_z_expected <= "00000000000000000000000000000000",
                      "10000000000000000000000000000000" after CLK_PERIOD,
                      "00000000000000000000000000000000" after 2*CLK_PERIOD,
                      "01111111100000000000000000000000" after 3*CLK_PERIOD,
                      "00000000000000000000000000000000" after 4*CLK_PERIOD,
                      "01111111100000000000000000000000" after 5*CLK_PERIOD,
                      "11111111100000000000000000000000" after 6*CLK_PERIOD,
                      "01111111100000000000000000000000" after 7*CLK_PERIOD,
                      "01111111100000000000000000000000" after 8*CLK_PERIOD,
                      "01111111100000000000000000000001" after 9*CLK_PERIOD,
                      "11111111100000000000000000000001" after 10*CLK_PERIOD,                      
                      "01111111100000000000000000000001" after 11*CLK_PERIOD,
                      "01111111100000000000000000000001" after 12*CLK_PERIOD;
                      
                      

                      
    -- Comparator
--    process begin
--        if now < CLK_PERIOD + MAX_DELAY then
--            wait for CLK_PERIOD + MAX_DELAY - now;
--        elsif now < END_TIME then
--            assert out_z = out_z_expected
--                report "Mismatch at t=" & to_string(now) & " out_z=" & to_string(out_z) &
--                       " out_z_expected=" & to_string (out_z_expected) & "."
--                severity failure; 
--            wait for CLK_PERIOD - MAX_DELAY;
--            assert out_z'stable(CLK_PERIOD-MAX_DELAY)
--                report "Instability detected in t=" & to_string(now - CLK_PERIOD + MAX_DELAY) & "to t=" & to_string(now) & " interval."
--                severity failure;
--            wait for MAX_DELAY;
--        else
--            report "No error found (ended at " & to_string(now) & ").";
--            wait;
--        end if;
--    end process;        
end architecture testbench;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use IEEE.float_pkg.ALL;

-- Testbench for the array_multiplier
entity fma_random_tb is
end fma_random_tb;

architecture testbench of fma_random_tb is
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
    constant DUV_DELAY : time := 20 ns; --maximum acceptable delay
    constant CLK_PERIOD : time := 100 ns; -- clock period
    constant END_TIME : time := 1000 us; -- end time of the simulation    
    constant DATA_PATH: string := "C:/Users/caten/Desktop/Tesina ASVD/Vivado/Codici/Testbenches/" ;
    
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
    
    
    file template_file: text open read_mode is DATA_PATH & "template.txt";
    file results_file: text open write_mode is DATA_PATH & "results.txt";   
begin
    -- DUV instantiation:   
    duv: entity work.fma
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
    clr <= '0';
--    clr <= '1';
--           '0' after CLK_PERIOD+DUV_DELAY;


    -- Stimuli generation and response analyzer:    
    stimulus_generator: process
        variable current_line_in: line;
        variable current_line_out: line;
        variable current_in_x: std_logic_vector(FLOAT_BITS-1 downto 0);
        variable current_in_y: std_logic_vector(FLOAT_BITS-1 downto 0);
        variable current_in_w: std_logic_vector(FLOAT_BITS-1 downto 0);
        variable current_out_z_expected: std_logic_vector(FLOAT_BITS-1 downto 0);
        variable good_value: boolean;
        variable errors: natural := 0;
        variable i: natural := 0;
        constant str1: string := " ";
    
    begin
        while not endfile(template_file) loop
            readline(template_file, current_line_in);
            read(current_line_in, current_in_x, good_value);
                assert (good_value)
                    report "Improper value for 'in_x' in file!"
                    severity failure;
            read(current_line_in, current_in_y, good_value);
            assert (good_value)
                    report "Improper value for 'in_y' in file!"
                    severity failure;
            read(current_line_in, current_in_w, good_value);
            assert (good_value)
                    report "Improper value for 'in_z' in file!"
                    severity failure;                   
            in_x <= current_in_x;     
            in_y <= current_in_y; 
            in_w <= current_in_w; 
            
            read(current_line_in, current_out_z_expected, good_value);
            assert (good_value)
                report "Improper value for 'out_z_expected' in file!"
                severity failure;
            out_z_expected <= current_out_z_expected;
            
            wait for DUV_DELAY;
            
            if (out_z /= out_z_expected) and (i > 1) then
                report "Error detected at t=" & to_string(now) & "."
                severity error;
                errors := errors + 1;
            end if;
            
            
            
            write(current_line_out, in_x);
            write(current_line_out, str1);
            write(current_line_out, in_y);
            write(current_line_out, str1);
            write(current_line_out, in_w);
            write(current_line_out, str1);
            write(current_line_out, out_z);
            writeline(results_file, current_line_out);
 
            wait for CLK_PERIOD - DUV_DELAY;
            i := i + 1;
        end loop; 
        
        report "Errors = " & to_string(errors);                              
        file_close(template_file);
        file_close(results_file);
        wait;
    end process;
end architecture testbench;

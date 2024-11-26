library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Testbench for the array_multiplier
entity test_array_multiplier_tb is
end test_array_multiplier_tb;

architecture testbench of test_array_multiplier_tb is
    -- Number of bits of the inputs  
    constant N_BITS : natural := 24; 
    -- Test parameters
    constant N_DATA_TEST : natural := 4;
    constant TEST_PERIOD : time := 100 ns; --test time interval
    constant MAX_DELAY : time := 10 ns; --maximum acceptable delay
    
    -- Signal for the port map
    signal in_x : std_logic_vector(N_BITS-1 downto 0);   
    signal in_y : std_logic_vector(N_BITS-1 downto 0);   
    signal out_mult : std_logic_vector(2*N_BITS-1 downto 0);

    -- Define a template to generate the stimulus and the target response of the circuit
    signal template_index: natural range 0 to N_DATA_TEST-1 := 0;
    type test_data_type is record
        stimulus_in_x: std_logic_vector(N_BITS-1 downto 0);
        stimulus_in_y: std_logic_vector(N_BITS-1 downto 0);
        response: std_logic_vector(2*N_BITS-1 downto 0);
    end record;
    type template_type is array (0 to N_DATA_TEST-1) of test_data_type;
    -- Input and desired output (last)
    constant TEMPLATE: template_type := (      
--        ("0000","0001", "00000000"),
--        ("0001","0000", "00000000"),
--        ("0010","0100", "00001000"),
--        ("0011","0110", "00010010"),
--        ("0100","0001", "00000100"),
--        ("1111","1111", "11100001"),
--        ("0000","0000", "00000000"),
--        ("0001","0001", "00000001"));

        ("000000000000000000000000","000000000000000000000000", "000000000000000000000000000000000000000000000000"),
        ("111111111111111111111111","111111111111111111111111", "111111111111111111111110000000000000000000000001"),
        ("000000000000001010010011","000000000000100000110010", "000000000000000000000000000101010001100010110110"),
        ("000000000011101110111001","000000110100100101010111", "000000000000000011000100010001110000110011011111"));
        
    
begin
    duv: entity work.test_array_multiplier
        
        port map (
            in_x => in_x,
            in_y => in_y,
            out_mult => out_mult);        
        
    Stimulus_generator: process begin
        for i in template'range loop
            template_index <= i;
            in_x <= template(i).stimulus_in_x;
            in_y <= template(i).stimulus_in_y;
            wait for TEST_PERIOD;
        end loop;
        report "End of simulation. No errors found.";
    end process;
    Response_analyzer: process begin
        wait on template_index'transaction;
        wait for MAX_DELAY;
        -- Report an error if the the real outputs are different from the desired outputs
        -- The failure report the input index of the error
        assert out_mult = template(template_index).response
            report "Error at test index " & to_string(template_index) & "."
            severity failure;
    end process;
end architecture testbench;
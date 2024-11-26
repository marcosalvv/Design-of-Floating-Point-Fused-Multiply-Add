library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Testbench for the array_multiplier
entity lod16_tb is
end lod16_tb;

architecture testbench of lod16_tb is
    constant IN_N_BIT : natural := 35;
    constant OUT_N_BIT : natural := 6;
    -- Test parameters
    constant N_DATA_TEST : natural := 6;
    constant TEST_PERIOD : time := 100 ns; --test time interval
    constant MAX_DELAY : time := 10 ns; --maximum acceptable delay
    
    -- Signal for the port map
    signal in_lod: std_logic_vector(IN_N_BIT-1 downto 0);   -- deve essere di 35 bit
    signal out_lod: std_logic_vector(OUT_N_BIT-1 downto 0);

    -- Define a template to generate the stimulus and the target response of the circuit
    signal template_index: natural range 0 to N_DATA_TEST-1 := 0;
    type test_data_type is record
        stimulus: std_logic_vector(IN_N_BIT-1 downto 0);
        response: std_logic_vector(OUT_N_BIT-1 downto 0);
    end record;
    type template_type is array (0 to N_DATA_TEST-1) of test_data_type;
    -- Input and desired output (last)
    constant TEMPLATE: template_type := (       
        ("00000000000000000000000000000000001","000000"),
        ("00000000000000000000000000000000011","000001"),
        ("10000000000000000000000000000000001","100010"),
        ("00000000000000000000000000000000001","000000"),
        ("00000000010000000000011000010000001","011001"),
        ("00000000000000000000000000000000000","000000"));
    
begin
    duv: entity work.lod16
        port map (
            in_lod => in_lod,
            out_lod => out_lod);        
        
    Stimulus_generator: process begin
        for i in template'range loop
            template_index <= i;
            in_lod <= template(i).stimulus;
            wait for TEST_PERIOD;
        end loop;
        report "End of simulation. No errors found.";
    end process;
    Response_analyzer: process begin
        wait on template_index'transaction;
        wait for MAX_DELAY;
        -- Report an error if the the real outputs are different from the desired outputs
        -- The failure report the input index of the error
        assert out_lod = template(template_index).response
            report "Error at test index " & to_string(template_index) & "."
            severity failure;
    end process;
end architecture testbench;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Testbench for the array_multiplier
entity round_to_nearest_tb is
end round_to_nearest_tb;

architecture testbench of round_to_nearest_tb is
    constant IN_BITS : natural := 35;
    constant OUT_BITS : natural := 11;
    -- Test parameters
    constant N_DATA_TEST : natural := 8;
    constant TEST_PERIOD : time := 100 ns; --test time interval
    constant MAX_DELAY : time := 10 ns; --maximum acceptable delay
    
    -- Signals for the port map
    signal in_round : std_logic_vector(IN_BITS-1 downto 0);
    signal out_round : std_logic_vector(OUT_BITS-1 downto 0);
    signal ovf_round : std_logic;

    -- Define a template to generate the stimulus and the target response of the circuit
    signal template_index: natural range 0 to N_DATA_TEST-1 := 0;
    type test_data_type is record
        stimulus: std_logic_vector(IN_BITS-1 downto 0);
        response_out: std_logic_vector(OUT_BITS-1 downto 0);
        response_ovf_round: std_logic;
    end record;
    type template_type is array (0 to N_DATA_TEST-1) of test_data_type;
    -- Input and desired output (last)
    constant TEMPLATE: template_type := (
    
--        ----------LGRTTTTTTTTTTTTTTTTTTTTTT             L
        ("00000000000000000000000000000000000","00000000000",'0'),
        ("00000000001111000000000000000000000","00000000010",'0'),
        ("00000000001011000000000000000000000","00000000001",'0'),
        ("10010000001100000000000000000000000","10010000010",'0'),
        ("10000000000100000000001000100000000","10000000001",'0'),
        ("11111111111100000000100000000000000","10000000000",'1'),
        ("00000000000000000000000000000000001","00000000000",'0'),
        ("00000000000100000000000000000000001","00000000001",'0'));
                                 
begin
    duv: entity work.round_to_nearest
        generic map (
            IN_BITS => IN_BITS,
            OUT_BITS => OUT_BITS)
        port map (
            in_round => in_round,
            out_round => out_round,
            ovf_round => ovf_round);        
        
    Stimulus_generator: process begin
        for i in template'range loop
            template_index <= i;
            in_round <= template(i).stimulus;
            wait for TEST_PERIOD;
        end loop;
        report "End of simulation. No errors found.";
    end process;
    Response_analyzer: process begin
        wait on template_index'transaction;
        wait for MAX_DELAY;
        -- Report an error if the the real outputs are different from the desired outputs
        -- The failure report the input index of the error
        assert out_round = template(template_index).response_out
            report "Error at test index " & to_string(template_index) & "."
            severity failure;        
        assert ovf_round = template(template_index).response_ovf_round
            report "Error at test index " & to_string(template_index) & "."
            severity failure;    
    end process;
end architecture testbench;
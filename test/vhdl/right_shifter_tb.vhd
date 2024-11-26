library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Testbench for a bit inverter with enable
entity right_shifter_tb is
end right_shifter_tb;

architecture testbench of right_shifter_tb is
    
    constant IN_BITS : natural := 3;
    constant SHAMT_BITS : natural := 2;
    
    -- Test parameters
    constant TEST_PERIOD: time := 100 ns; --test time interval
    constant MAX_DELAY: time := 10 ns; --maximum acceptable delay
    constant N_DATA_TEST : natural := 8;
    
    -- Signal for the port map
    signal in_shift : std_logic_vector(IN_BITS-1 downto 0);
    signal rshamt : std_logic_vector(SHAMT_BITS-1 downto 0);
    signal out_shift : std_logic_vector(IN_BITS-1 downto 0);

    -- Define a template to generate the stimulus and the target response of the circuit
    signal template_index: natural range 0 to N_DATA_TEST-1 := 0;
    type test_data_type is record
        stimulus_in: std_logic_vector(IN_BITS-1 downto 0);
        stimulus_rshamt: std_logic_vector(SHAMT_BITS-1 downto 0);
        response: std_logic_vector(IN_BITS-1 downto 0);
    end record;
    type template_type is array (0 to N_DATA_TEST-1) of test_data_type;
    -- Input and desired output (last)
    constant TEMPLATE: template_type := (      
        ("000","10", "000"),
        ("001","10", "000"),
        ("010","10", "000"),
        ("011","10", "000"),
        ("100","10", "001"),
        ("101","10", "001"),
        ("110","10", "001"),
        ("111","10", "001"));
    
begin

    duv: entity work.right_shifter
        port map (
            in_shift => in_shift,
            rshamt => rshamt,
            out_shift => out_shift);        
        
    Stimulus_generator: process begin
        for i in template'range loop
            template_index <= i;
            in_shift <= template(i).stimulus_in;
            rshamt <= template(i).stimulus_rshamt;
            wait for TEST_PERIOD;
        end loop;
        report "End of simulation. No errors found.";
    end process;
    Response_analyzer: process begin
        wait on template_index'transaction;
        wait for MAX_DELAY;
        -- Report an error if the the real outputs are different from the desired outputs
        -- The failure report the input index of the error
        assert out_shift = template(template_index).response
            report "Error at test index " & to_string(template_index) & "."
            severity failure;
    end process;
end architecture testbench;
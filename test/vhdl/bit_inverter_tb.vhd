library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Testbench for a bit inverter with enable
entity bit_inverter_tb is
end bit_inverter_tb;

architecture testbench of bit_inverter_tb is
    -- Test parameters
    constant N_BITS: natural := 3; --size of inputs and outputs
    constant TEST_PERIOD: time := 100 ns; --test time interval
    constant MAX_DELAY: time := 10 ns; --maximum acceptable delay
    
    -- Signal for the port map
    signal in_inv : std_logic_vector(N_BITS-1 downto 0);   
    signal en : std_logic;
    signal out_inv : std_logic_vector(N_BITS-1 downto 0);
    
    -- Define a template to generate the stimulus and the target response of the circuit
    signal template_index: natural range 0 to 2**N_BITS-1 := 0;
    type test_data_type is record
        stimulus_en: std_logic;
        stimulus_in: std_logic_vector(N_BITS-1 downto 0);
        response: std_logic_vector(N_BITS-1 downto 0);
    end record;
    type template_type is array (0 to 2**N_BITS-1) of test_data_type;
    -- Input and desired output (last)
    constant TEMPLATE: template_type := (
        ('1',"000", "111"),
        ('1',"001", "110"),
        ('1',"010", "101"),
        ('1',"011", "100"),
        ('1',"100", "011"),
        ('0',"101", "101"),
        ('1',"110", "001"),
        ('1',"111", "000"));
    
begin
    duv: entity work.bit_inverter 
        generic map (N_BITS => N_BITS)
        port map (
            in_inv => in_inv,
            en => en,
            out_inv => out_inv
        );
  
    Stimulus_generator: process begin
        for i in template'range loop
            template_index <= i;
            en <= template(i).stimulus_en;
            in_inv <= template(i).stimulus_in;
            wait for TEST_PERIOD;
        end loop;
        report "End of simulation. No errors found.";
    end process;
    Response_analyzer: process begin
        wait on template_index'transaction;
        wait for MAX_DELAY;
        -- Report an error if the the real outputs are different from the desired outputs
        -- The failure report the input index of the error
        assert out_inv = template(template_index).response
            report "Error at test index " & to_string(template_index) & "."
            severity failure;
    end process;
end architecture testbench;

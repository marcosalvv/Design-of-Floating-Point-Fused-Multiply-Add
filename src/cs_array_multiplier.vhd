library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- A generic unsigned array multiplier with output in carry save representation
entity cs_array_multiplier is
    generic(
        -- Number of bits of the input
        N_BITS : natural := 11);
    Port ( 
        in_x : in std_logic_vector(N_BITS-1 downto 0);
        in_y : in std_logic_vector(N_BITS-1 downto 0);
        out_sum : out std_logic_vector(2*N_BITS-2 downto 0);   -- ricordarsi di aggiungere uno zero davanti
        out_carry : out std_logic_vector(N_BITS-1 downto 0));  --ricordarsi lo zeropadding lsb per portarolo a 2*N_BITS
end cs_array_multiplier;
    
architecture Structural of cs_array_multiplier is
    component cs_full_adder is
        Port(
            a : in std_logic;
            b : in std_logic;
            s_in : in std_logic;
            c_in : in std_logic; 
            s_out : out std_logic;
            c_out : out std_logic);
    end component;
    
    type type_2D is array (integer range <>, integer range <>) of std_logic;
    signal w_sum: type_2D(N_BITS downto 0, N_BITS-1 downto -1);
    signal w_carry: type_2D(N_BITS downto 0, N_BITS-1 downto 0);

    
begin
    -- Array generation of cs_full_adder
    gen_mult_i: for i in 0 to N_BITS-1 generate
        gen_mult_j: for j in 0 to N_BITS-1 generate
            cs_full_add: cs_full_adder
                port map (
                    a=>in_y(j),
                    b=>in_x(i),
                    s_in=>w_sum(i,j),
                    c_in=>w_carry(i,j),
                    s_out=>w_sum(i+1,j-1),
                    c_out=>w_carry(i+1,j));
        end generate;
    end generate;
    
    -- Assert to 0 the s_in of the first row of cs_full_adder
    s_in_first_row: for j in 0 to N_BITS-1 generate
        w_sum(0,j) <= '0';
    end generate;
    -- Assert to 0 the s_in of the last column of cs_full_adder
    s_in_last_col: for i in 0 to N_BITS-1 generate
        w_sum(i,N_BITS-1) <= '0';
    end generate;
    -- Assert to 0 the c_in of the first row of cs_full_adder
    c_in_first_row: for j in 0 to N_BITS-1 generate
        w_carry(0,j) <= '0';
    end generate;
    
    -- Link the s_out of the first column and the last row cs_full_adder to the output out_sum
    out_sum_1: for i in 0 to N_BITS-1 generate
        out_sum(i) <= w_sum(i+1,-1);
    end generate;
    out_sum_2: for j in N_BITS to 2*N_BITS-2 generate
        out_sum(j) <= w_sum(N_BITS,j-N_BITS);
    end generate;
    
    -- Link the c_out of the last row cs_full_adder to out_carry
    out_carry_1: for j in 0 to N_BITS-1 generate
        out_carry(j) <= w_carry(N_BITS,j);
    end generate;
end Structural;
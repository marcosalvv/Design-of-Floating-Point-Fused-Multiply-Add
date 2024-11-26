library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;

-- A basic floating point fused multiplier and adder,
-- that implements the operation z=x*y+w
entity fma_no_pipe is
    generic(
        -- Number of bits of the inputs and outputs
        FLOAT_BITS : natural := 32;        -- float16 --> 16 | float32 --> 32
        -- Number of bits for the exponent part
        EXP_BITS: natural := 8;            -- float16 --> 5 | float32 --> 8
        -- Number of bits for the significand part (hidden bit excluded)
        SIGNIF_BITS: natural := 23;        -- float16 --> 10 | float32 --> 23
        -- Bias of the exponent
        BIAS: natural := 127;              -- float16 --> 15 | float32 --> 127
        -- Number of bits of internal block of exp_update to prevent an internal overflow
        EXP_INTERN_BITS: natural := 10;    -- float16 --> 8 | float32 --> 10
        -- Number of bits of internal block of shift_distance to prevent an internal overflow
        SHIFT_INTERN_BITS: natural := 10; -- float16 --> 7 | float32 --> 10 
        -- Round mode
        ROUND_MODE: natural := 2); 
    port(
        in_x : in std_logic_vector(FLOAT_BITS-1 downto 0);
        in_y : in std_logic_vector(FLOAT_BITS-1 downto 0);
        in_w : in std_logic_vector(FLOAT_BITS-1 downto 0);
        clk : in std_logic; -- clock signal
        clr : in std_logic; -- clear signal
        out_z : out std_logic_vector(FLOAT_BITS-1 downto 0);
        flag_und : out std_logic;
        flag_ovf : out std_logic;
        flag_invalid : out std_logic);
        
          
end fma_no_pipe;
    
architecture Structural of fma_no_pipe is
    constant SHAMT_BITS: natural := integer(ceil(log2(real(3*(SIGNIF_BITS+1)+2))));
    
    component eop_unit is
        port(
            s_x: in std_logic;
            s_y: in std_logic;
            s_w: in std_logic;
            eop: out std_logic);
    end component;
    
    component sign_unit is
        port(
            s_x: in std_logic;
            s_y: in std_logic;
            s_w: in std_logic;
            sign_sum: in std_logic;
            s_z: out std_logic);
    end component;
    
    component shift_distance is
        generic(
            EXP_BITS : natural;     
            SIGNIF_BITS : natural;
            BIAS : natural;
            SHAMT_BITS: natural;
            SHIFT_INTERN_BITS: natural);
        port(
            e_x : in std_logic_vector(EXP_BITS-1 downto 0);
            e_y : in std_logic_vector(EXP_BITS-1 downto 0);
            e_w : in std_logic_vector(EXP_BITS-1 downto 0);
            rshamt : out std_logic_vector(SHAMT_BITS-1 downto 0);
            signD : out std_logic;
            disable : out std_logic);
    end component;
    
    component special_values is
        generic(
            EXP_BITS: natural;
            SIGNIF_BITS : natural);
        port(
            e_x: in std_logic_vector(EXP_BITS-1 downto 0);
            e_y: in std_logic_vector(EXP_BITS-1 downto 0);
            e_w: in std_logic_vector(EXP_BITS-1 downto 0);
            signif_x: in std_logic_vector(SIGNIF_BITS-1 downto 0);
            signif_y: in std_logic_vector(SIGNIF_BITS-1 downto 0);
            signif_w: in std_logic_vector(SIGNIF_BITS-1 downto 0);
            eop: in std_logic;
            zero_xyw: out std_logic;
            invalid: out std_logic);
    end component;
    
    component exp_update is
        generic(
            EXP_BITS: natural;      
            SIGNIF_BITS: natural;
            BIAS: natural;
            SHAMT_BITS: natural;
            EXP_INTERN_BITS: natural);        
        port(
            e_x : in std_logic_vector(EXP_BITS-1 downto 0);
            e_y : in std_logic_vector(EXP_BITS-1 downto 0);
            e_w : in std_logic_vector(EXP_BITS-1 downto 0);
            signD : in std_logic;
            rshamt : in std_logic_vector(SHAMT_BITS-1 downto 0);
            lshamt : in std_logic_vector(SHAMT_BITS-1 downto 0);
            ovf_round : in std_logic;
            zero_xyw : in std_logic;
            e_z : out std_logic_vector(EXP_BITS-1 downto 0);
            exp_und : out std_logic;
            exp_ovf : out std_logic);        
    end component;
      
    component bit_inverter is
        generic(
            -- Input and output number of bits 
            N_BITS : natural);
        port(
            in_inv : in std_logic_vector(N_BITS-1 downto 0);
            -- Bit inverter enable
            en : in std_logic;
            out_inv : out std_logic_vector(N_BITS-1 downto 0));
    end component;
    
    component right_shifter is
        generic(
            -- Number of bits of the input
            IN_BITS : natural;
            -- Number of bits of the shift amount
            SHAMT_BITS : natural);  -- 6 bits for float 16bit and 7 bits for float 32 bit
        Port(
            -- Input of the shifter
            in_shift : std_logic_vector(IN_BITS-1 downto 0);
            -- Number of shift positions
            rshamt : std_logic_vector(SHAMT_BITS-1 downto 0);
            -- Output of the shifter
            out_shift : out std_logic_vector(IN_BITS-1 downto 0));
    end component;
    
    component cs_array_multiplier is
        generic(
            -- Number of bits of the input
            N_BITS : natural);
        Port ( 
            in_x : in std_logic_vector(N_BITS-1 downto 0);
            in_y : in std_logic_vector(N_BITS-1 downto 0);
            out_sum : out std_logic_vector(2*N_BITS-2 downto 0);   -- ricordarsi di aggiungere uno zero davanti
            out_carry : out std_logic_vector(N_BITS-1 downto 0));  --ricordarsi lo zeropadding lsb per portarolo a 2*N_BITS
    end component;
    
    component csa_3_2 is
        generic(
            N_BITS: natural);
        Port(  
        in_x : in std_logic_vector(N_BITS-1 downto 0);
        in_y : in std_logic_vector(N_BITS-1 downto 0);
        in_w : in std_logic_vector(N_BITS-1 downto 0);
        out_sum : out std_logic_vector(N_BITS-1 downto 0);
        out_carry : out std_logic_vector(N_BITS-1 downto 0));
    end component;
    
    component adder_1c is
        generic(
            -- Number of input bits, where N_BITS=3m+2
            N_BITS: natural);
        Port (
        in_a: in std_logic_vector(N_BITS-1 downto 0);
        in_b: in std_logic_vector(N_BITS-1 downto 0);
        disable : in std_logic;
        out_add: out std_logic_vector(N_BITS-1 downto 0);
        sign_sum: out std_logic);
    end component;
    
    component lod16 is
        -- Not generalized, only work for float16
        port(
            in_lod: in std_logic_vector(3*SIGNIF_BITS+4 downto 0);  --3m+2 bits
            out_lod: out std_logic_vector(SHAMT_BITS-1 downto 0));
    end component;
    
    component lod32 is
        -- Not generalized, only work for float32
        port(
            in_lod: in std_logic_vector(3*SIGNIF_BITS+4 downto 0);  --3m+2 bits
            out_lod: out std_logic_vector(SHAMT_BITS-1 downto 0));
    end component;
    
    component left_shifter is
        generic(
            -- Number of bits of the input
            IN_BITS : natural;
            -- Number of bits of the input (6 for float16, 7 for float32)
            SHAMT_BITS : natural);  
        port(
            -- Input of the shifter
            in_shift : std_logic_vector(IN_BITS-1 downto 0);
            -- Number of shift positions
            lshamt : std_logic_vector(SHAMT_BITS-1 downto 0);
            -- Output of the shifter
            out_shift : out std_logic_vector(IN_BITS-1 downto 0));
    end component;
    
    component round_to_nearest is
        generic(
            -- Number of input bits (35 for 16float e 74 for 32float)
            IN_BITS : natural;
            -- Number of output bits (11 for 16float e 24 for 32float)
            OUT_BITS : natural);
        port(
            in_round : in std_logic_vector(IN_BITS-1 downto 0);
            out_round : out std_logic_vector(OUT_BITS-1 downto 0);
            ovf_round : out std_logic);
    end component;
    
    component round_zero is
        generic(
            -- Number of input bits (35 for 16float e 74 for 32float)
            IN_BITS : natural;
            -- Number of output bits (11 for 16float e 24 for 32float)
            OUT_BITS : natural);
        port(
            in_round : in std_logic_vector(IN_BITS-1 downto 0);
            out_round : out std_logic_vector(OUT_BITS-1 downto 0);
            ovf_round : out std_logic);
    end component;
    
    component round_pos_inf is
        generic(
            -- Number of input bits (35 for 16float e 74 for 32float)
            IN_BITS : natural;
            -- Number of output bits (11 for 16float e 24 for 32float)
            OUT_BITS : natural);
        port(
            in_round : in std_logic_vector(IN_BITS-1 downto 0);
            s_z : in std_logic;
            out_round : out std_logic_vector(OUT_BITS-1 downto 0);
            ovf_round : out std_logic);
    end component;
    component round_neg_inf is
        generic(
            -- Number of input bits (35 for 16float e 74 for 32float)
            IN_BITS : natural;
            -- Number of output bits (11 for 16float e 24 for 32float)
            OUT_BITS : natural);
        port(
            in_round : in std_logic_vector(IN_BITS-1 downto 0);
            s_z : in std_logic;
            out_round : out std_logic_vector(OUT_BITS-1 downto 0);
            ovf_round : out std_logic);
    end component;
       
    -- Signals
    signal s_x : std_logic;
    signal s_y : std_logic;
    signal s_w : std_logic;
    signal s_z : std_logic;
    signal e_x : std_logic_vector(EXP_BITS-1 downto 0);
    signal e_y : std_logic_vector(EXP_BITS-1 downto 0);
    signal e_w : std_logic_vector(EXP_BITS-1 downto 0);
    signal e_z : std_logic_vector(EXP_BITS-1 downto 0);
    signal signif_x : std_logic_vector(SIGNIF_BITS-1 downto 0); -- m bits
    signal signif_y : std_logic_vector(SIGNIF_BITS-1 downto 0); -- m bits
    signal signif_w : std_logic_vector(SIGNIF_BITS-1 downto 0); -- m bits
    signal m_x : std_logic_vector(SIGNIF_BITS downto 0); -- m bits
    signal m_y : std_logic_vector(SIGNIF_BITS downto 0); -- m bits
    signal m_w : std_logic_vector(SIGNIF_BITS downto 0); -- m bits
    signal m_z : std_logic_vector(SIGNIF_BITS downto 0); -- m bits
    signal eop : std_logic;
    signal sign_sum : std_logic;
    signal rshamt : std_logic_vector(SHAMT_BITS-1 downto 0); 
    signal lshamt : std_logic_vector(SHAMT_BITS-1 downto 0);
    signal signD : std_logic;
    signal w_inv0 : std_logic_vector(3*SIGNIF_BITS+4 downto 0); -- 3m+2 bits
    signal w_zeros_vec0 : std_logic_vector(2*SIGNIF_BITS+3 downto 0); 
    signal w_rshift_in : std_logic_vector(3*SIGNIF_BITS+4 downto 0); -- 3m+2 bits
    signal w_rshift_out : std_logic_vector(3*SIGNIF_BITS+4 downto 0); -- 3m+2 bits
    signal w_sum_vec : std_logic_vector(2*SIGNIF_BITS downto 0); -- 2m-1 bits
    signal w_carry_vec : std_logic_vector(SIGNIF_BITS downto 0); -- m bits
    signal w_zeros_vec1 : std_logic_vector(SIGNIF_BITS downto 0); -- m bits
    signal w_csa_in0 : std_logic_vector(2*SIGNIF_BITS+1 downto 0); -- 2m bits
    signal w_csa_in1 : std_logic_vector(2*SIGNIF_BITS+1 downto 0); -- 2m bits
    signal w_csa_in2 : std_logic_vector(2*SIGNIF_BITS+1 downto 0); -- 2m bits
    signal w_csa_out0 : std_logic_vector(2*SIGNIF_BITS+1 downto 0); -- 2m bits
    signal w_csa_out1 : std_logic_vector(2*SIGNIF_BITS+1 downto 0); -- 2m bits
    signal w_zeros_vec2 : std_logic_vector(SIGNIF_BITS+1 downto 0); -- m+1 bits
    signal w_add_in0 : std_logic_vector(3*SIGNIF_BITS+4 downto 0); -- 3m+2 bits
    signal w_add_in1 : std_logic_vector(3*SIGNIF_BITS+4 downto 0); -- 3m+2 bits
    signal w_add_out : std_logic_vector(3*SIGNIF_BITS+4 downto 0); -- 3m+2 bits
    signal sign_bit : std_logic;
    signal w_lshift : std_logic_vector(3*SIGNIF_BITS+4 downto 0); -- 3m+2 bits
    signal ovf_round : std_logic;
    signal subn : std_logic;
    signal sel_mux_ovf : std_logic;
    signal w_mux_ovf_in : std_logic_vector(SIGNIF_BITS downto 0);
    signal exp_und : std_logic;
    signal exp_ovf : std_logic;
    signal zero_xyw : std_logic;
    signal invalid: std_logic;
    signal valid: std_logic;
    signal lsb_m_z: std_logic;
    signal disable: std_logic;
    signal en_inv: std_logic;
    signal en_compl2: std_logic;
    
    
    -- Signals for the pipelining
    signal reg0 : std_logic_vector(6*SIGNIF_BITS+SHAMT_BITS+3*EXP_BITS+14 downto 0);
    signal reg1 : std_logic_vector(3*SIGNIF_BITS+2*SHAMT_BITS+3*EXP_BITS+12 downto 0);
    
    signal r_disable: std_logic;
    signal r_invalid : std_logic; 
    signal r_zero_xyw : std_logic;   
    signal r_s_x : std_logic;
    signal r_s_y : std_logic;
    signal r_s_w : std_logic;
    signal r_eop : std_logic;
    signal r_e_x : std_logic_vector(EXP_BITS-1 downto 0);
    signal r_e_y : std_logic_vector(EXP_BITS-1 downto 0);
    signal r_e_w : std_logic_vector(EXP_BITS-1 downto 0);
    signal r_signD : std_logic;
    signal r_rshamt : std_logic_vector(SHAMT_BITS-1 downto 0);    
    signal r_inv0 : std_logic_vector(3*SIGNIF_BITS+4 downto 0); 
    signal r_sum_vec : std_logic_vector(2*SIGNIF_BITS downto 0);
    signal r_carry_vec : std_logic_vector(SIGNIF_BITS downto 0);
    
    signal rr_invalid : std_logic;
    signal rr_zero_xyw : std_logic;   
    signal rr_s_x : std_logic;
    signal rr_s_y : std_logic;
    signal rr_s_w : std_logic;
    signal rr_eop : std_logic;
    signal r_sign_sum : std_logic;
    signal rr_e_x : std_logic_vector(EXP_BITS-1 downto 0);
    signal rr_e_y : std_logic_vector(EXP_BITS-1 downto 0);
    signal rr_e_w : std_logic_vector(EXP_BITS-1 downto 0);
    signal rr_signD : std_logic;
    signal rr_rshamt : std_logic_vector(SHAMT_BITS-1 downto 0);    
    signal r_lshamt : std_logic_vector(SHAMT_BITS-1 downto 0); 
    signal r_add_out : std_logic_vector(3*SIGNIF_BITS+4 downto 0);
    
    signal inf_nan: std_logic;
    signal nan_x: std_logic;
    signal nan_y: std_logic;
    signal nan_w: std_logic;
    
begin
    -- Separates the sign from the float inputs
    s_x <= in_x(FLOAT_BITS-1);
    s_y <= in_y(FLOAT_BITS-1);
    s_w <= in_w(FLOAT_BITS-1);
    -- Separates the exponent from the float inputs
    e_x <= in_x(FLOAT_BITS-2 downto FLOAT_BITS-EXP_BITS-1);
    e_y <= in_y(FLOAT_BITS-2 downto FLOAT_BITS-EXP_BITS-1);
    e_w <= in_w(FLOAT_BITS-2 downto FLOAT_BITS-EXP_BITS-1);
    -- Separates the significand from the float inputs
    signif_x <= in_x(SIGNIF_BITS-1 downto 0);
    signif_y <= in_y(SIGNIF_BITS-1 downto 0);
    signif_w <= in_w(SIGNIF_BITS-1 downto 0);   
    -- The hidden bit is concatenated with the significand
    m_x <= '1' & signif_x;
    m_y <= '1' & signif_y;
    m_w <= '1' & signif_w; 
    
    -- Determines the effective operation signal of the FMA   
    eop_unit_comp: eop_unit
        port map(
            s_x => s_x,
            s_y => s_y,
            s_w => s_w,
            eop => eop);
            
    -- Determines the sign of the float output
    shift_distance_comp: shift_distance
        generic map(
            EXP_BITS => EXP_BITS,
            SIGNIF_BITS => SIGNIF_BITS,
            BIAS => BIAS,
            SHAMT_BITS => SHAMT_BITS,
            SHIFT_INTERN_BITS => SHIFT_INTERN_BITS)
        port map(
            e_x => e_x,
            e_y => e_y,
            e_w => e_w,
            rshamt => rshamt,
            signD => signD,
            disable => disable);
                
    -- Determines the input for the right shifter        
    w_zeros_vec0 <= (others=>'0');
    w_rshift_in <= m_w & w_zeros_vec0;                   
    -- A right shifter with a shift amount equals to exponent difference of the inputs  
    right_shifter_comp: right_shifter
        generic map(
            IN_BITS => 3*(SIGNIF_BITS+1)+2, -- 3m+2
            SHAMT_BITS => SHAMT_BITS)
        port map(
            in_shift => w_rshift_in,
            rshamt => rshamt,
            out_shift => w_rshift_out);
            
    -- The enable of the bit_inverter is active when eop is 1 and disable is 0        
    en_inv <= (eop and (not disable));                                                   
    -- Complement the significand input w when eop=1   
    bit_inverter0: bit_inverter
        generic map(
            N_BITS => 3*(SIGNIF_BITS+1)+2)
        port map(
            in_inv => w_rshift_out,
            en => en_inv,
            out_inv => w_inv0);      
    -- Multiply the x and y significand inputs        
    cs_array_multiplier_comp: cs_array_multiplier
        generic map(
            N_BITS => SIGNIF_BITS+1)
        port map( 
            in_x => m_x,
            in_y => m_y,
            out_sum => w_sum_vec,   
            out_carry  => w_carry_vec);

    special_values_comp: special_values
        generic map(
            EXP_BITS => EXP_BITS,
            SIGNIF_BITS => SIGNIF_BITS)
        port map(
            e_x => e_x,
            e_y => e_y,
            e_w => e_w,
            signif_x => signif_x,
            signif_y => signif_y,
            signif_w => signif_w,
            eop => eop,
            zero_xyw => zero_xyw,
            invalid => invalid);
                  
    r_disable <= disable;
    r_invalid <= invalid;
    r_zero_xyw <= zero_xyw;
    r_s_x <= s_x;
    r_s_y <= s_y;
    r_s_w <= s_w;
    r_eop <= eop;
    r_e_x <= e_x;
    r_e_y <= e_y;
    r_e_w <= e_w;
    r_signD <= signD;
    r_rshamt <= rshamt;
    r_inv0 <= w_inv0;
    r_sum_vec <= w_sum_vec;
    r_carry_vec <= w_carry_vec;
        
-- The inputs of the CSA 3:2
    w_csa_in0 <= r_inv0(2*SIGNIF_BITS+1 downto 0);
    w_csa_in1 <= '0' & r_sum_vec;
    w_zeros_vec1 <= (others=>'0');
    w_csa_in2 <= r_carry_vec & w_zeros_vec1;
    -- CSA 3:2, adder with 3 inputs and 2 outputs
    csa_3_2_comp: csa_3_2
        generic map(
            N_BITS => 2*(SIGNIF_BITS+1))
        port map(  
            in_x => w_csa_in0,
            in_y => w_csa_in1,
            in_w => w_csa_in2,
            out_sum => w_csa_out0,
            out_carry => w_csa_out1);   
    w_add_in0 <= r_inv0(3*SIGNIF_BITS+4 downto 2*SIGNIF_BITS+2) & w_csa_out0;  
    w_add_in1 <= std_logic_vector(resize(unsigned(w_csa_out1 & '0'),3*(SIGNIF_BITS+1)+2));
    adder_1c_comp: adder_1c
        generic map(
            N_BITS => 3*(SIGNIF_BITS+1)+2)
        port map(
            in_a=>w_add_in0,
            in_b=>w_add_in1,
            disable=>r_disable,
            out_add=>w_add_out,
            sign_sum=>sign_sum);

    -- Determines the index of the leading one of the input             
    lod_comp: if FLOAT_BITS=16 generate
        lod16_comp: lod16
        port map(
            in_lod => w_add_out,
            out_lod => lshamt);
    elsif FLOAT_BITS=32 generate
        lod32_comp: lod32
        port map(
            in_lod => w_add_out,
            out_lod => lshamt);
    end generate;   
    
    rr_invalid <= r_invalid;
    rr_zero_xyw <= r_zero_xyw;
    rr_s_x <= r_s_x;
    rr_s_y <= r_s_y;
    rr_s_w <= r_s_w;
    rr_eop <= r_eop;
    r_sign_sum <= sign_sum;
    rr_e_x <= r_e_x;
    rr_e_y <= r_e_y;
    rr_e_w <= r_e_w;
    rr_signD <= r_signD;
    rr_rshamt <= r_rshamt;
    r_lshamt <= lshamt;
    r_add_out <= w_add_out;
     

--Determines the sign of the float output
    sign_unit_comp: sign_unit
        port map(
            s_x => rr_s_x,
            s_y => rr_s_y,
            s_w => rr_s_w,
            sign_sum => r_sign_sum,
            s_z => s_z);
        
    -- Updates the exponents of the inputs and it calculates the output exponent
    exp_update_comp: exp_update
        generic map(
            EXP_BITS => EXP_BITS,
            SIGNIF_BITS => SIGNIF_BITS,
            BIAS => BIAS,   
            SHAMT_BITS => SHAMT_BITS,
            EXP_INTERN_BITS => EXP_INTERN_BITS)
        port map(
            e_x => rr_e_x,
            e_y => rr_e_y,
            e_w => rr_e_w,
            signD => rr_signD,
            rshamt => rr_rshamt,
            lshamt => r_lshamt,
            ovf_round => ovf_round,
            zero_xyw => rr_zero_xyw,
            e_z => e_z,
            exp_und => exp_und,
            exp_ovf => exp_ovf);   
                     
-- A left shifter with a shift amount of the leading one detector output
    left_shifter_comp: left_shifter
        generic map(
            IN_BITS => 3*(SIGNIF_BITS+1)+2,
            SHAMT_BITS => SHAMT_BITS)  
        port map(
            in_shift => r_add_out,
            lshamt => r_lshamt,
            out_shift => w_lshift);
            
    
    -- Determines the index of the leading one of the input             
    round_comp: if ROUND_MODE=0 generate
        round_to_nearest_comp: round_to_nearest
            generic map(            
                IN_BITS => 3*(SIGNIF_BITS+1)+2,         
                OUT_BITS => SIGNIF_BITS+1)
            port map(
                in_round => w_lshift,
                out_round => w_mux_ovf_in,
                ovf_round => ovf_round);
    elsif ROUND_MODE=1 generate
        round_zero_comp: round_zero
            generic map(            
                IN_BITS => 3*(SIGNIF_BITS+1)+2,         
                OUT_BITS => SIGNIF_BITS+1)
            port map(
                in_round => w_lshift,
                out_round => w_mux_ovf_in,
                ovf_round => ovf_round);
    elsif ROUND_MODE=2 generate
        round_pos_inf_comp: round_pos_inf
            generic map(            
                IN_BITS => 3*(SIGNIF_BITS+1)+2,         
                OUT_BITS => SIGNIF_BITS+1)
            port map(
                in_round => w_lshift,
                s_z => s_z,
                out_round => w_mux_ovf_in,
                ovf_round => ovf_round);
    elsif ROUND_MODE=3 generate
        round_neg_inf_comp: round_neg_inf
            generic map(            
                IN_BITS => 3*(SIGNIF_BITS+1)+2,         
                OUT_BITS => SIGNIF_BITS+1)
            port map(
                in_round => w_lshift,
                s_z => s_z,
                out_round => w_mux_ovf_in,
                ovf_round => ovf_round);
    end generate;
    

    -- Mux to flush at zero in case of overflow and underflow        
    sel_mux_ovf <= (exp_ovf or exp_und);
    with sel_mux_ovf select
        m_z <= w_mux_ovf_in when '0',
               (others => '0') when others;    
    -- Change the last bit to 1 when flag_invalid is active to force NaN in the output
    lsb_m_z <= m_z(0) or rr_invalid;
    -- This signal is active when the output is valid
    valid <= not rr_invalid;
               
    -- Determines the floating output
    out_z <= s_z & e_z & m_z(SIGNIF_BITS-1 downto 1) & lsb_m_z;   
    -- Flags
    flag_ovf <= exp_ovf and valid;
    flag_und <= exp_und and (valid and (not rr_zero_xyw));
    flag_invalid <= rr_invalid;                           
end Structural;
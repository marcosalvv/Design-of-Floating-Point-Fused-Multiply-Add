library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
-- TODO: WARNING STRANO NELLA SINTESI, CONTROLLARE

-- Component for the rounding to the nearest(even to tie)
entity round_to_nearest is
    generic(
        -- Number of input bits (35 for 16float e 74 for 32float)
        IN_BITS : natural := 35;
        -- Number of output bits (11 for 16float e 24 for 32float)
        OUT_BITS : natural := 11);
    Port(
        in_round : in std_logic_vector(IN_BITS-1 downto 0);
        out_round : out std_logic_vector(OUT_BITS-1 downto 0);
        ovf_round : out std_logic);
end round_to_nearest;

architecture Behavioral of round_to_nearest is
    signal rnd : std_logic;
    signal L : std_logic;
    signal G : std_logic;
    signal R : std_logic;
    signal T : std_logic;
    signal w_mux_rnd0 : std_logic_vector(OUT_BITS downto 0);
    signal w_mux_rnd1 : std_logic_vector(OUT_BITS downto 0);
    signal w_ovf_round : std_logic;
    signal w_mux_ovf0 : std_logic_vector(OUT_BITS downto 0);
    signal w_mux_ovf1 : std_logic_vector(OUT_BITS downto 0);
    --signal w_round : std_logic_vector(OUT_BITS downto 0);
begin
    -- Least significant bit
    L <= in_round(IN_BITS-OUT_BITS);
    -- Guard bit
    G <= in_round(IN_BITS-OUT_BITS-1);
    -- Round bit
    R <= in_round(IN_BITS-OUT_BITS-2);
    -- Sticky bit
    T <= or in_round(IN_BITS-OUT_BITS-3 downto 0);
    -- rnd is a signal that indicates to round the input
    rnd <= G and (R or T or L);
    -- A mux controlled by rnd, the inputs of the mux are the entity input
    -- (with a zero as MSB for the overflow) and the input incremented by 1
    w_mux_rnd0 <= '0' & in_round(IN_BITS-1 downto IN_BITS-OUT_BITS);
    w_mux_rnd1 <= std_logic_vector(unsigned(w_mux_rnd0) + 1);
    mux_rnd: with rnd select
        w_mux_ovf0 <= w_mux_rnd0 when '0',
                      w_mux_rnd1 when others;
    -- It's the overflow flag for the rounding              
    w_ovf_round <= w_mux_ovf0(OUT_BITS);
    -- A mux that select the input shifted to right of 1 bit,
    -- when a overflow flag is activated
    w_mux_ovf1 <= w_mux_ovf0 srl 1;
    mux_ovf: with w_ovf_round select
        out_round <= w_mux_ovf0(OUT_BITS-1 downto 0) when '0',
                   w_mux_ovf1(OUT_BITS-1 downto 0) when others;
               
   -- This output indicates that occured an overflow in rounding process, it's necessary for the exponent update
    ovf_round <= w_ovf_round;
end Behavioral;
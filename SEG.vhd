library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SEG is
    generic(
            nbit : integer :=4;
            start1 : std_logic :='1';
            start2 : std_logic := '0'
    );
    Port(
            clk_in_m : in std_logic;
            steuer_in : in std_logic;
            eingang : in std_logic;
            k_in : in std_logic_vector(nbit downto 0);
            start_in_m : in std_logic;
            x_out : out std_logic_vector(nbit-1 downto 0)
    );
end SEG;

architecture Behavioral of SEG is
    component D_FF
        generic(
                start : std_logic :='1'
        );
        Port(
                clk_in : in std_logic;
                D_in : in std_logic;
                start_in : in std_logic;
                Q_out : out std_logic
        );
    end component;
    signal internal_and : std_logic_vector(nbit downto 0);
    signal internal_out : std_logic_vector(nbit-1 downto 0);
    signal internal_xor : std_logic_vector(nbit-2 downto 0);
    signal internal_input : std_logic;
    
begin

    internal_input <= (internal_and(0) xor eingang) when steuer_in ='0' else (internal_and(0));

    X0: D_FF generic map(start2) port map(clk_in=>clk_in_m,D_in=>internal_input,start_in=>start_in_m,Q_out=>internal_out(0));
    internal_and(0) <= k_in(0) and internal_and(nbit);
    x_out(0) <= internal_out(0);

    G: for i in 1 to nbit-2 generate
        Xi: D_FF generic map(start1) port map(clk_in=>clk_in_m,D_in=>internal_xor(i-1),start_in=>start_in_m,Q_out=>internal_out(i));
        internal_xor(i-1) <= internal_out(i-1) xor internal_and(i);
        internal_and(i) <= k_in(i) and internal_and(nbit);
        x_out(i) <= internal_out(i);
    end generate;
    
    internal_and(nbit-1) <= internal_and(nbit) and k_in(nbit-1);
    
    XNN: D_FF generic map(start1) port map(clk_in=>clk_in_m,D_in=>internal_xor(nbit-2),start_in=>start_in_m,Q_out=>internal_out(nbit-1));
    internal_and(nbit) <= k_in(nbit) and internal_out(nbit-1);
    internal_xor(nbit-2) <= internal_out(nbit-2) xor internal_and(nbit-1); 
    x_out(nbit-1) <= internal_out(nbit-1);

end Behavioral;

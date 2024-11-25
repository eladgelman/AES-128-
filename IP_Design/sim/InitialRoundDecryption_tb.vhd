library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InitialRoundDecryption_tb is
end InitialRoundDecryption_tb;

architecture Behavioral of InitialRoundDecryption_tb is
component InitialRoundDecryption is
port ( 
    clk: in std_logic;
    rst: in std_logic;
    in_key: in std_logic_vector(127 downto 0);
    in_block: in std_logic_vector(127 downto 0);
    out_block: out std_logic_vector(127 downto 0);    
    valid_in: in std_logic; 
    last_in: in std_logic; 
    valid_out: out std_logic; 
    last_out : out std_logic
);
end component;

--constants
constant clk_period : time := 10 ns;
--signals
signal clk, rst: std_logic:= '0';
signal in_block: std_logic_vector (127 downto 0):= x"00000000000000000000000000000000";
signal in_key: std_logic_vector (127 downto 0):= x"00000000000000000000000000000000";
signal out_block: std_logic_vector (127 downto 0);
signal valid_in: std_logic:= '0';
signal last_in: std_logic:= '0';
signal valid_out: std_logic;
signal last_out: std_logic;

begin
U1: InitialRoundDecryption port map(
    clk => clk,
    rst => rst,
    in_block => in_block,
    in_key => in_key,
    out_block => out_block,
    valid_in => valid_in,
    last_in => last_in,
    valid_out => valid_out,
    last_out => last_out
);

clk_process :process
begin
    clk <= '0';
    wait for clk_period/2; 
    clk <= '1';
    wait for clk_period/2;
end process;

process
begin
wait for 20ns;
rst <= '1';
in_block <= x"29c3505f571420f6402299b31a02d73a";
in_key <= x"28fddef86da4244accc0a4fe3b316f26";
valid_in <= '1';
last_in <= '1';
wait for 8ns;
valid_in <= '0';
last_in <= '0';

wait;
end process;
end Behavioral; 
 
--original key 54686174 73206D79 204B756E 67204675
--orginal Plaintext 54776F20 4F6E6520 4E696E65 2054776F

--key10 28fddef8 6da4244a ccc0a4fe 3b316f26
--block data (Ciphertext) 29c3505f 571420f6 402299b3 1a02d73a
--block after initial step 013e8ea7 3ab004bc 8ce23d4d 2s133b81c



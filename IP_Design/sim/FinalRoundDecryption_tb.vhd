library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FinalRoundDecryption_tb is
end FinalRoundDecryption_tb;

architecture Behavioral of FinalRoundDecryption_tb is
component FinalRoundDecryption is 
Port ( 
    clk: in std_logic;
    rst: in std_logic;
    
    inputBlock: in std_logic_vector (127 downto 0);
    inputKey: in std_logic_vector (127 downto 0);
    
    outputBlock: out std_logic_vector (127 downto 0);
    
    valid_in: in std_logic;
    last_in: in std_logic;
    valid_out: out std_logic;
    last_out: out std_logic;
    stall: in std_logic
);
end component;

--constants
constant clk_period : time := 10 ns;
--signals
signal clk, rst: std_logic:= '0';
signal inputBlock: std_logic_vector (127 downto 0):= x"00000000000000000000000000000000";
signal inputKey: std_logic_vector (127 downto 0):= x"00000000000000000000000000000000";
signal outputBlock: std_logic_vector (127 downto 0);
signal valid_in: std_logic:= '0';
signal last_in: std_logic:= '0';
signal valid_out: std_logic;
signal last_out: std_logic;
signal stall: std_logic:= '0';

begin
U1: FinalRoundDecryption port map(
    clk => clk,
    rst => rst,
    inputBlock => inputBlock,
    inputKey => inputKey,
    outputBlock => outputBlock,
    valid_in => valid_in,
    last_in => last_in,
    valid_out => valid_out,
    last_out => last_out,
    stall => stall
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
--round 10
inputBlock <= x"632fafa2eb93c7209f92abcba0c0302b";
inputKey <= x"5468617473206d79204b756e67204675";
valid_in <= '1';
last_in <= '1';
stall <= '0';
wait for 8ns;
valid_in <= '0';
last_in <= '0';
wait;
end process;
end Behavioral; 
 
---before encryption
--original key 54686174 73206d79 204b756e 67204675
--ofiginal block 54776f20 4f6e6520 4e696e65 2054776f
 
---Decryption
--last round
--key0 5468617473206d79204b756e67204675
--block10 632fafa2eb93c7209f92abcba0c0302b

--outputblock Plaintext 54776f204f6e65204e696e652054776f




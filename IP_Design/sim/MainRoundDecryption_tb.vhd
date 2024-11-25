library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MainRoundDecryption_tb is
end MainRoundDecryption_tb;

architecture Behavioral of MainRoundDecryption_tb is
component MainRoundDecryption is 
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
U1: MainRoundDecryption port map(
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
--round 1
inputBlock <= x"013e8ea73ab004bc8ce23d4d2133b81c";
inputKey <= x"bfe2bf904559fab2a16480b4f7f1cbd8";
valid_in <= '1';
last_in <= '1';
stall <= '0';
wait for 8ns;
valid_in <= '0';
last_in <= '0';

--round 2 + stall
wait for 50ns;
inputBlock <= x"338b762051667d92798febc20a3fbe67";
inputKey <= x"8e51ef21fabb4522e43d7a0656954b6c";
valid_in <= '1';
last_in <= '1';
stall <= '1';
wait for 20ns;
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
--round 0 + 1
--key10 28fddef86da4244accc0a4fe3b316f26
--ciphertext 29c3505f571420f6402299b31a02d73a
--block after AddKeyRound initial step 013e8ea73ab004bc8ce23d4d2133b81c
--key9 bfe2bf904559fab2a16480b4f7f1cbd8

--output block 338b762051667d92798febc20a3fbe67

--round 2
--key8 8e51ef21fabb4522e43d7a0656954b6c
--input block 338b762051667d92798febc20a3fbe67

--output block ed6fe27a1a675b4c840019419712dc2a


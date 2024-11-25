library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MainRoundEncryption_tb is
end MainRoundEncryption_tb;

architecture Behavioral of MainRoundEncryption_tb is
component MainRoundEncryption is 
Port (
    clk: in std_logic;
    rst: in std_logic;
    
    --main data inputs for single round hardware
    inputBlock: in std_logic_vector (127 downto 0);
    inputKey: in std_logic_vector (127 downto 0);
    roundConst: in std_logic_vector  (31 downto 0);
    
    --main data output
    outputBlock: out std_logic_vector (127 downto 0);
    outputKey: out std_logic_vector (127 downto 0);
    
    --valid and last signals
    valid_in: in std_logic;
    last_in: in std_logic;
    valid_out: out std_logic;
    last_out: out std_logic;
    stall: in std_logic
);
end component;

--constants
constant clk_period : time := 10 ns;

signal clk, rst: std_logic:= '0';
signal inputBlock: std_logic_vector (127 downto 0):= x"00000000000000000000000000000000";
signal inputKey: std_logic_vector (127 downto 0):= x"00000000000000000000000000000000";
signal roundConst: std_logic_vector  (31 downto 0):=x"00000000";
signal outputBlock: std_logic_vector (127 downto 0);
signal outputKey: std_logic_vector (127 downto 0);
signal valid_in: std_logic:= '0';
signal last_in: std_logic:= '0';
signal valid_out: std_logic;
signal last_out: std_logic;
signal stall: std_logic:= '0';

begin
U1: MainRoundEncryption port map(
    clk => clk,
    rst => rst,
    inputBlock => inputBlock,
    inputKey => inputKey,
    roundConst => roundConst,
    outputBlock => outputBlock,
    outputKey => outputKey,
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
inputBlock <= x"001f0e543c4e08596e221b0b4774311a";
inputKey <= x"5468617473206D79204B756E67204675";
roundConst <= x"01000000";
valid_in <= '1';
last_in <= '1';
stall <= '0';
wait for 8ns;
valid_in <= '0';
last_in <= '0';

--round 2 + stall
wait for 50ns;
inputBlock <= x"5847088b15b61cba59d4e2e8cd39dfce";
inputKey <= x"e232fcf191129188b159e4e6d679a293";
roundConst <= x"02000000";
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
 
--round 0 + 1
--key 5468617473206D79204B756E67204675
--block data 54776F204F6E65204E696E652054776F
--block after AddKeyRound initial step 001f0e543c4e08596e221b0b4774311a

---output round key e232fcf191129188b159e4e6d679a293
---output block 5847088b15b61cba59d4e2e8cd39dfce

--round 2
--block after AddKeyRound (round 2) 5847088b15b61cba59d4e2e8cd39dfce
--round key 1 e232fcf191129188b159e4e6d679a293

---output round key 56082007c71ab18f76435569a03af7fa
---outputblock 43c6a9620e57c0c80908ebfe3df87f37
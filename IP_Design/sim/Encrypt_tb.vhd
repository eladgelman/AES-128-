library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Encrypt_tb is
end Encrypt_tb;

architecture Behavioral of Encrypt_tb is
component Encrypt is 
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
U1: Encrypt port map(
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

clk_process: process
begin
    clk <= '0';
    wait for clk_period/2; 
    clk <= '1';
    wait for clk_period/2;
end process;

stall_process: process
begin
    wait for 200ns;
    stall <= '1';
    wait for 35ns;
    stall<= '0';
end process;

process
begin
wait for 20ns;
rst <= '1';
inputBlock <= x"54776F204F6E65204E696E652054776F";
inputKey <= x"5468617473206D79204B756E67204675";
valid_in <= '1';
last_in <= '1';
wait for 8ns;
valid_in <= '0';
last_in <= '0';
wait;
end process;

end Behavioral; 
 
--key 5468617473206D79204B756E67204675
--block data 54776F204F6E65204E696E652054776F

---outputblock 29c3505f571420f6402299b31a02d73a

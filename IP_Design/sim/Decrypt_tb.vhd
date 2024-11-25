library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Decrypt_tb is
end Decrypt_tb;

architecture Behavioral of Decrypt_tb is
component Decrypt is
Port (
    clk: in std_logic;
    rst: in std_logic;
    
    inputBlock: in std_logic_vector (127 downto 0);
    inputRoundKeys: in std_logic_vector (1407 downto 0);
    
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
signal inputBlock: std_logic_vector (127 downto 0):= X"00000000000000000000000000000000";
signal inputRoundKeys: std_logic_vector(1407 downto 0):= (others =>'0');
signal outputBlock: std_logic_vector (127 downto 0);
signal valid_in, last_in, stall: std_logic:= '0';
signal valid_out, last_out: std_logic;

begin
U1: Decrypt port map(
    clk => clk,
    rst =>rst,
    inputBlock => inputBlock,
    inputRoundKeys => inputRoundKeys,
    outputBlock => outputBlock,
    valid_in => valid_in,
    last_in => last_in,
    stall => stall,
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
inputRoundKeys <= X"5468617473206d79204b756e67204675" &
                  X"e232fcf191129188b159e4e6d679a293" &
                  X"56082007c71ab18f76435569a03af7fa" &
                  X"d2600de7157abc686339e901c3031efb" &
                  X"a11202c9b468bea1d75157a01452495b" &
                  X"b1293b3305418592d210d232c6429b69" &
                  X"bd3dc287b87c47156a6c9527ac2e0e4e" &
                  X"cc96ed1674eaaa031e863f24b2a8316a" &
                  X"8e51ef21fabb4522e43d7a0656954b6c" &
                  X"bfe2bf904559fab2a16480b4f7f1cbd8" &
                  X"28fddef86da4244accc0a4fe3b316f26" ;
                             
inputBlock <= X"29c3505f571420f6402299b31a02d73a";
valid_in <= '1';
last_in <= '1';
stall <= '0';
wait for 8ns;
valid_in <= '0';
last_in <= '0';
wait;
end process;
end Behavioral;
--decryption
---cipher text 29c3505f571420f6402299b31a02d73a
---round keys:
-- 5468617473206d79204b756e67204675
-- e232fcf191129188b159e4e6d679a293
-- 56082007c71ab18f76435569a03af7fa
-- d2600de7157abc686339e901c3031efb
-- a11202c9b468bea1d75157a01452495b
-- b1293b3305418592d210d232c6429b69
-- bd3dc287b87c47156a6c9527ac2e0e4e
-- cc96ed1674eaaa031e863f24b2a8316a
-- 8e51ef21fabb4522e43d7a0656954b6c 
-- bfe2bf904559fab2a16480b4f7f1cbd8 
-- 28fddef86da4244accc0a4fe3b316f26 

--encryption
--original key 5468617473206D79204B756E67204675
--original Plaintext 54776F204F6E65204E696E652054776F

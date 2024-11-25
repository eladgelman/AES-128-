library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity KeyExpansion_tb is
end KeyExpansion_tb;

architecture Behavioral of KeyExpansion_tb is
component KeyExpansion is
generic (
    KEY_SIZE : integer := 128  -- AES-128
);
port (
    clk : in std_logic;
    rst : in std_logic;
    in_key : in std_logic_vector(KEY_SIZE - 1 downto 0);
    round_keys : out std_logic_vector((11 * KEY_SIZE) - 1 downto 0);
    valid_in : in std_logic;
    valid_out : out std_logic 
);
end component;
--constants
constant clk_period : time := 10 ns;
--signals 
signal clk, rst: std_logic := '0';
signal in_key: std_logic_vector (128 - 1 downto 0) := X"00000000000000000000000000000000";
signal round_keys: std_logic_vector((11 * 128) - 1 downto 0);
signal valid_in : std_logic:= '0';
signal valid_out : std_logic;

begin
U1: KeyExpansion port map(
    clk => clk,
    rst => rst,
    in_key => in_key,
    round_keys => round_keys,
    valid_in => valid_in,
    valid_out  => valid_out
);

clk_process: process
begin
    report "Clock process started";
    clk <= '0';
    wait for clk_period / 2; 
    clk <= '1';
    wait for clk_period / 2;
end process;

rst_process: process
begin
rst <= '0';
wait for 20 ns;
rst <= '1';
wait;
end process;

process
begin
wait for 20ns;
in_key <= X"5668617473206d79204b756e67204675"; 
valid_in <= '1';
wait for 20ns;
valid_in <='0';
wait for 420ns;
in_key <= X"00000000000000000000000000000000"; 
valid_in <= '1';
wait for 20ns;
valid_in <='0';
wait;
end process;
end Behavioral;   
--in_key:
--56686174 73206d79 204b756e 67204675
--key rounds:
--56686174 73206d79 204b756e 67204675 
--e032fcf1 93129188 b359e4e6 d479a293 
--540820b9 c71ab131 744355d7 a03af744 
--d0603b59 177a8a68 6339dfbf c30328fb 
--a3543477 b42ebe1f d71761a0 1414495b 
--496f0d8d fd41b392 2a56d232 3e429b69 
--457bf43f b83a47ad 926c959f ac2e0ef6 
--34d0b6ae 8ceaf103 1e86649c b2a86a6a 
--76d2b499 fa38459a e4be2106 56164b6c 
--2a61e428 d059a1b2 34e780b4 62f1cbd8 
--bd7e8582 6d272430 59c0a484 3b316f5c


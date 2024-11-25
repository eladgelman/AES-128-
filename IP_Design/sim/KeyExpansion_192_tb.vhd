library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity KeyExpansion_192_tb is
end KeyExpansion_192_tb;

architecture Behavioral of KeyExpansion_192_tb is
component KeyExpansion_192 is
generic (
    KEY_SIZE : integer := 192;
    Nb: integer := 6;
    Nr: integer := 13
 
);
port (
    clk : in std_logic;
    rst : in std_logic;
    in_key : in std_logic_vector(KEY_SIZE - 1 downto 0);
    round_keys : out std_logic_vector((Nr * 128) - 1 downto 0);
    valid_in : in std_logic;
    valid_out : out std_logic 
    );
end component;
--constants
constant KEY_SIZE :integer := 192;
constant Nr :integer := 13;
constant clk_period : time := 10 ns;
--signals 
signal clk, rst: std_logic := '0';
signal in_key: std_logic_vector (KEY_SIZE - 1 downto 0) := (others=>'0');
signal round_keys: std_logic_vector((Nr * 128) - 1 downto 0);
signal valid_in : std_logic:= '0';
signal valid_out : std_logic;

begin
U1: KeyExpansion_192 port map(
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
in_key <= X"8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"; 
valid_in <= '1';
wait for 20ns;
valid_in <='0';




wait;
end process;
end Behavioral;   
--in_key:
--8e73b0f7 da0e6452 c810f32b 809079e5 62f8ead2 522c6b7b
--key rounds:
--8e73b0f7 da0e6452 c810f32b 809079e5
--62f8ead2 522c6b7b fe0c91f7 2402f5a5  
--ec12068e 6c827f6b 0e7a95b9 5c56fec2
--4db7b4bd 69b54118 85a74796 e92538fd
--e75fad44 bb095386 485af057 21efb14f
--a448f6d9 4d6dce24 aa326360 113b30e6
--a25e7ed5 83b1cf9a 27f93943 6a94f767
--c0a69407 d19da4e1 ec1786eb 6fa64971
--485f7032 22cb8755 e26d1352 33f0b7b3
--40beeb28 2f18a259 6747d26b 458c553e
--a7e1466c 9411f1df 821f750a ad07d753
--ca400538 8fcc5006 282d166a bc3ce7b5
--e98ba06f 448c773c 8ecc7204 01002202
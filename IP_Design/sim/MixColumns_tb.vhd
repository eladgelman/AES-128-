library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MixColumns_tb is
end MixColumns_tb;

architecture Behavioral of MixColumns_tb is

component MixColumns is
Port (
    a: in std_logic_vector (127 downto 0);
    mixcol: out std_logic_vector (127 downto 0)
 );
end component;

signal a: std_logic_vector(127 downto 0):= x"00000000000000000000000000000000";
signal mixcol: std_logic_vector (127 downto 0);

begin
U1: MixColumns port map(
    a => a,
    mixcol => mixcol
);

process
begin
a <= x"876e46a6f24ce78c4d904ad897ecc395";
wait;
end process;
end Behavioral;

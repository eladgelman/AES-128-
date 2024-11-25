library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Inv_MixColumns_tb is
end Inv_MixColumns_tb;

architecture Behavioral of Inv_MixColumns_tb is
component Inv_MixColumns is
Port (
    a: in std_logic_vector (127 downto 0);
    inv_mixcol: out std_logic_vector (127 downto 0)
);
end component;

signal a: std_logic_vector(127 downto 0):= x"00000000000000000000000000000000";
signal inv_mixcol: std_logic_vector (127 downto 0);

begin
U1: Inv_MixColumns port map(
    a => a,
    inv_mixcol => inv_mixcol
);

process
begin
a <= x"473794ed40d4e4a5a3703aa64c9f42bc";
wait;
end process;
end Behavioral;

--a 473794ed 40d4e4a5 a3703aa6 4c9f42bc
--inv_mixcol 876e46a6 f24ce78c 4d904ad8 97ecc395

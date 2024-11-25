library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MixColumns8_tb is
end MixColumns8_tb;

architecture Behavioral of MixColumns8_tb is
component MixColumns8 is
Port (
i1, i2, i3, i4: in std_logic_vector (7 downto 0);
data_out: out std_logic_vector (7 downto 0)
 );
end component;

signal i1, i2, i3, i4: std_logic_vector(7 downto 0):="00000000";
signal data_out: std_logic_vector (7 downto 0);

begin
U1: MixColumns8 port map(
    i1 => i1,
    i2 => i2,
    i3 => i3,
    i4 => i4,
    data_out => data_out
);

process
begin
i1 <= x"87" ;i2 <= x"6e" ;i3 <= x"46" ;i4 <= x"a6";
wait for 20ns;
i1 <= x"6e" ;i2 <= x"46" ;i3 <= x"a6" ;i4 <= x"87";
wait for 20ns;
i1 <= x"46" ;i2 <= x"a6" ;i3 <= x"87" ;i4 <= x"6e";
wait for 20ns;
i1 <= x"a6" ;i2 <= x"87" ;i3 <= x"6e" ;i4 <= x"46";

wait for 20ns;
i1 <= x"f2" ;i2 <= x"4d" ;i3 <= x"6e" ;i4 <= x"46";
wait for 20ns;
i1 <= x"87" ;i2 <= x"6e" ;i3 <= x"46" ;i4 <= x"a6";
wait for 20ns;
i1 <= x"6e" ;i2 <= x"46" ;i3 <= x"a6" ;i4 <= x"87";
wait for 20ns;
i1 <= x"46" ;i2 <= x"a6" ;i3 <= x"87" ;i4 <= x"6e";
wait for 20ns;
i1 <= x"a6" ;i2 <= x"87" ;i3 <= x"6e" ;i4 <= x"46";
wait;
end process;
end Behavioral;

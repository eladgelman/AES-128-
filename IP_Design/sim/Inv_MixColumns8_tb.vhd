library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Inv_MixColumns8_tb is
end Inv_MixColumns8_tb;

architecture Behavioral of Inv_MixColumns8_tb is
component Inv_MixColumns8 is
Port (
i1, i2, i3, i4: in std_logic_vector (7 downto 0);
data_out: out std_logic_vector (7 downto 0)
 );
end component;

signal i1, i2, i3, i4: std_logic_vector(7 downto 0):="00000000";
signal data_out: std_logic_vector (7 downto 0);

begin
U1: Inv_MixColumns8 port map(
    i1 => i1,
    i2 => i2,
    i3 => i3,
    i4 => i4,
    data_out => data_out
);

process
begin
i1 <= x"47" ;i2 <= x"37" ;i3 <= x"94" ;i4 <= x"ed";
wait for 20ns;
i1 <= x"37" ;i2 <= x"94" ;i3 <= x"ed" ;i4 <= x"47";
wait for 20ns;
i1 <= x"94" ;i2 <= x"ed" ;i3 <= x"47" ;i4 <= x"37";
wait for 20ns;
i1 <= x"ed" ;i2 <= x"47" ;i3 <= x"37" ;i4 <= x"94";
wait;
end process;

end Behavioral;

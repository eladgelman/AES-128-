library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MixColumns is
Port ( 
    a: in std_logic_vector (127 downto 0);
    mixcol: out std_logic_vector (127 downto 0)
);
end MixColumns;

architecture Behavioral of MixColumns is
component MixColumns8 is
Port (
i1, i2, i3, i4: in std_logic_vector (7 downto 0);
data_out: out std_logic_vector (7 downto 0)
 );
end component;

signal p0, p1, p2, p3, p4, p5, p6, p7, p8, p9 ,p10, p11, p12, p13, p14, p15: std_logic_vector (7 downto 0);

begin
m0: MixColumns8 port map (
    i1 => a(127 downto 120),
    i2 => a(119 downto 112),
    i3 => a(111 downto 104),
    i4 => a(103 downto 96),
    data_out => p0
);
m1: MixColumns8 port map (
    i1 => a(119 downto 112),
    i2 => a(111 downto 104),
    i3 => a(103 downto 96),
    i4 => a(127 downto 120),
    data_out => p1
);
m2: MixColumns8 port map (
    i1 => a(111 downto 104),
    i2 => a(103 downto 96),
    i3 => a(127 downto 120),
    i4 => a(119 downto 112),
    data_out => p2
);
m3: MixColumns8 port map (
    i1 => a(103 downto 96),
    i2 => a(127 downto 120),
    i3 => a(119 downto 112),
    i4 => a(111 downto 104),
    data_out => p3
);

m4: MixColumns8 port map (
    i1 => a(95 downto 88),
    i2 => a(87 downto 80),
    i3 => a(79 downto 72),
    i4 => a(71 downto 64),
    data_out => p4
);
m5: MixColumns8 port map (
    i1 => a(87 downto 80),
    i2 => a(79 downto 72),
    i3 => a(71 downto 64),
    i4 => a(95 downto 88),
    data_out => p5
);
m6: MixColumns8 port map (
    i1 => a(79 downto 72),
    i2 => a(71 downto 64),
    i3 => a(95 downto 88),
    i4 => a(87 downto 80),
    data_out => p6
);
m7: MixColumns8 port map (
    i1 => a(71 downto 64),
    i2 => a(95 downto 88),
    i3 => a(87 downto 80),
    i4 => a(79 downto 72),
    data_out => p7
);

m8: MixColumns8 port map (
    i1 => a(63 downto 56),
    i2 => a(55 downto 48),
    i3 => a(47 downto 40),
    i4 => a(39 downto 32),
    data_out => p8
);
m9: MixColumns8 port map (
    i1 => a(55 downto 48),
    i2 => a(47 downto 40),
    i3 => a(39 downto 32),
    i4 => a(63 downto 56),
    data_out => p9
);
m10: MixColumns8 port map (
    i1 => a(47 downto 40),
    i2 => a(39 downto 32),
    i3 => a(63 downto 56),
    i4 => a(55 downto 48),
    data_out => p10
);
m11: MixColumns8 port map (
    i1 => a(39 downto 32),
    i2 => a(63 downto 56),
    i3 => a(55 downto 48),
    i4 => a(47 downto 40),
    data_out => p11
);
m12: MixColumns8 port map (
    i1 => a(31 downto 24),
    i2 => a(23 downto 16),
    i3 => a(15 downto 8),
    i4 => a(7 downto 0),
    data_out => p12
);
m13: MixColumns8 port map (
    i1 => a(23 downto 16),
    i2 => a(15 downto 8),
    i3 => a(7 downto 0),
    i4 => a(31 downto 24),
    data_out => p13
);
m14: MixColumns8 port map (
    i1 => a(15 downto 8),
    i2 => a(7 downto 0),
    i3 => a(31 downto 24),
    i4 => a(23 downto 16),
    data_out => p14
);
m15: MixColumns8 port map (
    i1 => a(7 downto 0),
    i2 => a(31 downto 24),
    i3 => a(23 downto 16),
    i4 => a(15 downto 8),
    data_out => p15
);

mixcol <= p0 & p1 & p2 & p3 & p4 & p5 & p6 & p7 & p8 & p9 & p10 & p11 & p12 & p13 & p14 & p15;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Encrypt is
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
end Encrypt;

architecture Behavioral of Encrypt is
--components------------------------------------------
--MainRoundEncryption component
component MainRoundEncryption is
Port (
    clk: in std_logic;
    rst: in std_logic;
    
    inputBlock: in std_logic_vector (127 downto 0);
    inputKey: in std_logic_vector (127 downto 0);
    roundConst: in std_logic_vector  (31 downto 0);
    

    outputBlock: out std_logic_vector (127 downto 0);
    outputKey: out std_logic_vector (127 downto 0);
    

    valid_in: in std_logic;
    last_in: in std_logic;
    valid_out: out std_logic;
    last_out: out std_logic;
    stall: in std_logic
 );
end component;

--FinalRoundEncryption component (for last round)
component FinalRoundEncryption is
Port (
    clk: in std_logic;
    rst: in std_logic;
    
    inputBlock: in std_logic_vector (127 downto 0);
    inputKey: in std_logic_vector (127 downto 0);
    roundConst: in std_logic_vector  (31 downto 0);
    
    outputBlock: out std_logic_vector (127 downto 0);
    outputKey: out std_logic_vector (127 downto 0);
    
    valid_in: in std_logic;
    last_in: in std_logic;
    valid_out: out std_logic;
    last_out: out std_logic;
    stall: in std_logic
 );
end component;

--signals---------------------------------------------------------------
--blocks
signal block1: std_logic_vector(127 downto 0);
signal block2: std_logic_vector(127 downto 0);
signal block3: std_logic_vector(127 downto 0);
signal block4: std_logic_vector(127 downto 0);
signal block5: std_logic_vector(127 downto 0);
signal block6: std_logic_vector(127 downto 0);
signal block7: std_logic_vector(127 downto 0);
signal block8: std_logic_vector(127 downto 0);
signal block9: std_logic_vector(127 downto 0);
signal block10: std_logic_vector(127 downto 0);

--round keys
signal key1: std_logic_vector(127 downto 0);
signal key2: std_logic_vector(127 downto 0);
signal key3: std_logic_vector(127 downto 0);
signal key4: std_logic_vector(127 downto 0);
signal key5: std_logic_vector(127 downto 0);
signal key6: std_logic_vector(127 downto 0);
signal key7: std_logic_vector(127 downto 0);
signal key8: std_logic_vector(127 downto 0);
signal key9: std_logic_vector(127 downto 0);
signal key10: std_logic_vector(127 downto 0);

--valid and last
signal valid1: std_logic;
signal valid2: std_logic;
signal valid3: std_logic;
signal valid4: std_logic;
signal valid5: std_logic;
signal valid6: std_logic;
signal valid7: std_logic;
signal valid8: std_logic;
signal valid9: std_logic;

signal last1: std_logic;
signal last2: std_logic;
signal last3: std_logic;
signal last4: std_logic;
signal last5: std_logic;
signal last6: std_logic;
signal last7: std_logic;
signal last8: std_logic;
signal last9: std_logic;

begin
--initial round (round 0)
block1 <= inputBlock xor inputKey;

round1: MainRoundEncryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block1,
    inputKey => inputKey,
    roundConst => X"01000000",
    outputBlock => block2,
    outputKey => key1,
    valid_in => valid_in,
    last_in => last_in,
    stall => stall,
    valid_out => valid1,
    last_out => last1
);
round2: MainRoundEncryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block2,
    inputKey => key1,
    roundConst => X"02000000",
    outputBlock => block3,
    outputKey => key2,
    valid_in => valid1,
    last_in => last1,
    stall => stall,
    valid_out => valid2,
    last_out => last2
);
round3: MainRoundEncryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block3,
    inputKey => key2,
    roundConst => X"04000000",
    outputBlock => block4,
    outputKey => key3,
    valid_in => valid2,
    last_in => last2,
    stall => stall,
    valid_out => valid3,
    last_out => last3
);
round4: MainRoundEncryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block4,
    inputKey => key3,
    roundConst => X"08000000",
    outputBlock => block5,
    outputKey => key4,
    valid_in => valid3,
    last_in => last3,
    stall => stall,
    valid_out => valid4,
    last_out => last4
);
round5: MainRoundEncryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block5,
    inputKey => key4,
    roundConst => X"10000000",
    outputBlock => block6,
    outputKey => key5,
    valid_in => valid4,
    last_in => last4,
    stall => stall,
    valid_out => valid5,
    last_out => last5
);
round6: MainRoundEncryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block6,
    inputKey => key5,
    roundConst => X"20000000",
    outputBlock => block7,
    outputKey => key6,
    valid_in => valid5,
    last_in => last5,
    stall => stall,
    valid_out => valid6,
    last_out => last6
);
round7: MainRoundEncryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block7,
    inputKey => key6,
    roundConst => X"40000000",
    outputBlock => block8,
    outputKey => key7,
    valid_in => valid6,
    last_in => last6,
    stall => stall,
    valid_out => valid7,
    last_out => last7
);
round8: MainRoundEncryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block8,
    inputKey => key7,
    roundConst => X"80000000",
    outputBlock => block9,
    outputKey => key8,
    valid_in => valid7,
    last_in => last7,
    stall => stall,
    valid_out => valid8,
    last_out => last8
);
round9: MainRoundEncryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block9,
    inputKey => key8,
    roundConst => X"1b000000",
    outputBlock => block10,
    outputKey => key9,
    valid_in => valid8,
    last_in => last8,
    stall => stall,
    valid_out => valid9,
    last_out => last9
);
round10: FinalRoundEncryption 
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block10,
    inputKey => key9,
    roundConst => X"36000000",
    outputBlock => outputBlock,
    outputKey => key10,
    valid_in => valid9,
    last_in => last9,
    stall => stall,
    valid_out => valid_out,
    last_out => last_out
);

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Decrypt is
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
end Decrypt;

architecture Behavioral of Decrypt is
--constants
constant KEY_SIZE : integer := 128;
--components------------------------------------------
--initial round component
component InitialRoundDecryption is 
port ( 
    clk: in std_logic;
    rst: in std_logic;
    in_key: in std_logic_vector(127 downto 0);
    in_block: in std_logic_vector(127 downto 0);
    out_block: out std_logic_vector(127 downto 0);
    
    valid_in: in std_logic; 
    last_in: in std_logic; 
    valid_out: out std_logic; 
    last_out : out std_logic
);
end component;

--main round component
component MainRoundDecryption is
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
--final round component
component FinalRoundDecryption is 
port( 
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

--signals---------------------------------------------------------------
--blocks
signal block0: std_logic_vector(127 downto 0);
signal block1: std_logic_vector(127 downto 0);
signal block2: std_logic_vector(127 downto 0);
signal block3: std_logic_vector(127 downto 0);
signal block4: std_logic_vector(127 downto 0);
signal block5: std_logic_vector(127 downto 0);
signal block6: std_logic_vector(127 downto 0);
signal block7: std_logic_vector(127 downto 0);
signal block8: std_logic_vector(127 downto 0);
signal block9: std_logic_vector(127 downto 0);

--keys
signal key0: std_logic_vector(127 downto 0);
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
signal valid0: std_logic;
signal valid1: std_logic;
signal valid2: std_logic;
signal valid3: std_logic;
signal valid4: std_logic;
signal valid5: std_logic;
signal valid6: std_logic;
signal valid7: std_logic;
signal valid8: std_logic;
signal valid9: std_logic;

signal last0: std_logic;
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
key0 <= inputRoundKeys(11*KEY_SIZE -1 downto 10*KEY_SIZE);
key1 <= inputRoundKeys(10*KEY_SIZE -1 downto 9*KEY_SIZE);
key2 <= inputRoundKeys(9*KEY_SIZE -1 downto 8*KEY_SIZE);
key3 <= inputRoundKeys(8*KEY_SIZE -1 downto 7*KEY_SIZE);
key4 <= inputRoundKeys(7*KEY_SIZE -1 downto 6*KEY_SIZE);
key5 <= inputRoundKeys(6*KEY_SIZE -1 downto 5*KEY_SIZE);
key6 <= inputRoundKeys(5*KEY_SIZE -1 downto 4*KEY_SIZE);
key7 <= inputRoundKeys(4*KEY_SIZE -1 downto 3*KEY_SIZE);
key8 <= inputRoundKeys(3*KEY_SIZE -1 downto 2*KEY_SIZE);
key9 <= inputRoundKeys(2*KEY_SIZE -1 downto 1*KEY_SIZE);
key10 <= inputRoundKeys(1*KEY_SIZE -1 downto 0*KEY_SIZE);

--initial round (round 0)
init_round: InitialRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    in_block => inputBlock,
    in_key => key10,
    
    out_block => block0,
    
    valid_in => valid_in, 
    last_in => last_in, 
    valid_out => valid0,
    last_out => last0
);
round1: MainRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block0,
    inputKey => key9,
    outputBlock => block1,
    
    valid_in => valid0,
    last_in => last0,
    stall => stall,
    valid_out => valid1,
    last_out => last1
);
round2: MainRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block1,
    inputKey => key8,
    outputBlock => block2,
    
    valid_in => valid1,
    last_in => last1,
    stall => stall,
    valid_out => valid2,
    last_out => last2
);
round3: MainRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block2,
    inputKey => key7,
    outputBlock => block3,
    
    valid_in => valid2,
    last_in => last2,
    stall => stall,
    valid_out => valid3,
    last_out => last3
);
round4: MainRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block3,
    inputKey => key6,
    outputBlock => block4,
    
    valid_in => valid3,
    last_in => last3,
    stall => stall,
    valid_out => valid4,
    last_out => last4
);
round5: MainRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block4,
    inputKey => key5,
    outputBlock => block5,
    
    valid_in => valid4,
    last_in => last4,
    stall => stall,
    valid_out => valid5,
    last_out => last5
);
round6: MainRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block5,
    inputKey => key4,
    outputBlock => block6,
    
    valid_in => valid5,
    last_in => last5,
    stall => stall,
    valid_out => valid6,
    last_out => last6
);
round7: MainRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block6,
    inputKey => key3,
    outputBlock => block7,
    
    valid_in => valid6,
    last_in => last6,
    stall => stall,
    valid_out => valid7,
    last_out => last7
);
round8: MainRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block7,
    inputKey => key2,
    outputBlock => block8,
    
    valid_in => valid7,
    last_in => last7,
    stall => stall,
    valid_out => valid8,
    last_out => last8
);
round9: MainRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block8,
    inputKey => key1,
    outputBlock => block9,
    
    valid_in => valid8,
    last_in => last8,
    stall => stall,
    valid_out => valid9,
    last_out => last9
);
round10: FinalRoundDecryption
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block9,
    inputKey => key0,
    outputBlock => outputBlock,
    
    valid_in => valid9,
    last_in => last9,
    stall => stall,
    valid_out => valid_out,
    last_out => last_out
);

end Behavioral;
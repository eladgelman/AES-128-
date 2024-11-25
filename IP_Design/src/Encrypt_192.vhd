
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity encrypt_192 is
generic (
    KEY_SIZE : integer := 192;
    Nb: integer := 6;
    Nr: integer := 13
);   
Port (
    clk: in std_logic;
    rst: in std_logic;
    
    inputBlock: in std_logic_vector (KEY_SIZE - 1 downto 0);
    inputRoundKeys: in std_logic_vector ((Nr * 128) - 1 downto 0);
    
    outputBlock: out std_logic_vector (KEY_SIZE- 1 downto 0);
    
    --valid and last signals
    valid_in: in std_logic;
    last_in: in std_logic;
    valid_out: out std_logic;
    last_out: out std_logic;
    stall: in std_logic
 );
end encrypt_192;

architecture Behavioral of encrypt_192 is
--constants
--constant KEY_SIZE : integer := 192;
 constant Nw : integer := 4 * Nr; -- W(0),W(1),.. W(4Nr-1) as 32 bits words of expanded key wiki = 4 * R
--components------------------------------------------
component init_Round is -- new 19/04
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
    --stall => stall
);
end component;
--main round component
component mainRound is
Port (
    clk: in std_logic;
    rst: in std_logic;
    
    --main data inputs for single round hardware
    inputBlock: in std_logic_vector (127 downto 0);
    inputKey: in std_logic_vector (127 downto 0);
    --roundConst: in std_logic_vector  (31 downto 0);
    
    --main data output
    outputBlock: out std_logic_vector (127 downto 0);
    --outputKey: out std_logic_vector (127 downto 0);
    
    --valid and last signals
    valid_in: in std_logic;
    last_in: in std_logic;
    valid_out: out std_logic;
    last_out: out std_logic;
    stall: in std_logic
 );
end component;

--main round no mix columns component (for last round)
component mainRoundNoCols is
Port (
    clk: in std_logic;
    rst: in std_logic;
    
    --main data inputs for single round hardware
    inputBlock: in std_logic_vector (127 downto 0);
    inputKey: in std_logic_vector (127 downto 0);
    --roundConst: in std_logic_vector  (31 downto 0);
    
    --main data output
    outputBlock: out std_logic_vector (127 downto 0);
    --outputKey: out std_logic_vector (127 downto 0);
    
    --valid and last signals
    valid_in: in std_logic;
    last_in: in std_logic;
    valid_out: out std_logic;
    last_out: out std_logic;
    stall: in std_logic
 );
end component;

--signals---------------------------------------------------------------
--blocks
signal block0_1: std_logic_vector(127 downto 0);
signal block1_2: std_logic_vector(127 downto 0);
signal block2_3: std_logic_vector(127 downto 0);
signal block3_4: std_logic_vector(127 downto 0);
signal block4_5: std_logic_vector(127 downto 0);
signal block5_6: std_logic_vector(127 downto 0);
signal block6_7: std_logic_vector(127 downto 0);
signal block7_8: std_logic_vector(127 downto 0);
signal block8_9: std_logic_vector(127 downto 0);
signal block9_10: std_logic_vector(127 downto 0);

signal block10_11: std_logic_vector(127 downto 0);
signal block11_12: std_logic_vector(127 downto 0);
 
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

-- signal for aes 192
signal key11: std_logic_vector(127 downto 0);
signal key12: std_logic_vector(127 downto 0);

--signal endkey: std_logic_vector(127 downto 0);

--key expnetion
--signal in_key : std_logic_vector(KEY_SIZE - 1 downto 0);
--signal round_keys : std_logic_vector((11 * KEY_SIZE) - 1 downto 0);



--valid and last
--signal valid0_1: std_logic;
signal valid1_2: std_logic;
signal valid2_3: std_logic;
signal valid3_4: std_logic;
signal valid4_5: std_logic;
signal valid5_6: std_logic;
signal valid6_7: std_logic;
signal valid7_8: std_logic;
signal valid8_9: std_logic;
signal valid9_10: std_logic;
signal valid10_11: std_logic; -- 19/04

signal valid11_12: std_logic;
signal valid12_13: std_logic;

--signal last0_1: std_logic;
signal last1_2: std_logic;
signal last2_3: std_logic;
signal last3_4: std_logic;
signal last4_5: std_logic;
signal last5_6: std_logic;
signal last6_7: std_logic;
signal last7_8: std_logic;
signal last8_9: std_logic;
signal last9_10: std_logic;
signal last10_11: std_logic; -- 19/04

signal last11_12: std_logic;
signal last12_13: std_logic;



begin


key0 <= inputRoundKeys(13*128 -1 downto 12*128);
key1 <= inputRoundKeys(12*128 -1 downto 11*128);
key2 <= inputRoundKeys(11*128 -1 downto 10*128);
key3 <= inputRoundKeys(10*128 -1 downto 9*128);
key4 <= inputRoundKeys(9*128 -1 downto 8*128);
key5 <= inputRoundKeys(8*128 -1 downto 7*128);
key6 <= inputRoundKeys(7*128 -1 downto 6*128);
key7 <= inputRoundKeys(6*128 -1 downto 5*128);
key8 <= inputRoundKeys(5*128 -1 downto 4*128);
key9 <= inputRoundKeys(4*128 -1 downto 3*128);
key10 <= inputRoundKeys(3*128 -1 downto 2*128);
key11 <= inputRoundKeys(2*128 -1 downto 1*128);
key12 <= inputRoundKeys(1*128 -1 downto 0*128);




  
--initial round (round 0)
--block0_1 <= inputBlock xor key10; -- need to be change to key 10
initial_round: init_Round
port map(
    clk => clk,
    rst =>rst,
    in_block => inputBlock,
    in_key => key0,
    
    out_block => block0_1,
    
    valid_in => valid_in, --valid0_1, --valid_in
    last_in => last_in, --last0_1, --last_in
    --stall => stall,
    valid_out => valid1_2,
    last_out => last1_2

);

round1: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block0_1,
    inputKey => key1,
    outputBlock => block1_2,
    
    valid_in => valid1_2,--valid_in, --notice change from valid0_1
    last_in => last1_2,--last_in, -- notice change from last0_1
    stall => stall,
    valid_out => valid2_3,
    last_out => last2_3
);

round2: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block1_2,
    inputKey => key2,
    outputBlock => block2_3,
    
    valid_in => valid2_3,
    last_in => last2_3,
    stall => stall,
    valid_out => valid3_4,
    last_out => last3_4
);

round3: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block2_3,
    inputKey => key3,
    outputBlock => block3_4,
    
    valid_in => valid3_4,
    last_in => last3_4,
    stall => stall,
    valid_out => valid4_5,
    last_out => last4_5
);

round4: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block3_4,
    inputKey => key4,
    outputBlock => block4_5,
    
    valid_in => valid4_5,
    last_in => last4_5,
    stall => stall,
    valid_out => valid5_6,
    last_out => last5_6
);

round5: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block4_5,
    inputKey => key5,
    outputBlock => block5_6,
    
    valid_in => valid5_6,
    last_in => last5_6,
    stall => stall,
    valid_out => valid6_7,
    last_out => last6_7
);

round6: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block5_6,
    inputKey => key6,
    outputBlock => block6_7,
    
    valid_in => valid6_7,
    last_in => last6_7,
    stall => stall,
    valid_out => valid7_8,
    last_out => last7_8
);

round7: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block6_7,
    inputKey => key7,
    outputBlock => block7_8,
    
    valid_in => valid7_8,
    last_in => last7_8,
    stall => stall,
    valid_out => valid8_9,
    last_out => last8_9
);

round8: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block7_8,
    inputKey => key8,
    outputBlock => block8_9,
    
    valid_in => valid8_9,
    last_in => last8_9,
    stall => stall,
    valid_out => valid9_10,
    last_out => last9_10
);

round9: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block8_9,
    inputKey => key9,
    outputBlock => block9_10,
    
    valid_in => valid9_10,
    last_in => last9_10,
    stall => stall,
    valid_out => valid10_11,
    last_out => last10_11
);

round10: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block9_10,
    inputKey => key10,
    outputBlock => block10_11,
    
    valid_in => valid10_11,
    last_in => last10_11,
    stall => stall,
    valid_out => valid11_12,
    last_out => last11_12
);

round11: mainRound
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block10_11,
    inputKey => key11,
    outputBlock => block11_12,
    
    valid_in => valid11_12,
    last_in => last11_12,
    stall => stall,
    valid_out => valid12_13,
    last_out => last12_13
);


round12: mainRoundNoCols
port map(
    clk => clk,
    rst =>rst,
    inputBlock => block11_12,
    inputKey => key12,
    outputBlock => outputBlock,
    
    valid_in => valid12_13,
    last_in => last12_13,
    stall => stall,
    valid_out => valid_out,
    last_out => last_out
);

end Behavioral;
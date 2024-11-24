library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Encrypt_128 is
Port (
    clk: in std_logic;
    rst: in std_logic;
    input_round_keys: in std_logic_vector (1407 downto 0);
    input_block: in std_logic_vector(127 downto 0);
    output_block: out std_logic_vector(127 downto 0);
    valid_in: in std_logic; 
    last_in: in std_logic; 
    valid_out: out std_logic; 
    last_out : out std_logic;
    stall: in std_logic
 );
end Encrypt_128;

architecture Behavioral of Encrypt_128 is
--constants
constant KEY_SIZE : integer := 128;
--components------------------------------------------
component InitialRoundEncryption is 
port ( 
    clk: in std_logic;
    rst: in std_logic;
    input_key: in std_logic_vector(127 downto 0);
    input_block: in std_logic_vector(127 downto 0);
    output_block: out std_logic_vector(127 downto 0);
    valid_in: in std_logic; 
    last_in: in std_logic; 
    valid_out: out std_logic; 
    last_out : out std_logic
);
end component;
component MainRoundEncryption is
Port (
    clk: in std_logic;
    rst: in std_logic;
    input_block: in std_logic_vector (127 downto 0);
    input_key: in std_logic_vector (127 downto 0);
    output_block: out std_logic_vector (127 downto 0);
    valid_in: in std_logic;
    last_in: in std_logic;
    valid_out: out std_logic;
    last_out: out std_logic;
    stall: in std_logic
 );
end component;
component FinalRoundEncryption is
Port (
    clk: in std_logic;
    rst: in std_logic;
    input_block: in std_logic_vector (127 downto 0);
    input_key: in std_logic_vector (127 downto 0);
    output_block: out std_logic_vector (127 downto 0);
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
signal valid1: std_logic;
signal valid2: std_logic;
signal valid3: std_logic;
signal valid4: std_logic;
signal valid5: std_logic;
signal valid6: std_logic;
signal valid7: std_logic;
signal valid8: std_logic;
signal valid9: std_logic;
signal valid10: std_logic;

signal last1: std_logic;
signal last2: std_logic;
signal last3: std_logic;
signal last4: std_logic;
signal last5: std_logic;
signal last6: std_logic;
signal last7: std_logic;
signal last8: std_logic;
signal last9: std_logic;
signal last10: std_logic;

begin
key0 <= input_round_keys(11*128 -1 downto 10*128);
key1 <= input_round_keys(10*128 -1 downto 9*128);
key2 <= input_round_keys(9*128 -1 downto 8*128);
key3 <= input_round_keys(8*128 -1 downto 7*128);
key4 <= input_round_keys(7*128 -1 downto 6*128);
key5 <= input_round_keys(6*128 -1 downto 5*128);
key6 <= input_round_keys(5*128 -1 downto 4*128);
key7 <= input_round_keys(4*128 -1 downto 3*128);
key8 <= input_round_keys(3*128 -1 downto 2*128);
key9 <= input_round_keys(2*128 -1 downto 1*128);
key10 <= input_round_keys(1*128 -1 downto 0*128);


round0: InitialRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => input_block,
    input_key => key0,
    
    output_block => block1, 
    valid_in => valid_in,
    last_in => last_in,
    valid_out => valid1,
    last_out => last1
);
round1: MainRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => block1,
    input_key => key1,

    output_block => block2,
    valid_in => valid1,
    last_in => last1,
    stall => stall,
    valid_out => valid2,
    last_out => last2
);
round2: MainRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => block2,
    input_key => key2,

    output_block => block3,
    valid_in => valid2,
    last_in => last2,
    stall => stall,
    valid_out => valid3,
    last_out => last3
);
round3: MainRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => block3,
    input_key => key3,

    output_block => block4,
    valid_in => valid3,
    last_in => last3,
    stall => stall,
    valid_out => valid4,
    last_out => last4
);
round4: MainRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => block4,
    input_key => key4,

    output_block => block5,
    valid_in => valid4,
    last_in => last4,
    stall => stall,
    valid_out => valid5,
    last_out => last5
);
round5: MainRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => block5,
    input_key => key5,

    output_block => block6,
    valid_in => valid5,
    last_in => last5,
    stall => stall,
    valid_out => valid6,
    last_out => last6
);
round6: MainRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => block6,
    input_key => key6,

    output_block => block7,
    valid_in => valid6,
    last_in => last6,
    stall => stall,
    valid_out => valid7,
    last_out => last7
);
round7: MainRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => block7,
    input_key => key7,

    output_block => block8,
    valid_in => valid7,
    last_in => last7,
    stall => stall,
    valid_out => valid8,
    last_out => last8
);
round8: MainRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => block8,
    input_key => key8,

    output_block => block9,
    valid_in => valid8,
    last_in => last8,
    stall => stall,
    valid_out => valid9,
    last_out => last9
);
round9: MainRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => block9,
    input_key => key9,

    output_block => block10,
    valid_in => valid9,
    last_in => last9,
    stall => stall,
    valid_out => valid10,
    last_out => last10
);
round10: FinalRoundEncryption
port map(
    clk => clk,
    rst => rst,
    input_block => block10,
    input_key => key10,

    output_block => output_block,
    valid_in => valid10,
    last_in => last10,
    stall => stall,
    valid_out => valid_out,
    last_out => last_out
);

end Behavioral;
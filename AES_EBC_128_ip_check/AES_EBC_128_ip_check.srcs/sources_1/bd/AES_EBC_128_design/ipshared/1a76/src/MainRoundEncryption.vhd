library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MainRoundEncryption is
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
end MainRoundEncryption;

architecture Behavioral of MainRoundEncryption is
--components-------------
component MixColumns is 
Port ( 
    a: in std_logic_vector (127 downto 0);
    mix_col: out std_logic_vector (127 downto 0)
);
end component;

--forward S-box lookup array
type ram_type is array(natural range<>) of std_logic_vector (7 downto 0);
constant sbox_ram: ram_type(255 downto 0) :=
(
X"16", X"bb", X"54", X"b0", X"0f", X"2d", X"99", X"41", X"68", X"42", X"e6", X"bf", X"0d", X"89", X"a1", X"8c", 
X"df", X"28", X"55", X"ce", X"e9", X"87", X"1e", X"9b", X"94", X"8e", X"d9", X"69", X"11", X"98", X"f8", X"e1", 
X"9e", X"1d", X"c1", X"86", X"b9", X"57", X"35", X"61", X"0e", X"f6", X"03", X"48", X"66", X"b5", X"3e", X"70", 
X"8a", X"8b", X"bd", X"4b", X"1f", X"74", X"dd", X"e8", X"c6", X"b4", X"a6", X"1c", X"2e", X"25", X"78", X"ba", 
X"08", X"ae", X"7a", X"65", X"ea", X"f4", X"56", X"6c", X"a9", X"4e", X"d5", X"8d", X"6d", X"37", X"c8", X"e7", 
X"79", X"e4", X"95", X"91", X"62", X"ac", X"d3", X"c2", X"5c", X"24", X"06", X"49", X"0a", X"3a", X"32", X"e0", 
X"db", X"0b", X"5e", X"de", X"14", X"b8", X"ee", X"46", X"88", X"90", X"2a", X"22", X"dc", X"4f", X"81", X"60", 
X"73", X"19", X"5d", X"64", X"3d", X"7e", X"a7", X"c4", X"17", X"44", X"97", X"5f", X"ec", X"13", X"0c", X"cd", 
X"d2", X"f3", X"ff", X"10", X"21", X"da", X"b6", X"bc", X"f5", X"38", X"9d", X"92", X"8f", X"40", X"a3", X"51", 
X"a8", X"9f", X"3c", X"50", X"7f", X"02", X"f9", X"45", X"85", X"33", X"4d", X"43", X"fb", X"aa", X"ef", X"d0", 
X"cf", X"58", X"4c", X"4a", X"39", X"be", X"cb", X"6a", X"5b", X"b1", X"fc", X"20", X"ed", X"00", X"d1", X"53", 
X"84", X"2f", X"e3", X"29", X"b3", X"d6", X"3b", X"52", X"a0", X"5a", X"6e", X"1b", X"1a", X"2c", X"83", X"09", 
X"75", X"b2", X"27", X"eb", X"e2", X"80", X"12", X"07", X"9a", X"05", X"96", X"18", X"c3", X"23", X"c7", X"04", 
X"15", X"31", X"d8", X"71", X"f1", X"e5", X"a5", X"34", X"cc", X"f7", X"3f", X"36", X"26", X"93", X"fd", X"b7", 
X"c0", X"72", X"a4", X"9c", X"af", X"a2", X"d4", X"ad", X"f0", X"47", X"59", X"fa", X"7d", X"c9", X"82", X"ca", 
X"76", X"ab", X"d7", X"fe", X"2b", X"67", X"01", X"30", X"c5", X"6f", X"6b", X"f2", X"7b", X"77", X"7c", X"63" 
);
--signals---------------
--block signals
signal input_block_sig: std_logic_vector (127 downto 0);
signal input_key_sig : std_logic_vector (127 downto 0);

signal sub_bytes: std_logic_vector (127 downto 0);

signal temp_row0: std_logic_vector (31 downto 0);
signal temp_row1: std_logic_vector (31 downto 0);
signal temp_row2: std_logic_vector (31 downto 0);
signal temp_row3: std_logic_vector (31 downto 0);

signal shift_row0: std_logic_vector (31 downto 0);
signal shift_row1: std_logic_vector (31 downto 0);
signal shift_row2: std_logic_vector (31 downto 0);
signal shift_row3: std_logic_vector (31 downto 0);
signal shift_row: std_logic_vector (127 downto 0);

signal mix_cols: std_logic_vector (127 downto 0);

signal add_round_key: std_logic_vector (127 downto 0);

--signals between steps
signal shift_mix : std_logic_vector(127 downto 0);
signal mix_add : std_logic_vector(127 downto 0);

--valid and last signals for every step
signal valid_0 : std_logic;
signal last_0 : std_logic;
signal valid_1 : std_logic;
signal last_1 : std_logic;
signal valid_2 : std_logic;
signal last_2 : std_logic;
signal valid_3 : std_logic;
signal last_3 : std_logic; 

begin
process (clk)
begin
    if rising_edge(clk) then
        if rst = '0' then
            valid_0 <= '0';
            last_0 <= '0';
            valid_1 <= '0';
            last_1 <= '0';
            valid_2 <= '0';
            last_2 <= '0';
            valid_3 <= '0';
            last_3 <= '0';   
        else
            input_key_sig <= input_key;
            if stall = '1' then
                input_block_sig <= input_block_sig;

                temp_row0 <= temp_row0;
                temp_row1 <= temp_row1;
                temp_row2 <= temp_row2;
                temp_row3 <= temp_row3;
                
                shift_Mix <= shift_mix;
                mix_add <= mix_add;
                
                valid_0 <= valid_0;
                last_0 <= last_0;
                valid_1 <= valid_1;
                last_1 <= last_1;
                valid_2 <= valid_2;
                last_2 <= last_2;
                valid_3 <= valid_3;
                last_3 <= last_3;   
            else  
                input_block_sig <= input_block;
                
                temp_row0 <= sub_bytes(127 downto 120) & sub_bytes(95 downto 88) & sub_bytes(63 downto 56) & sub_bytes(31 downto 24);
                temp_row1 <= sub_bytes(119 downto 112) & sub_bytes(87 downto 80) & sub_bytes(55 downto 48) & sub_bytes(23 downto 16);
                temp_row2 <= sub_bytes(111 downto 104) & sub_bytes(79 downto 72) & sub_bytes(47 downto 40) & sub_bytes(15 downto 8);
                temp_row3 <= sub_bytes(103 downto 96) & sub_bytes(71 downto 64) & sub_bytes(39 downto 32) & sub_bytes(7 downto 0);

                shift_mix <= shift_row;
                mix_add <= mix_cols;
                
                valid_0 <= valid_in;
                last_0 <= last_in;
                valid_1 <= valid_0;
                last_1 <= last_0;
                valid_2 <= valid_1;
                last_2 <= last_1;
                valid_3 <= valid_2;
                last_3 <= last_2;  
            end if;
        end if;  
    end if;     
end process;
--output of internal signals to port level
valid_out <= valid_3;
last_out <= last_3;
output_block <= add_round_key;

--------------------------------------------------------------------------------------------------
--byte substitution
--sub_bytes word 0
sub_bytes(7 downto 0) <= sbox_ram(conv_integer(input_block_sig(7 downto 0)));
sub_bytes(15 downto 8) <= sbox_ram(conv_integer(input_block_sig(15 downto 8)));
sub_bytes(23 downto 16) <= sbox_ram(conv_integer(input_block_sig(23 downto 16)));
sub_bytes(31 downto 24) <= sbox_ram(conv_integer(input_block_sig(31 downto 24)));
--sub_bytes word 1
sub_bytes(39 downto 32) <= sbox_ram(conv_integer(input_block_sig(39 downto 32)));
sub_bytes(47 downto 40) <= sbox_ram(conv_integer(input_block_sig(47 downto 40)));
sub_bytes(55 downto 48) <= sbox_ram(conv_integer(input_block_sig(55 downto 48)));
sub_bytes(63 downto 56) <= sbox_ram(conv_integer(input_block_sig(63 downto 56)));
--sub_bytes word 2
sub_bytes(71 downto 64) <= sbox_ram(conv_integer(input_block_sig(71 downto 64)));
sub_bytes(79 downto 72) <= sbox_ram(conv_integer(input_block_sig(79 downto 72)));
sub_bytes(87 downto 80) <= sbox_ram(conv_integer(input_block_sig(87 downto 80)));
sub_bytes(95 downto 88) <= sbox_ram(conv_integer(input_block_sig(95 downto 88)));
--sub_bytes word 3
sub_bytes(103 downto 96) <= sbox_ram(conv_integer(input_block_sig(103 downto 96)));
sub_bytes(111 downto 104) <= sbox_ram(conv_integer(input_block_sig(111 downto 104)));
sub_bytes(119 downto 112) <= sbox_ram(conv_integer(input_block_sig(119 downto 112)));
sub_bytes(127 downto 120) <= sbox_ram(conv_integer(input_block_sig(127 downto 120)));

--shift rows
shift_row0 <= temp_row0;
shift_row1 <= temp_row1(23 downto 0) & temp_row1(31 downto 24);
shift_row2 <= temp_row2(15 downto 0) & temp_row2(31 downto 16);
shift_row3 <= temp_row3(7 downto 0) & temp_row3(31 downto 8);
--restoring the block structure from the shifted rows
shift_row <= shift_row0(31 downto 24) & shift_row1(31 downto 24) & shift_row2(31 downto 24) & shift_row3(31 downto 24) & 
            shift_row0(23 downto 16) & shift_row1(23 downto 16) & shift_row2(23 downto 16) & shift_row3(23 downto 16) & 
            shift_row0(15 downto 8) & shift_row1(15 downto 8) & shift_row2(15 downto 8) & shift_row3(15 downto 8) & 
            shift_row0(7 downto 0) & shift_row1(7 downto 0) & shift_row2(7 downto 0) & shift_row3(7 downto 0);

--mix columns
mix_columns: MixColumns
port map (
    a => shift_mix,
    mix_col => mix_cols
);

--add round key
add_round_key <= mix_add xor input_key_sig;


end Behavioral;

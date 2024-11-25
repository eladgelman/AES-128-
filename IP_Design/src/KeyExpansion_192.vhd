library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity KeyExpansion_192 is
generic (
    KEY_SIZE : integer := 192;
    Nb: integer := 6;
    Nr: integer := 13
);
port (
    clk : in std_logic;
    rst : in std_logic;
    in_key : in std_logic_vector(KEY_SIZE - 1 downto 0);
    round_keys : out std_logic_vector((Nr * 128) - 1 downto 0);
    valid_in : in std_logic;
    valid_out : out std_logic 
    );
end entity KeyExpansion_192;

architecture Behavioral of KeyExpansion_192 is
   -- constant Nb : integer := 4; -- length of the key in 32- but words wiki = N
   -- constant Nr : integer := 11; -- number if round keys needed : 11 round keys for AES 128 wiki = R
    constant Nw : integer := 4 * Nr; -- W(0),W(1),.. W(4Nr-1) as 32 bits words of expanded key wiki = 4 * R
    
--forward sbox lookup array
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
  -------------------------------------------------------------------------------------------------------   
function SubWord(word : in std_logic_vector(31 downto 0)) return std_logic_vector is
variable result : std_logic_vector(31 downto 0);
begin
    result := x"00000000";
    for i in 0 to 3 loop
        result(i*8+7 downto i*8) := sbox_ram(conv_integer(word(i*8+7 downto i*8)));
    end loop;
return result;
end function SubWord;  
------------------------------------------    
function RotWord(word : in std_logic_vector(31 downto 0)) return std_logic_vector is
variable result : std_logic_vector(31 downto 0);
begin
    result := word(23 downto 0) & word(31 downto 24);
return result;
end function RotWord;
--------------------------------------------------
function Rcon(i : in integer) return std_logic_vector is
variable rcon : std_logic_vector(31 downto 0);
begin
    case i is
        when 1 => rcon := x"01000000";
        when 2 => rcon := x"02000000";
        when 3 => rcon := x"04000000";
        when 4 => rcon := x"08000000";
        when 5 => rcon := x"10000000";
        when 6 => rcon := x"20000000";
        when 7 => rcon := x"40000000";
        when 8 => rcon := x"80000000";
        when 9 => rcon := x"1b000000";
        when 10 => rcon := x"36000000";
        when others => rcon := x"00000000";
    end case;
return rcon;
end function Rcon;
-------------------------------------------------
--signals
signal w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, 
       w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36, w37, w38, w39, 
       w40, w41, w42, w43, w44, w45, w46, w47, w48, w49, w50, w51 : std_logic_vector(31 downto 0);
--signals used for pipelining
signal a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15,
       a16, a17, a18, a19, a20, a21,a22, a23, a24, a25, a26, a27, a28, a29, 
       a30, a31, a32, a33, a34, a35, a36, a37, a38, a39, a40, a41,
       a42, a43, a44, a45, a46, a47, a48, a49, a50 : std_logic_vector(31 downto 0);
signal b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, 
       b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, 
       b29, b30, b31, b32, b33, b34, b35, b36, b37, b38, b39, b40, b41,
       b42, b43, b44, b45, b46, b47, b48, b49 : std_logic_vector(31 downto 0);
signal c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, 
       c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27, c28, 
       c29, c30, c31, c32, c33, c34, c35, c36, c37, c38, c39, c40, c41,
       c42, c43, c44, c45, c46, c47, c48 : std_logic_vector(31 downto 0);
signal d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, 
       d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, 
       d29, d30, d31, d32, d33, d34, d35, d36, d37, d38, d39, d40, d41,
       d42, d43, d44, d45, d46, d47: std_logic_vector(31 downto 0);
signal e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, 
       e16, e17, e18, e19, e20, e21, e22, e23, e24, e25, e26, e27, e28, 
       e29, e30, e31, e32, e33, e34, e35, e36, e37, e38, e39, e40, e41,
       e42, e43, e44, e45, e46 : std_logic_vector(31 downto 0);
      
--signals used for validition 
signal valid_0, valid_1, valid_2, valid_3, valid_4, valid_5, valid_6, valid_7, 
       valid_8, valid_9 : std_logic;
signal valid_10, valid_11, valid_12, valid_13, valid_14, valid_15, valid_16, 
       valid_17, valid_18, valid_19 : std_logic;
signal valid_20, valid_21, valid_22, valid_23, valid_24, valid_25, valid_26, 
       valid_27, valid_28, valid_29 : std_logic;
signal valid_30, valid_31, valid_32, valid_33, valid_34, valid_35, valid_36, valid_37, 
       valid_38, valid_39, valid_40, valid_41, valid_42, valid_43, valid_44, valid_45,
       valid_46 : std_logic;

begin
key_expand_process: process(clk)
begin
    if rising_edge(clk) then
        if rst = '0' then
            round_keys <= (others => '0');   
        else
            valid_0 <= valid_in;
            w0 <= in_key( ((KEY_SIZE-1)- 32*0)  downto (KEY_SIZE - 32*1) );
            w1 <= in_key( ((KEY_SIZE-1)- 32*1)  downto (KEY_SIZE - 32*2) );
            w2 <= in_key( ((KEY_SIZE-1)- 32*2)  downto (KEY_SIZE - 32*3) );
            w3 <= in_key( ((KEY_SIZE-1)- 32*3)  downto (KEY_SIZE - 32*4) );
            w4 <= in_key( ((KEY_SIZE-1)- 32*4)  downto (KEY_SIZE - 32*5) );
            w5 <= in_key( ((KEY_SIZE-1)- 32*5)  downto (KEY_SIZE - 32*6) );
     		
      		
            valid_1 <= valid_0;
      		w6 <= w0 xor subword(rotword(w5)) xor rcon(6/Nb);
      		a1 <= w1;
      		a2 <= w2;
      		a3 <= w3;
      		a4 <= w4;
      		a5 <= w5;
      		
      		valid_2 <= valid_1;
            w7 <= a1 xor w6;
            b2 <= a2;
            b3 <= a3;
            b4 <= a4;
            b5 <= a5;
            a6 <= w6;        

            valid_3 <= valid_2;  
            w8 <= b2 xor w7;
            c3 <= b3;
            c4 <= b4;
            c5 <= b5;
            b6 <= a6;
            a7 <= w7;

            valid_4 <= valid_3;  
            w9 <= c3 xor w8;
            d4 <= c4;
            d5 <= c5;
            c6 <= b6;
            b7 <= a7;
            a8 <= w8;

            valid_5 <= valid_4;
            w10 <= d4 xor w9;
            e5 <= d5;
            d6 <= c6;
            c7 <= b7;
            b8 <= a8;
            a9 <= w9;

            valid_6 <= valid_5;
            w11 <= e5 xor w10;
            e6 <= d6;
            d7 <= c7;
            c8 <= b8;
            b9 <= a9;
            a10 <= w10; 
            
            valid_7 <= valid_6;
            w12 <= e6 xor subword(rotword(w11)) xor rcon(12/Nb);
            e7 <= d7;
            d8 <= c8;
            c9 <= b9;
            b10 <= a10;
            a11 <= w11;  
 
            valid_8 <= valid_7;
            w13 <= e7 xor w12;
            e8 <= d8;
            d9 <= c9;
            c10 <= b10;
            b11 <= a11;
            a12 <= w12; 

            valid_9 <= valid_8;
            w14 <= e8 xor w13;
            e9 <= d9;
            d10 <= c10;
            c11 <= b11;
            b12 <= a12;
            a13 <= w13; 

            valid_10 <= valid_9;
            w15 <= e9 xor w14;
            e10 <= d10;
            d11 <= c11;
            c12 <= b12;
            b13 <= a13;
            a14 <= w14;

            valid_11 <= valid_10; 
            w16 <= e10 xor w15;
            e11 <= d11;
            d12 <= c12;
            c13 <= b13;
            b14 <= a14;
            a15 <= w15;

            valid_12 <= valid_11;
            w17 <= e11 xor w16;
            e12 <= d12;
            d13 <= c13;
            c14 <= b14;
            b15 <= a15;
            a16 <= w16;

            valid_13 <= valid_12;           
            w18 <= e12 xor subword(rotword(w17)) xor rcon(18/Nb);
            e13 <= d13;
            d14 <= c14;
            c15 <= b15;
            b16 <= a16;
            a17 <= w17;

            valid_14 <= valid_13;
            w19 <= e13 xor w18;
            e14 <= d14;
            d15 <= c15;
            c16 <= b16;
            b17 <= a17;
            a18 <= w18;

            valid_15 <= valid_14;  
            w20 <= e14 xor w19;
            e15 <= d15;
            d16 <= c16;
            c17 <= b17;
            b18 <= a18;
            a19 <= w19;

            valid_16 <= valid_15;
            w21 <= e15 xor w20;
            e16 <= d16;
            d17 <= c17;
            c18 <= b18;
            b19 <= a19;
            a20 <= w20;

            valid_17 <= valid_16;               
            w22 <= e16 xor w21;
            e17 <= d17;
            d18 <= c18;
            c19 <= b19;
            b20 <= a20;
            a21 <= w21;

            valid_18 <= valid_17;
            w23 <= e17 xor w22;
            e18 <= d18;
            d19 <= c19;
            c20 <= b20;
            b21 <= a21;
            a22 <= w22;

            valid_19 <= valid_18; 
            w24 <= e18 xor subword(rotword(w23)) xor rcon(24/Nb);
            e19 <= d19;
            d20 <= c20;
            c21 <= b21;
            b22 <= a22;
            a23 <= w23;

            valid_20 <= valid_19;  
            w25 <= e19 xor w24;
            e20 <= d20;
            d21 <= c21;
            c22 <= b22;
            b23 <= a23;
            a24 <= w24;

            valid_21 <= valid_20;              
            w26 <= e20 xor w25;
            e21 <= d21;
            d22 <= c22;
            c23 <= b23;
            b24 <= a24;
            a25 <= w25;

            valid_22 <= valid_21;
            w27 <= e21 xor w26;
            e22 <= d22;
            d23 <= c23;
            c24 <= b24;
            b25 <= a25;
            a26 <= w26;

            valid_23 <= valid_22; 
            w28 <= e22 xor w27;
            e23 <= d23;
            d24 <= c24;
            c25 <= b25;
            b26 <= a26;
            a27 <= w27;
 
            valid_24 <= valid_23; 
            w29 <= e23 xor w28;
            e24 <= d24;
            d25 <= c25;
            c26 <= b26;
            b27 <= a27;
            a28 <= w28;

            valid_25 <= valid_24;               
            w30 <= e24 xor subword(rotword(w29)) xor rcon(30/Nb);
            e25 <= d25;
            d26 <= c26;
            c27 <= b27;
            b28 <= a28;
            a29 <= w29;
            
            valid_26 <= valid_25;
            w31 <= e25 xor w30;
            e26 <= d26;
            d27 <= c27;
            c28 <= b28;
            b29 <= a29;
            a30 <= w30;

            valid_27 <= valid_26; 
            w32 <= e26 xor w31;
            e27 <= d27;
            d28 <= c28;
            c29 <= b29;
            b30 <= a30;
            a31 <= w31;

            valid_28 <= valid_27; 
            w33 <= e27 xor w32;
            e28 <= d28;
            d29 <= c29;
            c30 <= b30;
            b31 <= a31;
            a32 <= w32;

            valid_29 <= valid_28; 
            w34 <= e28 xor w33;
            e29 <= d29;
            d30 <= c30;
            c31 <= b31;
            b32 <= a32;
            a33 <= w33;

            valid_30 <= valid_29;
            w35 <= e29 xor w34;
            e30 <= d30;
            d31 <= c31;
            c32 <= b32;
            b33 <= a33;
            a34 <= w34;

            valid_31 <= valid_30;  
            w36 <= e30 xor subword(rotword(w35)) xor rcon(36/Nb);
            e31 <= d31;
            d32 <= c32;
            c33 <= b33;
            b34 <= a34;
            a35 <= w35;

            valid_32 <= valid_31; 
            w37 <= e31 xor w36;
            e32 <= d32;
            d33 <= c33;
            c34 <= b34;
            b35 <= a35;
            a36 <= w36;

            valid_33 <= valid_32;              
            w38 <= e32 xor w37;
            e33 <= d33;
            d34 <= c34;
            c35 <= b35;
            b36 <= a36;
            a37 <= w37;

            valid_34 <= valid_33;
            w39 <= e33 xor w38;
            e34 <= d34;
            d35 <= c35;
            c36 <= b36;
            b37 <= a37;
            a38 <= w38;

            valid_35 <= valid_34;  
            w40 <= e34 xor w39;
            e35 <= d35;
            d36 <= c36;
            c37 <= b37;
            b38 <= a38;
            a39 <= w39;

            valid_36 <= valid_35;
            w41 <= e35 xor w40;
            e36 <= d36;
            d37 <= c37;
            c38 <= b38;
            b39 <= a39;
            a40 <= w40;
 
            valid_37 <= valid_36;          
            w42 <= e36 xor subword(rotword(w41)) xor rcon(42/Nb);
            e37 <= d37;
            d38 <= c38;
            c39 <= b39;
            b40 <= a40;
            a41 <= w41;

            valid_38 <= valid_37;
            w43 <= e37 xor w42;
            e38 <= d38;
            d39 <= c39;
            c40 <= b40;
            b41 <= a41;
            a42 <= w42;

            valid_39 <= valid_38;
            w44 <= e38 xor w43;
            e39 <= d39;
            d40 <= c40;
            c41 <= b41;
            b42 <= a42;
            a43 <= w43;
                
            valid_40 <= valid_39;
            w45 <= e39 xor w44;
            e40 <= d40;
            d41 <= c41;
            c42 <= b42;
            b43 <= a43;
            a44 <= w44;

            valid_41 <= valid_40;
            w46 <= e40 xor w45;
            e41 <= d41;
            d42 <= c42;
            c43 <= b43;
            b44 <= a44;
            a45 <= w45;
            
            valid_42 <= valid_41;
            w47 <= e41 xor w46;
            e42 <= d42;
            d43 <= c43;
            c44 <= b44;
            b45 <= a45;
            a46 <= w46;
            
            valid_43 <= valid_42;
            w48 <= e42 xor subword(rotword(w47)) xor rcon(48/Nb);
            e43 <= d43;
            d44 <= c44;
            c45 <= b45;
            b46 <= a46;
            a47 <= w47;
  
            valid_44 <= valid_43;
            w49 <= e43 xor w48;
            e44 <= d44;
            d45 <= c45;
            c46 <= b46;
            b47 <= a47;
            a48 <= w48;

            valid_45 <= valid_44;
            w50 <= e44 xor w49;
            e45 <= d45;
            d46 <= c46;
            c47 <= b47;
            b48 <= a48;
            a49 <= w49;
            
            valid_46 <= valid_45;
            w51 <= e45 xor w50;
            e46 <= d46;
            d47 <= c47;
            c48 <= b48;
            b49 <= a49;
            a50 <= w50;


            valid_out <= valid_46;
            round_keys <= w0 & w1 & w2 & w3 & w4 & w5 & w6 & w7 & w8 & w9 
                        & w10 & w11 & w12 & w13& w14 & w15 & w16 & w17 & w18 
                        & w19 & w20 & w21 & w22 & w23 & w24 & w25 & w26 & w27 
                        & w28 & w29 & w30 & w31 & w32 & w33 & w34 & w35 & w36 
                        & w37 & w38 & w39 & w40 & w41 & w42 & w43 & w44 & w45
                        & w46 & w47 & w48 & w49 & w50 & w51;           
        end if;
    end if;
end process;   
end Behavioral;

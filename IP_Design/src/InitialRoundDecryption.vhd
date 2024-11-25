library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InitialRoundDecryption is
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
end InitialRoundDecryption;

architecture Behavioral of InitialRoundDecryption is

begin
process(clk)
begin
if rising_edge(clk) then
    if rst = '0' then 
        valid_out <= '0';
        last_out <= '0';
    else 
        valid_out <= valid_in;
        last_out <= last_in;
        out_block <= in_block xor in_key;
    end if;
end if;
end process;
end Behavioral;

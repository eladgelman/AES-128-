
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AES_EBC_tb is
end AES_EBC_tb;

architecture Behavioral of AES_EBC_tb is
component AES_EBC
generic (
    C_AXIS_TDATA_WIDTH: integer := 128
);
Port (
    --slave signals (data coming into the IP)
    s00_axis_aclk: in std_logic;
    s00_axis_aresetn: in std_logic;
    s00_axis_tdata: in std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
    s00_axis_tvalid: in std_logic;
    s00_axis_tready: out std_logic;  
    s00_axis_tlast: in std_logic;
    
    --master signals (data coming out of the IP)
    m00_axis_tdata: out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
    m00_axis_tvalid: out std_logic;
    m00_axis_tready: in std_logic;  
    m00_axis_tlast: out std_logic;  
    
     --non- AXI port
    en_decrypt: in std_logic  
);
end component;

--constants
constant clk_period : time := 10 ns;
constant C_AXIS_TDATA_WIDTH: integer := 128;
--signals

signal s00_axis_aclk: std_logic:= '0';
signal s00_axis_aresetn: std_logic:= '0';

signal s00_axis_tdata: std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0):= X"00000000000000000000000000000000";
signal s00_axis_tvalid: std_logic:= '0';
signal s00_axis_tready: std_logic;
signal s00_axis_tlast: std_logic:= '0';

signal m00_axis_tdata: std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
signal m00_axis_tvalid: std_logic;
signal m00_axis_tready: std_logic:= '0';
signal m00_axis_tlast: std_logic;

signal en_decrypt: std_logic:= '0';

begin
U1: AES_EBC port map(
    s00_axis_aclk => s00_axis_aclk,
    s00_axis_aresetn => s00_axis_aresetn,
    s00_axis_tdata => s00_axis_tdata,
    s00_axis_tvalid => s00_axis_tvalid,
    s00_axis_tready => s00_axis_tready,
    s00_axis_tlast => s00_axis_tlast,
    m00_axis_tdata => m00_axis_tdata,
    m00_axis_tvalid => m00_axis_tvalid,
    m00_axis_tready => m00_axis_tready,
    m00_axis_tlast => m00_axis_tlast,
    en_decrypt => en_decrypt
      
);

clk_process :process
begin
    s00_axis_aclk <= '0';
    wait for clk_period/2; 
    s00_axis_aclk <= '1';
    wait for clk_period/2;
end process;

process
begin
wait for 20ns;
en_decrypt <= '1';
s00_axis_aresetn <= '1';
s00_axis_tdata <= X"000102030405060708090a0b0c0d0e0f"; --X"5468617473206d79204b756e67204675";
s00_axis_tvalid <= '1';
s00_axis_tlast <= '0';
wait for 430ns;
s00_axis_tdata <= X"101112131415161718191a1b1c1d1e1f";--X"29c3505f571420f6402299b31a02d73a"; --s00_axis_tdata <= X"54776f204f6e65204e696e652054776f"; for en_decrypt <= '0';
s00_axis_tvalid <= '1';
s00_axis_tlast <= '0';
wait for 20ns;
s00_axis_tdata <= X"202122232425262728292a2b2c2d2e2f";--X"29c3505f571420f6402299b31a02d73a"; --s00_axis_tdata <= X"54776f204f6e65204e696e652054776f"; for en_decrypt <= '0';
s00_axis_tvalid <= '1';
s00_axis_tlast <= '0';
wait for 20ns;
s00_axis_tdata <= X"303132333435363738393a3b3c3d3e3f";--X"29c3505f571420f6402299b31a02d73a"; --s00_axis_tdata <= X"54776f204f6e65204e696e652054776f"; for en_decrypt <= '0';
s00_axis_tvalid <= '1';
s00_axis_tlast <= '1';
wait for 20ns;
s00_axis_tvalid <= '0';
s00_axis_tlast <= '0';
-- add master signals 
wait for 20ns;
m00_axis_tready <= '1';
wait for 440ns; -- new part 29/04
m00_axis_tready <= '0'; -- new part 29/04  --master_ready need to be HIGH when with master_valid!


wait for 20ns;
en_decrypt <= '0';
s00_axis_tdata <= X"101112131415161718191a1b1c1d1e1f"; --X"5468617473206d79204b756e67204675";
s00_axis_tvalid <= '1';
s00_axis_tlast <= '0';
wait for 20ns;
s00_axis_tdata <= X"202122232425262728292a2b2c2d2e2f";--X"29c3505f571420f6402299b31a02d73a"; --s00_axis_tdata <= X"54776f204f6e65204e696e652054776f"; for en_decrypt <= '0';
s00_axis_tvalid <= '1';
s00_axis_tlast <= '0';
wait for 20ns;
s00_axis_tdata <= X"303132333435363738393a3b3c3d3e3f";--X"29c3505f571420f6402299b31a02d73a"; --s00_axis_tdata <= X"54776f204f6e65204e696e652054776f"; for en_decrypt <= '0';
s00_axis_tvalid <= '1';
s00_axis_tlast <= '1';
wait for 20ns;
s00_axis_tvalid <= '0';
s00_axis_tlast <= '0';
---- add master signals 
wait for 20ns;
m00_axis_tready <= '1';

wait;
end process;

-- important!!! The low order bytes of the data bus are the earlier bytes in a data stream.

-- key: 5468617473206d79204b756e67204675 
-- data: 54776f204f6e65204e696e652054776f
-- chiper text: 29c3505f571420f6402299b31a02d73a

--low order bytes first
-- key_sig: 75462067, 6e754b20, 796d2073, 74616854
-- data_sig: 6f775420, 656e694e, 20656e4f, 206f7754
-- chiper text_sig: 


end Behavioral;

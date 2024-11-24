library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AES_CBC_128 is
generic (
    C_AXIS_TDATA_WIDTH: integer := 128
);
Port (
    --slave signals
    s00_axis_aclk: in std_logic;
    s00_axis_aresetn: in std_logic;
    s00_axis_tdata: in std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
    s00_axis_tvalid: in std_logic;
    s00_axis_tready: out std_logic;  
    s00_axis_tlast: in std_logic;
    
    --master signals
    m00_axis_tdata: out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
    m00_axis_tvalid: out std_logic;
    m00_axis_tready: in std_logic;  
    m00_axis_tlast: out std_logic;  
    
    --non-AXI port
    en_decrypt: in std_logic; 
    LD4_rgb: out std_logic_vector(2 downto 0) 
);
end AES_CBC_128;

architecture Behavioral of AES_CBC_128 is
--components-----------------------------------------
component KeyExpansion_128 is
generic (
    KEY_SIZE : integer := 128;  
    Nb: integer := 4; -- length of the key in 32- but words wiki = N
    Nr: integer := 11 -- number of round keys needed : 11 round keys for AES 128 wiki = R
);
port (
    clk : in std_logic;
    rst : in std_logic;
    in_key : in std_logic_vector(KEY_SIZE - 1 downto 0);
    round_keys : out std_logic_vector((Nr * 128) - 1 downto 0);
    valid_in : in std_logic;
    valid_out : out std_logic 
);
end component;
component Encrypt_128 is 
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
end component;
component Decrypt_128 is 
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
end component;
--signals--------------------------------------------
 
--signals  for CBC mode
signal iv: std_logic;
signal init: std_logic;
signal input_IV : std_logic_vector(127 downto 0);
signal input_IV_sig : std_logic_vector(127 downto 0);

-- signal to store the previous inputBlock (decrypt CBC mode)
signal temp: std_logic_vector (127 downto 0);
signal temp_sig: std_logic_vector (127 downto 0);

--signal for key expension
signal round_keys: std_logic_vector(1407 downto 0);
signal valid_key_in: std_logic;
signal valid_key_out: std_logic;

--general signals for both encryption and decryption
signal clk: std_logic;
signal rst: std_logic;
signal input_block: std_logic_vector (127 downto 0);
signal input_block_sig: std_logic_vector (127 downto 0);
signal input_key: std_logic_vector (127 downto 0); 
signal input_key_sig: std_logic_vector (127 downto 0); 
signal output_block_sig: std_logic_vector (127 downto 0);

--signals for encrypt
signal output_block_e: std_logic_vector (127 downto 0); 
signal valid_in_e: std_logic; 
signal last_in_e: std_logic; 
signal valid_out_e: std_logic; 
signal last_out_e: std_logic; 
signal stall_sig_e: std_logic; 

--signal for decrypt 
signal output_block_d: std_logic_vector (127 downto 0); 
signal valid_in_d: std_logic; 
signal last_in_d: std_logic; 
signal valid_out_d: std_logic; 
signal last_out_d: std_logic; 
signal stall_sig_d: std_logic; 

--signal for marking new read key and not input_block
signal key: std_logic;

--AXI_Stream signals
--slave signals
signal s_tdata: std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
signal s_tvalid: std_logic;
signal s_tready: std_logic;
signal s_tlast: std_logic;

--master signals
signal m_tdata: std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
signal m_tvalid: std_logic;
signal m_tready: std_logic;
signal m_tlast: std_logic;


--state machine decrypt--------------------------------
type STATE_TYPE_1 is(Idle ,Wait_For_Keys, Read_Inputs, Waiting, Write_Outputs);
signal state: STATE_TYPE_1;
-- state machine encrypt-----------------------------------------
type STATE_TYPE_2 is(Idle ,Wait_For_Keys, Read_Inputs, Waiting, Write_Outputs); 
signal state2: STATE_TYPE_2;
--------------------------------------------------------
begin
key_expansion_128 : KeyExpansion_128
port map (
    clk => s00_axis_aclk,
    rst => s00_axis_aresetn,
    in_key => input_key, -- notice: need to change input_key without *_sig for ip packging
    round_keys => round_keys,  
    valid_in => valid_key_in,
    valid_out  => valid_key_out
);
encryption: Encrypt_128
port map (
    clk => s00_axis_aclk, 
    rst => s00_axis_aresetn,
    input_block => input_block, -- notice: need to change input_block without *_sig for ip packging
    input_round_keys => round_keys, 
    output_block => output_block_e,  
    valid_in => valid_in_e, 
    last_in => last_in_e, 
    valid_out => valid_out_e, 
    last_out => last_out_e,  
    stall => stall_sig_e 

);
decryption: Decrypt_128
port map (
    clk => s00_axis_aclk, 
    rst => s00_axis_aresetn,
    input_block => input_block, -- notice: need to change input_block without *_sig for ip packging
    input_round_keys => round_keys,
    output_block => output_block_d, 
    valid_in => valid_in_d, 
    last_in => last_in_d, 
    valid_out => valid_out_d, 
    last_out => last_out_d,  
    stall => stall_sig_d 
);


--standard assignments------------------------------------
clk <= s00_axis_aclk;
rst <= s00_axis_aresetn;
--axis slave assignments
s_tdata <= s00_axis_tdata;
s_tvalid <= s00_axis_tvalid;
s00_axis_tready <= s_tready;
s_tlast <= s00_axis_tlast;

--axis master assignments
m00_axis_tdata <= m_tdata;
m00_axis_tvalid <= m_tvalid;
m_tready <= m00_axis_tready;
m00_axis_tlast <= m_tlast;

s_tready <= '1' when (state2 = Read_Inputs or state = Read_Inputs) else '0';
m_tvalid <= '1' when (state2 = Write_Outputs or state = Write_Outputs) else '0';

m_tdata <= output_block_sig; 

process(clk)
begin
if rising_edge(clk) then
    if rst = '0' then
        key <= '1';
        valid_in_e <= '0';
        last_in_e <= '0'; 
        valid_in_d <= '0';
        last_in_d <= '0'; 
        valid_key_in <= '0';
        iv <= '0'; 
        init <= '0'; 
        stall_sig_e <= '0';
        stall_sig_d <= '0'; 
        state <= Idle;
        state2 <= Idle;
    else
    if en_decrypt = '1' then
        case state is
            when Idle =>
                valid_key_in <= '0';
                valid_in_d <= '0'; 
                last_in_d <= '0'; 
                if s_tvalid = '1' and stall_sig_d = '0' then 
                    state <= Read_Inputs;
                else
                    state <= Idle;
                end if;
            when Read_Inputs =>
                if (s_tvalid = '1' and s_tready = '1') then
                    if key = '1' then
                        input_key_sig <= s_tdata;
                        valid_key_in <= '1';
                        iv <= '1'; 
                        stall_sig_d <= '0'; 
                        state <= Wait_For_Keys; 
                    elsif iv = '1' then
                    	input_IV_sig <= s_tdata;
                        iv <= '0';
                        init <= '1';
                        state <= Idle;                
                     elsif init = '1' then
                    	input_block_sig <= s_tdata; 
                        temp_sig <= input_block_sig; --previous input_block 
                        valid_in_d <= '1';
                        last_in_d <= s_tlast;
                        init <= '1'; 
                        state <= Waiting; 
                    else
                        input_block_sig <= s_tdata; 
                        temp_sig <= input_block_sig; 
                        valid_in_d <= '1';
                        last_in_d <= s_tlast;
                        stall_sig_d <= '0'; 
                        state <= waiting; 
                    end if;
                    if (s_tlast = '1') then 
                        key <= '1';
                    else
                        key <= '0';
                    end if;
                else 
                    state <= Read_Inputs;
                end if;
            when Wait_For_Keys =>
                valid_key_in <= '0';
                if valid_key_out = '1' then
                      if (s_tvalid = '1' and stall_sig_d = '0') then
                        state <= Read_Inputs;
                      else
                        state <= Idle; 
                end if;
                else
                    state <= Wait_For_Keys;
                end if;
           when waiting => 
            	valid_in_d <= '0';
                last_in_d <= '0';
                if valid_out_d = '1' and init = '1' then 
                    stall_sig_d <= '1'; 
                    state <= Write_Outputs;
                    m_tlast <= last_out_d;
                    init <= '0'; 

                    -- notice: need to change input_IV without *_sig for ip packging 
                    output_block_sig(127 downto 120) <= output_block_d(7 downto 0) xor input_IV(7 downto 0);
                    output_block_sig(119 downto 112) <= output_block_d(15 downto 8) xor input_IV(15 downto 8);
                    output_block_sig(111 downto 104) <= output_block_d(23 downto 16) xor input_IV(23 downto 16);
                    output_block_sig(103 downto 96) <= output_block_d(31 downto 24) xor input_IV(31 downto 24);
                    output_block_sig(95 downto 88) <= output_block_d(39 downto 32) xor input_IV(39 downto 32);
                    output_block_sig(87 downto 80) <= output_block_d(47 downto 40) xor input_IV(47 downto 40);
                    output_block_sig(79 downto 72) <= output_block_d(55 downto 48) xor input_IV(55 downto 48);
                    output_block_sig(71 downto 64) <= output_block_d(63 downto 56) xor input_IV(63 downto 56);
                    output_block_sig(63 downto 56) <= output_block_d(71 downto 64) xor input_IV(71 downto 64);
                    output_block_sig(55 downto 48) <= output_block_d(79 downto 72) xor input_IV(79 downto 72);
                    output_block_sig(47 downto 40) <= output_block_d(87 downto 80) xor input_IV(87 downto 80);
                    output_block_sig(39 downto 32) <= output_block_d(95 downto 88) xor input_IV(95 downto 88);
                    output_block_sig(31 downto 24) <= output_block_d(103 downto 96) xor input_IV(103 downto 96);
                    output_block_sig(23 downto 16) <= output_block_d(111 downto 104) xor input_IV(111 downto 104);
                    output_block_sig(15 downto 8) <= output_block_d(119 downto 112) xor input_IV(119 downto 112);
                    output_block_sig(7 downto 0) <= output_block_d(127 downto 120) xor input_IV(127 downto 120);
                elsif valid_out_d = '1' and init = '0' then
                	stall_sig_d <= '1'; 
                    state <= Write_Outputs;
                    m_tlast <= last_out_d;

                    -- notice: need to change temp without *_sig for ip packging 
                    output_block_sig(127 downto 120) <= output_block_d(7 downto 0) xor temp(7 downto 0);
                    output_block_sig(119 downto 112) <= output_block_d(15 downto 8) xor temp(15 downto 8);
                    output_block_sig(111 downto 104) <= output_block_d(23 downto 16) xor temp(23 downto 16);
                    output_block_sig(103 downto 96) <= output_block_d(31 downto 24) xor temp(31 downto 24);
                    output_block_sig(95 downto 88) <= output_block_d(39 downto 32) xor temp(39 downto 32);
                    output_block_sig(87 downto 80) <= output_block_d(47 downto 40) xor temp(47 downto 40);
                    output_block_sig(79 downto 72) <= output_block_d(55 downto 48) xor temp(55 downto 48);
                    output_block_sig(71 downto 64) <= output_block_d(63 downto 56) xor temp(63 downto 56);
                    output_block_sig(63 downto 56) <= output_block_d(71 downto 64) xor temp(71 downto 64);
                    output_block_sig(55 downto 48) <= output_block_d(79 downto 72) xor temp(79 downto 72);
                    output_block_sig(47 downto 40) <= output_block_d(87 downto 80) xor temp(87 downto 80);
                    output_block_sig(39 downto 32) <= output_block_d(95 downto 88) xor temp(95 downto 88);
                    output_block_sig(31 downto 24) <= output_block_d(103 downto 96) xor temp(103 downto 96);
                    output_block_sig(23 downto 16) <= output_block_d(111 downto 104) xor temp(111 downto 104);
                    output_block_sig(15 downto 8) <= output_block_d(119 downto 112) xor temp(119 downto 112);
                    output_block_sig(7 downto 0) <= output_block_d(127 downto 120) xor temp(127 downto 120);
                else
                    state <= waiting;
                    stall_sig_d <= '0';
                    m_tlast <= '0'; 
                end if;
            when Write_Outputs =>
              --if transfer complete
                if (m_tready = '1' and m_tvalid = '1') then
                    state <= Idle;
                    stall_sig_d <= '0'; 
                    m_tlast <= '0';  
                end if;
        end case; 
        --------------
        elsif en_decrypt = '0' then 
        case state2 is  
        	when Idle =>
        	    valid_key_in <= '0';
            	valid_in_e <= '0';
        		last_in_e <= '0';
                if s_tvalid = '1' then  
                	state2 <= Read_Inputs; 
                else
                	state2 <= Idle; 
                end if;
            when Read_Inputs =>
                if (s_tvalid = '1' and s_tready = '1') then
                    if key = '1' then
                        input_key_sig <= s_tdata;
                        valid_key_in <= '1';
                        iv <= '1'; 
                        stall_sig_d <= '0'; 
                        state2 <= Wait_For_Keys; 
                    elsif iv = '1' then
                    	input_IV_sig <= s_tdata;
                        iv <= '0';
                        init <= '1';
                        state2 <= Idle;
                    elsif init = '1' then
                    	input_block_sig <= s_tdata xor input_IV_sig;
                        valid_in_e <= '1';
                        last_in_e <= s_tlast;
                        init <= '0';
                        state2 <= Waiting;  
                    else
                        input_block_sig <= s_tdata xor output_block_sig; ---- notice: need to change output_block_e with *_sig for ip packging 
                        valid_in_e <= '1';
                        last_in_e <= s_tlast;
                        stall_sig_e <= '0'; 
                        state2 <= waiting; 
                    end if;
                    if (s_tlast = '1') then 
                        key <= '1';
                    else
                        key <= '0';
                    end if;
                else
                	state2 <= Read_Inputs; 
                end if;
            when Wait_For_Keys =>
                valid_key_in <= '0';  
                if valid_key_out = '1' then
                      if (s_tvalid = '1' and stall_sig_e = '0') then
                        state2 <= Read_Inputs;
                      else
                        state2 <= Idle; 
                end if;
                else
                    state2 <= Wait_For_Keys;
                end if;
            when waiting => 
            	valid_in_e <= '0';
                last_in_e <= '0';
                if valid_out_e = '1' then 
                    stall_sig_e <= '1'; 
                    state2 <= Write_Outputs;
                    m_tlast <= last_out_e;

                    output_block_sig(127 downto 120) <= output_block_e(7 downto 0);
                    output_block_sig(119 downto 112) <= output_block_e(15 downto 8);
                    output_block_sig(111 downto 104) <= output_block_e(23 downto 16);
                    output_block_sig(103 downto 96) <= output_block_e(31 downto 24);
                    output_block_sig(95 downto 88) <= output_block_e(39 downto 32);
                    output_block_sig(87 downto 80) <= output_block_e(47 downto 40);
                    output_block_sig(79 downto 72) <= output_block_e(55 downto 48);
                    output_block_sig(71 downto 64) <= output_block_e(63 downto 56);
                    output_block_sig(63 downto 56) <= output_block_e(71 downto 64);
                    output_block_sig(55 downto 48) <= output_block_e(79 downto 72);
                    output_block_sig(47 downto 40) <= output_block_e(87 downto 80);
                    output_block_sig(39 downto 32) <= output_block_e(95 downto 88);
                    output_block_sig(31 downto 24) <= output_block_e(103 downto 96);
                    output_block_sig(23 downto 16) <= output_block_e(111 downto 104);
                    output_block_sig(15 downto 8) <= output_block_e(119 downto 112);
                    output_block_sig(7 downto 0) <= output_block_e(127 downto 120);
                else
                    state2 <= waiting; 
                    stall_sig_e <= '0';
                    m_tlast <= '0'; 
                end if;
           
            when Write_Outputs =>
              --if transfer complete
                if (m_tready = '1' and m_tvalid = '1') then
                    state2 <= Idle; 
                    stall_sig_e <= '1';
                    m_tlast <= '0'; 
                end if;
            end case;
        end if;
    end if;
 end if;
 end process;

--LD4 led indicate to user if en_decrypt = '1', and LD4_led ouput port use as input for AXI GPIO ip
process(en_decrypt)
begin
if en_decrypt = '1' then
    LD4_rgb <= "001";  
else
    LD4_rgb <= "000";  
end if;
end process;

--reverse bytes
input_block(127 downto 120) <= input_block_sig(7 downto 0);
input_block(119 downto 112) <= input_block_sig(15 downto 8);
input_block(111 downto 104) <= input_block_sig(23 downto 16);
input_block(103 downto 96) <= input_block_sig(31 downto 24);
input_block(95 downto 88) <= input_block_sig(39 downto 32);
input_block(87 downto 80) <= input_block_sig(47 downto 40);
input_block(79 downto 72) <= input_block_sig(55 downto 48);
input_block(71 downto 64) <= input_block_sig(63 downto 56);
input_block(63 downto 56) <= input_block_sig(71 downto 64);
input_block(55 downto 48) <= input_block_sig(79 downto 72);
input_block(47 downto 40) <= input_block_sig(87 downto 80);
input_block(39 downto 32) <= input_block_sig(95 downto 88);
input_block(31 downto 24) <= input_block_sig(103 downto 96);
input_block(23 downto 16) <= input_block_sig(111 downto 104);
input_block(15 downto 8) <= input_block_sig(119 downto 112);
input_block(7 downto 0) <= input_block_sig(127 downto 120);

input_key(127 downto 120) <= input_key_sig(7 downto 0);
input_key(119 downto 112) <= input_key_sig(15 downto 8);
input_key(111 downto 104) <= input_key_sig(23 downto 16);
input_key(103 downto 96) <= input_key_sig(31 downto 24);
input_key(95 downto 88) <= input_key_sig(39 downto 32);
input_key(87 downto 80) <= input_key_sig(47 downto 40);
input_key(79 downto 72) <= input_key_sig(55 downto 48);
input_key(71 downto 64) <= input_key_sig(63 downto 56);
input_key(63 downto 56) <= input_key_sig(71 downto 64);
input_key(55 downto 48) <= input_key_sig(79 downto 72);
input_key(47 downto 40) <= input_key_sig(87 downto 80);
input_key(39 downto 32) <= input_key_sig(95 downto 88);
input_key(31 downto 24) <= input_key_sig(103 downto 96);
input_key(23 downto 16) <= input_key_sig(111 downto 104);
input_key(15 downto 8) <= input_key_sig(119 downto 112);
input_key(7 downto 0) <= input_key_sig(127 downto 120);
    
input_IV(127 downto 120) <= input_IV_sig(7 downto 0);
input_IV(119 downto 112) <= input_IV_sig(15 downto 8);
input_IV(111 downto 104) <= input_IV_sig(23 downto 16);
input_IV(103 downto 96) <= input_IV_sig(31 downto 24);
input_IV(95 downto 88) <= input_IV_sig(39 downto 32);
input_IV(87 downto 80) <= input_IV_sig(47 downto 40);
input_IV(79 downto 72) <= input_IV_sig(55 downto 48);
input_IV(71 downto 64) <= input_IV_sig(63 downto 56);
input_IV(63 downto 56) <= input_IV_sig(71 downto 64);
input_IV(55 downto 48) <= input_IV_sig(79 downto 72);
input_IV(47 downto 40) <= input_IV_sig(87 downto 80);
input_IV(39 downto 32) <= input_IV_sig(95 downto 88);
input_IV(31 downto 24) <= input_IV_sig(103 downto 96);
input_IV(23 downto 16) <= input_IV_sig(111 downto 104);
input_IV(15 downto 8) <= input_IV_sig(119 downto 112);
input_IV(7 downto 0) <= input_IV_sig(127 downto 120);  

temp(127 downto 120) <= temp_sig(7 downto 0);
temp(119 downto 112) <= temp_sig(15 downto 8);
temp(111 downto 104) <= temp_sig(23 downto 16);
temp(103 downto 96) <= temp_sig(31 downto 24);
temp(95 downto 88) <= temp_sig(39 downto 32);
temp(87 downto 80) <= temp_sig(47 downto 40);
temp(79 downto 72) <= temp_sig(55 downto 48);
temp(71 downto 64) <= temp_sig(63 downto 56);
temp(63 downto 56) <= temp_sig(71 downto 64);
temp(55 downto 48) <= temp_sig(79 downto 72);
temp(47 downto 40) <= temp_sig(87 downto 80);
temp(39 downto 32) <= temp_sig(95 downto 88);
temp(31 downto 24) <= temp_sig(103 downto 96);
temp(23 downto 16) <= temp_sig(111 downto 104);
temp(15 downto 8) <= temp_sig(119 downto 112);
temp(7 downto 0) <= temp_sig(127 downto 120);  

end Behavioral;


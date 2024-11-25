

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AES_CBC is
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
    --m00_axis_aclk: in std_logic;
    --m00_axis_aresetn: in std_logic;
    m00_axis_tdata: out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
    m00_axis_tvalid: out std_logic;
    m00_axis_tready: in std_logic;  
    m00_axis_tlast: out std_logic;  
    
    --non- AXI port
    en_decrypt: in std_logic  
);
end AES_CBC;

architecture Behavioral of AES_CBC is

--components-----------------------------------------
component KeyExpansion is
generic (
    KEY_SIZE : integer := 128  -- AES-128
 );
port (
    clk : in std_logic;
    rst : in std_logic;
    in_key : in std_logic_vector(KEY_SIZE - 1 downto 0);
    round_keys : out std_logic_vector((11 * KEY_SIZE) - 1 downto 0);
    valid_in : in std_logic;
    valid_out : out std_logic
    
    
    --last_in : in std_logic;
    --last_out : out std_logic;
    --stall: in std_logic      
 );
end component;

component Encrypt is
Port (
    clk: in std_logic;
    rst: in std_logic;
    
    --main data inputs for single round hardware
    inputBlock: in std_logic_vector (127 downto 0);
    inputKey: in std_logic_vector (127 downto 0);
    
    --main data output
    outputBlock: out std_logic_vector (127 downto 0);
    
    --valid and last signals
    valid_in: in std_logic;
    last_in: in std_logic;
    valid_out: out std_logic;
    last_out: out std_logic;
    stall: in std_logic
 );
end component;

component Decrypt is --added 08/04
Port (
    clk: in std_logic;
    rst: in std_logic;
    
    --main data inputs for single round hardware
    inputBlock: in std_logic_vector (127 downto 0);
    inputRoundKeys: in std_logic_vector (1407 downto 0);
    
    --main data output
    outputBlock: out std_logic_vector (127 downto 0);
    
    --valid and last signals
    valid_in: in std_logic;
    last_in: in std_logic;
    valid_out: out std_logic;
    last_out: out std_logic;
    stall: in std_logic
 );
end component;
------------------------------------------------------------------
--signals-------------------------------------------- 


--signals  for CBC mode
signal iv: std_logic;
signal init: std_logic;

signal inputIV : std_logic_vector(127 downto 0);
signal inputIV_sig : std_logic_vector(127 downto 0);

-- signal to store the previous inputBlock (decrypt CBC mode)
signal temp: std_logic_vector (127 downto 0);
signal temp_sig: std_logic_vector (127 downto 0);


--signal for key expension
signal round_keys: std_logic_vector(1407 downto 0);
signal valid_key_in: std_logic;
signal valid_key_out: std_logic;


--signals for both for encrypt/decrypt 
signal clk: std_logic;
signal rst: std_logic;
signal inputBlock: std_logic_vector (127 downto 0);
signal inputBlock_sig: std_logic_vector (127 downto 0);
signal inputKey: std_logic_vector (127 downto 0); 
signal inputKey_sig: std_logic_vector (127 downto 0); 

signal key: std_logic;

--encrypt only signals
signal outputBlock: std_logic_vector (127 downto 0);
signal outputBlock_sig: std_logic_vector (127 downto 0);
signal valid_in: std_logic;
signal last_in: std_logic;
signal valid_out: std_logic;
signal last_out: std_logic;
signal stall_sig: std_logic;



--decrypt only signals
signal outputBlock_d: std_logic_vector (127 downto 0); 
signal valid_in_d: std_logic; --added 08/04
signal last_in_d: std_logic; --added 08/04
signal valid_out_d: std_logic; --added 08/04
signal last_out_d: std_logic; --added 08/04
signal stall_sig_d: std_logic; --added 08/04

-- AXI Stream signals----------------------------------

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
type STATE_TYPE_2 is(Idle ,Read_Inputs, Waiting, Write_Outputs); 
signal state2: STATE_TYPE_2;

--------------------------------------------------------

begin
encrypt_mode: encrypt
port map (
    clk => s00_axis_aclk, 
    rst => s00_axis_aresetn,
    inputBlock => inputBlock_sig,  -- notice: need to change inputBlock without *_sig for ip packging
    inputKey => inputKey_sig,  -- notice: need to change inputKey without *_sig for ip packging
    outputBlock => outputBlock,  
    valid_in => valid_in,
    last_in => last_in,
    valid_out => valid_out,
    last_out => last_out,
    stall => stall_sig
);


key_expansion : KeyExpansion
port map (
    clk => s00_axis_aclk,
    rst => s00_axis_aresetn,
    
    in_key => inputKey_sig, -- notice: need to change inputKey without *_sig for ip packging
    round_keys => round_keys,
    
    valid_in => valid_key_in,
    valid_out  => valid_key_out
    
);

decrypt_mode: decrypt
port map (
    clk => s00_axis_aclk, 
    rst => s00_axis_aresetn,
    inputBlock => inputBlock_sig, -- notice: need to change inputKey without *_sig for ip packging
    
    inputRoundKeys => round_keys,
     
    outputBlock => outputBlock_d,  
    valid_in => valid_in_d, 
    last_in => last_in_d, 
    valid_out => valid_out_d, 
    last_out => last_out_d,  
    stall => stall_sig_d 
);



--standard assignments------------------------------------
clk <= s00_axis_aclk; --v
rst <= s00_axis_aresetn; --v
--axis slave assignments
s_tdata <= s00_axis_tdata; --v
s_tvalid <= s00_axis_tvalid; --v
s00_axis_tready <= s_tready; --v
s_tlast <= s00_axis_tlast; --v

--axis master assignments
m00_axis_tdata <= m_tdata; --v
m00_axis_tvalid <= m_tvalid; --v
m_tready <= m00_axis_tready; --v
m00_axis_tlast <= m_tlast; --v

--s_tready <= '1' when state = Read_Inputs else '0'; --
--m_tvalid <= '1' when state = Write_Outputs else '0'; --


s_tready <= '1' when (state2 = Read_Inputs or state = Read_Inputs) else '0';
m_tvalid <= '1' when (state2 = Write_Outputs or state = Write_Outputs) else '0';

m_tdata <= outputBlock_sig; 


process(clk)
begin
if rising_edge(clk) then
    if rst = '0' then --active low reset
        key <= '1';
        valid_in <= '0';
        last_in <= '0'; 
        valid_in_d <= '0';
        last_in_d <= '0'; 
        valid_key_in <= '0';
        iv <= '0'; --20/05
        init <= '0'; --20/05
        stall_sig <= '0';
        stall_sig_d <= '0'; --20/05
   
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
                        inputKey_sig <= s_tdata;
                        valid_key_in <= '1';
                        iv <= '1'; --20/05
                        stall_sig_d <= '0'; --20/05
                     
                        state <= Wait_For_Keys; 
                        
                    elsif iv = '1' then
                    	inputIV_sig <= s_tdata;
                        iv <= '0';
                        init <= '1';
                        state <= Idle;
                    
                     elsif init = '1' then
                    	inputBlock_sig <= s_tdata; -- xor inputIV_sig;
                        temp_sig <= inputBlock_sig; --previous inputBlock ?
                        
                        valid_in_d <= '1';
                        last_in_d <= s_tlast;
                        init <= '1'; -- 21/05 change to '1'
                        
                        state <= Waiting; 
                        
       
                    else
                        inputBlock_sig <= s_tdata; 
                        temp_sig <= inputBlock_sig; --21/05
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
                    stall_sig_d <= '1'; -- 21/05 ???
                    state <= Write_Outputs;
                    m_tlast <= last_out_d;
                    
                    init <= '0'; --21/05
                    
                    
                    -- notice: need to change inputIV without *_sig for ip packging 
                    outputBlock_sig(127 downto 120) <= outputBlock_d(7 downto 0) xor inputIV_sig(7 downto 0);
                    outputBlock_sig(119 downto 112) <= outputBlock_d(15 downto 8) xor inputIV_sig(15 downto 8);
                    outputBlock_sig(111 downto 104) <= outputBlock_d(23 downto 16) xor inputIV_sig(23 downto 16);
                    outputBlock_sig(103 downto 96) <= outputBlock_d(31 downto 24) xor inputIV_sig(31 downto 24);
                    outputBlock_sig(95 downto 88) <= outputBlock_d(39 downto 32) xor inputIV_sig(39 downto 32);
                    outputBlock_sig(87 downto 80) <= outputBlock_d(47 downto 40) xor inputIV_sig(47 downto 40);
                    outputBlock_sig(79 downto 72) <= outputBlock_d(55 downto 48) xor inputIV_sig(55 downto 48);
                    outputBlock_sig(71 downto 64) <= outputBlock_d(63 downto 56) xor inputIV_sig(63 downto 56);
                    outputBlock_sig(63 downto 56) <= outputBlock_d(71 downto 64) xor inputIV_sig(71 downto 64);
                    outputBlock_sig(55 downto 48) <= outputBlock_d(79 downto 72) xor inputIV_sig(79 downto 72);
                    outputBlock_sig(47 downto 40) <= outputBlock_d(87 downto 80) xor inputIV_sig(87 downto 80);
                    outputBlock_sig(39 downto 32) <= outputBlock_d(95 downto 88) xor inputIV_sig(95 downto 88);
                    outputBlock_sig(31 downto 24) <= outputBlock_d(103 downto 96) xor inputIV_sig(103 downto 96);
                    outputBlock_sig(23 downto 16) <= outputBlock_d(111 downto 104) xor inputIV_sig(111 downto 104);
                    outputBlock_sig(15 downto 8) <= outputBlock_d(119 downto 112) xor inputIV_sig(119 downto 112);
                    outputBlock_sig(7 downto 0) <= outputBlock_d(127 downto 120) xor inputIV_sig(127 downto 120);
                    
                elsif valid_out_d = '1' and init = '0' then
                	stall_sig_d <= '1'; -- 21/05 ???
                    state <= Write_Outputs;
                    m_tlast <= last_out_d;
                    

                    -- notice: need to change temp without *_sig for ip packging 
                    outputBlock_sig(127 downto 120) <= outputBlock_d(7 downto 0) xor temp_sig(7 downto 0);
                    outputBlock_sig(119 downto 112) <= outputBlock_d(15 downto 8) xor temp_sig(15 downto 8);
                    outputBlock_sig(111 downto 104) <= outputBlock_d(23 downto 16) xor temp_sig(23 downto 16);
                    outputBlock_sig(103 downto 96) <= outputBlock_d(31 downto 24) xor temp_sig(31 downto 24);
                    outputBlock_sig(95 downto 88) <= outputBlock_d(39 downto 32) xor temp_sig(39 downto 32);
                    outputBlock_sig(87 downto 80) <= outputBlock_d(47 downto 40) xor temp_sig(47 downto 40);
                    outputBlock_sig(79 downto 72) <= outputBlock_d(55 downto 48) xor temp_sig(55 downto 48);
                    outputBlock_sig(71 downto 64) <= outputBlock_d(63 downto 56) xor temp_sig(63 downto 56);
                    outputBlock_sig(63 downto 56) <= outputBlock_d(71 downto 64) xor temp_sig(71 downto 64);
                    outputBlock_sig(55 downto 48) <= outputBlock_d(79 downto 72) xor temp_sig(79 downto 72);
                    outputBlock_sig(47 downto 40) <= outputBlock_d(87 downto 80) xor temp_sig(87 downto 80);
                    outputBlock_sig(39 downto 32) <= outputBlock_d(95 downto 88) xor temp_sig(95 downto 88);
                    outputBlock_sig(31 downto 24) <= outputBlock_d(103 downto 96) xor temp_sig(103 downto 96);
                    outputBlock_sig(23 downto 16) <= outputBlock_d(111 downto 104) xor temp_sig(111 downto 104);
                    outputBlock_sig(15 downto 8) <= outputBlock_d(119 downto 112) xor temp_sig(119 downto 112);
                    outputBlock_sig(7 downto 0) <= outputBlock_d(127 downto 120) xor temp_sig(127 downto 120);
                
                else
                    state <= waiting;
                    stall_sig_d <= '0';
                    m_tlast <= '0'; -- new 30/04
                end if;
            when Write_Outputs =>
              --if transfer complete
                if (m_tready = '1' and m_tvalid = '1') then
                    state <= Idle;
                    stall_sig_d <= '0'; --21/05 change to  '0'
                    m_tlast <= '0'; -- new 30/04  
                end if;
           
        end case; 
        --------------
        elsif en_decrypt = '0' then 
        case state2 is  --2
        	when Idle =>
            	valid_in <= '0';
        		last_in <= '0';
                if s_tvalid = '1' then  
                	state2 <= Read_Inputs; --2
                else
                	state2 <= Idle; --2
                end if;
            when Read_Inputs =>
            	if s_tvalid = '1' and s_tready ='1' then
                	if key = '1' then
                    	inputKey_sig <= s_tdata;
                        iv <= '1'; --make sure after getting the key, iv goes HIGH for next time state = Read_inputs, IVinput_sig <= s_tdata
                        state2 <= Idle; --2
                        stall_sig <= '0'; --
                    elsif iv = '1' then
                    	inputIV_sig <= s_tdata;
                        iv <= '0';
                        init <= '1';
                        state2 <= Idle; --2
                        
                    elsif init = '1' then
                    	inputBlock_sig <= s_tdata xor inputIV_sig;
                        valid_in <= '1';
                        last_in <= s_tlast;
                        init <= '0';
                        
                        state2 <= Waiting; --2
                        
                    else
                       -- if valid_out_delay = '1' then --valid_out = '1' 
                        	inputBlock_sig <= s_tdata xor outputBlock; ---- notice: need to change outputBlock with *_sig for ip packging 
                            valid_in <= '1';
                            last_in <= s_tlast;
                            stall_sig <= '0'; --16/05
                            state2 <= waiting; --2
                        --else
                        	--state <= Idle; --
                        --end if;
                    end if;
                    if (s_tlast = '1') then 
                        key <= '1';
                    else
                        key <= '0';
                    end if;
                else
                	state2 <= Read_Inputs; --2
                end if;
            when waiting => 
            	valid_in <= '0';
                last_in <= '0';
                    
                
                
                if (valid_out = '1') then --valid_out
                    stall_sig <= '1';
                    state2 <= Write_Outputs; --2
                    m_tlast <= last_out;
                
                    outputBlock_sig(127 downto 120) <= outputBlock(7 downto 0);
                    outputBlock_sig(119 downto 112) <= outputBlock(15 downto 8);
                    outputBlock_sig(111 downto 104) <= outputBlock(23 downto 16);
                    outputBlock_sig(103 downto 96) <= outputBlock(31 downto 24);
                    outputBlock_sig(95 downto 88) <= outputBlock(39 downto 32);
                    outputBlock_sig(87 downto 80) <= outputBlock(47 downto 40);
                    outputBlock_sig(79 downto 72) <= outputBlock(55 downto 48);
                    outputBlock_sig(71 downto 64) <= outputBlock(63 downto 56);
                    outputBlock_sig(63 downto 56) <= outputBlock(71 downto 64);
                    outputBlock_sig(55 downto 48) <= outputBlock(79 downto 72);
                    outputBlock_sig(47 downto 40) <= outputBlock(87 downto 80);
                    outputBlock_sig(39 downto 32) <= outputBlock(95 downto 88);
                    outputBlock_sig(31 downto 24) <= outputBlock(103 downto 96);
                    outputBlock_sig(23 downto 16) <= outputBlock(111 downto 104);
                    outputBlock_sig(15 downto 8) <= outputBlock(119 downto 112);
                    outputBlock_sig(7 downto 0) <= outputBlock(127 downto 120);
                
                else
                    state2 <= waiting; --2
                    stall_sig <= '0';
                    m_tlast <= '0'; -- new 30/04
                end if;
            when Write_Outputs =>
              --if transfer complete
                if (m_tready = '1' and m_tvalid = '1') then
                    state2 <= Idle; --2
                    stall_sig <= '1';
                    m_tlast <= '0'; -- new 30/04  
                end if;
        end case;
     end if;
 end if;
 end if;
 end process;


--endianness conversion
inputBlock(127 downto 120) <= inputBlock_sig(7 downto 0);
inputBlock(119 downto 112) <= inputBlock_sig(15 downto 8);
inputBlock(111 downto 104) <= inputBlock_sig(23 downto 16);
inputBlock(103 downto 96) <= inputBlock_sig(31 downto 24);
inputBlock(95 downto 88) <= inputBlock_sig(39 downto 32);
inputBlock(87 downto 80) <= inputBlock_sig(47 downto 40);
inputBlock(79 downto 72) <= inputBlock_sig(55 downto 48);
inputBlock(71 downto 64) <= inputBlock_sig(63 downto 56);
inputBlock(63 downto 56) <= inputBlock_sig(71 downto 64);
inputBlock(55 downto 48) <= inputBlock_sig(79 downto 72);
inputBlock(47 downto 40) <= inputBlock_sig(87 downto 80);
inputBlock(39 downto 32) <= inputBlock_sig(95 downto 88);
inputBlock(31 downto 24) <= inputBlock_sig(103 downto 96);
inputBlock(23 downto 16) <= inputBlock_sig(111 downto 104);
inputBlock(15 downto 8) <= inputBlock_sig(119 downto 112);
inputBlock(7 downto 0) <= inputBlock_sig(127 downto 120);

inputKey(127 downto 120) <= inputKey_sig(7 downto 0);
inputKey(119 downto 112) <= inputKey_sig(15 downto 8);
inputKey(111 downto 104) <= inputKey_sig(23 downto 16);
inputKey(103 downto 96) <= inputKey_sig(31 downto 24);
inputKey(95 downto 88) <= inputKey_sig(39 downto 32);
inputKey(87 downto 80) <= inputKey_sig(47 downto 40);
inputKey(79 downto 72) <= inputKey_sig(55 downto 48);
inputKey(71 downto 64) <= inputKey_sig(63 downto 56);
inputKey(63 downto 56) <= inputKey_sig(71 downto 64);
inputKey(55 downto 48) <= inputKey_sig(79 downto 72);
inputKey(47 downto 40) <= inputKey_sig(87 downto 80);
inputKey(39 downto 32) <= inputKey_sig(95 downto 88);
inputKey(31 downto 24) <= inputKey_sig(103 downto 96);
inputKey(23 downto 16) <= inputKey_sig(111 downto 104);
inputKey(15 downto 8) <= inputKey_sig(119 downto 112);
inputKey(7 downto 0) <= inputKey_sig(127 downto 120);
    
inputIV(127 downto 120) <= inputIV_sig(7 downto 0);
inputIV(119 downto 112) <= inputIV_sig(15 downto 8);
inputIV(111 downto 104) <= inputIV_sig(23 downto 16);
inputIV(103 downto 96) <= inputIV_sig(31 downto 24);
inputIV(95 downto 88) <= inputIV_sig(39 downto 32);
inputIV(87 downto 80) <= inputIV_sig(47 downto 40);
inputIV(79 downto 72) <= inputIV_sig(55 downto 48);
inputIV(71 downto 64) <= inputIV_sig(63 downto 56);
inputIV(63 downto 56) <= inputIV_sig(71 downto 64);
inputIV(55 downto 48) <= inputIV_sig(79 downto 72);
inputIV(47 downto 40) <= inputIV_sig(87 downto 80);
inputIV(39 downto 32) <= inputIV_sig(95 downto 88);
inputIV(31 downto 24) <= inputIV_sig(103 downto 96);
inputIV(23 downto 16) <= inputIV_sig(111 downto 104);
inputIV(15 downto 8) <= inputIV_sig(119 downto 112);
inputIV(7 downto 0) <= inputIV_sig(127 downto 120);  

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



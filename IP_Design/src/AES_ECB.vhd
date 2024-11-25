
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AES_ECB is
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
end AES_ECB;

architecture Behavioral of AES_ECB is

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

component Encrypt is --add 02/05
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
------------------------------------------------------------------------------------------------------------------------
--signals-------------------------------------------- 

--signal for key expension
signal round_keys: std_logic_vector(1407 downto 0);
signal valid_key_in: std_logic;
signal valid_key_out: std_logic;

--general signals for both encryption and decryption
signal clk: std_logic;
signal rst: std_logic;

signal inputBlock: std_logic_vector (127 downto 0);
signal inputBlock_sig: std_logic_vector (127 downto 0);

signal inputKey: std_logic_vector (127 downto 0); 
signal inputKey_sig: std_logic_vector (127 downto 0); 

signal outputBlock_sig: std_logic_vector (127 downto 0);

--signals for encrypt
signal outputBlock_e: std_logic_vector (127 downto 0); -- to used with encrypt
signal valid_in_e: std_logic; --added 08/04
signal last_in_e: std_logic; --added 08/04
signal valid_out_e: std_logic; --added 08/04
signal last_out_e: std_logic; --added 08/04
signal stall_sig_e: std_logic; --added 08/04

--signal for decrypt 
signal outputBlock_d: std_logic_vector (127 downto 0); --added 08/04
signal valid_in_d: std_logic; --added 08/04
signal last_in_d: std_logic; --added 08/04
signal valid_out_d: std_logic; --added 08/04
signal last_out_d: std_logic; --added 08/04
signal stall_sig_d: std_logic; --added 08/04

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

signal key: std_logic;
--state machine--------------------------------
type STATE_TYPE_1 is(Idle, Wait_For_Keys ,Read_Inputs);
type STATE_TYPE_2 is (Idle2, Write_Outputs);
signal state: STATE_TYPE_1;
signal state2: STATE_TYPE_2;


--------------------------------------------------------

begin
key_expansion : KeyExpansion
port map (
    clk => s00_axis_aclk,
    rst => s00_axis_aresetn,
    
    in_key => inputKey_sig, -- notice: need to change inputKey without *_sig for ip packging
    round_keys => round_keys,
    
    valid_in => valid_key_in,
    valid_out  => valid_key_out    
);

encryption: Encrypt
port map (
    clk => s00_axis_aclk, 
    rst => s00_axis_aresetn,
    inputBlock => inputBlock_sig, -- notice: need to change inputKey without *_sig for ip packging
    
    inputKey => inputKey_sig, -- notice: need to change inputKey without *_sig for ip packging
     
    outputBlock => outputBlock_e,  
    valid_in => valid_in_e, 
    last_in => last_in_e, 
    valid_out => valid_out_e, 
    last_out => last_out_e,  
    stall => stall_sig_e 

);

decryption: Decrypt
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

s_tready <= '1' when state = Read_Inputs else '0'; --
m_tvalid <= '1' when state2 = Write_Outputs else '0'; --

m_tdata <= outputBlock_sig; 

--read side FSM(slave)
process(clk)
begin
if rising_edge(clk) then
    if rst = '0' then --active low reset
        state <= Idle;
        key <= '1';
        valid_key_in <= '0';
        
        valid_in_e <= '0';
        last_in_e <= '0';
 
        valid_in_d <= '0';
        last_in_d <= '0'; 
    else
        case state is
            when Idle =>
                valid_key_in <= '0';
                
                valid_in_e <= '0';
                last_in_e <= '0';

                valid_in_d <= '0'; --added 08/04
                last_in_d <= '0'; --added 08/04
                if (s_tvalid = '1' and stall_sig_d = '0') or (s_tvalid = '1' and stall_sig_e = '0') then
                    state <= Read_Inputs;
                else
                    state <= Idle;
                end if;
            when Read_Inputs =>
                if (s_tvalid = '1' and s_tready = '1') then
                    if key = '1' then  
                        if en_decrypt = '1' then
                            inputKey_sig <= s_tdata;
                            valid_key_in <= '1';
                            state <= Wait_For_Keys; 
                        else
                            inputKey_sig <= s_tdata; 
                            state <= Idle;
                        end if;
                    else   
                        if (en_decrypt = '1') then
                            inputBlock_sig <= s_tdata;  --added 08/04
                            valid_in_d <= '1';      --added 08/04
                            last_in_d <= s_tlast;   --added 08/04
                            valid_key_in <= '0';
                            state <= Idle;
                        else
                            inputBlock_sig <= s_tdata;
                            valid_in_e <= '1';      --added 08/04
                            last_in_e <= s_tlast;   --added 08/04
                            valid_key_in <= '0';
                            state <= Idle; 
                        end if;                         
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
        end case; 
    end if;
end if;
end process;        
                
--write side FSM (master)
process(clk)
begin  -- process The_SW_accelerator
    if rising_edge(clk) then     -- Rising clock edge
        if rst = '0' then               -- Synchronous reset (active low)
            state2 <= Idle2;        
            stall_sig_e <= '0';
            stall_sig_d <= '0';
        else    
          case state2 is
             when Idle2 => 
               if valid_out_d = '1'  then
                    stall_sig_d <= '1';
                    state2 <= Write_Outputs;
                    m_tlast <= last_out_d;
                    outputBlock_sig(127 downto 120) <= outputBlock_d(7 downto 0);
                    outputBlock_sig(119 downto 112) <= outputBlock_d(15 downto 8);
                    outputBlock_sig(111 downto 104) <= outputBlock_d(23 downto 16);
                    outputBlock_sig(103 downto 96) <= outputBlock_d(31 downto 24);
                    outputBlock_sig(95 downto 88) <= outputBlock_d(39 downto 32);
                    outputBlock_sig(87 downto 80) <= outputBlock_d(47 downto 40);
                    outputBlock_sig(79 downto 72) <= outputBlock_d(55 downto 48);
                    outputBlock_sig(71 downto 64) <= outputBlock_d(63 downto 56);
                    outputBlock_sig(63 downto 56) <= outputBlock_d(71 downto 64);
                    outputBlock_sig(55 downto 48) <= outputBlock_d(79 downto 72);
                    outputBlock_sig(47 downto 40) <= outputBlock_d(87 downto 80);
                    outputBlock_sig(39 downto 32) <= outputBlock_d(95 downto 88);
                    outputBlock_sig(31 downto 24) <= outputBlock_d(103 downto 96);
                    outputBlock_sig(23 downto 16) <= outputBlock_d(111 downto 104);
                    outputBlock_sig(15 downto 8) <= outputBlock_d(119 downto 112);
                    outputBlock_sig(7 downto 0) <= outputBlock_d(127 downto 120);
                elsif valid_out_e = '1'  then
                    stall_sig_e <= '1';
                    state2 <= Write_Outputs;
                    m_tlast <= last_out_e;
                    outputBlock_sig(127 downto 120) <= outputBlock_e(7 downto 0);
                    outputBlock_sig(119 downto 112) <= outputBlock_e(15 downto 8);
                    outputBlock_sig(111 downto 104) <= outputBlock_e(23 downto 16);
                    outputBlock_sig(103 downto 96) <= outputBlock_e(31 downto 24);
                    outputBlock_sig(95 downto 88) <= outputBlock_e(39 downto 32);
                    outputBlock_sig(87 downto 80) <= outputBlock_e(47 downto 40);
                    outputBlock_sig(79 downto 72) <= outputBlock_e(55 downto 48);
                    outputBlock_sig(71 downto 64) <= outputBlock_e(63 downto 56);
                    outputBlock_sig(63 downto 56) <= outputBlock_e(71 downto 64);
                    outputBlock_sig(55 downto 48) <= outputBlock_e(79 downto 72);
                    outputBlock_sig(47 downto 40) <= outputBlock_e(87 downto 80);
                    outputBlock_sig(39 downto 32) <= outputBlock_e(95 downto 88);
                    outputBlock_sig(31 downto 24) <= outputBlock_e(103 downto 96);
                    outputBlock_sig(23 downto 16) <= outputBlock_e(111 downto 104);
                    outputBlock_sig(15 downto 8) <= outputBlock_e(119 downto 112);
                    outputBlock_sig(7 downto 0) <= outputBlock_e(127 downto 120); 
                else
                    state2 <= Idle2;
                    m_tlast <= '0'; -- new 30/04
                    
                    stall_sig_d <= '0';
                    stall_sig_e <= '0';
                end if;
                            
             when Write_Outputs =>
              --if transfer complete
                if (m_tready = '1' and m_tvalid = '1') then
                    state2 <= Idle2;
                    m_tlast <= '0'; -- new 30/04
                    
                    stall_sig_d <= '0';
                    stall_sig_e <= '0';                           
                end if;
          end case;
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
    
end Behavioral;



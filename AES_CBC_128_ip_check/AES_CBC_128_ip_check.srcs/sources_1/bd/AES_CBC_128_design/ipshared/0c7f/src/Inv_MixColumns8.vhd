library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Inv_MixColumns8 is
Port (
    i1, i2, i3, i4: in std_logic_vector (7 downto 0);
    data_out: out std_logic_vector (7 downto 0)       
);
end Inv_MixColumns8;
  
architecture Behavioral of Inv_MixColumns8 is

function Gmul_2(a : std_logic_vector(7 downto 0)) return std_logic_vector is
variable result : std_logic_vector(7 downto 0);
begin
    if a(7) = '1' then
        result := (a(6 downto 0) & '0') xor "00011011";
    else
        result := (a(6 downto 0) & '0');
    end if;
return result;
end function Gmul_2;

function Gmul_9(a : std_logic_vector(7 downto 0)) return std_logic_vector is
variable temp : std_logic_vector(7 downto 0);
begin
    temp := Gmul_2(Gmul_2(Gmul_2(a)));
return temp xor a;
end function Gmul_9;

function Gmul_11(a : std_logic_vector(7 downto 0)) return std_logic_vector is
variable temp : std_logic_vector(7 downto 0);
begin
    temp := Gmul_2(Gmul_2(Gmul_2(a)) xor a);
return temp xor a;
end function Gmul_11;

function Gmul_13(a : std_logic_vector(7 downto 0)) return std_logic_vector is
variable temp : std_logic_vector(7 downto 0);
begin
    temp := Gmul_2(Gmul_2(Gmul_2(a)) xor Gmul_2(a));
return temp xor a;
end function Gmul_13;

function Gmul_14(a : std_logic_vector(7 downto 0)) return std_logic_vector is
variable temp : std_logic_vector(7 downto 0);
begin
    temp := Gmul_2(Gmul_2(Gmul_2(a)) xor Gmul_2(a));
return temp xor Gmul_2(a);
end function Gmul_14;
   
begin
data_out <= Gmul_14(i1) xor Gmul_11(i2) xor Gmul_13(i3) xor Gmul_9(i4); 
  
end Behavioral;




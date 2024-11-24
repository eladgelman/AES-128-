-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Wed Jul  3 13:01:01 2024
-- Host        : DESKTOP-JE2C2J2 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/User/AES_EBC_128_ip_check/AES_EBC_128_ip_check.srcs/sources_1/bd/AES_EBC_128_design/ip/AES_EBC_128_design_AES_EBC_128_0_0/AES_EBC_128_design_AES_EBC_128_0_0_stub.vhdl
-- Design      : AES_EBC_128_design_AES_EBC_128_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AES_EBC_128_design_AES_EBC_128_0_0 is
  Port ( 
    s00_axis_aclk : in STD_LOGIC;
    s00_axis_aresetn : in STD_LOGIC;
    s00_axis_tdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    s00_axis_tvalid : in STD_LOGIC;
    s00_axis_tready : out STD_LOGIC;
    s00_axis_tlast : in STD_LOGIC;
    m00_axis_tdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m00_axis_tvalid : out STD_LOGIC;
    m00_axis_tready : in STD_LOGIC;
    m00_axis_tlast : out STD_LOGIC;
    en_decrypt : in STD_LOGIC;
    LD4_rgb : out STD_LOGIC_VECTOR ( 2 downto 0 )
  );

end AES_EBC_128_design_AES_EBC_128_0_0;

architecture stub of AES_EBC_128_design_AES_EBC_128_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "s00_axis_aclk,s00_axis_aresetn,s00_axis_tdata[127:0],s00_axis_tvalid,s00_axis_tready,s00_axis_tlast,m00_axis_tdata[127:0],m00_axis_tvalid,m00_axis_tready,m00_axis_tlast,en_decrypt,LD4_rgb[2:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "AES_EBC_128,Vivado 2020.1";
begin
end;

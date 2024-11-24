// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Wed Jul  3 13:00:46 2024
// Host        : DESKTOP-JE2C2J2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ AES_EBC_128_design_AES_EBC_128_0_0_stub.v
// Design      : AES_EBC_128_design_AES_EBC_128_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "AES_EBC_128,Vivado 2020.1" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(s00_axis_aclk, s00_axis_aresetn, 
  s00_axis_tdata, s00_axis_tvalid, s00_axis_tready, s00_axis_tlast, m00_axis_tdata, 
  m00_axis_tvalid, m00_axis_tready, m00_axis_tlast, en_decrypt, LD4_rgb)
/* synthesis syn_black_box black_box_pad_pin="s00_axis_aclk,s00_axis_aresetn,s00_axis_tdata[127:0],s00_axis_tvalid,s00_axis_tready,s00_axis_tlast,m00_axis_tdata[127:0],m00_axis_tvalid,m00_axis_tready,m00_axis_tlast,en_decrypt,LD4_rgb[2:0]" */;
  input s00_axis_aclk;
  input s00_axis_aresetn;
  input [127:0]s00_axis_tdata;
  input s00_axis_tvalid;
  output s00_axis_tready;
  input s00_axis_tlast;
  output [127:0]m00_axis_tdata;
  output m00_axis_tvalid;
  input m00_axis_tready;
  output m00_axis_tlast;
  input en_decrypt;
  output [2:0]LD4_rgb;
endmodule

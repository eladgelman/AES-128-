set_property SRC_FILE_INFO {cfile:c:/Users/User/AES_EBC_128_ip_check/AES_EBC_128_ip_check.srcs/sources_1/bd/AES_EBC_128_design/ip/AES_EBC_128_design_processing_system7_0_0/AES_EBC_128_design_processing_system7_0_0/AES_EBC_128_design_processing_system7_0_0_in_context.xdc rfile:../../../AES_EBC_128_ip_check.srcs/sources_1/bd/AES_EBC_128_design/ip/AES_EBC_128_design_processing_system7_0_0/AES_EBC_128_design_processing_system7_0_0/AES_EBC_128_design_processing_system7_0_0_in_context.xdc id:1 order:EARLY scoped_inst:AES_EBC_128_design_i/processing_system7_0} [current_design]
set_property SRC_FILE_INFO {cfile:C:/Users/User/AES_EBC_128_ip_check/AES_EBC_128_ip_check.srcs/constrs_1/new/switch_led.xdc rfile:../../../AES_EBC_128_ip_check.srcs/constrs_1/new/switch_led.xdc id:2} [current_design]
current_instance AES_EBC_128_design_i/processing_system7_0
set_property src_info {type:SCOPED_XDC file:1 line:2 export:INPUT save:INPUT read:READ} [current_design]
create_clock -period 10.000 [get_ports {}]
current_instance
set_property src_info {type:XDC file:2 line:3 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {sw1}]
set_property src_info {type:XDC file:2 line:7 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports {LD4_port[0]}]
set_property src_info {type:XDC file:2 line:8 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {LD4_port[1]}]
set_property src_info {type:XDC file:2 line:9 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {LD4_port[2]}]

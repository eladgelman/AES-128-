## Switches
#set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {sw2}]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {sw1}]


## RGB LEDs
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports {LD4_port[0]}] 
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {LD4_port[1]}] 
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {LD4_port[2]}]

#set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {LD5_led[0]}]
#set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports {LD5_led[1]}]
#set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {LD5_led[2]}]

## LOC constrain for DRP_CLK_P/N
set_property PACKAGE_PIN AF22 [get_ports DRP_CLK_P]
set_property PACKAGE_PIN AG23 [get_ports DRP_CLK_N]
set_property IOSTANDARD LVDS_25 [get_ports DRP_CLK_P]
set_property IOSTANDARD LVDS_25 [get_ports DRP_CLK_N]
create_clock -period 10.000 -name drpclk_in_i [get_ports DRP_CLK_P]

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets txusrclk2]
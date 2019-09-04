set_property PACKAGE_PIN A8 [get_ports {RXP[0]}]
set_property PACKAGE_PIN B6 [get_ports {RXP[1]}]
set_property PACKAGE_PIN D6 [get_ports {RXP[2]}]
set_property PACKAGE_PIN E4 [get_ports {RXP[3]}]
set_property PACKAGE_PIN F6 [get_ports {RXP[4]}]
set_property PACKAGE_PIN G4 [get_ports {RXP[5]}]
set_property PACKAGE_PIN H6 [get_ports {RXP[6]}]
set_property PACKAGE_PIN K6 [get_ports {RXP[7]}]

set_property PACKAGE_PIN G8 [get_ports GTREFCLK_P]
set_property PACKAGE_PIN G7 [get_ports GTREFCLK_N]
create_clock -period 8.000 [get_ports GTREFCLK_P]



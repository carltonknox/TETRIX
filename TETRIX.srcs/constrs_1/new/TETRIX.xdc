set_property PACKAGE_PIN V10 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_property PACKAGE_PIN V11 [get_ports {out_of_bounds[0]}]
set_property PACKAGE_PIN V12 [get_ports {out_of_bounds[1]}]
set_property PACKAGE_PIN V14 [get_ports {out_of_bounds[2]}]
set_property PACKAGE_PIN V15 [get_ports {out_of_bounds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out_of_bounds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out_of_bounds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out_of_bounds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out_of_bounds[0]}]

set_property PACKAGE_PIN H17 [get_ports fall_fail]
set_property IOSTANDARD LVCMOS33 [get_ports fall_fail]

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clock]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clock]
#uart:
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports uart_tx]

#keyboard
set_property -dict { PACKAGE_PIN F4    IOSTANDARD LVCMOS33 } [get_ports { PS2_CLK }]; #IO_L13P_T2_MRCC_35 Sch=ps2_clk
set_property -dict { PACKAGE_PIN B2    IOSTANDARD LVCMOS33 } [get_ports { PS2_DATA }]; #IO_L10N_T1_AD15N_35 Sch=ps2_data
# -*- tcl -*-
# $Id: cmoda7_pins.xdc 906 2017-06-04 21:59:13Z mueller $
#
# Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Digilent CmodA7 core functionality
# - Configuration setup
#   - config voltage
#   - enable bitstream timestamp
# - Pin Locks for
#   - USB UART
#   - human I/O (sbuttons, leds)
#
# Revision History: 
# Date         Rev Version  Comment
# 2017-06-04   906   1.0    Initial version
#

# config setup --------------------------------------------------------------
set_property CFGBVS         VCCO [current_design]
set_property CONFIG_VOLTAGE  3.3 [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]

# clocks -- in bank 14 ------------------------------------------------------
set_property PACKAGE_PIN l17 [get_ports {I_CLK12}]
set_property IOSTANDARD LVCMOS33 [get_ports {I_CLK12}]

#
# USB UART Interface -- in bank 14 ------------------------------------------
set_property PACKAGE_PIN j17 [get_ports {I_RXD}]
set_property PACKAGE_PIN j18 [get_ports {O_TXD}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_RXD O_TXD}]
set_property DRIVE 12   [get_ports {O_TXD}]
set_property SLEW SLOW  [get_ports {O_TXD}]

#
# buttons -- in bank 16 -----------------------------------------------------
set_property PACKAGE_PIN a18 [get_ports {I_BTN[0]}]
set_property PACKAGE_PIN b18 [get_ports {I_BTN[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_BTN[*]}]

#
# LEDs -- in bank 16 --------------------------------------------------------
set_property PACKAGE_PIN a17 [get_ports {O_LED[0]}]
set_property PACKAGE_PIN c16 [get_ports {O_LED[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_LED[*]}]
set_property DRIVE 12            [get_ports {O_LED[*]}]
set_property SLEW SLOW           [get_ports {O_LED[*]}]

#
# RGB-LED -- in bank 16 -----------------------------------------------------
set_property PACKAGE_PIN c17 [get_ports {O_RGBLED0_N[0]}]
set_property PACKAGE_PIN b16 [get_ports {O_RGBLED0_N[1]}]
set_property PACKAGE_PIN b17 [get_ports {O_RGBLED0_N[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_RGBLED0_N[*]}]
set_property DRIVE 12            [get_ports {O_RGBLED0_N[*]}]
set_property SLEW SLOW           [get_ports {O_RGBLED0_N[*]}]

# -*- tcl -*-
# $Id: artys7_pins.xdc 1038 2018-08-11 12:39:52Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Digilent Arty core functionality
# - Configuration setup
#   - config voltage
#   - enable bitstream timestamp
# - Pin Locks for
#   - USB UART
#   - human I/O (switches, buttons, leds)
#
# Revision History: 
# Date         Rev Version  Comment
# 2018-08-05  1038   1.0    Initial version
#

# config setup --------------------------------------------------------------
set_property CFGBVS         VCCO [current_design]
set_property CONFIG_VOLTAGE  3.3 [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
# other setups --------------------------------------------------------------
# force internal ref for bank 34, allows to use M5 for SWI[3]
set_property INTERNAL_VREF 0.675 [get_iobanks 34]

# clocks -- in bank 34 ------------------------------------------------------
set_property PACKAGE_PIN r2  [get_ports {I_CLK100}]
set_property IOSTANDARD SSTL135 [get_ports {I_CLK100}]

#
# USB UART Interface -- in bank 14 ------------------------------------------
set_property PACKAGE_PIN v12 [get_ports {I_RXD}]
set_property PACKAGE_PIN r12 [get_ports {O_TXD}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_RXD O_TXD}]
set_property DRIVE 12   [get_ports {O_TXD}]
set_property SLEW SLOW  [get_ports {O_TXD}]

#
# switches -- in bank 15+34 -------------------------------------------------
set_property PACKAGE_PIN h14 [get_ports {I_SWI[0]}]
set_property PACKAGE_PIN h18 [get_ports {I_SWI[1]}]
set_property PACKAGE_PIN g18 [get_ports {I_SWI[2]}]
set_property PACKAGE_PIN m5  [get_ports {I_SWI[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_SWI[0] I_SWI[1] I_SWI[2] }]
set_property IOSTANDARD SSTL135  [get_ports {I_SWI[3]}]

#
# buttons -- in bank 15 -----------------------------------------------------
set_property PACKAGE_PIN g15 [get_ports {I_BTN[0]}]
set_property PACKAGE_PIN k16 [get_ports {I_BTN[1]}]
set_property PACKAGE_PIN j16 [get_ports {I_BTN[2]}]
set_property PACKAGE_PIN h13 [get_ports {I_BTN[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_BTN[*]}]

#
# LEDs -- in bank 15 --------------------------------------------------------
set_property PACKAGE_PIN e18 [get_ports {O_LED[0]}]
set_property PACKAGE_PIN f13 [get_ports {O_LED[1]}]
set_property PACKAGE_PIN e13 [get_ports {O_LED[2]}]
set_property PACKAGE_PIN h15 [get_ports {O_LED[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_LED[*]}]
set_property DRIVE 12            [get_ports {O_LED[*]}]
set_property SLEW SLOW           [get_ports {O_LED[*]}]

#
# RGB-LEDs -- in bank 35 ----------------------------------------------------
#   Note: [0] red  [1] green  [2] blue
set_property PACKAGE_PIN j15 [get_ports {O_RGBLED0[0]}]
set_property PACKAGE_PIN g17 [get_ports {O_RGBLED0[1]}]
set_property PACKAGE_PIN f15 [get_ports {O_RGBLED0[2]}]

set_property PACKAGE_PIN e15 [get_ports {O_RGBLED1[0]}]
set_property PACKAGE_PIN f18 [get_ports {O_RGBLED1[1]}]
set_property PACKAGE_PIN e14 [get_ports {O_RGBLED1[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]
set_property DRIVE 12            [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]
set_property SLEW SLOW           [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]


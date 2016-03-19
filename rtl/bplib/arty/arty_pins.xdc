# -*- tcl -*-
# $Id: arty_pins.xdc 740 2016-03-06 20:56:56Z mueller $
#
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Pin locks for Digilent Arty core functionality
#  - USB UART
#  - human I/O (switches, buttons, leds)
#
# Revision History: 
# Date         Rev Version  Comment
# 2016-03-06   740   1.1    add A_VPWRP/N to baseline config
# 2016-01-31   726   1.0    Initial version
#

# config setup --------------------------------------------------------------
set_property CFGBVS         VCCO [current_design]
set_property CONFIG_VOLTAGE  3.3 [current_design]

# clocks -- in bank 35 ------------------------------------------------------
set_property PACKAGE_PIN e3  [get_ports {I_CLK100}]
set_property IOSTANDARD LVCMOS33 [get_ports {I_CLK100}]

#
# USB UART Interface -- in bank 16 ------------------------------------------
set_property PACKAGE_PIN a9  [get_ports {I_RXD}]
set_property PACKAGE_PIN d10 [get_ports {O_TXD}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_RXD O_TXD}]
set_property DRIVE 12   [get_ports {O_TXD}]
set_property SLEW SLOW  [get_ports {O_TXD}]

#
# switches -- in bank 16 ----------------------------------------------------
set_property PACKAGE_PIN a8  [get_ports {I_SWI[0]}]
set_property PACKAGE_PIN c11 [get_ports {I_SWI[1]}]
set_property PACKAGE_PIN c10 [get_ports {I_SWI[2]}]
set_property PACKAGE_PIN a10 [get_ports {I_SWI[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_SWI[*]}]

#
# buttons -- in bank 16 -----------------------------------------------------
set_property PACKAGE_PIN d9  [get_ports {I_BTN[0]}]
set_property PACKAGE_PIN c9  [get_ports {I_BTN[1]}]
set_property PACKAGE_PIN b9  [get_ports {I_BTN[2]}]
set_property PACKAGE_PIN b8  [get_ports {I_BTN[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_BTN[*]}]

#
# LEDs -- in bank 14+35 -----------------------------------------------------
set_property PACKAGE_PIN h5  [get_ports {O_LED[0]}]
set_property PACKAGE_PIN j5  [get_ports {O_LED[1]}]
set_property PACKAGE_PIN t9  [get_ports {O_LED[2]}]
set_property PACKAGE_PIN t10 [get_ports {O_LED[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_LED[*]}]
set_property DRIVE 12            [get_ports {O_LED[*]}]
set_property SLEW SLOW           [get_ports {O_LED[*]}]

#
# RGB-LEDs -- in bank 35 ----------------------------------------------------
#   Note: [0] red  [1] green  [2] blue
set_property PACKAGE_PIN g6  [get_ports {O_RGBLED0[0]}]
set_property PACKAGE_PIN f6  [get_ports {O_RGBLED0[1]}]
set_property PACKAGE_PIN e1  [get_ports {O_RGBLED0[2]}]

set_property PACKAGE_PIN g3  [get_ports {O_RGBLED1[0]}]
set_property PACKAGE_PIN j4  [get_ports {O_RGBLED1[1]}]
set_property PACKAGE_PIN g4  [get_ports {O_RGBLED1[2]}]

set_property PACKAGE_PIN j3  [get_ports {O_RGBLED2[0]}]
set_property PACKAGE_PIN j2  [get_ports {O_RGBLED2[1]}]
set_property PACKAGE_PIN h4  [get_ports {O_RGBLED2[2]}]

set_property PACKAGE_PIN k1  [get_ports {O_RGBLED3[0]}]
set_property PACKAGE_PIN h6  [get_ports {O_RGBLED3[1]}]
set_property PACKAGE_PIN k2  [get_ports {O_RGBLED3[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]
set_property DRIVE 12            [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]
set_property SLEW SLOW           [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_RGBLED2[*] O_RGBLED3[*]}]
set_property DRIVE 12            [get_ports {O_RGBLED2[*] O_RGBLED3[*]}]
set_property SLEW SLOW           [get_ports {O_RGBLED2[*] O_RGBLED3[*]}]

#
# power measurements -- in bank 15 ------------------------------------------
set_property PACKAGE_PIN c12 [get_ports {A_VPWRP[0]}];      # ad1p  -> vaux(1)
set_property PACKAGE_PIN b12 [get_ports {A_VPWRN[0]}];      # ad1n  (VU volt)
set_property PACKAGE_PIN b16 [get_ports {A_VPWRP[1]}];      # ad2p  -> vaux(2)
set_property PACKAGE_PIN b17 [get_ports {A_VPWRN[1]}];      # ad2n  (5V0 volt)   
set_property PACKAGE_PIN f13 [get_ports {A_VPWRP[2]}];      # ad9p  -> vaux(9)
set_property PACKAGE_PIN f14 [get_ports {A_VPWRN[2]}];      # ad9n  (5V0 curr)
set_property PACKAGE_PIN a15 [get_ports {A_VPWRP[3]}];      # ad10p -> vaux(10)
set_property PACKAGE_PIN a16 [get_ports {A_VPWRN[3]}];      # ad10n (0V95 curr)

set_property IOSTANDARD LVCMOS33 [get_ports {A_VPWRP[*] A_VPWRN[*]}]

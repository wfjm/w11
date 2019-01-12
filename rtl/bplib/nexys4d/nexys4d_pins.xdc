# -*- tcl -*-
# $Id: nexys4d_pins.xdc 1099 2018-12-31 09:07:36Z mueller $
#
# Copyright 2017-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Nexys 4DDR core functionality
# - Configuration setup
#   - config voltage
#   - enable bitstream timestamp
# - Pin Locks for
#   - USB UART
#   - human I/O (switches, buttons, leds, display)
#
# Revision History: 
# Date         Rev Version  Comment
# 2018-12-30  1099   1.1    BUFFIX: Fix faulty IO voltage for I_SWI[8,9]
# 2017-01-04   838   1.0    Initial version
#

# config setup --------------------------------------------------------------
set_property CFGBVS         VCCO [current_design]
set_property CONFIG_VOLTAGE  3.3 [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]

# clocks -- in bank 35 ------------------------------------------------------
set_property PACKAGE_PIN e3 [get_ports {I_CLK100}]
set_property IOSTANDARD LVCMOS33 [get_ports {I_CLK100}]

#
# USB UART Interface -- in bank 35 ------------------------------------------
set_property PACKAGE_PIN c4 [get_ports {I_RXD}]
set_property PACKAGE_PIN d4 [get_ports {O_TXD}]
set_property PACKAGE_PIN d3 [get_ports {O_RTS_N}]
set_property PACKAGE_PIN e5 [get_ports {I_CTS_N}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_RXD O_TXD O_RTS_N I_CTS_N}]
set_property DRIVE 12   [get_ports {O_TXD O_RTS_N}]
set_property SLEW SLOW  [get_ports {O_TXD O_RTS_N}]

#
# switches -- in bank 14+15+34 -------------------------------------------------
set_property PACKAGE_PIN j15 [get_ports {I_SWI[0]}]
set_property PACKAGE_PIN l16 [get_ports {I_SWI[1]}]
set_property PACKAGE_PIN m13 [get_ports {I_SWI[2]}]
set_property PACKAGE_PIN r15 [get_ports {I_SWI[3]}]
set_property PACKAGE_PIN r17 [get_ports {I_SWI[4]}]
set_property PACKAGE_PIN t18 [get_ports {I_SWI[5]}]
set_property PACKAGE_PIN u18 [get_ports {I_SWI[6]}]
set_property PACKAGE_PIN r13 [get_ports {I_SWI[7]}]
set_property PACKAGE_PIN t8  [get_ports {I_SWI[8]}]
set_property PACKAGE_PIN u8  [get_ports {I_SWI[9]}]
set_property PACKAGE_PIN r16 [get_ports {I_SWI[10]}]
set_property PACKAGE_PIN t13 [get_ports {I_SWI[11]}]
set_property PACKAGE_PIN h6  [get_ports {I_SWI[12]}]
set_property PACKAGE_PIN u12 [get_ports {I_SWI[13]}]
set_property PACKAGE_PIN u11 [get_ports {I_SWI[14]}]
set_property PACKAGE_PIN v10 [get_ports {I_SWI[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_SWI[*]}]; # bank 14+15
set_property IOSTANDARD LVCMOS18 [get_ports {I_SWI[8]}]; # bank 34
set_property IOSTANDARD LVCMOS18 [get_ports {I_SWI[9]}]; # bank 34

#
# buttons -- in bank 14+15 --------------------------------------------------
#   sequence: clockwise(U-R-D-L) - middle - reset
set_property PACKAGE_PIN m18 [get_ports {I_BTN[0]}]
set_property PACKAGE_PIN m17 [get_ports {I_BTN[1]}]
set_property PACKAGE_PIN p18 [get_ports {I_BTN[2]}]
set_property PACKAGE_PIN p17 [get_ports {I_BTN[3]}]
set_property PACKAGE_PIN n17 [get_ports {I_BTN[4]}]
set_property PACKAGE_PIN c12 [get_ports {I_BTNRST_N}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_BTN[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I_BTNRST_N}]

#
# LEDs -- in bank 14+15------------------------------------------------------
set_property PACKAGE_PIN h17 [get_ports {O_LED[0]}]
set_property PACKAGE_PIN k15 [get_ports {O_LED[1]}]
set_property PACKAGE_PIN j13 [get_ports {O_LED[2]}]
set_property PACKAGE_PIN n14 [get_ports {O_LED[3]}]
set_property PACKAGE_PIN r18 [get_ports {O_LED[4]}]
set_property PACKAGE_PIN v17 [get_ports {O_LED[5]}]
set_property PACKAGE_PIN u17 [get_ports {O_LED[6]}]
set_property PACKAGE_PIN u16 [get_ports {O_LED[7]}]
set_property PACKAGE_PIN v16 [get_ports {O_LED[8]}]
set_property PACKAGE_PIN t15 [get_ports {O_LED[9]}]
set_property PACKAGE_PIN u14 [get_ports {O_LED[10]}]
set_property PACKAGE_PIN t16 [get_ports {O_LED[11]}]
set_property PACKAGE_PIN v15 [get_ports {O_LED[12]}]
set_property PACKAGE_PIN v14 [get_ports {O_LED[13]}]
set_property PACKAGE_PIN v12 [get_ports {O_LED[14]}]
set_property PACKAGE_PIN v11 [get_ports {O_LED[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_LED[*]}]
set_property DRIVE 12            [get_ports {O_LED[*]}]
set_property SLEW SLOW           [get_ports {O_LED[*]}]

#
# RGB-LEDs -- in bank 14+15 -------------------------------------------------
set_property PACKAGE_PIN n15 [get_ports {O_RGBLED0[0]}]
set_property PACKAGE_PIN m16 [get_ports {O_RGBLED0[1]}]
set_property PACKAGE_PIN r12 [get_ports {O_RGBLED0[2]}]

set_property PACKAGE_PIN n16 [get_ports {O_RGBLED1[0]}]
set_property PACKAGE_PIN r11 [get_ports {O_RGBLED1[1]}]
set_property PACKAGE_PIN g14 [get_ports {O_RGBLED1[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]
set_property DRIVE 12            [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]
set_property SLEW SLOW           [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]

#
# 7 segment display -- in bank 14+15-----------------------------------------
set_property PACKAGE_PIN j17 [get_ports {O_ANO_N[0]}]
set_property PACKAGE_PIN j18 [get_ports {O_ANO_N[1]}]
set_property PACKAGE_PIN t9  [get_ports {O_ANO_N[2]}]
set_property PACKAGE_PIN j14 [get_ports {O_ANO_N[3]}]
set_property PACKAGE_PIN p14 [get_ports {O_ANO_N[4]}]
set_property PACKAGE_PIN t14 [get_ports {O_ANO_N[5]}]
set_property PACKAGE_PIN k2  [get_ports {O_ANO_N[6]}]
set_property PACKAGE_PIN u13 [get_ports {O_ANO_N[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_ANO_N[*]}]
set_property DRIVE 12            [get_ports {O_ANO_N[*]}]
set_property SLEW SLOW           [get_ports {O_ANO_N[*]}]
#
set_property PACKAGE_PIN t10 [get_ports {O_SEG_N[0]}]
set_property PACKAGE_PIN r10 [get_ports {O_SEG_N[1]}]
set_property PACKAGE_PIN k16 [get_ports {O_SEG_N[2]}]
set_property PACKAGE_PIN k13 [get_ports {O_SEG_N[3]}]
set_property PACKAGE_PIN p15 [get_ports {O_SEG_N[4]}]
set_property PACKAGE_PIN t11 [get_ports {O_SEG_N[5]}]
set_property PACKAGE_PIN l18 [get_ports {O_SEG_N[6]}]
set_property PACKAGE_PIN h15 [get_ports {O_SEG_N[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_SEG_N[*]}]
set_property DRIVE 12            [get_ports {O_SEG_N[*]}]
set_property SLEW SLOW           [get_ports {O_SEG_N[*]}]
#

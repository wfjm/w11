# -*- tcl -*-
# $Id: cmoda7_pins_sram.xdc 906 2017-06-04 21:59:13Z mueller $
#
# Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Pin locks for CmodA7 sram
#
# Revision History: 
# Date         Rev Version  Comment
# 2017-06-04   906   1.0    Initial version
#

# SRAM -- in bank 14 --------------------------------------------------------
set_property PACKAGE_PIN n19 [get_ports {O_MEM_CE_N}]
set_property PACKAGE_PIN r19 [get_ports {O_MEM_WE_N}]
set_property PACKAGE_PIN p19 [get_ports {O_MEM_OE_N}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_MEM_CE_N O_MEM_WE_N O_MEM_OE_N}]
set_property DRIVE 12            [get_ports {O_MEM_CE_N O_MEM_WE_N O_MEM_OE_N}]
set_property SLEW FAST           [get_ports {O_MEM_CE_N O_MEM_WE_N O_MEM_OE_N}]

#
set_property PACKAGE_PIN m18 [get_ports {O_MEM_ADDR[0]}]
set_property PACKAGE_PIN m19 [get_ports {O_MEM_ADDR[1]}]
set_property PACKAGE_PIN k17 [get_ports {O_MEM_ADDR[2]}]
set_property PACKAGE_PIN n17 [get_ports {O_MEM_ADDR[3]}]
set_property PACKAGE_PIN p17 [get_ports {O_MEM_ADDR[4]}]
set_property PACKAGE_PIN p18 [get_ports {O_MEM_ADDR[5]}]
set_property PACKAGE_PIN r18 [get_ports {O_MEM_ADDR[6]}]
set_property PACKAGE_PIN w19 [get_ports {O_MEM_ADDR[7]}]
set_property PACKAGE_PIN u19 [get_ports {O_MEM_ADDR[8]}]
set_property PACKAGE_PIN v19 [get_ports {O_MEM_ADDR[9]}]
set_property PACKAGE_PIN w18 [get_ports {O_MEM_ADDR[10]}]
set_property PACKAGE_PIN t17 [get_ports {O_MEM_ADDR[11]}]
set_property PACKAGE_PIN t18 [get_ports {O_MEM_ADDR[12]}]
set_property PACKAGE_PIN u17 [get_ports {O_MEM_ADDR[13]}]
set_property PACKAGE_PIN u18 [get_ports {O_MEM_ADDR[14]}]
set_property PACKAGE_PIN v16 [get_ports {O_MEM_ADDR[15]}]
set_property PACKAGE_PIN w16 [get_ports {O_MEM_ADDR[16]}]
set_property PACKAGE_PIN w17 [get_ports {O_MEM_ADDR[17]}]
set_property PACKAGE_PIN v15 [get_ports {O_MEM_ADDR[18]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_MEM_ADDR[*]}]
set_property DRIVE 8             [get_ports {O_MEM_ADDR[*]}]
set_property SLEW FAST           [get_ports {O_MEM_ADDR[*]}]

#
set_property PACKAGE_PIN w15 [get_ports {IO_MEM_DATA[0]}]
set_property PACKAGE_PIN w13 [get_ports {IO_MEM_DATA[1]}]
set_property PACKAGE_PIN w14 [get_ports {IO_MEM_DATA[2]}]
set_property PACKAGE_PIN u15 [get_ports {IO_MEM_DATA[3]}]
set_property PACKAGE_PIN u16 [get_ports {IO_MEM_DATA[4]}]
set_property PACKAGE_PIN v13 [get_ports {IO_MEM_DATA[5]}]
set_property PACKAGE_PIN v14 [get_ports {IO_MEM_DATA[6]}]
set_property PACKAGE_PIN u14 [get_ports {IO_MEM_DATA[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {IO_MEM_DATA[*]}]
set_property DRIVE 8             [get_ports {IO_MEM_DATA[*]}]
set_property SLEW SLOW           [get_ports {IO_MEM_DATA[*]}]
set_property KEEPER true         [get_ports {IO_MEM_DATA[*]}]
#

# -*- tcl -*-
# $Id: generic_clk_100mhz.xdc 777 2016-06-19 20:24:15Z mueller $
#
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Generic constraint for pin CLK with a 100 MHz clock
# Helpful for test benches and generic test synthesis
#
# Revision History: 
# Date         Rev Version  Comment
# 2016-06-19   777   1.0    Initial version

create_clock -name CLK -period 10 -waveform {0 5} [get_ports CLK]

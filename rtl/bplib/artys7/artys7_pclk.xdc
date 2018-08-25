# -*- tcl -*-
# $Id: artys7_pclk.xdc 1038 2018-08-11 12:39:52Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Primary clocks for Digilent Arty
#
# Revision History: 
# Date         Rev Version  Comment
# 2018-08-05  1038   1.0    Initial version
#

create_clock -name I_CLK100 -period 10 -waveform {0 5} [get_ports I_CLK100]

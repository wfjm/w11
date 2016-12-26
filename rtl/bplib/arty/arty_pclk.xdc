# -*- tcl -*-
# $Id: arty_pclk.xdc 830 2016-12-26 20:25:49Z mueller $
#
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Primary clocks for Digilent Arty
#
# Revision History: 
# Date         Rev Version  Comment
# 2016-01-31   726   1.0    Initial version
#

create_clock -name I_CLK100 -period 10 -waveform {0 5} [get_ports I_CLK100]

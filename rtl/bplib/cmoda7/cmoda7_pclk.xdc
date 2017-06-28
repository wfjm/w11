# -*- tcl -*-
# $Id: cmoda7_pclk.xdc 906 2017-06-04 21:59:13Z mueller $
#
# Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Primary clocks for Digilent CmodA7
#
# Revision History: 
# Date         Rev Version  Comment
# 2017-06-04   906   1.0    Initial version
#

create_clock -name I_CLK12 -period 83.33 -waveform {0 41.66} [get_ports I_CLK12]

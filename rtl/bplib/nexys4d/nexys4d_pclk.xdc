# $Id: nexys4d_pclk.xdc 838 2017-01-04 20:57:57Z mueller $
#
# Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Primary clocks for Nexys4 DDR
#
# Revision History: 
# Date         Rev Version  Comment
# 2017-01-04   838   1.0    Initial version
#

create_clock -name I_CLK100 -period 10 -waveform {0 5} [get_ports I_CLK100]

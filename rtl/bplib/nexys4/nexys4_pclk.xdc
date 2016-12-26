# $Id: nexys4_pclk.xdc 830 2016-12-26 20:25:49Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Primary clocks for Nexys4
#
# Revision History: 
# Date         Rev Version  Comment
# 2015-01-25   639   1.0    Initial version
#

create_clock -name I_CLK100 -period 10 -waveform {0 5} [get_ports I_CLK100]

# -*- tcl -*-
# $Id: basys3_pclk.xdc 1190 2019-07-13 17:05:39Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Primary clocks for Digilent Basys3
#
# Revision History: 
# Date         Rev Version  Comment
# 2015-01-25   637   1.0    Initial version
#

create_clock -name I_CLK100 -period 10 -waveform {0 5} [get_ports I_CLK100]

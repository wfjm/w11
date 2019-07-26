# -*- tcl -*-
# $Id: nexys4d_pclk.xdc 1190 2019-07-13 17:05:39Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Primary clocks for Nexys4 DDR
#
# Revision History: 
# Date         Rev Version  Comment
# 2017-01-04   838   1.0    Initial version
#

create_clock -name I_CLK100 -period 10 -waveform {0 5} [get_ports I_CLK100]

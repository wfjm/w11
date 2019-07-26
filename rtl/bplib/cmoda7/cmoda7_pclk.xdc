# -*- tcl -*-
# $Id: cmoda7_pclk.xdc 1190 2019-07-13 17:05:39Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Primary clocks for Digilent CmodA7
#
# Revision History: 
# Date         Rev Version  Comment
# 2017-06-04   906   1.0    Initial version
#

create_clock -name I_CLK12 -period 83.33 -waveform {0 41.66} [get_ports I_CLK12]

# -*- tcl -*-
# $Id: cdc_pulse.xdc 1190 2019-07-13 17:05:39Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# cdc constraints for cdc_pulse
#
# Revision History: 
# Date         Rev Version  Comment
# 2016-03-28   756   1.0    Initial version
#
set clkm [get_clocks -of_objects  [get_cells RM_ACK_S0_reg]]
set clks [get_clocks -of_objects  [get_cells RS_REQ_S0_reg]]

#
# CLKM->CLKS
# capture REQ
set_max_delay \
  -from [get_cells -regexp "RM_REQ_reg"] \
  -to   [get_cells -regexp "RS_REQ_S0_reg"] \
  -datapath_only   [get_property -min PERIOD $clks]

#
# CLKS->CLKM
# capture ACK
set_max_delay \
  -from [get_cells -regexp "RS_REQ_S1_reg"] \
  -to   [get_cells -regexp "RM_ACK_S0_reg"] \
  -datapath_only   [get_property -min PERIOD $clkm]

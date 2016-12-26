# -*- tcl -*-
# $Id: cdc_signal_s1.xdc 830 2016-12-26 20:25:49Z mueller $
#
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# cdc constraints for cdc_signal_s1
#
# Revision History: 
# Date         Rev Version  Comment
# 2016-04-08   759   1.0    Initial version
#

set clko [get_clocks -of_objects  [get_cells R_DO_S0_reg]]
set clko_per80 [expr {0.8 * [get_property -min PERIOD $clko]}]

#
# CLKI->CLK0
# ensure timing delay in DI smaller than a receiver clock cycle
#   Note: -datapath_only requires -from to be specified; -from must be a
#         clock (or primary port); a -from clock can't be reliably determined
#         because 'single signal' synchronizer might be driven by logic or
#         even by a constant. So simply use [get_clock], thus all clocks.
set_max_delay \
  -from [get_clocks] \
  -to   [get_cells {R_DO_S0_reg}] \
  -datapath_only  $clko_per80

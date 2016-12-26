# -*- tcl -*-
# $Id: fifo_2c_dram2.xdc 830 2016-12-26 20:25:49Z mueller $
#
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# cdc constraints for fifo_2c_dram2 core
#
# Revision History: 
# Date         Rev Version  Comment
# 2016-04-17   761   1.1    add false path for hold time through DRAM
# 2016-03-26   752   1.0    Initial version
#

set clkw [get_clocks -of_objects  [get_cells RW_RADDR_S0_reg[0]]]
set clkr [get_clocks -of_objects  [get_cells RR_WADDR_S0_reg[0]]]
set clkw_per80 [expr {0.8 * [get_property -min PERIOD $clkw]}]
set clkr_per80 [expr {0.8 * [get_property -min PERIOD $clkr]}]

#
# CLKR->CLKW
# read address
set_max_delay \
  -from [get_cells -regexp "GCR/.*/R_DATA_reg.*"] \
  -to   [get_cells -regexp "RW_RADDR_S0_reg.*"] \
  -datapath_only   $clkw_per80
# reset
set_max_delay \
  -from $clkr \
  -to   [get_cells  -regexp "RW_(RSTW_E|RSTR)_S0_reg.*"] \
  -datapath_only   $clkw_per80
#
# CLKW->CLKR
# read address
set_max_delay \
  -from [get_cells -regexp "GCW/.*/R_DATA_reg.*"] \
  -to   [get_cells -regexp "RR_WADDR_S0_reg.*"] \
  -datapath_only   $clkr_per80
# reset
set_max_delay \
  -from $clkw \
  -to   [get_cells -regexp "RR_(RSTR_E|RSTW)_S0_reg.*"] \
  -datapath_only   $clkr_per80
#
# handle path from write clock to data output of dual port distributed RAM it's
# conceptualy a false path (this timing should not be relevant). To be on the 
# save side only hold timing is set as false path and a set set_max_delay with
# read side period is used to constrain setup time.
#
set_max_delay \
  -from $clkw \
  -to   $clkr \
  -through [get_cells -regexp "RAM/.*"] \
  [get_property -min PERIOD $clkr]

set_false_path -hold \
  -from $clkw \
  -to   $clkr \
  -through [get_cells -regexp "RAM/.*"] 

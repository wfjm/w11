# -*- tcl -*-
# $Id: cdc_vector_s0.xdc 759 2016-04-09 10:13:57Z mueller $
#
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# cdc constraints for cdc_vector_s0
#
# Revision History: 
# Date         Rev Version  Comment
# 2016-04-08   759   1.0    Initial version
#

# The following determines the input clock assuming that the synchronizer is 
# directly connected to a register. Will not work when logic is inbetween or 
# when driven by a dual-clocked BRAM.
set clki [get_clocks   -of_objects \
           [get_cells -of_objects \
           [get_pins  -filter {DIRECTION==OUT && IS_LEAF==1} -of_objects \
           [get_nets  -segments -of_objects \
           [get_ports -scoped_to_current_instance {DI[0]} ] ] ] ] ]

set clki_per80 [expr {0.8 * [get_property -min PERIOD $clki]}]

#
# CLKI->CLK0
# ensure delay and thus skew in DI smaller than a sender clock cycle
#   Note: the _s0 form should be used for 'quasi static' cases
#         this skew and delay control is therefore bit of an overkill
set_max_delay \
  -from $clki \
  -to   [get_cells {R_DO_S0_reg[*]}] \
  -datapath_only  $clki_per80


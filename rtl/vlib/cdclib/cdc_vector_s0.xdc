# -*- tcl -*-
# $Id: cdc_vector_s0.xdc 1101 2019-01-02 21:22:37Z mueller $
#
# Copyright 2016-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# cdc constraints for cdc_vector_s0
#
# Revision History: 
# Date         Rev Version  Comment
# 2019-01-02  1101   1.1    contrain on both input and output clock period
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
set clko [get_clocks -of_objects  [get_cells {R_DO_S0_reg[*]} ] ]

set clki_per50 [expr {0.5 * [get_property -min PERIOD $clki]}]
set clko_per50 [expr {0.5 * [get_property -min PERIOD $clko]}]
set maxdly [expr { min($clki_per50,$clko_per50) }]

#
# CLKI->CLKO
# Ensure delay and thus skew of the DI->R_DO datapath is smaller than
# 80% of both the input and the output clock period. That should be
# save in all usage modes.
set_max_delay \
  -from $clki \
  -to   [get_cells {R_DO_S0_reg[*]}] \
  -datapath_only  $maxdly


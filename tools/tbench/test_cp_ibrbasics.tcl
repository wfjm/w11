# $Id: test_cp_ibrbasics.tcl 552 2014-03-02 23:02:00Z mueller $
#
# Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2014-03-02   552   1.0    Initial version
#
# Test very basic memory interface gymnastics
#  2. write/read IB space via bwm/brm (use MMU SAR SM I regs)
#

# ----------------------------------------------------------------------------
rlc log "test_cp_membasics: Test very basic ibus interface gymnastics"

rlc log "  write/read ibus space (MMU SAR SM I regs) via bwm/brm"
$cpu cp -wal 0172240 \
        -bwm {012340 012342 012344}

$cpu cp -wal 0172240 \
        -brm 3 -edata {012340 012342 012344}

# --------------------------------------------------------------------

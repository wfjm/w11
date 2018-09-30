# $Id: test_pcnt_regs.tcl 1050 2018-09-23 15:46:42Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2018-09-23  1450   1.0    Initial version
#
# Test register response 

# ----------------------------------------------------------------------------
rlc log "test_pcnt_regs: test register response ------------------------------"

if {[$cpu get haspcnt] == 0} {
  rlc log "  test_pcnt_regs-W: no pcnt unit found, test aborted"
  return
}

# -- Section A ---------------------------------------------------------------
rlc log "  A basic register access tests -----------------------------"

rlc log "    A1: write cntl, read stat --------------------------"
# test start,stop works and run flag follows
$cpu cp \
  -wreg pc.cntl [regbld rw11::PC_CNTL {func "CLR"}] \
  -rreg pc.stat -edata [regbld rw11::PC_STAT] \
  -wreg pc.cntl [regbld rw11::PC_CNTL {func "STA"}] \
  -rreg pc.stat -edata [regbld rw11::PC_STAT run] \
  -wreg pc.cntl [regbld rw11::PC_CNTL {func "STO"}] \
  -rreg pc.stat -edata [regbld rw11::PC_STAT]
# test that load works, caddr and ainc follow in status, and that clr clears
$cpu cp \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr 0x07 ainc 0] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr 0x07 ainc 0]  \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr 0x17 ainc 1] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr 0x17 ainc 1] \
  -wreg pc.cntl [regbld rw11::PC_CNTL {func "CLR"}] \
  -rreg pc.stat -edata [regbld rw11::PC_STAT]

rlc log "    A2: test err when written --------------------------"
$cpu cp \
  -wreg pc.stat 0x100 -estaterr \
  -wreg pc.data 0x100 -estaterr

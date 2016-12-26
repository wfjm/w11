# $Id: test_cmon_regs.tcl 830 2016-12-26 20:25:49Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-07-18   701   1.0    Initial version
#
# Test register response 

# ----------------------------------------------------------------------------
rlc log "test_cmon_regs: test register response ------------------------------"

if {[$cpu get hascmon] == 0} {
  rlc log "  test_cmon_regs-W: no cmon unit found, test aborted"
  return
}

# -- Section A ---------------------------------------------------------------
rlc log "  A basic register access tests -----------------------------"

rlc log "    A1: test cntl --------------------------------------"
# reset cmon
$cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL start stop] \
        -rreg cm.cntl -edata 0

# test imode, wena bits (set only when start=1)
  $cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL start] \
          -rreg cm.cntl -edata [regbld rw11::CM_CNTL start] \
          -wreg cm.cntl [regbld rw11::CM_CNTL wena start] \
          -rreg cm.cntl -edata [regbld rw11::CM_CNTL wena start] \
          -wreg cm.cntl [regbld rw11::CM_CNTL imode wena start] \
          -rreg cm.cntl -edata [regbld rw11::CM_CNTL imode wena start]
# test imode, wena bits (kept when start=0)
  $cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL stop] \
          -rreg cm.cntl -edata [regbld rw11::CM_CNTL imode wena] \
          -wreg cm.cntl [regbld rw11::CM_CNTL start stop] \
          -rreg cm.cntl -edata 0 \
          -wreg cm.cntl [regbld rw11::CM_CNTL imode] \
          -rreg cm.cntl -edata 0 \
          -wreg cm.cntl [regbld rw11::CM_CNTL wena] \
          -rreg cm.cntl -edata 0 

# start cmon
$cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL start] \
        -rreg cm.cntl -edata [regbld rw11::CM_CNTL start]

rlc log "    A2: test stat --------------------------------------"
# is read only
$cpu cp -rreg cm.stat \
        -wreg cm.stat 0 -estaterr

rlc log "    A3: test addr ---------------------------------------"
rlc log "    A3.1: when stopped ----------------------------------"
# start will clear addr
$cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL stop] \
        -rreg cm.cntl -edata 0 \
        -wreg cm.addr [regbld rw11::CM_ADDR {laddr 017} {waddr 03}] \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 017} {waddr 03}] \
        -wreg cm.cntl [regbld rw11::CM_CNTL start] \
        -rreg cm.cntl -edata [regbld rw11::CM_CNTL start] \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 0} {waddr 0}]
rlc log "    A3.2: test err when started and written ------------"
$cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL start] \
        -wreg cm.addr 0x1234 -estaterr 

rlc log "    A4: test data --------------------------------------"
rlc log "    A4.1: when stopped ---------------------------------"
# stop, set addr, and nine times data, check addr
$cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL stop] \
        -wreg cm.addr [regbld rw11::CM_ADDR {laddr 010} {waddr 0}] \
        -rreg cm.data \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 010} {waddr 001}] \
        -rreg cm.data \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 010} {waddr 002}] \
        -rreg cm.data \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 010} {waddr 003}] \
        -rreg cm.data \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 010} {waddr 004}]
# at 9th data read waddr goes 0 and laddr incs
$cpu cp -rreg cm.data \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 010} {waddr 005}] \
        -rreg cm.data \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 010} {waddr 006}] \
        -rreg cm.data \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 010} {waddr 007}] \
        -rreg cm.data \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 010} {waddr 010}] \
        -rreg cm.data \
        -rreg cm.addr -edata [regbld rw11::CM_ADDR {laddr 011} {waddr 000}]

rlc log "    A4.2: test err when started or written -------------"
$cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL start] \
        -rreg cm.data -estaterr \
        -wreg cm.cntl [regbld rw11::CM_CNTL stop] \
        -wreg cm.data 0 -estaterr 

rlc log "    A5: test imon section; readable, not writable ------"
$cpu cp -rreg cm.iaddr \
        -rreg cm.ipc   \
        -rreg cm.ireg  \
        -rreg cm.imal  \
        -wreg cm.iaddr 0 -estaterr \
        -wreg cm.ipc   0 -estaterr \
        -wreg cm.ireg  0 -estaterr \
        -wreg cm.imal  0 -estaterr

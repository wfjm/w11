# $Id: test_cmon_regs.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-03-02  1116   2.0.1  add a few cntl logic tests
# 2017-04-23   885   2.0    adopt to revised interface
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

rlc log "    A1: write/read cntl---------------------------------"
# test that starting captures option flags, and that stoping keeps them
# test that NOOP is a noop and doesn't change flags
$cpu cp \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "STA"}] \
  -rreg cm.cntl -edata [regbld rw11::CM_CNTL] \
  -wreg cm.cntl [regbld rw11::CM_CNTL wstop {func "STA"}] \
  -rreg cm.cntl -edata  [regbld rw11::CM_CNTL wstop] \
  -wreg cm.cntl [regbld rw11::CM_CNTL imode {func "STA"}] \
  -rreg cm.cntl -edata  [regbld rw11::CM_CNTL imode] \
  -wreg cm.cntl [regbld rw11::CM_CNTL mwsup {func "STA"}] \
  -rreg cm.cntl -edata  [regbld rw11::CM_CNTL mwsup] \
  -wreg cm.cntl [regbld rw11::CM_CNTL wstop mwsup {func "STA"}] \
  -rreg cm.cntl -edata  [regbld rw11::CM_CNTL wstop mwsup] \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "STO"}] \
  -rreg cm.cntl -edata  [regbld rw11::CM_CNTL wstop mwsup] \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "NOOP"}] \
  -rreg cm.cntl -edata  [regbld rw11::CM_CNTL wstop mwsup]

rlc log "    A2: write cntl, read stat --------------------------"
# test that susp/run follow functions set to cntl
# test that sus/res does not change option flags
set statmsk [regbld rw11::CM_STAT wrap susp run] 
$cpu cp \
  -wreg cm.cntl [regbld rw11::CM_CNTL wstop imode {func "STA"}] \
  -rreg cm.cntl -edata  [regbld rw11::CM_CNTL wstop imode] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT run] $statmsk \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "SUS"}] \
  -rreg cm.cntl -edata  [regbld rw11::CM_CNTL wstop imode] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT susp run] $statmsk \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "RES"}] \
  -rreg cm.cntl -edata  [regbld rw11::CM_CNTL wstop imode] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT run] $statmsk \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "STO"}] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT] $statmsk 
# test that suspend/resume of a stopped system is a noop
$cpu cp \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "SUS"}] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT] $statmsk \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "RES"}] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT] $statmsk
# test that start of a suspended system clears suspend
$cpu cp \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "STA"}] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT run] $statmsk \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "SUS"}] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT susp run] $statmsk \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "STA"}] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT run] $statmsk
# test that suspend of a suspended system is a noop
# test that stop of a suspended system clears suspend
$cpu cp \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "STA"}] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT run] $statmsk \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "SUS"}] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT susp run] $statmsk \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "SUS"}] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT susp run] $statmsk \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "STO"}] \
  -rreg cm.stat -edata [regbld rw11::CM_STAT] $statmsk
# get amax for later usage
$cpu cp \
  -rreg cm.stat rstat
set bsize [regget rbmoni::STAT(bsize) $rstat]
set amax  [expr {( 256 << $bsize ) - 1}]

rlc log "    A3: test addr --------------------------------------"
rlc log "    A3.1: write/read addr when stopped -----------------"
foreach {laddr waddr} [list 0x0000 0 0x0000 7 $amax 0 $amax 8] {
  set addr [regbld rw11::CM_ADDR [list laddr $laddr] [list waddr $waddr]]
  $cpu cp \
    -wreg cm.addr $addr \
    -rreg cm.addr -edata $addr
}

rlc log "    A3.2: verify that starting clears addr -------------"
$cpu cp \
  -wreg cm.cntl [regbldkv rw11::CM_CNTL func "STO"] \
  -wreg cm.addr [regbldkv rw11::CM_ADDR laddr $amax] \
  -rreg cm.addr -edata [regbldkv rw11::CM_ADDR laddr $amax] \
  -wreg cm.cntl [regbldkv rw11::CM_CNTL func "STA"] \
  -rreg cm.addr -edata 0x00 \
  -wreg cm.cntl [regbldkv rw11::CM_CNTL func "STO"]

rlc log "    A3.3: test err when started and addr written -------"
$cpu cp \
  -wreg cm.cntl [regbldkv rw11::CM_CNTL func "STA"] \
  -wreg cm.addr 0x100 -estaterr \
  -wreg cm.cntl [regbldkv rw11::CM_CNTL func "STO"]

rlc log "    A4: test data --------------------------------------"
rlc log "    A4.1: when stopped ---------------------------------"
# stop, set addr, and nine times data, check addr
$cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL {func "STO"}] \
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

rlc log "    A4.2: test err when written ------------------------"
$cpu cp -wreg cm.data 0x100 -estaterr

rlc log "    A5: test imon section; readable, not writable ------"
$cpu cp -rreg cm.iaddr \
        -rreg cm.ipc   \
        -rreg cm.ireg  \
        -rreg cm.imal  \
        -wreg cm.iaddr 0 -estaterr \
        -wreg cm.ipc   0 -estaterr \
        -wreg cm.ireg  0 -estaterr \
        -wreg cm.imal  0 -estaterr

# $Id: test_ibmon_regs.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-03-01  1116   1.0    Initial version
# 2019-02-24  1115   0.1    First draft
#
# Test register response 

# ----------------------------------------------------------------------------
rlc log "test_ibmon_regs: test register response -----------------------------"

if {[$cpu get hasibmon] == 0} {
  rlc log "  test_ibmon_regs-W: no ibmon unit found, test aborted"
  return
}
package require ibd_ibmon

# -- Section A ---------------------------------------------------------------
rlc log "  A basic register access tests -----------------------------"

rlc log "    A1: write/read cntl---------------------------------"
# test that starting captures option flags, and that stoping keeps them
# test that NOOP is a noop and doesn't change flags
$cpu cp \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "STA"}] \
  -rreg im.cntl -edata [regbld ibd_ibmon::CNTL] \
  -wreg im.cntl [regbld ibd_ibmon::CNTL locena {func "STA"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL locena] \
  -wreg im.cntl [regbld ibd_ibmon::CNTL remena {func "STA"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL remena] \
  -wreg im.cntl [regbld ibd_ibmon::CNTL conena {func "STA"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL conena] \
  -wreg im.cntl [regbld ibd_ibmon::CNTL wstop {func "STA"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL wstop] \
  -wreg im.cntl [regbld ibd_ibmon::CNTL rcolr {func "STA"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL rcolr] \
  -wreg im.cntl [regbld ibd_ibmon::CNTL rcolw {func "STA"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL rcolw] \
  -wreg im.cntl [regbld ibd_ibmon::CNTL wstop remena locena {func "STA"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL wstop remena locena ] \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "STO"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL wstop remena locena] \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "NOOP"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL wstop remena locena]

rlc log "    A2: write cntl, read stat --------------------------"
# test that susp/run follow functions set to cntl
# test that sus/res does not change option flags
set statmsk [regbld ibd_ibmon::STAT wrap susp run] 
$cpu cp \
  -wreg im.cntl [regbld ibd_ibmon::CNTL wstop locena {func "STA"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL wstop locena ] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT run] $statmsk \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "SUS"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL wstop locena ] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT susp run] $statmsk \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "RES"}] \
  -rreg im.cntl -edata  [regbld ibd_ibmon::CNTL wstop locena ] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT run] $statmsk \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "STO"}] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT] $statmsk 
# test that suspend/resume of a stopped system is a noop
$cpu cp \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "SUS"}] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT] $statmsk \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "RES"}] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT] $statmsk
# test that start of a suspended system clears suspend
$cpu cp \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "STA"}] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT run] $statmsk \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "SUS"}] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT susp run] $statmsk \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "STA"}] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT run] $statmsk
# test that suspend of a suspended system is a noop
# test that stop of a suspended system clears suspend
$cpu cp \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "STA"}] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT run] $statmsk \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "SUS"}] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT susp run] $statmsk \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "SUS"}] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT susp run] $statmsk \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "STO"}] \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT] $statmsk
# get amax for later usage
$cpu cp \
  -rreg im.stat rstat
set bsize [regget ibd_ibmon::STAT(bsize) $rstat]
set amax  [expr {( 256 << $bsize ) - 1}]

rlc log "    A3: test addr --------------------------------------"
rlc log "    A3.1: write/read addr when stopped -----------------"
foreach {laddr waddr} [list 0x0000 0 0x0000 3 $amax 0 $amax 3] {
  set addr [regbld ibd_ibmon::ADDR [list laddr $laddr] [list waddr $waddr]]
  $cpu cp \
    -wreg im.addr $addr \
    -rreg im.addr -edata $addr
}

rlc log "    A3.2: verify that starting clears addr -------------"
$cpu cp \
  -wreg im.cntl [regbldkv ibd_ibmon::CNTL func "STO"] \
  -wreg im.addr [regbldkv ibd_ibmon::ADDR laddr $amax] \
  -rreg im.addr -edata [regbldkv ibd_ibmon::ADDR laddr $amax] \
  -wreg im.cntl [regbldkv ibd_ibmon::CNTL func "STA"] \
  -rreg im.addr -edata 0x00 \
  -wreg im.cntl [regbldkv ibd_ibmon::CNTL func "STO"]

rlc log "    A3.3: test err when started and addr written -------"
$cpu cp \
  -wreg im.cntl [regbldkv ibd_ibmon::CNTL func "STA"] \
  -wreg im.addr 0x100 -estaterr \
  -wreg im.cntl [regbldkv ibd_ibmon::CNTL func "STO"]

rlc log "    A4: test data --------------------------------------"
rlc log "    A4.1: when stopped ---------------------------------"
# stop, set addr, and four times data, check addr
# at 5th data read waddr goes 0 and laddr incs
$cpu cp \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "STO"}] \
  -wreg im.addr [regbld ibd_ibmon::ADDR {laddr 010} {waddr 0}] \
  -rreg im.data \
  -rreg im.addr -edata [regbld ibd_ibmon::ADDR {laddr 010} {waddr 001}] \
  -rreg im.data \
  -rreg im.addr -edata [regbld ibd_ibmon::ADDR {laddr 010} {waddr 002}] \
  -rreg im.data \
  -rreg im.addr -edata [regbld ibd_ibmon::ADDR {laddr 010} {waddr 003}] \
  -rreg im.data \
  -rreg im.addr -edata [regbld ibd_ibmon::ADDR {laddr 011} {waddr 000}]

rlc log "    A4.2: test err when written ------------------------"
$cpu cp -wreg im.data 0x100 -estaterr

rlc log "    A5: test hilim/lolim -------------------------------"
# check also that upper 3 bits are stuck 1, lsb stuck 0
$cpu cp \
  -wreg im.hilim        0162346 \
  -wreg im.lolim        0161234 \
  -rreg im.hilim -edata 0162346 \
  -rreg im.lolim -edata 0161234 \
  -wreg im.hilim        0017777 \
  -wreg im.lolim        0000001 \
  -rreg im.hilim -edata 0177776 \
  -rreg im.lolim -edata 0160000

rlc log "    A6: test reset behavior ----------------------------"
# a reset will start ibtst with conena remena locena and hilim/lolim fully open

rlc log "    A6.1: no reset on BRESET ---------------------------"
# no reset on BRESET and CRESET (cp -creset), only on GRESET (rbus init)
$cpu cp \
  -wreg im.hilim        0172000 \
  -wreg im.lolim        0171000 \
  -wreg im.cntl [regbld ibd_ibmon::CNTL wstop locena {func "STA"}] \
  -wreg im.cntl [regbld ibd_ibmon::CNTL {func "SUS"}] \
  -rreg im.cntl  -edata [regbld ibd_ibmon::CNTL wstop locena] \
  -rreg im.stat  -edata [regbld ibd_ibmon::STAT susp run] $statmsk \
  -rreg im.hilim -edata 0172000 \
  -rreg im.lolim -edata 0171000 \
  -breset \
  -rreg im.cntl  -edata [regbld ibd_ibmon::CNTL wstop locena] \
  -rreg im.stat  -edata [regbld ibd_ibmon::STAT susp run] $statmsk \
  -rreg im.hilim -edata 0172000 \
  -rreg im.lolim -edata 0171000

rlc log "    A6.2: no reset on CRESET ---------------------------"
$cpu cp \
  -creset \
  -rreg im.cntl  -edata [regbld ibd_ibmon::CNTL wstop locena] \
  -rreg im.stat  -edata [regbld ibd_ibmon::STAT susp run] $statmsk \
  -rreg im.hilim -edata 0172000 \
  -rreg im.lolim -edata 0171000

rlc log "    A6.2: test reset on GRESET -------------------------"
# GRESET, triggered by rbus init against cpu conf register

rlc exec -init [$cpu rmap conf] [regbld rw11::INIT greset]

$cpu cp \
  -rreg im.cntl  -edata [regbld ibd_ibmon::CNTL conena remena locena] \
  -rreg im.stat  -edata [regbld ibd_ibmon::STAT run] $statmsk \
  -rreg im.hilim -edata 0177776 \
  -rreg im.lolim -edata 0160000

# harvest breset/creset triggered attn's
rlc exec -attn 
rlc wtlam 0.

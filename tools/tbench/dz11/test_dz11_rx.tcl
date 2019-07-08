# $Id: test_dz11_rx.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-05-18  1150   1.0    Initial version
# 2019-05-04  1146   0.1    First draft
#
# Test DZ11 receiver response

# ----------------------------------------------------------------------------
rlc log "test_dz11_rx: test dz11 receiver data path --------------------------"
package require ibd_dz11
if {![ibd_dz11::setup]} {
  rlc log "  test_dz11_rx-W: device not found, test aborted"
  return
}

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

set attndl  [expr {1<<$ibd_dz11::ANUM}]
set attncpu [expr {1<<$rw11::ANUM}]

# -- Section A ---------------------------------------------------------------
rlc log "  A1: init dz11 ---------------------------------------------"
# - issue csr.clr
# - remember 'awdth' retrieved from rcsr for later tests
# - set rlim's to 0, clear fifos
# - harvest any dangling attn
$cpu cp \
  -wma   dza.csr         [regbld ibd_dz11::CSR clr] \
  -ribr  dza.csr dzcntl \
  -wibr  dza.csr         [regbld ibd_dz11::RRLIMW {rrlim 0} {trlim 0} \
                            rcl tcl {func "SRLIM"}]
set awdth  [regget ibd_dz11::RCNTLR(awdth) $dzcntl]
rlc exec -attn 
rlc wtlam 0.

rlc log "  A2: basic data path ---------------------------------------"
rlc log "    A2.1: reset and setup with line 4 ------------------"

set csrmask [regbld ibd_dz11::CSR trdy tie sa sae rdone rie mse maint]

# - loc csr.mse=1
# - loc rx enable line 4
# - rem check rxon value
# - rem check  csr cal message
# - rem check rxon cal message
$cpu cp \
  -breset \
  -wma   dza.csr         [regbld ibd_dz11::CSR mse] \
  -wma   dza.rbuf        [regbld ibd_dz11::LPR {rxon 1} {line 4}] \
  -wibr  dza.csr         [regbld ibd_dz11::RCNTLW  {ssel "BRRX"}] \
  -ribr  dza.rbuf -edata [regbld ibd_dz11::RSBRRX {brk 0x0} {rxon 0x10}] \
  -ribr  dza.tcr  -edata [regbld ibd_dz11::RFUSE {rfuse 0} {tfuse 2}] \
  -ribr  dza.tdr  -edata [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 1 \
                            line $ibd_dz11::CAL_CSR \
                            data [regbld ibd_dz11::CSR mse]] \
  -ribr  dza.tdr  -edata [regbldkv ibd_dz11::RFDAT  val 1 last 1 cal 1 \
                           line $ibd_dz11::CAL_RXON data 0x10] \
  -rma  dza.csr  -edata [regbld ibd_dz11::CSR mse] $csrmask

# - rem wr fifo
# - loc rd rbuf
rlc log "    A2.2: rem fifo -> loc rbuf - 1 char ----------------"
$cpu cp \
  -wibr  dza.tdr         [regbld ibd_dz11::RFDAT {line 4} {data 0x41} ] \
  -ribr  dza.tcr  -edata [regbld ibd_dz11::RFUSE {rfuse 1} {tfuse 0}] \
  -rma   dza.csr  -edata [regbld ibd_dz11::CSR mse rdone] $csrmask \
  -rma   dza.rbuf -edata [regbld ibd_dz11::RBUF val {line 4} {data 0x41}] \
  -ribr  dza.tcr  -edata [regbld ibd_dz11::RFUSE {rfuse 0} {tfuse 0}] \
  -rma   dza.csr  -edata [regbld ibd_dz11::CSR mse ] $csrmask \
  -rma   dza.rbuf -edata 0x0 [regbld ibd_dz11::RBUF val]

# - loc rx enable line 5,6
# - rem check rxon value
# - rem check rxon cal messages (one per update)
# - rem wr fifo with data for line 4,5,6 but also 1,2,3
# - loc rd rbuf (only line 4,5,6 line data appears)
rlc log "    A3.3: rem fifo -> loc rbuf - 5 char for line 4,5,6 -"
$cpu cp \
  -wma   dza.rbuf        [regbld ibd_dz11::LPR {rxon 1} {line 5}] \
  -wibr  dza.csr         [regbld ibd_dz11::RCNTLW  {ssel "BRRX"}] \
  -wma   dza.rbuf        [regbld ibd_dz11::LPR {rxon 1} {line 6}] \
  -ribr  dza.rbuf -edata [regbld ibd_dz11::RSBRRX {brk 0x0} {rxon 0x70}] \
  -ribr  dza.tcr  -edata [regbld ibd_dz11::RFUSE {rfuse 0} {tfuse 2}] \
  -ribr  dza.tdr  -edata [regbldkv ibd_dz11::RFDAT \
                           val 1 last 0 cal 1 \
                           line $ibd_dz11::CAL_RXON data 0x30] \
  -ribr  dza.tdr  -edata [regbldkv ibd_dz11::RFDAT \
                           val 1 last 1 cal 1 \
                           line $ibd_dz11::CAL_RXON data 0x70] \
  -wbibr dza.tdr [list \
                    [regbld ibd_dz11::RFDAT {line 1} {data 0x11} ] \
                    [regbld ibd_dz11::RFDAT {line 4} {data 0x42} ] \
                    [regbld ibd_dz11::RFDAT {line 2} {data 0x21} ] \
                    [regbld ibd_dz11::RFDAT {line 5} {data 0x51} ] \
                    [regbld ibd_dz11::RFDAT {line 6} {data 0x61} ] \
                    [regbld ibd_dz11::RFDAT {line 3} {data 0x31} ] \
                    [regbld ibd_dz11::RFDAT {line 5} {data 0x52} ] \
                    [regbld ibd_dz11::RFDAT {line 4} {data 0x43} ]] \
  -ribr  dza.tcr  -edata [regbld ibd_dz11::RFUSE {rfuse 5} {tfuse 0}] \
  -rma   dza.csr  -edata [regbld ibd_dz11::CSR mse rdone] $csrmask \
  -rma   dza.rbuf -edata [regbld ibd_dz11::RBUF val {line 4} {data 0x42}] \
  -ribr  dza.tcr  -edata [regbld ibd_dz11::RFUSE {rfuse 4} {tfuse 0}] \
  -rma   dza.csr  -edata [regbld ibd_dz11::CSR mse rdone] $csrmask \
  -rma   dza.rbuf -edata [regbld ibd_dz11::RBUF val {line 5} {data 0x51}] \
  -ribr  dza.tcr  -edata [regbld ibd_dz11::RFUSE {rfuse 3} {tfuse 0}] \
  -rma   dza.csr  -edata [regbld ibd_dz11::CSR mse rdone] $csrmask \
  -rma   dza.rbuf -edata [regbld ibd_dz11::RBUF val {line 6} {data 0x61}] \
  -ribr  dza.tcr  -edata [regbld ibd_dz11::RFUSE {rfuse 2} {tfuse 0}] \
  -rma   dza.csr  -edata [regbld ibd_dz11::CSR mse rdone] $csrmask \
  -rma   dza.rbuf -edata [regbld ibd_dz11::RBUF val {line 5} {data 0x52}] \
  -ribr  dza.tcr  -edata [regbld ibd_dz11::RFUSE {rfuse 1} {tfuse 0}] \
  -rma   dza.csr  -edata [regbld ibd_dz11::CSR mse rdone] $csrmask \
  -rma   dza.rbuf -edata [regbld ibd_dz11::RBUF val {line 4} {data 0x43}] \
  -ribr  dza.tcr  -edata [regbld ibd_dz11::RFUSE {rfuse 0} {tfuse 0}] \
  -rma   dza.csr  -edata [regbld ibd_dz11::CSR mse] $csrmask \
  -rma   dza.rbuf -edata 0x0 [regbld ibd_dz11::RBUF val]

# harvest any dangling attn
rlc exec -attn 
rlc wtlam 0.

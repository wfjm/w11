# $Id: test_m9312_all.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-04-30  1143   1.0    Initial version
#
# Test register response 

# ----------------------------------------------------------------------------
rlc log "test_m9312_all: test m9312 response ---------------------------------"

if {[$cpu get hasm9312] == 0} {
  rlc log "  test_m9312_regs-W: no m9312 unit found, test aborted"
  return
}
package require ibd_m9312

# -- Section A ---------------------------------------------------------------
rlc log "  A1: test csr response (rem) -------------------------------"

# test csr bits
$cpu cp \
  -wibr m9.csr         [regbld ibd_m9312::RCSR locwe] \
  -ribr m9.csr -edata  [regbld ibd_m9312::RCSR locwe] \
  -wibr m9.csr         [regbld ibd_m9312::RCSR enahi] \
  -ribr m9.csr -edata  [regbld ibd_m9312::RCSR enahi] \
  -wibr m9.csr         [regbld ibd_m9312::RCSR enalo] \
  -ribr m9.csr -edata  [regbld ibd_m9312::RCSR enalo]
# test that only csr is rem accessible, and not rest of LO-ROM and HI-ROM
$cpu cp \
  -ribr [expr $ibd_m9312::A_LOROM + 0002]  -estaterr \
  -ribr [expr $ibd_m9312::A_LOROM + 0776]  -estaterr \
  -ribr [expr $ibd_m9312::A_HIROM       ]  -estaterr \
  -ribr [expr $ibd_m9312::A_HIROM + 0776]  -estaterr

rlc log "  A2: csr.locwe=1: loc write ROM ----------------------------"
$cpu cp \
  -wibr m9.csr [regbld ibd_m9312::RCSR locwe] \
  -wma [expr $ibd_m9312::A_LOROM + 0000] 0100000 \
  -wma [expr $ibd_m9312::A_LOROM + 0200] 0100222 \
  -wma [expr $ibd_m9312::A_LOROM + 0400] 0100444 \
  -wma [expr $ibd_m9312::A_LOROM + 0600] 0100666 \
  -wma [expr $ibd_m9312::A_LOROM + 0776] 0100777 \
  -wma [expr $ibd_m9312::A_HIROM + 0000] 0101000 \
  -wma [expr $ibd_m9312::A_HIROM + 0200] 0101222 \
  -wma [expr $ibd_m9312::A_HIROM + 0400] 0101444 \
  -wma [expr $ibd_m9312::A_HIROM + 0600] 0101666 \
  -wma [expr $ibd_m9312::A_HIROM + 0776] 0101777

rlc log "  A3: csr.locwe=0: loc write ROM fails ----------------------"
$cpu cp \
  -wibr m9.csr [regbld ibd_m9312::RCSR enahi enalo] \
  -wma [expr $ibd_m9312::A_LOROM + 0000] 0xdead -estaterr \
  -wma [expr $ibd_m9312::A_LOROM + 0776] 0xbeaf -estaterr \
  -wma [expr $ibd_m9312::A_HIROM + 0000] 0xdead -estaterr \
  -wma [expr $ibd_m9312::A_HIROM + 0776] 0xbeaf -estaterr

rlc log "  A4: csr.enalo=1,enahi=1: all ROM readable -----------------"
$cpu cp \
  -wibr m9.csr        [regbld ibd_m9312::RCSR enahi enalo] \
  -ribr m9.csr -edata [regbld ibd_m9312::RCSR enahi enalo] \
  -rma [expr $ibd_m9312::A_LOROM + 0000] -edata 0100000 \
  -rma [expr $ibd_m9312::A_LOROM + 0200] -edata 0100222 \
  -rma [expr $ibd_m9312::A_LOROM + 0400] -edata 0100444 \
  -rma [expr $ibd_m9312::A_LOROM + 0600] -edata 0100666 \
  -rma [expr $ibd_m9312::A_LOROM + 0776] -edata 0100777 \
  -rma [expr $ibd_m9312::A_HIROM + 0000] -edata 0101000 \
  -rma [expr $ibd_m9312::A_HIROM + 0200] -edata 0101222 \
  -rma [expr $ibd_m9312::A_HIROM + 0400] -edata 0101444 \
  -rma [expr $ibd_m9312::A_HIROM + 0600] -edata 0101666 \
  -rma [expr $ibd_m9312::A_HIROM + 0776] -edata 0101777

rlc log "  A4: csr.enalo=1,enahi=0: only LO-ROM visible --------------"
$cpu cp \
  -wibr m9.csr [regbld ibd_m9312::RCSR enalo] \
  -rma [expr $ibd_m9312::A_LOROM + 0000] -edata 0100000 \
  -rma [expr $ibd_m9312::A_LOROM + 0776] -edata 0100777 \
  -rma [expr $ibd_m9312::A_HIROM + 0000] -estaterr \
  -rma [expr $ibd_m9312::A_HIROM + 0776] -estaterr

rlc log "  A4: csr.enalo=0,enahi=1: only HI-ROM visible --------------"
$cpu cp \
  -wibr m9.csr [regbld ibd_m9312::RCSR enahi] \
  -rma [expr $ibd_m9312::A_LOROM + 0000] -estaterr \
  -rma [expr $ibd_m9312::A_LOROM + 0776] -estaterr \
  -rma [expr $ibd_m9312::A_HIROM + 0000] -edata 0101000 \
  -rma [expr $ibd_m9312::A_HIROM + 0776] -edata 0101777

rlc log "  A4: csr.enalo=0,enahi=0: no ROM visible -------------------"
$cpu cp \
  -wibr m9.csr [regbld ibd_m9312::RCSR] \
  -rma [expr $ibd_m9312::A_LOROM + 0000] -estaterr \
  -rma [expr $ibd_m9312::A_LOROM + 0776] -estaterr \
  -rma [expr $ibd_m9312::A_HIROM + 0000] -estaterr \
  -rma [expr $ibd_m9312::A_HIROM + 0776] -estaterr

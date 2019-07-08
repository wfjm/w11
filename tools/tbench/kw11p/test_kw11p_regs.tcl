# $Id: test_kw11p_regs.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-04-24  1138   1.1    add csr.erate field test; use loc access
# 2018-09-15  1045   1.0    Initial version
# 2018-09-09  1044   0.1    First draft
#
# Test register response 

# ----------------------------------------------------------------------------
rlc log "test_kw11p_regs: test register response -----------------------------"

if {[$cpu get haskw11p] == 0} {
  rlc log "  test_kw11p_regs-W: no kw11p unit found, test aborted"
  return
}

# -- Section A ---------------------------------------------------------------
rlc log "  A basic register access tests -----------------------------"

rlc log "    A1: write/read csr ---------------------------------"
# test that ie,updn,mode and rate are write/readable; done,err not writable
$cpu cp \
  -wma  kwp.csr        [regbld rw11::KW11P_CSR ie] \
  -rma  kwp.csr -edata [regbld rw11::KW11P_CSR ie] \
  -wma  kwp.csr        [regbld rw11::KW11P_CSR updn] \
  -rma  kwp.csr -edata [regbld rw11::KW11P_CSR updn] \
  -wma  kwp.csr        [regbld rw11::KW11P_CSR mode] \
  -rma  kwp.csr -edata [regbld rw11::KW11P_CSR mode] \
  -wma  kwp.csr        [regbld rw11::KW11P_CSR {rate "rext"}] \
  -rma  kwp.csr -edata [regbld rw11::KW11P_CSR {rate "rext"}] \
  -wma  kwp.csr        [regbld rw11::KW11P_CSR err done mode] \
  -rma  kwp.csr -edata [regbld rw11::KW11P_CSR mode]

rlc log "    A2: read/write erate -------------------------------"
# test that erate is rem writable, but not the other fields
$cpu cp \
  -wma  kwp.csr        [regbld rw11::KW11P_CSR ie mode] \
  -rma  kwp.csr -edata [regbld rw11::KW11P_CSR ie mode] \
  -wibr kwp.csr        [regbld rw11::KW11P_RCSR {erate "usec"}] \
  -rma  kwp.csr -edata [regbld rw11::KW11P_CSR ie mode] \
  -ribr kwp.csr -edata [regbld rw11::KW11P_RCSR {erate "usec"} ie mode]

rlc log "    A3: write csb, read ctr ----------------------------"
# write csb, check csb reads 0, ctr returns csb value, and ctr write is noop
$cpu cp \
  -wma  kwp.csr        0x0000 \
  -wma  kwp.csb        0xbeaf \
  -rma  kwp.csb -edata 0x0000 \
  -rma  kwp.ctr -edata 0xbeaf \
  -wma  kwp.ctr        0xdead \
  -rma  kwp.ctr -edata 0xbeaf

rlc log "    A4: test breset ------------------------------------"
# all csr fields a cleared, only erate (hidden and rem only) stays
$cpu cp \
  -wma  kwp.csr        [regbld rw11::KW11P_CSR ie updn mode {rate "r10k"}] \
  -rma  kwp.csr -edata [regbld rw11::KW11P_CSR ie updn mode {rate "r10k"}] \
  -wibr kwp.csr        [regbld rw11::KW11P_RCSR {erate "rext"}] \
  -ribr kwp.csr -edata [regbld rw11::KW11P_RCSR {erate "rext"} \
                         ie updn mode {rate "r10k"}] \
  -breset \
  -rma  kwp.csr -edata [regbld rw11::KW11P_CSR {rate "r100k"}] \
  -ribr kwp.csr -edata [regbld rw11::KW11P_RCSR {erate "rext"} {rate "r100k"}]
# harvest breset/creset triggered attn's
rlc exec -attn
rlc wtlam 0.
# finally set erate to scnt (the default) again
$cpu cp \
  -wibr kwp.csr        [regbld rw11::KW11P_RCSR {erate "sclk"}] \
  -ribr kwp.csr -edata [regbld rw11::KW11P_RCSR {erate "sclk"} {rate "r100k"}]

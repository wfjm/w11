# $Id: test_kw11p_regs.tcl 1045 2018-09-15 15:20:57Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
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
  -wreg kwp.csr [regbld rw11::KW11P_CSR ie] \
  -rreg kwp.csr -edata [regbld rw11::KW11P_CSR ie] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR updn] \
  -rreg kwp.csr -edata [regbld rw11::KW11P_CSR updn] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR mode] \
  -rreg kwp.csr -edata [regbld rw11::KW11P_CSR mode] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR {rate "rext"}] \
  -rreg kwp.csr -edata [regbld rw11::KW11P_CSR {rate "rext"}] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR err done mode] \
  -rreg kwp.csr -edata [regbld rw11::KW11P_CSR mode]

rlc log "    A3: write csb, read ctr ----------------------------"
# write csb, check csb reads 0, ctr returns csb value, and ctr write is noop
$cpu cp \
  -wreg kwp.csr 0x0000 \
  -wreg kwp.csb 0xbeaf \
  -rreg kwp.csb -edata 0x0000 \
  -rreg kwp.ctr -edata 0xbeaf \
  -wreg kwp.ctr 0xdead \
  -rreg kwp.ctr -edata 0xbeaf

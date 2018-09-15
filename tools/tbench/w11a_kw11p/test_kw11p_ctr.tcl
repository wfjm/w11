# $Id: test_kw11p_ctr.tcl 1044 2018-09-15 11:12:07Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2018-09-09  1044   1.0    Initial version
#
# Test ctr response with CSR(fix)

# ----------------------------------------------------------------------------
rlc log "test_kw11p_regs: test ctr response with CSR(fix) --------------------"

if {[$cpu get haskw11p] == 0} {
  rlc log "  test_kw11p_regs-W: no kw11p unit found, test aborted"
  return
}

# -- Section A ---------------------------------------------------------------
rlc log "  A test basic counting -------------------------------------"

rlc log "    A1: count down -------------------------------------"
# test with updn=0, avoid counter overflows
$cpu cp \
  -wreg kwp.csb 0103 \
  -rreg kwp.ctr -edata 0103 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rreg kwp.ctr -edata 0102 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rreg kwp.ctr -edata 0101 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rreg kwp.ctr -edata 0100 

rlc log "    A1: count up ---------------------------------------"
# test with updn=1, avoid counter overflows
$cpu cp \
  -wreg kwp.csb 0100 \
  -rreg kwp.ctr -edata 0100 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rreg kwp.ctr -edata 0101 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rreg kwp.ctr -edata 0102 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rreg kwp.ctr -edata 0103

# -- Section B ---------------------------------------------------------------
rlc log "  B done response -------------------------------------------"

rlc log "    B1: single count down to zero ----------------------"
# test with updn=0, count down to zero; check that read csr clears done

$cpu cp \
  -wreg kwp.csb 3 \
  -rreg kwp.ctr -edata 3 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rreg kwp.ctr -edata  2 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rreg kwp.ctr -edata  1 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rreg kwp.ctr -edata  0 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR done] \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR]

rlc log "    B2: single count up to zero ------------------------"
# test with updn=1, count up to zero; check that read csr clears done

$cpu cp \
  -wreg kwp.csb 0177775 \
  -rreg kwp.ctr -edata 0177775 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rreg kwp.ctr -edata 0177776 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR updn] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rreg kwp.ctr -edata 0177777 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR updn] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rreg kwp.ctr -edata  0 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR done updn] \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR updn]

rlc log "    B3: repeat count down to zero ----------------------"
# test with updn=0 mode=1, repeat count down to zero

$cpu cp \
  -wreg kwp.csb 2 \
  -rreg kwp.ctr -edata 2 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rreg kwp.ctr -edata  1 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR mode] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rreg kwp.ctr -edata  2 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR done mode] \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR mode] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rreg kwp.ctr -edata  1 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR mode] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rreg kwp.ctr -edata  2 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR done mode] \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR mode]

rlc log "    B4: repeat count up to zero ------------------------"
# test with updn=1 mode=1, repeat count up to zero

$cpu cp \
  -wreg kwp.csb 0177776 \
  -rreg kwp.ctr -edata 0177776 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix updn mode] \
  -rreg kwp.ctr -edata 0177777 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR updn mode] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix updn mode] \
  -rreg kwp.ctr -edata  0177776 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR done updn mode] \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR updn mode] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix updn mode] \
  -rreg kwp.ctr -edata  0177777 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR updn mode] \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix updn mode] \
  -rreg kwp.ctr -edata  0177776 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR done updn mode] \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR updn mode]

# -- Section C ---------------------------------------------------------------
rlc log "  C err response --------------------------------------------"

rlc log "    C1: repeat count down to zero ----------------"
# test with updn=0 mode=1, repeat count down to zero without csr read

$cpu cp \
  -wreg kwp.csb 2 \
  -rreg kwp.ctr -edata 2 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rreg kwp.ctr -edata  1 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rreg kwp.ctr -edata  2 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rreg kwp.ctr -edata  1 \
  -wreg kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rreg kwp.ctr -edata  2 \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR err done mode] \
  -rreg kwp.csr -edata  [regbld rw11::KW11P_CSR mode]

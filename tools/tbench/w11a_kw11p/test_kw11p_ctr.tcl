# $Id: test_kw11p_ctr.tcl 1138 2019-04-26 08:14:56Z mueller $
#
# Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2019-04-24  1138   1.1    use loc access
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
  -wma  kwp.csb 0103 \
  -rma  kwp.ctr -edata 0103 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rma  kwp.ctr -edata 0102 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rma  kwp.ctr -edata 0101 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rma  kwp.ctr -edata 0100 

rlc log "    A1: count up ---------------------------------------"
# test with updn=1, avoid counter overflows
$cpu cp \
  -wma  kwp.csb 0100 \
  -rma  kwp.ctr -edata 0100 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rma  kwp.ctr -edata 0101 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rma  kwp.ctr -edata 0102 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rma  kwp.ctr -edata 0103

# -- Section B ---------------------------------------------------------------
rlc log "  B done response -------------------------------------------"

rlc log "    B1: single count down to zero ----------------------"
# test with updn=0, count down to zero; check that read csr clears done

$cpu cp \
  -wma  kwp.csb 3 \
  -rma  kwp.ctr -edata 3 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rma  kwp.ctr -edata  2 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR] \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rma  kwp.ctr -edata  1 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR] \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix] \
  -rma  kwp.ctr -edata  0 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR done] \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR]

rlc log "    B2: single count up to zero ------------------------"
# test with updn=1, count up to zero; check that read csr clears done

$cpu cp \
  -wma  kwp.csb 0177775 \
  -rma  kwp.ctr -edata 0177775 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rma  kwp.ctr -edata 0177776 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR updn] \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rma  kwp.ctr -edata 0177777 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR updn] \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix updn] \
  -rma  kwp.ctr -edata  0 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR done updn] \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR updn]

rlc log "    B3: repeat count down to zero ----------------------"
# test with updn=0 mode=1, repeat count down to zero

$cpu cp \
  -wma  kwp.csb 2 \
  -rma  kwp.ctr -edata 2 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rma  kwp.ctr -edata  1 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR mode] \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rma  kwp.ctr -edata  2 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR done mode] \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR mode] \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rma  kwp.ctr -edata  1 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR mode] \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rma  kwp.ctr -edata  2 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR done mode] \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR mode]

rlc log "    B4: repeat count up to zero ------------------------"
# test with updn=1 mode=1, repeat count up to zero

$cpu cp \
  -wma  kwp.csb 0177776 \
  -rma  kwp.ctr -edata 0177776 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix updn mode] \
  -rma  kwp.ctr -edata 0177777 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR updn mode] \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix updn mode] \
  -rma  kwp.ctr -edata  0177776 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR done updn mode] \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR updn mode] \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix updn mode] \
  -rma  kwp.ctr -edata  0177777 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR updn mode] \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix updn mode] \
  -rma  kwp.ctr -edata  0177776 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR done updn mode] \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR updn mode]

# -- Section C ---------------------------------------------------------------
rlc log "  C err response --------------------------------------------"

rlc log "    C1: repeat count down to zero ----------------"
# test with updn=0 mode=1, repeat count down to zero without csr read

$cpu cp \
  -wma  kwp.csb 2 \
  -rma  kwp.ctr -edata 2 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rma  kwp.ctr -edata  1 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rma  kwp.ctr -edata  2 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rma  kwp.ctr -edata  1 \
  -wma  kwp.csr [regbld rw11::KW11P_CSR fix mode] \
  -rma  kwp.ctr -edata  2 \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR err done mode] \
  -rma  kwp.csr -edata  [regbld rw11::KW11P_CSR mode]

# $Id: test_dz11_regs.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-05-11  1148   1.0    Initial version
# 2019-05-04  1146   0.1    First draft
#
# Test DZ11 register response

# ----------------------------------------------------------------------------
rlc log "test_dz11_regs: test dz11 register response -------------------------"
package require ibd_dz11
if {![ibd_dz11::setup]} {
  rlc log "  test_dz11_regs-W: device not found, test aborted"
  return
}

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

set attndl  [expr {1<<$ibd_dz11::ANUM}]
set attncpu [expr {1<<$rw11::ANUM}]

# remember 'awdth' retrieved from cntl for later tests
$cpu cp -ribr dza.csr dzcntl
set awdth  [regget ibd_dz11::RCNTLR(awdth) $dzcntl]

# -- Section A ---------------------------------------------------------------
rlc log "  A1: test rem cntl,stat response ---------------------------"
rlc log "    A1.1: rem cntl ssel --------------------------------"

set cntlmask [regbld ibd_dz11::RCNTLR {ssel -1}]

# rem write and readback cntl.ssel
$cpu cp \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel 1}] \
  -ribr dza.csr  -edata [regbld ibd_dz11::RCNTLR {ssel 1}] $cntlmask \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel 3}] \
  -ribr dza.csr  -edata [regbld ibd_dz11::RCNTLR {ssel 3}] $cntlmask \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel 0}] \
  -ribr dza.csr  -edata [regbld ibd_dz11::RCNTLR {ssel 0}] $cntlmask
  
rlc log "    A1.2: rem cntl stat --------------------------------"

# check that stat is rem readable but not writable
$cpu cp \
  -ribr dza.rbuf \
  -wibr dza.rbuf 0x0 -estaterr

rlc log "    A1.3: rem cntl(func=rlim) -> stat ------------------"

set rlcnmask [regbld ibd_dz11::RSRLCN {rrlim -1} {trlim -1}]

$cpu cp \
  -wibr dza.csr         [regbld ibd_dz11::RRLIMW {rrlim 1} {trlim 2} \
                          {ssel "RLCN"} {func "SRLIM"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSRLCN {rrlim 1} {trlim 2}] \
  -wibr dza.csr         [regbld ibd_dz11::RRLIMW {rrlim 6} {trlim 5} \
                          {ssel "RLCN"} {func "SRLIM"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSRLCN {rrlim 6} {trlim 5}] \
  -wibr dza.csr         [regbld ibd_dz11::RRLIMW {rrlim 0} {trlim 0} \
                          {ssel "RLCN"} {func "SRLIM"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSRLCN {rrlim 0} {trlim 0}]

rlc log "  A2: test csr response -------------------------------------"
rlc log "    A2.1: csr tie,sae,rie,mse,maint --------------------"

$cpu cp \
  -breset \
  -rma  dza.csr  -edata [regbld ibd_dz11::CSR ] \
  -wma  dza.csr         [regbld ibd_dz11::CSR tie] \
  -rma  dza.csr  -edata [regbld ibd_dz11::CSR tie] \
  -wma  dza.csr         [regbld ibd_dz11::CSR sae] \
  -rma  dza.csr  -edata [regbld ibd_dz11::CSR sae] \
  -wma  dza.csr         [regbld ibd_dz11::CSR rie] \
  -rma  dza.csr  -edata [regbld ibd_dz11::CSR rie] \
  -wma  dza.csr         [regbld ibd_dz11::CSR mse] \
  -rma  dza.csr  -edata [regbld ibd_dz11::CSR mse] \
  -wma  dza.csr         [regbld ibd_dz11::CSR maint] \
  -rma  dza.csr  -edata [regbld ibd_dz11::CSR maint]

rlc log "    A2.2: csr mse,maint -> cntl ------------------------"

set cntlmask [regbld ibd_dz11::RCNTLR mse maint]

$cpu cp \
  -wma  dza.csr         [regbld ibd_dz11::CSR mse] \
  -ribr dza.csr  -edata [regbld ibd_dz11::RCNTLR mse] $cntlmask \
  -wma  dza.csr         [regbld ibd_dz11::CSR mse maint] \
  -ribr dza.csr  -edata [regbld ibd_dz11::RCNTLR mse maint] $cntlmask \
  -wma  dza.csr         [regbld ibd_dz11::CSR] \
  -ribr dza.csr  -edata [regbld ibd_dz11::RCNTLR] $cntlmask

rlc log "  A3: test tcr -> stat response ------------------------"

$cpu cp \
  -wma  dza.tcr         [regbld ibd_dz11::TCR {dtr 0xaa} {lena 0x55}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel "DTLE"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSDTLE {dtr 0xaa} {lena 0x55}] \
  -wma  dza.tcr         [regbld ibd_dz11::TCR {dtr 0x12} {lena 0x34}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel "DTLE"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSDTLE {dtr 0x12} {lena 0x34}] \
  -wma  dza.tcr         [regbld ibd_dz11::TCR {dtr 0x0} {lena 0x0}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel "DTLE"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSDTLE {dtr 0x0} {lena 0x0}]

rlc log "  A4: test cntl -> msr and stat response ---------------"

# rem wr SCO    0x45 
# rem wr SRING  0x67
#     rd        (0x45 0x67)
# rem wr SCO    0xde
#     rd        (0xde 0x67)
# rem wr SRING  0xad
#     rd        (0xde 0xad)
# rem wr SCO    0x00
# rem wr SRING  0x00
#     rd        (0x00 0x00)
$cpu cp \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {data 0x45} \
                          {ssel "CORI"} {func "SCO"}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {data 0x67}  \
                          {ssel "CORI"} {func "SRING"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSCORI {co 0x45} {ring 0x67}] \
  -rma  dza.tdr  -edata [regbld ibd_dz11::MSR    {co 0x45} {ring 0x67}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {data 0xde} \
                          {ssel "CORI"} {func "SCO"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSCORI {co 0xde} {ring 0x67}] \
  -rma  dza.tdr  -edata [regbld ibd_dz11::MSR    {co 0xde} {ring 0x67}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {data 0xad} \
                          {ssel "CORI"} {func "SRING"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSCORI {co 0xde} {ring 0xad}] \
  -rma  dza.tdr  -edata [regbld ibd_dz11::MSR    {co 0xde} {ring 0xad}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {data 0x00} \
                          {ssel "CORI"} {func "SCO"}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {data 0x00}  \
                          {ssel "CORI"} {func "SRING"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSCORI {co 0x00} {ring 0x00}] \
  -rma  dza.tdr  -edata [regbld ibd_dz11::MSR    {co 0x00} {ring 0x00}]

rlc log "  A5: test lpr(rxon) -> stat response ------------------"

# loc wr LPR  line 1  txon=1
# rem rd      rxon= 0000 0010 = 0x02
# loc wr LPR  line 2  txon=1
# rem rd      rxon= 0000 0110 = 0x06
# loc wr LPR  line 6  txon=1
# rem rd      rxon= 0100 0110 = 0x46
# loc wr LPR  line 1  txon=0
# rem rd      rxon= 1000 0000 = 0x44
# loc wr LPR  line 2  txon=0
# loc wr LPR  line 6  txon=0
# rem rd      rxon= 0000 0000 = 0x00
$cpu cp \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel "BRRX"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSBRRX {brk 0x0} {rxon 0x00}] \
  -wma  dza.rbuf        [regbld ibd_dz11::LPR {rxon 1} {line 1}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel "BRRX"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSBRRX {brk 0x0} {rxon 0x02}] \
  -wma  dza.rbuf        [regbld ibd_dz11::LPR {rxon 1} {line 2}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel "BRRX"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSBRRX {brk 0x0} {rxon 0x06}] \
  -wma  dza.rbuf        [regbld ibd_dz11::LPR {rxon 1} {line 6}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel "BRRX"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSBRRX {brk 0x0} {rxon 0x46}] \
  -wma  dza.rbuf        [regbld ibd_dz11::LPR {rxon 0} {line 1}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel "BRRX"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSBRRX {brk 0x0} {rxon 0x44}] \
  -wma  dza.rbuf        [regbld ibd_dz11::LPR {rxon 0} {line 2}] \
  -wma  dza.rbuf        [regbld ibd_dz11::LPR {rxon 0} {line 6}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {ssel "BRRX"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSBRRX {brk 0x0} {rxon 0x00}]

rlc log "  A5: test stat auto-inc read --------------------------"

# loc wr TCR  (dtr=0xbe lena=0xaf)
# loc wr LPR  line 3  txon=1
# rem wr SCO    0x18
# rem wr SRING  0x26
# rem wr SRLIM (rrlim=3 trlim=4) SSEL=DTLE
# rem rd STAT DTLE
# rem rd STAT BRRX
# rem rd STAT CORI
# rem rd STAT RLCN
$cpu cp \
  -wma  dza.tcr         [regbld ibd_dz11::TCR {dtr 0xbe} {lena 0xaf}] \
  -wma  dza.rbuf        [regbld ibd_dz11::LPR {rxon 1} {line 3}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {data 0x18} {func "SCO"}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {data 0x26} {func "SRING"}] \
  -wibr dza.csr         [regbld ibd_dz11::RRLIMW {rrlim 1} {trlim 2} \
                           {ssel "DTLE"} {func "SRLIM"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSDTLE {dtr  0xbe} {lena 0xaf}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSBRRX {brk  0x00} {rxon 0x08}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSCORI {co   0x18} {ring 0x26}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSRLCN {rrlim   1} {trlim   2}]
# and clear everything
$cpu cp \
  -wma  dza.tcr         [regbld ibd_dz11::TCR {dtr 0x00} {lena 0x00}] \
  -wma  dza.rbuf        [regbld ibd_dz11::LPR {rxon 0} {line 3}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {data 0x00} {func "SCO"}] \
  -wibr dza.csr         [regbld ibd_dz11::RCNTLW {data 0x00} {func "SRING"}] \
  -wibr dza.csr         [regbld ibd_dz11::RRLIMW {rrlim 0} {trlim 0} \
                           {ssel "DTLE"} {func "SRLIM"}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSDTLE {dtr  0x00} {lena 0x00}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSBRRX {brk  0x00} {rxon 0x00}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSCORI {co   0x00} {ring 0x00}] \
  -ribr dza.rbuf -edata [regbld ibd_dz11::RSRLCN {rrlim   0} {trlim   0}]

# harvest any dangling attn
rlc exec -attn 
rlc wtlam 0.

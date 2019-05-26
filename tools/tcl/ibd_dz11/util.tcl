# $Id: util.tcl 1150 2019-05-19 17:52:54Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2019-05-18  1150   1.0    Initial version
# 2019-05-04  1146   0.1    First draft
#

package provide ibd_dz11 1.0

package require rlink
package require rw11util
package require rw11

namespace eval ibd_dz11 {
  #
  # setup register descriptions for ibd_dz11 ---------------------------------
  #

  regdsc CSR    {trdy 15} {tie 14} {sa 13} {sae 12} {tline 10 3} \
                  {rdone 7} {rie 6} {mse 5} {clr 4} {maint 3}
  regdsc RBUF   {val 15} {ferr 13} {line 10 3} {data 7 8}
  regdsc LPR    {rxon 12} {line 2 3}
  regdsc TCR    {dtr 15 8} {lena 7 8}
  regdsc MSR    {co 15 8} {ring 7 8}
  regdsc TDR    {brk 15 8} {tbuf 7 8}

  regdsc RCNTLR {awdth 10 3} {sam 7} {ssel 4 2 "s:DTLE:BRRX:CORI:RLCN"} \
                  {mse 2} {maint 1}
  regdsc RCNTLW {data 15 8} {sam 7} {rcl 6} {tcl 5} \
                  {ssel 4 2 "s:DTLE:BRRX:CORI:RLCN"} \
                  {func 2 3 "s:NOOP:SCO:SRING:SRLIM:F4:F5:F6:F7"}
  regdsc RRLIMW {rrlim 14 3} {trlim 10 3} {rcl 6} {tcl 5} \
                  {ssel 4 2 "s:DTLE:BRRX:CORI:RLCN"} \
                  {func 2 3 "s:NOOP:SCO:SRING:SRLIM:F4:F5:F6:F7"}; # func=SRLIM
  regdsc RSTAT  {dath 15 8} {datl 7 8}
  regdsc RSDTLE {dtr 15 8} {lena 7 8}
  regdsc RSBRRX {brk 15 8} {rxon 7 8}
  regdsc RSCORI {co  15 8} {ring 7 8}
  regdsc RSRLCN {rrlim 14 3} {trlim 10 3} {rir 7} {tir 6} {mse 5} {maint 3}
  regdsc RFUSE  {rfuse 14 7 "d"} {tfuse 6 7 "d"}
  regdsc RFDAT  {val 15} {last 14} {ferr 13} {cal 11} {line 10 3} {data 7 8}
  
  variable CAL_DTR   [bvi b3 "000"]
  variable CAL_BRK   [bvi b3 "001"]
  variable CAL_RXON  [bvi b3 "010"]
  variable CAL_CSR   [bvi b3 "011"]

  rw11util::regmap_add ibd_dz11 dz?.csr  {l? CSR rr RCNTLR rw RCNTLW}
  rw11util::regmap_add ibd_dz11 dz?.rbuf {lr RBUF lw LPR rr RSTAT}
  rw11util::regmap_add ibd_dz11 dz?.tcr  {l? TCR r? RFUSE}
  rw11util::regmap_add ibd_dz11 dz?.tdr  {lr MSR lw TDR r? RFDAT}
  
  variable ANUM  3;             # DZ11

  #
  # setup: create controller with default attributes -------------------------
  #
  proc setup {{cpu "cpu0"}} {
    return [rw11::setup_cntl $cpu "dz11" "dza"]
  }
  #
  # rdump: register dump - rem view ------------------------------------------
  #
  proc rdump {{cpu "cpu0"}} {
    set rval {}
    $cpu cp -rma  "dza.csr"  csr  \
            -ribr "dza.csr"  cntl \
            -ribr "dza.tcr"  fuse \
            -wibr "dza.csr"  [regbld ibd_dz11::RCNTLW {ssel "DTLE"}] \
            -ribr "dza.rbuf" dtle \
            -ribr "dza.rbuf" brrx \
            -ribr "dza.rbuf" cori \
            -ribr "dza.rbuf" rlcn
    append rval "Controller registers:"
    append rval [format "\n  csr:  %6.6o  %s" $csr  \
                                              [regtxt ibd_dz11::CSR    $csr ]]
    append rval [format "\n  cntl: %6.6o  %s" $cntl \
                                              [regtxt ibd_dz11::RCNTLR $cntl]]
    append rval [format "\n  fuse: %6.6o  %s" $fuse \
                                              [regtxt ibd_dz11::RFUSE  $fuse]]
    append rval [format "\n  dtle: %6.6o  %s" $dtle \
                                              [regtxt ibd_dz11::RSDTLE $dtle]]
    append rval [format "\n  brrx: %6.6o  %s" $brrx \
                                              [regtxt ibd_dz11::RSBRRX $brrx]]
    append rval [format "\n  cori: %6.6o  %s" $cori \
                                              [regtxt ibd_dz11::RSCORI $cori]]
    append rval [format "\n  rlcn: %6.6o  %s" $rlcn \
                                              [regtxt ibd_dz11::RSRLCN $rlcn]]
    
  }
}

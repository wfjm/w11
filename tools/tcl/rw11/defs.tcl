# $Id: defs.tcl 985 2018-01-03 08:59:40Z mueller $
#
# Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2017-02-17   851   1.0.5  defs for auxilliary devices (kw11l,kw11p,iist)
# 2016-12-30   834   1.0.4  fix typo in regmap_add for SDR's
# 2016-01-02   724   1.0.3  add s: defs for CP_STAT(rust)
# 2015-12-26   719   1.0.2  add regmap_add defs; add CNTRL def
# 2015-09-06   710   1.0.1  regdsc PSW: add silent n,z,v,c; *mode syms; fix tflag
# 2014-03-07   553   1.0    Initial version (extracted from util.tcl)
#

package provide rw11 1.0

package require rlink
package require rwxxtpp
package require rw11util

namespace eval rw11 {
  #
  # setup cp interface register descriptions for w11a -----------------------
  #
  regdsc CP_CNTL {func 3 0}

  regdsc CP_STAT {suspext 9} {suspint 8} \
                 {rust 7 4 "s:init:halt:reset:stop:step:susp:hbpt:runs:vecfet:recrsv:s1010:s1011:sfail:vfail:s1110:s1111"} \
                 {susp 3} {go 2} {merr 1} {err 0}
  variable RUST_INIT   [bvi b4 "0000"]
  variable RUST_HALT   [bvi b4 "0001"]
  variable RUST_RESET  [bvi b4 "0010"]
  variable RUST_STOP   [bvi b4 "0011"]
  variable RUST_STEP   [bvi b4 "0100"]
  variable RUST_SUSP   [bvi b4 "0101"]
  variable RUST_HBPT   [bvi b4 "0110"]
  variable RUST_RUNS   [bvi b4 "0111"]
  variable RUST_VECFET [bvi b4 "1000"]
  variable RUST_RECRSV [bvi b4 "1001"]
  variable RUST_SFAIL  [bvi b4 "1100"]
  variable RUST_VFAIL  [bvi b4 "1101"]

  regdsc CP_AH   {ubm 7} {p22 6} {addr 5 6}
  #
  # setup w11a register descriptions -----------------------------------------
  #
  # PSW - processor status word --------------------------------------
  set A_PSW 0177776
  regdsc PSW {cmode 15 2 "s:k:s:x:u"} {pmode 13 2 "s:k:s:x:u"} \
             {rset 11} {pri 7 3 "d"} {tflag 4} {cc 3 4} \
             {n 3 1 "-"} {z 2 1 "-"} {v 1 1 "-"} {c 0 1 "-"}
  #
  # SSR0 - MMU Segment Status Register #0 ----------------------------
  set A_SSR0     0177572
  regdsc SSR0 {abo_nonres 15} {abo_len 14}  {abo_rd 13} \
              {trap_mmu 12} {ena_trap 9} {inst_compl 7} \
              {mode 6 2} {dspace 4} {num 3 3} {ena 0}
  #
  # SSR1 - MMU Segment Status Register #1 ----------------------------
  set A_SSR1     0177574
  regdsc SSR1 {delta1 15 5} {rnum1 10 3} {delta0 7 5} {rnum0 2 3} 
  #
  # SSR2 - MMU Segment Status Register #2 ----------------------------
  set A_SSR2     0177576
  #
  # SSR3 - MMU Segment Status Register #3 ----------------------------
  set A_SSR3     0172516
  regdsc SSR3 {ena_ubm 5} {ena_22bit 4} {d_km 2} {d_sm 1} {d_um 0}
  #
  # SAR/SDR - MMU Address/Segment Descriptor Register ----------------
  set A_SDR_KM   0172300
  set A_SAR_KM   0172340
  set A_SDR_SM   0172200
  set A_SAR_SM   0172240
  set A_SDR_UM   0177600
  set A_SAR_UM   0177640
  regdsc SDR {slf 14 7} {aia  7} {aiw 6} {ed 3} {acf 2 3}
  #
  # PIRQ - Program Interrupt Requests -------------------------------
  set A_PIRQ     0177772
  regdsc PIRQ {pir 15 7} {piah 7 3} {pial 3 3}
  #
  # CPUERR - CPU Error Register -------------------------------------
  set A_CPUERR   0177766
  regdsc CPUERR {illhlt 7} {adderr 6} {nxm 5} {iobto 4} {ysv 3} {rsv 2}
  #
  # CNTRL - Memory System Control Register -------------------------
  set A_CNTRL    0177746
  regdsc CNTRL  {frep 5 2} {fmiss 3 2} {disutrap 1} {distrap 0}
  #
  # setup regmap
  #
  rw11util::regmap_add rw11 psw       {?? PSW}
  rw11util::regmap_add rw11 ssr0      {?? SSR0}
  rw11util::regmap_add rw11 ssr1      {?? SSR1}
  rw11util::regmap_add rw11 ssr3      {?? SSR3}
  rw11util::regmap_add rw11 sdr??.?   {?? SDR}
  rw11util::regmap_add rw11 pirq      {?? PIRQ}
  rw11util::regmap_add rw11 cpuerr    {?? CPUERR}
  #
  rw11util::regmap_add rw11 cntrl     {?? CNTRL}
  #
  # other w11a definitions ---------------------------------------------------
  #
  # KW11-L line clock
  set A_KW11L_CSR  0177546
  regdsc KW11L_CSR  {moni 7} {ie 6}
  rw11util::regmap_add rw11 kwl.csr    {?? KW11L_CSR}
  #
  # KW11-P line clock
  set A_KW11P_CSR  0172540
  set A_KW11P_CSB  0172542
  set A_KW11P_CTR  0172544
  regdsc KW11P_CSR  {err 15} {done 7} {ie 6} {fix 5} {updn 4} \
                    {mode 3} {rate 2 2} {run 0}
  rw11util::regmap_add rw11 kwp.csr    {?? KW11P_CSR}
  #
  # IIST - interprocessor communication
  set A_IIST_ACR   0177500
  set A_IIST_ADR   0177502
  regdsc IIST_ACR  {clr 15} {sid 9 2} {ac 3 4}
  rw11util::regmap_add rw11 iist.acr   {?? IIST_ACR}
  #
  # Interrupt vectors -----------------------------------------------
  #
  set V_004      0000004
  set V_010      0000010
  set V_BPT      0000014
  set V_IOT      0000020
  set V_PWR      0000024
  set V_EMT      0000030
  set V_TRAP     0000034
  set V_PIRQ     0000240
  set V_FPU      0000244
  set V_MMU      0000250

}

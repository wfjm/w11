# $Id: defs.tcl 1320 2022-11-22 18:52:59Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2014-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2022-11-21  1320   1.0.11 rename RUST recrsv -> recser
# 2022-09-03  1292   1.0.10 shorter field names for MMR0,MMR1
# 2022-08-07  1273   1.0.9  ssr->mmr rename
# 2019-04-24  1138   1.0.8  add RCSR defs for KW11-L and KW11-P
# 2019-03-10  1121   1.0.7  define INIT bits; define ANUM
# 2018-09-09  1044   1.0.6  update defs kw11p, literals for KW11P_CSR(rate)
# 2017-02-17   851   1.0.5  defs for auxilliary devices (kw11l,kw11p,iist)
# 2016-12-30   834   1.0.4  fix typo in regmap_add for PDR's
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
  regdsc INIT {greset 0};       # for rbus init send against base addr
  
  regdsc CP_CNTL {func 3 0}

  regdsc CP_STAT {suspext 9} {suspint 8} \
                 {rust 7 4 "s:init:halt:reset:stop:step:susp:hbpt:runs:vecfet:recser:s1010:s1011:sfail:vfail:s1110:s1111"} \
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
  variable RUST_RECSER [bvi b4 "1001"]
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
  # MMR0 - MMU Page Status Register #0 -------------------------------
  set A_MMR0     0177572
  regdsc MMR0 {anr 15} {ale 14} {ard 13} {trp 12} {ent 9} {ico 7} \
              {mode 6 2 "s:k:s:x:u"} {ds 4 1 "s:I:D"} {page 3 3 "d"} {ena 0}
  #
  # MMR1 - MMU Page Status Register #1 -------------------------------
  set A_MMR1     0177574
  regdsc MMR1 {du 15 5} {ru 10 3 "d"} {dl 7 5} {rl 2 3 "d"}
  #
  # MMR2 - MMU Page Status Register #2 -------------------------------
  set A_MMR2     0177576
  #
  # MMR3 - MMU Page Status Register #3 -------------------------------
  set A_MMR3     0172516
  regdsc MMR3 {ena_ubm 5} {ena_22bit 4} {d_km 2} {d_sm 1} {d_um 0}
  #
  # PAR/PDR - MMU Page Descriptor/Address  Register -----------------
  set A_PDR_KM   0172300
  set A_PAR_KM   0172340
  set A_PDR_SM   0172200
  set A_PAR_SM   0172240
  set A_PDR_UM   0177600
  set A_PAR_UM   0177640
  regdsc PDR {plf 14 7} {aia  7} {aiw 6} {ed 3} {acf 2 3}
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
  rw11util::regmap_add rw11 mmr0      {?? MMR0}
  rw11util::regmap_add rw11 mmr1      {?? MMR1}
  rw11util::regmap_add rw11 mmr3      {?? MMR3}
  rw11util::regmap_add rw11 pdr??.?   {?? PDR}
  rw11util::regmap_add rw11 pirq      {?? PIRQ}
  rw11util::regmap_add rw11 cpuerr    {?? CPUERR}
  #
  rw11util::regmap_add rw11 cntrl     {?? CNTRL}
  #
  # define attn channel for W11 CPU cluster
  variable ANUM 0
  #
  # other w11a definitions ---------------------------------------------------
  #
  # KW11-L line clock
  set A_KW11L_CSR  0177546
  regdsc KW11L_CSR  {moni 7} {ie 6}
  regdsc KW11L_RCSR {moni 7} {ie 6} {ir 5}
  rw11util::regmap_add rw11 kwl.csr    {l? KW11L_CSR r? KW11L_RCSR}
  #
  # KW11-P line clock
  set A_KW11P_CSR  0172540
  set A_KW11P_CSB  0172542
  set A_KW11P_CTR  0172544
  regdsc KW11P_CSR  {err 15} {done 7} {ie 6} {fix 5} {updn 4} {mode 3} \
                    {rate 2 2 "s:r100k:r10k:rline:rext"} {run 0}
  regdsc KW11P_RCSR {err 15} {ir 10} {erate 9 2 "s:sclk:usec:rext:noop"} \
                    {done 7} {ie 6} {fix 5} {updn 4} {mode 3} \
                    {rate 2 2 "s:r100k:r10k:rline:rext"} {run 0}
  rw11util::regmap_add rw11 kwp.csr    {l? KW11P_CSR r? KW11P_RCSR}
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

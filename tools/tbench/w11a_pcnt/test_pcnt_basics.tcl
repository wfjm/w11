# $Id: test_pcnt_basics.tcl 1330 2022-12-16 17:52:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2018-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2022-12-12  1330   1.0.1  rename vfetch -> vstart
# 2018-10-06  1053   1.0    Initial version
# 2018-09-23  1050   0.1    First draft
#
# Test basic perf counter functionality 

# ----------------------------------------------------------------------------
rlc log "test_pcnt_basics: test basic functionality --------------------------"

if {[$cpu get haspcnt] == 0} {
  rlc log "  test_pcnt_regs-W: no pcnt unit found, test aborted"
  return
}

# -- Section A ---------------------------------------------------------------
rlc log "  A: simple loop code ---------------------------------------"

$cpu ldasm -lst lst -sym sym {
        . = 1000
stack:  
start:  clr     r1
        mov     #32.,r0
1$:     inc     r1
        sob     r0,1$
        halt
stop:   
}

rlc log "    A1: run code, with pcnt running --------------------"
# clear and start pcnt
$cpu cp \
  -wreg pc.cntl [regbld rw11::PC_CNTL {func "CLR"}] \
  -wreg pc.cntl [regbld rw11::PC_CNTL {func "STA"}] \
  -rreg pc.stat -edata [regbld rw11::PC_STAT run] 
# run code
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu r0 0 r1 32
# stop pcnt
$cpu cp \
  -wreg pc.cntl [regbld rw11::PC_CNTL {func "STO"}] \
  -rreg pc.stat -edata [regbld rw11::PC_STAT] 
# now some counters have well defined states
#     1      =0    cpu_km_prix
#     2      >0    cpu_km_pri0
#     3      =0    cpu_km_wait
#     4      =0    cpu_sm
#     5      =0    cpu_um
#     6      67    cpu_inst
#     7      31    cpu_pcload
#     8      =0    cpu_vstart
#     9      =0    cpu_irupt
rlc log "    A2: test random access (ainc=0) --------------------"
# read pc(6) twice, (9) once, (7) one, check status
$cpu cp \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr 6 ainc 0] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  6 ainc 0] \
  -rreg pc.data -edata 67 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  6 waddr 1 ainc 0] \
  -rreg pc.data -edata  0 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  6 waddr 0 ainc 0] \
  -rreg pc.data -edata 67 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  6 waddr 1 ainc 0] \
  -rreg pc.data -edata  0 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  6 waddr 0 ainc 0] \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr 9 ainc 0] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  9 ainc 0] \
  -rreg pc.data -edata  0 \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr 7 ainc 0] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  7 ainc 0] \
  -rreg pc.data -edata 31 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  7 waddr 1 ainc 0] \
  -rreg pc.data -edata  0 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  7 waddr 0 ainc 0] 
  
rlc log "    A3: test sequential access (ainc=1) ----------------"
# read pc(6) to pc(9) check status
$cpu cp \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr  6 ainc 1] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  6 ainc 1] \
  -rreg pc.data -edata 67 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  6 waddr 1 ainc 1] \
  -rreg pc.data -edata  0 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  7 waddr 0 ainc 1] \
  -rreg pc.data -edata 31 \
  -rreg pc.data -edata  0 \
  -rreg pc.data -edata  0 \
  -rreg pc.data -edata  0 \
  -rreg pc.data -edata  0 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  9 waddr 1 ainc 1] \
  -rreg pc.data -edata  0 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr 10 waddr 0 ainc 1]

rlc log "    A3: test block access (ainc=1) ---------------------"
# read pc(3) to pc(9) check status
$cpu cp \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr  3 ainc 1] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  3 ainc 1] \
  -rblk pc.data 14 -edata {0 0  0 0  0 0  67 0  31 0  0 0  0 0} \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr 10 waddr 0 ainc 1]

#rlc log "    A4: test clear -------------------------------------"
$cpu cp \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "CLR"] \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr  3 ainc 1] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr 3 ainc 1] \
  -rblk pc.data 14 -edata {0 0  0 0  0 0  0 0  0 0  0 0  0 0} \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr 10 waddr 0 ainc 1]

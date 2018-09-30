# $Id: test_pcnt_basics.tcl 1050 2018-09-23 15:46:42Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2018-09-23  1450   1.0    Initial version
#
# Test basic perf counter functionality 

# ----------------------------------------------------------------------------
rlc log "test_pcnt_regs: test register response ------------------------------"

if {[$cpu get haspcnt] == 0} {
  rlc log "  test_pcnt_regs-W: no pcnt unit found, test aborted"
  return
}

# -- Section A ---------------------------------------------------------------
rlc log "  A: simple loop code ---------------------------------------"

cpu0 ldasm -lst lst -sym sym {
        . = 1000
stack:  
start:  clr     r0
        mov     #32.,r1
1$:     inc     r0
        sob     r1,1$
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
rw11::asmtreg $cpu r0 32 r1 0
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
#     7      =0    cpu_vfetch
#     8      =0    cpu_irupt
#     9      33    cpu_pcload
rlc log "    A2: test random access (ainc=0) --------------------"
# read pc(6) twice, (9) once, check status
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
  -rreg pc.data -edata 33 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  9 waddr 1 ainc 0] \
  -rreg pc.data -edata  0 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  9 waddr 0 ainc 0] 
  
rlc log "    A3: test sequential access (ainc=1) ----------------"
# read pc(6) to pc(9) check status
$cpu cp \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr  6 ainc 1] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  6 ainc 1] \
  -rreg pc.data -edata 67 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  6 waddr 1 ainc 1] \
  -rreg pc.data -edata  0 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  7 waddr 0 ainc 1] \
  -rreg pc.data -edata  0 \
  -rreg pc.data -edata  0 \
  -rreg pc.data -edata  0 \
  -rreg pc.data -edata  0 \
  -rreg pc.data -edata 33 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  9 waddr 1 ainc 1] \
  -rreg pc.data -edata  0 \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr 10 waddr 0 ainc 1]

rlc log "    A3: test block access (ainc=1) ---------------------"
# read pc(3) to pc(9) check status
$cpu cp \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr  3 ainc 1] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr  3 ainc 1] \
  -rblk pc.data 14 -edata {0 0 0 0 0 0 67 0 0 0 0 0 33 0} \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr 10 waddr 0 ainc 1]

#rlc log "    A4: test clear -------------------------------------"
$cpu cp \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "CLR"] \
  -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr  3 ainc 1] \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr 3 ainc 1] \
  -rblk pc.data 14 -edata {0 0 0 0 0 0  0 0 0 0 0 0  0 0} \
  -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr 10 waddr 0 ainc 1]

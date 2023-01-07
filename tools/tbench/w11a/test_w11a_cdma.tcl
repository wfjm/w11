# $Id: test_w11a_cdma.tcl 1347 2023-01-07 12:48:58Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-01-07  1347   1.0    Initial version
#
# Test bwm/brm while CPU active
#

# ----------------------------------------------------------------------------
rlc log "test_w11a_cdma: test bwm/brm while CPU active -----------------------"
rlc log "  A1: bwm/brm while CPU busy --------------------------------"

$cpu ldasm -lst lst -sym sym {
        . = 1000
stack:
start:  clr     r0              ; clear stop flag
        clr     r1              ; clear counter
        mov     #data,r2        ; ptr to data
100$:   inc     r1              ; bump counter
        mov     r2,r3           ; bump buffer
        inc     (r3)+
        inc     (r3)+
        inc     (r3)+
        inc     (r3)+
        tst     r0              ; check stop flag
        beq     100$            ; loop till set
        halt
stop:
;
data:   .word   0
        .word   0
        .word   0
        .word   0
buf:    .blkw 128.              ; buffer for dma
}

set buf {}
for {set i 0} {$i < 128} {incr i} {
  lappend buf [expr 0075000 + $i]
}

# start code
rw11::asmrun  $cpu sym
# write to buffer
$cpu cp -wal $sym(buf) \
        -bwm $buf
# read back and check
$cpu cp -wal $sym(buf) \
        -brm [llength $buf] -edata $buf
# end code by setting stop flag
$cpu cp -wr0 1
rw11::asmwait $cpu sym
# check that counter and data are consistent
$cpu cp -rr1 cnt
$cpu cp -wal $sym(data) \
        -brm 4 -edata [list $cnt $cnt $cnt $cnt]

rlc log "  A2: bwm/brm while CPU in WAIT -----------------------------"

$cpu ldasm -lst lst -sym sym {
        . = 1000
stack:
start:  wait                    ; wait for interrupt
100$:   halt
stop:
;
buf:    .blkw 128.              ; buffer for dma
}

# start code
$cpu cp -creset \
        -stapc $sym(start)
# check that wait does wait
rw11::asmtreg $cpu  pc $sym(start:100$)
# write to buffer
$cpu cp -wal $sym(buf) \
        -bwm $buf
rw11::asmtreg $cpu  pc $sym(start:100$)
# read back and check
$cpu cp -wal $sym(buf) \
        -brm [llength $buf] -edata $buf
rw11::asmtreg $cpu  pc $sym(start:100$)
# stop code and harvest attention
$cpu cp -stop \
        -attn


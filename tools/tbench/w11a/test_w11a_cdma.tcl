# $Id: test_w11a_cdma.tcl 1348 2023-01-08 13:33:01Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-01-07  1348   1.0    Initial version
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
        .include        |lib/defs_cpu.mac|
;
; setup pirq vector
        . = 000240
        .word   vh.pir
        .word   cp.pr7
;
        . = 1000
;
stack:
start:  wait                    ; wait for interrupt
100$:   halt
stop:
;
; PIRQ handler
vh.pir: clr     cp.pir          ; cancel PIRQ requests
        rti
;
buf:    .blkw 128.              ; buffer for dma
}

# start code
rw11::asmrun  $cpu sym
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
# end code via PIRQ interrupt with console write to cp.pir
$cpu cp -wibr [$cpu imap pirq] [regbld rw11::PIRQ {pir 2}]
rw11::asmwait $cpu sym;         # checks pc

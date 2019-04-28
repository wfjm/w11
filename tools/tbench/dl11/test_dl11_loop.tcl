# $Id: test_dl11_loop.tcl 1139 2019-04-27 14:00:38Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2019-04-26  1139   1.0    Initial version (derived from test_pc11_loop.tcl)
#
# Test DL11 combined receiver + transmitter response

# ----------------------------------------------------------------------------
rlc log "test_dl11_loop: test dl11 receive+transmit response -----------------"
package require ibd_dl11
if {![ibd_dl11::setup]} {
  rlc log "  test_dl11_loop-W: device not found, test aborted"
  return
}

# obtain 'type' from rcsr
$cpu cp -ribr tta.rcsr dlrcsr
set type  [regget ibd_dl11::RRCSR(type) $dlrcsr]
if {$type == 0} {
  rlc log "  test_dl11_loop-W: only available for buffered dl11"
  return
}

set fsize [expr {(1<<$type)-1}]
set nbyte [expr {$fsize - 3}]

# -- Section A ---------------------------------------------------------------
rlc log "  A1: loopback test: copy receive -> transmit ($nbyte bytes)-------"

# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_dl.mac|
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
;
        . = v..tti                      ; setup receiver vector
        .word   vh.tti
        .word   cp.pr7

        . = v..tto                      ; setup transmitter vector
        .word   vh.tto
        .word   cp.pr7

;
        . = 1000                ; code area
stack:
; 
; register usage:
;   r4   buffer write ptr
;   r5   buffer read ptr
; 
start:  mov     #buf,r4                 ; setup write ptr
        mov     r4,r5                   ; setup read  ptr
;
        spl     7
        bic     #to.ie,@#to.csr         ;;; disable tto irupt
        bis     #ti.ie,@#ti.csr         ;;; enable  tti irupt
        spl     0
;
3$:     wait
        br      3$
;
vh.tti: tstb    @#ti.csr                ;;; done set ?
        bpl     ehalt                   ;;; if pl not -> error halt
        movb    @#ti.buf,(r4)+          ;;; read char, to fifo
        bis     #to.ie,@#to.csr         ;;; enable tto irupt
        rti
;
vh.tto: tstb    @#to.csr                ;;; ready set ?
        bpl     ehalt                   ;;; if not error halt
        cmp     r4,r5                   ;;; data in fifo ?
        beq     ehalt                   ;;; if eq not -> error halt
        movb    (r5)+,@#to.buf          ;;; send char to transmitter
        beq     lchar                   ;;; if eq last char seen
        cmp     r4,r5                   ;;; more char in fifo
        bne     1$                      ;;; if ne yes, keep irupt enabled
        bic     #to.ie,@#to.csr         ;;; if fifo empty, disable tto irupt
1$:     rti

ehalt:  halt
lchar:  halt
stop:
buf:    .blkb   256.
}

## puts $lst

set rdata {}
set pdata {}
for {set i 0} { $i < $nbyte } {incr i} {
  set v [expr {$nbyte-$i-1}]
  lappend rdata $v
  lappend pdata [regbldkv ibd_dl11::RXBUF val 1 size [expr {$nbyte-$i}] data $v]
}

rw11::asmrun  $cpu sym

# fill receive fifo in two chunks
$cpu cp -wbibr tta.rbuf [lrange $rdata 0 [expr {$nbyte/2}] ]
$cpu cp -wbibr tta.rbuf [lrange $rdata [expr {$nbyte/2+1}] end ]

rw11::asmwait  $cpu sym 

# read and check transmitter fifo
$cpu cp \
  -wibr  tta.rcsr 0x0 \
  -wibr  tta.xcsr 0x0 \
  -rbibr tta.xbuf $nbyte -edata $pdata

#puts [rw11::cml $cpu]

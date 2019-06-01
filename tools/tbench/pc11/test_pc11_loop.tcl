# $Id: test_pc11_loop.tcl 1155 2019-05-31 06:38:06Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2019-05-30  1155   1.0.1  size->fuse rename
# 2019-04-20  1134   1.0    Initial version
# 2019-04-07  1129   0.1    First draft
#
# Test PC11 reader + puncher response

# ----------------------------------------------------------------------------
rlc log "test_pc11_loop: test pc11 reader+puncher response -------------------"
package require ibd_pc11
if {![ibd_pc11::setup]} {
  rlc log "  test_pc11_loop-W: device not found, test aborted"
  return
}

# obtain 'type' from rcsr
$cpu cp -ribr pca.rcsr pcrcsr
set type  [regget ibd_pc11::RRCSR(type) $pcrcsr]
if {$type == 0} {
  rlc log "  test_pc11_loop-W: only available for buffered pc11"
  return
}

set fsize [expr {(1<<$type)-1}]
set nbyte [expr {$fsize - 3}]

# -- Section A ---------------------------------------------------------------
rlc log "  A1: loopback test: copy reader -> puncher ($nbyte bytes)---------"

# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_pc.mac|
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
;
        . = v..ptr                      ; setup reader vector
        .word   vh.pr
        .word   cp.pr7

        . = v..ptp                      ; setup puncher vector
        .word   vh.pp
        .word   cp.pr7

;
        . = 1000                ; code area
stack:
; 
; register usage:
;   r4   buffer write ptr
;   r5   buffer read ptr
; 
start:
1$:     tst     @#pp.csr                ; test err
        bmi     1$                      ; loop on err=1
2$:     tst     @#pr.csr                ; test err
        bmi     2$                      ; loop on err=1
;
        mov     #buf,r4                 ; setup write ptr
        mov     r4,r5                   ; setup read  ptr
;
        spl     7
        bic     #pp.ie,@#pp.csr         ;;; disable pp irupt
        bis     #pr.ie,@#pr.csr         ;;; enable  pr irupt
        bis     #pr.ena,@#pr.csr        ;;; reader enable (read next)
        spl     0
;
3$:     wait
        br      3$
;
vh.pr:  tstb    @#pr.csr                ;;; done set ?
        bpl     ehalt                   ;;; if pl not -> error halt
        movb    @#pr.buf,(r4)+          ;;; read char, to fifo
        bis     #pr.ena,@#pr.csr        ;;; reader enable (read next)
        bis     #pp.ie,@#pp.csr         ;;; enable pp irupt
        rti
;
vh.pp:  tstb    @#pp.csr                ;;; ready set ?
        bpl     ehalt                   ;;; if not error halt
        cmp     r4,r5                   ;;; data in fifo ?
        beq     ehalt                   ;;; if eq not -> error halt
        movb    (r5)+,@#pp.buf          ;;; send char to punch
        beq     lchar                   ;;; if eq last char seen
        cmp     r4,r5                   ;;; more char in fifo
        bne     1$                      ;;; if ne yes, keep irupt enabled
        bic     #pp.ie,@#pp.csr         ;;; if fifo empty, disable pp irupt
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
  lappend pdata [regbldkv ibd_pc11::RPBUF val 1 fuse [expr {$nbyte-$i}] data $v]
}

# ensure pr and pp err=0
$cpu cp \
  -wibr  pca.rcsr 0x0 \
  -wibr  pca.pcsr 0x0

rw11::asmrun  $cpu sym

# fill reader fifo in two chunks
$cpu cp -wbibr pca.rbuf [lrange $rdata 0 [expr {$nbyte/2}] ]
$cpu cp -wbibr pca.rbuf [lrange $rdata [expr {$nbyte/2+1}] end ]

rw11::asmwait  $cpu sym 

# read and check puncher fifo
$cpu cp \
  -wibr  pca.rcsr 0x0 \
  -wibr  pca.pcsr 0x0 \
  -rbibr pca.pbuf $nbyte -edata $pdata

#puts [rw11::cml $cpu]

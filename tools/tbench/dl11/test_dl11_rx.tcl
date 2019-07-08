# $Id: test_dl11_rx.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-05-30  1155   1.0.1  size->fuse rename
# 2019-04-26  1139   1.0    Initial version (derived from test_pc11_pr.tcl)
#
# Test DL11 receiver response 

# ----------------------------------------------------------------------------
rlc log "test_dl11_pr: test dl11 paper reader resonse ------------------------"
package require ibd_dl11
if {![ibd_dl11::setup]} {
  rlc log "  test_dl11_pr-W: device not found, test aborted"
  return
}

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

set attndl  [expr {1<<$ibd_dl11::ANUM}]
set attncpu [expr {1<<$rw11::ANUM}]

# remember 'type' retrieved from rcsr for later tests
$cpu cp -ribr tta.rcsr dlrcsr
set type  [regget ibd_dl11::RRCSR(type) $dlrcsr]

# -- Section A ---------------------------------------------------------------
rlc log "  A1: test csr response -------------------------------------"
rlc log "    A1.1: csr ie ---------------------------------------"
#   loc IE=1   --> seen on loc and rem
#   rem IE=0   --> stays, IE not rem writable
#   loc IE=0   --> seen on loc and rem
set rcsrmask [regbld ibd_dl11::RRCSR done ie ir]

$cpu cp \
  -wma  tta.rcsr        [regbld ibd_dl11::RCSR ie] \
  -rma  tta.rcsr -edata [regbld ibd_dl11::RCSR ie] \
  -ribr tta.rcsr -edata [regbld ibd_dl11::RRCSR ie]  $rcsrmask\
  -wibr tta.rcsr 0x0 \
  -rma  tta.rcsr -edata [regbld ibd_dl11::RCSR ie] \
  -ribr tta.rcsr -edata [regbld ibd_dl11::RRCSR ie]  $rcsrmask\
  -wma  tta.rcsr 0x0 \
  -rma  tta.rcsr -edata [regbld ibd_dl11::RCSR ] \
  -ribr tta.rcsr -edata [regbld ibd_dl11::RRCSR ] $rcsrmask

if {$type > 0} {                # if buffered test rlim
  rlc log "    A1.2: csr rlim -----------------------------------"
  #   rem write rlim --> seen rem, not loc
  #   loc write rlim --> stays, rlim not loc writable
  #   breset         --> rlim not cleared
  set rcsrmaskbuf [regbld ibd_dl11::RRCSR {rlim -1} done ie ir]
  $cpu cp \
    -wibr tta.rcsr        [regbld ibd_dl11::RRCSR {rlim 1}] \
    -ribr tta.rcsr -edata [regbld ibd_dl11::RRCSR {rlim 1} ] $rcsrmaskbuf \
    -rma  tta.rcsr -edata [regbld ibd_dl11::RCSR ] \
    -wibr tta.rcsr        [regbld ibd_dl11::RRCSR {rlim 7}] \
    -ribr tta.rcsr -edata [regbld ibd_dl11::RRCSR {rlim 7} ] $rcsrmaskbuf \
    -wma  tta.rcsr 0x0 \
    -ribr tta.rcsr -edata [regbld ibd_dl11::RRCSR {rlim 7} ] $rcsrmaskbuf \
    -breset \
    -ribr tta.rcsr -edata [regbld ibd_dl11::RRCSR {rlim 7} ] $rcsrmaskbuf \
    -wibr tta.rcsr        [regbld ibd_dl11::RRCSR {rlim 0}] \
    -ribr tta.rcsr -edata [regbld ibd_dl11::RRCSR {rlim 0} ] $rcsrmaskbuf  
}

if {$type == 0} {                # unbuffered --------------------------
  rlc log "  A2: test data response (unbuffered) -----------------------"
  rlc log "    A2.1: rem write, loc read ------------------------"
    
  #                   test        RFUSE=0
  #    rem wr buf --> test DONE=1 RFUSE=1 (1 cmd delay)
  #    loc rd buf --> test DONE=0 RFUSE=0;
  $cpu cp \
    -ribr tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 0}] \
    -wibr tta.rbuf 0107 \
    -ribr tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 1}] \
    -rma  tta.rcsr \
    -rma  tta.rcsr -edata [regbld ibd_dl11::RCSR done] \
    -rma  tta.rbuf -edata 0107 \
    -rma  tta.rcsr -edata [regbld ibd_dl11::RCSR ] \
    -ribr tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 0}]

  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attndl $attndl
    
} else {                        #  buffered ---------------------------  
  set fsize [expr {(1<<$type)-1}]
  
  rlc log "  A2: test data response (basic fifo; AWIDTH=$type) --------"
  rlc log "    A2.1: rem write, loc read ------------------------"

  #    rem wr buf --> test DONE=1
  #    loc rd buf --> test DONE=0; test rem rbuf.busy=0
  #    loc rd buf --> test that buf cleared
  $cpu cp \
    -wibr tta.rbuf 0107 \
    -rma  tta.rcsr \
    -rma  tta.rcsr -edata [regbld ibd_dl11::RCSR done] \
    -rma  tta.rbuf -edata 0107 \
    -rma  tta.rcsr -edata [regbld ibd_dl11::RCSR ] \
    -ribr tta.rbuf -edata [regbld ibd_dl11::RRBUF]
  # expect and harvest attn
  rlc wtlam 1.
  rlc exec -attn -edata $attndl $attndl
  
  rlc log "    A2.2: test fifo csr.fclr clears and breset doesn't"
  #    rem wr buf --> test rbuf.fuse=1
  #    rem wr buf --> test rbuf.fuse=2
  # 2* rem wr buf --> test rbuf.fuse=4
  #    breset     --> test rbuf.fuse=4
  # 3* rem wr buf --> test rbuf.fuse=7
  #    csr.fclr   --> test rbuf.fuse=0
  $cpu cp \
    -wibr  tta.rbuf 0xaa \
    -ribr  tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 1}] \
    -wibr  tta.rbuf 0x55 \
    -ribr  tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 2}] \
    -wbibr tta.rbuf {0x11 0x22} \
    -ribr  tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 4}] \
    -breset \
    -ribr  tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 4}] \
    -wbibr tta.rbuf {0x33 0x44 0x55} \
    -ribr  tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 7}] \
    -wibr  tta.rcsr [regbld ibd_dl11::RRCSR fclr] \
    -ribr  tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 0}]
  # harvest breset/creset triggered attn's
  rlc exec -attn
  rlc wtlam 0.
  
  rlc log "  A3: test fifo logic -------------------------------------"
  rlc log "    A3.1: fill and overfill fifo ---------------------"
  set rdata {}
  for {set i 0} { $i < $fsize } {incr i} { lappend rdata [expr {$i+0100}] }
  #    rem wr fsize bytes --> test rbuf.fuse=fsize
  #    rem wr buf         --> test error and rbuf.fuse=fsize
  #    csr.fclr to discard data
  $cpu cp \
    -wbibr tta.rbuf $rdata \
    -ribr  tta.rbuf -edata [regbldkv ibd_dl11::RRBUF rfuse $fsize] \
    -wibr  tta.rbuf 0xff -estaterr \
    -ribr  tta.rbuf -edata [regbldkv ibd_dl11::RRBUF rfuse $fsize] \
    -wibr  tta.rcsr [regbld ibd_dl11::RRCSR fclr]
  
  rlc log "    A3.2: fill and empty fifo, attn on last read -----"
  #    rem wr 2 bytes --> test rbuf.fuse=2
  #    loc rd buf     --> test data; test rbuf.fuse=1; test no attn
  $cpu cp \
    -wbibr tta.rbuf {0x55 0xaa} \
    -ribr  tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 2}] \
    -rma   tta.rcsr \
    -rma   tta.rcsr -edata [regbld ibd_dl11::RCSR done] \
    -rma   tta.rbuf -edata 0x55 \
    -ribr  tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 1}]
  # test that no attn send
  rlc exec -attn -edata 0x0
  #    loc rd buf     --> test data; test rbuf.fuse=0; test attn seen
  $cpu cp \
    -rma   tta.rcsr \
    -rma   tta.rcsr -edata [regbld ibd_dl11::RCSR done] \
    -rma   tta.rbuf -edata 0xaa \
    -ribr  tta.rbuf -edata [regbld ibd_dl11::RRBUF {rfuse 0}]
  # expect and harvest attn
  rlc wtlam 1.
  rlc exec -attn -edata $attndl $attndl
}

# -- Section B ---------------------------------------------------------------
rlc log "  B1: test csr.ie and basic interrupt response --------------"
# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_dl.mac|
        . = va.tti               ; setup DL11 receiver interrupt vector
        .word vh.tti
        .word cp.pr7
;
        . = 1000                ; code area
stack:
;
; use in following mov to psw instead of spl to allow immediate interrupt
;
start:  spl     7                       ;;; lock-out interrupts
1$:     tstb    @#ti.csr                ;;; wait for done set
        bpl     1$                      ;;; 
        mov     #ti.ie,@#ti.csr         ;;; enable tti interrupt
        mov     #cp.pr6,@#cp.psw        ;;; allow pri=7
        mov     #cp.pr5,@#cp.psw        ;;; allow pri=6
        mov     #cp.pr4,@#cp.psw        ;;; allow pri=5
        mov     #cp.pr3,@#cp.psw        ;;; allow pri=4
        mov     #cp.pr2,@#cp.psw        ;;; allow pri=3
        mov     #cp.pr1,@#cp.psw        ;;; allow pri=2
        mov     #cp.pr0,@#cp.psw        ;;; allow pri=1
        halt                            ;;;
;
vh.tti: mov     @#ti.buf,r5             ;;; ptr handler
        halt                            ;;;
stop:
}

rw11::asmrun  $cpu sym
$cpu cp -wibr tta.rbuf 0111
rw11::asmwait $cpu sym
rw11::asmtreg $cpu r5 0111 \
                   sp [expr {$sym(stack)-4}]
rw11::asmtmem $cpu [expr {$sym(stack)-2}] [list [regbld rw11::PSW {pri 3}]]
#puts [rw11::cml $cpu]

rlc log "  B2: test csr.ie and rri write -> cpu read -----------------"
# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_dl.mac|
;
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
; 
        . = v..tti              ; setup DL11 receiver interrupt vector
        .word vh.tti
        .word cp.pr7
;
        . = 1000                ; data area
stack:
; 
start:  mov     #buf,r5                 ; set output buffer
        mov     #ti.ie,@#ti.csr         ; enable interrupt
1$:     wait                            ; wait for interrupt
        br      1$                      ; forever
;
vh.tti: movb    @#ti.buf,(r5)+          ;;; store char
        beq     1$                      ;;; last one
        rti                             ;;; exit interrupt
;
1$:     halt
stop:
buf:    .blkb   256.
}

# harvest any dangling attn
rlc exec -attn 
rlc wtlam 0.

set nchar     4
if {$type == 0} {                # unbuffered --------------------------
  rw11::asmrun  $cpu sym
  incr nchar -1
  $cpu cp -wibr tta.rbuf $nchar;  # send initial byte
  while {1} {
    if {[rlc wtlam 1.] >= 1.} { break }
    rlc exec -attn attnpat
    if {$attnpat & $attncpu} { break }; # cpu attn
    if {$attnpat & $attndl} {           # dl  attn
      incr nchar -1
      $cpu cp -wibr tta.rbuf $nchar;    # send next byte
    }
  }
  rw11::asmtreg $cpu pc $sym(stop)
  rw11::asmtmem $cpu [expr {$sym(buf)}] [list [expr {3 + (2<<8)}] \
                                              [expr {1 + (0<<8)}]]

} else {                        # buffered -----------------------------
  rw11::asmrun  $cpu sym
  $cpu cp -wbibr tta.rbuf {7 6 5 4 3 2 1 0}
  rw11::asmwait $cpu sym
  rw11::asmtmem $cpu [expr {$sym(buf)}] [list [expr {7 + (6<<8)}] \
                                              [expr {5 + (4<<8)}] \
                                              [expr {3 + (2<<8)}] \
                                              [expr {1 + (0<<8)}]]
}

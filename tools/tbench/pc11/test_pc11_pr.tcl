# $Id: test_pc11_pr.tcl 1364 2023-02-02 11:18:54Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-02-02  1364   1.0.2  use .mcall and vecdef
# 2019-05-30  1155   1.0.1  size->fuse rename
# 2019-04-21  1134   1.0    Initial version
# 2019-04-12  1131   0.1    First draft
#
# Test PC11 reader response 

# ----------------------------------------------------------------------------
rlc log "test_pc11_pr: test pc11 paper reader resonse ------------------------"
package require ibd_pc11
if {![ibd_pc11::setup]} {
  rlc log "  test_pc11_pr-W: device not found, test aborted"
  return
}

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

set attnpc  [expr {1<<$ibd_pc11::ANUM}]
set attncpu [expr {1<<$rw11::ANUM}]

# remember 'type' retrieved from rcsr for later tests
$cpu cp -ribr pca.rcsr pcrcsr
set type  [regget ibd_pc11::RRCSR(type) $pcrcsr]

# -- Section A ---------------------------------------------------------------
rlc log "  A1: test csr response -------------------------------------"
rlc log "    A1.1: csr err --------------------------------------"
#    breset & rem ERR=0  --> test DONE=0,IE=0
#    rem ERR=1           --> test ERR=1,DONE=0,IE=0   (DONE not rem writable)
#    loc ERR=0           --> test ERR=1,DONE=0,IE=0   (ERR  not loc writable)
#    rem ERR=0           --> test ERR=0,DONE=0,IE=0
#    breset              --> test ERR=0  (not set by breset)
set rcsrmask [regbld ibd_pc11::RRCSR err busy done ie ir ique iack]

$cpu cp \
  -breset \
  -wibr pca.rcsr 0x0 \
  -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR ] $rcsrmask \
  -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ] \
  -wibr pca.rcsr        [regbld ibd_pc11::RRCSR err] \
  -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR err ] $rcsrmask \
  -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR err ] \
  -wma  pca.rcsr 0x0 \
  -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR err ] \
  -wibr pca.rcsr 0x0 \
  -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR ] $rcsrmask \
  -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ] \
  -breset \
  -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ]

rlc log "    A1.2: csr ie ---------------------------------------"
#   loc IE=1   --> seen on loc and rem
#   rem IE=0   --> stays, IE not rem writable
#   loc IE=0   --> seen on loc and rem
$cpu cp \
  -wma  pca.rcsr        [regbld ibd_pc11::RCSR ie] \
  -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ie] \
  -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR ie]  $rcsrmask\
  -wibr pca.rcsr 0x0 \
  -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ie] \
  -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR ie]  $rcsrmask\
  -wma  pca.rcsr 0x0 \
  -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ] \
  -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR ] $rcsrmask

if {$type > 0} {                # if buffered test rlim
  rlc log "    A1.3: csr rlim -----------------------------------"
  #   rem write rlim --> seen rem, not loc
  #   loc write rlim --> stays, rlim not loc writable
  #   breset         --> rlim not cleared
  set rcsrmaskbuf [regbld ibd_pc11::RRCSR err {rlim -1} done ie ir ique iack]
  $cpu cp \
    -wibr pca.rcsr        [regbld ibd_pc11::RRCSR {rlim 1}] \
    -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR {rlim 1} ] $rcsrmaskbuf \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ] \
    -wibr pca.rcsr        [regbld ibd_pc11::RRCSR {rlim 7}] \
    -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR {rlim 7} ] $rcsrmaskbuf \
    -wma  pca.rcsr 0x0 \
    -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR {rlim 7} ] $rcsrmaskbuf \
    -breset \
    -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR {rlim 7} ] $rcsrmaskbuf \
    -wibr pca.rcsr        [regbld ibd_pc11::RRCSR {rlim 0}] \
    -ribr pca.rcsr -edata [regbld ibd_pc11::RRCSR {rlim 0} ] $rcsrmaskbuf  
}

if {$type == 0} {                # unbuffered --------------------------
  rlc log "  A2: test data response (unbuffered) -----------------------"
  rlc log "    A2.1: rem write, loc read ------------------------"
  #    loc wr csr.ena --> test BUSY=1; test rem rbuf.busy; test attn send
  $cpu cp \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 0}] \
    -wma  pca.rcsr        [regbld ibd_pc11::RCSR ena] \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR busy] \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF rbusy {rfuse 0}]
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc $attnpc
  #    rem wr buf --> test DONE=1 RFUSE=1 (1 cmd delay)
  #    loc rd buf --> test DONE=0 RRIZE=0  test rem rbuf.busy=0
  #    loc rd buf --> test that buf cleared
  $cpu cp \
    -wibr pca.rbuf 0107 \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 1}] \
    -rma  pca.rcsr \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR done] \
    -rma  pca.rbuf -edata 0107 \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ] \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 0}] \
    -rma  pca.rbuf -edata 0x0

  rlc log "    A2.2: rem write, loc write (discards data) -------"
  #    loc wr csr.ena --> test BUSY=1; test rem rbuf.busy; test attn send
  $cpu cp \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF] \
    -wma  pca.rcsr        [regbld ibd_pc11::RCSR ena] \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR busy] \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF rbusy]
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc $attnpc
  #    rem wr buf --> test DONE=1 (1 cmd delay)
  #    loc wr buf --> test DONE=0; test rem rbuf.busy=0  (do write here !!)
  #    loc rd buf --> test that buf cleared
  $cpu cp \
    -wibr pca.rbuf 0110 \
    -rma  pca.rcsr \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR done] \
    -wma  pca.rbuf 0177 \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ] \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF ] \
    -rma  pca.rbuf -edata 0x0
  
} else {                        #  buffered ---------------------------  
  set fsize [expr {(1<<$type)-1}]
  
  rlc log "  A2: test data response (basic fifo; AWIDTH=$type) --------"
  rlc log "    A2.1: rem write, loc read ------------------------"

  #    loc wr csr.ena --> test BUSY=1; test rem rbuf.busy
  $cpu cp \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF] \
    -wma  pca.rcsr        [regbld ibd_pc11::RCSR ena] \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR busy] \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF rbusy]
  # Note: pc11_buf send an attn only when reader buffer is emptied
  #       pc11_buf does not send an attn when ENA set 1 and not data 
  # test that no attn send
  rlc exec -attn -edata 0x0
  #    rem wr buf --> test DONE=1
  #    loc rd buf --> test DONE=0; test rem rbuf.busy=0
  #    loc rd buf --> test that buf cleared
  $cpu cp \
    -wibr pca.rbuf 0107 \
    -rma  pca.rcsr \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR done] \
    -rma  pca.rbuf -edata 0107 \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ] \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF ] \
    -rma  pca.rbuf -edata 0x0
  # expect and harvest attn
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc $attnpc
  
  rlc log "    A2.2: rem write, loc write (discards data) -------"
  #    loc wr csr.ena --> test BUSY=1; test rem rbuf.busy
  $cpu cp \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF] \
    -wma  pca.rcsr        [regbld ibd_pc11::RCSR ena] \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR busy] \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF rbusy]
  # test that no attn send
  rlc exec -attn -edata 0x0
  #    rem wr buf --> test DONE=1 (1 cmd delay)
  #    loc wr buf --> test DONE=0; test rem rbuf.busy=0  (do write here !!)
  #    loc rd buf --> test that buf cleared
  $cpu cp \
    -wibr pca.rbuf 0110 \
    -rma  pca.rcsr \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR done] \
    -wma  pca.rbuf 0177 \
    -rma  pca.rcsr -edata [regbld ibd_pc11::RCSR ] \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF ] \
    -rma  pca.rbuf -edata 0x0
  # expect and harvest attn
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc $attnpc
  
  rlc log "    A2.3: test fifo csr.fclr clears and breset doesn't"
  #    rem wr buf --> test rbuf.fuse=1
  #    rem wr buf --> test rbuf.fuse=2
  # 2* rem wr buf --> test rbuf.fuse=4
  #    breset     --> test rbuf.fuse=4
  # 3* rem wr buf --> test rbuf.fuse=7
  #    csr.fclr   --> test rbuf.fuse=0
  $cpu cp \
    -wibr  pca.rbuf 0xaa \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 1}] \
    -wibr  pca.rbuf 0x55 \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 2}] \
    -wbibr pca.rbuf {0x11 0x22} \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 4}] \
    -breset \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 4}] \
    -wbibr pca.rbuf {0x33 0x44 0x55} \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 7}] \
    -wibr  pca.rcsr [regbld ibd_pc11::RRCSR fclr] \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 0}]
  # harvest breset/creset triggered attn's
  rlc exec -attn
  rlc wtlam 0.
  
  rlc log "    A2.4: test fifo clear on csr.err=1 ---------------"
  # 2* rem wr buf --> test rbuf.fuse=2
  #    csr.err=1  --> test rbuf.fuse=0
  #    rem wr buf --> test rbuf.fuse=0
  #    csr.err=0 
  $cpu cp \
    -wbibr pca.rbuf {0x66 0x77} \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 2}] \
    -wibr  pca.rcsr        [regbld ibd_pc11::RRCSR err] \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 0}] \
    -wibr  pca.rbuf 0x88 \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 0}] \
    -wibr  pca.rcsr 0x0
  
  rlc log "  A3: test fifo logic -------------------------------------"
  rlc log "    A3.1: fill and overfill fifo ---------------------"
  set rdata {}
  for {set i 0} { $i < $fsize } {incr i} { lappend rdata [expr {$i+0100}] }
  #    rem wr fsize bytes --> test rbuf.fuse=fsize
  #    rem wr buf         --> test error and rbuf.fuse=fsize
  #    csr.fclr to discard data
  $cpu cp \
    -wbibr pca.rbuf $rdata \
    -ribr  pca.rbuf -edata [regbldkv ibd_pc11::RRBUF rfuse $fsize] \
    -wibr  pca.rbuf 0xff -estaterr \
    -ribr  pca.rbuf -edata [regbldkv ibd_pc11::RRBUF rfuse $fsize] \
    -wibr  pca.rcsr [regbld ibd_pc11::RRCSR fclr]
  
  rlc log "    A3.2: fill and empty fifo, attn on last read -----"
  #    rem wr 2 bytes --> test rbuf.fuse=2
  #    loc wr csr.ena --> test DONE=1 (1 cmd delay)
  #    loc rd buf     --> test data; test rbuf.fuse=1; test no attn
  $cpu cp \
    -wbibr pca.rbuf {0x55 0xaa} \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 2}] \
    -wma   pca.rcsr        [regbld ibd_pc11::RCSR ena] \
    -rma   pca.rcsr \
    -rma   pca.rcsr -edata [regbld ibd_pc11::RCSR done] \
    -rma   pca.rbuf -edata 0x55 \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 1}]
  # test that no attn send
  rlc exec -attn -edata 0x0
  #    loc wr csr.ena --> test DONE=1 (1 cmd delay)
  #    loc rd buf     --> test data; test rbuf.fuse=0; test attn seen
  $cpu cp \
    -wma   pca.rcsr        [regbld ibd_pc11::RCSR ena] \
    -rma   pca.rcsr \
    -rma   pca.rcsr -edata [regbld ibd_pc11::RCSR done] \
    -rma   pca.rbuf -edata 0xaa \
    -ribr  pca.rbuf -edata [regbld ibd_pc11::RRBUF {rfuse 0}]
  # expect and harvest attn
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc $attnpc
}

# -- Section B ---------------------------------------------------------------
rlc log "  B1: test csr.ie and basic interrupt response --------------"
# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_pc.mac|
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
        .mcall  vecdef
;
        vecdef    v..ptr,vh.ptr ; setup  reader vector
;
        . = 1000                ; code area
stack:
;
; use in following mov to psw instead of spl to allow immediate interrupt
;
start:  spl     7                       ;;; lock-out interrupts
        mov     #vh.ptr,@#va.ptr        ;;; setup ptr handler
        mov     #pr.ie,@#pr.csr         ;;; enable ptr interrupt
        bis     #pr.ena,@#pr.csr        ;;; reader enable (read next)
1$:     tstb    @#pr.csr                ;;; wait for done set
        bpl     1$                      ;;; 
        mov     #cp.pr6,@#cp.psw        ;;; allow pri=7
        mov     #cp.pr5,@#cp.psw        ;;; allow pri=6
        mov     #cp.pr4,@#cp.psw        ;;; allow pri=5
        mov     #cp.pr3,@#cp.psw        ;;; allow pri=4
        mov     #cp.pr2,@#cp.psw        ;;; allow pri=3
        mov     #cp.pr1,@#cp.psw        ;;; allow pri=2
        mov     #cp.pr0,@#cp.psw        ;;; allow pri=1
        halt                            ;;;
;
vh.ptr: mov     @#pr.buf,r5             ;;; ptr handler
        halt                            ;;;
stop:
;
; continue to perform err interrupt test
;
        mov     #vh.err,@#va.ptr        ;;; setup err handler
        spl     0                       ; allow interrupts
1$:     wait                    	; wait for interrupts
        br      1$

vh.err: halt                            ;;; err handler
stop1:
}

rlc log "    B1.1: done 0->1 interrupt --------------------------"
cpu0 cp -wibr pca.rcsr 0x0;     # ensure err = 0
rw11::asmrun  $cpu sym
if {$type == 0} {               # unbuffered: attn at ena time
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc $attnpc
}
$cpu cp -wibr pca.rbuf 0111
rw11::asmwait $cpu sym
rw11::asmtreg $cpu r5 0111 \
                   sp [expr {$sym(stack)-4}]
rw11::asmtmem $cpu [expr {$sym(stack)-2}] [list [regbld rw11::PSW {pri 3}]]
#puts [rw11::cml $cpu]

rlc log "    B1.2: err interrupt --------------------------------"

# continue code; set err=1 -> should interrupt again
cpu0 cp \
  -start \
  -wibr pca.rcsr [regbld ibd_pc11::RRCSR err]

rw11::asmwait $cpu sym 0. stop1
rw11::asmtreg $cpu sp [expr {$sym(stack)-8}]
#puts [rw11::cml $cpu]

cpu0 cp -wibr pca.rcsr 0x0;     # ensure err = 0 again

rlc log "  B2: test csr.ie and rri write -> cpu read -----------------"
# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_pc.mac|
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
        .mcall  vecdef
; 
        vecdef    v..ptr,vh.ptr ; setup  reader vector
;
        . = 1000                ; data area
stack:
; 
start:  mov     #buf,r5                 ; set output buffer
        mov     #pr.ie,@#pr.csr         ; enable interrupt
        bis     #pr.ena,@#pr.csr        ; reader enable (read next)
1$:     wait                            ; wait for interrupt
        br      1$                      ; forever
;
vh.ptr: movb    @#pr.buf,(r5)+          ;;; store char
        beq     1$                      ;;; last one
        bis     #pr.ena,@#pr.csr        ;;; reader enable (read next)
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
  while {1} {
    if {[rlc wtlam 1.] >= 1.} { break }
    rlc exec -attn attnpat
    if {$attnpat & $attncpu} { break }; # cpu attn
    if {$attnpat & $attnpc} {           # pc  attn
      incr nchar -1
      $cpu cp -wibr pca.rbuf $nchar;  # send byte
    }
  }
  rw11::asmtreg $cpu pc $sym(stop)
  rw11::asmtmem $cpu [expr {$sym(buf)}] [list [expr {3 + (2<<8)}] \
                                              [expr {1 + (0<<8)}]]

} else {                        # buffered -----------------------------
  rw11::asmrun  $cpu sym
  $cpu cp -wbibr pca.rbuf {7 6 5 4 3 2 1 0}
  rw11::asmwait $cpu sym
  rw11::asmtmem $cpu [expr {$sym(buf)}] [list [expr {7 + (6<<8)}] \
                                              [expr {5 + (4<<8)}] \
                                              [expr {3 + (2<<8)}] \
                                              [expr {1 + (0<<8)}]]
}

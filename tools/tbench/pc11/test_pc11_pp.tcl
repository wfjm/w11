# $Id: test_pc11_pp.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-05-30  1155   1.0.1  size->fuse rename
# 2019-04-21  1134   1.0    Initial version
# 2019-04-07  1129   0.1    First draft
#
# Test PC11 puncher response 

# ----------------------------------------------------------------------------
rlc log "test_pc11_pp: test pc11 paper puncher resonse -----------------------"
package require ibd_pc11
if {![ibd_pc11::setup]} {
  rlc log "  test_pc11_pp-W: device not found, test aborted"
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
rlc log "    A1.1: csr err, rdy ---------------------------------"
#    breset & rem ERR=0  --> test RDY=1,IE=0
#    rem ERR=1           --> test ERR=1,RDY=1,IE=0   (RDY not rem writable)
#    loc ERR=0           --> test ERR=1,RDY=1,IE=0   (ERR  not loc writable)
#    rem ERR=0           --> test ERR=0,RDY=1,IE=0
#    breset              --> test ERR=0  (not set by breset)
set rcsrmask [regbld ibd_pc11::RPCSR err rdy ie ir]

$cpu cp \
  -breset \
  -wibr pca.pcsr 0x0 \
  -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR rdy] $rcsrmask \
  -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
  -wibr pca.pcsr        [regbld ibd_pc11::RPCSR err] \
  -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR err rdy] $rcsrmask \
  -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR err rdy] \
  -wma  pca.pcsr 0x0 \
  -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR err rdy] \
  -wibr pca.pcsr 0x0 \
  -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR rdy] $rcsrmask \
  -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
  -breset \
  -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy]

rlc log "    A1.2: csr ie, ir -----------------------------------"
#   loc IE=1   --> seen on loc and rem; rem sees IR=1
#   rem IE=0   --> stays, IE not rem writable
#   loc IE=0   --> seen on loc and rem; rem sees IR=0
$cpu cp \
  -wma  pca.pcsr        [regbld ibd_pc11::PCSR ie] \
  -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy ie] \
  -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR rdy ie ir]  $rcsrmask\
  -wibr pca.pcsr 0x0 \
  -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy ie] \
  -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR rdy ie ir]  $rcsrmask\
  -wma  pca.pcsr 0x0 \
  -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
  -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR rdy] $rcsrmask

if {$type > 0} {                # if buffered test rlim
  rlc log "    A1.3: csr rlim -----------------------------------"
  #   rem write rlim --> seen rem, not loc
  #   loc write rlim --> stays, rlim not loc writable
  #   breset         --> rlim not cleared
  set rcsrmaskbuf [regbld ibd_pc11::RPCSR err {rlim -1} rdy ie]
  $cpu cp \
    -wibr pca.pcsr        [regbld ibd_pc11::RPCSR {rlim 1}] \
    -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR {rlim 1} rdy] $rcsrmaskbuf \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -wibr pca.pcsr        [regbld ibd_pc11::RPCSR {rlim 7}] \
    -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR {rlim 7} rdy] $rcsrmaskbuf \
    -wma  pca.pcsr 0x0 \
    -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR {rlim 7} rdy] $rcsrmaskbuf \
    -breset \
    -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR {rlim 7} rdy] $rcsrmaskbuf \
    -wibr pca.pcsr        [regbld ibd_pc11::RPCSR {rlim 0}] \
    -ribr pca.pcsr -edata [regbld ibd_pc11::RPCSR {rlim 0} rdy] $rcsrmaskbuf  
}

if {$type == 0} {                # unbuffered --------------------------
  rlc log "  A2: test data response (unbuffered) -----------------------"
  rlc log "    A2.1: loc write, rem read ------------------------"
  #               --> test        PFUSE=0
  #    loc wr buf --> test RDY=0  PFUSE=1
  #    loc rd buf --> test RDY=0  (loc read is noop); test attn send
  #    rem wr buf --> test RDY=1  PFUSE=0
  $cpu cp \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF {pfuse 0}] \
    -wma  pca.pbuf 0107 \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF {pfuse 1}] \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR] \
    -rma  pca.pbuf \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR] \
    -ribr pca.pbuf -edata [regbld ibd_pc11::RPBUF val {fuse 1} {data 0107} ] \
    -ribr pca.rbuf -edata [regbld ibd_pc11::RRBUF {pfuse 0}] \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy]
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc $attnpc

  rlc log "    A2.2: csr.err=1, no attn, RDY=1, no val data -----"
  $cpu cp \
    -wibr pca.pcsr [regbld ibd_pc11::RPCSR err] \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR err rdy] \
    -wma  pca.pbuf 031 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR err rdy] \
    -wibr pca.pcsr 0x0 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -ribr pca.pbuf -edata [regbld ibd_pc11::RPBUF {fuse 0} {data 0107} ]
  # test that no attn send
  rlc exec -attn -edata 0x0

  rlc log "    A2.3: 8 bit data; rdy set on breset --------------"
  $cpu cp \
    -wma  pca.pbuf 0370 \
    -ribr pca.pbuf -edata [regbld ibd_pc11::RPBUF val {fuse 1} {data 0370} ] \
    -wma  pca.pbuf 040 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR] \
    -breset \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy]
  # harvest breset/creset triggered attn's
  rlc exec -attn
  rlc wtlam 0.

  rlc log "    A2.4: loc write, csr.err sets RDY, data invalid --"
    $cpu cp \
    -wma  pca.pbuf 032 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR] \
    -wibr pca.pcsr [regbld ibd_pc11::RPCSR err] \
    -wibr pca.pcsr 0x0 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -ribr pca.pbuf -edata [regbld ibd_pc11::RPBUF {fuse 0} {data 032} ]
  # expect and harvest attn
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc
  
} else {                        #  buffered ---------------------------  
  set fsize [expr {(1<<$type)-1}]
  
  rlc log "  A2: test data response (basic fifo; AWIDTH=$type) --"
  rlc log "    A2.1: loc write, rem read; rbuf.pfuse check -------"
  #    loc wr buf --> test RDY=1  rbuf.pfuse=1
  #    loc rd buf --> test RDY=1  (loc read is noop); test attn send
  #    loc wr buf --> test RDY=1  rbuf.pfuse=2
  #    loc wr buf --> test RDY=1  rbuf.pfuse=3
  #    rem wr buf --> test VAL=1,FUSE=3  rbuf.pfuse=2
  #    rem wr buf --> test VAL=1,FUSE=2  rbuf.pfuse=1
  #    rem wr buf --> test VAL=1,FUSE=1  rbuf.pfuse=0
  $cpu cp \
    -ribr pca.rbuf -edata [regbldkv ibd_pc11::RRBUF pfuse 0] \
    -wma  pca.pbuf 031 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -ribr pca.rbuf -edata [regbldkv ibd_pc11::RRBUF pfuse 1] \
    -rma  pca.pbuf \
    -wma  pca.pbuf 032 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -ribr pca.rbuf -edata [regbldkv ibd_pc11::RRBUF pfuse 2] \
    -wma  pca.pbuf 033 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -ribr pca.rbuf -edata [regbldkv ibd_pc11::RRBUF pfuse 3] \
    -ribr pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse 3 data 031] \
    -ribr pca.rbuf -edata [regbldkv ibd_pc11::RRBUF pfuse 2] \
    -ribr pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse 2 data 032] \
    -ribr pca.rbuf -edata [regbldkv ibd_pc11::RRBUF pfuse 1] \
    -ribr pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse 1 data 033] \
    -ribr pca.rbuf -edata [regbldkv ibd_pc11::RRBUF pfuse 0] \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy]
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc $attnpc

  rlc log "    A2.2: csr.err=1, loc write not stored, no attn ---"
    $cpu cp \
    -wibr pca.pcsr [regbld ibd_pc11::PCSR err] \
    -wma  pca.pbuf 034 \
    -wibr pca.pcsr 0x0 \
    -ribr pca.pbuf -estaterr
  # test that no attn send
  rlc exec -attn -edata 0x0
  
  rlc log "    A2.3: loc write, rem blk read abort; 8 bit data --"
  #   loc wr two char; rem blk rd three char --> expect 2 and error
  #   test 7 bit data path trunctation
  $cpu cp \
    -wma   pca.pbuf 0340 \
    -wma   pca.pbuf 0037 \
    -rbibr pca.pbuf 4 -estaterr -edone 2 -edata \
             [list [regbldkv ibd_pc11::RPBUF val 1 fuse 2 data 0340] \
                   [regbldkv ibd_pc11::RPBUF val 1 fuse 1 data 0037] ] 
  # expect and harvest attn 
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc
  
  rlc log "    A2.4: loc write, breset does not clear -----------"
  $cpu cp \
    -wma   pca.pbuf 041 \
    -wma   pca.pbuf 042 \
    -breset \
    -rbibr pca.pbuf 3 -estaterr -edata \
             [list [regbldkv ibd_pc11::RPBUF val 1 fuse 2 data 0041] \
                   [regbldkv ibd_pc11::RPBUF val 1 fuse 1 data 0042] ]
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc $attnpc
  
  rlc log "    A2.5: loc write, csr.err clears fifo -------------"
  $cpu cp \
    -wma   pca.pbuf 043 \
    -wma   pca.pbuf 044 \
    -wibr  pca.pcsr [regbld ibd_pc11::RPCSR err] \
    -wibr  pca.pcsr 0x0 \
    -rbibr pca.pbuf 3 -estaterr -edone 0 
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc $attnpc
  
  rlc log "  A3: test fifo logic (csr.rdy and attn) ------------------"
  rlc log "    A3.1: 1st loc write, get attn --------------------"
  #     1 loc wr -> get attn (1 in fifo; RDY=1)
  $cpu cp \
    -wma  pca.pbuf 051 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy]
  # expect and harvest attn 
  rlc wtlam 1.
  rlc exec -attn -edata $attnpc
  
  rlc log "    A3.2: 2nd loc write, no attn ---------------------"
  #     1 loc wr -> no attn  (2 in fifo)
  $cpu cp  \
    -wma  pca.pbuf 052 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy]
  rlc exec -attn -edata 0x0
    
  rlc log "    A3.3: write/read to non-empty fifo -> no attn ----"
  #     1 rem rd             (1 in fifo; RDY=1)
  #     1 loc wr -> no attn  (2 in fifo; RDY=1)
  #     1 rem rd             (1 in fifo; RDY=1)
  $cpu cp \
    -ribr pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse 2 data 051] \
    -wma  pca.pbuf 053 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy]

  rlc exec -attn -edata 0x0
  $cpu cp \
    -ribr pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse 2 data 052] \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy]

  rlc log "    A3.4: fill fifo, RDY 1->0 on $fsize char ---------"
  #   x = fsize in following
  #   x-2 loc wr             (x-1 in fifo; RDY=1)
  #     1 rem rd             (x-2 in fifo; RDY=1)
  #     1 rem rd             (x-3 in fifo; RDY=1)
  $cpu ldasm -lst lst -sym sym {
        .include  |lib/vec_cpucatch.mac|
        . = 1000                ; data area
stack:
; 
start:  mov     r2,(r0)
        sob     r1,start
        halt
stop:
}
  # specify ps in asmrun to use -start (and avoid a creset!!)
  set fs0 $fsize
  set fs1 [expr {$fsize-1}]
  set fs2 [expr {$fsize-2}]
  set fs4 [expr {$fsize-4}]
  rw11::asmrun  $cpu sym r0 [$cpu imap pca.pbuf] \
                         r1 $fs2 \
                         r2 066 \
                         ps [regbld rw11::PSW {cmode k} {pri 7}]
  rw11::asmwait $cpu sym
  rw11::asmtreg $cpu     r1 0
  
  $cpu cp \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -ribr pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse $fs1 data 053] \
    -ribr pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse $fs2 data 066] \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy]

  #     1 loc wr ->  (x-2 in fifo; RDY=1)
  #     1 loc wr ->  (x-1 in fifo; RDY=1)
  #     1 loc wr ->  (x   in fifo; RDY=0)
  #     1 loc wr ->  (x   in fifo; RDY=0)  (overfill !!)
    $cpu cp  \
    -wma  pca.pbuf 066 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -wma  pca.pbuf 066 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -wma  pca.pbuf 066 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR] \
    -wma  pca.pbuf 066 \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR]
  
  rlc log "    A3.5: partial fifo read, RDY goes 1 --------------"
  #     1 rem rd ->  (x-1 in fifo; RDY=1)
  #     1 rem rd ->  (x-2 in fifo; RDY=1)
  $cpu cp \
    -ribr pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse $fs0 data 066] \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -ribr pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse $fs1 data 066] \
    -rma  pca.pcsr -edata [regbld ibd_pc11::PCSR rdy]
  
  rlc log "    A3.6: full fifo read -----------------------------"
  #   x-4 rem rd ->  (  2 in fifo; RDY=1)
  #     1 rem rd ->  (  1 in fifo; RDY=1)
  #     1 rem rd ->  (  0 in fifo; RDY=1)
  #     1 rem rd ->  error
  set edata {}
  for {set i 0} { $i < $fs4 } {incr i} {
    lappend edata [regbldkv ibd_pc11::RPBUF val 1 fuse [expr {$fs2-$i}] data 066]
  }
  $cpu cp \
    -rbibr pca.pbuf $fs4 -edata $edata \
    -ribr  pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse 2 data 066] \
    -rma   pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -ribr  pca.pbuf -edata [regbldkv ibd_pc11::RPBUF val 1 fuse 1 data 066] \
    -rma   pca.pcsr -edata [regbld ibd_pc11::PCSR rdy] \
    -ribr  pca.pbuf -estaterr
}

# harvest triggered attn's
rlc exec -attn 
rlc wtlam 0.

# -- Section B ---------------------------------------------------------------
rlc log "  B1: test csr.ie and basic interrupt response --------------"
# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_pc.mac|
        . = va.ptp               ; setup PC11 puncher interrupt vector
        .word vh.ptp
        .word cp.pr7
;
        . = 1000                ; code area
stack:
;
; use in following mov to psw instead of spl to allow immediate interrupt
;
start:  spl     7                       ;;; lock-out interrupts
        mov     #vh.ptp,@#va.ptp        ;;; setup ptp handler
        mov     #pp.ie,@#pp.csr         ;;; enable ptp interrupts
        mov     #cp.pr6,@#cp.psw        ;;; allow pri=7
        mov     #cp.pr5,@#cp.psw        ;;; allow pri=6
        mov     #cp.pr4,@#cp.psw        ;;; allow pri=5
        mov     #cp.pr3,@#cp.psw        ;;; allow pri=4
        mov     #cp.pr2,@#cp.psw        ;;; allow pri=3
        mov     #cp.pr1,@#cp.psw        ;;; allow pri=2
        mov     #cp.pr0,@#cp.psw        ;;; allow pri=1
        halt                            ;;;
;
vh.ptp: halt                            ;;; ptp handler
stop:
;
; continue to perform err interrupt test
;
        mov     #vh.err,@#va.ptp        ;;; setup err handler
        spl     0                       ; allow interrupts
1$:     wait                    	; wait for interrupts
        br      1$

vh.err: halt                            ;;; err handler
stop1:
}

rlc log "    B1.1: ie 0->1 interrupt ----------------------------"

# check that interrupt done, and pushed psw has pri=3 (device is pri=4)
cpu0 cp -wibr pca.pcsr 0x0;     # ensure err = 0
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym
rw11::asmtreg $cpu sp [expr {$sym(stack)-4}]
rw11::asmtmem $cpu [expr {$sym(stack)-2}] [list [regbld rw11::PSW {pri 3}]]

rlc log "    B1.2: err interrupt --------------------------------"

# continue code; set err=1 -> should interrupt again
cpu0 cp \
  -start \
  -wibr pca.pcsr [regbld ibd_pc11::RPCSR err]

rw11::asmwait $cpu sym 0. stop1
rw11::asmtreg $cpu sp [expr {$sym(stack)-8}]

cpu0 cp -wibr pca.pcsr 0x0;     # ensure err = 0 again

rlc log "  B2: test csr.ie and cpu write -> rri read -----------------"

# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_pc.mac|
;
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
; 
        . = v..ptp              ; setup PC11 puncher interrupt vector
        .word vh.ptp
        .word cp.pr7
;
        . = 1000                ; data area
stack:
; 
start:                                  ; call with r0=<count_of_chars>
        spl     7
        mov     #pp.ie,@#pp.csr         ; enable interrupt
        clr     r1                      ; clear out char
        spl     0
1$:     wait                            ; wait for interrupt
        br      1$                      ; forever
;
vh.ptp: movb    r1,@#pp.buf             ;;; write char
        dec     r0                      ;;; all done ?
        beq     1$                      ;;; if eq yes, quit
        incb    r1                      ;;;
        bicb    #200,r1                 ;;;
        tstb    @#pp.csr                ;;; ready set ?
        bmi     vh.ptp                  ;;; if mi yes, loop
        rti                             ;;; otherwise exit interrupt
;
1$:     halt
stop:
}

set nchar     4
set charcur   0
set charseen  0
set haltseen  0

if {$type == 0} {                # unbuffered --------------------------
  rw11::asmrun  $cpu sym r0 $nchar
  while {1} {
    if {[rlc wtlam 1.] >= 1.} { break }
    rlc exec -attn attnpat
    if {$attnpat & $attncpu} {    # cpu attn
      set haltseen 1
    }
    if {$attnpat & $attnpc} {     # pc attn
      $cpu cp \
        -ribr pca.pbuf -edata [regbldkv ibd_pc11::RPBUF \
                                 val 1 fuse 1 data $charcur]
      set charcur [expr { ($charcur+1) & 0377 }]
      incr charseen
    }
    if {$charseen == $nchar && $haltseen} { break }
  }
  
} else {                        # buffered -----------------------------
  # setup char count as about 1.25 of fifo size
  #   AWIDTH  4    15+ 3 =  18
  #   AWIDTH  5    31+ 7 =  38
  #   AWIDTH  6    63+15 =  78
  #   AWIDTH  7   127+31 = 158
  set nchar [expr {$fsize + ($fsize>>2)}]
  set rfuse [expr {$fsize>>2}]
  set wttout 10.;               # wtlam timeout 

  set fstatmsk [regbld rw11::STAT cmderr rbtout rbnak]; # don't check err !!

  # try this to verify rlim logic --> quite a slow down !!
  # $cpu cp -wibr pca.pcsr  [regbld ibd_pc11::RPCSR {rlim 1}]  
  
  rw11::asmrun  $cpu sym r0 $nchar
  while (1) {
    if {[rlc wtlam $wttout] >= $wttout} { break }; # quit on timeout
    rlc exec -attn attnpat
    
    if {$attnpat & $attncpu} {    # cpu attn
      set haltseen 1
    }
    if {$attnpat & $attnpc} {     # pc attn
      while (1) {
        $cpu cp \
          -rbibr pca.pbuf $rfuse fdata -estat 0x0 $fstatmsk
        for {set i 0} { $i < [llength $fdata] } {incr i} {
          set rbuf [lindex $fdata $i]
          set val  [regget ibd_pc11::RPBUF(val)  $rbuf]
          set fuse [regget ibd_pc11::RPBUF(fuse) $rbuf]
          set data [regget ibd_pc11::RPBUF(data) $rbuf]
          if {$val != 1 || $data != $charcur} {
            rlc log "FAIL: bad data: val: $val; data: $data, exp: $charcur"
            rlc errcnt -inc
          }
          if {$i   == 0} { set rfuse $fuse }
          set charcur [expr { ($charcur+1) & 0177 }]
          incr charseen
        }
        if {$fuse <= 1} {
          rlc log "    rbibr chain ends with fuse=1 after $charseen"
          break;
        }
      }
    }
    if {$charseen == $nchar && $haltseen} { break }
  } 
}

$cpu cp -rpc -edata $sym(stop);           # check proper stop pc
if {$haltseen == 0} {  $cpu cp -creset }; # kill rouge code

# harvest any dangling attn
rlc exec -attn 
rlc wtlam 0.

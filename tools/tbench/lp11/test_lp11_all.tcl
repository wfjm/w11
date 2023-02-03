# $Id: test_lp11_all.tcl 1364 2023-02-02 11:18:54Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-02-02  1364   1.0.4  use .mcall and vecdef
# 2019-05-30  1155   1.0.3  size->fuse rename
# 2019-04-19  1134   1.0.2  fifo not longer cleared by breset
# 2019-04-06  1126   1.0.1  check csr.err and csr.rlim not changed by breset
# 2019-03-17  1123   1.0    Initial version
# 2019-03-11  1121   0.1    First draft
#
# Test register response 
#  A: register basics

# ----------------------------------------------------------------------------
rlc log "test_lp11_all: test lp11 response -----------------------------------"
package require ibd_lp11
if {![ibd_lp11::setup]} {
  rlc log "  test_lp11_all-W: device not found, test aborted"
  return
}

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

set attnlp  [expr {1<<$ibd_lp11::ANUM}]
set attncpu [expr {1<<$rw11::ANUM}]

# -- Section A ---------------------------------------------------------------
rlc log "  A1: test csr response -------------------------------------"
rlc log "    A1.1: csr err, done --------------------------------"
#    breset & rem ERR=0  --> test DONE=1,IE=0
#    rem ERR=1           --> test ERR=1,DONE=1,IE=0   (DONE not rem writable)
#    loc ERR=0           --> test ERR=1,DONE=1,IE=0   (ERR  not loc writable)
#    rem ERR=0           --> test ERR=0,DONE=1,IE=0
#    breset              --> test ERR=0  (not set by breset)
set rcsrmask [regbld ibd_lp11::RCSR err done ie ir]

$cpu cp \
  -breset \
  -wibr lpa.csr 0x0 \
  -ribr lpa.csr lprcsr -edata [regbld ibd_lp11::RCSR done] $rcsrmask \
  -rma  lpa.csr        -edata [regbld ibd_lp11::CSR done] \
  -wibr lpa.csr               [regbld ibd_lp11::RCSR err] \
  -ribr lpa.csr        -edata [regbld ibd_lp11::RCSR err done] $rcsrmask \
  -rma  lpa.csr        -edata [regbld ibd_lp11::CSR err done] \
  -wma  lpa.csr 0x0 \
  -rma  lpa.csr        -edata [regbld ibd_lp11::CSR err done] \
  -wibr lpa.csr 0x0 \
  -ribr lpa.csr        -edata [regbld ibd_lp11::RCSR done] $rcsrmask \
  -rma  lpa.csr        -edata [regbld ibd_lp11::CSR done] \
  -breset \
  -rma  lpa.csr        -edata [regbld ibd_lp11::CSR done]

# remember 'type' retrieved from csr for later tests
set type  [regget ibd_lp11::RCSR(type) $lprcsr]

rlc log "    A1.2: csr ie,ir ------------------------------------"
#   loc IE=1   --> seen on loc and rem (check also ir=1)
#   rem IE=0   --> stays, IE not rem writable
#   loc IE=0   --> seen on loc and rem
$cpu cp \
  -wma  lpa.csr        [regbld ibd_lp11::CSR ie] \
  -rma  lpa.csr -edata [regbld ibd_lp11::CSR done ie] \
  -ribr lpa.csr -edata [regbld ibd_lp11::RCSR done ie ir]  $rcsrmask\
  -wibr lpa.csr 0x0 \
  -rma  lpa.csr -edata [regbld ibd_lp11::CSR done ie] \
  -ribr lpa.csr -edata [regbld ibd_lp11::RCSR done ie ir]  $rcsrmask\
  -wma  lpa.csr 0x0 \
  -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
  -ribr lpa.csr -edata [regbld ibd_lp11::RCSR done] $rcsrmask

if {$type > 0} {                # if buffered test rlim
  rlc log "    A1.3: csr rlim -------------------------------------"
  #   rem write rlim --> seen rem, not loc
  #   loc write rlim --> stays, rlim not loc writable
  #   breset         --> rlim not cleared
  set rcsrmaskbuf [regbld ibd_lp11::RCSR err {rlim -1} done ie ir]
  $cpu cp \
    -wibr lpa.csr        [regbld ibd_lp11::RCSR {rlim 1}] \
    -ribr lpa.csr -edata [regbld ibd_lp11::RCSR {rlim 1} done] $rcsrmaskbuf \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -wibr lpa.csr        [regbld ibd_lp11::RCSR {rlim 7}] \
    -ribr lpa.csr -edata [regbld ibd_lp11::RCSR {rlim 7} done] $rcsrmaskbuf \
    -wma  lpa.csr 0x0 \
    -ribr lpa.csr -edata [regbld ibd_lp11::RCSR {rlim 7} done] $rcsrmaskbuf \
    -breset \
    -ribr lpa.csr -edata [regbld ibd_lp11::RCSR {rlim 7} done] $rcsrmaskbuf \
    -wibr lpa.csr        [regbld ibd_lp11::RCSR {rlim 0}] \
    -ribr lpa.csr -edata [regbld ibd_lp11::RCSR {rlim 0} done] $rcsrmaskbuf  
}

if {$type == 0} {                # unbuffered --------------------------
  rlc log "  A2: test data response (unbuffered) -----------------------"
  rlc log "    A2.1: loc write, rem read --------------------------"
  #    loc wr buf --> test DONE=0
  #    loc rd buf --> test DONE=0  (loc read is noop); test attn send
  #    rem wr buf --> test DONE=1
  $cpu cp \
    -wma  lpa.buf 0107 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR] \
    -rma  lpa.buf \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR] \
    -ribr lpa.buf -edata [regbld ibd_lp11::RBUF val {fuse 1} {data 0107} ] \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done]
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attnlp $attnlp

  rlc log "    A2.2: csr.err=1, no attn, DONE=1, no val data ------"
    $cpu cp \
    -wibr lpa.csr [regbld ibd_lp11::RCSR err] \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR err done] \
    -wma  lpa.buf 031 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR err done] \
    -wibr lpa.csr 0x0 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -ribr lpa.buf -edata [regbld ibd_lp11::RBUF {fuse 0} {data 031} ]
  # test that no attn send
  rlc exec -attn -edata 0x0

  rlc log "    A2.3: 7 bit data; done set on breset ---------------"
  $cpu cp \
    -wma  lpa.buf 0370 \
    -ribr lpa.buf -edata [regbld ibd_lp11::RBUF val {fuse 1} {data 0170} ] \
    -wma  lpa.buf 040 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR] \
    -breset \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done]
  # harvest breset/creset triggered attn's
  rlc exec -attn
  rlc wtlam 0.

  rlc log "    A2.4: loc write, csr.err sets DONE, date invalid ---"
    $cpu cp \
    -wma  lpa.buf 032 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR] \
    -wibr lpa.csr [regbld ibd_lp11::RCSR err] \
    -wibr lpa.csr 0x0 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -ribr lpa.buf -edata [regbld ibd_lp11::RBUF {fuse 0} {data 032} ]
  # expect and harvest attn
  rlc wtlam 1.
  rlc exec -attn -edata $attnlp
  
} else {                        #  buffered ---------------------------  
  set fsize [expr {(1<<$type)-1}]
  
  rlc log "  A2: test data response (basic fifo; AWIDTH=$type) --------"
  rlc log "    A2.1: loc write, rem read --------------------------"
  #    loc wr buf --> test DONE=1
  #    loc rd buf --> test DONE=1  (loc read is noop); test attn send
  #    loc wr buf --> test DONE=1
  #    loc wr buf --> test DONE=1
  #    rem wr buf --> test VAL=1,FUSE=3
  #    rem wr buf --> test VAL=1,FUSE=2
  #    rem wr buf --> test VAL=1,FUSE=1
  $cpu cp \
    -wma  lpa.buf 031 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -rma  lpa.buf \
    -wma  lpa.buf 032 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -wma  lpa.buf 033 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -ribr lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse 3 data 031] \
    -ribr lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse 2 data 032] \
    -ribr lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse 1 data 033] \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done]
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attnlp $attnlp
  
  rlc log "    A2.2: csr.err=1, loc write not stored, no attn -----"
    $cpu cp \
    -wibr lpa.csr [regbld ibd_lp11::CSR err] \
    -wma  lpa.buf 034 \
    -wibr lpa.csr 0x0 \
    -ribr lpa.buf -estaterr
  # test that no attn send
  rlc exec -attn -edata 0x0

  rlc log "    A2.3: loc write, rem blk read abort; 7 bit data ----"
  #   loc wr two char; rem blk rd three char --> expect 2 and error
  #   test 7 bit data path trunctation
  $cpu cp \
    -wma   lpa.buf 0340 \
    -wma   lpa.buf 0037 \
    -rbibr lpa.buf 4 -estaterr -edone 2 -edata \
             [list [regbldkv ibd_lp11::RBUF val 1 fuse 2 data 0140] \
                   [regbldkv ibd_lp11::RBUF val 1 fuse 1 data 0037] ] 
  # expect and harvest attn 
  rlc wtlam 1.
  rlc exec -attn -edata $attnlp
  
  rlc log "    A2.4: loc write, breset does not clear fifo --------"
  $cpu cp \
    -wma   lpa.buf 041 \
    -wma   lpa.buf 042 \
    -breset \
    -rbibr lpa.buf 3 -estaterr -edata \
             [list [regbldkv ibd_lp11::RBUF val 1 fuse 2 data 0041] \
                   [regbldkv ibd_lp11::RBUF val 1 fuse 1 data 0042] ] 
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attnlp $attnlp
  
  rlc log "    A2.5: loc write, csr.err clears fifo ---------------"
  $cpu cp \
    -wma   lpa.buf 043 \
    -wma   lpa.buf 044 \
    -wibr  lpa.csr [regbld ibd_lp11::RCSR err] \
    -wibr  lpa.csr 0x0 \
    -rbibr lpa.buf 3 -estaterr -edone 0 
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attnlp $attnlp
  
  rlc log "  A3: test fifo logic (csr.done and attn) ------------------"
  rlc log "    A3.1: 1st loc write, get attn ----------------------"
  #     1 loc wr -> get attn (1 in fifo; DONE=1)
  $cpu cp \
    -wma  lpa.buf 051 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done]
  # expect and harvest attn 
  rlc wtlam 1.
  rlc exec -attn -edata $attnlp
  
  rlc log "    A3.2: 2nd loc write, no attn -----------------------"
  #     1 loc wr -> no attn  (2 in fifo)
  $cpu cp  \
    -wma  lpa.buf 052 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done]
  rlc exec -attn -edata 0x0
    
  rlc log "    A3.3: write/read to non-empty fifo -> no attn ------"
  #     1 rem rd             (1 in fifo; DONE=1)
  #     1 loc wr -> no attn  (2 in fifo; DONE=1)
  #     1 rem rd             (1 in fifo; DONE=1)
  $cpu cp \
    -ribr lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse 2 data 051] \
    -wma  lpa.buf 053 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done]

  rlc exec -attn -edata 0x0
  $cpu cp \
    -ribr lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse 2 data 052] \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done]

  rlc log "    A3.4: fill fifo, DONE 1->0 on $fsize char -------------"
  #   x = fsize in following
  #   x-2 loc wr             (x-1 in fifo; DONE=1)
  #     1 rem rd             (x-2 in fifo; DONE=1)
  #     1 rem rd             (x-3 in fifo; DONE=1)
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
  rw11::asmrun  $cpu sym r0 [$cpu imap lpa.buf] \
                         r1 $fs2 \
                         r2 066 \
                         ps [regbld rw11::PSW {cmode k} {pri 7}]
  rw11::asmwait $cpu sym
  rw11::asmtreg $cpu     r1 0
  
  $cpu cp \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -ribr lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse $fs1 data 053] \
    -ribr lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse $fs2 data 066] \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done]

  #     1 loc wr ->  (x-2 in fifo; DONE=1)
  #     1 loc wr ->  (x-1 in fifo; DONE=1)
  #     1 loc wr ->  (x   in fifo; DONE=0)
  #     1 loc wr ->  (x   in fifo; DONE=0)  (overfill !!)
    $cpu cp  \
    -wma  lpa.buf 066 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -wma  lpa.buf 066 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -wma  lpa.buf 066 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR] \
    -wma  lpa.buf 066 \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR]
  
  rlc log "    A3.5: partial fifo read, DONE goes 1 ---------------"
  #     1 rem rd ->  (x-1 in fifo; DONE=1)
  #     1 rem rd ->  (x-2 in fifo; DONE=1)
  $cpu cp \
    -ribr lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse $fs0 data 066] \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -ribr lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse $fs1 data 066] \
    -rma  lpa.csr -edata [regbld ibd_lp11::CSR done]
  
  rlc log "    A3.6: full fifo read -------------------------------"
  #   x-4 rem rd ->  (  2 in fifo; DONE=1)
  #     1 rem rd ->  (  1 in fifo; DONE=1)
  #     1 rem rd ->  (  0 in fifo; DONE=1)
  #     1 rem rd ->  error
  set edata {}
  for {set i 0} { $i < $fs4 } {incr i} {
    lappend edata [regbldkv ibd_lp11::RBUF val 1 fuse [expr {$fs2-$i}] data 066]
  }
  $cpu cp \
    -rbibr lpa.buf $fs4 -edata $edata \
    -ribr  lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse 2 data 066] \
    -rma   lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -ribr  lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse 1 data 066] \
    -rma   lpa.csr -edata [regbld ibd_lp11::CSR done] \
    -ribr  lpa.buf -estaterr
}

# harvest triggered attn's
rlc exec -attn 
rlc wtlam 0.

# -- Section B ---------------------------------------------------------------
rlc log "  B1: test csr.ie and basic interrupt response --------------"
# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_lp.mac|
        . = va.lp               ; setup LP11 interrupt vector
        .word vh.lp
        .word cp.pr7
;
        . = 1000                ; data area
stack:
;
; use in following mov to psw instead of spl to allow immediate interrupt
;
start:  spl     7                       ;;; lock-out interrupts
        mov     #lp.ie,@#lp.csr         ;;; enable lp interrupts
        mov     #cp.pr6,@#cp.psw        ;;; allow pri=7
        mov     #cp.pr5,@#cp.psw        ;;; allow pri=6
        mov     #cp.pr4,@#cp.psw        ;;; allow pri=5
        mov     #cp.pr3,@#cp.psw        ;;; allow pri=4
        mov     #cp.pr2,@#cp.psw        ;;; allow pri=3
        mov     #cp.pr1,@#cp.psw        ;;; allow pri=2
        mov     #cp.pr0,@#cp.psw        ;;; allow pri=1
        halt                            ;;;
;
vh.lp:  halt
stop:
}

# check that interrupt done, and pushed psw has pri=3 (device is pri=4)
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym
rw11::asmtreg $cpu sp [expr {$sym(stack)-4}]
rw11::asmtmem $cpu [expr {$sym(stack)-2}] [list [regbld rw11::PSW {pri 3}]]

rlc log "  B2: test csr.ie and cpu write -> rri read -----------------"

# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_lp.mac|
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
        .mcall  vecdef
;
        vecdef  v..lp,vh.lp     ; setup LP11 interrupt vector
;
        . = 1000                ; data area
stack:
; 
start:                                  ; call with r0=<count_of_chars>
        spl     7
        mov     #lp.ie,@#lp.csr         ; enable interrupt
        clr     r1                      ; clear out char
        spl     0
1$:     wait                            ; wait for interrupt
        br      1$                      ; forever
;
vh.lp:  movb    r1,@#lp.buf             ; write char
        dec     r0                      ; all done ?
        beq     1$                      ; if eq yes, quit
        incb    r1
        bicb    #200,r1
        tstb    @#lp.csr                ; done set ?
        bmi     vh.lp                   ; if mi yes, loop
        rti                             ; otherwise exit interrupt
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
    if {$attnpat & $attnlp} {     # lp attn
      $cpu cp \
        -ribr lpa.buf -edata [regbldkv ibd_lp11::RBUF val 1 fuse 1 data $charcur]
      set charcur [expr { ($charcur+1) & 0177 }]
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
  # $cpu cp -wibr lpa.csr  [regbld ibd_lp11::RCSR {rlim 1}]  
  
  rw11::asmrun  $cpu sym r0 $nchar
  while (1) {
    if {[rlc wtlam $wttout] >= $wttout} { break }; # quit on timeout
    rlc exec -attn attnpat
    
    if {$attnpat & $attncpu} {    # cpu attn
      set haltseen 1
    }
    if {$attnpat & $attnlp} {     # lp attn
      while (1) {
        $cpu cp \
          -rbibr lpa.buf $rfuse fdata -estat 0x0 $fstatmsk
        for {set i 0} { $i < [llength $fdata] } {incr i} {
          set rbuf [lindex $fdata $i]
          set val  [regget ibd_lp11::RBUF(val)  $rbuf]
          set fuse [regget ibd_lp11::RBUF(fuse) $rbuf]
          set data [regget ibd_lp11::RBUF(data) $rbuf]
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

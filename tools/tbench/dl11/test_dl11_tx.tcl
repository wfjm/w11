# $Id: test_dl11_tx.tcl 1140 2019-04-28 10:21:21Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2019-04-26  1139   1.0    Initial version (derived from test_pc11_pp.tcl)
#
# Test DL11 transmitter response

# ----------------------------------------------------------------------------
rlc log "test_dl11_tx: test dl11 paper puncher resonse -----------------------"
package require ibd_dl11
if {![ibd_dl11::setup]} {
  rlc log "  test_dl11_tx-W: device not found, test aborted"
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
rlc log "    A1.1: csr rdy, ie, ir ------------------------------"
#    breset              --> test RDY=1,IE=0
#   loc IE=1   --> seen on loc and rem; rem sees IR=1
#   rem IE=0   --> stays, IE not rem writable
#   loc IE=0   --> seen on loc and rem; rem sees IR=0
set rcsrmask [regbld ibd_dl11::RXCSR rdy ie ir]

$cpu cp \
  -breset \
  -wibr tta.xcsr 0x0 \
  -ribr tta.xcsr -edata [regbld ibd_dl11::RXCSR rdy] $rcsrmask \
  -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
  -wma  tta.xcsr        [regbld ibd_dl11::XCSR ie] \
  -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy ie] \
  -ribr tta.xcsr -edata [regbld ibd_dl11::RXCSR rdy ie ir]  $rcsrmask\
  -wibr tta.xcsr 0x0 \
  -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy ie] \
  -ribr tta.xcsr -edata [regbld ibd_dl11::RXCSR rdy ie ir]  $rcsrmask\
  -wma  tta.xcsr 0x0 \
  -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
  -ribr tta.xcsr -edata [regbld ibd_dl11::RXCSR rdy] $rcsrmask

if {$type > 0} {                # if buffered test rlim
  rlc log "    A1.2: csr rlim -----------------------------------"
  #   rem write rlim --> seen rem, not loc
  #   loc write rlim --> stays, rlim not loc writable
  #   breset         --> rlim not cleared
  set rcsrmaskbuf [regbld ibd_dl11::RXCSR {rlim -1} rdy ie]
  $cpu cp \
    -wibr tta.xcsr        [regbld ibd_dl11::RXCSR {rlim 1}] \
    -ribr tta.xcsr -edata [regbld ibd_dl11::RXCSR {rlim 1} rdy] $rcsrmaskbuf \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
    -wibr tta.xcsr        [regbld ibd_dl11::RXCSR {rlim 7}] \
    -ribr tta.xcsr -edata [regbld ibd_dl11::RXCSR {rlim 7} rdy] $rcsrmaskbuf \
    -wma  tta.xcsr 0x0 \
    -ribr tta.xcsr -edata [regbld ibd_dl11::RXCSR {rlim 7} rdy] $rcsrmaskbuf \
    -breset \
    -ribr tta.xcsr -edata [regbld ibd_dl11::RXCSR {rlim 7} rdy] $rcsrmaskbuf \
    -wibr tta.xcsr        [regbld ibd_dl11::RXCSR {rlim 0}] \
    -ribr tta.xcsr -edata [regbld ibd_dl11::RXCSR {rlim 0} rdy] $rcsrmaskbuf  
}

if {$type == 0} {                # unbuffered --------------------------
  rlc log "  A2: test data response (unbuffered) -----------------------"
  rlc log "    A2.1: loc write, rem read ------------------------"
  #               --> test        XSIZE=0
  #    loc wr buf --> test RDY=0  XSIZE=1
  #    loc rd buf --> test RDY=0  (loc read is noop); test attn send
  #    rem wr buf --> test RDY=1  XSIZE=0
  $cpu cp \
    -ribr tta.rbuf -edata [regbld ibd_dl11::RRBUF {xsize 0}] \
    -wma  tta.xbuf 0107 \
    -ribr tta.rbuf -edata [regbld ibd_dl11::RRBUF {xsize 1}] \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR] \
    -rma  tta.xbuf \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR] \
    -ribr tta.xbuf -edata [regbld ibd_dl11::RXBUF val {size 1} {data 0107} ] \
    -ribr tta.rbuf -edata [regbld ibd_dl11::RRBUF {xsize 0}] \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy]
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attndl $attndl

  rlc log "    A2.2: 8 bit data; rdy set on breset --------------"
  $cpu cp \
    -wma  tta.xbuf 0370 \
    -ribr tta.xbuf -edata [regbld ibd_dl11::RXBUF val {size 1} {data 0370} ] \
    -wma  tta.xbuf 040 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR] \
    -breset \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy]
  # harvest breset/creset triggered attn's
  rlc exec -attn
  rlc wtlam 0.
  
} else {                        #  buffered ---------------------------  
  set fsize [expr {(1<<$type)-1}]
  
  rlc log "  A2: test data response (basic fifo; AWIDTH=$type) --"
  rlc log "    A2.1: loc write, rem read; rbuf.xsize check -------"
  #    loc wr buf --> test RDY=1  rbuf.xsize=1
  #    loc rd buf --> test RDY=1  (loc read is noop); test attn send
  #    loc wr buf --> test RDY=1  rbuf.xsize=2
  #    loc wr buf --> test RDY=1  rbuf.xsize=3
  #    rem wr buf --> test VAL=1,SIZE=3  rbuf.xsize=2
  #    rem wr buf --> test VAL=1,SIZE=2  rbuf.xsize=1
  #    rem wr buf --> test VAL=1,SIZE=1  rbuf.xsize=0
  $cpu cp \
    -ribr tta.rbuf -edata [regbldkv ibd_dl11::RRBUF xsize 0] \
    -wma  tta.xbuf 031 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
    -ribr tta.rbuf -edata [regbldkv ibd_dl11::RRBUF xsize 1] \
    -rma  tta.xbuf \
    -wma  tta.xbuf 032 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
    -ribr tta.rbuf -edata [regbldkv ibd_dl11::RRBUF xsize 2] \
    -wma  tta.xbuf 033 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
    -ribr tta.rbuf -edata [regbldkv ibd_dl11::RRBUF xsize 3] \
    -ribr tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size 3 data 031] \
    -ribr tta.rbuf -edata [regbldkv ibd_dl11::RRBUF xsize 2] \
    -ribr tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size 2 data 032] \
    -ribr tta.rbuf -edata [regbldkv ibd_dl11::RRBUF xsize 1] \
    -ribr tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size 1 data 033] \
    -ribr tta.rbuf -edata [regbldkv ibd_dl11::RRBUF xsize 0] \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy]
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attndl $attndl

  rlc log "    A2.2: loc write, rem blk read abort; 8 bit data --"
  #   loc wr two char; rem blk rd three char --> expect 2 and error
  #   test 7 bit data path trunctation
  $cpu cp \
    -wma   tta.xbuf 0340 \
    -wma   tta.xbuf 0037 \
    -rbibr tta.xbuf 4 -estaterr -edone 2 -edata \
             [list [regbldkv ibd_dl11::RXBUF val 1 size 2 data 0340] \
                   [regbldkv ibd_dl11::RXBUF val 1 size 1 data 0037] ] 
  # expect and harvest attn 
  rlc wtlam 1.
  rlc exec -attn -edata $attndl
  
  rlc log "    A2.3: loc write, breset does not clear -----------"
  $cpu cp \
    -wma   tta.xbuf 041 \
    -wma   tta.xbuf 042 \
    -breset \
    -rbibr tta.xbuf 3 -estaterr -edata \
             [list [regbldkv ibd_dl11::RXBUF val 1 size 2 data 0041] \
                   [regbldkv ibd_dl11::RXBUF val 1 size 1 data 0042] ]
  # expect and harvest attn (drop other attn potentially triggered by breset)
  rlc wtlam 1.
  rlc exec -attn -edata $attndl $attndl
  
  rlc log "  A3: test fifo logic (csr.rdy and attn) ------------------"
  rlc log "    A3.1: 1st loc write, get attn --------------------"
  #     1 loc wr -> get attn (1 in fifo; RDY=1)
  $cpu cp \
    -wma  tta.xbuf 051 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy]
  # expect and harvest attn 
  rlc wtlam 1.
  rlc exec -attn -edata $attndl
  
  rlc log "    A3.2: 2nd loc write, no attn ---------------------"
  #     1 loc wr -> no attn  (2 in fifo)
  $cpu cp  \
    -wma  tta.xbuf 052 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy]
  rlc exec -attn -edata 0x0
    
  rlc log "    A3.3: write/read to non-empty fifo -> no attn ----"
  #     1 rem rd             (1 in fifo; RDY=1)
  #     1 loc wr -> no attn  (2 in fifo; RDY=1)
  #     1 rem rd             (1 in fifo; RDY=1)
  $cpu cp \
    -ribr tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size 2 data 051] \
    -wma  tta.xbuf 053 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy]

  rlc exec -attn -edata 0x0
  $cpu cp \
    -ribr tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size 2 data 052] \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy]

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
  rw11::asmrun  $cpu sym r0 [$cpu imap tta.xbuf] \
                         r1 $fs2 \
                         r2 066 \
                         ps [regbld rw11::PSW {cmode k} {pri 7}]
  rw11::asmwait $cpu sym
  rw11::asmtreg $cpu     r1 0
  
  $cpu cp \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
    -ribr tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size $fs1 data 053] \
    -ribr tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size $fs2 data 066] \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy]

  #     1 loc wr ->  (x-2 in fifo; RDY=1)
  #     1 loc wr ->  (x-1 in fifo; RDY=1)
  #     1 loc wr ->  (x   in fifo; RDY=0)
  #     1 loc wr ->  (x   in fifo; RDY=0)  (overfill !!)
    $cpu cp  \
    -wma  tta.xbuf 066 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
    -wma  tta.xbuf 066 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
    -wma  tta.xbuf 066 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR] \
    -wma  tta.xbuf 066 \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR]
  
  rlc log "    A3.5: partial fifo read, RDY goes 1 --------------"
  #     1 rem rd ->  (x-1 in fifo; RDY=1)
  #     1 rem rd ->  (x-2 in fifo; RDY=1)
  $cpu cp \
    -ribr tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size $fs0 data 066] \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
    -ribr tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size $fs1 data 066] \
    -rma  tta.xcsr -edata [regbld ibd_dl11::XCSR rdy]
  
  rlc log "    A3.6: full fifo read -----------------------------"
  #   x-4 rem rd ->  (  2 in fifo; RDY=1)
  #     1 rem rd ->  (  1 in fifo; RDY=1)
  #     1 rem rd ->  (  0 in fifo; RDY=1)
  #     1 rem rd ->  error
  set edata {}
  for {set i 0} { $i < $fs4 } {incr i} {
    lappend edata [regbldkv ibd_dl11::RXBUF val 1 size [expr {$fs2-$i}] data 066]
  }
  $cpu cp \
    -rbibr tta.xbuf $fs4 -edata $edata \
    -ribr  tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size 2 data 066] \
    -rma   tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
    -ribr  tta.xbuf -edata [regbldkv ibd_dl11::RXBUF val 1 size 1 data 066] \
    -rma   tta.xcsr -edata [regbld ibd_dl11::XCSR rdy] \
    -ribr  tta.xbuf -estaterr
}

# harvest triggered attn's
rlc exec -attn 
rlc wtlam 0.

# -- Section B ---------------------------------------------------------------
rlc log "  B1: test csr.ie and basic interrupt response --------------"
# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_dl.mac|
        . = va.tto              ; setup DL11 transmitter interrupt vector
        .word vh.tto
        .word cp.pr7
;
        . = 1000                ; code area
stack:
;
; use in following mov to psw instead of spl to allow immediate interrupt
;
start:  spl     7                       ;;; lock-out interrupts
        mov     #to.ie,@#to.csr         ;;; enable dlt interrupts
        mov     #cp.pr6,@#cp.psw        ;;; allow pri=7
        mov     #cp.pr5,@#cp.psw        ;;; allow pri=6
        mov     #cp.pr4,@#cp.psw        ;;; allow pri=5
        mov     #cp.pr3,@#cp.psw        ;;; allow pri=4
        mov     #cp.pr2,@#cp.psw        ;;; allow pri=3
        mov     #cp.pr1,@#cp.psw        ;;; allow pri=2
        mov     #cp.pr0,@#cp.psw        ;;; allow pri=1
        halt                            ;;;
;
vh.tto: halt                            ;;; dlt handler
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
        .include  |lib/defs_dl.mac|
;
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
; 
        . = v..tto              ; setup DL11 transmitter interrupt vector
        .word vh.tto
        .word cp.pr7
;
        . = 1000                ; data area
stack:
; 
start:                                  ; call with r0=<count_of_chars>
        spl     7
        mov     #to.ie,@#to.csr         ; enable interrupt
        clr     r1                      ; clear out char
        spl     0
1$:     wait                            ; wait for interrupt
        br      1$                      ; forever
;
vh.tto: movb    r1,@#to.buf             ;;; write char
        dec     r0                      ;;; all done ?
        beq     1$                      ;;; if eq yes, quit
        incb    r1                      ;;;
        bicb    #200,r1                 ;;;
        tstb    @#to.csr                ;;; ready set ?
        bmi     vh.tto                  ;;; if mi yes, loop
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
    if {$attnpat & $attndl} {     # dl attn
      $cpu cp \
        -ribr tta.xbuf -edata [regbldkv ibd_dl11::RXBUF \
                                 val 1 size 1 data $charcur]
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
  set rsize [expr {$fsize>>2}]
  set wttout 10.;               # wtlam timeout 

  set fstatmsk [regbld rw11::STAT cmderr rbtout rbnak]; # don't check err !!

  # try this to verify rlim logic --> quite a slow down !!
  # $cpu cp -wibr tta.xcsr  [regbld ibd_dl11::RXCSR {rlim 1}]  
  
  rw11::asmrun  $cpu sym r0 $nchar
  while (1) {
    if {[rlc wtlam $wttout] >= $wttout} { break }; # quit on timeout
    rlc exec -attn attnpat
    
    if {$attnpat & $attncpu} {    # cpu attn
      set haltseen 1
    }
    if {$attnpat & $attndl} {     # dl attn
      while (1) {
        $cpu cp \
          -rbibr tta.xbuf $rsize fdata -estat 0x0 $fstatmsk
        for {set i 0} { $i < [llength $fdata] } {incr i} {
          set rbuf [lindex $fdata $i]
          set val  [regget ibd_dl11::RXBUF(val)  $rbuf]
          set size [regget ibd_dl11::RXBUF(size) $rbuf]
          set data [regget ibd_dl11::RXBUF(data) $rbuf]
          if {$val != 1 || $data != $charcur} {
            rlc log "FAIL: bad data: val: $val; data: $data, exp: $charcur"
            rlc errcnt -inc
          }
          if {$i   == 0} { set rsize $size }
          set charcur [expr { ($charcur+1) & 0177 }]
          incr charseen
        }
        if {$size <= 1} {
          rlc log "    rbibr chain ends with size=1 after $charseen"
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

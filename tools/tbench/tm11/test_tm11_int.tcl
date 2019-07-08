# $Id: test_tm11_int.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-03-09  1120   1.0.2  add proper device check
# 2015-07-25   704   1.0.1  tmpproc_dotest: use args rather opts
# 2015-05-17   683   1.0    Initial version
#
# Test interrupt response 
#  A: 

# ----------------------------------------------------------------------------
rlc log "test_tm11_int: test interrupt response ------------------------------"
rlc log "  setup: all units online"
package require ibd_tm11
if {![ibd_tm11::setup]} {
  rlc log "  test_tm11_regs-W: device not found, test aborted"
  return
}

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

# configure drives
set rsronl  [regbld ibd_tm11::RRL {onl 1} {bot 1}]
$cpu cp -wibr "tma.cr"  [ibd_tm11::rcr_wunit 0] \
        -wibr "tma.rl" $rsronl \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 1] \
        -wibr "tma.rl" $rsronl \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 2] \
        -wibr "tma.rl" $rsronl \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 3] \
        -wibr "tma.rl" $rsronl

# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_tm.mac|
;
        .include  |lib/vec_cpucatch.mac|
; 
        . = 000224              ; setup TM11 interrupt vector
v..tm:  .word vh.tm
        .word cp.pr7
;
        . = 1000                ; data area
stack:  
ibuf:   .blkw  3.               ; input  buffer
obuf:   .blkw  5.               ; output buffer
fbuf:   .blkw  4.               ; final  buffer
;
        . = 2000                ; code area
start:  spl     7               ; lock out interrupts
; 
        mov     #obuf,r0        ; clear obuf 
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
; 
        mov     #ibuf,r0        ; setup regs from ibuf
        mov     (r0)+,@#tm.bc   ;   bc 
        mov     (r0)+,@#tm.ba   ;   ba
        mov     (r0)+,@#tm.cr   ;   cr 
        spl     0               ; allow interrupts
;   
poll:   tstb    @#tm.cr         ; check cr
        bpl     poll            ; if rdy=0 keep polling
; 
4$:     mov     #fbuf,r0        ; store final regs in fbuf
        mov     @#tm.sr,(r0)+   ;   sr
        mov     @#tm.cr,(r0)+   ;   cr
        mov     @#tm.bc,(r0)+   ;   bc
        mov     @#tm.ba,(r0)+   ;   ba

        halt                    ; halt if done
stop:

; TM11 interrupt handler
vh.tm:  mov     #obuf,r0        ; store regs in obuf
        mov     #1,(r0)+        ; flag
        mov     @#tm.sr,(r0)+   ;   sr 
        mov     @#tm.cr,(r0)+   ;   cr 
        mov     @#tm.bc,(r0)+   ;   bc 
        mov     @#tm.ba,(r0)+   ;   ba
        rti                     ; and return
}

##puts $lst

# define tmpproc for readback checks
proc tmpproc_dotest {cpu symName args} {
  upvar 1 $symName sym

  set tout 10.;                   # FIXME_code: parameter ??

# setup defs hash, first defaults, than write over concrete run values  
  args2opts opts {i.cr     0 \
                  i.bc     0 \
                  i.ba     0 \
                  o.sr     0 \
                  o.cr     0 \
                  o.bc     0 \
                  o.ba     0 \
                  do.lam   0 } {*}$args

  # build ibuf
  set ibuf [list $opts(i.bc) $opts(i.ba) $opts(i.cr)] 

  # setup write ibuf, setup stack, and start cpu at start:
  $cpu cp -wal   $sym(ibuf) \
          -bwm   $ibuf \
          -wsp   $sym(stack) \
          -stapc $sym(start)

  # here do minimal lam handling (harvest + send DONE)
  if {$opts(do.lam)} {
    rlc wtlam $tout apat
    $cpu cp -attn \
            -wibr tma.cs [ibd_rhrp::cr_func $ibd_tm11::RFUNC_DONE]
  }

  $cpu wtcpu -reset $tout

  # determine regs after cleanup
  $cpu cp -rpc   -edata $sym(stop) \
          -rsp   -edata $sym(stack) \
          -wal   $sym(obuf) \
          -rmi   -edata 1   \
          -rmi   -edata $opts(o.sr) \
          -rmi   -edata $opts(o.cr) \
          -rmi   -edata $opts(o.bc) \
          -rmi   -edata $opts(o.ba) \
          -wal   $sym(fbuf) \
          -rmi   -edata $opts(o.sr) \
          -rmi   -edata $opts(o.cr) \
          -rmi   -edata $opts(o.bc) \
          -rmi   -edata $opts(o.ba)   

  return
}

# discard pending attn to be on save side
rlc wtlam 0.
rlc exec -attn

# -- Section A ---------------------------------------------------------------
rlc log "    A1.1 set cr.ie=1 -> software interrupt -------------"

tmpproc_dotest $cpu sym \
            i.cr   [regbld ibd_tm11::CR ie] \
            i.bc   0xff00  \
            i.ba   0x8800  \
            o.sr   [regbld ibd_tm11::SR onl bot tur]  \
            o.cr   [regbld ibd_tm11::CR rdy ie] \
            o.bc   0xff00 \
            o.ba   0x8800



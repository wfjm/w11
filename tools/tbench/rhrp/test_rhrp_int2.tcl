# $Id: test_rhrp_int2.tcl 705 2015-07-26 21:25:42Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-07-25   704   1.0.1  tmpproc_dotest: use args rather opts
# 2015-05-20   692   1.0    Initial version
#
# Test interrupt response 
#  A: 

# ----------------------------------------------------------------------------
rlc log "test_rhrp_int2: test interrupt response for nested xfer+seek --------"
rlc log "  setup: unit 0-3: RP06(mol)"
package require ibd_rhrp
ibd_rhrp::setup

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

# de-configure all drives (and clear errros and reset vv)
$cpu cp -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 0] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS erp vv] \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 1] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS erp vv] \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 2] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS erp vv] \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 3] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS erp vv] 

# configure drives
$cpu cp -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 0] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS dpr mol] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RP06 \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 1] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS dpr mol] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RP06 \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 2] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS dpr mol] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RP06 \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 3] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS dpr mol] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RP06

# clear errors: cs1.tre=1 via unit 0
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_DCLR] \
        -wma  rpa.as  [regbld ibd_rhrp::AS u3 u2 u1 u0] \
        -rma  rpa.ds  -edata [regbld ibd_rhrp::DS dpr mol dry]

# do pack ack on all drives
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_PACK] \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_PACK] \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_PACK] \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 3}] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_PACK]

# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_rp.mac|
;
        .include  |lib/vec_cpucatch.mac|
; 
        . = 000254              ; setup RHRP interrupt vector
v..rp:  .word vh.rp
        .word cp.pr7
;
        . = 1000                ; data area
stack:  
ibuf:   .blkw   <3+1+<3*3>>     ; input buffer (3 for xfer; #seek; 3 per seek)
obuf:   .blkw   <<4*6>+<4*6>+1> ; output buffer
;
sdone:  .word   0               ; seek done
idone:  .word   0               ; interrupt done
apat:   .word   0               ; attn pattern
;
        . = 2000                ; code area
start:  spl     7               ; lock out interrupts
        clr     sdone           ; clear flags
        clr     idone
; 
        mov     #obuf,r5        ; clear obuf 
        mov     #8.,r2          ; clear 8 sections with 6 words
1$:     clr     (r5)+
        clr     (r5)+
        clr     (r5)+
        clr     (r5)+
        clr     (r5)+
        clr     (r5)+
        sob     r2,1$
        clr     (r5)+
; 
        mov     #obuf,r5        ; setup obuf pointer
        mov     #ibuf,r0        ; setup regs from ibuf
        clrb    @#rp.cs2        ;   cs2 (unit=0)
        mov     (r0)+,@#rp.da   ;   da
        mov     (r0)+,@#rp.dc   ;   dc
        mov     (r0)+,@#rp.cs1  ;   cs1
; 
        mov     #177000,(r5)+   ; tag: regs after xfer started
        mov     @#rp.cs1,(r5)+  ;   cs1
        mov     @#rp.cs2,(r5)+  ;   cs2
        mov     @#rp.er1,(r5)+  ;   er1
        mov     @#rp.ds,(r5)+   ;   ds
        mov     @#rp.as,(r5)+   ;   as
; 
        mov     #1,r2           ; next unit
        mov     #2,r3           ; next abit
        mov     (r0)+,r1        ; # of seeks
        beq     30$
;
20$:    movb    r2,@#rp.cs2     ;   cs2 (unit=i)
        mov     (r0)+,@#rp.da   ;   da
        mov     (r0)+,@#rp.dc   ;   dc
        mov     (r0)+,@#rp.cs1  ;   cs1
;
        mov     r2,(r5)
        add     #177100,(r5)+   ; tag: regs after seek started
        mov     @#rp.cs1,(r5)+  ;   cs1
        mov     @#rp.cs2,(r5)+  ;   cs2
        mov     @#rp.er1,(r5)+  ;   er1
        mov     @#rp.ds,(r5)+   ;   ds
        mov     @#rp.as,(r5)+   ;   as
;
        bis     r3,apat         ; build apat
        inc     r2              ; next unit
        asl     r3              ; next abit
;         
        sob     r1,20$
; 
30$:    inc     sdone           ; signal seeks queued
        spl     0               ; allow interrupts
wpnt:   wait

1$:     tst     idone           ; wait for interrupt
        beq     1$
        mov     #177777,(r5)+   ; tag: all done
        halt                    ; halt if done
stop:
; 

; RHRP interrupt handler
vh.rp:  clrb    @#rp.cs2        ;   cs2 (unit=0)
        mov     #177200,(r5)+   ; tag: regs after seek started
        mov     @#rp.cs1,(r5)+  ;   cs1
        mov     @#rp.cs2,(r5)+  ;   cs2
        mov     @#rp.er1,(r5)+  ;   er1
        mov     @#rp.ds,(r5)+   ;   ds
        mov     @#rp.as,r4      ;   
        mov     r4,(r5)+        ;   as
;
        mov     #3,r1           ; max # of seeks
        mov     #1,r2           ; next unit
        mov     #2,r3           ; next abit
; 
1$:     bit     r3,r4           ; bit set in as ?
        beq     2$
;
        movb    r2,@#rp.cs2     ;   cs2 (unit=i)
        mov     r2,(r5)
        add     #177300,(r5)+   ; tag: regs after seek started
        mov     @#rp.cs1,(r5)+  ;   cs1
        mov     @#rp.cs2,(r5)+  ;   cs2
        mov     @#rp.er1,(r5)+  ;   er1
        mov     @#rp.ds,(r5)+   ;   ds
        mov     r3,@#rp.as      ; clear abit in as
        mov     @#rp.as,(r5)+   ;   as
;         
2$:     inc     r2              ; next unit
        asl     r3              ; next abit
        sob     r1,1$
;
        inc     idone
        rti                     ; and return
}

##puts $lst

# define tmpproc for readback checks
proc tmpproc_dotest {cpu symName args} {
  upvar 1 $symName sym

  set tout 10.;                   # FIXME_code: parameter ??

# setup defs hash, first defaults, than write over concrete run values  
  args2opts opts {i.nseek  0 \
                  i.idly   0 }  {*}$args

  set fread [list func $ibd_rhrp::FUNC_READ]
  set fsear [list func $ibd_rhrp::FUNC_SEAR]
  set as  0

  # build ibuf
  set ibuf {}
  lappend ibuf 01 0100 [regbld ibd_rhrp::CS1 ie $fread go]
  lappend ibuf $opts(i.nseek)
  for {set i 1} {$i<=$opts(i.nseek)} {incr i} {
    set da [expr { 010 + $i}]
    set dc [expr {0100 + $i}]
    lappend ibuf $da $dc [regbld ibd_rhrp::CS1 ie $fsear go]
    set as [expr {$as | [expr {01 << $i} ] } ]
  }

  # setup idly, write ibuf, setup stack, and start cpu at start:
  $cpu cp -wibr rpa.cs1 [regbldkv ibd_rhrp::RCS1 \
                           val $opts(i.idly) func WIDLY ] \
          -wal   $sym(ibuf) \
          -bwm   $ibuf \
          -wsp   $sym(stack) \
          -stapc $sym(start)

  # here do minimal lam handling (harvest + send DONE)
  #   wait for interrupt
  #   and for sdone (all search issued flag) set
  rlc wtlam $tout apat
  for {set i 0} {$i<100} {incr i} {
    $cpu cp -wal   $sym(sdone) \
            -rmi   sdone
    if {$sdone} {break}
  }
  $cpu cp -attn \
          -wibr rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::RFUNC_DONE]

  # wait for halt
  $cpu wtcpu -reset $tout
  
  # check context
  $cpu cp -rpc   -edata $sym(stop) \
          -rsp   -edata $sym(stack) \
          -wal   $sym(idone) \
          -rmi   -edata 1 

  # check setup xfer
  set osxcs1 [regbld ibd_rhrp::CS1 dva ie $fread]
  set osxcs2 [regbld ibd_rhrp::CS2 or ir]
  set osxds  [regbld ibd_rhrp::DS  mol dpr vv]
  $cpu cp -wal   $sym(obuf) \
          -rmi   -edata 0177000 \
          -rmi   -edata $osxcs1 \
          -rmi   -edata $osxcs2 \
          -rmi   -edata 0 \
          -rmi   -edata $osxds  \
          -rmi   -edata 0

  # check setup search
  set mskcs1sc [rutil::com16 [regbld ibd_rhrp::CS1 sc]]
  for {set i 1} {$i<=$opts(i.nseek)} {incr i} {
    set osscs1 [regbld ibd_rhrp::CS1 dva ie $fsear]
    set osscs2 [regbld ibd_rhrp::CS2 or ir [list unit $i]]
    set ossds  [regbld ibd_rhrp::DS  pip mol dpr vv]
    $cpu cp -rmi   -edata [expr {0177100 + $i}] \
            -rmi   -edata $osscs1 $mskcs1sc\
            -rmi   -edata $osscs2 \
            -rmi   -edata 0 \
            -rmi   -edata $ossds  \
            -rmi   
  }

  # check interrupt xfer
  set sc [expr {$opts(i.nseek) > 0}]
  set oixcs1 [regbld ibd_rhrp::CS1 [list sc $sc] dva rdy $fread]
  set oixcs2 [regbld ibd_rhrp::CS2 or ir]
  set oixds  [regbld ibd_rhrp::DS  mol dpr dry vv]
  set oixas  $as
  $cpu cp -rmi   -edata 0177200 \
          -rmi   -edata $oixcs1 \
          -rmi   -edata $oixcs2 \
          -rmi   -edata 0 \
          -rmi   -edata $oixds  \
          -rmi   -edata $oixas 

  # check interrupt search
  set oisas  $as
  for {set i 1} {$i<=$opts(i.nseek)} {incr i} {
    set oiscs1 [regbld ibd_rhrp::CS1 [list sc $sc] dva rdy $fsear]
    set oiscs2 [regbld ibd_rhrp::CS2 or ir [list unit $i]]
    set oisds  [regbld ibd_rhrp::DS ata mol dpr dry vv]
    set oisas  [expr {$oisas & [expr {~(01<<$i)} ] }]
    $cpu cp -rmi   -edata [expr {0177300 + $i}] \
            -rmi   -edata $oiscs1 \
            -rmi   -edata $oiscs2 \
            -rmi   -edata 0 \
            -rmi   -edata $oisds  \
            -rmi   -edata $oisas
  }

  # ckeck end tag
  $cpu cp -rmi   -edata 0177777 

  return ""
}

# discard pending attn to be on save side
rlc wtlam 0.
rlc exec -attn

rlc log "  A1: test without search -----------------------------------"

tmpproc_dotest $cpu sym  i.nseek 0  i.idly  0

rlc log "  A2: test with 1 search ------------------------------------"

tmpproc_dotest $cpu sym  i.nseek 1  i.idly  10

rlc log "  A2: test with 2 search ------------------------------------"

tmpproc_dotest $cpu sym  i.nseek 2  i.idly  10

rlc log "  A2: test with 3 search ------------------------------------"

tmpproc_dotest $cpu sym  i.nseek 3  i.idly  10


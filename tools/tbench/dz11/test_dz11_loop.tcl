# $Id: test_dz11_loop.tcl 1365 2023-02-02 11:46:43Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-05-18  1150   1.0    Initial version
# 2019-05-11  1148   0.1    First draft
#
# Test DZ11 combined receiver + transmitter response

# ----------------------------------------------------------------------------
rlc log "test_dz11_loop: test dz11 receiver+transmit response ----------------"
package require ibd_dz11
if {![ibd_dz11::setup]} {
  rlc log "  test_dz11_loop-W: device not found, test aborted"
  return
}

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

set attndl  [expr {1<<$ibd_dz11::ANUM}]
set attncpu [expr {1<<$rw11::ANUM}]

# -- Section A ---------------------------------------------------------------
rlc log "  A1: init dz11 ---------------------------------------------"
# - issue csr.clr
# - remember 'awdth' retrieved from rcsr for later tests
# - set rlim's to 0, clear fifos
# - harvest any dangling attn
$cpu cp \
  -wma   dza.csr         [regbld ibd_dz11::CSR clr] \
  -ribr  dza.csr dzcntl \
  -wibr  dza.csr         [regbld ibd_dz11::RRLIMW {rrlim 0} {trlim 0} \
                            rcl tcl {func "SRLIM"}]
set awdth  [regget ibd_dz11::RCNTLR(awdth) $dzcntl]
rlc exec -attn 
rlc wtlam 0.

rlc log "  A2: backend -> cpu -> backend loop ------------------------"

# load test code
#   rx enable lines 1,3,5
#   store chars in line buffers
#   transmit all received buffers

$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_dz.mac|
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
;
        . = va.dzr               ; setup DZ11 receiver interrupt vector
        .word vh.dzr
        .word cp.pr7
;
        . = va.dzt               ; setup DZ11 transmitter interrupt vector
        .word vh.dzt
        .word cp.pr7
;
        . = 1000                ; code area
stack:
;
start:  spl     7
        mov     #<dz.tie!dz.rie!dz.mse>,@#dz.csr        ; start dz11
        mov     #<dz.rxo!dz.f96!dz.cl8!5>,@#dz.lpr      ; rxon line 5
        mov     #<dz.rxo!dz.f96!dz.cl8!3>,@#dz.lpr      ; rxon line 3
        mov     #<dz.rxo!dz.f96!dz.cl8!1>,@#dz.lpr      ; rxon line 1
        spl     0
1$:     wait
        br      1$
;
vh.dzr: mov     @#dz.rbu,r0             ; read rbuf
        bmi     1$                      ; valid ?
        rti
1$:     inc     rxcnt                   ; count chars
        mov     r0,r1
        swab    r1
        bic     #177770,r1              ; line number
        asl     r1                      ; word offset
        mov     wrptr(r1),r2            ; wr ptr to line buffer
        movb    r0,(r2)+                ; store
        mov     r2,wrptr(r1)
        asr     r1                      ; byte offset again
        bisb    lpat(r1),@#dz.len       ; tx enable line
        br      vh.dzr                  ; go for next
;
vh.dzt: movb    @#dz.csr+1,r1           ; get tline
        bic     #177770,r1
        asl     r1                      ; word offset
        mov     rdptr(r1),r2            ; rd ptr to line buffer
        cmp     r2,wrptr(r1)            ; chars to go ?
        bne     1$
        asr     r1                      ; if not back to byte offset
        bicb    lpat(r1),@#dz.len       ; tx disable line
        rti
1$:     inc     txcnt                   ; count chars
        movb    (r2)+,@#dz.tbu          ; send char
        mov     r2,rdptr(r1)
        cmp     txcnt,#18.
        beq     2$
        rti
2$:     halt
stop:
;
rxcnt:  .word   0
txcnt:  .word   0
lpat:   .byte   ^b00000001,^b00000010,^b00000100,^b00001000
        .byte   ^b00010000,^b00100000,^b01000000,^b10000000
rdptr:  .word   line0,line1,line2,line3,line4,line5,line6,line7
wrptr:  .word   line0,line1,line2,line3,line4,line5,line6,line7
line0:  .blkb   32.
line1:  .blkb   32.
line2:  .blkb   32.
line3:  .blkb   32.
line4:  .blkb   32.
line5:  .blkb   32.
line6:  .blkb   32.
line7:  .blkb   32.

}
#puts $lst

rw11::asmrun  $cpu sym
$cpu cp \
  -wbibr dza.tdr [list \
                    [regbld ibd_dz11::RFDAT {line 1} {data 0x11} ] \
                    [regbld ibd_dz11::RFDAT {line 3} {data 0x31} ] \
                    [regbld ibd_dz11::RFDAT {line 5} {data 0x51} ] \
                    [regbld ibd_dz11::RFDAT {line 1} {data 0x12} ] \
                    [regbld ibd_dz11::RFDAT {line 3} {data 0x32} ]] 
$cpu cp \
  -wbibr dza.tdr [list \
                    [regbld ibd_dz11::RFDAT {line 5} {data 0x52} ] \
                    [regbld ibd_dz11::RFDAT {line 1} {data 0x13} ] \
                    [regbld ibd_dz11::RFDAT {line 3} {data 0x33} ] \
                    [regbld ibd_dz11::RFDAT {line 5} {data 0x53} ] \
                    [regbld ibd_dz11::RFDAT {line 1} {data 0x14} ]] 
$cpu cp \
  -wbibr dza.tdr [list \
                    [regbld ibd_dz11::RFDAT {line 3} {data 0x34} ] \
                    [regbld ibd_dz11::RFDAT {line 5} {data 0x54} ] \
                    [regbld ibd_dz11::RFDAT {line 1} {data 0x15} ] \
                    [regbld ibd_dz11::RFDAT {line 3} {data 0x35} ] \
                    [regbld ibd_dz11::RFDAT {line 5} {data 0x55} ] \
                    [regbld ibd_dz11::RFDAT {line 1} {data 0x16} ] \
                    [regbld ibd_dz11::RFDAT {line 3} {data 0x36} ] \
                    [regbld ibd_dz11::RFDAT {line 5} {data 0x56} ]] 
rw11::asmwait $cpu sym
#puts [rw11::cml $cpu]

# expect as data
#   4 cal  message (csr changed, mse set; 3 times rxon update)
#  18 char message (in random order)
$cpu cp \
  -ribr  dza.tcr -edata [regbldkv ibd_dz11::RFUSE rfuse 0 tfuse 22] \
  -rbibr dza.tdr 4 -edata [list \
              [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 1 \
                 line $ibd_dz11::CAL_CSR  data [regbld ibd_dz11::CSR mse]] \
              [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 1 \
                 line $ibd_dz11::CAL_RXON data 040] \
              [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 1 \
                 line $ibd_dz11::CAL_RXON data 050] \
              [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 1 \
                 line $ibd_dz11::CAL_RXON data 052] \
              ] \
  -rbibr dza.tdr 18 tdata

# setup line - char list
set texpect {
  {}
  {0x11 0x12 0x13 0x14 0x15 0x16}
  {}
  {0x31 0x32 0x33 0x34 0x35 0x36}
  {}
  {0x51 0x52 0x53 0x54 0x55 0x56}
  {}
  {}
}
set tcount {0 0 0 0 0 0 0 0}

foreach tword $tdata {
  #puts [regtxt ibd_dz11::RFDAT $tword]
  set line [regget ibd_dz11::RFDAT(line) $tword]
  set data [regget ibd_dz11::RFDAT(data) $tword]
  set cind [lindex $tcount $line]
  set cexp [lindex $texpect $line $cind]
  if {$data != $cexp } {
    rlc log "FAIL: mismatch for line=$line cind=$cind: got $data expect $cexp"
    rlc errcnt -inc
  }
  lset tcount $line [expr {$cind + 1}]
}

# -- Section B ---------------------------------------------------------------
rlc log "  B1: cpu -> cpu loop using maintenance mode ----------------"

# re-init dz11
$cpu cp \
  -wma   dza.csr         [regbld ibd_dz11::CSR clr] \
  -wibr  dza.csr         [regbld ibd_dz11::RCNTLW rcl tcl]
# harvest any dangling attn
rlc exec -attn 
rlc wtlam 0.

# load test code
#   enable maintenance mode
#   rx enable lines 6,5,3,1
#   tx enable lines 6,5,3,1
#   send a,b         --> to line 6
#   send A,B,C,D,E,F --> to line 5
#   send 1,2,3       --> to line 3
#   send 7,8         --> to line 1
#   check received agains send chars

$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_dz.mac|
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
;
        . = va.dzr               ; setup DZ11 receiver interrupt vector
        .word vh.dzr
        .word cp.pr7
;
        . = va.dzt               ; setup DZ11 transmitter interrupt vector
        .word vh.dzt
        .word cp.pr7
;
        . = 1000                ; code area
stack:
;
start:  spl     7
        mov     #<dz.tie!dz.rie!dz.mse!dz.mai>,@#dz.csr ; start dz11
        movb    #^b01101010,@#dz.len                    ; tx ena lines 6,5,3,1
        mov     #<dz.rxo!dz.f96!dz.cl8!6>,@#dz.lpr      ; rxon line 6
        mov     #<dz.rxo!dz.f96!dz.cl8!5>,@#dz.lpr      ; rxon line 5
        mov     #<dz.rxo!dz.f96!dz.cl8!3>,@#dz.lpr      ; rxon line 3
        mov     #<dz.rxo!dz.f96!dz.cl8!1>,@#dz.lpr      ; rxon line 1
        spl     0
1$:     wait
        br      1$
;
vh.dzt: movb    @#dz.csr+1,r1           ; get tline
        bic     #177770,r1
        asl     r1                      ; word offset
        mov     tlptr(r1),r2            ; tx ptr to char for line
        tstb    (r2)                    ; end of transmission ?
        bne     1$
        asr     r1                      ; byte offset again
        bicb    lpat(r1),@#dz.len       ; and disable line
        rti

1$:     movb    (r2)+,@#dz.tbu          ; send next char
        mov     r2,tlptr(r1)
        rti

vh.dzr: mov     @#dz.rbu,r0             ; read rbuf
        bmi     1$                      ; valid ?
        cmp     #nchar,rcnt             ; all received ?
        beq     3$                      ; then quit
        rti
1$:     inc     rcnt                    ; count chars
        mov     r0,r1
        swab    r1
        bic     #177770,r1              ; line number
        asl     r1                      ; word offset
        mov     rlptr(r1),r2            ; rx ptr to char for line
        cmpb    r0,(r2)+                ; match ?
        beq     2$
        halt                            ; if not error halt
2$:     mov     r2,rlptr(r1)
        br      vh.dzr                  ; go for next
;
3$:     halt
stop:
;
lpat:   .byte   ^b00000001,^b00000010,^b00000100,^b00001000
        .byte   ^b00010000,^b00100000,^b01000000,^b10000000
tlptr:  .word   line0,line1,line2,line3,line4,line5,line6,line7
line0:  .asciz  //
line1:  .asciz  /78/
line2:  .asciz  //
line3:  .asciz  /123/
line4:  .asciz  //
line5:  .asciz  /ABCDEF/
line6:  .asciz  /ab/
line7:  .asciz  //
linee:
        nchar = linee - line0 - 8.
;
        .even
rcnt:   .word   0
rlptr:  .word   line0,line1,line2,line3,line4,line5,line6,line7

}
#puts $lst

rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym
#puts [ibd_dz11::rdump] 
#puts [rw11::cml $cpu]

# harvest any dangling attn
rlc exec -attn 
rlc wtlam 0.

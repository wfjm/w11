# $Id: test_dz11_tx.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-05-18  1150   1.0    Initial version
# 2019-05-04  1146   0.1    First draft
#
# Test DZ11 transmitter response

# ----------------------------------------------------------------------------
rlc log "test_dz11_tx: test dz11 transmitter data path -----------------------"
package require ibd_dz11
if {![ibd_dz11::setup]} {
  rlc log "  test_dz11_tx-W: device not found, test aborted"
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

# -- Section B ---------------------------------------------------------------
rlc log "  B1: test csr.tie and basic interrupt response -------------"
# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_dz.mac|
        . = va.dzt              ; setup DZ11 transmitter interrupt vector
        .word vh.dzt
        .word cp.pr7
;
        . = 1000                ; code area
stack:
;
; use in following mov to psw instead of spl to allow immediate interrupt
;
start:  spl     7                       ;;; lock-out interrupts
        movb    #^b00000001,@#dz.len    ;;; enable line 0
        mov     #<dz.tie!dz.mse>,@#dz.csr ;;; start dz11
        mov     #cp.pr6,@#cp.psw        ;;; allow pri=7
        mov     #cp.pr5,@#cp.psw        ;;; allow pri=6
        mov     #cp.pr4,@#cp.psw        ;;; allow pri=5
        mov     #cp.pr3,@#cp.psw        ;;; allow pri=4
        mov     #cp.pr2,@#cp.psw        ;;; allow pri=3
        mov     #cp.pr1,@#cp.psw        ;;; allow pri=2
        mov     #cp.pr0,@#cp.psw        ;;; allow pri=1
        halt                            ;;;
;
vh.dzt: halt                            ;;; dzt handler
stop:
}

# check that interrupt done, and pushed psw has pri=4 (device is pri=5)
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym
rw11::asmtreg $cpu sp [expr {$sym(stack)-4}]
rw11::asmtmem $cpu [expr {$sym(stack)-2}] [list [regbld rw11::PSW {pri 4}]]

# check that cal message for csr.mse 0->1 change seen
$cpu cp \
  -ribr  dza.tcr -edata [regbldkv ibd_dz11::RFUSE rfuse 0 tfuse 1] \
  -ribr  dza.tdr -edata [regbldkv ibd_dz11::RFDAT val 1 last 1 cal 1 \
                   line $ibd_dz11::CAL_CSR data [regbld ibd_dz11::CSR mse]]

rlc log "  B2: one line at a time ------------------------------------"

# re-init dz11
$cpu cp \
  -wma   dza.csr         [regbld ibd_dz11::CSR clr] \
  -wibr  dza.csr         [regbld ibd_dz11::RCNTLW rcl tcl]
# harvest any dangling attn
rlc exec -attn 
rlc wtlam 0.

# load test code
#   send a,b,c  --> to line 0
#   send A,B,C  --> to line 1
#   send 0,1,2  --> to line 2
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_dz.mac|
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
;
        . = va.dzt               ; setup DZ11 transmitter interrupt vector
        .word vh.dzt
        .word cp.pr7
;
        . = 1000                ; code area
stack:
;
start:  spl     7
        movb    #^b00000001,@#dz.len    ; enable line 0
        mov     #tbl,r5                 ; setup table pointer
        mov     #<dz.tie!dz.mse>,@#dz.csr ; start dz11
        spl     0
1$:     wait
        br      1$
;
vh.dzt: tstb    (r5)+                   ;;; action type ?
        bne     1$
        movb    (r5)+,@#dz.tbu          ;;; write char
        rti
1$:     movb    (r5)+,@#dz.len          ;;; select new line
        beq     2$                      ;;; end token ?
        rti
2$:     halt
stop:
;
tbl:    .byte   0,'a                    ; send a -> line 0
        .byte   0,'b                    ; send b -> line 0
        .byte   1,^b00000010            ; switch to line 1
        .byte   0,'A                    ; send A -> line 1
        .byte   0,'B                    ; send B -> line 1
        .byte   1,^b00000100            ; switch to line 2
        .byte   0,'0                    ; send 0 -> line 2
        .byte   0,'1                    ; send 1 -> line 2
        .byte   0,'2                    ; send 2 -> line 2
        .byte   1,^b00000001            ; switch to line 0
        .byte   0,'c                    ; send c -> line 0
        .byte   1,^b00000010            ; switch to line 1
        .byte   0,'C                    ; send C -> line 1
        .byte   1,0                     ; end
}
#puts $lst

rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym
#puts [rw11::cml $cpu]

# expect as data
#   1 cal  message (csr changed, mse set)
#   9 char message (in order, since one line at a time)
set tdata [list \
             [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 1 \
                line $ibd_dz11::CAL_CSR data [regbld ibd_dz11::CSR mse]] \
             [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 0 line 0 data 0x61] \
             [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 0 line 0 data 0x62] \
             [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 0 line 1 data 0x41] \
             [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 0 line 1 data 0x42] \
             [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 0 line 2 data 0x30] \
             [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 0 line 2 data 0x31] \
             [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 0 line 2 data 0x32] \
             [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 0 line 0 data 0x63] \
             [regbldkv ibd_dz11::RFDAT val 1 last 1 cal 0 line 1 data 0x43] \
          ]

$cpu cp \
  -ribr  dza.tcr -edata [regbldkv ibd_dz11::RFUSE rfuse 0 \
                                                  tfuse [llength $tdata]] \
             -rbibr dza.tdr [llength $tdata] -edata $tdata

rlc log "  B3: up to 4 lines enabled ---------------------------------"
# re-init dz11
$cpu cp \
  -wma   dza.csr         [regbld ibd_dz11::CSR clr] \
  -wibr  dza.csr         [regbld ibd_dz11::RCNTLW rcl tcl]
# harvest any dangling attn
rlc exec -attn 
rlc wtlam 0.

# load test code
#   tx enable lines 6,5,3,1
#   send a,b         --> to line 6
#   send A,B,C,D,E,F --> to line 5
#   send 1,2,3       --> to line 3
#   send 7,8         --> to line 1

$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_dz.mac|
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|
;
        . = va.dzt               ; setup DZ11 transmitter interrupt vector
        .word vh.dzt
        .word cp.pr7
;
        . = 1000                ; code area
stack:
;
start:  spl     7
        movb    #^b01101010,@#dz.len    ; enable lines 6,5,3,1
        mov     #<dz.tie!dz.mse>,@#dz.csr ; start dz11
        spl     0
1$:     wait
        br      1$
;
vh.dzt: movb    @#dz.csr+1,r0   ; get tline
        bic     #177770,r0
        asl     r0              ; word offset
        mov     lptr(r0),r1     ; ptr to char for line
        tstb    (r1)            ; end of transmission ?
        bne     1$
        asr     r0              ; byte offset again
        bicb    lpat(r0),@#dz.len  ; and tx disable line
        tstb    @#dz.len           ; all disabled ?
        beq     2$
        rti

1$:     movb    (r1)+,@#dz.tbu  ; send next char
        mov     r1,lptr(r0)
        rti

2$:     halt
stop:
;
lptr:   .word   line0,line1,line2,line3,line4,line5,line6,line7
lpat:   .byte   ^b00000001,^b00000010,^b00000100,^b00001000
        .byte   ^b00010000,^b00100000,^b01000000,^b10000000
line0:  .asciz  //
line1:  .asciz  /78/
line2:  .asciz  //
line3:  .asciz  /123/
line4:  .asciz  //
line5:  .asciz  /ABCDEF/
line6:  .asciz  /ab/
line7:  .asciz  //
}
#puts $lst

rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym
#puts [rw11::cml $cpu]

# expect as data
#   1 cal  message (csr changed, mse set)
#  13 char message (in random order)
$cpu cp \
  -ribr  dza.tcr -edata [regbldkv ibd_dz11::RFUSE rfuse 0 tfuse 14] \
  -ribr  dza.tdr -edata [regbldkv ibd_dz11::RFDAT val 1 last 0 cal 1 \
                line $ibd_dz11::CAL_CSR data [regbld ibd_dz11::CSR mse]] \
  -rbibr dza.tdr 13 tdata

# check char message, look only at line and data
set texpect {
  {}
  {0x37 0x38}
  {}
  {0x31 0x32 0x33}
  {}
  {0x41 0x42 0x43 0x44 0x45 0x46}
  {0x61 0x62}
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

# harvest any dangling attn
rlc exec -attn 
rlc wtlam 0.

# $Id: test_deuna_int.tcl 874 2017-04-14 17:53:07Z mueller $
#
# Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2017-04-14   874   1.0    Initial version
# 2017-02-03   848   0.1    First draft
#
# Test interrupt response 

# ----------------------------------------------------------------------------
rlc log "test_deuna_int: test interrupt response -----------------------------"
package require ibd_deuna
if {![ibd_deuna::setup]} {
  rlc log "  test_deuna_regs-W: device not found, test aborted"
  return
}

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_xu.mac|
;
        .include  |lib/vec_cpucatch.mac|
; 
        . = 000120              ; setup DEUNA interrupt vector catcher
v..xu:  .word vh.xu
        .word cp.pr7
;
        . = 1000                ; data area
stack:
; 
start:                          ; started with pr7, interrupts locked out
        clr     r2
        clr     r3
        clr     r4
        spl     0               ; allow interrupts
        nop                     ; will be executed (11/70...)
        nop                     ; interrupt here
        nop                     ; to be sure ...
        nop
        halt

; DEUNA interrupt handler
;     r0    in: pr0 clear mask after 1st interrupt
;     r1    in: pr0 clear mask after 2nd interrupt
;     r2    out: pr0 after 1st interrupt
;     r3    out: pr0 after 2nd interrupt
;     r4    out: interrupt count
;
vh.xu:  tst     r4              ; 1st or 2nd interrupt ?
        bne     100$
                                ; handle 1st interrupt
        inc     r4              ; count interrupts
        mov     @#xu.pr0,r2     ; get state
        mov     r0,r5
        swab    r5
        movb    r5,@#xu.pr0+1   ; clear interrupt
        rti                     ; and return

100$:                           ; handle 2nd interrupt
        cmp     r4,#2           ; check for unexpected re-interrupt
        bge     200$
        inc     r4              ; count interrupts
        mov     @#xu.pr0,r3     ; get state
        mov     r1,r5
        swab    r5
        movb    r5,@#xu.pr0+1   ; clear interrupt
        rti                     ; and return

200$:                           ; unexpected re-interrupt
        halt
}

##puts $lst

# define tmpproc for doing checks
proc tmpproc_dotest {cpu symName args} {
  upvar 1 $symName sym
  args2opts opts  {i.pr0    0 \
                   i.r0     0 \
                   i.r1     0 \
                   o.r2     0 \
                   o.r3     0 \
                   o.r4     0 } {*}$args

  $cpu cp -wibr xua.pr0 $opts(i.pr0)

  rw11::asmrun  $cpu sym r0 $opts(i.r0) \
                         r1 $opts(i.r1) \
                         ps [regbld rw11::PSW {pri 7}]
  rw11::asmwait $cpu sym 
  rw11::asmtreg $cpu     r2 $opts(o.r2) \
                         r3 $opts(o.r3) \
                         r4 $opts(o.r4) \
                         sp $sym(stack)
  return ""
}

# -- Section A ---------------------------------------------------------------
rlc log "  A1: enable interrupt --------------------------------------"
# Note: changing inte sets DNI !

$cpu cp -wma  xua.pr0 [regbld ibd_deuna::PR0 inte] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 dni intr inte] \
        -wma  xua.pr0 [regbld ibd_deuna::PR0 dni inte] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 inte]

# -- Section B ---------------------------------------------------------------
rlc log "  B1: test RXI interrupt ------------------------------------"

tmpproc_dotest $cpu sym  i.pr0 [regbld ibd_deuna::PR0RW rxi] \
                         i.r0  [regbld ibd_deuna::PR0   rxi] \
                         o.r2  [regbld ibd_deuna::PR0   rxi intr inte] \
                         o.r4  1

rlc log "  B2: test TXI interrupt ------------------------------------"

tmpproc_dotest $cpu sym  i.pr0 [regbld ibd_deuna::PR0RW txi] \
                         i.r0  [regbld ibd_deuna::PR0   txi] \
                         o.r2  [regbld ibd_deuna::PR0   txi intr inte] \
                         o.r4  1

rlc log "  B3: test RXI+TXI interrupt --------------------------------"

tmpproc_dotest $cpu sym  i.pr0 [regbld ibd_deuna::PR0RW rxi txi] \
                         i.r0  [regbld ibd_deuna::PR0   rxi] \
                         i.r1  [regbld ibd_deuna::PR0   txi] \
                         o.r2  [regbld ibd_deuna::PR0   rxi txi intr inte] \
                         o.r3  [regbld ibd_deuna::PR0   txi intr inte] \
                         o.r4  2

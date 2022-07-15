# $Id: test_w11a_cpuerr.tcl 1254 2022-07-13 06:16:19Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2016-12-27   831   1.0    Initial version
#
# Test cpuerr register
#

# ----------------------------------------------------------------------------
rlc log "test_w11a_cpuerr: test cpuerr register"
rlc log "  test basic CPUERR semantics"

$cpu ldasm -lst lst -sym sym {
        .include        |lib/defs_cpu.mac|
        .include        |lib/defs_reg70.mac|
        .include        |lib/defs_mmu.mac|
;
        .include        |lib/vec_cpucatch.mac|
;
        . = 1000
stack:
start:
;
; test 001: first test that any write will clear cpuerr ----------------------
; that test also conveniently erases any pre-history
;
        mov     #177777,@#cpuerr        ; clear cpuerr
        mov     #001,(r5)+              ; tag
        mov     @#cpuerr,(r5)+          ; val
;
; test 002: odd address abort, will set bit cp.aer ---------------------------
;
        mov     @#v..iit,saviit         ; save old handler
        mov     #h.iit,@#v..iit         ; setup handler
        mov     #t.002,r4               ; setup continuation address
        mov     #1,r0                   ; r0 points to odd address
        tst     (r0)                    ; access 
                                        ; !! will trap to 004 and set 000100 !!
        halt                            ; blocker
t.002:
;
; test 003: clear cpuerr again (now it's really set) -------------------------
;
        mov     #177777,@#cpuerr        ; clear cpuerr
        mov     #003,(r5)+              ; tag
        mov     @#cpuerr,(r5)+          ; val
;
; test 004: non-existent memory abort, will set bit cp.nxm -------------------
;
; The address space just below the I/O page is never accessible in the
; w11 (the 11/70 has ubmap window in this addess space).
; So setup MMU kernel I space AR(6) to point to the 8 kbyte below I/O page
; don't clear CPUERR at end of test ! 
;
        jsr     pc, mminki              ; init MMU, kernel I space only
        mov     #177400,@#kipar+014     ; kipar(6): to page below I/O page
        mov     #m3.e22,@#ssr3          ; enable 22bit
        mov     #m0.ena,@#ssr0          ; enable MMU
;
        mov     #t.004,r4               ; setup continuation address
        mov     #140000,r0              ; r0 points to non-existent memory 
        tst     (r0)                    ; access 
                                        ; !! will trap to 004 and set 000040 !!
        halt                            ; blocker
t.004:  clr     @#ssr0                  ; disable MMU
;
; test 005: I/O bus timeout abort; will set bit cp.ito -----------------------
;
; The lowest I/O page address 160000 not occupied by a device in the w11.
; Since CPUERR wasn't cleared after previous test the error bits will
; accumulate
;
        mov     #t.005,r4               ; setup continuation address
        mov     #160000,r0              ; r0 points to non-existent device 
        tst     (r0)                    ; access 
                                        ; !! will trap to 004 and set 000020 !!
        halt                            ; blocker
t.005:
;
; test 006: HALT in user mode; will set bit cp.hlt ---------------------------
;
        mov     #h.hlt,@#v..iit         ; setup handler
        mov     #cp.cmu!cp.pmu,@#cp.psw    ; psw:  cmode=pmode=11 (user)
        mov     #t.006,r4               ; setup continuation address
1$:     halt
        br      1$                      ; blocker
t.006:  
;  clear cpuerr again
        mov     #177777,@#cpuerr        ; clear cpuerr
        mov     #006,(r5)+              ; tag
        mov     @#cpuerr,(r5)+          ; val
;
; test 007: yellow stack trap; will set bit cp.ysv ---------------------------
;
        mov     #h.iit,@#v..iit         ; setup handler
        mov     #t.007,r4               ; setup continuation address
        mov     #000400,sp              ; set stack into 'yellow' zone
        clr     -(sp)                   ; and push to stack
                                        ; push will be done plus a trap !
t.007:
;
; test 010: 2nd yellow stack trap with CPUERR set should *not* trap ----------
;
        mov     saviit,@#v..iit         ; restore blocker handler
        clr     -(sp)                   ; and push to stack
                                        ; push will be done and no trap !
        mov     #010,(r5)+              ; tag
        mov     sp,(r5)+                ; val
; clear cpuerr again
        mov     #177777,@#cpuerr        ; clear cpuerr
        mov     #010,(r5)+              ; tag
        mov     @#cpuerr,(r5)+          ; val
;
; test 011: red stack trap from odd stack; will set bit cp.aer and cp.rsv ----
;
        mov     #h.rsv,@#v..iit         ; setup handler (will also reset stack)
        mov     #t.011,r4               ; setup continuation address
        mov     #001001,sp              ; set stack odd kernel stack
        clr     -(sp)                   ; and push to stack
                                        ; cause 'red stack' and set SP=004
t.011:
;  clear cpuerr again
        mov     #177777,@#cpuerr        ; clear cpuerr
        mov     #011,(r5)+              ; tag
        mov     @#cpuerr,(r5)+          ; val
; 
; end of tests ---------------------------------------------------------------
; 
        halt
stop:
;
h.iit:  mov     r4,(r5)+                ; tag
        mov     @#cpuerr,(r5)+          ; val
        mov     r4,(sp)                 ; set return PC
        rti
;
h.hlt:  mov     r4,(r5)+                ; tag
        mov     @#cpuerr,(r5)+          ; val
        mov     r4,(sp)                 ; set return PC
        clr     2(sp)                   ; set return PS (kernel mode again)
        rti
;
h.rsv:  mov     r4,(r5)+                ; tag
        mov     @#cpuerr,(r5)+          ; val
        mov     #1000,sp                ; reset stack
        clr     -(sp)                   ; PS = kernel mode
        mov     r4,-(sp)                ; PC = continuation address
        rti
;
saviit: .word   0
data:   .blkw   12.*2.
        .word   177777
;
; support procedures
;
        .include        |lib/mminki.mac|

}

# puts $lst
# parray sym

# code register pre/post conditions beyond defaults
#   r5   #data   -> #data+12*2*2
rw11::asmrun  $cpu sym r5 $sym(data)
rw11::asmwait $cpu sym 

rw11::asmtreg $cpu     r1 0 \
                       r2 0 \
                       r3 0 \
                       r5 [expr {$sym(data) + 12*2*2}] \
                       sp $sym(stack)
# data:    tag      val pairs
rw11::asmtmem $cpu $sym(data) \
  [list 001          0000000 \
        $sym(t.002)  [regbld rw11::CPUERR adderr] \
        003          0000000 \
        $sym(t.004)  [regbld rw11::CPUERR nxm] \
        $sym(t.005)  [regbld rw11::CPUERR nxm iobto] \
        $sym(t.006)  0000260 \
        006          0000000 \
        $sym(t.007)  [regbld rw11::CPUERR ysv] \
        010          0000374 \
        010          0000000 \
        $sym(t.011)  [regbld rw11::CPUERR adderr rsv] \
        011          0000000 \
        0177777 ]

# ----------------------------------------------------------------------------
rlc log "  test basic CPUERR reset via creset"

# use minmal code to set CPUERR: odd address abort against vector catcher
$cpu ldasm -lst lst -sym sym {
        . = 000004
v..iit: .word   v..iit+2        ; vec   4 
        .word   0
stop:
;
        . = 1000
stack:
start:
;
        mov     #1,r0                   ; r0 points to odd address
        tst     (r0)                    ; access 
}

rw11::asmrun  $cpu sym 
rw11::asmwait $cpu sym 

rw11::asmtreg $cpu     r1 0 \
                       r2 0 \
                       r3 0 \
                       r5 0 \
                       sp [expr $sym(stack) - 4]

# now test whether creset clears CPUERR
rw11::asmtmem $cpu $rw11::A_CPUERR [regbld rw11::CPUERR adderr]
cpu0 cp -creset
rw11::asmtmem $cpu $rw11::A_CPUERR 0

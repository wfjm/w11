# $Id: test_cmon_logs.tcl 895 2017-05-07 07:38:47Z mueller $
#
# Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2017-04-23   885   2.0    adopt to revised interface
# 2015-08-02   707   1.0    Initial version
#
# Test cm_print

# ----------------------------------------------------------------------------
rlc log "test_cmon_logs: test cmon logs (cm_print) ---------------------------"

if {[$cpu get hascmon] == 0} {
  rlc log "  test_cmon_logs-W: no cmon unit found, test aborted"
  return
}

# reset cmon
# reset cmon
$cpu cp \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "STA"}] \
  -wreg cm.cntl [regbld rw11::CM_CNTL {func "STO"}] \
  -rreg cm.cntl -edata 0

# define tmpproc for executing tests
proc tmpproc_dotest {cpu code tname} {

  $cpu ldasm -lst lst -sym sym $code

  foreach imode {0 1} {
    $cpu cp -creset
    rw11::cm_start $cpu imode $imode mwsup 1
    rw11::asmrun  $cpu sym
    rw11::asmwait $cpu sym 
    rw11::cm_stop $cpu
    set cmraw [rw11::cm_read $cpu]
    set cmprt [rw11::cm_print $cmraw]
    set fnam "test_cmon_${tname}_imode${imode}.log"
    tofile $fnam $cmprt
  }
  return
}

# -- Section A ---------------------------------------------------------------
rlc log "  A: basic instructions -------------------------------------"
rlc log "    A1: opg_reg: basic register - register -------------"

set code {
        . = 1000
start:  clr     r0              ; 000000*
        inc     r0              ; 000001*
        mov     r0,r1           ; 000001  000001*
        mov     r0,r2           ; 000001  000001  000001*
        asl     r2              ; 000001  000001  000002*
        neg     r1              ; 000001  177777* 000002
        clc                     ; c = 0
        rol     r1              ; 000001  177776* 000002  c = 1
        ror     r2              ; 000001  177776  100001* c = 0
        mov     r2,r3           ; 000001  177776  100001  100001*
        com     r2              ; 000001  177776  077776* 100001
        asr     r3              ; 000001  177776  077776  140000*
        mov     r3,r4           ; 000001  177776  077776  140000  140000*
        swab    r4              ; 000001  177776  077776  140000  000300*
        bis     r3,r4           ; 000001  177776  077776  140000  140300*
        bic     r3,r1           ; 000001  037776* 077776  140000  140300
        dec     r1              ; 000001  037775* 077776  140000  140300
        sub     r0,r2           ; 000001  037775* 077775  140000  140300
        add     r0,r4           ; 000001  037775* 077775  140000  140301*
        xor     r3,r4           ; 000001  037775* 077775  140000  000301*
        halt
stop:
}

tmpproc_dotest $cpu $code opg_reg

# -- ------- A2 -----------------------------------------------------------
rlc log "    A2: mov_srcr: mov and srcr chain -------------------"

set code {
        . = 1000
start:  nop
        clr     r0              ; m=0,rx; 
        inc     r0              ; m=0,rx;
        mov     r0,r1           ; m=0,rx;
        mov     #a,r2           ; m=2,pc; r2<=a
        mov     #pa,r3          ; m=2,pc; r3<=pa
        mov     (r2)+,r4        ; m=2,rx; read a; r2->b
        mov     (r2),r4         ; m=1,rx; read b;
        mov     -(r2),r4        ; m=4,rx; read a; r2->a
        mov     @(r3)+,r4       ; m=3,rx; read a; r3->pb
        mov     @-(r3),r4       ; m=5,rx; read a; r3->pa
        mov     a,r4            ; m=6,pc; read a;
        mov     @pb,r4          ; m=7,pc; read b;
        mov     @#a,r4          ; m=3,pc; read a;
        mov     2(r2),r4        ; m=6,rx; read b (r2->a)
        mov     @2(r3),r4       ; m=7,rx; read b (r3->pa)
        halt
stop:
;
a:      .word   123
b:      .word   234
pa:     .word   a
pb:     .word   b
}

tmpproc_dotest $cpu $code mov_srcr

# -- ------- A3 -----------------------------------------------------------
rlc log "    A3: mov_dstw: mov and dstw chain -------------------"

set code {
        . = 1000
start:  mov     #123,r0
        mov     #234,r1
        mov     #a,r2           ; m=2,pc; r2<=a
        mov     #pa,r3          ; m=2,pc; r3<=pa
        mov     r0,(r2)+        ; m=2,rx; write a; r2->b
        mov     r0,(r2)         ; m=1,rx; write b;
        mov     r1,-(r2)        ; m=4,rx; write a; r2->a
        mov     r0,@(r3)+       ; m=3,rx; write a; r3->pb
        mov     r1,@-(r3)       ; m=5,rx; write a; r3->pa
        mov     r0,a            ; m=6,pc; write a;
        mov     r1,@pb          ; m=7,pc; write b;
        mov     r1,@#a          ; m=3,pc; write a;
        mov     r0,2(r2)        ; m=6,rx; write b (r2->a)
        mov     r1,@2(r3)       ; m=7,rx; write b (r3->pa)
        halt
stop:
;
a:      .word   0
b:      .word   0
pa:     .word   a
pb:     .word   b
}

tmpproc_dotest $cpu $code mov_dstw

# -- ------- A4 -----------------------------------------------------------
rlc log "    A4: cmp_dstr: cmp and dstr chain -------------------"

set code {
        . = 1000
start:  mov     #000001,r0
        mov     #177777,r1
        mov     #a,r2
        mov     #pa,r3
        cmp     r0,(r2)+        ; m=2,rx; read a; r2->b
        cmp     r1,(r2)         ; m=1,rx; read b;
        cmp     r0,-(r2)        ; m=4,rx; read a; r2->a
        cmp     r0,@(r3)+       ; m=3,rx; read a; r3->pb
        cmp     r0,@-(r3)       ; m=5,rx; read a; r3->pa
        cmp     r0,a            ; m=6,pc; read a;
        cmp     r1,@pb          ; m=7,pc; read b;
        cmp     r0,#000001      ; m=2,pc; read const
        cmp     r0,@#a          ; m=3,pc; read a;
        cmp     r1,2(r2)        ; m=6,rx; read b (r2->a)
        cmp     r1,@2(r3)       ; m=7,rx; read b (r3->pa)
        halt
stop:
;
a:      .word   000001
b:      .word   177777
pa:     .word   a
pb:     .word   b
}

tmpproc_dotest $cpu $code cmp_dstr

# -- ------- A5 -----------------------------------------------------------
rlc log "    A5: add_dstr: add and dstr chain, test r-m-w -------"

set code {
        . = 1000
start:  mov     #000123,a
        mov     #000234,b
        mov     #000001,r0
        mov     #177777,r1
        mov     #a,r2
        mov     #pa,r3
        add     r0,(r2)+        ; m=2,rx; modify a; r2->b
        add     r1,(r2)         ; m=1,rx; modify b;
        add     r0,-(r2)        ; m=4,rx; modify a; r2->a
        add     r0,@(r3)+       ; m=3,rx; modify a; r3->pb
        add     r0,@-(r3)       ; m=5,rx; modify a; r3->pa
        add     r0,a            ; m=6,pc; modify a;
        add     r1,@pb          ; m=7,pc; modify b;
        add     r0,@#a          ; m=3,pc; modify a;
        add     r1,2(r2)        ; m=6,rx; modify b (r2->a)
        add     r1,@2(r3)       ; m=7,rx; modify b (r3->pa)
        halt
stop:
;
a:      .word   000001
b:      .word   177777
pa:     .word   a
pb:     .word   b
}

tmpproc_dotest $cpu $code add_dstr

rlc log "    A6: op_byte some byte accesses ---------------------"

set code {
        . = 1000
start:  
        mov     #pb0,r2
        movb    a0,r0
        movb    a1,r1
        movb    r0,@(r2)+       ; write b0; afterwards r2->pb1
        movb    r1,b1           ; write b1
        incb    @pb1            ; access b1
        bisb    #101,@-2(r2)    ; access b0
        halt
stop:
;
a0:     .byte   010
a1:     .byte   020
b0:     .byte   0
b1:     .byte   0
pb0:    .word   b0
pb1:    .word   b1
}

tmpproc_dotest $cpu $code op_byte
        
# -- ------- A7 -----------------------------------------------------------
rlc log "    A7: op_mixed: a long mixed address case ------------"

set code {
        . = 1000
start:  mov     #123,a
        mov     #234,b
        mov     #pa,r0
        mov     #pb,r1
        add     @-2(r1),@2(r0)  ; does add a,b ...
        mov     b,r0
        halt
stop:
;
a:      .word   0
b:      .word   0
pa:     .word   a
pb:     .word   b
}

tmpproc_dotest $cpu $code op_mixed

# -- ------- A8 -----------------------------------------------------------
rlc log "    A8: op_long: complex instructions: mul,div,ash(c) --"

set code {
        . = 1000
start:  mov     #1234,r0
        mul     #2345,r0        ; 1234*2345 -> 314 2614
        add     #345,r1         ; add 345   to lsb
        adc     r0              ; and carry to msb
        mov     r1,r5
        div     #1234,r0        ; 314 3161 / 1234 -> 2345 reminder 345
        mov     r0,r4           ; quotient  2345
        mov     r1,r5           ; reminder   345
;
        mov     #1,r0
        ash     #10,r0
        mov     r0,r4
;
        mov     #123,r1
        mov     #234,r0
        ashc    #3,r0
        mov     r0,r4           ; msb: 2340
        mov     r1,r5           ; lsb: 1230
        halt
stop:
}

tmpproc_dotest $cpu $code op_long

# -- ------- A8 -----------------------------------------------------------
rlc log "    A8: op_mxpx: m(tf)p(id) instruction ----------------"

set code {
        . = 1000
start:  mov     #123,a          ; set a value
        mfpd    @pa             ; fetch a: now on stack
        inc     (sp)            ; inc it
        mtpd    @pa             ; store a
        mov     a,r0            ; and check
        halt
stop:
;
a:      .word   0
pa:     .word   a
}

tmpproc_dotest $cpu $code op_mxpx

# -- Section B ---------------------------------------------------------------
rlc log "  B: flow control instructions ------------------------------"

rlc log "    B1: jsr_dsta: jsr and dsta chain -------------------"

set code {
        . = 1000
start:  mov     #ra,r2
        mov     #pra,r3
        jsr     pc,(r2)+        ; m=2,rx; call ra; r2->rb
        jsr     pc,(r2)         ; m=1,rx; call rb;
        jsr     pc,-(r2)        ; m=4,rx; call ra; r2->ra
        jsr     pc,@(r3)+       ; m=3,rx; call ra; r3->prb
        jsr     pc,@-(r3)       ; m=5,rx; call ra; r3->pra
        jsr     pc,ra           ; m=6,pc; call ra;
        jsr     pc,@prb         ; m=7,pc; call rb;
        jsr     pc,@#ra         ; m=3,pc; call ra;
        jsr     pc,2(r2)        ; m=6,rx; call rb (r2->ra)
        jsr     pc,@2(r3)       ; m=7,rx; call rb (r3->pra)
        halt
stop:
;
ra:     rts     pc
rb:     rts     pc
pra:    .word   ra
prb:    .word   rb
}

tmpproc_dotest $cpu $code jsr_dsta

# -- ------- B2 -----------------------------------------------------------
rlc log "    B2: brsobjmp: br, sob and jmp ----------------------"

set code {
        . = 1000
start:  clr     r0
        mov     #000001,r1
        mov     #177777,r2
; cmp and cond branch
        cmp     r1,r0
        beq     bad
        bne     10$
        halt
; bit and cond branch
10$:    bit     r1,r2
        beq     bad
        bne     20$
        halt
; br loop
20$:    mov     #3,r3
        clr     r4
21$:    inc     r4
        dec     r3
        bne     21$
        
; sob loop
30$:    mov     #3,r3
        clr     r4
31$:    inc     r4
        sob     r3,31$

; some branches
        br      40$
        halt
40$:    sec
        bcc     bad
        bcs     41$

; and jumps
41$:    jmp     l1
        halt
l1:     jmp     @#l2
        halt
l2:     halt
stop:
;
bad:    halt
}

tmpproc_dotest $cpu $code brsobjmp

# -- ------- B3 -----------------------------------------------------------
rlc log "    B3: test mark instruction (never used nonsense) ----"

set code {
        . = 1000
start:  mov     r5,-(sp)        ; push old r5 on stack
        mov     #101,-(sp)      ; push 1st param
        mov     #102,-(sp)      ; push 2nd param
        mov     #103,-(sp)      ; push 3rd param
        mov     #<mark+3>,-(sp) ; push MARK 3
        mov     sp,r5           ; get address of MARK N
        jsr     pc,r            ; call routine
        halt
stop:
;
r:      mov     6(r5),r0        ; 1st param
        mov     4(r5),r0        ; 2nd param
        mov     2(r5),r0        ; 3rd param
        rts     r5
}

tmpproc_dotest $cpu $code op_mark

# -- Section D ---------------------------------------------------------------
rlc log "  D: traps --------------------------------------------------"
rlc log "    D1: trap instructions ------------------------------"

set code {
        .include        |lib/defs_cpu.mac|
        . = 000004
v..iit: .word   vh.xxx          ; vec   4 
        .word   cp.pr7
v..rit: .word   vh.xxx          ; vec  10 
        .word   cp.pr7
v..bpt: .word   vh.bpt          ; vec  14 (T bit; BPT)
        .word   cp.pr7
v..iot: .word   vh.iot          ; vec  20 (IOT)
        .word   cp.pr7
        . = 000030
v..emt: .word   vh.emt          ; vec  30 (EMT)
        .word   cp.pr7
v..trp: .word   vh.trp          ; vec  34 (TRAP)
        .word   cp.pr7
        . = 000250
v..mmu: .word   vh.xxx          ; vec 250 (MMU)
        .word   000340
;        
        . = 1000
start:  bpt
        iot
        emt     123
        trap    234
        halt
stop:
;
vh.bpt: mov     #010000,r0
        rti
vh.iot: mov     #020000,r0
        rti
vh.emt: mov     (sp),r0
        mov     -2(r0),r0
        bic     #177400,r0
        bis     #030000,r0
        rti
vh.trp: mov     (sp),r0
        mov     -2(r0),r0
        bic     #177400,r0
        bis     #040000,r0
        rti
;
vh.xxx: halt
}

tmpproc_dotest $cpu $code trap_ins

# -- ------- D2 -----------------------------------------------------------
rlc log "    D2: usage of trace bit in psw ----------------------"

set code {
        .include        |lib/defs_cpu.mac|
        . = 000004
v..iit: .word   vh.xxx          ; vec   4 
        .word   cp.pr7
v..rit: .word   vh.xxx          ; vec  10 
        .word   cp.pr7
v..bpt: .word   vh.bpt          ; vec  14 (T bit; BPT)
        .word   cp.pr7
v..iot: .word   vh.iot          ; vec  20 (IOT)
        .word   cp.pr7
        . = 000030
v..emt: .word   vh.xxx          ; vec  30 (EMT)
        .word   cp.pr7
v..trp: .word   vh.xxx          ; vec  34 (TRAP)
        .word   cp.pr7
        . = 000250
v..mmu: .word   vh.xxx          ; vec 250 (MMU)
        .word   000340
;        
        . = 1000
start:  mov     #<cp.cmu+cp.pr7+cp.t>,-(sp)
        mov     #ucode,-(sp)
        rtt                     ; use rtt, allow 1 instruction
        halt
;
; this code will be executed in user mode
;
ucode:  clr     r2
        inc     r2
        com     r2
        iot
;
; iot will end this test with a halt (is executed in kernel mode)
;
vh.iot: halt
stop:
;
; bpt handler returns traced instruction (works only for 1 word instructions !!)
;
vh.bpt: mov     (sp),r0
        mov     -2(r0),r0
        rtt                     ; use rtt, allow 1 instruction
;
vh.xxx: halt
}

tmpproc_dotest $cpu $code trap_tbit

# -- ------- D3 -----------------------------------------------------------
rlc log "    D3: test yellow stack trap -------------------------"

set code {
        .include        |lib/defs_cpu.mac|
        .include        |lib/defs_reg70.mac|
        . = 000004
v..iit: .word   vh.iit          ; vec   4 
        .word   cp.pr7
v..rit: .word   vh.rit          ; vec  10 
        .word   cp.pr7
v..bpt: .word   vh.xxx          ; vec  14 (T bit; BPT)
        .word   cp.pr7
v..iot: .word   vh.xxx          ; vec  20 (IOT)
        .word   cp.pr7
        . = 000030
v..emt: .word   vh.xxx          ; vec  30 (EMT)
        .word   cp.pr7
v..trp: .word   vh.xxx          ; vec  34 (TRAP)
        .word   cp.pr7
        . = 000250
v..mmu: .word   vh.xxx          ; vec 250 (MMU)
        .word   000340
;
        . = 1000
start:  clr     @#cpuerr        ; FIXME: hack to workaround creset issue
                                ; remove (with defs_reg70 include) when fixed
        mov     #400,sp
        mov     #123,-(sp)
        halt
stop:
;
vh.iit: mov     #010000,r0
        mov     sp,r5
        rti
vh.rit: mov     #020000,r0
        rti
;
vh.xxx: halt                
}

tmpproc_dotest $cpu $code trap_ysv

# -- ------- D43 -----------------------------------------------------------
rlc log "    D4: mmu trap ---------------------------------------"

set code {
        .include        |lib/defs_cpu.mac|
        .include        |lib/defs_mmu.mac|
        . = 000004
v..iit: .word   vh.xxx          ; vec   4 
        .word   cp.pr7
v..rit: .word   vh.xxx          ; vec  10 
        .word   cp.pr7
v..bpt: .word   vh.xxx          ; vec  14 (T bit; BPT)
        .word   cp.pr7  
v..iot: .word   vh.xxx          ; vec  20 (IOT)
        .word   cp.pr7
        . = 000030
v..emt: .word   vh.xxx          ; vec  30 (EMT)
        .word   cp.pr7
v..trp: .word   vh.xxx          ; vec  34 (TRAP)
        .word   cp.pr7
        . = 000250
v..mmu: .word   vh.mmu          ; vec 250 (MMU)
        .word   cp.pr7
; 
        . = 1000
start:  mov     #<77400+md.arw>,@#<kipdr+00> ; s0: slf=127; ed=0; acf=rw
        mov     #000000,@#<kipar+00>         ;     1-to-1 
        mov     #<77400+md.atw>,@#<kipdr+02> ; s1: slf=127; ed=0; acf=rw,trap-w
        mov     #000200,@#<kipar+02>         ;     1-to-1 
        mov     #<77400+md.arw>,@#<kipdr+16> ; s7: slf=127; ed=0; acf=rw
        mov     #177600,@#<kipar+16>         ;     to io page (22 bit)
        mov     #234,vtst
        mov     #m3.e22,@#ssr3               ; enable 22bit mode
        mov     #<m0.ent+m0.ena>,@#ssr0      ; enable mmu, enable traps
;
        mov     vtst,r0         ; no trap (is read)
        inc     r0
        mov     r0,vtst         ; should trap (is write)
        inc     vtst            ; should trap (is read-mod-write)
;
        clr     @#ssr0
        halt
stop:
;
vh.mmu: mov     #<m0.ent+m0.ena>,@#ssr0  ; clear error flags, keep enables
        rti
;
vh.xxx: halt
; 
        . = 0020000
vtst:   .word   234             ; in segment 1, will trap on write
}

tmpproc_dotest $cpu $code trap_mmu

# -- Section E ---------------------------------------------------------------
rlc log "  E: faults -------------------------------------------------"
rlc log "    E1: test reserved and bad instruction faults -------"

set code {
        .include        |lib/defs_cpu.mac|
        . = 000004
v..iit: .word   vh.iit          ; vec   4 
        .word   cp.pr7
v..rit: .word   vh.rit          ; vec  10 
        .word   cp.pr7
v..bpt: .word   vh.xxx          ; vec  14 (T bit; BPT)
        .word   cp.pr7
v..iot: .word   vh.xxx          ; vec  20 (IOT)
        .word   cp.pr7
        . = 000030
v..emt: .word   vh.xxx          ; vec  30 (EMT)
        .word   cp.pr7
v..trp: .word   vh.xxx          ; vec  34 (TRAP)
        .word   cp.pr7
        . = 000250
v..mmu: .word   vh.xxx          ; vec 250 (MMU)
        .word   000340
;
        . = 1000
start:
tst0:   mov     #tst1,r5
        .word   000010          ; reserved instruction  (trap 10)
        halt
;
tst1:   mov     #end,r5
        jsr     pc,r1           ; bad address mode instruction (trap 10)
        halt
;
end:    halt
stop:
;
vh.iit: mov     #010000,r0
        mov     r5,(sp)
        rti
vh.rit: mov     #020000,r0
        mov     r5,(sp)
        rti
;
vh.xxx: halt                
}

tmpproc_dotest $cpu $code flt_trap10

# -- ------- E2 -----------------------------------------------------------
rlc log "    E2: test odd addr, io timeout faults ---------------"
# Note: E1/E2 splitt in two tests to ensure they stay < 256 cycles
        
set code {
        .include        |lib/defs_cpu.mac|
        . = 000004
v..iit: .word   vh.iit          ; vec   4 
        .word   cp.pr7
v..rit: .word   vh.rit          ; vec  10 
        .word   cp.pr7
v..bpt: .word   vh.xxx          ; vec  14 (T bit; BPT)
        .word   cp.pr7
v..iot: .word   vh.xxx          ; vec  20 (IOT)
        .word   cp.pr7
        . = 000030
v..emt: .word   vh.xxx          ; vec  30 (EMT)
        .word   cp.pr7
v..trp: .word   vh.xxx          ; vec  34 (TRAP)
        .word   cp.pr7
        . = 000250
v..mmu: .word   vh.xxx          ; vec 250 (MMU)
        .word   000340
;
        . = 1000
start:
tst0:   mov     #tst1,r5
        mov     b,r1            ; odd address (data)
        halt
;
tst1:   mov     #tst2,r5
        jmp     b               ; odd address (code)
        halt
;
tst2:   mov     #end,r5
        mov     @#160000,r1     ; ibus timeout
        halt
;
end:    halt
stop:
;
vh.iit: mov     #010000,r0
        mov     r5,(sp)
        rti
vh.rit: mov     #020000,r0
        mov     r5,(sp)
        rti
;
vh.xxx: halt                
; 
a:      .byte   0
b:      .byte   0
}

tmpproc_dotest $cpu $code flt_oddtout

# -- ------- E3 -----------------------------------------------------------
rlc log "    E3: test red stack trap ----------------------------"

set code {
        .include        |lib/defs_cpu.mac|
        . = 000004
v..iit: .word   vh.iit          ; vec   4 
        .word   cp.pr7
v..rit: .word   vh.rit          ; vec  10 
        .word   cp.pr7
v..bpt: .word   vh.xxx          ; vec  14 (T bit; BPT)
        .word   cp.pr7
v..iot: .word   vh.xxx          ; vec  20 (IOT)
        .word   cp.pr7
        . = 000030
v..emt: .word   vh.xxx          ; vec  30 (EMT)
        .word   cp.pr7
v..trp: .word   vh.xxx          ; vec  34 (TRAP)
        .word   cp.pr7
        . = 000250
v..mmu: .word   vh.xxx          ; vec 250 (MMU)
        .word   000340
;        
        . = 1000
start:  mov     #300,sp
        mov     #123,-(sp)
        halt
stop:
;
vh.iit: mov     #010000,r0
        mov     sp,r5
        rti
vh.rit: mov     #020000,r0
        rti
;
vh.xxx: halt                        
}

tmpproc_dotest $cpu $code flt_rsv

# -- ------- E4 -----------------------------------------------------------
rlc log "    E4: mmu fault --------------------------------------"

set code {
        .include        |lib/defs_cpu.mac|
        .include        |lib/defs_mmu.mac|
        . = 000004
v..iit: .word   vh.xxx          ; vec   4 
        .word   cp.pr7
v..rit: .word   vh.xxx          ; vec  10 
        .word   cp.pr7
v..bpt: .word   vh.xxx          ; vec  14 (T bit; BPT)
        .word   cp.pr7
v..iot: .word   vh.xxx          ; vec  20 (IOT)
        .word   cp.pr7
        . = 000030
v..emt: .word   vh.xxx          ; vec  30 (EMT)
        .word   cp.pr7
v..trp: .word   vh.xxx          ; vec  34 (TRAP)
        .word   cp.pr7
        . = 000250
v..mmu: .word   vh.mmu          ; vec 250 (MMU)
        .word   cp.pr7
; 
        . = 1000
start:  mov     #<77400+md.arw>,@#<kipdr+00> ; s0: slf=127; ed=0; acf=rw
        mov     #000000,@#<kipar+00>         ;     1-to-1 
        mov     #077400,@#<kipdr+02>         ; s1: slf=127; ed=0; acf=abo
        mov     #<77400+md.arw>,@#<kipdr+16> ; s7: slf=127; ed=0; acf=rw
        mov     #177600,@#<kipar+16>         ;     to io page (22 bit)
        mov     #m3.e22,@#ssr3               ; enable 22bit mode
        mov     #m0.ena,@#ssr0               ; enable mmu
;
        mov     #bad,r5         ; to blocker
        mov     vok,a           ; should be ok
        mov     #ok,r5          ; recover address
        mov     vbad,b          ; should fault
        br      bad             ; to blocker
ok:     mov     #bad,r5         ; to blocker
        mov     vok,a           ; should be ok again
; 
        clr     @#ssr0
        halt
stop:
bad:    halt
;
a:      .word   0
b:      .word   0
;
vh.mmu: mov     @#ssr0,r0       ; check ssr0
        mov     @#ssr1,r1       ; check ssr1
        mov     @#ssr2,r2       ; check ssr2
        mov     #m0.ena,@#ssr0  ; clear error flags, keep enable
        mov     r5,(sp)         ; use recovery address
        rti
;
vh.xxx: halt                        
; 
        . = 0010000
vok:    .word   123             ; still in segment 0, thus ok
; 
        . = 0020000
vbad:   .word   234             ; in segment 1, will abort
}

tmpproc_dotest $cpu $code flt_mmu

# -- Section I ---------------------------------------------------------------
rlc log "  I: interrupt-----------------------------------------------"

rlc log "    I1: test pirq interrupts and spl -------------------"

set code {
        .include        |lib/defs_cpu.mac|
        .include        |lib/defs_reg70.mac|
        . = 000240
v..pir: .word   vh.pir          ; vec 240 (PIRQ)
        .word   cp.pr7
; 
        . = 1000
start:  spl     7
        movb    #300,pirq+1     ; book pr7 and pr6
        clr     r5
; 
        spl     6               ; next instruction always done
        inc     r5              ; interrupt after inc
        inc     r5
; 
        spl     0               ; next instruction always done
        inc     r5              ; interrupt after inc
        inc     r5
; 
        halt
stop:
;
vh.pir: mov     pirq,r0
        bic     #177761,r0      ; mask index bits
        asr     r0              ; get pri
        mov     #1,r1
        ash     r0,r1           ; r2 = 1<<pri
        bicb    r1,pirq+1       ; clear request
        mov     r5,r2           ; sample inc counter
        rti
}

tmpproc_dotest $cpu $code int_pirq


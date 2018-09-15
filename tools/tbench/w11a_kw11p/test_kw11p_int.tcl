# $Id: test_kw11p_int.tcl 1045 2018-09-15 15:20:57Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2018-09-15  1045   1.0    Initial version
#
# Test interrupt response 

# ----------------------------------------------------------------------------
rlc log "test_kw11p_regs: test ctr response with CSR(fix) --------------------"

if {[$cpu get haskw11p] == 0} {
  rlc log "  test_kw11p_regs-W: no kw11p unit found, test aborted"
  return
}

# -- Section A ---------------------------------------------------------------
rlc log "  A test interrupts via 100 Khz clock -----------------------"

rlc log "    A1: single interrupt (mode=0) ----------------------"
# setup single interrupt after 2 ticks of 100 kHz clock
#   --> max 20 usec --> for 100 MHz CPU: 2000 cycles, at most 1000 instuctions
# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_kwp.mac|
;
        .include  |lib/vec_cpucatch.mac|
; 
        . = 000104              ; setup KW11-P interrupt vector
v..kwp: .word vh.kwp
        .word cp.pr7
        
        . = 1000                ; data area
stack:
        
        . = 2000                ; code area
start:  spl     7               ; lock out interrupts
;
        mov     #2,@#kw.csb     ; load kw11-p counter
        mov     #<kw.ie+kw.rhk+kw.run>,@#kw.csr  ; setup: 100 kHz down single
        spl     0               ; allow interrupts
        mov     #1000.,r0
1$:     sob     r0,1$           ; wait some time
        halt                    ; HALT if no interrupt seen
;
vh.kwp: halt                    ; HALT if done
stop:
}

rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu     sp [expr $sym(stack)-4]
$cpu cp -rr0 reg0

rlc log [format "      2 x 100 kHz ticks took %4d sob" [expr {1000-$reg0}]]

rlc log "    A2: repeat interrupt (mode=1) ----------------------"

# setup three interrupts after 1 tick of 100 kHz clock
#   --> max 30 usec --> for 100 MHz CPU: 3000 cycles, at most 1500 instuctions
# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_kwp.mac|
;
        .include  |lib/vec_cpucatch.mac|
; 
        . = 000104              ; setup KW11-P interrupt vector
v..kwp: .word vh.kwp
        .word cp.pr7
        
        . = 1000                ; data area
stack:
        
        . = 2000                ; code area
start:  spl     7               ; lock out interrupts
  
;
        mov     #3,r1           ; setup interrupt counter
        mov     #1,@#kw.csb     ; load kw11-p counter
        mov     #<kw.ie+kw.mod+kw.rhk+kw.run>,@#kw.csr  ; setup: 100 kHz dn rep
        spl     0               ; allow interrupts
        mov     #1500.,r0
1$:     sob     r0,1$           ; wait some time
        halt                    ; HALT if no interrupt seen
;
vh.kwp: dec     r1              ; count interrupts
        beq     2$              ; if eq three interrupts seen
        rti                     ; otherwise continue
2$:     halt                    ; HALT if done
stop:
}

rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu     r1 0 \
                       sp [expr $sym(stack)-4]
$cpu cp -rr0 reg0

rlc log [format "      3 x 100 kHz ticks took %4d sob" [expr {1500-$reg0}]]


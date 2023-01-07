# $Id: test_w11a_cpu_halt.tcl 1347 2023-01-07 12:48:58Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-01-06  1347   1.0    Initial version
#
# Test CPU fatal halt conditions:
#   vecfet: vector fetch error halt
#   recser: recursive stack error halt
# The other two, sfail and vfail, are internal bug checks, no known way
# to check them, and if there were, the CPU core would be fixed.
#
# Both vecfet and recset can only happen with MMU enabled.

# ----------------------------------------------------------------------------
rlc log "test_w11a_cpu_halt: test CPU fatal halt conditions ------------------"

$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_mmu.mac|
        .include  |lib/vec_cpucatch.mac|
;
        kipdr0 = kipdr+ 0
        kipar0 = kipar+ 0
        kipdr1 = kipdr+ 2
        kipar1 = kipar+ 2
        kipdr6 = kipdr+14
        kipar6 = kipar+14
        kipdr7 = kipdr+16
        kipar7 = kipar+16
        p1base = <1*20000>              ; page 1
        p6base = <6*20000>              ; page 6
;
        . = 1000
stack1:
;
; code 1: initial set up of MMU, execute EMT ---------------
start1: mov     #stack1,sp
; set up MMU: 1-to-1 mapping for kernel
        mov     #<127.*md.plf>!md.arw,r5
        mov     r5,kipdr0               ; rw
        mov     r5,kipdr1               ; rw
        clr     kipdr6                  ; non-resident
        mov     r5,kipdr7               ; rw
        mov     #000000,kipar0
        mov     #000200,kipar1
        mov     #001400,kipar6
        mov     #177600,kipar7
; set up EMT handler
        mov     #vh.emt,v..emt
; enable MMU and execute EMT
        mov     #m0.ena,mmr0
        inc     r0              ; bump trace count
        emt     100
        inc     r0              ; bump trace count
        halt
stop1:
;
vh.emt: inc     r0              ; bump trace count
        rti
;
; code 2: vector fetch failure after EMT -------------------
        . = p1base
        .blkw   32.
stack2:
start2: mov     #stack2,sp
; unmap page 0, any vector fetch must fail, test with EMT
        clr     kipdr0
; enable MMU and execute EMT
        mov     #m0.ena,mmr0
        inc     r0              ; bump trace count  
        emt     100             ; -> vecfet CPU halt
100$:   inc     r0              ; bump trace count
        halt
stop2:
;
; code 3: recursive stack error after EMT ------------------
start3: mov     #stack1,sp      ; stack in page 0
; map page 0 read-only, so fetch succeeds, but push fails
        mov     #<127.*md.plf>!md.ara,kipdr0
; enable MMU and execute EMT
        mov     #m0.ena,mmr0
        inc     r0              ; bump trace count  
        emt     100             ; -> recser CPU halt
100$:   inc     r0              ; bump trace count
        halt
stop3:
;
; code 4: recursive stack error after STKLIM abort ---------
        .blkw   32.
stack4:
start4: mov     #stack4,sp      ; stack in page 1
; map page 0 still read-only; set STKLIM to prevent stack pusk
        mov     #stack4,cp.slr
; enable MMU and execute stack push
        mov     #m0.ena,mmr0
        inc     r0              ; bump trace count  
        clr     -(sp)           ; -> recser CPU halt
100$:   inc     r0              ; bump trace count
        halt
stop4:
;
; code 5: recursive stack error after MMU abort ---------
start5: mov     #p6base,sp      ; stack in page 6
; map page 0 still read-only; page 6 is unmapped
        mov     #stack4,cp.slr
; enable MMU and execute stack push
        mov     #m0.ena,mmr0
        inc     r0              ; bump trace count  
        clr     -(sp)           ; -> recser CPU halt
100$:   inc     r0              ; bump trace count
        halt
stop5:
}

# --------------------------------------------------------------------
rlc log "  A1: initial set up of MMU, execute EMT --------------------"
# that test is warmup, shows that MMU setup works

$cpu cp -wr0 0 \
        -stapc $sym(start1)
rw11::asmwait $cpu sym
$cpu cp -rr0   -edata 3 \
        -rpc   -edata $sym(stop1) \
        -rstat -edata [regbld rw11::CP_STAT {rust halt}]

# --------------------------------------------------------------------
rlc log "  A2: vecfet halt after unmap page 0 and EMT ----------------"

$cpu cp -wr0 0 \
        -stapc $sym(start2)
rw11::asmwait $cpu sym
$cpu cp -rr0   -edata 1 \
        -rpc   -edata $sym(start2:100$) \
        -rstat -edata [regbld rw11::CP_STAT {rust vecfet}]

# --------------------------------------------------------------------
rlc log "  A3: recser halt cases -------------------------------------"
rlc log "    A3.1: after page 0 read-only and EMT ----------"

$cpu cp -wr0 0 \
        -stapc $sym(start3)
rw11::asmwait $cpu sym
$cpu cp -rr0   -edata 1 \
        -rpc   -edata $sym(start3:100$) \
        -rstat -edata [regbld rw11::CP_STAT {rust recser}]

# --------------------------------------------------------------------
rlc log "    A3.2: after STKLIM abort ----------------------"

$cpu cp -wr0 0 \
        -stapc $sym(start4)
rw11::asmwait $cpu sym
$cpu cp -rr0   -edata 1 \
        -rpc   -edata $sym(start4:100$) \
        -rstat -edata [regbld rw11::CP_STAT {rust recser}]

# --------------------------------------------------------------------
rlc log "    A3.3: after MMU abort -------------------------"

$cpu cp -wr0 0 \
        -stapc $sym(start5)
rw11::asmwait $cpu sym
$cpu cp -rr0   -edata 1 \
        -rpc   -edata $sym(start5:100$) \
        -rstat -edata [regbld rw11::CP_STAT {rust recser}]

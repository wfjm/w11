# $Id: test_w11a_inst_traps.tcl 1346 2023-01-06 12:56:08Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2013-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-01-06  1346   1.0.3  use defs_cpu.mac include
# 2014-07-27   575   1.0.2  drop tout value from asmwait, reply on asmwait_tout
# 2014-03-01   552   1.0.1  check that unused regs stay 0; use stack:; check sp;
# 2013-04-01   502   1.0    Initial version
#
# Test trap type instructions: bpt,iot, emt nn, trap nn
#

# ----------------------------------------------------------------------------
rlc log "test_w11a_inst_traps: test trap type instructions -------------------"

# code register pre/post conditions beyond defaults
#   r5   #data   -> #data+6*5*2
$cpu ldasm -lst lst -sym sym {
        .include        |lib/defs_cpu.mac|
;
        . = 14
        .word   vh.bpt          ; vec 14: bpt
        .word   340
        .word   vh.iot          ; vec 20: iot
        .word   341
        . = 30
        .word   vh.emt          ; vec 30: emt
        .word   342
        .word   vh.trp          ; vec 34: trap
        .word   343
;
        . = 1000
stack:
start:  mov     #350,@#cp.psw
        bpt
350$:   mov     #351,@#cp.psw
        iot
351$:   mov     #352,@#cp.psw
        emt     100
352$:   mov     #353,@#cp.psw
        emt     200
353$:   mov     #354,@#cp.psw
        trap    10
354$:   mov     #355,@#cp.psw
        trap    20
355$:   halt
stop:
;
vh.bpt: mov     @#cp.psw,(r5)+          ; record psw
        mov     #1014,(r5)+             ; record trap id
        br      iexit
vh.iot: mov     @#cp.psw,(r5)+
        mov     #1020,(r5)+
        br      iexit
vh.emt: mov     @#cp.psw,(r5)+
        mov     #1030,(r5)+
        br      iexit
vh.trp: mov     @#cp.psw,(r5)+
        mov     #1034,(r5)+
;
iexit:  mov     (sp),r4                 ; get stack PC
        mov     r4,(r5)+                ; record PC
        mov     2(sp),(r5)+             ; record stack PS
        mov     -2(r4),(r5)+            ; record opcode of trap
        rti
;
data:   .blkw   6.*5.
        .word   177777
}

rw11::asmrun  $cpu sym r5 $sym(data)
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu     r0 0 \
                       r1 0 \
                       r2 0 \
                       r3 0 \
                       r5 [expr {$sym(data) + 6*5*2}] \
                       sp $sym(stack)

# data: trap ps; trap id; stack-pc;    stack-ps   opcode
rw11::asmtmem $cpu $sym(data) \
  [list 000340   001014 $sym(start:350$) 000350   0000003 \
        000341   001020 $sym(start:351$) 000351   0000004 \
        000342   001030 $sym(start:352$) 000352   0104100 \
        000342   001030 $sym(start:353$) 000353   0104200 \
        000343   001034 $sym(start:354$) 000354   0104410 \
        000343   001034 $sym(start:355$) 000355   0104420 \
        0177777 ]

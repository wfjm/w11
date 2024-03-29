# $Id: test_w11a_inst_wait.tcl 1347 2023-01-07 12:48:58Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-01-06  1347   1.0    Initial version
#
# Test WAIT instruction. Can't be done in tcode because the test requires
# console interaction for monitoring the CPU state.
#

# ----------------------------------------------------------------------------
rlc log "test_w11a_inst_wait: test wait instruction --------------------------"

$cpu ldasm -lst lst -sym sym {
        .include        |lib/defs_cpu.mac|
;
; setup pirq vector
        . = 000240
        .word   vh.pir
        .word   cp.pr7
;
        . = 1000
stack:
start:  inc     r0
100$:   wait                    ; wait for interrupt
200$:   inc     r0
300$:   halt
stop:
;
; PIRQ handler
vh.pir: clr     cp.pir          ; cancel PIRQ requests
        rti
}

rlc log "  A1: test that wait does wait-------------------------------"

rw11::asmrun  $cpu sym  r0 0

# check that wait does wait
$cpu cp -rr0   -edata 1 \
        -rsp   -edata $sym(stack) \
        -rpc   -edata $sym(start:200$) \
        -rstat -edata [regbld rw11::CP_STAT {rust runs} go]
$cpu cp -rr0   -edata 1 \
        -rsp   -edata $sym(stack) \
        -rpc   -edata $sym(start:200$) \
        -rstat -edata [regbld rw11::CP_STAT {rust runs} go]
$cpu cp -rr0   -edata 1 \
        -rsp   -edata $sym(stack) \
        -rpc   -edata $sym(start:200$) \
        -rstat -edata [regbld rw11::CP_STAT {rust runs} go]

# trigger PIRQ interrupt with console write to cp.pir
$cpu cp -wibr [$cpu imap pirq] [regbld rw11::PIRQ {pir 2}]

# check that interrupt was handled and cpu halted
rw11::asmwait $cpu sym;         # checks pc
$cpu cp -rr0   -edata 2 \
        -rsp   -edata $sym(stack) \
        -rstat -edata [regbld rw11::CP_STAT {rust halt}]

rlc log "  A2: test that doesn't block when single stepped -----------"

$cpu cp -wr0  0 \
        -wpc  $sym(start)
# step over 1st inc
$cpu cp -step \
        -rr0   -edata 1 \
        -rpc   -edata $sym(start:100$) \
        -rstat -edata [regbld rw11::CP_STAT {rust step}]
# step over wait
$cpu cp -step \
        -rr0   -edata 1 \
        -rpc   -edata $sym(start:200$) \
        -rstat -edata [regbld rw11::CP_STAT {rust step}]
# step over 2nd inc
$cpu cp -step \
        -rr0   -edata 2 \
        -rpc   -edata $sym(start:300$) \
        -rstat -edata [regbld rw11::CP_STAT {rust step}]
$cpu cp -stop

# $Id: test_cp_cpubasics.tcl 552 2014-03-02 23:02:00Z mueller $
#
# Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2013-03-31   502   1.0    Initial version
#
# Test very basic cpu interface gymnastics
#  1. load code via ldasm
#  2. execute code via -start, -stapc, -continue
#  3. single step code via -step
#

# ----------------------------------------------------------------------------
rlc log "test_cp_cpubasics: Test very basic cpu interface gymnastics"
rlc log "  load code via lsasm"

#
$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  inc   r2
        inc   r2
        inc   r2
        halt
stop:
}

rlc log "  read back and check"
$cpu cp -wal $sym(start) \
        -brm 4 -edata {0005202 0005202 0005202 0000000}

rlc log "  execute via -start"
$cpu cp -wr2 00000 \
        -wpc $sym(start) \
        -start
$cpu wtcpu -reset 1.0
$cpu cp -rr2 -edata 00003 \
        -rpc -edata $sym(stop)

rlc log "  execute via -stapc"
$cpu cp -wr2 00100 \
        -stapc $sym(start)
$cpu wtcpu -reset 1.0
$cpu cp -rr2 -edata 00103 \
        -rpc -edata $sym(stop)

rlc log "  execute via -continue"
$cpu cp -wr2 00200 \
        -wpc $sym(start) \
        -continue
$cpu wtcpu -reset 1.0
$cpu cp -rr2 -edata 00203 \
        -rpc -edata $sym(stop)

rlc log "  execute via -step"
$cpu cp -wr2 00300 \
        -wpc  $sym(start)
$cpu cp -step -rpc -edata [expr {$sym(start)+002}] \
              -rr2 -edata 00301 -rstat -edata 000100
$cpu cp -step -rpc -edata [expr {$sym(start)+004}] \
              -rr2 -edata 00302 -rstat -edata 000100
$cpu cp -step -rpc -edata [expr {$sym(start)+006}] \
              -rr2 -edata 00303 -rstat -edata 000100
$cpu cp -step -rpc -edata [expr {$sym(start)+010}] \
              -rr2 -edata 00303 -rstat -edata 000030

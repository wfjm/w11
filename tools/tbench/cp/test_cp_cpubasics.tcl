# $Id: test_cp_cpubasics.tcl 1346 2023-01-06 12:56:08Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2013-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-01-05  1346   1.1.2  add creset test
# 2015-07-19   702   1.1.1  ignore attn in stat checks
# 2015-05-09   676   1.1    w11a start/stop/suspend overhaul
# 2013-03-31   502   1.0    Initial version
#
# Test very basic cpu interface gymnastics
#  1. load code via ldasm
#  2. execute code via -start, -stapc
#  3. single step code via -step
#  4. verify -suspend, -resume
#

# ----------------------------------------------------------------------------
rlc log "test_cp_cpubasics: Test very basic cpu interface gymnastics ---------"
rlc log "  A1: start/stop/step basics --------------------------------"
rlc log "    load simple linear code via lsasm"

#
$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  inc   r2
        inc   r2
        inc   r2
        halt
stop:
}

rlc log "    read back and check"
$cpu cp -wal $sym(start) \
        -brm 4 -edata {0005202 0005202 0005202 0000000}

rlc log "    execute via -start"
$cpu cp -wr2 00000 \
        -wpc $sym(start) \
        -start
$cpu wtcpu -reset 1.0
$cpu cp -rr2 -edata 00003 \
        -rpc -edata $sym(stop)

rlc log "    execute via -stapc"
$cpu cp -wr2 00100 \
        -stapc $sym(start)
$cpu wtcpu -reset 1.0
$cpu cp -rr2 -edata 00103 \
        -rpc -edata $sym(stop)

rlc log "    execute via -step"
$cpu cp -wr2  00300 \
        -wpc  $sym(start)
$cpu cp -step \
        -rpc -edata [expr {$sym(start)+002}] \
        -rr2 -edata 00301 \
        -rstat -edata 000100
$cpu cp -step \
        -rpc -edata [expr {$sym(start)+004}] \
        -rr2 -edata 00302 \
        -rstat -edata 000100
$cpu cp -step \
        -rpc -edata [expr {$sym(start)+006}] \
        -rr2 -edata 00303 \
        -rstat -edata 000100
$cpu cp -step \
        -rpc -edata [expr {$sym(start)+010}] \
        -rr2 -edata 00303 \
        -rstat -edata 000020

rlc log "  A2: suspend/resume basics; cpugo,cpususp flags ------------"
# define tmpproc for r2 increment checks
proc tmpproc_checkr2inc {val} {
  set emsg ""
  if {$val == 0} {
    set emsg "FAIL: r2 change zero"
    rlc errcnt -inc
  }
  rlc log -bare ".. r2 increment $val $emsg"
}

#
rlc log "    load simple loop code via lsasm"
$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  inc   r2
        br    start
stop:
}

set statgo   [regbld rw11::STAT cpugo]
set statgosu [regbld rw11::STAT cpususp cpugo]
set statmask [rutil::com8 [regbld rw11::STAT attn]]; # check all but attn

rlc log "    execute via -stapc, check cpugo and that r2 increments"
$cpu cp -wr2 00000 \
        -stapc $sym(start) \
        -rr2 rr2_1 -estat $statgo $statmask \
        -rr2 rr2_2 -estat $statgo $statmask
tmpproc_checkr2inc $rr2_1
tmpproc_checkr2inc [expr {$rr2_2 - $rr2_1}]

rlc log "    suspend, check cpususp=1 and that r2 doesn't increment"
$cpu cp -suspend \
        -wr2 00000 \
        -rr2 -edata 0 -estat $statgosu $statmask \
        -rr2 -edata 0 -estat $statgosu $statmask

rlc log "    resume, check cpususp=0 and that r2 increments again"
$cpu cp -resume \
        -rr2 rr2_1 -estat $statgo $statmask \
        -rr2 rr2_2 -estat $statgo $statmask
tmpproc_checkr2inc $rr2_1
tmpproc_checkr2inc [expr {$rr2_2 - $rr2_1}]

rlc log "    suspend then step, two steps should inc r2 once"
$cpu cp -suspend \
        -wr2 00000 \
        -step \
        -step \
        -rr2  -edata 1 \
        -step \
        -step \
        -rr2  -edata 2

rlc log "    stop while suspended, check cpugo=0,cpususp=1,attn=1; harvest attn"
$cpu cp -stop -estat [regbld rw11::STAT cpususp attn]
$cpu wtcpu -reset 1.0

rlc log "    creset, check cpususp=0"
# Note: creset still has cpususp stat flag set because it clears with one
#       cycle delay. So do -estat after next command
$cpu cp -creset \
        -rr2 -estat 0

rlc log "  A3: check that creset clears PSW,MMR0, MMR3 ---------------"

set mmr0  [$cpu imap mmr0]
set mmr3  [$cpu imap mmr3]
set psw_val  [regbld rw11::PSW rset {pri 7}]
set mmr0_val [regbld rw11::MMR0 anr ale ard trp ent ena]
set mmr3_val [regbld rw11::MMR3 ena_ubm ena_22bit d_km d_sm d_um]

rlc log "    write ps,mmr0,mmr3 and read back"
$cpu cp -wps  $psw_val \
        -wibr $mmr0 $mmr0_val \
        -wibr $mmr3 $mmr3_val \
        -rps  -edata $psw_val \
        -ribr $mmr0 -edata $mmr0_val \
        -ribr $mmr3 -edata $mmr3_val

rlc log "    creset and check that ps,mmr0,mmr3 cleared"
$cpu cp -creset \
        -rps  -edata 0 \
        -ribr $mmr0 -edata 0 \
        -ribr $mmr3 -edata 0

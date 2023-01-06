# $Id: test_cp_ubmap.tcl 1346 2023-01-06 12:56:08Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-01-05  1346   1.0    Initial version
#
# Test memory access via ubmap
#

# ----------------------------------------------------------------------------
rlc log "test_cp_ubmap: Test ubmap and memory access via ubmap ------------"
rlc log "  A1: write/read ubmap registers ----------------------------"
rlc log "    write ubmap registers"

set ubval {}
for {set i 0} {$i < 31} {incr i} {
  lappend ubval [expr 0110000 + 010*$i]
  lappend ubval [expr 040 + $i]
}

$cpu cp -wal $rw11::A_UBMAP \
        -bwm $ubval

rlc log "    read and check ubmap registers"
$cpu cp -wal $rw11::A_UBMAP \
        -brm [llength $ubval] -edata $ubval

rlc log "  A2: write/read memory via ubmap ---------------------------"
# ubmap.0 offsets by 03000
# data will be written 01400 (unmapped) and 04400 (mapped)
rlc log "    bwm via ubmap with mmr3 ubmap disabled"
$cpu cp -wal $rw11::A_UBMAP \
        -bwm {003000 0}
$cpu cp -wal 001400 \
        -wah [regbld rw11::CP_AH ubm] \
        -bwm {000111 000222 000333 000444}

rlc log "    check via direct read"
$cpu cp -wal 001400 \
        -brm 4 -edata {000111 000222 000333 000444}

rlc log "    bwm via ubmap with mmr3 ubmap enabled"
$cpu cp -wibr [$cpu imap mmr3] [regbld rw11::MMR3 ena_ubm]
$cpu cp -wal 001400 \
        -wah [regbld rw11::CP_AH ubm] \
        -bwm {010111 010222 010333 010444}

rlc log "    check via direct read"
$cpu cp -wal 001400 \
        -brm 4 -edata {000111 000222 000333 000444} \
        -wal 004400 \
        -brm 4 -edata {010111 010222 010333 010444}

rlc log "    read  via ubmap"
$cpu cp -wal 001400 \
        -wah [regbld rw11::CP_AH ubm] \
        -brm 4 -edata {010111 010222 010333 010444}

rlc log "  A3: write/read memory via ubmap over page border ----------"
# ubmap.0 offsets by 04000
# ubmap.1 offsets by 05000
# transfer to 017774:020002 goes to 023774,023776,005000,005002
$cpu cp -wal $rw11::A_UBMAP \
        -bwm {004000 0 005000 0}
$cpu cp -wal 023774 -bwm {0 0 0} \
        -wal 025000 -bwm {0 0 0}

rlc log "    bwm via ubmap with mmr3 ubmap enabled"
$cpu cp -wal 017774 \
        -wah [regbld rw11::CP_AH ubm] \
        -bwm {030111 030222 030333 030444}

rlc log "    check via direct read"
$cpu cp -wal 023774 -brm 3 -edata {030111 030222 0} \
        -wal 005000 -brm 3 -edata {030333 030444 0}
rlc log "    read  via ubmap"
$cpu cp -wal 017774 \
        -wah [regbld rw11::CP_AH ubm] \
        -brm 5 -edata {030111 030222 030333 030444 0}

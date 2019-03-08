# $Id: test_cp_ibrbasics.tcl 1116 2019-03-03 08:24:07Z mueller $
#
# Copyright 2014-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2019-03-01  1116   1.1.1  use imap addresses for test area
# 2014-12-26   621   1.1    test membe
# 2014-03-02   552   1.0    Initial version
#
# Test ibus window gymnastics
#  1. write/read IB space via bwm/brm   (use MMU SAR SM I regs)
#  2. write/read IB space via wibr/ribr (use MMU SAR SM I regs)
#  3. test membe (byte write) via wibr/ribr
#

# ----------------------------------------------------------------------------
rlc log "test_cp_ibrbasics: Test very basic ibus interface gymnastics --------"

set sarsi0 [$cpu imap sarsi.0]
set sarsi1 [$cpu imap sarsi.1]
set sarsi2 [$cpu imap sarsi.2]

rlc log "  write/read ibus space (MMU SAR SM I regs) via bwm/brm"
$cpu cp -wal $sarsi0 \
        -bwm {012340 012342 012344}

$cpu cp -wal $sarsi0 \
        -brm 3 -edata {012340 012342 012344}

rlc log "  write/read ibus space (MMU SAR SM I regs) via wibr/ribr"
$cpu cp -ribr $sarsi0 -edata 012340 \
        -ribr $sarsi1 -edata 012342 \
        -ribr $sarsi2 -edata 012344
$cpu cp -wibr $sarsi0        022340 \
        -wibr $sarsi1        022342 \
        -wibr $sarsi2        022344
$cpu cp -ribr $sarsi0 -edata 022340 \
        -ribr $sarsi1 -edata 022342 \
        -ribr $sarsi2 -edata 022344

rlc log "  membe with wibr (non sticky)"
$cpu cp -wibr $sarsi0 0x0100 \
        -wibr $sarsi1 0x0302 \
        -wibr $sarsi2 0x0504
rlc log "    membe = 0 (no byte selected)"
$cpu cp -wmembe 0 \
        -wibr $sarsi1 0xffff \
        -rmembe -edata 0x03 \
        -ribr $sarsi1 -edata 0x0302
rlc log "    membe = 1 (lsb selected)"
$cpu cp -wmembe 0x01 \
        -wibr $sarsi1 0xffaa \
        -rmembe -edata 0x03 \
        -ribr $sarsi1 -edata 0x03aa
rlc log "    membe = 2 (msb selected)"
$cpu cp -wmembe 0x02 \
        -wibr $sarsi1 0xbbff \
        -rmembe -edata 0x03 \
        -ribr $sarsi1 -edata 0xbbaa

$cpu cp -ribr $sarsi0 -edata 0x0100 \
        -ribr $sarsi1 -edata 0xbbaa \
        -ribr $sarsi2 -edata 0x0504

rlc log "  membe with wibr (sticky)"
$cpu cp -wibr $sarsi0 0x1110 \
        -wibr $sarsi1 0x1312 \
        -wibr $sarsi2 0x1514

rlc log "    membe = 0 + stick (no byte selected)"
$cpu cp -wmembe 0 -stick \
        -wibr $sarsi1 0xffff \
        -rmembe -edata 0x04 \
        -ribr $sarsi1 -edata 0x1312

rlc log "    membe = 1 + stick (lsb selected)"
$cpu cp -wmembe 1 -stick \
        -wibr $sarsi0 0xffaa \
        -rmembe -edata 0x05 \
        -wibr $sarsi1 0xffbb \
        -rmembe -edata 0x05 \
        -wibr $sarsi2 0xffcc \
        -rmembe -edata 0x05
$cpu cp -ribr $sarsi0 -edata 0x11aa \
        -ribr $sarsi1 -edata 0x13bb \
        -ribr $sarsi2 -edata 0x15cc

rlc log "    membe = 2 + stick (msb selected)"
$cpu cp -wmembe 2 -stick \
        -wibr $sarsi0 0xccff \
        -rmembe -edata 0x06 \
        -wibr $sarsi1 0xbbff \
        -rmembe -edata 0x06 \
        -wibr $sarsi2 0xaaff \
        -rmembe -edata 0x06
$cpu cp -ribr $sarsi0 -edata 0xccaa \
        -ribr $sarsi1 -edata 0xbbbb \
        -ribr $sarsi2 -edata 0xaacc
rlc log "    membe = 3 again"
$cpu cp -wmembe 3 \
        -rmembe -edata 0x03

# --------------------------------------------------------------------

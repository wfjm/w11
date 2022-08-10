# $Id: test_cp_ibrbasics.tcl 1274 2022-08-08 09:21:53Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2014-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2022-08-08  1274   1.1.2  ssr->mmr rename
# 2019-03-01  1116   1.1.1  use imap addresses for test area
# 2014-12-26   621   1.1    test membe
# 2014-03-02   552   1.0    Initial version
#
# Test ibus window gymnastics
#  1. write/read IB space via bwm/brm   (use MMU PAR SM I regs)
#  2. write/read IB space via wibr/ribr (use MMU PAR SM I regs)
#  3. test membe (byte write) via wibr/ribr
#

# ----------------------------------------------------------------------------
rlc log "test_cp_ibrbasics: Test very basic ibus interface gymnastics --------"

set parsi0 [$cpu imap parsi.0]
set parsi1 [$cpu imap parsi.1]
set parsi2 [$cpu imap parsi.2]

rlc log "  write/read ibus space (MMU PAR SM I regs) via bwm/brm"
$cpu cp -wal $parsi0 \
        -bwm {012340 012342 012344}

$cpu cp -wal $parsi0 \
        -brm 3 -edata {012340 012342 012344}

rlc log "  write/read ibus space (MMU PAR SM I regs) via wibr/ribr"
$cpu cp -ribr $parsi0 -edata 012340 \
        -ribr $parsi1 -edata 012342 \
        -ribr $parsi2 -edata 012344
$cpu cp -wibr $parsi0        022340 \
        -wibr $parsi1        022342 \
        -wibr $parsi2        022344
$cpu cp -ribr $parsi0 -edata 022340 \
        -ribr $parsi1 -edata 022342 \
        -ribr $parsi2 -edata 022344

rlc log "  membe with wibr (non sticky)"
$cpu cp -wibr $parsi0 0x0100 \
        -wibr $parsi1 0x0302 \
        -wibr $parsi2 0x0504
rlc log "    membe = 0 (no byte selected)"
$cpu cp -wmembe 0 \
        -wibr $parsi1 0xffff \
        -rmembe -edata 0x03 \
        -ribr $parsi1 -edata 0x0302
rlc log "    membe = 1 (lsb selected)"
$cpu cp -wmembe 0x01 \
        -wibr $parsi1 0xffaa \
        -rmembe -edata 0x03 \
        -ribr $parsi1 -edata 0x03aa
rlc log "    membe = 2 (msb selected)"
$cpu cp -wmembe 0x02 \
        -wibr $parsi1 0xbbff \
        -rmembe -edata 0x03 \
        -ribr $parsi1 -edata 0xbbaa

$cpu cp -ribr $parsi0 -edata 0x0100 \
        -ribr $parsi1 -edata 0xbbaa \
        -ribr $parsi2 -edata 0x0504

rlc log "  membe with wibr (sticky)"
$cpu cp -wibr $parsi0 0x1110 \
        -wibr $parsi1 0x1312 \
        -wibr $parsi2 0x1514

rlc log "    membe = 0 + stick (no byte selected)"
$cpu cp -wmembe 0 -stick \
        -wibr $parsi1 0xffff \
        -rmembe -edata 0x04 \
        -ribr $parsi1 -edata 0x1312

rlc log "    membe = 1 + stick (lsb selected)"
$cpu cp -wmembe 1 -stick \
        -wibr $parsi0 0xffaa \
        -rmembe -edata 0x05 \
        -wibr $parsi1 0xffbb \
        -rmembe -edata 0x05 \
        -wibr $parsi2 0xffcc \
        -rmembe -edata 0x05
$cpu cp -ribr $parsi0 -edata 0x11aa \
        -ribr $parsi1 -edata 0x13bb \
        -ribr $parsi2 -edata 0x15cc

rlc log "    membe = 2 + stick (msb selected)"
$cpu cp -wmembe 2 -stick \
        -wibr $parsi0 0xccff \
        -rmembe -edata 0x06 \
        -wibr $parsi1 0xbbff \
        -rmembe -edata 0x06 \
        -wibr $parsi2 0xaaff \
        -rmembe -edata 0x06
$cpu cp -ribr $parsi0 -edata 0xccaa \
        -ribr $parsi1 -edata 0xbbbb \
        -ribr $parsi2 -edata 0xaacc
rlc log "    membe = 3 again"
$cpu cp -wmembe 3 \
        -rmembe -edata 0x03

# --------------------------------------------------------------------

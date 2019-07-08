# $Id: test_ibmon_cpu.tcl 1178 2019-06-30 12:39:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-03-05  1118   1.0    Initial version
# 2019-02-24  1115   0.1    First draft
#
# Test register response 
#  1. write/read IB space via bwm/brm   (use MMU SAR SM I regs)
#  2. write/read IB space via wibr/ribr (use MMU SAR SM I regs)
#  3. test membe (byte write) via wibr/ribr

# ----------------------------------------------------------------------------
rlc log "test_ibmon_cpu: test basics with cpu register accesses --------------"

if {[$cpu get hasibmon] == 0} {
  rlc log "  test_ibmon_cpu-W: no ibmon unit found, test aborted"
  return
}
package require ibd_ibmon
set print 0

# -- Section A ---------------------------------------------------------------
rlc log "  A exercise monitor data access via data/addr regs ---------"

rlc log "    A1: capture write/read rem and loc -----------------"
# write/read rem and loc with ibmon on; check that 4 lines acquired
set cntlstastd [regbld ibd_ibmon::CNTL conena remena locena {func "STA"}]
set cntlsto    [regbld ibd_ibmon::CNTL {func "STO"}]
set statmsk    [regbld ibd_ibmon::STAT wrap susp run]
set sarsi0     [$cpu imap sarsi.0]
set sarsi1     [$cpu imap sarsi.1]
set sarsi2     [$cpu imap sarsi.2]

$cpu cp \
  -wreg im.hilim        0177776 \
  -wreg im.lolim        0160000 \
  -wreg im.cntl        $cntlstastd \
  -rreg im.stat -edata [regbld ibd_ibmon::STAT run] $statmsk \
  -wibr sarsi.0        0xdead \
  -ribr sarsi.0 -edata 0xdead \
  -wal         $sarsi0 \
  -wm          0xbeef \
  -rm   -edata 0xbeef \
  -wreg im.cntl $cntlsto \
  -rreg im.stat -edata 0x0000 $statmsk \
  -rreg im.addr -edata [regbld ibd_ibmon::ADDR {laddr 4}]

if {$print} {puts [ibd_ibmon::print $cpu]}

# build expect list: list of {eflag eaddr edata enbusy} sublists
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0 we] $sarsi0 0xdead 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0   ] $sarsi0 0xdead 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca      be1 be0 we] $sarsi0 0xbeef 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca      be1 be0   ] $sarsi0 0xbeef 0]

rlc log "    A1.1: read all in one rblk -------------------------"
$cpu cp \
  -wreg im.addr 0x0000 \
  -rblk im.data 16 -edata $edat $emsk \
  -rreg im.addr -edata 16

rlc log "    A1.2: random address read --------------------------"
foreach addr {0x1 0x3 0x5 0x7 0x6 0x4 0x2 0x0 \
                0x9 0xb 0xd 0xf 0xe 0xc 0xa 0x8} {
  $cpu cp \
    -wreg im.addr $addr \
    -rreg im.data -edata [lindex $edat $addr] [lindex $emsk $addr] \
    -rreg im.addr -edata [expr {$addr + 1}]
}

rlc log "    A1.3: random address with rblk length 2 ------------"
foreach addr {0x1 0x3 0x5 0x7 0x6 0x4 0x2 0x0 \
                0x9 0xb 0xd     0xe 0xc 0xa 0x8} {
  $cpu cp \
    -wreg im.addr $addr \
    -rblk im.data 2 -edata [lrange $edat $addr [expr {$addr + 1}] ] \
                           [lrange $emsk $addr [expr {$addr + 1}] ] \
    -rreg im.addr -edata [expr {$addr + 2}]
}

# -- Section B ---------------------------------------------------------------
rlc log "  B test rreg,wreg capture: ack,we,be* flags ----------------"
rlc log "    B1.1: test byte racc access (via wibr/ribr) --------"
# word write/read already tested in section A; now go for byte writes
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS ack ca ra     be0 we] $sarsi0 0x00aa 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0   ] $sarsi0 0xbeaa 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1     we] $sarsi0 0x5500 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0   ] $sarsi0 0x55aa 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra         we] $sarsi0 0xfade 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0   ] $sarsi0 0x55aa 0]
ibd_ibmon::start $cpu
$cpu cp \
  -wmembe 1 \
  -wibr sarsi.0        0x00aa \
  -ribr sarsi.0 -edata 0xbeaa \
  -wmembe 2 \
  -wibr sarsi.0        0x5500 \
  -ribr sarsi.0 -edata 0x55aa \
  -wmembe 0 \
  -wibr sarsi.0        0xfade \
  -ribr sarsi.0 -edata 0x55aa 
  
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    B1.2: test byte cacc access (via wm/rm) ------------"
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS ack ca          be0 we] $sarsi0 0xff34 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca      be1 be0   ] $sarsi0 0x5534 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca      be1     we] $sarsi0 0x12ff 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca      be1 be0   ] $sarsi0 0x1234 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca              we] $sarsi0 0xfade 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca      be1 be0   ] $sarsi0 0x1234 0]
ibd_ibmon::start $cpu
$cpu cp \
  -wal       $sarsi0 \
  -wmembe 1 \
  -wm        0xff34 \
  -rm -edata 0x5534 \
  -wmembe 2 \
  -wm        0x12ff \
  -rm -edata 0x1234 \
  -wmembe 0 \
  -wm        0xfade \
  -rm -edata 0x1234 
  
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    B1.3: test loc  access (via cpu code) --------------"
# check that burst flag is seen for write of rmw
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS    ack     be1 be0 we] $sarsi0 0xffff 0] \
  [list [regbld ibd_ibmon::FLAGS    ack rmw be1 be0   ] $sarsi0 0xffff 0] \
  [list [regbld ibd_ibmon::FLAGS bu ack rmw be1 be0 we] $sarsi0 0x0000 0] \
  [list [regbld ibd_ibmon::FLAGS    ack     be1 be0   ] $sarsi0 0x0000 0] \
  [list [regbld ibd_ibmon::FLAGS    ack rmw     be0   ] $sarsi0 0x0000 0] \
  [list [regbld ibd_ibmon::FLAGS bu ack rmw     be0 we] $sarsi0 0xffff 0] \
  [list [regbld ibd_ibmon::FLAGS    ack     be1 be0   ] $sarsi0 0x00ff 0] \
  [list [regbld ibd_ibmon::FLAGS    ack rmw be1       ] $sarsi0 0x00ff 0] \
  [list [regbld ibd_ibmon::FLAGS bu ack rmw be1     we] $sarsi0 0x0101 0] \
  [list [regbld ibd_ibmon::FLAGS    ack     be1 be0   ] $sarsi0 0x01ff 0]

$cpu ldasm -lst lst -sym sym {
        . = 1000
stack:
start:  mov     #177777,(r0)  
        inc     (r0)
        mov     (r0),r1
        decb    (r0)
        mov     (r0),r2
        incb    1(r0)
        mov     (r0),r3
        halt
stop:
}

ibd_ibmon::start $cpu
rw11::asmrun  $cpu sym r0 $sarsi0
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu     r1 0x0000 \
                       r2 0x00ff \
                       r3 0x01ff
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

# -- Section C ---------------------------------------------------------------
rlc log "  C test access mode enable flags ---------------------------"
$cpu ldasm -lst lst -sym sym {
        . = 1000
stack:
start:  mov     r1,(r0)  
stop:
}

rlc log "    C1.1: test conena ----------------------------------"
# note that ibr access set cacc and racc flags
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0 we] $sarsi0 0x0100 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca      be1 be0 we] $sarsi1 0x0101 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0   ] $sarsi0 0x0100 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca      be1 be0   ] $sarsi1 0x0101 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0   ] $sarsi2 0x0102 0]
  
ibd_ibmon::start $cpu conena 1 remena 0 locena 0
$cpu cp \
  -wibr sarsi.0        0x0100  \
  -wal  $sarsi1                \
  -wm                  0x0101  \
  -wr0  $sarsi2     \
  -wr1  0x0102      \
  -wpc  $sym(start) \
  -step             \
  -rpc          -edata $sym(stop)  \
  -ribr sarsi.0 -edata 0x0100  \
  -wal  $sarsi1                \
  -rm           -edata 0x0101  \
  -ribr sarsi.2 -edata 0x0102
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    C1.2: test remena ----------------------------------"
# Note: use -wal and -wr0 setup above, skip -rpc also
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0 we] $sarsi0 0x0200 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0   ] $sarsi0 0x0200 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0   ] $sarsi2 0x0202 0]

ibd_ibmon::start $cpu conena 0 remena 1 locena 0
$cpu cp \
  -wibr sarsi.0        0x0200  \
  -wm                  0x0201  \
  -wr1  0x0202      \
  -wpc  $sym(start) \
  -step             \
  -ribr sarsi.0 -edata 0x0200  \
  -wal  $sarsi1                \
  -rm           -edata 0x0201  \
  -ribr sarsi.2 -edata 0x0202
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    C1.3: test locena ----------------------------------"
# Note: again reuse -wal and -wr0 setup above, skip -rpc also
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS ack           be1 be0 we] $sarsi2 0x0302 0] \

ibd_ibmon::start $cpu conena 0 remena 0 locena 1
$cpu cp \
  -wibr sarsi.0        0x0300  \
  -wm                  0x0301  \
  -wr1  0x0302      \
  -wpc  $sym(start) \
  -step             \
  -ribr sarsi.0 -edata 0x0300  \
  -wal  $sarsi1                \
  -rm           -edata 0x0301  \
  -ribr sarsi.2 -edata 0x0302
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

# -- Section D ---------------------------------------------------------------
rlc log "  D test hilim,lolim ----------------------------------------"
# allow sarsi0,sarsi1, block sarsi2
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0 we] $sarsi0 0x1100 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0 we] $sarsi1 0x1101 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0   ] $sarsi0 0x1100 0] \
  [list [regbld ibd_ibmon::FLAGS ack ca ra be1 be0   ] $sarsi1 0x1101 0]

ibd_ibmon::start $cpu
$cpu cp \
  -wreg im.hilim  $sarsi1 \
  -wreg im.lolim  $sarsi0 \
  -wibr sarsi.0        0x1100 \
  -wibr sarsi.1        0x1101 \
  -wibr sarsi.2        0x1102 \
  -ribr sarsi.0 -edata 0x1100 \
  -ribr sarsi.1 -edata 0x1101 \
  -ribr sarsi.2 -edata 0x1102 \
  -wreg im.hilim  0177777 \
  -wreg im.lolim  0160000
  
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

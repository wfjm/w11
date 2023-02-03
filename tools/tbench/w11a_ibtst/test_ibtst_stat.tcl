# $Id: test_ibtst_stat.tcl 1365 2023-02-02 11:46:43Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2019-03-05  1118   1.0.1  rename dly[rw] -> bsy[rw]; use -wal
# 2019-02-16  1112   1.0    Initial version
#
# Test stat register response 
#
# Note: ibtst is more a processor extension than an ibus device
#       ctrl/stat are only rem accessible (acts like bridged rbus device)
#       data/fifo can be rem/loc enabled
#       --> use rreg/wreg for cntl/stat accesses
#       --> use ribr/wibr for data/fifo rem accesses
#       --> use rm  /wm   for data/fifo loc accesses

# ----------------------------------------------------------------------------
rlc log "test_ibtst_stat: test stat register response -------------------------"

if {[$cpu get hasibtst] == 0} {
  rlc log "  test_ibtst_stat-W: no ibtst unit found, test aborted"
  return
}
package require ibd_ibtst

rlc log "    A1: data rem access --------------------------------"
$cpu cp \
  -wal [cpu0 imap  it.data] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL fclr remw remr ] \
  -wibr it.data 0x1234 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT racc cacc be1 be0 we ] \
  -ribr it.data -edata 0x1234 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT racc cacc be1 be0    re ]

rlc log "    A2: data loc access --------------------------------"
$cpu cp \
  -wreg it.cntl [regbld ibd_ibtst::CNTL locw locr ] \
  -wm        0xffff \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT cacc be1 be0 we ] \
  -wmembe    0x01   \
  -wm        0xee11 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT cacc     be0 we ] \
  -rm -edata 0xff11 \
  -wmembe    0x02   \
  -wm        0x22dd \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT cacc be1     we ] \
  -rm -edata 0x2211 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT cacc be1 be0    re ]

rlc log "    A3: data cpu write -> rem read (busy=0) ------------"
# load test code
$cpu ldasm -lst lst -sym sym {
        . = 002000              ; code base
start:  mov  #100200,(r0)       ; wr  11  0x8080
        movb #377,(r0)          ; wr  01  0x00ff -> 0x80ff
        movb #377,(r1)          ; wr  10  0x1100 -> 0xffff
        inc  (r0)               ; rmw 11  0xffff -> 0x0000
        incb (r0)               ; rmw 01  0x0000 -> 0x0001
        incb (r1)               ; rmw 10  0x0001 -> 0x0101
        mov  (r0),r2            ; rd  11  0x0101
}

# setup code and ibtst
$cpu cp \
  -wr0 [cpu0 imap  it.data] \
  -wr1 [expr {[cpu0 imap  it.data] + 1}] \
  -wr2 0xdead \
  -wpc 02000 \
  -wal [cpu0 imap  it.data] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL fclr remr locw locr ]

# step through code and check
$cpu cp \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT     be1 be0 we ] \
  -ribr it.data -edata 0x8080 \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT         be0 we ] \
  -ribr it.data -edata 0x80ff \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT     be1     we ] \
  -ribr it.data -edata 0xffff \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT rmw be1 be0 we re ] \
  -ribr it.data -edata 0x0000 \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT rmw     be0 we re ] \
  -ribr it.data -edata 0x0001 \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT rmw be1     we re ] \
  -ribr it.data -edata 0x0101 \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT     be1 be0    re ] \
  -rr2 -edata 0x0101

rlc log "    A4: data cpu write -> rem read (busy=8) ------------"

# setup for run with response delay enabled
$cpu cp \
  -wr2 0xdead \
  -wpc 02000 \
  -wreg it.cntl [regbld ibd_ibtst::CNTL fclr bsyw bsyr remr locw locr ]

# step through code and check (same sequence as above)
$cpu cp \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT     be1 be0 we ] \
  -ribr it.data -edata 0x8080 \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT         be0 we ] \
  -ribr it.data -edata 0x80ff \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT     be1     we ] \
  -ribr it.data -edata 0xffff \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT rmw be1 be0 we re ] \
  -ribr it.data -edata 0x0000 \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT rmw     be0 we re ] \
  -ribr it.data -edata 0x0001 \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT rmw be1     we re ] \
  -ribr it.data -edata 0x0101 \
  -step \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT     be1 be0    re ] \
  -rr2 -edata 0x0101


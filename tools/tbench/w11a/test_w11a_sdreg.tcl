# $Id: test_w11a_sdreg.tcl 1118 2019-03-05 19:26:39Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2019-03-05  1118   1.01   use -wal
# 2019-02-17  1113   1.0    Initial version
#
# Test cntl register response
#
# Note: display/swich register is a processor register
#       --> use ribr/wibr for rem accesses
#       --> use rm  /wm   for loc accesses

# ----------------------------------------------------------------------------
rlc log "test_w11a_sdreg: test switch and display register access -------------"

# test write/read aaaa/5555 dead/beef 0000/0000
#   for display  loc write --> rem read
#   for switch   rem write --> loc read
$cpu cp \
  -wal [cpu0 imap  sdreg] \
  -wm                0xaaaa \
  -wibr sdreg        0x5555 \
  -ribr sdreg -edata 0xaaaa \
  -rm         -edata 0x5555 \
  -wm                0xdead \
  -wibr sdreg        0xbeef \
  -ribr sdreg -edata 0xdead \
  -rm         -edata 0xbeef \
  -wm                0x0000 \
  -wibr sdreg        0x0000 \
  -ribr sdreg -edata 0x0000 \
  -rm         -edata 0x0000

# $Id: test_ibtst_data.tcl 1120 2019-03-09 18:19:31Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2019-03-05  1118   1.0.1  use -wal
# 2019-02-16  1112   1.0    Initial version
#
# Test data register response
#
# Note: ibtst is more a processor extension than an ibus device
#       ctrl/stat are only rem accessible (acts like bridged rbus device)
#       data/fifo can be rem/loc enabled
#       --> use rreg/wreg for cntl/stat accesses
#       --> use ribr/wibr for data/fifo rem accesses
#       --> use rm  /wm   for data/fifo loc accesses

# ----------------------------------------------------------------------------
rlc log "test_ibtst_data: test data register response -------------------------"

if {[$cpu get hasibtst] == 0} {
  rlc log "  test_ibtst_data-W: no ibtst unit found, test aborted"
  return
}
package require ibd_ibtst

rlc log "    A1: data loc/rem access ----------------------------"
# test loc/rem write: n/n; y/n; n/y; y/y
# test loc/rem read:  n/n; y/n; n/y; y/y
$cpu cp \
  -wal [$cpu imap  it.data] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL ] \
  -wm           0xdead -estaterr \
  -wibr it.data 0xdead -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL locw ] \
  -wm           0xdead           \
  -wibr it.data 0xdead -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL remw ] \
  -wm           0xdead -estaterr \
  -wibr it.data 0xdead           \
  -wreg it.cntl [regbld ibd_ibtst::CNTL remw locw ] \
  -wm           0xdead           \
  -wibr it.data 0xdead           \
  -wreg it.cntl [regbld ibd_ibtst::CNTL ] \
  -rm                         -estaterr \
  -ribr it.data               -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL locr ] \
  -rm           -edata 0xdead           \
  -ribr it.data               -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL remr ] \
  -rm                         -estaterr \
  -ribr it.data -edata 0xdead           \
  -wreg it.cntl [regbld ibd_ibtst::CNTL remr locr ] \
  -rm           -edata 0xdead           \
  -ribr it.data -edata 0xdead

rlc log "    A2: data loc nak and bsy,bsy+ack,timeout -----------"
# should all give rbus
$cpu cp \
  -wreg it.cntl [regbld ibd_ibtst::CNTL bsyw bsyr ] \
  -wm 0xdead -estaterr \
  -rm        -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL bsyw bsyr datab ] \
  -wm 0xdead -estaterr \
  -rm        -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL datto ] \
  -wm 0xdead -estaterr \
  -rm        -estaterr

rlc log "    A3: data byte access (loc only) --------------------"
# test loc byte write; test nobyt
$cpu cp \
  -wreg it.cntl [regbld ibd_ibtst::CNTL locw locr ] \
  -wm        0xffff \
  -wmembe    0x01   \
  -wm        0xee11 \
  -rm -edata 0xff11 \
  -wmembe    0x02   \
  -wm        0x22dd \
  -rm -edata 0x2211 \
  -wmembe    0x03   \
  -wm        0x4433 \
  -rm -edata 0x4433 \
  -wreg it.cntl [regbld ibd_ibtst::CNTL nobyt locw locr ] \
  -wmembe    0x01 \
  -wm        0xdead -estaterr \
  -wmembe    0x02 \
  -wm        0xdead -estaterr \
  -wmembe    0x03 \
  -wm        0xbeef \
  -rm -edata 0xbeef

rlc log "    A4: reset data -------------------------------------"
# check that data is cleared
$cpu cp \
  -wreg it.cntl [regbld ibd_ibtst::CNTL remw remr ] \
  -wibr it.data 0xdead \
  -breset \
  -ribr it.data -edata 0x0000

# harvest breset/creset triggered attn's
rlc exec -attn -edata 0
rlc wtlam 0.

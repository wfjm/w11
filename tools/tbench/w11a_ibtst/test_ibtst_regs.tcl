# $Id: test_ibtst_regs.tcl 1112 2019-02-17 11:10:04Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2019-02-16  1112   1.0    Initial version
#
# Test cntl register response
#
# Note: ibtst is more a processor extension than an ibus device
#       ctrl/stat are only rem accessible (acts like bridged rbus device)
#       data/fifo can be rem/loc enabled
#       --> use rreg/wreg for cntl/stat accesses
#       --> use ribr/wibr for data/fifo rem accesses
#       --> use rm  /wm   for data/fifo loc accesses

# ----------------------------------------------------------------------------
rlc log "test_ibtst_regs: test cntl/stat register access ----------------------"

if {[$cpu get hasibtst] == 0} {
  rlc log "  test_ibtst_regs-W: no ibtest unit found, test aborted"
  return
}
package require ibd_ibtst

rlc log "    A1: write/read cntl---------------------------------"
# test cntl option flags
$cpu cp \
  -wreg it.cntl [regbld ibd_ibtst::CNTL locr] \
  -rreg it.cntl -edata [regbld ibd_ibtst::CNTL locr] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL locw] \
  -rreg it.cntl -edata [regbld ibd_ibtst::CNTL locw] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL remr] \
  -rreg it.cntl -edata [regbld ibd_ibtst::CNTL remr] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL remw] \
  -rreg it.cntl -edata [regbld ibd_ibtst::CNTL remw] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL dlyr] \
  -rreg it.cntl -edata [regbld ibd_ibtst::CNTL dlyr] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL dlyw] \
  -rreg it.cntl -edata [regbld ibd_ibtst::CNTL dlyw] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL nobyt] \
  -rreg it.cntl -edata [regbld ibd_ibtst::CNTL nobyt] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL datto] \
  -rreg it.cntl -edata [regbld ibd_ibtst::CNTL datto] \
  -wreg it.cntl 0x0000 \
  -rreg it.cntl -edata -0x0000

rlc log "    A2: reset cntl -------------------------------------"
# check that only data/fifo rem access enable after reset
$cpu cp \
  -wreg it.cntl 0xffff \
  -breset \
  -rreg it.cntl -edata [regbld ibd_ibtst::CNTL remw remr] \
  -rreg it.stat -edata 0x0000

rlc log "    A3: cntl,stat only rem accessible ------------------"
$cpu cp \
  -rreg it.stat -edata 0x0000 \
  -wa [cpu0 imap  it.cntl] \
  -wm 0xdead -estaterr \
  -rm        -estaterr \
  -wa [cpu0 imap  it.stat] \
  -wm 0xdead -estaterr \
  -rm        -estaterr

# $Id: test_ibtst_fifo.tcl 1120 2019-03-09 18:19:31Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2019-03-05  1118   1.0.1  use -wal
# 2019-02-16  1112   1.0    Initial version
#
# Test fifo register response 
#
# Note: ibtst is more a processor extension than an ibus device
#       ctrl/stat are only rem accessible (acts like bridged rbus device)
#       data/fifo can be rem/loc enabled
#       --> use rreg/wreg for cntl/stat accesses
#       --> use ribr/wibr for data/fifo rem accesses
#       --> use rm  /wm   for data/fifo loc accesses

# ----------------------------------------------------------------------------
rlc log "test_ibtst_fifo: test fifo register response -------------------------"

if {[$cpu get hasibtst] == 0} {
  rlc log "  test_ibtst_fifo-W: no ibtst unit found, test aborted"
  return
}
package require ibd_ibtst

rlc log "    A1: fifo loc/rem access ----------------------------"
# test off->off; loc->loc; loc->rem; rem->loc; rem->rem
$cpu cp \
  -wal [cpu0 imap  it.fifo] \
  -wreg it.cntl [regbld ibd_ibtst::CNTL fclr ] \
  -wm                  0xdead -estaterr \
  -wibr it.fifo        0xdead -estaterr \
  -rm                         -estaterr \
  -ribr it.fifo               -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL locw locr ] \
  -wm                  0x1111           \
  -wibr it.fifo        0xdead -estaterr \
  -rm           -edata 0x1111           \
  -ribr it.fifo               -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL locw remr ] \
  -wm                  0x2222           \
  -wibr it.fifo        0xdead -estaterr \
  -rm                         -estaterr \
  -ribr it.fifo -edata 0x2222           \
  -wreg it.cntl [regbld ibd_ibtst::CNTL remw locr ] \
  -wm                  0xdead -estaterr \
  -wibr it.fifo        0x3333           \
  -rm           -edata 0x3333           \
  -ribr it.fifo               -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL remw remr ] \
  -wm                  0xdead -estaterr \
  -wibr it.fifo        0x4444           \
  -rm                         -estaterr \
  -ribr it.fifo -edata 0x4444

rlc log "    A2: fifo scalar (loc->rem); fifo clr ---------------"
# write 2; fclr; write 2; read 3
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL locw remr ] \
  -wm                  0x1011 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 1} cacc be1 be0 we ] \
  -wm                  0x1012 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 2} cacc be1 be0 we ] \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL fclr locw remr ] \
  -wm                  0x2011 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 1} cacc be1 be0 we ] \
  -wm                  0x2012 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 2} cacc be1 be0 we ] \
  -ribr it.fifo -edata 0x2011 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 1} racc cacc be1 be0 re]\
  -ribr it.fifo -edata 0x2012 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 0} racc cacc be1 be0 re]\
  -ribr it.fifo -estaterr \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 0} racc cacc be1 be0 re]

rlc log "    A3: fifo scalar (rem->loc) -------------------------"
# write 2; read 3
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL remw locr ] \
  -wibr it.fifo        0x3011 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 1} racc cacc be1 be0 we]\
  -wibr it.fifo        0x3012 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 2} racc cacc be1 be0 we]\
  -rm           -edata 0x3011 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 1} cacc be1 be0 re]\
  -rm           -edata 0x3012 \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 0} cacc be1 be0 re]\
  -rm           -estaterr \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 0} cacc be1 be0 re]

rlc log "    A4: fifo block read (loc->rem, rblk, test abort) ---"
# write 2; fclr; write 2; read 3 (get 2)
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL locw remr ] \
  -wm                  0x4011 \
  -wm                  0x4012 \
  -rbibr it.fifo 3 -edata {0x4011 0x4012} -edone 2 -estaterr

rlc log "    A5: fifo block write (rem->loc, wblk, test abort) --"
# write 8; write 8; read 16 (get 15)
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL remw locr ] \
  -wbibr it.fifo {0x5000 0x5011 0x5022 0x5033 0x5044 0x5055 0x5066 0x5077} \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 8} racc cacc be1 be0 we]\
  -wbibr it.fifo {0x5088 0x5099 0x50aa 0x50bb 0x50cc 0x50dd 0x50ee 0x50ff} \
                 -edone  7 -estaterr \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT {fsize 15} racc cacc be1 be0 we]\
  -rm -edata 0x5000 \
  -rm -edata 0x5011 \
  -rm -edata 0x5022 \
  -rm -edata 0x5033 \
  -rm -edata 0x5044 \
  -rm -edata 0x5055 \
  -rm -edata 0x5066 \
  -rm -edata 0x5077 \
  -rm -edata 0x5088 \
  -rm -edata 0x5099 \
  -rm -edata 0x50aa \
  -rm -edata 0x50bb \
  -rm -edata 0x50cc \
  -rm -edata 0x50dd \
  -rm -edata 0x50ee \
  -rm -estaterr

rlc log "    A6: reset fifo (and stat) --------------------------"
# check that fifo is cleared
$cpu cp \
  -wreg it.cntl [regbld ibd_ibtst::CNTL fclr remw remr ] \
  -wibr it.fifo 0xdead \
  -breset \
  -ribr it.stat -edata [regbld ibd_ibtst::STAT] \
  -ribr it.fifo -estaterr

# harvest breset/creset triggered attn's
rlc exec -attn -edata 0
rlc wtlam 0.

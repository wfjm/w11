# $Id: test_ibmon_ibtst.tcl 1120 2019-03-09 18:19:31Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2019-03-09  1120   1.0.1  use -brm,-bwf
# 2019-03-05  1118   1.0    Initial version
#
# Test register response 
#  1. write/read IB space via bwm/brm   (use MMU SAR SM I regs)
#  2. write/read IB space via wibr/ribr (use MMU SAR SM I regs)
#  3. test membe (byte write) via wibr/ribr

# ----------------------------------------------------------------------------
rlc log "test_ibmon_ibtest: tests with ibd_ibtst as target -------------------"

if {[$cpu get hasibmon] == 0} {
  rlc log "  test_ibmon_ibtst-W: no ibmon unit found, test aborted"
  return
}
if {[$cpu get hasibtst] == 0} {
  rlc log "  test_ibmon_ibtst-W: no ibtst unit found, test aborted"
  return
}
package require ibd_ibmon
package require ibd_ibtst
set print 0

# -- Section A ---------------------------------------------------------------
rlc log "  A exercise ack,nak,tout,busy and nbusy --------------------"

set itdata     [$cpu imap it.data]
set itfifo     [$cpu imap it.fifo]

# only data and fifo visible for ibmon to keep logs short
$cpu cp \
  -wreg im.hilim  $itfifo \
  -wreg im.lolim  $itdata 

rlc log "    A1: ack,nak on data --------------------------------"
# disable/enable rem/loc side visibility of data
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS nak     ca ra be1 be0 we] $itdata 0xdead 0] \
  [list [regbld ibd_ibmon::FLAGS nak     ca ra be1 be0   ] $itdata {}     0] \
  [list [regbld ibd_ibmon::FLAGS nak     ca    be1 be0 we] $itdata 0xdead 0] \
  [list [regbld ibd_ibmon::FLAGS nak     ca    be1 be0   ] $itdata {}     0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itdata 0x1111 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itdata 0x1111 0] \
  [list [regbld ibd_ibmon::FLAGS nak     ca    be1 be0 we] $itdata 0xdead 0] \
  [list [regbld ibd_ibmon::FLAGS nak     ca    be1 be0   ] $itdata {}     0] \
  [list [regbld ibd_ibmon::FLAGS nak     ca ra be1 be0 we] $itdata 0xdead 0] \
  [list [regbld ibd_ibmon::FLAGS nak     ca ra be1 be0   ] $itdata {}     0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itdata 0x2222 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0   ] $itdata 0x2222 0]

ibd_ibmon::start $cpu
$cpu cp \
  -wal  $itdata \
  -wreg it.cntl [regbld ibd_ibtst::CNTL ] \
  -wibr it.data 0xdead -estaterr \
  -ribr it.data        -estaterr \
  -wm   0xdead         -estaterr \
  -rm                  -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL remw remr] \
  -wibr it.data        0x1111 \
  -ribr it.data -edata 0x1111 \
  -wm   0xdead         -estaterr \
  -rm                  -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL locw locr] \
  -wibr it.data 0xdead -estaterr \
  -ribr it.data        -estaterr \
  -wm        0x2222 \
  -rm -edata 0x2222  
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    A2: ack with busy on data --------------------------"
# enable loc/rem side visibility of data, enable bsy
# use 3 cases: bsyw; bsyr; bsyw+bsyr; check that delay only on loc side
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itdata 0x0101 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itdata 0x0101 0] \
  [list [regbld ibd_ibmon::FLAGS bsy ack ca    be1 be0 we] $itdata 0x0102 8] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0   ] $itdata 0x0102 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itdata 0x0201 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itdata 0x0201 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itdata 0x0202 0] \
  [list [regbld ibd_ibmon::FLAGS bsy ack ca    be1 be0   ] $itdata 0x0202 8] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itdata 0x0301 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itdata 0x0301 0] \
  [list [regbld ibd_ibmon::FLAGS bsy ack ca    be1 be0 we] $itdata 0x0302 8] \
  [list [regbld ibd_ibmon::FLAGS bsy ack ca    be1 be0   ] $itdata 0x0302 8]

ibd_ibmon::start $cpu
$cpu cp \
  -wreg it.cntl [regbld ibd_ibtst::CNTL bsyw remw remr locw locr] \
  -wibr it.data        0x0101 \
  -ribr it.data -edata 0x0101 \
  -wm                  0x0102 \
  -rm           -edata 0x0102 \
  -wreg it.cntl [regbld ibd_ibtst::CNTL bsyr remw remr locw locr] \
  -wibr it.data        0x0201 \
  -ribr it.data -edata 0x0201 \
  -wm                  0x0202 \
  -rm           -edata 0x0202 \
  -wreg it.cntl [regbld ibd_ibtst::CNTL bsyw bsyr remw remr locw locr] \
  -wibr it.data        0x0301 \
  -ribr it.data -edata 0x0301 \
  -wm                  0x0302 \
  -rm           -edata 0x0302
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk


rlc log "    A3: nak on data (bsy,bsy+datab,datto,datto+datab) --"
# disable loc side visibility of data and use
#                   --> prompt  nak (as above)
#   bsy             --> delayed nak on write
#   bsy             --> delayed nak on read
#   bsy+datab       --> delayed nak with ack while busy
#   datto           --> timeout
#   datto+bsy       --> timeout (should look plain timeout)
#   datto+bsy+datab --> timeout with inital ack

set ibtout 63;                  # ibus timeout

#  [list [regbld ibd_ibmon::FLAGS to bsy nak ack ca be1 be0 we]
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS        nak     ca be1 be0 we] \
                                                     $itdata 0xdead 0] \
  [list [regbld ibd_ibmon::FLAGS        nak     ca be1 be0   ] \
                                                     $itdata {}     0] \
  [list [regbld ibd_ibmon::FLAGS    bsy nak     ca be1 be0 we] \
                                                     $itdata 0xdead 8] \
  [list [regbld ibd_ibmon::FLAGS        nak     ca be1 be0   ] \
                                                     $itdata {}     0] \
  [list [regbld ibd_ibmon::FLAGS        nak     ca be1 be0 we] \
                                                     $itdata 0xdead 0] \
  [list [regbld ibd_ibmon::FLAGS    bsy nak     ca be1 be0   ] \
                                                     $itdata {}     8] \
  [list [regbld ibd_ibmon::FLAGS    bsy nak ack ca be1 be0 we] \
                                                     $itdata 0xdead 8] \
  [list [regbld ibd_ibmon::FLAGS    bsy nak ack ca be1 be0   ] \
                                                     $itdata {}     8] \
  [list [regbld ibd_ibmon::FLAGS to bsy nak     ca be1 be0 we] \
                                                     $itdata 0xdead $ibtout] \
  [list [regbld ibd_ibmon::FLAGS to bsy nak     ca be1 be0   ] \
                                                     $itdata {}     $ibtout] \
  [list [regbld ibd_ibmon::FLAGS to bsy nak     ca be1 be0 we] \
                                                     $itdata 0xdead $ibtout] \
  [list [regbld ibd_ibmon::FLAGS to bsy nak     ca be1 be0   ] \
                                                     $itdata {}     $ibtout] \
  [list [regbld ibd_ibmon::FLAGS to bsy nak ack ca be1 be0 we] \
                                                     $itdata 0xdead $ibtout] \
  [list [regbld ibd_ibmon::FLAGS to bsy nak ack ca be1 be0   ] \
                                                     $itdata {}     $ibtout]

ibd_ibmon::start $cpu
$cpu cp \
  -wreg it.cntl [regbld ibd_ibtst::CNTL                       remw remr] \
  -wm   0xdead -estaterr \
  -rm          -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL             bsyw      remw remr] \
  -wm   0xdead -estaterr \
  -rm          -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL                  bsyr remw remr] \
  -wm   0xdead -estaterr \
  -rm          -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL datab       bsyw bsyr remw remr] \
  -wm   0xdead -estaterr \
  -rm          -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL       datto           remw remr] \
  -wm   0xdead -estaterr \
  -rm          -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL       datto bsyw bsyr remw remr] \
  -wm   0xdead -estaterr \
  -rm          -estaterr \
  -wreg it.cntl [regbld ibd_ibtst::CNTL datab datto bsyw bsyr remw remr] \
  -wm   0xdead -estaterr \
  -rm          -estaterr
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

# -- Section B ---------------------------------------------------------------
rlc log "  B fifo basics ---------------------------------------------"
rlc log "    B1: fifo  read test (write  2, read 3) -------------"
# use remw locr
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0101 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0102 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0   ] $itfifo 0x0101 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0   ] $itfifo 0x0102 0] \
  [list [regbld ibd_ibmon::FLAGS nak     ca    be1 be0   ] $itfifo {}     0] \

ibd_ibmon::start $cpu
$cpu cp \
  -wal  $itfifo \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL fclr remw locr] \
  -wbibr it.fifo {0x0101 0x0102} \
  -brf   3 -edone 2 -edata {0x0101 0x0102} -estaterr
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    B2: fifo write test (write 16, read 15) ------------"
# use locw remr
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x0200 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x0201 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x0202 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x0203 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x0204 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x0205 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x0206 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x0207 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x0208 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x0209 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x020a 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x020b 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x020c 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x020d 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca    be1 be0 we] $itfifo 0x020e 0] \
  [list [regbld ibd_ibmon::FLAGS nak     ca    be1 be0 we] $itfifo 0x020f 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0200 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0201 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0202 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0203 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0204 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0205 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0206 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0207 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0208 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0209 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x020a 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x020b 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x020c 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x020d 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x020e 0]

ibd_ibmon::start $cpu
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL fclr locw remr] \
  -bwf   {0x0200 0x0201 0x0202 0x0203 0x0204 0x0205 0x0206 0x0207  \
         0x0208 0x0209 0x020a 0x020b 0x020c 0x020d 0x020e 0x020f} \
         -edone 15 -estaterr \
  -rbibr it.fifo 15 \
         -edata {0x0200 0x0201 0x0202 0x0203 0x0204 0x0205 0x0206 0x0207 \
                 0x0208 0x0209 0x020a 0x020b 0x020c 0x020d 0x020e}
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

# -- Section C ---------------------------------------------------------------
rlc log "  C test repeat collapes ------------------------------------"
rlc log "    C1: dry run, no collapse active --------------------"
# use remw remr (for simplicity)
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0300 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0301 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0302 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0303 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0300 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0301 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0302 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0303 0]

ibd_ibmon::start $cpu
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL fclr remw remr] \
  -wbibr it.fifo          {0x0300 0x0301 0x0302 0x0303} \
  -rbibr it.fifo 4 -edata {0x0300 0x0301 0x0302 0x0303}
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    C2.1: read collapse active -------------------------"
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0400 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0401 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0402 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0403 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0400 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0403 0]

ibd_ibmon::start $cpu rcolr 1
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL fclr remw remr] \
  -wbibr it.fifo          {0x0400 0x0401 0x0402 0x0403} \
  -rbibr it.fifo 4 -edata {0x0400 0x0401 0x0402 0x0403}
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    C2.2: write collapse active ------------------------"
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0500 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0503 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0500 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0501 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0502 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0503 0]

ibd_ibmon::start $cpu rcolw 1
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL fclr remw remr] \
  -wbibr it.fifo          {0x0500 0x0501 0x0502 0x0503} \
  -rbibr it.fifo 4 -edata {0x0500 0x0501 0x0502 0x0503}
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    C2.3: read and write collapse active ---------------"
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0600 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0603 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0600 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0603 0]

ibd_ibmon::start $cpu rcolw 1 rcolr 1
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL fclr remw remr] \
  -wbibr it.fifo          {0x0600 0x0601 0x0602 0x0603} \
  -rbibr it.fifo 4 -edata {0x0600 0x0601 0x0602 0x0603}
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    C2.4: non-collapse of write-read same address ------"
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0700 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0700 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0701 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0701 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0702 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0702 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0703 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0703 0]

ibd_ibmon::start $cpu rcolw 1 rcolr 1
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL fclr remw remr] \
  -wibr  it.fifo        0x0700 \
  -ribr  it.fifo -edata 0x0700 \
  -wibr  it.fifo        0x0701 \
  -ribr  it.fifo -edata 0x0701 \
  -wibr  it.fifo        0x0702 \
  -ribr  it.fifo -edata 0x0702 \
  -wibr  it.fifo        0x0703 \
  -ribr  it.fifo -edata 0x0703
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

rlc log "    C2.5: non-collapse of reads to different address ---"
ibd_ibmon::raw_edata edat emsk \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itdata 0xbabe 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0800 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0 we] $itfifo 0x0803 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0800 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itdata 0xbabe 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0801 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itdata 0xbabe 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0802 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itdata 0xbabe 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itfifo 0x0803 0] \
  [list [regbld ibd_ibmon::FLAGS     ack ca ra be1 be0   ] $itdata 0xbabe 0]

ibd_ibmon::start $cpu rcolw 1 rcolr 1
$cpu cp \
  -wreg  it.cntl [regbld ibd_ibtst::CNTL fclr remw remr] \
  -wibr  it.data 0xbabe \
  -wbibr it.fifo {0x0800 0x0801 0x0802 0x0803} \
  -ribr  it.fifo -edata 0x0800 \
  -ribr  it.data -edata 0xbabe \
  -ribr  it.fifo -edata 0x0801 \
  -ribr  it.data -edata 0xbabe \
  -ribr  it.fifo -edata 0x0802 \
  -ribr  it.data -edata 0xbabe \
  -ribr  it.fifo -edata 0x0803 \
  -ribr  it.data -edata 0xbabe
ibd_ibmon::stop $cpu
if {$print} {puts [ibd_ibmon::print $cpu]}
ibd_ibmon::raw_check $cpu $edat $emsk

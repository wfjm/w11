# $Id: test_cp_gr.tcl 1346 2023-01-06 12:56:08Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2013-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-01-05  1346   1.0.2  streamline, use longer command chains
# 2022-10-27  1309   1.0.1  rename _gpr -> _gr
# 2013-03-31   502   1.0    Initial version
#
# Test that general registers are writable and readable via cp
# check all 16 registers, especially that
#   set 0 and 1 are distinct
#   k,s,u mode sp are distinct
#

# ----------------------------------------------------------------------------
rlc log "test_cp_gr: test cp access to general registers ---------------------"
rlc log "  write set 0"
$cpu cp -wps 0000000 \
        -wr0 0000001 \
        -wr1 0000101 \
        -wr2 0000201 \
        -wr3 0000301 \
        -wr4 0000401 \
        -wr5 0000501

rlc log "  write set 1"
$cpu cp -wps [regbld rw11::PSW rset] \
        -wr0 0010001 \
        -wr1 0010101 \
        -wr2 0010201 \
        -wr3 0010301 \
        -wr4 0010401 \
        -wr5 0010501

rlc log "  write all sp and pc"
$cpu cp -wps [regbld rw11::PSW {cmode k}] -wsp 0000601 \
        -wps [regbld rw11::PSW {cmode s}] -wsp 0010601 \
        -wps [regbld rw11::PSW {cmode u}] -wsp 0020601 \
        -wps [regbld rw11::PSW {cmode k}] -wpc 0000701

rlc log "  read set 0"
$cpu cp -wps 0000000 \
        -rr0 -edata 0000001 \
        -rr1 -edata 0000101 \
        -rr2 -edata 0000201 \
        -rr3 -edata 0000301 \
        -rr4 -edata 0000401 \
        -rr5 -edata 0000501

rlc log "  read set 1"
$cpu cp -wps [regbld rw11::PSW rset] \
        -rr0 -edata 0010001 \
        -rr1 -edata 0010101 \
        -rr2 -edata 0010201 \
        -rr3 -edata 0010301 \
        -rr4 -edata 0010401 \
        -rr5 -edata 0010501

rlc log "  read all sp and pc"
$cpu cp -wps [regbld rw11::PSW {cmode k}] -rsp -edata 0000601 \
        -wps [regbld rw11::PSW {cmode s}] -rsp -edata 0010601 \
        -wps [regbld rw11::PSW {cmode u}] -rsp -edata 0020601 \
        -wps [regbld rw11::PSW {cmode k}] -rpc -edata 0000701

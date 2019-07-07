# $Id: test_mem.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2019-01-04  1103   1.1    add very basic low level interface tests
# 2018-12-28  1096   1.0    Initial version
#

package provide tst_mig 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval tst_mig {
  #
  # test_regs: Test register access
  #
  proc test_mem {} {
    variable mwidth
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "tst_mig::test_mem ----------------------------------------------"
    rlc log "  test 1: check memory status: pend,uirst=0 and caco=1"
    rlc exec \
      -rreg mt.stat -edata [regbld tst_mig::STAT caco] \
                           [regbld tst_mig::STAT zqpend refpend uirst caco]
    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: basic write read back"
    set dat0 {0x0000 0x0001 0x0002 0x0003}
    set dat1 {0x0100 0x0101 0x0102 0x0103}
    set dat2 {0x0200 0x0201 0x0202 0x0203}
    if {[iswide]} {
      lappend dat0  0x0004 0x0005 0x0006 0x0007
      lappend dat1  0x0104 0x0105 0x0106 0x0107
      lappend dat2  0x0204 0x0205 0x0206 0x0207
    }
    write  0x0000 $dat0
    write  0x0010 $dat1
    write  0x8020 $dat2
    readck 0x0000 $dat0
    readck 0x0010 $dat1
    readck 0x8020 $dat2
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3: masked write and read back"
    set datr {0x0200 0x0201 0x0202 0x0203}
    set datw {0xf0e0 0xf1e1 0xf2e2 0xf3e3}
    if {[iswide]} {
      lappend datr  0x0204 0x0205 0x0206 0x0207
      lappend datw  0xf4e4 0xf5e5 0xf6e6 0xf7e7
    }
    write  0x8020 $datw 0xffff;         # mask = ffff (all disabled)
    readck 0x8020 $datr

    set mask 0xfffe;                    # first byte enabled, others masked off
    for {set iw 0} {$iw < $mwidth/2} {incr iw} {
      set wold [lindex $datr $iw]
      set wmod [lindex $datw $iw]
      lset datr $iw [expr {($wold & 0xff00) | ($wmod & 0x00ff)}]
      write  0x8020 $datw $mask;        # overwrite low byte
      readck 0x8020 $datr
      lset datr $iw $wmod
      set mask [expr {($mask<<1) & 0xffff}]
      write  0x8020 $datw $mask;        # overwrite high byte
      readck 0x8020 $datr
      set mask [expr {($mask<<1) & 0xffff}]
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 4: REF and CAL functions; show latencies"
    rlc exec \
      -rreg mt.rwait rwait \
      -wreg mt.cntl [regbld tst_mig::CNTL {func "REF"}]
    rlc exec \
      -rreg mt.stat -edata 0x0 [regbld tst_mig::STAT zqpend refpend] \
      -rreg mt.xwait refwait \
      -wreg mt.cntl [regbld tst_mig::CNTL {func "CAL"}]
    rlc exec \
      -rreg mt.stat -edata 0x0 [regbld tst_mig::STAT zqpend refpend] \
      -rreg mt.xwait calwait
    rlc log [format "    # rwait: %2d  refwait: %2d  calwait: %2d" \
               $rwait $refwait $calwait]
    #
    #-------------------------------------------------------------------------
    rlc log "  test 5: CMD function - low level write/read"
    rlc exec \
      -wreg mt.mask    0x0000 \
      -wreg mt.addrh   0x0000 \
      -wreg mt.addrl   0x4400 \
      -wreg mt.datwr0  0x4400 \
      -wreg mt.datwr1  0x4401 \
      -wreg mt.datwr2  0x4402 \
      -wreg mt.datwr3  0x4403 \
      -wreg mt.cntl [regbld tst_mig::CNTL wren {cmd "WR"} {func "CMD"}] \
      -wreg mt.addrl   0x4500 \
      -wreg mt.datwr0  0x4500 \
      -wreg mt.datwr1  0x4501 \
      -wreg mt.datwr2  0x4502 \
      -wreg mt.datwr3  0x4503 \
      -wreg mt.cntl [regbld tst_mig::CNTL wren {cmd "WR"} {func "CMD"}]
    rlc exec \
      -wreg mt.addrl   0x4400 \
      -wreg mt.cntl [regbld tst_mig::CNTL {cmd "RD"} {func "CMD"}] \
      -rreg mt.datrd0  -edata 0x4400 \
      -rreg mt.datrd1  -edata 0x4401 \
      -rreg mt.datrd2  -edata 0x4402 \
      -rreg mt.datrd3  -edata 0x4403 \
      -wreg mt.addrl   0x4500 \
      -wreg mt.cntl [regbld tst_mig::CNTL {cmd "RD"} {func "CMD"}] \
      -rreg mt.datrd0  -edata 0x4500 \
      -rreg mt.datrd1  -edata 0x4501 \
      -rreg mt.datrd2  -edata 0x4502 \
      -rreg mt.datrd3  -edata 0x4503

    #
    #-------------------------------------------------------------------------
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}

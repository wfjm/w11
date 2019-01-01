# $Id: test_regs.tcl 1095 2018-12-28 11:53:13Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2018-12-28  1095   1.0    Initial version
#

package provide tst_mig 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval tst_mig {
  #
  # test_regs: Test register access
  #
  proc test_regs {} {
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "tst_mig::test_regs ---------------------------------------------"
    rlc log "  test 1a: test stat,..,initime readable"
    rlc exec \
      -rreg mt.stat    \
      -rreg mt.conf    \
      -rreg mt.mask    \
      -rreg mt.addrl   \
      -rreg mt.addrh   \
      -rreg mt.temp    \
      -rreg mt.dvalcnt \
      -rreg mt.crpat   \
      -rreg mt.wrpat   \
      -rreg mt.cwait   \
      -rreg mt.rwait   \
      -rreg mt.xwait   \
      -rreg mt.ircnt   \
      -rreg mt.rsttime \
      -rreg mt.initime
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1b: test stat,conf,temp,initime not writable"
    rlc exec \
      -wreg mt.stat    0x0 -estaterr \
      -wreg mt.conf    0x0 -estaterr \
      -wreg mt.temp    0x0 -estaterr \
      -wreg mt.dvalcnt 0x0 -estaterr \
      -wreg mt.crpat   0x0 -estaterr \
      -wreg mt.wrpat   0x0 -estaterr \
      -wreg mt.cwait   0x0 -estaterr \
      -wreg mt.rwait   0x0 -estaterr \
      -wreg mt.xwait   0x0 -estaterr \
      -wreg mt.ircnt   0x0 -estaterr \
      -wreg mt.rsttime 0x0 -estaterr \
      -wreg mt.initime 0x0 -estaterr
    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: test mask,addrl,addrh write and read back"
    rlc exec \
      -wreg mt.mask    0x00ff \
      -wreg mt.addrl   0xdead \
      -wreg mt.addrh   0xbeaf \
      -rreg mt.mask    -edata 0x00ff \
      -rreg mt.addrl   -edata 0xdead \
      -rreg mt.addrh   -edata 0xbeaf \
      -wreg mt.mask    0xff00 \
      -wreg mt.addrl   0xf0f0 \
      -wreg mt.addrh   0x0f0f \
      -rreg mt.mask    -edata 0xff00 \
      -rreg mt.addrl   -edata 0xf0f0 \
      -rreg mt.addrh   -edata 0x0f0f
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3a: test datrd readable and not writable"
    rlc exec \
      -rreg mt.datrd0  \
      -rreg mt.datrd1  \
      -rreg mt.datrd2  \
      -rreg mt.datrd3  \
      -rreg mt.datrd4  \
      -rreg mt.datrd5  \
      -rreg mt.datrd6  \
      -rreg mt.datrd7  \
      -rreg mt.datrd0  \
      -wreg mt.datrd1  0x0 -estaterr \
      -wreg mt.datrd2  0x0 -estaterr \
      -wreg mt.datrd3  0x0 -estaterr \
      -wreg mt.datrd4  0x0 -estaterr \
      -wreg mt.datrd5  0x0 -estaterr \
      -wreg mt.datrd6  0x0 -estaterr \
      -wreg mt.datrd7  0x0 -estaterr
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3b: test datwr write and read back"
    rlc exec \
      -wreg mt.datwr0 0x0100 \
      -wreg mt.datwr1 0x0302 \
      -wreg mt.datwr2 0x0504 \
      -wreg mt.datwr3 0x0706 \
      -wreg mt.datwr4 0x0908 \
      -wreg mt.datwr5 0x0b0a \
      -wreg mt.datwr6 0x0d0c \
      -wreg mt.datwr7 0x0f0e \
      -rreg mt.datwr0 -edata 0x0100 \
      -rreg mt.datwr1 -edata 0x0302 \
      -rreg mt.datwr2 -edata 0x0504 \
      -rreg mt.datwr3 -edata 0x0706 \
      -rreg mt.datwr4 -edata 0x0908 \
      -rreg mt.datwr5 -edata 0x0b0a \
      -rreg mt.datwr6 -edata 0x0d0c \
      -rreg mt.datwr7 -edata 0x0f0e
    #
    #-------------------------------------------------------------------------
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}

# $Id: test_flow.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2016-06-18   777   1.0    Initial version
#

package provide rbtest 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval rbtest {
  #
  # Test flow control
  #
  proc test_flow {{bufmax 512} {bufmin 4}} {
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbtest::test_flow - init: clear cntl"
    rlc exec -init te.cntl [regbld rbtest::INIT cntl]
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1: create back pressure with wblk after a rblk"
    set rbase 0x8000
    set wbase 0xc000
    set nw $bufmin
    set nmax [expr {[rlc get bsizeprudent] / 2}];    # /2 because rblk and wblk !
    if {$bufmax < $nmax} {set nmax $bufmax}
    while {$nw <= $nmax} {
      rlc log [format "    buffer size: %4d" $nw]
      set rbuf {}
      set wbuf {}
      for {set i 0} {$i < $nw} {incr i} {
        lappend rbuf [expr {$rbase + $i}]
        lappend wbuf [expr {$wbase + $i}]
      }
      rlc exec \
        -wreg te.data $rbase \
        -rblk te.dinc $nw  -edata $rbuf -edone $nw \
        -wreg te.data $wbase \
        -wblk te.dinc $wbuf \
        -rreg te.cntl -edata 0
      set nw [expr {2*$nw}]
      incr rbase 0x0400
      incr wbase 0x0400
    }
    #
    #-------------------------------------------------------------------------
    rlc log "rbtest::test_flow - cleanup: clear cntl"
    rlc exec -init te.cntl [regbld rbtest::INIT cntl]
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}

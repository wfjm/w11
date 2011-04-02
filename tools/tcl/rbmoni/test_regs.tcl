# $Id: test_regs.tcl 375 2011-04-02 07:56:47Z mueller $
#
# Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2, or at your option any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2011-03-27   374   1.0    Initial version
# 2011-03-13   369   0.1    First Draft
#

package provide rbmoni 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval rbmoni {
  #
  # Basic tests with rbtester registers
  #
  proc test_regs {} {
    set esdval 0x00
    set esdmsk [regbld rlink::STAT {stat -1}]
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbmoni::test_regs - start"
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1: write/read cntl"
    foreach val [list [regbld rbmoni::CNTL go] 0x0] {
      rlc exec -estatdef $esdval $esdmsk \
        -wreg rm.cntl $val \
        -rreg rm.cntl -edata $val
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: write/read alim"
    foreach val [list [regbld rbmoni::ALIM {hilim 0x00} {lolim 0x00}] \
                      [regbld rbmoni::ALIM {hilim 0xff} {lolim 0xff}] \
                      [regbld rbmoni::ALIM {hilim 0x00} {lolim 0xff}] \
                      [regbld rbmoni::ALIM {hilim 0xff} {lolim 0x00}]
                ] {
      rlc exec -estatdef $esdval $esdmsk \
        -wreg rm.alim $val \
        -rreg rm.alim -edata $val
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3: write/read addr"
    set amax [regget rbmoni::ADDR(laddr) -1]
    foreach {laddr waddr} [list 0x0000 0 0x0000 3 $amax 0 $amax 3] {
      set addr [regbld rbmoni::ADDR [list laddr $laddr] [list waddr $waddr]]
      rlc exec -estatdef $esdval $esdmsk \
        -wreg rm.addr $addr \
        -rreg rm.addr -edata $addr
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 4: verify that cntl.go 0->1 clear addr"
    rlc exec -estatdef $esdval $esdmsk \
      -wreg rm.cntl 0x0 \
      -rreg rm.cntl -edata 0x0 \
      -wreg rm.addr [regbld rbmoni::ADDR [list laddr $amax]] \
      -rreg rm.addr -edata [regbld rbmoni::ADDR [list laddr $amax]] \
      -wreg rm.cntl [regbld rbmoni::CNTL go] \
      -rreg rm.cntl -edata [regbld rbmoni::CNTL go] \
      -rreg rm.addr -edata 0x00 \
      -wreg rm.cntl 0x0 \
      -rreg rm.cntl -edata 0x0
    #
    #-------------------------------------------------------------------------
    rlc log "rbmoni::test_regs - cleanup"
    rbmoni::init
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}

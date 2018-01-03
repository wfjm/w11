# $Id: test_regs.tcl 985 2018-01-03 08:59:40Z mueller $
#
# Copyright 2011-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2017-04-29   888   3.1    add data/addr logic tests
# 2017-04-13   873   3.0    adopt to revised interface
# 2015-04-03   661   2.1    drop estatdef (stat err check default now)
# 2014-12-27   622   2.0    rbd_rbmon reorganized, supports now 16 bit addresses
# 2011-03-27   374   1.0    Initial version
# 2011-03-13   369   0.1    First Draft
#

package provide rbmoni 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval rbmoni {
  #
  # Basic access tests for rbmoni registers
  #
  proc test_regs {} {
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbmoni::test_regs - start"
    #
    #-------------------------------------------------------------------------
    rlc log "  A basic register access tests -----------------------------"
    rlc log "    A1: write/read cntl---------------------------------"
    # test that starting caputes option flags, and that stoping keeps them
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STA"}] \
      -rreg rm.cntl -edata [regbld rbmoni::CNTL] \
      -wreg rm.cntl [regbld rbmoni::CNTL wstop {func "STA"}] \
      -rreg rm.cntl -edata  [regbld rbmoni::CNTL wstop] \
      -wreg rm.cntl [regbld rbmoni::CNTL rcolr {func "STA"}] \
      -rreg rm.cntl -edata  [regbld rbmoni::CNTL rcolr] \
      -wreg rm.cntl [regbld rbmoni::CNTL rcolw {func "STA"}] \
      -rreg rm.cntl -edata  [regbld rbmoni::CNTL rcolw] \
      -wreg rm.cntl [regbld rbmoni::CNTL rcolw rcolr {func "STA"}] \
      -rreg rm.cntl -edata  [regbld rbmoni::CNTL rcolw rcolr] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STO"}] \
      -rreg rm.cntl -edata  [regbld rbmoni::CNTL rcolw rcolr] 
    #
    #-------------------------------------------------------------------------
    rlc log "    A2: write cntl, read stat --------------------------"
    # test that susp/run follow functions set to cntl
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STA"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT run] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "SUS"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT susp run] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "RES"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT run] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STO"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT]
    # test that suspend/resume of a stopped system is a noop
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "SUS"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "RES"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT]
    # test that start of a suspended system clears suspend
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STA"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT run] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "SUS"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT susp run] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STA"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT run]
    # test that suspend of a suspended system is a noop
    # test that stop of a suspended system clears suspend
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STA"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT run] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "SUS"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT susp run] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "SUS"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT susp run] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STO"}] \
      -rreg rm.stat -edata [regbld rbmoni::STAT]
    # get amax for later usage
    rlc exec \
      -rreg rm.stat rstat
    set bsize [regget rbmoni::STAT(bsize) $rstat]
    set amax  [expr {( 512 << $bsize ) - 1}]
    #
    #-------------------------------------------------------------------------
    rlc log "    A3: write/read hilim/lolim -------------------------"
    foreach {lolim hilim} {0xffff 0x0000 \
                           0x0000 0xfffb} {
      rlc exec \
        -wreg rm.lolim $lolim -wreg rm.hilim $hilim \
        -rreg rm.lolim -edata $lolim -rreg rm.hilim -edata $hilim
    }
    #
    #-------------------------------------------------------------------------
    rlc log "    A4: test addr --------------------------------------"
    rlc log "    A4.1: write/read addr when stopped -----------------"
    foreach {laddr waddr} [list 0x0000 0 0x0000 3 $amax 0 $amax 3] {
      set addr [regbld rbmoni::ADDR [list laddr $laddr] [list waddr $waddr]]
      rlc exec \
        -wreg rm.addr $addr \
        -rreg rm.addr -edata $addr
    }
    #
    #-------------------------------------------------------------------------
    rlc log "    A4.2: verify that starting clears addr -------------"
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STO"}] \
      -wreg rm.addr [regbld rbmoni::ADDR [list laddr $amax]] \
      -rreg rm.addr -edata [regbld rbmoni::ADDR [list laddr $amax]] \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STA"}] \
      -rreg rm.addr -edata 0x00 \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STO"}]
    #
    #-------------------------------------------------------------------------
    rlc log "    A4.3: test err when started and addr written -------"
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STA"}] \
      -wreg rm.addr 0x100 -estaterr \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STO"}]
    #
    #-------------------------------------------------------------------------
    rlc log "    A5: test data --------------------------------------"
    rlc log "    A5.1: when stopped ---------------------------------"
    # stop, set addr, and four times data, check addr
    # at 5th data read waddr goes 0 and laddr incs
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STO"}] \
      -wreg rm.addr [regbld rbmoni::ADDR {laddr 010} {waddr 0}] \
      -rreg rm.data \
      -rreg rm.addr -edata [regbld rbmoni::ADDR {laddr 010} {waddr 001}] \
      -rreg rm.data \
      -rreg rm.addr -edata [regbld rbmoni::ADDR {laddr 010} {waddr 002}] \
      -rreg rm.data \
      -rreg rm.addr -edata [regbld rbmoni::ADDR {laddr 010} {waddr 003}] \
      -rreg rm.data \
      -rreg rm.addr -edata [regbld rbmoni::ADDR {laddr 011} {waddr 000}]
    #
    #-------------------------------------------------------------------------
    rlc log "    A5.2: test err when written ------------------------"
    rlc exec -wreg rm.data 0x100 -estaterr
    
    #
    #-------------------------------------------------------------------------
    rlc log "rbmoni::test_regs - cleanup"
    rbmoni::init
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}

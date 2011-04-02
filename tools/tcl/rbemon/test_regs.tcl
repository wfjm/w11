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
# 2011-04-02   375   1.0    Initial version
#

package provide rbemon 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval rbemon {
  #
  # Basic tests with rbd_eyemon registers
  #
  proc test_regs {} {
    set esdval 0x00
    set esdmsk [regbld rlink::STAT {stat -1}]
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbemon::test_regs - start"
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1a: write/read cntl"
    # ensure that last value 0x0 -> go=0
    foreach val [list [regbld rbemon::CNTL ena01] [regbld rbemon::CNTL ena10] \
                      [regbld rbemon::CNTL go] 0x0 ] {
      rlc exec -estatdef $esdval $esdmsk \
        -wreg em.cntl $val \
        -rreg em.cntl -edata $val
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1b: write/read rdiv"
    foreach val [list [regbld rbemon::RDIV {rdiv -1}] 0x0 ] {
      rlc exec -estatdef $esdval $esdmsk \
        -wreg em.rdiv $val \
        -rreg em.rdiv -edata $val
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1c: write/read addr"
    set amax [regget rbemon::ADDR(addr) -1]
    foreach addr [list 0x1 $amax 0x0] {
      rlc exec -estatdef $esdval $esdmsk \
        -wreg em.addr $addr \
        -rreg em.addr -edata $addr
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: verify addr increments on data reads"
    foreach addr [list 0x0 0x011 [expr $amax - 1]] {
      rlc exec -estatdef $esdval $esdmsk \
        -wreg em.addr $addr \
        -rreg em.data \
        -rreg em.addr -edata [expr ( $addr + 1 ) & $amax] \
        -rreg em.data \
        -rreg em.addr -edata [expr ( $addr + 2 ) & $amax]
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3: verify rberr on DATA write and DATE read if in go state"
    rlc exec \
      -wreg em.data 0x0000 -estat [regbld rlink::STAT rberr] $esdmsk \
      -wreg em.cntl [regbld rbemon::CNTL go] -estat $esdval $esdmsk \
      -rreg em.data  -estat [regbld rlink::STAT rberr] $esdmsk 
    #
    #-------------------------------------------------------------------------
    rlc log "  test 4: verify that CNTL.clr returns to 0"
    set npoll 32
    set edat {}
    set emsk {}
    for {set i 0} {$i < $npoll} {incr i} { lappend edat 0x0000 }
    for {set i 1} {$i < $npoll} {incr i} { lappend emsk 0xffff }
    rlc exec -estatdef $esdval $esdmsk \
      -wreg em.cntl [regbld rbemon::CNTL clr] \
      -rblk em.cntl $npoll -edata $edat $emsk
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}

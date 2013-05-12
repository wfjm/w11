# $Id: test_data.tcl 516 2013-05-05 21:24:52Z mueller $
#
# Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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

package provide rbtest 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval rbtest {
  #
  # Basic tests with cntl and data registers.
  # All tests depend only on rbd_tester logic alone and not on how the
  # rbd_tester is embedded in the design (e.g. stat and attn connections)
  #
  proc test_data {} {
    set esdval 0x00
    set esdmsk [regbld rlink::STAT {stat -1}]
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbtest::test_data - init: clear cntl, data, and fifo"
    # Note: fifo clear via init is tested later, used here 'speculatively'
    rlc exec -init te.cntl [regbld rbtest::INIT fifo data cntl]
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1a: cntl, data are write- and read-able"
    foreach {addr valw valr} [list te.cntl 0xffff 0xf3ff \
                                   te.cntl 0x0000 0x0000 \
                                   te.data 0xffff 0xffff \
                                   te.data 0x0000 0x0000 ] {
      rlc exec -wreg $addr $valw -estat $esdval $esdmsk
      rlc exec -rreg $addr -edata $valr -estat $esdval $esdmsk
    }    
    #
    #
    rlc log "  test 1b: as test 1a, now use clists and check cntl/data distinct"
    foreach {valc vald} [list 0x0000 0x0000 [regbld rbtest::CNTL nofifo] 0xffff] {
      rlc exec -estatdef $esdval $esdmsk \
        -wreg te.cntl $valc \
        -wreg te.data $vald \
        -rreg te.cntl -edata $valc \
        -rreg te.data -edata $vald
    }
    #
    #
    rlc log "  test 1c: as test 1, now cntl.stat field is used"
    foreach stat {0x1 0x3 0x7 0x0} {
      set valc [regbld rbtest::CNTL [list stat $stat]]
      set vald [expr {$stat | ( $stat << 8 ) }]
      rlc exec -estatdef $esdval $esdmsk \
        -wreg te.cntl $valc \
        -wreg te.data $vald \
        -rreg te.cntl -edata $valc \
        -rreg te.data -edata $vald 
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: cntl.nbusy is write- and readable (last nbusy=0 again)"
    foreach nbusy {0x00f 0x0ff 0x3ff 0x000} {
      set valc [regbld rbtest::CNTL [list nbusy $nbusy]]
      rlc exec -estatdef $esdval $esdmsk \
        -wreg te.cntl $valc \
        -rreg te.cntl -edata $valc
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3: verify that large nbusy causes timeout"
    rlc exec -estatdef $esdval $esdmsk \
      -wreg te.data 0xdead \
      -rreg te.data -edata 0xdead \
      -wreg te.cntl [regbld rbtest::CNTL {nbusy 0x3ff}] \
      -wreg te.data 0xbeaf -estat [regbld rlink::STAT rbnak] $esdmsk \
      -rreg te.data        -estat [regbld rlink::STAT rbnak] $esdmsk \
      -wreg te.cntl 0x0000 \
      -rreg te.data -edata 0xdead -edata 0xdead
    #
    # -------------------------------------------------------------------------
    rlc log "  test 4a: verify that init 001 clears cntl and not data"
    set valc [regbld rbtest::CNTL nofifo {stat 0x3}]
    rlc exec -estatdef $esdval $esdmsk \
      -wreg te.cntl $valc \
      -wreg te.data 0x1234 \
      -init te.cntl [regbld rbtest::INIT cntl] \
      -rreg te.cntl -edata 0x0 \
      -wreg te.data 0x1234
    rlc log "  test 4b: verify that init 010 clears data and not cntl"
    set valc [regbld rbtest::CNTL {stat 0x7}]
    rlc exec -estatdef $esdval $esdmsk \
      -wreg te.cntl $valc \
      -wreg te.data 0x4321 \
      -init te.cntl [regbld rbtest::INIT data] \
      -rreg te.cntl -edata $valc \
      -wreg te.data 0x0
    rlc log "  test 4c: verify that init 011 clears data and cntl"
    rlc exec -estatdef $esdval $esdmsk \
      -wreg te.cntl [regbld rbtest::CNTL nofifo {stat 0x7} {nbusy 2}] \
      -wreg te.data 0xabcd \
      -init te.cntl [regbld rbtest::INIT data cntl] \
      -rreg te.cntl -edata 0x0 \
      -wreg te.data 0x0
    #
    # -------------------------------------------------------------------------
    rlc log "  test 5: test that te.attn returns # of cycles for te.data w&r"
    foreach nbusy {0x03 0x07 0x0f 0x1f 0x00} {
      set valc [regbld rbtest::CNTL [list nbusy $nbusy]]
      rlc exec -estatdef $esdval $esdmsk \
        -wreg te.cntl $valc \
        -wreg te.data [expr {$nbusy | ( $nbusy << 8 ) }] \
        -rreg te.attn -edata [expr {$nbusy + 1 }] \
        -rreg te.data -edata [expr {$nbusy | ( $nbusy << 8 ) }] \
        -rreg te.attn -edata [expr {$nbusy + 1 }] 
    }
    #
    # -------------------------------------------------------------------------
    rlc log "  test 6: verify stat command after te.data wreg & rreg"
    set rlist [rlc exec -rlist -estatdef $esdval $esdmsk \
                 -wreg te.data 0x1234 \
                 -stat ]
    #rlist like: {wreg 90 23 0} {stat 4 39 0 90 1}
    set xreg_ccode [lindex $rlist 0 1]
    set stat_ccode [lindex $rlist 1 4]
    if {$xreg_ccode != $stat_ccode} {
      rlc log " ---- stat ccmd mismatch, d=[pbvi o8 $xreg_ccode]! D=[pbvi o8 $stat_ccode] FAIL"
      incr errcnt
    }
    set rlist [rlc exec -rlist -estatdef $esdval $esdmsk \
                 -rreg te.data -edata 0x1234 \
                 -stat -edata 0x1234]
    #rlist like: {rreg 72 23 0 4660} {stat 12 39 0 72 4660}
    set xreg_ccode [lindex $rlist 0 1]
    set stat_ccode [lindex $rlist 1 4]
    if {$xreg_ccode != $stat_ccode} {
      rlc log " ---- stat ccmd mismatch, d=[pbvi o8 $xreg_ccode]! D=[pbvi o8 $stat_ccode] FAIL"
      incr errcnt
    }
    #
    #-------------------------------------------------------------------------
    rlc log "rbtest::test_data - cleanup: clear cntl and data"
    rlc exec -init te.cntl [regbld rbtest::INIT data cntl]
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}

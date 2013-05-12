# $Id: test_fifo.tcl 516 2013-05-05 21:24:52Z mueller $
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
# 2011-03-13   369   0.1    First draft
#

package provide rbtest 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval rbtest {
  #
  # Basic tests with cntl and fifo registers.
  #
  proc test_fifo {} {
    set esdval 0x00
    set esdmsk [regbld rlink::STAT {stat -1}]
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbtest::test_fifo - init: clear cntl, data, and fifo"
    # Note: fifo clear via init is tested later, used here 'speculatively'
    rlc exec -init te.cntl [regbld rbtest::INIT fifo data cntl]
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1: fifo write/read with wreg/rreg"
    # single word
    rlc exec -estatdef $esdval $esdmsk \
      -wreg te.fifo 0x0000 \
      -rreg te.fifo -estat 0x0000
    # three words
    rlc exec -estatdef $esdval $esdmsk \
      -wreg te.fifo 0xdead \
      -wreg te.fifo 0xbeaf \
      -wreg te.fifo 0x1234 \
      -rreg te.fifo -edata 0xdead \
      -rreg te.fifo -edata 0xbeaf \
      -rreg te.fifo -edata 0x1234 
    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: fifo write/read with wblk/rblk"
    # two words
    set blk {0x1111 0x2222}
    rlc exec -estatdef $esdval $esdmsk \
      -wblk te.fifo $blk \
      -rblk te.fifo [llength $blk] -edata $blk
    # six words
    set blk {0x3333 0x4444 0x5555 0x6666 0x7777 0x8888}
    rlc exec -estatdef $esdval $esdmsk \
      -wblk te.fifo $blk \
      -rblk te.fifo [llength $blk] -edata $blk
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3a: fifo read error (write 3, read 4)"
    set blk {0xdead 0xbeaf 0x1234}
    rlc exec -estatdef $esdval $esdmsk \
      -wblk te.fifo $blk \
      -rblk te.fifo 4 -edata $blk -estat [regbld rlink::STAT rberr] $esdmsk
    #
    #
    rlc log "  test 3b: fifo write error (write 17, read 16)"
    set blk {}
    for { set i 0 } { $i < 17 } { incr i } {
      lappend blk [expr {$i | ( $i << 8 ) }]
    }
    rlc exec -estatdef $esdval $esdmsk \
      -wblk te.fifo $blk -estat [regbld rlink::STAT rberr] $esdmsk \
      -rblk te.fifo 16 -edata [lrange $blk 0 15]
    #
    #-------------------------------------------------------------------------
    rlc log "  test 4a: verify that init 100 clears fifo ant not cntl&data"
    # check fifo empty; write a value; clear fifo via init; check fifo empty
    # check that cntl and data not affected
    rlc exec -estatdef $esdval $esdmsk \
      -wreg te.cntl [regbld rbtest::CNTL {stat 0x7}] \
      -wreg te.data 0x1234 \
      -rreg te.fifo -estat [regbld rlink::STAT rberr] $esdmsk \
      -wreg te.fifo 0x4321 \
      -init te.cntl [regbld rbtest::INIT fifo] \
      -rreg te.fifo -estat [regbld rlink::STAT rberr] $esdmsk \
      -rreg te.cntl -edata [regbld rbtest::CNTL {stat 0x7}] \
      -rreg te.data -edata 0x1234
    #
    #
    rlc log "  test 4b: verify fifo clear via nofifo flag in cntl"
    # write a value; set and clear nofifo flag in cntl; ckeck fifo empty
    rlc exec -estatdef $esdval $esdmsk \
      -wreg te.fifo 0x4321 \
      -wreg te.cntl [regbld rbtest::CNTL nofifo] \
      -wreg te.cntl 0x0000 \
      -rreg te.fifo -estat [regbld rlink::STAT rberr] $esdmsk
    #
    #-------------------------------------------------------------------------
    rlc log "  test 5: verify that nofifo causes a rbnak on fifo access"
    # write fifo; set nofifo in cntl; write/read fifo(->rbnak);
    #   clr nofifo in cntl; read fifo(->rberr)
    rlc exec -estatdef $esdval $esdmsk \
      -wreg te.fifo 0x12ab \
      -wreg te.cntl [regbld rbtest::CNTL nofifo] \
      -wreg te.fifo 0x12cd -estat [regbld rlink::STAT rbnak] $esdmsk \
      -rreg te.fifo        -estat [regbld rlink::STAT rbnak] $esdmsk \
      -wreg te.cntl 0x0000 \
      -rreg te.fifo        -estat [regbld rlink::STAT rberr] $esdmsk
    #
    #-------------------------------------------------------------------------
    rlc log "  test 6: test that te.attn returns # of cycles for te.fifo w&r"
    foreach nbusy {0x03 0x07 0x0f 0x1f 0x00} {
      set valc [regbld rbtest::CNTL [list nbusy $nbusy]]
      rlc exec -estatdef $esdval $esdmsk \
        -wreg te.cntl $valc \
        -wreg te.fifo [expr {$nbusy | ( $nbusy << 8 ) }] \
        -rreg te.attn -edata [expr {$nbusy + 1 }] \
        -rreg te.fifo -edata [expr {$nbusy | ( $nbusy << 8 ) }] \
        -rreg te.attn -edata [expr {$nbusy + 1 }]
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 7: verify escaping (all 256 byte codes transported)"
    for {set i 0} {$i < 8} {incr i} {
      set blk {}
      for {set j 0} {$j < 16} {incr j} {
        set bcode [expr {32 * $i + 2 * $j}]
        lappend blk [expr {( $bcode << 8 ) | ( $bcode + 1 )}]
      }
      rlc exec -estatdef $esdval $esdmsk \
        -wblk te.fifo $blk \
        -rblk te.fifo [llength $blk] -edata $blk
    }
    #
    # -------------------------------------------------------------------------
    rlc log "  test 8: verify stat command after te.data wblk & rblk"
    set blk {0x1234 0x2345}
    set rlist [rlc exec -rlist -estatdef $esdval $esdmsk \
                 -wblk te.fifo $blk \
                 -stat ]
    #puts $rlist
    #rlist like: {wblk 99 23 0} {stat 4 39 0 99 65279}
    set xreg_ccode [lindex $rlist 0 1]
    set stat_ccode [lindex $rlist 1 4]
    if {$xreg_ccode != $stat_ccode} {
      rlc log " ---- stat ccmd mismatch, d=[pbvi o8 $xreg_ccode]! D=[pbvi o8 $stat_ccode] FAIL"
      incr errcnt
    }
    set rlist [rlc exec -rlist -estatdef $esdval $esdmsk \
                 -rblk te.fifo [llength $blk] -edata $blk \
                 -stat -edata 0x2345]
    #puts $rlist
    #{rblk 97 23 0 {4660 9029}} {stat 12 39 0 97 9029}
    set xreg_ccode [lindex $rlist 0 1]
    set stat_ccode [lindex $rlist 1 4]
    if {$xreg_ccode != $stat_ccode} {
      rlc log " ---- stat ccmd mismatch, d=[pbvi o8 $xreg_ccode]! D=[pbvi o8 $stat_ccode] FAIL"
      incr errcnt
    }
    #
    #-------------------------------------------------------------------------
    rlc log "rbtest::test_fifo - cleanup: clear cntl, data, and fifo"
    rlc exec -init te.cntl [regbld rbtest::INIT fifo data cntl]
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}

# $Id: test_fifo.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2019-02-09  1109   2.2    adapt to fifo_simple (full at 15 writes)
# 2015-04-03   661   2.1    drop estatdef; use estaterr
# 2014-11-09   603   2.0    use rlink v4 address layout and iface
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
    rlc exec \
      -wreg te.fifo 0x0000 \
      -rreg te.fifo -estat 0x00
    # three words
    rlc exec \
      -wreg te.fifo 0xdead \
      -wreg te.fifo 0xbeaf \
      -wreg te.fifo 0x1234 \
      -rreg te.fifo -edata 0xdead \
      -rreg te.fifo -edata 0xbeaf \
      -rreg te.fifo -edata 0x1234 
    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: fifo write/read with wblk/rblk and -edone"
    # two words
    set blk {0x1111 0x2222}
    rlc exec \
      -wblk te.fifo $blk -edone [llength $blk] \
      -rblk te.fifo [llength $blk] -edata $blk -edone [llength $blk]
    # six words
    set blk {0x3333 0x4444 0x5555 0x6666 0x7777 0x8888}
    rlc exec \
      -wblk te.fifo $blk -edone [llength $blk] \
      -rblk te.fifo [llength $blk] -edata $blk -edone [llength $blk]
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3a: fifo read error (write 3, read 4) and -edone"
    set blk {0xdead 0xbeaf 0x1234}
    rlc exec \
      -wblk te.fifo $blk -edone [llength $blk] \
      -rblk te.fifo 4 -edata $blk -edone 3 -estaterr
    #
    #
    rlc log "  test 3b: fifo write error (write 17, read 15)"
    set blk {}
    for { set i 0 } { $i < 17 } { incr i } {
      lappend blk [expr {$i | ( $i << 8 ) }]
    }
    rlc exec \
      -wblk te.fifo $blk -edone 15 -estaterr \
      -rblk te.fifo 15 -edata [lrange $blk 0 14] -edone 15
    #
    #-------------------------------------------------------------------------
    rlc log "  test 4a: verify that init 100 clears fifo and not cntl&data"
    # check fifo empty; write a value; clear fifo via init; check fifo empty
    # check that cntl and data not affected
    rlc exec \
      -wreg te.cntl [regbld rbtest::CNTL {nbusy 0x1}] \
      -wreg te.data 0x1234 \
      -rreg te.fifo -estaterr \
      -wreg te.fifo 0x4321 \
      -init te.cntl [regbld rbtest::INIT fifo] \
      -rreg te.fifo -estaterr \
      -rreg te.cntl -edata [regbld rbtest::CNTL {nbusy 0x1}] \
      -rreg te.data -edata 0x1234
    #
    #-------------------------------------------------------------------------
    rlc log "  test 6: test that te.ncyc returns # of cycles for te.fifo w&r"
    foreach nbusy {0x03 0x07 0x0f 0x1f 0x00} {
      set valc [regbld rbtest::CNTL [list nbusy $nbusy]]
      rlc exec \
        -wreg te.cntl $valc \
        -wreg te.fifo [expr {$nbusy | ( $nbusy << 8 ) }] \
        -rreg te.ncyc -edata [expr {$nbusy + 1 }] \
        -rreg te.fifo -edata [expr {$nbusy | ( $nbusy << 8 ) }] \
        -rreg te.ncyc -edata [expr {$nbusy + 1 }]
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
      # write/read in two chunks of 8 words because fifo holds only 15 words
      rlc exec \
        -wblk te.fifo [lrange $blk 0 7] \
        -rblk te.fifo 8 -edata [lrange $blk 0 7] \
        -wblk te.fifo [lrange $blk 8 15] \
        -rblk te.fifo 8 -edata [lrange $blk 8 15]
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

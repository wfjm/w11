# $Id: test_all.tcl 985 2018-01-03 08:59:40Z mueller $
#
# Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2017-06-19   914   2.2    17bit support; use sstat(awidth); add isnarrow
# 2016-07-09   784   2.1    add test_all test driver
# 2014-11-23   606   2.0    use new rlink v4 iface
# 2014-08-14   582   1.0    Initial version
#

package provide tst_sram 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval tst_sram {
  #
  # test_all: Driver for all tst_sram tests
  #
  proc test_all {{tout 10.}} {
    #
    set errcnt 0
    tst_sram::init
    incr errcnt [test_regs]
    incr errcnt [test_seq $tout]

    puts "tst_sram::test_all errcnt = $errcnt --> [rutil::errcnt2txt $errcnt]"
    return $errcnt
  }

  #
  # test_sim: test suite for sim tests ---------------------------------------
  #   port of cmd_tst_sram_stress_sim.dat
  #
  proc test_sim {} {
    rlink::anena 1;             # enable attn notify
    rlc exec -attn;             # harvest spurious attn
    init
    scmd_write [test_scmdlist]

    set lmdi {0x0000 0x0000 \
              0xffff 0xffff \
              0x0000 0xffff \
              0xffff 0x0000 \
              0xaaaa 0xaaaa \
              0x5555 0x5555 }

    set lmaddr {0x0000 0x0000 \
                0x0003 0xffff \
                0x0000 0xffff \
                0x000f 0x0000 \
                0x000a 0xaaaa \
                0x0005 0x5555 }

    set lmaddr_ran {}
    for {set i 0} { $i < 3 } {incr i} {
      lappend lmaddr_ran [expr {int(65536*rand()) & 0x000f}]
      lappend lmaddr_ran [expr {int(65536*rand()) & 0xffff}]
    }

    srun_lists $lmdi $lmaddr
    srun_lists $lmdi $lmaddr_ran
    return
  }
  #
  # test_fpga: test suite for fpga tests -------------------------------------
  #   port of cmd_tst_sram_stress_fpga.dat
  #
  proc test_fpga {{wide -1} {tout 1000.}} {
    rlink::anena 1;             # enable attn notify
    rlc exec -attn;             # harvest spurious attn
    init
    scmd_write [test_scmdlist]

    set lmdi {0x0000 0x0000 \
              0xffff 0xffff \
              0x0000 0xffff \
              0xffff 0x0000 \
              0xaaaa 0xaaaa \
              0x5555 0x5555 \
              0x1e25 0x4e58 \
              0xa9d8 0xd6d4 \
              0xbcbd 0x0815 \
              0x7424 0x7466 }

    set lmdi_ran {}
    for {set i 0} { $i < 3 } {incr i} {
      lappend lmdi_ran [expr {int(65536*rand()) & 0xffff}]
      lappend lmdi_ran [expr {int(65536*rand()) & 0xffff}]
    }

    if {$wide < 0} { set wide [iswide] }

    set maddrh 0x0000
    set maddrl 0x0000
    if {[rlink::issim]} {
      set maddrh [expr {[iswide] ? 0x3f : [isnarrow] ? 0x01: 0x03}]
      set maddrl 0xfffc
    }

    foreach {mdih mdil} $lmdi {
      srun_loop $mdih $mdil $maddrh $maddrl $wide $tout
    }
    foreach {mdih mdil} $lmdi_ran {
      srun_loop $mdih $mdil $maddrh $maddrl $wide $tout
    }
    return
  }
}

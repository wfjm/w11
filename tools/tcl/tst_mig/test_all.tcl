# $Id: test_all.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2018-12-27  1094   1.0    Initial version
#

package provide tst_mig 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval tst_mig {
  #
  # test_all: Driver for all tst_mig tests
  #
  proc test_all {{tout 10.}} {
    #
    set errcnt 0
    tst_mig::setup
    incr errcnt [test_regs]
    incr errcnt [test_mem]

    puts "tst_mig::test_all errcnt = $errcnt --> [rutil::errcnt2txt $errcnt]"
    return $errcnt
  }

}

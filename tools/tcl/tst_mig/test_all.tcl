# $Id: test_all.tcl 1094 2018-12-27 15:18:27Z mueller $
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

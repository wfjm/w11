# $Id: test_all.tcl 985 2018-01-03 08:59:40Z mueller $
#
# Copyright 2011-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2016-06-18   777   1.2    add test_flow
# 2015-04-03   662   1.1    add test_labo
# 2011-03-27   374   1.0    Initial version
# 2011-03-13   369   0.1    First draft
#

package provide rbtest 1.0

namespace eval rbtest {
  #
  # Driver for all rbtest tests
  #
  proc test_all {{statmsk 0x0} {attnmsk 0x0}} {
    #
    set errcnt 0
    incr errcnt [rbtest::test_data]
    incr errcnt [rbtest::test_fifo]
    incr errcnt [rbtest::test_labo]
    incr errcnt [rbtest::test_stat $statmsk]
    incr errcnt [rbtest::test_attn $attnmsk]
    incr errcnt [rbtest::test_flow 256]
    return $errcnt
  }
}

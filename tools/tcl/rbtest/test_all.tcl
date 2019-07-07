# $Id: test_all.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2011-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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

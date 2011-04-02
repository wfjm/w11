# $Id: test_all.tcl 375 2011-04-02 07:56:47Z mueller $
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
# 2011-03-26   373   0.1    First draft
#

package provide tst_rlink 1.0

package require rbtest
package require rbmoni

namespace eval tst_rlink {
  #
  # Driver for all tst_rlink tests
  #
  proc test_all {} {
    #
    set errcnt 0
    incr errcnt [rbtest::test_all 0x7 0xfffc]
    incr errcnt [rbmoni::test_regs]
    incr errcnt [rbmoni::test_rbtest]
    incr errcnt [rbemon::test_regs]

    puts "tst_rlink::test_all errcnt = $errcnt --> [rutil::errcnt2txt $errcnt]"

    return $errcnt
  }
}

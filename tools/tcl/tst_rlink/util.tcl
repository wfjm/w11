# $Id: util.tcl 375 2011-04-02 07:56:47Z mueller $
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
# 2011-03-19   372   0.1    First draft
#

package provide tst_rlink 1.0

package require rlink
package require rbtest
package require rbmoni
package require rbbram
package require rbs3hio
package require rbemon

namespace eval tst_rlink {
  #
  # setup: amap definitions for tst_rlink
  # 
  proc setup {} {
    rlc amap -clear;                    # clear first to allow re-run
    rbmoni::setup  [bvi b 11111100]
    rbemon::setup  [bvi b 11111000]
    rbbram::setup  [bvi b 11110100]
    rbtest::setup  [bvi b 11110000]
    rlc amap -insert timer.1 [bvi b 11100001]
    rlc amap -insert timer.0 [bvi b 11100000]
    rbs3hio::setup [bvi b 11000000]
  }

  #
  # init: reset tst_rlink design to initial state
  #
  proc init {} {
    rlink::init;                        # reset rlink
    rbtest::init
    rbbram::init
    rbmoni::init
    rbs3hio::init
    rbemon::init
    rlink::init;                        # re-reset rlink
  }
}

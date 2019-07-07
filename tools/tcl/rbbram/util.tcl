# $Id: util.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2011-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2017-04-22   883   2.0.1  setup: now idempotent
# 2014-11-09   603   2.0    use rlink v4 address layout
# 2011-03-19   372   1.0    Initial version
#

package provide rbbram 1.0

namespace eval rbbram {
  #
  # setup register descriptions for rbd_bram
  #
  regdsc CNTL {nbusy 15 6} {addr 9 10}
  #
  # setup: amap definitions for rbd_bram
  # 
  proc setup {base} {
    if {[rlc amap -testname br.cntl $base]} {return}
    rlc amap -insert br.cntl [expr {$base + 0x00}]
    rlc amap -insert br.data [expr {$base + 0x01}]
  }
  #
  # init: reset rbd_bram (clear cntl register)
  # 
  proc init {} {
    rlc exec -wreg br.cntl 0x0000
  }
}

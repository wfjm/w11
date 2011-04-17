# $Id: perf.tcl 376 2011-04-17 12:24:07Z mueller $
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
# 2011-04-17   376   1.0    Initial version
#

package provide tst_rlink 1.0

namespace eval tst_rlink {
  #
  # perf_wtlam: determine wtlam latency using timer.0
  # 
  proc perf_wtlam {{tmax 1000}} {
    if {$tmax < 1} { error "-E: perf_wtlam: tmax argument must be >= 1" }

    set rval "delay  latency"

    rlc exec -init 0xff [regbld rlink::INIT anena]

    for {set dly 250} {$dly <= 10000} {incr dly 250} {
      rlc exec \
        -wreg timer.0 0 \
        -wreg timer.1 0 
      rlc exec -attn

      set tbeg [clock clicks -milliseconds]
      rlc exec -wreg timer.0 $dly
      for {set i 1} {1} {incr i} {
        rlc wtlam 1.
        rlc exec \
          -attn \
          -wreg timer.0 $dly
        set trun [expr [clock clicks -milliseconds] - $tbeg]
        if {$trun > $tmax} { break }
      }
      set ms [expr double($trun) / double($i)]
      append rval [format "\n%5d   %6.2f" $dly $ms]
    }

    rlc exec -init 0xff [regbld rlink::INIT {anena 0}]

    return $rval
  }
}

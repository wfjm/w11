# $Id: perf.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2014-11-23   606   2.0    use new rlink v4 iface
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

    rlink::anena 1;             # enable attn notify

    for {set dly 250} {$dly <= 10000} {incr dly 250} {
      rlc exec \
        -wreg timer.0 0 \
        -wreg timer.1 0 
      rlc exec -attn

      set tbeg [clock milliseconds]
      rlc exec -wreg timer.0 $dly
      for {set i 1} {1} {incr i} {
        rlc wtlam 1.
        rlc exec \
          -attn \
          -wreg timer.0 $dly
        set trun [expr {[clock milliseconds] - $tbeg}]
        if {$trun > $tmax} { break }
      }
      set ms [expr {double($trun) / double($i)}]
      append rval [format "\n%5d   %6.2f" $dly $ms]
    }

    rlink::anena 0;             # disable attn notify

    return $rval
  }
}

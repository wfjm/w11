# $Id: dmscnt.tcl 985 2018-01-03 08:59:40Z mueller $
#
# Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2017-04-22   883   1.0.3  sc_setup: now idempotent
# 2015-12-30   722   1.0.2  sc_start: use args2opts
# 2015-12-28   721   1.0.1  use ena instead of cnt; use regbldkv
# 2015-06-27   695   1.0    Initial version
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {
  #
  # setup dmscnt unit register descriptions for w11a -------------------------
  #
  regdsc SC_CNTL {clr 1} {ena 0}
  regdsc SC_ADDR {mem 10 8} {word 1 2}

  #
  # sc_setup: rmap definitions for dmscnt
  # 
  proc sc_setup {{cpu "cpu0"}} {
    set base [$cpu get base]
    if {[$cpu rmap -testname sc.cntl [expr {$base + 0x40}]]} {return}
    $cpu rmap -insert sc.cntl [expr {$base + 0x40}]
    $cpu rmap -insert sc.addr [expr {$base + 0x41}]
    $cpu rmap -insert sc.data [expr {$base + 0x42}]
  }

  #
  # sc_start: start the dmscnt
  #
  proc sc_start {{cpu "cpu0"} args} {
    args2opts opts { clr 0 } {*}$args
    $cpu cp -wreg sc.cntl [regbldkv rw11::SC_CNTL ena 1 clr $opts(clr)]
  }

  #
  # sc_stop: stop the dmscnt
  #
  proc sc_stop {{cpu "cpu0"}} {
    $cpu cp -wreg sc.cntl [regbldkv rw11::SC_CNTL ena 0]
  }

  #
  # sc_read: read dmscnt data
  #
  proc sc_read {{cpu "cpu0"}} {
    $cpu cp -wreg sc.addr 0x0000 \
            -rblk sc.data [expr {2*3*256}] blk
    set sn 0
    set rval {}
    append rval "#sn  . .... ...." 
    foreach {d0 d1 d2} $blk {
      append rval [format "\n%3.3x  %1.1x %4.4x %4.4x" $sn $d2 $d1 $d0]
      incr sn
    }
    return $rval
  }

}

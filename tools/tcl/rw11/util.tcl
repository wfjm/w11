# $Id: util.tcl 510 2013-04-26 16:14:57Z mueller $
#
# Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2013-04-26   510   1.1.1  split, asm* and tbench* into separate files
# 2013-04-01   501   1.1    add regdsc's and asm* procs
# 2013-02-02   380   1.0    Initial version
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {
  #
  # setup cp interface register descriptions for w11a
  #
  regdsc CP_CNTL {func 3 0}
  regdsc CP_STAT {rust 7 4} {halt 3} {go 2} {merr 1} {err 0}
  regdsc CP_IBRB {base 12 7} {bw 1 2}
  #
  # setup w11a register descriptions
  #
  regdsc PSW {cmode 15 2} {pmode 13 2} {rset 11} {pri 7 3} {tflag 3} {cc 3 4}

  #
  # setup_cpu: create w11 cpu system
  # 
  proc setup_cpu {} {
    rlc config -basestat 2 -baseaddr 8 -basedata 8
    rw11 rlw rls w11a 1
    cpu0 cp -reset;                     # reset CPU
    return ""
  }

  #
  # setup_sys: create full system
  # 
  proc setup_sys {} {
    if {[info commands rlw] eq ""} {
      setup_cpu
    }
    cpu0 add dl11
    cpu0 add dl11 -base 0176500 -lam 2
    cpu0 add rk11
    rlw start
    return ""
  }

  #
  # run_pdpcp: execute pdpcp type command file
  #
  proc run_pdpcp {fname {cpu "cpu0"}} {
    rlc errcnt -clear
    set code [exec ticonv_pdpcp $cpu $fname]
    eval $code
    set errcnt [rlc errcnt]
    if { $errcnt } {
      puts [format "run_pdpcp: FAIL after %d errors" $errcnt]
    }
    return $errcnt
  }

}

# $Id: asm.tcl 552 2014-03-02 23:02:00Z mueller $
#
# Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2014-03-01   552   1.0.1  BUGFIX: asmwait checks now pc if stop: defined
# 2013-04-26   510   1.0    Initial version (extracted from util.tcl)
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {

  #
  # asmrun: run a program loaded with ldasm
  # 
  proc asmrun {cpu symName opts} {
    upvar 1 $symName sym
    array set defs {r0 0 r1 0 r2 0 r3 0 r4 0 r5 0}
    array set defs $opts

    if {![info exists defs(pc)]} {
      if {[info exists sym(start)]} {
        set defs(pc) $sym(start)
      } else {
        error "neither opts(pc) nor sym(start) given"
      }
    }

    if {![info exists defs(sp)]} {
      if {[info exists sym(stack)]} {
        set defs(sp) $sym(stack)
      } elseif {[info exists sym(start)]} {
        set defs(sp) $sym(start)
      } else {
        error "neither opts(sp) nor sym(stack) or sym(start) given"
      }
    }

    $cpu cp -wr0 $defs(r0) \
            -wr1 $defs(r1) \
            -wr2 $defs(r2) \
            -wr3 $defs(r3) \
            -wr4 $defs(r4) \
            -wr5 $defs(r5) 

    $cpu cp -wsp $defs(sp) \
            -stapc $defs(pc)

    return ""
  }

  #
  # asmwait: wait for completion of a program loaded with ldasm
  # 
  proc asmwait {cpu symName {tout 10.}} {
    upvar 1 $symName sym
    set dt [$cpu wtcpu -reset $tout]
    if {$dt >= 0 && [info exists sym(stop)]} {
      $cpu cp -rpc -edata $sym(stop)
    }
    return $dt
  }

  #
  # asmtreg: test registers after running a program loaded with ldasm
  # 
  proc asmtreg {cpu opts} {
    array set defs $opts
    set cpcmd ""
    foreach key [lsort [array names defs]] {
      append cpcmd " -r$key -edata $defs($key)"
    }
    eval $cpu cp $cpcmd
    return ""
  }

  #
  # asmtmem: test memory after running a program loaded with ldasm
  # 
  proc asmtmem {cpu base list} {
    set nw [llength $list]
    if {$nw == 0} {
      error "asmtreg called with empty list"
    }
    $cpu cp -wal $base -brm $nw -edata $list
    return ""
  }

}

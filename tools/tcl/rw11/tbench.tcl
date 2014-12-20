# $Id: tbench.tcl 607 2014-11-30 20:02:48Z mueller $
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
# 2014-11-30   607   2.0    use new rlink v4 iface
# 2013-04-26   510   1.0    Initial version (extracted from util.tcl)
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {

  #
  # tbench: driver for tbench scripts
  #
  proc tbench {fname} {
    rlink::anena 1;             # enable attn notify
    set errcnt [tbench_list $fname]
    return $errcnt
  }

  #
  # tbench_file: execute list of tbench steps
  #
  proc tbench_list {lname} {
    set errcnt 0
    if {[string match "@*" $lname]} {
      set fname [string range $lname 1 end]
      set fh [open "$::env(RETROBASE)/tools/tbench/$fname"]
      while {[gets $fh line] >= 0} {
        if {[string match "#*" $line]} {
          if {[string match "##*" $line]} { puts $line }
        } elseif {[string match "@*" $line]} {
          incr errcnt [tbench_list $line]
        } else {
          incr errcnt [tbench_step $line]
        }
      }
      close $fh
    } else {
      incr errcnt [tbench_step $lname]
    }
    puts [format "%s: %s" $lname [rutil::errcnt2txt $errcnt]]
    return $errcnt
  }

  #
  # tbench_step: execute single tbench step
  #
  proc tbench_step {fname} {
    rlc errcnt -clear
    set cpu cpu0
    source "$::env(RETROBASE)/tools/tbench/$fname"
    set errcnt [rlc errcnt]
    puts [format "%s: %s" $fname [rutil::errcnt2txt $errcnt]]
    return $errcnt
  }

}

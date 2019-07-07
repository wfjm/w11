# $Id: shell_simh.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2016-12-30   833   1.0    Initial version (limited to 'dep')
#

package provide rw11 1.0

namespace eval rw11 {

  #
  # shell_simh: simh command converter ---------------------------------------
  # 
  proc shell_simh {fname} {
    set fd [open $fname r]
    while {[gets $fd line] >= 0} {
      set cline $line
      if {[regexp -- {^(.*);} $line matched nocomm]} {set cline $nocomm}
      set cline [string trim $cline]
      if {$cline eq ""} {continue}

      set tlist [regexp -inline -all -- {\S+} $cline]
      set scmd  [lindex $tlist 0]
      set sargs [lrange $tlist 1 end]
      switch $scmd {
        dep     {shell_simh_dep {*}$sargs}
        default {
          error "shell_simh-E: not supported simh command '$cmd'"
        }
      }
    }
    return
  }

  #
  # shell_simh_dep: handler for 'dep'  ---------------------------------------
  # 
  proc shell_simh_dep {addr val} {
    .d "0$addr" "0$val"
  }  
}

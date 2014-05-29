# $Id: util.tcl 553 2014-03-17 06:40:08Z mueller $
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
# 2014-03-07   553   1.1.3  move definitions to defs.tcl
# 2013-05-09   517   1.1.2  add setup_(tt|lp|pp|ostr) device setup procs
# 2013-04-26   510   1.1.1  split, asm* and tbench* into separate files
# 2013-04-01   501   1.1    add regdsc's and asm* procs
# 2013-02-02   380   1.0    Initial version
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {
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
    cpu0 add lp11
    cpu0 add pc11
    rlw start
    return ""
  }

  #
  # setup_tt: setup terminals
  # 
  proc setup_tt {{cpu "cpu0"} {optlist {}}} {
    # process and check options
    array set optref { ndl 2 dlrlim 0 ndz 0 to7bit 0 app 0 nbck 1}
    rutil::optlist2arr opt optref $optlist

    # check option values
    if {$opt(ndl) < 1 || $opt(ndl) > 2} {
      error "ndl option must be 1 or 2"
    }
    if {$opt(ndz) != 0} {
      error "ndz option must be 0 (till dz11 support is added)"
    }

    # setup attach url options
    set urlopt "?crlf"
    if {$opt(app) != 0} {
      append urlopt ";app"
    }
    if {$opt(nbck) != 0} {
      append urlopt ";bck=$opt(nbck)"
    }

    # setup list if DL11 controllers
    set dllist {}
    lappend dllist "tta" "8000"
    if {$opt(ndl) == 2} {
      lappend dllist "ttb" "8001"
    }

    # handle DL11 controllers
    foreach {cntl port} $dllist {
      set unit "${cntl}0"
      ${cpu}${unit} att "tcp:?port=${port}"
      ${cpu}${unit} set log "tirri_${unit}.log${urlopt}"
      if {$opt(dlrlim) != 0} {
        ${cpu}${cntl} set rxrlim 7
      }
      if {$opt(to7bit) != 0} {
        ${cpu}${unit} set to7bit 1
      }
    }
    return ""
  }

  #
  # setup_ostr: setup Ostream device (currently lp or pp)
  # 
  proc setup_ostr {cpu unit optlist} {
    # process and check options
    array set optref { app 0 nbck 1}
    rutil::optlist2arr opt optref $optlist

    # setup attach url options
    set urloptlist {}
    if {$opt(app) != 0} {
      append urloptlist "app"
    }
    if {$opt(nbck) != 0} {
      append urloptlist "bck=$opt(nbck)"
    }
    set urlopt ""
    if {[llength $urloptlist] > 0} {
      append urlopt "?"
      append urlopt [join $urloptlist ";"]
    }

    # handle unit
    ${cpu}${unit} att "tirri_${unit}.dat${urlopt}"
    return ""
  }

  #
  # setup_lp: setup printer
  # 
  proc setup_lp {{cpu "cpu0"} {optlist {}}} {
    # process and check options
    array set optref { nlp 1 app 0 nbck 1}
    rutil::optlist2arr opt optref $optlist
    if {$opt(nlp) != 0} {
      setup_ostr $cpu "lpa0" [list app $opt(app) nbck $opt(nbck)]
    }
  }
  #
  # setup_pp: setup paper puncher
  # 
  proc setup_pp {{cpu "cpu0"} {optlist {}}} {
    # process and check options
    array set optref { npc 1 app 0 nbck 1}
    rutil::optlist2arr opt optref $optlist
    if {$opt(npc) != 0} {
      setup_ostr $cpu "pp" [list app $opt(app) nbck $opt(nbck)]
    }
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

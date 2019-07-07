# $Id: util.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2015-07-25   704   1.1.1  rename optlist2arr->args2opts, new logic, export it
# 2015-06-26   695   1.1    move reg* proc to regdsc.tcl
# 2015-06-05   688   1.0.5  add dohook
# 2015-03-28   660   1.0.4  add com8 and com16
# 2014-12-23   619   1.0.3  regget: add check for unknown field descriptor
# 2014-07-12   569   1.0.2  add sxt16 and sxt32
# 2013-05-09   517   1.0.1  add optlist2arr
# 2011-03-27   374   1.0    Initial version
# 2011-03-19   372   0.1    First draft
#

package provide rutil 1.0

package require rutiltpp

namespace eval rutil {
  #
  # args2opts: process options arguments given as key value list -----------
  #
  proc args2opts {optsName refs args} {
    upvar $optsName opts
    if {[llength $args] % 2 != 0} {
      error "args2opts-E: odd number of optional key value args"
    }
    array set opts $refs
    foreach {key value} $args {
      if {[info exists opts($key)]} {
        set opts($key) $value
      } else {
        error "args2opts-E: key $key not valid in optlist"
      }
    }
    return
  }

  #
  # errcnt2txt: returns "PASS" if 0 and "FAIL" otherwise ---------------------
  #
  proc errcnt2txt {errcnt} {
    if {$errcnt} {return "FAIL"}
    return "PASS"
  }

  #
  # sxt16: 16 bit sign extend ------------------------------------------------
  #
  proc sxt16 {val} {
    if {$val & 0x8000} {                    # bit 15 set ?
      set val [expr $val | ~ 077777];       # --> set bits 15 and higher
    }
    return $val
  }

  #
  # sxt32: 32 bit sign extend ------------------------------------------------
  #
  proc sxt32 {val} {
    if {$val & 0x80000000} {                # bit 31 set ?
      set val [expr $val | ~ 017777777777]; # --> set bits 31 and higher
    }
    return $val
  }

  #
  # com8: 8 bit complement ---------------------------------------------------
  #
  proc com8 {val} {
    return [expr (~$val) & 0xff]
  }

  #
  # com16: 16 bit complement -------------------------------------------------
  #
  proc com16 {val} {
    return [expr (~$val) & 0xffff]
  }

  #
  # dohook: source a hook script if is defined -------------------------------
  #
  proc dohook {name} {
    set fname "${name}.tcl"
    if {[file readable $fname]} {
      puts "dohook: $fname"
      source $fname
    }
    return
  }

  # ! export some procs to global scope --------------------------------------

  namespace export args2opts

}

namespace import rutil::args2opts

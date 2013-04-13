# $Id: util.tcl 504 2013-04-13 15:37:24Z mueller $
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
# 2013-04-13   504   1.1.1  add tbench* procs
# 2013-04-01   501   1.1    add regdsc's and asm* procs
# 2013-02-02   380   1.0    Initial version
#

package provide rw11a 1.0

package require rlink
package require rwxxtpp

namespace eval rw11a {
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
    rlw start
    return ""
  }

  #
  # init: reset w11a 
  # 
  proc init {} {
    # rlc exec -wreg br.cntl 0x0000
  }

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
    if {$dt >= 0 && [info exists $sym(stop)]} {
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

  #
  # tbench: driver for tbench scripts
  #
  proc tbench {fname} {
    rlc exec -init 0xff [regbld rlink::INIT anena]
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

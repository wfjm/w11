# $Id: shell.tcl 717 2015-12-25 17:38:09Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2015-12-23   717   1.1    add e,g,d commands; fix shell_tin
# 2015-07-12   700   1.0    Initial version
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {

  variable shell_depth  0
  variable shell_cpu    "cpu0"
  variable shell_attnhdl_added 0
  variable shell_eofchar_save {puts {}}

  #
  # shell_start: start rw11 shell --------------------------------------------
  # 
  proc shell_start {} {
    variable shell_cpu
    variable shell_attnhdl_added
    variable shell_eofchar_save 
    global   tirri_interactive
    
    # quit if shell already active
    if {[llength [info procs ::rw11::unknown_save]] > 0} {
      error "rw11 shell already started" 
    }

    # set unknown handler
    rename ::unknown ::rw11::unknown_save
    rename ::rw11::shell_forward ::unknown

    # check that attn handler is installed
    if {!$shell_attnhdl_added} {
      rls attn -add 0x0001 { rw11::shell_attncpu }
      set shell_attnhdl_added 1
    }

    # redefine ti_rri prompt and eof handling
    if { $tirri_interactive } {
      # setup new prompt (save old one...)
      rename ::tclreadline::prompt1 ::rw11::shell_prompt1_save
      namespace eval ::tclreadline {
        proc prompt1 {} {
          return "${rw11::shell_cpu}> "
        }
      }
      # disable ^D (and save old setting)
      set shell_eofchar_save [::tclreadline::readline eofchar]
      ::tclreadline::readline eofchar {::rw11::shell_eofchar}
    }

    return ""
  }

  #
  # shell_stop: stop rw11 shell ----------------------------------------------
  # 
  proc shell_stop {} {
    variable shell_eofchar_save 
    global   tirri_interactive

    if {[llength [info procs ::rw11::unknown_save]] == 0} {
      error "rw11 shell not started" 
    }
    rename ::unknown ::rw11::shell_forward
    rename ::rw11::unknown_save ::unknown
    # restore ti_rri prompt and eof handling

    if { $tirri_interactive } {
      rename ::tclreadline::prompt1 {}
      rename ::rw11::shell_prompt1_save ::tclreadline::prompt1
      ::tclreadline::readline eofchar $shell_eofchar_save
    }

    return ""
  }

  #
  # shell_forward: rw11 shell forwarder (will be renamed to ::unknown) -------
  # 
  proc shell_forward args {
    uplevel 1 [list rw11::shell {*}$args]
  }

  #
  # shell_eofchar: eofchar handler -------------------------------------------
  # 
  proc shell_eofchar args {
    cpu0 cp -rstat cpustat
    if {[regget rw11::CP_STAT(go) $cpustat]} {
      puts \
      "cpu0 running, ^D disabled. Use qq to quit shell or tirri_exit to bail out"
      return ""
    }
    shell_stop
    return ""
  }

  #
  # shell_attncpu: cpu attn handler ------------------------------------------
  # 
  proc shell_attncpu {} {
    puts "CPU attention"
    puts [cpu0 show -r0ps]
    return ""
  }

  #
  # shell: rw11 shell --------------------------------------------------------
  # 
  proc shell args {
    variable shell_depth
    variable shell_cpu
    set rval   {}
    set cname  [lindex $args 0]
    set cargs  [lreplace $args 0 0]

    switch $cname {

      e         {set rval [shell_exa {*}$cargs]}
      g         {set rval [shell_get {*}$cargs]}
      d         {set rval [shell_dep {*}$cargs]}

      c0        -
      c1        -
      c2        -
      c3        {set rval [shell_setcpu $cname]}

      cs        {set rval [shell_cs  {*}$cargs]}
      cr        {set rval [shell_cr  {*}$cargs]}
      cl        {set rval [shell_cll {*}$cargs]}

      bs        {set rval [rw11::hb_set      $shell_cpu {*}$cargs]}
      br        {set rval [rw11::hb_remove   $shell_cpu {*}$cargs]}
      bl        {set rval [rw11::hb_list     $shell_cpu {*}$cargs]}

      qq        {set rval [rw11::shell_stop  {*}$cargs]}

      .         {set rval [shell_cls {*}$cargs]}
      ?         {set rval [shell_clb {*}$cargs]}
      (         {set rval [shell_ti  {*}$cargs]}
      <         {set rval [shell_tin {*}$cargs]}

      h         {set rval [shell_help {*}$cargs]}

      default   {
        if {$shell_depth > 1} {
          error "nested entry to shell for \"$cname\""
        }
        incr shell_depth
        uplevel 1 [list rw11::unknown_save {*}$args]
      }
    }
    set shell_depth 0
    return $rval;
  }

  #
  # shell_setcpu: set current cpu --------------------------------------------
  # 
  proc shell_setcpu {cname} {
    variable shell_cpu
    set cpucmd "cpu[string range $cname 1 1]"
    if {[llength [info commands $cpucmd]] == 0} {
      error "'$cpucmd' not available"
    }
    set shell_cpu $cpucmd
    return ""
  }

  #
  # shell_cs: cpu step -------------------------------------------------------
  # 
  proc shell_cs {{nstep 1}} {
    variable shell_cpu
    set rval {}
    for {set i 0} {$i < $nstep} {incr i} {
      rw11::hb_clear $shell_cpu
      $shell_cpu cp -step
      if {$i > 0} {append rval "\n"}
      append rval [$shell_cpu show -pcps]
      $shell_cpu cp -rstat stat
      if {[regget rw11::CP_STAT(rust) $stat] != 4} {break}
    }
    return $rval
  }

  #
  # shell_cr: cpu resume -----------------------------------------------------
  # 
  proc shell_cr {} {
    variable shell_cpu
    rw11::hb_clear $shell_cpu
    $shell_cpu cp -resume
    return ""
  }

  #
  # shell_cls: cpu short status ----------------------------------------------
  # 
  proc shell_cls {} {
    variable shell_cpu
    return [$shell_cpu show -pcps]
  }

  #
  # shell_clb: cpu brief status  ---------------------------------------------
  # 
  proc shell_clb {} {
    variable shell_cpu
    return [$shell_cpu show -r0ps]
  }

  #
  # shell_cll: cpu long status -----------------------------------------------
  # 
  proc shell_cll {} {
    variable shell_cpu
    set    rval [$shell_cpu show -r0ps]
    append rval "\n"
    append rval [$shell_cpu show -mmu]
    append rval "\n"
    append rval [$shell_cpu show -ubmap]
  }

  #
  # shell_ti: tta0 input (no cr at end) --------------------------------------
  # 
  proc shell_ti args {
    variable shell_cpu
    set str [join $args " "]
    "${shell_cpu}tta0" type $str
    return ""
  }

  #
  # shell_tin: tta0 input (with cr at end) -----------------------------------
  # 
  proc shell_tin args {
    variable shell_cpu
    set str [join $args " "]
    append str "\r"
    "${shell_cpu}tta0" type $str
    return ""
  }

  #
  # shell_help: shell help text ----------------------------------------------
  # 
  proc shell_help args {
    set rval "rw11 shell command abreviations:"
    foreach i {0 1 2 3} {
      if {[llength [info commands "cpu${i}"]] > 0} {
        append rval "\n  c${i}                 ; select cpu${i}"
      }
    }
    append rval "\n  e aspec            ; examine memory, return as text"
    append rval "\n  g aspec            ; get memory, return as tcl list"
    append rval "\n  d aspec vals       ; deposit memory"
    append rval "\n  cs                 ; cpu step"
    append rval "\n  cr                 ; cpu resume"
    append rval "\n  cl                 ; full cpu state (with mmu+ubmap)"
    append rval "\n  bs ind typ lo hi   ; set bpt"
    append rval "\n  br ?ind?           ; remove bpt"
    append rval "\n  bl                 ; list bpt"
    append rval "\n  qq                 ; quit shell, return to ti_rri"
    append rval "\n  .                  ; short cpu state (pc+psw)"
    append rval "\n  ?                  ; brief cpu state (all regs)"
    append rval "\n  ( ?text?           ; tta0 input without cr"
    append rval "\n  < ?text?           ; tta0 input with cr"
    append rval "\n  h                  ; this help text"
    return $rval
  }

}

# $Id: shell.tcl 885 2017-04-23 15:54:01Z mueller $
#
# Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2017-04-23   885   2.2.4  adopt .cm* to new interface
# 2017-04-22   883   2.2.3  integrate rbmon: add .rme,.rmd,.rmf,.rml
# 2017-04-16   879   2.2.2  rename .cres->.crst and .cr->.cres (more intuitive)
# 2017-04-09   872   2.2.1  adopt .ime to new interface
# 2017-01-02   837   2.2    code re-shuffle; add cpu status in prompt
# 2016-12-31   834   2.1    add '@' command
# 2016-12-30   833   2.0    major overhaul    
# 2015-12-23   717   1.1    add e,g,d commands; fix shell_tin
# 2015-07-12   700   1.0    Initial version
#

package provide rw11 1.0

package require rlink
package require rwxxtpp
package require ibd_ibmon
package require rbmoni

namespace eval rw11 {

  variable shell_depth     0;                   # recursion stopper
  variable shell_cpu       "cpu0";              # current cpu command
  variable shell_cpu_stat  "";                  # cpu status
  variable shell_attnhdl_added 0
  variable shell_eofchar_save {puts {}}

  #
  # shell_start: start rw11 shell --------------------------------------------
  # 
  proc shell_start {} {
    variable shell_cpu
    variable shell_attnhdl_added
    variable shell_eofchar_save
    variable shell_cpu_stat
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
          return "${rw11::shell_cpu_stat}${rw11::shell_cpu}> "
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
      "cpu0 running, ^D disabled. Use .q to quit shell or .qq to bail out"
      return ""
    }
    tirri_exit
    return ""
  }

  #
  # shell_attncpu: cpu attn handler ------------------------------------------
  # 
  proc shell_attncpu {} {
    puts "CPU attention"
    puts [cpu0 show -r0ps]
    shell_update_cpu_stat
    puts -nonewline [::tclreadline::prompt1]
    flush stdout
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

    # handle @<command-file>
    if {[regexp -- {^\@(.+)$} $cname matched fname]} {
      if {![file exists $fname]} {
        error "shell-E: file 'fname' not found"
      }
      if {[regexp -- {^(.+)\.scmd$} $fname]} {
        shell_simh $fname
      } else {
        source $fname
      }
      return
    }

    switch $cname {

      .e        {set rval [shell_exa {*}$cargs]}
      .g        {set rval [shell_get {*}$cargs]}
      .d        {set rval [shell_dep {*}$cargs]}

      .c0       -
      .c1       -
      .c2       -
      .c3       {set rval [shell_setcpu $cname]}

      .cs       {set rval [shell_cs   {*}$cargs]}
      .cres     {set rval [shell_cres {*}$cargs]}
      .csus     {set rval [shell_csus {*}$cargs]}
      .csto     {set rval [shell_csto {*}$cargs]}
      .crst     {set rval [shell_crst {*}$cargs]}
      .csta     {set rval [shell_csta {*}$cargs]}

      .bs       {set rval [rw11::hb_set      $shell_cpu {*}$cargs]}
      .br       {set rval [rw11::hb_remove   $shell_cpu {*}$cargs]}
      .bl       {set rval [rw11::hb_list     $shell_cpu {*}$cargs]}

      .cme      {set rval [shell_cme  {*}$cargs]}
      .cmd      {set rval [shell_cmd  {*}$cargs]}
      .cml      {set rval [shell_cml  {*}$cargs]}

      .ime      {set rval [shell_ime  {*}$cargs]}
      .imd      {set rval [shell_imd  {*}$cargs]}
      .imf      {set rval [shell_imf  {*}$cargs]}
      .iml      {set rval [shell_iml  {*}$cargs]}

      .rme      {set rval [shell_rme  {*}$cargs]}
      .rmd      {set rval [shell_rmd  {*}$cargs]}
      .rmf      {set rval [shell_rmf  {*}$cargs]}
      .rml      {set rval [shell_rml  {*}$cargs]}

      .         {set rval [shell_cls {*}$cargs]}
      ?         {set rval [shell_clb {*}$cargs]}
      ?m        {set rval [shell_clm {*}$cargs]}
      ?u        {set rval [shell_clu {*}$cargs]}
      ??        {set rval [shell_cll {*}$cargs]}
      (         {set rval [shell_ti  {*}$cargs]}
      <         {set rval [shell_tin {*}$cargs]}

      .hr       {set rval [shell_hr  {*}$cargs]}
      .h        {set rval [shell_h   {*}$cargs]}
      .ha       {set rval [shell_ha  {*}$cargs]}

      .q        {set rval [shell_q   {*}$cargs]}
      .qq       {set rval [shell_qq  {*}$cargs]}

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
    set cpucmd "cpu[string range $cname 2 2]"
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
      if {[regget rw11::CP_STAT(rust) $stat] != $rw11::RUST_STEP} {break}
    }
    shell_update_cpu_stat
    return $rval
  }

  #
  # shell_cres: cpu resume ---------------------------------------------------
  # 
  proc shell_cres {} {
    variable shell_cpu
    variable shell_cpu_stat

    set shell_cpu_stat "g:";

    rw11::hb_clear $shell_cpu
    $shell_cpu cp -resume
    return ""
  }

  #
  # shell_csus: cpu suspend --------------------------------------------------
  # 
  proc shell_csus {} {
    variable shell_cpu
    $shell_cpu cp -suspend
    shell_update_cpu_stat
    return ""
  }

  #
  # shell_csto: cpu stop -----------------------------------------------------
  # 
  proc shell_csto {} {
    variable shell_cpu
    $shell_cpu cp -stop
    shell_update_cpu_stat
    return ""
  }

  #
  # shell_crst: cpu reset ----------------------------------------------------
  # 
  proc shell_crst {} {
    variable shell_cpu
    $shell_cpu cp -stop
    $shell_cpu cp -creset
    shell_update_cpu_stat
    return ""
  }

  #
  # shell_csta: cpu start ----------------------------------------------------
  # 
  proc shell_csta {{pc -1}} {
    variable shell_cpu
    variable shell_cpu_stat

    set shell_cpu_stat "g:";

    if {$pc == -1} {
      $shell_cpu cp -start
    } else {
      $shell_cpu cp -stapc $pc
    }
    return ""
  }

  #
  # shell_cme: cmon enable ---------------------------------------------------
  # 
  proc shell_cme {{mode ""}} {
    variable shell_cpu

    if {![shell_test_cpurmap $shell_cpu "cme" "cm.cntl" "dmcmon"]} {return ""}
    rw11::cme $shell_cpu $mode
    return ""
  }

  #
  # shell_cmd: cmon disable --------------------------------------------------
  # 
  proc shell_cmd {} {
    variable shell_cpu

    if {![shell_test_cpurmap $shell_cpu "cmd" "cm.cntl" "dmcmon"]} {return ""}
    rw11::cm_stop $shell_cpu
    return ""
  }

  #
  # shell_cml: cmon list -----------------------------------------------------
  # 
  proc shell_cml {{nent -1}} {
    variable shell_cpu
    if {![shell_test_cpurmap $shell_cpu "cml" "cm.cntl" "dmcmon"]} {return ""}
    return [rw11::cml $shell_cpu $nent]
  }

  #
  # shell_ime: ibmon enable --------------------------------------------------
  # 
  proc shell_ime {{mode "lrc"}} {
    variable shell_cpu
    if {![shell_test_cpurmap $shell_cpu "ime" "im.cntl" "ibmon"]} {return ""}

    ibd_ibmon::ime $shell_cpu $mode
    return ""
  }

  #
  # shell_imd: ibmon diasable -------------------------------------------------
  # 
  proc shell_imd {} {
    variable shell_cpu
    if {![shell_test_cpurmap $shell_cpu "imd" "im.cntl" "ibmon"]} {return ""}

    ibd_ibmon::stop $shell_cpu
    return ""
  }

  #
  # shell_imf: ibmon filter ---------------------------------------------------
  # 
  proc shell_imf {{lo ""} {hi ""}} {
    variable shell_cpu
    if {![shell_test_cpurmap $shell_cpu "imf" "im.cntl" "ibmon"]} {return ""}

    ibd_ibmon::imf $shell_cpu $lo $hi
    return ""
  }

  #
  # shell_iml: ibmon list -----------------------------------------------------
  # 
  proc shell_iml {{nent -1}} {
    variable shell_cpu
    if {![shell_test_cpurmap $shell_cpu "iml" "im.cntl" "ibmon"]} {return ""}
    set mondat [ibd_ibmon::read $shell_cpu $nent]
    if {![llength $mondat]} {return ""}
    return [ibd_ibmon::print $shell_cpu $mondat]
  }

  #
  # shell_rme: rbmon enable --------------------------------------------------
  # 
  proc shell_rme {{mode ""}} {
    if {![shell_test_rlcamap "rme" "rm.cntl" "rbmon"]} {return ""}
   rbmoni::rme $mode
    return ""
  }

  #
  # shell_rmd: rbmon diasable -------------------------------------------------
  # 
  proc shell_rmd {} {
    if {![shell_test_rlcamap "rmd" "rm.cntl" "rbmon"]} {return ""}
    rbmoni::stop
    return ""
  }

  #
  # shell_rmf: rbmon filter ---------------------------------------------------
  # 
  proc shell_rmf {{lo ""} {hi ""}} {
    if {![shell_test_rlcamap "rmf" "rm.cntl" "rbmon"]} {return ""}
    rbmoni::rmf $lo $hi
    return ""
  }

  #
  # shell_rml: rbmon list -----------------------------------------------------
  # 
  proc shell_rml {{nent -1}} {
    if {![shell_test_rlcamap "rml" "rm.cntl" "rbmon"]} {return ""}
    set mondat [rbmoni::read $nent]
    if {![llength $mondat]} {return ""}
    return [rbmoni::print $mondat]
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
  # shell_clm: mmu status ----------------------------------------------------
  # 
  proc shell_clm {} {
    variable shell_cpu
    return [$shell_cpu show -mmu]
  }

  #
  # shell_clu: ubmap status --------------------------------------------------
  # 
  proc shell_clu {} {
    variable shell_cpu
    return [$shell_cpu show -ubmap]
  }

  #
  # shell_cll: cpu long status -----------------------------------------------
  # 
  proc shell_cll {} {
    variable shell_cpu
    set    rval [shell_clb]
    append rval "\n" [shell_clm]
    append rval "\n" [shell_clu]
    return $rval
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
  # shell_hr: list of and help on ibus register -------------------------------
  # 
  proc shell_hr {{spec "*"} {am ""}} {
    variable shell_cpu
    set nreg 0

    set rval "name       :    hex     oct"
    if {$am ne "" && ![regexp {^[rl][rw]$} $am]} {
      error ".hr-E: bad am '$am', only \[rl\]\[rw\] allowed"
    }
    foreach item [$shell_cpu imap] {
      set val [lindex $item 0]
      set nam [lindex $item 1]
      if {[string match $spec $nam]} {
        incr nreg
        append rval [format "\n%-10s : 0x%04x  %06o" $nam $val $val]
        set rdsc [rw11util::regmap_get $nam $am]
        if {$rdsc ne ""} {
          append rval "\n"
          append rval [regdsc_print $rdsc]
        }
      }
    }

    if {!$nreg} {
      append rval [format "\n%-10s : -- no matches found --" $spec]
    }

    return $rval
  }

  #
  # shell_q: quit shell ------------------------------------------------------
  # 
  proc shell_q args {
    puts "shell-I: use rw11::shell_start to restart shell"
    shell_stop
  }

  #
  # shell_qq: quit ti_rri unconditionally ------------------------------------
  # 
  proc shell_qq args {
    tirri_exit
  }

  #
  # shell_h: shell help text -------------------------------------------------
  # 
  proc shell_h args {
    variable shell_cpu
    append rval "CPU state:"
    foreach i {0 1 2 3} {
      if {[llength [info commands "cpu${i}"]] > 0} {
        append rval "\n    .c${i}                 ; select cpu${i}"
      }
    }
    append rval "\n    .cs ?nstep?         ; cpu step"
    append rval "\n    .cres               ; cpu resume"
    append rval "\n    .csus               ; cpu suspend"
    append rval "\n    .csto               ; cpu stop"
    append rval "\n    .csta ?addr?        ; cpu start"
    append rval "\n    .crst               ; cpu reset"
    append rval "\n    .                   ; short cpu state (pc+psw)"
    append rval "\n    ?                   ; brief cpu state (all regs)"
    append rval "\n    ?m                  ; mmu status"
    append rval "\n    ?u                  ; ubmap status"
    append rval "\n    ??                  ; full  cpu state (with mmu+ubmap)"
    append rval "\nmemory and register access:"
    append rval "\n    .e aspec            ; examine, return as text"
    append rval "\n    .g aspec            ; get, return as tcl list"
    append rval "\n    .d aspec vals       ; deposit"
    append rval "\n                        ; see .ha for help on aspec format"
    append rval "\nCPU hardware breakpoint:"
    append rval "\n    .bs ind typ lo hi   ; set bpt"
    append rval "\n    .br ?ind?           ; remove bpt"
    append rval "\n    .bl                 ; list bpt"
    if {[$shell_cpu get hascmon]} {
    append rval "\nCPU monitor:"
      append rval "\n    .cme ?mode?         ; cmon enable; mode:n?\[isS\]?"
      append rval "\n    .cmd                ; cmon disable"
      append rval "\n    .cml ?nent?         ; cmon list"
    }
    if {[$shell_cpu get hasibmon]} {
    append rval "\nibus monitor:"
      append rval "\n    .ime                ; ibmon enable; mode: \[lrcnRW\]*"
      append rval "\n    .imd                ; ibmon disable"
      append rval "\n    .imf ?lo? ?hi?      ; ibmon filter"
      append rval "\n    .iml ?nent?         ; ibmon list"
    }
    if {[rlc get hasrbmon]} {
    append rval "\nrbus monitor:"
      append rval "\n    .rme                ; rbmon enable; mode: \[nRW\]*"
      append rval "\n    .rmd                ; rbmon disable"
      append rval "\n    .rmf ?lo? ?hi?      ; rbmon filter"
      append rval "\n    .rml ?nent?         ; rbmon list"
    }
    append rval "\nconsole (tta0) direct input:"
    append rval "\n    ( ?text?            ; tta0 input without cr"
    append rval "\n    < ?text?            ; tta0 input with cr"
    append rval "\nmiscellaneous:"
    append rval "\n    .hr ?name? ?am?     ; list ibus registers; am: \[rl\]\[rw\]"
    append rval "\n    .h                  ; this help text"
    append rval "\n    .q                  ; quit shell, return to ti_rri"
    append rval "\n    .qq                 ; quit ti_rri unconditionally"
    return $rval
  }

  #
  # shell_ha: shell aspec help text ------------------------------------------
  # 
  proc shell_ha args {
    set rval "address specifier format for .e .g and .d:"
    append rval "\n  .e addr/opt/opt/...                  --> returns text"
    append rval "\n  .g addr/opt/opt/...                  --> returns value list"
    append rval "\n  .d addr/opt/opt/... vals"
    append rval "\n"
    append rval "\naddr format"
    append rval "\n  nnnn     - number (note that tcl default is decimal !!)"
    append rval "\n  name     - register name lookup in imap"
    append rval "\n  name+nn  - name with offset"
    append rval "\n  rx       - with r0,..,r7,sp,pc and also ps"
    append rval "\n  @rx      - indirect: with r0,..,r7,sp,pc"
    append rval "\n  (rx)     - indirect"
    append rval "\n  nnn(rx)  - indirect with offset"
    append rval "\n"
    append rval "\nopt format (multiple opt's allowed)"
    append rval "\n  nnn      - repeat count (decimal, in words)"
    append rval "\n  l        - for iopage access: loc (as seen by CPU)"
    append rval "\n  r        - for iopage access: rem (as seen by rlink)"
    append rval "\n  p        - for memory access: physical (16bit)"
    append rval "\n  e        - for memory access: extended (22 bit)"
    append rval "\n  u        - for memory access via ubmap (22 bit)"
    append rval "\n  MS       - for memory access via mmu mode=M and space=S"
    append rval "\n           -   M (mode)  as c,p,k,s,u for cm,pm,kern,sup,user"
    append rval "\n           -   S (space) as i,d for instruction,data"
    append rval "\n  i        - print as intructuion with dasm"
    append rval "\n  a        - print as ascii"
    append rval "\n  d        - print as decimal"
    append rval "\n  x        - print as hex"
    append rval "\n"
    append rval "\nexamples:"
    append rval "\n  .e rpa.cs1        - register rhrp.cs1"
    append rval "\n  .e rpa.cs1/12/r   - 12 regs starting rpa.cs1, rlink view"
    append rval "\n  .e @pc/8/ci/i     - use pc, mmu in ci mode, 8 words as instructions"
    append rval "\n  .e @r0/8/cd       - use r0. mmu in cd mode, show 8 words"
    return $rval
  }

  #
  # shell_test_cpurmap: test whether cpu option available ---------------------
  # 
  proc shell_test_cpurmap {cpu cmd regnam optnam} {
    if {[$cpu rmap -testname $regnam]} {
      return 1;
    }
    puts "shell-W: '$cmd' command ignored, '$optnam' CPU option not available"
    return 0;
  }

  #
  # shell_test_rlcamap: test whether rbus option available --------------------
  # 
  proc shell_test_rlcamap {cmd regnam optnam} {
    if {[rlc amap -testname $regnam]} {
      return 1;
    }
    puts "shell-W: '$cmd' command ignored, '$optnam' rbus option not available"
    return 0;
  }

  #
  # shell_update_cpu_stat ----------------------------------------------------
  #
  proc shell_update_cpu_stat {} {
    variable shell_cpu_stat
    set shell_cpu_stat ""
    foreach i {0 1 2 3} {
      if {[llength [info commands "cpu${i}"]] > 0} {
        cpu${i} cp -rreg "stat" cp_stat
        set cpu_rust [regget rw11::CP_STAT(rust) $cp_stat]
            if {$cpu_rust == $rw11::RUST_INIT}  { set cpu_rcode "I" } \
        elseif {$cpu_rust == $rw11::RUST_HALT}  { set cpu_rcode "H" } \
        elseif {$cpu_rust == $rw11::RUST_RESET} { set cpu_rcode "R" } \
        elseif {$cpu_rust == $rw11::RUST_STOP}  { set cpu_rcode "S" } \
        elseif {$cpu_rust == $rw11::RUST_STEP}  { set cpu_rcode "+" } \
        elseif {$cpu_rust == $rw11::RUST_SUSP}  { set cpu_rcode "s" } \
        elseif {$cpu_rust == $rw11::RUST_HBPT}  { set cpu_rcode "b" } \
        elseif {$cpu_rust == $rw11::RUST_RUNS}  { set cpu_rcode "g" } \
        else                                    { set cpu_rcode "E" }
        append shell_cpu_stat $cpu_rcode
      }
    }
    append shell_cpu_stat ":"
  }
}

# $Id: util.tcl 1196 2019-07-20 18:18:16Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-07-20  1196   1.0.1  et_tenv_cleanup: use test namespaces
# 2019-06-29  1174   1.0    Initial version
# 2019-06-10  1162   0.1    First draft
#

package provide exptest 1.0

package require Expect

#
# --------------------------------------------------------------------
# global defs

array set opts { 
  sys_     ""
  mode_    "rri"
  log      0
  log_     ""
  logu     0
  config   0
  help     0
}

array set genv {
  FAIL     0
}

set et_args  {}
set et_tests {}

#
# --------------------------------------------------------------------
#
proc bailout {msg} {
  set cmd [file tail $::argv0]
  puts "$cmd-E: $msg"
  exit 1
}

#
# --------------------------------------------------------------------
#
proc putl {msg} {
  if { $::opts(log) } { send_log -- "$msg\n" } else { puts "$msg" }
}

#
# --------------------------------------------------------------------
#
proc putb {msg} {
  if { $::opts(log) } { send_log -- "$msg\n" };  puts "$msg"
}

#
# --------------------------------------------------------------------
#
proc et_init {} {
  global opts;                  # for brevity of code

  set ::genv(iwd) [pwd]
  set ::genv(cmd) [file tail $::argv0]
  
  if {[info exists ::env(EXPTEST_SYS)]} {set opts(sys_) $::env(EXPTEST_SYS)}

  # process command arguments
  foreach arg $::argv {
    switch -regexp -- $arg {
      ^--?sys=.+$   { regexp -- {=(.*)} $arg dummy opts(sys_) }
      ^--?mode=.+$  { regexp -- {=(.*)} $arg dummy opts(mode_) }
      ^--?logu$     { set opts(logu)   1 }
      ^--?log=?.*$  { set opts(log) 1; regexp -- {=(.*)} $arg dummy opts(log_) }
      ^--?config$   { set opts(config) 1 }
      ^--?help$     { set opts(help)   1 }
      ^--?.+$       { bailout "bad option $arg, use --help" }
      default       { lappend ::et_args $arg }
    }
  }
  # handle --help
  if { $opts(help) } { et_help; exit 0 }
  
  # basic checks
  if {![info exists ::env(RETROBASE)]} { bailout "\$RETROBASE not defined" }
  if {$opts(sys_) eq ""} { bailout "system not defined, use --sys" }

  # initialize mode, load associated package
  set pack_mode "exptest_$opts(mode_)"
  if {![file isdirectory "$::env(RETROBASE)/tools/tcl/$pack_mode"]} {
    bailout "mode '$opts(mode_)' not defined"
  }
  package require $pack_mode
  
  # initialize system
  set base_sys "$::env(RETROBASE)/tools/exptest/sys"

  if {[catch {cd $base_sys}]} { bailout "$base_sys not existing" }
  
  set sys_setup_fname "$opts(sys_)_setup.tcl"
  if {![file readable $sys_setup_fname]} {
    bailout "not setup file found for '$opts(sys_)'"
  }
  
  if {[catch {source $sys_setup_fname} emsg]} {
    bailout "failed to setup sys '$opts(sys_)': \n$emsg"
  }

  return
}

#
# --------------------------------------------------------------------
#
proc et_init2 {deflist} {
  if {[llength $::et_args] == 0} { set ::et_args "*" }
  foreach arg $::et_args {
    if {[string first "*" $arg] >= 0} {
      foreach tst $deflist {
        if {[string match $arg $tst]} { lappend ::et_tests $tst }
      }
    } else {
      lappend ::et_tests $arg
    }
  }
  
  if {[llength $::et_tests] == 0} {
    puts "$::genv(cmd)-I: no tests selected, nothing to do"
    exit 0
  }
  
  et_setlog $::genv(cmd)
  
  return
}

#
# --------------------------------------------------------------------
#
proc et_prtrunhead {} {
  set ::et_timerun   [clock milliseconds]
  set ::et_timetest  $::et_timerun
  putl "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  putl "----- run setup"
  putl [et_parray ::opts]
  putl [et_parray ::genv]
  putl ""
  return
}

#
# --------------------------------------------------------------------
#
proc et_prttesthead {tnam} {
  set now [clock milliseconds]
  set dt [expr {$now - $::et_timetest}]
  putl "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  putb [format "----- %s (%6.1f,%6.1f): $tnam" \
          [clock format [clock seconds] -format %T] \
          [expr {($now-$::et_timerun)/1000.}] \
          [expr {($now-$::et_timetest)/1000.}] ]
  set ::et_timetest  [clock milliseconds]
  return
}

#
# --------------------------------------------------------------------
#
proc et_config {} {
  if {!$::opts(config)} { return }
  if {[info procs sv_config] eq ""} {
    bailout "--config not supported on mode $::opts(mode_)"
  }
  et_prttesthead "-config"
  if {[et_cmdl sv_config]} { exit 1}
  putl ""
  return
}

#
# --------------------------------------------------------------------
#
proc et_help {} {
  # use {} as delimiter here to avoid escaping of all [] 
  puts "usage: $::genv(cmd) \[OPTION\]... \[TEST\]..."
  puts {}
  puts {Options:}
  puts {  --sys=SNAME    system name, e.g. sys_w11a_n4. Default is taken from}
  puts {                   $EXPTEST_SYS environment variable}
  puts {  --mode=MODE    currently 'rri' the only option}
  puts {  --log[=FNAM]   log session to file FNAM}
  puts {  --logu         show session on stdout even when --log active}
  puts {  --config       configure FPGA}
  puts {  --help         display this help and exit}
  puts {}
  puts "For further details consults the $::genv(cmd) man page."
  return
}

#
# --------------------------------------------------------------------
#
proc et_parray {a {pattern *}} {
  upvar 1 $a array
  set res ""
  set maxl 0
  set names [lsort [array names array $pattern]]
  foreach name $names { set maxl [expr { max($maxl,[string length $name]) }] }
  set maxl [expr {$maxl + [string length $a] + 2}]
  foreach name $names {
    set nameString [format %s(%s) $a $name]
    if { $res ne "" } {append res "\n"}
    append res [format "%-*s = %s" $maxl $nameString $array($name)]
  }
  return $res
}

#
# --------------------------------------------------------------------
#
proc et_setlog {pref} {
  if { $::opts(log) } {
    if { $::opts(log_) eq "" } {
      set tnow [clock seconds]
      append ::opts(log_) "$pref-"
      append ::opts(log_) [clock format $tnow -format "%Y-%m-%d-%H%M%S"]
      append ::opts(log_) "-$::opts(sys_).log"
      puts "-I: log to $::opts(log_)"
    }
    log_file -a -noappend "$::genv(iwd)/$::opts(log_)"
    log_user $::opts(logu)
  }
  return
}

#
# --------------------------------------------------------------------
#
proc et_spawn {id args} {
  global spawn_id;              # ensure that spawn uses global spawn_id
  spawn {*}$args
  set ::tenv(sid_$id) $spawn_id
  return
}

#
# --------------------------------------------------------------------
#
proc et_spawn_term {port} {
  et_spawn $port telnet localhost $::sv_pmap($port)
  return
}

#
# --------------------------------------------------------------------
#
proc et_close_allterm {} {
  foreach sid [array names ::tenv sid_tt*] {
    et_exp i $::tenv($sid)
    et_exp e eof
    wait -i $::tenv($sid)
    unset ::tenv($sid)
  }
  return
}

#
# --------------------------------------------------------------------
#
proc et_close {id} {
  wait -i $::tenv(sid_$id)
  unset ::tenv(sid_$id)
  return
}

#
# --------------------------------------------------------------------
#
proc et_exp {args} {
  set ::timeout 10.
  foreach {cmd val} $args {
    switch -glob -- $cmd {
      i   { set ::spawn_id $val }
      t   { set ::timeout  $val }
      s   { send $val }
      e   { if {$val eq "eof"} {
              expect {
                eof      { }
                timeout  { error "FAIL: missed 'eof'" }
              }
            } else {
              expect {
                -re $val { } 
                eof      { error "FAIL: unexpected 'eof' seen" }
                timeout  { error "FAIL: missed '$val'" }
              }
            }
          }
      ct[0-9] { set slot [string range $cmd 2 2]
                set ::tenv(c_$val) $expect_out($slot,string) }
      cg[0-9] { set slot [string range $cmd 2 2]
                set ::genv(c_$val) $expect_out($slot,string) }
      default { error "invalid et_exp option '$cmd'" }
    }
  }
  return
}

#
# --------------------------------------------------------------------
#
proc et_cmd {cmd args} {
  if { [catch {$cmd {*}$args} msg]} {
    puts "$cmd-E: $msg"
    return 1
  }
  return 0
}

#
# --------------------------------------------------------------------
#
proc et_cmdl {cmd args} {
  if { [catch {$cmd {*}$args} msg]} {
    putl ""
    putl "--------------------------------------------------"
    putb "$cmd FAILed with '$msg'"
    putl "--------------------------------------------------"
    putl $::errorInfo
    return 1
  }
  return 0
}

#
# --------------------------------------------------------------------
#
proc et_dostep {cmd args} {
  if {[et_cmdl $cmd {*}$args]} { incr ::tenv(FAIL) }
  return
}

#
# --------------------------------------------------------------------
#
proc et_tenv_cleanup {} {
  if {[info exists ::tenv]} {
    if {[info exists ::tenv(namespace)]} {
      namespace delete $::tenv(namespace)
    }
    unset ::tenv
  }
}

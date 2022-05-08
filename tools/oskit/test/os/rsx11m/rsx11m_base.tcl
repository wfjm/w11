# $Id: rsx11m_base.tcl 1196 2019-07-20 18:18:16Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-07-20  1196   1.1    Use os namespace rsx11m
# 2019-06-29  1173   1.0    Initial version
# 2019-06-10  1163   0.1    First draft
#---
# basic procs for rsx11m tests
#

set ::tenv(namespace) "rsx11m";         # os namespace
set ::tenv(os_pr) "\[\n\r\]+>";         # system prompt

namespace eval rsx11m {
  #
  # ------------------------------------------------------------------
  #
  proc rsx_date {fmt {dyr 32}} {
    set tnow [clock seconds]
    set yrs  [clock format $tnow -format "%Y"]
    set res ""
    switch -- $fmt {
      "hm_dmy2" { append res [clock format $tnow -format "%H:%M"]
                  append res [clock format $tnow -format " %d-%b"]
                  append res [format "-%2d" [expr {$yrs-$dyr-1900}] ]
                }
      "hm_dmy4" { append res [clock format $tnow -format "%H:%M"]
                  append res [clock format $tnow -format " %d-%b"]
                  append res [format "-%4d" [expr {$yrs-$dyr}] ]
                }
      "dmy2_hm" { append res [clock format $tnow -format "%d-%b"]
                  append res [format "-%2d" [expr {$yrs-$dyr-1900}] ]
                  append res [clock format $tnow -format " %H:%M"]
                }
      default { error "rsx_date-E: bad format '$fmt'" }
    }
    return $res
  }

  #
  # ------------------------------------------------------------------
  #
  set ::tenv(proc_boot) "rsx11m::boot"
  proc boot {} {
    et_spawn_term "tta0"
    
    et_exp t 30 e $::tenv(startup_q1) s $::tenv(startup_a1)
    if {[info exists ::tenv(startup_q2)]} {
      et_exp t 30 e $::tenv(startup_q2) s $::tenv(startup_a2)
    }
    if {[info exists ::tenv(startup_end)]} {
      et_exp t 90 e $::tenv(startup_end)
    }
    if {[info exists ::tenv(startup_lc)]} {
      et_exp e $::tenv(os_pr)
      after $::tenv(startup_lw)
      et_exp s $::tenv(startup_lc)
      et_exp e $::tenv(startup_lq)
      et_exp s $::tenv(startup_la)
    }
    et_exp t 30 e $::tenv(os_pr)
    return
  }

  #
  # --------------------------------------------------------------------
  #
  set ::tenv(proc_halt) "rsx11m::halt"
  proc halt {} {
    et_exp i $::tenv(sid_tta0)
    et_exp s "\r"  e $::tenv(os_pr)
    et_exp s "run \$shutup\r"
    et_exp e $::tenv(shutdown_q1) s $::tenv(shutdown_a1)
    if {[info exists ::tenv(shutdown_q2)]} {
      et_exp e $::tenv(shutdown_q2) s $::tenv(shutdown_a2)
    }
    if {[info exists ::tenv(shutdown_q3)]} {
      et_exp e $::tenv(shutdown_q3) s $::tenv(shutdown_a3)
    }
    if {[info exists ::tenv(shutdown_end)]} {
      et_exp t 60 e $::tenv(shutdown_end)
    } else {
      set ::timeout 20.
      expect {
        -re "."   { exp_continue }
        timeout   { }
        eof       { error "FAIL: rsx11m_halt: unexpected 'eof' seen" }
      }
    }
    return
  }

  #
  # ------------------------------------------------------------------
  #
  lappend ::tenv(procs_test) "rsx11m::test_basic"
  proc test_basic {} {
    et_exp i $::tenv(sid_tta0)
    et_exp s "par\r"
    et_exp e "GEN +\[0-7\]+ +\[0-7\]+"
    et_exp e $::tenv(os_pr)
    et_exp s "dev\r"
    et_exp e "TT0:.+?(LOGGED ON|Logged in).+?(LOADED|Loaded)"
    et_exp e $::tenv(os_pr)
    et_exp s "tas\r"
    et_exp e "\.\.\.PIP"
    et_exp e $::tenv(os_pr)
    return
  }

}

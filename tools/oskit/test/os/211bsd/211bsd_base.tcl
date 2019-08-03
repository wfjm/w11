# $Id: 211bsd_base.tcl 1196 2019-07-20 18:18:16Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-07-20  1196   1.1    Use os namespace 211bsd
# 2019-06-29  1173   1.0    Initial version
# 2019-06-10  1162   0.1    First draft
#---
# basic procs for 211bsd tests
#

set ::tenv(namespace) "211bsd";         # os namespace
set ::tenv(os_kpr) "\[\n\r\]+# ";       # kernel prompt
set ::tenv(os_upr) "\[\n\r\]+$ ";       # user   prompt

namespace eval 211bsd {
  #
  # ------------------------------------------------------------------
  #
  set ::tenv(proc_boot) "211bsd::boot"
  proc boot {} {
    et_spawn_term "tta0"
    et_exp e "70Boot from (.+?) at"         ct1 bootdev
    et_exp e ": "   s  "\r"
    et_exp e "phys mem  = (\[0-9\]+)\n"     ct1 pmem
    et_exp e "avail mem = (\[0-9\]+)\n"     ct1 amem
    et_exp e "user mem  = (\[0-9\]+)\n"     ct1 umem
    et_exp t 30 e $::tenv(os_kpr)  s  "\004"
    et_exp t 30 e "login:"       s  "root\r"
    et_exp t 10 e "# "
    return
  }

  #
  # ------------------------------------------------------------------
  #
  set ::tenv(proc_halt) "211bsd::halt"
  proc halt {} {
    et_exp i $::tenv(sid_tta0)
    et_exp s "\r"  e $::tenv(os_kpr)
    et_exp s "halt\r"
    et_exp t 30 e "syncing disks"
    et_exp t 10 e "halting"
    return
  }
  
  #
  # ------------------------------------------------------------------
  #
  lappend ::tenv(procs_test) "211bsd::test_basic"
  proc test_basic {} {
    et_exp i $::tenv(sid_tta0)
    et_exp s "mount\r"
    et_exp e "(/dev/\[a-z0-9\]+?) on /"   ct1 rootdev
    et_exp e $::tenv(os_kpr)
    et_exp s "pstat -T\r"
    et_exp e "swapmap entries"
    et_exp e "coremap entries"
    et_exp e "ub_map entries"
    et_exp e $::tenv(os_kpr)
    return
  }
  
}

# $Id: hook_ibmon_xua.tcl 1169 2019-06-21 07:00:59Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2017-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
if {[cpu0 imap -testname im.lolim]} {
  puts "hook: start ibmon for xua"
  # set filter on xua registers
  # repeat collapse for reads (211bsd driver does polling!)
  .imd
  .imf xua.pr0 xua.pr3
  .ime R
} else {
  puts "hook: ibmon not available, hook_ibmon_xua ignored"
}

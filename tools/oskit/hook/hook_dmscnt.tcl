# $Id: hook_dmscnt.tcl 1169 2019-06-21 07:00:59Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2017-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
if {[cpu0 imap -testname sc.cntl]} {
  puts "hook: start dmscnt"
  rw11::sc_start
} else {
  puts "hook: dmscnt not available, hook_dmscnt ignored"
}

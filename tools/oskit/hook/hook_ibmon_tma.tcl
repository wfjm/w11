# $Id: hook_ibmon_tma.tcl 1169 2019-06-21 07:00:59Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
if {[cpu0 imap -testname im.lolim]} {
  puts "hook: start ibmon for tma"
  package require ibd_ibmon
  ibd_ibmon::stop
  cpu0 cp -wibr im.lolim [cpu0 imap tma.sr] \
          -wibr im.hilim [cpu0 imap tma.rl]
  ibd_ibmon::start
} else {
  puts "hook: ibmon not available, hook_ibmon_tma ignored"
}

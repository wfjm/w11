# $Id: hook_trace_dza.tcl 1169 2019-06-21 07:00:59Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
puts "hook: trace DZ11 to rlc.log"
rlc set logfile rlc.log
cpu0dza set trace 5

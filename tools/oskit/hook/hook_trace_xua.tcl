# $Id: hook_trace_xua.tcl 1378 2023-02-23 10:45:17Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2017-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
puts "hook: trace DEUNA to rlc.log"
rlc set logfile rlc.log
cpu0xua set trace 3

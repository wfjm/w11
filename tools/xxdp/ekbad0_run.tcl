# $Id: ekbad0_run.tcl 1319 2022-11-21 14:20:45Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
puts "PDP 11/70 cpu diagnostic part 1"
puts "..from ekbad0 (from xxdp22)"
#
cpu0 ldabs to_lda/ekbad0.lda
#
# set console to 7bit mode
cpu0tta0 set to7bit 1
#
# ensure console interrupt not immediate
cpu0tta  set txrlim 5
#
# check for debug hook
rutil::dohook "ekbad0_hook"
#
.csta 0200

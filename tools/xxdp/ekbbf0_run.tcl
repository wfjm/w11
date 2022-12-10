# $Id: ekbbf0_run.tcl 1319 2022-11-21 14:20:45Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2017-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
puts "PDP 11/70 cpu diagnostic part 2"
puts "..from ekbbf0.ld"
#
cpu0 ldabs to_lda/ekbbf0.lda
#
# set console to 7bit mode
cpu0tta0 set to7bit 1
#
# apply patches
source patch_dep.tcl
source ekbbf0_patch_w11a.tcl
#
# set switch register
puts "setup switches"
puts "004000  11  inhibit iterations"
puts "000100  06  skip bus request 6 test"
puts "000040  05  skip bus request 5 test"
puts "000020  04  skip bus request 4 test"
puts "000010  03  enables test 042"
puts "000001  00  skip operator intervention testing"
puts "------"
puts "004171"
.d sdreg/r 004171
#
# check for debug hook
rutil::dohook "ekbbf0_hook"
#
.csta 0200

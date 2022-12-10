# $Id: ekbee1_run.tcl 1318 2022-11-21 09:27:32Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
puts "EKBE - 11/70 memory management"
puts "..from ekbee1.lda"
#
cpu0 ldabs to_lda/ekbee1.lda
#
# apply patches
source patch_dep.tcl
source ekbee1_patch_w11a.tcl
#
# set console to 7bit mode
cpu0tta0 set to7bit 1
#
# set switch register
puts "setup switches"
puts "004000  11  inhibit iterations"
puts "------"
puts "004000"
.d sdreg/r 004000
#
# check for debug hook
rutil::dohook "ekbee1_hook"
#
.csta 0200

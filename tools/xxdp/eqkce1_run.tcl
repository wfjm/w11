# $Id: eqkce1_run.tcl 1320 2022-11-22 18:52:59Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
puts "EQKC - instruction exerciser"
puts "..from eqkce1.lda"
#
cpu0 ldabs to_lda/eqkce1.lda
#
# set console to 7bit mode
cpu0tta0 set to7bit 1
#
# ensure console interrupt not immediate
cpu0tta  set txrlim 4
#
# set switch register
puts "setup switches"
puts "010000  12  INHIBIT UBE"
puts "004000  11  INHIBIT ITTERATIONS"
puts "000200   7  INHIBIT TYPEOUT OF THIS TEXT AND SYS SIZE"
puts "000100   6  INHIBIT RELOCATION"
puts "000040   5  INHIBIT ROUND ROBIN RELOCATION"
puts "000020   4  INHIBIT RANDOM DISK ADDRESS"
puts "000010   3  INHIBIT MBT"
puts "------"
puts "014370"
puts ""
puts ""
puts ""
puts ""
.d sdreg/r 014370
#
# check for debug hook
rutil::dohook "eqkce1_hook"
#
.csta 0200

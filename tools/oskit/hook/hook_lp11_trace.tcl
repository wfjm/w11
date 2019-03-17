# $Id: hook_lp11_trace.tcl 1121 2019-03-11 08:59:12Z mueller $
puts "hook: trace LP11 to rlc.log"
rlc set logfile rlc.log
cpu0lpa set trace 2

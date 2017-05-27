# $Id: hook_deuna_trace.tcl 858 2017-03-05 17:41:37Z mueller $
puts "hook: trace DEUNA to rlc.log"
rlc set logfile rlc.log
cpu0xua set trace 2

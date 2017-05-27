# $Id: hook_deuna_trace.tcl 899 2017-05-27 13:25:41Z mueller $
puts "hook: trace DEUNA to rlc.log"
rlc set logfile rlc.log
cpu0xua set trace 2

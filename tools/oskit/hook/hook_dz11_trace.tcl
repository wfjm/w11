# $Id: hook_dz11_trace.tcl 1149 2019-05-12 21:00:29Z mueller $
puts "hook: trace DZ11 to rlc.log"
rlc set logfile rlc.log
cpu0dza set trace 5

# $Id: hook_blkdev_trace.tcl 689 2015-06-05 14:33:18Z mueller $
puts "hook: trace all block devices to rlc.log"
rlc set logfile rlc.log
cpu0rka set trace 2
cpu0rla set trace 2
cpu0rpa set trace 2
cpu0tma set trace 2

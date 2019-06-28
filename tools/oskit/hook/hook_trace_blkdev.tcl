# $Id: hook_blkdev_trace.tcl 899 2017-05-27 13:25:41Z mueller $
puts "hook: trace all block devices to rlc.log"
rlc set logfile rlc.log
cpu0rka set trace 2
cpu0rla set trace 2
cpu0rpa set trace 2
cpu0tma set trace 2

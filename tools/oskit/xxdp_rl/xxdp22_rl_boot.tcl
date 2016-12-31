# $Id: xxdp22_rl_boot.tcl 835 2016-12-31 10:00:14Z mueller $
#
# Setup file for XXDP V2.2 RL02 based system
#
# Usage:
#   
# console_starter -d DL0 &
# ti_w11 -xxx @xxdp22_rl_boot.tcl     ( -xxx depends on sim or fpga connect)
#

# setup w11 cpu
rutil::dohook "preinithook"
puts [rlw]

# setup tt,lp,pp (single console; enable rx rate limiter on old DEC OS)
rw11::setup_tt "cpu0" ndl 1 dlrlim 5 to7bit 1
rw11::setup_lp 
rw11::setup_pp

# mount disks
cpu0rla0 att xxdp22.dsk

# and boot
rutil::dohook "preboothook"
cpu0 boot rla0

# $Id: xxdp25_rl_boot.tcl 1128 2019-04-07 13:12:47Z mueller $
#
# Setup file for XXDP V2.5 RL02 based system
#
# Usage:
#   
# console_starter -d DL0 &
# ti_w11 -xxx @xxdp25_rl_boot.tcl     ( -xxx depends on sim or fpga connect)
#

# setup w11 cpu
rutil::dohook "preinithook"
puts [rlw]

# setup tt,lp,pp (single console; enable rx rate limiter on old DEC OS)
rw11::setup_tt "cpu0" ndl 1 dlrrlim 5 to7bit 1
rw11::setup_lp 
rw11::setup_pp

# mount disks
cpu0rla0 att xxdp25.dsk

# and boot
rutil::dohook "preboothook"
cpu0 boot rla0

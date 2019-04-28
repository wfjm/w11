# $Id: rt11-53_rl_boot.tcl 1139 2019-04-27 14:00:38Z mueller $
#
# Setup file for RT-11 V5.3 RL02 based system
#
# Usage:
#   
# console_starter -d DL0 &
# ti_w11 -xxx @rt11-53_rl_boot.tcl     ( -xxx depends on sim or fpga connect)
#

# setup w11 cpu
rutil::dohook "preinithook"
puts [rlw]

# setup tt,lp,pp (single console; enable rx rate limiter on old DEC OS)
rw11::setup_tt "cpu0" ndl 1 dlrxrlim 5
rw11::setup_lp 
rw11::setup_pp

# mount disks
cpu0rla0 att RT11_V5.3_SYSTEM.dsk

# and boot
rutil::dohook "preboothook"
cpu0 boot rla0

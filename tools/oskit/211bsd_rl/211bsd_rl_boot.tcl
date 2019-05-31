# $Id: 211bsd_rl_boot.tcl 1154 2019-05-30 13:21:01Z mueller $
#
# Setup file for 211bsd RL02 based system
#
# Usage:
#   
# console_starter -d DL0 &
# console_starter -d DL1 &
# console_starter -d DZ0 &
# console_starter -d DZ1 &
# ti_w11 -xxx @211bsd_rl_boot.tcl        ( -xxx depends on sim or fpga connect)
#

# setup w11 cpu
rutil::dohook "preinithook"
puts [rlw]

# setup tt,lp (211bsd uses parity -> use 7 bit mode)
rw11::setup_tt "cpu0" ndl 2 dlrxrlim 5 ndz 2 dzrxrlim 5 to7bit 1
rw11::setup_lp 

# mount disks
cpu0rla0 att 211bsd_rl_root.dsk
cpu0rla1 att 211bsd_rl_usr.dsk

# and boot
rutil::dohook "preboothook"
cpu0 boot rla0

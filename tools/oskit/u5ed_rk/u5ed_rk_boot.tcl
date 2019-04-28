# $Id: u5ed_rk_boot.tcl 1139 2019-04-27 14:00:38Z mueller $
#
# Setup file for Unix 5th Edition RK05 based system
#
# Usage:
#   
# console_starter -d DL0 &
# ti_w11 -xxx @u5ed_rk_boot.tcl         ( -xxx depends on sim or fpga connect)

# setup w11 cpu
rutil::dohook "preinithook"
puts [rlw]

# setup tt,lp (uses only 1 console; uses parity -> use 7 bit mode)
rw11::setup_tt "cpu0" ndl 1 dlrxrlim 5 to7bit 1
rw11::setup_lp 

# mount disks
cpu0rka0 att u5ed_rk.dsk

# and boot
rutil::dohook "preboothook"
cpu0 boot rka0

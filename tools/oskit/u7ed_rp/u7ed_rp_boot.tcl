# $Id: u7ed_rp_boot.tcl 921 2017-07-02 11:55:14Z mueller $
#
# Setup file for Unix 7th Edition RP04 based system
#
# Usage:
#   
# console_starter -d DL0 &
# ti_w11 -xxx @u7ed_rp_boot.tcl         ( -xxx depends on sim or fpga connect)

# setup w11 cpu
rutil::dohook "preinithook"
puts [rlw]

# setup tt,lp (uses only 1 console; uses parity -> use 7 bit mode)
rw11::setup_tt "cpu0" ndl 1 to7bit 1
rw11::setup_lp 

# mount disks
cpu0rpa0 set type rp04
cpu0rpa0 att u7ed_rp.dsk

# and boot
rutil::dohook "preboothook"
cpu0 boot rpa0

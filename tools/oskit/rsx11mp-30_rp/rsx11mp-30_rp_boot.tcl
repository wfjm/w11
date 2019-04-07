# $Id: rsx11mp-30_rp_boot.tcl 1126 2019-04-06 17:37:40Z mueller $
#
# Setup file for RSX11-M+ V3.0 RP06 based system
#
# Usage:
#   
# console_starter -d DL0 &
# console_starter -d DL1 &
# ti_w11 -xxx @rsx11mp-30_rp_boot.tcl    ( -xxx depends on sim or fpga connect)
#

# setup w11 cpu
rutil::dohook "preinithook"
puts [rlw]

# setup tt,lp,pp
rw11::setup_tt "cpu0" to7bit 1
rw11::setup_lp 
rw11::setup_pp

# mount disks
cpu0rpa0 set type rp06
cpu0rpa1 set type rp06

cpu0rpa0 att rsx11mp-30.dsk

# and boot
rutil::dohook "preboothook"
cpu0 boot rpa0

# $Id: 211bsd_rk_boot.tcl 511 2013-04-27 13:51:46Z mueller $
#
# Setup file for 211bsd RK based system (w11a, in sys/tb area...)
#
# Usage:
#   
# telnet_starter -d DL0 &
# telnet_starter -d DL1 &
# torri -xxx @211bsd_rk_boot.tcl        ( -xxx depends on sim or fpga connect)
#

# setup w11 cpu
puts [rlw]

# 2.11 bsd uses parity, so strip it
cpu0tta0 set to7bit 1
cpu0ttb0 set to7bit 1

# setup tcp links for terminals
cpu0tta0 att "tcp:?port=8000"
cpu0ttb0 att "tcp:?port=8001"

# setup log files
cpu0tta0 set log "tt_dl0.log?crlf"
cpu0ttb0 set log "tt_dl1.log?crlf"

# mount disks
cpu0rka0 att 211bsd_rk_root.dsk
cpu0rka1 att 211bsd_rk_swap.dsk
cpu0rka2 att 211bsd_rk_tmp.dsk
cpu0rka3 att 211bsd_rk_bin.dsk
cpu0rka4 att 211bsd_rk_usr.dsk

# and boot
#cpu0rka  set trace 1
rw11::cpumon
rw11::cpucons
cpu0 boot rka0

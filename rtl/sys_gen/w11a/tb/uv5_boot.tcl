# $Id: uv5_boot.tcl 511 2013-04-27 13:51:46Z mueller $
#
# Setup file for Unix V5 System
#
# Usage:
#   
# telnet_starter -d DL0 &
# torri -xxx @uv5_boot.tcl              ( -xxx depends on sim or fpga connect)

# setup w11 cpu
puts [rlw]

# 2.11 bsd uses parity, so strip it
cpu0tta0 set to7bit 1

# setup tcp links for terminals
cpu0tta0 att "tcp:?port=8000"

# setup log files
cpu0tta0 set log "tt_dl0.log?crlf"

# mount disks
cpu0rka0 att unix_v5_rk.dsk

# and boot
#cpu0rka  set trace 1
rw11::cpumon
rw11::cpucons
cpu0 boot rka0

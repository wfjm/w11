# $Id: viv_tools_config.tcl 895 2017-05-07 07:38:47Z mueller $
#
# Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2017-01-07   840   1.2    use get_hw_servers localhost:*
# 2016-04-02   758   1.1    add USR_ACCESS readback
# 2015-02-14   646   1.0    Initial version
#

#
# --------------------------------------------------------------------
#
proc rvtb_format_usracc {usracc} {
  set sec [expr { ($usracc >>  0) & 0x3f } ];       # 6 bit 05:00 
  set min [expr { ($usracc >>  6) & 0x3f } ];       # 6 bit 11:06 
  set hr  [expr { ($usracc >> 12) & 0x1f } ];       # 5 bit 16:12 
  set yr  [expr {(($usracc >> 17) & 0x3f)+2000} ];  # 6 bit 22:17 
  set mo  [expr { ($usracc >> 23) & 0x0f } ];       # 4 bit 26:23 
  set day [expr { ($usracc >> 27) & 0x1f } ];       # 5 bit 31:27 
  return [format "%04d-%02d-%02d %02d:%02d:%02d" $yr $mo $day $hr $min $sec]
}

#
# --------------------------------------------------------------------
#
proc rvtb_default_config {stem} {
  # open and connect to hardware server
  open_hw
  connect_hw_server

  # connect to target (Note: localhost:* will fail on vivado 2015.1 and before)
  open_hw_target [lindex [get_hw_targets -of_objects \
                            [get_hw_servers localhost:*]] 0]

  # setup bitfile
  set_property PROGRAM.FILE "${stem}.bit" [lindex [get_hw_devices] 0]

  # and configure FPGA
  program_hw_devices [lindex [get_hw_devices] 0]

  # and check USR_ACCESS setting
  set usracc_raw [get_property REGISTER.USR_ACCESS [lindex [get_hw_devices] 0] ]
  set usracc_num "0x$usracc_raw"
  set usracc_fmt [rvtb_format_usracc $usracc_num]
  puts ""
  puts "USR_ACCESS: 0x$usracc_raw  $usracc_fmt"
  puts ""

  return;
}

# $Id: util.tcl 375 2011-04-02 07:56:47Z mueller $
#
# Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2, or at your option any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2011-03-27   374   1.0    Initial version
# 2011-03-19   372   0.1    First draft
#

package provide rbs3hio 1.0

package require rutil
package require rutiltpp

namespace eval rbs3hio {
  #
  # setup register descriptions for s3_humanio_rbus
  #
  regdsc CNTL {daten 11} {dpen 10} {leden 9} {swien 8} {btn 3 4}
  regdsc LED  {dp 11 4} {led 7 8}
  #
  # setup: amap definitions for s3_humanio_rbus
  # 
  proc setup {base} {
    rlc amap -insert hi.cntl [expr $base + 0x00]
    rlc amap -insert hi.swi  [expr $base + 0x01]
    rlc amap -insert hi.led  [expr $base + 0x02]
    rlc amap -insert hi.dsp  [expr $base + 0x03]
  }
  #
  # init: reset s3_humanio_rbus (clear all enables)
  # 
  proc init {} {
    rlc exec -wreg hi.cntl 0x0000
  }
  #
  # print: show status
  # 
  proc print {} {
    set rval {}
    rlc exec \
      -rreg hi.cntl r_cntl \
      -rreg hi.swi  r_swi  \
      -rreg hi.led  r_led  \
      -rreg hi.dsp  r_dsp
    set led    [regget rbs3hio::LED(led)    $r_led]
    set dp     [regget rbs3hio::LED(dp)     $r_led]
    append rval "  cntl: [regtxt rbs3hio::CNTL $r_cntl]"
    append rval "\n  leds: [pbvi b8 $led]"
    set dspval ""
    for {set i 3} {$i >= 0} {incr i -1} {
      set digval [expr ( $r_dsp >> ( 4 * $i ) ) & 0x0f]
      set digdp  [expr ( $dp >> $i ) & 0x01]
      append dspval [format "%x" $digval]
      if {$digdp} {append dspval "."} else {append dspval " "}
    }
    append rval "\n  disp: [pbvi b16 $r_dsp] - [pbvi b4 $dp] -> \"$dspval\""
    return $rval
  }
}

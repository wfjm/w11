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
# 2011-03-19   372   0.1    Initial version
#

package provide rbbram 1.0

namespace eval rbbram {
  #
  # setup register descriptions for rbd_bram
  #
  regdsc CNTL {nbusy 15 6} {addr 9 10}
  #
  # setup: amap definitions for rbd_bram
  # 
  proc setup {{base 0x00f4}} {
    rlc amap -insert br.cntl [expr $base + 0x00]
    rlc amap -insert br.data [expr $base + 0x01]
  }
  #
  # init: reset rbd_bram (clear cntl register)
  # 
  proc init {} {
    rlc exec -wreg br.cntl 0x0000
  }
}

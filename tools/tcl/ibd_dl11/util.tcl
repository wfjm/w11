# $Id: util.tcl 1126 2019-04-06 17:37:40Z mueller $
#
# Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2019-04-06  1126   1.1    updates for buffered dl11
# 2015-12-26   719   1.0    Initial version
#

package provide ibd_dl11 1.0

package require rlink
package require rw11util
package require rw11

namespace eval ibd_dl11 {
  #
  # setup register descriptions for ibd_dl11 ---------------------------------
  #

  regdsc RCSR   {done 7} {ie 6}
  regdsc RRCSR  {rlim 14 3} {type 10 3} {done 7} {ie 6} {fclr 5}
  regdsc RRBUF  {rrdy 15} {size 14 7 "d"}

  regdsc XCSR   {done 7} {ie 6}
  regdsc RXCSR  {rlim 14 3} {done 7} {ie 6}
  regdsc RXBUF  {val 15} {size 14 7 "d"} {data 7 8 "o"}

  rw11util::regmap_add ibd_dl11 tt?.rcsr {l? RCSR r? RRCSR}
  rw11util::regmap_add ibd_dl11 tt?.rbuf {r? RRBUF}
  rw11util::regmap_add ibd_dl11 tt?.xcsr {l? XCSR r? RXCSR}
  rw11util::regmap_add ibd_dl11 tt?.xbuf {r? RXBUF}
  
  variable ANUM  1;             # 1st DL11

  #
  # setup: create controller with default attributes -------------------------
  #
  proc setup {{cpu "cpu0"}} {
    return [rw11::setup_cntl $cpu "dl11" "tta"]
  }
}

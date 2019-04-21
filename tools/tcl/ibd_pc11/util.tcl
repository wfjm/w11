# $Id: util.tcl 1134 2019-04-21 17:18:03Z mueller $
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
# 2019-04-21  1134   1.1    updates for buffered pc11
# 2015-12-26   719   1.0    Initial version
#

package provide ibd_pc11 1.0

package require rlink
package require rw11util
package require rw11

namespace eval ibd_pc11 {
  #
  # setup register descriptions for ibd_pc11 ---------------------------------
  #

  regdsc RCSR   {err 15} {busy 11} {done 7} {ie 6} {ena 0}
  regdsc RRCSR  {err 15} {rlim 14 3} {busy 11} {type 10 3} \
                  {done 7} {ie 6} {fclr 5}
  regdsc RRBUF  {rbusy 15} {rsize 14 7 "d"} {psize 6 7 "d"}

  regdsc PCSR   {err 15} {rdy 7} {ie 6}
  regdsc RPCSR  {err 15} {rlim 14 3} {rdy 7} {ie 6}
  
  regdsc RPBUF  {val 15} {size 14 7 "d"} {data 7 8 "o"}

  rw11util::regmap_add ibd_pc11 pc?.rcsr {l? RCSR r? RRCSR}
  rw11util::regmap_add ibd_pc11 pc?.rbuf {r? RRBUF}
  rw11util::regmap_add ibd_pc11 pc?.pcsr {l? PCSR r? RPCSR}
  rw11util::regmap_add ibd_pc11 pc?.pbuf {r? RPBUF}

  variable ANUM 10

  #
  # setup: create controller with default attributes -------------------------
  #
  proc setup {{cpu "cpu0"}} {
    return [rw11::setup_cntl $cpu "pc11" "pca"]
  }
  #
  # rdump: register dump - rem view ------------------------------------------
  #
  proc rdump {{cpu "cpu0"}} {
    set rval {}
    $cpu cp -ribr "pca.rcsr" rcsr \
            -ribr "pca.rbuf" rbuf \
            -ribr "pca.pcsr" pcsr
    append rval "Controller registers:"
    append rval [format "\n  rcsr: %6.6o  %s" $rcsr \
                                              [regtxt ibd_pc11::RRCSR $rcsr]]
    append rval [format "\n  rbuf: %6.6o  %s" $rbuf \
                                              [regtxt ibd_pc11::RRBUF $rbuf]]
    append rval [format "\n  pcsr: %6.6o  %s" $pcsr \
                                              [regtxt ibd_pc11::RPCSR $pcsr]]
    
  }
}

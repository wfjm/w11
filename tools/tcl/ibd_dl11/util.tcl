# $Id: util.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2019-05-30  1155   1.1.1  size->fuse rename
# 2019-04-24  1138   1.1    updates for buffered dl11
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
  regdsc RRCSR  {rlim 14 3} {type 10 3} {done 7} {ie 6} {ir 5} {rlb 4} {fclr 1}
  regdsc RRBUF  {rfuse 14 7 "d"} {xfuse 6 7 "d"}

  regdsc XCSR   {rdy 7} {ie 6}
  regdsc RXCSR  {rlim 14 3} {rdy 7} {ie 6} {ir 5} {rlb 4}
  regdsc RXBUF  {val 15} {fuse 14 7 "d"} {data 7 8 "o"}

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
  #
  # rdump: register dump - rem view ------------------------------------------
  #
  proc rdump {{cpu "cpu0"}} {
    set rval {}
    $cpu cp -ribr "tta.rcsr" rcsr \
            -ribr "tta.rbuf" rbuf \
            -ribr "tta.xcsr" xcsr
    append rval "Controller registers:"
    append rval [format "\n  rcsr: %6.6o  %s" $rcsr \
                                              [regtxt ibd_dl11::RRCSR $rcsr]]
    append rval [format "\n  rbuf: %6.6o  %s" $rbuf \
                                              [regtxt ibd_dl11::RRBUF $rbuf]]
    append rval [format "\n  xcsr: %6.6o  %s" $xcsr \
                                              [regtxt ibd_dl11::RXCSR $xcsr]]
    
  }
}

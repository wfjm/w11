# $Id: util.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2019-05-30  1155   1.1.1  size->fuse rename
# 2019-03-17  1123   1.1.1  add print formats for RBUF; add RCSR.rlim
# 2019-03-09  1120   1.1    add setup proc; add regdsc for RCSR,RBUF 
# 2015-12-26   719   1.0    Initial version
#

package provide ibd_lp11 1.0

package require rlink
package require rw11util
package require rw11

namespace eval ibd_lp11 {
  #
  # setup register descriptions for ibd_lp11 ---------------------------------
  #

  regdsc CSR   {err 15} {done 7} {ie 6}
  regdsc RCSR  {err 15} {rlim 14 3} {type 10 3} {done 7} {ie 6} {ir 5}
  regdsc RBUF  {val 15} {fuse 14 7 "d"} {data 6 7 "o"}

  rw11util::regmap_add ibd_lp11 lp?.csr {l? CSR r? RCSR}
  rw11util::regmap_add ibd_lp11 lp?.buf {r? RBUF}

  variable ANUM 8

  #
  # setup: create controller with default attributes -------------------------
  #
  proc setup {{cpu "cpu0"}} {
    return [rw11::setup_cntl $cpu "lp11" "lpa"]
  }
}

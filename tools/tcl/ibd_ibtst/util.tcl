# $Id: util.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2019-03-02  1116   1.0.1  rename dly[rw] -> bsy[rw]; add datab
# 2019-02-16  1112   1.0    Initial version
#

package provide ibd_ibtst 1.0

package require rlink
package require rw11util
package require rw11

namespace eval ibd_ibtst {
  #
  # setup register descriptions for ibd_ibtst --------------------------------
  #

  regdsc CNTL  {fclr 15} {datab 8} {datto 7} {nobyt 6} {bsyw 5} {bsyr 4} \
               {remw 3} {remr 2} {locw 1} {locr 0} 
  regdsc STAT  {fsize 15 4} {racc 6} {cacc 5} \
               {be1 4} {be0 3} {rmw 2} {we 1} {re 0} 

  rw11util::regmap_add ibd_ibtst it.cntl {r? CNTL}
  rw11util::regmap_add ibd_ibtst it.stat {r? STAT}

}

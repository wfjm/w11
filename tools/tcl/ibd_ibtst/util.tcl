# $Id: util.tcl 1112 2019-02-17 11:10:04Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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

  regdsc CNTL  {fclr 15} {datto 7} {nobyt 6} {dlyw 5} {dlyr 4} \
               {remw 3} {remr 2} {locw 1} {locr 0} 
  regdsc STAT  {fsize 15 4} {racc 6} {cacc 5} \
               {be1 4} {be0 3} {rmw 2} {we 1} {re 0} 

  rw11util::regmap_add ibd_ibtst it.cntl {r? CNTL}
  rw11util::regmap_add ibd_ibtst it.stat {r? STAT}

}

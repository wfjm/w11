# $Id: util.tcl 719 2015-12-27 09:45:43Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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

  regdsc CSR  {err 15} {done 7} {ie 6}

  rw11util::regmap_add ibd_lp11 lp?.rcsr {?? CSR}

  variable ANUM 8

}

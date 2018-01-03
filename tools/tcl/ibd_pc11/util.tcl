# $Id: util.tcl 985 2018-01-03 08:59:40Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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

  regdsc RCSR  {err 15} {busy 11} {done 7} {ie 6} {enb 0}

  regdsc PCSR  {err 15} {done 7} {ie 6}

  rw11util::regmap_add ibd_pc11 pc?.rcsr {?? RCSR}
  rw11util::regmap_add ibd_pc11 pc?.xcsr {?? PCSR}

  variable ANUM 10
}

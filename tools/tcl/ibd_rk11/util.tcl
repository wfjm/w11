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

package provide ibd_rk11 1.0

package require rlink
package require rw11util
package require rw11

namespace eval ibd_rk11 {
  #
  # setup register descriptions for ibd_rk11 ---------------------------------
  #

  regdsc DS  {id 15 3} {hden 11} {dru 10} {sin 9} {sok 8} {dry 7} \
             {adry 6} {wps 5} {scsa 4} {sc 3 4}
  regdsc ER  {dre 15} {ovr 14} {wlo 13} {pge 11} \
             {nxm 10} {nxd 7} {nxc 6} {nxs 5} {cse 1} {wce 0}
  regdsc CS  {err 15} {he 14} {scp 13} {maint 12} {iba 11} {fmt 10} \
             {rwa 9} {sse 8} {rdy 7} {ide 6} {mex 5 2} \
             {func 3 3 "s:CRES:WR:RD:WCHK:SEEK:RCHK:DRES:WLCK"} \
             {go 0}
  regdsc DA  {drsel 15 3} {cyl 12 8} {sur 4} {sc 3 4}
  regdsc RMR {rid 15 3} {crdone 11} {sbclr 10} {creset 9} {fdone 8} {sdone 7 8}

  variable FUNC_CRES   [bvi b3 "000"]
  variable FUNC_WR     [bvi b3 "001"]
  variable FUNC_RD     [bvi b3 "010"]
  variable FUNC_WCHK   [bvi b3 "011"]
  variable FUNC_SEEK   [bvi b3 "100"]
  variable FUNC_RCHK   [bvi b3 "101"]
  variable FUNC_DRES   [bvi b3 "110"]
  variable FUNC_WLCK   [bvi b3 "111"]

  rw11util::regmap_add ibd_rk11 rk?.ds {?? DS}
  rw11util::regmap_add ibd_rk11 rk?.er {?? ER}
  rw11util::regmap_add ibd_rk11 rk?.cs {?? CS}
  rw11util::regmap_add ibd_rk11 rk?.da {?? DA}
  rw11util::regmap_add ibd_rk11 rk?.mr {r? RMR}

  variable ANUM 4
}

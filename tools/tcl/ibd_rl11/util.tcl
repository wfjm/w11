# $Id: util.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2015-12-26   719   1.0    Initial version
#

package provide ibd_rl11 1.0

package require rlink
package require rw11util
package require rw11

namespace eval ibd_rl11 {
  #
  # setup register descriptions for ibd_rl11 ---------------------------------
  #

  regdsc CS  {err 15} {de 14} {e 13 4} {ds 9 2} {crdy 7} {ie 6} {ba 5 2} \
             {func 3 3 "s:NOOP:WCHK:GS:SEEK:RHDR:WR:RD:RNHC"} \
             {drdy 0}
  regdsc RCS {mprem 15 5} {mploc 10 3} {ena_mprem 5} {ena_mploc 4}

  variable FUNC_NOOP   [bvi b3 "000"]
  variable FUNC_WCHK   [bvi b3 "001"]
  variable FUNC_GS     [bvi b3 "010"]
  variable FUNC_SEEK   [bvi b3 "011"]
  variable FUNC_RHDR   [bvi b3 "100"]
  variable FUNC_WR     [bvi b3 "101"]
  variable FUNC_RD     [bvi b3 "110"]
  variable FUNC_RNHC   [bvi b3 "111"]

  rw11util::regmap_add ibd_rl11 rl?.cs {l? CS r? RCS}

  variable ANUM 5
}

# $Id: patch_dep.tcl 1318 2022-11-21 09:27:32Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2022-09-93  1292   1.0    Initial version
#

# defines 'dep' to 'cpu0 dep' forwards
# convenient for patch files common for w11, SimH, and e11
#
proc dep {addr val} {
  cpu0 dep $addr $val
}

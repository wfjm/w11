# $Id: ostest_midmem_setup.tcl 1174 2019-06-29 18:00:47Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-06-29  1174   1.0    Initial version
# 2019-06-10  1162   0.1    First draft
#---
# setup for mid-size memory systems (>0.5 MB and <1MB)
#

source ostest_minmem_setup.tcl
#
lappend ::et_oskitdef "211bsd_rpmin"
#

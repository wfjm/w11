# $Id: ostest_midmem_setup.tcl 1235 2022-05-07 12:47:28Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2022-05-07  1236   1.1    only kits on default with oskit loader
# 2019-06-29  1174   1.0    Initial version
# 2019-06-10  1162   0.1    First draft
#---
# setup for mid-size memory systems (>0.5 MB and <1MB)
#

source ostest_minmem_setup.tcl
#
lappend ::et_oskitdef "211bsd_rpmin"
#
lappend ::et_oskitdef "rsx11mp-30_rp"
#lappend ::et_oskitdef "rsx11mp-46_rl"
#lappend ::et_oskitdef "rsx11mp-46_rp"

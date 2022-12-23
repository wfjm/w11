# $Id: gwinit.tcl 1335 2022-12-22 14:23:24Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2016-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2022-12-22  1334   1.1    main Tcl code now in tools/gwstart/bin
# 2016-07-23   792   1.0    Initial version
#

source "$::env(RETROBASE)/tools/gwstart/bin/gwutil.tcl"
source "$::env(RETROBASE)/tools/gwstart/bin/gwsigdb.tcl"
source "$::env(RETROBASE)/tools/gwstart/bin/gwsigdisp.tcl"

gwtools::doinit

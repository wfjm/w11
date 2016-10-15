# $Id: viv_init.tcl 792 2016-07-23 18:05:40Z mueller $
#
# Copyright 2015-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2016-07-22   792   1.1    relocate viv tcl code to tools/vivado
# 2015-02-14   646   1.0    Initial version
# 2015-01-25   637   0.1    First draft
#
source -notrace "$::env(RETROBASE)/tools/vivado/viv_tools_build.tcl"
source -notrace "$::env(RETROBASE)/tools/vivado/viv_tools_config.tcl"
source -notrace "$::env(RETROBASE)/tools/vivado/viv_tools_model.tcl"

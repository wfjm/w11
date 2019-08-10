# $Id: sys_w11a_br_arty_setup.tcl 1201 2019-08-10 16:51:22Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-08-08  1201   1.0    Initial version
#---
# setup for sys_w11a_br_arty
#
set ::genv(rri_opt)  "-tuD,12M,break,xon"
set ::genv(sys_path) "rtl/sys_gen/w11a/arty"
set ::genv(memsize)   176
source ostest_minmem_setup.tcl
source mcode_setup.tcl

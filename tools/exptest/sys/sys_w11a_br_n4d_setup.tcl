# $Id: sys_w11a_br_n4d_setup.tcl 1201 2019-08-10 16:51:22Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-08-08  1201   1.0    Initial version
#---
# setup for sys_w11a_br_n4d
#
set ::genv(rri_opt)  "-tuD,12M,break,cts"
set ::genv(sys_path) "rtl/sys_gen/w11a/nexys4d_bram"
set ::genv(memsize)  512
source ostest_midmem_setup.tcl
source mcode_setup.tcl

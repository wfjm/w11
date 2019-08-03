# $Id: sys_w11a_n2_setup.tcl 1196 2019-07-20 18:18:16Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-07-13  1193   1.1    add mcode_setup
# 2019-06-29  1174   1.0    Initial version
#---
# setup for sys_w11a_n2
#
set ::genv(xil_ide)  "ise"
set ::genv(rri_opt)  "-u"
set ::genv(sys_path) "rtl/sys_gen/w11a/nexys2"
set ::genv(memsize)  3840
source ostest_bigmem_setup.tcl
source mcode_setup.tcl

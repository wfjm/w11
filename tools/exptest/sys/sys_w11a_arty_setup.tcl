# $Id: sys_w11a_arty_setup.tcl 1193 2019-07-14 08:36:20Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-07-13  1193   1.1    add mcode_setup
# 2019-06-29  1173   1.0    Initial version
# 2019-06-16  1165   0.1    First draft
#---
# setup for sys_w11a_arty
#
set ::genv(rri_opt)  "-tuD,12M,break,xon"
set ::genv(sys_path) "rtl/sys_gen/w11a/arty"
source ostest_bigmem_setup.tcl
source mcode_setup.tcl

# $Id: xflow_default_nexys2.mk 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-01-27   477   1.0    Initial version
#---
#
# Setup for Digilent Nexys2
#
# setup default board (for impact), device and userid (for bitgen)
#
ISE_BOARD = nexys2
ISE_PATH  = xc3s1200e-fg320-4
#
# setup defaults for xflow option files for synthesis and implementation
#
ifndef XFLOWOPT_SYN
XFLOWOPT_SYN = syn_s3_speed.opt
endif
#
ifndef XFLOWOPT_IMP
XFLOWOPT_IMP = imp_s3_speed.opt
endif
#

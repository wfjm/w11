# $Id: xflow_default_nexys4.mk 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-09-21   534   1.0    Initial version
#---
#
# Setup for Digilent Nexys4
#
# setup default board (for impact), device and userid (for bitgen)
#
ISE_BOARD = nexys4
ISE_PATH  = xc7a100t-csg324-1
#
# setup defaults for xflow option files for synthesis and implementation
#
ifndef XFLOWOPT_SYN
XFLOWOPT_SYN = syn_7a_speed.opt
endif
#
ifndef XFLOWOPT_IMP
XFLOWOPT_IMP = imp_7a_speed.opt
endif
#

# $Id: Makefile 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.1    use includes from rtl/make
# 2007-12-14   101   1.0    Initial version
#
#
.PHONY : clean
#
clean : ghdl_clean
#
#-----
#
include ${RETROBASE}/rtl/make_ise/generic_ghdl.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_ghdl)
endif
#

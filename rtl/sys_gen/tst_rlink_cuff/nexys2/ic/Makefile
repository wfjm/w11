# $Id: Makefile 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2012- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2012-12-29   466   1.0    Initial version
#
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include ${RETROBASE}/rtl/make_ise/xflow_default_nexys2.mk
FX2_FILE  = nexys2_jtag_2fifo_ic.ihx
#
.PHONY : all clean
#
all : $(BIT_all)
#
clean : ise_clean
	rm -f $(VBOM_all:.vbom=.ucf)
#
#----
#
include ${RETROBASE}/rtl/make_ise/generic_xflow.mk
include ${RETROBASE}/rtl/make_ise/generic_ghdl.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
endif
#

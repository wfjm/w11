# $Id: Makefile 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-03-20   749   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
DCP_all  = $(VBOM_all:.vbom=_syn.dcp)
#
# reference board for test synthesis is Artix-7 based Nexys4
ifndef XTW_BOARD
  XTW_BOARD=nexys4
endif
include ${RETROBASE}/rtl/make_viv/viv_default_$(XTW_BOARD).mk
#
.PHONY : all clean distclean
#
all : tst_serloop
#
distclean :
	rm -f tst_serloop
#
clean : viv_clean
#
#-----
#
include ${RETROBASE}/rtl/make_viv/generic_vivado.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_vsyn)
endif
#

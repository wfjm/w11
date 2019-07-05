# $Id: Makefile 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2010-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2015-01-24   637   1.1.2  use nexys3 as default XTW_BOARD
# 2014-07-27   545   1.1.1  make reference board configurable via XTW_BOARD
# 2011-08-13   405   1.1    use includes from rtl/make
# 2010-05-23   293   1.0    Initial version (cloned..)
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
ifndef XTW_BOARD
  XTW_BOARD=nexys3
endif
include ${RETROBASE}/rtl/make_ise/xflow_default_$(XTW_BOARD).mk
#
.PHONY : all clean
#
all : $(NGC_all)
#
clean : ise_clean
#
#----
#
include ${RETROBASE}/rtl/make_ise/generic_xflow.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
endif
#

# $Id: Makefile 575 2014-07-27 20:55:41Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2014-07-27   545   1.0.1  make reference board configurable via XTW_BOARD
# 2011-11-26   433   1.0    Initial version (cloned..)
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
ifndef XTW_BOARD
  XTW_BOARD=nexys2
endif
include $(RETROBASE)/rtl/make/xflow_default_$(XTW_BOARD).mk
#
.PHONY : all clean
#
all : $(NGC_all)
#
clean : ise_clean
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
endif
#
